import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/habit.dart';
import 'models/user_profile.dart';
import 'models/consistency_metrics.dart';
import 'notification_service.dart';
import 'ai_suggestion_service.dart';
import 'services/recovery_engine.dart';

/// Central state management for the app
///
/// **PHASE 3 UPDATE: Multiple Habits & Focus Mode**
/// - Supports a List<Habit> instead of single habit
/// - Maintains backward compatibility via currentHabit getter
/// - Automatic migration from legacy single-habit storage
///
/// Uses Provider for simple, beginner-friendly state management
/// Now includes Hive persistence for data that survives app restarts
/// Handles Hook Model: Trigger (notifications) → Action → Reward → Investment
///
/// **Graceful Consistency Philosophy:**
/// - Replaces fragile streaks with holistic consistency scoring
/// - Implements "Never Miss Twice" recovery system
/// - Celebrates recovery, not perfection
/// - Long-term averages matter more than perfect days
///
/// **Never Miss Twice Engine (Framework Feature 31):**
/// This engine is critical for preventing single misses from spiraling.
/// Key tracked fields:
/// - consecutiveMissedDays: tracks current miss streak (via currentMissStreak)
/// - shouldShowRecoveryPrompt: triggers recovery flow UI
/// - neverMissTwiceScore: percentage of single-day misses that stayed single
class AppState extends ChangeNotifier {
  // User profile
  UserProfile? _userProfile;

  // PHASE 3: List of habits (replacing single _currentHabit)
  List<Habit> _habits = [];

  // Onboarding completion status
  bool _hasCompletedOnboarding = false;

  // Hive box for persistent storage
  Box? _dataBox;

  // Loading state
  bool _isLoading = true;

  // Reward + Investment flow state
  bool _shouldShowRewardFlow = false;

  // ========== NEVER MISS TWICE ENGINE (Framework Feature 31) ==========
  // These fields implement the "Never Miss Twice" philosophy:
  // "Missing once is an accident. Missing twice is the start of a new habit."

  /// Current recovery need details (includes urgency level)
  RecoveryNeed? _currentRecoveryNeed;

  /// Whether to show the recovery prompt UI
  bool _shouldShowRecoveryPrompt = false;

  // Notification service
  final NotificationService _notificationService = NotificationService();

  // AI Suggestion service (local heuristics for now)
  final AiSuggestionService _aiSuggestionService = AiSuggestionService();

  // ========== GETTERS ==========

  UserProfile? get userProfile => _userProfile;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get isLoading => _isLoading;
  bool get shouldShowRewardFlow => _shouldShowRewardFlow;

  // PHASE 3: Access all habits
  List<Habit> get allHabits => List.unmodifiable(_habits);

  // PHASE 3: The "Focus Habit" (Primary)
  // Maintains backward compatibility for widgets expecting a single habit
  Habit? get currentHabit {
    if (_habits.isEmpty) return null;
    // Return the habit marked as primary, or the first one if none
    try {
      return _habits.firstWhere((h) => h.isPrimaryHabit);
    } catch (e) {
      // No primary habit found, return first
      return _habits.first;
    }
  }

  /// Tracks consecutive missed days (equivalent to user's suggested `int consecutiveMissedDays`)
  /// Calculated dynamically from habit.currentMissStreak for accuracy
  int get consecutiveMissedDays => currentHabit?.currentMissStreak ?? 0;

  /// The "Never Miss Twice Score" (0.0-1.0) - percentage of single misses that stayed single
  /// Higher score = better at recovering before a second miss
  double get neverMissTwiceScore => currentHabit?.neverMissTwiceRate ?? 1.0;

  // ========== Graceful Consistency Getters ==========

  /// Current recovery need (null if none needed)
  RecoveryNeed? get currentRecoveryNeed => _currentRecoveryNeed;

  /// Whether to show the recovery prompt (user's suggested `bool shouldShowRecoveryPrompt`)
  bool get shouldShowRecoveryPrompt => _shouldShowRecoveryPrompt;

