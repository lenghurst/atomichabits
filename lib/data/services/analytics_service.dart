import '../models/habit.dart';

/// Phase 10: Analytics Dashboard Service
/// 
/// Provides historical data computation for visualizing Graceful Consistency
/// over time. The key insight: missed days should look like small dips,
/// not catastrophic cliffs.
/// 
/// Core Philosophy:
/// "Graceful Consistency > Fragile Streaks"
/// - The chart should visually demonstrate resilience
/// - Recovery events are celebrated, not hidden
/// - Long-term trends matter more than single points

/// A single data point for charts
class AnalyticsDataPoint {
  final DateTime date;
  final double gracefulScore;
  final bool wasCompleted;
  final bool wasRecovery;
  final int dayIndex; // Days since habit creation
  
  AnalyticsDataPoint({
    required this.date,
    required this.gracefulScore,
    required this.wasCompleted,
    required this.wasRecovery,
    required this.dayIndex,
  });
}

/// Summary statistics for a time period
class PeriodSummary {
  final int totalDays;
  final int completedDays;
  final int missedDays;
  final int recoveryDays;
  final double averageScore;
  final double startScore;
  final double endScore;
  final double scoreChange;
  final double completionRate;
  final int longestStreak;
  final int currentStreak;
  
  PeriodSummary({
    required this.totalDays,
    required this.completedDays,
    required this.missedDays,
    required this.recoveryDays,
    required this.averageScore,
    required this.startScore,
    required this.endScore,
    required this.scoreChange,
    required this.completionRate,
    required this.longestStreak,
    required this.currentStreak,
  });
  
  /// Description of the trend
  String get trendDescription {
    if (scoreChange > 10) return 'Strong upward trend';
    if (scoreChange > 5) return 'Improving';
    if (scoreChange > -5) return 'Stable';
    if (scoreChange > -10) return 'Slight decline';
    return 'Needs attention';
  }
  
  /// Emoji for the trend
  String get trendEmoji {
    if (scoreChange > 10) return '🚀';
    if (scoreChange > 5) return '📈';
    if (scoreChange > -5) return '➡️';
    if (scoreChange > -10) return '📉';
    return '💪';
  }
}

/// Time period options for analytics
enum AnalyticsPeriod {
  week7('7 Days', 7),
  week14('14 Days', 14),
  month30('30 Days', 30),
  month90('90 Days', 90),
  all('All Time', -1);
  
  final String label;
  final int days;
  const AnalyticsPeriod(this.label, this.days);
}

/// Service for computing analytics data
class AnalyticsService {
  
