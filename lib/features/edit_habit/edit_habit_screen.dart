import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/app_state.dart';
import '../../data/models/habit.dart';
import '../../data/models/user_profile.dart';

/// Edit Habit & System screen
///
/// Allows users to refine their habit configuration after onboarding:
/// - Identity & habit basics
/// - Implementation intention (time, location)
/// - Make it Attractive (temptation bundling, pre-habit ritual)
/// - Environment design (cue, distraction removal)
/// - Option to reset streak & history
class EditHabitScreen extends StatefulWidget {
  const EditHabitScreen({super.key});

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  // Form controllers
  final _identityController = TextEditingController();
  final _habitNameController = TextEditingController();
  final _tinyVersionController = TextEditingController();
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();
  final _temptationBundleController = TextEditingController();
  final _preRitualController = TextEditingController();
  final _environmentCueController = TextEditingController();
  final _distractionController = TextEditingController();

  bool _keepStreakAndHistory = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load current habit data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentHabit();
    });
  }

  @override
  void dispose() {
    _identityController.dispose();
    _habitNameController.dispose();
    _tinyVersionController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _temptationBundleController.dispose();
    _preRitualController.dispose();
    _environmentCueController.dispose();
    _distractionController.dispose();
    super.dispose();
  }

  void _loadCurrentHabit() {
    final appState = Provider.of<AppState>(context, listen: false);
    final habit = appState.currentHabit;
    final profile = appState.userProfile;

    if (habit == null || profile == null) {
      // No habit found, navigate back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No habit found. Please complete onboarding first.'),
            backgroundColor: Colors.red,
          ),
        );
        context.go('/today');
      }
      return;
    }

    // Pre-fill form fields
    setState(() {
      _identityController.text = profile.identity;
      _habitNameController.text = habit.name;
      _tinyVersionController.text = habit.tinyVersion;
      _timeController.text = habit.implementationTime;
      _locationController.text = habit.implementationLocation;
      _temptationBundleController.text = habit.temptationBundle ?? '';
      _preRitualController.text = habit.preHabitRitual ?? '';
      _environmentCueController.text = habit.environmentCue ?? '';
      _distractionController.text = habit.environmentDistraction ?? '';
    });
  }

  Future<void> _showResetConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Streak & History?'),
        content: const Text(
          'This will reset your streak to 0 and clear your completion history. '
          'This action cannot be undone.\n\n'
          'Are you sure you want to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _keepStreakAndHistory = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Streak and history will be reset when you save'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    // Validate required fields
    if (_habitNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Habit name cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_tinyVersionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('2-minute version cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate time format (HH:MM)
    final timePattern = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!timePattern.hasMatch(_timeController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Time must be in HH:MM format (e.g., 08:00)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final oldHabit = appState.currentHabit!;
      final oldTime = oldHabit.implementationTime;
      final newTime = _timeController.text.trim();

      // Build updated habit
      final updatedHabit = oldHabit.copyWith(
        name: _habitNameController.text.trim(),
        identity: _identityController.text.trim(),
        tinyVersion: _tinyVersionController.text.trim(),
        implementationTime: newTime,
        implementationLocation: _locationController.text.trim(),
        temptationBundle: _temptationBundleController.text.trim().isEmpty
            ? null
            : _temptationBundleController.text.trim(),
        preHabitRitual: _preRitualController.text.trim().isEmpty
            ? null
            : _preRitualController.text.trim(),
        environmentCue: _environmentCueController.text.trim().isEmpty
            ? null
            : _environmentCueController.text.trim(),
        environmentDistraction: _distractionController.text.trim().isEmpty
            ? null
            : _distractionController.text.trim(),
        // Handle reset if requested
        currentStreak: _keepStreakAndHistory ? null : 0,
        lastCompletedDate: _keepStreakAndHistory ? null : null,
        completionHistory: _keepStreakAndHistory ? null : {},
      );

      // Update identity in profile
      final updatedProfile = UserProfile(
        identity: _identityController.text.trim(),
      );

      // Save to app state
      await appState.updateHabit(updatedHabit, updatedProfile);

      // If time changed, reschedule notifications
      if (oldTime != newTime) {
        await appState.updateReminderTime(newTime);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Habit updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/today');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving changes: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Habit & System'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            const Text(
              'Refine your habit system',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Update any part of your habit to better align with your lifestyle.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Section 1: Identity & Habit Basics
            _buildSectionHeader('Identity & Habit Basics', Icons.person),
            const SizedBox(height: 12),
            TextField(
              controller: _identityController,
              decoration: const InputDecoration(
                labelText: 'Who do you want to become?',
                hintText: 'I am a person who...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _habitNameController,
              decoration: const InputDecoration(
                labelText: 'Habit name',
                hintText: 'Read for 10 minutes',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tinyVersionController,
              decoration: const InputDecoration(
                labelText: '2-minute version',
                hintText: 'Read one page',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Section 2: Implementation Intention
            _buildSectionHeader('Implementation Intention', Icons.access_time),
            const SizedBox(height: 12),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(
                labelText: 'What time?',
                hintText: 'HH:MM (e.g., 22:00)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.schedule),
              ),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Where will you do it?',
                hintText: 'In bed before sleep',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.place),
              ),
            ),
            const SizedBox(height: 24),

            // Section 3: Make it Attractive
            _buildSectionHeader('Make it Attractive', Icons.favorite),
            const SizedBox(height: 12),
            TextField(
              controller: _temptationBundleController,
              decoration: const InputDecoration(
                labelText: 'Temptation bundling (optional)',
                hintText: 'Have herbal tea while reading',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _preRitualController,
              decoration: const InputDecoration(
                labelText: 'Pre-habit ritual (optional)',
                hintText: 'Take 3 deep breaths',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Section 4: Environment Design
            _buildSectionHeader('Environment Design', Icons.home),
            const SizedBox(height: 12),
            TextField(
              controller: _environmentCueController,
              decoration: const InputDecoration(
                labelText: 'Environment cue (optional)',
                hintText: 'Put book on pillow at 21:45',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _distractionController,
              decoration: const InputDecoration(
                labelText: 'Distraction guardrail (optional)',
                hintText: 'Charge phone in kitchen',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Section 5: System Options
            _buildSectionHeader('System Options', Icons.settings),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      value: _keepStreakAndHistory,
                      onChanged: (value) {
                        setState(() {
                          _keepStreakAndHistory = value;
                        });
                      },
                      title: const Text('Keep current streak and history'),
                      subtitle: Text(
                        _keepStreakAndHistory
                            ? 'Your progress will be preserved'
                            : 'Streak and history will be reset',
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_keepStreakAndHistory)
                      OutlinedButton.icon(
                        onPressed: _showResetConfirmation,
                        icon: const Icon(Icons.restart_alt),
                        label: const Text('Reset streak & history'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save button
            FilledButton(
              onPressed: _isLoading ? null : _saveChanges,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save changes'),
            ),
            const SizedBox(height: 12),

            // Cancel button
            TextButton(
              onPressed: _isLoading ? null : () => context.pop(),
              child: const Text('Cancel'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.deepPurple),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
      ],
    );
  }
}
