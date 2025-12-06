import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/habit.dart';
import 'models/user_profile.dart';
import 'notification_service.dart';
import 'ai_suggestion_service.dart';

/// Central state management for the app
/// Uses Provider for simple, beginner-friendly state management
/// Now includes Hive persistence for data that survives app restarts
/// Handles Hook Model: Trigger (notifications) → Action → Reward → Investment
///
/// MULTIPLE HABITS SUPPORT:
/// - Stores a list of habits instead of a single habit
/// - Tracks which habit is currently selected for viewing
/// - Each habit has independent streak and completion tracking
class AppState extends ChangeNotifier {
  // User profile
  UserProfile? _userProfile;

  // List of all habits (supports multiple habits)
  List<Habit> _habits = [];

  // Currently selected habit ID for detailed view
  String? _selectedHabitId;

  // Onboarding completion status
  bool _hasCompletedOnboarding = false;

  // Hive box for persistent storage
  Box? _dataBox;

  // Loading state
  bool _isLoading = true;

  // Reward + Investment flow state
  bool _shouldShowRewardFlow = false;
  String? _rewardFlowHabitId; // Track which habit triggered reward

  // Notification service
  final NotificationService _notificationService = NotificationService();

  // AI Suggestion service (local heuristics for now)
  final AiSuggestionService _aiSuggestionService = AiSuggestionService();

  // Getters to access state
  UserProfile? get userProfile => _userProfile;
  List<Habit> get habits => List.unmodifiable(_habits);
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get isLoading => _isLoading;
  bool get shouldShowRewardFlow => _shouldShowRewardFlow;
  String? get rewardFlowHabitId => _rewardFlowHabitId;

  /// Get currently selected habit (for backward compatibility and detail views)
  Habit? get currentHabit {
    if (_selectedHabitId != null) {
      return _habits.where((h) => h.id == _selectedHabitId).firstOrNull;
    }
    // Default to first habit if none selected
    return _habits.isNotEmpty ? _habits.first : null;
  }

  /// Get selected habit ID
  String? get selectedHabitId => _selectedHabitId;

  /// Get a specific habit by ID
  Habit? getHabitById(String id) {
    return _habits.where((h) => h.id == id).firstOrNull;
  }

