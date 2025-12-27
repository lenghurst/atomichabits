import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:sound_stream/sound_stream.dart';
import 'package:audio_session/audio_session.dart';

/// Audio Playback Service
///
/// Phase 33.5: Low-latency Audio Streaming for Voice AI
///
/// Provides a unified interface for streaming raw PCM audio to the device's
/// audio output. Uses `sound_stream` for low-latency playback and
/// `audio_session` for robust session management (speaker enforcement).
class AudioPlaybackService {
  // === CONFIGURATION ===
  static const int _sampleRate = 24000;
  static const int _bufferSize = 2048; // Adjust based on latency vs. stability needs

  // === STATE ===
  PlayerStream? _player;
  StreamSubscription? _statusSubscription;
  bool _isInitialized = false;

  // === GETTERS ===
  bool get isInitialized => _isInitialized;

  /// Initialize the audio playback service
  ///
  /// Sets up the audio session and initializes the player stream.
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (kDebugMode) {
      debugPrint('AudioPlaybackService: Initializing...');
    }

    try {
      // 1. Configure Audio Session (Speaker Enforcement)
      await _configureAudioSession();

      // 2. Initialize Player Stream
      _player = PlayerStream();

      // Listen for status updates if needed (e.g. buffer empty)
      _statusSubscription = _player!.status.listen((status) {
        if (kDebugMode) {
          // debugPrint('AudioPlaybackService: Status: $status');
        }
      });

      // Initialize the underlying native player
      await _player!.initialize(
        sampleRate: _sampleRate,
        showNotification: false,
      );

      _isInitialized = true;

      if (kDebugMode) {
        debugPrint('AudioPlaybackService: Initialized (24kHz, PCM 16-bit)');
      }
    } catch (e) {
      debugPrint('AudioPlaybackService: Initialization error: $e');
      // Attempt cleanup on failure
      await dispose();
      rethrow;
    }
  }

  /// Configure the global audio session
  ///
  /// Ensures we can play audio while recording, and defaults to the speaker.
  Future<void> _configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.allowBluetooth |
                                     AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.voiceChat,
      avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));

    if (kDebugMode) {
      debugPrint('AudioPlaybackService: Audio Session Configured (PlayAndRecord, Speaker)');
    }
  }

  /// Write raw PCM audio data to the stream
  ///
  /// [audioData] should be 16-bit PCM, 24kHz, Mono.
  Future<void> write(Uint8List audioData) async {
    if (!_isInitialized || _player == null) {
      if (kDebugMode) {
        debugPrint('AudioPlaybackService: Attempted to write before initialization');
      }
      return;
    }

    try {
      await _player!.writeChunk(audioData);
    } catch (e) {
      debugPrint('AudioPlaybackService: Write error: $e');
    }
  }

  /// Stop playback (clear buffer)
  Future<void> stop() async {
    if (!_isInitialized || _player == null) return;
    try {
      await _player!.stop();
    } catch (e) {
      debugPrint('AudioPlaybackService: Stop error: $e');
    }
  }

  /// Dispose of resources
  Future<void> dispose() async {
    _isInitialized = false;
    await _statusSubscription?.cancel();
    _statusSubscription = null;

    if (_player != null) {
      try {
        await _player!.dispose();
      } catch (e) {
        debugPrint('AudioPlaybackService: Dispose error: $e');
      }
      _player = null;
    }
  }
}
