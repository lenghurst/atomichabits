import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/app_state.dart';
import '../../data/models/habit.dart';
import 'widgets/habit_summary_card.dart';

/// Dashboard screen showing all habits
/// 
/// Phase 4: Multi-Habit Dashboard
/// - Displays all habits with consistency scores
/// - Tap to focus on a habit (navigates to TodayScreen)
/// - Add new habit button
/// - Swipe to delete (with confirmation)
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
    // Calculate overall stats
    final completedToday = habits.where((h) => _isCompletedToday(h)).length;
    final avgScore = habits.isNotEmpty
        ? habits.map((h) => h.gracefulScore).reduce((a, b) => a + b) / habits.length
        : 0.0;

    return CustomScrollView(
      slivers: [
        // Stats header
        SliverToBoxAdapter(
          child: _buildStatsHeader(context, habits.length, completedToday, avgScore),
        ),
        
        // Habit cards
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final habit = habits[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Dismissible(
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
                      onQuickComplete: () async {
                        final success = await appState.completeHabitForToday(habitId: habit.id);
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${habit.name} completed!'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
              childCount: habits.length,
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
}
