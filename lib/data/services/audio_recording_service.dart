import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audio_session/audio_session.dart';

/// Audio Recording Service for Voice AI
/// 
/// Phase 32: FEAT-01 - Audio Recording Implementation
/// 
/// Provides real-time audio recording with streaming support for:
/// - Microphone permission handling
/// - Audio session management (interruptions, routing)
/// - Real-time PCM audio streaming to WebSocket
/// - Voice Activity Detection (VAD) support
/// 
/// Audio Format (Gemini Live API requirements):
/// - Sample Rate: 16000 Hz
/// - Channels: Mono (1)
/// - Encoding: PCM 16-bit signed little-endian
/// 
/// Usage:
/// ```dart
/// final audioService = AudioRecordingService(
///   onAudioData: (data) => geminiService.sendAudio(data),
///   onError: (error) => print('Audio error: $error'),
/// );
/// await audioService.initialize();
/// await audioService.startRecording();
/// // ... user speaks ...
/// await audioService.stopRecording();
/// ```
class AudioRecordingService {
  // === CONFIGURATION ===
  /// Sample rate required by Gemini Live API
  static const int sampleRate = 16000;
  
  /// Mono audio for voice
  static const int numChannels = 1;
  
  /// 16-bit PCM encoding
  static const int bitDepth = 16;
  
  /// Buffer size in milliseconds (smaller = lower latency, higher CPU)
  static const int bufferMs = 100;
  
  // === STATE ===
  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _audioSubscription;
  bool _isInitialised = false;
  bool _isRecording = false;
  AudioSession? _audioSession;
  
  // === CALLBACKS ===
  /// Called when audio data is available for streaming
  final void Function(Uint8List audioData)? onAudioData;
  
  /// Called when an error occurs
  final void Function(String error)? onError;
  
  /// Called when recording state changes
  final void Function(bool isRecording)? onRecordingStateChanged;
  
  /// Called when audio level changes (for visualisation)
  final void Function(double level)? onAudioLevelChanged;
  
  /// Called when voice activity is detected
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
  
  /// Initialise the audio recording service.
  /// 
  /// This method:
  /// 1. Requests microphone permission
  /// 2. Configures the audio session for voice recording
  /// 3. Sets up interruption handling
  /// 
  /// Returns true if initialisation was successful.
  Future<bool> initialize() async {
    if (_isInitialised) return true;
    
    try {
      // Step 1: Request microphone permission
      final permissionStatus = await _requestMicrophonePermission();
      if (!permissionStatus) {
        onError?.call('Microphone permission denied');
        return false;
      }
      
      // Step 2: Check if recording is supported
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        onError?.call('Recording not supported on this device');
        return false;
      }
      
      // Step 3: Configure audio session
      await _configureAudioSession();
      
      _isInitialised = true;
      if (kDebugMode) {
        debugPrint('AudioRecordingService: Initialised successfully');
        debugPrint('  - Sample Rate: $sampleRate Hz');
        debugPrint('  - Channels: $numChannels (Mono)');
        debugPrint('  - Bit Depth: $bitDepth-bit');
        debugPrint('  - Buffer: ${bufferMs}ms');
      }
      
      return true;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('AudioRecordingService: Initialisation failed: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      onError?.call('Failed to initialise audio: $e');
      return false;
    }
  }
  
