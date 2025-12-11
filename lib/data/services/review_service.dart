import '../models/habit.dart';
import '../models/daily_metrics.dart';
import '../models/consistency_metrics.dart';
import '../../utils/date_utils.dart';
import 'consistency_service.dart';

/// ReviewService - Generates weekly and monthly habit reviews
/// 
/// Implements the "Weekly Review" concept from productivity methodologies,
/// adapted for habit tracking. Reviews help users:
/// 1. Celebrate wins (no matter how small)
/// 2. Learn from misses (without shame)
/// 3. Identify patterns
/// 4. Plan adjustments
class ReviewService {
  ReviewService._(); // Private constructor - use static methods
  
  // ========== Weekly Review ==========
  
  /// Generate a comprehensive weekly review for a habit
  static WeeklyReview generateWeeklyReview(
    Habit habit, {
    List<DailyMetrics>? dailyMetrics,
  }) {
    final now = DateTime.now();
    final weekStart = HabitDateUtils.startOfWeek();
    final weekEnd = now;
    
    // Get completion data
    final thisWeekData = ConsistencyService.getThisWeekData(habit);
    final lastWeekData = ConsistencyService.getLastWeekData(habit);
    
    // Calculate week-over-week change
    final comparison = ConsistencyService.compareWeekOverWeek(habit);
    
    // Analyze days
    final dayAnalysis = _analyzeDays(habit, weekStart, weekEnd);
    
    // Get recovery events this week
    final weekRecoveries = habit.recoveryHistory.where((r) =>
      r.recoveryDate.isAfter(weekStart) && 
      r.recoveryDate.isBefore(weekEnd.add(const Duration(days: 1)))
    ).toList();
    
    // Generate highlights
    final highlights = _generateWeeklyHighlights(
      habit, thisWeekData, lastWeekData, weekRecoveries
    );
    
    // Generate learnings
    final learnings = _generateWeeklyLearnings(
      habit, thisWeekData, dayAnalysis, dailyMetrics
    );
    
    // Generate suggestions
    final suggestions = _generateWeeklySuggestions(
      habit, thisWeekData, comparison, dayAnalysis
    );
    
    return WeeklyReview(
      habitId: habit.id,
      habitName: habit.name,
      weekStartDate: weekStart,
      weekEndDate: weekEnd,
      daysCompleted: thisWeekData.completedDays,
      daysMissed: thisWeekData.missedDays,
      completionRate: thisWeekData.completionRate,
      previousWeekRate: lastWeekData.completionRate,
      weekOverWeekChange: comparison.rateChange,
      currentStreak: habit.currentStreak,
      recoveryEventsThisWeek: weekRecoveries.length,
      quickRecoveriesThisWeek: weekRecoveries.where((r) => r.isQuickRecovery).length,
      identityVotesThisWeek: thisWeekData.completedDays,
      totalIdentityVotes: habit.identityVotes,
      dayAnalysis: dayAnalysis,
      highlights: highlights,
      learnings: learnings,
      suggestions: suggestions,
      gracefulScore: habit.gracefulScore,
    );
  }
  
  /// Analyze completion by day of week
  static Map<int, DayOfWeekAnalysis> _analyzeDays(
    Habit habit,
    DateTime start,
    DateTime end,
  ) {
    final analysis = <int, DayOfWeekAnalysis>{};
    
    // Initialize all days
    for (int day = 1; day <= 7; day++) {
      analysis[day] = DayOfWeekAnalysis(
        dayOfWeek: day,
        dayName: _getDayName(day),
        completions: 0,
        misses: 0,
      );
    }
    
    // Normalize completion dates
    final completions = habit.completionHistory
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();
    
    var current = DateTime(start.year, start.month, start.day);
    final endNormalized = DateTime(end.year, end.month, end.day);
    
    while (!current.isAfter(endNormalized)) {
      final dayOfWeek = current.weekday;
      
      if (completions.contains(current)) {
        analysis[dayOfWeek] = analysis[dayOfWeek]!.addCompletion();
      } else {
        analysis[dayOfWeek] = analysis[dayOfWeek]!.addMiss();
      }
      
      current = current.add(const Duration(days: 1));
    }
    
    return analysis;
  }
  
