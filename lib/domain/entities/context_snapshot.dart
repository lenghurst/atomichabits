/// ContextSnapshot: The unified sensory input for JITAI decision-making.
///
/// This is the "eyes and ears" of the intervention system - a frozen snapshot
/// of all contextual signals at a moment in time. Used as input to the
/// Vulnerability-Opportunity Calculator and Hierarchical Bandit.
///
/// Design principles:
/// - Immutable snapshot (no mutation after creation)
/// - All sensor values are optional (graceful degradation)
/// - Z-scores for cross-metric comparison (normalized to user baseline)
/// - Timestamps for staleness detection
///
/// Phase 63: JITAI Foundation
class ContextSnapshot {
  // === IDENTITY ===
  final String snapshotId;
  final DateTime capturedAt;

  // === TIME FEATURES (Always Available) ===
  final TimeContext time;

  // === BIOMETRIC FEATURES (Optional - Health Connect/HealthKit) ===
  final BiometricContext? biometrics;

  // === CALENDAR FEATURES (Optional - Google Calendar) ===
  final CalendarContext? calendar;

  // === WEATHER FEATURES (Optional - OpenWeatherMap) ===
  final WeatherContext? weather;

  // === LOCATION FEATURES (Optional - Geolocator) ===
  final LocationContext? location;

  // === DIGITAL BEHAVIOR (Optional - App Usage) ===
  final DigitalContext? digital;

  // === HISTORICAL FEATURES (From Habit Data) ===
  final HistoricalContext history;

  // === USER OVERRIDE (The Thermostat) ===
  /// Manual vulnerability override from user (0.0-1.0, null if not set)
  /// This is the strongest signal - user explicitly stating their state
  final double? userVulnerabilityOverride;

  // === ACTIVE PATTERNS (From Pattern Detection) ===
  final List<String> activePatterns;

  ContextSnapshot({
    required this.snapshotId,
    required this.capturedAt,
    required this.time,
    this.biometrics,
    this.calendar,
    this.weather,
    this.location,
    this.digital,
    required this.history,
    this.userVulnerabilityOverride,
    this.activePatterns = const [],
  });

  /// Create a snapshot with current time context
  factory ContextSnapshot.now({
    required HistoricalContext history,
    BiometricContext? biometrics,
    CalendarContext? calendar,
    WeatherContext? weather,
    LocationContext? location,
    DigitalContext? digital,
    double? userVulnerabilityOverride,
    List<String> activePatterns = const [],
  }) {
    final now = DateTime.now();
    return ContextSnapshot(
      snapshotId: '${now.millisecondsSinceEpoch}',
      capturedAt: now,
      time: TimeContext.fromDateTime(now),
      biometrics: biometrics,
      calendar: calendar,
      weather: weather,
      location: location,
      digital: digital,
      history: history,
      userVulnerabilityOverride: userVulnerabilityOverride,
      activePatterns: activePatterns,
    );
  }

  /// Check if snapshot is stale (older than threshold)
  bool isStale({Duration threshold = const Duration(minutes: 15)}) {
    return DateTime.now().difference(capturedAt) > threshold;
  }

  /// Count of available sensor sources (for data richness scoring)
  int get sensorCount {
    int count = 1; // Time is always available
    if (biometrics != null) count++;
    if (calendar != null) count++;
    if (weather != null) count++;
    if (location != null) count++;
    if (digital != null) count++;
    return count;
  }

  /// Data richness score (0.0-1.0) - how much context we have
  double get dataRichness => sensorCount / 6.0;

