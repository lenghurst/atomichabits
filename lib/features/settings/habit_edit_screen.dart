import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/router/app_routes.dart';
import '../../data/app_state.dart';
import '../../data/models/habit.dart';
import '../../widgets/habit_stack_selector.dart';

/// HabitEditScreen - Edit habit properties including stacking
/// 
/// **Phase 13: Habit Stacking Configuration**
/// This screen allows users to:
/// - Edit basic habit properties (name, tiny version, etc.)
/// - Configure habit stacking ("After X, I will Y")
/// - View and modify implementation intentions
/// - Pause/resume habits
/// 
/// **Vibecoding Architecture:**
/// Uses Consumer<AppState> for reactive updates
/// All changes persist via AppState → Hive
class HabitEditScreen extends StatefulWidget {
  final String habitId;
  
  const HabitEditScreen({super.key, required this.habitId});

  @override
  State<HabitEditScreen> createState() => _HabitEditScreenState();
}

class _HabitEditScreenState extends State<HabitEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _tinyVersionController;
  late TextEditingController _locationController;
  late TextEditingController _temptationController;
  late TextEditingController _ritualController;
  late TextEditingController _cueCcontroller;
  late TextEditingController _distractionController;
  
  String? _selectedAnchorId;
  String _stackPosition = 'after';
  String? _anchorEvent;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _tinyVersionController = TextEditingController();
    _locationController = TextEditingController();
    _temptationController = TextEditingController();
    _ritualController = TextEditingController();
    _cueCcontroller = TextEditingController();
    _distractionController = TextEditingController();
    
    // Load habit data after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHabitData();
    });
  }
  
  void _loadHabitData() {
    final appState = Provider.of<AppState>(context, listen: false);
    final habit = appState.getHabitById(widget.habitId);
    
    if (habit != null) {
      setState(() {
        _nameController.text = habit.name;
        _tinyVersionController.text = habit.tinyVersion;
        _locationController.text = habit.implementationLocation;
        _temptationController.text = habit.temptationBundle ?? '';
        _ritualController.text = habit.preHabitRitual ?? '';
        _cueCcontroller.text = habit.environmentCue ?? '';
        _distractionController.text = habit.environmentDistraction ?? '';
        
        // Stacking configuration
        _selectedAnchorId = habit.anchorHabitId;
        _stackPosition = habit.stackPosition;
        _anchorEvent = habit.anchorEvent;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tinyVersionController.dispose();
    _locationController.dispose();
    _temptationController.dispose();
    _ritualController.dispose();
    _cueCcontroller.dispose();
    _distractionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final habit = appState.getHabitById(widget.habitId);
        
        if (habit == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Edit Habit')),
            body: const Center(
              child: Text('Habit not found'),
            ),
          );
        }
        
        // Get available habits for stacking (excluding current habit)
        final availableAnchors = appState.habits
            .where((h) => h.id != widget.habitId)
            .toList();
        
        return Scaffold(
          appBar: AppBar(
            title: Text(habit.habitEmoji ?? '📝'),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            actions: [
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.check),
                  tooltip: 'Save Changes',
                  onPressed: () => _saveChanges(appState, habit),
                ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ========== Basic Info Section ==========
                _buildSectionTitle(context, 'Basic Info'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Habit Name',
                            hintText: 'e.g., Meditate for 20 minutes',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.edit),
                          ),
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _tinyVersionController,
                          decoration: const InputDecoration(
                            labelText: 'Tiny Version (2-Minute Rule)',
                            hintText: 'e.g., Meditate for 2 minutes',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.timer),
                            helperText: 'Make it so easy you can\'t say no',
                          ),
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // ========== Implementation Intentions Section ==========
                _buildSectionTitle(context, 'Implementation Intentions'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Where',
                            hintText: 'e.g., In my living room',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.access_time),
                          title: const Text('When'),
                          subtitle: Text(habit.implementationTime),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showTimePicker(context, appState, habit),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // ========== Phase 13: Habit Stacking Section ==========
                _buildSectionTitle(context, 'Habit Stacking'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: HabitStackSelector(
                      availableAnchors: availableAnchors,
                      selectedAnchorId: _selectedAnchorId,
                      stackPosition: _stackPosition,
                      anchorEvent: _anchorEvent,
                      excludeHabitId: widget.habitId,
                      onAnchorChanged: (id) => setState(() => _selectedAnchorId = id),
                      onPositionChanged: (pos) => setState(() => _stackPosition = pos),
                      onEventChanged: (event) => setState(() => _anchorEvent = event),
                      wouldCreateCircular: (anchorId) => 
                          appState.wouldCreateCircularStack(widget.habitId, anchorId),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // ========== Make it Attractive Section ==========
                _buildSectionTitle(context, 'Make it Attractive'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _temptationController,
                          decoration: const InputDecoration(
                            labelText: 'Temptation Bundle',
                            hintText: 'e.g., While watching my favorite show',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.favorite),
                            helperText: 'Pair with something you enjoy',
                          ),
                          maxLines: 2,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _ritualController,
                          decoration: const InputDecoration(
                            labelText: 'Pre-Habit Ritual',
                            hintText: 'e.g., Take 3 deep breaths',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.self_improvement),
                            helperText: 'A 30-second ritual to get started',
                          ),
                          maxLines: 2,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // ========== Environment Design Section ==========
                _buildSectionTitle(context, 'Environment Design'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _cueCcontroller,
                          decoration: const InputDecoration(
                            labelText: 'Visual Cue',
                            hintText: 'e.g., Meditation cushion by the bed',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.visibility),
                            helperText: 'Make it obvious',
                          ),
                          maxLines: 2,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _distractionController,
                          decoration: const InputDecoration(
                            labelText: 'Remove Distractions',
                            hintText: 'e.g., Phone in another room',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.do_not_disturb),
                            helperText: 'Make bad habits invisible',
                          ),
                          maxLines: 2,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // ========== Habit Status Section ==========
                _buildSectionTitle(context, 'Habit Status'),
                Card(
                  child: Column(
                    children: [
                      // Pause/Resume
                      SwitchListTile(
                        secondary: Icon(
                          habit.isPaused ? Icons.play_arrow : Icons.pause,
                        ),
                        title: Text(habit.isPaused ? 'Habit Paused' : 'Habit Active'),
                        subtitle: Text(
                          habit.isPaused 
                              ? 'Turn on to resume tracking'
                              : 'Turn off for a planned break',
                        ),
                        value: !habit.isPaused,
                        onChanged: (active) {
                          if (active) {
                            appState.resumeHabit(habitId: widget.habitId);
                          } else {
                            appState.pauseHabit(habitId: widget.habitId);
                          }
                        },
                      ),
                      const Divider(height: 1),
                      // Stats
                      ListTile(
                        leading: const Icon(Icons.trending_up),
                        title: const Text('Statistics'),
                        subtitle: Text(
                          '${habit.daysShowedUp} days tracked · '
                          '${habit.gracefulScore.toInt()}% consistency',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(AppRoutes.analytics),
                      ),
                      const Divider(height: 1),
                      // Remove Stack Button (if stacked)
                      if (_selectedAnchorId != null || 
                          (_anchorEvent != null && _anchorEvent!.isNotEmpty))
                        ListTile(
                          leading: Icon(Icons.link_off, color: Colors.orange.shade700),
                          title: const Text('Remove Stack'),
                          subtitle: const Text('Unlink from anchor habit'),
                          onTap: () {
                            setState(() {
                              _selectedAnchorId = null;
                              _anchorEvent = null;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Stack will be removed when you save'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Save button
                FilledButton.icon(
                  onPressed: () => _saveChanges(appState, habit),
                  icon: const Icon(Icons.check),
                  label: const Text('Save Changes'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Future<void> _showTimePicker(
    BuildContext context,
    AppState appState,
    Habit habit,
  ) async {
    // Parse current time
    final parts = habit.implementationTime.split(' ');
    final timeParts = parts[0].split(':');
    int hour = int.tryParse(timeParts[0]) ?? 8;
    final minute = int.tryParse(timeParts[1]) ?? 0;
    final isPM = parts.length > 1 && parts[1].toUpperCase() == 'PM';
    
    if (isPM && hour != 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      helpText: 'Set Habit Time',
    );
    
    if (picked != null) {
      final timeString = _formatTimeOfDay(picked);
      await appState.updateReminderTime(timeString, habitId: widget.habitId);
    }
  }
  
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _saveChanges(AppState appState, Habit habit) async {
    // Validate
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Habit name cannot be empty'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Check for circular stacks
    if (_selectedAnchorId != null && 
        appState.wouldCreateCircularStack(widget.habitId, _selectedAnchorId!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot create circular stack'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      // Update habit properties
      final updatedHabit = habit.copyWith(
        name: _nameController.text.trim(),
        tinyVersion: _tinyVersionController.text.trim(),
        implementationLocation: _locationController.text.trim(),
        temptationBundle: _temptationController.text.trim().isEmpty 
            ? null 
            : _temptationController.text.trim(),
        preHabitRitual: _ritualController.text.trim().isEmpty 
            ? null 
            : _ritualController.text.trim(),
        environmentCue: _cueCcontroller.text.trim().isEmpty 
            ? null 
            : _cueCcontroller.text.trim(),
        environmentDistraction: _distractionController.text.trim().isEmpty 
            ? null 
            : _distractionController.text.trim(),
        // Stacking
        anchorHabitId: _selectedAnchorId,
        anchorEvent: _anchorEvent,
        stackPosition: _stackPosition,
      );
      
      await appState.updateHabit(updatedHabit);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Habit updated successfully!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
