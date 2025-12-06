import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/app_state.dart';
import '../../data/models/habit.dart';
import '../../widgets/suggestion_dialog.dart';

/// Screen for adding a new habit
/// Simplified version of onboarding for users who want to track multiple habits
class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _habitNameController = TextEditingController();
  final _tinyVersionController = TextEditingController();
  final _locationController = TextEditingController();

  // Optional "Make it Attractive" and environment design controllers
  final _temptationBundleController = TextEditingController();
  final _preHabitRitualController = TextEditingController();
  final _environmentCueController = TextEditingController();
  final _environmentDistractionController = TextEditingController();

  // Implementation intention: Time
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  bool _isLoading = false;

  @override
  void dispose() {
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

  // Create a temporary habit for getting suggestions
  Habit _createTempHabit() {
    final appState = Provider.of<AppState>(context, listen: false);
    return Habit(
      id: 'temp',
      name: _habitNameController.text.trim().isEmpty
          ? 'your habit'
          : _habitNameController.text.trim(),
      identity: appState.userProfile?.identity ?? 'achieves their goals',
      tinyVersion: _tinyVersionController.text.trim().isEmpty
          ? 'start small'
          : _tinyVersionController.text.trim(),
      createdAt: DateTime.now(),
      implementationTime: _formatTime(_selectedTime),
      implementationLocation: _locationController.text.trim().isEmpty
          ? 'at home'
          : _locationController.text.trim(),
    );
  }

  // Helper: Show suggestion dialog for temptation bundle
  Future<void> _showTemptationBundleSuggestions() async {
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
      final tempHabit = _createTempHabit();
      final suggestions = await appState.getTemptationBundleSuggestions(tempHabit);

      if (mounted) Navigator.of(context).pop();

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
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get suggestions. Please try again.')),
        );
      }
    }
  }

  // Helper: Show suggestion dialog for pre-habit ritual
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
      final tempHabit = _createTempHabit();
      final suggestions = await appState.getPreHabitRitualSuggestions(tempHabit);

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

  // Helper: Show suggestion dialog for environment cue
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
      final tempHabit = _createTempHabit();
      final suggestions = await appState.getEnvironmentCueSuggestions(tempHabit);

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

  // Helper: Show suggestion dialog for environment distraction
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
      final tempHabit = _createTempHabit();
      final suggestions = await appState.getEnvironmentDistractionSuggestions(tempHabit);

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

  Future<void> _saveHabit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final appState = Provider.of<AppState>(context, listen: false);

      // Create new habit
      final habit = Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _habitNameController.text.trim(),
        identity: appState.userProfile?.identity ?? '',
        tinyVersion: _tinyVersionController.text.trim(),
        createdAt: DateTime.now(),
        implementationTime: _formatTime(_selectedTime),
        implementationLocation: _locationController.text.trim(),
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

      // Save to state
      await appState.addHabit(habit);

      setState(() {
        _isLoading = false;
      });

      // Navigate back to Today screen
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Habit "${habit.name}" added!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/today');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Habit'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/today'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Habit section
                Text(
                  'New Tiny Habit',
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
                    hintText: 'e.g., "Exercise every day"',
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
                    hintText: 'e.g., "Do 5 push-ups"',
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
                  'Make It Obvious',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '"I will [habit] at [time] in [location]"',
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
                    labelText: 'Where will you do it?',
                    hintText: 'e.g., "In my living room"',
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
                  'Make it Attractive (Optional)',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                // Temptation bundling field
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _temptationBundleController,
                        decoration: const InputDecoration(
                          labelText: 'Pair with something enjoyable',
                          hintText: 'e.g., "Listen to music while exercising"',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.favorite),
                        ),
                        maxLines: 2,
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

                // Pre-habit ritual field
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _preHabitRitualController,
                        decoration: const InputDecoration(
                          labelText: 'Pre-habit ritual (10-30 seconds)',
                          hintText: 'e.g., "Put on workout clothes"',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.self_improvement),
                        ),
                        maxLines: 2,
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
                  'Design Your Environment (Optional)',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                // Environment cue field
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _environmentCueController,
                        decoration: const InputDecoration(
                          labelText: 'Visual cue to trigger habit',
                          hintText: 'e.g., "Put workout shoes by the door"',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lightbulb),
                        ),
                        maxLines: 2,
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

                // Environment distraction field
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _environmentDistractionController,
                        decoration: const InputDecoration(
                          labelText: 'Distraction to remove',
                          hintText: 'e.g., "Hide TV remote before workout"',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.block),
                        ),
                        maxLines: 2,
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

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveHabit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Add Habit',
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
