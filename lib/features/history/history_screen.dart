import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/app_state.dart';
import '../../data/models/habit.dart';
import '../review/weekly_review_dialog.dart';
import 'widgets/calendar_month_view.dart';

/// History Screen - Visualize Habit Progress
/// 
/// **Phase 5: History & Calendar View**
/// - Stats overview (streak, total days, consistency)
/// - Calendar view with completion dots
/// - Month-by-month navigation
/// - Recovery day visualization
/// 
/// **"Don't Break the Chain" + Graceful Consistency:**
/// Shows both successful completions AND recovery days
/// to reinforce that bouncing back is also winning.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late DateTime _selectedMonth;
  
  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
  }
  
  void _goToPreviousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }
  
  void _goToNextMonth() {
    final now = DateTime.now();
    final nextMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    // Don't allow going past current month
    if (nextMonth.isBefore(DateTime(now.year, now.month + 1))) {
      setState(() {
        _selectedMonth = nextMonth;
      });
    }
  }
  
  bool get _canGoNext {
    final now = DateTime.now();
    return _selectedMonth.year < now.year || 
           (_selectedMonth.year == now.year && _selectedMonth.month < now.month);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final habit = appState.currentHabit;
        
        if (habit == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('History')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No habit selected'),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.go('/dashboard'),
                    child: const Text('Go to Dashboard'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.canPop() ? context.pop() : context.go('/today'),
            ),
            title: Text(habit.name),
            centerTitle: true,
            actions: [
              // Weekly Review button (Phase 7)
              IconButton(
                icon: const Icon(Icons.auto_awesome),
                tooltip: 'Weekly Review',
                onPressed: () => WeeklyReviewDialog.show(context, habit),
              ),
              // Habit picker for multi-habit users
              if (appState.habits.length > 1)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.swap_horiz),
                  tooltip: 'Switch habit',
                  onSelected: (habitId) {
                    appState.setFocusHabit(habitId);
                  },
                  itemBuilder: (context) => appState.habits.map((h) {
                    return PopupMenuItem(
                      value: h.id,
                      child: Row(
                        children: [
                          Text(h.habitEmoji ?? '✨'),
                          const SizedBox(width: 8),
                          Expanded(child: Text(h.name)),
                          if (h.id == habit.id)
                            const Icon(Icons.check, size: 18),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Overview
                _buildStatsOverview(context, habit),
                
                const SizedBox(height: 24),
                
                // Milestones section
                _buildMilestonesSection(context, habit),
                
                const SizedBox(height: 24),
                
                // Calendar section header
                Row(
                  children: [
                    const Icon(Icons.calendar_month, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Activity Calendar',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Calendar Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CalendarMonthView(
                      month: _selectedMonth,
                      completionDates: habit.completionHistory,
                      recoveryDates: habit.recoveryHistory.map((e) => e.recoveryDate).toList(),
                      showNavigation: true,
                      onPreviousMonth: _goToPreviousMonth,
                      onNextMonth: _canGoNext ? _goToNextMonth : null,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Insights section
                _buildInsightsSection(context, habit),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsOverview(BuildContext context, Habit habit) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatCard(
                label: 'Current\nStreak',
                value: '${habit.currentStreak}',
                icon: Icons.local_fire_department,
                color: Colors.orange,
              ),
              _StatCard(
                label: 'Longest\nStreak',
                value: '${habit.longestStreak}',
                icon: Icons.emoji_events,
                color: Colors.amber,
              ),
              _StatCard(
                label: 'Total\nDays',
                value: '${habit.daysShowedUp}',
                icon: Icons.check_circle_outline,
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatCard(
                label: 'Consistency\nScore',
                value: '${habit.gracefulScore.toInt()}%',
                icon: Icons.trending_up,
                color: Colors.blue,
              ),
              _StatCard(
                label: 'Identity\nVotes',
                value: '${habit.identityVotes}',
                icon: Icons.how_to_vote,
                color: Colors.purple,
              ),
              _StatCard(
                label: 'Recoveries',
                value: '${habit.singleMissRecoveries}',
                icon: Icons.refresh,
                color: Colors.teal,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMilestonesSection(BuildContext context, Habit habit) {
    final milestones = [
      _MilestoneData(7, 'First Week', Icons.looks_one),
      _MilestoneData(21, 'Three Weeks', Icons.looks_3),
      _MilestoneData(30, 'One Month', Icons.calendar_today),
      _MilestoneData(66, 'Habit Formed', Icons.psychology),
      _MilestoneData(100, 'Century Club', Icons.military_tech),
      _MilestoneData(365, 'One Year', Icons.celebration),
    ];
    
    final achieved = milestones.where((m) => habit.daysShowedUp >= m.days).toList();
    final nextMilestone = milestones.firstWhere(
      (m) => habit.daysShowedUp < m.days,
      orElse: () => milestones.last,
    );
    
    if (achieved.isEmpty && habit.daysShowedUp < 7) {
      // Show progress to first milestone
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.flag, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Next Milestone: ${nextMilestone.label}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: habit.daysShowedUp / nextMilestone.days,
                backgroundColor: Colors.grey.shade200,
              ),
              const SizedBox(height: 8),
              Text(
                '${habit.daysShowedUp} / ${nextMilestone.days} days',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.emoji_events, size: 20),
            const SizedBox(width: 8),
            Text(
              'Milestones',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: milestones.map((m) {
            final isAchieved = habit.daysShowedUp >= m.days;
            return Chip(
              avatar: Icon(
                m.icon,
                size: 18,
                color: isAchieved ? Colors.amber : Colors.grey,
              ),
              label: Text(m.label),
              backgroundColor: isAchieved 
                  ? Colors.amber.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
              labelStyle: TextStyle(
                color: isAchieved ? Colors.amber.shade800 : Colors.grey,
                fontWeight: isAchieved ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInsightsSection(BuildContext context, Habit habit) {
    final insights = <String>[];
    
    // Generate contextual insights
    if (habit.currentStreak > 0) {
      insights.add('You\'re on a ${habit.currentStreak}-day streak! Keep it going!');
    }
    
    if (habit.singleMissRecoveries > 0) {
      insights.add('You\'ve bounced back ${habit.singleMissRecoveries} times. That\'s resilience!');
    }
    
    if (habit.gracefulScore >= 80) {
      insights.add('Your consistency is excellent. You\'re building a strong identity.');
    } else if (habit.gracefulScore >= 60) {
      insights.add('Good consistency! Small improvements lead to big results.');
    }
    
    if (habit.longestStreak > habit.currentStreak && habit.longestStreak > 7) {
      insights.add('Your best streak was ${habit.longestStreak} days. You can beat it!');
    }
    
    if (habit.neverMissTwiceRate > 0.8) {
      insights.add('Great at Never Missing Twice! ${(habit.neverMissTwiceRate * 100).toInt()}% recovery rate.');
    }
    
    if (insights.isEmpty) {
      insights.add('Every day is a chance to vote for who you want to become.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Phase 7: Weekly Review Card
        _buildWeeklyReviewCard(context, habit),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            const Icon(Icons.lightbulb_outline, size: 20),
            const SizedBox(width: 8),
            Text(
              'Insights',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...insights.map((insight) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.auto_awesome,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  insight,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
  
  /// Phase 7: Weekly Review promotional card
  Widget _buildWeeklyReviewCard(BuildContext context, Habit habit) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Check if user has at least 7 days of data
    final daysSinceCreation = DateTime.now().difference(habit.createdAt).inDays;
    final hasEnoughData = daysSinceCreation >= 7;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: hasEnoughData 
            ? () => WeeklyReviewDialog.show(context, habit)
            : null,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                colorScheme.primaryContainer.withOpacity(0.8),
                colorScheme.secondaryContainer.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Review',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasEnoughData
                          ? 'Get AI-powered insights on your progress'
                          : '${7 - daysSinceCreation} more days until your first review',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasEnoughData)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stat card widget for the overview section
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

/// Data class for milestones
class _MilestoneData {
  final int days;
  final String label;
  final IconData icon;
  
  const _MilestoneData(this.days, this.label, this.icon);
}
