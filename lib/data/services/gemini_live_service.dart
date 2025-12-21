import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/ai_model_config.dart';

/// Gemini Live API Service - DEBUG EDITION (Phase 27.12)
/// 
/// Features:
/// - "Black Box" Phase Tracking (Records exactly where it fails)
/// - Detailed Error Reporting (Pastes codes/reasons into error message)
/// - Universal Auth (URL Parameters: ?key= or ?access_token=)
/// - Global Model Support (gemini-2.0-flash-exp via v1alpha)
/// 
/// When connection fails, the error message will include:
/// - [PHASE] Where exactly it failed
/// - Close Code (e.g., 1006 = Abnormal Closure)
/// - Close Reason (server's explanation)
/// - Model Name (to verify correct model is being used)
class GeminiLiveService {
  // === CONFIGURATION ===
  static const String _wsEndpoint = 'wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1alpha.GenerativeService.BidiGenerateContent';
  static const String _tokenEndpoint = 'get-gemini-ephemeral-token';
  
  // === STATE ===
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  bool _isConnected = false;
  bool _isListening = false;
  bool _setupComplete = false; 
  String? _ephemeralToken;
  DateTime? _tokenExpiry;
  Completer<void>? _setupCompleter;
  bool _isUsingApiKey = false;
  
  // === DEBUG STATE (The Black Box) ===
  String _connectionPhase = "IDLE"; // Tracks exactly what we were doing
  String _lastErrorDetail = "";     // The raw error for the screenshot
  
  // === CALLBACKS ===
  final void Function(Uint8List)? onAudioReceived;
  final void Function(String, bool)? onTranscription;
  final void Function(bool)? onModelSpeakingChanged;
  final void Function(LiveConnectionState)? onConnectionStateChanged;
  final void Function(String)? onError;
  final void Function()? onTurnComplete;
  final void Function()? onFallbackToTextMode;
  final void Function()? onVoiceModeRestored;
  final void Function(bool)? onVoiceActivityDetected;
  
  GeminiLiveService({
    this.onAudioReceived,
    this.onTranscription,
    this.onModelSpeakingChanged,
    this.onConnectionStateChanged,
    this.onError,
    this.onTurnComplete,
    this.onFallbackToTextMode,
    this.onVoiceModeRestored,
    this.onVoiceActivityDetected,
  });

  // === PUBLIC GETTERS ===
  bool get isConnected => _isConnected;
  bool get isListening => _isListening;
  String get connectionPhase => _connectionPhase;
  String get lastErrorDetail => _lastErrorDetail;

