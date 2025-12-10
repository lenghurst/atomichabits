import 'package:flutter/material.dart';

/// "Never Miss Twice" Recovery Dialog
///
/// Shown when user opens the app after missing 1+ days.
/// Based on James Clear's principle: "Missing once is an accident.
/// Missing twice is the start of a new habit."
///
/// Key principles:
/// - No shame or guilt
/// - Offer the 2-minute minimum version
/// - Celebrate showing up, not perfection
/// - Frame as identity reinforcement
class NeverMissTwiceDialog extends StatelessWidget {
  final int daysMissed;
  final String habitName;
  final String tinyVersion;
  final String identity;
  final int daysShowedUp; // Total days user has shown up (never resets)
  final int neverMissTwiceWins; // Previous recovery wins
  final VoidCallback onDoMinimumVersion;
  final VoidCallback onDoFullHabit;
  final VoidCallback onDismiss;

  const NeverMissTwiceDialog({
    super.key,
    required this.daysMissed,
    required this.habitName,
    required this.tinyVersion,
    required this.identity,
    required this.daysShowedUp,
    required this.neverMissTwiceWins,
    required this.onDoMinimumVersion,
    required this.onDoFullHabit,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSingleDayMiss = daysMissed == 2; // daysSinceLast == 2 means missed 1 day

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon - different based on situation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSingleDayMiss
                    ? Colors.amber.shade50
                    : Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSingleDayMiss
                    ? Icons.wb_sunny_outlined
                    : Icons.waving_hand,
                size: 48,
                color: isSingleDayMiss
                    ? Colors.amber.shade700
                    : Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 20),

            // Title - encouraging, not shaming
            Text(
              isSingleDayMiss
                  ? 'You missed yesterday'
                  : 'Welcome back!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message - James Clear framing
            Text(
              isSingleDayMiss
                  ? 'That\'s okay — it happens to everyone.\n\n'
                    '"Missing once is an accident.\nMissing twice is the start of a new habit."'
                  : 'It\'s been ${daysMissed - 1} days since your last check-in.\n\n'
                    'The fact that you\'re here now? That\'s what matters.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Show cumulative progress (never resets)
            if (daysShowedUp > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'You\'ve shown up $daysShowedUp ${daysShowedUp == 1 ? 'time' : 'times'} total',
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Show "Never Miss Twice" wins if any
            if (neverMissTwiceWins > 0) ...[
              Text(
                'You\'ve bounced back $neverMissTwiceWins ${neverMissTwiceWins == 1 ? 'time' : 'times'} before. You can do it again.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ] else ...[
              const SizedBox(height: 8),
            ],

            // Identity reinforcement
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.purple.shade400, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You are someone who $identity',
                      style: TextStyle(
                        color: Colors.purple.shade800,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Primary action: Do the minimum version
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onDoMinimumVersion,
                icon: const Icon(Icons.timer),
                label: Text(
                  'Just do: $tinyVersion',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Secondary action: Do full habit
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onDoFullHabit,
                child: Text(
                  'I\'ll do the full $habitName',
                  style: const TextStyle(fontSize: 15),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Dismiss (but keep visible)
            TextButton(
              onPressed: onDismiss,
              child: Text(
                'Remind me later',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
