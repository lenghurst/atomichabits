import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/app_state.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/habit.dart';

/// Onboarding screen - collects user identity and first habit
/// Based on Atomic Habits: Identity-based habits + Implementation intentions
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _identityController = TextEditingController();
  final _habitNameController = TextEditingController();
  final _tinyVersionController = TextEditingController();
  final _locationController = TextEditingController();
  
  // Implementation intention: Time
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void dispose() {
    _nameController.dispose();
    _identityController.dispose();
    _habitNameController.dispose();
    _tinyVersionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // Show time picker dialog
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Format TimeOfDay to readable string (HH:MM)
  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _completeOnboarding() async {
    if (_formKey.currentState?.validate() ?? false) {
      final appState = Provider.of<AppState>(context, listen: false);

      // Create user profile
      final profile = UserProfile(
        name: _nameController.text.trim(),
        identity: _identityController.text.trim(),
        createdAt: DateTime.now(),
      );

      // Create first habit with implementation intentions
      final habit = Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _habitNameController.text.trim(),
        identity: _identityController.text.trim(),
        tinyVersion: _tinyVersionController.text.trim(),
        createdAt: DateTime.now(),
        implementationTime: _formatTime(_selectedTime),
        implementationLocation: _locationController.text.trim(),
      );

      // Save to state (now with persistence!)
      await appState.setUserProfile(profile);
      await appState.createHabit(habit);
      await appState.completeOnboarding();

      // Navigate to Today screen
      if (mounted) {
        context.go('/today');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Atomic Habits'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  '🎯 Build Your Identity',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Every action you take is a vote for the type of person you want to become.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'What\'s your name?',
                    hintText: 'Enter your name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Identity field
                TextFormField(
                  controller: _identityController,
                  decoration: const InputDecoration(
                    labelText: 'Who do you want to become?',
                    hintText: 'e.g., "I am a healthy person"',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.star),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please describe your desired identity';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Habit section
                Text(
                  '✨ Your First Tiny Habit',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Start with something so easy you can\'t say no.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // Habit name
                TextFormField(
                  controller: _habitNameController,
                  decoration: const InputDecoration(
                    labelText: 'What habit do you want to build?',
                    hintText: 'e.g., "Read every day"',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.check_circle),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a habit name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Tiny version (2-minute rule)
                TextFormField(
                  controller: _tinyVersionController,
                  decoration: const InputDecoration(
                    labelText: 'Make it tiny (2-minute version)',
                    hintText: 'e.g., "Read one page"',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.timer),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a tiny version of your habit';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Implementation intentions section
                Text(
                  '📍 Make It Obvious (Implementation Intention)',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '"I will [habit] at [time] in [location]" — James Clear',
                  style: TextStyle(fontSize: 16, color: Colors.grey, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 24),

                // Time picker
                InkWell(
                  onTap: _selectTime,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'At what time each day?',
                      hintText: 'Select a time',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedTime.format(context),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Location field
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Where will you usually do it?',
                    hintText: 'e.g., "In bed before sleep", "At my desk", "On the sofa"',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.place),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a location for your habit';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Complete button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _completeOnboarding,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Start Building Habits',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