  static String _getDayName(int dayOfWeek) {
    const names = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return names[dayOfWeek];
  }
  
  static List<String> _generateWeeklyHighlights(
    Habit habit,
    PeriodCompletionData thisWeek,
    PeriodCompletionData lastWeek,
    List<RecoveryEvent> recoveries,
  ) {
    final highlights = <String>[];
    
    // Completion highlights
    if (thisWeek.completedDays == 7) {
      highlights.add('Perfect week! You showed up every single day.');
    } else if (thisWeek.completedDays >= 5) {
      highlights.add('Strong week with ${thisWeek.completedDays} days completed.');
    } else if (thisWeek.completedDays >= 3) {
      highlights.add('Solid effort - ${thisWeek.completedDays} days this week.');
    } else if (thisWeek.completedDays >= 1) {
      highlights.add('You showed up ${thisWeek.completedDays} time${thisWeek.completedDays == 1 ? '' : 's'}. Every vote counts!');
    }
    
    // Improvement highlight
    if (thisWeek.completionRate > lastWeek.completionRate + 0.1) {
      final improvement = ((thisWeek.completionRate - lastWeek.completionRate) * 100).round();
      highlights.add('$improvement% improvement over last week!');
    }
    
    // Recovery highlight
    if (recoveries.isNotEmpty) {
      final quickCount = recoveries.where((r) => r.isQuickRecovery).length;
      if (quickCount > 0) {
        highlights.add('$quickCount quick recover${quickCount == 1 ? 'y' : 'ies'} - you bounced back fast!');
      }
    }
    
    // Streak highlight
    if (habit.currentStreak >= 7) {
      highlights.add('${habit.currentStreak}-day streak and counting!');
    }
    
    // Identity votes milestone
    if (habit.identityVotes >= 100 && habit.identityVotes < 107) {
      highlights.add('100+ identity votes! You ARE this person now.');
    }
    
    return highlights;
  }
  
  static List<String> _generateWeeklyLearnings(
    Habit habit,
    PeriodCompletionData thisWeek,
    Map<int, DayOfWeekAnalysis> dayAnalysis,
    List<DailyMetrics>? dailyMetrics,
  ) {
    final learnings = <String>[];
    
    // Day pattern learning
    final bestDays = dayAnalysis.entries
        .where((e) => e.value.totalDays > 0 && e.value.completionRate >= 1.0)
        .map((e) => e.value.dayName)
        .toList();
    
    final worstDays = dayAnalysis.entries
        .where((e) => e.value.totalDays > 0 && e.value.completionRate < 0.5)
        .map((e) => e.value.dayName)
        .toList();
    
    if (bestDays.isNotEmpty && bestDays.length <= 3) {
      learnings.add('Your strongest days: ${bestDays.join(", ")}');
    }
    
    if (worstDays.isNotEmpty && worstDays.length <= 3) {
      learnings.add('Challenging days: ${worstDays.join(", ")} - consider adjusting your approach for these days.');
    }
    
    // Miss reason learning
    if (habit.lastMissReason != null) {
      learnings.add('Recent miss reason: "${habit.lastMissReason}" - this is valuable data for prevention.');
    }
    
    // Minimum version learning
    if (habit.minimumVersionRate > 0.3) {
      learnings.add('You used the minimum version ${(habit.minimumVersionRate * 100).round()}% of the time - that flexibility is key!');
    }
    
    return learnings;
  }
  
