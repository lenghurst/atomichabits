import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../data/app_state.dart';
import '../../data/models/habit.dart';
import '../../data/models/completion_record.dart';
import 'completion_detail_sheet.dart';

/// Habit History Screen - Calendar view with streak visualization
/// Core feature for "Don't break the chain" motivation
/// Differentiator: Shows not just completions but WHY days were missed
class HabitHistoryScreen extends StatefulWidget {
  final String habitId;

  const HabitHistoryScreen({super.key, required this.habitId});

  @override
  State<HabitHistoryScreen> createState() => _HabitHistoryScreenState();
}

class _HabitHistoryScreenState extends State<HabitHistoryScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final habit = appState.getHabitById(widget.habitId);
        if (habit == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('History')),
            body: const Center(child: Text('Habit not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(habit.name),
            centerTitle: true,
          ),
          body: Column(
            children: [
              // Streak Stats Header
              _buildStreakHeader(habit),

              // Calendar
              _buildCalendar(habit),

              // Selected Day Details
              if (_selectedDay != null) ...[
                const Divider(height: 1),
                Expanded(
                  child: _buildDayDetails(context, habit, appState),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStreakHeader(Habit habit) {
    final now = DateTime.now();
    final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final thisWeekEnd = thisWeekStart.add(const Duration(days: 6));
    final weeklyRate = habit.completionRateInRange(thisWeekStart, thisWeekEnd);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      ),
      child: Column(
        children: [
          // Main streak display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard(
                icon: Icons.local_fire_department,
                iconColor: habit.currentStreak > 0
                    ? Colors.orange
                    : Colors.grey,
                value: habit.currentStreak.toString(),
                label: 'Current Streak',
                highlight: habit.currentStreak > 0,
              ),
              _buildStatCard(
                icon: Icons.emoji_events,
                iconColor: Colors.amber,
                value: habit.longestStreak.toString(),
                label: 'Best Streak',
                highlight: false,
              ),
              _buildStatCard(
                icon: Icons.check_circle,
                iconColor: Colors.green,
                value: habit.totalCompletions.toString(),
                label: 'Total Done',
                highlight: false,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Weekly progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'This Week',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  Text(
                    '${(weeklyRate * 100).toInt()}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: weeklyRate,
                  minHeight: 8,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
            ],
          ),

          // Milestone message if applicable
          if (Habit.isStreakMilestone(habit.currentStreak)) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      Habit.getMilestoneMessage(habit.currentStreak) ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required bool highlight,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: highlight
                ? iconColor.withOpacity(0.2)
                : Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildCalendar(Habit habit) {
    final completedDates = habit.completedDates.toSet();
    final missedDates = habit.missedDates.toSet();
    final createdDate = CompletionRecord.normalizeDate(habit.createdAt);

    return TableCalendar(
      firstDay: createdDate,
      lastDay: DateTime.now(),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        todayDecoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
          shape: BoxShape.circle,
        ),
        todayTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          return _buildDayCell(day, completedDates, missedDates, createdDate);
        },
        todayBuilder: (context, day, focusedDay) {
          return _buildDayCell(day, completedDates, missedDates, createdDate,
              isToday: true);
        },
        selectedBuilder: (context, day, focusedDay) {
          return _buildDayCell(day, completedDates, missedDates, createdDate,
              isSelected: true);
        },
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
        formatButtonDecoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildDayCell(
    DateTime day,
    Set<DateTime> completedDates,
    Set<DateTime> missedDates,
    DateTime createdDate, {
    bool isToday = false,
    bool isSelected = false,
  }) {
    final normalizedDay = CompletionRecord.normalizeDate(day);
    final isCompleted = completedDates.contains(normalizedDay);
    final isMissed = missedDates.contains(normalizedDay);
    final isBeforeCreation = normalizedDay.isBefore(createdDate);
    final isFuture = normalizedDay.isAfter(DateTime.now());

    Color? backgroundColor;
    Color? borderColor;
    Color textColor = Theme.of(context).colorScheme.onSurface;

    if (isSelected) {
      backgroundColor = Theme.of(context).colorScheme.primary;
      textColor = Theme.of(context).colorScheme.onPrimary;
    } else if (isCompleted) {
      backgroundColor = Colors.green.withOpacity(0.3);
      borderColor = Colors.green;
    } else if (isMissed) {
      backgroundColor = Colors.red.withOpacity(0.2);
      borderColor = Colors.red.withOpacity(0.5);
    } else if (isBeforeCreation || isFuture) {
      textColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.3);
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: isToday && !isSelected
            ? Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              )
            : borderColor != null
                ? Border.all(color: borderColor, width: 1.5)
                : null,
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: textColor,
            fontWeight: isToday || isSelected ? FontWeight.bold : null,
          ),
        ),
      ),
    );
  }

  Widget _buildDayDetails(BuildContext context, Habit habit, AppState appState) {
    final selectedDate = _selectedDay!;
    final normalizedDate = CompletionRecord.normalizeDate(selectedDate);
    final record = habit.getRecordForDate(selectedDate);
    final createdDate = CompletionRecord.normalizeDate(habit.createdAt);
    final isToday = isSameDay(selectedDate, DateTime.now());
    final isBeforeCreation = normalizedDate.isBefore(createdDate);
    final isFuture = normalizedDate.isAfter(CompletionRecord.normalizeDate(DateTime.now()));

    if (isBeforeCreation) {
      return Center(
        child: Text(
          'Before habit was created',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    if (isFuture) {
      return Center(
        child: Text(
          'Future date',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    // Format date
    final dateStr = _formatDate(selectedDate);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header
          Text(
            dateStr,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          if (record != null) ...[
            // Status indicator
            _buildStatusCard(record),

            // Note if exists
            if (record.note != null && record.note!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildNoteCard(record.note!, 'Note'),
            ],

            // Obstacle if exists
            if (record.obstacle != null && record.obstacle!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildNoteCard(record.obstacle!, 'What got in the way'),
            ],

            // Mood if exists
            if (record.mood != null) ...[
              const SizedBox(height: 12),
              _buildMoodCard(record.mood!),
            ],

            const SizedBox(height: 16),

            // Edit button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showCompletionDetailSheet(
                  context,
                  habit,
                  selectedDate,
                  record,
                ),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Details'),
              ),
            ),
          ] else ...[
            // No record - offer to add one
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.help_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isToday ? 'Not completed yet' : 'No record for this day',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),

                  if (!isToday) ...[
                    // For past days, offer to mark as completed or missed
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showCompletionDetailSheet(
                              context,
                              habit,
                              selectedDate,
                              null,
                              markAsMissed: true,
                            ),
                            icon: const Icon(Icons.sentiment_dissatisfied),
                            label: const Text('I missed it'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _markPastDayComplete(
                              context,
                              appState,
                              habit,
                              selectedDate,
                            ),
                            icon: const Icon(Icons.check),
                            label: const Text('I did it'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard(CompletionRecord record) {
    final isCompleted = record.completed;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.cancel,
            color: isCompleted ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Text(
            isCompleted ? 'Completed' : 'Missed',
            style: TextStyle(
              color: isCompleted ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(String text, String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildMoodCard(int mood) {
    final emoji = CompletionRecord.moodEmojis[mood] ?? '';
    final label = CompletionRecord.moodLabels[mood] ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mood',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              Text(label),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = CompletionRecord.normalizeDate(now);
    final yesterday = today.subtract(const Duration(days: 1));
    final normalizedDate = CompletionRecord.normalizeDate(date);

    if (normalizedDate == today) {
      return 'Today';
    } else if (normalizedDate == yesterday) {
      return 'Yesterday';
    } else {
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      const days = [
        'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
      ];
      return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
    }
  }

  void _showCompletionDetailSheet(
    BuildContext context,
    Habit habit,
    DateTime date,
    CompletionRecord? existingRecord, {
    bool markAsMissed = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => CompletionDetailSheet(
        habitId: habit.id,
        date: date,
        existingRecord: existingRecord,
        markAsMissed: markAsMissed,
      ),
    );
  }

  void _markPastDayComplete(
    BuildContext context,
    AppState appState,
    Habit habit,
    DateTime date,
  ) async {
    final normalizedDate = CompletionRecord.normalizeDate(date);

    // Create a completion record for the past day
    final record = CompletionRecord(
      date: normalizedDate,
      completed: true,
    );

    // Update the habit's completion history
    final updatedHistory = habit.completionHistory
        .where((r) => CompletionRecord.normalizeDate(r.date) != normalizedDate)
        .toList()
      ..add(record);

    await appState.updateHabit(habit.copyWith(
      completionHistory: updatedHistory,
    ));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Marked as completed'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
