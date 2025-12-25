/// Daily Metrics - Track daily wellness indicators for correlation analysis
/// 
/// This enables the app to identify "keystone habits" - habits that have
/// outsized positive effects on other areas of life. By tracking mood, energy,
/// sleep quality, and other metrics alongside habit completion, we can
/// discover powerful correlations.
/// 
/// Example insight: "On days you meditate, your average mood is 7.8 vs 5.2"
class DailyMetrics {
  final DateTime date;
  
  // ========== Core Wellness Metrics (1-10 scale) ==========
  
  /// Overall mood rating (1 = very low, 10 = excellent)
  final int? mood;
  
  /// Energy level (1 = exhausted, 10 = highly energized)
  final int? energy;
  
  /// Sleep quality from previous night (1 = terrible, 10 = excellent)
  final int? sleepQuality;
  
  /// Hours of sleep from previous night
  final double? sleepHours;
  
  /// Stress level (1 = very stressed, 10 = very calm)
  final int? stressLevel;
  
  /// Focus/productivity rating (1 = scattered, 10 = laser focused)
  final int? focusRating;
  
  // ========== Habit Completion Data ==========
  
  /// IDs of habits completed on this day
  final List<String> completedHabitIds;
  
  /// IDs of habits where user did minimum/2-min version
  final List<String> minimumVersionHabitIds;
  
  /// IDs of habits that were missed
  final List<String> missedHabitIds;
  
  // ========== Optional Extended Metrics ==========
  
  /// Exercise minutes
  final int? exerciseMinutes;
  
  /// Water intake (glasses or liters)
  final double? waterIntake;
  
  /// Screen time in minutes
  final int? screenTimeMinutes;
  
  /// Social interaction quality (1-10)
  final int? socialQuality;
  
  /// Gratitude/positivity rating (1-10)
  final int? gratitudeRating;
  
  // ========== Notes & Context ==========
  
  /// Free-form notes about the day
  final String? notes;
  
  /// Any special circumstances (sick, travel, holiday, etc.)
  final List<String> tags;
  
  /// When this metrics entry was created/updated
  final DateTime recordedAt;
  
  DailyMetrics({
    required this.date,
    this.mood,
    this.energy,
    this.sleepQuality,
    this.sleepHours,
    this.stressLevel,
    this.focusRating,
    this.completedHabitIds = const [],
    this.minimumVersionHabitIds = const [],
    this.missedHabitIds = const [],
    this.exerciseMinutes,
    this.waterIntake,
    this.screenTimeMinutes,
    this.socialQuality,
    this.gratitudeRating,
    this.notes,
    this.tags = const [],
    DateTime? recordedAt,
  }) : recordedAt = recordedAt ?? DateTime.now();
  
  /// Normalized date (midnight) for comparison
  DateTime get normalizedDate => DateTime(date.year, date.month, date.day);
  
  /// Total habits attempted (completed + missed)
  int get totalHabitsAttempted => 
      completedHabitIds.length + missedHabitIds.length;
  
  /// Completion rate for this day
  double get habitCompletionRate {
    if (totalHabitsAttempted == 0) return 0;
    return completedHabitIds.length / totalHabitsAttempted;
  }
  
  /// Overall wellness score (average of available metrics)
  double? get overallWellnessScore {
    final scores = <int>[];
    if (mood != null) scores.add(mood!);
    if (energy != null) scores.add(energy!);
    if (sleepQuality != null) scores.add(sleepQuality!);
    if (stressLevel != null) scores.add(stressLevel!);
    if (focusRating != null) scores.add(focusRating!);
    
    if (scores.isEmpty) return null;
    return scores.reduce((a, b) => a + b) / scores.length;
  }
  
  /// Whether this is a "good day" (wellness score >= 7)
  bool get isGoodDay => (overallWellnessScore ?? 0) >= 7;
  
  /// Whether this is a "tough day" (wellness score < 5)
  bool get isToughDay => (overallWellnessScore ?? 10) < 5;
  
