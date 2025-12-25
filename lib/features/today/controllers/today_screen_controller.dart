import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/app_state.dart';
import '../../../data/models/consistency_metrics.dart';
import '../../../data/models/completion_result.dart';
import '../../../data/services/sound_service.dart';
import '../../../data/services/smart_nudge/optimized_time_finder.dart';
import '../../../widgets/reward_investment_dialog.dart';
import '../../../widgets/recovery_prompt_dialog.dart';
import '../../../widgets/stack_prompt_dialog.dart';
import '../../../widgets/time_drift_suggestion_dialog.dart';
import '../widgets/improvement_suggestions_dialog.dart';
import '../widgets/consistency_details_sheet.dart';

/// TodayScreenController - Manages behavior and side effects for TodayScreen
/// 
/// Following vibecoding principles:
/// - This controller handles "how it behaves" (state, side effects, dialog management)
/// - UI components handle "how it looks" (layout, styling)
/// 
/// Responsibilities:
/// - Dialog lifecycle management (showing/dismissing dialogs)
/// - App lifecycle observation (foreground/background)
/// - Coordinating actions between UI and AppState
/// - Providing callbacks for UI interactions
class TodayScreenController {
  final BuildContext context;
  final AppState appState;
  
  /// Phase 19: Drift detector for smart notifications
  final OptimizedTimeFinder _driftDetector = OptimizedTimeFinder();
  
  /// Key for storing drift prompt dismissal preference
  static const String _driftPromptDismissedKey = 'drift_prompt_dismissed_';
  
  /// Key for storing last drift prompt date
  static const String _lastDriftPromptKey = 'last_drift_prompt_';
  
  TodayScreenController({
    required this.context,
    required this.appState,
  });
  
  // ========== Lifecycle Callbacks ==========
  
  /// Called when screen loads or app comes to foreground
  /// Checks if any dialogs should be shown
  void onScreenResumed() {
    if (appState.shouldShowRewardFlow) {
      showRewardDialog();
    } else if (appState.shouldShowRecoveryPrompt) {
      showRecoveryDialog();
    }
  }
  
  /// Phase 19: Check for drift and show suggestion dialog if appropriate
  /// Called during screen initialization or data refresh
  Future<void> checkForDriftSuggestion() async {
    final habit = appState.currentHabit;
    if (habit == null) return;
    
    // Check if user has dismissed drift prompts for this habit
    final prefs = await SharedPreferences.getInstance();
    final dismissedKey = '$_driftPromptDismissedKey${habit.id}';
    if (prefs.getBool(dismissedKey) == true) {
      debugPrint('⏰ Drift suggestion dismissed permanently for ${habit.name}');
      return;
    }
    
    // Check if we've shown a drift prompt recently (within 7 days)
    final lastPromptKey = '$_lastDriftPromptKey${habit.id}';
    final lastPromptTimestamp = prefs.getInt(lastPromptKey);
    if (lastPromptTimestamp != null) {
      final lastPrompt = DateTime.fromMillisecondsSinceEpoch(lastPromptTimestamp);
      final daysSinceLastPrompt = DateTime.now().difference(lastPrompt).inDays;
      if (daysSinceLastPrompt < 7) {
        debugPrint('⏰ Too soon to show drift suggestion ($daysSinceLastPrompt days ago)');
        return;
      }
    }
    
    // Get completion history from habit
    final completionHistory = habit.completionHistory;
    if (completionHistory.isEmpty) {
      debugPrint('⏰ No completion history for drift analysis');
      return;
    }
    
    // Run drift analysis
    final analysis = _driftDetector.analyze(
      completionHistory: completionHistory,
      scheduledTime: habit.implementationTime,
    );
    
    debugPrint('⏰ Drift analysis: ${analysis.toString()}');
    
    // Show dialog if drift is detected and should suggest
    if (analysis.shouldSuggest && analysis.suggestedTime != null && _isContextMounted) {
      // Record that we're showing a prompt
      await prefs.setInt(lastPromptKey, DateTime.now().millisecondsSinceEpoch);
      
      await showTimeDriftSuggestionDialog(
        context: context,
        analysis: analysis,
        habitName: habit.name,
        onAcceptSuggestion: (newTime) async {
          debugPrint('⏰ User accepted drift suggestion: $newTime');
          await appState.updateReminderTime(newTime);
          _showSnackBar('Reminder updated to $newTime');
        },
        onDismiss: () {
          debugPrint('⏰ User dismissed drift suggestion');
        },
        onDontShowAgain: () async {
          debugPrint('⏰ User chose to never show drift suggestion for ${habit.name}');
          await prefs.setBool(dismissedKey, true);
        },
      );
    }
  }
  
