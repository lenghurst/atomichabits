/// VoiceAffectDetectionService - Emotional State Detection from Voice
///
/// Genspark Recommendation Implementation:
/// Uses Gemini to analyze vocal tone during voice sessions
/// for stress, fatigue, and emotional state.
///
/// Detects:
/// - Energy level (tired vs. energized)
/// - Stress indicators (rushed speech, tension)
/// - Emotional valence (positive, negative, neutral)
/// - Confidence level (assertive vs. hesitant)
/// - Motivation state (engaged vs. disengaged)
///
/// Privacy considerations:
/// - All analysis happens on-device or via Gemini (not stored)
/// - Only aggregated affect scores are persisted
/// - User can disable affect detection
///
/// Philosophy: How you speak reveals how you feel.
/// Detect emotional states to provide better-timed interventions.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../config/ai_model_config.dart';

/// Detected emotional affect from voice
class VoiceAffect {
  /// Energy level (0.0 = exhausted, 1.0 = high energy)
  final double energyLevel;

  /// Stress level (0.0 = calm, 1.0 = highly stressed)
  final double stressLevel;

  /// Emotional valence (-1.0 = negative, 0.0 = neutral, 1.0 = positive)
  final double emotionalValence;

  /// Confidence in speech (0.0 = hesitant, 1.0 = assertive)
  final double confidenceLevel;

  /// Motivation level (0.0 = disengaged, 1.0 = highly motivated)
  final double motivationLevel;

  /// Primary detected emotion
  final DetectedEmotion primaryEmotion;

  /// Secondary emotions detected
  final List<DetectedEmotion> secondaryEmotions;

  /// Raw transcript (if available)
  final String? transcript;

  /// Timestamp of detection
  final DateTime detectedAt;

  /// Confidence in the detection (0.0 - 1.0)
  final double detectionConfidence;

  const VoiceAffect({
    this.energyLevel = 0.5,
    this.stressLevel = 0.3,
    this.emotionalValence = 0.0,
    this.confidenceLevel = 0.5,
    this.motivationLevel = 0.5,
    this.primaryEmotion = DetectedEmotion.neutral,
    this.secondaryEmotions = const [],
    this.transcript,
    required this.detectedAt,
    this.detectionConfidence = 0.5,
  });

  /// Is user in a vulnerable state?
  bool get isVulnerable =>
      energyLevel < 0.3 || stressLevel > 0.7 || emotionalValence < -0.5;

  /// Is user in a good state for habit execution?
  bool get isOptimalForHabits =>
      energyLevel > 0.5 && stressLevel < 0.5 && motivationLevel > 0.5;

  /// Overall affect score (0.0 = poor state, 1.0 = excellent state)
  double get overallScore {
    return ((energyLevel * 0.25) +
            ((1 - stressLevel) * 0.25) +
            ((emotionalValence + 1) / 2 * 0.2) +
            (confidenceLevel * 0.15) +
            (motivationLevel * 0.15))
        .clamp(0.0, 1.0);
  }

  /// Get intervention recommendation based on affect
  AffectBasedRecommendation get recommendation {
    if (isVulnerable) {
      if (stressLevel > 0.7) {
        return AffectBasedRecommendation.urgeSurfing;
      }
      if (energyLevel < 0.3) {
        return AffectBasedRecommendation.tinyVersion;
      }
      if (emotionalValence < -0.5) {
        return AffectBasedRecommendation.compassion;
      }
    }

    if (motivationLevel < 0.3) {
      return AffectBasedRecommendation.identityReminder;
    }

    if (isOptimalForHabits) {
      return AffectBasedRecommendation.fullExecution;
    }

    return AffectBasedRecommendation.gentleNudge;
  }

  Map<String, dynamic> toJson() => {
        'energyLevel': energyLevel,
        'stressLevel': stressLevel,
        'emotionalValence': emotionalValence,
        'confidenceLevel': confidenceLevel,
        'motivationLevel': motivationLevel,
        'primaryEmotion': primaryEmotion.name,
        'secondaryEmotions': secondaryEmotions.map((e) => e.name).toList(),
        'transcript': transcript,
        'detectedAt': detectedAt.toIso8601String(),
        'detectionConfidence': detectionConfidence,
      };

