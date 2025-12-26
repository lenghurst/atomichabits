import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Calendar Month View - Custom Vibecoding Calendar Widget
/// 
/// **Phase 5: History & Calendar View**
/// - Displays a month grid with completion dots
/// - Highlights completed days in green
/// - Shows recovery days with special styling
/// - Marks today with a border ring
/// 
/// **"Don't Break the Chain" Philosophy:**
/// Visual streaks reinforce habit momentum while
/// Graceful Consistency shows recovery is also success.
class CalendarMonthView extends StatelessWidget {
  final DateTime month;
  final List<DateTime> completionDates;
  final List<DateTime> recoveryDates;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;
  final bool showNavigation;

  const CalendarMonthView({
    super.key,
    required this.month,
    required this.completionDates,
    this.recoveryDates = const [],
    this.onPreviousMonth,
    this.onNextMonth,
    this.showNavigation = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    // Weekday: 1 = Monday, 7 = Sunday. Adjust for Monday start.
    final firstWeekdayOffset = (firstDayOfMonth.weekday - 1) % 7;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month Header with optional navigation
        _buildMonthHeader(context, theme),
        
        const SizedBox(height: 8),
        
        // Weekday labels
        _buildWeekdayLabels(theme),
        
        const SizedBox(height: 8),
        
        // Days Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 1.0,
          ),
          itemCount: daysInMonth + firstWeekdayOffset,
          itemBuilder: (context, index) {
            if (index < firstWeekdayOffset) {
              return const SizedBox(); // Empty slots before 1st day
            }
            
            final day = index - firstWeekdayOffset + 1;
            final date = DateTime(month.year, month.month, day);
            final isCompleted = _isCompleted(date);
            final isRecovery = _isRecovery(date);
            final isToday = _isToday(date);
            final isFuture = date.isAfter(DateTime.now());
            
            return _DayCell(
              day: day,
              isCompleted: isCompleted,
              isRecovery: isRecovery,
              isToday: isToday,
              isFuture: isFuture,
            );
          },
        ),
        
        const SizedBox(height: 8),
        
        // Legend
        _buildLegend(context),
      ],
    );
  }

  Widget _buildMonthHeader(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showNavigation)
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: onPreviousMonth,
              visualDensity: VisualDensity.compact,
            )
          else
            const SizedBox(width: 40),
          
          Text(
            DateFormat('MMMM yyyy').format(month),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          if (showNavigation)
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: onNextMonth,
              visualDensity: VisualDensity.compact,
            )
          else
            const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildWeekdayLabels(ThemeData theme) {
    const weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((day) => SizedBox(
        width: 32,
        child: Center(
          child: Text(
            day,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: [
          _LegendItem(color: Colors.green.shade400, label: 'Completed'),
          _LegendItem(color: Colors.blue.shade300, label: 'Recovery'),
          _LegendItem(
            color: Colors.transparent,
            label: 'Today',
            hasBorder: true,
          ),
        ],
      ),
    );
  }

  bool _isCompleted(DateTime date) {
    return completionDates.any((d) => 
      d.year == date.year && d.month == date.month && d.day == date.day);
  }

  bool _isRecovery(DateTime date) {
    return recoveryDates.any((d) => 
      d.year == date.year && d.month == date.month && d.day == date.day);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return now.year == date.year && now.month == date.month && now.day == date.day;
  }
}

/// Individual day cell in the calendar
class _DayCell extends StatelessWidget {
  final int day;
  final bool isCompleted;
  final bool isRecovery;
  final bool isToday;
  final bool isFuture;

  const _DayCell({
    required this.day,
    required this.isCompleted,
    required this.isRecovery,
    required this.isToday,
    required this.isFuture,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color bgColor = Colors.transparent;
    Color textColor = theme.colorScheme.onSurface;
    BoxBorder? border;
    List<BoxShadow>? shadows;

    if (isCompleted) {
      bgColor = Colors.green.shade400;
      textColor = Colors.white;
      shadows = [
        BoxShadow(
          color: Colors.green.withValues(alpha: 0.3),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];
    } else if (isRecovery) {
      bgColor = Colors.blue.shade300;
      textColor = Colors.white;
      shadows = [
        BoxShadow(
          color: Colors.blue.withValues(alpha: 0.3),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];
    } else if (isFuture) {
      textColor = theme.colorScheme.onSurface.withValues(alpha: 0.3);
    }
    
    if (isToday) {
      border = Border.all(
        color: theme.colorScheme.primary,
        width: 2,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: border,
        boxShadow: shadows,
      ),
      alignment: Alignment.center,
      child: Text(
        '$day',
        style: TextStyle(
          color: textColor,
          fontSize: 13,
          fontWeight: isCompleted || isRecovery || isToday 
              ? FontWeight.bold 
              : FontWeight.normal,
        ),
      ),
    );
  }
}

/// Legend item for calendar explanation
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool hasBorder;

  const _LegendItem({
    required this.color,
    required this.label,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: hasBorder 
                ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