  /// Convert to ML feature vector for bandit input
  Map<String, double> toFeatureVector() {
    return {
      // Time features (cyclical encoding for ML)
      'hour_sin': time.hourSin,
      'hour_cos': time.hourCos,
      'day_of_week': time.dayOfWeek.toDouble(),
      'is_weekend': time.isWeekend ? 1.0 : 0.0,
      'is_morning': time.isMorning ? 1.0 : 0.0,
      'is_evening': time.isEvening ? 1.0 : 0.0,

      // Biometric features (z-scores, 0 if unavailable)
      'sleep_z': biometrics?.sleepZScore ?? 0.0,
      'hrv_z': biometrics?.hrvZScore ?? 0.0,

      // Calendar features
      'busyness': calendar?.busynessScore ?? 0.5,
      'free_window_mins': (calendar?.freeWindowMinutes ?? 60).toDouble(),
      'in_meeting': (calendar?.isInMeeting ?? false) ? 1.0 : 0.0,

      // Weather features
      'outdoor_suitable': (weather?.isOutdoorSuitable ?? true) ? 1.0 : 0.0,
      'is_raining': (weather?.isRaining ?? false) ? 1.0 : 0.0,

      // Location features
      'at_home': (location?.isAtHome ?? false) ? 1.0 : 0.0,
      'at_work': (location?.isAtWork ?? false) ? 1.0 : 0.0,
      'at_gym': (location?.isAtGym ?? false) ? 1.0 : 0.0,

      // Digital features
      'distraction_z': digital?.distractionZScore ?? 0.0,

      // Historical features
      'current_streak': history.currentStreak.toDouble(),
      'days_since_miss': history.daysSinceMiss.toDouble(),
      'identity_score': history.identityFusionScore,
      'resilience': history.resilienceScore,
      'habit_strength': history.habitStrength,

      // Intervention fatigue
      'interventions_24h': history.interventionCount24h.toDouble(),
      'hours_since_intervention': history.hoursSinceLastIntervention,

      // Override signal
      'user_override': userVulnerabilityOverride ?? -1.0, // -1 = not set

      // Data richness (meta-feature)
      'data_richness': dataRichness,
    };
  }

  Map<String, dynamic> toJson() => {
        'snapshotId': snapshotId,
        'capturedAt': capturedAt.toIso8601String(),
        'time': time.toJson(),
        'biometrics': biometrics?.toJson(),
        'calendar': calendar?.toJson(),
        'weather': weather?.toJson(),
        'location': location?.toJson(),
        'digital': digital?.toJson(),
        'history': history.toJson(),
        'userVulnerabilityOverride': userVulnerabilityOverride,
        'activePatterns': activePatterns,
      };

  factory ContextSnapshot.fromJson(Map<String, dynamic> json) {
    return ContextSnapshot(
      snapshotId: json['snapshotId'] as String,
      capturedAt: DateTime.parse(json['capturedAt'] as String),
      time: TimeContext.fromJson(json['time'] as Map<String, dynamic>),
      biometrics: json['biometrics'] != null
          ? BiometricContext.fromJson(json['biometrics'] as Map<String, dynamic>)
          : null,
      calendar: json['calendar'] != null
          ? CalendarContext.fromJson(json['calendar'] as Map<String, dynamic>)
          : null,
      weather: json['weather'] != null
          ? WeatherContext.fromJson(json['weather'] as Map<String, dynamic>)
          : null,
      location: json['location'] != null
          ? LocationContext.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      digital: json['digital'] != null
          ? DigitalContext.fromJson(json['digital'] as Map<String, dynamic>)
          : null,
      history: HistoricalContext.fromJson(json['history'] as Map<String, dynamic>),
      userVulnerabilityOverride: json['userVulnerabilityOverride'] as double?,
      activePatterns: List<String>.from(json['activePatterns'] ?? []),
    );
  }
}

// =============================================================================
// CONTEXT COMPONENTS
// =============================================================================

/// Time-based context (always available)
class TimeContext {
  final int hour; // 0-23
  final int dayOfWeek; // 1-7 (Monday = 1)
  final bool isWeekend;
  final bool isMorning; // 5-11
  final bool isEvening; // 18-23

  // Cyclical encoding for ML (captures "11pm is close to 1am")
  final double hourSin;
  final double hourCos;

  TimeContext({
    required this.hour,
    required this.dayOfWeek,
    required this.isWeekend,
    required this.isMorning,
    required this.isEvening,
    required this.hourSin,
    required this.hourCos,
  });

  factory TimeContext.fromDateTime(DateTime dt) {
    final hour = dt.hour;
    final dayOfWeek = dt.weekday;
    final isWeekend = dayOfWeek == DateTime.saturday || dayOfWeek == DateTime.sunday;

    // Cyclical encoding: hour -> sin/cos for continuity
    final hourRadians = (hour / 24.0) * 2 * 3.14159;

    return TimeContext(
      hour: hour,
      dayOfWeek: dayOfWeek,
      isWeekend: isWeekend,
      isMorning: hour >= 5 && hour < 12,
      isEvening: hour >= 18,
      hourSin: _sin(hourRadians),
      hourCos: _cos(hourRadians),
    );
  }

