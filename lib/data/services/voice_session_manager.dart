import 'dart:async';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;

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
import 'stream_voice_player.dart';

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
class VoiceSessionManager {
  // === CONFIGURATION ===
  final VoiceSessionMode mode;
  final String? systemInstruction;
  final bool enableTranscription;
  
  // === PROVIDERS (Phase 42) ===
  final PsychometricProvider? psychometricProvider;
  final UserProfile? userProfile;
  final PsychometricProfile? psychometricProfile;
  
  // === SERVICES ===
  late final AudioRecordingService _audioService;
  late final VoiceApiService _voiceService;
  late final StreamVoicePlayer _voicePlayer;
  
  // === DIAGNOSTICS ===
  final Stopwatch _turnLatencyStopwatch = Stopwatch();
  DateTime? _lastUserTurnEnd;
  
  VoiceApiService? get voiceService => _voiceService;
  
  // === STATE ===
  VoiceSessionState _state = VoiceSessionState.idle;
  bool _isUserSpeaking = false;
  bool _isAISpeaking = false;
  
  // Transcript Buffer (Deferred Intelligence)
  final List<Map<String, String>> _transcript = [];
  List<Map<String, String>> get transcript => List.unmodifiable(_transcript);

  // === CALLBACKS ===
  final void Function(String text, bool isUser)? onTranscription;
  final void Function(Uint8List audioData)? onAudioReceived;
  final void Function(VoiceSessionState state)? onStateChanged;
  final void Function(String error)? onError;
  final void Function(double level)? onAudioLevelChanged;
  final void Function(bool isSpeaking)? onAISpeakingChanged;
  final void Function(bool isSpeaking)? onUserSpeakingChanged;
  final void Function()? onTurnComplete;
  final void Function(List<String> log)? onDebugLogUpdated;
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
  
  void _initializeServices() {
    _audioService = AudioRecordingService(
      onAudioData: _handleMicrophoneAudio,
      onError: _handleAudioError,
      onRecordingStateChanged: _handleRecordingStateChanged,
      onAudioLevelChanged: onAudioLevelChanged,
      onVoiceActivityDetected: _handleVoiceActivity,
    );
    
    if (AIModelConfig.voiceProvider == 'openai') {
      _voiceService = OpenAILiveService(
        onAudioReceived: _handleAIAudio,
        onTranscription: _handleTranscription,
        onModelSpeakingChanged: _handleAISpeakingChanged,
        onError: _handleGeminiError,
        onToolCall: _handleToolCall,
        onDebugLogUpdated: onDebugLogUpdated,
      );
    } else {
      _voiceService = GeminiLiveService(
        onAudioReceived: _handleAIAudio,
        onTranscription: _handleTranscription,
        onModelSpeakingChanged: _handleAISpeakingChanged,
        onConnectionStateChanged: _handleConnectionStateChanged,
        onError: _handleGeminiError,
        onTurnComplete: _handleTurnComplete,
        onDebugLogUpdated: onDebugLogUpdated,
        onToolCall: _handleToolCall, 
        onThinkingChanged: _handleThinkingChanged,
      );
    }
    
    _voicePlayer = StreamVoicePlayer();
    _voicePlayer.isPlayingStream.listen((isPlaying) {
      if (kDebugMode) debugPrint(isPlaying ? 'VoiceSessionManager: 🗣️ AI Speaking STARTED' : 'VoiceSessionManager: 🤫 AI Speaking STOPPED');
      _isAISpeaking = isPlaying;
      
      if (!isPlaying && (_state == VoiceSessionState.thinking || _state == VoiceSessionState.active)) {
         _setState(VoiceSessionState.paused);
      }
      
      onAISpeakingChanged?.call(isPlaying);
    });
  }
  
  String _generateSystemInstruction() {
    switch (mode) {
      case VoiceSessionMode.onboarding:
        return AtomicHabitsReasoningPrompts.voiceOnboardingSystemPrompt;
      case VoiceSessionMode.coaching:
        if (userProfile != null && psychometricProfile != null) {
          final isFirstSession = psychometricProfile!.antiIdentityLabel == null ||
              psychometricProfile!.antiIdentityLabel!.isEmpty;
          return PromptFactory.generateSessionPrompt(
            user: userProfile!,
            psychometrics: psychometricProfile!,
            isFirstSession: isFirstSession,
          );
        }
        return AtomicHabitsReasoningPrompts.voiceSession(userName: userProfile?.name);
      case VoiceSessionMode.legacy:
      default:
        return systemInstruction ?? AtomicHabitsReasoningPrompts.voiceSession();
    }
  }
  
  bool _shouldEnableTools() {
    // DEFERRED INTELLIGENCE PIVOT:
    // Disable live tools to prevent "Reasoning Lock" (yellow flash -> connection lost).
    // We now capture the transcript and process it post-session.
    return false; // mode == VoiceSessionMode.onboarding;
  }
  
  Map<String, dynamic>? _getToolsConfig() {
    if (!_shouldEnableTools()) return null;
    return AiToolsConfig.psychometricTool;
  }
  
