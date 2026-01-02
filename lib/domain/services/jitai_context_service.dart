import 'package:flutter/foundation.dart';
import '../../domain/entities/context_snapshot.dart';
import '../../domain/entities/weather_context.dart';
import '../../data/models/habit.dart';
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

  // Thermostat state
  double? _userVulnerabilityOverride;
  DateTime? _overrideExpiresAt;

  JITAIContextService({
     ContextService? baseService,
     BaselineTracker? baselineTracker,
  }) : _baseService = baseService ?? ContextService(),
       _baselineTracker = baselineTracker ?? BaselineTracker();

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

    // 3. Apply Thermostat
    final currentOverride = _checkOverride();

    // 4. Return new snapshot
    return ContextSnapshot(
      snapshotId: rawSnapshot.snapshotId,
      capturedAt: rawSnapshot.capturedAt,
      time: rawSnapshot.time,
      weather: rawSnapshot.weather,
      calendar: rawSnapshot.calendar,
      history: rawSnapshot.history,
      location: rawSnapshot.location, // Logic for zones could be added here
      digital: rawSnapshot.digital, // Logic for distraction Z-scores here
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
}
