/// Graceful Consistency Metrics
/// 
/// Replaces fragile streak mentality with a holistic consistency score
/// that rewards showing up, recovering from misses, and building sustainable habits.
/// 
/// Philosophy: "Graceful Consistency > Fragile Streaks"
/// - One miss is an accident
/// - Two misses is the start of a new habit
/// - Recovery is celebrated, not hidden
/// - Long-term averages matter more than perfect days
library;

/// Represents the urgency level for recovery prompts
enum RecoveryUrgency {
  /// Day 1 miss - gentle nudge, "never miss twice" framing
  gentle,
  
  /// Day 2 miss - more important, last chance before pattern forms
  important,
  
  /// Day 3+ miss - compassionate re-engagement, no shame
  compassionate,
}

/// Represents a single day's completion status
enum DayStatus {
  /// Habit was completed (full or minimum version)
  completed,
  
  /// Habit was skipped/missed
  missed,
  
  /// Day hasn't ended yet or no data
  pending,
  
  /// User explicitly paused the habit
  paused,
}

/// Tracks a recovery event (bouncing back after a miss)
class RecoveryEvent {
  final DateTime missDate;
  final DateTime recoveryDate;
  final int daysMissed;
  final String? missReason;
  final bool usedTinyVersion;
  
  RecoveryEvent({
    required this.missDate,
    required this.recoveryDate,
    required this.daysMissed,
    this.missReason,
    this.usedTinyVersion = false,
  });
  
  /// Was this a "quick recovery" (within 1 day)?
  bool get isQuickRecovery => daysMissed == 1;
  
  Map<String, dynamic> toJson() => {
    'missDate': missDate.toIso8601String(),
    'recoveryDate': recoveryDate.toIso8601String(),
    'daysMissed': daysMissed,
    'missReason': missReason,
    'usedTinyVersion': usedTinyVersion,
  };
  
  factory RecoveryEvent.fromJson(Map<String, dynamic> json) => RecoveryEvent(
    missDate: DateTime.parse(json['missDate'] as String),
    recoveryDate: DateTime.parse(json['recoveryDate'] as String),
    daysMissed: json['daysMissed'] as int,
    missReason: json['missReason'] as String?,
    usedTinyVersion: json['usedTinyVersion'] as bool? ?? false,
  );
}

/// Category for miss reasons (for pattern detection)
/// Phase 14: Pattern Detection - "The Safety Net"
enum MissReasonCategory {
  /// Time-related issues (wrong time, too busy)
  time('Time Issues', '⏰'),
  
  /// Energy-related issues (tired, sick, mood)
  energy('Energy Issues', '⚡'),
  
  /// Location-related issues (travel, environment)
  location('Location Issues', '📍'),
  
  /// Memory-related issues (forgot, not reminded)
  forgetfulness('Forgetfulness', '🧠'),
  
  /// Unexpected disruptions (emergency, social)
  unexpected('Unexpected Events', '🔀');
  
  final String label;
  final String emoji;
  const MissReasonCategory(this.label, this.emoji);
}

/// Common reasons for missing a habit (for pattern tracking)
/// Phase 14: Enhanced with categories for pattern detection
enum MissReason {
  // Time category
  busy('Too busy', '😰', MissReasonCategory.time),
  wrongTime('Wrong time of day', '🕐', MissReasonCategory.time),
  noTime('Couldn\'t find time', '⏳', MissReasonCategory.time),
  
  // Energy category
  tired('Low energy', '😴', MissReasonCategory.energy),
  sick('Feeling unwell', '🤒', MissReasonCategory.energy),
  mood('Not in the mood', '😔', MissReasonCategory.energy),
  stressed('Too stressed', '😫', MissReasonCategory.energy),
  
  // Location category
  travel('Traveling', '✈️', MissReasonCategory.location),
  wrongPlace('Wrong location', '📍', MissReasonCategory.location),
  noEquipment('Missing equipment', '🎒', MissReasonCategory.location),
  