  /// Determines if recovery prompt should be shown (for external checks)
  /// Implements user's suggested `bool shouldShowNeverMissTwicePrompt()`
  bool shouldShowNeverMissTwicePrompt() {
    final habit = currentHabit;
    if (habit == null) return false;
    if (habit.isPaused) return false;
    if (habit.isCompletedToday) return false;
    return consecutiveMissedDays >= 1;
  }

  /// Get the current graceful consistency metrics
  ConsistencyMetrics? get consistencyMetrics => currentHabit?.consistencyMetrics;

  /// Quick access to graceful score (0-100)
  double get gracefulScore => currentHabit?.gracefulScore ?? 0;

  /// Quick access to weekly average (0.0-1.0)
  double get weeklyAverage => currentHabit?.weeklyAverage ?? 0;

  /// Check if habit needs recovery attention
  bool get needsRecovery => currentHabit?.needsRecovery ?? false;

  // ========== INITIALIZATION & MIGRATION ==========

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

      // Load saved data from Hive (includes migration)
      await _loadFromStorage();

      // Schedule notifications if onboarding completed
      if (_hasCompletedOnboarding && currentHabit != null && _userProfile != null) {
        await _scheduleNotifications();
      }

      // Check for recovery needs (Never Miss Twice)
      _checkRecoveryNeeds();

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
  /// PHASE 3: Includes migration from legacy single-habit format
  Future<void> _loadFromStorage() async {
    if (_dataBox == null) return;

    // Load onboarding status
    _hasCompletedOnboarding = _dataBox!.get('hasCompletedOnboarding', defaultValue: false);

    // Load user profile
    final profileJson = _dataBox!.get('userProfile');
    if (profileJson != null) {
      _userProfile = UserProfile.fromJson(Map<String, dynamic>.from(profileJson));
    }

    // PHASE 3: Load List of Habits (new format)
    final habitsJson = _dataBox!.get('habits');

    if (habitsJson != null) {
      // New format: List of habits
      _habits = (habitsJson as List)
          .map((json) => Habit.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } else {
      // LEGACY MIGRATION: Check for single 'currentHabit'
      final legacyHabitJson = _dataBox!.get('currentHabit');
      if (legacyHabitJson != null) {
        final legacyHabit = Habit.fromJson(Map<String, dynamic>.from(legacyHabitJson));

        // Mark legacy habit as primary and add to list
        final migratedHabit = legacyHabit.copyWith(isPrimaryHabit: true);
        _habits = [migratedHabit];

        // Save immediately in new format and clear old key
        await _dataBox!.put('habits', _habits.map((h) => h.toJson()).toList());
        await _dataBox!.delete('currentHabit');

        if (kDebugMode) {
          debugPrint('🛠️ Migrated legacy habit to list format: ${migratedHabit.name}');
        }
      }
    }

    if (kDebugMode) {
      debugPrint('Loaded ${_habits.length} habits. Focus: ${currentHabit?.name}');
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

      // PHASE 3: Save List of Habits
      if (_habits.isNotEmpty) {
        await _dataBox!.put('habits', _habits.map((h) => h.toJson()).toList());
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

  // ========== USER PROFILE ==========

  /// Sets the user profile (from onboarding)
  Future<void> setUserProfile(UserProfile profile) async {
    _userProfile = profile;
    await _saveToStorage();
    notifyListeners();
  }

  // ========== HABIT CRUD OPERATIONS (PHASE 3) ==========

  /// Create a new habit
  /// If it's the first habit, it automatically becomes Primary
  Future<void> createHabit(Habit habit) async {
    // If this is the only habit, ensure it's primary
    final isFirst = _habits.isEmpty;
    final newHabit = habit.copyWith(
      isPrimaryHabit: isFirst || habit.isPrimaryHabit,
      focusCycleStart: (isFirst || habit.isPrimaryHabit) ? DateTime.now() : null,
    );

    // If new habit is primary, unset others
    if (newHabit.isPrimaryHabit) {
      _unfocusOtherHabits();
    }

    _habits.add(newHabit);
    await _saveToStorage();
    notifyListeners();

    if (kDebugMode) {
      debugPrint('➕ Created habit: ${newHabit.name} (primary: ${newHabit.isPrimaryHabit})');
    }
  }

  /// Update an existing habit by ID
  Future<void> updateHabit(Habit updatedHabit) async {
    final index = _habits.indexWhere((h) => h.id == updatedHabit.id);
    if (index != -1) {
      // Handle focus switching logic
      if (updatedHabit.isPrimaryHabit && !_habits[index].isPrimaryHabit) {
        _unfocusOtherHabits();
      }

      _habits[index] = updatedHabit;
      await _saveToStorage();
      notifyListeners();
    }
  }

  /// Delete a habit by ID
  Future<void> deleteHabit(String id) async {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index == -1) return;

    final wasPrimary = _habits[index].isPrimaryHabit;
    _habits.removeAt(index);

    // If we deleted the primary habit, promote the first remaining one
    if (wasPrimary && _habits.isNotEmpty) {
      _habits[0] = _habits[0].copyWith(
        isPrimaryHabit: true,
        focusCycleStart: DateTime.now(),
      );
    }

    await _saveToStorage();
    notifyListeners();

    if (kDebugMode) {
      debugPrint('🗑️ Deleted habit (was primary: $wasPrimary)');
    }
  }

  /// Set the Focus (Primary) habit by ID
  Future<void> setFocusHabit(String id) async {
    bool changed = false;
    for (int i = 0; i < _habits.length; i++) {
      if (_habits[i].id == id) {
        if (!_habits[i].isPrimaryHabit) {
          _habits[i] = _habits[i].copyWith(
            isPrimaryHabit: true,
            focusCycleStart: DateTime.now(),
          );
          changed = true;
        }
      } else {
        if (_habits[i].isPrimaryHabit) {
          _habits[i] = _habits[i].copyWith(isPrimaryHabit: false);
          changed = true;
        }
      }
    }

    if (changed) {
      await _saveToStorage();
      await _scheduleNotifications(); // Reschedule for new focus
      _checkRecoveryNeeds(); // Update recovery state for new focus
      notifyListeners();

      if (kDebugMode) {
        debugPrint('🎯 Focus habit changed to: ${currentHabit?.name}');
      }
    }
  }

  /// Get a habit by ID
  Habit? getHabitById(String id) {
    try {
      return _habits.firstWhere((h) => h.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Helper: Ensure only one habit is primary
  void _unfocusOtherHabits() {
    for (int i = 0; i < _habits.length; i++) {
      if (_habits[i].isPrimaryHabit) {
        _habits[i] = _habits[i].copyWith(isPrimaryHabit: false);
      }
    }
  }

  // ========== COMPLETION LOGIC ==========

  /// Marks habit as completed for today
  /// Returns true if this was a new completion (triggers reward flow)
  ///
  /// PHASE 3: Accepts optional habitId parameter
  /// If not provided, completes the Focus (primary) habit
  ///
  /// **Graceful Consistency Updates:**
  /// - Adds completion to history for rolling averages
  /// - Tracks recovery events if bouncing back from a miss
  /// - Updates identity votes count
  /// - Updates longest streak if needed
  Future<bool> completeHabitForToday({
    bool fromNotification = false,
    bool usedTinyVersion = false,
    String? habitId,
  }) async {
    // Determine target habit
    Habit? targetHabit;
    if (habitId != null) {
      targetHabit = getHabitById(habitId);
    } else {
      targetHabit = currentHabit;
    }

    if (targetHabit == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if already completed today
    if (targetHabit.lastCompletedDate != null) {
      final lastCompleted = targetHabit.lastCompletedDate!;
      final lastDate = DateTime(
        lastCompleted.year,
        lastCompleted.month,
        lastCompleted.day,
      );

      if (lastDate == today) {
        // Already completed today
        if (kDebugMode) {
          debugPrint('Habit already completed today');
        }
        return false;
      }
    }

    // Calculate new streak (check if yesterday was completed)
    int newStreak = targetHabit.currentStreak;
    bool isRecovery = false;
    int daysMissed = 0;
    DateTime? missStartDate;

    if (targetHabit.lastCompletedDate != null) {
      final lastCompleted = targetHabit.lastCompletedDate!;
      final yesterday = today.subtract(const Duration(days: 1));
      final lastDate = DateTime(
        lastCompleted.year,
        lastCompleted.month,
        lastCompleted.day,
      );

      // If last completion was yesterday, continue streak
      if (lastDate == yesterday) {
        newStreak = targetHabit.currentStreak + 1;
      } else {
        // **GRACEFUL CONSISTENCY**: Not a "reset" - this is a RECOVERY!
        // The old fragile streak mentality would reset to 0.
        // Instead, we start a new streak at 1 AND track the recovery.
        // The Graceful Consistency Score handles the nuance.
        newStreak = 1;
        isRecovery = true;
        daysMissed = today.difference(lastDate).inDays - 1;
        missStartDate = lastDate.add(const Duration(days: 1));

        // Log the graceful recovery philosophy in action
        if (kDebugMode) {
          debugPrint('💫 Graceful Recovery: Not a failure, just a comeback!');
          debugPrint('   Days missed: $daysMissed | Starting fresh streak');
        }
      }
    } else {
      // First completion
      newStreak = 1;
    }

    // Update completion history
    final newCompletionHistory = List<DateTime>.from(targetHabit.completionHistory)
      ..add(now);

    // Update recovery history if this was a recovery
    final newRecoveryHistory = List<RecoveryEvent>.from(targetHabit.recoveryHistory);

    // Track "Never Miss Twice" wins specifically
    int newSingleMissRecoveries = targetHabit.singleMissRecoveries;

    if (isRecovery && missStartDate != null) {
      newRecoveryHistory.add(RecoveryEvent(
        missDate: missStartDate,
        recoveryDate: now,
        daysMissed: daysMissed,
        missReason: targetHabit.lastMissReason,
        usedTinyVersion: usedTinyVersion,
      ));

      // "Never Miss Twice" win = recovered after only 1 day missed
      if (daysMissed == 1) {
        newSingleMissRecoveries++;
        if (kDebugMode) {
          debugPrint('🏆 NEVER MISS TWICE WIN! Single miss recovered immediately');
          debugPrint('   Total NMT wins: $newSingleMissRecoveries');
        }
      }

      if (kDebugMode) {
        debugPrint('🔄 Recovery recorded! Bounced back after $daysMissed day(s)');
      }
    }

    // Update flexible tracking metrics
    final newDaysShowedUp = targetHabit.daysShowedUp + 1;
    final newMinimumVersionCount = usedTinyVersion
        ? targetHabit.minimumVersionCount + 1
        : targetHabit.minimumVersionCount;
    final newFullCompletionCount = !usedTinyVersion
        ? targetHabit.fullCompletionCount + 1
        : targetHabit.fullCompletionCount;

    // Update identity votes and longest streak
    final newIdentityVotes = targetHabit.identityVotes + 1;
    final newLongestStreak = newStreak > targetHabit.longestStreak
        ? newStreak
        : targetHabit.longestStreak;

    final updatedHabit = targetHabit.copyWith(
      currentStreak: newStreak,
      lastCompletedDate: now,
      completionHistory: newCompletionHistory,
      recoveryHistory: newRecoveryHistory,
      identityVotes: newIdentityVotes,
      longestStreak: newLongestStreak,
      lastMissReason: null, // Clear last miss reason after recovery
      // Flexible tracking updates
      daysShowedUp: newDaysShowedUp,
      minimumVersionCount: newMinimumVersionCount,
      fullCompletionCount: newFullCompletionCount,
      singleMissRecoveries: newSingleMissRecoveries,
    );

    // Update habit in list
    await updateHabit(updatedHabit);

    // Clear recovery state and trigger reward flow only for primary habit
    if (updatedHabit.isPrimaryHabit) {
      _currentRecoveryNeed = null;
      _shouldShowRecoveryPrompt = false;
      _shouldShowRewardFlow = true;
    }

    notifyListeners();

    if (kDebugMode) {
      final metrics = updatedHabit.consistencyMetrics;
      debugPrint('✅ Habit completed! New streak: $newStreak');
      debugPrint('📊 Graceful Score: ${metrics.gracefulScore.toStringAsFixed(1)}');
      debugPrint('📈 Weekly Average: ${(metrics.weeklyAverage * 100).toStringAsFixed(0)}%');
      debugPrint('🏆 Identity Votes: $newIdentityVotes');
      debugPrint('📅 Days Showed Up: $newDaysShowedUp (never resets!)');
      debugPrint('🎯 Never Miss Twice Score: ${(metrics.neverMissTwiceRate * 100).toStringAsFixed(0)}%');
      if (isRecovery) {
        debugPrint('🎉 RECOVERY! Bounced back after $daysMissed day(s) missed');
        if (daysMissed == 1) {
          debugPrint('   ⭐ This was a "Never Miss Twice" win!');
        }
      }
    }

    return true; // New completion
  }

  /// Marks onboarding as complete
  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    await _saveToStorage();

    // Schedule daily notifications
    await _scheduleNotifications();

    notifyListeners();
  }

  /// Checks if habit was completed today (for primary habit)
  bool isHabitCompletedToday() {
    return currentHabit?.isCompletedToday ?? false;
  }

  /// Clear all data (useful for testing/reset)
  Future<void> clearAllData() async {
    if (_dataBox != null) {
      await _dataBox!.clear();
    }
    _userProfile = null;
    _habits = [];
    _hasCompletedOnboarding = false;
    await _notificationService.cancelAllNotifications();
    notifyListeners();
  }

  // ========== Notification Methods ==========

  /// Schedule daily notifications for habit reminder (primary habit only)
  Future<void> _scheduleNotifications() async {
    final habit = currentHabit;
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

    if (action == 'mark_done') {
      // Mark habit as complete from notification
      completeHabitForToday(fromNotification: true);
    } else if (action == 'snooze') {
      // Schedule snooze notification
      final habit = currentHabit;
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
  Future<void> updateReminderTime(String newTime) async {
    final habit = currentHabit;
    if (habit == null) return;

    final updatedHabit = habit.copyWith(
      implementationTime: newTime,
    );

    await updateHabit(updatedHabit);

    // Reschedule notifications with new time
    await _scheduleNotifications();

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

  /// Check if we should show reward flow when app comes to foreground
  bool checkAndTriggerRewardFlow() {
    // If habit was just completed and we haven't shown reward yet
    if (_shouldShowRewardFlow) {
      return true;
    }
    return false;
  }

  // ========== Graceful Consistency & Recovery Methods ==========

  /// Check if habit needs recovery attention (Never Miss Twice)
  /// This should be called when app starts or comes to foreground
  void _checkRecoveryNeeds() {
    final habit = currentHabit;
    if (habit == null || _userProfile == null) {
      _currentRecoveryNeed = null;
      _shouldShowRecoveryPrompt = false;
      return;
    }

    _currentRecoveryNeed = RecoveryEngine.checkRecoveryNeed(
      habit: habit,
      profile: _userProfile!,
      completionHistory: habit.completionHistory,
    );

    // Show recovery prompt if there's a recovery need
    _shouldShowRecoveryPrompt = _currentRecoveryNeed != null;

    if (kDebugMode && _currentRecoveryNeed != null) {
      debugPrint('⚠️ Recovery needed: ${_currentRecoveryNeed!.daysMissed} day(s) missed');
      debugPrint('🎯 Urgency: ${_currentRecoveryNeed!.urgency}');
    }
  }

  /// Manually trigger recovery check (e.g., when app comes to foreground)
  void checkRecoveryNeeds() {
    _checkRecoveryNeeds();
    notifyListeners();
  }

  /// Dismiss the recovery prompt (user acknowledged it)
  void dismissRecoveryPrompt() {
    _shouldShowRecoveryPrompt = false;
    notifyListeners();
  }

  /// Record why the user missed (for pattern tracking)
  Future<void> recordMissReason(MissReason reason) async {
    final habit = currentHabit;
    if (habit == null) return;

    final updatedHabit = habit.copyWith(
      lastMissReason: reason.name,
    );

    await updateHabit(updatedHabit);

    if (kDebugMode) {
      debugPrint('📝 Recorded miss reason: ${reason.label}');
    }
  }

  /// Update failure playbook for habit
  Future<void> updateFailurePlaybook(FailurePlaybook playbook) async {
    final habit = currentHabit;
    if (habit == null) return;

    final updatedHabit = habit.copyWith(
      failurePlaybook: playbook,
    );

    await updateHabit(updatedHabit);

    if (kDebugMode) {
      debugPrint('📋 Updated failure playbook: ${playbook.scenario}');
    }
  }

  /// Pause the habit (planned break)
  Future<void> pauseHabit({String? habitId}) async {
    final habit = habitId != null ? getHabitById(habitId) : currentHabit;
    if (habit == null) return;

    final updatedHabit = habit.copyWith(
      isPaused: true,
      pausedAt: DateTime.now(),
    );

    await updateHabit(updatedHabit);

    // Clear recovery needs if pausing primary habit
    if (habit.isPrimaryHabit) {
      _currentRecoveryNeed = null;
      _shouldShowRecoveryPrompt = false;
    }

    notifyListeners();

    if (kDebugMode) {
      debugPrint('⏸️ Habit paused: ${habit.name}');
    }
  }

  /// Resume the habit from pause
  Future<void> resumeHabit({String? habitId}) async {
    final habit = habitId != null ? getHabitById(habitId) : currentHabit;
    if (habit == null) return;

    final updatedHabit = habit.copyWith(
      isPaused: false,
      pausedAt: null,
    );

    await updateHabit(updatedHabit);

    // Check recovery needs after resuming primary habit
    if (habit.isPrimaryHabit) {
      _checkRecoveryNeeds();
    }

    notifyListeners();

    if (kDebugMode) {
      debugPrint('▶️ Habit resumed: ${habit.name}');
    }
  }

  /// Get recovery message for current recovery need
  String? getRecoveryMessage() {
    if (_currentRecoveryNeed == null) return null;
    return RecoveryEngine.getRecoveryMessage(_currentRecoveryNeed!);
  }

  /// Get recovery title for current recovery need
  String? getRecoveryTitle() {
    if (_currentRecoveryNeed == null) return null;
    return RecoveryEngine.getRecoveryTitle(_currentRecoveryNeed!.urgency);
  }

  /// Get zoom-out perspective message
  String? getZoomOutMessage() {
    final habit = currentHabit;
    if (habit == null) return null;
    final metrics = habit.consistencyMetrics;
    return RecoveryEngine.getZoomOutMessage(
      totalDays: metrics.totalDays,
      completedDays: metrics.daysShowedUp,
      currentMissStreak: metrics.currentMissStreak,
    );
  }

  // ========== AI Suggestion Methods (Async with Remote LLM + Local Fallback) ==========

  /// Get temptation bundling suggestions for current habit (async)
  /// Returns empty list if habit data is incomplete
  ///
  /// Flow: Remote LLM (5s timeout) → Local fallback if needed
  Future<List<String>> getTemptationBundleSuggestionsForCurrentHabit() async {
    final habit = currentHabit;
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

  /// Get pre-habit ritual suggestions for current habit (async)
  /// Returns empty list if habit data is incomplete
  Future<List<String>> getPreHabitRitualSuggestionsForCurrentHabit() async {
    final habit = currentHabit;
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

  /// Get environment cue suggestions for current habit (async)
  /// Returns empty list if habit data is incomplete
  Future<List<String>> getEnvironmentCueSuggestionsForCurrentHabit() async {
    final habit = currentHabit;
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

  /// Get environment distraction removal suggestions for current habit (async)
  /// Returns empty list if habit data is incomplete
  Future<List<String>> getEnvironmentDistractionSuggestionsForCurrentHabit() async {
    final habit = currentHabit;
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