  Future<bool> startSession() async {
    if (_state != VoiceSessionState.idle && _state != VoiceSessionState.error) {
      if (kDebugMode) debugPrint('VoiceSessionManager: Cannot start - already in state: $_state');
      return false;
    }
    
    _setState(VoiceSessionState.connecting);
    
    try {
      final instruction = _generateSystemInstruction();
      final tools = _getToolsConfig();
      
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

      if (kDebugMode) {
        // VoiceApiService interface includes sendText, so we can call it directly
        _voiceService.sendText("Hello, can you hear me?");
      }
      
      if (kDebugMode) debugPrint('VoiceSessionManager: Initialising audio recording...');
      
      final audioReady = await _audioService.initialize();
      if (!audioReady) {
        await _voiceService.disconnect();
        _setState(VoiceSessionState.error);
        onError?.call('Failed to initialise microphone');
        return false;
      }
      
      if (kDebugMode) debugPrint('VoiceSessionManager: Starting audio recording...');
      
      final recordingStarted = await _audioService.startRecording();
      if (!recordingStarted) {
        await _voiceService.disconnect();
        _setState(VoiceSessionState.error);
        onError?.call('Failed to start recording');
        return false;
      }
      
      _setState(VoiceSessionState.active);
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

  Future<void> saveProgression() async {
    if (kDebugMode) debugPrint('VoiceSessionManager: Stub saveProgression() called.');
  }
  
  Future<void> endSession() async {
    if (_state == VoiceSessionState.idle) return;
    
    if (kDebugMode) debugPrint('VoiceSessionManager: Ending session...');
    _setState(VoiceSessionState.disconnecting);
    
    try {
      await _audioService.stopRecording();
      await _voicePlayer.stop();
      await _voiceService.disconnect();
    } catch (e) {
      if (kDebugMode) debugPrint('VoiceSessionManager: Error during disconnect: $e');
    }
    
    _setState(VoiceSessionState.idle);
  }
  
  Future<void> pauseSession() async {
    if (_state != VoiceSessionState.active) return;
    await _audioService.pauseRecording();
    await _voicePlayer.stop();
    _setState(VoiceSessionState.paused);
  }
  
  Future<void> resumeSession() async {
    if (_state != VoiceSessionState.paused) return;
    await _audioService.resumeRecording();
    await _voicePlayer.enforceSpeakerOutput();
    _setState(VoiceSessionState.active);
  }

  Future<void> startRecording() async {
    if (_isAISpeaking) {
      if (kDebugMode) debugPrint('VoiceSessionManager: PTT Blocked - AI is Speaking');
       return;
    }
    if (_state != VoiceSessionState.thinking && _state != VoiceSessionState.active && _state != VoiceSessionState.paused) return;
    await _audioService.resumeRecording();
    _setState(VoiceSessionState.active);
  }

  Future<void> stopRecording() async {
    if (_state != VoiceSessionState.active) return;
    await _audioService.pauseRecording();
    await commitUserTurn();
  }
  
  void sendText(String text) {
    if (_state != VoiceSessionState.active && _state != VoiceSessionState.paused) return;
    _voiceService.sendText(text);
  }
  
  void interruptAI() {
    _voiceService.interrupt();
  }
  
  // === PRIVATE HANDLERS ===
  
  void _setState(VoiceSessionState newState) {
    if (_state == newState) return;
    if (kDebugMode) debugPrint('🕵️ [SHERLOCK_TRACE] State Transition: ${_state.name} -> ${newState.name}');
    _state = newState;
    onStateChanged?.call(newState);
  }
  
  void _handleMicrophoneAudio(Uint8List audioData) {
    if (_state != VoiceSessionState.active) return;
    _voiceService.sendAudio(audioData);
  }
  
  void _handleAIAudio(Uint8List audioData) {
    if (kDebugMode) debugPrint('VoiceSessionManager: 🌉 Bridging ${audioData.length} bytes to UI');
    
    // Diagnostics: Measure Latency
    if (_turnLatencyStopwatch.isRunning) {
      _turnLatencyStopwatch.stop();
      if (kDebugMode && _lastUserTurnEnd != null) {
        final totalLatency = DateTime.now().difference(_lastUserTurnEnd!).inMilliseconds;
        debugPrint('⏱️ [LATENCY] Response Time: ${_turnLatencyStopwatch.elapsedMilliseconds}ms (Total: ${totalLatency}ms)');
      }
      _turnLatencyStopwatch.reset();
    }
    
    _voicePlayer.playChunk(audioData);
    final level = _calculateRms(audioData);
    onAudioLevelChanged?.call(level);
  }

  double _calculateRms(Uint8List audioData) {
    if (audioData.isEmpty) return 0.0;
    double sum = 0;
    for (int i = 0; i < audioData.length - 1; i += 2) {
      int sample = audioData[i] | (audioData[i + 1] << 8);
      if (sample > 32767) sample -= 65536;
      final normalizedSample = sample / 32768.0;
      sum += normalizedSample * normalizedSample;
    }
    final sampleCount = audioData.length ~/ 2;
    if (sampleCount == 0) return 0.0;
    final rms = math.sqrt(sum / sampleCount);
    return (rms * 5.0).clamp(0.0, 1.0);
  }
  
  void _handleTranscription(String text, bool isUser) {
    if (kDebugMode) {
      // debugPrint('VoiceSessionManager: Transcription ($isUser): $text');
    }
    
    // Buffer for Deferred Intelligence
    _transcript.add({
      'role': isUser ? 'user' : 'model',
      'content': text,
    });
    
    onTranscription?.call(text, isUser);
  }
  
  void _handleAudioError(String error) {
    if (kDebugMode) debugPrint('VoiceSessionManager: Audio error: $error');
    onError?.call('Audio error: $error');
  }
  
  void _handleGeminiError(String error) {
    if (kDebugMode) debugPrint('VoiceSessionManager: Gemini error: $error');
    onError?.call(error);
  }
  
  void _handleRecordingStateChanged(bool isRecording) {
    if (kDebugMode) debugPrint('VoiceSessionManager: Recording state: $isRecording');
  }
  
  Future<void> commitUserTurn() async {
    if (_state != VoiceSessionState.active) return;
    if (kDebugMode) debugPrint('VoiceSessionManager: 👆 User manually committed turn');
    if (_voiceService is GeminiLiveService) {
      _voiceService.sendEndTurn();
    } else {
      _voiceService.sendText(" ", turnComplete: true);
    }
    _handleSilenceTimeout(); 
  }

  void _handleVoiceActivity(bool isActive) {
     // STRICT PTT: Ignore VAD signals to prevent "Green Pulse" when button is not held.
     // Turn completion is now fully manual via commitUserTurn().
     if (kDebugMode) {
       // debugPrint('VoiceSessionManager: VAD detected but ignored (Strict PTT)');
     }
  }

  void _handleSilenceTimeout() {
    bool canCommit = _state == VoiceSessionState.active;
    if (canCommit) {
      if (kDebugMode) debugPrint('VoiceSessionManager: 🤫 Turn Ended (Manual/Silence), switching to thinking state');
      if (_voiceService is GeminiLiveService) {
        _voiceService.sendEndTurn();
      } else {
        _voiceService.sendText(" ", turnComplete: true); 
      }
      _setState(VoiceSessionState.thinking);
      
      // Diagnostics: Start Timer
      _lastUserTurnEnd = DateTime.now();
      _turnLatencyStopwatch.start();
    }
  }
  
  void _handleAISpeakingChanged(bool isSpeaking) {
    // Driven by player
  }
  
  void _handleConnectionStateChanged(LiveConnectionState connectionState) {
    if (connectionState == LiveConnectionState.disconnected && 
        _state == VoiceSessionState.active) {
      _setState(VoiceSessionState.error);
      onError?.call('Connection lost');
    }
  }
  
  void _handleTurnComplete() {
    _voicePlayer.flush();
    onTurnComplete?.call();
  }
  
  /// Handle tool calls from Gemini (Phase 42: Sherlock Protocol)
  Future<void> _handleToolCall(String functionName, Map<String, dynamic> args, String callId) async {
    if (kDebugMode) {
      debugPrint('VoiceSessionManager: Tool call received: $functionName');
      debugPrint('🕵️ [SHERLOCK_TRACE] Tool Exec START: $functionName (ID: $callId)');
    }
    
    if (functionName != AiToolsConfig.psychometricToolName) {
      _voiceService.sendToolResponse(functionName, callId, {'error': 'Unknown tool: $functionName'});
      return;
    }
    
    if (psychometricProvider == null) {
      _voiceService.sendToolResponse(functionName, callId, {'error': 'Psychometric provider not configured'});
      return;
    }
    
    try {
      await psychometricProvider!.updateFromToolCall(args);
      _notifyTraitUpdates(args);
      
      if (kDebugMode) debugPrint('VoiceSessionManager: Psychometric profile updated successfully');
      
      _voiceService.sendToolResponse(
        functionName,
        callId,
        {
          'status': 'success',
          'message': 'Psychometric profile updated',
          'updated_fields': args.keys.toList(),
        },
      );

      // === PHASE 55: THE AMBER UNLOCK (REMOVED) ===
      // Logic removed: The "nudge" was interrupting the AI's natural tool response generation
      // causing an infinite "Thinking" state. 
      // We now rely on the model to self-recover or the user to manually interrupt if needed.

    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('VoiceSessionManager: Failed to update psychometric profile: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      _voiceService.sendToolResponse(functionName, callId, {
          'status': 'error',
          'message': 'Failed to update profile: $e',
      });
    }
  }
  
  void _notifyTraitUpdates(Map<String, dynamic> args) {
    if (onTraitUpdated == null) return;
    
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
  
  void _handleThinkingChanged(bool isThinking) {
    if (_state == VoiceSessionState.thinking && !isThinking) {
      _setState(VoiceSessionState.active);
    }
  }

  Future<void> dispose() async {
    await endSession();
    await _audioService.dispose();
    await _voicePlayer.dispose();
  }
}

enum VoiceSessionState {
  idle,
  connecting,
  active,
  paused,
  thinking,
  disconnecting,
  error,
}