  // Forgetfulness category
  forgot('Simply forgot', '🤔', MissReasonCategory.forgetfulness),
  noReminder('No reminder', '🔔', MissReasonCategory.forgetfulness),
  distracted('Got distracted', '🌀', MissReasonCategory.forgetfulness),
  
  // Unexpected category
  disruption('Routine disrupted', '🔀', MissReasonCategory.unexpected),
  social('Social commitments', '👥', MissReasonCategory.unexpected),
  emergency('Emergency/Urgent', '🚨', MissReasonCategory.unexpected),
  other('Other', '📝', MissReasonCategory.unexpected);
  
  final String label;
  final String emoji;
  final MissReasonCategory category;
  const MissReason(this.label, this.emoji, this.category);
  
  /// Full display string with emoji
  String get display => '$emoji $label';
  
  static MissReason? fromString(String? value) {
    if (value == null) return null;
    return MissReason.values.cast<MissReason?>().firstWhere(
      (e) => e?.name == value,
      orElse: () => null,
    );
  }
  
  /// Get all reasons in a specific category
  static List<MissReason> inCategory(MissReasonCategory category) {
    return MissReason.values.where((r) => r.category == category).toList();
  }
}

/// Comprehensive consistency metrics for a habit
/// 
/// This replaces the simple "currentStreak" with a multi-dimensional
/// view of habit consistency that aligns with Graceful Consistency philosophy.
class ConsistencyMetrics {
  /// Overall graceful consistency score (0-100)
  /// This is the primary metric shown to users
  final double gracefulScore;
  
  /// Number of days the user "showed up" (completed habit) in current period
  final int daysShowedUp;
  
  /// Total days in the current tracking period
  final int totalDays;
  
  /// Rolling 7-day completion percentage (0.0-1.0)
  final double weeklyAverage;
  
  /// Rolling 30-day completion percentage (0.0-1.0)
  final double monthlyAverage;
  
  /// Number of times user bounced back after a miss
  final int recoveryCount;
  
  /// Number of "quick recoveries" (bounced back within 1 day)
  final int quickRecoveryCount;
  
  /// Historical best streak (for reference, de-emphasized)
  final int longestStreak;
  
  /// Current consecutive days (de-emphasized in UI)
  final int currentStreak;
  
  /// Total completions since habit creation
  final int totalCompletions;
  
  /// Total "identity votes" cast (each completion = 1 vote)
  final int identityVotes;
  
  /// "Never Miss Twice" success rate (0.0-1.0)
  /// Percentage of single misses that didn't become 2+ misses
  final double neverMissTwiceRate;
  
  /// Current consecutive misses (for recovery prompts)
  final int currentMissStreak;
  
  /// Recent recovery events (last 30 days)
  final List<RecoveryEvent> recentRecoveries;
  
  /// Score change from previous period (+/- value)
  final double scoreChange;
  
  ConsistencyMetrics({
    required this.gracefulScore,
    required this.daysShowedUp,
    required this.totalDays,
    required this.weeklyAverage,
    required this.monthlyAverage,
    required this.recoveryCount,
    required this.quickRecoveryCount,
    required this.longestStreak,
    required this.currentStreak,
    required this.totalCompletions,
    required this.identityVotes,
    required this.neverMissTwiceRate,
    required this.currentMissStreak,
    this.recentRecoveries = const [],
    this.scoreChange = 0.0,
  });
  
  /// Show-up rate for the tracking period
  double get showUpRate => totalDays > 0 ? daysShowedUp / totalDays : 0;
  
  /// Whether user is currently in a "miss streak" (needs recovery)
  bool get needsRecovery => currentMissStreak > 0;
  
  /// Recovery urgency level based on consecutive misses
  RecoveryUrgency get recoveryUrgency {
    if (currentMissStreak <= 1) return RecoveryUrgency.gentle;
    if (currentMissStreak == 2) return RecoveryUrgency.important;
    return RecoveryUrgency.compassionate;
  }
  
