import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../config/ai_prompts.dart';
import '../../config/ai_tools_config.dart';
import '../../domain/entities/psychometric_profile.dart';
import '../models/user_profile.dart';
import '../providers/psychometric_provider.dart';
import 'ai/prompt_factory.dart';
import 'audio_recording_service.dart';
import 'gemini_live_service.dart';
import 'openai_live_service.dart';
import 'voice_api_service.dart';
import '../../config/ai_model_config.dart';
import '../enums/voice_session_mode.dart';

/// Voice Session Manager
/// 
/// Phase 32: FEAT-01 - Audio Recording Integration
/// Phase 42: Soul Capture - Psychometric Engine Integration
/// 
/// Orchestrates the full voice conversation flow by integrating:
/// - AudioRecordingService: Microphone input
/// - GeminiLiveService: AI communication
/// - PsychometricProvider: Trait persistence (Phase 42)
/// - PromptFactory: Dynamic prompt generation (Phase 42)
/// 
/// This manager handles:
/// - Session lifecycle (connect, start, stop, disconnect)
/// - Audio routing (mic → WebSocket, WebSocket → speaker)
/// - State synchronisation between services
/// - Error recovery and graceful degradation
/// - Tool call routing for psychometric updates (Phase 42)
/// 
/// Session Modes (Phase 42):
/// - Onboarding: Uses Sherlock Protocol prompts with tools enabled
/// - Coaching: Uses PromptFactory for dynamic prompts based on psychometrics
/// 
/// Usage:
/// ```dart
/// final manager = VoiceSessionManager(
///   mode: VoiceSessionMode.onboarding,
///   psychometricProvider: psychometricProvider,
///   userProfile: userProfile,
///   onTranscription: (text, isUser) => updateUI(text, isUser),
///   onAudioReceived: (data) => playAudio(data),
///   onError: (error) => showError(error),
/// );
/// 
/// await manager.startSession();
/// // ... conversation happens ...
/// await manager.endSession();
/// ```

class VoiceSessionManager {
  // === CONFIGURATION ===
  /// Session mode determines prompt generation and tool enablement
  final VoiceSessionMode mode;
  
  /// Legacy system instruction (for backward compatibility)
  final String? systemInstruction;
  final bool enableTranscription;
  
  // === PROVIDERS (Phase 42) ===
  /// Provider for psychometric profile updates
  final PsychometricProvider? psychometricProvider;
  
  /// Current user profile for prompt generation
  final UserProfile? userProfile;
  
  /// Current psychometric profile for prompt generation
  final PsychometricProfile? psychometricProfile;
  
  // === SERVICES ===
  late final AudioRecordingService _audioService;
  late final VoiceApiService _voiceService;
  
  /// Expose VoiceApiService for debug access
  VoiceApiService? get voiceService => _voiceService;
  
  // === STATE ===
  VoiceSessionState _state = VoiceSessionState.idle;
  bool _isUserSpeaking = false;
  bool _isAISpeaking = false;
  
  // === CALLBACKS ===
  /// Called when transcription is available (user or AI)
  final void Function(String text, bool isUser)? onTranscription;
  
  /// Called when audio is received from AI (for playback)
  final void Function(Uint8List audioData)? onAudioReceived;
  
  /// Called when session state changes
  final void Function(VoiceSessionState state)? onStateChanged;
  
  /// Called when an error occurs
  final void Function(String error)? onError;
  
  /// Called when audio level changes (for visualisation)
  final void Function(double level)? onAudioLevelChanged;
  
  /// Called when AI speaking state changes
  final void Function(bool isSpeaking)? onAISpeakingChanged;
  
  /// Called when user speaking state changes
  final void Function(bool isSpeaking)? onUserSpeakingChanged;
  
  /// Called when the AI completes a turn
  final void Function()? onTurnComplete;
  
  /// Called when debug log is updated (for in-app display)
  final void Function(List<String> log)? onDebugLogUpdated;
  
  /// Called when a psychometric trait is updated (Phase 42)
  final void Function(String traitName, dynamic value)? onTraitUpdated;
  
