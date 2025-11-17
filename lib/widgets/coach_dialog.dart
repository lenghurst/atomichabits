import 'package:flutter/material.dart';
import '../data/coach_service.dart';

/// Coach onboarding dialog - conversational habit discovery
///
/// This widget provides a simple step-by-step conversation with the coach
/// to collect context and generate a habit plan.
///
/// Flow:
/// 1. Show 5 questions one at a time
/// 2. User answers each question
/// 3. Generate habit plan from collected answers
/// 4. Show summary with "Apply to my setup" button
/// 5. Callback to parent to populate form
class CoachOnboardingDialog extends StatefulWidget {
  final String? userName;
  final Function(HabitPlanResult) onPlanGenerated;

  const CoachOnboardingDialog({
    super.key,
    this.userName,
    required this.onPlanGenerated,
  });

  @override
  State<CoachOnboardingDialog> createState() => _CoachOnboardingDialogState();
}

class _CoachOnboardingDialogState extends State<CoachOnboardingDialog> {
  // Current step in the conversation
  int _currentStep = 0;

  // User answers
  final Map<int, String> _answers = {};

  // Loading state
  bool _isGenerating = false;

  // Generated plan (null until generated)
  HabitPlanResult? _generatedPlan;

  // Error message
  String? _errorMessage;

  // Text controller for current answer
  final _answerController = TextEditingController();

  // Questions for the coach conversation
  final List<Map<String, String>> _questions = [
    {
      'question': 'What type of person are you trying to become?',
      'hint': 'e.g., "a reader", "a healthy person", "a writer"',
      'example': 'I want to be someone who reads regularly',
    },
    {
      'question': 'What\'s one small habit that would support that identity?',
      'hint': 'e.g., "read more", "exercise", "write every day"',
      'example': 'I want to read more books',
    },
    {
      'question': 'When in your day does this realistically fit?',
      'hint': 'e.g., "before bed", "morning coffee", "lunch break"',
      'example': 'Before bed around 9pm',
    },
    {
      'question': 'Where will you usually be when doing it?',
      'hint': 'e.g., "in bed", "at my desk", "on the couch"',
      'example': 'In bed',
    },
    {
      'question': 'What would make this more enjoyable or obvious?',
      'hint': 'e.g., "having tea", "music", "visual reminder"',
      'example': 'Having a cup of herbal tea',
    },
  ];

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _handleNext() {
    // Save current answer
    if (_answerController.text.trim().isNotEmpty) {
      _answers[_currentStep] = _answerController.text.trim();
    }

    setState(() {
      if (_currentStep < _questions.length - 1) {
        _currentStep++;
        _answerController.clear();
        // Pre-fill if user goes back and forth
        if (_answers.containsKey(_currentStep)) {
          _answerController.text = _answers[_currentStep]!;
        }
      }
    });
  }

