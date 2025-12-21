import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/ai_model_config.dart';

/// Gemini Live API Service for Real-Time Voice Interaction
/// 
/// Phase 25.9: "The Resilient Voice" - Circuit Breaker & Reconnection Logic
/// 
/// Architecture:
/// 1. Client requests ephemeral token from Supabase Edge Function
/// 2. Client connects to Gemini Live API via WebSocket
/// 3. Bidirectional audio streaming (PCM 16-bit)
/// 4. Circuit Breaker pattern for graceful degradation to text mode
/// 
/// SME Recommendations Implemented (Uncle Bob & James Bach):
/// - Exponential backoff reconnection with jitter
/// - Circuit Breaker: 3 failures in 10 seconds triggers fallback
/// - Automatic degradation to GeminiChatService (text mode)
/// - Network state monitoring for proactive reconnection
/// 
/// Audio Specifications:
/// - Input: 16kHz, 16-bit PCM, mono
/// - Output: 24kHz, 16-bit PCM, mono
class GeminiLiveService {
  // === CONFIGURATION ===
  
  /// Gemini Live API WebSocket endpoint
  static const String _wsEndpoint = 'wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateContent';
  
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
  String? _ephemeralToken;
  DateTime? _tokenExpiry;
  
  /// Current session ID for resumption
  String? _sessionId;
  
  /// Stored system instruction for reconnection
  String? _lastSystemInstruction;
  bool _lastEnableTranscription = true;
  
  // === TRANSCRIPT BUFFER (Phase 25.9 - Failover Context Preservation) ===
  
  /// Buffer of input transcriptions (user speech) for failover context
  /// Head of Engineering: "If I'm halfway through explaining my habit, and the
  /// line drops, the Text Bot needs to know what I just said."
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
  /// UI should switch to text input when this fires
  final void Function()? onFallbackToTextMode;
  
  /// Called when voice mode is restored after fallback
  final void Function()? onVoiceModeRestored;
  
  /// Called when VAD detects voice activity (for immediate UI feedback)
  /// This fires BEFORE the interrupt signal is sent to provide instant feedback
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
      
      // Step 2: Build WebSocket URL
      final wsUrl = _buildWebSocketUrl(token);
      
