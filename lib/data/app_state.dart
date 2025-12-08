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
/// Supports multiple habits with soft guardrails (Atomic Habits philosophy)
class AppState extends ChangeNotifier {
  // User profile
  UserProfile? _userProfile;

  // Multiple habits support
  List<Habit> _habits = [];
  String? _primaryHabitId; // The "focused" habit (user's main habit)

  // Onboarding completion status
  bool _hasCompletedOnboarding = false;

  // Hive box for persistent storage
  Box? _dataBox;

  // Loading state
  bool _isLoading = true;

  // Reward + Investment flow state
  bool _shouldShowRewardFlow = false;

  // Notification service
  final NotificationService _notificationService = NotificationService();

  // AI Suggestion service (local heuristics for now)
  final AiSuggestionService _aiSuggestionService = AiSuggestionService();

  // ========== Getters ==========

  UserProfile? get userProfile => _userProfile;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get isLoading => _isLoading;
  bool get shouldShowRewardFlow => _shouldShowRewardFlow;

  /// Get all active (non-archived) habits
  List<Habit> get habits => _habits.where((h) => !h.isArchived).toList();

  /// Get all habits including archived
  List<Habit> get allHabits => List.unmodifiable(_habits);

  /// Get archived habits only
  List<Habit> get archivedHabits => _habits.where((h) => h.isArchived).toList();

  /// Get the primary/focused habit (or first habit if none set)
  Habit? get currentHabit {
    if (_habits.isEmpty) return null;
    final activeHabits = habits;
    if (activeHabits.isEmpty) return null;

    // Return primary habit if set and exists
    if (_primaryHabitId != null) {
      final primary = activeHabits.where((h) => h.id == _primaryHabitId).firstOrNull;
      if (primary != null) return primary;
    }

    // Fallback to first active habit
    return activeHabits.first;
  }

  /// Get habit by ID
  Habit? getHabitById(String id) {
    return _habits.where((h) => h.id == id).firstOrNull;
  }

  /// Check if any habit is established (21+ day streak)
  bool get hasEstablishedHabit => habits.any((h) => h.isEstablished);

  /// Get count of active habits
  int get activeHabitCount => habits.length;

