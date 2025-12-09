import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/app_state.dart';

/// Stats Screen - "Zoom Out" View
///
/// Provides weekly and monthly perspective on habit progress.
/// Based on Atomic Habits: "You do not rise to the level of your goals.
/// You fall to the level of your systems."
///
/// Shows:
/// - Weekly completion rates with comparison
/// - Monthly overview with trends
/// - Best streaks and recovery wins
/// - Motivational insights based on data
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final habit = appState.currentHabit;

        if (habit == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Your Progress'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/today'),
              ),
            ),
            body: const Center(
              child: Text('No habit data available'),
            ),
          );
        }

        // Calculate stats
        final stats = _calculateStats(habit.completionHistory);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Zoom Out'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/today'),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with total days
                _buildTotalDaysCard(context, habit.daysShowedUp),
                const SizedBox(height: 20),

                // This Week vs Last Week
                Text(
                  'Weekly View',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                _buildWeeklyComparison(context, stats),
                const SizedBox(height: 24),

                // Monthly Overview
                Text(
                  'Monthly View',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                _buildMonthlyOverview(context, stats),
                const SizedBox(height: 24),

                // Streaks & Recovery
                Text(
                  'Resilience Stats',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                _buildResilienceStats(
                  context,
                  habit.currentStreak,
                  stats['longestStreak'] as int,
                  habit.neverMissTwiceWins,
                  habit.minimumVersionCount,
                ),
                const SizedBox(height: 24),

                // Motivational Insight
                _buildInsightCard(context, stats, habit),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Map<String, dynamic> _calculateStats(List<String> completionHistory) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Calculate week boundaries
    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    final lastWeekEnd = thisWeekStart.subtract(const Duration(days: 1));

    // Calculate month boundaries
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = thisMonthStart.subtract(const Duration(days: 1));

    // Parse dates and count
    int thisWeekCount = 0;
    int lastWeekCount = 0;
    int thisMonthCount = 0;
    int lastMonthCount = 0;
    int longestStreak = 0;
    int currentStreakCalc = 0;

    // Sort completion history for streak calculation
    final sortedDates = <DateTime>[];
    for (final dateStr in completionHistory) {
      try {
        final date = DateTime.parse(dateStr.split('T')[0]);
        sortedDates.add(DateTime(date.year, date.month, date.day));
      } catch (_) {}
    }
    sortedDates.sort();

    // Calculate streak and counts
    DateTime? lastDate;
    for (final date in sortedDates) {
      // This week
      if (!date.isBefore(thisWeekStart) && !date.isAfter(today)) {
        thisWeekCount++;
      }
      // Last week
      if (!date.isBefore(lastWeekStart) && !date.isAfter(lastWeekEnd)) {
        lastWeekCount++;
      }
      // This month
      if (!date.isBefore(thisMonthStart) && !date.isAfter(today)) {
        thisMonthCount++;
      }
      // Last month
      if (!date.isBefore(lastMonthStart) && !date.isAfter(lastMonthEnd)) {
        lastMonthCount++;
      }

      // Streak calculation
      if (lastDate == null) {
        currentStreakCalc = 1;
      } else {
        final diff = date.difference(lastDate).inDays;
        if (diff == 1) {
          currentStreakCalc++;
        } else if (diff > 1) {
          longestStreak = longestStreak > currentStreakCalc ? longestStreak : currentStreakCalc;
          currentStreakCalc = 1;
        }
      }
      lastDate = date;
    }
    longestStreak = longestStreak > currentStreakCalc ? longestStreak : currentStreakCalc;

    // Days in current month so far
    final daysInThisMonth = today.day;
    final daysInLastMonth = lastMonthEnd.day;

    // Days elapsed in this week
    final daysInThisWeek = today.weekday;

    return {
      'thisWeekCount': thisWeekCount,
      'lastWeekCount': lastWeekCount,
      'thisMonthCount': thisMonthCount,
      'lastMonthCount': lastMonthCount,
      'daysInThisWeek': daysInThisWeek,
      'daysInThisMonth': daysInThisMonth,
      'daysInLastMonth': daysInLastMonth,
      'longestStreak': longestStreak,
      'totalDays': sortedDates.length,
    };
  }

  Widget _buildTotalDaysCard(BuildContext context, int daysShowedUp) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade400, Colors.purple.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.emoji_events, size: 48, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            '$daysShowedUp',
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            'Total Days You Showed Up',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This number never resets',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyComparison(BuildContext context, Map<String, dynamic> stats) {
    final thisWeek = stats['thisWeekCount'] as int;
    final lastWeek = stats['lastWeekCount'] as int;
    final daysInThisWeek = stats['daysInThisWeek'] as int;

    final thisWeekPercent = (thisWeek / daysInThisWeek * 100).round();
    final lastWeekPercent = (lastWeek / 7 * 100).round();
    final trend = thisWeekPercent - lastWeekPercent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildWeekCard(
                  'This Week',
                  thisWeek,
                  daysInThisWeek,
                  Colors.blue,
                  isCurrentWeek: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildWeekCard(
                  'Last Week',
                  lastWeek,
                  7,
                  Colors.grey,
                  isCurrentWeek: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Trend indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: trend >= 0 ? Colors.green.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  trend >= 0 ? Icons.trending_up : Icons.trending_down,
                  color: trend >= 0 ? Colors.green.shade700 : Colors.orange.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  trend >= 0
                      ? 'Up ${trend.abs()}% from last week'
                      : 'Down ${trend.abs()}% from last week',
                  style: TextStyle(
                    color: trend >= 0 ? Colors.green.shade700 : Colors.orange.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCard(
    String label,
    int count,
    int total,
    Color color, {
    required bool isCurrentWeek,
  }) {
    final percent = total > 0 ? (count / total * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: isCurrentWeek ? Border.all(color: color, width: 2) : null,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$count/$total',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            '$percent%',
            style: TextStyle(
              fontSize: 14,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyOverview(BuildContext context, Map<String, dynamic> stats) {
    final thisMonth = stats['thisMonthCount'] as int;
    final lastMonth = stats['lastMonthCount'] as int;
    final daysInThisMonth = stats['daysInThisMonth'] as int;
    final daysInLastMonth = stats['daysInLastMonth'] as int;

    final thisMonthPercent = daysInThisMonth > 0 ? (thisMonth / daysInThisMonth * 100).round() : 0;
    final lastMonthPercent = daysInLastMonth > 0 ? (lastMonth / daysInLastMonth * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMonthCard(
                  'This Month',
                  thisMonth,
                  daysInThisMonth,
                  thisMonthPercent,
                  Colors.teal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMonthCard(
                  'Last Month',
                  lastMonth,
                  daysInLastMonth,
                  lastMonthPercent,
                  Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar for this month
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This month\'s progress',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: thisMonthPercent / 100,
                  minHeight: 12,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    thisMonthPercent >= 80
                        ? Colors.green
                        : thisMonthPercent >= 50
                            ? Colors.teal
                            : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthCard(
    String label,
    int count,
    int total,
    int percent,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$count days',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            'of $total ($percent%)',
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResilienceStats(
    BuildContext context,
    int currentStreak,
    int longestStreak,
    int neverMissTwiceWins,
    int minimumVersionCount,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  Icons.local_fire_department,
                  Colors.orange,
                  '$currentStreak',
                  'Current Streak',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  Icons.emoji_events,
                  Colors.amber,
                  '$longestStreak',
                  'Best Streak',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  Icons.replay,
                  Colors.blue,
                  '$neverMissTwiceWins',
                  'Bounce Backs',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  Icons.timer,
                  Colors.purple,
                  '$minimumVersionCount',
                  '2-Min Versions',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, Color color, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, Map<String, dynamic> stats, dynamic habit) {
    final insight = _generateInsight(stats, habit);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade50, Colors.purple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.indigo.shade400, size: 20),
              const SizedBox(width: 8),
              Text(
                'Insight',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insight,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade800,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _generateInsight(Map<String, dynamic> stats, dynamic habit) {
    final thisWeek = stats['thisWeekCount'] as int;
    final lastWeek = stats['lastWeekCount'] as int;
    final thisMonth = stats['thisMonthCount'] as int;
    final daysInThisMonth = stats['daysInThisMonth'] as int;
    final neverMissTwiceWins = habit.neverMissTwiceWins as int;
    final minimumVersionCount = habit.minimumVersionCount as int;

    // Generate contextual insight
    if (thisWeek > lastWeek && thisWeek >= 5) {
      return "You're on fire this week! You've shown up more than last week. Keep this momentum going.";
    } else if (neverMissTwiceWins > 0 && thisWeek > 0) {
      return "You've bounced back $neverMissTwiceWins times after missing a day. That's real resilience. Missing once is an accident; showing up after is a choice.";
    } else if (minimumVersionCount > 3) {
      return "You've done the 2-minute version $minimumVersionCount times. Remember: showing up matters more than perfection. Those 'minimum' days still count.";
    } else if (thisMonth >= daysInThisMonth * 0.8) {
      return "You're crushing this month with ${(thisMonth / daysInThisMonth * 100).round()}% consistency! You're building a real identity as someone who ${habit.identity}.";
    } else if (thisWeek < lastWeek && lastWeek > 3) {
      return "This week started slower than last week, but that's okay. Every day is a fresh opportunity to vote for the person you want to become.";
    } else if (habit.daysShowedUp > 20) {
      return "With ${habit.daysShowedUp} total days, you're building real momentum. You're not just doing a habit—you're becoming a different person.";
    } else {
      return "Every day you show up, you cast a vote for your future self. Small actions, compounded over time, lead to remarkable results.";
    }
  }
}
