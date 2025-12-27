import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Stream Voice Player
/// 
/// Handles real-time audio playback for Gemini/Sherlock.
/// Encapsulates:
/// - Audio buffering (to prevent stutter)
/// - WAV header injection (for raw PCM support)
/// - Speaker enforcement (AudioContext)
class StreamVoicePlayer {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<int> _audioBuffer = [];
  
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;
  
  // Callback for state changes (e.g., for UI animations)
  final void Function(bool isPlaying)? onPlayingStateChanged;
  
  // Configuration
  static const int _bufferingThreshold = 24000; // ~0.5s at 24kHz 16-bit
  static const int _sampleRate = 24000;
  
  StreamVoicePlayer({this.onPlayingStateChanged});

  /// Initialize the player and enforce speaker output
  Future<void> initialize() async {
    await _enforceSpeakerOutput();
  }

  /// Add audio chunk to buffer and attempt to play
  void playChunk(Uint8List chunk) {
    _audioBuffer.addAll(chunk);
    
    // Start playing if not already playing and buffer is sufficient
    if (!_isPlaying && _audioBuffer.length >= _bufferingThreshold) {
      _playBufferedAudio();
    }
  }
  
  /// Stop playback and clear buffer
  Future<void> stop() async {
    _audioBuffer.clear();
    await _audioPlayer.stop();
    _setPlaying(false);
  }
  
  /// Re-enforce speaker output (useful after mic permission grants)
  Future<void> enforceSpeaker() async {
    await _enforceSpeakerOutput();
  }
  
  /// Dispose resources
  Future<void> dispose() async {
    await stop();
    await _audioPlayer.dispose();
  }

  // === INTERNAL LOGIC ===

  void _setPlaying(bool playing) {
    if (_isPlaying != playing) {
      _isPlaying = playing;
      onPlayingStateChanged?.call(playing);
    }
  }

  Future<void> _playBufferedAudio() async {
    if (_audioBuffer.isEmpty) {
      _setPlaying(false);
      return;
    }

    _setPlaying(true);
    
    // Take a snapshot of the buffer
    final List<int> chunk = List.from(_audioBuffer);
    _audioBuffer.clear();

    try {
      final wavBytes = _addWavHeader(Uint8List.fromList(chunk));
      
      if (kDebugMode) {
        debugPrint('StreamVoicePlayer: ▶️ Playing ${chunk.length} bytes...');
      }
      
      await _audioPlayer.play(BytesSource(wavBytes));
      
      // Wait for completion with timeout based on audio length
      try {
        // Calculate duration: bytes / (sampleRate * channels * bytesPerSample)
        // 24000Hz * 1 channel * 2 bytes = 48000 bytes/sec
        final durationMs = (chunk.length / 48).round();
        
        await _audioPlayer.onPlayerComplete.first.timeout(
          Duration(milliseconds: durationMs + 1000), // Add 1s buffer
          onTimeout: () => null,
        );
      } catch (_) {
        // Ignore timeout errors
      }
      
      // Recursive call to play next chunk if available
      if (_audioBuffer.isNotEmpty) {
        await _playBufferedAudio();
      } else {
        _setPlaying(false);
      }
    } catch (e) {
      debugPrint('StreamVoicePlayer: ❌ Playback Error: $e');
      _setPlaying(false);
    }
  }

  /// CRITICAL: Force audio to speaker, even if mic is on
  Future<void> _enforceSpeakerOutput() async {
    if (kDebugMode) debugPrint('StreamVoicePlayer: 🔊 Enforcing Speaker Output...');
    
    await _audioPlayer.setVolume(1.0); // Ensure volume is max
    
    await AudioPlayer.global.setAudioContext(AudioContext(
      android: const AudioContextAndroid(
        isSpeakerphoneOn: true,
        stayAwake: true,
        contentType: AndroidContentType.speech,
        usageType: AndroidUsageType.assistant,
        audioFocus: AndroidAudioFocus.gain,
      ),
      iOS: AudioContextIOS(
        // 'playAndRecord' is required to hear audio while mic is active
        category: AVAudioSessionCategory.playAndRecord, 
        options: {
          AVAudioSessionOptions.defaultToSpeaker, 
          AVAudioSessionOptions.allowBluetooth,
          AVAudioSessionOptions.allowAirPlay
        },
      ),
    ));
  }

  Uint8List _addWavHeader(Uint8List pcmData) {
    const int sampleRate = _sampleRate;
    const int numChannels = 1;
    const int bitsPerSample = 16;
    
    final int byteRate = sampleRate * numChannels * bitsPerSample ~/ 8;
    final int blockAlign = numChannels * bitsPerSample ~/ 8;
    final int dataSize = pcmData.length;
    final int fileSize = 36 + dataSize;

    final header = Uint8List(44);
    final view = ByteData.view(header.buffer);

    header.setRange(0, 4, ascii.encode('RIFF'));
    view.setUint32(4, fileSize, Endian.little);
    header.setRange(8, 12, ascii.encode('WAVE'));
    header.setRange(12, 16, ascii.encode('fmt '));
    view.setUint32(16, 16, Endian.little);
    view.setUint16(20, 1, Endian.little);
    view.setUint16(22, numChannels, Endian.little);
    view.setUint32(24, sampleRate, Endian.little);
    view.setUint32(28, byteRate, Endian.little);
    view.setUint16(32, blockAlign, Endian.little);
    view.setUint16(34, bitsPerSample, Endian.little);
    header.setRange(36, 40, ascii.encode('data'));
    view.setUint32(40, dataSize, Endian.little);

    final wavFile = Uint8List(44 + dataSize);
    wavFile.setRange(0, 44, header);
    wavFile.setRange(44, 44 + dataSize, pcmData);
    
    return wavFile;
  }
}
