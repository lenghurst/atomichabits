import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/app_state.dart';
import '../../data/models/consistency_metrics.dart';
import '../../widgets/reward_investment_dialog.dart';
import '../../widgets/pre_habit_ritual_dialog.dart';
import '../../widgets/recovery_prompt_dialog.dart';
import '../../widgets/graceful_consistency_card.dart';

/// Today screen - Shows today's habit and graceful consistency metrics
/// Implements the Hook Model: Trigger → Action → Variable Reward → Investment
/// 
/// **Graceful Consistency Philosophy:**
/// - Shows holistic consistency score instead of fragile streaks
/// - Displays "Never Miss Twice" recovery prompts when needed
/// - Celebrates recoveries, not just perfect streaks
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
    } else if (appState.shouldShowRecoveryPrompt) {
      // Show recovery prompt if habit needs attention
      _showRecoveryPromptDialog(appState);
    }
  }
  
  void _showRecoveryPromptDialog(AppState appState) {
    if (appState.currentRecoveryNeed == null) {
      debugPrint('⚠️ No recovery need to display');
      return;
    }
    
    final recoveryNeed = appState.currentRecoveryNeed!;
    debugPrint('💪 Showing recovery dialog - ${recoveryNeed.daysMissed} day(s) missed');
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => RecoveryPromptDialog(
        recoveryNeed: recoveryNeed,
        zoomOutMessage: appState.getZoomOutMessage(),
        onDoTinyVersion: () async {
          Navigator.of(dialogContext).pop();
          // Complete the habit with tiny version flag
          // Phase 13: Now returns CompletionResult
          final result = await appState.completeHabitForToday(
            usedTinyVersion: true,
          );
          if (result != null && result.wasNewCompletion && mounted) {
            _showRewardInvestmentDialog(appState);
          }
        },
        onDismiss: () {
          Navigator.of(dialogContext).pop();
          appState.dismissRecoveryPrompt();
        },
        onMissReasonSelected: (reason) {
          appState.recordMissReason(reason);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Got it - ${reason.label}. We\'ll help you work around that.'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
      ),
    );
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

  /// Shows detailed consistency metrics in a bottom sheet
  void _showConsistencyDetails(BuildContext context, dynamic habit) {
    final metrics = habit.consistencyMetrics;
    
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
              // Handle
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
              const SizedBox(height: 20),
              
              // Title
              const Text(
                'Your Consistency Journey',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Graceful Consistency > Fragile Streaks',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),
              
              // Main score
              _DetailSection(
                title: 'Overall Score',
                icon: Icons.analytics,
                child: Row(
                  children: [
                    Text(
                      '${metrics.gracefulScore.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            metrics.scoreDescription,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Based on 7-day average, recovery rate, and consistency',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Weekly stats
              _DetailSection(
                title: 'This Week',
                icon: Icons.calendar_view_week,
                child: Row(
                  children: [
                    _StatBox(
                      value: '${(metrics.weeklyAverage * 100).toStringAsFixed(0)}%',
                      label: 'Completion Rate',
                    ),
                    const SizedBox(width: 16),
                    _StatBox(
                      value: '${(metrics.weeklyAverage * 7).round()}/7',
                      label: 'Days Completed',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // All-time stats
              _DetailSection(
                title: 'All Time',
                icon: Icons.timeline,
                child: Row(
                  children: [
                    _StatBox(
                      value: '${habit.identityVotes}',
                      label: 'Identity Votes',
                    ),
                    const SizedBox(width: 16),
                    _StatBox(
                      value: '${metrics.daysShowedUp}/${metrics.totalDays}',
                      label: 'Days Showed Up',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Recovery stats
              _DetailSection(
                title: 'Never Miss Twice',
                icon: Icons.shield,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _StatBox(
                          value: '${(metrics.neverMissTwiceRate * 100).toStringAsFixed(0)}%',
                          label: 'Success Rate',
                        ),
                        const SizedBox(width: 16),
                        _StatBox(
                          value: '${metrics.quickRecoveryCount}',
                          label: 'Quick Recoveries',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Quick recoveries = bounced back within 1 day of missing',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Streak info (de-emphasized)
              _DetailSection(
                title: 'Streaks (for reference)',
                icon: Icons.local_fire_department,
                deEmphasized: true,
                child: Row(
                  children: [
                    _StatBox(
                      value: '${metrics.currentStreak}',
                      label: 'Current',
                      deEmphasized: true,
                    ),
                    const SizedBox(width: 16),
                    _StatBox(
                      value: '${metrics.longestStreak}',
                      label: 'Best Ever',
                      deEmphasized: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Philosophy note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '"Streaks are fragile. Consistency is resilient. '
                        'One miss is an accident. Two is a pattern." '
                        '– Atomic Habits Philosophy',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Builds an inline recovery banner for when recovery is needed
  Widget _buildRecoveryBanner(BuildContext context, dynamic habit, AppState appState) {
    final recoveryNeed = appState.currentRecoveryNeed;
    if (recoveryNeed == null) return const SizedBox.shrink();
    
    MaterialColor bannerColor;
    IconData bannerIcon;
    String bannerTitle;
    
    switch (recoveryNeed.urgency) {
      case RecoveryUrgency.gentle:
        bannerColor = Colors.amber;
        bannerIcon = Icons.wb_sunny;
        bannerTitle = 'Never Miss Twice';
        break;
      case RecoveryUrgency.important:
        bannerColor = Colors.orange;
        bannerIcon = Icons.warning_amber;
        bannerTitle = 'Day 2 - Critical';
        break;
      case RecoveryUrgency.compassionate:
        bannerColor = Colors.purple;
        bannerIcon = Icons.favorite;
        bannerTitle = 'Welcome Back';
        break;
    }
    
    return GestureDetector(
      onTap: () => _showRecoveryPromptDialog(appState),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bannerColor.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: bannerColor.shade300, width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bannerColor.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                bannerIcon,
                color: bannerColor.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bannerTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: bannerColor.shade900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to see your comeback plan',
                    style: TextStyle(
                      fontSize: 13,
                      color: bannerColor.shade700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: bannerColor.shade700,
            ),
          ],
        ),
      ),
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

          // Graceful Consistency Card (replaces fragile streak counter)
          Text(
            'Your Consistency',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          GracefulConsistencyCard(
            metrics: habit.consistencyMetrics,
            identityVotes: habit.identityVotes,
            showDetailedMetrics: true,
            onTap: () => _showConsistencyDetails(context, habit),
          ),
          const SizedBox(height: 24),

          // Recovery prompt banner (if needed and not showing dialog)
          if (!isCompleted && habit.needsRecovery) ...[
            _buildRecoveryBanner(context, habit, appState),
            const SizedBox(height: 24),
          ],

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
                  // Phase 13: Now returns CompletionResult
                  final result = await appState.completeHabitForToday();
                  
                  debugPrint('📊 Result: ${result?.wasNewCompletion}, mounted: $mounted');
                  
                  // Show reward flow if this was a new completion
                  if (result != null && result.wasNewCompletion && mounted) {
                    debugPrint('✨ Triggering reward dialog');
                    _showRewardInvestmentDialog(appState);
                  } else if (result == null || !result.wasNewCompletion) {
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

/// Section widget for consistency details bottom sheet
class _DetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final bool deEmphasized;
  
  const _DetailSection({
    required this.title,
    required this.icon,
    required this.child,
    this.deEmphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: deEmphasized ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: deEmphasized ? Colors.grey.shade500 : Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

/// Stat box widget for displaying individual statistics
class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final bool deEmphasized;
  
  const _StatBox({
    required this.value,
    required this.label,
    this.deEmphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: deEmphasized ? Colors.grey.shade100 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: deEmphasized ? Colors.grey.shade500 : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: deEmphasized ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
