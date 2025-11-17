import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/app_state.dart';
import '../../data/review_service.dart';

/// History & Weekly Review screen
///
/// Shows:
/// - Current habit summary (name, identity, streak)
/// - Completion rate for last 7 and 30 days
/// - History list for last 30 days (completed vs missed)
/// - AI Weekly Review feature (calls backend)
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History & Review'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final habit = appState.currentHabit;

          if (habit == null) {
            return const Center(
              child: Text('No habit found'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header card with summary
                _buildSummaryCard(habit),
                const SizedBox(height: 16),

                // History list (last 30 days)
                _buildHistoryList(habit),
                const SizedBox(height: 16),

                // Weekly Review section
                _buildWeeklyReviewCard(context, habit, appState),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(dynamic habit) {
    final completionStats = _calculateCompletionStats(habit.completionHistory);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              habit.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              habit.identity,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  label: 'Current Streak',
                  value: '${habit.currentStreak} days',
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                ),
                _buildStatItem(
                  label: 'Last 7 days',
                  value: '${completionStats['last7Days']}/${completionStats['total7Days']} (${completionStats['percent7Days']}%)',
                  icon: Icons.calendar_today,
                  color: Colors.blue,
                ),
                _buildStatItem(
                  label: 'Last 30 days',
                  value: '${completionStats['last30Days']}/${completionStats['total30Days']} (${completionStats['percent30Days']}%)',
                  icon: Icons.calendar_month,
                  color: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList(dynamic habit) {
    final history = _getLast30Days(habit.completionHistory);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Last 30 Days',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final entry = history[index];
                final date = entry['date'] as DateTime;
                final completed = entry['completed'] as bool;

                return ListTile(
                  dense: true,
                  leading: Icon(
                    completed ? Icons.check_circle : Icons.cancel,
                    color: completed ? Colors.green : Colors.red,
                    size: 28,
                  ),
                  title: Text(
                    DateFormat('EEE, MMM d').format(date),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    completed ? 'Completed' : 'Missed',
                    style: TextStyle(
                      fontSize: 12,
                      color: completed ? Colors.green[700] : Colors.red[700],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyReviewCard(BuildContext context, dynamic habit, AppState appState) {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: Colors.blue[700], size: 28),
                const SizedBox(width: 8),
                const Text(
                  'AI Weekly Review',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Get an AI-powered weekly check-in based on your last 7 days of progress. Receive personalized insights and suggestions to refine your habit system.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  _handleGetWeeklyReview(context, habit, appState);
                },
                icon: const Icon(Icons.psychology),
                label: const Text('Get AI Weekly Review'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleGetWeeklyReview(BuildContext context, dynamic habit, AppState appState) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating your weekly review...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final reviewService = ReviewService();
      final review = await reviewService.fetchWeeklyReview(habit: habit);

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show review in a dialog
      if (context.mounted) {
        _showWeeklyReviewDialog(context, review);
      }
    } catch (error) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not load weekly review: $error'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _showWeeklyReviewDialog(BuildContext context, WeeklyReview review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.psychology, color: Colors.blue[700]),
            const SizedBox(width: 8),
            const Text('Your Weekly Review'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary
              Text(
                review.summary,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),

              // Insights
              const Text(
                'Insights:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...review.insights.map((insight) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 16)),
                        Expanded(
                          child: Text(
                            insight,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),

              // Suggested Adjustments
              const Text(
                'Suggested Adjustments:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...review.suggestedAdjustments.map((adjustment) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_outline,
                            size: 16, color: Colors.orange[700]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            adjustment,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ========== HELPER METHODS ==========

  /// Calculate completion statistics for last 7 and 30 days
  Map<String, dynamic> _calculateCompletionStats(Map<String, bool> completionHistory) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int completed7Days = 0;
    int completed30Days = 0;

    for (int i = 0; i < 30; i++) {
      final date = today.subtract(Duration(days: i));
      final dateKey = _formatDateKey(date);
      final isCompleted = completionHistory[dateKey] ?? false;

      if (isCompleted) {
        completed30Days++;
        if (i < 7) {
          completed7Days++;
        }
      }
    }

    final percent7Days = (completed7Days / 7 * 100).round();
    final percent30Days = (completed30Days / 30 * 100).round();

    return {
      'last7Days': completed7Days,
      'total7Days': 7,
      'percent7Days': percent7Days,
      'last30Days': completed30Days,
      'total30Days': 30,
      'percent30Days': percent30Days,
    };
  }

  /// Get last 30 days of history with completion status
  List<Map<String, dynamic>> _getLast30Days(Map<String, bool> completionHistory) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final history = <Map<String, dynamic>>[];

    for (int i = 0; i < 30; i++) {
      final date = today.subtract(Duration(days: i));
      final dateKey = _formatDateKey(date);
      final completed = completionHistory[dateKey] ?? false;

      history.add({
        'date': date,
        'completed': completed,
      });
    }

    return history;
  }

  /// Format DateTime to yyyy-MM-dd string
  String _formatDateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
