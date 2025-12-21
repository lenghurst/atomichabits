import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/ai_model_config.dart';

/// Gemini Live API Service for Real-Time Voice Interaction
/// 
/// Phase 27.11: "The Build Fix" - Revert to URL Auth for Compatibility
/// 
/// Changes:
/// 1. Fixed build error by removing `headers` from WebSocketChannel.connect
/// 2. Restored URL-based authentication (?key= or ?access_token=)
/// 3. Preserved the "Handshake" logic (waiting for SetupComplete)
/// 4. Preserved the Global Model logic (gemini-2.0-flash-exp)
class GeminiLiveService {
  // === CONFIGURATION ===
  
  /// Gemini Live API WebSocket endpoint
  /// Note: We use v1alpha as required for ephemeral tokens/raw key auth
  static const String _wsEndpoint = 'wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1alpha.GenerativeService.BidiGenerateContent';
  
  /// Supabase Edge Function for ephemeral token
  static const String _tokenEndpoint = 'get-gemini-ephemeral-token';
  
  // === CIRCUIT BREAKER CONFIGURATION ===
  static const int _maxFailures = 3;
  static const int _failureWindowSeconds = 10;
  static const int _circuitCooldownSeconds = 30;
  static const int _maxReconnectAttempts = 5;
  static const int _baseReconnectDelayMs = 1000;
  
  // === STATE ===
  
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  bool _isConnected = false;
  bool _isListening = false;
  bool _setupComplete = false; 
  String? _ephemeralToken;
  DateTime? _tokenExpiry;
  
  /// Completer to wait for the server's handshake response
  Completer<void>? _setupCompleter;
  
  /// Flag to indicate if using raw API key (vs OAuth token)
  bool _isUsingApiKey = false;
  
  /// Current session ID for resumption
  String? _sessionId;
  
  /// Stored system instruction for reconnection
  String? _lastSystemInstruction;
  bool _lastEnableTranscription = true;
  
  // === TRANSCRIPT BUFFER ===
  final List<String> _inputTranscriptBuffer = [];
  final List<String> _outputTranscriptBuffer = [];
  static const int _maxTranscriptBufferSize = 20;
  
  // === CIRCUIT BREAKER STATE ===
  final List<DateTime> _failureTimestamps = [];
  CircuitBreakerState _circuitState = CircuitBreakerState.closed;
  DateTime? _circuitOpenedAt;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  bool _hasFallenBackToText = false;
  
  // === CALLBACKS ===
  final void Function(Uint8List audioData)? onAudioReceived;
  final void Function(String text, bool isInput)? onTranscription;
  final void Function(bool isSpeaking)? onModelSpeakingChanged;
  final void Function(LiveConnectionState state)? onConnectionStateChanged;
  final void Function(String error)? onError;
  final void Function()? onTurnComplete;
  final void Function()? onFallbackToTextMode;
  final void Function()? onVoiceModeRestored;
  final void Function(bool isActive)? onVoiceActivityDetected;
  
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
  
  // === PUBLIC API ===
  
  bool get isConnected => _isConnected;
  bool get isListening => _isListening;
  bool get isInTextFallbackMode => _hasFallenBackToText;
  CircuitBreakerState get circuitState => _circuitState;
  