  // Simple sin/cos to avoid importing dart:math everywhere
  static double _sin(double x) {
    // Taylor series approximation (good enough for encoding)
    x = x % (2 * 3.14159);
    double result = x;
    double term = x;
    for (int i = 1; i <= 5; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }

  static double _cos(double x) => _sin(x + 3.14159 / 2);

  Map<String, dynamic> toJson() => {
        'hour': hour,
        'dayOfWeek': dayOfWeek,
        'isWeekend': isWeekend,
        'isMorning': isMorning,
        'isEvening': isEvening,
        'hourSin': hourSin,
        'hourCos': hourCos,
      };

  factory TimeContext.fromJson(Map<String, dynamic> json) {
    return TimeContext(
      hour: json['hour'] as int,
      dayOfWeek: json['dayOfWeek'] as int,
      isWeekend: json['isWeekend'] as bool,
      isMorning: json['isMorning'] as bool,
      isEvening: json['isEvening'] as bool,
      hourSin: (json['hourSin'] as num).toDouble(),
      hourCos: (json['hourCos'] as num).toDouble(),
    );
  }
}

/// Biometric context from Health Connect / HealthKit
class BiometricContext {
  final int? sleepMinutes; // Last night's sleep
  final double? hrvSdnn; // Heart rate variability
  final DateTime capturedAt;

  // Z-scores relative to user's baseline (positive = better than average)
  final double sleepZScore;
  final double hrvZScore;

  BiometricContext({
    this.sleepMinutes,
    this.hrvSdnn,
    required this.capturedAt,
    this.sleepZScore = 0.0,
    this.hrvZScore = 0.0,
  });

  /// Is user sleep deprived? (< 6 hours or z-score < -1)
  bool get isSleepDeprived => sleepZScore < -1.0 || (sleepMinutes != null && sleepMinutes! < 360);

  /// Is user stressed? (low HRV, z-score < -1)
  bool get isStressed => hrvZScore < -1.0;

  Map<String, dynamic> toJson() => {
        'sleepMinutes': sleepMinutes,
        'hrvSdnn': hrvSdnn,
        'capturedAt': capturedAt.toIso8601String(),
        'sleepZScore': sleepZScore,
        'hrvZScore': hrvZScore,
      };

