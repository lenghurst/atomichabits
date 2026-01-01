import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../../domain/entities/psychometric_profile.dart';
import '../../../config/ai_model_config.dart';
import '../../models/habit.dart';

/// UrgeSurfingService: Guided Audio for Urge Management
///
/// Generates personalized urge surfing sessions using Gemini TTS.
/// Based on MBRP (Mindfulness-Based Relapse Prevention) and ACT protocols.
///
/// Protocol Structure (2-5 minutes):
/// 1. ACKNOWLEDGE: Name the urge without judgment
/// 2. OBSERVE: Body scan, rate intensity
/// 3. BREATHE: HRV-synced breathing pattern
/// 4. REFRAME: Identity reminder, BigWhy connection
/// 5. BRIDGE: Micro-action suggestion
///
/// Phase 63: JITAI Foundation
class UrgeSurfingService {
  // Singleton
  static final UrgeSurfingService _instance = UrgeSurfingService._internal();
  factory UrgeSurfingService() => _instance;
  UrgeSurfingService._internal();

  final String _apiKey = AIModelConfig.geminiApiKey;

  // Track generated audio for cleanup
  final Set<String> _sessionAudioPaths = {};

  /// Generate a personalized urge surfing session
  Future<UrgeSurfingSession> generateSession({
    required Habit habit,
    required PsychometricProfile profile,
    required double urgencyLevel, // 0.0-1.0
    double? currentHRV,
  }) async {
    // Calculate session parameters
    final duration = _calculateDuration(urgencyLevel);
    final breathingPattern = _calculateBreathingPattern(currentHRV);

    // Build personalized script
    final script = _buildScript(
      habit: habit,
      profile: profile,
      duration: duration,
      breathingPattern: breathingPattern,
      urgencyLevel: urgencyLevel,
    );

    try {
      // Generate audio via Gemini TTS
      final audioPath = await _generateSpeech(
        script,
        speakingRate: 0.85, // Slower for meditation
      );

      return UrgeSurfingSession(
        audioPath: audioPath,
        script: script,
        duration: duration,
        breathingPattern: breathingPattern,
        habitId: habit.id,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('UrgeSurfingService: TTS generation failed: $e');
      // Return session without audio (script-only fallback)
      return UrgeSurfingSession(
        audioPath: null,
        script: script,
        duration: duration,
        breathingPattern: breathingPattern,
        habitId: habit.id,
        generatedAt: DateTime.now(),
        error: e.toString(),
      );
    }
  }

  /// Build the urge surfing script
  String _buildScript({
    required Habit habit,
    required PsychometricProfile profile,
    required Duration duration,
    required BreathingPattern breathingPattern,
    required double urgencyLevel,
  }) {
    final buffer = StringBuffer();

    // PHASE 1: ACKNOWLEDGE
    buffer.writeln(_acknowledgePhase(habit, profile));
    buffer.writeln();
    buffer.writeln('[Pause for 3 seconds]');
    buffer.writeln();

    // PHASE 2: OBSERVE
    buffer.writeln(_observePhase(urgencyLevel));
    buffer.writeln();
    buffer.writeln('[Pause for 4 seconds]');
    buffer.writeln();

    // PHASE 3: BREATHE
    buffer.writeln(_breathePhase(breathingPattern));
    buffer.writeln();

    // PHASE 4: REFRAME
    buffer.writeln(_reframePhase(habit, profile));
    buffer.writeln();
    buffer.writeln('[Pause for 3 seconds]');
    buffer.writeln();

    // PHASE 5: BRIDGE
    buffer.writeln(_bridgePhase(habit, profile));

    return buffer.toString();
  }

  String _acknowledgePhase(Habit habit, PsychometricProfile profile) {
    final habitName = habit.name;
    return '''
I see you're feeling a pull right now. That's okay.
This urge you're experiencing, it's real, and it's valid.
But here's what's also true: you're here, noticing it, not acting on it.
That's already a vote for who you're becoming.
Let's ride this wave together.''';
  }

  String _observePhase(double urgencyLevel) {
    final intensityWord = urgencyLevel > 0.7
        ? 'strong'
        : urgencyLevel > 0.4
            ? 'moderate'
            : 'present';

    return '''
Now, let's observe what's happening in your body.
Close your eyes if it feels comfortable.
Where do you feel this urge? Your chest? Your stomach? Your hands?
The intensity feels $intensityWord right now.
Just notice it. Don't fight it. Don't feed it.
It's already changing, even as we speak.''';
  }

  String _breathePhase(BreathingPattern pattern) {
    return '''
Now, let's anchor with your breath.
Breathe in slowly through your nose for ${pattern.inhale} seconds...
[Pause for ${pattern.inhale} seconds]
Hold gently for ${pattern.hold} seconds...
[Pause for ${pattern.hold} seconds]
And slowly release through your mouth for ${pattern.exhale} seconds...
[Pause for ${pattern.exhale} seconds]

Let's do that again.
Breathe in... ${pattern.inhale} seconds...
[Pause for ${pattern.inhale} seconds]
Hold... ${pattern.hold} seconds...
[Pause for ${pattern.hold} seconds]
And release... ${pattern.exhale} seconds...
[Pause for ${pattern.exhale} seconds]

One more time.
In...
[Pause for ${pattern.inhale} seconds]
Hold...
[Pause for ${pattern.hold} seconds]
And out...
[Pause for ${pattern.exhale} seconds]

Notice: the intensity is already shifting.''';
  }

  String _reframePhase(Habit habit, PsychometricProfile profile) {
    final antiIdentity = profile.antiIdentityLabel ?? 'the old pattern';
    final bigWhy = profile.bigWhy.isNotEmpty
        ? profile.bigWhy
        : 'your future self';
    final identity = habit.identity ?? 'someone who chooses differently';
    final substitution = habit.substitutionPlan ?? 'a healthier alternative';

    return '''
This feeling will peak and pass. You've seen it happen before.
You're not becoming $antiIdentity. That's not who you are anymore.
Every time you let this wave pass, you're proving something to yourself.
You're proving you're $identity.
Remember why you started this: $bigWhy.
If it helps, consider: $substitution.
But honestly? Just staying present for the next 5 minutes is a win.''';
  }

  String _bridgePhase(Habit habit, PsychometricProfile profile) {
    final tinyVersion = habit.tinyVersion ?? 'a small positive action';

    return '''
You've done it. The peak has passed.
The urge is still there, maybe, but you're in control.
Here's your next step: $tinyVersion.
Or simply continue with your day, knowing you've just cast another vote.
Every urge you surf makes the next one easier.
You've got this.''';
  }

  Duration _calculateDuration(double urgencyLevel) {
    // Higher urgency = longer session
    if (urgencyLevel > 0.8) {
      return const Duration(minutes: 5);
    } else if (urgencyLevel > 0.5) {
      return const Duration(minutes: 4);
    } else {
      return const Duration(minutes: 3);
    }
  }

  BreathingPattern _calculateBreathingPattern(double? hrv) {
    // Lower HRV = more stressed = gentler pattern
    if (hrv == null || hrv < 30) {
      return BreathingPattern(inhale: 4, hold: 4, exhale: 6); // Box-ish, gentle
    } else if (hrv < 50) {
      return BreathingPattern(inhale: 4, hold: 7, exhale: 8); // Standard 4-7-8
    } else {
      return BreathingPattern(inhale: 5, hold: 7, exhale: 9); // Extended for calm
    }
  }

  /// Generate speech via Gemini TTS REST API
  Future<String?> _generateSpeech(String text, {double speakingRate = 1.0}) async {
    final url = "https://generativelanguage.googleapis.com/v1beta/models/${AIModelConfig.ttsModel}:generateContent";

    try {
      final response = await http.post(
        Uri.parse("$url?key=$_apiKey"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": text}
              ]
            }
          ],
          "generationConfig": {
            "responseModalities": ["AUDIO"],
            "speechConfig": {
              "voiceConfig": {
                "prebuiltVoiceConfig": {
                  "voiceName": "Aoede" // Calm, measured voice for meditation
                }
              }
            }
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['candidates'] != null &&
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          final part = data['candidates'][0]['content']['parts'][0];

          if (part.containsKey('inlineData') &&
              part['inlineData'].containsKey('data')) {
            final String base64Audio = part['inlineData']['data'];
            if (base64Audio.isNotEmpty) {
              final audioBytes = base64Decode(base64Audio);
              final wavBytes = _pcmBytesToWav(audioBytes);

              final dir = await getApplicationDocumentsDirectory();
              final filePath =
                  "${dir.path}/urge_surf_${DateTime.now().millisecondsSinceEpoch}.wav";
              final file = File(filePath);
              await file.writeAsBytes(wavBytes);

              _sessionAudioPaths.add(filePath);

              if (kDebugMode) {
                debugPrint(
                    'UrgeSurfingService: Generated audio: $filePath (${wavBytes.length} bytes)');
              }

              return filePath;
            }
          }
        }
        throw Exception('Invalid TTS response structure');
      } else {
        throw Exception('TTS API Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('UrgeSurfingService: TTS failed: $e');
      rethrow;
    }
  }

  /// Convert raw PCM to WAV format
  Uint8List _pcmBytesToWav(List<int> pcmBytes) {
    if (pcmBytes.isEmpty) {
      throw ArgumentError('Cannot create WAV from empty PCM data');
    }

    const sampleRate = 24000;
    const channels = 1;
    const bitsPerSample = 16;
    const blockAlign = channels * bitsPerSample ~/ 8;
    const byteRate = sampleRate * blockAlign;

    final dataSize = pcmBytes.length;
    final totalSize = 36 + dataSize;

    final header = ByteData(44);
    header.setUint32(0, 0x46464952, Endian.little); // "RIFF"
    header.setUint32(4, totalSize, Endian.little);
    header.setUint32(8, 0x45564157, Endian.little); // "WAVE"
    header.setUint32(12, 0x20746D66, Endian.little); // "fmt "
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little);
    header.setUint16(22, channels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, bitsPerSample, Endian.little);
    header.setUint32(36, 0x61746164, Endian.little); // "data"
    header.setUint32(40, dataSize, Endian.little);

    final wavBytes = Uint8List(44 + pcmBytes.length);
    wavBytes.setRange(0, 44, header.buffer.asUint8List());
    wavBytes.setRange(44, wavBytes.length, pcmBytes);
    return wavBytes;
  }

