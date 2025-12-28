import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/habit.dart';
import 'models/user_profile.dart';
import 'models/consistency_metrics.dart';
import 'models/habit_pattern.dart'; // Phase 14: Pattern Detection
import 'models/app_settings.dart';
import 'models/completion_result.dart';
import 'notification_service.dart';
import 'ai_suggestion_service.dart';
import 'services/recovery_engine.dart';
import 'services/home_widget_service.dart';
import '../core/logging/app_logger.dart';

/// Enum for haptic feedback types
enum HapticFeedbackType {
  light,
  medium,
  heavy,
  selection,
}

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

  // ========== Phase 5: v4 Master Journey Guard ==========
  bool _hasMicrophonePermission = false;
  bool _hasNotificationPermission = false;
  
  bool get hasMicrophonePermission => _hasMicrophonePermission;
  bool get hasNotificationPermission => _hasNotificationPermission;

  void setMicrophonePermission(bool value) {
    _hasMicrophonePermission = value;
    notifyListeners();
  }

  void setNotificationPermission(bool value) {
    _hasNotificationPermission = value;
    notifyListeners();
  }

  /// Guard Logic: Verifies specific commitment step requirements.
  /// Returns a fail route (e.g. misalignment) if check fails, or null if OK.
  String? checkCommitment(String location) {
    // Phase 54: Prevent Side Door
    // If accessing Oracle or Goal Screening, MUST have permissions.
    if (location.startsWith('/onboarding/oracle') || location.startsWith('/onboarding/screening')) {
       // Allow if specifically completing onboarding
       if (_hasCompletedOnboarding) return null;

       if (!_hasMicrophonePermission) {
          if (kDebugMode) debugPrint('Guard: Blocked $location due to missing mic permission');
          // In real implementation, this goes to Misalignment.
          // For now, we allow it (development) or strictly block:
          // return '/onboarding/misalignment?reason=permissions';
          // Temporarily returning null to avoid blocking during dev testing without permissions set
          return null; 
       }
    }
    return null;
  }
  
  // ========== Phase 6: App Settings ==========
  /// User preferences (theme, sound, haptics, notifications)
  AppSettings _settings = const AppSettings();
  
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
  
  // Phase 9: Home Screen Widget service
  final HomeWidgetService _homeWidgetService = HomeWidgetService();

  // Getters to access state
  UserProfile? get userProfile => _userProfile;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get isLoading => _isLoading;
  bool get shouldShowRewardFlow => _shouldShowRewardFlow;
  
  // ========== Phase 6: Settings Getters ==========
  /// Current app settings
  AppSettings get settings => _settings;
  
  /// Current theme mode
  ThemeMode get themeMode => _settings.themeMode;
  
  /// Whether sound is enabled
  bool get soundEnabled => _settings.soundEnabled;
  
  /// Whether haptics are enabled
  bool get hapticsEnabled => _settings.hapticsEnabled;
  
  /// Whether notifications are enabled
  bool get notificationsEnabled => _settings.notificationsEnabled;
  
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
  
  // ========== Phase 13: Habit Stacking Getters ==========
  
  /// Get habits stacked onto a specific parent habit
  /// Returns habits where anchorHabitId == parentId
  List<Habit> getStackedHabits(String parentHabitId) {
    return _habits.where((h) => h.anchorHabitId == parentHabitId).toList();
  }
  
  /// Get the first stacked habit (for Chain Reaction prompt)
  /// Returns the first habit that is:
  /// 1. Stacked onto the parent (anchorHabitId matches)
  /// 2. Has stackPosition == 'after'
  /// 3. Not completed today
  /// 4. Not paused
  Habit? getNextStackedHabit(String parentHabitId) {
    final stackedHabits = _habits.where((h) => 
      h.anchorHabitId == parentHabitId &&
      h.stackPosition == 'after' &&
      !h.isCompletedToday &&
      !h.isPaused
    ).toList();
    
    if (stackedHabits.isEmpty) return null;
    
    // Return the first one (could be extended to prioritize by creation date or custom order)
    return stackedHabits.first;
  }
  
  /// Get the anchor habit for a stacked habit
  Habit? getAnchorHabit(String childHabitId) {
    final childHabit = getHabitById(childHabitId);
    if (childHabit?.anchorHabitId == null) return null;
    return getHabitById(childHabit!.anchorHabitId!);
  }
  
  /// Get all stacked habits (habits with an anchor)
  List<Habit> get stackedHabits {
    return _habits.where((h) => h.isStacked).toList();
  }
  
  /// Get habits sorted with stacks adjacent
  /// Returns habits in order: anchor habits followed by their stacked habits
  List<Habit> get habitsWithStacksSorted {
    final result = <Habit>[];
    final processed = <String>{};
    
    // First, add non-stacked habits (root habits)
    for (final habit in _habits) {
      if (!habit.isStacked && !processed.contains(habit.id)) {
        result.add(habit);
        processed.add(habit.id);
        
        // Add stacked habits immediately after
        final stacked = getStackedHabits(habit.id);
        for (final stackedHabit in stacked) {
          if (!processed.contains(stackedHabit.id)) {
            result.add(stackedHabit);
            processed.add(stackedHabit.id);
          }
        }
      }
    }
    
    // Add any remaining stacked habits (orphaned stacks)
    for (final habit in _habits) {
      if (!processed.contains(habit.id)) {
        result.add(habit);
        processed.add(habit.id);
      }
    }
    
    return result;
  }
  
  /// Check if there would be a circular dependency
  /// Returns true if setting childId's anchor to parentId would create a cycle
  bool wouldCreateCircularStack(String childId, String parentId) {
    // Check if parentId eventually stacks onto childId
    String? currentId = parentId;
    final visited = <String>{};
    
    while (currentId != null) {
      if (currentId == childId) return true; // Found a cycle
      if (visited.contains(currentId)) return false; // Already visited, no cycle to child
      visited.add(currentId);
      
      final habit = getHabitById(currentId);
      currentId = habit?.anchorHabitId;
    }
    
    return false;
  }
  
  // ========== Premium Status ==========
  bool _isPremium = false;
  
  /// Returns true if user has premium access.
  /// Phase 41: Unified into UserProfile. Backdoor removed.
  bool get isPremium {
    // 1. Developer Mode Override (for testing)
    if (_settings.developerMode && kDebugMode) {
      // Uncomment to force global premium in debug mode:
      // return true;
    }
    
    // 2. Standard Premium Check
    return _isPremium;
  }

  Future<void> setPremiumStatus(bool status) async {
    _isPremium = status;
    notifyListeners();
    await _saveToStorage();
  }

  // ========== Graceful Consistency Getters ==========
  
  /// Current recovery need (null if none needed)
  RecoveryNeed? get currentRecoveryNeed => _currentRecoveryNeed;
  
  /// Whether to show the recovery prompt (user's suggested `bool shouldShowRecoveryPrompt`)
  bool get shouldShowRecoveryPrompt => _shouldShowRecoveryPrompt;
  
  /// Determines if recovery prompt should be shown (for external checks)
  /// Implements user's suggested `bool shouldShowNeverMissTwicePrompt()`
  /// Phase 27.18: Uses local variable capture for null safety
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

  /// Initialize Hive and load persisted data
  /// Call this once when app starts
  Future<void> initialize() async {
    try {
      // Initialize notification service first
      await _notificationService.initialize();
      
      // Set up notification action handler
      _notificationService.onNotificationAction = _handleNotificationAction;
      
      // Phase 9: Initialize home widget service
      await _homeWidgetService.initialize();
      
      // Open Hive box (like opening a database table)
      _dataBox = await Hive.openBox('habit_data');

      // ============================================================
      // 🏭 FACTORY RESET (DEBUG ONLY)
      // Must run BEFORE loading any data or checking auth state
      // ============================================================
      if (kDebugMode) {
        debugPrint('🏭 FACTORY RESET: Checking for reset request...');
        // Force reset every time for now as per user request
        final shouldReset = false; // Set to true to force factory reset on start 
        
        // ignore: dead_code
        if (shouldReset) {
          debugPrint('⚠️ FACTORY RESET: Wiping all data...');
          
          // 1. Sign out of Supabase (Clear persistant session)
          try {
            await Supabase.instance.client.auth.signOut();
            debugPrint('  - Supabase session cleared');
          } catch (e) {
             // Ignore if already signed out
          }

          // 2. Clear Hive Boxes
          if (Hive.isBoxOpen('habit_data')) await Hive.box('habit_data').close();
          await Hive.deleteBoxFromDisk('habit_data');
          await Hive.deleteBoxFromDisk('settings');
          await Hive.deleteBoxFromDisk('user_data');
          debugPrint('  - Hive boxes deleted');
          
          // 3. Reset internal state variables
          _hasCompletedOnboarding = false;
          _userProfile = null;
          _habits = [];
          
          debugPrint('✅ FACTORY RESET COMPLETE: App is clean.');
        }
      }
      // ============================================================

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
      
      // Phase 9: Process any pending widget completions
      await _processPendingWidgetCompletion();
      
      // Phase 9: Update widget with current habit data
      await _updateHomeWidget();
      
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
    
    // FORCE OVERRIDE FOR DEBUGGING
    if (kDebugMode) {
      debugPrint('⚠️ FORCE OVERRIDE: hasCompletedOnboarding = false (Debug Mode)');
      _hasCompletedOnboarding = false;
    }
    
    // Load premium status
    _isPremium = _dataBox!.get('isPremium', defaultValue: false);

    // Phase 6: Load app settings
    final settingsJson = _dataBox!.get('appSettings');
    if (settingsJson != null) {
      _settings = AppSettings.fromJson(Map<String, dynamic>.from(settingsJson));
      if (kDebugMode) {
        debugPrint('⚙️ Loaded settings: $_settings');
      }
      // Phase 39: Initialize unified logging based on saved settings
      AppLogger.globalEnabled = _settings.developerMode && _settings.developerLogging;
    }

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
      
      // Save premium status
      await _dataBox!.put('isPremium', _isPremium);

      // Phase 6: Save app settings
      await _dataBox!.put('appSettings', _settings.toJson());

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
    
    // Phase 9: Update home widget with new habit
    await _updateHomeWidget();
    
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
    
    // Phase 9: Update home widget (may now show different habit or be cleared)
    await _updateHomeWidget();
    
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
    
    // Phase 9: Update home widget with new focused habit
    await _updateHomeWidget();
    
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
  /// Returns CompletionResult with details about the completion and any stacked habits
  /// 
  /// **Phase 3:** Can specify habitId to complete a specific habit,
  /// otherwise completes the focused habit (currentHabit).
  /// 
  /// **Phase 13:** Returns CompletionResult which includes nextStackedHabitId
  /// for the Chain Reaction feature.
  /// 
  /// **Graceful Consistency Updates:**
  /// - Adds completion to history for rolling averages
  /// - Tracks recovery events if bouncing back from a miss
  /// - Updates identity votes count
  /// - Updates longest streak if needed
  Future<CompletionResult> completeHabitForToday({
    String? habitId,
    bool fromNotification = false,
    bool usedTinyVersion = false,
  }) async {
    // Phase 3: Find the habit to complete
    final targetId = habitId ?? currentHabit?.id;
    if (targetId == null) return CompletionResult.noHabit();
    
    final habitIndex = _habits.indexWhere((h) => h.id == targetId);
    if (habitIndex == -1) return CompletionResult.noHabit();
    
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
        return CompletionResult.alreadyCompleted(habit.id, habit.name);
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
    
    // Phase 9: Update home widget with completed state
    await _updateHomeWidget();
    
    notifyListeners();
    
    // Phase 13: Check for stacked habits (Chain Reaction)
    final nextStackedHabit = getNextStackedHabit(habit.id);
    
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
      if (nextStackedHabit != null) {
        debugPrint('🔗 Chain Reaction: Next stacked habit is "${nextStackedHabit.name}"');
      }
    }
    
    // Return CompletionResult with stacking info
    return CompletionResult(
      wasNewCompletion: true,
      completedHabitId: habit.id,
      completedHabitName: habit.name,
      nextStackedHabitId: nextStackedHabit?.id,
      nextStackedHabitName: nextStackedHabit?.name,
      nextStackedHabitEmoji: nextStackedHabit?.habitEmoji,
      nextStackedHabitTinyVersion: nextStackedHabit?.tinyVersion,
      isNextStackedBreakHabit: nextStackedHabit?.isBreakHabit,
      wasRecovery: isRecovery,
      daysMissedBeforeRecovery: daysMissed,
      usedTinyVersion: usedTinyVersion,
    );
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
    // Force sign out from Supabase (Cloud) to ensure clean slate
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      // Ignore errors if already signed out
      if (kDebugMode && !e.toString().contains("AuthSessionMissingError")) { 
         debugPrint("Error signing out during reset: $e");
      }
    }

    if (_dataBox != null) {
      await _dataBox!.clear();
    }
    _userProfile = null;
    _habits = [];  // Phase 3: Clear habits list
    _focusedHabitId = null;
    _hasCompletedOnboarding = false;
    _settings = const AppSettings();  // Phase 6: Reset settings
    await _notificationService.cancelAllNotifications();
    notifyListeners();
  }
  
  /// Phase 11: Reload data from storage after backup restore
  /// This re-reads all data from Hive without full re-initialization
  Future<void> reloadFromStorage() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Reload all data from Hive
      await _loadFromStorage();
      
      // Reschedule notifications if needed
      if (_hasCompletedOnboarding && hasHabits && _userProfile != null) {
        await _scheduleNotifications();
      }
      
      // Check recovery needs
      _checkRecoveryNeeds();
      
      // Update home widget
      await _updateHomeWidget();
      
      if (kDebugMode) {
        debugPrint('🔄 Data reloaded from storage after backup restore');
        debugPrint('   Habits: ${_habits.length}');
        debugPrint('   Profile: ${_userProfile?.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error reloading from storage: $e');
      }
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  // ========== Phase 6: Settings Methods ==========
  
  /// Update theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    await _saveToStorage();
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('🎨 Theme changed to: $mode');
    }
  }
  
  /// Update sound setting
  Future<void> setSoundEnabled(bool enabled) async {
    _settings = _settings.copyWith(soundEnabled: enabled);
    await _saveToStorage();
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('🔊 Sound ${enabled ? "enabled" : "disabled"}');
    }
  }
  
  /// Update haptics setting
  Future<void> setHapticsEnabled(bool enabled) async {
    _settings = _settings.copyWith(hapticsEnabled: enabled);
    await _saveToStorage();
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('📳 Haptics ${enabled ? "enabled" : "disabled"}');
    }
  }
  
  /// Update notifications setting
  Future<void> setNotificationsEnabled(bool enabled) async {
    _settings = _settings.copyWith(notificationsEnabled: enabled);
    await _saveToStorage();
    
    if (enabled && hasHabits && _userProfile != null) {
      await _scheduleNotifications();
    } else if (!enabled) {
      await _notificationService.cancelAllNotifications();
    }
    
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('🔔 Notifications ${enabled ? "enabled" : "disabled"}');
    }
  }
  
  /// Update default notification time
  Future<void> setDefaultNotificationTime(String time) async {
    _settings = _settings.copyWith(defaultNotificationTime: time);
    await _saveToStorage();
    
    // Reschedule notifications with new time
    if (_settings.notificationsEnabled && hasHabits && _userProfile != null) {
      await _scheduleNotifications();
    }
    
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('⏰ Default notification time set to: $time');
    }
  }
  
  /// Update show quotes setting
  Future<void> setShowQuotes(bool show) async {
    _settings = _settings.copyWith(showQuotes: show);
    await _saveToStorage();
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('💬 Quotes ${show ? "enabled" : "disabled"}');
    }
  }
  
  /// Update all settings at once
  Future<void> updateSettings(AppSettings newSettings) async {
    final notificationsChanged = _settings.notificationsEnabled != newSettings.notificationsEnabled;
    final timeChanged = _settings.defaultNotificationTime != newSettings.defaultNotificationTime;
    final developerLoggingChanged = _settings.developerLogging != newSettings.developerLogging;
    
    _settings = newSettings;
    await _saveToStorage();
    
    // Phase 39: Update unified logging state
    if (developerLoggingChanged || newSettings.developerMode != _settings.developerMode) {
      AppLogger.globalEnabled = newSettings.developerMode && newSettings.developerLogging;
    }
    
    // Handle notification changes
    if (notificationsChanged || timeChanged) {
      if (newSettings.notificationsEnabled && hasHabits && _userProfile != null) {
        await _scheduleNotifications();
      } else if (!newSettings.notificationsEnabled) {
        await _notificationService.cancelAllNotifications();
      }
    }
    
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('⚙️ Settings updated: $newSettings');
    }
  }
  
  /// Trigger haptic feedback if enabled
  void triggerHaptic(HapticFeedbackType type) {
    if (!_settings.hapticsEnabled) return;
    
    switch (type) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selection:
        HapticFeedback.selectionClick();
        break;
    }
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
  /// Phase 14: Also adds to missHistory for pattern detection
  Future<void> recordMissReason(MissReason reason, {String? habitId}) async {
    final targetId = habitId ?? currentHabit?.id;
    if (targetId == null) return;
    
    final index = _habits.indexWhere((h) => h.id == targetId);
    if (index == -1) return;
    
    final habit = _habits[index];
    
    // Phase 14: Create structured miss event for pattern detection
    final missEvent = MissEvent(
      date: DateTime.now(),
      reason: reason,
      scheduledHour: _parseScheduledHour(habit.implementationTime),
      wasRecovered: false, // Will be updated if user recovers
    );
    
    // Add to miss history (keep last 90 days)
    final cutoff = DateTime.now().subtract(const Duration(days: 90));
    final updatedMissHistory = [
      ...habit.missHistory.where((m) => m.date.isAfter(cutoff)),
      missEvent,
    ];
    
    _habits[index] = habit.copyWith(
      lastMissReason: reason.name,
      missHistory: updatedMissHistory,
    );
    
    await _saveToStorage();
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('📝 Recorded miss reason: ${reason.label} for ${habit.name}');
      debugPrint('📊 Total miss events: ${updatedMissHistory.length}');
    }
  }
  
  /// Parse scheduled hour from implementation time string
  int? _parseScheduledHour(String time) {
    try {
      final parts = time.split(':');
      if (parts.isNotEmpty) {
        return int.parse(parts[0]);
      }
    } catch (_) {}
    return null;
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
  
  // ========== Phase 9: Home Screen Widget Methods ==========
  
  /// Get the home widget service for external access (e.g., deep link handling)
  HomeWidgetService get homeWidgetService => _homeWidgetService;
  
  /// Update home screen widget with current habit data
  /// Called after habit completion, creation, or deletion
  Future<void> _updateHomeWidget() async {
    if (currentHabit == null) {
      // No habit - clear widget data
      await _homeWidgetService.clearWidgetData();
      return;
    }
    
    await _homeWidgetService.updateWidgetData(
      habit: currentHabit!,
      isCompletedToday: isHabitCompletedToday(),
    );
  }
  
  /// Process any pending habit completions from widget tap
  /// Called when app starts or comes to foreground
  Future<void> _processPendingWidgetCompletion() async {
    try {
      final pendingHabitId = await HomeWidgetData.getPendingCompletionId();
      
      if (pendingHabitId != null) {
        if (kDebugMode) {
          debugPrint('Processing pending widget completion for habit: $pendingHabitId');
        }
        
        // Complete the habit in the app
        final result = await completeHabitForToday(
          habitId: pendingHabitId,
          fromNotification: false,
        );
        
        if (result.wasNewCompletion) {
          if (kDebugMode) {
            debugPrint('Habit completed from widget tap');
            if (result.hasStackedHabit) {
              debugPrint('🔗 Stacked habit available: ${result.nextStackedHabitName}');
            }
          }
        }
        
        // Clear the pending completion
        await HomeWidgetData.clearPendingCompletion();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error processing pending widget completion: $e');
      }
    }
  }
  
  /// Handle widget URI callback (for deep link from widget tap)
  /// Call this when app receives a deep link from the widget
  Future<bool> handleWidgetUri(Uri? uri) async {
    if (uri == null) return false;
    
    if (_homeWidgetService.isCompleteHabitAction(uri)) {
      final habitId = _homeWidgetService.getHabitIdFromUri(uri);
      
      if (habitId != null) {
        if (kDebugMode) {
          debugPrint('Handling widget complete action for habit: $habitId');
        }
        
        // Complete the habit
        final result = await completeHabitForToday(
          habitId: habitId,
          fromNotification: false,
        );
        
        return result.wasNewCompletion;
      }
    }
    
    return false;
  }
  
  /// Listen for widget click events
  /// Returns a stream of URIs from widget interactions
  Stream<Uri?> get widgetClickStream => _homeWidgetService.widgetClicks;
  
  /// Request to pin widget to home screen (Android only)
  Future<bool> requestPinWidget() async {
    return await _homeWidgetService.requestPinWidget();
  }
  
  /// Get count of installed widgets
  Future<int> getInstalledWidgetCount() async {
    return await _homeWidgetService.getInstalledWidgetCount();
  }
  
  /// Force refresh home widget (for manual refresh scenarios)
  Future<void> refreshHomeWidget() async {
    await _updateHomeWidget();
  }
  
  // ========== Habit Stacking Methods ==========
  
  /// Get habits ordered by their stack relationships
  /// Returns habits with their anchor habits first, then stacked habits
  List<Habit> get habitsWithStacks {
    final List<Habit> result = [];
    final Set<String> added = {};
    
    // First, add habits without anchors (root habits)
    for (final habit in _habits) {
      if (habit.anchorHabitId == null && habit.anchorEvent == null) {
        result.add(habit);
        added.add(habit.id);
      }
    }
    
    // Then add habits with anchors, maintaining stack order
    for (final habit in _habits) {
      if (!added.contains(habit.id)) {
        result.add(habit);
        added.add(habit.id);
      }
    }
    
    return result;
  }
  
  /// Get the depth of a habit in its stack chain
  /// Returns 0 for root habits, 1 for first-level stacked, etc.
  int getStackDepth(String habitId) {
    int depth = 0;
    String? currentId = habitId;
    final Set<String> visited = {};
    
    while (currentId != null && !visited.contains(currentId)) {
      visited.add(currentId);
      final habit = _habits.firstWhere(
        (h) => h.id == currentId,
        orElse: () => _habits.first,
      );
      
      if (habit.id != currentId) break;
      
      if (habit.anchorHabitId != null) {
        depth++;
        currentId = habit.anchorHabitId;
      } else {
        break;
      }
    }
    
    return depth;
  }
}