  /// Generate historical Graceful Consistency scores for charting
  /// 
  /// This computes what the score WOULD HAVE BEEN on each day,
  /// using a rolling 7-day window. This creates a smooth line
  /// where misses are dips, not cliffs.
  List<AnalyticsDataPoint> generateScoreHistory({
    required Habit habit,
    required AnalyticsPeriod period,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final habitStart = DateTime(
      habit.createdAt.year,
      habit.createdAt.month,
      habit.createdAt.day,
    );
    
    // Normalize completion dates
    final completions = habit.completionHistory.map((d) => 
      DateTime(d.year, d.month, d.day)
    ).toSet();
    
    // Determine the period to analyze
    final totalDaysSinceStart = today.difference(habitStart).inDays + 1;
    final daysToAnalyze = period.days < 0 
        ? totalDaysSinceStart 
        : period.days.clamp(1, totalDaysSinceStart);
    
    final startDate = today.subtract(Duration(days: daysToAnalyze - 1));
    
    // Recovery dates for highlighting
    final recoveryDates = habit.recoveryHistory.map((r) => 
      DateTime(r.recoveryDate.year, r.recoveryDate.month, r.recoveryDate.day)
    ).toSet();
    
    final dataPoints = <AnalyticsDataPoint>[];
    
    for (int i = 0; i < daysToAnalyze; i++) {
      final checkDate = startDate.add(Duration(days: i));
      final dayIndex = checkDate.difference(habitStart).inDays;
      
      // Skip if before habit creation
      if (dayIndex < 0) continue;
      
      // Calculate rolling 7-day score for this day
      final score = _calculateRollingScore(
        checkDate: checkDate,
        completions: completions,
        habitStart: habitStart,
      );
      
      dataPoints.add(AnalyticsDataPoint(
        date: checkDate,
        gracefulScore: score,
        wasCompleted: completions.contains(checkDate),
        wasRecovery: recoveryDates.contains(checkDate),
        dayIndex: dayIndex,
      ));
    }
    
    return dataPoints;
  }
  
  /// Calculate rolling 7-day Graceful Score for a specific date
  double _calculateRollingScore({
    required DateTime checkDate,
    required Set<DateTime> completions,
    required DateTime habitStart,
  }) {
    int completedInWindow = 0;
    int daysInWindow = 0;
    
    // Look back 7 days (including checkDate)
    for (int j = 0; j < 7; j++) {
      final windowDate = checkDate.subtract(Duration(days: j));
      
      // Don't count days before habit started
      if (windowDate.isBefore(habitStart)) continue;
      
      daysInWindow++;
      if (completions.contains(windowDate)) {
        completedInWindow++;
      }
    }
    
    if (daysInWindow == 0) return 0;
    
    // Calculate a simplified graceful score based on completion rate
    // This gives us a score that drops gradually with misses, not instantly
    final completionRate = completedInWindow / daysInWindow;
    
    // Base score is heavily weighted by completion rate (60%)
    // Add bonus for consistency (40% - simulated from rate smoothness)
    final baseScore = completionRate * 60;
    final consistencyBonus = completionRate * 40; // Simplified
    
    return (baseScore + consistencyBonus).clamp(0, 100);
  }
  
  /// Generate summary statistics for a period
  PeriodSummary generatePeriodSummary({
    required Habit habit,
    required AnalyticsPeriod period,
  }) {
    final dataPoints = generateScoreHistory(habit: habit, period: period);
    
    if (dataPoints.isEmpty) {
      return PeriodSummary(
        totalDays: 0,
        completedDays: 0,
        missedDays: 0,
        recoveryDays: 0,
        averageScore: 0,
        startScore: 0,
        endScore: 0,
        scoreChange: 0,
        completionRate: 0,
        longestStreak: 0,
        currentStreak: 0,
      );
    }
    
    final completedDays = dataPoints.where((p) => p.wasCompleted).length;
    final recoveryDays = dataPoints.where((p) => p.wasRecovery).length;
    final totalDays = dataPoints.length;
    final missedDays = totalDays - completedDays;
    
    final scores = dataPoints.map((p) => p.gracefulScore).toList();
    final averageScore = scores.reduce((a, b) => a + b) / scores.length;
    
    final startScore = scores.first;
    final endScore = scores.last;
    final scoreChange = endScore - startScore;
    
    final completionRate = totalDays > 0 ? completedDays / totalDays : 0.0;
    
    // Calculate streaks within this period
    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;
    
    for (final point in dataPoints) {
      if (point.wasCompleted) {
        tempStreak++;
        if (tempStreak > longestStreak) longestStreak = tempStreak;
      } else {
        tempStreak = 0;
      }
    }
    
    // Current streak (from end)
    for (int i = dataPoints.length - 1; i >= 0; i--) {
      if (dataPoints[i].wasCompleted) {
        currentStreak++;
      } else {
        break;
      }
    }
    
    return PeriodSummary(
      totalDays: totalDays,
      completedDays: completedDays,
      missedDays: missedDays,
      recoveryDays: recoveryDays,
      averageScore: averageScore,
      startScore: startScore,
      endScore: endScore,
      scoreChange: scoreChange,
      completionRate: completionRate,
      longestStreak: longestStreak,
      currentStreak: currentStreak,
    );
  }
  
  /// Generate weekly breakdown data (for bar chart)
  List<WeeklyBreakdown> generateWeeklyBreakdown({
    required Habit habit,
    required int weeksToShow,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final completions = habit.completionHistory.map((d) => 
      DateTime(d.year, d.month, d.day)
    ).toSet();
    
    final weeks = <WeeklyBreakdown>[];
    
    for (int week = 0; week < weeksToShow; week++) {
      final weekEnd = today.subtract(Duration(days: week * 7));
      final weekStart = weekEnd.subtract(const Duration(days: 6));
      
      int completed = 0;
      for (int day = 0; day < 7; day++) {
        final checkDate = weekStart.add(Duration(days: day));
        if (completions.contains(checkDate)) completed++;
      }
      
      weeks.add(WeeklyBreakdown(
        weekNumber: weeksToShow - week,
        startDate: weekStart,
        endDate: weekEnd,
        completedDays: completed,
        totalDays: 7,
      ));
    }
    
    return weeks.reversed.toList(); // Oldest first
  }
  
  /// Get completion breakdown by day of week
  Map<String, int> getDayOfWeekBreakdown({
    required Habit habit,
  }) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final counts = <String, int>{for (var day in dayNames) day: 0};
    
    for (final completion in habit.completionHistory) {
      final dayIndex = completion.weekday - 1; // 1-7 to 0-6
      counts[dayNames[dayIndex]] = counts[dayNames[dayIndex]]! + 1;
    }
    
    return counts;
  }
  
  /// Calculate time-of-day patterns (if we had time data)
  /// For now, returns placeholder data
  Map<String, int> getTimeOfDayBreakdown({
    required Habit habit,
  }) {
    // Placeholder - would need completion times
    return {
      'Morning': 0,
      'Afternoon': 0,
      'Evening': 0,
      'Night': 0,
    };
  }
}

/// Weekly breakdown for bar charts
class WeeklyBreakdown {
  final int weekNumber;
  final DateTime startDate;
  final DateTime endDate;
  final int completedDays;
  final int totalDays;
  
  WeeklyBreakdown({
    required this.weekNumber,
    required this.startDate,
    required this.endDate,
    required this.completedDays,
    required this.totalDays,
  });
  
  double get completionRate => totalDays > 0 ? completedDays / totalDays : 0;
  
  String get label => 'Week $weekNumber';
  
  String get dateRange {
    final startStr = '${startDate.month}/${startDate.day}';
    final endStr = '${endDate.month}/${endDate.day}';
    return '$startStr - $endStr';
  }
}
