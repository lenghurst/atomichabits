/// OnboardingInsightsService - JITAI Signal Capture During Onboarding
///
/// The "theatre page" is the perfect moment to:
/// 1. Capture initial context signals (weather, calendar, time)
/// 2. Establish behavioral baselines before any habit data
/// 3. Initialize Thompson Sampling with archetype priors
/// 4. Generate personalized insights that demonstrate value
///
/// Philosophy: Show users we understand them from day one.
/// First impressions set expectations for the entire relationship.

import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../data/models/onboarding_data.dart';
import '../../config/niche_config.dart';
import 'jitai/context_snapshot.dart';
import 'jitai/weather_service.dart';
import 'jitai/calendar_service.dart';
import 'population_learning.dart';

/// Signal categories captured during onboarding
enum SignalCategory {
  /// Context: weather, time, calendar
  context,

  /// Intent: habit choices, commitment level
  intent,

  /// Baseline: initial risk profile, timing preferences
  baseline,

  /// Population: archetype priors from similar users
  population,
}

/// A single insight to display in the theatre
class OnboardingInsight {
  /// Category of this insight
  final SignalCategory category;

  /// Short label (e.g., "Optimal Window")
  final String label;

  /// Main insight text
  final String insight;

  /// Supporting detail or data point
  final String? detail;

  /// Confidence level (0.0 - 1.0)
  final double confidence;

  /// Icon suggestion for UI
  final String iconHint;

  const OnboardingInsight({
    required this.category,
    required this.label,
    required this.insight,
    this.detail,
    this.confidence = 0.8,
    this.iconHint = 'auto_awesome',
  });
}

/// Captured signals from onboarding context
class OnboardingSignals {
  // === TEMPORAL SIGNALS ===
  /// Hour of signup (0-23)
  final int signupHour;

  /// Day of week (1=Monday, 7=Sunday)
  final int signupDayOfWeek;

  /// Whether signup is on weekend
  final bool isWeekend;

  /// Time category (morning/afternoon/evening/night)
  final String timeOfDay;

  // === CONTEXT SIGNALS ===
  /// Current weather conditions (if permission granted)
  final String? weatherCondition;

  /// Current temperature (if available)
  final double? temperature;

  /// Calendar event count today (if permission granted)
  final int? calendarEventsToday;

  /// Whether calendar is "busy" (>3 events)
  final bool? isCalendarBusy;

  // === BEHAVIORAL INTENT SIGNALS ===
  /// Number of habits user wants to build
  final int habitCount;

  /// Whether user chose a break habit (harder)
  final bool hasBreakHabit;

  /// Preferred implementation time
  final String? preferredTime;

  /// Time category of preferred time
  final String? preferredTimeCategory;

  /// Whether user completed Sherlock screening
  final bool completedSherlock;

  /// User's failure archetype
  final String? failureArchetype;

  /// User's niche/persona
  final UserNiche userNiche;

  /// Whether user is a "streak refugee"
  final bool isStreakRefugee;

  // === COMMITMENT SIGNALS ===
  /// Whether user provided a Big Why
  final bool hasBigWhy;

  /// Whether user added witnesses
  final bool hasWitnesses;

  /// Whether user set environment design
  final bool hasEnvironmentDesign;

  /// Commitment score (0.0 - 1.0)
  final double commitmentScore;

  // === RISK SIGNALS ===
  /// Initial risk bitmask
  final int initialRiskBitmask;

  /// Risk level description
  final String riskLevel;

  const OnboardingSignals({
    required this.signupHour,
    required this.signupDayOfWeek,
    required this.isWeekend,
    required this.timeOfDay,
    this.weatherCondition,
    this.temperature,
    this.calendarEventsToday,
    this.isCalendarBusy,
    required this.habitCount,
    required this.hasBreakHabit,
    this.preferredTime,
    this.preferredTimeCategory,
    required this.completedSherlock,
    this.failureArchetype,
    required this.userNiche,
    required this.isStreakRefugee,
    required this.hasBigWhy,
    required this.hasWitnesses,
    required this.hasEnvironmentDesign,
    required this.commitmentScore,
    required this.initialRiskBitmask,
    required this.riskLevel,
  });

