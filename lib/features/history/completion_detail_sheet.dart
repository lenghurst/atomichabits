import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/app_state.dart';
import '../../data/models/completion_record.dart';
import '../../data/models/habit.dart';
import '../../data/services/reflection_coach_service.dart';
import '../../widgets/voice_input_button.dart';

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

  // Voice input state
  bool _isListeningForNote = false;
  bool _isListeningForObstacle = false;
  String _liveTranscript = '';

  // AI coaching state
  bool _isLoadingCoachResponse = false;
  String? _coachResponse;
  bool _showCoachConversation = false;
  final List<_ChatMessage> _conversation = [];

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
    ReflectionCoach.instance.endConversation();
    super.dispose();
  }

  /// Start AI coaching conversation
  Future<void> _startCoachConversation() async {
    if (_selectedObstacle == null) return;

    final appState = context.read<AppState>();
    final habit = appState.habits.firstWhere(
      (h) => h.id == widget.habitId,
      orElse: () => appState.habits.first,
    );

    setState(() {
      _isLoadingCoachResponse = true;
      _showCoachConversation = true;
      _conversation.clear();
    });

    final response = await ReflectionCoach.instance.startReflectionConversation(
      habit: habit,
      obstacle: _selectedObstacle!,
      additionalContext: _customObstacleController.text.trim().isEmpty
          ? null
          : _customObstacleController.text.trim(),
      mood: _selectedMood,
    );

    if (mounted) {
      setState(() {
        _isLoadingCoachResponse = false;
        if (response != null) {
          _coachResponse = response;
          _conversation.add(_ChatMessage(
            text: response,
            isUser: false,
          ));
        }
      });
    }
  }

  /// Send a follow-up message to the coach
  Future<void> _sendToCoach(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _conversation.add(_ChatMessage(text: message, isUser: true));
      _isLoadingCoachResponse = true;
    });

    final response = await ReflectionCoach.instance.sendMessage(message);

    if (mounted) {
      setState(() {
        _isLoadingCoachResponse = false;
        if (response != null) {
          _conversation.add(_ChatMessage(text: response, isUser: false));
        }
      });
    }
  }

  /// Handle voice input result for notes
  void _onVoiceResultForNote(String text) {
    setState(() {
      _isListeningForNote = false;
      _liveTranscript = '';
      // Append to existing text with a space if needed
      final existing = _noteController.text;
      if (existing.isNotEmpty && !existing.endsWith(' ')) {
        _noteController.text = '$existing $text';
      } else {
        _noteController.text = existing + text;
      }
    });
  }

  /// Handle voice input result for obstacle context
  void _onVoiceResultForObstacle(String text) {
    setState(() {
      _isListeningForObstacle = false;
      _liveTranscript = '';
      final existing = _customObstacleController.text;
      if (existing.isNotEmpty && !existing.endsWith(' ')) {
        _customObstacleController.text = '$existing $text';
      } else {
        _customObstacleController.text = existing + text;
      }
    });
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

                  // Custom obstacle text input with voice
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customObstacleController,
                          decoration: InputDecoration(
                            labelText: 'Or add more context...',
                            hintText: _isListeningForObstacle
                                ? 'Listening...'
                                : 'What specifically happened?',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.edit_note),
                          ),
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      VoiceInputButton(
                        compact: true,
                        onResult: _onVoiceResultForObstacle,
                        onListeningChanged: (listening) {
                          setState(() => _isListeningForObstacle = listening);
                        },
                        onError: (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error)),
                          );
                        },
                      ),
                    ],
                  ),

                  // "Talk to Coach" button
                  if (_selectedObstacle != null && showAiCoaching) ...[
                    const SizedBox(height: 16),
                    _buildTalkToCoachButton(),
                  ],

                  // AI Conversation section
                  if (_showCoachConversation) ...[
                    const SizedBox(height: 16),
                    _buildCoachConversation(),
                  ],
                ],

                // Note section with voice input
                const SizedBox(height: 20),
                Text(
                  isMissedDay ? 'Any thoughts to capture?' : 'How did it go?',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _noteController,
                        decoration: InputDecoration(
                          hintText: _isListeningForNote
                              ? 'Listening...'
                              : (isMissedDay
                                  ? 'Optional reflection...'
                                  : 'How do you feel? What went well?'),
                          border: const OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    VoiceInputButton(
                      compact: true,
                      onResult: _onVoiceResultForNote,
                      onListeningChanged: (listening) {
                        setState(() => _isListeningForNote = listening);
                      },
                      onError: (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error)),
                        );
                      },
                    ),
                  ],
                ),

                // Live transcript indicator
                if (_isListeningForNote || _isListeningForObstacle) ...[
                  const SizedBox(height: 12),
                  VoiceListeningIndicator(currentText: _liveTranscript),
                ],

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

  Widget _buildTalkToCoachButton() {
    final isCoachReady = ReflectionCoach.instance.isReady;

    return OutlinedButton.icon(
      onPressed: _showCoachConversation
          ? null
          : (isCoachReady ? _startCoachConversation : null),
      icon: Icon(
        _showCoachConversation ? Icons.chat : Icons.psychology,
        size: 20,
      ),
      label: Text(
        _showCoachConversation
            ? 'Conversation started'
            : (isCoachReady ? 'Talk to Coach' : 'Coach offline'),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.tertiary,
        side: BorderSide(
          color: Theme.of(context).colorScheme.tertiary.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildCoachConversation() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: Theme.of(context).colorScheme.tertiary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Habit Coach',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    setState(() {
                      _showCoachConversation = false;
                      _conversation.clear();
                    });
                    ReflectionCoach.instance.endConversation();
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Messages
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(12),
              itemCount: _conversation.length + (_isLoadingCoachResponse ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _conversation.length && _isLoadingCoachResponse) {
                  return const _TypingIndicator();
                }
                final message = _conversation[index];
                return _buildChatBubble(message);
              },
            ),
          ),

          // Input area
          if (!_isLoadingCoachResponse && _conversation.isNotEmpty)
            _buildCoachInputArea(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(_ChatMessage message) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? const Radius.circular(4) : null,
            bottomLeft: !isUser ? const Radius.circular(4) : null,
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }

  Widget _buildCoachInputArea() {
    final TextEditingController replyController = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          VoiceInputButton(
            compact: true,
            size: 36,
            onResult: (text) {
              replyController.text = text;
              _sendToCoach(text);
            },
            onError: (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error)),
              );
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: replyController,
              decoration: InputDecoration(
                hintText: 'Reply to coach...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                isDense: true,
              ),
              onSubmitted: (text) {
                if (text.trim().isNotEmpty) {
                  _sendToCoach(text);
                  replyController.clear();
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (replyController.text.trim().isNotEmpty) {
                _sendToCoach(replyController.text);
                replyController.clear();
              }
            },
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

/// Simple chat message model
class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({required this.text, required this.isUser});
}

/// Typing indicator for AI responses
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomLeft: const Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final delay = index * 0.2;
                final value = (_controller.value + delay) % 1.0;
                final opacity = 0.3 + (0.7 * (value < 0.5 ? value * 2 : (1 - value) * 2));
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSecondaryContainer
                        .withOpacity(opacity),
                    shape: BoxShape.circle,
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
