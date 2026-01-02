/// ContextSnapshotBuilder - Unified Sensor Aggregation
///
/// Aggregates all contextual data sources into a single ContextSnapshot.
/// Handles partial failures gracefully (some sensors may be unavailable).
///
/// Data sources:
/// - Time (always available)
/// - Weather (OpenWeatherMap)
/// - Calendar (Google Calendar)
/// - Biometrics (Health Connect / HealthKit)
/// - Location (Geolocator)
/// - Historical (from habit data)

import 'package:geolocator/geolocator.dart';

import '../../../domain/entities/context_snapshot.dart';
import '../../../data/models/habit.dart';
import '../weather_service.dart';
import '../../../domain/entities/weather_context.dart';
import 'calendar_service.dart';
import 'biometrics_service.dart';

class ContextSnapshotBuilder {
  final WeatherService _weatherService;
  final CalendarService _calendarService;
  final BiometricsService _biometricsService;

  /// Last known location for weather API
  Position? _lastPosition;

  ContextSnapshotBuilder({
    WeatherService? weatherService,
    CalendarService? calendarService,
    BiometricsService? biometricsService,
  })  : _weatherService = weatherService ?? WeatherService(),
        _calendarService = calendarService ?? CalendarService(),
        _biometricsService = biometricsService ?? BiometricsService();

  /// Build a complete context snapshot
  ///
  /// Fetches all available sensor data in parallel.
  /// Returns snapshot even if some sensors fail (graceful degradation).
  Future<ContextSnapshot> build({
    required Habit habit,
    List<Habit>? allHabits,
    double? userVulnerabilityOverride,
    List<String> activePatterns = const [],
  }) async {
    final now = DateTime.now();

    // Fetch all sensor data in parallel
    final futures = await Future.wait([
      _getWeatherContext(),
      _calendarService.getCalendarContext(),
      _biometricsService.getBiometricContext(),
      _getLocationContext(),
    ]);

    final weatherContext = futures[0] as WeatherContext?;
    final calendarContext = futures[1] as CalendarContext?;
    final biometricContext = futures[2] as BiometricContext?;
    final locationContext = futures[3] as LocationContext?;

    // Build historical context from habit data
    final historicalContext = _buildHistoricalContext(habit, allHabits);

    // Build snapshot
    return ContextSnapshot(
      snapshotId: '${now.millisecondsSinceEpoch}',
      capturedAt: now,
      time: TimeContext.fromDateTime(now),
      weather: weatherContext,
      calendar: calendarContext,
      biometrics: biometricContext,
      location: locationContext,
      history: historicalContext,
      userVulnerabilityOverride: userVulnerabilityOverride,
      activePatterns: activePatterns,
    );
  }

  /// Build a lightweight snapshot (time + historical only)
  ///
  /// Use when full sensor data isn't needed or battery is low.
  ContextSnapshot buildLightweight({
    required Habit habit,
    List<Habit>? allHabits,
    double? userVulnerabilityOverride,
  }) {
    final now = DateTime.now();
    final historicalContext = _buildHistoricalContext(habit, allHabits);

    return ContextSnapshot(
      snapshotId: '${now.millisecondsSinceEpoch}',
      capturedAt: now,
      time: TimeContext.fromDateTime(now),
      history: historicalContext,
      userVulnerabilityOverride: userVulnerabilityOverride,
    );
  }

  /// Get weather context with location
  Future<WeatherContext?> _getWeatherContext() async {
    try {
      // Get current location
      final position = await _getCurrentPosition();
      if (position == null) return null;

      return await _weatherService.getWeatherContext(
        lat: position.latitude,
        lon: position.longitude,
      );
    } catch (_) {
      return null;
    }
  }

  /// Get current position
  Future<Position?> _getCurrentPosition() async {
    try {
      // Check permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return _lastPosition; // Use cached
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return _lastPosition; // Use cached
      }

      // Get position with timeout
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );

