import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/app_state.dart';
import '../../data/models/habit.dart';
import '../../widgets/reward_investment_dialog.dart';
import '../../widgets/pre_habit_ritual_dialog.dart';

/// Today screen - Shows all habits and their completion status
/// Implements the Hook Model: Trigger → Action → Variable Reward → Investment
///
/// MULTIPLE HABITS SUPPORT:
/// - Shows a list of all habits with individual completion tracking
/// - Daily progress bar showing overall completion
/// - Add new habit button for quick access
class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Listen for app lifecycle changes to detect coming from background
    WidgetsBinding.instance.addObserver(this);

    // Check if we should show reward flow when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowRewardFlow();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When app comes to foreground, check if reward flow should be shown
    if (state == AppLifecycleState.resumed) {
      _checkAndShowRewardFlow();
    }
  }

  void _checkAndShowRewardFlow() {
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.shouldShowRewardFlow) {
      final habitId = appState.rewardFlowHabitId;
      final habit = habitId != null ? appState.getHabitById(habitId) : appState.currentHabit;
      if (habit != null) {
        _showRewardInvestmentDialog(appState, habit);
      }
    }
  }

  void _showRewardInvestmentDialog(AppState appState, Habit habit) {
    if (appState.userProfile == null) {
      debugPrint('⚠️ Cannot show reward dialog - missing profile');
      return;
    }

    debugPrint('🎉 Showing reward dialog - streak: ${habit.currentStreak}');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => RewardInvestmentDialog(
        streak: habit.currentStreak,
        identity: appState.userProfile!.identity,
        currentReminderTime: habit.implementationTime,
        onTimeUpdated: (newTime) {
          debugPrint('⏰ Updating reminder time to: $newTime');
          appState.updateReminderTime(newTime, habitId: habit.id);
        },
        onDismiss: () {
          debugPrint('✅ Dismissing reward dialog');
          appState.dismissRewardFlow();
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }

  Future<void> _showImprovementSuggestions(AppState appState, Habit habit) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Getting optimization tips...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Fetch all suggestions (async)
      final allSuggestions = await appState.getAllSuggestionsForHabit(habit);

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Check if we have any suggestions
      final hasSuggestions = allSuggestions.values.any((list) => list.isNotEmpty);

      if (!hasSuggestions) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No suggestions available. Please try again later.'),
            ),
          );
        }
        return;
      }

      // Show suggestions dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.tips_and_updates, color: Colors.deepPurple),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Strengthen "${habit.name}"',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Here are some ideas to make your habit stronger:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),

                  // Temptation Bundle suggestions
                  if (allSuggestions['temptationBundle']!.isNotEmpty) ...[
                    const Text(
                      'Temptation Bundling',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    ...allSuggestions['temptationBundle']!.take(2).map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('• $s', style: const TextStyle(fontSize: 14)),
                        )),
                    const SizedBox(height: 12),
                  ],

                  // Pre-habit Ritual suggestions
                  if (allSuggestions['preHabitRitual']!.isNotEmpty) ...[
                    const Text(
                      'Pre-Habit Ritual',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    ...allSuggestions['preHabitRitual']!.take(2).map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('• $s', style: const TextStyle(fontSize: 14)),
                        )),
                    const SizedBox(height: 12),
                  ],

                  // Environment Cue suggestions
                  if (allSuggestions['environmentCue']!.isNotEmpty) ...[
                    const Text(
                      'Environment Cue',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    ...allSuggestions['environmentCue']!.take(2).map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('• $s', style: const TextStyle(fontSize: 14)),
                        )),
                    const SizedBox(height: 12),
                  ],

                  // Distraction Removal suggestions
                  if (allSuggestions['environmentDistraction']!.isNotEmpty) ...[
                    const Text(
                      'Remove Distractions',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    ...allSuggestions['environmentDistraction']!.take(2).map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('• $s', style: const TextStyle(fontSize: 14)),
                        )),
                  ],

                  const SizedBox(height: 16),
                  Text(
                    'Tip: You can adjust your habit setup in Settings.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to get optimization tips. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final habits = appState.habits;
        final profile = appState.userProfile;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Today'),
            centerTitle: true,
            actions: [
              // Test notification button (debug only)
              IconButton(
                icon: const Icon(Icons.notifications_active),
                onPressed: () => appState.showTestNotification(),
                tooltip: 'Test notification',
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => context.go('/settings'),
              ),
            ],
          ),
          body: SafeArea(
            child: habits.isEmpty
                ? _buildNoHabitView(context)
                : _buildHabitsView(context, habits, profile, appState),
          ),
          floatingActionButton: habits.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: () => context.go('/add-habit'),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Habit'),
                )
              : null,
        );
      },
    );
  }

  Widget _buildNoHabitView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.calendar_today,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No habits set yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Complete onboarding to create your first habit',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Go to Onboarding'),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsView(
    BuildContext context,
    List<Habit> habits,
    dynamic profile,
    AppState appState,
  ) {
    final completedCount = appState.habitsCompletedToday;
    final totalCount = habits.length;
    final completionPercentage = appState.todayCompletionPercentage;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Identity reminder
          if (profile != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${profile.name}!',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile.identity,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Daily progress section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Today\'s Progress',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$completedCount / $totalCount',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: completedCount == totalCount
                              ? Colors.green
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: completionPercentage,
                      minHeight: 12,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        completedCount == totalCount ? Colors.green : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  if (completedCount == totalCount && totalCount > 0) ...[
                    const SizedBox(height: 12),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.celebration, color: Colors.amber),
                        SizedBox(width: 8),
                        Text(
                          'All habits completed!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Habits list header
          Text(
            'Your Habits',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Habits list
          ...habits.map((habit) => _buildHabitCard(context, habit, appState)),

          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildHabitCard(BuildContext context, Habit habit, AppState appState) {
    final isCompleted = appState.isHabitCompletedToday(habit.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Show habit details in a bottom sheet
          _showHabitDetails(context, habit, appState, isCompleted);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Completion checkbox
                  InkWell(
                    onTap: isCompleted
                        ? null
                        : () async {
                            final wasNew = await appState.completeHabitForToday(habitId: habit.id);
                            if (wasNew && mounted) {
                              _showRewardInvestmentDialog(appState, appState.getHabitById(habit.id)!);
                            }
                          },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted ? Colors.green : Colors.transparent,
                        border: Border.all(
                          color: isCompleted ? Colors.green : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: isCompleted
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Habit name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                            color: isCompleted ? Colors.grey : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              habit.implementationTime,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.local_fire_department, size: 14, color: Colors.orange.shade600),
                            const SizedBox(width: 4),
                            Text(
                              '${habit.currentStreak} days',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.orange.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // More options button
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showHabitOptions(context, habit, appState),
                  ),
                ],
              ),
              // Tiny version hint
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer, color: Colors.amber, size: 16),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Start tiny: ${habit.tinyVersion}',
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Pre-habit ritual button (if exists and not completed)
              if (!isCompleted && habit.preHabitRitual != null && habit.preHabitRitual!.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => PreHabitRitualDialog(
                          ritualText: habit.preHabitRitual!,
                          onDismiss: () => Navigator.of(context).pop(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.self_improvement, size: 18),
                    label: const Text('Start ritual'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.purple.shade300),
                      foregroundColor: Colors.purple.shade700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showHabitDetails(BuildContext context, Habit habit, AppState appState, bool isCompleted) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Habit name and status
              Row(
                children: [
                  Icon(
                    isCompleted ? Icons.check_circle : Icons.circle_outlined,
                    size: 32,
                    color: isCompleted ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      habit.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Streak
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade300, Colors.deepOrange.shade400],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.local_fire_department, size: 32, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      '${habit.currentStreak} day streak',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Details
              _buildDetailRow(Icons.timer, 'Tiny version', habit.tinyVersion),
              _buildDetailRow(Icons.access_time, 'Scheduled time', habit.implementationTime),
              _buildDetailRow(Icons.place, 'Location', habit.implementationLocation),

              if (habit.temptationBundle != null && habit.temptationBundle!.isNotEmpty)
                _buildDetailRow(Icons.favorite, 'Bundled with', habit.temptationBundle!),

              if (habit.preHabitRitual != null && habit.preHabitRitual!.isNotEmpty)
                _buildDetailRow(Icons.self_improvement, 'Pre-habit ritual', habit.preHabitRitual!),

              if (habit.environmentCue != null && habit.environmentCue!.isNotEmpty)
                _buildDetailRow(Icons.lightbulb, 'Environment cue', habit.environmentCue!),

              if (habit.environmentDistraction != null && habit.environmentDistraction!.isNotEmpty)
                _buildDetailRow(Icons.block, 'Distraction to remove', habit.environmentDistraction!),

              const SizedBox(height: 24),

              // Action buttons
              if (!isCompleted) ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      final wasNew = await appState.completeHabitForToday(habitId: habit.id);
                      if (wasNew && mounted) {
                        _showRewardInvestmentDialog(appState, appState.getHabitById(habit.id)!);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Mark as Complete',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Optimization tips button
              Center(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showImprovementSuggestions(appState, habit);
                  },
                  icon: const Icon(Icons.tips_and_updates),
                  label: const Text('Get optimization tips'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHabitOptions(BuildContext context, Habit habit, AppState appState) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit habit'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                context.go('/edit-habit/${habit.id}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.tips_and_updates),
              title: const Text('Get optimization tips'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _showImprovementSuggestions(appState, habit);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete habit', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _confirmDeleteHabit(context, habit, appState);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteHabit(BuildContext context, Habit habit, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${habit.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              appState.deleteHabit(habit.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Habit "${habit.name}" deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
