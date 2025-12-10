import 'package:flutter/material.dart';

/// Habit Calendar View
///
/// Shows the last 35 days (5 weeks) of habit completion history.
/// Based on Atomic Habits principle: "Don't break the chain" with
/// graceful framing - emphasis on days showed up, not perfection.
///
/// Visual design:
/// - Green dots = completed days
/// - Gray dots = missed days
/// - Current day highlighted
/// - Shows "Days showed up this month" as primary metric
class HabitCalendar extends StatelessWidget {
  final List<String> completionHistory; // ISO date strings (YYYY-MM-DD)
  final int daysShowedUp;
  final int neverMissTwiceWins;

  const HabitCalendar({
    super.key,
    required this.completionHistory,
    required this.daysShowedUp,
    required this.neverMissTwiceWins,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Generate last 35 days (5 weeks) for the calendar
    final days = List.generate(35, (index) {
      return today.subtract(Duration(days: 34 - index));
    });

    // Convert completion history to a Set for O(1) lookup
    final completedDates = completionHistory
        .map((dateStr) {
          try {
            return dateStr.split('T')[0]; // Handle both date and datetime strings
          } catch (_) {
            return dateStr;
          }
        })
        .toSet();

    // Calculate this month's stats
    final thisMonthStart = DateTime(now.year, now.month, 1);
    int thisMonthCompletions = 0;
    for (final dateStr in completionHistory) {
      try {
        final date = DateTime.parse(dateStr);
        if (date.isAfter(thisMonthStart.subtract(const Duration(days: 1)))) {
          thisMonthCompletions++;
        }
      } catch (_) {}
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Showing-Up Calendar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$thisMonthCompletions this month',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Weekday labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((day) => SizedBox(
                      width: 36,
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),

          // Calendar grid (5 weeks)
          ...List.generate(5, (weekIndex) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (dayIndex) {
                  final dayOffset = weekIndex * 7 + dayIndex;
                  final date = days[dayOffset];
                  final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                  final isCompleted = completedDates.contains(dateStr);
                  final isToday = date == today;
                  final isFuture = date.isAfter(today);

                  return _CalendarDay(
                    day: date.day,
                    isCompleted: isCompleted,
                    isToday: isToday,
                    isFuture: isFuture,
                  );
                }),
              ),
            );
          }),

          const SizedBox(height: 16),

          // Legend and summary
          Row(
            children: [
              _LegendItem(color: Colors.green.shade400, label: 'Showed up'),
              const SizedBox(width: 16),
              _LegendItem(color: Colors.grey.shade300, label: 'Missed'),
              const Spacer(),
              // Encouraging message
              if (thisMonthCompletions > 0)
                Text(
                  _getEncouragingMessage(thisMonthCompletions, neverMissTwiceWins),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getEncouragingMessage(int completions, int recoveries) {
    if (completions >= 20) {
      return 'Incredible consistency!';
    } else if (completions >= 15) {
      return 'Strong month so far!';
    } else if (completions >= 10) {
      return 'Building momentum!';
    } else if (recoveries > 0) {
      return 'You bounced back $recoveries ${recoveries == 1 ? 'time' : 'times'}!';
    } else if (completions >= 5) {
      return 'Good progress!';
    } else if (completions > 0) {
      return 'Every day counts!';
    }
    return '';
  }
}

class _CalendarDay extends StatelessWidget {
  final int day;
  final bool isCompleted;
  final bool isToday;
  final bool isFuture;

  const _CalendarDay({
    required this.day,
    required this.isCompleted,
    required this.isToday,
    required this.isFuture,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    BoxBorder? border;

    if (isFuture) {
      backgroundColor = Colors.transparent;
      textColor = Colors.grey.shade300;
    } else if (isCompleted) {
      backgroundColor = Colors.green.shade400;
      textColor = Colors.white;
    } else {
      backgroundColor = Colors.grey.shade200;
      textColor = Colors.grey.shade500;
    }

    if (isToday) {
      border = Border.all(color: Colors.blue.shade400, width: 2);
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: border,
      ),
      child: Center(
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: 12,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
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
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