  Map<String, dynamic> toJson() => {
        'signupHour': signupHour,
        'signupDayOfWeek': signupDayOfWeek,
        'isWeekend': isWeekend,
        'timeOfDay': timeOfDay,
        'weatherCondition': weatherCondition,
        'temperature': temperature,
        'calendarEventsToday': calendarEventsToday,
        'isCalendarBusy': isCalendarBusy,
        'habitCount': habitCount,
        'hasBreakHabit': hasBreakHabit,
        'preferredTime': preferredTime,
        'preferredTimeCategory': preferredTimeCategory,
        'completedSherlock': completedSherlock,
        'failureArchetype': failureArchetype,
        'userNiche': userNiche.name,
        'isStreakRefugee': isStreakRefugee,
        'hasBigWhy': hasBigWhy,
        'hasWitnesses': hasWitnesses,
        'hasEnvironmentDesign': hasEnvironmentDesign,
        'commitmentScore': commitmentScore,
        'initialRiskBitmask': initialRiskBitmask,
        'riskLevel': riskLevel,
      };
}

/// Service for capturing onboarding signals and generating insights
class OnboardingInsightsService {
  final WeatherService? _weatherService;
  final CalendarService? _calendarService;
  final PopulationLearningService? _populationLearning;

  /// Cached signals from last capture
  OnboardingSignals? _cachedSignals;

  /// Cached insights from last generation
  List<OnboardingInsight>? _cachedInsights;

  OnboardingInsightsService({
    WeatherService? weatherService,
    CalendarService? calendarService,
    PopulationLearningService? populationLearning,
  })  : _weatherService = weatherService,
        _calendarService = calendarService,
        _populationLearning = populationLearning;

  /// Capture all available signals during onboarding
  ///
  /// Call this when the theatre page loads to begin signal capture.
  /// Returns a stream of progress updates for UI feedback.
  Stream<String> captureSignals({
    required List<OnboardingData> habits,
    bool hasWitnesses = false,
    String? bigWhy,
  }) async* {
    yield 'Analyzing your timing preferences...';

    final now = DateTime.now();
    final signupHour = now.hour;
    final signupDayOfWeek = now.weekday;
    final isWeekend = signupDayOfWeek >= 6;
    final timeOfDay = _categorizeTime(signupHour);

    // Parse preferred time from first habit
    String? preferredTime;
    String? preferredTimeCategory;
    if (habits.isNotEmpty && habits.first.implementationTime != null) {
      preferredTime = habits.first.implementationTime;
      final hour = _parseHour(preferredTime!);
      if (hour != null) {
        preferredTimeCategory = _categorizeTime(hour);
      }
    }

    yield 'Reading environmental context...';

    // Weather (if service available and configured)
    String? weatherCondition;
    double? temperature;
    if (_weatherService != null) {
      try {
        final weather = await _weatherService!.getCurrentWeather().timeout(
              const Duration(seconds: 3),
              onTimeout: () => null,
            );
        if (weather != null) {
          weatherCondition = weather.condition;
          temperature = weather.temperature;
        }
      } catch (e) {
        if (kDebugMode) debugPrint('Weather fetch failed: $e');
      }
    }

    yield 'Checking your schedule density...';

    // Calendar (if service available)
    int? calendarEventsToday;
    bool? isCalendarBusy;
    if (_calendarService != null) {
      try {
        final events = await _calendarService!.getTodayEventCount().timeout(
              const Duration(seconds: 2),
              onTimeout: () => null,
            );
        if (events != null) {
          calendarEventsToday = events;
          isCalendarBusy = events > 3;
        }
      } catch (e) {
        if (kDebugMode) debugPrint('Calendar fetch failed: $e');
      }
    }

    yield 'Profiling your commitment patterns...';

    // Analyze habits
    final habitCount = habits.length;
    final hasBreakHabit = habits.any((h) => h.habitType == HabitType.breakHabit);
    final completedSherlock = habits.any((h) => h.failureArchetype != null);
    final failureArchetype = habits
        .map((h) => h.failureArchetype)
        .firstWhere((a) => a != null, orElse: () => null);
    final userNiche = habits.isNotEmpty ? habits.first.userNiche : UserNiche.general;
    final isStreakRefugee = habits.any((h) => h.isStreakRefugee);

    // Commitment signals
    final hasBigWhy = bigWhy != null && bigWhy.isNotEmpty;
    final hasEnvironmentDesign = habits.any(
      (h) =>
          h.temptationBundle != null ||
          h.preHabitRitual != null ||
          h.environmentDistraction != null,
    );

    // Calculate commitment score
    final commitmentScore = _calculateCommitmentScore(
      hasBigWhy: hasBigWhy,
      hasWitnesses: hasWitnesses,
      hasEnvironmentDesign: hasEnvironmentDesign,
      completedSherlock: completedSherlock,
      habitCount: habitCount,
    );

    yield 'Building your risk profile...';

    // Initial risk bitmask
    final initialRiskBitmask = _calculateInitialRiskBitmask(
      isWeekend: isWeekend,
      signupHour: signupHour,
      isStreakRefugee: isStreakRefugee,
      failureArchetype: failureArchetype,
    );
    final riskLevel = _describeRiskLevel(initialRiskBitmask);

    yield 'Loading insights from similar users...';

    // Initialize population priors if archetype known
    if (failureArchetype != null && _populationLearning != null) {
      try {
        await _populationLearning!.fetchFromEdgeFunction(failureArchetype);
      } catch (e) {
        if (kDebugMode) debugPrint('Population learning fetch failed: $e');
      }
    }

    // Cache signals
    _cachedSignals = OnboardingSignals(
      signupHour: signupHour,
      signupDayOfWeek: signupDayOfWeek,
      isWeekend: isWeekend,
      timeOfDay: timeOfDay,
      weatherCondition: weatherCondition,
      temperature: temperature,
      calendarEventsToday: calendarEventsToday,
      isCalendarBusy: isCalendarBusy,
      habitCount: habitCount,
      hasBreakHabit: hasBreakHabit,
      preferredTime: preferredTime,
      preferredTimeCategory: preferredTimeCategory,
      completedSherlock: completedSherlock,
      failureArchetype: failureArchetype,
      userNiche: userNiche,
      isStreakRefugee: isStreakRefugee,
      hasBigWhy: hasBigWhy,
      hasWitnesses: hasWitnesses,
      hasEnvironmentDesign: hasEnvironmentDesign,
      commitmentScore: commitmentScore,
      initialRiskBitmask: initialRiskBitmask,
      riskLevel: riskLevel,
    );

    yield 'Generating personalized insights...';

    // Generate insights
    _cachedInsights = _generateInsights(_cachedSignals!);

    yield 'Ready';
  }

