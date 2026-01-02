/// JITAIInsightsCard - Timing and Pattern Insights Display
///
/// Shows users when and how to optimally complete their habits.
/// Displays:
/// - Current timing quality
/// - Optimal windows
/// - Historical patterns
/// - Cascade risks

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/jitai_provider.dart';

class JITAIInsightsCard extends StatelessWidget {
  final String? habitId;
  final bool showCascadeAlerts;
  final bool compact;

  const JITAIInsightsCard({
    super.key,
    this.habitId,
    this.showCascadeAlerts = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final jitai = context.watch<JITAIProvider>();

    if (!jitai.isInitialized || !jitai.isEnabled) {
      return const SizedBox.shrink();
    }

    final insights = jitai.timingInsights;
    final alerts = jitai.cascadeAlerts;

    if (insights.isEmpty && alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    if (compact) {
      return _buildCompactView(context, insights, alerts);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.insights_outlined,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Smart Timing',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                if (jitai.hasCascadeRisk)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 14,
                          color: Colors.orange.shade800,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Risk',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ...insights.map((insight) => _InsightRow(insight: insight)),
            if (showCascadeAlerts && alerts.isNotEmpty) ...[
              const Divider(height: 24),
              ...alerts.map((alert) => _AlertRow(alert: alert)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactView(
    BuildContext context,
    List<TimingInsight> insights,
    List<CascadeAlert> alerts,
  ) {
    // Show just the primary insight
    final primaryInsight = insights.isNotEmpty ? insights.first : null;
    final primaryAlert =
        alerts.isNotEmpty && alerts.first.severity > 0.5 ? alerts.first : null;

    if (primaryInsight == null && primaryAlert == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: primaryAlert != null
            ? Colors.orange.shade50
            : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            primaryAlert != null
                ? Icons.warning_amber_rounded
                : _iconForType(primaryInsight?.iconType ?? IconType.clock),
            size: 16,
            color: primaryAlert != null
                ? Colors.orange.shade700
                : Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              primaryAlert?.title ?? primaryInsight?.title ?? '',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: primaryAlert != null
                    ? Colors.orange.shade700
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          if (primaryInsight != null)
            _ScoreIndicator(score: primaryInsight.score, compact: true),
        ],
      ),
    );
  }

  IconData _iconForType(IconType type) {
    switch (type) {
      case IconType.clock:
        return Icons.access_time;
      case IconType.warning:
        return Icons.warning_amber_rounded;
      case IconType.checkCircle:
        return Icons.check_circle_outline;
      case IconType.trending:
        return Icons.trending_up;
      case IconType.calendar:
        return Icons.calendar_today;
      case IconType.heart:
        return Icons.favorite_outline;
    }
  }
}

class _InsightRow extends StatelessWidget {
  final TimingInsight insight;

  const _InsightRow({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _iconForType(insight.iconType),
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  insight.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          _ScoreIndicator(score: insight.score),
        ],
      ),
    );
  }

  IconData _iconForType(IconType type) {
    switch (type) {
      case IconType.clock:
        return Icons.access_time;
      case IconType.warning:
        return Icons.warning_amber_rounded;
      case IconType.checkCircle:
        return Icons.check_circle_outline;
      case IconType.trending:
        return Icons.trending_up;
      case IconType.calendar:
        return Icons.calendar_today;
      case IconType.heart:
        return Icons.favorite_outline;
    }
  }
}

class _AlertRow extends StatelessWidget {
  final CascadeAlert alert;

  const _AlertRow({required this.alert});

  @override
  Widget build(BuildContext context) {
    final color = _colorForSeverity(alert.severity);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 20,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alert.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      alert.suggestedAction,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _colorForSeverity(double severity) {
    if (severity >= 0.7) return Colors.red;
    if (severity >= 0.5) return Colors.orange;
    return Colors.amber;
  }
}

class _ScoreIndicator extends StatelessWidget {
  final double score;
  final bool compact;

  const _ScoreIndicator({required this.score, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final color = _colorForScore(score);

    if (compact) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '${(score * 100).round()}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: score,
                strokeWidth: 3,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              Text(
                '${(score * 100).round()}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _colorForScore(double score) {
    if (score >= 0.7) return Colors.green;
    if (score >= 0.4) return Colors.orange;
    return Colors.red;
  }
}
