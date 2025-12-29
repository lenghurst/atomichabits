import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'dart:math' as math;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:audio_session/audio_session.dart';

/// Audio Recording Service - Architecture Refactor (AEC Enforced)
/// 
/// Solves the "Echo Nightmare" by using a hybrid stack:
/// 1. flutter_webrtc: Opens a 'dummy' local audio track to force the OS
///    into "Voice Communication Mode" (Hardware AEC + Noise Suppression).
/// 2. record: Captures the clean, pre-processed audio stream for the AI.
/// 
/// STABILITY UPDATE (Phase 59.1):
/// Includes fallback logic. If the WebRTC anchor causes a resource lock on 
/// Android (preventing the recorder from starting), we release the anchor 
/// and retry in standard mode.
class AudioRecordingService {
  // === CONFIGURATION ===
  static const int sampleRate = 16000;
  static const int numChannels = 1;
  static const int bitDepth = 16;
  
  /// Adaptive VAD State
  double _adaptiveNoiseFloor = 0.02;
  
  // === STATE ===
  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _audioSubscription;
  bool _isInitialised = false;
  bool _isRecording = false;
  
  // WebRTC "Anchor" Stream - Holds the hardware AEC lock
  MediaStream? _aecStream;
  
  // === SAFETY FUSE ===
  // If native audio_session fails on certain Android OEMs, this anchor forces AEC.
  bool useWebRtcAnchor = true;
  
  // === CALLBACKS ===
  final void Function(Uint8List audioData)? onAudioData;
  final void Function(String error)? onError;
  final void Function(bool isRecording)? onRecordingStateChanged;
  final void Function(double level)? onAudioLevelChanged;
  final void Function(bool isVoiceActive)? onVoiceActivityDetected;
  
  AudioRecordingService({
    this.onAudioData,
    this.onError,
    this.onRecordingStateChanged,
    this.onAudioLevelChanged,
    this.onVoiceActivityDetected,
  });
  
  // === PUBLIC GETTERS ===
  bool get isInitialised => _isInitialised;
  bool get isRecording => _isRecording;
  
