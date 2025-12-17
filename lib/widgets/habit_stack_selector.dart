import 'package:flutter/material.dart';
import '../data/models/habit.dart';

/// Phase 13: Habit Stacking Selector Widget
/// 
/// A reusable widget for selecting habit stacking configuration.
/// Allows users to chain habits together ("After X, I will Y").
/// 
/// **Vibecoding Architecture:**
/// - Pure presentational widget
/// - Receives data and callbacks via props
/// - No internal state management
class HabitStackSelector extends StatelessWidget {
  /// List of habits that can be used as anchors
  final List<Habit> availableAnchors;
  
  /// Currently selected anchor habit ID
  final String? selectedAnchorId;
  
  /// Position relative to anchor: 'before' or 'after'
  final String stackPosition;
  
  /// Optional anchor event (e.g., 'waking up', 'lunch')
  final String? anchorEvent;
  
  /// Habit ID to exclude from the anchor list (the habit being edited)
  final String? excludeHabitId;
  
  /// Callback when anchor selection changes
  final ValueChanged<String?> onAnchorChanged;
  
  /// Callback when position changes
  final ValueChanged<String> onPositionChanged;
  
  /// Callback when anchor event changes
  final ValueChanged<String?> onEventChanged;
  
  /// Function to check if selecting an anchor would create a circular dependency
  final bool Function(String anchorId)? wouldCreateCircular;

  const HabitStackSelector({
    super.key,
    required this.availableAnchors,
    required this.selectedAnchorId,
    required this.stackPosition,
    required this.anchorEvent,
    this.excludeHabitId,
    required this.onAnchorChanged,
    required this.onPositionChanged,
    required this.onEventChanged,
    this.wouldCreateCircular,
  });

  @override
  Widget build(BuildContext context) {
    // Filter out the current habit from available anchors
    final filteredAnchors = excludeHabitId != null
        ? availableAnchors.where((h) => h.id != excludeHabitId).toList()
        : availableAnchors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stack Position Toggle
        Row(
          children: [
            const Text('Stack Position: '),
            const SizedBox(width: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'before', label: Text('Before')),
                ButtonSegment(value: 'after', label: Text('After')),
              ],
              selected: {stackPosition},
              onSelectionChanged: (selection) {
                onPositionChanged(selection.first);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Anchor Habit Dropdown
        DropdownButtonFormField<String>(
          value: selectedAnchorId,
          decoration: InputDecoration(
            labelText: stackPosition == 'after' 
                ? 'After completing...' 
                : 'Before starting...',
            hintText: 'Select an anchor habit or event',
            border: const OutlineInputBorder(),
          ),
          items: [
            // Built-in anchor events
            const DropdownMenuItem(
              value: '__waking_up__',
              child: Text('🌅 Waking up'),
            ),
            const DropdownMenuItem(
              value: '__morning_coffee__',
              child: Text('☕ Morning coffee'),
            ),
            const DropdownMenuItem(
              value: '__lunch__',
              child: Text('🍽️ Lunch'),
            ),
            const DropdownMenuItem(
              value: '__dinner__',
              child: Text('🍽️ Dinner'),
            ),
            const DropdownMenuItem(
              value: '__bedtime__',
              child: Text('🌙 Bedtime'),
            ),
            // Divider
            if (filteredAnchors.isNotEmpty)
              const DropdownMenuItem(
                enabled: false,
                value: '__divider__',
                child: Divider(),
              ),
            // Existing habits
            ...filteredAnchors.map((habit) {
              final isCircular = wouldCreateCircular?.call(habit.id) ?? false;
              return DropdownMenuItem(
                value: habit.id,
                enabled: !isCircular,
                child: Row(
                  children: [
                    Text(
                      habit.name,
                      style: isCircular 
                          ? const TextStyle(color: Colors.grey)
                          : null,
                    ),
                    if (isCircular) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.warning, color: Colors.orange, size: 16),
                      const Text(
                        ' (circular)',
                        style: TextStyle(color: Colors.orange, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
          onChanged: (value) {
            if (value == '__divider__') return;
            
            // Check if it's a built-in event
            if (value?.startsWith('__') ?? false) {
              onAnchorChanged(null);
              onEventChanged(value);
            } else {
              onAnchorChanged(value);
              onEventChanged(null);
            }
          },
        ),
        const SizedBox(height: 8),
        
        // Help text
        Text(
          stackPosition == 'after'
              ? 'This habit will be prompted after completing the selected anchor.'
              : 'This habit will be prompted before starting the selected anchor.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        
        // Clear button
        if (selectedAnchorId != null || anchorEvent != null) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              onAnchorChanged(null);
              onEventChanged(null);
            },
            icon: const Icon(Icons.clear, size: 16),
            label: const Text('Remove stack'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red.shade400,
            ),
          ),
        ],
      ],
    );
  }
}
