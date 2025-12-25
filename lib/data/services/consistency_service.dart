import '../models/habit.dart';
import '../models/consistency_metrics.dart';
import '../../utils/date_utils.dart';

/// ConsistencyService - Core service for Graceful Consistency scoring
/// 
/// This service encapsulates all the logic for calculating and analyzing
/// habit consistency. It implements the "Graceful Consistency > Fragile Streaks"
/// philosophy throughout.
/// 
/// Key responsibilities:
/// 1. Calculate graceful consistency scores
/// 2. Compute rolling averages (7-day, 30-day, custom)
/// 3. Determine "Never Miss Twice" triggers
/// 4. Analyze recovery patterns
/// 5. Track identity votes and show-up rates
class ConsistencyService {
  ConsistencyService._(); // Private constructor - use static methods
  
  // ========== Score Calculation ==========
  
  /// Calculate the Graceful Consistency Score (0-100) for a habit
  /// 
  /// Formula:
  /// - Base (40%): 7-day rolling average
  /// - Recovery Bonus (20%): Quick recovery count
  /// - Stability Bonus (20%): Consistency of completion times
  /// - Never Miss Twice Bonus (20%): Single-miss recovery rate
  static double calculateGracefulConsistencyScore(Habit habit) {
    final metrics = habit.consistencyMetrics;
    return metrics.gracefulScore;
  }
  
  /// Calculate graceful score from raw components (for custom calculations)
  static double calculateGracefulScoreFromComponents({
    required double sevenDayAverage,
    required int quickRecoveryCount,
    required double completionTimeVariance,
    required double neverMissTwiceRate,
  }) {
    return ConsistencyMetrics.calculateGracefulScore(
      sevenDayAverage: sevenDayAverage,
      quickRecoveries: quickRecoveryCount,
      completionTimeVariance: completionTimeVariance,
      neverMissTwiceRate: neverMissTwiceRate,
    );
  }
  
  // ========== Rolling Averages ==========
  
  /// Get rolling average adherence for a habit over specified weeks
  static double getRollingAverageAdherence(Habit habit, int weeks) {
    final days = weeks * 7;
    final today = HabitDateUtils.startOfToday();
    
    // Normalize completion dates
    final completions = habit.completionHistory
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();
    
    int completedDays = 0;
    int totalDays = 0;
    
    for (int i = 0; i < days; i++) {
      final checkDate = today.subtract(Duration(days: i));
      
      // Don't count days before habit creation
      if (checkDate.isBefore(habit.createdAt)) continue;
      
      totalDays++;
      if (completions.contains(checkDate)) {
        completedDays++;
      }
    }
    
    if (totalDays == 0) return 0;
    return completedDays / totalDays;
  }
  
  /// Get 7-day rolling average
  static double get7DayAverage(Habit habit) => 
      getRollingAverageAdherence(habit, 1);
  
  /// Get 30-day (4-week) rolling average
  static double get30DayAverage(Habit habit) => 
      getRollingAverageAdherence(habit, 4);
  
  /// Get 90-day (12-week) rolling average
  static double get90DayAverage(Habit habit) => 
      getRollingAverageAdherence(habit, 12);
  
  // ========== Never Miss Twice Logic ==========
  
  /// Determine if "Never Miss Twice" prompt should be triggered
  static bool shouldTriggerNeverMissTwice(Habit habit) {
    // Don't trigger if completed today
    if (habit.isCompletedToday) return false;
    
    // Don't trigger if paused
    if (habit.isPaused) return false;
    
    // Don't trigger for new habits (created today)
    final habitCreatedToday = HabitDateUtils.isToday(habit.createdAt);
    if (habitCreatedToday) return false;
    
    // Trigger if there's a current miss streak
    return habit.currentMissStreak >= 1;
  }
  
  /// Get the urgency level for the "Never Miss Twice" prompt
  static RecoveryUrgency getNeverMissTwiceUrgency(Habit habit) {
    final missStreak = habit.currentMissStreak;
    
    if (missStreak <= 1) return RecoveryUrgency.gentle;
    if (missStreak == 2) return RecoveryUrgency.important;
    return RecoveryUrgency.compassionate;
  }
  
