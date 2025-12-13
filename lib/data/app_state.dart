import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/habit.dart';
import 'models/user_profile.dart';
import 'models/consistency_metrics.dart';
import 'notification_service.dart';
import 'ai_suggestion_service.dart';
import 'services/recovery_engine.dart';

/// Central state management for the app
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
/// 
/// **Phase 3: Multi-Habit Support (v4.1.0)**
/// - Supports multiple habits with Focus Mode
/// - `currentHabit` getter returns the focused (primary) habit
/// - Legacy single-habit data auto-migrated on first load
/// - CRUD methods: createHabit, updateHabit, deleteHabit, setFocusHabit
class AppState extends ChangeNotifier {
  // User profile
  UserProfile? _userProfile;
  
  // ========== Phase 3: Multi-Habit Support ==========
  /// List of all user's habits
  List<Habit> _habits = [];
  
  /// ID of the currently focused habit (for Focus Mode)
  /// If null, the first primary habit or first habit is used
  String? _focusedHabitId;
  
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
  
  /// Tracks consecutive missed days (equivalent to user's suggested `int consecutiveMissedDays`)
  /// Calculated dynamically from habit.currentMissStreak for accuracy
  int get consecutiveMissedDays => currentHabit?.currentMissStreak ?? 0;
  
  /// The "Never Miss Twice Score" (0.0-1.0) - percentage of single misses that stayed single
  /// Higher score = better at recovering before a second miss
  double get neverMissTwiceScore => currentHabit?.neverMissTwiceRate ?? 1.0;
  
  // Notification service
  final NotificationService _notificationService = NotificationService();
  
  // AI Suggestion service (local heuristics for now)
  final AiSuggestionService _aiSuggestionService = AiSuggestionService();

  // Getters to access state
  UserProfile? get userProfile => _userProfile;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get isLoading => _isLoading;
  bool get shouldShowRewardFlow => _shouldShowRewardFlow;
  
  // ========== Phase 3: Multi-Habit Getters ==========
  
  /// All habits (read-only)
  List<Habit> get habits => List.unmodifiable(_habits);
  
  /// Number of habits
  int get habitCount => _habits.length;
  
  /// Check if user has any habits
  bool get hasHabits => _habits.isNotEmpty;
  
  /// The currently focused habit (backward compatible with single-habit code)
  /// Returns:
  /// 1. The habit matching _focusedHabitId (if set)
  /// 2. The first habit with isPrimaryHabit = true
  /// 3. The first habit in the list
  /// 4. null if no habits exist
  Habit? get currentHabit {
    if (_habits.isEmpty) return null;
    
    // Try to find the explicitly focused habit
    if (_focusedHabitId != null) {
      final focused = _habits.where((h) => h.id == _focusedHabitId).firstOrNull;
      if (focused != null) return focused;
    }
    
    // Fallback to first primary habit
    final primary = _habits.where((h) => h.isPrimaryHabit).firstOrNull;
    if (primary != null) return primary;
    
    // Ultimate fallback: first habit
    return _habits.first;
  }
  
  /// Get a habit by ID
  Habit? getHabitById(String id) {
    return _habits.where((h) => h.id == id).firstOrNull;
  }
  
  /// Get habits by category
  List<Habit> getHabitsByCategory(String category) {
    return _habits.where((h) => h.category == category).toList();
  }
  
  /// Get primary habits (in focus cycle)
  List<Habit> get primaryHabits {
    return _habits.where((h) => h.isPrimaryHabit).toList();
  }
  
  /// Get graduated habits (completed focus cycle)
  List<Habit> get graduatedHabits {
    return _habits.where((h) => h.hasGraduated).toList();
  }
  
  // ========== Graceful Consistency Getters ==========
  
  /// Current recovery need (null if none needed)
  RecoveryNeed? get currentRecoveryNeed => _currentRecoveryNeed;
  
  /// Whether to show the recovery prompt (user's suggested `bool shouldShowRecoveryPrompt`)
  bool get shouldShowRecoveryPrompt => _shouldShowRecoveryPrompt;
  