  /// Check if a specific habit was completed
  bool wasHabitCompleted(String habitId) => 
      completedHabitIds.contains(habitId);
  
  /// Check if a specific habit was missed
  bool wasHabitMissed(String habitId) => 
      missedHabitIds.contains(habitId);
  
  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'mood': mood,
    'energy': energy,
    'sleepQuality': sleepQuality,
    'sleepHours': sleepHours,
    'stressLevel': stressLevel,
    'focusRating': focusRating,
    'completedHabitIds': completedHabitIds,
    'minimumVersionHabitIds': minimumVersionHabitIds,
    'missedHabitIds': missedHabitIds,
    'exerciseMinutes': exerciseMinutes,
    'waterIntake': waterIntake,
    'screenTimeMinutes': screenTimeMinutes,
    'socialQuality': socialQuality,
    'gratitudeRating': gratitudeRating,
    'notes': notes,
    'tags': tags,
    'recordedAt': recordedAt.toIso8601String(),
  };
  
  factory DailyMetrics.fromJson(Map<String, dynamic> json) => DailyMetrics(
    date: DateTime.parse(json['date'] as String),
    mood: json['mood'] as int?,
    energy: json['energy'] as int?,
    sleepQuality: json['sleepQuality'] as int?,
    sleepHours: (json['sleepHours'] as num?)?.toDouble(),
    stressLevel: json['stressLevel'] as int?,
    focusRating: json['focusRating'] as int?,
    completedHabitIds: (json['completedHabitIds'] as List?)
        ?.map((e) => e as String).toList() ?? [],
    minimumVersionHabitIds: (json['minimumVersionHabitIds'] as List?)
        ?.map((e) => e as String).toList() ?? [],
    missedHabitIds: (json['missedHabitIds'] as List?)
        ?.map((e) => e as String).toList() ?? [],
    exerciseMinutes: json['exerciseMinutes'] as int?,
    waterIntake: (json['waterIntake'] as num?)?.toDouble(),
    screenTimeMinutes: json['screenTimeMinutes'] as int?,
    socialQuality: json['socialQuality'] as int?,
    gratitudeRating: json['gratitudeRating'] as int?,
    notes: json['notes'] as String?,
    tags: (json['tags'] as List?)?.map((e) => e as String).toList() ?? [],
    recordedAt: json['recordedAt'] != null
        ? DateTime.parse(json['recordedAt'] as String)
        : null,
  );
  
  DailyMetrics copyWith({
    int? mood,
    int? energy,
    int? sleepQuality,
    double? sleepHours,
    int? stressLevel,
    int? focusRating,
    List<String>? completedHabitIds,
    List<String>? minimumVersionHabitIds,
    List<String>? missedHabitIds,
    int? exerciseMinutes,
    double? waterIntake,
    int? screenTimeMinutes,
    int? socialQuality,
    int? gratitudeRating,
    String? notes,
    List<String>? tags,
  }) => DailyMetrics(
    date: date,
    mood: mood ?? this.mood,
    energy: energy ?? this.energy,
    sleepQuality: sleepQuality ?? this.sleepQuality,
    sleepHours: sleepHours ?? this.sleepHours,
    stressLevel: stressLevel ?? this.stressLevel,
    focusRating: focusRating ?? this.focusRating,
    completedHabitIds: completedHabitIds ?? this.completedHabitIds,
    minimumVersionHabitIds: minimumVersionHabitIds ?? this.minimumVersionHabitIds,
    missedHabitIds: missedHabitIds ?? this.missedHabitIds,
    exerciseMinutes: exerciseMinutes ?? this.exerciseMinutes,
    waterIntake: waterIntake ?? this.waterIntake,
    screenTimeMinutes: screenTimeMinutes ?? this.screenTimeMinutes,
    socialQuality: socialQuality ?? this.socialQuality,
    gratitudeRating: gratitudeRating ?? this.gratitudeRating,
    notes: notes ?? this.notes,
    tags: tags ?? this.tags,
    recordedAt: DateTime.now(),
  );
  
  /// Create empty metrics for today
  factory DailyMetrics.today() => DailyMetrics(date: DateTime.now());
  
  /// Create empty metrics for a specific date
  factory DailyMetrics.forDate(DateTime date) => DailyMetrics(date: date);
}

