import 'package:flutter/material.dart';
import '../data/models/habit.dart';
import '../data/models/user_profile.dart';
import '../data/daily_coach_service.dart';

/// Daily reflection coach dialog - helps users understand their day
///
/// This widget provides a 3-step conversation with the coach to:
/// 1. Check if habit was completed/partial/missed
/// 2. Gather context about what happened
/// 3. Get 1% easier suggestions for tomorrow
///
/// Flow:
/// 1. Status selection (completed/partial/missed)
/// 2. Context questions (what happened, what helped/blocked, ideas for tomorrow)
/// 3. Call coach API and show personalized insights
/// 4. Optional: Save reflection note
class DailyCoachDialog extends StatefulWidget {
  final Habit habit;
  final UserProfile profile;
  final Function(String note)? onSaveReflection;

  const DailyCoachDialog({
    super.key,
    required this.habit,
    required this.profile,
    this.onSaveReflection,
  });

  @override
  State<DailyCoachDialog> createState() => _DailyCoachDialogState();
}

class _DailyCoachDialogState extends State<DailyCoachDialog> {
  // Current step in the conversation (0: status, 1: context, 2: results)
  int _currentStep = 0;

  // Step 0: Status
  String? _selectedStatus; // "completed", "partial", "missed"

  // Step 1: Context
  final _whatHappenedController = TextEditingController();
  final _whatHelpedOrBlockedController = TextEditingController();
  final _whatMightHelpTomorrowController = TextEditingController();

  // Loading state
  bool _isGenerating = false;

  // Generated response
  DailyCoachResponse? _coachResponse;

  // Error state
  String? _errorMessage;

  // Save reflection checkbox
  bool _shouldSaveReflection = true;

  @override
  void dispose() {
    _whatHappenedController.dispose();
    _whatHelpedOrBlockedController.dispose();
    _whatMightHelpTomorrowController.dispose();
    super.dispose();
  }

  void _handleNext() {
    setState(() {
      if (_currentStep < 1) {
        _currentStep++;
      }
    });
  }