  static List<String> _generateWeeklySuggestions(
    Habit habit,
    PeriodCompletionData thisWeek,
    WeekOverWeekComparison comparison,
    Map<int, DayOfWeekAnalysis> dayAnalysis,
  ) {
    final suggestions = <String>[];
    
    // Low completion suggestion
    if (thisWeek.completionRate < 0.3) {
      suggestions.add('Consider making your habit even smaller. What takes just 1 minute?');
    }
    
    // Declining trend suggestion
    if (comparison.rateChange < -0.2) {
      suggestions.add('Completion dropped this week. Any environmental changes you could make?');
    }
    
    // Specific day suggestion
    final fridayData = dayAnalysis[5];
    final weekendData = [dayAnalysis[6]!, dayAnalysis[7]!];
    
    if (fridayData != null && fridayData.completionRate < 0.5) {
      suggestions.add('Fridays seem challenging - consider a different implementation intention for end of week.');
    }
    
    final weekendMisses = weekendData.fold<int>(0, (sum, d) => sum + d.misses);
    if (weekendMisses >= 2) {
      suggestions.add('Weekends are inconsistent - your routine changes. Plan a weekend-specific trigger.');
    }
    
    // Recovery suggestion
    if (habit.recoveryHistory.isEmpty && thisWeek.missedDays > 0) {
      suggestions.add('Set up a Failure Playbook - pre-plan how you\'ll recover next time.');
    }
    
    return suggestions;
  }
  
  // ========== Monthly Review ==========
  
  /// Generate a comprehensive monthly review for a habit
  static MonthlyReview generateMonthlyReview(
    Habit habit, {
    List<DailyMetrics>? dailyMetrics,
  }) {
    final now = DateTime.now();
    final monthStart = HabitDateUtils.startOfMonth();
    
    // Get monthly completion data
    final monthData = ConsistencyService.getCompletionDataForPeriod(
      habit, monthStart, now
    );
    
    // Get weekly breakdowns
    final weeklyBreakdown = _getWeeklyBreakdown(habit, monthStart, now);
    
    // Get all recovery events this month
    final monthRecoveries = habit.recoveryHistory.where((r) =>
      r.recoveryDate.isAfter(monthStart) && 
      r.recoveryDate.isBefore(now.add(const Duration(days: 1)))
    ).toList();
    
    // Calculate trends
    final trend = _calculateMonthlyTrend(weeklyBreakdown);
    
    // Check milestones
    final milestonesAchieved = _checkMilestones(habit);
    
    // Generate monthly insights
    final insights = _generateMonthlyInsights(
      habit, monthData, weeklyBreakdown, monthRecoveries, trend
    );
    
    return MonthlyReview(
      habitId: habit.id,
      habitName: habit.name,
      monthStartDate: monthStart,
      monthEndDate: now,
      totalDays: monthData.totalDays,
      daysCompleted: monthData.completedDays,
      completionRate: monthData.completionRate,
      weeklyBreakdown: weeklyBreakdown,
      trend: trend,
      totalRecoveries: monthRecoveries.length,
      quickRecoveries: monthRecoveries.where((r) => r.isQuickRecovery).length,
      neverMissTwiceRate: habit.neverMissTwiceRate,
      identityVotesThisMonth: monthData.completedDays,
      totalIdentityVotes: habit.identityVotes,
      longestStreak: habit.longestStreak,
      currentStreak: habit.currentStreak,
      gracefulScore: habit.gracefulScore,
      milestonesAchieved: milestonesAchieved,
      insights: insights,
    );
  }
  
  static List<WeeklyBreakdown> _getWeeklyBreakdown(
    Habit habit,
    DateTime monthStart,
    DateTime monthEnd,
  ) {
    final breakdown = <WeeklyBreakdown>[];
    
    var weekStart = monthStart;
    var weekNumber = 1;
    
    while (weekStart.isBefore(monthEnd)) {
      var weekEnd = weekStart.add(const Duration(days: 6));
      if (weekEnd.isAfter(monthEnd)) weekEnd = monthEnd;
      
      final weekData = ConsistencyService.getCompletionDataForPeriod(
        habit, weekStart, weekEnd
      );
      
      breakdown.add(WeeklyBreakdown(
        weekNumber: weekNumber,
        startDate: weekStart,
        endDate: weekEnd,
        daysCompleted: weekData.completedDays,
        totalDays: weekData.totalDays,
        completionRate: weekData.completionRate,
      ));
      
      weekStart = weekStart.add(const Duration(days: 7));
      weekNumber++;
    }
    
    return breakdown;
  }
  
