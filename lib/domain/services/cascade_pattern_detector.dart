/// Cascade Pattern Detector - ML Workstream #2 Enhancement
///
/// Detects high-risk patterns that lead to cascade failures:
/// 1. Weather-sensitive outdoor habits
/// 2. Travel disruption patterns
/// 3. Weekend vulnerability patterns
/// 4. Energy gap patterns (biometrics)
///
/// Philosophy: Predict the cascade BEFORE it starts,
/// not after the user has already missed multiple days.

import '../entities/context_snapshot.dart';
import '../../data/models/habit.dart';

/// Risk assessment for cascade failure
class CascadeRisk {
  /// Probability of cascade (0.0-1.0)
  final double probability;

  /// Primary reason for risk
  final CascadeRiskReason reason;

  /// Secondary contributing factors
  final List<CascadeRiskReason> contributingFactors;

  /// Recommended preventive action
  final CascadePreventionAction? suggestedAction;

  /// Days until predicted cascade (null if immediate)
  final int? daysUntilRisk;

  /// Human-readable explanation
  final String explanation;

  const CascadeRisk({
    required this.probability,
    required this.reason,
    this.contributingFactors = const [],
    this.suggestedAction,
    this.daysUntilRisk,
    required this.explanation,
  });

  /// Low risk baseline
  static const baseline = CascadeRisk(
    probability: 0.15,
    reason: CascadeRiskReason.baseline,
    explanation: 'Normal risk level',
  );

  /// Is this a high-risk situation requiring intervention?
  bool get isHighRisk => probability >= 0.6;

  /// Is this a critical situation requiring immediate action?
  bool get isCritical => probability >= 0.8;
}

/// Reasons for cascade risk
enum CascadeRiskReason {
  /// No specific risk factor
  baseline,

  /// Weather blocking outdoor activity
  weatherBlocking,

  /// User is traveling (routine disruption)
  travelDisruption,

  /// Weekend pattern detected
  weekendPattern,

  /// Low energy / sleep deprivation
  energyGap,

  /// Yesterday was a miss (Never Miss Twice zone)
  yesterdayMiss,

  /// Multiple days missed (critical zone)
  multiDayMiss,

  /// Calendar is packed (no time windows)
  calendarCrunch,

  /// Social isolation (no witness engagement)
  socialIsolation,
}

/// Suggested preventive actions
enum CascadePreventionAction {
  /// Suggest indoor alternative
  suggestIndoorAlternative,

  /// Suggest travel-friendly version
  suggestTravelVersion,

  /// Pre-weekend reminder
  weekendPreReminder,

  /// Energy-appropriate tiny version
  suggestTinyVersion,

  /// Never Miss Twice intervention
  neverMissTwiceNudge,

  /// Compassionate return message
  compassionateReturn,

  /// Find a time slot
  findTimeSlot,

  /// Activate witness
  activateWitness,
}

/// Cascade Pattern Detector Service
class CascadePatternDetector {
  /// Detect all cascade risks for a habit
  CascadeRisk detectRisk({
    required Habit habit,
    required ContextSnapshot context,
  }) {
    final risks = <CascadeRisk>[];

    // === PATTERN 1: Yesterday Miss (Highest Priority) ===
    final yesterdayRisk = _detectYesterdayMiss(habit, context);
    if (yesterdayRisk != null) risks.add(yesterdayRisk);

    // === PATTERN 2: Weather Cascade (Outdoor Habits) ===
    final weatherRisk = _detectWeatherCascade(habit, context);
    if (weatherRisk != null) risks.add(weatherRisk);

    // === PATTERN 3: Travel Disruption ===
    final travelRisk = _detectTravelDisruption(habit, context);
    if (travelRisk != null) risks.add(travelRisk);

    // === PATTERN 4: Weekend Pattern ===
    final weekendRisk = _detectWeekendPattern(habit, context);
    if (weekendRisk != null) risks.add(weekendRisk);

    // === PATTERN 5: Energy Gap ===
    final energyRisk = _detectEnergyGap(habit, context);
    if (energyRisk != null) risks.add(energyRisk);

    // === PATTERN 6: Calendar Crunch ===
    final calendarRisk = _detectCalendarCrunch(habit, context);
    if (calendarRisk != null) risks.add(calendarRisk);

    // Return highest risk, with others as contributing factors
    if (risks.isEmpty) {
      return CascadeRisk.baseline;
    }

    risks.sort((a, b) => b.probability.compareTo(a.probability));
    final primary = risks.first;
    final contributing = risks.skip(1).map((r) => r.reason).toList();

    return CascadeRisk(
      probability: primary.probability,
      reason: primary.reason,
      contributingFactors: contributing,
      suggestedAction: primary.suggestedAction,
      daysUntilRisk: primary.daysUntilRisk,
      explanation: primary.explanation,
    );
  }

