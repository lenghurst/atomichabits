import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

import 'audio_recording_service.dart';
import 'gemini_live_service.dart';

/// Voice Session Manager
/// 
/// Phase 32: FEAT-01 - Audio Recording Integration
/// 
/// Orchestrates the full voice conversation flow by integrating:
/// - AudioRecordingService: Microphone input
/// - GeminiLiveService: AI communication
/// 
/// This manager handles:
/// - Session lifecycle (connect, start, stop, disconnect)
/// - Audio routing (mic → WebSocket, WebSocket → speaker)
/// - State synchronisation between services
/// - Error recovery and graceful degradation
/// 
/// Usage:
/// ```dart
/// final manager = VoiceSessionManager(
///   systemInstruction: 'You are a helpful coach...',
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
  final String? systemInstruction;
  final bool enableTranscription;
  
  // === SERVICES ===
  late final AudioRecordingService _audioService;
  late final GeminiLiveService _geminiService;
  
  /// Expose GeminiLiveService for debug access
  GeminiLiveService? get geminiService => _geminiService;
  
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
  
  VoiceSessionManager({
    this.systemInstruction,
    this.enableTranscription = true,
    this.onTranscription,
    this.onAudioReceived,
    this.onStateChanged,
    this.onError,
    this.onAudioLevelChanged,
    this.onAISpeakingChanged,
    this.onUserSpeakingChanged,
    this.onTurnComplete,
    this.onDebugLogUpdated,
  }) {
    _initializeServices();
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
    
    // Gemini Live Service
    _geminiService = GeminiLiveService(
      onAudioReceived: _handleAIAudio,
      onTranscription: _handleTranscription,
      onModelSpeakingChanged: _handleAISpeakingChanged,
      onConnectionStateChanged: _handleConnectionStateChanged,
      onError: _handleGeminiError,
      onTurnComplete: _handleTurnComplete,
      onDebugLogUpdated: onDebugLogUpdated,
    );
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
      // Step 1: Connect to Gemini Live API
      if (kDebugMode) {
        debugPrint('VoiceSessionManager: Connecting to Gemini Live API...');
      }
      
      final connected = await _geminiService.connect(
        systemInstruction: systemInstruction,
        enableTranscription: enableTranscription,
      );
      
      if (!connected) {
        _setState(VoiceSessionState.error);
        onError?.call('Failed to connect to AI service');
        return false;
      }
      
      // Step 2: Initialise audio recording
      if (kDebugMode) {
        debugPrint('VoiceSessionManager: Initialising audio recording...');
      }
      
      final audioReady = await _audioService.initialize();
      if (!audioReady) {
        await _geminiService.disconnect();
        _setState(VoiceSessionState.error);
        onError?.call('Failed to initialise microphone');
        return false;
      }
      
      // Step 3: Start recording
      if (kDebugMode) {
        debugPrint('VoiceSessionManager: Starting audio recording...');
      }
      
      final recordingStarted = await _audioService.startRecording();
      if (!recordingStarted) {
        await _geminiService.disconnect();
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
      await _geminiService.disconnect();
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
    
    _geminiService.sendText(text);
  }
  
  /// Interrupt the AI's current response.
  void interruptAI() {
    _geminiService.interrupt();
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
    
    // Forward audio to Gemini
    _geminiService.sendAudio(audioData);
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