  /// Calculate "focus score" - are habits getting proper attention?
  /// Returns 0.0 to 1.0 (1.0 = well focused, 0.0 = spread too thin)
  double get focusScore {
    final active = habits;
    if (active.isEmpty) return 1.0;
    if (active.length == 1) return 1.0;

    // Penalize for too many habits without established foundation
    final establishedCount = active.where((h) => h.isEstablished).length;
    final newCount = active.length - establishedCount;

    // Ideal: each new habit should have at least one established habit backing it
    if (newCount > establishedCount + 1) {
      // Too many new habits without foundation
      return (establishedCount + 1) / active.length;
    }

    // Also factor in average health of habits
    final avgHealth = active.map((h) => h.healthScore).reduce((a, b) => a + b) / active.length;

    return avgHealth.clamp(0.0, 1.0);
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
      if (_hasCompletedOnboarding && currentHabit != null && _userProfile != null) {
        await _scheduleNotifications();
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
  /// Handles backward compatibility: migrates single habit to habits list
  Future<void> _loadFromStorage() async {
    if (_dataBox == null) return;

    // Load onboarding status
    _hasCompletedOnboarding = _dataBox!.get('hasCompletedOnboarding', defaultValue: false);

    // Load user profile
    final profileJson = _dataBox!.get('userProfile');
    if (profileJson != null) {
      _userProfile = UserProfile.fromJson(Map<String, dynamic>.from(profileJson));
    }

    // Load primary habit ID
    _primaryHabitId = _dataBox!.get('primaryHabitId');

    // Try to load habits list (new format)
    final habitsJson = _dataBox!.get('habits');
    if (habitsJson != null) {
      final habitsList = habitsJson as List<dynamic>;
      _habits = habitsList
          .map((h) => Habit.fromJson(Map<String, dynamic>.from(h)))
          .toList();
    } else {
      // Backward compatibility: migrate single habit to list
      final habitJson = _dataBox!.get('currentHabit');
      if (habitJson != null) {
        final singleHabit = Habit.fromJson(Map<String, dynamic>.from(habitJson));
        _habits = [singleHabit];
        _primaryHabitId = singleHabit.id;

        // Migrate to new format
        await _saveToStorage();

        if (kDebugMode) {
          debugPrint('Migrated single habit to habits list');
        }
      }
    }

    if (kDebugMode) {
      debugPrint('Loaded from storage: onboarding=$_hasCompletedOnboarding, '
          'profile=${_userProfile?.name}, habits=${_habits.length}');
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

      // Save primary habit ID
      if (_primaryHabitId != null) {
        await _dataBox!.put('primaryHabitId', _primaryHabitId);
      }

      // Also save currentHabit for backward compatibility
      if (currentHabit != null) {
        await _dataBox!.put('currentHabit', currentHabit!.toJson());
      }

      if (kDebugMode) {
        debugPrint('Saved to storage: ${_habits.length} habits');
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

  // ========== Habit Management Methods ==========

  /// Creates a new habit and adds it to the list
  /// If this is the first habit, it becomes primary automatically
  Future<void> createHabit(Habit habit) async {
    // Check if habit with same ID exists (update instead of add)
    final existingIndex = _habits.indexWhere((h) => h.id == habit.id);
    if (existingIndex >= 0) {
      _habits[existingIndex] = habit;
    } else {
      _habits.add(habit);
    }

    // If this is the first habit, make it primary
    if (_habits.length == 1 || _primaryHabitId == null) {
      _primaryHabitId = habit.id;
    }

    await _saveToStorage(); // Persist to storage
    notifyListeners();
  }

  /// Add a new habit (alias for createHabit for clarity)
  Future<void> addHabit(Habit habit) async {
    await createHabit(habit);
  }

  /// Set the primary/focused habit
  Future<void> setPrimaryHabit(String habitId) async {
    if (_habits.any((h) => h.id == habitId && !h.isArchived)) {
      _primaryHabitId = habitId;
      await _saveToStorage();
      notifyListeners();

      if (kDebugMode) {
        final habit = getHabitById(habitId);
        debugPrint('Primary habit set to: ${habit?.name}');
      }
    }
  }

  /// Archive a habit (soft delete - keeps history)
  Future<void> archiveHabit(String habitId) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index >= 0) {
      _habits[index] = _habits[index].copyWith(isArchived: true);

      // If archived habit was primary, select new primary
      if (_primaryHabitId == habitId) {
        final active = habits;
        _primaryHabitId = active.isNotEmpty ? active.first.id : null;
      }

      await _saveToStorage();
      notifyListeners();

      if (kDebugMode) {
        debugPrint('Habit archived: ${_habits[index].name}');
      }
    }
  }

  /// Restore an archived habit
  Future<void> restoreHabit(String habitId) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index >= 0) {
      _habits[index] = _habits[index].copyWith(isArchived: false);
      await _saveToStorage();
      notifyListeners();

      if (kDebugMode) {
        debugPrint('Habit restored: ${_habits[index].name}');
      }
    }
  }

  /// Permanently delete a habit (use with caution - loses history)
  Future<void> deleteHabitPermanently(String habitId) async {
    _habits.removeWhere((h) => h.id == habitId);

    // If deleted habit was primary, select new primary
    if (_primaryHabitId == habitId) {
      final active = habits;
      _primaryHabitId = active.isNotEmpty ? active.first.id : null;
    }

    await _saveToStorage();
    notifyListeners();
  }

  /// Update an existing habit
  Future<void> updateHabit(Habit updatedHabit) async {
    final index = _habits.indexWhere((h) => h.id == updatedHabit.id);
    if (index >= 0) {
      _habits[index] = updatedHabit;
      await _saveToStorage();
      notifyListeners();
    }
  }

  /// Check if user should see a soft warning before adding a new habit
  /// Returns a message if warning should show, null if OK to proceed
  String? getNewHabitWarning() {
    final active = habits;

    // No warning for first habit
    if (active.isEmpty) return null;

    // Check if any habit is established
    final hasEstablished = active.any((h) => h.isEstablished);

    if (!hasEstablished) {
      return 'Tip: James Clear recommends mastering one habit before adding another. '
          'Your current habit isn\'t established yet (21+ day streak). '
          'Consider focusing on it first, but you can still add a new one if you\'re ready.';
    }

    // Check focus score
    if (focusScore < 0.5) {
      return 'Your habits might need more attention. '
          'Some aren\'t being completed consistently. '
          'Consider strengthening existing habits before adding new ones.';
    }

    // Check for too many habits
    if (active.length >= 5) {
      return 'You have ${active.length} active habits. '
          'Managing too many habits can reduce effectiveness. '
          'Consider archiving some or using habit stacking instead.';
    }

    return null; // No warning needed
  }

  /// Marks habit as completed for today (uses current/primary habit)
  /// Returns true if this was a new completion (triggers reward flow)
  Future<bool> completeHabitForToday({bool fromNotification = false}) async {
    return completeHabit(currentHabit?.id, fromNotification: fromNotification);
  }

  /// Marks a specific habit as completed for today
  /// Returns true if this was a new completion (triggers reward flow)
  Future<bool> completeHabit(String? habitId, {bool fromNotification = false}) async {
    if (habitId == null) return false;

    final habitIndex = _habits.indexWhere((h) => h.id == habitId);
    if (habitIndex < 0) return false;

    final habit = _habits[habitIndex];
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

    // Update longest streak if current streak exceeds it
    final newLongestStreak = newStreak > habit.longestStreak
        ? newStreak
        : habit.longestStreak;

    // Add to completion history
    final updatedHistory = List<DateTime>.from(habit.completionHistory)
      ..add(now);

    // Update the habit in the list
    _habits[habitIndex] = habit.copyWith(
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
      lastCompletedDate: now,
      completionHistory: updatedHistory,
    );

    await _saveToStorage(); // Persist the updated streak and history

    // Trigger Reward + Investment flow (only for primary habit)
    if (habitId == _primaryHabitId) {
      _shouldShowRewardFlow = true;
    }

    notifyListeners();

    if (kDebugMode) {
      debugPrint('✅ "${habit.name}" completed! Streak: $newStreak (best: $newLongestStreak), Total: ${updatedHistory.length}');
    }

    return true; // New completion
  }

  /// Marks onboarding as complete
  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    await _saveToStorage(); // Persist to storage
    
    // Schedule daily notifications
    await _scheduleNotifications();
    
    notifyListeners();
  }

