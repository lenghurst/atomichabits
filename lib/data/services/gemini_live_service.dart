import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/ai_model_config.dart';

/// Gemini Live API Service for Real-Time Voice Interaction
/// 
/// Phase 25.3: "The Voice Engine" - Raw WebSocket Implementation
/// 
/// Architecture:
/// 1. Client requests ephemeral token from Supabase Edge Function
/// 2. Client connects to Gemini Live API via WebSocket
/// 3. Bidirectional audio streaming (PCM 16-bit)
/// 
/// Audio Specifications:
/// - Input: 16kHz, 16-bit PCM, mono
/// - Output: 24kHz, 16-bit PCM, mono
/// 
/// Marketing vs Technical:
/// - UI displays: "Gemini 3 Flash Voice"
/// - API calls: "gemini-2.5-flash-native-audio-preview-12-2025"
class GeminiLiveService {
  // === CONFIGURATION ===
  
  /// Gemini Live API WebSocket base URL
  static const String _baseWsUrl = 'wss://generativelanguage.googleapis.com';
  
  /// API version for Live API (requires v1alpha for ephemeral tokens)
  static const String _apiVersion = 'v1alpha';
  
  /// Supabase Edge Function for ephemeral token
  static const String _tokenEndpoint = 'get-gemini-ephemeral-token';
  
  // === STATE ===
  
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  bool _isConnected = false;
  bool _isListening = false;
  String? _ephemeralToken;
  DateTime? _tokenExpiry;
  
  /// Current session ID for resumption
  String? _sessionId;
  
  // === CALLBACKS ===
  
  /// Called when audio data is received from the model
  final void Function(Uint8List audioData)? onAudioReceived;
  
  /// Called when text transcription is received
  final void Function(String text, bool isInput)? onTranscription;
  
  /// Called when the model starts/stops speaking
  final void Function(bool isSpeaking)? onModelSpeakingChanged;
  
  /// Called when connection state changes
  final void Function(LiveConnectionState state)? onConnectionStateChanged;
  
  /// Called on error
  final void Function(String error)? onError;
  
  /// Called when turn is complete (model finished responding)
  final void Function()? onTurnComplete;
  
  GeminiLiveService({
    this.onAudioReceived,
    this.onTranscription,
    this.onModelSpeakingChanged,
    this.onConnectionStateChanged,
    this.onError,
    this.onTurnComplete,
  });
  
  // === PUBLIC API ===
  
  /// Check if connected to Live API
  bool get isConnected => _isConnected;
  
  /// Check if actively listening to audio
  bool get isListening => _isListening;
  
