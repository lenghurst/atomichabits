import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

/// Stream Voice Player - Phase 59.2: Output Stabilization
/// 
/// Updates:
/// - Implements "Silence Debouncing" to bridge network latency gaps.
/// - Prevents UI flickering by holding "Speaking" state during buffer underruns.
/// - Optimistic state management with race-condition guards.
class StreamVoicePlayer {
  final SoLoud _soloud = SoLoud.instance;
  AudioSource? _streamSource;
  SoundHandle? _streamHandle;
  
  bool _isInitialised = false;
  bool _isStartingStream = false; // Busy lock
  
  // === SILENCE DEBOUNCER ===
  // Prevents state flickering when buffer runs dry due to network latency.
  Timer? _silenceGraceTimer;
  static const Duration _gracePeriod = Duration(milliseconds: 600);
  
  final StreamController<bool> _playingStateController = StreamController<bool>.broadcast();
  Stream<bool> get isPlayingStream => _playingStateController.stream;
  
  StreamVoicePlayer({bool autoInit = true}) {
    if (autoInit) _initialize();
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
        if (kDebugMode) debugPrint('StreamVoicePlayer: [TRACE] 📥 Chunk Received (${audioData.length} bytes)');

        // 1. Cancel any pending silence timer (The Bridge)
        // We received data, so we are definitely still speaking.
        if (_silenceGraceTimer?.isActive ?? false) {
          _silenceGraceTimer!.cancel();
          if (kDebugMode) debugPrint('StreamVoicePlayer: [TRACE] 🌉 Latency Bridge Active (Timer Cancelled)');
        }

        // 2. Feed the engine immediately (Zero Latency)
        _soloud.addAudioDataStream(_streamSource!, audioData);
        
        // 3. Optimistic State Update:
        // We do this BEFORE the async check to ensure UI responsiveness.
        _setPlaying(true); 

        // 4. Ensure the engine is actually pulling data
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

  /// Watchdog: Monitors the buffer and handles the transition to silence.
  void _monitorPlaybackState() async {
    // Wait while handle is valid (audio is playing)
    while (_streamHandle != null && _soloud.getIsValidVoiceHandle(_streamHandle!)) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    // Double check we didn't just restart in a race condition
    if (!_isStartingStream) {
      if (kDebugMode) debugPrint('StreamVoicePlayer: [TRACE] ⏳ Buffer Drained. Starting Grace Period (${_gracePeriod.inMilliseconds}ms)...');
      
      // === GRACE PERIOD ===
      // Don't kill the UI state immediately. Wait to see if more packets arrive.
      _silenceGraceTimer?.cancel();
      _silenceGraceTimer = Timer(_gracePeriod, () {
        if (kDebugMode) debugPrint('StreamVoicePlayer: [TRACE] 🤫 Silence Confirmed (Grace Period Expired)');
        _setPlaying(false);
        _streamHandle = null; // Clean up the handle reference
      });
    }
  }

  Future<void> stop() async {
    _silenceGraceTimer?.cancel();
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
    if (kDebugMode) debugPrint('StreamVoicePlayer: [TRACE] State Update -> $playing');
    _playingStateController.add(playing);
  }
  
  // Compatibility shim
  Future<void> enforceSpeakerOutput() async {}

  Future<void> dispose() async {
    _silenceGraceTimer?.cancel();
    await stop();
    _soloud.deinit();
    await _playingStateController.close();
  }
}