  /// Determines if recovery prompt should be shown (for external checks)
  /// Implements user's suggested `bool shouldShowNeverMissTwicePrompt()`
  bool shouldShowNeverMissTwicePrompt() {
    if (currentHabit == null) return false;
    if (currentHabit!.isPaused) return false;
    if (currentHabit!.isCompletedToday) return false;
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
      if (_hasCompletedOnboarding && hasHabits && _userProfile != null) {
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
  /// 
  /// **Phase 3 Migration:**
  /// - First tries to load 'habits' (new list format)
  /// - Falls back to 'currentHabit' (legacy single habit)
  /// - Auto-upgrades legacy data to list format
  Future<void> _loadFromStorage() async {
    if (_dataBox == null) return;

    // Load onboarding status
    _hasCompletedOnboarding = _dataBox!.get('hasCompletedOnboarding', defaultValue: false);

    // Load user profile
    final profileJson = _dataBox!.get('userProfile');
    if (profileJson != null) {
      _userProfile = UserProfile.fromJson(Map<String, dynamic>.from(profileJson));
    }

    // Load focused habit ID (Phase 3)
    _focusedHabitId = _dataBox!.get('focusedHabitId');

    // Phase 3: Try to load habits list first
    final habitsJson = _dataBox!.get('habits');
    if (habitsJson != null) {
      // New format: list of habits
      final habitsList = habitsJson as List;
      _habits = habitsList
          .map((h) => Habit.fromJson(Map<String, dynamic>.from(h)))
          .toList();
      
      if (kDebugMode) {
        debugPrint('📦 Loaded ${_habits.length} habits from storage');
      }
    } else {
      // Legacy format: check for single 'currentHabit'
      final legacyHabitJson = _dataBox!.get('currentHabit');
      if (legacyHabitJson != null) {
        final legacyHabit = Habit.fromJson(Map<String, dynamic>.from(legacyHabitJson));
        
        // Auto-upgrade: Make it the primary habit in the new list
        _habits = [
          legacyHabit.copyWith(
            isPrimaryHabit: true,
            focusCycleStart: legacyHabit.focusCycleStart ?? legacyHabit.createdAt,
          ),
        ];
        
        // Save in new format immediately
        await _saveToStorage();
        
        if (kDebugMode) {
          debugPrint('🚀 MIGRATION: Upgraded legacy habit "${legacyHabit.name}" to Multi-Habit system');
        }
      }
    }

    if (kDebugMode) {
      debugPrint('Loaded from storage: onboarding=$_hasCompletedOnboarding, profile=${_userProfile?.name}, habits=${_habits.length}');
      for (final h in _habits) {
        debugPrint('  - ${h.name} (primary=${h.isPrimaryHabit}, id=${h.id})');
      }
    }
  }

  /// Save all data to Hive storage
  /// 
  /// **Phase 3:** Saves habits as a list, plus focused habit ID
  Future<void> _saveToStorage() async {
    if (_dataBox == null) return;

    try {
      // Save onboarding status
      await _dataBox!.put('hasCompletedOnboarding', _hasCompletedOnboarding);

      // Save user profile
      if (_userProfile != null) {
        await _dataBox!.put('userProfile', _userProfile!.toJson());
      }

      // Phase 3: Save habits as list
      await _dataBox!.put('habits', _habits.map((h) => h.toJson()).toList());
      
      // Save focused habit ID
      if (_focusedHabitId != null) {
        await _dataBox!.put('focusedHabitId', _focusedHabitId);
      } else {
        await _dataBox!.delete('focusedHabitId');
      }
      
      // Clean up legacy 'currentHabit' key if it exists (one-time cleanup)
      if (_dataBox!.containsKey('currentHabit')) {
        await _dataBox!.delete('currentHabit');
        if (kDebugMode) {
          debugPrint('🧹 Cleaned up legacy currentHabit key');
        }
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

  /// Creates a new habit
  /// 
  /// **Phase 3 Behavior:**
  /// - If this is the first habit, it becomes primary automatically
  /// - If `habit.isPrimaryHabit` is true, other habits' primary status is cleared
  /// - The new habit becomes focused
  Future<void> createHabit(Habit habit) async {
    // If this is the first habit, make it primary
    final isFirst = _habits.isEmpty;
    Habit habitToAdd = habit;
    
    if (isFirst) {
      habitToAdd = habit.copyWith(
        isPrimaryHabit: true,
        focusCycleStart: habit.focusCycleStart ?? DateTime.now(),
      );
    } else if (habit.isPrimaryHabit) {
      // Clear primary status from other habits
      _habits = _habits.map((h) => h.copyWith(isPrimaryHabit: false)).toList();
    }
    
    _habits.add(habitToAdd);
    _focusedHabitId = habitToAdd.id;
    
    await _saveToStorage();
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('➕ Created habit: ${habitToAdd.name} (total: ${_habits.length})');
    }
  }
  
  /// Update an existing habit by ID
  Future<void> updateHabit(Habit updatedHabit) async {
    final index = _habits.indexWhere((h) => h.id == updatedHabit.id);
    if (index == -1) {
      if (kDebugMode) {
        debugPrint('⚠️ updateHabit: Habit not found (id=${updatedHabit.id})');
      }
      return;
    }
    
    // If this habit is becoming primary, clear others
    if (updatedHabit.isPrimaryHabit && !_habits[index].isPrimaryHabit) {
      _habits = _habits.map((h) => h.copyWith(isPrimaryHabit: false)).toList();
    }
    
    _habits[index] = updatedHabit;
    await _saveToStorage();
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('✏️ Updated habit: ${updatedHabit.name}');
    }
  }
  
  /// Delete a habit by ID
  Future<void> deleteHabit(String habitId) async {
    final habitToDelete = _habits.where((h) => h.id == habitId).firstOrNull;
    if (habitToDelete == null) {
      if (kDebugMode) {
        debugPrint('⚠️ deleteHabit: Habit not found (id=$habitId)');
      }
      return;
    }
    
    final wasPrimary = habitToDelete.isPrimaryHabit;
    final wasFocused = _focusedHabitId == habitId;
    
    _habits.removeWhere((h) => h.id == habitId);
    
    // If we deleted the focused habit, reset focus
    if (wasFocused) {
      _focusedHabitId = null;
    }
    
    // If we deleted the primary habit and others exist, promote the first one
    if (wasPrimary && _habits.isNotEmpty) {
      _habits[0] = _habits[0].copyWith(
        isPrimaryHabit: true,
        focusCycleStart: _habits[0].focusCycleStart ?? DateTime.now(),
      );
      if (kDebugMode) {
        debugPrint('👑 Promoted "${_habits[0].name}" to primary after deletion');
      }
    }
    
    await _saveToStorage();
    
    // Clear recovery state if it was for the deleted habit
    _currentRecoveryNeed = null;
    _shouldShowRecoveryPrompt = false;
    
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('🗑️ Deleted habit: ${habitToDelete.name} (remaining: ${_habits.length})');
    }
  }
  
  /// Set the focused habit (Focus Mode)
  Future<void> setFocusHabit(String habitId) async {
    final habit = _habits.where((h) => h.id == habitId).firstOrNull;
    if (habit == null) {
      if (kDebugMode) {
        debugPrint('⚠️ setFocusHabit: Habit not found (id=$habitId)');
      }
      return;
    }
    
    _focusedHabitId = habitId;
    await _saveToStorage();
    
    // Check recovery needs for the new focused habit
    _checkRecoveryNeeds();
    
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('🎯 Focus set to: ${habit.name}');
    }
  }
  
  /// Set a habit as the primary (start/restart focus cycle)
  Future<void> setPrimaryHabit(String habitId) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return;
    
    // Clear primary from all habits
    _habits = _habits.map((h) => h.copyWith(isPrimaryHabit: false)).toList();
    
    // Set this habit as primary with new focus cycle
    _habits[index] = _habits[index].copyWith(
      isPrimaryHabit: true,
      focusCycleStart: DateTime.now(),
    );
    
    // Also set as focused
    _focusedHabitId = habitId;
    
    await _saveToStorage();
    _checkRecoveryNeeds();
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('👑 Set primary habit: ${_habits[index].name}');
    }
  }
  
  /// Graduate a habit from focus mode (completed focus cycle)
  Future<void> graduateHabit(String habitId) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return;
    
    _habits[index] = _habits[index].copyWith(
      hasGraduated: true,
      graduatedAt: DateTime.now(),
      isPrimaryHabit: false,
    );
    
    await _saveToStorage();
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('🎓 Graduated habit: ${_habits[index].name}');
    }
  }

  /// Marks habit as completed for today
  /// Returns true if this was a new completion (triggers reward flow)
  /// 
  /// **Phase 3:** Can specify habitId to complete a specific habit,
  /// otherwise completes the focused habit (currentHabit).
  /// 
  /// **Graceful Consistency Updates:**
  /// - Adds completion to history for rolling averages
  /// - Tracks recovery events if bouncing back from a miss
  /// - Updates identity votes count
  /// - Updates longest streak if needed
  Future<bool> completeHabitForToday({
    String? habitId,
    bool fromNotification = false,
    bool usedTinyVersion = false,
  }) async {
    // Phase 3: Find the habit to complete
    final targetId = habitId ?? currentHabit?.id;
    if (targetId == null) return false;
    
    final habitIndex = _habits.indexWhere((h) => h.id == targetId);
    if (habitIndex == -1) return false;
    
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
    bool isRecovery = false;
    int daysMissed = 0;
    DateTime? missStartDate;
    
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
    final newCompletionHistory = List<DateTime>.from(habit.completionHistory)
      ..add(now);
    
    // Update recovery history if this was a recovery
    final newRecoveryHistory = List<RecoveryEvent>.from(habit.recoveryHistory);
    
    // Track "Never Miss Twice" wins specifically
    int newSingleMissRecoveries = habit.singleMissRecoveries;
    
    if (isRecovery && missStartDate != null) {
      newRecoveryHistory.add(RecoveryEvent(
        missDate: missStartDate,
        recoveryDate: now,
        daysMissed: daysMissed,
        missReason: habit.lastMissReason,
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
    final newDaysShowedUp = habit.daysShowedUp + 1;
    final newMinimumVersionCount = usedTinyVersion 
        ? habit.minimumVersionCount + 1 
        : habit.minimumVersionCount;
    final newFullCompletionCount = !usedTinyVersion 
        ? habit.fullCompletionCount + 1 
        : habit.fullCompletionCount;
    
    // Update identity votes and longest streak
    final newIdentityVotes = habit.identityVotes + 1;
    final newLongestStreak = newStreak > habit.longestStreak 
        ? newStreak 
        : habit.longestStreak;
    
    // Phase 3: Update habit in the list
    _habits[habitIndex] = habit.copyWith(
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
    
    await _saveToStorage(); // Persist the updated data
    
    // Clear recovery state since we just completed
    _currentRecoveryNeed = null;
    _shouldShowRecoveryPrompt = false;
    
    // Trigger Reward + Investment flow
    _shouldShowRewardFlow = true;
    
    notifyListeners();
    
    if (kDebugMode) {
      final updatedHabit = _habits[habitIndex];
      final metrics = updatedHabit.consistencyMetrics;
      debugPrint('✅ Habit "${updatedHabit.name}" completed! New streak: $newStreak');
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
    await _saveToStorage(); // Persist to storage
    
    // Schedule daily notifications
    await _scheduleNotifications();
    
    notifyListeners();
  }

  /// Checks if habit was completed today
  /// Phase 3: Can check specific habit by ID, defaults to focused habit
  bool isHabitCompletedToday({String? habitId}) {
    final habit = habitId != null ? getHabitById(habitId) : currentHabit;
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

  /// Clear all data (useful for testing/reset)
  Future<void> clearAllData() async {
    if (_dataBox != null) {
      await _dataBox!.clear();
    }
    _userProfile = null;
    _habits = [];  // Phase 3: Clear habits list
    _focusedHabitId = null;
    _hasCompletedOnboarding = false;
    await _notificationService.cancelAllNotifications();
    notifyListeners();
  }
  
  // ========== Notification Methods ==========
  
  /// Schedule daily notifications for habit reminder
  /// Phase 3: Schedules for the primary/focused habit
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
  
  /// Update reminder time and reschedule notifications
  /// Called from Investment flow
  /// Phase 3: Updates the focused habit's reminder time
  Future<void> updateReminderTime(String newTime, {String? habitId}) async {
    final targetId = habitId ?? currentHabit?.id;
    if (targetId == null) return;
    
    final index = _habits.indexWhere((h) => h.id == targetId);
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
  /// Phase 3: Checks the focused habit for recovery needs
  void _checkRecoveryNeeds() {
    if (currentHabit == null || _userProfile == null) {
      _currentRecoveryNeed = null;
      _shouldShowRecoveryPrompt = false;
      return;
    }
    
    _currentRecoveryNeed = RecoveryEngine.checkRecoveryNeed(
      habit: currentHabit!,
      profile: _userProfile!,
      completionHistory: currentHabit!.completionHistory,
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
  /// Phase 3: Records for the focused habit
  Future<void> recordMissReason(MissReason reason, {String? habitId}) async {
    final targetId = habitId ?? currentHabit?.id;
    if (targetId == null) return;
    
    final index = _habits.indexWhere((h) => h.id == targetId);
    if (index == -1) return;
    
    _habits[index] = _habits[index].copyWith(
      lastMissReason: reason.name,
    );
    
    await _saveToStorage();
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('📝 Recorded miss reason: ${reason.label} for ${_habits[index].name}');
    }
  }
  
  /// Update failure playbook for habit
  /// Phase 3: Updates for the focused habit
  Future<void> updateFailurePlaybook(FailurePlaybook playbook, {String? habitId}) async {
    final targetId = habitId ?? currentHabit?.id;
    if (targetId == null) return;
    
    final index = _habits.indexWhere((h) => h.id == targetId);
    if (index == -1) return;
    
    _habits[index] = _habits[index].copyWith(
      failurePlaybook: playbook,
    );
    
    await _saveToStorage();
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('📋 Updated failure playbook: ${playbook.scenario} for ${_habits[index].name}');
    }
  }
  
  /// Pause the habit (planned break)
  /// Phase 3: Pauses the focused habit or specified habit
  Future<void> pauseHabit({String? habitId}) async {
    final targetId = habitId ?? currentHabit?.id;
    if (targetId == null) return;
    
    final index = _habits.indexWhere((h) => h.id == targetId);
    if (index == -1) return;
    
    _habits[index] = _habits[index].copyWith(
      isPaused: true,
      pausedAt: DateTime.now(),
    );
    
    await _saveToStorage();
    
    // Clear recovery needs since habit is paused (if it's the focused one)
    if (targetId == currentHabit?.id) {
      _currentRecoveryNeed = null;
      _shouldShowRecoveryPrompt = false;
    }
    
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('⏸️ Habit paused: ${_habits[index].name}');
    }
  }
  
  /// Resume the habit from pause
  /// Phase 3: Resumes the focused habit or specified habit
  Future<void> resumeHabit({String? habitId}) async {
    final targetId = habitId ?? currentHabit?.id;
    if (targetId == null) return;
    
    final index = _habits.indexWhere((h) => h.id == targetId);
    if (index == -1) return;
    
    _habits[index] = _habits[index].copyWith(
      isPaused: false,
      pausedAt: null,
    );
    
    await _saveToStorage();
    
    // Check recovery needs after resuming (if it's the focused one)
    if (targetId == currentHabit?.id) {
      _checkRecoveryNeeds();
    }
    
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('▶️ Habit resumed: ${_habits[index].name}');
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
    if (currentHabit == null) return null;
    final metrics = currentHabit!.consistencyMetrics;
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
    if (currentHabit == null || _userProfile == null) {
      return [];
    }
    
    try {
      return await _aiSuggestionService.getTemptationBundleSuggestions(
        identity: _userProfile!.identity,
        habitName: currentHabit!.name,
        tinyVersion: currentHabit!.tinyVersion,
        implementationTime: currentHabit!.implementationTime,
        implementationLocation: currentHabit!.implementationLocation,
        existingTemptationBundle: currentHabit!.temptationBundle,
        existingPreRitual: currentHabit!.preHabitRitual,
        existingEnvironmentCue: currentHabit!.environmentCue,
        existingEnvironmentDistraction: currentHabit!.environmentDistraction,
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
    if (currentHabit == null || _userProfile == null) {
      return [];
    }
    
    try {
      return await _aiSuggestionService.getPreHabitRitualSuggestions(
        identity: _userProfile!.identity,
        habitName: currentHabit!.name,
        tinyVersion: currentHabit!.tinyVersion,
        implementationTime: currentHabit!.implementationTime,
        implementationLocation: currentHabit!.implementationLocation,
        existingTemptationBundle: currentHabit!.temptationBundle,
        existingPreRitual: currentHabit!.preHabitRitual,
        existingEnvironmentCue: currentHabit!.environmentCue,
        existingEnvironmentDistraction: currentHabit!.environmentDistraction,
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
    if (currentHabit == null || _userProfile == null) {
      return [];
    }
    
    try {
      return await _aiSuggestionService.getEnvironmentCueSuggestions(
        identity: _userProfile!.identity,
        habitName: currentHabit!.name,
        tinyVersion: currentHabit!.tinyVersion,
        implementationTime: currentHabit!.implementationTime,
        implementationLocation: currentHabit!.implementationLocation,
        existingTemptationBundle: currentHabit!.temptationBundle,
        existingPreRitual: currentHabit!.preHabitRitual,
        existingEnvironmentCue: currentHabit!.environmentCue,
        existingEnvironmentDistraction: currentHabit!.environmentDistraction,
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
    if (currentHabit == null || _userProfile == null) {
      return [];
    }
    
    try {
      return await _aiSuggestionService.getEnvironmentDistractionSuggestions(
        identity: _userProfile!.identity,
        habitName: currentHabit!.name,
        tinyVersion: currentHabit!.tinyVersion,
        implementationTime: currentHabit!.implementationTime,
        implementationLocation: currentHabit!.implementationLocation,
        existingTemptationBundle: currentHabit!.temptationBundle,
        existingPreRitual: currentHabit!.preHabitRitual,
        existingEnvironmentCue: currentHabit!.environmentCue,
        existingEnvironmentDistraction: currentHabit!.environmentDistraction,
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
