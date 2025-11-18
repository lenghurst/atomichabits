import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/app_state.dart';
import '../../data/models/habit.dart';
import '../../data/models/user_profile.dart';
import '../../data/identity_messages.dart';
import '../../data/celebration_config.dart';
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
  // Identity message state
  String _identityMessage = '';
  bool _showIdentityMessage = false;
  int _messageIndex = 0;

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

  /// Builds the tiny action line from habit details
  /// Format: "[Tiny version] at [time] [in location]"
  /// Handles missing fields gracefully
  String _buildTinyActionLine(Habit habit) {
    final parts = <String>[];

    // Tiny version (required, but check anyway)
    if (habit.tinyVersion.isNotEmpty) {
      parts.add(habit.tinyVersion);
    } else {
      parts.add('Do your habit');
    }

    // Time
    if (habit.implementationTime.isNotEmpty) {
      parts.add('at ${habit.implementationTime}');
    }

    // Location
    if (habit.implementationLocation.isNotEmpty) {
      parts.add('in ${habit.implementationLocation}');
    }

    return parts.join(' ');
  }

  /// Checks if yesterday was missed by looking at completion history
  /// Uses the same date key format as AppState for consistency
  bool _wasYesterdayMissed(Habit habit) {
    // If this is the very first completion (empty history), treat as not a comeback
    if (habit.completionHistory.isEmpty) {
      return false;
    }

    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    // Match AppState's _formatDateKey format exactly
    final yesterdayKey = '${yesterday.year.toString().padLeft(4, '0')}-'
        '${yesterday.month.toString().padLeft(2, '0')}-'
        '${yesterday.day.toString().padLeft(2, '0')}';

    // Check if yesterday is explicitly in history
    if (habit.completionHistory.containsKey(yesterdayKey)) {
      // If it's there and false, it was explicitly missed
      return habit.completionHistory[yesterdayKey] == false;
    }

    // If yesterday is not in history but we have other entries, consider it missed
    // (user has been tracking but didn't log yesterday)
    return true;
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
              // History & Review button
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () => context.go('/history'),
                tooltip: 'History & Review',
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
    // Get celebration config for animations
    final celebrationStyle = appState.userProfile?.celebrationStyle ?? CelebrationStyle.standard;
    final celebrationConfig = configForStyle(celebrationStyle);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Identity header - who you are becoming
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              habit.identity.isNotEmpty
                  ? habit.identity
                  : 'Your current habit',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 24),

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
                  // Tiny action line - combines tiny version + time + location
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.light_mode,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _buildTinyActionLine(habit),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                              height: 1.4,
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
                    // Animate streak number changes (uses celebration style config)
                    AnimatedSwitcher(
                      duration: celebrationConfig.animationDuration,
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        // Use celebration config's bounce scale for animation
                        final scaleTween = Tween<double>(
                          begin: 1.0,
                          end: celebrationConfig.bounceScale,
                        );
                        return ScaleTransition(
                          scale: scaleTween.animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutBack,
                            ),
                          ),
                          child: child,
                        );
                      },
                      child: Text(
                        '${habit.currentStreak}',
                        key: ValueKey<int>(habit.currentStreak),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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
          if (!isCompleted) ...[
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  debugPrint('🔘 Complete habit button pressed');

                  // Get celebration config based on user's celebration style
                  final celebrationStyle = appState.userProfile?.celebrationStyle ?? CelebrationStyle.standard;
                  final celebrationConfig = configForStyle(celebrationStyle);

                  // Haptic feedback (conditional based on celebration style)
                  if (celebrationConfig.enableHaptic) {
                    HapticFeedback.lightImpact();
                  }

                  // Complete habit and check if it's a new completion
                  final wasNewCompletion = await appState.completeHabitForToday();

                  debugPrint('📊 Was new completion: $wasNewCompletion, mounted: $mounted');

                  // Show reward flow if this was a new completion
                  if (wasNewCompletion && mounted) {
                    // Get identity message
                    final wasPreviousDayMissed = _wasYesterdayMissed(habit);
                    final message = IdentityMessages.getMessage(
                      currentStreak: appState.currentHabit!.currentStreak,
                      wasPreviousDayMissed: wasPreviousDayMissed,
                      messageIndex: _messageIndex,
                    );

                    // Show identity message with fade-in
                    setState(() {
                      _identityMessage = message;
                      _showIdentityMessage = true;
                      _messageIndex++;
                    });

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
                  'I did my 2-minute version',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Secondary nuance link
            Center(
              child: TextButton(
                onPressed: () {
                  debugPrint('📝 Opening daily coach dialog from nuance link');
                  showDialog(
                    context: context,
                    builder: (dialogContext) => DailyCoachDialog(
                      habit: habit,
                      profile: profile!,
                      onSaveReflection: (note) {
                        debugPrint('💾 Saving reflection note');
                        appState.saveReflectionForToday(note);
                      },
                    ),
                  );
                },
                child: Text(
                  'Today was tough',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ] else ...[
            // Completed state
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
            // Identity message (fades in after completion)
            const SizedBox(height: 16),
            AnimatedOpacity(
              opacity: _showIdentityMessage ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  _identityMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Daily Reflection card
          Card(
            elevation: 1,
            color: Colors.purple.shade50,
            child: InkWell(
              onTap: () {
                debugPrint('📝 Opening daily reflection dialog');
                showDialog(
                  context: context,
                  builder: (dialogContext) => DailyCoachDialog(
                    habit: habit,
                    profile: profile!,
                    onSaveReflection: (note) {
                      debugPrint('💾 Saving reflection note');
                      appState.saveReflectionForToday(note);
                    },
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.psychology,
                        color: Colors.purple.shade700,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reflect with your coach',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Spend a minute understanding what helped or got in the way',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.purple.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.purple.shade400,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // "Improve this habit" button
          Center(
            child: OutlinedButton.icon(
              onPressed: () => _showImprovementSuggestions(appState),
              icon: const Icon(Icons.tips_and_updates),
              label: const Text('Get optimization tips'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
