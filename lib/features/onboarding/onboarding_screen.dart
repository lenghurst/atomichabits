import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/app_state.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/habit.dart';
import '../../widgets/suggestion_dialog.dart';
import '../../widgets/coach_dialog.dart';
import '../../data/coach_service.dart';

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
  
  // New "Make it Attractive" and environment design controllers
  final _temptationBundleController = TextEditingController();
  final _preHabitRitualController = TextEditingController();
  final _environmentCueController = TextEditingController();
  final _environmentDistractionController = TextEditingController();
  
  // Implementation intention: Time
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void dispose() {
    _nameController.dispose();
    _identityController.dispose();
    _habitNameController.dispose();
    _tinyVersionController.dispose();
    _locationController.dispose();
    _temptationBundleController.dispose();
    _preHabitRitualController.dispose();
    _environmentCueController.dispose();
    _environmentDistractionController.dispose();
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

  // Helper: Show suggestion dialog for temptation bundle (async with loading state)
  Future<void> _showTemptationBundleSuggestions() async {
    final appState = Provider.of<AppState>(context, listen: false);
    
    // Show loading dialog immediately
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Getting suggestions...'),
              ],
            ),
          ),
        ),
      ),
    );
    
    try {
      // Create temporary habit to get suggestions
      final tempHabit = Habit(
        id: 'temp',
        name: _habitNameController.text.trim().isEmpty 
            ? 'your habit' 
            : _habitNameController.text.trim(),
        identity: _identityController.text.trim().isEmpty 
            ? 'achieves their goals' 
            : _identityController.text.trim(),
        tinyVersion: _tinyVersionController.text.trim().isEmpty 
            ? 'start small' 
            : _tinyVersionController.text.trim(),
        createdAt: DateTime.now(),
        implementationTime: _formatTime(_selectedTime),
        implementationLocation: _locationController.text.trim().isEmpty 
            ? 'at home' 
            : _locationController.text.trim(),
      );
      
      // Save current habit temporarily to get suggestions
      final originalHabit = appState.currentHabit;
      await appState.createHabit(tempHabit);
      
      // Fetch suggestions (async - remote LLM with local fallback)
      final suggestions = await appState.getTemptationBundleSuggestionsForCurrentHabit();
      
      // Restore original habit
      if (originalHabit != null) {
        await appState.createHabit(originalHabit);
      }
      
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();
      
      // Show suggestions dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => SuggestionDialog(
            title: 'Temptation Bundling Ideas',
            subtitle: 'Pair your habit with something you enjoy',
            suggestions: suggestions,
            onSuggestionSelected: (suggestion) {
              setState(() {
                _temptationBundleController.text = suggestion;
              });
            },
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to get suggestions. Please try again.'),
          ),
        );
      }
    }
  }
  
  // Helper: Show suggestion dialog for pre-habit ritual (async with loading state)
  Future<void> _showPreHabitRitualSuggestions() async {
    final appState = Provider.of<AppState>(context, listen: false);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Getting suggestions...'),
              ],
            ),
          ),
        ),
      ),
    );
    
    try {
      final tempHabit = Habit(
        id: 'temp',
        name: _habitNameController.text.trim().isEmpty ? 'your habit' : _habitNameController.text.trim(),
        identity: _identityController.text.trim().isEmpty ? 'achieves their goals' : _identityController.text.trim(),
        tinyVersion: _tinyVersionController.text.trim().isEmpty ? 'start small' : _tinyVersionController.text.trim(),
        createdAt: DateTime.now(),
        implementationTime: _formatTime(_selectedTime),
        implementationLocation: _locationController.text.trim().isEmpty ? 'at home' : _locationController.text.trim(),
      );
      
      final originalHabit = appState.currentHabit;
      await appState.createHabit(tempHabit);
      final suggestions = await appState.getPreHabitRitualSuggestionsForCurrentHabit();
      
      if (originalHabit != null) {
        await appState.createHabit(originalHabit);
      }
      
      if (mounted) Navigator.of(context).pop();
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => SuggestionDialog(
            title: 'Pre-Habit Ritual Ideas',
            subtitle: '10-30 second rituals to prime your mindset',
            suggestions: suggestions,
            onSuggestionSelected: (suggestion) {
              setState(() {
                _preHabitRitualController.text = suggestion;
              });
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get suggestions. Please try again.')),
        );
      }
    }
  }
  
  // Helper: Show suggestion dialog for environment cue (async with loading state)
  Future<void> _showEnvironmentCueSuggestions() async {
    final appState = Provider.of<AppState>(context, listen: false);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Getting suggestions...'),
              ],
            ),
          ),
        ),
      ),
    );
    
    try {
      final tempHabit = Habit(
        id: 'temp',
        name: _habitNameController.text.trim().isEmpty ? 'your habit' : _habitNameController.text.trim(),
        identity: _identityController.text.trim().isEmpty ? 'achieves their goals' : _identityController.text.trim(),
        tinyVersion: _tinyVersionController.text.trim().isEmpty ? 'start small' : _tinyVersionController.text.trim(),
        createdAt: DateTime.now(),
        implementationTime: _formatTime(_selectedTime),
        implementationLocation: _locationController.text.trim().isEmpty ? 'at home' : _locationController.text.trim(),
      );
      
      final originalHabit = appState.currentHabit;
      await appState.createHabit(tempHabit);
      final suggestions = await appState.getEnvironmentCueSuggestionsForCurrentHabit();
      
      if (originalHabit != null) {
        await appState.createHabit(originalHabit);
      }
      
      if (mounted) Navigator.of(context).pop();
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => SuggestionDialog(
            title: 'Environment Cue Ideas',
            subtitle: 'Make your habit obvious with visual triggers',
            suggestions: suggestions,
            onSuggestionSelected: (suggestion) {
              setState(() {
                _environmentCueController.text = suggestion;
              });
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get suggestions. Please try again.')),
        );
      }
    }
  }
  
  // Helper: Show suggestion dialog for environment distraction (async with loading state)
  Future<void> _showEnvironmentDistractionSuggestions() async {
    final appState = Provider.of<AppState>(context, listen: false);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Getting suggestions...'),
              ],
            ),
          ),
        ),
      ),
    );
    
    try {
      final tempHabit = Habit(
        id: 'temp',
        name: _habitNameController.text.trim().isEmpty ? 'your habit' : _habitNameController.text.trim(),
        identity: _identityController.text.trim().isEmpty ? 'achieves their goals' : _identityController.text.trim(),
        tinyVersion: _tinyVersionController.text.trim().isEmpty ? 'start small' : _tinyVersionController.text.trim(),
        createdAt: DateTime.now(),
        implementationTime: _formatTime(_selectedTime),
        implementationLocation: _locationController.text.trim().isEmpty ? 'at home' : _locationController.text.trim(),
      );
      
      final originalHabit = appState.currentHabit;
      await appState.createHabit(tempHabit);
      final suggestions = await appState.getEnvironmentDistractionSuggestionsForCurrentHabit();
      
      if (originalHabit != null) {
        await appState.createHabit(originalHabit);
      }
      
      if (mounted) Navigator.of(context).pop();
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => SuggestionDialog(
            title: 'Remove Distractions',
            subtitle: 'Make bad habits harder by removing obstacles',
            suggestions: suggestions,
            onSuggestionSelected: (suggestion) {
              setState(() {
                _environmentDistractionController.text = suggestion;
              });
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get suggestions. Please try again.')),
        );
      }
    }
  }

  // ========== COACH ONBOARDING METHODS ==========

  /// Show the coach onboarding dialog
  Future<void> _showCoachDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CoachOnboardingDialog(
        userName: _nameController.text.trim().isEmpty
            ? null
            : _nameController.text.trim(),
        onPlanGenerated: _handleCoachPlanGenerated,
      ),
    );
  }

  /// Handle the generated plan from the coach and populate the form
  void _handleCoachPlanGenerated(HabitPlanResult result) {
    final plan = result.habitPlan;
    final metadata = result.metadata;

    setState(() {
      // Populate identity field (only if non-empty and valid)
      if (plan.identity.isNotEmpty && plan.identity.length >= 5) {
        _identityController.text = plan.identity;
      }

      // Populate habit name and tiny version (only if non-empty)
      if (plan.habitName.isNotEmpty && plan.habitName.length >= 3) {
        _habitNameController.text = plan.habitName;
      }
      if (plan.tinyVersion.isNotEmpty && plan.tinyVersion.length >= 3) {
        _tinyVersionController.text = plan.tinyVersion;
      }

      // Parse and set time (with fallback to 20:00 if invalid)
      final timeParts = plan.implementationTime.split(':');
      if (timeParts.length == 2) {
        final hour = int.tryParse(timeParts[0]);
        final minute = int.tryParse(timeParts[1]);
        if (hour != null && minute != null && hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
          _selectedTime = TimeOfDay(hour: hour, minute: minute);
        } else {
          // Invalid time, fallback to 20:00
          _selectedTime = const TimeOfDay(hour: 20, minute: 0);
        }
      } else {
        // Malformed time, fallback to 20:00
        _selectedTime = const TimeOfDay(hour: 20, minute: 0);
      }

      // Populate location (only if non-empty and valid)
      if (plan.implementationLocation.isNotEmpty && plan.implementationLocation.length >= 3) {
        _locationController.text = plan.implementationLocation;
      }

      // Populate optional fields only if present and non-empty
      if (plan.temptationBundle != null && plan.temptationBundle!.isNotEmpty) {
        _temptationBundleController.text = plan.temptationBundle!;
      }
      if (plan.preHabitRitual != null && plan.preHabitRitual!.isNotEmpty) {
        _preHabitRitualController.text = plan.preHabitRitual!;
      }
      if (plan.environmentCue != null && plan.environmentCue!.isNotEmpty) {
        _environmentCueController.text = plan.environmentCue!;
      }
      if (plan.environmentDistraction != null && plan.environmentDistraction!.isNotEmpty) {
        _environmentDistractionController.text = plan.environmentDistraction!;
      }
    });

    // Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your habit plan has been applied. You can tweak any field before starting.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 4),
      ),
    );
  }

  /// Determines celebration style based on habit time and location
  /// Late evening (≥22:00) + quiet locations → Calm
  /// Otherwise → Standard
  CelebrationStyle _determineCelebrationStyle(String time, String location) {
    // Parse hour from time (format: "HH:mm")
    final hour = int.tryParse(time.split(':')[0]) ?? 12;

    // Normalize location to lowercase for matching
    final normalizedLocation = location.toLowerCase();

    // Check for quiet/bedtime locations
    final isQuietLocation = normalizedLocation.contains('bed') ||
        normalizedLocation.contains('bedroom') ||
        normalizedLocation.contains('sofa');

    // Late evening (22:00 or later) + quiet location → Calm
    if (hour >= 22 && isQuietLocation) {
      return CelebrationStyle.calm;
    }

    // Default to standard for all other cases
    return CelebrationStyle.standard;
  }

  Future<void> _completeOnboarding() async {
    if (_formKey.currentState?.validate() ?? false) {
      final appState = Provider.of<AppState>(context, listen: false);

      // Determine celebration style based on habit time and location
      final celebrationStyle = _determineCelebrationStyle(
        _formatTime(_selectedTime),
        _locationController.text.trim(),
      );

      // Create user profile with AI-informed celebration style
      final profile = UserProfile(
        name: _nameController.text.trim(),
        identity: _identityController.text.trim(),
        createdAt: DateTime.now(),
        celebrationStyle: celebrationStyle,
      );

      // Create first habit with implementation intentions + Make it Attractive
      final habit = Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _habitNameController.text.trim(),
        identity: _identityController.text.trim(),
        tinyVersion: _tinyVersionController.text.trim(),
        createdAt: DateTime.now(),
        implementationTime: _formatTime(_selectedTime),
        implementationLocation: _locationController.text.trim(),
        // New "Make it Attractive" and environment design fields
        temptationBundle: _temptationBundleController.text.trim().isEmpty 
            ? null 
            : _temptationBundleController.text.trim(),
        preHabitRitual: _preHabitRitualController.text.trim().isEmpty 
            ? null 
            : _preHabitRitualController.text.trim(),
        environmentCue: _environmentCueController.text.trim().isEmpty 
            ? null 
            : _environmentCueController.text.trim(),
        environmentDistraction: _environmentDistractionController.text.trim().isEmpty 
            ? null 
            : _environmentDistractionController.text.trim(),
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
                const SizedBox(height: 24),

                // Coach onboarding option
                Card(
                  color: Colors.deepPurple.shade50,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.psychology, color: Colors.deepPurple.shade700, size: 28),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Talk to your habit coach',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Answer 5 quick questions and let the coach design a tiny habit and system for you.',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'You\'ll still be able to review and edit everything before you start.',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _showCoachDialog,
                            icon: const Icon(Icons.chat),
                            label: const Text('Start coach conversation'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or fill in your plan manually',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),

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

                // === MAKE IT ATTRACTIVE SECTION ===
                
                Text(
                  '✨ Make it Attractive (Optional)',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bundle your habit with something you enjoy!',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),

                // Temptation bundling field with "Get ideas" button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _temptationBundleController,
                        decoration: const InputDecoration(
                          labelText: 'What will you pair this habit with that you enjoy?',
                          hintText: 'e.g., "Have herbal tea while reading"',
                          helperText: 'Examples:\n'
                              '• Listen to a podcast while walking\n'
                              '• Play your favourite playlist while tidying',
                          helperMaxLines: 3,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.favorite),
                        ),
                        maxLines: 2,
                        // Optional field - no validator
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: OutlinedButton.icon(
                        onPressed: _showTemptationBundleSuggestions,
                        icon: const Icon(Icons.lightbulb_outline, size: 18),
                        label: const Text('Ideas'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Pre-habit ritual field with "Get ideas" button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _preHabitRitualController,
                        decoration: const InputDecoration(
                          labelText: 'Pre-habit ritual (10-30 seconds, optional)',
                          hintText: 'e.g., "3 deep breaths before reading"',
                          helperText: 'A short ritual to get into the right mindset:\n'
                              '• 3 deep breaths\n'
                              '• Put phone on airplane mode\n'
                              '• Play 1 song',
                          helperMaxLines: 4,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.self_improvement),
                        ),
                        maxLines: 2,
                        // Optional field - no validator
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: OutlinedButton.icon(
                        onPressed: _showPreHabitRitualSuggestions,
                        icon: const Icon(Icons.lightbulb_outline, size: 18),
                        label: const Text('Ideas'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // === ENVIRONMENT DESIGN SECTION ===
                
                Text(
                  '🏠 Design Your Environment (Optional)',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Set up your space to make the habit obvious and distractions invisible.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),

                // Environment cue field with "Get ideas" button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _environmentCueController,
                        decoration: const InputDecoration(
                          labelText: 'What cue will you place in your environment?',
                          hintText: 'e.g., "Put your book on your pillow at 21:45"',
                          helperText: 'A visual reminder to trigger your habit',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lightbulb),
                        ),
                        maxLines: 2,
                        // Optional field - no validator
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: OutlinedButton.icon(
                        onPressed: _showEnvironmentCueSuggestions,
                        icon: const Icon(Icons.lightbulb_outline, size: 18),
                        label: const Text('Ideas'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Environment distraction field with "Get ideas" button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _environmentDistractionController,
                        decoration: const InputDecoration(
                          labelText: 'What distraction will you move or hide?',
                          hintText: 'e.g., "Charge your phone in the kitchen"',
                          helperText: 'Remove obstacles to make bad habits harder',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.block),
                        ),
                        maxLines: 2,
                        // Optional field - no validator
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: OutlinedButton.icon(
                        onPressed: _showEnvironmentDistractionSuggestions,
                        icon: const Icon(Icons.lightbulb_outline, size: 18),
                        label: const Text('Ideas'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                      ),
                    ),
                  ],
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
