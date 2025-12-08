import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_state.dart';
import '../data/models/habit.dart';
import 'habit_card.dart';

/// Bottom sheet showing all habits with management options
class HabitListSheet extends StatelessWidget {
  final VoidCallback? onAddHabit;

  const HabitListSheet({
    super.key,
    this.onAddHabit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<AppState>(
      builder: (context, appState, child) {
        final habits = appState.habits;
        final primaryHabit = appState.currentHabit;

        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Text(
                          'Your Habits',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildProgressBadge(context, appState),
                        const Spacer(),
                        if (onAddHabit != null)
                          IconButton(
                            onPressed: onAddHabit,
                            icon: const Icon(Icons.add_circle_outline),
                            tooltip: 'Add new habit',
                          ),
                      ],
                    ),
                  ),

                  // Focus score indicator
                  if (habits.length > 1) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: _buildFocusScoreIndicator(context, appState),
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Habit list
                  Expanded(
                    child: habits.isEmpty
                        ? _buildEmptyState(context)
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: habits.length,
                            itemBuilder: (context, index) {
                              final habit = habits[index];
                              final isPrimary = habit.id == primaryHabit?.id;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: HabitCard(
                                  habit: habit,
                                  isPrimary: isPrimary,
                                  onComplete: () {
                                    appState.completeHabit(habit.id);
                                  },
                                  onSetPrimary: isPrimary
                                      ? null
                                      : () {
                                          appState.setPrimaryHabit(habit.id);
                                        },
                                  onTap: () {
                                    _showHabitOptions(context, habit, appState);
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProgressBadge(BuildContext context, AppState appState) {
    final completed = appState.habitsCompletedTodayCount;
    final total = appState.activeHabitCount;
    final theme = Theme.of(context);

    final allDone = completed == total && total > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: allDone
            ? Colors.green.withOpacity(0.15)
            : theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$completed / $total today',
        style: theme.textTheme.labelMedium?.copyWith(
          color: allDone ? Colors.green[700] : theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFocusScoreIndicator(BuildContext context, AppState appState) {
    final theme = Theme.of(context);
    final focusScore = appState.focusScore;

    String message;
    Color color;
    IconData icon;

    if (focusScore >= 0.7) {
      message = 'Great focus! Your habits are on track.';
      color = Colors.green;
      icon = Icons.check_circle_outline;
    } else if (focusScore >= 0.4) {
      message = 'Some habits need attention.';
      color = Colors.orange;
      icon = Icons.info_outline;
    } else {
      message = 'Consider focusing on fewer habits.';
      color = Colors.red;
      icon = Icons.warning_amber_outlined;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.track_changes,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No habits yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          if (onAddHabit != null)
            FilledButton.icon(
              onPressed: onAddHabit,
              icon: const Icon(Icons.add),
              label: const Text('Create Your First Habit'),
            ),
        ],
      ),
    );
  }

  void _showHabitOptions(BuildContext context, Habit habit, AppState appState) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.star_outline),
              title: const Text('Set as Primary'),
              subtitle: const Text('Make this your main focus'),
              onTap: () {
                appState.setPrimaryHabit(habit.id);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: const Text('Archive Habit'),
              subtitle: const Text('Hide but keep history'),
              onTap: () {
                appState.archiveHabit(habit.id);
                Navigator.pop(context);
                Navigator.pop(context); // Close habit list sheet too
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red[400]),
              title: Text(
                'Delete Permanently',
                style: TextStyle(color: Colors.red[400]),
              ),
              subtitle: const Text('Cannot be undone'),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, habit, appState);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Habit habit, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit?'),
        content: Text(
          'This will permanently delete "${habit.name}" and all its history. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              appState.deleteHabitPermanently(habit.id);
              Navigator.pop(context);
              Navigator.pop(context); // Close habit list sheet
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Show the habit list as a modal bottom sheet
  static void show(BuildContext context, {VoidCallback? onAddHabit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HabitListSheet(onAddHabit: onAddHabit),
    );
  }
}
