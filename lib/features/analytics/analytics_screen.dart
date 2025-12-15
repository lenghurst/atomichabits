import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/app_state.dart';
import '../../data/models/habit.dart';
import '../../data/services/analytics_service.dart';

/// Phase 10: Analytics Dashboard Screen
/// 
/// Visualizes Graceful Consistency over time with interactive charts.
/// Key design principle: Missed days appear as small dips, not cliffs.
/// This visually reinforces the "Graceful Consistency > Fragile Streaks" philosophy.
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  AnalyticsPeriod _selectedPeriod = AnalyticsPeriod.month30;
  Habit? _selectedHabit;
  
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Default to focused habit if none selected
    _selectedHabit ??= appState.currentHabit;
    
    if (_selectedHabit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analytics')),
        body: const Center(
          child: Text('No habits to analyze'),
        ),
      );
    }
    
    final dataPoints = _analyticsService.generateScoreHistory(
      habit: _selectedHabit!,
      period: _selectedPeriod,
    );
    
    final summary = _analyticsService.generatePeriodSummary(
      habit: _selectedHabit!,
      period: _selectedPeriod,
    );
    
    final weeklyData = _analyticsService.generateWeeklyBreakdown(
      habit: _selectedHabit!,
      weeksToShow: 8,
    );
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          // Habit selector for multi-habit users
          if (appState.habits.length > 1)
            PopupMenuButton<Habit>(
              icon: const Icon(Icons.swap_horiz),
              tooltip: 'Switch habit',
              onSelected: (habit) {
                setState(() => _selectedHabit = habit);
              },
              itemBuilder: (context) => appState.habits.map((h) =>
                PopupMenuItem(
                  value: h,
                  child: Row(
                    children: [
                      if (h.habitEmoji?.isNotEmpty == true)
                        Text('${h.habitEmoji} '),
                      Expanded(child: Text(h.name)),
                      if (h.id == _selectedHabit?.id)
                        Icon(Icons.check, color: colorScheme.primary),
                    ],
                  ),
                ),
              ).toList(),
            ),
        ],
      ),
      body: dataPoints.isEmpty
          ? _buildEmptyState(context)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Habit header
                  _buildHabitHeader(context),
                  const SizedBox(height: 24),
                  
                  // Period selector
                  _buildPeriodSelector(context),
                  const SizedBox(height: 24),
                  
                  // Main trend chart
                  _buildTrendCard(context, dataPoints, summary),
                  const SizedBox(height: 24),
                  
                  // Summary stats
                  _buildSummaryCard(context, summary),
                  const SizedBox(height: 24),
                  
                  // Weekly breakdown
                  if (weeklyData.isNotEmpty)
                    _buildWeeklyBreakdownCard(context, weeklyData),
                  const SizedBox(height: 24),
                  
                  // Resilience insight
                  _buildResilienceInsight(context, summary),
                ],
              ),
            ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Not enough data yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Complete your habit a few times to see your trends',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHabitHeader(BuildContext context) {
    final habit = _selectedHabit!;
    final theme = Theme.of(context);
    
    return Row(
      children: [
        if (habit.habitEmoji?.isNotEmpty == true)
          Text(
            habit.habitEmoji!,
            style: const TextStyle(fontSize: 32),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                habit.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'I am ${habit.identity}',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildPeriodSelector(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: AnalyticsPeriod.values.map((period) {
          final isSelected = period == _selectedPeriod;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(period.label),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _selectedPeriod = period);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildTrendCard(
    BuildContext context,
    List<AnalyticsDataPoint> dataPoints,
    PeriodSummary summary,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Graceful Consistency',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Trend indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getTrendColor(summary.scoreChange).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(summary.trendEmoji),
                      const SizedBox(width: 4),
                      Text(
                        '${summary.scoreChange >= 0 ? '+' : ''}${summary.scoreChange.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getTrendColor(summary.scoreChange),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Small dips are normal. Recovery is what matters.',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 24),
            
            // The main chart
            SizedBox(
              height: 200,
              child: _buildLineChart(context, dataPoints),
            ),
            
            const SizedBox(height: 16),
            
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(colorScheme.primary, 'Score'),
                const SizedBox(width: 16),
                _buildLegendItem(Colors.green, 'Completed'),
                const SizedBox(width: 16),
                _buildLegendItem(Colors.orange, 'Recovery'),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLineChart(
    BuildContext context,
    List<AnalyticsDataPoint> dataPoints,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (dataPoints.isEmpty) return const SizedBox();
    
    // Convert to FlSpot
    final spots = <FlSpot>[];
    for (int i = 0; i < dataPoints.length; i++) {
      spots.add(FlSpot(i.toDouble(), dataPoints[i].gracefulScore));
    }
    
    // Find min/max for better visualization
    final scores = dataPoints.map((p) => p.gracefulScore).toList();
    final minScore = scores.reduce((a, b) => a < b ? a : b);
    final maxScore = scores.reduce((a, b) => a > b ? a : b);
    
    // Add padding to min/max
    final yMin = (minScore - 10).clamp(0.0, 100.0);
    final yMax = (maxScore + 10).clamp(0.0, 100.0);
    
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (dataPoints.length - 1).toDouble(),
        minY: yMin,
        maxY: yMax,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: colorScheme.outlineVariant.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: _getXInterval(dataPoints.length),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= dataPoints.length) {
                  return const SizedBox();
                }
                final date = dataPoints[index].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${date.month}/${date.day}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 20,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final point = dataPoints[index];
                
                // Different colors for different states
                Color dotColor;
                double dotSize;
                
                if (point.wasRecovery) {
                  dotColor = Colors.orange;
                  dotSize = 6;
                } else if (point.wasCompleted) {
                  dotColor = Colors.green;
                  dotSize = 4;
                } else {
                  dotColor = colorScheme.outline;
                  dotSize = 3;
                }
                
                return FlDotCirclePainter(
                  radius: dotSize,
                  color: dotColor,
                  strokeWidth: 0,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.primary.withOpacity(0.3),
                  colorScheme.primary.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index < 0 || index >= dataPoints.length) return null;
                
                final point = dataPoints[index];
                final date = point.date;
                final status = point.wasRecovery 
                    ? 'Recovery!' 
                    : point.wasCompleted 
                        ? 'Completed' 
                        : 'Missed';
                
                return LineTooltipItem(
                  '${date.month}/${date.day}\n${point.gracefulScore.toStringAsFixed(1)}%\n$status',
                  TextStyle(
                    color: colorScheme.onInverseSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
  
  double _getXInterval(int dataLength) {
    if (dataLength <= 7) return 1;
    if (dataLength <= 14) return 2;
    if (dataLength <= 30) return 5;
    if (dataLength <= 90) return 14;
    return 30;
  }
  
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSummaryCard(BuildContext context, PeriodSummary summary) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Period Summary',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    '${summary.completedDays}/${summary.totalDays}',
                    'Days Completed',
                    Icons.check_circle_outline,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    '${(summary.completionRate * 100).toStringAsFixed(0)}%',
                    'Completion Rate',
                    Icons.percent,
                    theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    '${summary.recoveryDays}',
                    'Recoveries',
                    Icons.replay,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    '${summary.longestStreak}',
                    'Best Streak',
                    Icons.local_fire_department,
                    Colors.deepOrange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  Widget _buildWeeklyBreakdownCard(
    BuildContext context,
    List<WeeklyBreakdown> weeklyData,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Breakdown',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 7,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final week = weeklyData[group.x.toInt()];
                        return BarTooltipItem(
                          '${week.dateRange}\n${week.completedDays}/7 days',
                          TextStyle(
                            color: colorScheme.onInverseSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= weeklyData.length) {
                            return const SizedBox();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'W${index + 1}',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value % 2 != 0) return const SizedBox();
                          return Text(
                            '${value.toInt()}',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: colorScheme.outlineVariant.withOpacity(0.3),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  barGroups: weeklyData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final week = entry.value;
                    
                    // Color based on completion rate
                    Color barColor;
                    if (week.completionRate >= 0.7) {
                      barColor = Colors.green;
                    } else if (week.completionRate >= 0.4) {
                      barColor = Colors.orange;
                    } else {
                      barColor = colorScheme.outline;
                    }
                    
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: week.completedDays.toDouble(),
                          color: barColor,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildResilienceInsight(BuildContext context, PeriodSummary summary) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Generate insight based on data
    String insight;
    IconData icon;
    Color color;
    
    if (summary.recoveryDays > 0 && summary.scoreChange >= 0) {
      insight = 'Your recoveries kept your score stable. '
          'This is Graceful Consistency in action!';
      icon = Icons.auto_awesome;
      color = Colors.amber;
    } else if (summary.completionRate >= 0.8) {
      insight = 'Excellent consistency! You\'re building '
          'strong evidence that you are ${_selectedHabit?.identity ?? 'this person'}.';
      icon = Icons.emoji_events;
      color = Colors.amber;
    } else if (summary.missedDays > 0 && summary.scoreChange > -10) {
      insight = 'Notice how the score dips gently, not crashes. '
          'One miss doesn\'t erase your progress!';
      icon = Icons.insights;
      color = colorScheme.primary;
    } else if (summary.scoreChange < -10) {
      insight = 'Let\'s focus on the 2-minute version. '
          'Showing up matters more than intensity.';
      icon = Icons.lightbulb_outline;
      color = Colors.orange;
    } else {
      insight = 'Every completion is a vote for your identity. '
          'The graph shows your journey, not perfection.';
      icon = Icons.favorite;
      color = Colors.pink;
    }
    
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Insight',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    insight,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getTrendColor(double change) {
    if (change > 5) return Colors.green;
    if (change > -5) return Colors.grey;
    return Colors.orange;
  }
}
