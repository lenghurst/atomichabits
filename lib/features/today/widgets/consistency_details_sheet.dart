import 'package:flutter/material.dart';
import '../../../data/models/consistency_metrics.dart';

/// ConsistencyDetailsSheet - Bottom sheet showing detailed consistency metrics
/// 
/// Purely presentational widget - all data comes via props.
class ConsistencyDetailsSheet extends StatelessWidget {
  final ConsistencyMetrics metrics;
  final int identityVotes;
  
  const ConsistencyDetailsSheet({
    super.key,
    required this.metrics,
    required this.identityVotes,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHandle(),
            const SizedBox(height: 20),
            _buildTitle(),
            const SizedBox(height: 24),
            _OverallScoreSection(metrics: metrics),
            const SizedBox(height: 20),
            _WeeklyStatsSection(metrics: metrics),
            const SizedBox(height: 20),
            _AllTimeSection(metrics: metrics, identityVotes: identityVotes),
            const SizedBox(height: 20),
            _NeverMissTwiceSection(metrics: metrics),
            const SizedBox(height: 20),
            _StreaksSection(metrics: metrics),
            const SizedBox(height: 16),
            _PhilosophyNote(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
  
  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Consistency Journey',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Graceful Consistency > Fragile Streaks',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

/// Section showing overall score
class _OverallScoreSection extends StatelessWidget {
  final ConsistencyMetrics metrics;
  
  const _OverallScoreSection({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return _DetailSection(
      title: 'Overall Score',
      icon: Icons.analytics,
      child: Row(
        children: [
          Text(
            metrics.gracefulScore.toStringAsFixed(0),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metrics.scoreDescription,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Based on 7-day average, recovery rate, and consistency',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Section showing weekly stats
class _WeeklyStatsSection extends StatelessWidget {
  final ConsistencyMetrics metrics;
  
  const _WeeklyStatsSection({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return _DetailSection(
      title: 'This Week',
      icon: Icons.calendar_view_week,
      child: Row(
        children: [
          _StatBox(
            value: '${(metrics.weeklyAverage * 100).toStringAsFixed(0)}%',
            label: 'Completion Rate',
          ),
          const SizedBox(width: 16),
          _StatBox(
            value: '${(metrics.weeklyAverage * 7).round()}/7',
            label: 'Days Completed',
          ),
        ],
      ),
    );
  }
}

/// Section showing all-time stats
class _AllTimeSection extends StatelessWidget {
  final ConsistencyMetrics metrics;
  final int identityVotes;
  
  const _AllTimeSection({
    required this.metrics,
    required this.identityVotes,
  });

  @override
  Widget build(BuildContext context) {
    return _DetailSection(
      title: 'All Time',
      icon: Icons.timeline,
      child: Row(
        children: [
          _StatBox(
            value: '$identityVotes',
            label: 'Identity Votes',
          ),
          const SizedBox(width: 16),
          _StatBox(
            value: '${metrics.daysShowedUp}/${metrics.totalDays}',
            label: 'Days Showed Up',
          ),
        ],
      ),
    );
  }
}

/// Section showing Never Miss Twice stats
class _NeverMissTwiceSection extends StatelessWidget {
  final ConsistencyMetrics metrics;
  
  const _NeverMissTwiceSection({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return _DetailSection(
      title: 'Never Miss Twice',
      icon: Icons.shield,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatBox(
                value: '${(metrics.neverMissTwiceRate * 100).toStringAsFixed(0)}%',
                label: 'Success Rate',
              ),
              const SizedBox(width: 16),
              _StatBox(
                value: '${metrics.quickRecoveryCount}',
                label: 'Quick Recoveries',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Quick recoveries = bounced back within 1 day of missing',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Section showing streaks (de-emphasized)
class _StreaksSection extends StatelessWidget {
  final ConsistencyMetrics metrics;
  
  const _StreaksSection({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return _DetailSection(
      title: 'Streaks (for reference)',
      icon: Icons.local_fire_department,
      deEmphasized: true,
      child: Row(
        children: [
          _StatBox(
            value: '${metrics.currentStreak}',
            label: 'Current',
            deEmphasized: true,
          ),
          const SizedBox(width: 16),
          _StatBox(
            value: '${metrics.longestStreak}',
            label: 'Best Ever',
            deEmphasized: true,
          ),
        ],
      ),
    );
  }
}

/// Philosophy note at the bottom
class _PhilosophyNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: Colors.blue.shade700,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '"Streaks are fragile. Consistency is resilient. '
              'One miss is an accident. Two is a pattern." '
              '– Atomic Habits Philosophy',
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable detail section widget
class _DetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final bool deEmphasized;
  
  const _DetailSection({
    required this.title,
    required this.icon,
    required this.child,
    this.deEmphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: deEmphasized ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: deEmphasized ? Colors.grey.shade500 : Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

/// Stat box widget for displaying individual statistics
class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final bool deEmphasized;
  
  const _StatBox({
    required this.value,
    required this.label,
    this.deEmphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: deEmphasized ? Colors.grey.shade100 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: deEmphasized ? Colors.grey.shade500 : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: deEmphasized ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