  VoiceSessionManager({
    this.mode = VoiceSessionMode.legacy,
    this.systemInstruction,
    this.enableTranscription = true,
    this.psychometricProvider,
    this.userProfile,
    this.psychometricProfile,
    this.onTranscription,
    this.onAudioReceived,
    this.onStateChanged,
    this.onError,
    this.onAudioLevelChanged,
    this.onAISpeakingChanged,
    this.onUserSpeakingChanged,
    this.onTurnComplete,
    this.onDebugLogUpdated,
    this.onTraitUpdated,
  }) {
    _initializeServices();
  }
  
  /// Factory constructor for onboarding sessions (Phase 42)
  factory VoiceSessionManager.onboarding({
    required PsychometricProvider psychometricProvider,
    UserProfile? userProfile,
    bool enableTranscription = true,
    void Function(String text, bool isUser)? onTranscription,
    void Function(Uint8List audioData)? onAudioReceived,
    void Function(VoiceSessionState state)? onStateChanged,
    void Function(String error)? onError,
    void Function(double level)? onAudioLevelChanged,
    void Function(bool isSpeaking)? onAISpeakingChanged,
    void Function(bool isSpeaking)? onUserSpeakingChanged,
    void Function()? onTurnComplete,
    void Function(List<String> log)? onDebugLogUpdated,
    void Function(String traitName, dynamic value)? onTraitUpdated,
  }) {
    return VoiceSessionManager(
      mode: VoiceSessionMode.onboarding,
      psychometricProvider: psychometricProvider,
      userProfile: userProfile,
      enableTranscription: enableTranscription,
      onTranscription: onTranscription,
      onAudioReceived: onAudioReceived,
      onStateChanged: onStateChanged,
      onError: onError,
      onAudioLevelChanged: onAudioLevelChanged,
      onAISpeakingChanged: onAISpeakingChanged,
      onUserSpeakingChanged: onUserSpeakingChanged,
      onTurnComplete: onTurnComplete,
      onDebugLogUpdated: onDebugLogUpdated,
      onTraitUpdated: onTraitUpdated,
    );
  }
  
  /// Factory constructor for coaching sessions (Phase 42)
  factory VoiceSessionManager.coaching({
    required PsychometricProvider psychometricProvider,
    required UserProfile userProfile,
    required PsychometricProfile psychometricProfile,
    bool enableTranscription = true,
    void Function(String text, bool isUser)? onTranscription,
    void Function(Uint8List audioData)? onAudioReceived,
    void Function(VoiceSessionState state)? onStateChanged,
    void Function(String error)? onError,
    void Function(double level)? onAudioLevelChanged,
    void Function(bool isSpeaking)? onAISpeakingChanged,
    void Function(bool isSpeaking)? onUserSpeakingChanged,
    void Function()? onTurnComplete,
    void Function(List<String> log)? onDebugLogUpdated,
    void Function(String traitName, dynamic value)? onTraitUpdated,
  }) {
    return VoiceSessionManager(
      mode: VoiceSessionMode.coaching,
      psychometricProvider: psychometricProvider,
      userProfile: userProfile,
      psychometricProfile: psychometricProfile,
      enableTranscription: enableTranscription,
      onTranscription: onTranscription,
      onAudioReceived: onAudioReceived,
      onStateChanged: onStateChanged,
      onError: onError,
      onAudioLevelChanged: onAudioLevelChanged,
      onAISpeakingChanged: onAISpeakingChanged,
      onUserSpeakingChanged: onUserSpeakingChanged,
      onTurnComplete: onTurnComplete,
      onDebugLogUpdated: onDebugLogUpdated,
      onTraitUpdated: onTraitUpdated,
    );
  }
  
  // === PUBLIC GETTERS ===
  VoiceSessionState get state => _state;
  bool get isActive => _state == VoiceSessionState.active;
  bool get isConnecting => _state == VoiceSessionState.connecting;
  bool get isUserSpeaking => _isUserSpeaking;
  bool get isAISpeaking => _isAISpeaking;
  
