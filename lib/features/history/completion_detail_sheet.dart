import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/app_state.dart';
import '../../data/models/completion_record.dart';

/// Bottom sheet for viewing/editing completion details
/// Key differentiator: "What got in the way?" prompt for missed days
/// This turns the app from a tracker into a troubleshooting tool
class CompletionDetailSheet extends StatefulWidget {
  final String habitId;
  final DateTime date;
  final CompletionRecord? existingRecord;
  final bool markAsMissed;

  const CompletionDetailSheet({
    super.key,
    required this.habitId,
    required this.date,
    this.existingRecord,
    this.markAsMissed = false,
  });

  @override
  State<CompletionDetailSheet> createState() => _CompletionDetailSheetState();
}

class _CompletionDetailSheetState extends State<CompletionDetailSheet> {
  late TextEditingController _noteController;
  late TextEditingController _obstacleController;
  int? _selectedMood;
  String? _selectedObstacle;
  bool _useCustomObstacle = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(
      text: widget.existingRecord?.note ?? '',
    );
    _obstacleController = TextEditingController(
      text: widget.existingRecord?.obstacle ?? '',
    );
    _selectedMood = widget.existingRecord?.mood;

    // Check if existing obstacle is a custom one
    if (widget.existingRecord?.obstacle != null) {
      final existingObstacle = widget.existingRecord!.obstacle!;
      if (CompletionRecord.commonObstacles.contains(existingObstacle)) {
        _selectedObstacle = existingObstacle;
      } else {
        _useCustomObstacle = true;
        _obstacleController.text = existingObstacle;
      }
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _obstacleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMissedDay = widget.markAsMissed ||
        (widget.existingRecord != null && !widget.existingRecord!.completed);
    final isNewMissedRecord = widget.existingRecord == null && widget.markAsMissed;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isMissedDay
                            ? 'What got in the way?'
                            : 'Add Reflection',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Subheader for missed days
                if (isMissedDay) ...[
                  Text(
                    'Understanding obstacles helps you design better systems. '
                    'This isn\'t about blame—it\'s about learning.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Common obstacles
                  Text(
                    'Common obstacles',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: CompletionRecord.commonObstacles.map((obstacle) {
                      final isSelected =
                          _selectedObstacle == obstacle && !_useCustomObstacle;
                      return FilterChip(
                        selected: isSelected,
                        label: Text(obstacle),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedObstacle = obstacle;
                              _useCustomObstacle = false;
                              _obstacleController.clear();
                            } else {
                              _selectedObstacle = null;
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Custom obstacle input
                  TextField(
                    controller: _obstacleController,
                    decoration: InputDecoration(
                      labelText: 'Or describe what happened...',
                      hintText: 'e.g., "Had to work late on deadline"',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.edit_note),
                    ),
                    maxLines: 2,
                    onChanged: (value) {
                      setState(() {
                        if (value.isNotEmpty) {
                          _useCustomObstacle = true;
                          _selectedObstacle = null;
                        } else {
                          _useCustomObstacle = false;
                        }
                      });
                    },
                  ),
                ],

                // Note section (for both completed and missed days)
                if (!isNewMissedRecord || !isMissedDay) ...[
                  const SizedBox(height: 24),
                  Text(
                    isMissedDay ? 'Additional notes' : 'Reflection note',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText: isMissedDay
                          ? 'Any other thoughts?'
                          : 'How did it go? How do you feel?',
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],

                // Mood selector
                const SizedBox(height: 24),
                Text(
                  'How were you feeling?',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [1, 2, 3, 4, 5].map((mood) {
                    final isSelected = _selectedMood == mood;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMood = isSelected ? null : mood;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Column(
                          children: [
                            Text(
                              CompletionRecord.moodEmojis[mood] ?? '',
                              style: TextStyle(
                                fontSize: isSelected ? 28 : 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              CompletionRecord.moodLabels[mood]
                                      ?.split(' ')
                                      .first ??
                                  '',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _save,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(isMissedDay ? 'Save Reflection' : 'Save'),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Skip button for missed days
                if (isNewMissedRecord)
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => _save(skipDetails: true),
                      child: const Text('Skip for now'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _save({bool skipDetails = false}) async {
    final appState = context.read<AppState>();
    final normalizedDate = CompletionRecord.normalizeDate(widget.date);

    // Determine obstacle
    String? obstacle;
    if (!skipDetails) {
      if (_useCustomObstacle && _obstacleController.text.isNotEmpty) {
        obstacle = _obstacleController.text.trim();
      } else if (_selectedObstacle != null) {
        obstacle = _selectedObstacle;
      }
    }

    // Determine note
    final note = skipDetails ? null : _noteController.text.trim();

    // Determine if this is a missed day
    final isMissed = widget.markAsMissed ||
        (widget.existingRecord != null && !widget.existingRecord!.completed);

    if (widget.existingRecord != null) {
      // Update existing record
      await appState.updateCompletionRecord(
        habitId: widget.habitId,
        date: normalizedDate,
        note: note?.isEmpty == true ? null : note,
        obstacle: obstacle,
        mood: _selectedMood,
      );
    } else if (isMissed) {
      // Create new missed record
      await appState.recordMissedDay(
        habitId: widget.habitId,
        date: normalizedDate,
        obstacle: obstacle,
        mood: _selectedMood,
      );
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            skipDetails ? 'Day marked as missed' : 'Reflection saved',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
