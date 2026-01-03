import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/context_snapshot.dart';
import '../../domain/entities/weather_context.dart';
import '../../data/models/habit.dart';
import '../../data/sensors/digital_truth_sensor.dart';
import 'context_service.dart';
import 'baseline_tracker.dart';

/// JITAI Context Service (Aggregator)
///
/// Extends the base [ContextService] capabilities with JITAI-specific logic:
/// - Z-score calculation (using [BaselineTracker])
/// - User Vulnerability Override (Thermostat)
/// - Location Zone enrichment (Home/Work/Gym)
class JITAIContextService {
  final ContextService _baseService;
  final BaselineTracker _baselineTracker;
  final DigitalTruthSensor _digitalSensor;

  // Thermostat state
  double? _userVulnerabilityOverride;
  DateTime? _overrideExpiresAt;

  JITAIContextService({
     ContextService? baseService,
     BaselineTracker? baselineTracker,
     DigitalTruthSensor? digitalSensor,
  }) : _baseService = baseService ?? ContextService(),
       _baselineTracker = baselineTracker ?? BaselineTracker(),
       _digitalSensor = digitalSensor ?? DigitalTruthSensor();

  Future<void> initialize() async {
    // Load baselines from storage if needed
  }

  /// Get enriched JITAI snapshot
  Future<ContextSnapshot> getEnrichedSnapshot({
    required Habit habit,
    List<Habit>? allHabits,
    List<String> activePatterns = const [],
  }) async {
    // 1. Get raw snapshot
    final rawSnapshot = await _baseService.getSnapshot(
      habit: habit,
      allHabits: allHabits,
      activePatterns: activePatterns,
    );

    // 2. Enrich with Biometric Z-scores
    BiometricContext? enrichedBiometrics;
    if (rawSnapshot.biometrics != null) {
      final bio = rawSnapshot.biometrics!;

      // Update baselines
      if (bio.sleepMinutes != null) _baselineTracker.updateSleepBaseline(bio.sleepMinutes!);
      if (bio.hrvSdnn != null) _baselineTracker.updateHrvBaseline(bio.hrvSdnn!);

      // Calculate Z-scores
      enrichedBiometrics = BiometricContext(
        capturedAt: bio.capturedAt,
        sleepMinutes: bio.sleepMinutes,
        hrvSdnn: bio.hrvSdnn,
        sleepZScore: bio.sleepMinutes != null ? _baselineTracker.sleepZScore(bio.sleepMinutes!) : 0.0,
        hrvZScore: bio.hrvSdnn != null ? _baselineTracker.hrvZScore(bio.hrvSdnn!) : 0.0,
      );
    }

    // 3. Enrich with Digital Context (Phase 65: Guardian Mode + Emotion)
    final enrichedDigital = await _enrichDigitalContext();

    // 4. Apply Thermostat
    final currentOverride = _checkOverride();

    // 5. Return new snapshot
    return ContextSnapshot(
      snapshotId: rawSnapshot.snapshotId,
      capturedAt: rawSnapshot.capturedAt,
      time: rawSnapshot.time,
      weather: rawSnapshot.weather,
      calendar: rawSnapshot.calendar,
      history: rawSnapshot.history,
      location: rawSnapshot.location,
      digital: enrichedDigital,
      biometrics: enrichedBiometrics ?? rawSnapshot.biometrics,
      userVulnerabilityOverride: currentOverride,
      activePatterns: rawSnapshot.activePatterns,
    );
  }

  // === Thermostat Logic ===
  void setVulnerabilityOverride(double value, {Duration? expiresIn}) {
    _userVulnerabilityOverride = value.clamp(0.0, 1.0);
    _overrideExpiresAt = expiresIn != null
        ? DateTime.now().add(expiresIn)
        : DateTime.now().add(const Duration(hours: 4));
  }

  double? _checkOverride() {
    if (_userVulnerabilityOverride == null) return null;
    if (_overrideExpiresAt != null && DateTime.now().isAfter(_overrideExpiresAt!)) {
      _userVulnerabilityOverride = null;
      _overrideExpiresAt = null;
      return null;
    }
    return _userVulnerabilityOverride;
  }

  // === Digital Context Enrichment (Phase 65) ===

  /// Build enriched digital context with:
  /// - Basic distraction tracking (existing)
  /// - Distraction Z-score (new)
  /// - Emotion metadata from voice sessions (Phase 65)
  /// - Session tracking and dopamine loop detection (future enhancement)
  Future<DigitalContext?> _enrichDigitalContext() async {
    if (!_digitalSensor.isSupported) return null;

    try {
      // Fetch distraction data
      final distractionMinutes = await _digitalSensor.getDopamineBurnMinutes();
      final apexDistractor = await _digitalSensor.getApexDistractor();

      // Calculate Z-score
      _baselineTracker.updateDistractionBaseline(distractionMinutes);
      final distractionZScore = _baselineTracker.distractionZScore(distractionMinutes);

      // Load emotion from Hive (Phase 65)
      final emotion = await _loadLatestEmotion();

      return DigitalContext(
        distractionMinutes: distractionMinutes,
        apexDistractor: apexDistractor,
        distractionZScore: distractionZScore,
        capturedAt: DateTime.now(),
        // Emotion fields
        primaryEmotion: emotion?['primaryEmotion'] as String?,
        emotionalIntensity: emotion?['confidence'] as double?,
        emotionalTone: emotion?['tone'] as String?,
        emotionCapturedAt: emotion?['capturedAt'] != null
            ? DateTime.parse(emotion!['capturedAt'] as String)
            : null,
        // Session tracking (future enhancement - requires native bridge)
        // currentSessionMinutes: null,
        // isActivelyDoomScrolling: false,
        // sessionCount: null,
        // recentLoop: null,
      );
    } catch (e) {
      debugPrint('JITAIContextService: Digital context enrichment failed: $e');
      return null;
    }
  }

  /// Load latest emotion metadata from Hive
  /// Data is stored by VoiceSessionManager after OpenAI voice sessions
  /// Expires after 2 hours (checked by DigitalContext.isEmotionStale)
  Future<Map<String, dynamic>?> _loadLatestEmotion() async {
    try {
      final box = await Hive.openBox('emotion_metadata');
      final emotion = box.get('latest_emotion') as Map<String, dynamic>?;

      if (emotion == null) return null;

      // Check if emotion is stale (older than 2 hours)
      final capturedAt = emotion['capturedAt'] != null
          ? DateTime.parse(emotion['capturedAt'] as String)
          : null;

      if (capturedAt != null) {
        final age = DateTime.now().difference(capturedAt);
        if (age.inHours >= 2) {
          // Emotion is stale, remove it
          await box.delete('latest_emotion');
          return null;
        }
      }

      return emotion;
    } catch (e) {
      debugPrint('JITAIContextService: Failed to load emotion metadata: $e');
      return null;
    }
  }
}