  /// Initialise the underlying services with callbacks.
  void _initializeServices() {
    // Audio Recording Service
    _audioService = AudioRecordingService(
      onAudioData: _handleMicrophoneAudio,
      onError: _handleAudioError,
      onRecordingStateChanged: _handleRecordingStateChanged,
      onAudioLevelChanged: onAudioLevelChanged,
      onVoiceActivityDetected: _handleVoiceActivity,
    );
    
    // Choose Provider based on Config
    if (AIModelConfig.voiceProvider == 'openai') {
      _voiceService = OpenAILiveService(
        onAudioReceived: _handleAIAudio,
        onTranscription: _handleTranscription,
        onModelSpeakingChanged: _handleAISpeakingChanged,
        onError: _handleGeminiError, // Reuse error handler
        onToolCall: _handleToolCall,
        onDebugLogUpdated: onDebugLogUpdated,
      );
    } else {
      // Default to Gemini
      _voiceService = GeminiLiveService(
        onAudioReceived: _handleAIAudio,
        onTranscription: _handleTranscription,
        onModelSpeakingChanged: _handleAISpeakingChanged,
        onConnectionStateChanged: _handleConnectionStateChanged,
        onError: _handleGeminiError,
        onTurnComplete: _handleTurnComplete,
        onDebugLogUpdated: onDebugLogUpdated,
        onToolCall: _handleToolCall, // Phase 42: Tool call handling
      );
    }
  }
  
  /// Generate the system instruction based on session mode (Phase 42)
  String _generateSystemInstruction() {
    switch (mode) {
      case VoiceSessionMode.onboarding:
        // Use the Sherlock Protocol prompt for onboarding
        return AtomicHabitsReasoningPrompts.voiceOnboardingSystemPrompt;
        
      case VoiceSessionMode.coaching:
        // Use PromptFactory for dynamic prompts
        if (userProfile != null && psychometricProfile != null) {
          // Check if this is the first session (no anti-identity set)
          final isFirstSession = psychometricProfile!.antiIdentityLabel == null ||
              psychometricProfile!.antiIdentityLabel!.isEmpty;
          
          return PromptFactory.generateSessionPrompt(
            user: userProfile!,
            psychometrics: psychometricProfile!,
            isFirstSession: isFirstSession,
          );
        }
        // Fallback to basic prompt if profiles not available
        return AtomicHabitsReasoningPrompts.voiceSession(
          userName: userProfile?.name,
        );
        
      case VoiceSessionMode.legacy:
      default:
        // Use the legacy system instruction
        return systemInstruction ?? AtomicHabitsReasoningPrompts.voiceSession();
    }
  }
  
  /// Determine if tools should be enabled for this session (Phase 42)
  bool _shouldEnableTools() {
    // Tools are only enabled during onboarding for the Sherlock Protocol
    return mode == VoiceSessionMode.onboarding;
  }
  
  /// Get the tools configuration for onboarding (Phase 42)
  /// Returns a single tool definition map (GeminiLiveService wraps it in an array)
  Map<String, dynamic>? _getToolsConfig() {
    if (!_shouldEnableTools()) return null;
    return AiToolsConfig.psychometricTool;
  }
  