  /// Checks if current/primary habit was completed today
  bool isHabitCompletedToday() {
    return currentHabit?.isCompletedToday ?? false;
  }

  /// Check if a specific habit was completed today
  bool isHabitCompletedTodayById(String habitId) {
    final habit = getHabitById(habitId);
    return habit?.isCompletedToday ?? false;
  }

  /// Get count of habits completed today
  int get habitsCompletedTodayCount {
    return habits.where((h) => h.isCompletedToday).length;
  }

  /// Get count of habits not yet completed today
  int get habitsPendingTodayCount {
    return habits.where((h) => !h.isCompletedToday).length;
  }

  /// Clear all data (useful for testing/reset)
  Future<void> clearAllData() async {
    if (_dataBox != null) {
      await _dataBox!.clear();
    }
    _userProfile = null;
    _habits = [];
    _primaryHabitId = null;
    _hasCompletedOnboarding = false;
    await _notificationService.cancelAllNotifications();
    notifyListeners();
  }
  
  // ========== Notification Methods ==========

  /// Schedule daily notifications for habit reminder (primary habit)
  Future<void> _scheduleNotifications() async {
    if (currentHabit == null || _userProfile == null) return;

    await _notificationService.scheduleDailyHabitReminder(
      habit: currentHabit!,
      profile: _userProfile!,
    );
  }