  /// Get cached signals (call after captureSignals completes)
  OnboardingSignals? get signals => _cachedSignals;

  /// Get cached insights (call after captureSignals completes)
  List<OnboardingInsight> get insights => _cachedInsights ?? [];

  /// Generate insights from captured signals
  List<OnboardingInsight> _generateInsights(OnboardingSignals signals) {
    final insights = <OnboardingInsight>[];

    // 1. TIMING INSIGHT - When they're likely to succeed
    insights.add(_generateTimingInsight(signals));

    // 2. ARCHETYPE INSIGHT - What we learned from Sherlock
    if (signals.failureArchetype != null) {
      insights.add(_generateArchetypeInsight(signals));
    }

    // 3. CONTEXT INSIGHT - Environmental awareness
    if (signals.weatherCondition != null || signals.isCalendarBusy != null) {
      insights.add(_generateContextInsight(signals));
    }

    // 4. RISK INSIGHT - Proactive protection
    if (signals.initialRiskBitmask > 0 || signals.isStreakRefugee) {
      insights.add(_generateRiskInsight(signals));
    }

    // 5. COMMITMENT INSIGHT - What we noticed about their setup
    insights.add(_generateCommitmentInsight(signals));

    // 6. NICHE INSIGHT - Persona-specific
    if (signals.userNiche != UserNiche.general) {
      insights.add(_generateNicheInsight(signals));
    }

    return insights;
  }

  OnboardingInsight _generateTimingInsight(OnboardingSignals signals) {
    final preferredCategory = signals.preferredTimeCategory ?? signals.timeOfDay;

    // Infer optimal windows based on signup time and preferred time
    String optimalWindow;
    String detail;

    if (signals.preferredTime != null) {
      optimalWindow = 'Your ${preferredCategory.toLowerCase()} window looks promising';
      detail = 'Users who set specific times are 2.3x more likely to build lasting habits';
    } else if (signals.signupHour >= 5 && signals.signupHour < 9) {
      optimalWindow = 'Morning energy detected';
      detail = 'Early risers have 40% higher completion rates. We\'ll prioritize morning nudges.';
    } else if (signals.signupHour >= 20 || signals.signupHour < 5) {
      optimalWindow = 'Night owl pattern recognized';
      detail = 'We\'ll avoid early morning pressure and find your natural rhythm.';
    } else {
      optimalWindow = 'Flexible timing detected';
      detail = 'We\'ll learn your optimal windows over the first week.';
    }

    return OnboardingInsight(
      category: SignalCategory.baseline,
      label: 'Optimal Window',
      insight: optimalWindow,
      detail: detail,
      confidence: signals.preferredTime != null ? 0.9 : 0.7,
      iconHint: 'schedule',
    );
  }

