import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:audio_session/audio_session.dart';
import 'package:path_provider/path_provider.dart';

/// Audio Recording Service - Phase 59.5 (Async File Mode)
/// 
/// Refactored to record directly to file (M4A/AAC) for upload efficiency.
/// Solves the "Echo Nightmare" by using a hybrid stack:
/// 1. flutter_webrtc: Opens a 'dummy' local audio track to force the OS
///    into "Voice Communication Mode" (Hardware AEC + Noise Suppression).
/// 2. record: Captures audio to file.
/// 
class AudioRecordingService {
  // === CONFIGURATION ===
  static const int sampleRate = 24000; // Aligned with Gemini 2.0
  static const int numChannels = 1;
  
  // === STATE ===
  final AudioRecorder _recorder = AudioRecorder();
  bool _isInitialised = false;
  bool _isRecording = false;
  
  // Amplitude Polling for Visualization
  Timer? _amplitudeTimer;
  
  // WebRTC "Anchor" Stream - Holds the hardware AEC lock
  MediaStream? _aecStream;
  bool useWebRtcAnchor = true;
  
  // === CALLBACKS ===
  final void Function(Uint8List audioData)? onAudioData; // Deprecated/Unused in File Mode
  final void Function(String error)? onError;
  final void Function(bool isRecording)? onRecordingStateChanged;
  final void Function(double level)? onAudioLevelChanged;
  final void Function(bool isVoiceActive)? onVoiceActivityDetected; // Deprecated in File Mode
  
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
  
  Future<bool> initialize() async {
    if (_isInitialised) return true;
    
    try {
      if (kDebugMode) debugPrint('AudioRecordingService: 🚀 Initializing File-Based AEC Stack...');
      
      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        onError?.call('Microphone permission denied');
        return false;
      }
      
      // 1. ACTIVATE HARDWARE AEC (The "WebRTC Hack" - Gated)
      if (useWebRtcAnchor) {
        final Map<String, dynamic> mediaConstraints = {
          'audio': {
            'echoCancellation': true,
            'noiseSuppression': true,
            'autoGainControl': true,
          },
          'video': false,
        };

        try {
          _aecStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
          if (kDebugMode) debugPrint('AudioRecordingService: ✅ Hardware AEC Lock Acquired');
        } catch (e) {
          debugPrint('AudioRecordingService: ⚠️ Failed to acquire AEC lock: $e');
          useWebRtcAnchor = false; 
        }
      }
      
      // 2. Configure Audio Session
      final session = await AudioSession.instance;
      await session.configure(AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionMode: AVAudioSessionMode.measurement, // Often better for raw recording
        avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.defaultToSpeaker | 
                                       AVAudioSessionCategoryOptions.allowBluetooth |
                                       AVAudioSessionCategoryOptions.mixWithOthers,
        androidAudioAttributes: const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          usage: AndroidAudioUsage.voiceCommunication,
        ),
      ));
      
      _isInitialised = true;
      return true;
    } catch (e) {
      onError?.call('Failed to initialize audio: $e');
      return false;
    }
  }
  
  /// Start recording to a temporary file.
  Future<void> startRecording({bool isRetry = false}) async {
    if (!_isInitialised) await initialize();
    if (_isRecording) return;
    
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';
      
      final config = RecordConfig(
        encoder: AudioEncoder.aacLc, // Standard efficient format
        sampleRate: sampleRate,
        numChannels: numChannels,
        bitRate: 64000,
      );
      
      await _recorder.start(config, path: filePath);
      
      _isRecording = true;
      onRecordingStateChanged?.call(true);
      
      // Start polling for amplitude (visualization)
      _startAmplitudePolling();
      
    } catch (e) {
       // Retry logic (Simplified for file mode - if Anchor fails, maybe we drop it?)
       if (useWebRtcAnchor && !isRetry) {
          await _releaseAnchor();
          useWebRtcAnchor = false;
          _isInitialised = false;
          return startRecording(isRetry: true);
       }
       onError?.call('Start recording failed: $e');
    }
  }
  
  /// Stop recording and return the file path.
  Future<String?> stopRecording() async {
    if (!_isRecording) return null;
    
    _stopAmplitudePolling();
    
    try {
      final path = await _recorder.stop();
      _isRecording = false;
      onRecordingStateChanged?.call(false);
      return path;
    } catch (e) {
      onError?.call('Stop recording failed: $e');
      _isRecording = false;
      return null;
    }
  }
  
  void _startAmplitudePolling() {
    _amplitudeTimer?.cancel();
    _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      if (!_isRecording) {
        timer.cancel();
        return;
      }
      try {
        final amp = await _recorder.getAmplitude();
        // Convert dBFS to 0.0-1.0 range for UI
        // Typical range: -160 to 0. Let's map -50dB to 0.0 and -10dB to 0.8
        final currentDb = amp.current;
        double normalized = 0.0;
        if (currentDb > -60) {
           normalized = (currentDb + 60) / 60.0; // Map -60..0 to 0..1
        }
        onAudioLevelChanged?.call(normalized.clamp(0.0, 1.0));
      } catch (e) {
        // ignore
      }
    });
  }
  
  void _stopAmplitudePolling() {
    _amplitudeTimer?.cancel();
    _amplitudeTimer = null;
    // Reset level
    onAudioLevelChanged?.call(0.0);
  }

  Future<void> pauseRecording() async {
    if (_isRecording) {
      await _recorder.pause();
      _amplitudeTimer?.cancel(); // Pause polling
    }
  }
  
  Future<void> resumeRecording() async {
    // Note: 'record' package resume might not need re-starting polling if it wasn't stopped?
    // But we cancelled it.
    if (_isRecording) {
      await _recorder.resume();
      _startAmplitudePolling();
    }
  }
  
  Future<void> _releaseAnchor() async {
    if (_aecStream != null) {
      try {
        _aecStream!.getTracks().forEach((track) => track.stop());
        await _aecStream!.dispose();
      } catch (_) {}
      _aecStream = null;
    }
  }
  
  Future<void> dispose() async {
    _stopAmplitudePolling();
    await _recorder.stop(); // Safe stop
    _recorder.dispose();
    await _releaseAnchor();
    _isInitialised = false;
  }
}