  /// Handle notification action buttons (Mark Done, Snooze)
  void _handleNotificationAction(String action) {
    if (kDebugMode) {
      debugPrint('📱 Notification action: $action');
    }

    if (action == 'mark_done') {
      // Mark habit as complete from notification
      completeHabitForToday(fromNotification: true);
    } else if (action == 'snooze') {
      // Schedule snooze notification
      if (currentHabit != null && _userProfile != null) {
        _notificationService.scheduleSnoozeNotification(
          habit: currentHabit!,
          profile: _userProfile!,
        );
      }
    }
  }

  /// Update reminder time and reschedule notifications for current habit
  /// Called from Investment flow
  Future<void> updateReminderTime(String newTime) async {
    if (currentHabit == null) return;

    final habitIndex = _habits.indexWhere((h) => h.id == currentHabit!.id);
    if (habitIndex < 0) return;

    _habits[habitIndex] = _habits[habitIndex].copyWith(
      implementationTime: newTime,
    );

    await _saveToStorage();

    // Reschedule notifications with new time
    await _scheduleNotifications();

    notifyListeners();

    if (kDebugMode) {
      debugPrint('⏰ Reminder time updated to: $newTime');
    }
  }

  /// Update reminder time for a specific habit
  Future<void> updateHabitReminderTime(String habitId, String newTime) async {
    final habitIndex = _habits.indexWhere((h) => h.id == habitId);
    if (habitIndex < 0) return;

    _habits[habitIndex] = _habits[habitIndex].copyWith(
      implementationTime: newTime,
    );

    await _saveToStorage();

    // Reschedule notifications if this is the primary habit
    if (habitId == _primaryHabitId) {
      await _scheduleNotifications();
    }

    notifyListeners();
  }
  
  /// Show test notification (for debugging)
  Future<void> showTestNotification() async {
    await _notificationService.showTestNotification();
  }
  
  // ========== Reward + Investment Flow Methods ==========
  