  void _handleBack() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep--;
        // Pre-fill previous answer
        if (_answers.containsKey(_currentStep)) {
          _answerController.text = _answers[_currentStep]!;
        } else {
          _answerController.clear();
        }
      }
    });
  }

  Future<void> _handleGeneratePlan() async {
    // Save final answer
    if (_answerController.text.trim().isNotEmpty) {
      _answers[_currentStep] = _answerController.text.trim();
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      // Build context from answers
      final context = CoachContext(
        desiredIdentity: _answers[0],
        habitIdea: _answers[1],
        whenInDay: _answers[2],
        whereLocation: _answers[3],
        whatMakesItEnjoyable: _answers[4],
        userName: widget.userName,
      );

      // Call coach service
      final coachService = CoachService();
      final result = await coachService.generateHabitPlan(context: context);

      setState(() {
        _generatedPlan = result;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _errorMessage = 'The coach is temporarily unavailable. '
            'You can continue with the manual form or try again.';
      });
    }
  }

  void _handleApplyPlan() {
    if (_generatedPlan != null) {
      widget.onPlanGenerated(_generatedPlan!);
      Navigator.of(context).pop();
    }
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Show generated plan summary
    if (_generatedPlan != null) {
      return _buildPlanSummary();
    }

    // Show loading state
    if (_isGenerating) {
      return _buildLoadingState();
    }

    // Show conversation
    return _buildConversationStep();
  }

  Widget _buildConversationStep() {
    final currentQ = _questions[_currentStep];

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Talk to the Coach',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Question ${_currentStep + 1} of ${_questions.length}',
                          style: const TextStyle(fontSize: 12),
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
            LinearProgressIndicator(
              value: (_currentStep + 1) / _questions.length,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_currentStep == 0) ...[
                            const Text(
                              '👋 Hi! I\'m your Atomic Habits coach.',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'I\'ll ask you 5 quick questions to help design your first tiny habit. '
                              'Then I\'ll generate a complete plan you can review and adjust.',
                              style: TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 16),
                          ],
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.chat_bubble_outline, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  currentQ['question']!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Answer input
                    TextField(
                      controller: _answerController,
                      decoration: InputDecoration(
                        labelText: 'Your answer',
                        hintText: currentQ['hint'],
                        helperText: 'Example: ${currentQ['example']}',
                        helperMaxLines: 2,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.edit),
                      ),
                      maxLines: 3,
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) {
                        if (_currentStep == _questions.length - 1) {
                          _handleGeneratePlan();
                        } else {
                          _handleNext();
                        }
                      },
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red.shade900),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                  if (_currentStep > 0)
                    OutlinedButton.icon(
                      onPressed: _handleBack,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                    ),
                  const Spacer(),
                  if (_currentStep < _questions.length - 1)
                    FilledButton.icon(
                      onPressed: _answerController.text.trim().isEmpty
                          ? null
                          : _handleNext,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next'),
                    )
                  else
                    FilledButton.icon(
                      onPressed: _handleGeneratePlan,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Generate My Plan'),
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
              'The coach is designing your habit plan...',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'This may take a few seconds',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanSummary() {
    final plan = _generatedPlan!.habitPlan;
    final metadata = _generatedPlan!.metadata;

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
                          'Your Habit Plan is Ready!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Review and adjust before applying',
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
                    // Identity
                    _buildPlanField('Identity', plan.identity, Icons.star),
                    const SizedBox(height: 16),

                    // Habit
                    _buildPlanField('Habit', plan.habitName, Icons.check_circle),
                    const SizedBox(height: 16),

                    // Tiny version
                    _buildPlanField('Tiny Version', plan.tinyVersion, Icons.timer),
                    const SizedBox(height: 16),

                    // Implementation intention
                    _buildPlanField(
                      'When & Where',
                      '${plan.implementationTime} at ${plan.implementationLocation}',
                      Icons.place,
                    ),
                    const SizedBox(height: 16),

                    // Optional fields
                    if (plan.temptationBundle != null) ...[
                      _buildPlanField(
                        'Temptation Bundle',
                        plan.temptationBundle!,
                        Icons.favorite,
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (plan.preHabitRitual != null) ...[
                      _buildPlanField(
                        'Pre-Habit Ritual',
                        plan.preHabitRitual!,
                        Icons.self_improvement,
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (plan.environmentCue != null) ...[
                      _buildPlanField(
                        'Environment Cue',
                        plan.environmentCue!,
                        Icons.lightbulb,
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (plan.environmentDistraction != null) ...[
                      _buildPlanField(
                        'Remove Distraction',
                        plan.environmentDistraction!,
                        Icons.block,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Metadata notes
                    if (metadata.notes != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                metadata.notes!,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                  OutlinedButton(
                    onPressed: _handleCancel,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _handleApplyPlan,
                      icon: const Icon(Icons.done),
                      label: const Text('Apply to My Setup'),
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

  Widget _buildPlanField(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.deepPurple),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