  OnboardingInsight _generateArchetypeInsight(OnboardingSignals signals) {
    final archetype = signals.failureArchetype!;
    String insight;
    String detail;

    switch (archetype.toUpperCase()) {
      case 'REBEL':
        insight = 'Independence is your superpower';
        detail = 'We\'ll frame habits as choices, not obligations. Autonomy-first interventions.';
        break;
      case 'PERFECTIONIST':
        insight = 'Excellence drives you—but can trap you';
        detail = 'We\'ll emphasize progress over perfection. "Done" beats "perfect".';
        break;
      case 'PROCRASTINATOR':
        insight = 'You work well under pressure';
        detail = 'We\'ll create artificial urgency and tiny first steps to beat resistance.';
        break;
      case 'OVERTHINKER':
        insight = 'Analysis is your strength—and obstacle';
        detail = 'We\'ll provide clear actions, not options. Decision fatigue is your enemy.';
        break;
      case 'PLEASURE_SEEKER':
        insight = 'Enjoyment is non-negotiable for you';
        detail = 'We\'ll make habits attractive first. If it\'s not fun, it won\'t stick.';
        break;
      case 'PEOPLE_PLEASER':
        insight = 'Connection fuels your motivation';
        detail = 'Witnesses will be key. Your accountability partners matter more than most.';
        break;
      default:
        insight = 'Your pattern has been identified';
        detail = 'We\'ll personalize interventions based on what works for similar users.';
    }

    return OnboardingInsight(
      category: SignalCategory.population,
      label: 'Pattern Recognized',
      insight: insight,
      detail: detail,
      confidence: 0.85,
      iconHint: 'psychology',
    );
  }

  OnboardingInsight _generateContextInsight(OnboardingSignals signals) {
    String insight;
    String detail;

    if (signals.isCalendarBusy == true) {
      insight = 'Busy schedule detected';
      detail =
          '${signals.calendarEventsToday} events today. We\'ll find the gaps and protect your habit windows.';
    } else if (signals.weatherCondition != null) {
      final weather = signals.weatherCondition!.toLowerCase();
      if (weather.contains('rain') || weather.contains('snow')) {
        insight = 'Weather awareness enabled';
        detail = 'We\'ll adjust expectations on difficult weather days—no guilt, just adaptation.';
      } else {
        insight = 'Environmental tracking active';
        detail = 'Weather, schedule, and energy will inform when we reach out.';
      }
    } else {
      insight = 'Context sensing initialized';
      detail = 'We\'ll learn your environmental patterns over the first week.';
    }

    return OnboardingInsight(
      category: SignalCategory.context,
      label: 'Context Aware',
      insight: insight,
      detail: detail,
      confidence: 0.75,
      iconHint: 'sensors',
    );
  }

  OnboardingInsight _generateRiskInsight(OnboardingSignals signals) {
    String insight;
    String detail;

    if (signals.isStreakRefugee) {
      insight = 'Streak burnout recognized';
      detail =
          'We won\'t guilt you about missed days. Show-up rate > streak count. Recovery is the goal.';
    } else if (signals.isWeekend) {
      insight = 'Weekend start noted';
      detail = 'Weekend habits have different patterns. We\'ll adapt for Monday transitions.';
    } else {
      insight = 'Risk profile initialized';
      detail = 'We\'ll proactively warn you before high-risk moments, not judge you after.';
    }

    return OnboardingInsight(
      category: SignalCategory.baseline,
      label: 'Protection Ready',
      insight: insight,
      detail: detail,
      confidence: signals.isStreakRefugee ? 0.95 : 0.7,
      iconHint: 'shield',
    );
  }

  OnboardingInsight _generateCommitmentInsight(OnboardingSignals signals) {
    String insight;
    String detail;

    if (signals.commitmentScore >= 0.8) {
      insight = 'Strong commitment signals detected';
      detail =
          'Big Why + Witnesses + Environment design. You\'re set up for success.';
    } else if (signals.commitmentScore >= 0.5) {
      insight = 'Solid foundation established';
      detail = 'Add witnesses or environment design to increase your success probability.';
    } else if (signals.hasBreakHabit) {
      insight = 'Breaking habits is harder—we\'re here for it';
      detail =
          'Break habits need substitution plans. We\'ll focus on what replaces the old behavior.';
    } else {
      insight = 'Starting point captured';
      detail = 'We\'ll help you strengthen your setup as you learn what works.';
    }

    return OnboardingInsight(
      category: SignalCategory.intent,
      label: 'Commitment Level',
      insight: insight,
      detail: detail,
      confidence: signals.commitmentScore,
      iconHint: 'verified',
    );
  }