  /// Calculate "Never Miss Twice" success rate
  static double calculateNeverMissTwiceRate(Habit habit) {
    final completions = habit.completionHistory
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();
    
    final habitStart = DateTime(
      habit.createdAt.year,
      habit.createdAt.month,
      habit.createdAt.day,
    );
    
    final today = HabitDateUtils.startOfToday();
    final totalDays = today.difference(habitStart).inDays + 1;
    
    if (totalDays <= 1) return 1.0;
    
    int singleMisses = 0;
    int multiDayMisses = 0;
    int currentMissStreak = 0;
    
    for (int i = 0; i < totalDays; i++) {
      final checkDate = habitStart.add(Duration(days: i));
      
      if (!completions.contains(checkDate)) {
        currentMissStreak++;
      } else {
        if (currentMissStreak == 1) {
          singleMisses++;
        } else if (currentMissStreak > 1) multiDayMisses++;
        currentMissStreak = 0;
      }
    }
    
    // Handle trailing miss streak
    if (currentMissStreak == 1) {
      singleMisses++;
    } else if (currentMissStreak > 1) multiDayMisses++;
    
    final totalMissEvents = singleMisses + multiDayMisses;
    if (totalMissEvents == 0) return 1.0;
    
    return singleMisses / totalMissEvents;
  }
  
  // ========== Show-Up Analysis ==========
  
  /// Calculate total "days showed up" (completed any version)
  static int calculateDaysShowedUp(Habit habit) {
    return habit.completionHistory
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .length;
  }
  
  /// Calculate show-up rate (days showed up / total possible days)
  static double calculateShowUpRate(Habit habit) {
    final totalDays = DateTime.now().difference(habit.createdAt).inDays + 1;
    if (totalDays <= 0) return 0;
    
    final daysShowedUp = calculateDaysShowedUp(habit);
    return daysShowedUp / totalDays;
  }
  
  /// Calculate identity votes (cumulative completions)
  static int calculateIdentityVotes(Habit habit) {
    return calculateDaysShowedUp(habit);
  }
  
  // ========== Recovery Analysis ==========
  
  /// Count quick recoveries (recovered within 1 day of miss)
  static int countQuickRecoveries(Habit habit) {
    return habit.recoveryHistory
        .where((r) => r.isQuickRecovery)
        .length;
  }
  
  /// Count total recoveries
  static int countTotalRecoveries(Habit habit) {
    return habit.recoveryHistory.length;
  }
  
  /// Get average recovery time in days
  static double getAverageRecoveryTime(Habit habit) {
    if (habit.recoveryHistory.isEmpty) return 0;
    
    final totalDays = habit.recoveryHistory
        .fold<int>(0, (sum, r) => sum + r.daysMissed);
    
    return totalDays / habit.recoveryHistory.length;
  }
  
  /// Analyze recovery patterns by miss reason
  static Map<String, RecoveryPattern> analyzeRecoveryPatterns(Habit habit) {
    final patterns = <String, RecoveryPattern>{};
    
    for (final recovery in habit.recoveryHistory) {
      final reason = recovery.missReason ?? 'unknown';
      
      if (!patterns.containsKey(reason)) {
        patterns[reason] = RecoveryPattern(reason: reason);
      }
      
      patterns[reason] = patterns[reason]!.addRecovery(recovery);
    }
    
    return patterns;
  }
  
  // ========== Streak Analysis (De-emphasized) ==========
  