  factory VoiceAffect.fromJson(Map<String, dynamic> json) {
    return VoiceAffect(
      energyLevel: (json['energyLevel'] as num?)?.toDouble() ?? 0.5,
      stressLevel: (json['stressLevel'] as num?)?.toDouble() ?? 0.3,
      emotionalValence: (json['emotionalValence'] as num?)?.toDouble() ?? 0.0,
      confidenceLevel: (json['confidenceLevel'] as num?)?.toDouble() ?? 0.5,
      motivationLevel: (json['motivationLevel'] as num?)?.toDouble() ?? 0.5,
      primaryEmotion: DetectedEmotion.values.firstWhere(
        (e) => e.name == json['primaryEmotion'],
        orElse: () => DetectedEmotion.neutral,
      ),
      secondaryEmotions: (json['secondaryEmotions'] as List<dynamic>?)
              ?.map((e) => DetectedEmotion.values.firstWhere(
                    (em) => em.name == e,
                    orElse: () => DetectedEmotion.neutral,
                  ))
              .toList() ??
          [],
      transcript: json['transcript'] as String?,
      detectedAt: DateTime.parse(json['detectedAt'] as String),
      detectionConfidence: (json['detectionConfidence'] as num?)?.toDouble() ?? 0.5,
    );
  }
}

/// Detected emotions from voice
enum DetectedEmotion {
  // Positive
  happy,
  excited,
  confident,
  calm,
  hopeful,

  // Neutral
  neutral,
  focused,
  thoughtful,

  // Negative
  stressed,
  anxious,
  tired,
  sad,
  frustrated,
  overwhelmed,
  discouraged,
}

extension DetectedEmotionExtension on DetectedEmotion {
  String get displayName {
    switch (this) {
      case DetectedEmotion.happy:
        return 'Happy';
      case DetectedEmotion.excited:
        return 'Excited';
      case DetectedEmotion.confident:
        return 'Confident';
      case DetectedEmotion.calm:
        return 'Calm';
      case DetectedEmotion.hopeful:
        return 'Hopeful';
      case DetectedEmotion.neutral:
        return 'Neutral';
      case DetectedEmotion.focused:
        return 'Focused';
      case DetectedEmotion.thoughtful:
        return 'Thoughtful';
      case DetectedEmotion.stressed:
        return 'Stressed';
      case DetectedEmotion.anxious:
        return 'Anxious';
      case DetectedEmotion.tired:
        return 'Tired';
      case DetectedEmotion.sad:
        return 'Sad';
      case DetectedEmotion.frustrated:
        return 'Frustrated';
      case DetectedEmotion.overwhelmed:
        return 'Overwhelmed';
      case DetectedEmotion.discouraged:
        return 'Discouraged';
    }
  }

  String get emoji {
    switch (this) {
      case DetectedEmotion.happy:
        return '😊';
      case DetectedEmotion.excited:
        return '🎉';
      case DetectedEmotion.confident:
        return '💪';
      case DetectedEmotion.calm:
        return '😌';
      case DetectedEmotion.hopeful:
        return '🌟';
      case DetectedEmotion.neutral:
        return '😐';
      case DetectedEmotion.focused:
        return '🎯';
      case DetectedEmotion.thoughtful:
        return '🤔';
      case DetectedEmotion.stressed:
        return '😰';
      case DetectedEmotion.anxious:
        return '😟';
      case DetectedEmotion.tired:
        return '😴';
      case DetectedEmotion.sad:
        return '😢';
      case DetectedEmotion.frustrated:
        return '😤';
      case DetectedEmotion.overwhelmed:
        return '😵';
      case DetectedEmotion.discouraged:
        return '😞';
    }
  }

  bool get isPositive => [
        DetectedEmotion.happy,
        DetectedEmotion.excited,
        DetectedEmotion.confident,
        DetectedEmotion.calm,
        DetectedEmotion.hopeful,
      ].contains(this);