  /// Dismiss the reward flow
  void dismissRewardFlow() {
    _shouldShowRewardFlow = false;
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
  
  /// Get temptation bundling suggestions for current habit (async)
  /// Returns empty list if habit data is incomplete
  /// 
  /// Flow: Remote LLM (5s timeout) → Local fallback if needed
  Future<List<String>> getTemptationBundleSuggestionsForCurrentHabit() async {
    if (_currentHabit == null || _userProfile == null) {
      return [];
    }
    
    try {
      return await _aiSuggestionService.getTemptationBundleSuggestions(
        identity: _userProfile!.identity,
        habitName: _currentHabit!.name,
        tinyVersion: _currentHabit!.tinyVersion,
        implementationTime: _currentHabit!.implementationTime,
        implementationLocation: _currentHabit!.implementationLocation,
        existingTemptationBundle: _currentHabit!.temptationBundle,
        existingPreRitual: _currentHabit!.preHabitRitual,
        existingEnvironmentCue: _currentHabit!.environmentCue,
        existingEnvironmentDistraction: _currentHabit!.environmentDistraction,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting temptation bundle suggestions: $e');
      }
      return [];
    }
  }
  
  /// Get pre-habit ritual suggestions for current habit (async)
  /// Returns empty list if habit data is incomplete
  Future<List<String>> getPreHabitRitualSuggestionsForCurrentHabit() async {
    if (_currentHabit == null || _userProfile == null) {
      return [];
    }
    
    try {
      return await _aiSuggestionService.getPreHabitRitualSuggestions(
        identity: _userProfile!.identity,
        habitName: _currentHabit!.name,
        tinyVersion: _currentHabit!.tinyVersion,
        implementationTime: _currentHabit!.implementationTime,
        implementationLocation: _currentHabit!.implementationLocation,
        existingTemptationBundle: _currentHabit!.temptationBundle,
        existingPreRitual: _currentHabit!.preHabitRitual,
        existingEnvironmentCue: _currentHabit!.environmentCue,
        existingEnvironmentDistraction: _currentHabit!.environmentDistraction,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting pre-habit ritual suggestions: $e');
      }
      return [];
    }
  }
  
  /// Get environment cue suggestions for current habit (async)
  /// Returns empty list if habit data is incomplete
  Future<List<String>> getEnvironmentCueSuggestionsForCurrentHabit() async {
    if (_currentHabit == null || _userProfile == null) {
      return [];
    }
    
    try {
      return await _aiSuggestionService.getEnvironmentCueSuggestions(
        identity: _userProfile!.identity,
        habitName: _currentHabit!.name,
        tinyVersion: _currentHabit!.tinyVersion,
        implementationTime: _currentHabit!.implementationTime,
        implementationLocation: _currentHabit!.implementationLocation,
        existingTemptationBundle: _currentHabit!.temptationBundle,
        existingPreRitual: _currentHabit!.preHabitRitual,
        existingEnvironmentCue: _currentHabit!.environmentCue,
        existingEnvironmentDistraction: _currentHabit!.environmentDistraction,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting environment cue suggestions: $e');
      }
      return [];
    }
  }
  
  /// Get environment distraction removal suggestions for current habit (async)
  /// Returns empty list if habit data is incomplete
  Future<List<String>> getEnvironmentDistractionSuggestionsForCurrentHabit() async {
    if (_currentHabit == null || _userProfile == null) {
      return [];
    }
    
    try {
      return await _aiSuggestionService.getEnvironmentDistractionSuggestions(
        identity: _userProfile!.identity,
        habitName: _currentHabit!.name,
        tinyVersion: _currentHabit!.tinyVersion,
        implementationTime: _currentHabit!.implementationTime,
        implementationLocation: _currentHabit!.implementationLocation,
        existingTemptationBundle: _currentHabit!.temptationBundle,
        existingPreRitual: _currentHabit!.preHabitRitual,
        existingEnvironmentCue: _currentHabit!.environmentCue,
        existingEnvironmentDistraction: _currentHabit!.environmentDistraction,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting environment distraction suggestions: $e');
      }
      return [];
    }
  }
  
  /// Get combined suggestions for "Improve this habit" feature (async)
  /// Returns a map with all suggestion types
  Future<Map<String, List<String>>> getAllSuggestionsForCurrentHabit() async {
    // Fetch all suggestions in parallel for better performance
    final results = await Future.wait([
      getTemptationBundleSuggestionsForCurrentHabit(),
      getPreHabitRitualSuggestionsForCurrentHabit(),
      getEnvironmentCueSuggestionsForCurrentHabit(),
      getEnvironmentDistractionSuggestionsForCurrentHabit(),
    ]);

    return {
      'temptationBundle': results[0],
      'preHabitRitual': results[1],
      'environmentCue': results[2],
      'environmentDistraction': results[3],
    };
  }

  // ========== Analytics & History Methods ==========

  /// Get longest streak ever achieved
  int get longestStreak => _currentHabit?.longestStreak ?? 0;

  /// Get total number of completions
  int get totalCompletions => _currentHabit?.totalCompletions ?? 0;

  /// Get overall completion rate (0.0 to 1.0)
  double get completionRate => _currentHabit?.completionRate ?? 0.0;

  /// Get weekly completion rate (last 7 days)
  double get weeklyCompletionRate => _currentHabit?.weeklyCompletionRate ?? 0.0;

  /// Get monthly completion rate (last 30 days)
  double get monthlyCompletionRate => _currentHabit?.monthlyCompletionRate ?? 0.0;

  /// Check if habit was completed on a specific date
  bool wasHabitCompletedOn(DateTime date) {
    return _currentHabit?.wasCompletedOn(date) ?? false;
  }

  /// Get all completion dates for calendar view
  List<DateTime> get completionHistory =>
      _currentHabit?.completionHistory ?? [];

  /// Get completions within a date range (for calendar/chart views)
  List<DateTime> getCompletionsInRange(DateTime startDate, DateTime endDate) {
    return _currentHabit?.getCompletionsInRange(startDate, endDate) ?? [];
  }

  /// Get completion count for a date range
  int getCompletionCount({DateTime? startDate, DateTime? endDate}) {
    return _currentHabit?.getCompletionCount(
          startDate: startDate,
          endDate: endDate,
        ) ??
        0;
  }

  /// Get completion rate for a specific number of days
  double getCompletionRateForLastDays(int days) {
    return _currentHabit?.getCompletionRateForLastDays(days) ?? 0.0;
  }
}
