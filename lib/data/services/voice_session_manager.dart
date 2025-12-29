import 'dart:async';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
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

/// Voice Session Manager - Phase 59.3 (Sherlock Restored & Integrated Safety Gate)
class VoiceSessionManager {
  // === CONFIGURATION ===
  final VoiceSessionMode mode;
  final String? systemInstruction;
  final bool enableTranscription;
  final PsychometricProvider? psychometricProvider;
  final UserProfile? userProfile;
  final PsychometricProfile? psychometricProfile;
  
  // === SERVICES ===
  late final AudioRecordingService _audioService;
  late final VoiceApiService _voiceService;
  late final StreamVoicePlayer _voicePlayer;
  
  // === STATE ===
  VoiceSessionState _state = VoiceSessionState.idle;
  bool _isUserSpeaking = false;
  bool _isAISpeaking = false;
  DateTime? _aiSpeechStartTime; // Renamed from _aiStartedSpeakingTime
  static const Duration _safetyGateDuration = Duration(milliseconds: 500);
  
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
    _voicePlayer.isPlayingStream.listen(_handlePlayerStateChange);
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
    // SHERLOCK RESTORATION:
    // Onboarding (Sherlock) REQUIRES tools to function (it's how he "learns").
    // Coaching/Legacy modes can use Deferred Intelligence (Post-Session Analysis) to reduce latency.
    return mode == VoiceSessionMode.onboarding;
  }
  
  Map<String, dynamic>? _getToolsConfig() {
    if (!_shouldEnableTools()) return null;
    return AiToolsConfig.psychometricTool;
  }

  Future<bool> startSession() async {
    if (_state != VoiceSessionState.idle && _state != VoiceSessionState.error) return false;
    _setState(VoiceSessionState.connecting);
    
    try {
      final connected = await _voiceService.connect(
        systemInstruction: _generateSystemInstruction(),
        enableTranscription: enableTranscription,
        tools: _getToolsConfig(),
      );
      if (!connected) {
        _setState(VoiceSessionState.error);
        return false;
      }
      
      await _audioService.initialize();
      await _audioService.startRecording();
      _setState(VoiceSessionState.active);
      return true;
    } catch (e) {
      _setState(VoiceSessionState.error);
      return false;
    }
  }

  Future<void> saveProgression() async {
    if (kDebugMode) debugPrint('VoiceSessionManager: Stub saveProgression() called.');
  }

  Future<void> endSession() async {
    await _audioService.stopRecording();
    await _voicePlayer.stop();
    await _voiceService.disconnect();
    _setState(VoiceSessionState.idle);
  }
  
  Future<void> pauseSession() async {
    await _audioService.pauseRecording();
    await _voicePlayer.stop();
    _setState(VoiceSessionState.paused);
  }
  
  Future<void> resumeSession() async {
    await _audioService.resumeRecording();
    _setState(VoiceSessionState.active);
  }

  /// Handles User Interaction (Tap to Speak / Interrupt).
  /// Enforces the "Safety Gate" to prevent accidental interruptions.
  Future<void> startRecording() async {
    // 1. Safety Gate Check
    // We only guard if the AI is actively speaking (or we think it is).
    // The gate is 500ms from the FIRST byte of audio received.
    if (_isAISpeaking && _aiSpeechStartTime != null) {
      final timeSinceStart = DateTime.now().difference(_aiSpeechStartTime!);
      if (timeSinceStart < _safetyGateDuration) {
        if (kDebugMode) debugPrint('VoiceSessionManager: 🛡️ Input Ignored (Safety Gate active: ${timeSinceStart.inMilliseconds}ms)');
        return;
      }
    }

    // 2. Interrupt Logic
    if (_isAISpeaking) {
      if (kDebugMode) debugPrint('VoiceSessionManager: 🛑 Interrupting AI...');
      
      // Stop Output immediately
      await _voicePlayer.stop(); 
      
      // Send Interrupt Signal to AI Service
      _voiceService.interrupt();
      
      // Force state update immediately for UI responsiveness
      _handlePlayerStateChange(false);
    }
    
    // 3. Prevent "Double Tap" or invalid state re-entry
    if (_state != VoiceSessionState.thinking && _state != VoiceSessionState.active && _state != VoiceSessionState.paused) {
        return;
    }
    
    // 4. Resume Input
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
    _state = newState;
    onStateChanged?.call(newState);
  }
  
  void _handleMicrophoneAudio(Uint8List audioData) {
    if (_state != VoiceSessionState.active) return;
    _voiceService.sendAudio(audioData);
  }
  
  void _handleAIAudio(Uint8List audioData) {
    // === UI OVERRIDE ===
    // If we receive data, we ARE speaking. Don't wait for the player callback.
    // This immediately fixes the "Amber Lock" by forcing the UI to Purple.
    if (!_isAISpeaking) {
      if (kDebugMode) debugPrint('VoiceSessionManager: ⚡ Force-Switching UI to Speaking (Data Received)');
      _isAISpeaking = true;
      _aiSpeechStartTime = DateTime.now();
      onAISpeakingChanged?.call(true);
    }
    
    _voicePlayer.playChunk(audioData);
    
    // Minimal visualization using amplitude of received chunk
    // (Optional: drive Orb radius here if Player is silent)
  }

  void _handleTurnComplete() {
    if (kDebugMode) debugPrint('VoiceSessionManager: ✅ AI Turn Complete');
    _voicePlayer.flush(); // Don't stop, let it drain
    onTurnComplete?.call();
  }

  void _handleTranscription(String text, bool isUser) {
    _transcript.add({'role': isUser ? 'user' : 'model', 'content': text});
    onTranscription?.call(text, isUser);
  }
  void _handleAudioError(String error) => onError?.call(error);
  void _handleGeminiError(String error) => onError?.call(error);
  void _handleRecordingStateChanged(bool isRecording) {}
  
  Future<void> commitUserTurn() async {
    if (_state != VoiceSessionState.active) return;
    if (_voiceService is GeminiLiveService) {
      _voiceService.sendEndTurn();
    } else {
      _voiceService.sendText(" ", turnComplete: true);
    }
    _setState(VoiceSessionState.thinking);
  }

  void _handleVoiceActivity(bool isActive) {} // Strict PTT ignores this
  
  void _handleAISpeakingChanged(bool isSpeaking) {
    // Handled by player listener
  }
  
  void _handleConnectionStateChanged(LiveConnectionState connectionState) {
    if (connectionState == LiveConnectionState.disconnected && _state == VoiceSessionState.active) {
      _setState(VoiceSessionState.error);
    }
  }
  
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

  void _handlePlayerStateChange(bool isPlaying) {
    if (kDebugMode) debugPrint(isPlaying ? 'VoiceSessionManager: 🗣️ Player Reported Speaking' : 'VoiceSessionManager: 🤫 Player Reported Silence');
    
    // Only update if we aren't already in that state (Debounce)
    if (_isAISpeaking != isPlaying) {
      _isAISpeaking = isPlaying;
      if (isPlaying) _aiSpeechStartTime = DateTime.now();
      onAISpeakingChanged?.call(isPlaying);
    }
    
    if (!isPlaying && (_state == VoiceSessionState.thinking || _state == VoiceSessionState.active)) {
       _setState(VoiceSessionState.paused); 
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
