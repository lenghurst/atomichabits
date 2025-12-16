/// Phase 19: The Intelligent Nudge - Time Drift Suggestion Dialog
/// 
/// A modal dialog that suggests time changes based on drift analysis.
/// Shows when the app detects that the user consistently completes
/// habits at a different time than scheduled.
/// 
/// Philosophy: "The app should observe what you do, not just what you say you'll do."

import 'package:flutter/material.dart';
import '../data/services/smart_nudge/drift_analysis.dart' as drift;
import '../data/services/sound_service.dart';

/// Dialog that suggests updating habit reminder time based on detected drift
class TimeDriftSuggestionDialog extends StatefulWidget {
  /// The drift analysis result
  final drift.DriftAnalysis driftAnalysis;
  
  /// The habit name being analyzed
  final String habitName;
  
  /// Callback when user accepts the time change
  final void Function(String newTime) onAcceptSuggestion;
  
  /// Callback when user dismisses the dialog
  final VoidCallback? onDismiss;
  
  /// Whether to show "Don't show again" option
  final bool showDontShowAgain;
  
  /// Callback when user taps "Don't show again"
  final VoidCallback? onDontShowAgain;

  const TimeDriftSuggestionDialog({
    super.key,
    required this.driftAnalysis,
    required this.habitName,
    required this.onAcceptSuggestion,
    this.onDismiss,
    this.showDontShowAgain = true,
    this.onDontShowAgain,
  });

  @override
  State<TimeDriftSuggestionDialog> createState() => _TimeDriftSuggestionDialogState();
}

class _TimeDriftSuggestionDialogState extends State<TimeDriftSuggestionDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatDrift(int driftMinutes) {
    final absDrift = driftMinutes.abs();
    final hours = absDrift ~/ 60;
    final mins = absDrift % 60;
    final direction = driftMinutes > 0 ? 'later' : 'earlier';
    
    if (hours > 0 && mins > 0) {
      return '${hours}h ${mins}m $direction';
    } else if (hours > 0) {
      return '${hours} hour${hours > 1 ? 's' : ''} $direction';
    } else {
      return '$mins minutes $direction';
    }
  }

  @override
  Widget build(BuildContext context) {
    final analysis = widget.driftAnalysis;
    final suggestedTime = analysis.suggestedTime;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with clock icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.shade400,
                            Colors.orange.shade400,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.schedule,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Time Update Found',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.habitName,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Insight message
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? Colors.grey.shade800 
                        : Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark 
                          ? Colors.grey.shade700 
                          : Colors.amber.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        analysis.description,
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.black87,
                          height: 1.4,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Stats row
                      Row(
                        children: [
                          _buildStatBadge(
                            icon: Icons.trending_flat,
                            label: _formatDrift(analysis.driftMinutes),
                            isDark: isDark,
                          ),
                          const SizedBox(width: 8),
                          _buildStatBadge(
                            icon: Icons.bar_chart,
                            label: '${(analysis.confidence * 100).toInt()}% confident',
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Time comparison
                if (suggestedTime != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeCard(
                          label: 'Current',
                          time: analysis.scheduledTime.formatAmPm(),
                          isOld: true,
                          isDark: isDark,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(
                          Icons.arrow_forward,
                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                        ),
                      ),
                      Expanded(
                        child: _buildTimeCard(
                          label: 'Suggested',
                          time: suggestedTime.formatAmPm(),
                          isOld: false,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                ],
                
                // Action buttons
                Row(
                  children: [
                    // Dismiss button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          widget.onDismiss?.call();
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          'Keep Current',
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Accept button
                    if (suggestedTime != null)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Trigger haptic and sound feedback
                            SoundService().playNudge();
                            
                            widget.onAcceptSuggestion(suggestedTime.format());
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.orange.shade400,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Update Time',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
                
                // Don't show again option
                if (widget.showDontShowAgain) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        widget.onDontShowAgain?.call();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Don't suggest this again",
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade700 : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon, 
            size: 14, 
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard({
    required String label,
    required String time,
    required bool isOld,
    required bool isDark,
  }) {
    final color = isOld 
        ? (isDark ? Colors.grey.shade600 : Colors.grey.shade400)
        : Colors.orange;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark 
            ? (isOld ? Colors.grey.shade800 : Colors.orange.shade900.withOpacity(0.3))
            : (isOld ? Colors.grey.shade100 : Colors.orange.shade50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOld 
              ? (isDark ? Colors.grey.shade700 : Colors.grey.shade300)
              : Colors.orange.shade300,
          width: isOld ? 1 : 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
              decoration: isOld ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper function to show the drift suggestion dialog
Future<void> showTimeDriftSuggestionDialog({
  required BuildContext context,
  required drift.DriftAnalysis analysis,
  required String habitName,
  required void Function(String newTime) onAcceptSuggestion,
  VoidCallback? onDismiss,
  VoidCallback? onDontShowAgain,
}) async {
  // Only show if there's a suggestion
  if (!analysis.shouldSuggest || analysis.suggestedTime == null) {
    return;
  }
  
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => TimeDriftSuggestionDialog(
      driftAnalysis: analysis,
      habitName: habitName,
      onAcceptSuggestion: onAcceptSuggestion,
      onDismiss: onDismiss,
      onDontShowAgain: onDontShowAgain,
    ),
  );
}