  /// Human-readable description of the graceful score
  String get scoreDescription {
    if (gracefulScore >= 90) return 'Excellent consistency!';
    if (gracefulScore >= 75) return 'Strong consistency';
    if (gracefulScore >= 60) return 'Good progress';
    if (gracefulScore >= 40) return 'Building momentum';
    if (gracefulScore >= 20) return 'Getting started';
    return 'Every day is a fresh start';
  }
  
  /// Emoji representation of score level
  String get scoreEmoji {
    if (gracefulScore >= 90) return '🌟';
    if (gracefulScore >= 75) return '💪';
    if (gracefulScore >= 60) return '👍';
    if (gracefulScore >= 40) return '🌱';
    if (gracefulScore >= 20) return '🚀';
    return '✨';
  }
  
  /// Creates empty/initial metrics
  factory ConsistencyMetrics.empty() => ConsistencyMetrics(
    gracefulScore: 0,
    daysShowedUp: 0,
    totalDays: 0,
    weeklyAverage: 0,
    monthlyAverage: 0,
    recoveryCount: 0,
    quickRecoveryCount: 0,
    longestStreak: 0,
    currentStreak: 0,
    totalCompletions: 0,
    identityVotes: 0,
    neverMissTwiceRate: 1.0, // Start optimistic
    currentMissStreak: 0,
    recentRecoveries: [],
    scoreChange: 0,
  );
  
  /// Calculate graceful consistency score from component metrics
  /// 
  /// Formula breakdown:
  /// - Base (40%): 7-day rolling average - rewards recent consistency
  /// - Recovery Bonus (20%): Quick recoveries - rewards bouncing back
  /// - Stability Bonus (20%): Low variance in completion - rewards reliability
  /// - Never Miss Twice Bonus (20%): Single misses staying single - rewards the core philosophy
  static double calculateGracefulScore({
    required double sevenDayAverage,
    required int quickRecoveries,
    required double completionTimeVariance,
    required double neverMissTwiceRate,
  }) {
    // Base: 7-day average (40% weight)
    final baseScore = sevenDayAverage * 100 * 0.4;
    
    // Recovery bonus: Each quick recovery adds up to 5 points, max 20 points (20% weight)
    final recoveryBonus = (quickRecoveries * 5).clamp(0, 20).toDouble();
    
    // Stability bonus: Lower variance = higher bonus (20% weight)
    // Variance of 0 = 20 points, variance of 1 = 0 points
    final stabilityBonus = (1 - completionTimeVariance.clamp(0, 1)) * 20;
    
    // Never Miss Twice bonus: Rate * 20 (20% weight)
    final neverMissTwiceBonus = neverMissTwiceRate * 20;
    
    return (baseScore + recoveryBonus + stabilityBonus + neverMissTwiceBonus)
        .clamp(0, 100);
  }
  
