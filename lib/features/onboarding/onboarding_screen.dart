import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/router/app_routes.dart';
import '../../data/app_state.dart';
import '../../data/providers/user_provider.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/habit.dart';
import '../../data/models/onboarding_data.dart';
import '../../widgets/suggestion_dialog.dart';
import 'widgets/magic_wand_button.dart';
import '../../data/ai_suggestion_service.dart';
import '../dev/dev_tools_overlay.dart';

/// Onboarding screen - collects user identity and first habit
/// Based on Atomic Habits: Identity-based habits + Implementation intentions
/// 
/// **Phase 12: Bad Habit Protocol**
/// Supports both building good habits and breaking bad habits.
/// For break habits:
/// - Habit type toggle (Build vs Break)
/// - Additional fields: What to replace, Root cause, Substitution plan
/// - Different UI labeling and guidance
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
  // ignore: unused_field - set by callback but UI uses different loading indicator
  bool _isAiLoading = false;
  
  // Phase 12: Break Habit Protocol
  bool _isBreakHabit = false;
  final _replacesHabitController = TextEditingController();
  final _rootCauseController = TextEditingController();
  final _substitutionPlanController = TextEditingController();
  
  // Phase 13: Habit Stacking
  String? _anchorHabitId;
  final String _stackPosition = 'after'; // 'after' is the default
  
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
    // Phase 12: Break Habit Protocol
    _replacesHabitController.dispose();
    _rootCauseController.dispose();
    _substitutionPlanController.dispose();
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
  // FIXED Phase 27.4: No longer creates ghost habits - calls AiSuggestionService directly
  Future<void> _showTemptationBundleSuggestions() async {
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
      // FIXED: Call AiSuggestionService directly without saving to database
      final aiService = AiSuggestionService();
      final suggestions = await aiService.getTemptationBundleSuggestions(
        identity: _identityController.text.trim().isEmpty 
            ? 'achieves their goals' 
            : _identityController.text.trim(),
        habitName: _habitNameController.text.trim().isEmpty 
            ? 'your habit' 
            : _habitNameController.text.trim(),
        tinyVersion: _tinyVersionController.text.trim().isEmpty 
            ? 'start small' 
            : _tinyVersionController.text.trim(),
        implementationTime: _formatTime(_selectedTime),
        implementationLocation: _locationController.text.trim().isEmpty 
            ? 'at home' 
            : _locationController.text.trim(),
        existingTemptationBundle: _temptationBundleController.text.trim(),
        existingPreRitual: _preHabitRitualController.text.trim(),
        existingEnvironmentCue: _environmentCueController.text.trim(),
        existingEnvironmentDistraction: _environmentDistractionController.text.trim(),
      );
      
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
  // FIXED Phase 27.4: No longer creates ghost habits - calls AiSuggestionService directly
  Future<void> _showPreHabitRitualSuggestions() async {
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
      // FIXED: Call AiSuggestionService directly without saving to database
      final aiService = AiSuggestionService();
      final suggestions = await aiService.getPreHabitRitualSuggestions(
        identity: _identityController.text.trim().isEmpty 
            ? 'achieves their goals' 
            : _identityController.text.trim(),
        habitName: _habitNameController.text.trim().isEmpty 
            ? 'your habit' 
            : _habitNameController.text.trim(),
        tinyVersion: _tinyVersionController.text.trim().isEmpty 
            ? 'start small' 
            : _tinyVersionController.text.trim(),
        implementationTime: _formatTime(_selectedTime),
        implementationLocation: _locationController.text.trim().isEmpty 
            ? 'at home' 
            : _locationController.text.trim(),
        existingTemptationBundle: _temptationBundleController.text.trim(),
        existingPreRitual: _preHabitRitualController.text.trim(),
        existingEnvironmentCue: _environmentCueController.text.trim(),
        existingEnvironmentDistraction: _environmentDistractionController.text.trim(),
      );
      
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
  // FIXED Phase 27.4: No longer creates ghost habits - calls AiSuggestionService directly
  Future<void> _showEnvironmentCueSuggestions() async {
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
      // FIXED: Call AiSuggestionService directly without saving to database
      final aiService = AiSuggestionService();
      final suggestions = await aiService.getEnvironmentCueSuggestions(
        identity: _identityController.text.trim().isEmpty 
            ? 'achieves their goals' 
            : _identityController.text.trim(),
        habitName: _habitNameController.text.trim().isEmpty 
            ? 'your habit' 
            : _habitNameController.text.trim(),
        tinyVersion: _tinyVersionController.text.trim().isEmpty 
            ? 'start small' 
            : _tinyVersionController.text.trim(),
        implementationTime: _formatTime(_selectedTime),
        implementationLocation: _locationController.text.trim().isEmpty 
            ? 'at home' 
            : _locationController.text.trim(),
        existingTemptationBundle: _temptationBundleController.text.trim(),
        existingPreRitual: _preHabitRitualController.text.trim(),
        existingEnvironmentCue: _environmentCueController.text.trim(),
        existingEnvironmentDistraction: _environmentDistractionController.text.trim(),
      );
      
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
  // FIXED Phase 27.4: No longer creates ghost habits - calls AiSuggestionService directly
  Future<void> _showEnvironmentDistractionSuggestions() async {
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
      // FIXED: Call AiSuggestionService directly without saving to database
      final aiService = AiSuggestionService();
      final suggestions = await aiService.getEnvironmentDistractionSuggestions(
        identity: _identityController.text.trim().isEmpty 
            ? 'achieves their goals' 
            : _identityController.text.trim(),
        habitName: _habitNameController.text.trim().isEmpty 
            ? 'your habit' 
            : _habitNameController.text.trim(),
        tinyVersion: _tinyVersionController.text.trim().isEmpty 
            ? 'start small' 
            : _tinyVersionController.text.trim(),
        implementationTime: _formatTime(_selectedTime),
        implementationLocation: _locationController.text.trim().isEmpty 
            ? 'at home' 
            : _locationController.text.trim(),
        existingTemptationBundle: _temptationBundleController.text.trim(),
        existingPreRitual: _preHabitRitualController.text.trim(),
        existingEnvironmentCue: _environmentCueController.text.trim(),
        existingEnvironmentDistraction: _environmentDistractionController.text.trim(),
      );
      
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

  // Phase 12: Build vs Break habit type toggle
  Widget _buildHabitTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isBreakHabit = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isBreakHabit ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: !_isBreakHabit
                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: !_isBreakHabit ? Colors.green : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Build',
                      style: TextStyle(
                        fontWeight: !_isBreakHabit ? FontWeight.bold : FontWeight.normal,
                        color: !_isBreakHabit ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isBreakHabit = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isBreakHabit ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _isBreakHabit
                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.remove_circle_outline,
                      color: _isBreakHabit ? Colors.purple : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Break',
                      style: TextStyle(
                        fontWeight: _isBreakHabit ? FontWeight.bold : FontWeight.normal,
                        color: _isBreakHabit ? Colors.purple : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Phase 12: Break Habit specific fields
  List<Widget> _buildBreakHabitFields() {
    return [
      // What habit are you replacing?
      TextFormField(
        controller: _replacesHabitController,
        decoration: const InputDecoration(
          labelText: 'What triggers this habit? (Optional)',
          hintText: 'e.g., "Boredom", "Stress", "After meals"',
          helperText: 'Understanding triggers helps you break the pattern',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.psychology),
        ),
        maxLines: 2,
      ),
      const SizedBox(height: 16),
      
      // Root cause
      TextFormField(
        controller: _rootCauseController,
        decoration: const InputDecoration(
          labelText: 'Why do you want to break this habit? (Optional)',
          hintText: 'e.g., "It wastes my time", "Affects my health"',
          helperText: 'Your motivation will help when cravings hit',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.favorite),
        ),
        maxLines: 2,
      ),
      const SizedBox(height: 24),
    ];
  }

  // Phase 13: Habit Stacking section
  Widget _buildHabitStackingSection() {
    final appState = Provider.of<AppState>(context, listen: false);
    final existingHabits = appState.habits;
    
    // Don't show stacking if there are no existing habits to stack on
    if (existingHabits.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.link, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              '\ud83d\udd17 Chain Reaction (Optional)',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Stack this habit onto an existing one for better consistency.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        
        // Anchor Habit Dropdown
        DropdownButtonFormField<String>(
          key: ValueKey(_anchorHabitId),
          initialValue: _anchorHabitId,
          decoration: const InputDecoration(
            labelText: 'Stack after which habit?',
            hintText: 'Choose an existing habit (or leave blank)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.layers),
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('None - Stand-alone habit'),
            ),
            ...existingHabits.map((habit) {
              return DropdownMenuItem<String>(
                value: habit.id,
                child: Text(
                  '${habit.habitEmoji ?? '\u2728'} ${habit.name}',
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _anchorHabitId = value;
            });
          },
        ),
        
        if (_anchorHabitId != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.green.shade700, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "After completing '${existingHabits.firstWhere((h) => h.id == _anchorHabitId).name}', you'll be prompted to do this habit.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
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
        // Phase 12: Bad Habit Protocol - merge manual + AI data
        isBreakHabit: _isBreakHabit || _lastAiData?.habitType == HabitType.breakHabit,
        replacesHabit: _isBreakHabit 
            ? (_replacesHabitController.text.trim().isEmpty ? null : _replacesHabitController.text.trim())
            : _lastAiData?.replacesHabit,
        rootCause: _isBreakHabit 
            ? (_rootCauseController.text.trim().isEmpty ? null : _rootCauseController.text.trim())
            : _lastAiData?.rootCause,
        substitutionPlan: _isBreakHabit 
            ? (_substitutionPlanController.text.trim().isEmpty ? null : _substitutionPlanController.text.trim())
            : _lastAiData?.substitutionPlan,
        habitEmoji: _lastAiData?.habitEmoji ?? '✨', // Default emoji
        motivation: _lastAiData?.motivation,
        recoveryPlan: _lastAiData?.recoveryPlan,
        
        // Phase 13: Habit Stacking fields
        anchorHabitId: _anchorHabitId,
        stackPosition: _anchorHabitId != null ? _stackPosition : 'after',
        anchorEvent: _anchorHabitId != null && _stackPosition == 'after' ? 'completion' : null,
      );

      // Save to state (now with persistence!)
      await appState.setUserProfile(profile);
      
      // Strangler Fig Phase 2: Save to UserProvider as well
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.setUserProfile(profile);
      await userProvider.completeOnboarding();
      
      await appState.createHabit(habit);
      await appState.completeOnboarding();

      // Navigate to Today screen
      if (mounted) {
        context.go(AppRoutes.today);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: DevToolsGestureDetector(
          child: const Text('Welcome to The Pact'),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => context.go(AppRoutes.settings),
          ),
        ],
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
                  _isBreakHabit ? '🛡️ Breaking a Bad Habit' : '✨ Your First Tiny Habit',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isBreakHabit 
                      ? 'Make it invisible, unattractive, difficult, and unsatisfying.'
                      : 'Start with something so easy you can\'t say no.',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                
                // Phase 12: Habit Type Toggle
                _buildHabitTypeToggle(),
                const SizedBox(height: 24),

                // Habit name with Magic Wand button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _habitNameController,
                        decoration: InputDecoration(
                          labelText: _isBreakHabit 
                              ? 'What habit do you want to break?'
                              : 'What habit do you want to build?',
                          hintText: _isBreakHabit 
                              ? 'e.g., "Doomscrolling", "Stress eating"'
                              : 'e.g., "Read every day"',
                          border: const OutlineInputBorder(),
                          prefixIcon: Icon(_isBreakHabit ? Icons.block : Icons.check_circle),
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
                        isBreakHabit: _isBreakHabit,
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

                // Phase 12: Break Habit specific fields
                if (_isBreakHabit) ..._buildBreakHabitFields(),
                
                // Tiny version (2-minute rule) - or substitution for break habits
                TextFormField(
                  controller: _isBreakHabit ? _substitutionPlanController : _tinyVersionController,
                  decoration: InputDecoration(
                    labelText: _isBreakHabit 
                        ? 'What will you do instead? (Substitution)'
                        : 'Make it tiny (2-minute version)',
                    hintText: _isBreakHabit 
                        ? 'e.g., "5-minute walk", "Breathing exercises"'
                        : 'e.g., "Read one page"',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(_isBreakHabit ? Icons.swap_horiz : Icons.timer),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return _isBreakHabit 
                          ? 'Please enter a healthy substitution'
                          : 'Please enter a tiny version of your habit';
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

                // === HABIT STACKING SECTION (Phase 13) ===
                _buildHabitStackingSection(),
                const SizedBox(height: 32),

                // Complete button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _completeOnboarding,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isBreakHabit ? Colors.purple : Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      _isBreakHabit ? 'Start Breaking This Habit' : 'Start Building Habits',
                      style: const TextStyle(
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