  void _handleBack() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep--;
      }
    });
  }

  Future<void> _handleGenerateReflection() async {
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      // Build date string (today)
      final now = DateTime.now();
      final dateString = '${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';

      // Build request
      final request = DailyReflectionRequest(
        habit: DailyHabitInfo(
          habitName: widget.habit.name,
          identity: widget.profile.identity,
          twoMinuteVersion: widget.habit.tinyVersion,
          time: widget.habit.implementationTime,
          location: widget.habit.implementationLocation,
        ),
        date: dateString,
        status: _selectedStatus!,
        reflection: DailyReflectionContext(
          whatHappened: _whatHappenedController.text.trim().isEmpty
              ? null
              : _whatHappenedController.text.trim(),
          whatHelpedOrBlocked: _whatHelpedOrBlockedController.text.trim().isEmpty
              ? null
              : _whatHelpedOrBlockedController.text.trim(),
          whatMightHelpTomorrow: _whatMightHelpTomorrowController.text.trim().isEmpty
              ? null
              : _whatMightHelpTomorrowController.text.trim(),
        ),
      );

      // Call coach service
      final coachService = DailyCoachService();
      final response = await coachService.generateReflection(request: request);

      setState(() {
        _coachResponse = response;
        _currentStep = 2; // Move to results step
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _errorMessage = e.toString();
      });

      // Show error dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Coach is currently offline'),
            content: const Text(
              'Something went wrong while generating your reflection.\n\n'
              'Your habit data is still saved. You can try reflecting again later.',
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close error dialog
                  Navigator.of(context).pop(); // Close coach dialog
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _handleSaveAndClose() {
    // Build reflection note from user inputs
    if (_shouldSaveReflection && widget.onSaveReflection != null) {
      final note = _buildReflectionNote();
      widget.onSaveReflection!(note);
    }

    Navigator.of(context).pop();
  }

  String _buildReflectionNote() {
    final parts = <String>[];

    parts.add('Status: $_selectedStatus');

    if (_whatHappenedController.text.trim().isNotEmpty) {
      parts.add('What happened: ${_whatHappenedController.text.trim()}');
    }

    if (_whatHelpedOrBlockedController.text.trim().isNotEmpty) {
      parts.add('What helped/blocked: ${_whatHelpedOrBlockedController.text.trim()}');
    }

    if (_whatMightHelpTomorrowController.text.trim().isNotEmpty) {
      parts.add('Ideas for tomorrow: ${_whatMightHelpTomorrowController.text.trim()}');
    }

    if (_coachResponse != null) {
      parts.add('\nCoach: ${_coachResponse!.coachMessage}');
      if (_coachResponse!.suggestedTomorrowExperiment.isNotEmpty) {
        parts.add('Tomorrow experiment: ${_coachResponse!.suggestedTomorrowExperiment}');
      }
    }

    return parts.join('\n');
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading state
    if (_isGenerating) {
      return _buildLoadingState();
    }

    // Show results
    if (_coachResponse != null && _currentStep == 2) {
      return _buildResultsStep();
    }

    // Show conversation steps
    switch (_currentStep) {
      case 0:
        return _buildStatusStep();
      case 1:
        return _buildContextStep();
      default:
        return _buildStatusStep();
    }
  }

  Widget _buildStatusStep() {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.psychology, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Reflection',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Step 1 of 2',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _handleCancel,
                  ),
                ],
              ),
            ),

            // Progress indicator
            const LinearProgressIndicator(value: 0.5),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Coach message
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.chat_bubble_outline, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'How did it go with "${widget.habit.name}" today?',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'There\'s no right or wrong answer. Every day teaches us something.',
                                  style: TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Status options
                    RadioListTile<String>(
                      value: 'completed',
                      groupValue: _selectedStatus,
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value;
                        });
                      },
                      title: const Text('I did it! ✅'),
                      subtitle: const Text('Completed the habit today'),
                    ),

                    RadioListTile<String>(
                      value: 'partial',
                      groupValue: _selectedStatus,
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value;
                        });
                      },
                      title: const Text('Partial progress 🟡'),
                      subtitle: const Text('Started but didn\'t finish'),
                    ),

                    RadioListTile<String>(
                      value: 'missed',
                      groupValue: _selectedStatus,
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value;
                        });
                      },
                      title: const Text('Didn\'t happen today ⭕'),
                      subtitle: const Text('Missed it this time'),
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _selectedStatus == null ? null : _handleNext,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContextStep() {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.psychology, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Reflection',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Step 2 of 2',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _handleCancel,
                  ),
                ],
              ),
            ),

            // Progress indicator
            const LinearProgressIndicator(value: 1.0),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Coach message
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Let\'s figure out what made today work (or not work).',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Question 1: What happened?
                    TextField(
                      controller: _whatHappenedController,
                      decoration: const InputDecoration(
                        labelText: 'What happened? (optional)',
                        hintText: 'e.g., "I was too tired" or "I felt energized after coffee"',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                    ),

                    const SizedBox(height: 16),

                    // Question 2: What helped or blocked?
                    TextField(
                      controller: _whatHelpedOrBlockedController,
                      decoration: const InputDecoration(
                        labelText: 'What helped or blocked you? (optional)',
                        hintText: 'e.g., "My phone distracted me" or "The book was on my pillow"',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lightbulb_outline),
                      ),
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                    ),

                    const SizedBox(height: 16),

                    // Question 3: What might help tomorrow?
                    TextField(
                      controller: _whatMightHelpTomorrowController,
                      decoration: const InputDecoration(
                        labelText: 'What would make it 1% easier tomorrow? (optional)',
                        hintText: 'e.g., "Charge my phone in the kitchen"',
                        helperText: 'Just one tiny change you could test',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.science),
                      ),
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                    ),

                    const SizedBox(height: 16),

                    // Helper text
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, size: 20, color: Colors.amber.shade700),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'You can skip these questions. The coach will still help you make sense of your day.',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _handleBack,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _handleGenerateReflection,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Get coach insights'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
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

  Widget _buildLoadingState() {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(32),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text(
              'The coach is reflecting on your day…',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Analyzing patterns and finding tiny improvements',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsStep() {
    final response = _coachResponse!;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade700, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Coach Insights',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Here\'s what I noticed',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _handleCancel,
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Coach message
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.chat_bubble_outline, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              response.coachMessage,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Insights
                    if (response.insights.isNotEmpty) ...[
                      const Text(
                        'Patterns I noticed:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...response.insights.map((insight) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.lightbulb, size: 18, color: Colors.orange),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    insight,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 20),
                    ],

                    // Suggested adjustments
                    if (response.suggestedAdjustments.isNotEmpty) ...[
                      const Text(
                        'Tiny adjustments to try:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...response.suggestedAdjustments.map((adjustment) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.tune, size: 18, color: Colors.deepPurple),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    adjustment,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 20),
                    ],

                    // Tomorrow experiment
                    if (response.suggestedTomorrowExperiment.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.science, color: Colors.amber.shade700, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Tomorrow\'s experiment:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              response.suggestedTomorrowExperiment,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Save reflection checkbox
                    CheckboxListTile(
                      value: _shouldSaveReflection,
                      onChanged: (value) {
                        setState(() {
                          _shouldSaveReflection = value ?? true;
                        });
                      },
                      title: const Text('Save this reflection'),
                      subtitle: const Text('Add to your habit history'),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: _handleSaveAndClose,
                      child: const Text('Done'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
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
}
