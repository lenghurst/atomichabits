import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/app_state.dart';
import '../../data/models/completion_record.dart';

/// Bottom sheet for viewing/editing completion details
/// Key differentiator: "What got in the way?" with emoji selection + AI coaching
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
  late TextEditingController _customObstacleController;
  int? _selectedMood;
  ObstacleOption? _selectedObstacle;
  bool _showAiTip = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(
      text: widget.existingRecord?.note ?? '',
    );
    _customObstacleController = TextEditingController();
    _selectedMood = widget.existingRecord?.mood;

    // Restore selected obstacle from existing record
    if (widget.existingRecord?.obstacleEmoji != null) {
      _selectedObstacle = CompletionRecord.getObstacleByEmoji(
        widget.existingRecord!.obstacleEmoji!,
      );
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _customObstacleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isMissedDay = widget.markAsMissed ||
        (widget.existingRecord != null && !widget.existingRecord!.completed);
    final isNewMissedRecord = widget.existingRecord == null && widget.markAsMissed;
    final moodEmojis = appState.activeMoodEmojis;
    final showAiCoaching = appState.userPreferences.showAiCoaching;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
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
                  const SizedBox(height: 20),

                  // Emoji obstacle grid
                  Text(
                    'What happened?',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildEmojiObstacleGrid(),

                  // AI Coaching tip (collapsible)
                  if (_selectedObstacle != null && showAiCoaching) ...[
                    const SizedBox(height: 16),
                    _buildAiCoachingCard(_selectedObstacle!),
                  ],

                  const SizedBox(height: 16),

                  // Custom obstacle text input
                  TextField(
                    controller: _customObstacleController,
                    decoration: InputDecoration(
                      labelText: 'Or add more context...',
                      hintText: 'What specifically happened?',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.edit_note),
                    ),
                    maxLines: 2,
                  ),
                ],

                // Note section
                const SizedBox(height: 20),
                Text(
                  isMissedDay ? 'Any thoughts to capture?' : 'How did it go?',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    hintText: isMissedDay
                        ? 'Optional reflection...'
                        : 'How do you feel? What went well?',
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),

                // Mood selector
                const SizedBox(height: 20),
                Text(
                  'How were you feeling?',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                _buildMoodSelector(moodEmojis),

                const SizedBox(height: 28),

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

  Widget _buildEmojiObstacleGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: CompletionRecord.obstacleOptions.map((option) {
        final isSelected = _selectedObstacle?.emoji == option.emoji;
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedObstacle = null;
                _showAiTip = false;
              } else {
                _selectedObstacle = option;
                _showAiTip = true;
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(option.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  option.label,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : null,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAiCoachingCard(ObstacleOption obstacle) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.5),
              Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Theme.of(context).colorScheme.tertiary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Atomic Habits Insight',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.tertiary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              obstacle.aiTip,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSelector(Map<int, String> moodEmojis) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [1, 2, 3, 4, 5].map((mood) {
        final isSelected = _selectedMood == mood;
        final emoji = moodEmojis[mood] ?? CompletionRecord.defaultMoodEmojis[mood]!;
        final label = CompletionRecord.moodLabels[mood]?.split(' ').first ?? '';

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedMood = isSelected ? null : mood;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
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
                  emoji,
                  style: TextStyle(fontSize: isSelected ? 28 : 24),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : null,
                      ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _save({bool skipDetails = false}) async {
    final appState = context.read<AppState>();
    final normalizedDate = CompletionRecord.normalizeDate(widget.date);

    // Determine obstacle
    String? obstacle;
    String? obstacleEmoji;

    if (!skipDetails && _selectedObstacle != null) {
      obstacleEmoji = _selectedObstacle!.emoji;
      obstacle = _selectedObstacle!.label;
      // Add custom context if provided
      if (_customObstacleController.text.trim().isNotEmpty) {
        obstacle = '${_selectedObstacle!.label}: ${_customObstacleController.text.trim()}';
      }
    } else if (!skipDetails && _customObstacleController.text.trim().isNotEmpty) {
      obstacle = _customObstacleController.text.trim();
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
        obstacleEmoji: obstacleEmoji,
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