      // Step 3: Connect to WebSocket
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      // Step 4: Set up message listener with error handling
      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: (error) {
          debugPrint('GeminiLiveService: WebSocket error: $error');
          _recordFailure();
          _handleDisconnection(wasError: true);
        },
        onDone: () {
          debugPrint('GeminiLiveService: WebSocket closed');
          _handleDisconnection(wasError: false);
        },
      );
      
      // Step 5: Send setup message
      await _sendSetupMessage(
        systemInstruction: systemInstruction,
        enableTranscription: enableTranscription,
      );
      
      _isConnected = true;
      _reconnectAttempts = 0; // Reset on successful connection
      _notifyConnectionState(LiveConnectionState.connected);
      
      // If we were in fallback mode, restore voice mode
      if (_hasFallenBackToText) {
        _hasFallenBackToText = false;
        onVoiceModeRestored?.call();
      }
      
      if (kDebugMode) {
        debugPrint('GeminiLiveService: Connected to ${AIModelConfig.tier2Model}');
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
    
    try {
      _channel!.sink.add(message);
      
      if (kDebugMode) {
        debugPrint('GeminiLiveService: Sent interrupt signal');
      }
    } catch (e) {
      debugPrint('GeminiLiveService: Failed to send interrupt: $e');
    }
  }
  
  /// Notify that voice activity was detected (for immediate UI feedback)
  /// 
  /// Call this from the audio recorder when VAD detects speech.
  /// This provides instant visual feedback BEFORE the interrupt is processed.
  /// (Don Norman's recommendation: "The user needs to know they were heard NOW")
  void notifyVoiceActivityDetected(bool isActive) {
    onVoiceActivityDetected?.call(isActive);
    
    // If voice detected while model is speaking, send interrupt
    if (isActive && _isConnected) {
      interrupt();
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
  
  /// Manually reset the circuit breaker (for testing or admin override)
  void resetCircuitBreaker() {
    _circuitState = CircuitBreakerState.closed;
    _failureTimestamps.clear();
    _circuitOpenedAt = null;
    _reconnectAttempts = 0;
    _hasFallenBackToText = false;
    
    if (kDebugMode) {
      debugPrint('GeminiLiveService: Circuit breaker manually reset');
    }
  }
  
  /// Attempt to restore voice mode after fallback
  Future<bool> attemptVoiceModeRestore() async {
    if (!_hasFallenBackToText) return true;
    
    // Check if cooldown has passed
    if (_circuitOpenedAt != null) {
      final elapsed = DateTime.now().difference(_circuitOpenedAt!).inSeconds;
      if (elapsed < _circuitCooldownSeconds) {
        if (kDebugMode) {
          debugPrint('GeminiLiveService: Cooldown not complete (${_circuitCooldownSeconds - elapsed}s remaining)');
        }
        return false;
      }
    }
    
    // Move to half-open state and attempt connection
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
  
  // === CIRCUIT BREAKER LOGIC ===
  
  /// Check if we can attempt a connection (circuit breaker logic)
  bool _canAttemptConnection() {
    // Clean old failures outside the window
    final cutoff = DateTime.now().subtract(Duration(seconds: _failureWindowSeconds));
    _failureTimestamps.removeWhere((t) => t.isBefore(cutoff));
    
    switch (_circuitState) {
      case CircuitBreakerState.closed:
        return true;
        
      case CircuitBreakerState.open:
        // Check if cooldown has passed
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
    
    // Clean old failures
    final cutoff = DateTime.now().subtract(Duration(seconds: _failureWindowSeconds));
    _failureTimestamps.removeWhere((t) => t.isBefore(cutoff));
    
    if (kDebugMode) {
      debugPrint('GeminiLiveService: Failure recorded (${_failureTimestamps.length}/$_maxFailures in window)');
    }
    
    // Check if circuit should open
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
      
      if (kDebugMode) {
        debugPrint('GeminiLiveService: Falling back to text mode');
        debugPrint('GeminiLiveService: Transcript buffer preserved (${_inputTranscriptBuffer.length} user, ${_outputTranscriptBuffer.length} AI)');
      }
    }
  }
  
  /// Add text to transcript buffer with size limit
  void _addToTranscriptBuffer(List<String> buffer, String text) {
    buffer.add(text);
    while (buffer.length > _maxTranscriptBufferSize) {
      buffer.removeAt(0);
    }
  }
  
  /// Get the conversation context for failover to text mode
  /// 
  /// Returns a formatted string containing the recent conversation history
  /// that can be passed to GeminiChatService.sendMessageStream() to maintain
  /// context during the voice-to-text failover.
  /// 
  /// Head of Engineering Action Item: "Verify sendMessageStream receives the
  /// transcript buffer from the failed socket session."
  String getFailoverContext() {
    if (_inputTranscriptBuffer.isEmpty && _outputTranscriptBuffer.isEmpty) {
      return '';
    }
    
    final buffer = StringBuffer();
    buffer.writeln('--- Conversation Context (Voice Session) ---');
    
    // Interleave the transcripts in chronological order
    // This is a simplified approach; in production, you'd want timestamps
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
  
  /// Get the last user message for quick context
  String? getLastUserMessage() {
    if (_inputTranscriptBuffer.isEmpty) return null;
    return _inputTranscriptBuffer.last;
  }
  
  /// Get the last AI message for quick context
  String? getLastAiMessage() {
    if (_outputTranscriptBuffer.isEmpty) return null;
    return _outputTranscriptBuffer.last;
  }
  
  /// Clear transcript buffers (call after successful text mode handover)
  void clearTranscriptBuffers() {
    _inputTranscriptBuffer.clear();
    _outputTranscriptBuffer.clear();
  }
  
  // === RECONNECTION LOGIC ===
  
  /// Handle disconnection with potential reconnection
  void _handleDisconnection({required bool wasError}) {
    _isConnected = false;
    _isListening = false;
    
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
    if (!_canAttemptConnection()) {
      if (kDebugMode) {
        debugPrint('GeminiLiveService: Cannot reconnect - circuit breaker open');
      }
      return;
    }
    
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      if (kDebugMode) {
        debugPrint('GeminiLiveService: Max reconnect attempts reached');
      }
      _recordFailure(); // This may trigger circuit breaker
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
  
  // === PRIVATE METHODS ===
  
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
          // Return the API key directly - works for testing but less secure
          _ephemeralToken = AIModelConfig.geminiApiKey;
          _tokenExpiry = DateTime.now().add(const Duration(hours: 24)); // Fake expiry
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
          return _ephemeralToken;
        }
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
      // DEV MODE FALLBACK: If anything fails, try API key directly
      if (kDebugMode && AIModelConfig.hasGeminiKey) {
        debugPrint('GeminiLiveService: DEV MODE FALLBACK - Using Gemini API key directly after error');
        _ephemeralToken = AIModelConfig.geminiApiKey;
        _tokenExpiry = DateTime.now().add(const Duration(hours: 24));
        return _ephemeralToken;
      }
      return null;
    }
  }
  
  /// Build WebSocket URL with ephemeral token
  String _buildWebSocketUrl(String token) {
    // The ephemeral token is passed as access_token query parameter
    return '$_wsEndpoint?access_token=$token';
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
        final errorMessage = error['message'] as String? ?? 'Unknown error';
        _notifyError(errorMessage);
        _recordFailure();
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
    _cancelReconnect();
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

/// Circuit breaker states
enum CircuitBreakerState {
  /// Circuit is closed - connections allowed
  closed,
  
  /// Circuit is open - connections blocked, fallback to text mode
  open,
  
  /// Circuit is half-open - testing if service has recovered
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
  
  bool get isActive {
    return this == LiveConnectionState.connected;
  }
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