  Future<bool> connect({
    String? systemInstruction,
    bool enableTranscription = true,
  }) async {
    _lastSystemInstruction = systemInstruction;
    _lastEnableTranscription = enableTranscription;
    
    if (!_canAttemptConnection()) {
      if (kDebugMode) debugPrint('GeminiLiveService: Circuit breaker OPEN - falling back to text mode');
      _triggerTextFallback();
      return false;
    }
    
    if (_isConnected) {
      debugPrint('GeminiLiveService: Already connected');
      return true;
    }
    
    _notifyConnectionState(LiveConnectionState.connecting);
    
    try {
      // Step 1: Get Token
      final token = await _getEphemeralToken();
      if (token == null) {
        _recordFailure();
        _notifyError('Failed to obtain ephemeral token');
        _notifyConnectionState(LiveConnectionState.disconnected);
        return false;
      }
      
      // Step 2: Build URL with Auth Parameters (FIXED: Moved from headers to URL)
      String wsUrl = _wsEndpoint;
      if (_isUsingApiKey) {
        // Use 'key' for API Keys
        wsUrl += '?key=$token';
      } else {
        // Use 'access_token' for OAuth
        wsUrl += '?access_token=$token';
      }
      
      if (kDebugMode) {
        debugPrint('GeminiLiveService: Connecting to WebSocket...');
        debugPrint('GeminiLiveService: Auth method: ${_isUsingApiKey ? "API Key (URL param)" : "OAuth Token (URL param)"}');
      }
      
      // Step 3: Connect to WebSocket (Generic constructor, no headers)
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      // Step 4: Set up Listener
      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: (error) {
          debugPrint('GeminiLiveService: WebSocket error: $error');
          _recordFailure();
          _handleDisconnection(wasError: true);
        },
        onDone: () {
          final closeCode = _channel?.closeCode;
          final closeReason = _channel?.closeReason;
          debugPrint('GeminiLiveService: WebSocket closed. Code: $closeCode, Reason: $closeReason');
          _handleDisconnection(wasError: false);
        },
      );
      
      // Step 5: Send Setup Message
      await _sendSetupMessage(
        systemInstruction: systemInstruction,
        enableTranscription: enableTranscription,
      );
      
      // Step 6: Wait for Handshake
      try {
        await _waitForSetupComplete();
      } catch (e) {
        debugPrint('GeminiLiveService: Handshake failed: $e');
        _recordFailure();
        _channel?.sink.close();
        _handleDisconnection(wasError: true);
        return false;
      }
      
      _isConnected = true;
      _reconnectAttempts = 0;
      _notifyConnectionState(LiveConnectionState.connected);
      
      if (_hasFallenBackToText) {
        _hasFallenBackToText = false;
        onVoiceModeRestored?.call();
      }
      
      if (kDebugMode) {
        debugPrint('GeminiLiveService: Connected to ${AIModelConfig.tier2Model} (v1alpha)');
      }
      
      return true;
      
    } catch (e) {
      debugPrint('GeminiLiveService: Connection failed: $e');
      _recordFailure();
      _notifyError('Connection failed: $e');
      _notifyConnectionState(LiveConnectionState.disconnected);
      _scheduleReconnect();
      return false;
    }
  }
  
  Future<void> disconnect() async {
    _cancelReconnect();
    await _disconnect();
  }
  
  void sendAudio(Uint8List audioData) {
    if (_hasFallenBackToText || !_isConnected || _channel == null) return;
    
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
      _recordFailure();
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
      _recordFailure();
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
  
  void notifyVoiceActivityDetected(bool isActive) {
    onVoiceActivityDetected?.call(isActive);
    if (isActive && _isConnected) interrupt();
  }
  
  void startListening() {
    _isListening = true;
    if (kDebugMode) debugPrint('GeminiLiveService: Started listening');
  }
  
  void stopListening() {
    _isListening = false;
    if (kDebugMode) debugPrint('GeminiLiveService: Stopped listening');
  }
  
  void resetCircuitBreaker() {
    _circuitState = CircuitBreakerState.closed;
    _failureTimestamps.clear();
    _circuitOpenedAt = null;
    _reconnectAttempts = 0;
    _hasFallenBackToText = false;
    if (kDebugMode) debugPrint('GeminiLiveService: Circuit breaker manually reset');
  }
  
  Future<bool> attemptVoiceModeRestore() async {
    if (!_hasFallenBackToText) return true;
    
    if (_circuitOpenedAt != null) {
      final elapsed = DateTime.now().difference(_circuitOpenedAt!).inSeconds;
      if (elapsed < _circuitCooldownSeconds) return false;
    }
    
    _circuitState = CircuitBreakerState.halfOpen;
    final success = await connect(
      systemInstruction: _lastSystemInstruction,
      enableTranscription: _lastEnableTranscription,
    );
    
    if (success) {
      _circuitState = CircuitBreakerState.closed;
    } else {
      _circuitState = CircuitBreakerState.open;
      _circuitOpenedAt = DateTime.now();
    }
    
    return success;
  }
  
  String getFailoverContext() {
    if (_inputTranscriptBuffer.isEmpty && _outputTranscriptBuffer.isEmpty) return '';
    final buffer = StringBuffer();
    buffer.writeln('--- Conversation Context (Voice Session) ---');
    final maxLen = _inputTranscriptBuffer.length > _outputTranscriptBuffer.length
        ? _inputTranscriptBuffer.length
        : _outputTranscriptBuffer.length;
    
    for (int i = 0; i < maxLen; i++) {
      if (i < _inputTranscriptBuffer.length) buffer.writeln('User: ${_inputTranscriptBuffer[i]}');
      if (i < _outputTranscriptBuffer.length) buffer.writeln('Coach: ${_outputTranscriptBuffer[i]}');
    }
    buffer.writeln('--- End Context ---');
    return buffer.toString();
  }
  
  String? getLastUserMessage() => _inputTranscriptBuffer.isEmpty ? null : _inputTranscriptBuffer.last;
  String? getLastAiMessage() => _outputTranscriptBuffer.isEmpty ? null : _outputTranscriptBuffer.last;
  void clearTranscriptBuffers() {
    _inputTranscriptBuffer.clear();
    _outputTranscriptBuffer.clear();
  }
  
  // === PRIVATE METHODS ===
  
  Future<void> _waitForSetupComplete() async {
    _setupCompleter = Completer<void>();
    final timeout = Timer(const Duration(seconds: 10), () {
      if (_setupCompleter != null && !_setupCompleter!.isCompleted) {
        _setupCompleter!.completeError('Setup timeout - server did not respond within 10 seconds');
      }
    });
    
    try {
      await _setupCompleter!.future;
      timeout.cancel();
      if (kDebugMode) debugPrint('GeminiLiveService: Handshake successful - SetupComplete received');
    } catch (e) {
      timeout.cancel();
      rethrow;
    } finally {
      _setupCompleter = null;
    }
  }

  bool _canAttemptConnection() {
    final cutoff = DateTime.now().subtract(Duration(seconds: _failureWindowSeconds));
    _failureTimestamps.removeWhere((t) => t.isBefore(cutoff));
    
    switch (_circuitState) {
      case CircuitBreakerState.closed:
        return true;
      case CircuitBreakerState.open:
        if (_circuitOpenedAt != null) {
          final elapsed = DateTime.now().difference(_circuitOpenedAt!).inSeconds;
          if (elapsed >= _circuitCooldownSeconds) {
            _circuitState = CircuitBreakerState.halfOpen;
            return true;
          }
        }
        return false;
      case CircuitBreakerState.halfOpen:
        return true;
    }
  }
  
  void _recordFailure() {
    _failureTimestamps.add(DateTime.now());
    final cutoff = DateTime.now().subtract(Duration(seconds: _failureWindowSeconds));
    _failureTimestamps.removeWhere((t) => t.isBefore(cutoff));
    
    if (_failureTimestamps.length >= _maxFailures) {
      _openCircuit();
    }
  }
  
  void _openCircuit() {
    _circuitState = CircuitBreakerState.open;
    _circuitOpenedAt = DateTime.now();
    if (kDebugMode) debugPrint('GeminiLiveService: Circuit breaker OPENED - too many failures');
    _triggerTextFallback();
  }
  
  void _triggerTextFallback() {
    if (!_hasFallenBackToText) {
      _hasFallenBackToText = true;
      onFallbackToTextMode?.call();
    }
  }
  
  void _addToTranscriptBuffer(List<String> buffer, String text) {
    buffer.add(text);
    while (buffer.length > _maxTranscriptBufferSize) {
      buffer.removeAt(0);
    }
  }
  
  void _handleDisconnection({required bool wasError}) {
    _isConnected = false;
    _isListening = false;
    _setupComplete = false;
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
    
    if (wasError) {
      _notifyError('Connection lost');
      _scheduleReconnect();
    }
    _notifyConnectionState(LiveConnectionState.disconnected);
  }
  
  void _scheduleReconnect() {
    if (!_canAttemptConnection()) return;
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      if (kDebugMode) debugPrint('GeminiLiveService: Max reconnect attempts reached');
      _recordFailure();
      return;
    }
    _reconnectAttempts++;
    final baseDelay = _baseReconnectDelayMs * (1 << (_reconnectAttempts - 1));
    final jitter = (baseDelay * 0.2 * (DateTime.now().millisecond / 1000)).round();
    final delay = Duration(milliseconds: baseDelay + jitter);
    
    if (kDebugMode) debugPrint('GeminiLiveService: Scheduling reconnect attempt $_reconnectAttempts in ${delay.inMilliseconds}ms');
    _notifyConnectionState(LiveConnectionState.reconnecting);
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () async {
      await connect(
        systemInstruction: _lastSystemInstruction,
        enableTranscription: _lastEnableTranscription,
      );
    });
  }
  
  void _cancelReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }
  
  Future<String?> _getEphemeralToken() async {
    if (_ephemeralToken != null && _tokenExpiry != null && 
        _tokenExpiry!.isAfter(DateTime.now().add(const Duration(minutes: 5)))) {
      return _ephemeralToken;
    }
    try {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;
      
      if (session == null) {
        if (kDebugMode && AIModelConfig.hasGeminiKey) {
          debugPrint('GeminiLiveService: DEV MODE - Using Gemini API key directly (no auth)');
          _ephemeralToken = AIModelConfig.geminiApiKey;
          _tokenExpiry = DateTime.now().add(const Duration(hours: 24));
          _isUsingApiKey = true;
          return _ephemeralToken;
        }
        return null;
      }
      
      final response = await supabase.functions.invoke(
        _tokenEndpoint,
        body: {'lockToConfig': true},
      );
      
      if (response.status != 200) {
        if (kDebugMode && AIModelConfig.hasGeminiKey) {
          debugPrint('GeminiLiveService: DEV MODE FALLBACK - Using Gemini API key directly');
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
      if (kDebugMode && AIModelConfig.hasGeminiKey) {
        debugPrint('GeminiLiveService: DEV MODE FALLBACK (Error) - Using Gemini API key directly');
        _ephemeralToken = AIModelConfig.geminiApiKey;
        _tokenExpiry = DateTime.now().add(const Duration(hours: 24));
        _isUsingApiKey = true;
        return _ephemeralToken;
      }
      return null;
    }
  }
  
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
                'voiceName': 'Kore',
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
        'sessionResumption': {},
      }
    };
    
    _channel!.sink.add(jsonEncode(setupConfig));
  }
  
  void _handleMessage(dynamic message) {
    try {
      if (kDebugMode) debugPrint('GeminiLiveService RX: $message');
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      
      if (data.containsKey('setupComplete')) {
        if (kDebugMode) debugPrint('GeminiLiveService: SetupComplete received from server');
        _setupComplete = true;
        if (_setupCompleter != null && !_setupCompleter!.isCompleted) {
          _setupCompleter!.complete();
        }
        return;
      }
      
      if (data.containsKey('serverContent')) {
        final serverContent = data['serverContent'] as Map<String, dynamic>;
        
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
        
        if (serverContent.containsKey('outputTranscription')) {
          final transcription = serverContent['outputTranscription'] as Map<String, dynamic>;
          final text = transcription['text'] as String?;
          if (text != null && text.isNotEmpty) {
            _addToTranscriptBuffer(_outputTranscriptBuffer, text);
            onTranscription?.call(text, false);
          }
        }
        
        if (serverContent.containsKey('inputTranscription')) {
          final transcription = serverContent['inputTranscription'] as Map<String, dynamic>;
          final text = transcription['text'] as String?;
          if (text != null && text.isNotEmpty) {
            _addToTranscriptBuffer(_inputTranscriptBuffer, text);
            onTranscription?.call(text, true);
          }
        }
        
        if (serverContent['turnComplete'] == true) {
          onModelSpeakingChanged?.call(false);
          onTurnComplete?.call();
        }
        
        if (serverContent['interrupted'] == true) {
          onModelSpeakingChanged?.call(false);
          if (kDebugMode) debugPrint('GeminiLiveService: Model interrupted');
        }
      }
      
      if (data.containsKey('sessionResumptionUpdate')) {
        final update = data['sessionResumptionUpdate'] as Map<String, dynamic>;
        _sessionId = update['newHandle'] as String?;
      }
      
      if (data.containsKey('error')) {
        final error = data['error'] as Map<String, dynamic>;
        final errorMessage = error['message'] as String? ?? 'Unknown error';
        _notifyError(errorMessage);
        _recordFailure();
      }
      
    } catch (e) {
      debugPrint('GeminiLiveService: Failed to parse message: $e');
    }
  }
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
  
  void _notifyConnectionState(LiveConnectionState state) {
    onConnectionStateChanged?.call(state);
  }
  
  void _notifyError(String error) {
    onError?.call(error);
    if (kDebugMode) debugPrint('GeminiLiveService: Error - $error');
  }
  
  void dispose() {
    _cancelReconnect();
    _disconnect();
  }
}

enum LiveConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

enum CircuitBreakerState {
  closed,
  open,
  halfOpen,
}

extension LiveConnectionStateExtension on LiveConnectionState {
  String get displayName {
    switch (this) {
      case LiveConnectionState.disconnected: return 'Disconnected';
      case LiveConnectionState.connecting: return 'Connecting...';
      case LiveConnectionState.connected: return 'Connected';
      case LiveConnectionState.reconnecting: return 'Reconnecting...';
    }
  }
  bool get isActive => this == LiveConnectionState.connected;
}

extension CircuitBreakerStateExtension on CircuitBreakerState {
  String get displayName {
    switch (this) {
      case CircuitBreakerState.closed: return 'Healthy';
      case CircuitBreakerState.open: return 'Degraded (Text Mode)';
      case CircuitBreakerState.halfOpen: return 'Recovering';
    }
  }
}
