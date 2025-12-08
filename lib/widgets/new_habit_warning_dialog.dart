import 'package:flutter/material.dart';

/// Dialog shown when user wants to add a new habit
/// Provides soft guidance based on Atomic Habits philosophy
/// Does NOT block - just informs and lets user decide
class NewHabitWarningDialog extends StatelessWidget {
  final String? warningMessage;
  final VoidCallback onProceed;
  final VoidCallback onCancel;

  const NewHabitWarningDialog({
    super.key,
    this.warningMessage,
    required this.onProceed,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // If no warning, show encouraging message
    if (warningMessage == null) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(Icons.add_circle, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            const Text('Add New Habit'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Great job on your progress!',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              'You\'re ready to add a new habit. Remember to keep it small '
              'and tie it to your identity.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: onCancel,
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: onProceed,
            child: const Text('Add Habit'),
          ),
        ],
      );
    }

    // Show warning with option to proceed anyway
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.amber[700]),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Before You Add...'),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Text(
              warningMessage!,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'You can still add a new habit if you\'re ready.',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Focus on Current'),
        ),
        FilledButton.tonal(
          onPressed: onProceed,
          child: const Text('Add Anyway'),
        ),
      ],
    );
  }

  /// Show the dialog and return true if user wants to proceed
  static Future<bool> show(BuildContext context, String? warningMessage) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => NewHabitWarningDialog(
        warningMessage: warningMessage,
        onProceed: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
    return result ?? false;
  }
}
