import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/app_state.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/habit.dart';
import '../../data/models/onboarding_data.dart';
import '../../data/services/onboarding/onboarding_orchestrator.dart';
import '../../widgets/suggestion_dialog.dart';
import 'widgets/magic_wand_button.dart';

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
  
  // AI Magic Wand state
  bool _isAiLoading = false;
  
  // Store the full AI data to preserve invisible fields (motivation, rootCause, etc.)
  // This prevents "Data Amnesia" - losing AI-generated metadata when saving
  OnboardingData? _lastAiData;

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

  // Handle AI-generated habit data from Magic Wand
  void _onAiHabitGenerated(OnboardingData data) {
    setState(() {
      // CRITICAL: Store the full AI data to preserve invisible fields
      // This includes: motivation, rootCause, replacesHabit, substitutionPlan, habitEmoji, recoveryPlan
      // Without this, Tier 2 Claude coaching would lose context about WHY the user started
      _lastAiData = data;
      
      // Fill in the tiny version if provided
      if (data.tinyVersion != null && data.tinyVersion!.isNotEmpty) {
        _tinyVersionController.text = data.tinyVersion!;
      }
      
      // Fill in the location if provided
      if (data.implementationLocation != null && data.implementationLocation!.isNotEmpty) {
        _locationController.text = data.implementationLocation!;
      }
      
      // Fill in the time if provided
      if (data.implementationTime != null && data.implementationTime!.isNotEmpty) {
        final timeParsed = _parseTimeString(data.implementationTime!);
        if (timeParsed != null) {
          _selectedTime = timeParsed;
        }
      }
      
      // Fill in optional fields
      if (data.temptationBundle != null && data.temptationBundle!.isNotEmpty) {
        _temptationBundleController.text = data.temptationBundle!;
      }
      
      if (data.preHabitRitual != null && data.preHabitRitual!.isNotEmpty) {
        _preHabitRitualController.text = data.preHabitRitual!;
      }
      
      if (data.environmentCue != null && data.environmentCue!.isNotEmpty) {
        _environmentCueController.text = data.environmentCue!;
      }
      
      if (data.environmentDistraction != null && data.environmentDistraction!.isNotEmpty) {
        _environmentDistractionController.text = data.environmentDistraction!;
      }
      
      // Also fill habit name if user hasn't entered one
      if (data.name != null && data.name!.isNotEmpty && _habitNameController.text.trim().isEmpty) {
        _habitNameController.text = data.name!;
      }
    });
  }

  // Parse time string from AI (handles "HH:MM" and descriptive times)
  TimeOfDay? _parseTimeString(String timeStr) {
    // Try parsing HH:MM format
    final timeRegex = RegExp(r'(\d{1,2}):(\d{2})');
    final match = timeRegex.firstMatch(timeStr);
    
    if (match != null) {
      final hour = int.tryParse(match.group(1)!);
      final minute = int.tryParse(match.group(2)!);
      if (hour != null && minute != null && hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    }
    
    // Try parsing descriptive times
    final lowerTimeStr = timeStr.toLowerCase();
    if (lowerTimeStr.contains('morning') || lowerTimeStr.contains('breakfast')) {
      return const TimeOfDay(hour: 8, minute: 0);
    } else if (lowerTimeStr.contains('afternoon') || lowerTimeStr.contains('lunch')) {
      return const TimeOfDay(hour: 12, minute: 0);
    } else if (lowerTimeStr.contains('evening') || lowerTimeStr.contains('dinner')) {
      return const TimeOfDay(hour: 18, minute: 0);
    } else if (lowerTimeStr.contains('night') || lowerTimeStr.contains('bed')) {
      return const TimeOfDay(hour: 22, minute: 0);
    }
    
    return null;
  }

  // Handle AI loading state
  void _onAiLoadingChanged(bool isLoading) {
    setState(() {
      _isAiLoading = isLoading;
    });
  }

  // Handle AI errors
  void _onAiError(String error) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(error)),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    }
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

  Future<void> _completeOnboarding() async {
    if (_formKey.currentState?.validate() ?? false) {
      final appState = Provider.of<AppState>(context, listen: false);

      // Create user profile
      final profile = UserProfile(
        name: _nameController.text.trim(),
        identity: _identityController.text.trim(),
        createdAt: DateTime.now(),
      );

      // Create first habit with implementation intentions + Make it Attractive
      // CRITICAL: Merge Manual Input + AI Metadata to prevent "Data Amnesia"
      final habit = Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _habitNameController.text.trim(),
        identity: _identityController.text.trim(),
        tinyVersion: _tinyVersionController.text.trim(),
        createdAt: DateTime.now(),
        implementationTime: _formatTime(_selectedTime),
        implementationLocation: _locationController.text.trim(),
        
        // "Make it Attractive" and environment design fields (from form)
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
        
        // === AI METADATA: The "Invisible" Fields ===
        // These come from _lastAiData (if Magic Wand was used)
        // They enable Tier 2 Claude coaching to understand:
        // - Why the user started this habit (motivation)
        // - What triggers/problems they're addressing (rootCause)
        // - What bad habit they're replacing (replacesHabit)
        // - Their fallback plan when tempted (substitutionPlan, recoveryPlan)
        isBreakHabit: _lastAiData?.habitType == HabitType.breakHabit,
        replacesHabit: _lastAiData?.replacesHabit,
        rootCause: _lastAiData?.rootCause,
        substitutionPlan: _lastAiData?.substitutionPlan,
        habitEmoji: _lastAiData?.habitEmoji ?? '✨', // Default emoji
        motivation: _lastAiData?.motivation,
        recoveryPlan: _lastAiData?.recoveryPlan,
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

                // Habit name with Magic Wand button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
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
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: MagicWandButton(
                        habitName: _habitNameController.text,
                        identity: _identityController.text,
                        isBreakHabit: false,
                        onHabitGenerated: _onAiHabitGenerated,
                        onLoadingChanged: _onAiLoadingChanged,
                        onError: _onAiError,
                      ),
                    ),
                  ],
                ),
                // AI Magic Wand hint
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                  child: Text(
                    'Tap the AI button to auto-fill habit details',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
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
