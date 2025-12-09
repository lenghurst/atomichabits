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
class AppState extends ChangeNotifier {
  // User profile
  UserProfile? _userProfile;
  
  // Current habit (we'll support multiple habits later)
  Habit? _currentHabit;
  
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
  Habit? get currentHabit => _currentHabit;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get isLoading => _isLoading;
  bool get shouldShowRewardFlow => _shouldShowRewardFlow;
  bool get shouldShowNeverMissTwice => _shouldShowNeverMissTwice;
  int get daysSinceLastCompletion => _daysSinceLastCompletion;
  bool get shouldShowWeeklyReview => _shouldShowWeeklyReview;

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
      if (_hasCompletedOnboarding && _currentHabit != null && _userProfile != null) {
        await _scheduleNotifications();

        // Check for "Never Miss Twice" situation
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

    // Load current habit
    final habitJson = _dataBox!.get('currentHabit');
    if (habitJson != null) {
      _currentHabit = Habit.fromJson(Map<String, dynamic>.from(habitJson));
    }

    // Load last weekly review date
    _lastWeeklyReviewDate = _dataBox!.get('lastWeeklyReviewDate');

    if (kDebugMode) {
      debugPrint('Loaded from storage: onboarding=$_hasCompletedOnboarding, profile=${_userProfile?.name}, habit=${_currentHabit?.name}');
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

      // Save current habit
      if (_currentHabit != null) {
        await _dataBox!.put('currentHabit', _currentHabit!.toJson());
      }

      if (kDebugMode) {
        debugPrint('Saved to storage successfully');
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

  /// Creates a new habit
  Future<void> createHabit(Habit habit) async {
    _currentHabit = habit;
    await _saveToStorage(); // Persist to storage
    notifyListeners();
  }

  /// Marks habit as completed for today
  /// Returns true if this was a new completion (triggers reward flow)
  ///
  /// Now tracks:
  /// - daysShowedUp (NEVER resets - cumulative total)
  /// - completionHistory (for rolling averages)
  /// - neverMissTwiceWins (when user recovers after single miss)
  /// - currentStreak (still tracked, but de-emphasized in UI)
  Future<bool> completeHabitForToday({
    bool fromNotification = false,
    bool isMinimumVersion = false,
  }) async {
    if (_currentHabit == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayStr = today.toIso8601String().split('T')[0]; // YYYY-MM-DD

    // Check if already completed today
    if (_currentHabit!.lastCompletedDate != null) {
      final lastCompleted = _currentHabit!.lastCompletedDate!;
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
    int newStreak = _currentHabit!.currentStreak;
    bool isNeverMissTwiceRecovery = false;

    if (_currentHabit!.lastCompletedDate != null) {
      final lastCompleted = _currentHabit!.lastCompletedDate!;
      final lastDate = DateTime(
        lastCompleted.year,
        lastCompleted.month,
        lastCompleted.day,
      );

      final daysSinceLast = today.difference(lastDate).inDays;

      if (daysSinceLast == 1) {
        // Yesterday was completed - continue streak
        newStreak = _currentHabit!.currentStreak + 1;
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
    List<String> updatedHistory = List<String>.from(_currentHabit!.completionHistory);
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
    _currentHabit = _currentHabit!.copyWith(
      currentStreak: newStreak,
      lastCompletedDate: now,
      // These NEVER reset - cumulative progress
      daysShowedUp: _currentHabit!.daysShowedUp + 1,
      minimumVersionCount: isMinimumVersion
          ? _currentHabit!.minimumVersionCount + 1
          : _currentHabit!.minimumVersionCount,
      neverMissTwiceWins: isNeverMissTwiceRecovery
          ? _currentHabit!.neverMissTwiceWins + 1
          : _currentHabit!.neverMissTwiceWins,
      completionHistory: updatedHistory,
    );

    // Clear "Never Miss Twice" prompt since user just completed
    _shouldShowNeverMissTwice = false;
    _daysSinceLastCompletion = 0;

    await _saveToStorage();

    // Trigger Reward + Investment flow
    _shouldShowRewardFlow = true;

    notifyListeners();

    if (kDebugMode) {
      debugPrint('✅ Habit completed!');
      debugPrint('   Streak: $newStreak');
      debugPrint('   Days showed up (total): ${_currentHabit!.daysShowedUp}');
      debugPrint('   Graceful Consistency: ${_currentHabit!.gracefulConsistencyScore}%');
      if (isNeverMissTwiceRecovery) {
        debugPrint('   🏆 Never Miss Twice wins: ${_currentHabit!.neverMissTwiceWins}');
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
  bool isHabitCompletedToday() {
    if (_currentHabit?.lastCompletedDate == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCompleted = _currentHabit!.lastCompletedDate!;
    final lastDate = DateTime(
      lastCompleted.year,
      lastCompleted.month,
      lastCompleted.day,
    );

    return lastDate == today;
  }

  /// Clear all data (useful for testing/reset)
  Future<void> clearAllData() async {
    if (_dataBox != null) {
      await _dataBox!.clear();
    }
    _userProfile = null;
    _currentHabit = null;
    _hasCompletedOnboarding = false;
    await _notificationService.cancelAllNotifications();
    notifyListeners();
  }
  
  // ========== Notification Methods ==========
  
  /// Schedule daily notifications for habit reminder
  Future<void> _scheduleNotifications() async {
    if (_currentHabit == null || _userProfile == null) return;
    
    await _notificationService.scheduleDailyHabitReminder(
      habit: _currentHabit!,
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
      if (_currentHabit != null && _userProfile != null) {
        _notificationService.scheduleSnoozeNotification(
          habit: _currentHabit!,
          profile: _userProfile!,
        );
      }
    }
  }
  
  /// Update reminder time and reschedule notifications
  /// Called from Investment flow
  Future<void> updateReminderTime(String newTime) async {
    if (_currentHabit == null) return;
    
    _currentHabit = _currentHabit!.copyWith(
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
  ///
  /// Situations:
  /// - Missed 1 day: Show gentle "Never Miss Twice" prompt
  /// - Missed 2+ days: Show "Welcome Back" prompt (different flow)
  void _checkNeverMissTwiceSituation() {
    if (_currentHabit == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if already completed today
    if (isHabitCompletedToday()) {
      _shouldShowNeverMissTwice = false;
      _daysSinceLastCompletion = 0;
      return;
    }

    // Check last completion
    if (_currentHabit!.lastCompletedDate == null) {
      // Never completed - not a "miss" situation
      _shouldShowNeverMissTwice = false;
      _daysSinceLastCompletion = 0;
      return;
    }

    final lastCompleted = _currentHabit!.lastCompletedDate!;
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
        debugPrint('⚠️ Never Miss Twice situation detected! Missed 1 day.');
      }
    } else if (_daysSinceLastCompletion > 2) {
      // Missed multiple days - still show recovery, but different framing
      _shouldShowNeverMissTwice = true;
      if (kDebugMode) {
        debugPrint('📅 Multi-day gap: $_daysSinceLastCompletion days since last completion');
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
  Map<String, int> getWeeklyStats() {
    if (_currentHabit == null) {
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
    for (final dateStr in _currentHabit!.completionHistory) {
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
}
