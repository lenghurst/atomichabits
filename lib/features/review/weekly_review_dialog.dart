import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/habit.dart';
import '../../data/services/weekly_review_service.dart';

/// Dialog for displaying AI-generated weekly habit reviews
/// 
/// Part of Phase 7: Analytics & Expansion
/// 
/// Shows:
/// - 7-day visual progress (emoji dots)
/// - Key stats (graceful score, identity votes)
/// - AI-generated personalized review
class WeeklyReviewDialog extends StatefulWidget {
  final Habit habit;

  const WeeklyReviewDialog({
    super.key,
    required this.habit,
  });

  /// Show the weekly review dialog for a habit
  static Future<void> show(BuildContext context, Habit habit) async {
    await showDialog(
      context: context,
      builder: (context) => WeeklyReviewDialog(habit: habit),
    );
  }

  @override
  State<WeeklyReviewDialog> createState() => _WeeklyReviewDialogState();
}

class _WeeklyReviewDialogState extends State<WeeklyReviewDialog> {
  WeeklyReviewResult? _result;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generateReview();
  }

  Future<void> _generateReview() async {
    try {
      final reviewService = context.read<WeeklyReviewService>();
      final result = await reviewService.generateReview(widget.habit);
      
      if (mounted) {
        setState(() {
          _result = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Unable to generate review. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _isLoading
              ? _buildLoadingState(theme)
              : _error != null
                  ? _buildErrorState(theme)
                  : _buildContent(theme, colorScheme),
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(
          'Generating your weekly review...',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '✨ Powered by AI',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.error_outline,
          size: 48,
          color: theme.colorScheme.error,
        ),
        const SizedBox(height: 16),
        Text(
          _error!,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            setState(() {
              _isLoading = true;
              _error = null;
            });
            _generateReview();
          },
          child: const Text('Try Again'),
        ),
      ],
    );
  }

  Widget _buildContent(ThemeData theme, ColorScheme colorScheme) {
    final result = _result!;
    final stats = result.stats;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.habit.habitEmoji ?? '📊',
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Review',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.habit.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // 7-day progress dots
        _buildWeekProgress(theme, colorScheme, stats),
        
        const SizedBox(height: 20),
        
        // Stats row
        _buildStatsRow(theme, colorScheme, stats),
        
        const SizedBox(height: 20),
        
        // AI Review text
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    result.isAiGenerated ? Icons.auto_awesome : Icons.lightbulb_outline,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    result.isAiGenerated ? 'AI Coach Insight' : 'Weekly Insight',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                result.reviewText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Close button
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekProgress(ThemeData theme, ColorScheme colorScheme, WeeklyStats stats) {
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final now = DateTime.now();
    
    // Calculate which day index each history entry corresponds to
    final dayIndices = <int>[];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      dayIndices.add((date.weekday - 1) % 7); // Monday = 0
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last 7 Days',
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (index) {
            final status = stats.weekHistory[index];
            final dayIndex = dayIndices[index];
            final isToday = index == 6;
            
            return Column(
              children: [
                Text(
                  dayLabels[dayIndex],
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isToday 
                        ? colorScheme.primary 
                        : colorScheme.onSurfaceVariant,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _getStatusColor(status, colorScheme),
                    shape: BoxShape.circle,
                    border: isToday
                        ? Border.all(color: colorScheme.primary, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      _getStatusEmoji(status),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Color _getStatusColor(DayStatus status, ColorScheme colorScheme) {
    switch (status) {
      case DayStatus.completed:
        return Colors.green.withValues(alpha: 0.2);
      case DayStatus.missed:
        return Colors.red.withValues(alpha: 0.1);
      case DayStatus.pending:
        return colorScheme.surfaceContainerHighest;
    }
  }

  String _getStatusEmoji(DayStatus status) {
    switch (status) {
      case DayStatus.completed:
        return '✅';
      case DayStatus.missed:
        return '❌';
      case DayStatus.pending:
        return '⏳';
    }
  }

  Widget _buildStatsRow(ThemeData theme, ColorScheme colorScheme, WeeklyStats stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            theme,
            colorScheme,
            '${stats.daysCompleted}/7',
            'This Week',
            Icons.calendar_today_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            theme,
            colorScheme,
            stats.gracefulScore.toStringAsFixed(0),
            'Score',
            Icons.trending_up,
            badge: stats.scoreChange != 0
                ? '${stats.scoreChange >= 0 ? '+' : ''}${stats.scoreChange.toStringAsFixed(0)}'
                : null,
            badgeColor: stats.scoreChange >= 0 ? Colors.green : Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            theme,
            colorScheme,
            '${stats.totalIdentityVotes}',
            'Votes',
            Icons.how_to_vote_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    ColorScheme colorScheme,
    String value,
    String label,
    IconData icon, {
    String? badge,
    Color? badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: badgeColor?.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: badgeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