/// Correlation between a habit and a metric
class HabitMetricCorrelation {
  final String habitId;
  final String habitName;
  final String metricName;
  
  /// Average metric value on days habit was completed
  final double avgWithHabit;
  
  /// Average metric value on days habit was not completed
  final double avgWithoutHabit;
  
  /// The difference (positive = habit helps)
  final double difference;
  
  /// Correlation coefficient (-1 to 1)
  final double correlationCoefficient;
  
  /// Number of data points used
  final int sampleSize;
  
  /// Statistical significance level
  final double significance;
  
  HabitMetricCorrelation({
    required this.habitId,
    required this.habitName,
    required this.metricName,
    required this.avgWithHabit,
    required this.avgWithoutHabit,
    required this.difference,
    required this.correlationCoefficient,
    required this.sampleSize,
    this.significance = 0,
  });
  
  /// Whether this correlation is statistically significant
  bool get isSignificant => significance < 0.05 && sampleSize >= 10;
  
  /// Whether this is a positive correlation
  bool get isPositive => difference > 0;
  
  /// Strength description
  String get strengthDescription {
    final absCoeff = correlationCoefficient.abs();
    if (absCoeff >= 0.7) return 'Strong';
    if (absCoeff >= 0.4) return 'Moderate';
    if (absCoeff >= 0.2) return 'Weak';
    return 'Very weak';
  }
  
  /// Human-readable insight
  String get insight {
    if (!isSignificant) {
      return 'Not enough data to determine relationship';
    }
    
    final direction = isPositive ? 'higher' : 'lower';
    return 'On days you complete "$habitName", your $metricName is ${difference.abs().toStringAsFixed(1)} points $direction (${avgWithHabit.toStringAsFixed(1)} vs ${avgWithoutHabit.toStringAsFixed(1)})';
  }
}

/// Weekly summary of metrics
class WeeklyMetricsSummary {
  final DateTime weekStartDate;
  final List<DailyMetrics> dailyMetrics;
  
  WeeklyMetricsSummary({
    required this.weekStartDate,
    required this.dailyMetrics,
  });
  
  /// Average mood for the week
  double? get avgMood => _average(dailyMetrics.map((m) => m.mood));
  
  /// Average energy for the week
  double? get avgEnergy => _average(dailyMetrics.map((m) => m.energy));
  
  /// Average sleep quality for the week
  double? get avgSleepQuality => _average(dailyMetrics.map((m) => m.sleepQuality));
  
  /// Total habits completed during the week
  int get totalHabitsCompleted => dailyMetrics.fold<int>(
    0, (sum, m) => sum + m.completedHabitIds.length
  );
  
  /// Average habit completion rate
  double get avgCompletionRate {
    final rates = dailyMetrics
        .where((m) => m.totalHabitsAttempted > 0)
        .map((m) => m.habitCompletionRate);
    return _average(rates) ?? 0;
  }
  
  /// Days with data recorded
  int get daysWithData => dailyMetrics.length;
  
  /// Good days count
  int get goodDaysCount => dailyMetrics.where((m) => m.isGoodDay).length;
  
  /// Tough days count  
  int get toughDaysCount => dailyMetrics.where((m) => m.isToughDay).length;
  
  double? _average(Iterable<num?> values) {
    final nonNull = values.where((v) => v != null).map((v) => v!.toDouble());
    if (nonNull.isEmpty) return null;
    return nonNull.reduce((a, b) => a + b) / nonNull.length;
  }
}