  factory BiometricContext.fromJson(Map<String, dynamic> json) {
    return BiometricContext(
      sleepMinutes: json['sleepMinutes'] as int?,
      hrvSdnn: (json['hrvSdnn'] as num?)?.toDouble(),
      capturedAt: DateTime.parse(json['capturedAt'] as String),
      sleepZScore: (json['sleepZScore'] as num?)?.toDouble() ?? 0.0,
      hrvZScore: (json['hrvZScore'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Calendar context from Google Calendar
class CalendarContext {
  final double busynessScore; // 0.0 (free) to 1.0 (packed)
  final int? freeWindowMinutes; // Next free window duration
  final int? minutesToNextMeeting;
  final bool isInMeeting;
  final String? currentEventTitle; // For context (anonymized)
  final DateTime capturedAt;

  // Travel detection
  final bool isTravelDay; // Calendar has travel-related events
  final bool isMultiDayTrip; // Travel spans multiple days
  final int? tripDaysRemaining; // Days until return (if on trip)

  CalendarContext({
    required this.busynessScore,
    this.freeWindowMinutes,
    this.minutesToNextMeeting,
    this.isInMeeting = false,
    this.currentEventTitle,
    required this.capturedAt,
    this.isTravelDay = false,
    this.isMultiDayTrip = false,
    this.tripDaysRemaining,
  });

  /// Has enough time for a habit? (> 15 min free window)
  bool get hasTimeWindow => freeWindowMinutes != null && freeWindowMinutes! >= 15;

  /// Is in a good intervention window? (not in meeting, has time)
  bool get isGoodWindow => !isInMeeting && hasTimeWindow;

  /// Is routine likely disrupted?
  bool get isRoutineDisrupted => isTravelDay || isMultiDayTrip;

  /// Check if current event title contains travel keywords
  bool get hasUpcomingTravel {
    final title = currentEventTitle?.toLowerCase() ?? '';
    const travelKeywords = [
      'flight',
      'airport',
      'travel',
      'trip',
      'vacation',
      'hotel',
      'train',
      'conference',
      'out of office',
      'ooo',
      'pto',
      'holiday',
    ];
    return travelKeywords.any((kw) => title.contains(kw));
  }

  Map<String, dynamic> toJson() => {
        'busynessScore': busynessScore,
        'freeWindowMinutes': freeWindowMinutes,
        'minutesToNextMeeting': minutesToNextMeeting,
        'isInMeeting': isInMeeting,
        'currentEventTitle': currentEventTitle,
        'capturedAt': capturedAt.toIso8601String(),
        'isTravelDay': isTravelDay,
        'isMultiDayTrip': isMultiDayTrip,
        'tripDaysRemaining': tripDaysRemaining,
      };

  factory CalendarContext.fromJson(Map<String, dynamic> json) {
    return CalendarContext(
      busynessScore: (json['busynessScore'] as num).toDouble(),
      freeWindowMinutes: json['freeWindowMinutes'] as int?,
      minutesToNextMeeting: json['minutesToNextMeeting'] as int?,
      isInMeeting: json['isInMeeting'] as bool? ?? false,
      currentEventTitle: json['currentEventTitle'] as String?,
      capturedAt: DateTime.parse(json['capturedAt'] as String),
      isTravelDay: json['isTravelDay'] as bool? ?? false,
      isMultiDayTrip: json['isMultiDayTrip'] as bool? ?? false,
      tripDaysRemaining: json['tripDaysRemaining'] as int?,
    );
  }
}

/// Weather context from OpenWeatherMap
class WeatherContext {
  final WeatherCondition condition;
  final double temperatureCelsius;
  final bool isOutdoorSuitable;
  final List<WeatherForecast>? forecast; // Next 3 days
  final DateTime capturedAt;

  WeatherContext({
    required this.condition,
    required this.temperatureCelsius,
    required this.isOutdoorSuitable,
    this.forecast,
    required this.capturedAt,
  });

  bool get isRaining =>
      condition == WeatherCondition.rain ||
      condition == WeatherCondition.thunderstorm ||
      condition == WeatherCondition.drizzle;

  bool get isCold => temperatureCelsius < 5;
  bool get isHot => temperatureCelsius > 32;

  /// Predicts if outdoor activities will be blocked for multiple days
  bool get isMultiDayOutdoorBlock {
    if (forecast == null) return false;
    final badDays = forecast!.where((f) => !f.isOutdoorSuitable).length;
    return badDays >= 2;
  }

  Map<String, dynamic> toJson() => {
        'condition': condition.name,
        'temperatureCelsius': temperatureCelsius,
        'isOutdoorSuitable': isOutdoorSuitable,
        'forecast': forecast?.map((f) => f.toJson()).toList(),
        'capturedAt': capturedAt.toIso8601String(),
      };

  factory WeatherContext.fromJson(Map<String, dynamic> json) {
    return WeatherContext(
      condition: WeatherCondition.values.firstWhere(
        (e) => e.name == json['condition'],
        orElse: () => WeatherCondition.clear,
      ),
      temperatureCelsius: (json['temperatureCelsius'] as num).toDouble(),
      isOutdoorSuitable: json['isOutdoorSuitable'] as bool,
      forecast: (json['forecast'] as List?)
          ?.map((f) => WeatherForecast.fromJson(f as Map<String, dynamic>))
          .toList(),
      capturedAt: DateTime.parse(json['capturedAt'] as String),
    );
  }
}

enum WeatherCondition {
  clear,
  clouds,
  rain,
  drizzle,
  thunderstorm,
  snow,
  mist,
  fog,
  unknown,
}

class WeatherForecast {
  final DateTime date;
  final WeatherCondition condition;
  final bool isOutdoorSuitable;

  WeatherForecast({
    required this.date,
    required this.condition,
    required this.isOutdoorSuitable,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'condition': condition.name,
        'isOutdoorSuitable': isOutdoorSuitable,
      };

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      date: DateTime.parse(json['date'] as String),
      condition: WeatherCondition.values.firstWhere(
        (e) => e.name == json['condition'],
        orElse: () => WeatherCondition.unknown,
      ),
      isOutdoorSuitable: json['isOutdoorSuitable'] as bool,
    );
  }
}

/// Location context from Geolocator
class LocationContext {
  final double? latitude;
  final double? longitude;
  final LocationZone zone;
  final double? distanceToHabitLocation; // meters
  final DateTime capturedAt;

  LocationContext({
    this.latitude,
    this.longitude,
    required this.zone,
    this.distanceToHabitLocation,
    required this.capturedAt,
  });

  bool get isAtHome => zone == LocationZone.home;
  bool get isAtWork => zone == LocationZone.work;
  bool get isAtGym => zone == LocationZone.gym;
  bool get isNearHabitLocation =>
      distanceToHabitLocation != null && distanceToHabitLocation! < 100;

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'zone': zone.name,
        'distanceToHabitLocation': distanceToHabitLocation,
        'capturedAt': capturedAt.toIso8601String(),
      };

  factory LocationContext.fromJson(Map<String, dynamic> json) {
    return LocationContext(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      zone: LocationZone.values.firstWhere(
        (e) => e.name == json['zone'],
        orElse: () => LocationZone.unknown,
      ),
      distanceToHabitLocation: (json['distanceToHabitLocation'] as num?)?.toDouble(),
      capturedAt: DateTime.parse(json['capturedAt'] as String),
    );
  }
}

enum LocationZone {
  home,
  work,
  gym,
  commute,
  travel,
  unknown,
}

/// Digital behavior context from App Usage APIs
class DigitalContext {
  final int distractionMinutes; // Total dopamine app time today
  final String? apexDistractor; // Most used app (e.g., "TikTok")
  final double distractionZScore; // Relative to user's baseline
  final DateTime capturedAt;

  DigitalContext({
    required this.distractionMinutes,
    this.apexDistractor,
    this.distractionZScore = 0.0,
    required this.capturedAt,
  });

  /// Is user in a high-distraction state? (z-score > 1)
  bool get isHighDistraction => distractionZScore > 1.0;

  Map<String, dynamic> toJson() => {
        'distractionMinutes': distractionMinutes,
        'apexDistractor': apexDistractor,
        'distractionZScore': distractionZScore,
        'capturedAt': capturedAt.toIso8601String(),
      };

  factory DigitalContext.fromJson(Map<String, dynamic> json) {
    return DigitalContext(
      distractionMinutes: json['distractionMinutes'] as int,
      apexDistractor: json['apexDistractor'] as String?,
      distractionZScore: (json['distractionZScore'] as num?)?.toDouble() ?? 0.0,
      capturedAt: DateTime.parse(json['capturedAt'] as String),
    );
  }
}

/// Historical context from habit tracking data
class HistoricalContext {
  // Streak and consistency
  final int currentStreak;
  final int daysSinceMiss;
  final int totalIdentityVotes; // Cumulative completions

  // Scores (0.0-1.0)
  final double identityFusionScore; // How "fused" with identity
  final double resilienceScore; // Recovery capability
  final double habitStrength; // Automaticity level

  // Intervention fatigue tracking
  final int interventionCount24h;
  final double hoursSinceLastIntervention;
  final List<String> recentInterventionArms; // Last 5 arm IDs

  HistoricalContext({
    required this.currentStreak,
    required this.daysSinceMiss,
    required this.totalIdentityVotes,
    required this.identityFusionScore,
    required this.resilienceScore,
    required this.habitStrength,
    this.interventionCount24h = 0,
    this.hoursSinceLastIntervention = 24.0,
    this.recentInterventionArms = const [],
  });

  /// Is user at risk of intervention fatigue?
  bool get isInterventionFatigued => interventionCount24h >= 5;

  /// Is habit becoming automatic? (high strength, long streak)
  bool get isApproachingAutomaticity => habitStrength > 0.7 && currentStreak > 21;

  Map<String, dynamic> toJson() => {
        'currentStreak': currentStreak,
        'daysSinceMiss': daysSinceMiss,
        'totalIdentityVotes': totalIdentityVotes,
        'identityFusionScore': identityFusionScore,
        'resilienceScore': resilienceScore,
        'habitStrength': habitStrength,
        'interventionCount24h': interventionCount24h,
        'hoursSinceLastIntervention': hoursSinceLastIntervention,
        'recentInterventionArms': recentInterventionArms,
      };

  factory HistoricalContext.fromJson(Map<String, dynamic> json) {
    return HistoricalContext(
      currentStreak: json['currentStreak'] as int,
      daysSinceMiss: json['daysSinceMiss'] as int,
      totalIdentityVotes: json['totalIdentityVotes'] as int,
      identityFusionScore: (json['identityFusionScore'] as num).toDouble(),
      resilienceScore: (json['resilienceScore'] as num).toDouble(),
      habitStrength: (json['habitStrength'] as num).toDouble(),
      interventionCount24h: json['interventionCount24h'] as int? ?? 0,
      hoursSinceLastIntervention:
          (json['hoursSinceLastIntervention'] as num?)?.toDouble() ?? 24.0,
      recentInterventionArms:
          List<String>.from(json['recentInterventionArms'] ?? []),
    );
  }
}
