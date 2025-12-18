import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// CompletionButton - Shows either "Mark as Complete" or completion status
/// 
/// Purely presentational - receives completion state and callback via props.
/// 
/// **Phase 12: Bad Habit Protocol**
/// For break habits (isBreakHabit=true):
/// - Action text: "I Stayed Strong" instead of "Mark as Complete"
/// - Completed text: "Avoided today!" instead of "Completed for today!"
/// - Purple color scheme instead of green
/// 
/// **Phase 25.7: The Golden Minute**
/// - Implements "Heavy Seal" haptic pattern on press.
class CompletionButton extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback onComplete;
  final bool isBreakHabit;
  
  const CompletionButton({
    super.key,
    required this.isCompleted,
    required this.onComplete,
    this.isBreakHabit = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return _CompletedStatus(isBreakHabit: isBreakHabit);
    }
    return _CompleteButton(onComplete: onComplete, isBreakHabit: isBreakHabit);
  }
}

class _CompleteButton extends StatelessWidget {
  final VoidCallback onComplete;
  final bool isBreakHabit;
  
  const _CompleteButton({required this.onComplete, required this.isBreakHabit});

  Future<void> _handlePress() async {
    // The "Heavy Seal" Pattern
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 300));
    await HapticFeedback.vibrate(); // Long vibration for the "Seal" melting
    
    onComplete();
  }

  @override
  Widget build(BuildContext context) {
    // Phase 12: Different text and color for break habits
    final buttonColor = isBreakHabit ? Colors.purple : Colors.green;
    final buttonText = isBreakHabit ? 'I Stayed Strong Today' : 'Mark as Complete ✓';
    final buttonIcon = isBreakHabit ? Icons.shield : Icons.check;
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _handlePress,
        icon: Icon(buttonIcon, size: 24),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
        ),
        label: Text(
          buttonText,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _CompletedStatus extends StatelessWidget {
  final bool isBreakHabit;
  
  const _CompletedStatus({required this.isBreakHabit});
  
  @override
  Widget build(BuildContext context) {
    // Phase 12: Different text, color, and icon for break habits
    final statusColor = isBreakHabit ? Colors.purple : Colors.green;
    final bgColor = isBreakHabit ? Colors.purple.shade50 : Colors.green.shade50;
    final statusText = isBreakHabit ? 'Avoided today!' : 'Completed for today! 🎉';
    final statusIcon = isBreakHabit ? Icons.shield : Icons.check_circle;
    final statusEmoji = isBreakHabit ? '💪' : '🎉';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(statusIcon, color: statusColor),
          const SizedBox(width: 8),
          Text(
            '$statusText $statusEmoji',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}