  /// Detect yesterday miss (Never Miss Twice territory)
  CascadeRisk? _detectYesterdayMiss(Habit habit, ContextSnapshot context) {
    if (habit.lastCompletedDate == null) return null;

    final daysSinceLast = context.time.hour >= 12
        ? context.capturedAt.difference(habit.lastCompletedDate!).inDays
        : context.capturedAt.difference(habit.lastCompletedDate!).inDays - 1;

    if (daysSinceLast >= 3) {
      return CascadeRisk(
        probability: 0.9,
        reason: CascadeRiskReason.multiDayMiss,
        suggestedAction: CascadePreventionAction.compassionateReturn,
        explanation: 'It\'s been $daysSinceLast days. Time for a compassionate return.',
      );
    }

    if (daysSinceLast >= 1) {
      return CascadeRisk(
        probability: 0.75,
        reason: CascadeRiskReason.yesterdayMiss,
        suggestedAction: CascadePreventionAction.neverMissTwiceNudge,
        explanation: 'Yesterday was a miss. Today is Never Miss Twice day.',
      );
    }

    return null;
  }

  /// Detect weather cascade for outdoor habits
  CascadeRisk? _detectWeatherCascade(Habit habit, ContextSnapshot context) {
    // Only applies to outdoor habits
    if (!_isOutdoorHabit(habit)) return null;

    final weather = context.weather;
    if (weather == null) return null;

    // Check multi-day outdoor block
    if (weather.isMultiDayOutdoorBlock) {
      final badDays = weather.forecast
              ?.where((f) => !f.isOutdoorSuitable)
              .length ?? 0;

      return CascadeRisk(
        probability: 0.7 + (badDays * 0.05),
        reason: CascadeRiskReason.weatherBlocking,
        suggestedAction: CascadePreventionAction.suggestIndoorAlternative,
        daysUntilRisk: 0,
        explanation: 'Weather forecast shows $badDays unsuitable days. '
            'Consider an indoor alternative.',
      );
    }

    // Check current weather
    if (weather.isRaining || weather.isCold || weather.isHot) {
      return CascadeRisk(
        probability: 0.5,
        reason: CascadeRiskReason.weatherBlocking,
        suggestedAction: CascadePreventionAction.suggestTinyVersion,
        daysUntilRisk: 0,
        explanation: 'Current weather may block outdoor activity.',
      );
    }

    return null;
  }

  /// Detect travel disruption from calendar or location
  CascadeRisk? _detectTravelDisruption(Habit habit, ContextSnapshot context) {
    // Check location zone
    if (context.location?.zone == LocationZone.travel) {
      return CascadeRisk(
        probability: 0.65,
        reason: CascadeRiskReason.travelDisruption,
        suggestedAction: CascadePreventionAction.suggestTravelVersion,
        explanation: 'Routine disrupted by travel. Suggest travel-friendly version.',
      );
    }

    // Check calendar for travel keywords
    final calendar = context.calendar;
    if (calendar != null && _hasUpcomingTravel(calendar)) {
      return CascadeRisk(
        probability: 0.55,
        reason: CascadeRiskReason.travelDisruption,
        suggestedAction: CascadePreventionAction.suggestTravelVersion,
        daysUntilRisk: 1,
        explanation: 'Upcoming travel detected. Plan a travel-friendly approach.',
      );
    }

    return null;
  }

  /// Detect weekend vulnerability pattern
  CascadeRisk? _detectWeekendPattern(Habit habit, ContextSnapshot context) {
    // Only check on Friday evening or weekend
    final isWeekendWindow = context.time.isWeekend ||
        (context.time.dayOfWeek == DateTime.friday && context.time.isEvening);

    if (!isWeekendWindow) return null;

    // Check if habit has weekend pattern in miss history
    final hasWeekendPattern = habit.missHistory.any((m) =>
        m.category == 'weekend' ||
        (m.missedAt.weekday == DateTime.saturday ||
            m.missedAt.weekday == DateTime.sunday));

    // Check if habit has weekend risk flag
    final weekendMissCount = habit.missHistory
        .where((m) =>
            m.missedAt.weekday == DateTime.saturday ||
            m.missedAt.weekday == DateTime.sunday)
        .length;

    final totalMisses = habit.missHistory.length;
    final weekendMissRate =
        totalMisses > 0 ? weekendMissCount / totalMisses : 0.0;

    if (weekendMissRate > 0.4 || hasWeekendPattern) {
      return CascadeRisk(
        probability: 0.5 + (weekendMissRate * 0.3),
        reason: CascadeRiskReason.weekendPattern,
        suggestedAction: CascadePreventionAction.weekendPreReminder,
        explanation: 'Weekend pattern detected. ${(weekendMissRate * 100).toInt()}% '
            'of misses are on weekends.',
      );
    }

    return null;
  }

