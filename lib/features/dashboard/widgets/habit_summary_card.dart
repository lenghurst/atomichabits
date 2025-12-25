import 'package:flutter/material.dart';
import '../../../data/models/habit.dart';

/// Summary card for a single habit in the dashboard
/// 
/// Shows:
/// - Habit name and emoji
/// - Tiny version (or substitution plan for break habits)
/// - Graceful Consistency score with progress bar
/// - Completion status for today
/// - Quick complete button
/// 
/// **Phase 12: Bad Habit Protocol**
/// For break habits (isBreakHabit=true):
/// - Avoidance = completion (tracked via completionHistory)
/// - Streak label changes to "Days Habit-Free"
/// - Color palette shifts to emphasize avoidance
/// - Action text changes to "Stayed Strong" / "Avoided"
class HabitSummaryCard extends StatelessWidget {
  final Habit habit;
  final int index;
  final bool isCompleted;
  final VoidCallback onTap;
  final VoidCallback onQuickComplete;
  final VoidCallback? onEdit; // Phase 13: Edit callback for stacking config

  const HabitSummaryCard({
    super.key,
    required this.habit,
    required this.index,
    required this.isCompleted,
    required this.onTap,
    required this.onQuickComplete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final score = habit.gracefulScore;
    final scoreColor = _getScoreColor(score);
    
    // Phase 12: Break habit color adjustments
    final isBreakHabit = habit.isBreakHabit;
    final completedColor = isBreakHabit ? Colors.purple : Colors.green;

    return Card(
      elevation: isCompleted ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isCompleted
            ? BorderSide(color: completedColor.withOpacity(0.3), width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onEdit, // Phase 13: Long-press to edit
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
                  
                  // Name and tiny version (or substitution for break habits)
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
                          // Phase 12: Show substitution plan for break habits
                          isBreakHabit && habit.substitutionPlan != null && habit.substitutionPlan!.isNotEmpty
                              ? habit.substitutionPlan!
                              : habit.tinyVersion,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isBreakHabit ? Colors.purple.shade700 : colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Quick complete button
                  _buildCompletionButton(context, isBreakHabit),
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
                              // Phase 12: Abstinence Rate for break habits
                              isBreakHabit ? 'Abstinence Rate' : 'Consistency',
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
                  _buildStreakBadge(context, isBreakHabit),
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

  Widget _buildCompletionButton(BuildContext context, bool isBreakHabit) {
    // Phase 12: Different colors and icons for break habits
    final completedColor = isBreakHabit ? Colors.purple : Colors.green;
    final completedIcon = isBreakHabit ? Icons.shield : Icons.check_circle;
    final incompleteIcon = isBreakHabit ? Icons.shield_outlined : Icons.check_circle_outline;
    
    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: completedColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          completedIcon,
          color: completedColor,
          size: 28,
        ),
      );
    }

    return Material(
      color: isBreakHabit 
          ? Colors.purple.withOpacity(0.1) 
          : Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onQuickComplete,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            incompleteIcon,
            color: isBreakHabit ? Colors.purple : Theme.of(context).colorScheme.primary,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildStreakBadge(BuildContext context, bool isBreakHabit) {
    final streak = habit.currentStreak;
    final theme = Theme.of(context);
    
    // Phase 12: Different styling for break habits
    final activeColor = isBreakHabit ? Colors.purple : Colors.orange;
    final activeDarkColor = isBreakHabit ? Colors.purple.shade700 : Colors.orange.shade700;
    final icon = isBreakHabit ? Icons.shield : Icons.local_fire_department;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: streak > 0
            ? activeColor.withOpacity(0.1)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: streak > 0 ? activeColor : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$streak',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: streak > 0 ? activeDarkColor : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (isBreakHabit)
                Text(
                  'free',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 8,
                    color: streak > 0 ? activeDarkColor : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  bool _shouldShowExtraInfo() {
    return habit.isPrimaryHabit ||
        habit.needsRecovery ||
        habit.isInFocusCycle ||
        habit.isStacked ||  // Phase 13: Show stacking info
        (habit.temptationBundle != null && habit.temptationBundle!.isNotEmpty);
  }

  Widget _buildExtraInfoRow(BuildContext context) {
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
        Colors.purple,
      ));
    }

    // Phase 13: Show stacking indicator
    if (habit.isStacked) {
      chips.add(_buildInfoChip(
        context,
        Icons.link,
        habit.stackPosition == 'after' 
            ? 'After ${habit.anchorDescription}' 
            : 'Before ${habit.anchorDescription}',
        Colors.teal,
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
