import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/habit.dart';
import 'models/user_profile.dart';
import 'models/consistency_metrics.dart';
import 'notification_service.dart';
import 'ai_suggestion_service.dart';
import 'services/recovery_engine.dart';
import 'services/atomic_widget_service.dart';

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
/// **Resume Sync Strategy (Split-Brain Fix):**
/// Implements lifecycle-aware state reconciliation to handle the scenario where
/// the home screen widget completes a habit via background isolate while the app
/// is suspended. When the app resumes:
/// 1. Reloads habit data from Hive
/// 2. Detects external completions (widget wrote to Hive)
/// 3. Syncs in-memory state, cancels notifications, triggers reward flow
class AppState extends ChangeNotifier with WidgetsBindingObserver {
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

  // ========== RESUME SYNC STRATEGY (Split-Brain Fix) ==========
  // These fields track state for reconciliation with widget updates

  /// Tracks if we detected an external completion (from widget)
  /// Used to ensure reward flow triggers even when app was backgrounded
  bool _externalCompletionDetected = false;

  /// Concurrency guard: timestamp of last in-app state modification
  /// Used to prevent overwriting fresher widget data
  DateTime? _lastStateModification;

  /// Lock to prevent concurrent reconciliation operations
  bool _isReconciling = false;

  // ========== NEVER MISS TWICE ENGINE (Framework Feature 31) ==========
  // These fields implement the "Never Miss Twice" philosophy:
  // "Missing once is an accident. Missing twice is the start of a new habit."
  
  /// Current recovery need details (includes urgency level)
  RecoveryNeed? _currentRecoveryNeed;
  
  /// Whether to show the recovery prompt UI
  bool _shouldShowRecoveryPrompt = false;
  
  /// Tracks consecutive missed days (equivalent to user's suggested `int consecutiveMissedDays`)
  /// Calculated dynamically from habit.currentMissStreak for accuracy
  int get consecutiveMissedDays => _currentHabit?.currentMissStreak ?? 0;
  
  /// The "Never Miss Twice Score" (0.0-1.0) - percentage of single misses that stayed single
  /// Higher score = better at recovering before a second miss
  double get neverMissTwiceScore => _currentHabit?.neverMissTwiceRate ?? 1.0;
  
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

  /// Whether an external completion was detected (from widget)
  /// This flag helps UI show reward flow for widget completions
  bool get externalCompletionDetected => _externalCompletionDetected;
  
  // ========== Graceful Consistency Getters ==========
  
  /// Current recovery need (null if none needed)
  RecoveryNeed? get currentRecoveryNeed => _currentRecoveryNeed;
  
  /// Whether to show the recovery prompt (user's suggested `bool shouldShowRecoveryPrompt`)
  bool get shouldShowRecoveryPrompt => _shouldShowRecoveryPrompt;
  
  /// Determines if recovery prompt should be shown (for external checks)
  /// Implements user's suggested `bool shouldShowNeverMissTwicePrompt()`
  bool shouldShowNeverMissTwicePrompt() {
    if (_currentHabit == null) return false;
    if (_currentHabit!.isPaused) return false;
    if (_currentHabit!.isCompletedToday) return false;
    return consecutiveMissedDays >= 1;
  }
  
  /// Get the current graceful consistency metrics
  ConsistencyMetrics? get consistencyMetrics => _currentHabit?.consistencyMetrics;
  
  /// Quick access to graceful score (0-100)
  double get gracefulScore => _currentHabit?.gracefulScore ?? 0;
  
  /// Quick access to weekly average (0.0-1.0)
  double get weeklyAverage => _currentHabit?.weeklyAverage ?? 0;
  
  /// Check if habit needs recovery attention
  bool get needsRecovery => _currentHabit?.needsRecovery ?? false;

  /// Initialize Hive and load persisted data
  /// Call this once when app starts
  Future<void> initialize() async {
    try {
      // Register lifecycle observer for Resume Sync Strategy
      WidgetsBinding.instance.addObserver(this);

      // Initialize notification service first
      await _notificationService.initialize();

      // Set up notification action handler
      _notificationService.onNotificationAction = _handleNotificationAction;

      // Open Hive box (like opening a database table)
      _dataBox = await Hive.openBox('habit_data');

      // Load saved data from Hive
      await _loadFromStorage();

      // Record initial state modification timestamp
      _lastStateModification = DateTime.now();

      // Schedule notifications if onboarding completed
      if (_hasCompletedOnboarding && _currentHabit != null && _userProfile != null) {
        await _scheduleNotifications();
      }

      // Initialize home screen widget
      await AtomicWidgetService.initialize();

      // Update widget with current habit data
      await _updateHomeWidget();

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

  /// Clean up lifecycle observer
  /// Call when app is being disposed
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ========== LIFECYCLE OBSERVER (Resume Sync Strategy) ==========

  /// Called when app lifecycle state changes
  /// Key for detecting when app returns from background after widget update
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (kDebugMode) {
        debugPrint('📱 App resumed - checking for external changes...');
      }
      _reconcileWithHive();
    }
  }