  /// Initialize Hive and load persisted data
  /// Call this once when app starts
  Future<void> initialize() async {
    try {
      // Initialize notification service first
      await _notificationService.initialize();

      // Set up notification action handler
      _notificationService.onNotificationAction = _handleNotificationAction;

      // Open Hive box (like opening a database table)
      _dataBox = await Hive.openBox('habit_data');

      // Load saved data from Hive
      await _loadFromStorage();

      // Schedule notifications if onboarding completed
      if (_hasCompletedOnboarding && _habits.isNotEmpty && _userProfile != null) {
        await _scheduleAllNotifications();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error initializing AppState: $e');
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load data from Hive storage
  Future<void> _loadFromStorage() async {
    if (_dataBox == null) return;

    // Load onboarding status
    _hasCompletedOnboarding = _dataBox!.get('hasCompletedOnboarding', defaultValue: false);

    // Load user profile
    final profileJson = _dataBox!.get('userProfile');
    if (profileJson != null) {
      _userProfile = UserProfile.fromJson(Map<String, dynamic>.from(profileJson));
    }

    // Try to load habits list first (new format)
    final habitsJson = _dataBox!.get('habits');
    if (habitsJson != null) {
      final List<dynamic> habitsList = habitsJson as List<dynamic>;
      _habits = habitsList
          .map((json) => Habit.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } else {
      // Backward compatibility: load single currentHabit and migrate to list
      final habitJson = _dataBox!.get('currentHabit');
      if (habitJson != null) {
        final habit = Habit.fromJson(Map<String, dynamic>.from(habitJson));
        _habits = [habit];
        // Migrate to new format
        await _saveToStorage();
      }
    }

    // Load selected habit ID
    _selectedHabitId = _dataBox!.get('selectedHabitId');
    // If no selection but we have habits, select the first one
    if (_selectedHabitId == null && _habits.isNotEmpty) {
      _selectedHabitId = _habits.first.id;
    }

    if (kDebugMode) {
      debugPrint('Loaded from storage: onboarding=$_hasCompletedOnboarding, profile=${_userProfile?.name}, habits=${_habits.length}');
    }
  }

  /// Save all data to Hive storage
  Future<void> _saveToStorage() async {
    if (_dataBox == null) return;

    try {
      // Save onboarding status
      await _dataBox!.put('hasCompletedOnboarding', _hasCompletedOnboarding);

      // Save user profile
      if (_userProfile != null) {
        await _dataBox!.put('userProfile', _userProfile!.toJson());
      }

      // Save habits list (new format)
      await _dataBox!.put('habits', _habits.map((h) => h.toJson()).toList());

      // Save selected habit ID
      if (_selectedHabitId != null) {
        await _dataBox!.put('selectedHabitId', _selectedHabitId);
      }

      // Clean up old single habit key if it exists
      if (_dataBox!.containsKey('currentHabit')) {
        await _dataBox!.delete('currentHabit');
      }

      if (kDebugMode) {
        debugPrint('Saved to storage successfully (${_habits.length} habits)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving to storage: $e');
      }
    }
  }

  /// Sets the user profile (from onboarding)
  Future<void> setUserProfile(UserProfile profile) async {
    _userProfile = profile;
    await _saveToStorage(); // Persist to storage
    notifyListeners(); // Tell UI to rebuild
  }

  /// Creates a new habit and adds it to the list
  Future<void> createHabit(Habit habit) async {
    // Check if habit with this ID already exists
    final existingIndex = _habits.indexWhere((h) => h.id == habit.id);
    if (existingIndex >= 0) {
      // Update existing habit
      _habits[existingIndex] = habit;
    } else {
      // Add new habit
      _habits.add(habit);
    }

    // Select the new habit
    _selectedHabitId = habit.id;

    await _saveToStorage(); // Persist to storage

    // Schedule notification for this habit
    if (_hasCompletedOnboarding && _userProfile != null) {
      await _notificationService.scheduleHabitReminder(
        habit: habit,
        profile: _userProfile!,
        notificationId: _habits.indexOf(habit),
      );
    }

    notifyListeners();
  }

  /// Add a new habit (alias for createHabit for clarity)
  Future<void> addHabit(Habit habit) async {
    await createHabit(habit);
  }

  /// Update an existing habit
  Future<void> updateHabit(Habit updatedHabit) async {
    final index = _habits.indexWhere((h) => h.id == updatedHabit.id);
    if (index >= 0) {
      _habits[index] = updatedHabit;
      await _saveToStorage();

      // Reschedule notification for this habit
      if (_hasCompletedOnboarding && _userProfile != null) {
        await _notificationService.scheduleHabitReminder(
          habit: updatedHabit,
          profile: _userProfile!,
          notificationId: index,
        );
      }

      notifyListeners();
    }
  }

  /// Delete a habit by ID
  Future<void> deleteHabit(String habitId) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index >= 0) {
      // Cancel notification for this habit
      await _notificationService.cancelNotification(index);

      _habits.removeAt(index);

      // If deleted habit was selected, select another
      if (_selectedHabitId == habitId) {
        _selectedHabitId = _habits.isNotEmpty ? _habits.first.id : null;
      }

      await _saveToStorage();

      // Reschedule all notifications (IDs may have shifted)
      await _scheduleAllNotifications();

      notifyListeners();
    }
  }

  /// Select a habit for detailed view
  void selectHabit(String habitId) {
    if (_habits.any((h) => h.id == habitId)) {
      _selectedHabitId = habitId;
      _saveToStorage();
      notifyListeners();
    }
  }

  /// Marks a specific habit as completed for today
  /// Returns true if this was a new completion (triggers reward flow)
  Future<bool> completeHabitForToday({String? habitId, bool fromNotification = false}) async {
    // Use provided habitId or fall back to selected habit
    final targetId = habitId ?? _selectedHabitId;
    if (targetId == null) return false;

    final index = _habits.indexWhere((h) => h.id == targetId);
    if (index < 0) return false;

    final habit = _habits[index];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if already completed today
    if (habit.lastCompletedDate != null) {
      final lastCompleted = habit.lastCompletedDate!;
      final lastDate = DateTime(
        lastCompleted.year,
        lastCompleted.month,
        lastCompleted.day,
      );

      if (lastDate == today) {
        // Already completed today
        if (kDebugMode) {
          debugPrint('Habit "${habit.name}" already completed today');
        }
        return false;
      }
    }

    // Calculate new streak (check if yesterday was completed)
    int newStreak = habit.currentStreak;

    if (habit.lastCompletedDate != null) {
      final lastCompleted = habit.lastCompletedDate!;
      final yesterday = today.subtract(const Duration(days: 1));
      final lastDate = DateTime(
        lastCompleted.year,
        lastCompleted.month,
        lastCompleted.day,
      );

      // If last completion was yesterday, continue streak
      if (lastDate == yesterday) {
        newStreak = habit.currentStreak + 1;
      } else {
        // Streak broken, start over
        newStreak = 1;
      }
    } else {
      // First completion
      newStreak = 1;
    }

    _habits[index] = habit.copyWith(
      currentStreak: newStreak,
      lastCompletedDate: now,
    );

    await _saveToStorage(); // Persist the updated streak

    // Trigger Reward + Investment flow
    _shouldShowRewardFlow = true;
    _rewardFlowHabitId = targetId;

    notifyListeners();

    if (kDebugMode) {
      debugPrint('✅ Habit "${habit.name}" completed! New streak: $newStreak');
    }

    return true; // New completion
  }

  /// Check if a specific habit was completed today
  bool isHabitCompletedToday(String habitId) {
    final habit = getHabitById(habitId);
    if (habit?.lastCompletedDate == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCompleted = habit!.lastCompletedDate!;
    final lastDate = DateTime(
      lastCompleted.year,
      lastCompleted.month,
      lastCompleted.day,
    );

    return lastDate == today;
  }

  /// Marks onboarding as complete
  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    await _saveToStorage(); // Persist to storage

    // Schedule notifications for all habits
    await _scheduleAllNotifications();

    notifyListeners();
  }

  /// Checks if the currently selected habit was completed today
  /// (Backward compatibility)
  bool isHabitCompletedTodayForCurrent() {
    if (currentHabit == null) return false;
    return isHabitCompletedToday(currentHabit!.id);
  }

  /// Clear all data (useful for testing/reset)
  Future<void> clearAllData() async {
    if (_dataBox != null) {
      await _dataBox!.clear();
    }
    _userProfile = null;
    _habits = [];
    _selectedHabitId = null;
    _hasCompletedOnboarding = false;
    await _notificationService.cancelAllNotifications();
    notifyListeners();
  }

  // ========== Notification Methods ==========

  /// Schedule notifications for all habits
  Future<void> _scheduleAllNotifications() async {
    if (_userProfile == null) return;

    // Cancel all existing notifications first
    await _notificationService.cancelAllNotifications();

    // Schedule a notification for each habit
    for (int i = 0; i < _habits.length; i++) {
      await _notificationService.scheduleHabitReminder(
        habit: _habits[i],
        profile: _userProfile!,
        notificationId: i,
      );
    }
  }

  /// Handle notification action buttons (Mark Done, Snooze)
  void _handleNotificationAction(String action, {String? habitId}) {
    if (kDebugMode) {
      debugPrint('📱 Notification action: $action for habit: $habitId');
    }

    if (action == 'mark_done') {
      // Mark habit as complete from notification
      completeHabitForToday(habitId: habitId, fromNotification: true);
    } else if (action == 'snooze') {
      // Schedule snooze notification
      final habit = habitId != null ? getHabitById(habitId) : currentHabit;
      if (habit != null && _userProfile != null) {
        _notificationService.scheduleSnoozeNotification(
          habit: habit,
          profile: _userProfile!,
        );
      }
    }
  }

  /// Update reminder time for a specific habit and reschedule notification
  Future<void> updateReminderTime(String newTime, {String? habitId}) async {
    final targetId = habitId ?? _selectedHabitId;
    if (targetId == null) return;

    final index = _habits.indexWhere((h) => h.id == targetId);
    if (index < 0) return;

    _habits[index] = _habits[index].copyWith(
      implementationTime: newTime,
    );

    await _saveToStorage();

    // Reschedule notification for this habit
    if (_userProfile != null) {
      await _notificationService.scheduleHabitReminder(
        habit: _habits[index],
        profile: _userProfile!,
        notificationId: index,
      );
    }

    notifyListeners();

    if (kDebugMode) {
      debugPrint('⏰ Reminder time updated to: $newTime for habit: ${_habits[index].name}');
    }
  }

  /// Show test notification (for debugging)
  Future<void> showTestNotification() async {
    await _notificationService.showTestNotification();
  }

  // ========== Reward + Investment Flow Methods ==========

  /// Dismiss the reward flow
  void dismissRewardFlow() {
    _shouldShowRewardFlow = false;
    _rewardFlowHabitId = null;
    notifyListeners();
  }

  /// Check if we should show reward flow when app comes to foreground
  bool checkAndTriggerRewardFlow() {
    // If habit was just completed and we haven't shown reward yet
    if (_shouldShowRewardFlow) {
      return true;
    }
    return false;
  }

  // ========== AI Suggestion Methods (Async with Remote LLM + Local Fallback) ==========

  /// Get temptation bundling suggestions for a specific habit (async)
  /// Returns empty list if habit data is incomplete
  Future<List<String>> getTemptationBundleSuggestions(Habit habit) async {
    if (_userProfile == null) {
      return [];
    }

    try {
      return await _aiSuggestionService.getTemptationBundleSuggestions(
        identity: _userProfile!.identity,
        habitName: habit.name,
        tinyVersion: habit.tinyVersion,
        implementationTime: habit.implementationTime,
        implementationLocation: habit.implementationLocation,
        existingTemptationBundle: habit.temptationBundle,
        existingPreRitual: habit.preHabitRitual,
        existingEnvironmentCue: habit.environmentCue,
        existingEnvironmentDistraction: habit.environmentDistraction,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting temptation bundle suggestions: $e');
      }
      return [];
    }
  }

  /// Get temptation bundling suggestions for current habit (backward compatibility)
  Future<List<String>> getTemptationBundleSuggestionsForCurrentHabit() async {
    if (currentHabit == null) return [];
    return getTemptationBundleSuggestions(currentHabit!);
  }

  /// Get pre-habit ritual suggestions for a specific habit (async)
  Future<List<String>> getPreHabitRitualSuggestions(Habit habit) async {
    if (_userProfile == null) {
      return [];
    }

    try {
      return await _aiSuggestionService.getPreHabitRitualSuggestions(
        identity: _userProfile!.identity,
        habitName: habit.name,
        tinyVersion: habit.tinyVersion,
        implementationTime: habit.implementationTime,
        implementationLocation: habit.implementationLocation,
        existingTemptationBundle: habit.temptationBundle,
        existingPreRitual: habit.preHabitRitual,
        existingEnvironmentCue: habit.environmentCue,
        existingEnvironmentDistraction: habit.environmentDistraction,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting pre-habit ritual suggestions: $e');
      }
      return [];
    }
  }

  /// Get pre-habit ritual suggestions for current habit (backward compatibility)
  Future<List<String>> getPreHabitRitualSuggestionsForCurrentHabit() async {
    if (currentHabit == null) return [];
    return getPreHabitRitualSuggestions(currentHabit!);
  }

  /// Get environment cue suggestions for a specific habit (async)
  Future<List<String>> getEnvironmentCueSuggestions(Habit habit) async {
    if (_userProfile == null) {
      return [];
    }

    try {
      return await _aiSuggestionService.getEnvironmentCueSuggestions(
        identity: _userProfile!.identity,
        habitName: habit.name,
        tinyVersion: habit.tinyVersion,
        implementationTime: habit.implementationTime,
        implementationLocation: habit.implementationLocation,
        existingTemptationBundle: habit.temptationBundle,
        existingPreRitual: habit.preHabitRitual,
        existingEnvironmentCue: habit.environmentCue,
        existingEnvironmentDistraction: habit.environmentDistraction,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting environment cue suggestions: $e');
      }
      return [];
    }
  }

  /// Get environment cue suggestions for current habit (backward compatibility)
  Future<List<String>> getEnvironmentCueSuggestionsForCurrentHabit() async {
    if (currentHabit == null) return [];
    return getEnvironmentCueSuggestions(currentHabit!);
  }

  /// Get environment distraction removal suggestions for a specific habit (async)
  Future<List<String>> getEnvironmentDistractionSuggestions(Habit habit) async {
    if (_userProfile == null) {
      return [];
    }

    try {
      return await _aiSuggestionService.getEnvironmentDistractionSuggestions(
        identity: _userProfile!.identity,
        habitName: habit.name,
        tinyVersion: habit.tinyVersion,
        implementationTime: habit.implementationTime,
        implementationLocation: habit.implementationLocation,
        existingTemptationBundle: habit.temptationBundle,
        existingPreRitual: habit.preHabitRitual,
        existingEnvironmentCue: habit.environmentCue,
        existingEnvironmentDistraction: habit.environmentDistraction,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting environment distraction suggestions: $e');
      }
      return [];
    }
  }

  /// Get environment distraction suggestions for current habit (backward compatibility)
  Future<List<String>> getEnvironmentDistractionSuggestionsForCurrentHabit() async {
    if (currentHabit == null) return [];
    return getEnvironmentDistractionSuggestions(currentHabit!);
  }

  /// Get combined suggestions for "Improve this habit" feature (async)
  /// Returns a map with all suggestion types
  Future<Map<String, List<String>>> getAllSuggestionsForHabit(Habit habit) async {
    // Fetch all suggestions in parallel for better performance
    final results = await Future.wait([
      getTemptationBundleSuggestions(habit),
      getPreHabitRitualSuggestions(habit),
      getEnvironmentCueSuggestions(habit),
      getEnvironmentDistractionSuggestions(habit),
    ]);

    return {
      'temptationBundle': results[0],
      'preHabitRitual': results[1],
      'environmentCue': results[2],
      'environmentDistraction': results[3],
    };
  }

  /// Get combined suggestions for current habit (backward compatibility)
  Future<Map<String, List<String>>> getAllSuggestionsForCurrentHabit() async {
    if (currentHabit == null) {
      return {
        'temptationBundle': [],
        'preHabitRitual': [],
        'environmentCue': [],
        'environmentDistraction': [],
      };
    }
    return getAllSuggestionsForHabit(currentHabit!);
  }

  // ========== Statistics Methods ==========

  /// Get total number of habits
  int get totalHabits => _habits.length;

  /// Get number of habits completed today
  int get habitsCompletedToday {
    return _habits.where((h) => isHabitCompletedToday(h.id)).length;
  }

  /// Get overall completion percentage for today
  double get todayCompletionPercentage {
    if (_habits.isEmpty) return 0.0;
    return habitsCompletedToday / _habits.length;
  }

  /// Get the longest current streak across all habits
  int get longestCurrentStreak {
    if (_habits.isEmpty) return 0;
    return _habits.map((h) => h.currentStreak).reduce((a, b) => a > b ? a : b);
  }
}
