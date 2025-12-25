import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/ai_model_config.dart';

/// Gemini Live API Service - Phase 28: Gemini 3 Compliance
/// 
/// Features:
/// - "Black Box" Phase Tracking (Records exactly where it fails)
/// - Detailed Error Reporting (Pastes codes/reasons into error message)
/// - Universal Auth (URL Parameters: ?key= or ?access_token=)
/// - Global Model Support (gemini-live-2.5-flash-native-audio via v1alpha)
/// - **Gemini 3 Compliance:**
///   - Thought Signature handling (maintains conversational context)
///   - thinking_level: "minimal" (reduces latency for voice interactions)
///   - No temperature setting (prevents looping behaviour)
/// 
/// When connection fails, the error message will include:
/// - [PHASE] Where exactly it failed
/// - Close Code (e.g., 1006 = Abnormal Closure)
/// - Close Reason (server's explanation)
/// - Model Name (to verify correct model is being used)
class GeminiLiveService {
  // === CONFIGURATION ===
  // PHASE 34 FIX: Changed from v1alpha to v1beta per official Gemini API documentation
  // The December 2025 model requires v1beta endpoint
  static const String _wsEndpoint = 'wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateContent';
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
  
  // === GEMINI 3: THOUGHT SIGNATURE STATE ===
  /// Stores the encrypted reasoning context from the model.
  /// CRITICAL: Must be echoed back in subsequent messages to maintain context.
  /// Without this, the AI experiences "amnesia" after every turn.
  String? _currentThoughtSignature;
  
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
  final void Function(List<String> log)? onDebugLogUpdated;
  
