import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../config/router/app_routes.dart';
import '../../data/app_state.dart';
import '../../data/providers/user_provider.dart';
import '../../data/models/habit.dart';
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
    return Consumer2<UserProvider, AppState>(
      builder: (context, userProvider, appState, child) {
        final habits = appState.habits;
        // Strangler Fig Phase 2: Read profile from UserProvider
        final profile = userProvider.userProfile;

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
                  onPressed: () => context.push(AppRoutes.analytics),
                ),
              // History button (Phase 5)
              IconButton(
                icon: const Icon(Icons.calendar_month_outlined),
                tooltip: 'History',
                onPressed: () => context.push(AppRoutes.history),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'Settings',
                onPressed: () => context.push(AppRoutes.settings),
              ),
              // DEBUG: Factory Reset Button
              IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                tooltip: 'Factory Reset (Debug)',
                onPressed: () async {
                  // Confirm dialog first
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Factory Reset?'),
                      content: const Text(
                        'This will wipe ALL data, sign out, and restart onboarding.\n\n'
                        'Only for testing purposes.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: FilledButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('NUKE IT ☢️'),
                        ),
                      ],
                    ),
                  ) ?? false;

                  if (confirmed && context.mounted) {
                    debugPrint('☢️ MANUAL NUCLEAR RESET INITIATED');
                    // 1. Sign out
                    try {
                      // ignore: undefined_prefixed_name
                      await Supabase.instance.client.auth.signOut();
                    } catch (e) { /* ignore */ }
                    
                    // 2. Clear Hive
                    await Hive.deleteBoxFromDisk('habit_data');
                    await Hive.deleteBoxFromDisk('settings');
                    await Hive.deleteBoxFromDisk('user_data');
                    
                    // 3. Force Navigation
                    if (context.mounted) {
                      context.go(AppRoutes.home);
                    }
                  }
                },
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

  /// Phase 31 (Zhuo Z5): Enhanced empty state with personality
  /// Creates an emotional connection and motivates action
  Widget _buildEmptyState(BuildContext context) {
    // Strangler Fig Phase 2: Read from UserProvider
    final profile = context.read<UserProvider>().userProfile;
    final identity = profile?.identity ?? 'the person you want to become';
    
    // Motivational quotes that rotate
    final quotes = [
      '"Every action is a vote for the type of person you wish to become."\n— James Clear',
      '"You do not rise to the level of your goals. You fall to the level of your systems."\n— James Clear',
      '"The secret to getting results that last is to never stop making improvements."\n— James Clear',
    ];
    final quote = quotes[DateTime.now().day % quotes.length];
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Phase 31: Animated icon with gradient
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.rocket_launch_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            // Phase 31: Personalised greeting
            Text(
              'Ready to become',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              identity,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              '?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            // Phase 31: Rotating motivational quote
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                quote,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Phase 31: More prominent CTA
            FilledButton.icon(
              onPressed: () => context.push(AppRoutes.habitAdd),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Create Your First Habit'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'It only takes 2 minutes to start',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
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
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'stacked ${habit.stackPosition}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
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
                            context.push(AppRoutes.today);
                          },
                          // Phase 13: Long-press to edit habit (stacking config)
                          onEdit: () => context.push(AppRoutes.habitEdit(habit.id)),
                          onQuickComplete: () async {
                            final result = await appState.completeHabitForToday(habitId: habit.id);
                            if (result.wasNewCompletion && context.mounted) {
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
                                  context.push(AppRoutes.today);
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
            theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
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
            color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
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
    final appState = context.read<AppState>();
    final userProvider = context.read<UserProvider>();
    
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Voice Coach (Premium - Tier 2)
              ListTile(
                leading: const Icon(Icons.mic, color: Colors.deepPurple),
                title: const Text('Voice Coach'),
                subtitle: Text(
                  userProvider.isPremium 
                    ? 'Speak with your AI coach (Premium)'
                    : 'Premium feature - Upgrade to unlock',
                ),
                enabled: userProvider.isPremium,
                onTap: userProvider.isPremium ? () {
                  Navigator.pop(sheetContext);
                  context.push(AppRoutes.voiceOnboarding);
                } : null,
              ),
              // Text AI Coach (Tier 1)
              ListTile(
                leading: const Icon(Icons.auto_awesome),
                title: const Text('AI Coach'),
                subtitle: const Text('Let AI guide you through habit creation'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.push(AppRoutes.habitAdd); // Conversational onboarding (new habit flow)
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_note),
                title: const Text('Manual Entry'),
                subtitle: const Text('Fill in the habit details yourself'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.go(AppRoutes.manualOnboarding);
                },
              ),
              // DEBUG: Force Voice Coach (bypasses premium check)
              if (kDebugMode || appState.settings.developerMode)
                ListTile(
                  leading: const Icon(Icons.bug_report, color: Colors.redAccent),
                  title: const Text(
                    'DEBUG: Force Voice Coach',
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Bypass premium check for testing'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    debugPrint('🐞 [Debug] Forcing navigation to Voice Coach');
                    context.push(AppRoutes.voiceOnboarding);
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
