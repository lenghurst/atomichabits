import 'package:flutter/material.dart';
import '../data/models/habit.dart';

/// Add Habit Dialog
///
/// Simplified flow for adding additional habits after initial onboarding.
/// Based on Atomic Habits: "Start small" and "implementation intentions"
///
/// Features:
/// - Quick habit setup (name, identity, tiny version)
/// - Implementation intention (when & where)
/// - Optional: habit stacking (anchor event)
class AddHabitDialog extends StatefulWidget {
  final Function(Habit) onHabitCreated;
  final VoidCallback onCancel;

  const AddHabitDialog({
    super.key,
    required this.onHabitCreated,
    required this.onCancel,
  });

  @override
  State<AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<AddHabitDialog> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _nameController = TextEditingController();
  final _identityController = TextEditingController();
  final _tinyVersionController = TextEditingController();
  final _locationController = TextEditingController();
  final _anchorEventController = TextEditingController();

  // Time picker state
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  // Common habit templates
  final List<Map<String, String>> _habitTemplates = [
    {
      'name': 'Read',
      'identity': 'I am a reader',
      'tiny': 'Read one page',
    },
    {
      'name': 'Exercise',
      'identity': 'I am someone who moves daily',
      'tiny': 'Do 1 pushup',
    },
    {
      'name': 'Meditate',
      'identity': 'I am someone who practices mindfulness',
      'tiny': 'Take 3 deep breaths',
    },
    {
      'name': 'Write',
      'identity': 'I am a writer',
      'tiny': 'Write one sentence',
    },
    {
      'name': 'Learn a language',
      'identity': 'I am a language learner',
      'tiny': 'Review 1 word',
    },
    {
      'name': 'Practice instrument',
      'identity': 'I am a musician',
      'tiny': 'Play for 2 minutes',
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _identityController.dispose();
    _tinyVersionController.dispose();
    _locationController.dispose();
    _anchorEventController.dispose();
    super.dispose();
  }

  void _selectTemplate(Map<String, String> template) {
    setState(() {
      _nameController.text = template['name'] ?? '';
      _identityController.text = template['identity'] ?? '';
      _tinyVersionController.text = template['tiny'] ?? '';
    });
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _nextStep() {
    if (_currentStep == 0) {
      // Validate basic info
      if (_nameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a habit name')),
        );
        return;
      }
      if (_identityController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your identity statement')),
        );
        return;
      }
      if (_tinyVersionController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a tiny version')),
        );
        return;
      }
    }

    if (_currentStep < 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      _createHabit();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _createHabit() {
    final habit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      identity: _identityController.text.trim(),
      tinyVersion: _tinyVersionController.text.trim(),
      createdAt: DateTime.now(),
      implementationTime: _formatTime(_selectedTime),
      implementationLocation: _locationController.text.trim().isNotEmpty
          ? _locationController.text.trim()
          : 'At home',
      anchorEvent: _anchorEventController.text.trim().isNotEmpty
          ? _anchorEventController.text.trim()
          : null,
    );

    widget.onHabitCreated(habit);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add_task,
                          color: Colors.green.shade600,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Add New Habit',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Step ${_currentStep + 1} of 2',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: widget.onCancel,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Step indicator
                  Row(
                    children: List.generate(2, (index) => Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: index <= _currentStep
                              ? Colors.green
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    )),
                  ),
                  const SizedBox(height: 24),

                  // Step content
                  if (_currentStep == 0) _buildBasicInfoStep(),
                  if (_currentStep == 1) _buildImplementationStep(),

                  const SizedBox(height: 24),

                  // Navigation buttons
                  Row(
                    children: [
                      if (_currentStep > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _previousStep,
                            child: const Text('Back'),
                          ),
                        ),
                      if (_currentStep > 0) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _nextStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(_currentStep < 1 ? 'Next' : 'Create Habit'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick templates
        const Text(
          'Quick Start (tap to use)',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _habitTemplates.map((template) => ActionChip(
            label: Text(template['name'] ?? ''),
            onPressed: () => _selectTemplate(template),
            backgroundColor: _nameController.text == template['name']
                ? Colors.green.shade100
                : null,
          )).toList(),
        ),
        const SizedBox(height: 20),

        // Habit name
        const Text(
          'What habit do you want to build?',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'e.g., Read, Exercise, Meditate',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        const SizedBox(height: 16),

        // Identity
        const Text(
          'Who do you want to become?',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          '"Every action is a vote for the type of person you wish to become"',
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _identityController,
          decoration: InputDecoration(
            hintText: 'I am someone who...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        const SizedBox(height: 16),

        // Tiny version (2-minute rule)
        const Text(
          'What\'s the 2-minute version?',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Make it so easy you can\'t say no',
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _tinyVersionController,
          decoration: InputDecoration(
            hintText: 'e.g., Read one page, Do 1 pushup',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  Widget _buildImplementationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Implementation intention explanation
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '"I will [BEHAVIOR] at [TIME] in [LOCATION]"',
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Time picker
        const Text(
          'When will you do this habit?',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectTime,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey.shade600),
                const SizedBox(width: 12),
                Text(
                  _selectedTime.format(context),
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                Text(
                  'Tap to change',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Location
        const Text(
          'Where will you do it?',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _locationController,
          decoration: InputDecoration(
            hintText: 'e.g., In my bedroom, At my desk',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        const SizedBox(height: 16),

        // Habit stacking (optional)
        const Text(
          'Stack with existing habit (optional)',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          '"After I [CURRENT HABIT], I will [NEW HABIT]"',
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _anchorEventController,
          decoration: InputDecoration(
            hintText: 'e.g., After I brush my teeth, After my morning coffee',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }
}