  /// Cleanup session audio files
  Future<void> cleanupSessionAudio() async {
    for (final path in List<String>.from(_sessionAudioPaths)) {
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
          if (kDebugMode) debugPrint('UrgeSurfingService: Deleted $path');
        }
        _sessionAudioPaths.remove(path);
      } catch (e) {
        debugPrint('UrgeSurfingService: Cleanup failed for $path: $e');
      }
    }
  }

  /// Cleanup specific audio file
  Future<void> cleanupAudio(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        _sessionAudioPaths.remove(path);
      }
    } catch (e) {
      debugPrint('UrgeSurfingService: Cleanup failed: $e');
    }
  }
}

/// A generated urge surfing session
class UrgeSurfingSession {
  final String? audioPath;
  final String script;
  final Duration duration;
  final BreathingPattern breathingPattern;
  final String habitId;
  final DateTime generatedAt;
  final String? error;

  UrgeSurfingSession({
    this.audioPath,
    required this.script,
    required this.duration,
    required this.breathingPattern,
    required this.habitId,
    required this.generatedAt,
    this.error,
  });

  bool get hasAudio => audioPath != null;
  bool get hasError => error != null;

  Map<String, dynamic> toJson() => {
        'audioPath': audioPath,
        'script': script,
        'durationSeconds': duration.inSeconds,
        'breathingPattern': breathingPattern.toJson(),
        'habitId': habitId,
        'generatedAt': generatedAt.toIso8601String(),
        'error': error,
      };
}