  /// Reconciles in-memory state with Hive storage
  ///
  /// **Critical for Split-Brain Fix:**
  /// When the widget completes a habit, it writes directly to Hive.
  /// This method detects that external change and:
  /// 1. Updates in-memory state to match Hive
  /// 2. Cancels the daily reminder notification (no nagging!)
  /// 3. Triggers the reward flow (dopamine hit for widget users)
  ///
  /// **Concurrency Guard:**
  /// Uses timestamps and a reconciliation lock to prevent race conditions
  /// if user does something in-app at the exact same moment the widget updates.
  Future<void> _reconcileWithHive() async {
    // Prevent concurrent reconciliation
    if (_isReconciling) {
      if (kDebugMode) {
        debugPrint('⏳ Reconciliation already in progress, skipping...');
      }
      return;
    }

    _isReconciling = true;

    try {
      if (_dataBox == null || _currentHabit == null) {
        _isReconciling = false;
        return;
      }

      // Capture current in-memory state BEFORE loading from Hive
      final wasCompletedInMemory = isHabitCompletedToday();
      final inMemoryHabitId = _currentHabit!.id;

      // Load fresh data from Hive
      final habitJson = _dataBox!.get('currentHabit');
      if (habitJson == null) {
        _isReconciling = false;
        return;
      }

      final hiveHabit = Habit.fromJson(Map<String, dynamic>.from(habitJson));

      // Safety check: ensure we're comparing the same habit
      if (hiveHabit.id != inMemoryHabitId) {
        if (kDebugMode) {
          debugPrint('⚠️ Habit ID mismatch during reconciliation - skipping');
        }
        _isReconciling = false;
        return;
      }

      // Check if Hive has a completion that in-memory doesn't know about
      final hiveCompletedToday = _isHabitCompletedTodayFromData(hiveHabit);

      if (hiveCompletedToday && !wasCompletedInMemory) {
        // 🎯 SPLIT-BRAIN DETECTED: Widget completed the habit!
        if (kDebugMode) {
          debugPrint('🔄 External completion detected! Syncing state...');
          debugPrint('   Hive says: Completed');
          debugPrint('   Memory said: Not completed');
        }

        // Update in-memory state to match Hive
        _currentHabit = hiveHabit;
        _externalCompletionDetected = true;

        // CRITICAL: Cancel daily reminder so we don't nag the user
        await _notificationService.cancelDailyReminder();
        if (kDebugMode) {
          debugPrint('🔕 Daily reminder cancelled');
        }

        // Clear recovery state (habit is done!)
        _currentRecoveryNeed = null;
        _shouldShowRecoveryPrompt = false;

        // CRITICAL: Trigger reward flow so widget users get their dopamine hit
        _shouldShowRewardFlow = true;
        if (kDebugMode) {
          debugPrint('🎉 Reward flow triggered for widget completion');
        }

        notifyListeners();
      } else if (!hiveCompletedToday && !wasCompletedInMemory) {
        // No completion detected, but sync any other changes from Hive
        // (e.g., streak data, recovery history updated by widget)
        if (_habitDataDiffers(_currentHabit!, hiveHabit)) {
          if (kDebugMode) {
            debugPrint('🔄 Syncing non-completion changes from Hive...');
          }
          _currentHabit = hiveHabit;
          _checkRecoveryNeeds();
          notifyListeners();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error during reconciliation: $e');
      }
    } finally {
      _isReconciling = false;
    }
  }

  /// Check if habit was completed today from a Habit object
  /// (Helper for reconciliation - doesn't use in-memory _currentHabit)
  bool _isHabitCompletedTodayFromData(Habit habit) {
    if (habit.lastCompletedDate == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCompleted = habit.lastCompletedDate!;
    final lastDate = DateTime(
      lastCompleted.year,
      lastCompleted.month,
      lastCompleted.day,
    );

    return lastDate == today;
  }

  /// Check if two habits have meaningful differences (excluding lastCompletedDate)
  /// Used to detect if widget made other updates we should sync
  bool _habitDataDiffers(Habit a, Habit b) {
    return a.currentStreak != b.currentStreak ||
        a.identityVotes != b.identityVotes ||
        a.daysShowedUp != b.daysShowedUp ||
        a.completionHistory.length != b.completionHistory.length;
  }

  /// Public method to manually trigger reconciliation
  /// Called by UI when app comes to foreground (backup to lifecycle observer)
  Future<void> reconcileWithHiveIfNeeded() async {
    await _reconcileWithHive();
  }

  /// Clear the external completion flag after reward flow is shown
  void clearExternalCompletionFlag() {
    _externalCompletionDetected = false;
  }

  // ========== HOME SCREEN WIDGET INTEGRATION ==========

  /// Update the home screen widget with current habit data
  ///
  /// Called after:
  /// - App initialization
  /// - Habit completion
  /// - State reconciliation (after widget updates)
  /// - Habit changes (name, reset, etc.)
  Future<void> _updateHomeWidget() async {
    if (_currentHabit == null) {
      await AtomicWidgetService.showEmptyState();
      return;
    }

    await AtomicWidgetService.updateWidget(
      habitId: _currentHabit!.id,
      habitName: _currentHabit!.name,
      streak: _currentHabit!.currentStreak,
      completedToday: isHabitCompletedToday(),
      tinyVersion: _currentHabit!.tinyVersion,
    );
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
  /// **Graceful Consistency Updates:**
  /// - Adds completion to history for rolling averages
  /// - Tracks recovery events if bouncing back from a miss
  /// - Updates identity votes count
  /// - Updates longest streak if needed
  Future<bool> completeHabitForToday({
    bool fromNotification = false,
    bool usedTinyVersion = false,
  }) async {
    if (_currentHabit == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Check if already completed today
    if (_currentHabit!.lastCompletedDate != null) {
      final lastCompleted = _currentHabit!.lastCompletedDate!;
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
    int newStreak = _currentHabit!.currentStreak;
    bool isRecovery = false;
    int daysMissed = 0;
    DateTime? missStartDate;
    
    if (_currentHabit!.lastCompletedDate != null) {
      final lastCompleted = _currentHabit!.lastCompletedDate!;
      final yesterday = today.subtract(const Duration(days: 1));
      final lastDate = DateTime(
        lastCompleted.year,
        lastCompleted.month,
        lastCompleted.day,
      );
      
      // If last completion was yesterday, continue streak
      if (lastDate == yesterday) {
        newStreak = _currentHabit!.currentStreak + 1;
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
    final newCompletionHistory = List<DateTime>.from(_currentHabit!.completionHistory)
      ..add(now);
    
    // Update recovery history if this was a recovery
    final newRecoveryHistory = List<RecoveryEvent>.from(_currentHabit!.recoveryHistory);
    
    // Track "Never Miss Twice" wins specifically
    int newSingleMissRecoveries = _currentHabit!.singleMissRecoveries;
    
    if (isRecovery && missStartDate != null) {
      newRecoveryHistory.add(RecoveryEvent(
        missDate: missStartDate,
        recoveryDate: now,
        daysMissed: daysMissed,
        missReason: _currentHabit!.lastMissReason,
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
    final newDaysShowedUp = _currentHabit!.daysShowedUp + 1;
    final newMinimumVersionCount = usedTinyVersion 
        ? _currentHabit!.minimumVersionCount + 1 
        : _currentHabit!.minimumVersionCount;
    final newFullCompletionCount = !usedTinyVersion 
        ? _currentHabit!.fullCompletionCount + 1 
        : _currentHabit!.fullCompletionCount;
    
    // Update identity votes and longest streak
    final newIdentityVotes = _currentHabit!.identityVotes + 1;
    final newLongestStreak = newStreak > _currentHabit!.longestStreak 
        ? newStreak 
        : _currentHabit!.longestStreak;
    
    _currentHabit = _currentHabit!.copyWith(
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

    // Update home screen widget
    await _updateHomeWidget();

    notifyListeners();

    if (kDebugMode) {
      final metrics = _currentHabit!.consistencyMetrics;
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
    if (_currentHabit == null || _userProfile == null) {
      _currentRecoveryNeed = null;
      _shouldShowRecoveryPrompt = false;
      return;
    }
    
    _currentRecoveryNeed = RecoveryEngine.checkRecoveryNeed(
      habit: _currentHabit!,
      profile: _userProfile!,
      completionHistory: _currentHabit!.completionHistory,
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
    if (_currentHabit == null) return;
    
    _currentHabit = _currentHabit!.copyWith(
      lastMissReason: reason.name,
    );
    
    await _saveToStorage();
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('📝 Recorded miss reason: ${reason.label}');
    }
  }
  
  /// Update failure playbook for habit
  Future<void> updateFailurePlaybook(FailurePlaybook playbook) async {
    if (_currentHabit == null) return;
    
    _currentHabit = _currentHabit!.copyWith(
      failurePlaybook: playbook,
    );
    
    await _saveToStorage();
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('📋 Updated failure playbook: ${playbook.scenario}');
    }
  }
  
  /// Pause the habit (planned break)
  Future<void> pauseHabit() async {
    if (_currentHabit == null) return;
    
    _currentHabit = _currentHabit!.copyWith(
      isPaused: true,
      pausedAt: DateTime.now(),
    );
    
    await _saveToStorage();
    
    // Clear recovery needs since habit is paused
    _currentRecoveryNeed = null;
    _shouldShowRecoveryPrompt = false;
    
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('⏸️ Habit paused');
    }
  }
  
  /// Resume the habit from pause
  Future<void> resumeHabit() async {
    if (_currentHabit == null) return;
    
    _currentHabit = _currentHabit!.copyWith(
      isPaused: false,
      pausedAt: null,
    );
    
    await _saveToStorage();
    
    // Check recovery needs after resuming
    _checkRecoveryNeeds();
    
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('▶️ Habit resumed');
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
    if (_currentHabit == null) return null;
    final metrics = _currentHabit!.consistencyMetrics;
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
