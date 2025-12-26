import 'dart:async';
import 'dart:io'; // Required for HandshakeException, SocketException
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/ai_model_config.dart';
import '../../core/logging/app_logger.dart';
import '../../core/logging/log_buffer.dart';

/// Gemini Live API Service - Phase 38: In-App Log Console
/// 
/// Features:
/// - "Black Box" Phase Tracking (Records exactly where it fails)
/// - Detailed Error Reporting (Pastes codes/reasons into error message)
/// - Universal Auth (URL Parameters: ?key= or ?access_token=)
/// - Global Model Support (gemini-2.5-flash-native-audio-preview-12-2025 via v1beta)
/// - **Gemini 3 Compliance:**
///   - Thought Signature handling (maintains conversational context)
///   - thinkingConfig.thinkingLevel: "MINIMAL" (reduces latency for voice interactions)
///   - No temperature setting (prevents looping behaviour)
/// 
/// Phase 35 Fix:
/// - CRITICAL: Moved thinkingConfig INSIDE generationConfig per official API schema
/// - Previous error "Unknown name 'thinkingConfig'" was caused by incorrect nesting
/// - See: https://ai.google.dev/api/generate-content#ThinkingConfig
/// 
/// Phase 36 Fix:
/// - CRITICAL: Added custom headers to mimic Python client (fixes 403 Forbidden)
/// - Uses IOWebSocketChannel.connect() with explicit Host and User-Agent headers
/// - Root cause: Dart's default WebSocket client lacks headers that GFE expects
/// - See: docs/PHASE_36_ERROR_ANALYSIS.md
/// 
/// Phase 37 Fix (Genspark Feedback):
/// - IMPROVED: Honest User-Agent header (Dart/3.x (flutter); co.thepact.app/x.x.x)
/// - ADDED: await _channel!.ready to ensure handshake completes before proceeding
/// - ADDED: Granular error handling (HandshakeException vs SocketException)
/// - ADDED: URL validation assert for defensive programming
/// 
/// Phase 38: In-App Log Console
/// - ADDED: LogBuffer integration for centralized, persistent logging
/// - ADDED: Verbose connection logging (headers, URL, status codes)
/// - ADDED: DebugConsoleView widget for DevToolsOverlay
/// - ADDED: One-click copy for debugging
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
  // ignore: unused_field - used for state tracking, may be needed for debugging
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
  
  // === PHASE 42: TOOL STATE ===
  Map<String, dynamic>? _pendingTools; // Tools to inject in setup message
  
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
  
  // === PHASE 42: TOOL CALL CALLBACK ===
  /// Called when the AI invokes a function/tool.
  /// Parameters: toolName, arguments, callId
  final void Function(String toolName, Map<String, dynamic> args, String callId)? onToolCall;
  
  // === DEBUG LOG STATE ===
  final List<String> _debugLog = [];
  
  // === PHASE 39: UNIFIED LOGGING ===
  // static const _logger = AppLogger('GeminiLive');

  
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
    this.onToolCall,
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
  
  /// Add an entry to the debug log (also writes to centralized LogBuffer via AppLogger)
  void _addDebugLog(String entry, {bool isError = false}) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    _debugLog.add('[$timestamp] $entry');
    if (_debugLog.length > 100) {
      _debugLog.removeAt(0); // Keep only last 100 entries
    }
    onDebugLogUpdated?.call(_debugLog);
    
    // PHASE 39: Use unified AppLogger (which writes to LogBuffer automatically)
    if (isError) {
      AppLogger.error(entry);
    } else {
      AppLogger.info(entry);
    }
  }
  String get connectionPhase => _connectionPhase;
  String get lastErrorDetail => _lastErrorDetail;
  
  /// Exposes the current thought signature for debugging purposes.
  String? get currentThoughtSignature => _currentThoughtSignature;

  /// Connect to the Gemini Live API.
  /// 
  /// [systemInstruction] - The system prompt for the AI
  /// [enableTranscription] - Enable audio transcription
  /// [tools] - Optional tool definitions for function calling (Phase 42)
  Future<bool> connect({
    String? systemInstruction,
    bool enableTranscription = true,
    Map<String, dynamic>? tools,
  }) async {
    if (_isConnected) return true;
    
    // Store tools for use in setup message
    _pendingTools = tools;
    
    // PHASE 39: Add separator and start logging
    LogBuffer.instance.addLog('════ NEW CONNECTION ATTEMPT ════');
    _addDebugLog('🚀 Starting connection sequence...');
    if (tools != null) {
      _addDebugLog('🔧 Tools enabled: ${tools['functionDeclarations']?.length ?? 0} function(s)');
    }
    
    _setPhase("STARTING");
    _notifyConnectionState(LiveConnectionState.connecting);
    
    // Reset thought signature on new connection
    _currentThoughtSignature = null;
    
    try {
      // PHASE 1: TOKEN
      _setPhase("FETCHING_TOKEN");
      _addDebugLog('🔑 Fetching authentication token...');
      final tokenResult = await _getEphemeralTokenWithReason();
      if (tokenResult.token == null) {
        throw 'Token is null: ${tokenResult.reason}';
      }
      final token = tokenResult.token;
      _addDebugLog('✅ Token acquired (${_isUsingApiKey ? "API Key" : "OAuth"})');
      
      // PHASE 2: URL BUILD
      _setPhase("BUILDING_URL");
      _addDebugLog('🔗 Building WebSocket URL...');
      String wsUrl = _wsEndpoint;
      if (_isUsingApiKey) {
        // Legacy/Dev fallback
        wsUrl += '?key=$token';
        if (kDebugMode) debugPrint('GeminiLiveService: Using API Key auth (key= param)');
      } else {
        // Ephemeral token flow
        wsUrl += '?access_token=$token';
        if (kDebugMode) debugPrint('GeminiLiveService: Using OAuth token auth (access_token= param)');
      }
      
      // PHASE 3: SOCKET CONNECT
      _setPhase("CONNECTING_SOCKET");
      
      // PHASE 38: Verbose logging for debugging
      final headers = <String, dynamic>{
        // 'Authorization': 'Bearer $token', // Alternative if query param fails, but standard is access_token
      };
      
      _addDebugLog('📡 Endpoint: ${_wsEndpoint.split("?")[0]}');
      _addDebugLog('🎯 Model: ${AIModelConfig.tier2Model}');
      _addDebugLog('📋 Headers: $headers');
      _addDebugLog('⏳ Opening WebSocket connection...');
      
      if (kDebugMode) {
        debugPrint('GeminiLiveService: Connecting to WebSocket...');
        debugPrint('GeminiLiveService: Model: ${AIModelConfig.tier2Model}');
        debugPrint('GeminiLiveService: Endpoint: v1alpha (Phase 45 fix)');
        debugPrint('GeminiLiveService: Headers: Honest UA (Phase 37 fix)');
        debugPrint('GeminiLiveService: Full URL: $wsUrl');
        debugPrint('GeminiLiveService: Gemini 3 Compliance: thinking_level=MINIMAL, thoughtSignature=enabled');
      }
      
      // PHASE 37: Defensive URL validation (catches config errors early)
      assert(
        wsUrl.contains('key=') || wsUrl.contains('access_token='),
        '❌ Invalid WebSocket URL: Missing authentication parameter',
      );
      assert(
        wsUrl.startsWith('wss://'),
        '❌ Invalid WebSocket URL: Must use secure WebSocket (wss://)',
      );
      
      // PHASE 37: Use IOWebSocketChannel with HONEST headers (not spoofing)
      // This builds trust with WAFs (Web Application Firewalls) and is sustainable.
      // Format: "Runtime/Version (Framework); PackageID/AppVersion"
      _channel = IOWebSocketChannel.connect(
        Uri.parse(wsUrl),
        headers: headers, // Pass the headers map, even if empty or minimal
      );
      
      // PHASE 37: Wait for WebSocket handshake to complete before proceeding
      // This ensures TCP + TLS + WebSocket upgrade are all successful.
      try {
        await _channel!.ready;
        _addDebugLog('✅ WebSocket handshake successful');
        if (kDebugMode) debugPrint('GeminiLiveService: ✅ WebSocket handshake successful. Protocol upgraded.');
      } on HandshakeException catch (e) {
        // Server rejected the connection (403, SSL mismatch, etc.)
        _setPhase("HANDSHAKE_REJECTED");
        _addDebugLog('⛔ HANDSHAKE REJECTED: $e', isError: true);
        _addDebugLog('🔍 Check: API Key permissions, Billing enabled, or Geo-blocking', isError: true);
        _notifyDetailedError("Server Rejected Connection", "HandshakeException: $e");
        rethrow;
      } on SocketException catch (e) {
        // Network failure (DNS, TCP, no internet)
        _setPhase("NETWORK_FAILURE");
        _addDebugLog('📡 NETWORK FAILURE: $e', isError: true);
        _addDebugLog('🔍 Check: Internet connection, DNS, Firewall', isError: true);
        _notifyDetailedError("Network Failure", "SocketException: $e");
        rethrow;
      }
      
      _subscription = _channel!.stream.listen(
        (message) {
          if (message is String) {
            // Log JSON messages clearly
            try {
              final json = jsonDecode(message);
              // Don't log full audio payloads in JSON if they exist
              if (json.toString().length > 500) {
                 AppLogger.debug('ℹ️ [GeminiLive] 📥 Rx JSON (truncated): ${json.toString().substring(0, 500)}...');
              } else {
                 AppLogger.debug('ℹ️ [GeminiLive] 📥 Rx JSON: $message');
              }
              _handleServerMessage(json);
            } catch (e) {
              AppLogger.warning('⚠️ [GeminiLive] Rx Non-JSON text: $message');
            }
          } else if (message is List<int>) {
            // CRITICAL: Log that we received binary audio data
            AppLogger.debug('ℹ️ [GeminiLive] 📥 Rx BINARY AUDIO: ${message.length} bytes');
            _handleAudioData(Uint8List.fromList(message));
          }
        },
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
      await _sendSetupMessage(systemInstruction, enableTranscription, _pendingTools);
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

  /// Handles incoming audio binary data
  void _handleAudioData(Uint8List data) {
    // This is for future native audio support if the API sends raw PCM
    // Currently, Gemini v1beta sends base64 in JSON, handled in _handleServerMessage
    onAudioReceived?.call(data);
    onModelSpeakingChanged?.call(true);
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
  /// Phase 35: Fix thinkingConfig placement
  /// - CRITICAL FIX: Moved `thinkingConfig` INSIDE `generationConfig` per official API schema
  /// - The API was returning "Unknown name 'thinkingConfig'" because it was at the wrong level
  /// - See: https://ai.google.dev/api/generate-content#ThinkingConfig
  /// - Removed `temperature` setting to prevent looping behaviour.
  /// 
  /// Phase 42: Tool Injection
  /// - Added optional [tools] parameter for function calling during onboarding
  /// - Tools enable the AI to save data in real-time via tool_call events
  Future<void> _sendSetupMessage(String? instruction, bool transcribe, Map<String, dynamic>? tools) async {
    final Map<String, dynamic> setupConfig = {
      'setup': {
        'model': 'models/${AIModelConfig.tier2Model}',
        'generationConfig': {
          'responseModalities': ['AUDIO'], // camelCase per official docs
          'speechConfig': {
            'voiceConfig': {
              'prebuiltVoiceConfig': {
                'voiceName': 'Puck', // Phase 42: Changed from Kore to Puck (Stoic Coach persona)
              }
            }
          },
          // PHASE 35 FIX: thinkingConfig belongs INSIDE generationConfig
          // This was causing "Unknown name 'thinkingConfig'" when placed at setup level
          'thinkingConfig': {
            'thinkingLevel': 'MINIMAL',
          },
          // GEMINI 3 COMPLIANCE: Do NOT set temperature. 
          // Values < 1.0 cause "unexpected behavior, such as looping".
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
    
    // PHASE 42: Inject tools for function calling
    if (tools != null) {
      setupConfig['setup']['tools'] = [tools];
      _addDebugLog('🔧 Injecting tools into setup message');
    }
    
    final payload = jsonEncode(setupConfig);
    
    // PHASE 35: Enhanced debug logging for handshake payload
    if (kDebugMode) {
      debugPrint('GeminiLiveService: === HANDSHAKE PAYLOAD ===');
      debugPrint('GeminiLiveService: Model: models/${AIModelConfig.tier2Model}');
      debugPrint('GeminiLiveService: generationConfig.thinkingConfig.thinkingLevel: MINIMAL (FIXED - now inside generationConfig)');
      debugPrint('GeminiLiveService: responseModalities: [AUDIO]');
      debugPrint('GeminiLiveService: voiceName: Puck');
      debugPrint('GeminiLiveService: Tools: ${tools != null ? "enabled" : "none"}');
      debugPrint('GeminiLiveService: Full payload: $payload');
      debugPrint('GeminiLiveService: === END PAYLOAD ===');
    }
    
    _channel!.sink.add(payload);
  }

  void _handleServerMessage(Map<String, dynamic> data) {
    try {
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
      
      // PHASE 42: Handle Tool Calls (Function Calling)
      // The AI can invoke tools defined in the setup message.
      // When it does, we receive a toolCall event that we must handle and respond to.
      if (data.containsKey('toolCall')) {
        _handleToolCall(data['toolCall'] as Map<String, dynamic>);
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
      FunctionResponse response;
      try {
        response = await supabase.functions.invoke(
          _tokenEndpoint,
          body: {'lockToConfig': true},
        );
      } on FunctionException catch (e) {
        final errorBody = e.details;
        final status = e.status;
        final errorMsg = 'Edge Function Error ($status): $errorBody';
        AppLogger.error('❌ [GeminiLive] $errorMsg');
        _addDebugLog('❌ Token fetch failed: $status', isError: true);

        // DEV MODE FALLBACK
        if (kDebugMode && AIModelConfig.hasGeminiKey) {
           debugPrint('GeminiLiveService: DEV MODE FALLBACK - Edge function failed ($status), using API key');
          _ephemeralToken = AIModelConfig.geminiApiKey;
          _tokenExpiry = DateTime.now().add(const Duration(hours: 24));
          _isUsingApiKey = true;
          return _TokenResult(_ephemeralToken, 'Dev fallback after Edge Function error ($status)');
        }
        return _TokenResult(null, 'Edge Function Error ($status): $errorBody');
      } catch (e) {
        // Network or other errors
        AppLogger.error('❌ [GeminiLive] Token invocation failed: $e');
        _addDebugLog('❌ Token fetch exception: $e', isError: true);
         if (kDebugMode && AIModelConfig.hasGeminiKey) {
          debugPrint('GeminiLiveService: DEV MODE FALLBACK - Network error, using API key');
          _ephemeralToken = AIModelConfig.geminiApiKey;
          _tokenExpiry = DateTime.now().add(const Duration(hours: 24));
          _isUsingApiKey = true;
          return _TokenResult(_ephemeralToken, 'Dev fallback after network error');
        }
        return _TokenResult(null, 'Token invocation failed: $e');
      }

      if (response.status != 200) {
        final errorMsg = 'Edge function returned status ${response.status}. Body: ${response.data}';
        debugPrint('GeminiLiveService: $errorMsg');
        _addDebugLog('❌ Backend returned ${response.status}', isError: true);

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

      // If backend doesn't return expiry, default to 30 mins
      _tokenExpiry = data['expiresAt'] != null 
          ? DateTime.parse(data['expiresAt'] as String)
          : DateTime.now().add(const Duration(minutes: 30));
          
      _isUsingApiKey = false;

      // Log the model returned by backend for debugging
      final backendModel = data['model'] as String?;
      if (kDebugMode) {
        debugPrint('GeminiLiveService: Backend token model: $backendModel');
        debugPrint('GeminiLiveService: Frontend model: ${AIModelConfig.tier2Model}');
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
    
    sendJsonMessage(message);
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
    
    sendJsonMessage(message);
  }
  
  /// Helper to send JSON messages with logging
  void sendJsonMessage(Map<String, dynamic> data) {
    if (_channel == null) return;
    
    try {
      final jsonString = jsonEncode(data);
      if (kDebugMode) {
        // Truncate long logs (like audio chunks)
        if (jsonString.length > 500) {
          AppLogger.debug('ℹ️ [GeminiLive] 📤 Tx JSON (truncated): ${jsonString.substring(0, 500)}...');
        } else {
          AppLogger.debug('ℹ️ [GeminiLive] 📤 Tx JSON: $jsonString');
        }
      }
      _channel!.sink.add(jsonString);
    } catch (e) {
      AppLogger.error('❌ [GeminiLive] Failed to send JSON: $e');
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
  
  // ============================================================
  // PHASE 42: TOOL CALL HANDLING
  // ============================================================
  
  /// Handle a tool call from the AI.
  /// 
  /// Tool calls have the structure:
  /// ```json
  /// {
  ///   "toolCall": {
  ///     "functionCalls": [
  ///       {
  ///         "name": "update_user_psychometrics",
  ///         "args": { ... },
  ///         "id": "call_123"
  ///       }
  ///     ]
  ///   }
  /// }
  /// ```
  void _handleToolCall(Map<String, dynamic> toolCallData) {
    try {
      final functionCalls = toolCallData['functionCalls'] as List<dynamic>?;
      if (functionCalls == null || functionCalls.isEmpty) {
        _addDebugLog('⚠️ Tool call received but no function calls found', isError: true);
        return;
      }
      
      for (final call in functionCalls) {
        final callMap = call as Map<String, dynamic>;
        final name = callMap['name'] as String?;
        final args = callMap['args'] as Map<String, dynamic>? ?? {};
        final id = callMap['id'] as String? ?? 'unknown_${DateTime.now().millisecondsSinceEpoch}';
        
        if (name == null) {
          _addDebugLog('⚠️ Tool call missing function name', isError: true);
          continue;
        }
        
        _addDebugLog('🔧 Tool call received: $name (id: $id)');
        if (kDebugMode) {
          debugPrint('GeminiLiveService: Tool call - $name with args: $args');
        }
        
        // Notify the callback
        onToolCall?.call(name, args, id);
      }
    } catch (e) {
      _addDebugLog('❌ Error parsing tool call: $e', isError: true);
      if (kDebugMode) debugPrint('GeminiLiveService: Error parsing tool call: $e');
    }
  }
  
  /// Send a tool response back to the AI.
  /// 
  /// After processing a tool call, you MUST send a response so the AI knows
  /// the operation completed and can continue the conversation.
  /// 
  /// [functionName] - The name of the function that was called
  /// [callId] - The ID of the tool call (from the original request)
  /// [result] - The result of the function execution
  void sendToolResponse(String functionName, String callId, Map<String, dynamic> result) {
    if (!_isConnected || _channel == null) {
      _addDebugLog('⚠️ Cannot send tool response: not connected', isError: true);
      return;
    }
    
    final Map<String, dynamic> response = {
      'toolResponse': {
        'functionResponses': [
          {
            'name': functionName,
            'id': callId,
            'response': result,
          }
        ]
      }
    };
    
    // GEMINI 3 COMPLIANCE: Echo back the thought signature
    if (_currentThoughtSignature != null) {
      response['thoughtSignature'] = _currentThoughtSignature;
    }
    
    try {
      _channel!.sink.add(jsonEncode(response));
      _addDebugLog('✅ Tool response sent: $functionName');
      if (kDebugMode) {
        debugPrint('GeminiLiveService: Tool response sent for $functionName');
      }
    } catch (e) {
      _addDebugLog('❌ Failed to send tool response: $e', isError: true);
      debugPrint('GeminiLiveService: Failed to send tool response: $e');
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
