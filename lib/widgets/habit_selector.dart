import 'package:flutter/material.dart';
import '../data/models/habit.dart';

/// Habit Selector Widget
///
/// Allows users to switch between multiple habits or enter focus mode.
/// Based on Atomic Habits principle: "Don't try to change everything at once."
///
/// Features:
/// - Dropdown to select focused habit
/// - Visual indicator for focus mode
/// - Quick access to add new habit
class HabitSelector extends StatelessWidget {
  final List<Habit> habits;
  final Habit? focusedHabit;
  final bool isFocusMode;
  final Function(String?) onHabitSelected;
  final VoidCallback onAddHabit;
  final VoidCallback onManageHabits;

  const HabitSelector({
    super.key,
    required this.habits,
    required this.focusedHabit,
    required this.isFocusMode,
    required this.onHabitSelected,
    required this.onAddHabit,
    required this.onManageHabits,
  });

  @override
  Widget build(BuildContext context) {
    if (habits.isEmpty) {
      return const SizedBox.shrink();
    }

    // Single habit - just show habit name
    if (habits.length == 1) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            habits.first.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            onPressed: onAddHabit,
            tooltip: 'Add another habit',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      );
    }

    // Multiple habits - show dropdown
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Focus mode indicator
        if (isFocusMode)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.center_focus_strong, size: 12, color: Colors.purple.shade700),
                const SizedBox(width: 2),
                Text(
                  'Focus',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
              ],
            ),
          ),

        // Habit dropdown
        PopupMenuButton<String?>(
          initialValue: focusedHabit?.id,
          onSelected: onHabitSelected,
          tooltip: 'Select habit',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  focusedHabit?.name ?? 'All Habits',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
          ),
          itemBuilder: (context) => [
            // "All Habits" option (exits focus mode)
            PopupMenuItem<String?>(
              value: null,
              child: Row(
                children: [
                  Icon(
                    Icons.list,
                    size: 18,
                    color: !isFocusMode ? Colors.purple : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'All Habits (${habits.length})',
                    style: TextStyle(
                      fontWeight: !isFocusMode ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (!isFocusMode)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.check, size: 16, color: Colors.purple),
                    ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            // Individual habits
            ...habits.map((habit) => PopupMenuItem<String?>(
              value: habit.id,
              child: Row(
                children: [
                  Icon(
                    _isCompletedToday(habit) ? Icons.check_circle : Icons.circle_outlined,
                    size: 18,
                    color: _isCompletedToday(habit) ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      habit.name,
                      style: TextStyle(
                        fontWeight: focusedHabit?.id == habit.id ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (focusedHabit?.id == habit.id)
                    Icon(Icons.center_focus_strong, size: 14, color: Colors.purple.shade400),
                ],
              ),
            )),
            const PopupMenuDivider(),
            // Add new habit option
            PopupMenuItem<String?>(
              value: '_add_new_',
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline, size: 18, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Add New Habit',
                    style: TextStyle(
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Manage habits option
            PopupMenuItem<String?>(
              value: '_manage_',
              child: Row(
                children: [
                  Icon(Icons.settings, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Manage Habits',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool _isCompletedToday(Habit habit) {
    if (habit.lastCompletedDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCompleted = habit.lastCompletedDate!;
    final lastDate = DateTime(
      lastCompleted.year,
      lastCompleted.month,
      lastCompleted.day,
    );
    return lastDate == today;
  }
}

/// Compact habit card for multi-habit list view
class HabitMiniCard extends StatelessWidget {
  final Habit habit;
  final bool isCompleted;
  final bool isFocused;
  final VoidCallback onTap;
  final VoidCallback onComplete;
  final VoidCallback onFocus;

  const HabitMiniCard({
    super.key,
    required this.habit,
    required this.isCompleted,
    required this.isFocused,
    required this.onTap,
    required this.onComplete,
    required this.onFocus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isFocused ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isFocused
            ? BorderSide(color: Colors.purple.shade300, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Completion status
              GestureDetector(
                onTap: isCompleted ? null : onComplete,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? Colors.green : Colors.grey.shade200,
                    border: isCompleted
                        ? null
                        : Border.all(color: Colors.grey.shade400, width: 2),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),
              ),
              const SizedBox(width: 12),

              // Habit info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            habit.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                              color: isCompleted ? Colors.grey : Colors.black87,
                            ),
                          ),
                        ),
                        if (isFocused)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.center_focus_strong,
                              size: 14,
                              color: Colors.purple.shade600,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.check_circle, size: 14, color: Colors.green.shade400),
                        const SizedBox(width: 4),
                        Text(
                          '${habit.daysShowedUp} days',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.local_fire_department, size: 14, color: Colors.orange.shade400),
                        const SizedBox(width: 4),
                        Text(
                          '${habit.currentStreak} streak',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Focus button
              IconButton(
                icon: Icon(
                  isFocused ? Icons.center_focus_strong : Icons.center_focus_weak,
                  color: isFocused ? Colors.purple : Colors.grey,
                ),
                onPressed: onFocus,
                tooltip: isFocused ? 'Exit focus mode' : 'Focus on this habit',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
