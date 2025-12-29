import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

/// Stream Voice Player - Phase 59.1: Force Playback Protocol
/// 
/// Changes:
/// - Immediate UI feedback (Optimistic State)
/// - Race condition locking for stream initialization
/// - Robust buffer monitoring to auto-reset state on silence
class StreamVoicePlayer {
  final SoLoud _soloud = SoLoud.instance;
  AudioSource? _streamSource;
  SoundHandle? _streamHandle;
  
  bool _isInitialised = false;
  bool _isStartingStream = false; // Busy lock
  
  final StreamController<bool> _playingStateController = StreamController<bool>.broadcast();
  Stream<bool> get isPlayingStream => _playingStateController.stream;
  
  StreamVoicePlayer() {
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isInitialised) return;
    
    try {
      if (kDebugMode) debugPrint('StreamVoicePlayer: 🚀 Initializing SoLoud Engine...');
      
      if (!_soloud.isInitialized) {
        await _soloud.init(
          sampleRate: 24000, 
          bufferSize: 1024,
          channels: Channels.mono,
        );
      }
      
      // Setup the dynamic buffer
      // Note: In SoLoud v3, setBufferStream creates a source we can feed continuously
      _streamSource = _soloud.setBufferStream(
          maxBufferSizeBytes: 2048 * 1024, // 2MB Buffer
          bufferingType: BufferingType.preserved,
          sampleRate: 24000,
          channels: Channels.mono,
          format: BufferType.s16le, 
      );
      
      _isInitialised = true;
      if (kDebugMode) debugPrint('StreamVoicePlayer: ✅ SoLoud Ready');
      
    } catch (e) {
      debugPrint('StreamVoicePlayer: 💥 Init Error: $e');
    }
  }

  /// Feed raw PCM data. Starts playback automatically if needed.
  void playChunk(Uint8List audioData) async {
    if (!_isInitialised || _streamSource == null) return;

    try {
        // 1. Feed the engine immediately (Zero Latency)
        _soloud.addAudioDataStream(_streamSource!, audioData);
        
        // 2. Optimistic State Update:
        // If we just fed data, we should be "Speaking" in the UI.
        // We do this BEFORE the async check to break the "Amber Lock".
        _setPlaying(true); 

        // 3. Ensure the engine is actually pulling data
        bool isHandleInvalid = _streamHandle == null || !_soloud.getIsValidVoiceHandle(_streamHandle!);
        
        if (isHandleInvalid) {
           _ensurePlaybackStarted();
        }
    } catch (e) {
      debugPrint('StreamVoicePlayer: ❌ PlayChunk Error: $e');
    }
  }

  Future<void> _ensurePlaybackStarted() async {
    if (_isStartingStream) return;
    _isStartingStream = true;
    
    try {
      if (kDebugMode) debugPrint('StreamVoicePlayer: ▶️ Force Starting Stream...');
      
      // Start playing the source. It will consume the buffer we just fed.
      _streamHandle = await _soloud.play(_streamSource!);
      
      // Start the "Silence Watchdog"
      _monitorPlaybackState();
    } catch (e) {
      debugPrint('StreamVoicePlayer: ⚠️ Start Error: $e');
      _setPlaying(false); // Revert state if hardware fails
    } finally {
      _isStartingStream = false;
    }
  }

  /// Watchdog: Sets state to Idle when the buffer runs dry
  void _monitorPlaybackState() async {
    // Wait while handle is valid (audio is playing)
    while (_streamHandle != null && _soloud.getIsValidVoiceHandle(_streamHandle!)) {
      // Check every 100ms. If buffer empties, SoLoud invalidates the handle.
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    // Double check we didn't just restart
    if (!_isStartingStream) {
      if (kDebugMode) debugPrint('StreamVoicePlayer: 🤫 Stream Drained (Silence)');
      _setPlaying(false);
    }
  }

  Future<void> stop() async {
    if (_streamHandle != null) {
      await _soloud.stop(_streamHandle!);
      _streamHandle = null;
    }
    _setPlaying(false);
  }

  Future<void> flush() async {
    // Do NOT stop. Just let the watchdog handle the end of the buffer.
    if (kDebugMode) debugPrint('StreamVoicePlayer: 🚽 Flushing (Letting buffer drain naturally)');
  }

  void _setPlaying(bool playing) {
    _playingStateController.add(playing);
  }
  
  // Compatibility shim
  Future<void> enforceSpeakerOutput() async {}

  Future<void> dispose() async {
    await stop();
    _soloud.deinit();
    await _playingStateController.close();
  }
}