  Future<bool> connect({
    String? systemInstruction,
    bool enableTranscription = true,
  }) async {
    if (_isConnected) return true;
    _setPhase("STARTING");
    _notifyConnectionState(LiveConnectionState.connecting);
    
    try {
      // PHASE 1: TOKEN
      _setPhase("FETCHING_TOKEN");
      final token = await _getEphemeralToken();
      if (token == null) {
        throw 'Token is null (Check API Key in secrets.json)';
      }
      
      // PHASE 2: URL BUILD
      _setPhase("BUILDING_URL");
      String wsUrl = _wsEndpoint;
      if (_isUsingApiKey) {
        wsUrl += '?key=$token';
        if (kDebugMode) debugPrint('GeminiLiveService: Using API Key auth (key= param)');
      } else {
        wsUrl += '?access_token=$token';
        if (kDebugMode) debugPrint('GeminiLiveService: Using OAuth token auth (access_token= param)');
      }
      
      // PHASE 3: SOCKET CONNECT
      _setPhase("CONNECTING_SOCKET");
      if (kDebugMode) {
        debugPrint('GeminiLiveService: Connecting to WebSocket...');
        debugPrint('GeminiLiveService: Model: ${AIModelConfig.tier2Model}');
        debugPrint('GeminiLiveService: Endpoint: v1alpha');
      }
      
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: (e) {
          _setPhase("SOCKET_ERROR");
          debugPrint('GeminiLiveService: WebSocket error: $e');
          _notifyDetailedError("Socket Error", e.toString());
          _handleDisconnection(wasError: true);
        },
        onDone: () {
          final previousPhase = _connectionPhase;
          _setPhase("SOCKET_CLOSED");
          final code = _channel?.closeCode;
          final reason = _channel?.closeReason ?? 'No reason provided';
          debugPrint('GeminiLiveService: WebSocket closed. Code: $code, Reason: $reason');
          
          if (!_isConnected) {
            // If we weren't fully connected yet, this is a connection failure
            _notifyDetailedError(
              "Connection Closed During: $previousPhase", 
              "Code: $code | Reason: $reason"
            );
            _handleDisconnection(wasError: true);
          } else {
            _handleDisconnection(wasError: false);
          }
        },
      );
      
      // PHASE 4: SEND SETUP
      _setPhase("SENDING_HANDSHAKE");
      await _sendSetupMessage(systemInstruction, enableTranscription);
      if (kDebugMode) debugPrint('GeminiLiveService: Setup message sent, waiting for server...');
      
      // PHASE 5: WAIT FOR READY
      _setPhase("WAITING_FOR_SERVER_READY");
      try {
        await _waitForSetupComplete();
      } catch (e) {
        _setPhase("HANDSHAKE_TIMEOUT");
        _notifyDetailedError("Handshake Failed", e.toString());
        _channel?.sink.close();
        _notifyConnectionState(LiveConnectionState.disconnected);
        return false;
      }
      
      // PHASE 6: SUCCESS
      _setPhase("CONNECTED_STABLE");
      _isConnected = true;
      _notifyConnectionState(LiveConnectionState.connected);
      if (kDebugMode) debugPrint('GeminiLiveService: ✅ Handshake successful! Connected to ${AIModelConfig.tier2Model}');
      return true;
      
    } catch (e) {
      _notifyDetailedError("Connect Logic Failed", e.toString());
      _notifyConnectionState(LiveConnectionState.disconnected);
      return false;
    }
  }

  // === HELPER METHODS ===
  
  void _setPhase(String phase) {
    _connectionPhase = phase;
    if (kDebugMode) debugPrint("GeminiLiveService Phase: $phase");
  }

  void _notifyDetailedError(String title, String details) {
    // This creates the "Screenshot Ready" error message
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    final fullError = '''
[$timestamp] $_connectionPhase
$title
$details
Model: ${AIModelConfig.tier2Model}
Auth: ${_isUsingApiKey ? "API Key" : "OAuth Token"}
Endpoint: v1alpha''';
    
    _lastErrorDetail = fullError;
    onError?.call(fullError);
    if (kDebugMode) debugPrint("GeminiLiveService ERROR:\n$fullError");
  }
  
  Future<void> _waitForSetupComplete() async {
    _setupCompleter = Completer<void>();
    // Wait up to 10 seconds for the server to say "Ready"
    final timeout = Timer(const Duration(seconds: 10), () {
      if (_setupCompleter != null && !_setupCompleter!.isCompleted) {
        _setupCompleter!.completeError('Server did not send "setupComplete" within 10 seconds. This usually means: 1) Model name is wrong, 2) API Key is invalid, or 3) Region is blocked.');
      }
    });
    
    try {
      await _setupCompleter!.future;
      timeout.cancel();
    } catch (e) {
      timeout.cancel();
      rethrow;
    } finally {
      _setupCompleter = null;
    }
  }

  Future<void> _sendSetupMessage(String? instruction, bool transcribe) async {
    final setupConfig = {
      'setup': {
        'model': 'models/${AIModelConfig.tier2Model}',
        'generationConfig': {
          'responseModalities': ['AUDIO'], // camelCase per official docs
          'speechConfig': {
            'voiceConfig': {
              'prebuiltVoiceConfig': {
                'voiceName': 'Kore',
              }
            }
          }
        },
        if (instruction != null) 
          'systemInstruction': {
            'parts': [{'text': instruction}]
          },
        if (transcribe) ...{
          'outputAudioTranscription': {},
          'inputAudioTranscription': {},
        },
      }
    };
    _channel!.sink.add(jsonEncode(setupConfig));
  }

  void _handleMessage(dynamic message) {
    try {
      // Log ALL incoming messages in debug mode for visibility
      if (kDebugMode) {
        final preview = message.toString();
        if (preview.length > 200) {
          debugPrint('GeminiLiveService RX: ${preview.substring(0, 200)}...');
        } else {
          debugPrint('GeminiLiveService RX: $preview');
        }
      }
      
      final data = jsonDecode(message as String) as Map<String, dynamic>;

      // HANDSHAKE SUCCESS
      if (data.containsKey('setupComplete')) {
        if (kDebugMode) debugPrint('GeminiLiveService: ✅ SetupComplete received from server!');
        _setupComplete = true;
        _setupCompleter?.complete();
        return;
      }
      
      // Handle Server Content (Audio/Text)
      if (data.containsKey('serverContent')) {
        final serverContent = data['serverContent'] as Map<String, dynamic>;
        
        // Handle model turn (audio output)
        if (serverContent.containsKey('modelTurn')) {
          final modelTurn = serverContent['modelTurn'] as Map<String, dynamic>;
          final parts = modelTurn['parts'] as List<dynamic>?;
          
          if (parts != null) {
            for (final part in parts) {
              final partMap = part as Map<String, dynamic>;
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
          if (kDebugMode) debugPrint('GeminiLiveService: Model interrupted');
        }
      }
      
      // Handle errors from server
      if (data.containsKey('error')) {
        final error = data['error'] as Map<String, dynamic>;
        final errorMessage = error['message'] as String? ?? 'Unknown server error';
        final errorCode = error['code'] as int?;
        _notifyDetailedError("Server Error", "Code: $errorCode | $errorMessage");
      }
      
    } catch (e) {
      debugPrint('GeminiLiveService: Parse error: $e');
    }
  }

  Future<String?> _getEphemeralToken() async {
    // Check if we have a valid cached token
    if (_ephemeralToken != null && _tokenExpiry != null && 
        _tokenExpiry!.isAfter(DateTime.now().add(const Duration(minutes: 5)))) {
      return _ephemeralToken;
    }
    
    try {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;
      
      // DEV MODE BYPASS: Use API key directly if no session
      if (session == null) {
        if (kDebugMode && AIModelConfig.hasGeminiKey) {
          debugPrint('GeminiLiveService: DEV MODE - Using Gemini API key directly (no auth session)');
          _ephemeralToken = AIModelConfig.geminiApiKey;
          _tokenExpiry = DateTime.now().add(const Duration(hours: 24));
          _isUsingApiKey = true;
          return _ephemeralToken;
        }
        debugPrint('GeminiLiveService: No session and no API key available');
        return null;
      }
      
      // Try to get ephemeral token from Supabase Edge Function
      final response = await supabase.functions.invoke(
        _tokenEndpoint,
        body: {'lockToConfig': true},
      );
      
      if (response.status != 200) {
        // Fallback to API key in dev mode
        if (kDebugMode && AIModelConfig.hasGeminiKey) {
          debugPrint('GeminiLiveService: DEV MODE FALLBACK - Edge function failed, using API key');
          _ephemeralToken = AIModelConfig.geminiApiKey;
          _tokenExpiry = DateTime.now().add(const Duration(hours: 24));
          _isUsingApiKey = true;
          return _ephemeralToken;
        }
        return null;
      }
      
      final data = response.data as Map<String, dynamic>;
      _ephemeralToken = data['token'] as String?;
      _tokenExpiry = DateTime.parse(data['expiresAt'] as String);
      _isUsingApiKey = false;
      return _ephemeralToken;
      
    } catch (e) {
      // Fallback to API key in dev mode
      if (kDebugMode && AIModelConfig.hasGeminiKey) {
        debugPrint('GeminiLiveService: DEV MODE FALLBACK (Error: $e) - Using API key');
        _ephemeralToken = AIModelConfig.geminiApiKey;
        _tokenExpiry = DateTime.now().add(const Duration(hours: 24));
        _isUsingApiKey = true;
        return _ephemeralToken;
      }
      return null;
    }
  }

  // === PUBLIC METHODS ===

  Future<void> disconnect() async {
    await _disconnect();
  }

  Future<void> _disconnect() async {
    _isConnected = false;
    _isListening = false;
    _setupComplete = false;
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close();
    _channel = null;
    _notifyConnectionState(LiveConnectionState.disconnected);
    if (kDebugMode) debugPrint('GeminiLiveService: Disconnected');
  }

  void _handleDisconnection({required bool wasError}) {
    _isConnected = false;
    _isListening = false;
    _setupComplete = false;
    _subscription?.cancel();
    _subscription = null;
    _channel = null;
    _notifyConnectionState(LiveConnectionState.disconnected);
  }

  void _notifyConnectionState(LiveConnectionState state) {
    onConnectionStateChanged?.call(state);
  }
  
  void sendAudio(Uint8List audioData) {
    if (!_isConnected || _channel == null) return;
    
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
    
    try {
      _channel!.sink.add(message);
    } catch (e) {
      debugPrint('GeminiLiveService: Failed to send audio: $e');
    }
  }
  
  void sendText(String text, {bool turnComplete = true}) {
    if (!_isConnected || _channel == null) return;
    
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
    
    try {
      _channel!.sink.add(message);
    } catch (e) {
      debugPrint('GeminiLiveService: Failed to send text: $e');
    }
  }
  
  void interrupt() {
    if (!_isConnected || _channel == null) return;
    
    final message = jsonEncode({
      'realtimeInput': {
        'mediaChunks': []
      }
    });
    
    try {
      _channel!.sink.add(message);
      if (kDebugMode) debugPrint('GeminiLiveService: Sent interrupt signal');
    } catch (e) {
      debugPrint('GeminiLiveService: Failed to send interrupt: $e');
    }
  }

  void startListening() {
    _isListening = true;
    if (kDebugMode) debugPrint('GeminiLiveService: Started listening');
  }

  void stopListening() {
    _isListening = false;
    if (kDebugMode) debugPrint('GeminiLiveService: Stopped listening');
  }

  void dispose() {
    _disconnect();
  }
}

/// Connection state for the Live API
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
  
  bool get isActive => this == LiveConnectionState.connected;
}
