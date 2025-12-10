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
/// MULTIPLE HABITS + FOCUS MODE:
/// - Users can track multiple habits
/// - One habit can be "focused" at a time for primary attention
/// - Focus mode helps prevent overwhelm (per Atomic Habits principle of habit stacking)
class AppState extends ChangeNotifier {
  // User profile
  UserProfile? _userProfile;

  // Multiple habits support
  List<Habit> _habits = [];

  // Focus mode: ID of the habit user wants to focus on (null = show all)
  String? _focusedHabitId;

  // Onboarding completion status
  bool _hasCompletedOnboarding = false;
  
  // Hive box for persistent storage
  Box? _dataBox;
  
  // Loading state
  bool _isLoading = true;
  
  // Reward + Investment flow state
  bool _shouldShowRewardFlow = false;

  // "Never Miss Twice" recovery flow state
  bool _shouldShowNeverMissTwice = false;
  int _daysSinceLastCompletion = 0;

  // Weekly review state
  bool _shouldShowWeeklyReview = false;
  String? _lastWeeklyReviewDate; // ISO date string of last completed review

  // Notification service
  final NotificationService _notificationService = NotificationService();
  
  // AI Suggestion service (local heuristics for now)
  final AiSuggestionService _aiSuggestionService = AiSuggestionService();

  // Getters to access state
  UserProfile? get userProfile => _userProfile;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get isLoading => _isLoading;
  bool get shouldShowRewardFlow => _shouldShowRewardFlow;
  bool get shouldShowNeverMissTwice => _shouldShowNeverMissTwice;
  int get daysSinceLastCompletion => _daysSinceLastCompletion;
  bool get shouldShowWeeklyReview => _shouldShowWeeklyReview;

  // === MULTIPLE HABITS GETTERS ===

  /// All habits the user is tracking
  List<Habit> get habits => List.unmodifiable(_habits);

  /// The ID of the currently focused habit (null if showing all)
  String? get focusedHabitId => _focusedHabitId;

  /// The currently focused habit (or first habit if none focused)
  /// Backward compatible - replaces old _currentHabit
  Habit? get focusedHabit {
    if (_habits.isEmpty) return null;
    if (_focusedHabitId != null) {
      final focused = _habits.where((h) => h.id == _focusedHabitId).firstOrNull;
      if (focused != null) return focused;
    }
    // Default to first habit if no focus set or focused habit not found
    return _habits.first;
  }

  /// Backward compatibility getter - same as focusedHabit
  Habit? get currentHabit => focusedHabit;

  /// Whether user is in focus mode (single habit view)
  bool get isFocusMode => _focusedHabitId != null;

  /// Number of habits user is tracking
  int get habitCount => _habits.length;

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
        await _scheduleNotifications();

        // Check for "Never Miss Twice" situation (for focused habit)
        _checkNeverMissTwiceSituation();

        // Check for weekly review (Sunday)
        _checkWeeklyReviewSituation();
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

    // Load multiple habits (with backward compatibility)
    final habitsJson = _dataBox!.get('habits');
    if (habitsJson != null && habitsJson is List) {
      _habits = (habitsJson as List)
          .map((h) => Habit.fromJson(Map<String, dynamic>.from(h)))
          .toList();
    } else {
      // Backward compatibility: migrate old single habit to list
      final oldHabitJson = _dataBox!.get('currentHabit');
      if (oldHabitJson != null) {
        final oldHabit = Habit.fromJson(Map<String, dynamic>.from(oldHabitJson));
        _habits = [oldHabit];
        // Set this habit as focused by default
        _focusedHabitId = oldHabit.id;
        // Migrate to new format
        await _dataBox!.put('habits', [oldHabitJson]);
        await _dataBox!.put('focusedHabitId', oldHabit.id);
        await _dataBox!.delete('currentHabit');
        if (kDebugMode) {
          debugPrint('Migrated old single habit to new multi-habit format');
        }
      }
    }

    // Load focused habit ID
    _focusedHabitId = _dataBox!.get('focusedHabitId');

    // Load last weekly review date
    _lastWeeklyReviewDate = _dataBox!.get('lastWeeklyReviewDate');