  /// Calculate metrics from a list of completion dates
  factory ConsistencyMetrics.fromCompletionHistory({
    required List<DateTime> completionDates,
    required DateTime habitCreatedAt,
    required List<RecoveryEvent> recoveryEvents,
    int? previousWeekCompletions,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final habitStart = DateTime(
      habitCreatedAt.year, 
      habitCreatedAt.month, 
      habitCreatedAt.day,
    );
    
    // Normalize completion dates to day-only
    final completions = completionDates.map((d) => 
      DateTime(d.year, d.month, d.day)
    ).toSet();
    
    // Calculate total days since habit creation
    final totalDays = today.difference(habitStart).inDays + 1;
    final daysShowedUp = completions.length;
    
    // Calculate 7-day average
    int weeklyCompletions = 0;
    for (int i = 0; i < 7; i++) {
      final checkDate = today.subtract(Duration(days: i));
      if (completions.contains(checkDate)) weeklyCompletions++;
    }
    final weeklyAverage = weeklyCompletions / 7;
    
    // Calculate 30-day average
    int monthlyCompletions = 0;
    for (int i = 0; i < 30; i++) {
      final checkDate = today.subtract(Duration(days: i));
      if (completions.contains(checkDate)) monthlyCompletions++;
    }
    final monthlyAverage = monthlyCompletions / 30;
    
    // Calculate current streak
    int currentStreak = 0;
    var checkDate = today;
    while (completions.contains(checkDate)) {
      currentStreak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    
    // Calculate longest streak
    int longestStreak = 0;
    int tempStreak = 0;
    final sortedCompletions = completions.toList()..sort();
    DateTime? prevDate;
    for (final date in sortedCompletions) {
      if (prevDate != null && 
          date.difference(prevDate).inDays == 1) {
        tempStreak++;
      } else {
        tempStreak = 1;
      }
      if (tempStreak > longestStreak) longestStreak = tempStreak;
      prevDate = date;
    }
    
    // Calculate current miss streak
    int currentMissStreak = 0;
    if (!completions.contains(today)) {
      currentMissStreak = 1;
      checkDate = today.subtract(const Duration(days: 1));
      while (!completions.contains(checkDate) && 
             checkDate.isAfter(habitStart.subtract(const Duration(days: 1)))) {
        currentMissStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
    }
    
    // Calculate never-miss-twice rate
    // Count single misses vs multi-day misses
    int singleMisses = 0;
    int multiDayMisses = 0;
    int missStreak = 0;
    
    for (int i = 0; i < totalDays; i++) {
      checkDate = habitStart.add(Duration(days: i));
      if (!completions.contains(checkDate)) {
        missStreak++;
      } else {
        if (missStreak == 1) {
          singleMisses++;
        } else if (missStreak > 1) multiDayMisses++;
        missStreak = 0;
      }
    }
    // Handle trailing miss streak
    if (missStreak == 1) {
      singleMisses++;
    } else if (missStreak > 1) multiDayMisses++;
    
    final totalMissEvents = singleMisses + multiDayMisses;
    final neverMissTwiceRate = totalMissEvents > 0 
        ? singleMisses / totalMissEvents 
        : 1.0;
    
    // Recovery metrics
    final recentRecoveries = recoveryEvents.where((r) => 
      r.recoveryDate.isAfter(today.subtract(const Duration(days: 30)))
    ).toList();
    final recoveryCount = recentRecoveries.length;
    final quickRecoveryCount = recentRecoveries.where((r) => r.isQuickRecovery).length;
    
    // Calculate completion time variance (placeholder - would need time data)
    // For now, use a proxy based on weekly consistency
    final completionTimeVariance = 1 - weeklyAverage;
    
    // Calculate graceful score
    final gracefulScore = calculateGracefulScore(
      sevenDayAverage: weeklyAverage,
      quickRecoveries: quickRecoveryCount,
      completionTimeVariance: completionTimeVariance,
      neverMissTwiceRate: neverMissTwiceRate,
    );
    
    // Calculate score change (if previous data available)
    double scoreChange = 0;
    if (previousWeekCompletions != null) {
      final previousWeeklyAvg = previousWeekCompletions / 7;
      final previousScore = calculateGracefulScore(
        sevenDayAverage: previousWeeklyAvg,
        quickRecoveries: quickRecoveryCount > 0 ? quickRecoveryCount - 1 : 0,
        completionTimeVariance: 1 - previousWeeklyAvg,
        neverMissTwiceRate: neverMissTwiceRate,
      );
      scoreChange = gracefulScore - previousScore;
    }
    
    return ConsistencyMetrics(
      gracefulScore: gracefulScore,
      daysShowedUp: daysShowedUp,
      totalDays: totalDays,
      weeklyAverage: weeklyAverage,
      monthlyAverage: monthlyAverage,
      recoveryCount: recoveryCount,
      quickRecoveryCount: quickRecoveryCount,
      longestStreak: longestStreak,
      currentStreak: currentStreak,
      totalCompletions: daysShowedUp,
      identityVotes: daysShowedUp, // Each completion = 1 identity vote
      neverMissTwiceRate: neverMissTwiceRate,
      currentMissStreak: currentMissStreak,
      recentRecoveries: recentRecoveries,
      scoreChange: scoreChange,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'gracefulScore': gracefulScore,
    'daysShowedUp': daysShowedUp,
    'totalDays': totalDays,
    'weeklyAverage': weeklyAverage,
    'monthlyAverage': monthlyAverage,
    'recoveryCount': recoveryCount,
    'quickRecoveryCount': quickRecoveryCount,
    'longestStreak': longestStreak,
    'currentStreak': currentStreak,
    'totalCompletions': totalCompletions,
    'identityVotes': identityVotes,
    'neverMissTwiceRate': neverMissTwiceRate,
    'currentMissStreak': currentMissStreak,
    'recentRecoveries': recentRecoveries.map((r) => r.toJson()).toList(),
    'scoreChange': scoreChange,
  };
  
  factory ConsistencyMetrics.fromJson(Map<String, dynamic> json) {
    return ConsistencyMetrics(
      gracefulScore: (json['gracefulScore'] as num?)?.toDouble() ?? 0,
      daysShowedUp: json['daysShowedUp'] as int? ?? 0,
      totalDays: json['totalDays'] as int? ?? 0,
      weeklyAverage: (json['weeklyAverage'] as num?)?.toDouble() ?? 0,
      monthlyAverage: (json['monthlyAverage'] as num?)?.toDouble() ?? 0,
      recoveryCount: json['recoveryCount'] as int? ?? 0,
      quickRecoveryCount: json['quickRecoveryCount'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      totalCompletions: json['totalCompletions'] as int? ?? 0,
      identityVotes: json['identityVotes'] as int? ?? 0,
      neverMissTwiceRate: (json['neverMissTwiceRate'] as num?)?.toDouble() ?? 1.0,
      currentMissStreak: json['currentMissStreak'] as int? ?? 0,
      recentRecoveries: (json['recentRecoveries'] as List?)
          ?.map((r) => RecoveryEvent.fromJson(r as Map<String, dynamic>))
          .toList() ?? [],
      scoreChange: (json['scoreChange'] as num?)?.toDouble() ?? 0,
    );
  }
  
  ConsistencyMetrics copyWith({
    double? gracefulScore,
    int? daysShowedUp,
    int? totalDays,
    double? weeklyAverage,
    double? monthlyAverage,
    int? recoveryCount,
    int? quickRecoveryCount,
    int? longestStreak,
    int? currentStreak,
    int? totalCompletions,
    int? identityVotes,
    double? neverMissTwiceRate,
    int? currentMissStreak,
    List<RecoveryEvent>? recentRecoveries,
    double? scoreChange,
  }) {
    return ConsistencyMetrics(
      gracefulScore: gracefulScore ?? this.gracefulScore,
      daysShowedUp: daysShowedUp ?? this.daysShowedUp,
      totalDays: totalDays ?? this.totalDays,
      weeklyAverage: weeklyAverage ?? this.weeklyAverage,
      monthlyAverage: monthlyAverage ?? this.monthlyAverage,
      recoveryCount: recoveryCount ?? this.recoveryCount,
      quickRecoveryCount: quickRecoveryCount ?? this.quickRecoveryCount,
      longestStreak: longestStreak ?? this.longestStreak,
      currentStreak: currentStreak ?? this.currentStreak,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      identityVotes: identityVotes ?? this.identityVotes,
      neverMissTwiceRate: neverMissTwiceRate ?? this.neverMissTwiceRate,
      currentMissStreak: currentMissStreak ?? this.currentMissStreak,
      recentRecoveries: recentRecoveries ?? this.recentRecoveries,
      scoreChange: scoreChange ?? this.scoreChange,
    );
  }
}
