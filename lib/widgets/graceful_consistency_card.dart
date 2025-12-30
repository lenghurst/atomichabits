import 'package:flutter/material.dart';
import '../data/models/consistency_metrics.dart';

/// Graceful Consistency Card - Shows holistic consistency metrics
/// 
/// Replaces the traditional "streak counter" with a more encouraging,
/// multi-dimensional view of habit consistency that:
/// - Emphasizes overall consistency over perfect streaks
/// - Celebrates recoveries (bouncing back from misses)
/// - Shows "Never Miss Twice" success rate
/// - De-emphasizes but still shows current streak
/// 
/// Philosophy: "Graceful Consistency > Fragile Streaks"
class GracefulConsistencyCard extends StatelessWidget {
  final ConsistencyMetrics metrics;
  final int identityVotes;
  final bool showDetailedMetrics;
  final VoidCallback? onTap;
  
  const GracefulConsistencyCard({
    super.key,
    required this.metrics,
    required this.identityVotes,
    this.showDetailedMetrics = true,
    this.onTap,
  });

  Color _getScoreColor() {
    if (metrics.gracefulScore >= 80) return Colors.green;
    if (metrics.gracefulScore >= 60) return Colors.teal;
    if (metrics.gracefulScore >= 40) return Colors.orange;
    if (metrics.gracefulScore >= 20) return Colors.amber;
    return Colors.blue; // Fresh start, still positive
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getScoreColor().shade400,
            _getScoreColor().shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getScoreColor().withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Header with title and emoji
            Row(
              children: [
                Text(
                  metrics.scoreEmoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Consistency Score',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        metrics.scoreDescription,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Main score display
            Center(
              child: Column(
                children: [
                  Text(
                    metrics.gracefulScore.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (metrics.scoreChange != 0) ...[
                        Icon(
                          metrics.scoreChange > 0 
                              ? Icons.arrow_upward 
                              : Icons.arrow_downward,
                          size: 14,
                          color: metrics.scoreChange > 0 
                              ? Colors.greenAccent 
                              : Colors.redAccent,
                        ),
                        Text(
                          '${metrics.scoreChange > 0 ? '+' : ''}${metrics.scoreChange.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: metrics.scoreChange > 0 
                                ? Colors.greenAccent 
                                : Colors.redAccent,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      const Text(
                        'out of 100',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            if (showDetailedMetrics) ...[
              const SizedBox(height: 20),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 16),
              
              // Detailed metrics grid
              Row(
                children: [
                  // Weekly average
                  Expanded(
                    child: _MetricTile(
                      icon: Icons.calendar_today,
                      label: '7-Day',
                      value: '${(metrics.weeklyAverage * 100).toStringAsFixed(0)}%',
                    ),
                  ),
                  // Identity votes
                  Expanded(
                    child: _MetricTile(
                      icon: Icons.how_to_vote,
                      label: 'Identity Votes',
                      value: '$identityVotes',
                    ),
                  ),
                  // Never miss twice rate
                  Expanded(
                    child: _MetricTile(
                      icon: Icons.shield,
                      label: 'NMT Rate',
                      value: '${(metrics.neverMissTwiceRate * 100).toStringAsFixed(0)}%',
                      tooltip: 'Never Miss Twice success rate',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Recoveries
                  Expanded(
                    child: _MetricTile(
                      icon: Icons.replay,
                      label: 'Recoveries',
                      value: '${metrics.quickRecoveryCount}/${metrics.recoveryCount}',
                      tooltip: 'Quick recoveries / Total recoveries',
                    ),
                  ),
                  // Current streak (de-emphasized)
                  Expanded(
                    child: _MetricTile(
                      icon: Icons.local_fire_department,
                      label: 'Streak',
                      value: '${metrics.currentStreak}d',
                      deEmphasized: true,
                    ),
                  ),
                  // Best streak
                  Expanded(
                    child: _MetricTile(
                      icon: Icons.emoji_events,
                      label: 'Best',
                      value: '${metrics.longestStreak}d',
                      deEmphasized: true,
                    ),
                  ),
                ],
              ),
            ],
            
            // Tap hint
            if (onTap != null) ...[
              const SizedBox(height: 12),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.touch_app,
                      size: 14,
                      color: Colors.white54,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Tap for details',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Individual metric tile for the detailed grid
class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? tooltip;
  final bool deEmphasized;
  
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    this.tooltip,
    this.deEmphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        Icon(
          icon,
          size: 18,
          color: deEmphasized ? Colors.white38 : Colors.white70,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: deEmphasized ? Colors.white54 : Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: deEmphasized ? Colors.white38 : Colors.white60,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
    
    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: content,
      );
    }
    
    return content;
  }
}

/// Compact version of the consistency card (for smaller spaces)
class GracefulConsistencyCompact extends StatelessWidget {
  final ConsistencyMetrics metrics;
  final VoidCallback? onTap;
  
  const GracefulConsistencyCompact({
    super.key,
    required this.metrics,
    this.onTap,
  });

  Color _getScoreColor() {
    if (metrics.gracefulScore >= 80) return Colors.green;
    if (metrics.gracefulScore >= 60) return Colors.teal;
    if (metrics.gracefulScore >= 40) return Colors.orange;
    if (metrics.gracefulScore >= 20) return Colors.amber;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getScoreColor().shade300,
            _getScoreColor().shade500,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
            Text(
              metrics.scoreEmoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Consistency: ${metrics.gracefulScore.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    metrics.scoreDescription,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(metrics.weeklyAverage * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  '7-day',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white60,
                  ),
                ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Extension to access color shades
extension _ColorShades on Color {
  Color get shade300 {
    if (this == Colors.green) return Colors.green.shade300;
    if (this == Colors.teal) return Colors.teal.shade300;
    if (this == Colors.orange) return Colors.orange.shade300;
    if (this == Colors.amber) return Colors.amber.shade300;
    if (this == Colors.blue) return Colors.blue.shade300;
    return withValues(alpha: 0.5);
  }
  
  Color get shade400 {
    if (this == Colors.green) return Colors.green.shade400;
    if (this == Colors.teal) return Colors.teal.shade400;
    if (this == Colors.orange) return Colors.orange.shade400;
    if (this == Colors.amber) return Colors.amber.shade400;
    if (this == Colors.blue) return Colors.blue.shade400;
    return withValues(alpha: 0.6);
  }
  
  Color get shade500 {
    if (this == Colors.green) return Colors.green.shade500;
    if (this == Colors.teal) return Colors.teal.shade500;
    if (this == Colors.orange) return Colors.orange.shade500;
    if (this == Colors.amber) return Colors.amber.shade500;
    if (this == Colors.blue) return Colors.blue.shade500;
    return withValues(alpha: 0.7);
  }
  
  Color get shade600 {
    if (this == Colors.green) return Colors.green.shade600;
    if (this == Colors.teal) return Colors.teal.shade600;
    if (this == Colors.orange) return Colors.orange.shade600;
    if (this == Colors.amber) return Colors.amber.shade600;
    if (this == Colors.blue) return Colors.blue.shade600;
    return withValues(alpha: 0.8);
  }
}