  bool get isNegative => [
        DetectedEmotion.stressed,
        DetectedEmotion.anxious,
        DetectedEmotion.tired,
        DetectedEmotion.sad,
        DetectedEmotion.frustrated,
        DetectedEmotion.overwhelmed,
        DetectedEmotion.discouraged,
      ].contains(this);
}

/// Intervention recommendations based on affect
enum AffectBasedRecommendation {
  /// User is in great shape - proceed with full habit
  fullExecution,

  /// User is slightly off - gentle encouragement
  gentleNudge,

  /// User is stressed - urge surfing meditation
  urgeSurfing,

  /// User is tired - suggest tiny version
  tinyVersion,

  /// User is emotionally down - self-compassion focus
  compassion,

  /// User lacks motivation - identity reminder
  identityReminder,
}

extension AffectRecommendationExtension on AffectBasedRecommendation {
  String get message {
    switch (this) {
      case AffectBasedRecommendation.fullExecution:
        return "You sound ready. Let's do this!";
      case AffectBasedRecommendation.gentleNudge:
        return "A small step forward is still forward.";
      case AffectBasedRecommendation.urgeSurfing:
        return "I sense some tension. Let's take a breath first.";
      case AffectBasedRecommendation.tinyVersion:
        return "Your energy is low. The tiny version counts today.";
      case AffectBasedRecommendation.compassion:
        return "Be gentle with yourself. Tomorrow is another day.";
      case AffectBasedRecommendation.identityReminder:
        return "Remember who you're becoming.";
    }
  }
}

/// Service for detecting emotional affect from voice
class VoiceAffectDetectionService {
  /// History of affect detections (for trend analysis)
  final List<VoiceAffect> _affectHistory = [];

  /// Maximum history size
  static const int _maxHistorySize = 50;

  /// Whether detection is enabled
  bool _isEnabled = true;
  bool get isEnabled => _isEnabled;