  /// Detect energy gap from biometrics
  CascadeRisk? _detectEnergyGap(Habit habit, ContextSnapshot context) {
    final biometrics = context.biometrics;
    if (biometrics == null) return null;

    // Check for sleep deprivation
    if (biometrics.isSleepDeprived) {
      return CascadeRisk(
        probability: 0.45,
        reason: CascadeRiskReason.energyGap,
        suggestedAction: CascadePreventionAction.suggestTinyVersion,
        explanation: 'Low sleep detected. Consider the tiny version today.',
      );
    }

    // Check for stress (low HRV)
    if (biometrics.isStressed) {
      return CascadeRisk(
        probability: 0.4,
        reason: CascadeRiskReason.energyGap,
        suggestedAction: CascadePreventionAction.suggestTinyVersion,
        explanation: 'Elevated stress detected. Be kind to yourself.',
      );
    }

    return null;
  }

  /// Detect calendar crunch (no time available)
  CascadeRisk? _detectCalendarCrunch(Habit habit, ContextSnapshot context) {
    final calendar = context.calendar;
    if (calendar == null) return null;

    // Very busy day (busyness > 0.8) with no free windows
    if (calendar.busynessScore > 0.8 && !calendar.hasTimeWindow) {
      return CascadeRisk(
        probability: 0.55,
        reason: CascadeRiskReason.calendarCrunch,
        suggestedAction: CascadePreventionAction.findTimeSlot,
        explanation: 'Packed schedule today. Let\'s find a tiny window.',
      );
    }

    return null;
  }

  /// Check if habit is outdoor-based
  bool _isOutdoorHabit(Habit habit) {
    final outdoorKeywords = [
      'run',
      'jog',
      'walk',
      'hike',
      'bike',
      'cycle',
      'swim',
      'outdoor',
      'outside',
      'park',
      'garden',
      'exercise',
      'workout',
      'gym', // Often requires going outside
    ];

    final habitNameLower = habit.name.toLowerCase();
    final habitIdentityLower = (habit.identity).toLowerCase();

    return outdoorKeywords.any(
      (kw) => habitNameLower.contains(kw) || habitIdentityLower.contains(kw),
    );
  }

  /// Check calendar for travel keywords
  bool _hasUpcomingTravel(CalendarContext calendar) {
    final title = calendar.currentEventTitle?.toLowerCase() ?? '';
    final travelKeywords = [
      'flight',
      'airport',
      'travel',
      'trip',
      'vacation',
      'hotel',
      'train',
      'conference',
      'out of office',
    ];

    return travelKeywords.any((kw) => title.contains(kw));
  }

  /// Get alternative suggestion based on risk
  String? getAlternativeSuggestion({
    required Habit habit,
    required CascadeRisk risk,
  }) {
    switch (risk.suggestedAction) {
      case CascadePreventionAction.suggestIndoorAlternative:
        return _generateIndoorAlternative(habit);

      case CascadePreventionAction.suggestTravelVersion:
        return _generateTravelVersion(habit);

      case CascadePreventionAction.suggestTinyVersion:
        return 'Just do ${habit.tinyVersion}. That\'s a win.';

      case CascadePreventionAction.weekendPreReminder:
        return 'Weekend ahead. What\'s your Saturday plan for ${habit.name}?';

      case CascadePreventionAction.neverMissTwiceNudge:
        return 'Yesterday was a miss. Today: ${habit.tinyVersion}. That\'s all.';

      case CascadePreventionAction.compassionateReturn:
        return 'Welcome back. ${habit.identityVotes} votes still count. '
            'Today is just the next one.';

      case CascadePreventionAction.findTimeSlot:
        return 'Busy day. Can you do ${habit.tinyVersion} between meetings?';

      case CascadePreventionAction.activateWitness:
        return 'Time to check in with your accountability partner.';

      case null:
        return null;
    }
  }

  String _generateIndoorAlternative(Habit habit) {
    final name = habit.name.toLowerCase();

    if (name.contains('run') || name.contains('jog')) {
      return 'Rain plan: Indoor workout, jumping jacks, or yoga.';
    }
    if (name.contains('walk')) {
      return 'Rain plan: Walk around your home, stretch, or indoor steps.';
    }
    if (name.contains('bike') || name.contains('cycle')) {
      return 'Rain plan: Indoor cycling, squats, or bodyweight exercises.';
    }
    if (name.contains('exercise') || name.contains('workout')) {
      return 'Rain plan: Home workout, push-ups, or YouTube fitness video.';
    }

    return 'Weather alert: Consider an indoor version of ${habit.name}.';
  }

  String _generateTravelVersion(Habit habit) {
    final tinyVersion = habit.tinyVersion;
    return 'Travel version: $tinyVersion, anywhere, any time.';
  }
}
