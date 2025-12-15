import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/app_state.dart';
import '../../data/models/habit.dart';
import '../../data/models/completion_result.dart';
import '../../widgets/stack_prompt_dialog.dart';
import '../review/weekly_review_dialog.dart';
import 'widgets/habit_summary_card.dart';

/// Dashboard screen showing all habits
/// 
/// Phase 4: Multi-Habit Dashboard
/// - Displays all habits with consistency scores
/// - Tap to focus on a habit (navigates to TodayScreen)
/// - Add new habit button
/// - Swipe to delete (with confirmation)
/// 
/// Phase 13: Habit Stacking
/// - Displays stacked habits indented under their anchors
/// - Long-press to edit habit (stacking config)
/// - Chain Reaction prompt on quick-complete
class HabitListScreen extends StatelessWidget {
  const HabitListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final habits = appState.habits;
        final profile = appState.userProfile;

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'My Habits',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (profile != null)
                  Text(
                    profile.identity,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            centerTitle: true,
            actions: [
              // Weekly Review button (Phase 7)
              if (habits.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.auto_awesome),
                  tooltip: 'Weekly Review',
                  onPressed: () => _showWeeklyReviewPicker(context, habits),
                ),
              // Analytics button (Phase 10)
              if (habits.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.analytics_outlined),
                  tooltip: 'Analytics',
                  onPressed: () => context.push('/analytics'),
                ),
              // History button (Phase 5)
              IconButton(
                icon: const Icon(Icons.calendar_month_outlined),
                tooltip: 'History',
                onPressed: () => context.push('/history'),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'Settings',
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),
          body: habits.isEmpty
              ? _buildEmptyState(context)
              : _buildHabitList(context, appState, habits),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddHabitOptions(context),
            icon: const Icon(Icons.add),
            label: const Text('New Habit'),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.track_changes,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No habits yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Start your journey by creating your first habit.\n"Every action is a vote for the type of person you wish to become."',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Create Your First Habit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitList(BuildContext context, AppState appState, List<Habit> habits) {
    // Phase 13: Use habitsWithStacks to show habits in stack order
    final orderedHabits = appState.habitsWithStacks;
    
    // Calculate overall stats
    final completedToday = orderedHabits.where((h) => _isCompletedToday(h)).length;
    final avgScore = orderedHabits.isNotEmpty
        ? orderedHabits.map((h) => h.gracefulScore).reduce((a, b) => a + b) / orderedHabits.length
        : 0.0;

    return CustomScrollView(
      slivers: [
        // Stats header
        SliverToBoxAdapter(
          child: _buildStatsHeader(context, orderedHabits.length, completedToday, avgScore),
        ),
        
        // Habit cards
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final habit = orderedHabits[index];
                // Phase 13: Calculate indent depth for stacked habits
                final stackDepth = appState.getStackDepth(habit.id);
                final isStacked = habit.anchorHabitId != null;
                
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: 12,
                    // Phase 13: Indent stacked habits
                    left: stackDepth * 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Phase 13: Show chain link indicator for stacked habits
                      if (isStacked)
                        Padding(
                          padding: const EdgeInsets.only(left: 12, bottom: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.subdirectory_arrow_right,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'stacked ${habit.stackPosition ?? "after"}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Dismissible(
                        key: Key(habit.id),
                        direction: DismissDirection.endToStart,
                        background: _buildDismissBackground(),
                        confirmDismiss: (_) => _confirmDelete(context, habit),
                        onDismissed: (_) => appState.deleteHabit(habit.id),
                        child: HabitSummaryCard(
                          habit: habit,
                          index: index,
                          isCompleted: _isCompletedToday(habit),
                          onTap: () {
                            appState.setFocusHabit(habit.id);
                            context.push('/today');
                          },
                          // Phase 13: Long-press to edit habit (stacking config)
                          onEdit: () => context.push('/habit/${habit.id}/edit'),
                          onQuickComplete: () async {
                            final result = await appState.completeHabitForToday(habitId: habit.id);
                            if (result != null && result.wasNewCompletion && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${habit.name} completed!'),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              
                              // Phase 13: If there's a chain reaction, navigate to TodayScreen
                              if (result.shouldTriggerStack && result.nextHabitInChain != null) {
                                // Set focus to the completed habit to show chain reaction dialog
                                await appState.setFocusHabit(habit.id);
                                if (context.mounted) {
                                  context.push('/today');
                                }
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: orderedHabits.length,
            ),
          ),
        ),
        
        // Bottom padding for FAB
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }

  Widget _buildStatsHeader(BuildContext context, int total, int completed, double avgScore) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(context, '$total', 'Habits', Icons.list_alt),
          _buildStatItem(context, '$completed/$total', 'Today', Icons.check_circle_outline),
          _buildStatItem(context, '${avgScore.toInt()}%', 'Avg Score', Icons.trending_up),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, Habit habit) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit?'),
        content: Text(
          'Are you sure you want to delete "${habit.name}"?\n\n'
          'This will remove all ${habit.daysShowedUp} days of progress and cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showAddHabitOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.auto_awesome),
                title: const Text('AI Coach'),
                subtitle: const Text('Let AI guide you through habit creation'),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/'); // Conversational onboarding
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_note),
                title: const Text('Manual Entry'),
                subtitle: const Text('Fill in the habit details yourself'),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/onboarding/manual');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isCompletedToday(Habit habit) {
    if (habit.lastCompletedDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(
      habit.lastCompletedDate!.year,
      habit.lastCompletedDate!.month,
      habit.lastCompletedDate!.day,
    );
    return lastDate == today;
  }

  /// Phase 7: Show picker for weekly review if multiple habits
  void _showWeeklyReviewPicker(BuildContext context, List<Habit> habits) {
    // Filter habits with at least 7 days of data
    final eligibleHabits = habits.where((h) {
      final daysSinceCreation = DateTime.now().difference(h.createdAt).inDays;
      return daysSinceCreation >= 7;
    }).toList();
    
    if (eligibleHabits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Weekly reviews available after 7 days of tracking'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    // If only one eligible habit, show review directly
    if (eligibleHabits.length == 1) {
      WeeklyReviewDialog.show(context, eligibleHabits.first);
      return;
    }
    
    // Show picker for multiple habits
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Weekly Review',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Select a habit to review',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              ...eligibleHabits.map((habit) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    habit.habitEmoji ?? '✨',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                title: Text(habit.name),
                subtitle: Text(
                  '${habit.gracefulScore.toInt()}% consistency',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  WeeklyReviewDialog.show(context, habit);
                },
              )),
            ],
          ),
        ),
      ),
    );
  }
}