  /// Start a new voice session.
  /// 
  /// This method:
  /// 1. Connects to the Gemini Live API
  /// 2. Initialises the audio recording service
  /// 3. Starts streaming audio to the AI
  Future<bool> startSession() async {
    if (_state != VoiceSessionState.idle) {
      if (kDebugMode) {
        debugPrint('VoiceSessionManager: Cannot start - already in state: $_state');
      }
      return false;
    }
    
    _setState(VoiceSessionState.connecting);
    
    try {
      // Step 1: Generate system instruction based on mode
      final instruction = _generateSystemInstruction();
      final tools = _getToolsConfig();
      
      if (kDebugMode) {
        debugPrint('VoiceSessionManager: Starting session in mode: $mode');
        debugPrint('VoiceSessionManager: Tools enabled: ${tools != null}');
      }
      
      // Step 2: Connect to AI Service
      if (kDebugMode) {
        debugPrint('VoiceSessionManager: Connecting to AI service (${AIModelConfig.voiceProvider})...');
      }
      
      final connected = await _voiceService.connect(
        systemInstruction: instruction,
        enableTranscription: enableTranscription,
        tools: tools,
      );
      
      if (!connected) {
        _setState(VoiceSessionState.error);
        onError?.call('Failed to connect to AI service');
        return false;
      }
      
      // Step 3: Initialise audio recording
      if (kDebugMode) {
        debugPrint('VoiceSessionManager: Initialising audio recording...');
      }
      
      final audioReady = await _audioService.initialize();
      if (!audioReady) {
        await _voiceService.disconnect();
        _setState(VoiceSessionState.error);
        onError?.call('Failed to initialise microphone');
        return false;
      }
      
      // Step 4: Start recording
      if (kDebugMode) {
        debugPrint('VoiceSessionManager: Starting audio recording...');
      }
      
      final recordingStarted = await _audioService.startRecording();
      if (!recordingStarted) {
        await _voiceService.disconnect();
        _setState(VoiceSessionState.error);
        onError?.call('Failed to start recording');
        return false;
      }
      
      _setState(VoiceSessionState.active);
      
      if (kDebugMode) {
        debugPrint('VoiceSessionManager: Session started successfully');
      }
      
      return true;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('VoiceSessionManager: Failed to start session: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      _setState(VoiceSessionState.error);
      onError?.call('Failed to start voice session: $e');
      return false;
    }
  }
  
  /// End the current voice session.
  Future<void> endSession() async {
    if (_state == VoiceSessionState.idle) return;
    
    if (kDebugMode) {
      debugPrint('VoiceSessionManager: Ending session...');
    }
    
    _setState(VoiceSessionState.disconnecting);
    
    try {
      await _audioService.stopRecording();
      await _voiceService.disconnect();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('VoiceSessionManager: Error during disconnect: $e');
      }
    }
    
    _setState(VoiceSessionState.idle);
    
    if (kDebugMode) {
      debugPrint('VoiceSessionManager: Session ended');
    }
  }
  
  /// Pause the voice session (mute microphone).
  Future<void> pauseSession() async {
    if (_state != VoiceSessionState.active) return;
    
    await _audioService.pauseRecording();
    _setState(VoiceSessionState.paused);
    
    if (kDebugMode) {
      debugPrint('VoiceSessionManager: Session paused');
    }
  }
  
  /// Resume the voice session (unmute microphone).
  Future<void> resumeSession() async {
    if (_state != VoiceSessionState.paused) return;
    
    await _audioService.resumeRecording();
    _setState(VoiceSessionState.active);
    
    if (kDebugMode) {
      debugPrint('VoiceSessionManager: Session resumed');
    }
  }
  
  /// Send a text message to the AI (for hybrid voice/text mode).
  void sendText(String text) {
    if (_state != VoiceSessionState.active && _state != VoiceSessionState.paused) {
      return;
    }
    
    _voiceService.sendText(text);
  }
  
  /// Interrupt the AI's current response.
  void interruptAI() {
    _voiceService.interrupt();
  }
  
  // === PRIVATE HANDLERS ===
  
  void _setState(VoiceSessionState newState) {
    if (_state == newState) return;
    _state = newState;
    onStateChanged?.call(newState);
  }
  
  /// Handle audio data from the microphone.
  void _handleMicrophoneAudio(Uint8List audioData) {
    if (_state != VoiceSessionState.active) return;
    
    // Forward audio to AI Service
    _voiceService.sendAudio(audioData);
  }
  
  /// Handle audio data from the AI.
  void _handleAIAudio(Uint8List audioData) {
    onAudioReceived?.call(audioData);
  }
  
  /// Handle transcription from the AI.
  void _handleTranscription(String text, bool isUser) {
    onTranscription?.call(text, isUser);
  }
  
  /// Handle audio recording errors.
  void _handleAudioError(String error) {
    if (kDebugMode) {
      debugPrint('VoiceSessionManager: Audio error: $error');
    }
    onError?.call('Audio error: $error');
  }
  
  /// Handle Gemini service errors.
  void _handleGeminiError(String error) {
    if (kDebugMode) {
      debugPrint('VoiceSessionManager: Gemini error: $error');
    }
    onError?.call(error);
  }
  
  /// Handle recording state changes.
  void _handleRecordingStateChanged(bool isRecording) {
    if (kDebugMode) {
      debugPrint('VoiceSessionManager: Recording state: $isRecording');
    }
  }
  
  /// Handle voice activity detection.
  void _handleVoiceActivity(bool isActive) {
    if (_isUserSpeaking != isActive) {
      _isUserSpeaking = isActive;
      onUserSpeakingChanged?.call(isActive);
    }
  }
  
