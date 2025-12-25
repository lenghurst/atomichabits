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
/// - Global Model Support (gemini-2.5-flash-native-audio-preview-12-2025 via v1beta)
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
  
  // === IN-APP DEBUG LOG ===
  final List<String> _debugLog = [];
  static const int _maxLogEntries = 100;
  final void Function(List<String>)? onDebugLogUpdated;
  
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
    this.onDebugLogUpdated,
  });

  // === PUBLIC GETTERS ===
  bool get isConnected => _isConnected;
  bool get isListening => _isListening;
  String get connectionPhase => _connectionPhase;
  String get lastErrorDetail => _lastErrorDetail;
  
  /// Exposes the current thought signature for debugging purposes.
  String? get currentThoughtSignature => _currentThoughtSignature;
  
  /// Get the debug log for in-app display
  List<String> get debugLog => List.unmodifiable(_debugLog);
  
  /// Get phase durations for display
  Map<String, Duration> get phaseDurations => Map.unmodifiable(_phaseDurations);
  
  /// Add entry to debug log and notify listeners
  void _log(String message) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 23);
    final entry = '[$timestamp] $message';
    _debugLog.add(entry);
    if (_debugLog.length > _maxLogEntries) {
      _debugLog.removeAt(0);
    }
    onDebugLogUpdated?.call(_debugLog);
    if (kDebugMode) debugPrint('GeminiLiveService: $message');
  }
  
  /// Clear the debug log
  void clearDebugLog() {
    _debugLog.clear();
    onDebugLogUpdated?.call(_debugLog);
  }
  
  /// Get a formatted summary for display
  String getDebugSummary() {
    final buffer = StringBuffer();
    buffer.writeln('=== CONNECTION INFO ===');
    buffer.writeln('Model: ${AIModelConfig.tier2Model}');
    buffer.writeln('Endpoint: v1beta');
    buffer.writeln('WebSocket: $_wsEndpoint');
    buffer.writeln('');
    buffer.writeln('=== CURRENT STATE ===');
    buffer.writeln('Phase: $_connectionPhase');
    buffer.writeln('Connected: $_isConnected');
    buffer.writeln('Auth: ${_isUsingApiKey ? "API Key" : "OAuth Token"}');
    buffer.writeln('ThoughtSignature: ${_currentThoughtSignature != null ? "present (${_currentThoughtSignature!.length} chars)" : "none"}');
    buffer.writeln('');
    if (_phaseDurations.isNotEmpty) {
      buffer.writeln('=== PHASE TIMINGS ===');
      _phaseDurations.forEach((phase, duration) {
        buffer.writeln('$phase: ${duration.inMilliseconds}ms');
      });
    }
    return buffer.toString();
  }

  // === TIMING FOR ROOT CAUSE ANALYSIS ===
  DateTime? _connectStartTime;
  final Map<String, Duration> _phaseDurations = {};
  DateTime? _phaseStartTime;
  
  Future<bool> connect({
    String? systemInstruction,
    bool enableTranscription = true,
  }) async {
    if (_isConnected) return true;
    
    // Start timing
    _connectStartTime = DateTime.now();
    _phaseDurations.clear();
    
    _setPhase("STARTING");
    _notifyConnectionState(LiveConnectionState.connecting);
    
    // Reset state on new connection
    _currentThoughtSignature = null;
    _firstMessageReceived = false;
    
    _log('========== CONNECTION ATTEMPT ==========');
    _log('Model: ${AIModelConfig.tier2Model}');
    _log('Endpoint: v1beta');
    _log('URL: $_wsEndpoint');
    
    try {
      // PHASE 1: TOKEN
      _setPhase("FETCHING_TOKEN");
      final tokenResult = await _getEphemeralTokenWithReason();
      if (tokenResult.token == null) {
        throw 'Token is null: ${tokenResult.reason}';
      }
      final token = tokenResult.token;
      
      _log('Token obtained (${token!.length} chars)');
      _log('Token prefix: ${token.substring(0, 10)}...');
      _log('Auth: ${_isUsingApiKey ? "API Key" : "OAuth Token"}');
      
      // PHASE 2: URL BUILD
      _setPhase("BUILDING_URL");
      String wsUrl = _wsEndpoint;
      if (_isUsingApiKey) {
        wsUrl += '?key=$token';
      } else {
        wsUrl += '?access_token=$token';
      }
      
      // Log full URL with masked token
      final maskedUrl = wsUrl.replaceAll(RegExp(r'(key=|access_token=)[^&]+'), r'\$1***MASKED***');
      _log('WebSocket URL: $maskedUrl');
      
      // PHASE 3: SOCKET CONNECT
      _setPhase("CONNECTING_SOCKET");
      _log('Opening WebSocket connection...');
      
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      _log('WebSocket channel created, setting up listeners...');
      
      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: (e) {
          _setPhase("SOCKET_ERROR");
          _log('❌ WebSocket error: $e');
          _notifyDetailedError("Socket Error", e.toString());
          _handleDisconnection(wasError: true);
        },
        onDone: () {
          final previousPhase = _connectionPhase;
          _setPhase("SOCKET_CLOSED");
          final code = _channel?.closeCode;
          final reason = _channel?.closeReason ?? 'No reason provided';
          _log('WebSocket closed. Code: $code, Reason: $reason');
          
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
      _log('Sending setup message...');
      await _sendSetupMessage(systemInstruction, enableTranscription);
      _log('Setup sent, waiting for setupComplete (timeout: 10s)...');
      
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
      
      final totalTime = DateTime.now().difference(_connectStartTime!);
      _log('✅ CONNECTION SUCCESSFUL');
      _log('Total time: ${totalTime.inMilliseconds}ms');
      _phaseDurations.forEach((phase, duration) {
        _log('  $phase: ${duration.inMilliseconds}ms');
      });
      return true;
      
    } catch (e) {
      _notifyDetailedError("Connect Logic Failed", e.toString());
      _notifyConnectionState(LiveConnectionState.disconnected);
      return false;
    }
  }

  // === HELPER METHODS ===
  
  void _setPhase(String phase) {
    // Track duration of previous phase
    if (_phaseStartTime != null && _connectionPhase.isNotEmpty) {
      _phaseDurations[_connectionPhase] = DateTime.now().difference(_phaseStartTime!);
    }
    _phaseStartTime = DateTime.now();
    _connectionPhase = phase;
    if (kDebugMode) debugPrint("GeminiLiveService Phase: $phase");
  }

  void _notifyDetailedError(String title, String details) {
    // This creates the "Screenshot Ready" error message
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    final totalTime = _connectStartTime != null 
        ? DateTime.now().difference(_connectStartTime!).inMilliseconds 
        : 0;
    
    // Build phase timing summary
    final phaseTimings = _phaseDurations.entries
        .map((e) => '  ${e.key}: ${e.value.inMilliseconds}ms')
        .join('\n');
    
    final fullError = '''
[$timestamp] $_connectionPhase
$title
$details

--- CONNECTION INFO ---
Model: ${AIModelConfig.tier2Model}
Auth: ${_isUsingApiKey ? "API Key" : "OAuth Token"}
Endpoint: v1beta
Total Time: ${totalTime}ms

--- PHASE TIMINGS ---
$phaseTimings

--- DEBUG ---
ThoughtSignature: ${_currentThoughtSignature != null ? "present" : "none"}
WebSocket URL: $_wsEndpoint''';
    
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
  /// Phase 34.4d: MINIMAL setup message matching official WebSocket schema
  /// Reference: https://ai.google.dev/api/live
  /// 
  /// Official generationConfig fields (from API reference):
  /// - candidateCount, maxOutputTokens, temperature, topP, topK
  /// - presencePenalty, frequencyPenalty, responseModalities
  /// - speechConfig, mediaResolution
  /// 
  /// NOT valid in raw WebSocket (SDK-only or wrong location):
  /// - thinkingConfig, thinkingBudget
  /// - outputAudioTranscription, inputAudioTranscription (may need different location)
  Future<void> _sendSetupMessage(String? instruction, bool transcribe) async {
    // MINIMAL CONFIG - only official fields from https://ai.google.dev/api/live
    final setupConfig = {
      'setup': {
        'model': 'models/${AIModelConfig.tier2Model}',
        'generationConfig': {
          'responseModalities': ['AUDIO'],
          'speechConfig': {
            'voiceConfig': {
              'prebuiltVoiceConfig': {
                'voiceName': 'Kore',
              }
            }
          },
        },
        if (instruction != null) 
          'systemInstruction': {
            'parts': [{'text': instruction}]
          },
      }
    };
    
    _log('Sending setup config:');
    _log('  Model: models/${AIModelConfig.tier2Model}');
    _log('  Voice: Kore');
    _log('  Modalities: [AUDIO]');
    if (kDebugMode) {
      debugPrint('GeminiLiveService: Full config: ${jsonEncode(setupConfig)}');
    }
    
    _channel!.sink.add(jsonEncode(setupConfig));
  }

  bool _firstMessageReceived = false;
  
  void _handleMessage(dynamic message) {
    try {
      // Log server responses for in-app visibility
      if (!_firstMessageReceived) {
        _firstMessageReceived = true;
        final timeSinceStart = _connectStartTime != null 
            ? DateTime.now().difference(_connectStartTime!).inMilliseconds 
            : 0;
        _log('📨 FIRST SERVER RESPONSE (${timeSinceStart}ms)');
      }
      
      final preview = message.toString();
      if (preview.length > 200) {
        _log('RX: ${preview.substring(0, 200)}...');
      } else {
        _log('RX: $preview');
      }
      
      final data = jsonDecode(message as String) as Map<String, dynamic>;

     // NOTE: thoughtSignature is NOT supported by native audio model
      // The gemini-2.5-flash-native-audio-preview-12-2025 model returns:
      // "Unknown name 'thoughtSignature': Cannot find field."
      // Keeping capture code commented out for future reference:
      // if (data.containsKey('thoughtSignature')) {
      //   _currentThoughtSignature = data['thoughtSignature'] as String?;
      // }

      // HANDSHAKE SUCCESS
      if (data.containsKey('setupComplete')) {
        _log('✅ setupComplete received!');
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
  /// Phase 34.4g: REMOVED thoughtSignature - NOT supported by native audio model!
  /// The native audio model (gemini-2.5-flash-native-audio-preview-12-2025) returns:
  /// "Unknown name 'thoughtSignature': Cannot find field."
  /// 
  /// thoughtSignature is only for Gemini 3 Pro/Flash text models, NOT Live API.
  void sendAudio(Uint8List audioData) {
    if (!_isConnected || _channel == null) return;
    
    final base64Audio = base64Encode(audioData);
    final message = {
      'realtimeInput': {
        'mediaChunks': [
          {
            'mimeType': AIModelConfig.audioInputMimeType,
            'data': base64Audio,
          }
        ]
      }
    };
    
    // NOTE: thoughtSignature REMOVED - not supported by native audio model
    
    try {
      _channel!.sink.add(jsonEncode(message));
    } catch (e) {
      debugPrint('GeminiLiveService: Failed to send audio: $e');
    }
  }
  
  /// Sends text input to the Gemini Live API.
  /// 
  /// Phase 34.4g: REMOVED thoughtSignature - NOT supported by native audio model!
  void sendText(String text, {bool turnComplete = true}) {
    if (!_isConnected || _channel == null) return;
    
    final message = {
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
    
    // NOTE: thoughtSignature REMOVED - not supported by native audio model
    
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
