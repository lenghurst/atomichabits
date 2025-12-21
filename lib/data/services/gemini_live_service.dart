import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/ai_model_config.dart';

/// Gemini Live API Service for Real-Time Voice Interaction
/// 
/// Phase 27.9: "The Handshake Fix" - Protocol Compliance & Auth Parameter Fix
/// 
/// Key Fixes in This Version:
/// 1. Auth Parameter: Use `key=` for API keys, `access_token=` for OAuth tokens
/// 2. API Version: Switched from v1beta to v1alpha (required for raw key auth)
/// 3. Protocol Compliance: Wait for SetupComplete before marking connected
/// 4. Enhanced Logging: Visibility into WebSocket close codes and all messages
/// 
/// Architecture:
/// 1. Client requests ephemeral token from Supabase Edge Function
/// 2. Client connects to Gemini Live API via WebSocket
/// 3. Client sends "Setup" message
/// 4. Client WAITS for "SetupComplete" (Critical Fix)
/// 5. Bidirectional audio streaming begins
/// 
/// Audio Specifications:
/// - Input: 16kHz, 16-bit PCM, mono
/// - Output: 24kHz, 16-bit PCM, mono
class GeminiLiveService {
  // === CONFIGURATION ===
  
  /// Gemini Live API WebSocket endpoint
  /// FIX: Switched to v1alpha as required for ephemeral tokens/raw key auth
  static const String _wsEndpoint = 'wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1alpha.GenerativeService.BidiGenerateContent';
  
  /// Supabase Edge Function for ephemeral token
  static const String _tokenEndpoint = 'get-gemini-ephemeral-token';
  
  // === CIRCUIT BREAKER CONFIGURATION ===
  
  /// Maximum failures before circuit opens
  static const int _maxFailures = 3;
  
  /// Time window for failure counting (seconds)
  static const int _failureWindowSeconds = 10;
  
  /// Cooldown period when circuit is open (seconds)
  static const int _circuitCooldownSeconds = 30;
  
  /// Maximum reconnection attempts before giving up
  static const int _maxReconnectAttempts = 5;
  
  /// Base delay for exponential backoff (milliseconds)
  static const int _baseReconnectDelayMs = 1000;
  
  // === STATE ===
  
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  bool _isConnected = false;
  bool _isListening = false;
  bool _setupComplete = false; // FIX: Track setup state
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
  
  // === TRANSCRIPT BUFFER (Phase 25.9 - Failover Context Preservation) ===
  
  /// Buffer of input transcriptions (user speech) for failover context
  final List<String> _inputTranscriptBuffer = [];
  
  /// Buffer of output transcriptions (AI speech) for failover context
  final List<String> _outputTranscriptBuffer = [];
  
  /// Maximum number of transcript entries to buffer
  static const int _maxTranscriptBufferSize = 20;
  
  // === CIRCUIT BREAKER STATE ===
  
  /// Failure timestamps for circuit breaker
  final List<DateTime> _failureTimestamps = [];
  
  /// Circuit breaker state
  CircuitBreakerState _circuitState = CircuitBreakerState.closed;
  
  /// When the circuit was opened (for cooldown calculation)
  DateTime? _circuitOpenedAt;
  
  /// Current reconnection attempt count
  int _reconnectAttempts = 0;
  
  /// Timer for reconnection attempts
  Timer? _reconnectTimer;
  
  /// Flag to indicate if we've fallen back to text mode
  bool _hasFallenBackToText = false;
  
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
  
  /// Called when service falls back to text mode (Circuit Breaker triggered)
  final void Function()? onFallbackToTextMode;
  
  /// Called when voice mode is restored after fallback
  final void Function()? onVoiceModeRestored;
  
  /// Called when VAD detects voice activity (for immediate UI feedback)
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
  
  /// Check if connected to Live API
  bool get isConnected => _isConnected;
  
  /// Check if actively listening to audio
  bool get isListening => _isListening;
  
  /// Check if circuit breaker has triggered fallback to text mode
  bool get isInTextFallbackMode => _hasFallenBackToText;
  
  /// Get current circuit breaker state
  CircuitBreakerState get circuitState => _circuitState;
  