/// Breathing pattern for the session
class BreathingPattern {
  final int inhale; // seconds
  final int hold; // seconds
  final int exhale; // seconds

  BreathingPattern({
    required this.inhale,
    required this.hold,
    required this.exhale,
  });

  Duration get cycleDuration =>
      Duration(seconds: inhale + hold + exhale);

  String get displayName {
    if (inhale == 4 && hold == 4 && exhale == 6) return 'Gentle Box';
    if (inhale == 4 && hold == 7 && exhale == 8) return '4-7-8 Relaxing';
    return 'Extended Calm';
  }

  Map<String, int> toJson() => {
        'inhale': inhale,
        'hold': hold,
        'exhale': exhale,
      };

  factory BreathingPattern.fromJson(Map<String, dynamic> json) {
    return BreathingPattern(
      inhale: json['inhale'] as int,
      hold: json['hold'] as int,
      exhale: json['exhale'] as int,
    );
  }
}

/// Outcome tracking for urge surfing sessions
class UrgeSurfingOutcome {
  final String sessionId;
  final String habitId;
  final DateTime startTime;
  final DateTime? endTime;
  final double vulnerabilityAtStart;
  final double? hrvAtStart;
  final double? hrvAtEnd;

  // Session engagement
  final double percentListened; // 0.0-1.0
  final String? exitPhase; // Which phase they stopped at

  // Outcome
  final bool habitLoggedAsResisted; // For break habits
  final bool relapsedWithin2Hours;
  final int? userFeedbackRating; // 1-5 if provided

  // Long-term (for delayed reward)
  final bool streakMaintained24h;
  final double? identityScoreDelta;

  UrgeSurfingOutcome({
    required this.sessionId,
    required this.habitId,
    required this.startTime,
    this.endTime,
    required this.vulnerabilityAtStart,
    this.hrvAtStart,
    this.hrvAtEnd,
    this.percentListened = 0.0,
    this.exitPhase,
    this.habitLoggedAsResisted = false,
    this.relapsedWithin2Hours = false,
    this.userFeedbackRating,
    this.streakMaintained24h = false,
    this.identityScoreDelta,
  });

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'habitId': habitId,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'vulnerabilityAtStart': vulnerabilityAtStart,
        'hrvAtStart': hrvAtStart,
        'hrvAtEnd': hrvAtEnd,
        'percentListened': percentListened,
        'exitPhase': exitPhase,
        'habitLoggedAsResisted': habitLoggedAsResisted,
        'relapsedWithin2Hours': relapsedWithin2Hours,
        'userFeedbackRating': userFeedbackRating,
        'streakMaintained24h': streakMaintained24h,
        'identityScoreDelta': identityScoreDelta,
      };

  /// Calculate composite reward for ML training
  double get compositeReward {
    double reward = 0.0;

    // Completion reward (40%)
    reward += percentListened * 0.4;

    // Urge resisted (40%)
    if (habitLoggedAsResisted) reward += 0.4;

    // No relapse (10%)
    if (!relapsedWithin2Hours) reward += 0.1;

    // User satisfaction (10%)
    if (userFeedbackRating != null) {
      reward += (userFeedbackRating! / 5.0) * 0.1;
    }

    return reward.clamp(0.0, 1.0);
  }
}