      _lastPosition = position;
      return position;
    } catch (_) {
      return _lastPosition;
    }
  }

  /// Get location context
  Future<LocationContext?> _getLocationContext() async {
    try {
      final position = await _getCurrentPosition();
      if (position == null) return null;

      // Determine zone (would use geofences in production)
      final zone = await _determineLocationZone(position);

      return LocationContext(
        latitude: position.latitude,
        longitude: position.longitude,
        zone: zone,
        capturedAt: DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Determine location zone from position
  ///
  /// In production, this would use user-defined geofences.
  Future<LocationZone> _determineLocationZone(Position position) async {
    // TODO: Implement geofence checking
    // For now, return unknown
    return LocationZone.unknown;
  }

  /// Build historical context from habit data
  HistoricalContext _buildHistoricalContext(Habit habit, List<Habit>? allHabits) {
    final now = DateTime.now();

    // Calculate days since miss
    int daysSinceMiss = 0;
    if (habit.lastCompletedDate != null) {
      final lastCompletion = habit.lastCompletedDate!;
      final today = DateTime(now.year, now.month, now.day);
      final lastDate = DateTime(
        lastCompletion.year,
        lastCompletion.month,
        lastCompletion.day,
      );

      if (lastDate == today) {
        // Completed today - count from previous miss
        daysSinceMiss = habit.currentStreak;
      } else {
        daysSinceMiss = 0; // Currently on a miss
      }
    }

    // Calculate identity fusion score (0.0 - 1.0)
    // Higher = more identified with the habit
    final identityFusion = _calculateIdentityFusion(habit);

    // Calculate resilience score (0.0 - 1.0)
    // Higher = recovers well from misses
    final resilience = _calculateResilience(habit);

    // Calculate habit strength (0.0 - 1.0)
    // Higher = more automatic
    final habitStrength = _calculateHabitStrength(habit);

    // Intervention fatigue (would come from JITAI state)
    // TODO: Wire this to actual intervention tracking
    const interventionCount24h = 0;
    const hoursSinceLastIntervention = 24.0;

    return HistoricalContext(
      currentStreak: habit.currentStreak,
      daysSinceMiss: daysSinceMiss,
      totalIdentityVotes: habit.identityVotes,
      identityFusionScore: identityFusion,
      resilienceScore: resilience,
      habitStrength: habitStrength,
      interventionCount24h: interventionCount24h,
      hoursSinceLastIntervention: hoursSinceLastIntervention,
    );
  }

  /// Calculate identity fusion score
  double _calculateIdentityFusion(Habit habit) {
    // Based on:
    // - Total identity votes (more = stronger)
    // - Completion rate
    // - Longest streak

    final votes = habit.identityVotes;
    final longestStreak = habit.longestStreak;
    final showUpRate = habit.showUpRate;

    // Scale votes (50 votes = strong, 100 = very strong)
    final voteScore = (votes / 100.0).clamp(0.0, 0.4);

    // Scale streak (21 days = habit forming, 66 = automatic)
    final streakScore = (longestStreak / 66.0).clamp(0.0, 0.3);

    // Show up rate contribution
    final rateScore = showUpRate * 0.3;

    return (voteScore + streakScore + rateScore).clamp(0.0, 1.0);
  }

  /// Calculate resilience score
  double _calculateResilience(Habit habit) {
    // Based on:
    // - Single miss recoveries (Never Miss Twice)
    // - Recovery events
    // - Current streak after recovery

    final recoveries = habit.singleMissRecoveries;
    final totalMisses = habit.missHistory.length;

    if (totalMisses == 0) {
      // No misses = we don't know resilience yet
      return 0.5; // Neutral
    }

    // Recovery rate
    final recoveryRate = totalMisses > 0 ? recoveries / totalMisses : 0.0;

    return recoveryRate.clamp(0.0, 1.0);
  }

  /// Calculate habit strength (automaticity)
  double _calculateHabitStrength(Habit habit) {
    // Based on:
    // - Current streak (consistency)
    // - Days showed up
    // - Age of habit

    final daysSinceCreation = DateTime.now().difference(habit.createdAt).inDays;
    if (daysSinceCreation == 0) return 0.0;

    // Show up rate is the primary indicator
    final showUpRate = habit.showUpRate;

    // Streak bonus (long streak = automatic)
    final streakBonus = (habit.currentStreak / 66.0).clamp(0.0, 0.3);

    // Age factor (older habit + high show up = stronger)
    final ageFactor = (daysSinceCreation / 180.0).clamp(0.0, 0.2);

    return (showUpRate * 0.5 + streakBonus + ageFactor).clamp(0.0, 1.0);
  }

  /// Initialize all services
  Future<void> initialize({String? weatherApiKey}) async {
    // Initialize biometrics (requests permissions)
    await _biometricsService.initialize();

    // Weather service is initialized with API key in constructor
    // Calendar service initializes lazily on first use
  }

  /// Check which sensors are available
  Future<Map<String, bool>> checkSensorAvailability() async {
    return {
      'location': await Geolocator.isLocationServiceEnabled(),
      'calendar': await _calendarService.hasPermission(),
      'biometrics': await _biometricsService.hasPermission(),
      'weather': true, // Always available if API key set
    };
  }

  /// Request all permissions
  Future<Map<String, bool>> requestAllPermissions() async {
    final results = <String, bool>{};

    // Location
    try {
      final permission = await Geolocator.requestPermission();
      results['location'] = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (_) {
      results['location'] = false;
    }

    // Calendar
    results['calendar'] = await _calendarService.requestPermission();

    // Biometrics
    results['biometrics'] = await _biometricsService.initialize();

    return results;
  }
}