  /// Connect to Gemini Live API
  /// 
  /// [systemInstruction] - Optional system prompt for the session
  /// [enableTranscription] - Whether to receive text transcriptions
  Future<bool> connect({
    String? systemInstruction,
    bool enableTranscription = true,
  }) async {
    // Store for reconnection
    _lastSystemInstruction = systemInstruction;
    _lastEnableTranscription = enableTranscription;
    
    // Check circuit breaker state
    if (!_canAttemptConnection()) {
      if (kDebugMode) {
        debugPrint('GeminiLiveService: Circuit breaker OPEN - falling back to text mode');
      }
      _triggerTextFallback();
      return false;
    }
    
    if (_isConnected) {
      debugPrint('GeminiLiveService: Already connected');
      return true;
    }
    
    _notifyConnectionState(LiveConnectionState.connecting);
    
    try {
      // Step 1: Get ephemeral token from Supabase Edge Function
      final token = await _getEphemeralToken();
      if (token == null) {
        _recordFailure();
        _notifyError('Failed to obtain ephemeral token');
        _notifyConnectionState(LiveConnectionState.disconnected);
        return false;
      }
      
      // Step 2: Build WebSocket URL (no auth parameters)
      final wsUrl = _wsEndpoint;
      if (kDebugMode) {
        debugPrint('GeminiLiveService: Connecting to WebSocket...');
        debugPrint('GeminiLiveService: Using ${_isUsingApiKey ? "API Key (header: x-goog-api-key)" : "OAuth Token (header: Authorization)"}');
      }
      
      // Step 3: Connect to WebSocket with header-based auth
      // FIX: Use headers instead of URL parameters for better compatibility
      _channel = WebSocketChannel.connect(
        Uri.parse(wsUrl),
        headers: {
          // Standard Google API Key Header (for raw API keys)
          if (_isUsingApiKey) 'x-goog-api-key': token,
          // OAuth Bearer Token Header (for ephemeral tokens)
          if (!_isUsingApiKey) 'Authorization': 'Bearer $token',
        },
      );
      
      // Step 4: Set up message listener with error handling
      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: (error) {
          debugPrint('GeminiLiveService: WebSocket error: $error');
          _recordFailure();
          _handleDisconnection(wasError: true);
        },
        onDone: () {
          // FIX: Enhanced logging for close codes
          final closeCode = _channel?.closeCode;
          final closeReason = _channel?.closeReason;
          debugPrint('GeminiLiveService: WebSocket closed. Code: $closeCode, Reason: $closeReason');
          _handleDisconnection(wasError: false);
        },
      );
      
      // Step 5: Send setup message
      await _sendSetupMessage(
        systemInstruction: systemInstruction,
        enableTranscription: enableTranscription,
      );
      
      // FIX: Wait for server handshake (SetupComplete)
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
      _reconnectAttempts = 0; // Reset on successful connection
      _notifyConnectionState(LiveConnectionState.connected);
      
      // If we were in fallback mode, restore voice mode
      if (_hasFallenBackToText) {
        _hasFallenBackToText = false;
        onVoiceModeRestored?.call();
      }
      
      if (kDebugMode) {
        debugPrint('GeminiLiveService: Connected to ${AIModelConfig.tier2Model} (v1alpha)');
        debugPrint('Marketing: "Gemini 3 Flash Voice" | Technical: "${AIModelConfig.tier2Model}"');
      }
      
      return true;
      
    } catch (e) {
      debugPrint('GeminiLiveService: Connection failed: $e');
      _recordFailure();
      _notifyError('Connection failed: $e');
      _notifyConnectionState(LiveConnectionState.disconnected);
      
      // Attempt reconnection if circuit is still closed
      _scheduleReconnect();
      
      return false;
    }
  }
  
  /// Disconnect from Live API
  Future<void> disconnect() async {
    _cancelReconnect();
    await _disconnect();
  }
  
  /// Send audio data to the model
  /// 
  /// [audioData] - Raw PCM audio bytes (16-bit, 16kHz, mono)
  void sendAudio(Uint8List audioData) {
    if (_hasFallenBackToText) {
      debugPrint('GeminiLiveService: In text fallback mode - audio disabled');
      return;
    }
    
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
    
    try {
      _channel!.sink.add(message);
    } catch (e) {
      debugPrint('GeminiLiveService: Failed to send audio: $e');
      _recordFailure();
    }
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
    
    try {
      _channel!.sink.add(message);
    } catch (e) {
      debugPrint('GeminiLiveService: Failed to send text: $e');
      _recordFailure();
    }
  }
  
  /// Interrupt the model's current response
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
  
  /// Notify that voice activity was detected (for VAD integration)
  void notifyVoiceActivityDetected(bool isActive) {
    onVoiceActivityDetected?.call(isActive);
    if (isActive && _isConnected) {
      interrupt();
    }
  }
  
  /// Start listening mode
  void startListening() {
    _isListening = true;
    if (kDebugMode) debugPrint('GeminiLiveService: Started listening');
  }
  
  /// Stop listening mode
  void stopListening() {
    _isListening = false;
    if (kDebugMode) debugPrint('GeminiLiveService: Stopped listening');
  }
  
  /// Manually reset the circuit breaker
  void resetCircuitBreaker() {
    _circuitState = CircuitBreakerState.closed;
    _failureTimestamps.clear();
    _circuitOpenedAt = null;
    _reconnectAttempts = 0;
    _hasFallenBackToText = false;
    if (kDebugMode) debugPrint('GeminiLiveService: Circuit breaker manually reset');
  }
  
  /// Attempt to restore voice mode after fallback
  Future<bool> attemptVoiceModeRestore() async {
    if (!_hasFallenBackToText) return true;
    
    if (_circuitOpenedAt != null) {
      final elapsed = DateTime.now().difference(_circuitOpenedAt!).inSeconds;
      if (elapsed < _circuitCooldownSeconds) {
        return false;
      }
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
  
  /// Get conversation context for failover to text mode
  String getFailoverContext() {
    if (_inputTranscriptBuffer.isEmpty && _outputTranscriptBuffer.isEmpty) {
      return '';
    }
    
    final buffer = StringBuffer();
    buffer.writeln('--- Conversation Context (Voice Session) ---');
    
    final maxLen = _inputTranscriptBuffer.length > _outputTranscriptBuffer.length
        ? _inputTranscriptBuffer.length
        : _outputTranscriptBuffer.length;
    
    for (int i = 0; i < maxLen; i++) {
      if (i < _inputTranscriptBuffer.length) {
        buffer.writeln('User: ${_inputTranscriptBuffer[i]}');
      }
      if (i < _outputTranscriptBuffer.length) {
        buffer.writeln('Coach: ${_outputTranscriptBuffer[i]}');
      }
    }
    
    buffer.writeln('--- End Context ---');
    return buffer.toString();
  }
  
  /// Get the last user message from transcript buffer
  String? getLastUserMessage() {
    return _inputTranscriptBuffer.isEmpty ? null : _inputTranscriptBuffer.last;
  }
  
  /// Get the last AI message from transcript buffer
  String? getLastAiMessage() {
    return _outputTranscriptBuffer.isEmpty ? null : _outputTranscriptBuffer.last;
  }
  
  /// Clear transcript buffers
  void clearTranscriptBuffers() {
    _inputTranscriptBuffer.clear();
    _outputTranscriptBuffer.clear();
  }
  
  // === PRIVATE METHODS ===
  
  /// Wait for setup complete message from server (Handshake)
  Future<void> _waitForSetupComplete() async {
    _setupCompleter = Completer<void>();
    
    // Timeout after 10 seconds
    final timeout = Timer(const Duration(seconds: 10), () {
      if (_setupCompleter != null && !_setupCompleter!.isCompleted) {
        _setupCompleter!.completeError('Setup timeout - server did not respond within 10 seconds');
      }
    });
    
    try {
      await _setupCompleter!.future;
      timeout.cancel();
      if (kDebugMode) {
        debugPrint('GeminiLiveService: Handshake successful - SetupComplete received');
      }
    } catch (e) {
      timeout.cancel();
      rethrow;
    } finally {
      _setupCompleter = null;
    }
  }
  
  /// Check if connection attempt is allowed by circuit breaker
  bool _canAttemptConnection() {
    // Clean up old failure timestamps
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
  
  /// Record a failure for circuit breaker
  void _recordFailure() {
    _failureTimestamps.add(DateTime.now());
    
    // Clean up old timestamps
    final cutoff = DateTime.now().subtract(Duration(seconds: _failureWindowSeconds));
    _failureTimestamps.removeWhere((t) => t.isBefore(cutoff));
    
    if (_failureTimestamps.length >= _maxFailures) {
      _openCircuit();
    }
  }
  
  /// Open the circuit breaker
  void _openCircuit() {
    _circuitState = CircuitBreakerState.open;
    _circuitOpenedAt = DateTime.now();
    if (kDebugMode) {
      debugPrint('GeminiLiveService: Circuit breaker OPENED - too many failures');
    }
    _triggerTextFallback();
  }
  
  /// Trigger fallback to text mode
  void _triggerTextFallback() {
    if (!_hasFallenBackToText) {
      _hasFallenBackToText = true;
      onFallbackToTextMode?.call();
    }
  }
  
  /// Add text to transcript buffer with size limit
  void _addToTranscriptBuffer(List<String> buffer, String text) {
    buffer.add(text);
    while (buffer.length > _maxTranscriptBufferSize) {
      buffer.removeAt(0);
    }
  }
  
  /// Handle disconnection
  void _handleDisconnection({required bool wasError}) {
    _isConnected = false;
    _isListening = false;
    _setupComplete = false; // Reset handshake state
    
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
  
  /// Schedule a reconnection attempt with exponential backoff
  void _scheduleReconnect() {
    if (!_canAttemptConnection()) return;
    
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      if (kDebugMode) {
        debugPrint('GeminiLiveService: Max reconnect attempts reached');
      }
      _recordFailure();
      return;
    }
    
    _reconnectAttempts++;
    
    // Exponential backoff with jitter
    final baseDelay = _baseReconnectDelayMs * (1 << (_reconnectAttempts - 1));
    final jitter = (baseDelay * 0.2 * (DateTime.now().millisecond / 1000)).round();
    final delay = Duration(milliseconds: baseDelay + jitter);
    
    if (kDebugMode) {
      debugPrint('GeminiLiveService: Scheduling reconnect attempt $_reconnectAttempts in ${delay.inMilliseconds}ms');
    }
    
    _notifyConnectionState(LiveConnectionState.reconnecting);
    
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () async {
      await connect(
        systemInstruction: _lastSystemInstruction,
        enableTranscription: _lastEnableTranscription,
      );
    });
  }
  
  /// Cancel any pending reconnection
  void _cancelReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }
  
  /// Get ephemeral token from Supabase Edge Function
  /// 
  /// DEV MODE: If user is not authenticated and we're in debug mode,
  /// use the Gemini API key directly (less secure but works for testing)
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
      
      // DEV MODE BYPASS: Use API key directly if not authenticated in debug mode
      if (session == null) {
        if (kDebugMode && AIModelConfig.hasGeminiKey) {
          debugPrint('GeminiLiveService: DEV MODE - Using Gemini API key directly (no auth)');
          _ephemeralToken = AIModelConfig.geminiApiKey;
          _tokenExpiry = DateTime.now().add(const Duration(hours: 24)); // Fake expiry
          _isUsingApiKey = true; // FIX: Track that we're using API key
          return _ephemeralToken;
        }
        debugPrint('GeminiLiveService: User not authenticated');
        return null;
      }
      
      // Call Edge Function (production flow)
      final response = await supabase.functions.invoke(
        _tokenEndpoint,
        body: {'lockToConfig': true},
      );
      
      if (response.status != 200) {
        debugPrint('GeminiLiveService: Token request failed: ${response.status}');
        // DEV MODE FALLBACK: If Edge Function fails, try API key directly
        if (kDebugMode && AIModelConfig.hasGeminiKey) {
          debugPrint('GeminiLiveService: DEV MODE FALLBACK - Using Gemini API key directly');
          _ephemeralToken = AIModelConfig.geminiApiKey;
          _tokenExpiry = DateTime.now().add(const Duration(hours: 24));
          _isUsingApiKey = true; // FIX: Track that we're using API key
          return _ephemeralToken;
        }
        return null;
      }
      
      final data = response.data as Map<String, dynamic>;
      _ephemeralToken = data['token'] as String?;
      _tokenExpiry = DateTime.parse(data['expiresAt'] as String);
      _isUsingApiKey = false; // Using OAuth token from Edge Function
      
      if (kDebugMode) {
        debugPrint('GeminiLiveService: Obtained ephemeral token, expires: $_tokenExpiry');
      }
      
      return _ephemeralToken;
      
    } catch (e) {
      debugPrint('GeminiLiveService: Failed to get ephemeral token: $e');
      // DEV MODE FALLBACK: If anything fails, try API key directly
      if (kDebugMode && AIModelConfig.hasGeminiKey) {
        debugPrint('GeminiLiveService: DEV MODE FALLBACK - Using Gemini API key directly after error');
        _ephemeralToken = AIModelConfig.geminiApiKey;
        _tokenExpiry = DateTime.now().add(const Duration(hours: 24));
        _isUsingApiKey = true; // FIX: Track that we're using API key
        return _ephemeralToken;
      }
      return null;
    }
  }
  
  /// Build WebSocket URL with correct auth parameter
  /// 
  /// DEPRECATED: Phase 27.10 switched to header-based auth for better compatibility
  /// This method is kept for reference but is no longer used.
  /// 
  /// Previous approach used URL parameters:
  /// - API keys: ?key=
  /// - OAuth tokens: ?access_token=
  /// 
  /// New approach (Phase 27.10) uses HTTP headers:
  /// - API keys: x-goog-api-key header
  /// - OAuth tokens: Authorization: Bearer header
  String _buildWebSocketUrl(String token) {
    // This method is deprecated - auth is now done via headers
    return _wsEndpoint;
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
    
    if (kDebugMode) {
      debugPrint('GeminiLiveService: Sending setup message for model: models/${AIModelConfig.tier2Model}');
    }
    
    _channel!.sink.add(jsonEncode(setupConfig));
  }
  
  /// Handle incoming WebSocket messages
  void _handleMessage(dynamic message) {
    try {
      // FIX: Log all incoming messages for debugging
      if (kDebugMode) {
        debugPrint('GeminiLiveService RX: $message');
      }
      
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      
      // FIX: Handle setup complete - complete the handshake
      if (data.containsKey('setupComplete')) {
        if (kDebugMode) {
          debugPrint('GeminiLiveService: SetupComplete received from server');
        }
        _setupComplete = true;
        if (_setupCompleter != null && !_setupCompleter!.isCompleted) {
          _setupCompleter!.complete();
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
            // Buffer for failover context preservation
            _addToTranscriptBuffer(_outputTranscriptBuffer, text);
            onTranscription?.call(text, false);
          }
        }
        
        // Handle input transcription
        if (serverContent.containsKey('inputTranscription')) {
          final transcription = serverContent['inputTranscription'] as Map<String, dynamic>;
          final text = transcription['text'] as String?;
          if (text != null && text.isNotEmpty) {
            // Buffer for failover context preservation
            _addToTranscriptBuffer(_inputTranscriptBuffer, text);
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
            debugPrint('GeminiLiveService: Model interrupted by user');
          }
        }
      }
      
      // Handle session resumption update
      if (data.containsKey('sessionResumptionUpdate')) {
        final update = data['sessionResumptionUpdate'] as Map<String, dynamic>;
        _sessionId = update['newHandle'] as String?;
        if (kDebugMode) {
          debugPrint('GeminiLiveService: Session ID updated: $_sessionId');
        }
      }
      
      // Handle tool calls (for future function calling support)
      if (data.containsKey('toolCall')) {
        if (kDebugMode) {
          debugPrint('GeminiLiveService: Tool call received (not yet implemented)');
        }
        // TODO: Implement tool call handling
      }
      
      // Handle tool call cancellation
      if (data.containsKey('toolCallCancellation')) {
        if (kDebugMode) {
          debugPrint('GeminiLiveService: Tool call cancelled');
        }
      }
      
      // Handle errors from server
      if (data.containsKey('error')) {
        final error = data['error'] as Map<String, dynamic>;
        final errorMessage = error['message'] as String? ?? 'Unknown error';
        final errorCode = error['code'] as int?;
        debugPrint('GeminiLiveService: Server error - Code: $errorCode, Message: $errorMessage');
        _notifyError(errorMessage);
        _recordFailure();
      }
      
    } catch (e, stackTrace) {
      debugPrint('GeminiLiveService: Failed to parse message: $e');
      if (kDebugMode) {
        debugPrint('GeminiLiveService: Stack trace: $stackTrace');
      }
    }
  }
  
  /// Disconnect from the WebSocket
  Future<void> _disconnect() async {
    _isConnected = false;
    _isListening = false;
    _setupComplete = false;
    
    await _subscription?.cancel();
    _subscription = null;
    
    await _channel?.sink.close();
    _channel = null;
    
    _notifyConnectionState(LiveConnectionState.disconnected);
    if (kDebugMode) {
      debugPrint('GeminiLiveService: Disconnected');
    }
  }
  
  /// Notify listeners of connection state change
  void _notifyConnectionState(LiveConnectionState state) {
    onConnectionStateChanged?.call(state);
  }
  
  /// Notify listeners of an error
  void _notifyError(String error) {
    onError?.call(error);
    if (kDebugMode) {
      debugPrint('GeminiLiveService: Error - $error');
    }
  }
  
  /// Dispose of resources
  void dispose() {
    _cancelReconnect();
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

/// Circuit breaker state for resilience
enum CircuitBreakerState {
  closed,
  open,
  halfOpen,
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

/// Extension for CircuitBreakerState display
extension CircuitBreakerStateExtension on CircuitBreakerState {
  String get displayName {
    switch (this) {
      case CircuitBreakerState.closed:
        return 'Healthy';
      case CircuitBreakerState.open:
        return 'Degraded (Text Mode)';
      case CircuitBreakerState.halfOpen:
        return 'Recovering';
    }
  }
}