  /// Calculate current streak (for reference, not primary metric)
  static int calculateCurrentStreak(Habit habit) {
    final completions = habit.completionHistory
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();
    
    final today = HabitDateUtils.startOfToday();
    int streak = 0;
    var checkDate = today;
    
    while (completions.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    
    return streak;
  }
  
  /// Calculate longest streak ever (historical best)
  static int calculateLongestStreak(Habit habit) {
    final completions = habit.completionHistory
        .map((d) => DateTime(d.year, d.month, d.day))
        .toList()
      ..sort();
    
    if (completions.isEmpty) return 0;
    
    int longestStreak = 1;
    int currentStreak = 1;
    
    for (int i = 1; i < completions.length; i++) {
      final diff = completions[i].difference(completions[i - 1]).inDays;
      
      if (diff == 1) {
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else {
        currentStreak = 1;
      }
    }
    
    return longestStreak;
  }
  
  // ========== Progress Analysis ==========
  
  /// Get completion data for a specific period
  static PeriodCompletionData getCompletionDataForPeriod(
    Habit habit,
    DateTime startDate,
    DateTime endDate,
  ) {
    final completions = habit.completionHistory
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();
    
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    
    int totalDays = 0;
    int completedDays = 0;
    int minimumVersionDays = 0;
    
    var current = start;
    while (!current.isAfter(end)) {
      // Skip days before habit creation
      if (!current.isBefore(habit.createdAt)) {
        totalDays++;
        if (completions.contains(current)) {
          completedDays++;
        }
      }
      current = current.add(const Duration(days: 1));
    }
    
    return PeriodCompletionData(
      startDate: startDate,
      endDate: endDate,
      totalDays: totalDays,
      completedDays: completedDays,
      minimumVersionDays: minimumVersionDays,
    );
  }
  
  /// Get this week's completion data
  static PeriodCompletionData getThisWeekData(Habit habit) {
    final now = DateTime.now();
    final weekStart = HabitDateUtils.startOfWeek();
    return getCompletionDataForPeriod(habit, weekStart, now);
  }
  
  /// Get last week's completion data
  static PeriodCompletionData getLastWeekData(Habit habit) {
    final weekStart = HabitDateUtils.startOfWeek();
    final lastWeekStart = weekStart.subtract(const Duration(days: 7));
    final lastWeekEnd = weekStart.subtract(const Duration(days: 1));
    return getCompletionDataForPeriod(habit, lastWeekStart, lastWeekEnd);
  }
  
  /// Compare this week to last week
  static WeekOverWeekComparison compareWeekOverWeek(Habit habit) {
    final thisWeek = getThisWeekData(habit);
    final lastWeek = getLastWeekData(habit);
    
    return WeekOverWeekComparison(
      thisWeek: thisWeek,
      lastWeek: lastWeek,
    );
  }
  
  // ========== Consistency Insights ==========
  
  /// Get personalized consistency insights
  static List<ConsistencyInsight> getConsistencyInsights(Habit habit) {
    final insights = <ConsistencyInsight>[];
    final metrics = habit.consistencyMetrics;
    
    // Streak insight (de-emphasized but still interesting)
    if (habit.currentStreak >= 7) {
      insights.add(ConsistencyInsight(
        type: InsightType.positive,
        title: 'Week-long momentum!',
        message: "You've shown up ${habit.currentStreak} days in a row. Keep it going!",
        priority: 2,
      ));
    }
    
    // Recovery excellence
    if (habit.singleMissRecoveries >= 3) {
      insights.add(ConsistencyInsight(
        type: InsightType.positive,
        title: 'Recovery champion',
        message: "You've bounced back ${habit.singleMissRecoveries} times. That resilience is your superpower.",
        priority: 1,
      ));
    }
    
    // Never miss twice success
    if (metrics.neverMissTwiceRate >= 0.8 && habit.recoveryHistory.isNotEmpty) {
      insights.add(ConsistencyInsight(
        type: InsightType.positive,
        title: '"Never Miss Twice" master',
        message: '${(metrics.neverMissTwiceRate * 100).round()}% of your misses stayed single misses. That\'s the real habit!',
        priority: 1,
      ));
    }
    
    // Identity votes milestone
    if (habit.identityVotes >= 50) {
      insights.add(ConsistencyInsight(
        type: InsightType.milestone,
        title: '${habit.identityVotes} identity votes cast',
        message: 'Every completion is a vote for who you\'re becoming.',
        priority: 2,
      ));
    }
    
    // Show-up rate insight
    final showUpRate = habit.showUpRate;
    if (showUpRate >= 0.7) {
      insights.add(ConsistencyInsight(
        type: InsightType.positive,
        title: '${(showUpRate * 100).round()}% show-up rate',
        message: 'You show up more often than not. That\'s consistency.',
        priority: 2,
      ));
    } else if (showUpRate < 0.4 && habit.daysShowedUp >= 7) {
      insights.add(ConsistencyInsight(
        type: InsightType.suggestion,
        title: 'Make it easier',
        message: 'Consider making your habit even smaller. What\'s a 1-minute version?',
        priority: 1,
      ));
    }
    
    // Recovery needed
    if (shouldTriggerNeverMissTwice(habit)) {
      final urgency = getNeverMissTwiceUrgency(habit);
      insights.add(ConsistencyInsight(
        type: InsightType.action,
        title: urgency == RecoveryUrgency.gentle 
            ? 'Never miss twice'
            : urgency == RecoveryUrgency.important
                ? 'Day 2 - critical moment'
                : 'Welcome back',
        message: 'Just do the 2-minute version: "${habit.tinyVersion}"',
        priority: 0,
      ));
    }
    
    // Sort by priority
    insights.sort((a, b) => a.priority.compareTo(b.priority));
    
    return insights;
  }
}

/// Recovery pattern analysis for a specific miss reason
class RecoveryPattern {
  final String reason;
  final int totalOccurrences;
  final int quickRecoveries;
  final int totalDaysMissed;
  
  RecoveryPattern({
    required this.reason,
    this.totalOccurrences = 0,
    this.quickRecoveries = 0,
    this.totalDaysMissed = 0,
  });
  
  double get quickRecoveryRate => 
      totalOccurrences > 0 ? quickRecoveries / totalOccurrences : 0;
  
  double get averageDaysMissed =>
      totalOccurrences > 0 ? totalDaysMissed / totalOccurrences : 0;
  
  RecoveryPattern addRecovery(RecoveryEvent recovery) {
    return RecoveryPattern(
      reason: reason,
      totalOccurrences: totalOccurrences + 1,
      quickRecoveries: quickRecoveries + (recovery.isQuickRecovery ? 1 : 0),
      totalDaysMissed: totalDaysMissed + recovery.daysMissed,
    );
  }
}

/// Completion data for a specific time period
class PeriodCompletionData {
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final int completedDays;
  final int minimumVersionDays;
  
  PeriodCompletionData({
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.completedDays,
    this.minimumVersionDays = 0,
  });
  
  double get completionRate => totalDays > 0 ? completedDays / totalDays : 0;
  
  int get missedDays => totalDays - completedDays;
}

/// Week-over-week comparison data
class WeekOverWeekComparison {
  final PeriodCompletionData thisWeek;
  final PeriodCompletionData lastWeek;
  
  WeekOverWeekComparison({
    required this.thisWeek,
    required this.lastWeek,
  });
  
  double get rateChange => thisWeek.completionRate - lastWeek.completionRate;
  
  bool get isImproving => rateChange > 0;
  
  String get comparisonDescription {
    final changePercent = (rateChange * 100).abs().round();
    if (rateChange > 0.1) return '$changePercent% better than last week';
    if (rateChange < -0.1) return '$changePercent% below last week';
    return 'Consistent with last week';
  }
}

/// Types of consistency insights
enum InsightType {
  positive,    // Good news
  milestone,   // Achievement unlocked
  suggestion,  // Improvement suggestion
  action,      // Immediate action needed
}

/// A single consistency insight
class ConsistencyInsight {
  final InsightType type;
  final String title;
  final String message;
  final int priority; // 0 = highest priority
  
  ConsistencyInsight({
    required this.type,
    required this.title,
    required this.message,
    required this.priority,
  });
}