  OnboardingInsight _generateNicheInsight(OnboardingSignals signals) {
    final niche = signals.userNiche;
    String insight;
    String detail;

    switch (niche) {
      case UserNiche.developer:
        insight = 'Developer patterns recognized';
        detail = 'We understand flow states and context switching costs. Focused support.';
        break;
      case UserNiche.writer:
        insight = 'Creative rhythm understood';
        detail = 'We\'ll respect your creative process and avoid interrupting flow.';
        break;
      case UserNiche.scholar:
        insight = 'Academic patterns detected';
        detail = 'Deadline-aware interventions. We know exam weeks hit different.';
        break;
      case UserNiche.linguist:
        insight = 'Language learning context set';
        detail = 'Consistency over intensity. Daily contact with the language matters most.';
        break;
      case UserNiche.maker:
        insight = 'Builder mindset recognized';
        detail = 'Progress visibility will be key. We\'ll celebrate shipped work.';
        break;
      default:
        insight = 'Profile initialized';
        detail = 'We\'ll learn your unique patterns over the coming days.';
    }

    return OnboardingInsight(
      category: SignalCategory.intent,
      label: 'Persona Match',
      insight: insight,
      detail: detail,
      confidence: 0.8,
      iconHint: 'person',
    );
  }

  // === HELPER METHODS ===

  String _categorizeTime(int hour) {
    if (hour >= 5 && hour < 12) return 'Morning';
    if (hour >= 12 && hour < 17) return 'Afternoon';
    if (hour >= 17 && hour < 21) return 'Evening';
    return 'Night';
  }

  int? _parseHour(String timeString) {
    // Handle formats like "22:00", "10:30 PM", "7am"
    try {
      final cleaned = timeString.toLowerCase().replaceAll(' ', '');
      if (cleaned.contains(':')) {
        final parts = cleaned.split(':');
        var hour = int.parse(parts[0]);
        if (cleaned.contains('pm') && hour < 12) hour += 12;
        if (cleaned.contains('am') && hour == 12) hour = 0;
        return hour;
      } else if (cleaned.contains('am') || cleaned.contains('pm')) {
        final numStr = cleaned.replaceAll(RegExp(r'[^0-9]'), '');
        var hour = int.parse(numStr);
        if (cleaned.contains('pm') && hour < 12) hour += 12;
        if (cleaned.contains('am') && hour == 12) hour = 0;
        return hour;
      }
    } catch (e) {
      // Parse failed
    }
    return null;
  }

  double _calculateCommitmentScore({
    required bool hasBigWhy,
    required bool hasWitnesses,
    required bool hasEnvironmentDesign,
    required bool completedSherlock,
    required int habitCount,
  }) {
    double score = 0.3; // Base score for signing up

    if (hasBigWhy) score += 0.2;
    if (hasWitnesses) score += 0.2;
    if (hasEnvironmentDesign) score += 0.15;
    if (completedSherlock) score += 0.1;

    // Penalize overcommitment (>3 habits is risky)
    if (habitCount > 3) score -= 0.1;
    if (habitCount > 5) score -= 0.1;

    return score.clamp(0.0, 1.0);
  }

  int _calculateInitialRiskBitmask({
    required bool isWeekend,
    required int signupHour,
    required bool isStreakRefugee,
    required String? failureArchetype,
  }) {
    int mask = 0;

    if (isWeekend) mask |= 1; // Weekend flag
    if (signupHour >= 20 || signupHour < 6) mask |= 4; // Evening/night flag
    if (signupHour >= 5 && signupHour < 9) mask |= 8; // Morning flag
    if (isStreakRefugee) mask |= 32; // Stress flag (burnout)

    // Archetype-specific risks
    if (failureArchetype != null) {
      switch (failureArchetype.toUpperCase()) {
        case 'PROCRASTINATOR':
          mask |= 4; // Evening risk
          break;
        case 'PEOPLE_PLEASER':
          mask |= 16; // Social risk
          break;
        case 'PERFECTIONIST':
          mask |= 32; // Stress risk
          break;
      }
    }

    return mask;
  }

  String _describeRiskLevel(int bitmask) {
    final flagCount = _countSetBits(bitmask);
    if (flagCount == 0) return 'Low';
    if (flagCount <= 2) return 'Moderate';
    if (flagCount <= 4) return 'Elevated';
    return 'High';
  }

  int _countSetBits(int n) {
    int count = 0;
    while (n > 0) {
      count += n & 1;
      n >>= 1;
    }
    return count;
  }
}