  // === DEBUG LOG STATE ===
  final List<String> _debugLog = [];
  
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
    this.onDebugLogUpdated,
  });

  // === PUBLIC GETTERS ===
  bool get isConnected => _isConnected;
  bool get isListening => _isListening;
  
  /// Get the debug log entries
  List<String> get debugLog => List.unmodifiable(_debugLog);
  
  /// Clear the debug log
  void clearDebugLog() {
    _debugLog.clear();
    onDebugLogUpdated?.call(_debugLog);
  }
  
  /// Add an entry to the debug log
  void _addDebugLog(String entry) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    _debugLog.add('[$timestamp] $entry');
    if (_debugLog.length > 100) {
      _debugLog.removeAt(0); // Keep only last 100 entries
    }
    onDebugLogUpdated?.call(_debugLog);
  }
  String get connectionPhase => _connectionPhase;
  String get lastErrorDetail => _lastErrorDetail;
  
  /// Exposes the current thought signature for debugging purposes.
  String? get currentThoughtSignature => _currentThoughtSignature;

  Future<bool> connect({
    String? systemInstruction,
    bool enableTranscription = true,
  }) async {
    if (_isConnected) return true;
    _setPhase("STARTING");
    _notifyConnectionState(LiveConnectionState.connecting);
    
    // Reset thought signature on new connection
    _currentThoughtSignature = null;
    
    try {
      // PHASE 1: TOKEN
      _setPhase("FETCHING_TOKEN");
      final tokenResult = await _getEphemeralTokenWithReason();
      if (tokenResult.token == null) {
        throw 'Token is null: ${tokenResult.reason}';
      }
      final token = tokenResult.token;
      
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
        debugPrint('GeminiLiveService: Endpoint: v1beta (Phase 34 fix)');
        debugPrint('GeminiLiveService: Full URL: $wsUrl');
        debugPrint('GeminiLiveService: Gemini 3 Compliance: thinking_level=MINIMAL, thoughtSignature=enabled');
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
Endpoint: v1alpha
ThoughtSignature: ${_currentThoughtSignature != null ? "present" : "none"}''';
    
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

  /// Sends the initial setup message to the Gemini Live API.
  /// 
  /// Phase 28: Gemini 3 Compliance
  /// - Added `thinkingConfig` with `thinkingLevel: "MINIMAL"` to reduce latency.
  /// - Removed `temperature` setting to prevent looping behaviour.
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
          },
          // GEMINI 3 COMPLIANCE: Do NOT set temperature. 
          // Values < 1.0 cause "unexpected behavior, such as looping".
        },
        // GEMINI 3 COMPLIANCE: Set thinking level to minimal for voice.
        // This reduces server-side processing time and minimises "dead air".
        'thinkingConfig': {
          'thinkingLevel': 'MINIMAL',
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
    final payload = jsonEncode(setupConfig);
    
    // PHASE 34: Enhanced debug logging for handshake payload
    if (kDebugMode) {
      debugPrint('GeminiLiveService: === HANDSHAKE PAYLOAD ===');
      debugPrint('GeminiLiveService: Model: models/${AIModelConfig.tier2Model}');
      debugPrint('GeminiLiveService: thinkingConfig.thinkingLevel: MINIMAL');
      debugPrint('GeminiLiveService: responseModalities: [AUDIO]');
      debugPrint('GeminiLiveService: voiceName: Kore');
      debugPrint('GeminiLiveService: Full payload: $payload');
      debugPrint('GeminiLiveService: === END PAYLOAD ===');
    }
    
    _channel!.sink.add(payload);
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

      // GEMINI 3 COMPLIANCE: Capture Thought Signature
      // The thought signature is an encrypted string that stores the model's
      // reasoning state. It MUST be echoed back in subsequent messages.
      if (data.containsKey('thoughtSignature')) {
        _currentThoughtSignature = data['thoughtSignature'] as String?;
        if (kDebugMode) {
          debugPrint('GeminiLiveService: 🧠 Thought Signature captured (${_currentThoughtSignature?.length ?? 0} chars)');
        }
      }

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

  /// Result class for token fetching with detailed reason
  Future<_TokenResult> _getEphemeralTokenWithReason() async {
    // Check if we have a valid cached token
    if (_ephemeralToken != null && _tokenExpiry != null &&
        _tokenExpiry!.isAfter(DateTime.now().add(const Duration(minutes: 5)))) {
      return _TokenResult(_ephemeralToken, 'Cached token valid');
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
          return _TokenResult(_ephemeralToken, 'Dev mode API key');
        }
        debugPrint('GeminiLiveService: No session and no API key available');
        return _TokenResult(null, 'No Supabase session (not logged in) and no GEMINI_API_KEY in secrets.json for dev fallback');
      }

      // Try to get ephemeral token from Supabase Edge Function
      final response = await supabase.functions.invoke(
        _tokenEndpoint,
        body: {'lockToConfig': true},
      );

      if (response.status != 200) {
        final errorMsg = 'Edge function returned status ${response.status}';
        debugPrint('GeminiLiveService: $errorMsg');

        // Fallback to API key in dev mode
        if (kDebugMode && AIModelConfig.hasGeminiKey) {
          debugPrint('GeminiLiveService: DEV MODE FALLBACK - Edge function failed, using API key');
          _ephemeralToken = AIModelConfig.geminiApiKey;
          _tokenExpiry = DateTime.now().add(const Duration(hours: 24));
          _isUsingApiKey = true;
          return _TokenResult(_ephemeralToken, 'Dev fallback after edge function error');
        }
        return _TokenResult(null, '$errorMsg - check Supabase Edge Function logs');
      }

      final data = response.data as Map<String, dynamic>;
      _ephemeralToken = data['token'] as String?;

      if (_ephemeralToken == null || _ephemeralToken!.isEmpty) {
        return _TokenResult(null, 'Edge function returned empty token - check backend GEMINI_API_KEY');
      }

      _tokenExpiry = DateTime.parse(data['expiresAt'] as String);
      _isUsingApiKey = false;

      // Log the model returned by backend for debugging
      final backendModel = data['model'] as String?;
      if (kDebugMode) {
        debugPrint('GeminiLiveService: Backend token model: $backendModel');
        debugPrint('GeminiLiveService: Frontend model: ${AIModelConfig.tier2Model}');
        if (backendModel != null && backendModel != AIModelConfig.tier2Model) {
          debugPrint('GeminiLiveService: ⚠️ WARNING - Model mismatch detected!');
        }
      }

      return _TokenResult(_ephemeralToken, 'Ephemeral token from backend');

    } catch (e) {
      // Fallback to API key in dev mode
      if (kDebugMode && AIModelConfig.hasGeminiKey) {
        debugPrint('GeminiLiveService: DEV MODE FALLBACK (Error: $e) - Using API key');
        _ephemeralToken = AIModelConfig.geminiApiKey;
        _tokenExpiry = DateTime.now().add(const Duration(hours: 24));
        _isUsingApiKey = true;
        return _TokenResult(_ephemeralToken, 'Dev fallback after exception');
      }
      return _TokenResult(null, 'Exception: $e');
    }
  }

  // Legacy method for backwards compatibility
  Future<String?> _getEphemeralToken() async {
    final result = await _getEphemeralTokenWithReason();
    return result.token;
  }

  // === PUBLIC METHODS ===

  Future<void> disconnect() async {
    await _disconnect();
  }

  Future<void> _disconnect() async {
    _isConnected = false;
    _isListening = false;
    _setupComplete = false;
    _currentThoughtSignature = null; // Clear thought signature on disconnect
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
    // Note: We do NOT clear _currentThoughtSignature here to allow for reconnection
    _subscription?.cancel();
    _subscription = null;
    _channel = null;
    _notifyConnectionState(LiveConnectionState.disconnected);
  }

  void _notifyConnectionState(LiveConnectionState state) {
    onConnectionStateChanged?.call(state);
  }
  
  /// Sends audio data to the Gemini Live API.
  /// 
  /// Phase 28: Gemini 3 Compliance
  /// - Includes `thoughtSignature` if available to maintain context.
  void sendAudio(Uint8List audioData) {
    if (!_isConnected || _channel == null) return;
    
    final base64Audio = base64Encode(audioData);
    final Map<String, dynamic> message = {
      'realtimeInput': {
        'mediaChunks': [
          {
            'mimeType': AIModelConfig.audioInputMimeType,
            'data': base64Audio,
          }
        ]
      }
    };
    
    // GEMINI 3 COMPLIANCE: Echo back the thought signature
    if (_currentThoughtSignature != null) {
      message['thoughtSignature'] = _currentThoughtSignature;
    }
    
    try {
      _channel!.sink.add(jsonEncode(message));
    } catch (e) {
      debugPrint('GeminiLiveService: Failed to send audio: $e');
    }
  }
  
  /// Sends text input to the Gemini Live API.
  /// 
  /// Phase 28: Gemini 3 Compliance
  /// - Includes `thoughtSignature` if available to maintain context.
  void sendText(String text, {bool turnComplete = true}) {
    if (!_isConnected || _channel == null) return;
    
    final Map<String, dynamic> message = {
      'clientContent': {
        'turns': [
          {
            'role': 'user',
            'parts': [{'text': text}]
          }
        ],
        'turnComplete': turnComplete,
      }
    };
    
    // GEMINI 3 COMPLIANCE: Echo back the thought signature
    if (_currentThoughtSignature != null) {
      message['thoughtSignature'] = _currentThoughtSignature;
    }
    
    try {
      _channel!.sink.add(jsonEncode(message));
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

/// Internal helper class for token fetching results
class _TokenResult {
  final String? token;
  final String reason;

  _TokenResult(this.token, this.reason);
}
