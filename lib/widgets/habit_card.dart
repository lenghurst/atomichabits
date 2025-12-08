import 'package:flutter/material.dart';
import '../data/models/habit.dart';

/// A card displaying a single habit with completion status and actions
class HabitCard extends StatelessWidget {
  final Habit habit;
  final bool isPrimary;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onSetPrimary;

  const HabitCard({
    super.key,
    required this.habit,
    this.isPrimary = false,
    this.onTap,
    this.onComplete,
    this.onSetPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = habit.isCompletedToday;

    return Card(
      elevation: isPrimary ? 2 : 0,
      color: isPrimary
          ? theme.colorScheme.primaryContainer.withOpacity(0.3)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isPrimary
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: name + status
              Row(
                children: [
                  // Completion checkbox
                  _buildCompletionButton(context, isCompleted),
                  const SizedBox(width: 12),

                  // Habit name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: isCompleted
                                ? theme.colorScheme.onSurfaceVariant
                                : null,
                          ),
                        ),
                        if (isPrimary) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 12,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Primary Focus',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Streak badge
                  _buildStreakBadge(context),
                ],
              ),

              const SizedBox(height: 8),

              // Tiny version
              Text(
                '2-min version: ${habit.tinyVersion}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),

              // Health indicator (if not new habit)
              if (habit.totalCompletions > 0) ...[
                const SizedBox(height: 8),
                _buildHealthIndicator(context),
              ],

              // Actions row (only if not primary)
              if (!isPrimary && onSetPrimary != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onSetPrimary,
                      icon: const Icon(Icons.star_outline, size: 18),
                      label: const Text('Make Primary'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionButton(BuildContext context, bool isCompleted) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: isCompleted ? null : onComplete,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isCompleted
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: isCompleted
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: 2,
          ),
        ),
        child: isCompleted
            ? Icon(
                Icons.check,
                size: 20,
                color: theme.colorScheme.onPrimary,
              )
            : null,
      ),
    );
  }

  Widget _buildStreakBadge(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: habit.currentStreak > 0
            ? Colors.orange.withOpacity(0.15)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            size: 16,
            color: habit.currentStreak > 0 ? Colors.orange : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            '${habit.currentStreak}',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: habit.currentStreak > 0 ? Colors.orange[800] : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final health = habit.healthScore;

    Color healthColor;
    String healthLabel;
    if (health >= 0.7) {
      healthColor = Colors.green;
      healthLabel = 'Strong';
    } else if (health >= 0.4) {
      healthColor = Colors.orange;
      healthLabel = 'Building';
    } else {
      healthColor = Colors.red;
      healthLabel = 'Needs attention';
    }

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: health,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: healthColor,
              minHeight: 4,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          healthLabel,
          style: theme.textTheme.labelSmall?.copyWith(
            color: healthColor,
          ),
        ),
      ],
    );
  }
}
