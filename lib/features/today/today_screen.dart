import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/app_state.dart';
import '../../data/notification_service.dart';
import '../../data/notification_ids.dart';
import '../../data/daily_coach_service.dart';
import '../../widgets/reward_investment_dialog.dart';
import '../../widgets/pre_habit_ritual_dialog.dart';
import '../../widgets/daily_coach_dialog.dart';

/// Today screen - Shows today's habit and streak
/// Implements the Hook Model: Trigger → Action → Variable Reward → Investment
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
      _showRewardInvestmentDialog(appState);
    }
  }

  void _showRewardInvestmentDialog(AppState appState) {
    if (appState.currentHabit == null || appState.userProfile == null) {
      debugPrint('⚠️ Cannot show reward dialog - missing habit or profile');
      return;
    }

    debugPrint('🎉 Showing reward dialog - streak: ${appState.currentHabit!.currentStreak}');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => RewardInvestmentDialog(
        streak: appState.currentHabit!.currentStreak,
        identity: appState.userProfile!.identity,
        currentReminderTime: appState.currentHabit!.implementationTime,
        onTimeUpdated: (newTime) {
          debugPrint('⏰ Updating reminder time to: $newTime');
          appState.updateReminderTime(newTime);
        },
        onDismiss: () {
          debugPrint('✅ Dismissing reward dialog');
          appState.dismissRewardFlow();
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }

  /// Show daily coach reflection dialog (Phase 6)
  void _showDailyCoachDialog(AppState appState) {
    if (appState.currentHabit == null || appState.userProfile == null) {
      debugPrint('⚠️ Cannot show daily coach dialog - missing habit or profile');
      return;
    }

    final habit = appState.currentHabit!;
    final profile = appState.userProfile!;

    debugPrint('💭 Showing daily coach reflection dialog');

    // Build context for daily reflection
    final reflectionContext = DailyReflectionContext(
      identity: profile.identity,
      habitName: habit.name,
      tinyVersion: habit.tinyVersion,
      date: DateTime.now(),
      status: 'completed', // User accessed this after completing
      currentStreak: habit.currentStreak,
      totalCompletions: habit.totalCompletions,
    );

    showDialog(
      context: context,
      builder: (dialogContext) => DailyCoachDialog(
        context: reflectionContext,
      ),
    );
  }

  Future<void> _showImprovementSuggestions(AppState appState) async {
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
      final allSuggestions = await appState.getAllSuggestionsForCurrentHabit();
      
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
        title: const Row(
          children: [
            Icon(Icons.tips_and_updates, color: Colors.deepPurple),
            SizedBox(width: 12),
            Text('Strengthen Your Habit'),
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
                  '💗 Temptation Bundling',
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
                  '🧘 Pre-Habit Ritual',
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
                  '💡 Environment Cue',
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
                  '🚫 Remove Distractions',
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

  /// Handle "Remind me later" button tap
  /// Schedules a one-off snooze notification 30 minutes from now
  Future<void> _handleRemindMeLater(AppState appState, dynamic habit) async {
    if (appState.currentHabit == null || appState.userProfile == null) return;

    try {
      // Schedule snooze notification
      await NotificationService().scheduleSnoozeNotification(
        habit: appState.currentHabit!,
        profile: appState.userProfile!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder set for 30 minutes from now'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      if (kDebugMode) {
        debugPrint('⏰ Snooze notification scheduled');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to schedule snooze: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to set reminder. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final habit = appState.currentHabit;
        final profile = appState.userProfile;
        final isCompleted = appState.isHabitCompletedToday();

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
            child: habit == null
                ? _buildNoHabitView(context)
                : _buildHabitView(
                    context,
                    habit,
                    profile,
                    isCompleted,
                    appState,
                  ),
          ),
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
            'No habit set yet',
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

  Widget _buildHabitView(
    BuildContext context,
    dynamic habit,
    dynamic profile,
    bool isCompleted,
    AppState appState,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
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
                          'Hello, ${profile.name}! 👋',
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
            const SizedBox(height: 32),
          ],

          // Habit card
          Text(
            'Your Habit for Today',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer, color: Colors.amber),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Start tiny: ${habit.tinyVersion}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Implementation intention display
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Planned: ${habit.implementationTime} in ${habit.implementationLocation}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Temptation Bundle display (Make it Attractive)
                  if (habit.temptationBundle != null && habit.temptationBundle!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.pink.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.favorite, color: Colors.pink, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Bundled with: ${habit.temptationBundle}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  // Environment Design display
                  if ((habit.environmentCue != null && habit.environmentCue!.isNotEmpty) ||
                      (habit.environmentDistraction != null && habit.environmentDistraction!.isNotEmpty)) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.home, color: Colors.green, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Environment',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          if (habit.environmentCue != null && habit.environmentCue!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.lightbulb, size: 16, color: Colors.orange),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Cue: ${habit.environmentCue}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (habit.environmentDistraction != null && habit.environmentDistraction!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.block, size: 16, color: Colors.red),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Distraction guardrail: ${habit.environmentDistraction}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Streak counter
          Text(
            'Your Streak',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.shade300,
                  Colors.deepOrange.shade400,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.local_fire_department,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    Text(
                      '${habit.currentStreak}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'days',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Pre-Habit Ritual button (if ritual exists and not completed)
          if (!isCompleted && 
              habit.preHabitRitual != null && 
              habit.preHabitRitual!.isNotEmpty) ...[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  debugPrint('🧘 Starting pre-habit ritual');
                  showDialog(
                    context: context,
                    builder: (context) => PreHabitRitualDialog(
                      ritualText: habit.preHabitRitual!,
                      onDismiss: () {
                        debugPrint('✅ Ritual completed, closing dialog');
                        Navigator.of(context).pop();
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.self_improvement),
                label: const Text(
                  'Start ritual',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.purple.shade300, width: 2),
                  foregroundColor: Colors.purple.shade700,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Complete button
          if (!isCompleted)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  debugPrint('🔘 Mark as Complete button pressed');
                  
                  // Complete habit and check if it's a new completion
                  final wasNewCompletion = await appState.completeHabitForToday();

                  // Cancel any pending snooze notification since habit is now complete
                  if (wasNewCompletion) {
                    await NotificationService().cancelNotification(NotificationIds.snoozeReminder);
                    debugPrint('🚫 Cancelled snooze notification (habit completed)');
                  }

                  debugPrint('📊 Was new completion: $wasNewCompletion, mounted: $mounted');

                  // Show reward flow if this was a new completion
                  if (wasNewCompletion && mounted) {
                    debugPrint('✨ Triggering reward dialog');
                    _showRewardInvestmentDialog(appState);
                  } else if (!wasNewCompletion) {
                    debugPrint('⚠️ Habit already completed today');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Already completed for today!')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Mark as Complete ✓',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Phase 5: "Remind me later" button (only when not completed)
          if (!isCompleted)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: TextButton.icon(
                  onPressed: () => _handleRemindMeLater(appState, habit),
                  icon: const Icon(Icons.schedule, size: 18),
                  label: const Text('Not now – remind me in 30 minutes'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                  ),
                ),
              ),
            )
          else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  const Text(
                    'Completed for today! 🎉',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            // Phase 6: "Reflect with coach" card (optional daily reflection)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Card(
                elevation: 0,
                color: Colors.deepPurple.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Colors.deepPurple.shade100,
                    width: 1,
                  ),
                ),
                child: InkWell(
                  onTap: () => _showDailyCoachDialog(appState),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.auto_awesome,
                            color: Colors.deepPurple.shade700,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reflect with coach',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.deepPurple.shade900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Get personalised feedback on today\'s progress',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.deepPurple.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.deepPurple.shade400,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),

          // "Improve this habit" button
          Center(
            child: OutlinedButton.icon(
              onPressed: () => _showImprovementSuggestions(appState),
              icon: const Icon(Icons.tips_and_updates),
              label: const Text('Get optimisation tips'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Phase 4: Avatar entry point (only shown if avatar enabled)
          if (appState.avatarEnabled)
            Center(
              child: TextButton.icon(
                onPressed: () => context.go('/avatar'),
                icon: const Icon(Icons.person_outline, size: 20),
                label: const Text('View identity avatar'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                ),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
