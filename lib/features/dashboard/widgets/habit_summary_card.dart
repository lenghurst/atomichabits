import 'package:flutter/material.dart';
import '../../../data/models/habit.dart';

/// Summary card for a single habit in the dashboard
/// 
/// Shows:
/// - Habit name and emoji
/// - Tiny version
/// - Graceful Consistency score with progress bar
/// - Completion status for today
/// - Quick complete button
class HabitSummaryCard extends StatelessWidget {
  final Habit habit;
  final int index;
  final bool isCompleted;
  final VoidCallback onTap;
  final VoidCallback onQuickComplete;

  const HabitSummaryCard({
    super.key,
    required this.habit,
    required this.index,
    required this.isCompleted,
    required this.onTap,
    required this.onQuickComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final score = habit.gracefulScore;
    final scoreColor = _getScoreColor(score);

    return Card(
      elevation: isCompleted ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isCompleted
            ? BorderSide(color: Colors.green.withOpacity(0.3), width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: Emoji + Name + Status
              Row(
                children: [
                  // Habit emoji or default icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        habit.habitEmoji ?? _getDefaultEmoji(index),
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Name and tiny version
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                            color: isCompleted ? colorScheme.onSurfaceVariant : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          habit.tinyVersion,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Quick complete button
                  _buildCompletionButton(context),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Progress bar and stats row
              Row(
                children: [
                  // Score progress bar
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Consistency',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '${score.toInt()}%',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: scoreColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: score / 100,
                            backgroundColor: colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Streak badge
                  _buildStreakBadge(context),
                ],
              ),
              
              // Additional info row (if has interesting data)
              if (_shouldShowExtraInfo()) ...[
                const SizedBox(height: 12),
                _buildExtraInfoRow(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionButton(BuildContext context) {
    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 28,
        ),
      );
    }

    return Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onQuickComplete,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            Icons.check_circle_outline,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildStreakBadge(BuildContext context) {
    final streak = habit.currentStreak;
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: streak > 0
            ? Colors.orange.withOpacity(0.1)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            size: 16,
            color: streak > 0 ? Colors.orange : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: streak > 0 ? Colors.orange.shade700 : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowExtraInfo() {
    return habit.isPrimaryHabit ||
        habit.needsRecovery ||
        habit.isInFocusCycle ||
        (habit.temptationBundle != null && habit.temptationBundle!.isNotEmpty);
  }

  Widget _buildExtraInfoRow(BuildContext context) {
    final theme = Theme.of(context);
    final chips = <Widget>[];

    if (habit.isPrimaryHabit) {
      chips.add(_buildInfoChip(
        context,
        Icons.star,
        'Primary',
        Colors.amber,
      ));
    }

    if (habit.needsRecovery) {
      chips.add(_buildInfoChip(
        context,
        Icons.refresh,
        'Recovery',
        Colors.blue,
      ));
    }

    if (habit.isInFocusCycle) {
      final daysLeft = habit.focusCycleDaysRemaining;
      chips.add(_buildInfoChip(
        context,
        Icons.timer,
        '$daysLeft days left',
        Colors.purple,
      ));
    }

    if (habit.isBreakHabit) {
      chips.add(_buildInfoChip(
        context,
        Icons.block,
        'Breaking',
        Colors.red,
      ));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: chips,
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 70) return Colors.blue;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  String _getDefaultEmoji(int index) {
    const emojis = ['📚', '🏃', '🧘', '💪', '🎯', '✨', '🌟', '🔥', '💡', '🎨'];
    return emojis[index % emojis.length];
  }
}
