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
      'question': '1. Who are you trying to become?',
      'hint': 'e.g., "a reader", "someone who moves every day", "a calmer person"',
      'helper': 'Think about the type of person you\'d be proud to become, not just what you want to do.',
    },
    {
      'question': '2. What\'s one habit that would support that?',
      'hint': 'e.g., "read more books", "go for a walk", "meditate", "write daily"',
      'helper': 'Don\'t worry about getting it perfect. Just write the first habit that comes to mind.',
    },
    {
      'question': '3. When does this realistically fit into your day?',
      'hint': 'e.g., "before bed around 10pm", "after breakfast", "just after work"',
      'helper': 'Choose a moment that already exists in your routine. We\'ll turn it into a clear time.',
    },
    {
      'question': '4. Where will you usually be when you do it?',
      'hint': 'e.g., "in bed", "at my desk", "in the living room", "at the gym"',
      'helper': 'A clear place makes the habit easier to see and remember.',
    },
    {
      'question': '5. What would make this feel easier or more enjoyable?',
      'hint': 'e.g., "a cup of tea", "my favourite playlist", "laying my book on my pillow"',
      'helper': 'This helps us build in a tiny ritual, a reward, or a clear cue.',
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
      });

      // Show error dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Coach is currently offline'),
            content: const Text(
              'Something went wrong while generating your plan.\n\n'
              'You can still set up your habit manually – the form below will guide you.',
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close error dialog
                  Navigator.of(context).pop(); // Close coach dialog
                },
                child: const Text('Continue without coach'),
              ),
            ],
          ),
        );
      }
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
                              'Let\'s design a habit that fits your life.',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'I\'ll ask 5 short questions. You can change anything later.',
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
                        helperText: currentQ['helper'],
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        FilledButton.icon(
                          onPressed: _handleGeneratePlan,
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('Generate my habit plan'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'We\'ll create a tiny starting version that takes\nabout two minutes or less.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
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
              'The coach is designing your habit plan…',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'This usually takes a few seconds.\nWe\'re turning your answers into a tiny habit and system you can edit.',
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
                          'Here\'s your suggested habit plan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'This is a starting point based on your answers.',
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
                    Text(
                      'You can adjust anything that doesn\'t feel realistic.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Identity
                    _buildPlanField('Identity', plan.identity, Icons.star),
                    const SizedBox(height: 16),

                    // Habit
                    _buildPlanField('Habit', plan.habitName, Icons.check_circle),
                    const SizedBox(height: 16),

                    // Tiny version (2-minute version)
                    _buildPlanField('2-minute version', plan.tinyVersion, Icons.timer),
                    const SizedBox(height: 16),

                    // Time
                    _buildPlanField('Time', plan.implementationTime, Icons.schedule),
                    const SizedBox(height: 16),

                    // Place
                    _buildPlanField('Place', plan.implementationLocation, Icons.place),
                    const SizedBox(height: 16),

                    // Optional fields
                    if (plan.temptationBundle != null) ...[
                      _buildPlanField(
                        'Temptation bundle',
                        plan.temptationBundle!,
                        Icons.favorite,
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (plan.preHabitRitual != null) ...[
                      _buildPlanField(
                        'Pre-habit ritual',
                        plan.preHabitRitual!,
                        Icons.self_improvement,
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (plan.environmentCue != null) ...[
                      _buildPlanField(
                        'Environment cue',
                        plan.environmentCue!,
                        Icons.lightbulb,
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (plan.environmentDistraction != null) ...[
                      _buildPlanField(
                        'Distraction guardrail',
                        plan.environmentDistraction!,
                        Icons.block,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Show missing fields warning if any
                    if (metadata.missingFields != null && metadata.missingFields!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: metadata.confidence >= 0.6
                              ? Colors.orange.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: metadata.confidence >= 0.6
                                ? Colors.orange.shade200
                                : Colors.red.shade200,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.warning_outlined,
                              size: 20,
                              color: metadata.confidence >= 0.6
                                  ? Colors.orange.shade700
                                  : Colors.red.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'The coach isn\'t sure about: ${metadata.missingFields!.join(", ")}.\n'
                                'You\'ll want to double-check these before you start.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: metadata.confidence >= 0.6
                                      ? Colors.orange.shade900
                                      : Colors.red.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Low confidence warning
                    if (metadata.confidence < 0.6) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade300),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, size: 20, color: Colors.amber.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'The coach had to guess some parts. Please review carefully and adjust before applying.',
                                style: TextStyle(fontSize: 13, color: Colors.amber.shade900),
                              ),
                            ),
                          ],
                        ),
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
                            const Icon(Icons.lightbulb_outline, size: 20, color: Colors.blue),
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
                      label: const Text('Apply to my setup'),
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
