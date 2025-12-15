import 'package:flutter/material.dart';

/// Stack Prompt Dialog - Phase 13: Habit Stacking
/// 
/// Shows the "Chain Reaction" prompt after completing a habit
/// that has stacked habits waiting to be done next.
/// 
/// Philosophy: "After [COMPLETED HABIT], I will [NEXT HABIT]"
/// This leverages existing momentum to build new behaviors.
class StackPromptDialog extends StatelessWidget {
  final String completedHabitName;
  final String nextHabitName;
  final String? nextHabitEmoji;
  final String? nextHabitTinyVersion;
  final bool isBreakHabit;
  final VoidCallback onStartNow;
  final VoidCallback onNotNow;

  const StackPromptDialog({
    super.key,
    required this.completedHabitName,
    required this.nextHabitName,
    this.nextHabitEmoji,
    this.nextHabitTinyVersion,
    this.isBreakHabit = false,
    required this.onStartNow,
    required this.onNotNow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Use purple for break habits, green for build habits
    final accentColor = isBreakHabit ? Colors.purple : Colors.green;
    final actionText = isBreakHabit ? 'Stay Strong' : "Let's Do It";
    final actionDescription = isBreakHabit 
        ? 'Keep your momentum going by avoiding' 
        : 'Continue your momentum with';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Chain Reaction Header
            _buildHeader(accentColor),
            
            const SizedBox(height: 20),
            
            // Completed Habit Badge
            _buildCompletedBadge(colorScheme),
            
            const SizedBox(height: 16),
            
            // Chain Link Animation
            Icon(
              Icons.arrow_downward,
              color: accentColor.withOpacity(0.7),
              size: 24,
            ),
            
            const SizedBox(height: 16),
            
            // Next Habit Card
            _buildNextHabitCard(context, accentColor, actionDescription),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            _buildActionButtons(context, accentColor, actionText),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color accentColor) {
    return Column(
      children: [
        // Chain Link Icon
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.link,
            color: accentColor,
            size: 32,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Chain Reaction!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'You\'ve built momentum!',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedBadge(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              completedHabitName,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.green,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextHabitCard(BuildContext context, Color accentColor, String actionDescription) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            actionDescription,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (nextHabitEmoji != null) ...[
                Text(
                  nextHabitEmoji!,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  nextHabitName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          if (nextHabitTinyVersion != null) ...[
            const SizedBox(height: 8),
            Text(
              isBreakHabit 
                  ? 'Remember: $nextHabitTinyVersion'
                  : 'Just: $nextHabitTinyVersion',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Color accentColor, String actionText) {
    return Column(
      children: [
        // Primary Action: Start Now
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onStartNow,
            icon: Icon(isBreakHabit ? Icons.shield : Icons.play_arrow),
            label: Text(actionText),
            style: FilledButton.styleFrom(
              backgroundColor: accentColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Secondary Action: Not Now
        TextButton(
          onPressed: onNotNow,
          child: Text(
            'Not right now',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }
}

/// Compact Stack Prompt for use in snackbars or smaller UI contexts
class CompactStackPrompt extends StatelessWidget {
  final String nextHabitName;
  final String? nextHabitEmoji;
  final bool isBreakHabit;
  final VoidCallback onTap;

  const CompactStackPrompt({
    super.key,
    required this.nextHabitName,
    this.nextHabitEmoji,
    this.isBreakHabit = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = isBreakHabit ? Colors.purple : Colors.green;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.link, color: accentColor, size: 16),
            const SizedBox(width: 8),
            Text(
              'Chain: ${nextHabitEmoji ?? ''} $nextHabitName',
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_forward, color: accentColor, size: 14),
          ],
        ),
      ),
    );
  }
}