  /// Handle AI speaking state changes.
  void _handleAISpeakingChanged(bool isSpeaking) {
    if (_isAISpeaking != isSpeaking) {
      _isAISpeaking = isSpeaking;
      onAISpeakingChanged?.call(isSpeaking);
    }
  }
  
  /// Handle Gemini connection state changes.
  void _handleConnectionStateChanged(LiveConnectionState connectionState) {
    if (kDebugMode) {
      debugPrint('VoiceSessionManager: Connection state: $connectionState');
    }
    
    if (connectionState == LiveConnectionState.disconnected && 
        _state == VoiceSessionState.active) {
      // Unexpected disconnection
      _setState(VoiceSessionState.error);
      onError?.call('Connection lost');
    }
  }
  
  /// Handle AI turn completion.
  void _handleTurnComplete() {
    onTurnComplete?.call();
  }
  
  /// Handle tool calls from Gemini (Phase 42: Sherlock Protocol)
  /// 
  /// This method processes tool_call events from the AI and:
  /// 1. Validates the tool name
  /// 2. Extracts arguments
  /// 3. Updates the psychometric profile via the provider
  /// 4. Sends a success response back to the AI
  Future<void> _handleToolCall(String functionName, Map<String, dynamic> args, String callId) async {
    if (kDebugMode) {
      debugPrint('VoiceSessionManager: Tool call received: $functionName');
      debugPrint('VoiceSessionManager: Args: $args');
      debugPrint('VoiceSessionManager: Call ID: $callId');
    }
    
    // Only handle the psychometric tool
    if (functionName != AiToolsConfig.psychometricToolName) {
      if (kDebugMode) {
        debugPrint('VoiceSessionManager: Unknown tool: $functionName');
      }
      // Send error response
      _voiceService.sendToolResponse(
        functionName,
        callId,
        {'error': 'Unknown tool: $functionName'},
      );
      return;
    }
    
    // Verify we have the provider
    if (psychometricProvider == null) {
      if (kDebugMode) {
        debugPrint('VoiceSessionManager: No psychometric provider available');
      }
      _voiceService.sendToolResponse(
        functionName,
        callId,
        {'error': 'Psychometric provider not configured'},
      );
      return;
    }
    
    try {
      // Update the psychometric profile via the provider
      await psychometricProvider!.updateFromToolCall(args);
      
      // Notify listeners of trait updates
      _notifyTraitUpdates(args);
      
      if (kDebugMode) {
        debugPrint('VoiceSessionManager: Psychometric profile updated successfully');
      }
      
      // Send success response back to the AI
      _voiceService.sendToolResponse(
        functionName,
        callId,
        {
          'status': 'success',
          'message': 'Psychometric profile updated',
          'updated_fields': args.keys.toList(),
        },
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('VoiceSessionManager: Failed to update psychometric profile: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      
      // Send error response
      _voiceService.sendToolResponse(
        functionName,
        callId,
        {
          'status': 'error',
          'message': 'Failed to update profile: $e',
        },
      );
    }
  }
  
  /// Notify listeners about individual trait updates (Phase 42)
  void _notifyTraitUpdates(Map<String, dynamic> args) {
    if (onTraitUpdated == null) return;
    
    // Map tool argument names to display names
    final traitDisplayNames = {
      'anti_identity_label': 'Anti-Identity',
      'anti_identity_context': 'Anti-Identity Context',
      'failure_archetype': 'Failure Archetype',
      'failure_trigger_context': 'Failure Trigger',
      'resistance_lie_label': 'Resistance Lie',
      'resistance_lie_context': 'Resistance Context',
      'inferred_fears': 'Inferred Fears',
    };
    
    for (final entry in args.entries) {
      final displayName = traitDisplayNames[entry.key] ?? entry.key;
      onTraitUpdated?.call(displayName, entry.value);
    }
  }
  
  /// Dispose of all resources.
  Future<void> dispose() async {
    await endSession();
    await _audioService.dispose();
  }
}

/// Voice session states.
enum VoiceSessionState {
  /// Session is not active
  idle,
  
  /// Connecting to AI service
  connecting,
  
  /// Session is active and streaming
  active,
  
  /// Session is paused (microphone muted)
  paused,
  
  /// Disconnecting from AI service
  disconnecting,
  
  /// An error occurred
  error,
}