  /// Request microphone permission from the user.
  Future<bool> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    
    if (kDebugMode) {
      debugPrint('AudioRecordingService: Microphone permission status: $status');
    }
    
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      // User has permanently denied permission, need to open settings
      onError?.call('Microphone permission permanently denied. Please enable in Settings.');
      return false;
    } else {
      return false;
    }
  }
  
  /// Configure the audio session for voice recording.
  /// 
  /// This ensures proper handling of:
  /// - Audio interruptions (phone calls, other apps)
  /// - Audio routing (speaker, headphones, Bluetooth)
  /// - Audio focus management
  Future<void> _configureAudioSession() async {
    _audioSession = await AudioSession.instance;
    
    await _audioSession!.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionMode: AVAudioSessionMode.videoChat,
      avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.defaultToSpeaker | AVAudioSessionCategoryOptions.allowBluetooth,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
    
    // Listen for interruptions
    _audioSession!.interruptionEventStream.listen((event) {
      if (event.begin) {
        if (kDebugMode) {
          debugPrint('AudioRecordingService: Audio interrupted (${event.type})');
        }
        // Pause recording on interruption
        if (_isRecording) {
          pauseRecording();
        }
      } else {
        if (kDebugMode) {
          debugPrint('AudioRecordingService: Audio interruption ended');
        }
        // Could resume recording here if desired
      }
    });
    
    // Activate the session
    await _audioSession!.setActive(true);
  }
  
  /// Start recording audio and streaming to the callback.
  /// 
  /// Audio is streamed in real-time as PCM data suitable for
  /// the Gemini Live API.
  Future<bool> startRecording() async {
    if (!_isInitialised) {
      final success = await initialize();
      if (!success) return false;
    }
    
    if (_isRecording) {
      if (kDebugMode) {
        debugPrint('AudioRecordingService: Already recording');
      }
      return true;
    }
    
    try {
      // Configure the recording stream
      final stream = await _recorder.startStream(RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: sampleRate,
        numChannels: numChannels,
        bitRate: sampleRate * numChannels * bitDepth,
      ));
      
      // Subscribe to the audio stream
      _audioSubscription = stream.listen(
        (data) {
          // Forward audio data to callback
          onAudioData?.call(data);
          
          // Calculate audio level for visualisation
          _calculateAudioLevel(data);
        },
        onError: (error) {
          if (kDebugMode) {
            debugPrint('AudioRecordingService: Stream error: $error');
          }
          onError?.call('Audio stream error: $error');
        },
        onDone: () {
          if (kDebugMode) {
            debugPrint('AudioRecordingService: Stream completed');
          }
        },
      );
      
      _isRecording = true;
      onRecordingStateChanged?.call(true);
      
      if (kDebugMode) {
        debugPrint('AudioRecordingService: Recording started');
      }
      
      return true;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('AudioRecordingService: Failed to start recording: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      onError?.call('Failed to start recording: $e');
      return false;
    }
  }
  
  /// Pause recording temporarily.
  Future<void> pauseRecording() async {
    if (!_isRecording) return;
    
    try {
      await _recorder.pause();
      if (kDebugMode) {
        debugPrint('AudioRecordingService: Recording paused');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AudioRecordingService: Failed to pause: $e');
      }
    }
  }
  
  /// Resume recording after pause.
  Future<void> resumeRecording() async {
    if (!_isRecording) return;
    
    try {
      await _recorder.resume();
      if (kDebugMode) {
        debugPrint('AudioRecordingService: Recording resumed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AudioRecordingService: Failed to resume: $e');
      }
    }
  }
  
  /// Stop recording and clean up resources.
  Future<void> stopRecording() async {
    if (!_isRecording) return;
    
    try {
      await _audioSubscription?.cancel();
      _audioSubscription = null;
      
      await _recorder.stop();
      
      _isRecording = false;
      onRecordingStateChanged?.call(false);
      
      if (kDebugMode) {
        debugPrint('AudioRecordingService: Recording stopped');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AudioRecordingService: Error stopping recording: $e');
      }
    }
  }
  
  /// Calculate audio level from PCM data for visualisation.
  /// 
  /// Returns a normalised value between 0.0 and 1.0.
  void _calculateAudioLevel(Uint8List data) {
    if (data.isEmpty) return;
    
    // Convert bytes to 16-bit samples
    final samples = data.buffer.asInt16List();
    if (samples.isEmpty) return;
    
    // Calculate RMS (Root Mean Square) for audio level
    double sum = 0;
    for (final sample in samples) {
      sum += sample * sample;
    }
    final rms = sum / samples.length;
    final level = rms > 0 ? (rms / 32768.0 / 32768.0).clamp(0.0, 1.0) : 0.0;
    
    // Normalise to 0-1 range with some smoothing
    final normalisedLevel = (level * 10).clamp(0.0, 1.0);
    
    onAudioLevelChanged?.call(normalisedLevel);
    
    // Simple voice activity detection based on level threshold
    final isVoiceActive = normalisedLevel > 0.05;
    onVoiceActivityDetected?.call(isVoiceActive);
  }
  
  /// Dispose of all resources.
  Future<void> dispose() async {
    await stopRecording();
    await _audioSession?.setActive(false);
    _recorder.dispose();
    _isInitialised = false;
    
    if (kDebugMode) {
      debugPrint('AudioRecordingService: Disposed');
    }
  }
}