  static TrendDirection _calculateMonthlyTrend(List<WeeklyBreakdown> weeks) {
    if (weeks.length < 2) return TrendDirection.stable;
    
    final firstHalf = weeks.take(weeks.length ~/ 2).toList();
    final secondHalf = weeks.skip(weeks.length ~/ 2).toList();
    
    final firstHalfAvg = firstHalf.fold<double>(0, (sum, w) => sum + w.completionRate) / firstHalf.length;
    final secondHalfAvg = secondHalf.fold<double>(0, (sum, w) => sum + w.completionRate) / secondHalf.length;
    
    final diff = secondHalfAvg - firstHalfAvg;
    
    if (diff > 0.1) return TrendDirection.improving;
    if (diff < -0.1) return TrendDirection.declining;
    return TrendDirection.stable;
  }
  
  static List<String> _checkMilestones(Habit habit) {
    final achieved = <String>[];
    
    for (final milestone in habit.milestones) {
      if (milestone.isAchieved) {
        achieved.add(milestone.name);
      }
    }
    
    // Check default milestones based on days showed up
    if (habit.daysShowedUp >= 7) achieved.add('First Week');
    if (habit.daysShowedUp >= 21) achieved.add('Three Weeks');
    if (habit.daysShowedUp >= 30) achieved.add('One Month');
    if (habit.daysShowedUp >= 66) achieved.add('Habit Formed');
    if (habit.daysShowedUp >= 90) achieved.add('Quarter Year');
    
    return achieved.toSet().toList(); // Remove duplicates
  }
  
  static List<MonthlyInsight> _generateMonthlyInsights(
    Habit habit,
    PeriodCompletionData monthData,
    List<WeeklyBreakdown> weeklyBreakdown,
    List<RecoveryEvent> recoveries,
    TrendDirection trend,
  ) {
    final insights = <MonthlyInsight>[];
    
    // Trend insight
    switch (trend) {
      case TrendDirection.improving:
        insights.add(MonthlyInsight(
          type: MonthlyInsightType.trend,
          title: 'Upward trajectory!',
          message: 'Your consistency improved throughout the month. The habit is taking hold.',
          isPositive: true,
        ));
        break;
      case TrendDirection.declining:
        insights.add(MonthlyInsight(
          type: MonthlyInsightType.trend,
          title: 'Momentum shifted',
          message: 'Consistency dipped later in the month. Consider refreshing your environment cues.',
          isPositive: false,
        ));
        break;
      case TrendDirection.stable:
        insights.add(MonthlyInsight(
          type: MonthlyInsightType.trend,
          title: 'Steady consistency',
          message: 'You maintained stable consistency throughout the month.',
          isPositive: true,
        ));
        break;
    }
    
    // Completion rate insight
    if (monthData.completionRate >= 0.8) {
      insights.add(MonthlyInsight(
        type: MonthlyInsightType.achievement,
        title: 'Outstanding month!',
        message: '${(monthData.completionRate * 100).round()}% completion rate. You\'re building real automaticity.',
        isPositive: true,
      ));
    } else if (monthData.completionRate >= 0.5) {
      insights.add(MonthlyInsight(
        type: MonthlyInsightType.progress,
        title: 'Solid foundation',
        message: 'Showing up more than half the time is building the habit neural pathway.',
        isPositive: true,
      ));
    }
    
    // Recovery insight
    if (recoveries.isNotEmpty) {
      final quickRate = recoveries.where((r) => r.isQuickRecovery).length / recoveries.length;
      if (quickRate >= 0.7) {
        insights.add(MonthlyInsight(
          type: MonthlyInsightType.resilience,
          title: 'Quick recovery master',
          message: '${(quickRate * 100).round()}% of your misses were followed by immediate recovery. That\'s the real skill.',
          isPositive: true,
        ));
      }
    }
    
    // Identity votes insight
    if (habit.identityVotes >= 50) {
      insights.add(MonthlyInsight(
        type: MonthlyInsightType.identity,
        title: '${habit.identityVotes} identity votes',
        message: 'Every completion is a vote for "${habit.identity}". You\'re becoming this person.',
        isPositive: true,
      ));
    }
    
    return insights;
  }
}

/// Day of week analysis data
class DayOfWeekAnalysis {
  final int dayOfWeek;
  final String dayName;
  final int completions;
  final int misses;
  
