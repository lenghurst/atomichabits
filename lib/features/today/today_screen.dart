import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/app_state.dart';
import '../../widgets/reward_investment_dialog.dart';
import '../../widgets/pre_habit_ritual_dialog.dart';

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
            )
          else
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
          const SizedBox(height: 24),
          
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