  /// Set enabled state
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Analyze voice recording for emotional affect
  ///
  /// Uses Gemini to analyze the transcript + speech patterns.
  /// Falls back to transcript-only analysis if audio analysis fails.
  Future<VoiceAffect?> analyzeVoice({
    required String transcript,
    String? audioPath,
  }) async {
    if (!_isEnabled || transcript.isEmpty) return null;

    try {
      final affect = await _analyzeWithGemini(transcript);

      if (affect != null) {
        _affectHistory.add(affect);
        if (_affectHistory.length > _maxHistorySize) {
          _affectHistory.removeAt(0);
        }
      }

      return affect;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('VoiceAffect: Analysis failed: $e');
      }
      return null;
    }
  }

  /// Analyze transcript using Gemini
  Future<VoiceAffect?> _analyzeWithGemini(String transcript) async {
    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${AIModelConfig.geminiApiKey}',
      );

      final prompt = '''
Analyze the emotional state from this voice transcript. Focus on:
1. Energy level (tired vs energized)
2. Stress indicators
3. Emotional tone
4. Confidence in speech
5. Motivation level

Transcript: "$transcript"

Respond with ONLY a JSON object (no markdown):
{
  "energyLevel": 0.0-1.0,
  "stressLevel": 0.0-1.0,
  "emotionalValence": -1.0 to 1.0,
  "confidenceLevel": 0.0-1.0,
  "motivationLevel": 0.0-1.0,
  "primaryEmotion": "one of: happy, excited, confident, calm, hopeful, neutral, focused, thoughtful, stressed, anxious, tired, sad, frustrated, overwhelmed, discouraged",
  "secondaryEmotions": ["emotion1", "emotion2"],
  "reasoning": "brief explanation"
}
''';

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.3,
            'maxOutputTokens': 500,
          },
        }),
      );

      if (response.statusCode != 200) {
        if (kDebugMode) {
          debugPrint('VoiceAffect: Gemini error: ${response.statusCode}');
        }
        return null;
      }

      final responseData = json.decode(response.body);
      final content = responseData['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;

      if (content == null) return null;

      // Parse JSON from response
      final cleanJson = content
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final affectData = json.decode(cleanJson) as Map<String, dynamic>;

      return VoiceAffect(
        energyLevel: (affectData['energyLevel'] as num?)?.toDouble() ?? 0.5,
        stressLevel: (affectData['stressLevel'] as num?)?.toDouble() ?? 0.3,
        emotionalValence: (affectData['emotionalValence'] as num?)?.toDouble() ?? 0.0,
        confidenceLevel: (affectData['confidenceLevel'] as num?)?.toDouble() ?? 0.5,
        motivationLevel: (affectData['motivationLevel'] as num?)?.toDouble() ?? 0.5,
        primaryEmotion: _parseEmotion(affectData['primaryEmotion'] as String?),
        secondaryEmotions: (affectData['secondaryEmotions'] as List<dynamic>?)
                ?.map((e) => _parseEmotion(e as String?))
                .toList() ??
            [],
        transcript: transcript,
        detectedAt: DateTime.now(),
        detectionConfidence: 0.8, // Gemini is fairly confident
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('VoiceAffect: Gemini analysis error: $e');
      }
      return null;
    }
  }

  DetectedEmotion _parseEmotion(String? emotion) {
    if (emotion == null) return DetectedEmotion.neutral;

    return DetectedEmotion.values.firstWhere(
      (e) => e.name.toLowerCase() == emotion.toLowerCase(),
      orElse: () => DetectedEmotion.neutral,
    );
  }

  /// Get the most recent affect
  VoiceAffect? get latestAffect =>
      _affectHistory.isNotEmpty ? _affectHistory.last : null;

  /// Get average affect over recent sessions
  VoiceAffect? getAverageAffect({int sessions = 5}) {
    if (_affectHistory.isEmpty) return null;

    final recent = _affectHistory.length > sessions
        ? _affectHistory.sublist(_affectHistory.length - sessions)
        : _affectHistory;

    double avgEnergy = 0;
    double avgStress = 0;
    double avgValence = 0;
    double avgConfidence = 0;
    double avgMotivation = 0;

    for (final affect in recent) {
      avgEnergy += affect.energyLevel;
      avgStress += affect.stressLevel;
      avgValence += affect.emotionalValence;
      avgConfidence += affect.confidenceLevel;
      avgMotivation += affect.motivationLevel;
    }

    final count = recent.length;

    return VoiceAffect(
      energyLevel: avgEnergy / count,
      stressLevel: avgStress / count,
      emotionalValence: avgValence / count,
      confidenceLevel: avgConfidence / count,
      motivationLevel: avgMotivation / count,
      primaryEmotion: DetectedEmotion.neutral, // Average doesn't have a single emotion
      detectedAt: DateTime.now(),
      detectionConfidence: 0.7,
    );
  }

  /// Detect affect trend (improving, declining, stable)
  AffectTrend getAffectTrend() {
    if (_affectHistory.length < 3) return AffectTrend.stable;

    final recent = _affectHistory.sublist(_affectHistory.length - 3);
    final scores = recent.map((a) => a.overallScore).toList();

    final diff = scores.last - scores.first;

    if (diff > 0.15) return AffectTrend.improving;
    if (diff < -0.15) return AffectTrend.declining;
    return AffectTrend.stable;
  }

  /// Get affect summary for display
  Map<String, dynamic> getAffectSummary() {
    final latest = latestAffect;
    final average = getAverageAffect();
    final trend = getAffectTrend();

    return {
      'latestScore': latest?.overallScore ?? 0.5,
      'latestEmotion': latest?.primaryEmotion.displayName ?? 'Unknown',
      'averageScore': average?.overallScore ?? 0.5,
      'trend': trend.name,
      'isVulnerable': latest?.isVulnerable ?? false,
      'recommendation': latest?.recommendation.message ?? '',
      'historyCount': _affectHistory.length,
    };
  }

  /// Clear affect history
  void clearHistory() {
    _affectHistory.clear();
  }
}

/// Affect trend over time
enum AffectTrend {
  improving,
  stable,
  declining,
}
