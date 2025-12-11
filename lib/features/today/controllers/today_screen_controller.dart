import 'package:flutter/material.dart';
import '../../../data/app_state.dart';
import '../../../data/models/consistency_metrics.dart';
import '../../../widgets/reward_investment_dialog.dart';
import '../../../widgets/recovery_prompt_dialog.dart';
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
  Future<void> handleCompleteHabit() async {
    debugPrint('🔘 Mark as Complete button pressed');
    
    final wasNewCompletion = await appState.completeHabitForToday();
    
    debugPrint('📊 Was new completion: $wasNewCompletion');
    
    if (wasNewCompletion && _isContextMounted) {
      debugPrint('✨ Triggering reward dialog');
      showRewardDialog();
    } else if (!wasNewCompletion) {
      debugPrint('⚠️ Habit already completed today');
      _showSnackBar('Already completed for today!');
    }
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
    final wasNewCompletion = await appState.completeHabitForToday(
      usedTinyVersion: true,
    );
    if (wasNewCompletion && _isContextMounted) {
      showRewardDialog();
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