  /// Connect to Gemini Live API
  /// 
  /// [systemInstruction] - Optional system prompt for the session
  /// [enableTranscription] - Whether to receive text transcriptions
  Future<bool> connect({
    String? systemInstruction,
    bool enableTranscription = true,
  }) async {
    if (_isConnected) {
      debugPrint('GeminiLiveService: Already connected');
      return true;
    }
    
    _notifyConnectionState(LiveConnectionState.connecting);
    
    try {
      // Step 1: Get ephemeral token from Supabase Edge Function
      final token = await _getEphemeralToken();
      if (token == null) {
        _notifyError('Failed to obtain ephemeral token');
        _notifyConnectionState(LiveConnectionState.disconnected);
        return false;
      }
      
      // Step 2: Build WebSocket URL
      final wsUrl = _buildWebSocketUrl(token);
      
      // Step 3: Connect to WebSocket
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      // Step 4: Set up message listener
      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: (error) {
          debugPrint('GeminiLiveService: WebSocket error: $error');
          _notifyError('Connection error: $error');
          _disconnect();
        },
        onDone: () {
          debugPrint('GeminiLiveService: WebSocket closed');
          _disconnect();
        },
      );
      
      // Step 5: Send setup message
      await _sendSetupMessage(
        systemInstruction: systemInstruction,
        enableTranscription: enableTranscription,
      );
      
      _isConnected = true;
      _notifyConnectionState(LiveConnectionState.connected);
      
      if (kDebugMode) {
        debugPrint('GeminiLiveService: Connected to ${AIModelConfig.tier2Model}');
        debugPrint('Marketing: "Gemini 3 Flash Voice" | Technical: "${AIModelConfig.tier2Model}"');
      }
      
      return true;
      
    } catch (e) {
      debugPrint('GeminiLiveService: Connection failed: $e');
      _notifyError('Connection failed: $e');
      _notifyConnectionState(LiveConnectionState.disconnected);
      return false;
    }
  }
  
  /// Disconnect from Live API
  Future<void> disconnect() async {
    await _disconnect();
  }
  
  /// Send audio data to the model
  /// 
  /// [audioData] - Raw PCM audio bytes (16-bit, 16kHz, mono)
  void sendAudio(Uint8List audioData) {
    if (!_isConnected || _channel == null) {
      debugPrint('GeminiLiveService: Cannot send audio - not connected');
      return;
    }
    
    // Encode audio as base64 for JSON transport
    final base64Audio = base64Encode(audioData);
    
    final message = jsonEncode({
      'realtimeInput': {
        'mediaChunks': [
          {
            'mimeType': AIModelConfig.audioInputMimeType,
            'data': base64Audio,
          }
        ]
      }
    });
    
    _channel!.sink.add(message);
  }
  
  /// Send text message to the model
  void sendText(String text, {bool turnComplete = true}) {
    if (!_isConnected || _channel == null) {
      debugPrint('GeminiLiveService: Cannot send text - not connected');
      return;
    }
    
    final message = jsonEncode({
      'clientContent': {
        'turns': [
          {
            'role': 'user',
            'parts': [{'text': text}]
          }
        ],
        'turnComplete': turnComplete,
      }
    });
    
    _channel!.sink.add(message);
  }
  
  /// Interrupt the model's current response
  /// 
  /// Call this when the user starts speaking while the model is responding.
  /// This implements "push-to-interrupt" for natural conversation flow.
  void interrupt() {
    if (!_isConnected || _channel == null) return;
    
    // Send empty realtime input to signal interruption
    final message = jsonEncode({
      'realtimeInput': {
        'mediaChunks': []
      }
    });
    
    _channel!.sink.add(message);
    
    if (kDebugMode) {
      debugPrint('GeminiLiveService: Sent interrupt signal');
    }
  }
  
  /// Start listening mode (begin VAD)
  void startListening() {
    _isListening = true;
    if (kDebugMode) {
      debugPrint('GeminiLiveService: Started listening');
    }
  }
  
  /// Stop listening mode (end VAD)
  void stopListening() {
    _isListening = false;
    if (kDebugMode) {
      debugPrint('GeminiLiveService: Stopped listening');
    }
  }
  
  // === PRIVATE METHODS ===
  
  /// Get ephemeral token from Supabase Edge Function
  Future<String?> _getEphemeralToken() async {
    // Check if we have a valid cached token
    if (_ephemeralToken != null && 
        _tokenExpiry != null && 
        _tokenExpiry!.isAfter(DateTime.now().add(const Duration(minutes: 5)))) {
      return _ephemeralToken;
    }
    
    try {
      final supabase = Supabase.instance.client;
      
      // Check if user is authenticated
      final session = supabase.auth.currentSession;
      if (session == null) {
        debugPrint('GeminiLiveService: User not authenticated');
        return null;
      }
      
      // Call Edge Function
      final response = await supabase.functions.invoke(
        _tokenEndpoint,
        body: {'lockToConfig': true},
      );
      
      if (response.status != 200) {
        debugPrint('GeminiLiveService: Token request failed: ${response.status}');
        return null;
      }
      
      final data = response.data as Map<String, dynamic>;
      _ephemeralToken = data['token'] as String?;
      _tokenExpiry = DateTime.parse(data['expiresAt'] as String);
      
      if (kDebugMode) {
        debugPrint('GeminiLiveService: Obtained ephemeral token, expires: $_tokenExpiry');
      }
      
      return _ephemeralToken;
      
    } catch (e) {
      debugPrint('GeminiLiveService: Failed to get ephemeral token: $e');
      return null;
    }
  }
  
  /// Build WebSocket URL with ephemeral token
  String _buildWebSocketUrl(String token) {
    // The ephemeral token is used as the API key in the URL
    return '$_baseWsUrl/$_apiVersion/models/${AIModelConfig.tier2Model}:streamGenerateContent?key=$token';
  }
  
  /// Send initial setup message to configure the session
  Future<void> _sendSetupMessage({
    String? systemInstruction,
    bool enableTranscription = true,
  }) async {
    final setupConfig = {
      'setup': {
        'model': 'models/${AIModelConfig.tier2Model}',
        'generationConfig': {
          'responseModalities': ['AUDIO'],
          'speechConfig': {
            'voiceConfig': {
              'prebuiltVoiceConfig': {
                'voiceName': 'Kore', // Default voice
              }
            }
          }
        },
        if (systemInstruction != null)
          'systemInstruction': {
            'parts': [{'text': systemInstruction}]
          },
        if (enableTranscription) ...{
          'outputAudioTranscription': {},
          'inputAudioTranscription': {},
        },
        // Enable session resumption for reconnection
        'sessionResumption': {},
      }
    };
    
    _channel!.sink.add(jsonEncode(setupConfig));
  }
  
  /// Handle incoming WebSocket messages
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      
      // Handle setup complete
      if (data.containsKey('setupComplete')) {
        if (kDebugMode) {
          debugPrint('GeminiLiveService: Setup complete');
        }
        return;
      }
      
      // Handle server content (model responses)
      if (data.containsKey('serverContent')) {
        final serverContent = data['serverContent'] as Map<String, dynamic>;
        
        // Handle model turn (audio response)
        if (serverContent.containsKey('modelTurn')) {
          final modelTurn = serverContent['modelTurn'] as Map<String, dynamic>;
          final parts = modelTurn['parts'] as List<dynamic>?;
          
          if (parts != null) {
            for (final part in parts) {
              final partMap = part as Map<String, dynamic>;
              
              // Handle audio data
              if (partMap.containsKey('inlineData')) {
                final inlineData = partMap['inlineData'] as Map<String, dynamic>;
                final mimeType = inlineData['mimeType'] as String?;
                final base64Data = inlineData['data'] as String?;
                
                if (mimeType?.startsWith('audio/') == true && base64Data != null) {
                  final audioBytes = base64Decode(base64Data);
                  onAudioReceived?.call(Uint8List.fromList(audioBytes));
                  onModelSpeakingChanged?.call(true);
                }
              }
            }
          }
        }
        
        // Handle output transcription
        if (serverContent.containsKey('outputTranscription')) {
          final transcription = serverContent['outputTranscription'] as Map<String, dynamic>;
          final text = transcription['text'] as String?;
          if (text != null && text.isNotEmpty) {
            onTranscription?.call(text, false);
          }
        }
        
        // Handle input transcription
        if (serverContent.containsKey('inputTranscription')) {
          final transcription = serverContent['inputTranscription'] as Map<String, dynamic>;
          final text = transcription['text'] as String?;
          if (text != null && text.isNotEmpty) {
            onTranscription?.call(text, true);
          }
        }
        
        // Handle turn complete
        if (serverContent['turnComplete'] == true) {
          onModelSpeakingChanged?.call(false);
          onTurnComplete?.call();
        }
        
        // Handle interruption
        if (serverContent['interrupted'] == true) {
          onModelSpeakingChanged?.call(false);
          if (kDebugMode) {
            debugPrint('GeminiLiveService: Model interrupted');
          }
        }
      }
      
      // Handle session resumption token
      if (data.containsKey('sessionResumptionUpdate')) {
        final update = data['sessionResumptionUpdate'] as Map<String, dynamic>;
        _sessionId = update['newHandle'] as String?;
        if (kDebugMode) {
          debugPrint('GeminiLiveService: Session ID updated: $_sessionId');
        }
      }
      
      // Handle errors
      if (data.containsKey('error')) {
        final error = data['error'] as Map<String, dynamic>;
        final message = error['message'] as String? ?? 'Unknown error';
        _notifyError(message);
      }
      
    } catch (e) {
      debugPrint('GeminiLiveService: Failed to parse message: $e');
    }
  }
  
  /// Disconnect and clean up
  Future<void> _disconnect() async {
    _isConnected = false;
    _isListening = false;
    
    await _subscription?.cancel();
    _subscription = null;
    
    await _channel?.sink.close();
    _channel = null;
    
    _notifyConnectionState(LiveConnectionState.disconnected);
    
    if (kDebugMode) {
      debugPrint('GeminiLiveService: Disconnected');
    }
  }
  
  /// Notify connection state change
  void _notifyConnectionState(LiveConnectionState state) {
    onConnectionStateChanged?.call(state);
  }
  
  /// Notify error
  void _notifyError(String error) {
    onError?.call(error);
    if (kDebugMode) {
      debugPrint('GeminiLiveService: Error - $error');
    }
  }
  
  /// Dispose resources
  void dispose() {
    _disconnect();
  }
}

/// Connection states for the Live API
enum LiveConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

/// Extension for LiveConnectionState display
extension LiveConnectionStateExtension on LiveConnectionState {
  String get displayName {
    switch (this) {
      case LiveConnectionState.disconnected:
        return 'Disconnected';
      case LiveConnectionState.connecting:
        return 'Connecting...';
      case LiveConnectionState.connected:
        return 'Connected';
      case LiveConnectionState.reconnecting:
        return 'Reconnecting...';
    }
  }
  
  bool get isActive {
    return this == LiveConnectionState.connected;
  }
}
