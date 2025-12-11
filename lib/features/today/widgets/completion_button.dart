import 'package:flutter/material.dart';

/// CompletionButton - Shows either "Mark as Complete" or completion status
/// 
/// Purely presentational - receives completion state and callback via props.
class CompletionButton extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback onComplete;
  
  const CompletionButton({
    super.key,
    required this.isCompleted,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return _CompletedStatus();
    }
    return _CompleteButton(onComplete: onComplete);
  }
}

class _CompleteButton extends StatelessWidget {
  final VoidCallback onComplete;
  
  const _CompleteButton({required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onComplete,
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
    );
  }
}

class _CompletedStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 8),
          Text(
            'Completed for today! 🎉',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
