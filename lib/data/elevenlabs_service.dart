import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// ElevenLabs Voice Service
///
/// Provides high-quality text-to-speech synthesis for the AI coaching experience.
/// Uses ElevenLabs' neural voice models for natural, human-like speech.
///
/// Recommended voices for coaching:
/// - "Sarah" (EXAVITQu4vr4xnSDxMaL) - Warm, professional, American female
/// - "Rachel" (21m00Tcm4TlvDq8ikWAM) - Calm, soothing, American female
/// - "Adam" (pNInz6obpgDQGcFmaJgB) - Deep, confident, American male
/// - "Antoni" (ErXwobaYiN019PkySvjV) - Warm, friendly, British male
class ElevenLabsService {
  final String apiKey;
  final String voiceId;
  final String modelId;
  final VoiceSettings settings;

  // API endpoints
  static const String _baseUrl = 'https://api.elevenlabs.io/v1';

  // Audio cache for repeated phrases
  final Map<String, Uint8List> _audioCache = {};

  ElevenLabsService({
    required this.apiKey,
    this.voiceId = 'EXAVITQu4vr4xnSDxMaL', // Sarah - warm, professional
    this.modelId = 'eleven_multilingual_v2', // Best quality model
    VoiceSettings? settings,
  }) : settings = settings ?? const VoiceSettings();

  /// Synthesize text to speech
  /// Returns audio data as bytes (MP3 format)
  Future<Uint8List?> synthesize(String text) async {
    if (apiKey.isEmpty) {
      if (kDebugMode) {
        debugPrint('ElevenLabs: API key not configured');
      }
      return null;
    }

    // Check cache first
    final cacheKey = _getCacheKey(text);
    if (_audioCache.containsKey(cacheKey)) {
      return _audioCache[cacheKey];
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/text-to-speech/$voiceId'),
        headers: {
          'Accept': 'audio/mpeg',
          'Content-Type': 'application/json',
          'xi-api-key': apiKey,
        },
        body: jsonEncode({
          'text': text,
          'model_id': modelId,
          'voice_settings': settings.toJson(),
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final audioData = response.bodyBytes;

        // Cache the result
        _audioCache[cacheKey] = audioData;

        return audioData;
      } else {
        if (kDebugMode) {
          debugPrint('ElevenLabs error: ${response.statusCode} - ${response.body}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ElevenLabs synthesis error: $e');
      }
      return null;
    }
  }

  /// Synthesize with streaming (for real-time playback)
  /// Yields audio chunks as they become available
  Stream<Uint8List> synthesizeStream(String text) async* {
    if (apiKey.isEmpty) {
      return;
    }

    try {
      final request = http.Request(
        'POST',
        Uri.parse('$_baseUrl/text-to-speech/$voiceId/stream'),
      );

      request.headers.addAll({
        'Accept': 'audio/mpeg',
        'Content-Type': 'application/json',
        'xi-api-key': apiKey,
      });

      request.body = jsonEncode({
        'text': text,
        'model_id': modelId,
        'voice_settings': settings.toJson(),
      });

      final response = await http.Client().send(request);

      if (response.statusCode == 200) {
        await for (final chunk in response.stream) {
          yield Uint8List.fromList(chunk);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ElevenLabs streaming error: $e');
      }
    }
  }

  /// Get available voices
  Future<List<VoiceInfo>> getVoices() async {
    if (apiKey.isEmpty) return [];

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/voices'),
        headers: {'xi-api-key': apiKey},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final voices = data['voices'] as List;

        return voices.map((v) => VoiceInfo.fromJson(v)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching voices: $e');
      }
    }

    return [];
  }

  /// Clear audio cache
  void clearCache() {
    _audioCache.clear();
  }

  /// Get cache key for text
  String _getCacheKey(String text) {
    // Use first 100 chars + length as cache key
    final truncated = text.length > 100 ? text.substring(0, 100) : text;
    return '$voiceId:${truncated.hashCode}:${text.length}';
  }
}

/// Voice settings for fine-tuning synthesis
class VoiceSettings {
  /// Stability: 0.0 (variable/expressive) to 1.0 (stable/consistent)
  /// For coaching, moderate stability (0.5-0.7) works well
  final double stability;

  /// Similarity boost: 0.0 to 1.0
  /// Higher values make voice more similar to original
  final double similarityBoost;

  /// Style: 0.0 to 1.0 (only for v2 models)
  /// Higher values increase expressiveness
  final double style;

  /// Use speaker boost for enhanced clarity
  final bool useSpeakerBoost;

  const VoiceSettings({
    this.stability = 0.6,
    this.similarityBoost = 0.8,
    this.style = 0.4,
    this.useSpeakerBoost = true,
  });

  /// Preset for warm coaching voice
  factory VoiceSettings.warmCoach() {
    return const VoiceSettings(
      stability: 0.55,
      similarityBoost: 0.75,
      style: 0.45,
      useSpeakerBoost: true,
    );
  }

  /// Preset for calm, soothing voice
  factory VoiceSettings.calm() {
    return const VoiceSettings(
      stability: 0.7,
      similarityBoost: 0.8,
      style: 0.3,
      useSpeakerBoost: true,
    );
  }

  /// Preset for energetic, motivational voice
  factory VoiceSettings.energetic() {
    return const VoiceSettings(
      stability: 0.4,
      similarityBoost: 0.85,
      style: 0.6,
      useSpeakerBoost: true,
    );
  }

  Map<String, dynamic> toJson() => {
        'stability': stability,
        'similarity_boost': similarityBoost,
        'style': style,
        'use_speaker_boost': useSpeakerBoost,
      };
}

/// Voice information from ElevenLabs
class VoiceInfo {
  final String voiceId;
  final String name;
  final String? description;
  final String? previewUrl;
  final Map<String, String> labels;

  VoiceInfo({
    required this.voiceId,
    required this.name,
    this.description,
    this.previewUrl,
    this.labels = const {},
  });

  factory VoiceInfo.fromJson(Map<String, dynamic> json) {
    return VoiceInfo(
      voiceId: json['voice_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      previewUrl: json['preview_url'] as String?,
      labels: (json['labels'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v.toString())) ??
          {},
    );
  }

  @override
  String toString() => 'VoiceInfo($name, $voiceId)';
}

/// Recommended voices for different coaching styles
class RecommendedVoices {
  /// Warm, professional female (American) - Best for general coaching
  static const String sarah = 'EXAVITQu4vr4xnSDxMaL';

  /// Calm, soothing female (American) - Good for meditation/mindfulness habits
  static const String rachel = '21m00Tcm4TlvDq8ikWAM';

  /// Deep, confident male (American) - Good for fitness/discipline habits
  static const String adam = 'pNInz6obpgDQGcFmaJgB';

  /// Warm, friendly male (British) - Good for intellectual/reading habits
  static const String antoni = 'ErXwobaYiN019PkySvjV';

  /// Young, energetic female (American) - Good for younger users
  static const String bella = 'EXAVITQu4vr4xnSDxMaL';
}
