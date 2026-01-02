import 'package:flutter/foundation.dart';
import '../../domain/entities/context_snapshot.dart';
import '../../domain/entities/weather_context.dart';
import '../../data/models/habit.dart';
import '../../data/services/weather_service.dart';
import '../../data/services/context/calendar_service.dart';
import '../../data/services/context/biometrics_service.dart';
import '../../data/services/context/context_snapshot_builder.dart'; // For HistoricalContext helper

/// Base Context Service
///
/// Responsible for fetching raw context data from various providers.
/// Does NOT apply JITAI-specific logic (Z-scores, Thermostat) - see JITAIContextService.
class ContextService {
  final WeatherService _weatherService;
  final CalendarService _calendarService;
  final BiometricsService _biometricsService;

  ContextService({
    WeatherService? weatherService,
    CalendarService? calendarService,
    BiometricsService? biometricsService,
  })  : _weatherService = weatherService ?? WeatherService(),
        _calendarService = calendarService ?? CalendarService(),
        _biometricsService = biometricsService ?? BiometricsService();

  /// Build a standard snapshot (without JITAI enhancements)
  Future<ContextSnapshot> getSnapshot({
    required Habit habit,
    List<Habit>? allHabits,
    List<String> activePatterns = const [],
  }) async {
    final now = DateTime.now();

    // Fetch sensors in parallel
    final futures = await Future.wait([
      _weatherService.getWeatherContext(),
      _calendarService.getCalendarContext(),
      _biometricsService.getBiometricContext(),
    ]);

    final weatherContext = futures[0] as WeatherContext?;
    final calendarContext = futures[1] as CalendarContext?;
    final biometricContext = futures[2] as BiometricContext?;

    // Use builder logic for historical data (temporary reuse)
    // Ideally this logic moves to a HistoricalContextService
    final history = _buildHistoricalContext(habit, allHabits);

    return ContextSnapshot(
      snapshotId: '${now.millisecondsSinceEpoch}',
      capturedAt: now,
      time: TimeContext.fromDateTime(now),
      weather: weatherContext,
      calendar: calendarContext,
      biometrics: biometricContext,
      history: history,
      activePatterns: activePatterns,
      // No JITAI overrides here
    );
  }

  // TODO: Refactor this to a proper service
  HistoricalContext _buildHistoricalContext(Habit habit, List<Habit>? allHabits) {
    // Basic implementation for base service
    // In real migration, we might duplicate logic or inject a helper
    return HistoricalContext(
      currentStreak: habit.currentStreak,
      daysSinceMiss: 0, // Placeholder
      totalIdentityVotes: habit.identityVotes,
      identityFusionScore: 0.5,
      resilienceScore: 0.5,
      habitStrength: 0.5,
    );
  }
}