  /// Initialise the audio stack with Hardware AEC Enforcement.
  Future<bool> initialize() async {
    if (_isInitialised) return true;
    if (kDebugMode) debugPrint('AudioRecordingService: 🚀 Initializing Hybrid AEC Stack (Anchor: $useWebRtcAnchor)...');
    
    try {
      // 1. Permission Check
      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        onError?.call('Microphone permission denied');
        return false;
      }
      
      // 2. ACTIVATE HARDWARE AEC (The "WebRTC Hack" - Gated)
      if (useWebRtcAnchor) {
        final Map<String, dynamic> mediaConstraints = {
          'audio': {
            'echoCancellation': true,
            'noiseSuppression': true,
            'autoGainControl': true,
            'googEchoCancellation': true,
            'googNoiseSuppression': true,
            'googHighpassFilter': true,
          },
          'video': false,
        };

        try {
          _aecStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
          if (kDebugMode) debugPrint('AudioRecordingService: ✅ Hardware AEC Lock Acquired');
        } catch (e) {
          debugPrint('AudioRecordingService: ⚠️ Failed to acquire AEC lock: $e');
          // Update config to reflect reality so we don't try to release a null stream later
          useWebRtcAnchor = false; 
        }
      }
      
      // 3. Configure Audio Session (The Native Foundation)
      // This is now the Primary method, with WebRTC as the reinforcement.
      final session = await AudioSession.instance;
      await session.configure(AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionMode: AVAudioSessionMode.voiceChat, // Critical for iOS AEC
        avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.defaultToSpeaker | 
                                       AVAudioSessionCategoryOptions.allowBluetooth |
                                       AVAudioSessionCategoryOptions.mixWithOthers, // Allow background audio
        androidAudioAttributes: const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          usage: AndroidAudioUsage.voiceCommunication, // Critical for Android AEC
        ),
      ));
      
      _isInitialised = true;
      return true;
    } catch (e) {
      onError?.call('Failed to initialize audio: $e');
      return false;
    }
  }
  
  /// Start recording the *clean* audio stream.
  /// 
  /// [isRetry] is a recursion guard. If the first attempt fails due to resource locking,
  /// we disable the WebRTC anchor and try exactly one more time.
  Future<bool> startRecording({bool isRetry = false}) async {
    if (!_isInitialised) await initialize();
    if (_isRecording) return true;
    
    try {
      final config = RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: sampleRate,
        numChannels: numChannels,
      );
      
      final stream = await _recorder.startStream(config);
      
      _audioSubscription = stream.listen(
        (data) {
          onAudioData?.call(data);
          _calculateAudioLevel(data);
        },
        onError: (e) => onError?.call('Stream error: $e'),
      );
      
      _isRecording = true;
      onRecordingStateChanged?.call(true);
      return true;
    } catch (e) {
      // === FAILURE HANDLING & RETRY LOGIC ===
      // If we are using the Anchor and we haven't already retried:
      if (useWebRtcAnchor && !isRetry) {
        debugPrint('AudioRecordingService: ⚠️ Resource locking detected ($e). Releasing WebRTC Anchor and retrying...');
        
        // 1. Release the lock which is likely blocking the recorder
        await _releaseAnchor(); 
        
        // 2. Update config to prevent re-acquisition
        useWebRtcAnchor = false;
        _isInitialised = false; // Force re-initialization with new config
        
        // 3. Retry once (Recursion)
        return startRecording(isRetry: true);
      }

      onError?.call('Start recording failed: $e');
      return false;
    }
  }
  
  /// Stop recording but keep AEC lock if possible (for quick resume).
  Future<void> stopRecording() async {
    if (!_isRecording) return;
    
    await _audioSubscription?.cancel();
    await _recorder.stop();
    _isRecording = false;
    onRecordingStateChanged?.call(false);
  }
  
  Future<void> pauseRecording() async {
    if (_isRecording) await _recorder.pause();
  }
  
  Future<void> resumeRecording() async {
    if (_isRecording) await _recorder.resume();
  }
  
  /// Helper to safely release the WebRTC stream
  Future<void> _releaseAnchor() async {
    if (_aecStream != null) {
      try {
        _aecStream!.getTracks().forEach((track) => track.stop());
        await _aecStream!.dispose();
        debugPrint('AudioRecordingService: ⚓ WebRTC Anchor Released');
      } catch (e) {
        debugPrint('AudioRecordingService: ⚠️ Error releasing anchor: $e');
      } finally {
        _aecStream = null;
      }
    }
  }
  
  /// Full cleanup releasing the Hardware AEC Lock.
  Future<void> dispose() async {
    await stopRecording();
    _recorder.dispose();
    await _releaseAnchor();
    _isInitialised = false;
  }

  // --- VAD & Visualization Logic (Unchanged) ---
  void _calculateAudioLevel(Uint8List data) {
    if (data.isEmpty) return;
    final samples = data.buffer.asInt16List();
    double sumSquares = 0;
    for (final sample in samples) {
      final normalized = sample / 32768.0;
      sumSquares += normalized * normalized;
    }
    final rms = math.sqrt(sumSquares / samples.length);
    
    // Adaptive Noise Floor
    if (rms < _adaptiveNoiseFloor) {
      _adaptiveNoiseFloor = rms;
    } else {
      _adaptiveNoiseFloor += 0.0001;
    }
    if (_adaptiveNoiseFloor < 0.005) _adaptiveNoiseFloor = 0.005;
    if (_adaptiveNoiseFloor > 0.1) _adaptiveNoiseFloor = 0.1;

    final vadThreshold = _adaptiveNoiseFloor + 0.03; // ~10dB margin
    final isVoiceActive = rms > vadThreshold;
    
    double displayLevel = isVoiceActive 
        ? ((rms - _adaptiveNoiseFloor) * 5.0).clamp(0.2, 1.0)
        : (rms * 2.0).clamp(0.0, 0.1);
    
    onAudioLevelChanged?.call(displayLevel);
    onVoiceActivityDetected?.call(isVoiceActive);
  }
}