    if (kDebugMode) {
      debugPrint('Loaded from storage: onboarding=$_hasCompletedOnboarding, profile=${_userProfile?.name}, habits=${_habits.length}, focused=$_focusedHabitId');
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

      // Save all habits
      await _dataBox!.put('habits', _habits.map((h) => h.toJson()).toList());

      // Save focused habit ID
      if (_focusedHabitId != null) {
        await _dataBox!.put('focusedHabitId', _focusedHabitId);
      } else {
        await _dataBox!.delete('focusedHabitId');
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

  /// Creates a new habit (adds to list)
  /// If this is the first habit, it becomes focused automatically
  Future<void> createHabit(Habit habit) async {
    _habits.add(habit);

    // If this is the first habit, focus on it
    if (_habits.length == 1) {
      _focusedHabitId = habit.id;
    }

    await _saveToStorage();
    notifyListeners();
  }

  /// Add an additional habit (alias for createHabit for clarity)
  Future<void> addHabit(Habit habit) async {
    await createHabit(habit);
  }

  /// Remove a habit by ID
  Future<void> removeHabit(String habitId) async {
    _habits.removeWhere((h) => h.id == habitId);

    // If we removed the focused habit, clear focus or refocus
    if (_focusedHabitId == habitId) {
      _focusedHabitId = _habits.isNotEmpty ? _habits.first.id : null;
    }

    await _saveToStorage();
    notifyListeners();
  }

  /// Update an existing habit
  Future<void> updateHabit(Habit updatedHabit) async {
    final index = _habits.indexWhere((h) => h.id == updatedHabit.id);
    if (index != -1) {
      _habits[index] = updatedHabit;
      await _saveToStorage();
      notifyListeners();
    }
  }

  /// Set the focused habit (focus mode)
  /// Pass null to exit focus mode and show all habits
  Future<void> setFocusedHabit(String? habitId) async {
    _focusedHabitId = habitId;
    await _saveToStorage();
    notifyListeners();

    if (kDebugMode) {
      if (habitId != null) {
        final habit = _habits.where((h) => h.id == habitId).firstOrNull;
        debugPrint('🎯 Focus mode: ${habit?.name ?? "unknown"}');
      } else {
        debugPrint('📋 Showing all habits');
      }
    }
  }

  /// Get a habit by ID
  Habit? getHabitById(String habitId) {
    return _habits.where((h) => h.id == habitId).firstOrNull;
  }

  /// Marks habit as completed for today
  /// Returns true if this was a new completion (triggers reward flow)
  ///
  /// Now tracks:
  /// - daysShowedUp (NEVER resets - cumulative total)
  /// - completionHistory (for rolling averages)
  /// - neverMissTwiceWins (when user recovers after single miss)
  /// - currentStreak (still tracked, but de-emphasized in UI)
  ///
  /// If habitId is provided, completes that specific habit.
  /// Otherwise completes the focused habit.
  Future<bool> completeHabitForToday({
    String? habitId,
    bool fromNotification = false,
    bool isMinimumVersion = false,
  }) async {
    // Find the habit to complete
    Habit? habitToComplete;
    int habitIndex = -1;

    if (habitId != null) {
      habitIndex = _habits.indexWhere((h) => h.id == habitId);
      if (habitIndex != -1) {
        habitToComplete = _habits[habitIndex];
      }
    } else {
      // Use focused habit
      habitToComplete = focusedHabit;
      if (habitToComplete != null) {
        habitIndex = _habits.indexWhere((h) => h.id == habitToComplete!.id);
      }
    }

    if (habitToComplete == null || habitIndex == -1) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayStr = today.toIso8601String().split('T')[0]; // YYYY-MM-DD

    // Check if already completed today
    if (habitToComplete.lastCompletedDate != null) {
      final lastCompleted = habitToComplete.lastCompletedDate!;
      final lastDate = DateTime(
        lastCompleted.year,
        lastCompleted.month,
        lastCompleted.day,
      );

      if (lastDate == today) {
        if (kDebugMode) {
          debugPrint('Habit already completed today');
        }
        return false;
      }
    }

    // Calculate new streak and detect "Never Miss Twice" recovery
    int newStreak = habitToComplete.currentStreak;
    bool isNeverMissTwiceRecovery = false;

    if (habitToComplete.lastCompletedDate != null) {
      final lastCompleted = habitToComplete.lastCompletedDate!;
      final lastDate = DateTime(
        lastCompleted.year,
        lastCompleted.month,
        lastCompleted.day,
      );

      final daysSinceLast = today.difference(lastDate).inDays;

      if (daysSinceLast == 1) {
        // Yesterday was completed - continue streak
        newStreak = habitToComplete.currentStreak + 1;
      } else if (daysSinceLast == 2) {
        // Missed exactly ONE day - this is a "Never Miss Twice" recovery!
        newStreak = 1;
        isNeverMissTwiceRecovery = true;
        if (kDebugMode) {
          debugPrint('🎯 Never Miss Twice recovery! User bounced back after 1 missed day.');
        }
      } else {
        // Missed multiple days - streak resets
        newStreak = 1;
        if (kDebugMode) {
          debugPrint('📉 Streak reset after $daysSinceLast days gap');
        }
      }
    } else {
      // First completion ever
      newStreak = 1;
    }

    // Update completion history (keep last 90 days for analytics)
    List<String> updatedHistory = List<String>.from(habitToComplete.completionHistory);
    if (!updatedHistory.contains(todayStr)) {
      updatedHistory.add(todayStr);
    }
    // Prune old entries (keep last 90 days)
    final ninetyDaysAgo = today.subtract(const Duration(days: 90));
    updatedHistory = updatedHistory.where((dateStr) {
      try {
        final date = DateTime.parse(dateStr);
        return date.isAfter(ninetyDaysAgo);
      } catch (_) {
        return false;
      }
    }).toList();

    // Update all metrics
    final updatedHabit = habitToComplete.copyWith(
      currentStreak: newStreak,
      lastCompletedDate: now,
      // These NEVER reset - cumulative progress
      daysShowedUp: habitToComplete.daysShowedUp + 1,
      minimumVersionCount: isMinimumVersion
          ? habitToComplete.minimumVersionCount + 1
          : habitToComplete.minimumVersionCount,
      neverMissTwiceWins: isNeverMissTwiceRecovery
          ? habitToComplete.neverMissTwiceWins + 1
          : habitToComplete.neverMissTwiceWins,
      completionHistory: updatedHistory,
    );

    // Update the habit in the list
    _habits[habitIndex] = updatedHabit;

    // Clear "Never Miss Twice" prompt since user just completed
    _shouldShowNeverMissTwice = false;
    _daysSinceLastCompletion = 0;

    await _saveToStorage();

    // Trigger Reward + Investment flow
    _shouldShowRewardFlow = true;

    notifyListeners();

    if (kDebugMode) {
      debugPrint('✅ Habit completed: ${updatedHabit.name}');
      debugPrint('   Streak: $newStreak');
      debugPrint('   Days showed up (total): ${updatedHabit.daysShowedUp}');
      debugPrint('   Graceful Consistency: ${updatedHabit.gracefulConsistencyScore}%');
      if (isNeverMissTwiceRecovery) {
        debugPrint('   🏆 Never Miss Twice wins: ${updatedHabit.neverMissTwiceWins}');
      }
    }

    return true;
  }

  /// Marks onboarding as complete
  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    await _saveToStorage(); // Persist to storage
    
    // Schedule daily notifications
    await _scheduleNotifications();
    
    notifyListeners();
  }

  /// Checks if habit was completed today
  /// If habitId is provided, checks that specific habit.
  /// Otherwise checks the focused habit.
  bool isHabitCompletedToday({String? habitId}) {
    Habit? habitToCheck;

    if (habitId != null) {
      habitToCheck = _habits.where((h) => h.id == habitId).firstOrNull;
    } else {
      habitToCheck = focusedHabit;
    }

    if (habitToCheck?.lastCompletedDate == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCompleted = habitToCheck!.lastCompletedDate!;
    final lastDate = DateTime(
      lastCompleted.year,
      lastCompleted.month,
      lastCompleted.day,
    );

    return lastDate == today;
  }

  /// Get count of habits completed today
  int get habitsCompletedTodayCount {
    int count = 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final habit in _habits) {
      if (habit.lastCompletedDate != null) {
        final lastDate = DateTime(
          habit.lastCompletedDate!.year,
          habit.lastCompletedDate!.month,
          habit.lastCompletedDate!.day,
        );
        if (lastDate == today) count++;
      }
    }
    return count;
  }

  /// Check if all habits are completed today
  bool get allHabitsCompletedToday {
    if (_habits.isEmpty) return false;
    return habitsCompletedTodayCount == _habits.length;
  }

  /// Clear all data (useful for testing/reset)
  Future<void> clearAllData() async {
    if (_dataBox != null) {
      await _dataBox!.clear();
    }
    _userProfile = null;
    _habits = [];
    _focusedHabitId = null;
    _hasCompletedOnboarding = false;
    await _notificationService.cancelAllNotifications();
    notifyListeners();
  }
  
  // ========== Notification Methods ==========
  
  /// Schedule daily notifications for habit reminder
  /// Schedules notifications for the focused habit (or first habit if none focused)
  Future<void> _scheduleNotifications() async {
    final habit = focusedHabit;
    if (habit == null || _userProfile == null) return;

    await _notificationService.scheduleDailyHabitReminder(
      habit: habit,
      profile: _userProfile!,
    );
  }
  
  /// Handle notification action buttons (Mark Done, Snooze)
  void _handleNotificationAction(String action) {
    if (kDebugMode) {
      debugPrint('📱 Notification action: $action');
    }

    final habit = focusedHabit;

    if (action == 'mark_done') {
      // Mark focused habit as complete from notification
      completeHabitForToday(fromNotification: true);
    } else if (action == 'snooze') {
      // Schedule snooze notification
      if (habit != null && _userProfile != null) {
        _notificationService.scheduleSnoozeNotification(
          habit: habit,
          profile: _userProfile!,
        );
      }
    }
  }
  
  /// Update reminder time and reschedule notifications
  /// Called from Investment flow
  /// Updates the focused habit's reminder time
  Future<void> updateReminderTime(String newTime, {String? habitId}) async {
    final targetHabitId = habitId ?? _focusedHabitId;
    if (targetHabitId == null) return;

    final index = _habits.indexWhere((h) => h.id == targetHabitId);
    if (index == -1) return;

    _habits[index] = _habits[index].copyWith(
      implementationTime: newTime,
    );

    await _saveToStorage();

    // Reschedule notifications with new time
    await _scheduleNotifications();

    notifyListeners();

    if (kDebugMode) {
      debugPrint('⏰ Reminder time updated to: $newTime for ${_habits[index].name}');
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
    notifyListeners();
  }

  /// Dismiss the "Never Miss Twice" recovery prompt
  void dismissNeverMissTwice() {
    _shouldShowNeverMissTwice = false;
    notifyListeners();
  }

  /// Check if user is in a "Never Miss Twice" situation
  /// Called on app launch and periodically
  /// Checks the focused habit (or first habit if none focused)
  ///
  /// Situations:
  /// - Missed 1 day: Show gentle "Never Miss Twice" prompt
  /// - Missed 2+ days: Show "Welcome Back" prompt (different flow)
  void _checkNeverMissTwiceSituation() {
    final habit = focusedHabit;
    if (habit == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if already completed today
    if (isHabitCompletedToday()) {
      _shouldShowNeverMissTwice = false;
      _daysSinceLastCompletion = 0;
      return;
    }

    // Check last completion
    if (habit.lastCompletedDate == null) {
      // Never completed - not a "miss" situation
      _shouldShowNeverMissTwice = false;
      _daysSinceLastCompletion = 0;
      return;
    }

    final lastCompleted = habit.lastCompletedDate!;
    final lastDate = DateTime(
      lastCompleted.year,
      lastCompleted.month,
      lastCompleted.day,
    );

    _daysSinceLastCompletion = today.difference(lastDate).inDays;

    if (_daysSinceLastCompletion == 1) {
      // Just yesterday - no need for special prompt yet
      // (They might complete today normally)
      _shouldShowNeverMissTwice = false;
    } else if (_daysSinceLastCompletion == 2) {
      // Missed exactly 1 day (yesterday) - "Never Miss Twice" situation!
      _shouldShowNeverMissTwice = true;
      if (kDebugMode) {
        debugPrint('⚠️ Never Miss Twice situation detected! Missed 1 day for ${habit.name}.');
      }
    } else if (_daysSinceLastCompletion > 2) {
      // Missed multiple days - still show recovery, but different framing
      _shouldShowNeverMissTwice = true;
      if (kDebugMode) {
        debugPrint('📅 Multi-day gap: $_daysSinceLastCompletion days since last completion of ${habit.name}');
      }
    }
  }

  /// Refresh the "Never Miss Twice" check (call when app resumes)
  void refreshMissedDayCheck() {
    _checkNeverMissTwiceSituation();
    notifyListeners();
  }

  // ========== Weekly Review Methods ==========

  /// Check if we should show the weekly review prompt
  /// Shows on Sundays if not already completed this week
  void _checkWeeklyReviewSituation() {
    final now = DateTime.now();

    // Only show on Sundays (weekday 7 in Dart)
    if (now.weekday != DateTime.sunday) {
      _shouldShowWeeklyReview = false;
      return;
    }

    // Check if already completed review this week
    if (_lastWeeklyReviewDate != null) {
      try {
        final lastReview = DateTime.parse(_lastWeeklyReviewDate!);
        final lastReviewDate = DateTime(lastReview.year, lastReview.month, lastReview.day);
        final today = DateTime(now.year, now.month, now.day);

        // Calculate the start of this week (Monday)
        final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));

        // If last review was this week, don't show again
        if (!lastReviewDate.isBefore(thisWeekStart)) {
          _shouldShowWeeklyReview = false;
          if (kDebugMode) {
            debugPrint('📅 Weekly review already completed this week');
          }
          return;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error parsing last review date: $e');
        }
      }
    }

    // It's Sunday and no review this week - show the prompt
    _shouldShowWeeklyReview = true;
    if (kDebugMode) {
      debugPrint('📅 Sunday! Time for weekly review');
    }
  }

  /// Complete the weekly review
  Future<void> completeWeeklyReview() async {
    final now = DateTime.now();
    _lastWeeklyReviewDate = DateTime(now.year, now.month, now.day).toIso8601String();
    _shouldShowWeeklyReview = false;

    // Save to storage
    if (_dataBox != null) {
      await _dataBox!.put('lastWeeklyReviewDate', _lastWeeklyReviewDate);
    }

    notifyListeners();

    if (kDebugMode) {
      debugPrint('✅ Weekly review completed');
    }
  }

  /// Dismiss the weekly review (skip for now)
  void dismissWeeklyReview() {
    _shouldShowWeeklyReview = false;
    notifyListeners();
  }

  /// Get weekly stats for the review dialog
  /// Returns stats for the focused habit (or first habit if none focused)
  Map<String, int> getWeeklyStats({String? habitId}) {
    Habit? habit;
    if (habitId != null) {
      habit = _habits.where((h) => h.id == habitId).firstOrNull;
    } else {
      habit = focusedHabit;
    }

    if (habit == null) {
      return {
        'daysCompleted': 0,
        'daysInWeek': 7,
      };
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Calculate this week's boundaries (Monday to Sunday)
    final daysFromMonday = today.weekday - 1;
    final thisWeekStart = today.subtract(Duration(days: daysFromMonday));

    // Count completions this week
    int daysCompleted = 0;
    for (final dateStr in habit.completionHistory) {
      try {
        final date = DateTime.parse(dateStr);
        final completionDate = DateTime(date.year, date.month, date.day);

        if (!completionDate.isBefore(thisWeekStart) &&
            !completionDate.isAfter(today)) {
          daysCompleted++;
        }
      } catch (_) {}
    }

    // Days elapsed in this week (1-7)
    final daysInWeek = today.weekday;

    return {
      'daysCompleted': daysCompleted,
      'daysInWeek': daysInWeek,
    };
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

  /// Get temptation bundling suggestions for focused habit (async)
  /// Returns empty list if habit data is incomplete
  ///
  /// Flow: Remote LLM (5s timeout) → Local fallback if needed
  Future<List<String>> getTemptationBundleSuggestionsForCurrentHabit() async {
    final habit = focusedHabit;
    if (habit == null || _userProfile == null) {
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

  /// Get pre-habit ritual suggestions for focused habit (async)
  /// Returns empty list if habit data is incomplete
  Future<List<String>> getPreHabitRitualSuggestionsForCurrentHabit() async {
    final habit = focusedHabit;
    if (habit == null || _userProfile == null) {
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

  /// Get environment cue suggestions for focused habit (async)
  /// Returns empty list if habit data is incomplete
  Future<List<String>> getEnvironmentCueSuggestionsForCurrentHabit() async {
    final habit = focusedHabit;
    if (habit == null || _userProfile == null) {
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

  /// Get environment distraction removal suggestions for focused habit (async)
  /// Returns empty list if habit data is incomplete
  Future<List<String>> getEnvironmentDistractionSuggestionsForCurrentHabit() async {
    final habit = focusedHabit;
    if (habit == null || _userProfile == null) {
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

  /// Get combined suggestions for "Improve this habit" feature (async)
  /// Returns a map with all suggestion types for the focused habit
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
}