  DayOfWeekAnalysis({
    required this.dayOfWeek,
    required this.dayName,
    this.completions = 0,
    this.misses = 0,
  });
  
  int get totalDays => completions + misses;
  double get completionRate => totalDays > 0 ? completions / totalDays : 0;
  
  DayOfWeekAnalysis addCompletion() => DayOfWeekAnalysis(
    dayOfWeek: dayOfWeek,
    dayName: dayName,
    completions: completions + 1,
    misses: misses,
  );
  
  DayOfWeekAnalysis addMiss() => DayOfWeekAnalysis(
    dayOfWeek: dayOfWeek,
    dayName: dayName,
    completions: completions,
    misses: misses + 1,
  );
}

/// Weekly review data structure
class WeeklyReview {
  final String habitId;
  final String habitName;
  final DateTime weekStartDate;
  final DateTime weekEndDate;
  final int daysCompleted;
  final int daysMissed;
  final double completionRate;
  final double previousWeekRate;
  final double weekOverWeekChange;
  final int currentStreak;
  final int recoveryEventsThisWeek;
  final int quickRecoveriesThisWeek;
  final int identityVotesThisWeek;
  final int totalIdentityVotes;
  final Map<int, DayOfWeekAnalysis> dayAnalysis;
  final List<String> highlights;
  final List<String> learnings;
  final List<String> suggestions;
  final double gracefulScore;
  
  WeeklyReview({
    required this.habitId,
    required this.habitName,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.daysCompleted,
    required this.daysMissed,
    required this.completionRate,
    required this.previousWeekRate,
    required this.weekOverWeekChange,
    required this.currentStreak,
    required this.recoveryEventsThisWeek,
    required this.quickRecoveriesThisWeek,
    required this.identityVotesThisWeek,
    required this.totalIdentityVotes,
    required this.dayAnalysis,
    required this.highlights,
    required this.learnings,
    required this.suggestions,
    required this.gracefulScore,
  });
  
  bool get isImproving => weekOverWeekChange > 0;
}

/// Weekly breakdown for monthly review
class WeeklyBreakdown {
  final int weekNumber;
  final DateTime startDate;
  final DateTime endDate;
  final int daysCompleted;
  final int totalDays;
  final double completionRate;
  
  WeeklyBreakdown({
    required this.weekNumber,
    required this.startDate,
    required this.endDate,
    required this.daysCompleted,
    required this.totalDays,
    required this.completionRate,
  });
}

/// Trend direction
enum TrendDirection {
  improving,
  stable,
  declining,
}

/// Monthly insight types
enum MonthlyInsightType {
  trend,
  achievement,
  progress,
  resilience,
  identity,
  suggestion,
}

/// Monthly insight
class MonthlyInsight {
  final MonthlyInsightType type;
  final String title;
  final String message;
  final bool isPositive;
  
  MonthlyInsight({
    required this.type,
    required this.title,
    required this.message,
    required this.isPositive,
  });
}

/// Monthly review data structure
class MonthlyReview {
  final String habitId;
  final String habitName;
  final DateTime monthStartDate;
  final DateTime monthEndDate;
  final int totalDays;
  final int daysCompleted;
  final double completionRate;
  final List<WeeklyBreakdown> weeklyBreakdown;
  final TrendDirection trend;
  final int totalRecoveries;
  final int quickRecoveries;
  final double neverMissTwiceRate;
  final int identityVotesThisMonth;
  final int totalIdentityVotes;
  final int longestStreak;
  final int currentStreak;
  final double gracefulScore;
  final List<String> milestonesAchieved;
  final List<MonthlyInsight> insights;
  
  MonthlyReview({
    required this.habitId,
    required this.habitName,
    required this.monthStartDate,
    required this.monthEndDate,
    required this.totalDays,
    required this.daysCompleted,
    required this.completionRate,
    required this.weeklyBreakdown,
    required this.trend,
    required this.totalRecoveries,
    required this.quickRecoveries,
    required this.neverMissTwiceRate,
    required this.identityVotesThisMonth,
    required this.totalIdentityVotes,
    required this.longestStreak,
    required this.currentStreak,
    required this.gracefulScore,
    required this.milestonesAchieved,
    required this.insights,
  });
}
