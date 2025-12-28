import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Handles streaming audio playback with buffering and WAV header injection.
/// Unifies logic previously duplicated across VoiceCoachScreen and SherlockScreen.
class StreamVoicePlayer {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<int> _audioBuffer = [];
  bool _isPlaying = false;
  
  // ~0.5s at 24kHz 16-bit to prevent stuttering
  static const int _bufferingThreshold = 24000; 

  final StreamController<bool> _playingStateController = StreamController<bool>.broadcast();
  Stream<bool> get isPlayingStream => _playingStateController.stream;

  StreamVoicePlayer() {
    _initialize();
  }

  Future<void> _initialize() async {
    // Initial setup
    await enforceSpeakerOutput();
    
    // Listen for completion
    _audioPlayer.onPlayerComplete.listen((_) {
      if (_audioBuffer.isNotEmpty) {
        _playBufferedAudio();
      } else {
        _setPlaying(false);
      }
    });

    // Handle errors globally for the player
    // audio_players stream might not catch all platform errors, keeping robust try-catch on play()
  }

  void _setPlaying(bool playing) {
    if (_isPlaying != playing) {
      _isPlaying = playing;
      _playingStateController.add(playing);
    }
  }

  /// Force audio to speaker, critical for iOS when microphone is active.
  Future<void> enforceSpeakerOutput() async {
    if (kDebugMode) debugPrint('StreamVoicePlayer: 🔊 Enforcing Speaker Output...');
    
    await _audioPlayer.setVolume(1.0);
    
    await AudioPlayer.global.setAudioContext(AudioContext(
      android: const AudioContextAndroid(
        isSpeakerphoneOn: true,
        stayAwake: true,
        contentType: AndroidContentType.speech,
        usageType: AndroidUsageType.assistant,
        audioFocus: AndroidAudioFocus.gain,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playAndRecord,
        options: {
          AVAudioSessionOptions.defaultToSpeaker,
          AVAudioSessionOptions.allowBluetooth,
          AVAudioSessionOptions.allowAirPlay
        },
      ),
    ));
  }
  
  // Alias for compatibility if needed
  Future<void> enforceSpeaker() => enforceSpeakerOutput();

  /// Processes incoming PCM chunks
  void playChunk(Uint8List audioData) {
    _audioBuffer.addAll(audioData);
    if (!_isPlaying && _audioBuffer.length >= _bufferingThreshold) {
      _playBufferedAudio();
    }
  }

  Future<void> _playBufferedAudio() async {
    if (_audioBuffer.isEmpty) {
      _setPlaying(false);
      return;
    }

    _setPlaying(true);
    
    final List<int> chunk = List.from(_audioBuffer);
    _audioBuffer.clear();

    try {
      final wavBytes = _addWavHeader(Uint8List.fromList(chunk));
      if (kDebugMode) debugPrint('StreamVoicePlayer: ▶️ Playing ${chunk.length} bytes...');
      await _audioPlayer.play(BytesSource(wavBytes));
    } catch (e) {
      debugPrint('StreamVoicePlayer: ❌ Playback Error: $e');
      _setPlaying(false);
    }
  }

  /// Stops playback and clears buffer
  Future<void> stop() async {
    _audioBuffer.clear();
    await _audioPlayer.stop();
    _setPlaying(false);
  }

  /// Force play any remaining buffered audio (called on Turn Complete)
  Future<void> flush() async {
    if (_audioBuffer.isNotEmpty && !_isPlaying) {
      if (kDebugMode) debugPrint('StreamVoicePlayer: 🚽 Flushing ${_audioBuffer.length} bytes...');
      await _playBufferedAudio();
    }
  }

  Future<void> dispose() async {
    await stop();
    await _audioPlayer.dispose();
    await _playingStateController.close();
  }

  /// Adds WAV header to raw PCM data so AudioPlayer can play it
  Uint8List _addWavHeader(Uint8List pcmData) {
    const int sampleRate = 24000;
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