  // ========== Dialog Management ==========
  
  /// Shows the reward/investment dialog after habit completion
  void showRewardDialog() {
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
  
  /// Shows the "Never Miss Twice" recovery dialog
  void showRecoveryDialog() {
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
        onDoTinyVersion: () => _handleDoTinyVersion(dialogContext),
        onDismiss: () => _handleDismissRecovery(dialogContext),
        onMissReasonSelected: (reason) => _handleMissReasonSelected(reason),
      ),
    );
  }
  
  /// Shows the consistency details bottom sheet
  void showConsistencyDetails(dynamic habit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ConsistencyDetailsSheet(
        metrics: habit.consistencyMetrics,
        identityVotes: habit.identityVotes,
      ),
    );
  }
  
  /// Shows the improvement suggestions dialog
  Future<void> showImprovementSuggestions() async {
    // Show loading
    _showLoadingDialog('Getting optimization tips...');
    
    try {
      final allSuggestions = await appState.getAllSuggestionsForCurrentHabit();
      
      // Close loading
      if (_isContextMounted) Navigator.of(context).pop();
      
      final hasSuggestions = allSuggestions.values.any((list) => list.isNotEmpty);
      
      if (!hasSuggestions) {
        _showSnackBar('No suggestions available. Please try again later.');
        return;
      }

      if (_isContextMounted) {
        showDialog(
          context: context,
          builder: (dialogContext) => ImprovementSuggestionsDialog(
            suggestions: allSuggestions,
            onClose: () => Navigator.of(dialogContext).pop(),
          ),
        );
      }
    } catch (e) {
      if (_isContextMounted) Navigator.of(context).pop();
      _showSnackBar('Failed to get optimization tips. Please try again.');
    }
  }
  
  /// Shows the pre-habit ritual dialog
  void showPreHabitRitualDialog(String ritualText, VoidCallback onDismiss) {
    showDialog(
      context: context,
      builder: (dialogContext) => _buildPreHabitRitualDialog(ritualText, () {
        Navigator.of(dialogContext).pop();
        onDismiss();
      }),
    );
  }
  
  // ========== Action Handlers ==========
  
  /// Handles the "Mark as Complete" button press
  /// Phase 13: Updated to handle Chain Reaction flow for stacked habits
  /// Phase 18: Added visceral sound/haptic feedback for emotional payoff
  Future<void> handleCompleteHabit() async {
    debugPrint('🔘 Mark as Complete button pressed');
    
    final result = await appState.completeHabitForToday();
    
    debugPrint('📊 Was new completion: ${result.wasNewCompletion}');
    
    if (result.wasNewCompletion && _isContextMounted) {
      debugPrint('✨ Triggering reward dialog');
      
      // Phase 18: Visceral feedback - "The Clunk" 🔊
      // Make the emotional payoff visceral instead of boring boolean update
      try {
        final soundService = context.read<SoundService>();
        await FeedbackPatterns.completion(
          soundService,
          hapticsEnabled: appState.hapticsEnabled,
        );
        debugPrint('🔊 Completion feedback triggered');
      } catch (e) {
        debugPrint('🔊 SoundService not available: $e');
      }
      
      // Phase 13: Check for stacked habit (Chain Reaction)
      if (result.hasStackedHabit) {
        debugPrint('🔗 Chain Reaction: Showing stack prompt for ${result.nextStackedHabitName}');
        // Show Chain Reaction dialog instead of reward dialog
        _showStackPromptDialog(result);
      } else {
        // Normal flow - show reward dialog
        showRewardDialog();
      }
    } else if (!result.wasNewCompletion) {
      debugPrint('⚠️ Habit already completed today');
      _showSnackBar('Already completed for today!');
    }
  }
  
  /// Phase 13: Show Chain Reaction prompt dialog
  void _showStackPromptDialog(CompletionResult result) {
    if (!result.hasStackedHabit) return;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => StackPromptDialog(
        completedHabitName: result.completedHabitName,
        nextHabitName: result.nextStackedHabitName!,
        nextHabitEmoji: result.nextStackedHabitEmoji,
        nextHabitTinyVersion: result.nextStackedHabitTinyVersion,
        isBreakHabit: result.isNextStackedBreakHabit ?? false,
        onStartNow: () async {
          Navigator.of(dialogContext).pop();
          // Focus on the stacked habit and stay on Today screen
          appState.setFocusHabit(result.nextStackedHabitId!);
          // Dismiss reward flow since we're continuing to next habit
          appState.dismissRewardFlow();
        },
        onNotNow: () {
          Navigator.of(dialogContext).pop();
          // Show normal reward dialog after dismissing stack prompt
          showRewardDialog();
        },
      ),
    );
  }
  
  /// Handles navigation to settings
  void navigateToSettings() {
    Navigator.of(context).pushNamed('/settings');
  }
  
  /// Handles test notification button
  void handleTestNotification() {
    appState.showTestNotification();
  }
  
  // ========== Private Helpers ==========
  
  void _handleDoTinyVersion(BuildContext dialogContext) async {
    Navigator.of(dialogContext).pop();
    final result = await appState.completeHabitForToday(
      usedTinyVersion: true,
    );
    if (result.wasNewCompletion && _isContextMounted) {
      // Phase 18: Recovery feedback - "The Rise" 🔊
      // Triumphant sound for Never Miss Twice recovery
      try {
        final soundService = context.read<SoundService>();
        await FeedbackPatterns.recovery(
          soundService,
          hapticsEnabled: appState.hapticsEnabled,
        );
        debugPrint('🔊 Recovery feedback triggered');
      } catch (e) {
        debugPrint('🔊 SoundService not available: $e');
      }
      
      // Phase 13: Check for stacked habit (Chain Reaction)
      if (result.hasStackedHabit) {
        _showStackPromptDialog(result);
      } else {
        showRewardDialog();
      }
    }
  }
  
  void _handleDismissRecovery(BuildContext dialogContext) {
    Navigator.of(dialogContext).pop();
    appState.dismissRecoveryPrompt();
  }
  
  void _handleMissReasonSelected(MissReason reason) {
    appState.recordMissReason(reason);
    _showSnackBar('Got it - ${reason.label}. We\'ll help you work around that.');
  }
  
  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(message),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _showSnackBar(String message) {
    if (_isContextMounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  
  Widget _buildPreHabitRitualDialog(String ritualText, VoidCallback onDismiss) {
    // Import the actual dialog widget
    return Builder(
      builder: (context) {
        // Lazy import to avoid circular dependency
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.self_improvement, size: 48, color: Colors.purple),
                const SizedBox(height: 16),
                const Text('Pre-Habit Ritual', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text(ritualText, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onDismiss,
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  bool get _isContextMounted {
    try {
      // Check if context is still valid
      return context.mounted;
    } catch (e) {
      return false;
    }
  }
}

/// Extension to check if BuildContext is still mounted
extension BuildContextMounted on BuildContext {
  bool get mounted {
    try {
      // Try to access the widget - if it fails, context is not mounted
      (this as Element).widget;
      return true;
    } catch (e) {
      return false;
    }
  }
}
