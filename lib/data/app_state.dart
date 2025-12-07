import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/habit.dart';
import 'models/user_profile.dart';
import 'models/habit_circle.dart';
import 'models/creator_session.dart';
import 'notification_service.dart';
import 'ai_suggestion_service.dart';
import 'services/auth_service.dart';

/// Central state management for the app
/// Uses Provider for simple, beginner-friendly state management
/// Now includes Hive persistence for data that survives app restarts
/// Handles Hook Model: Trigger (notifications) → Action → Reward → Investment
///
/// Supports:
/// - Good habits (build) and bad habits (reduce)
/// - Habit circles (social layer)
/// - Creator mode (quantity-first tracking)
class AppState extends ChangeNotifier {
  // ============ Authentication State ============

  // Auth service
  final AuthService _authService = AuthService();

  // Auth state subscription
  StreamSubscription<User?>? _authSubscription;

  // Current Firebase user
  User? _firebaseUser;

  // Whether Firebase has initialized
  bool _authInitialized = false;

  // ============ User Data State ============

  // User profile
  UserProfile? _userProfile;

  // All habits (good and bad)
  List<Habit> _habits = [];

  // Current/selected habit for primary display
  Habit? _currentHabit;

  // Habit circles (social layer)
  List<HabitCircle> _habitCircles = [];

  // Creator sessions (for creator mode habits)
  List<CreatorSession> _creatorSessions = [];

  // Active creator session (if any)
  CreatorSession? _activeCreatorSession;

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

  // ============ Auth Getters ============

  /// Whether user is authenticated (signed in)
  bool get isAuthenticated => _firebaseUser != null;

  /// Whether auth has been initialized
  bool get authInitialized => _authInitialized;

  /// Current Firebase user
  User? get firebaseUser => _firebaseUser;

  /// Whether current user is a guest (anonymous)
  bool get isGuest => _firebaseUser?.isAnonymous ?? false;

  /// User's display name from Firebase
  String? get authDisplayName => _firebaseUser?.displayName;

  /// User's email from Firebase
  String? get authEmail => _firebaseUser?.email;

  /// Auth service for login operations
  AuthService get authService => _authService;

  // ============ Data Getters ============

  UserProfile? get userProfile => _userProfile;
  List<Habit> get habits => List.unmodifiable(_habits);
  List<Habit> get goodHabits => _habits.where((h) => h.habitType == HabitType.good).toList();
  List<Habit> get badHabits => _habits.where((h) => h.habitType == HabitType.bad).toList();
  Habit? get currentHabit => _currentHabit;
  List<HabitCircle> get habitCircles => List.unmodifiable(_habitCircles);
  List<CreatorSession> get creatorSessions => List.unmodifiable(_creatorSessions);
  CreatorSession? get activeCreatorSession => _activeCreatorSession;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get isLoading => _isLoading;
  bool get shouldShowRewardFlow => _shouldShowRewardFlow;

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

      // Initialize auth listener
      _initAuthListener();

      // Schedule notifications if onboarding completed
      if (_hasCompletedOnboarding && _currentHabit != null && _userProfile != null) {
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

  /// Initialize Firebase auth state listener
  void _initAuthListener() {
    // Get current user immediately
    _firebaseUser = _authService.currentUser;
    _authInitialized = true;

    // Listen for auth state changes
    _authSubscription = _authService.authStateChanges.listen((User? user) {
      _firebaseUser = user;
      notifyListeners();

      if (kDebugMode) {
        debugPrint('Auth state changed: ${user?.email ?? user?.uid ?? 'signed out'}');
      }
    });
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await _authService.signOut();

    // Optionally clear local data on sign out
    // Uncomment below to clear data when user signs out:
    // await _clearUserData();

    notifyListeners();
  }

  /// Clear all user data (for sign out or account deletion)
  Future<void> clearUserData() async {
    _userProfile = null;
    _habits.clear();
    _currentHabit = null;
    _habitCircles.clear();
    _creatorSessions.clear();
    _activeCreatorSession = null;
    _hasCompletedOnboarding = false;

    // Clear storage
    if (_dataBox != null) {
      await _dataBox!.clear();
    }

    notifyListeners();
  }

  /// Clean up resources
  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
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

    // Load all habits (new multi-habit support)
    final habitsJson = _dataBox!.get('habits');
    if (habitsJson != null && habitsJson is List) {
      _habits = habitsJson
          .map((h) => Habit.fromJson(Map<String, dynamic>.from(h)))
          .toList();
    }

    // Load current habit (backward compatibility)
    final habitJson = _dataBox!.get('currentHabit');
    if (habitJson != null) {
      _currentHabit = Habit.fromJson(Map<String, dynamic>.from(habitJson));
      // Migrate: add to habits list if not already there
      if (!_habits.any((h) => h.id == _currentHabit!.id)) {
        _habits.add(_currentHabit!);
      }
    } else if (_habits.isNotEmpty) {
      // Set first habit as current if none set
      _currentHabit = _habits.first;
    }

    // Load habit circles
    final circlesJson = _dataBox!.get('habitCircles');
    if (circlesJson != null && circlesJson is List) {
      _habitCircles = circlesJson
          .map((c) => HabitCircle.fromJson(Map<String, dynamic>.from(c)))
          .toList();
    }

    // Load creator sessions
    final sessionsJson = _dataBox!.get('creatorSessions');
    if (sessionsJson != null && sessionsJson is List) {
      _creatorSessions = sessionsJson
          .map((s) => CreatorSession.fromJson(Map<String, dynamic>.from(s)))
          .toList();
    }

    if (kDebugMode) {
      debugPrint('Loaded from storage: onboarding=$_hasCompletedOnboarding, '
          'profile=${_userProfile?.name}, habits=${_habits.length}, '
          'circles=${_habitCircles.length}, sessions=${_creatorSessions.length}');
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

      // Save current habit (for backward compatibility)
      if (_currentHabit != null) {
        await _dataBox!.put('currentHabit', _currentHabit!.toJson());
      }

      // Save habit circles
      await _dataBox!.put('habitCircles', _habitCircles.map((c) => c.toJson()).toList());

      // Save creator sessions
      await _dataBox!.put('creatorSessions', _creatorSessions.map((s) => s.toJson()).toList());

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
  Future<bool> completeHabitForToday({bool fromNotification = false}) async {
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
        // Streak broken, start over
        newStreak = 1;
      }
    } else {
      // First completion
      newStreak = 1;
    }
    
    _currentHabit = _currentHabit!.copyWith(
      currentStreak: newStreak,
      lastCompletedDate: now,
    );
    
    await _saveToStorage(); // Persist the updated streak
    
    // Trigger Reward + Investment flow
    _shouldShowRewardFlow = true;
    
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('✅ Habit completed! New streak: $newStreak');
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

  // ========== MULTI-HABIT MANAGEMENT ==========

  /// Add a new habit (good or bad)
  Future<void> addHabit(Habit habit) async {
    _habits.add(habit);
    // Set as current if it's the first habit or if it's a good habit and we don't have one
    if (_currentHabit == null ||
        (habit.habitType == HabitType.good && _currentHabit!.habitType == HabitType.bad)) {
      _currentHabit = habit;
    }
    await _saveToStorage();
    notifyListeners();

    if (kDebugMode) {
      debugPrint('Added habit: ${habit.name} (${habit.habitTypeDisplay})');
    }
  }

  /// Update an existing habit
  Future<void> updateHabit(Habit updatedHabit) async {
    final index = _habits.indexWhere((h) => h.id == updatedHabit.id);
    if (index != -1) {
      _habits[index] = updatedHabit;
      if (_currentHabit?.id == updatedHabit.id) {
        _currentHabit = updatedHabit;
      }
      await _saveToStorage();
      notifyListeners();
    }
  }

  /// Delete a habit
  Future<void> deleteHabit(String habitId) async {
    _habits.removeWhere((h) => h.id == habitId);
    if (_currentHabit?.id == habitId) {
      _currentHabit = _habits.isNotEmpty ? _habits.first : null;
    }
    await _saveToStorage();
    notifyListeners();
  }

  /// Select a habit as current
  void selectHabit(String habitId) {
    final habit = _habits.firstWhere((h) => h.id == habitId, orElse: () => _habits.first);
    _currentHabit = habit;
    notifyListeners();
  }

  /// Get a habit by ID
  Habit? getHabitById(String habitId) {
    try {
      return _habits.firstWhere((h) => h.id == habitId);
    } catch (e) {
      return null;
    }
  }

  // ========== BAD HABIT METHODS (Change / Reduce Habit Toolkit) ==========

  /// Mark a bad habit as avoided for today
  Future<bool> avoidBadHabitForToday(String habitId) async {
    final habit = getHabitById(habitId);
    if (habit == null || habit.habitType != HabitType.bad) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if already avoided today
    if (habit.lastAvoidedDate != null) {
      final lastAvoided = habit.lastAvoidedDate!;
      final lastDate = DateTime(lastAvoided.year, lastAvoided.month, lastAvoided.day);
      if (lastDate == today) {
        if (kDebugMode) debugPrint('Bad habit already avoided today');
        return false;
      }
    }

    // Calculate new streak (check if yesterday was also avoided)
    int newStreak = habit.currentStreak;
    if (habit.lastAvoidedDate != null) {
      final lastAvoided = habit.lastAvoidedDate!;
      final yesterday = today.subtract(const Duration(days: 1));
      final lastDate = DateTime(lastAvoided.year, lastAvoided.month, lastAvoided.day);
      newStreak = (lastDate == yesterday) ? habit.currentStreak + 1 : 1;
    } else {
      newStreak = 1;
    }

    final updatedHabit = habit.copyWith(
      currentStreak: newStreak,
      avoidedCount: habit.avoidedCount + 1,
      lastAvoidedDate: now,
    );

    await updateHabit(updatedHabit);

    _shouldShowRewardFlow = true;
    notifyListeners();

    if (kDebugMode) {
      debugPrint('Bad habit avoided! Streak: $newStreak, Total avoided: ${updatedHabit.avoidedCount}');
    }
    return true;
  }

  /// Add a cue firewall to a bad habit
  Future<void> addCueFirewall(String habitId, CueFirewall firewall) async {
    final habit = getHabitById(habitId);
    if (habit == null) return;

    final updatedFirewalls = [...habit.cueFirewalls, firewall];
    await updateHabit(habit.copyWith(cueFirewalls: updatedFirewalls));
  }

  /// Remove a cue firewall from a bad habit
  Future<void> removeCueFirewall(String habitId, String firewallId) async {
    final habit = getHabitById(habitId);
    if (habit == null) return;

    final updatedFirewalls = habit.cueFirewalls.where((f) => f.id != firewallId).toList();
    await updateHabit(habit.copyWith(cueFirewalls: updatedFirewalls));
  }

  /// Add a bright-line rule to a bad habit
  Future<void> addBrightLineRule(String habitId, BrightLineRule rule) async {
    final habit = getHabitById(habitId);
    if (habit == null) return;

    final updatedRules = [...habit.brightLineRules, rule];
    await updateHabit(habit.copyWith(brightLineRules: updatedRules));
  }

  /// Remove a bright-line rule
  Future<void> removeBrightLineRule(String habitId, String ruleId) async {
    final habit = getHabitById(habitId);
    if (habit == null) return;

    final updatedRules = habit.brightLineRules.where((r) => r.id != ruleId).toList();
    await updateHabit(habit.copyWith(brightLineRules: updatedRules));
  }

  /// Update substitution behavior for a bad habit
  Future<void> updateSubstitution(String habitId, String substitution, String? underlyingNeed) async {
    final habit = getHabitById(habitId);
    if (habit == null) return;

    await updateHabit(habit.copyWith(
      substitutionBehavior: substitution,
      underlyingNeed: underlyingNeed,
    ));
  }

  /// Update friction settings for a bad habit
  Future<void> updateFriction(String habitId, int steps, String? description) async {
    final habit = getHabitById(habitId);
    if (habit == null) return;

    await updateHabit(habit.copyWith(
      frictionSteps: steps,
      frictionDescription: description,
    ));
  }

  /// Get bad habit suggestions (async)
  Future<Map<String, List<String>>> getBadHabitSuggestions(String habitId) async {
    final habit = getHabitById(habitId);
    if (habit == null || habit.habitType != HabitType.bad) {
      return {'substitution': [], 'cueFirewall': [], 'brightLineRule': [], 'friction': []};
    }

    final results = await Future.wait([
      _aiSuggestionService.getSubstitutionSuggestions(
        badHabitName: habit.name,
        underlyingNeed: habit.underlyingNeed,
      ),
      _aiSuggestionService.getCueFirewallSuggestions(badHabitName: habit.name),
      _aiSuggestionService.getBrightLineRuleSuggestions(badHabitName: habit.name),
      _aiSuggestionService.getFrictionSuggestions(badHabitName: habit.name),
    ]);

    return {
      'substitution': results[0],
      'cueFirewall': results[1],
      'brightLineRule': results[2],
      'friction': results[3],
    };
  }

  // ========== SOCIAL LAYER (Habit Circles) ==========

  /// Create a new habit circle
  Future<void> createHabitCircle(HabitCircle circle) async {
    _habitCircles.add(circle);
    await _saveToStorage();
    notifyListeners();

    if (kDebugMode) {
      debugPrint('Created habit circle: ${circle.name}');
    }
  }

  /// Update a habit circle
  Future<void> updateHabitCircle(HabitCircle updatedCircle) async {
    final index = _habitCircles.indexWhere((c) => c.id == updatedCircle.id);
    if (index != -1) {
      _habitCircles[index] = updatedCircle;
      await _saveToStorage();
      notifyListeners();
    }
  }

  /// Delete a habit circle
  Future<void> deleteHabitCircle(String circleId) async {
    _habitCircles.removeWhere((c) => c.id == circleId);
    // Also remove circle reference from habits
    for (int i = 0; i < _habits.length; i++) {
      if (_habits[i].habitCircleId == circleId) {
        _habits[i] = _habits[i].copyWith(habitCircleId: null);
      }
    }
    await _saveToStorage();
    notifyListeners();
  }

  /// Join a habit to a circle
  Future<void> joinHabitToCircle(String habitId, String circleId) async {
    final habit = getHabitById(habitId);
    if (habit == null) return;

    await updateHabit(habit.copyWith(habitCircleId: circleId));

    // Add habit to circle's shared habits
    final circleIndex = _habitCircles.indexWhere((c) => c.id == circleId);
    if (circleIndex != -1) {
      final circle = _habitCircles[circleIndex];
      if (!circle.sharedHabitIds.contains(habitId)) {
        _habitCircles[circleIndex] = circle.copyWith(
          sharedHabitIds: [...circle.sharedHabitIds, habitId],
        );
        await _saveToStorage();
        notifyListeners();
      }
    }
  }

  /// Add a people cue to a habit
  Future<void> addPeopleCue(String habitId, PeopleCue peopleCue) async {
    final habit = getHabitById(habitId);
    if (habit == null) return;

    final updatedCues = [...habit.peopleCues, peopleCue];
    await updateHabit(habit.copyWith(peopleCues: updatedCues));
  }

  /// Remove a people cue from a habit
  Future<void> removePeopleCue(String habitId, String peopleCueId) async {
    final habit = getHabitById(habitId);
    if (habit == null) return;

    final updatedCues = habit.peopleCues.where((p) => p.id != peopleCueId).toList();
    await updateHabit(habit.copyWith(peopleCues: updatedCues));
  }

  /// Get a habit circle by ID
  HabitCircle? getCircleById(String circleId) {
    try {
      return _habitCircles.firstWhere((c) => c.id == circleId);
    } catch (e) {
      return null;
    }
  }

  // ========== CREATOR MODE ==========

  /// Enable creator mode for a habit
  Future<void> enableCreatorMode(String habitId, {
    int weeklyRepGoal = 10,
    String? repUnit,
    String? workspace,
  }) async {
    final habit = getHabitById(habitId);
    if (habit == null) return;

    await updateHabit(habit.copyWith(
      isCreatorModeEnabled: true,
      weeklyRepGoal: weeklyRepGoal,
      creatorWorkspace: workspace,
    ));
  }

  /// Disable creator mode for a habit
  Future<void> disableCreatorMode(String habitId) async {
    final habit = getHabitById(habitId);
    if (habit == null) return;

    await updateHabit(habit.copyWith(isCreatorModeEnabled: false));
  }

  /// Start a creator session
  Future<CreatorSession> startCreatorSession(String habitId, {
    CreatorSessionType sessionType = CreatorSessionType.generate,
    String? repUnit,
  }) async {
    final session = CreatorSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      habitId: habitId,
      startedAt: DateTime.now(),
      sessionType: sessionType,
      repUnit: repUnit,
      isQuantityMode: sessionType == CreatorSessionType.generate,
    );

    _activeCreatorSession = session;
    _creatorSessions.add(session);
    await _saveToStorage();
    notifyListeners();

    if (kDebugMode) {
      debugPrint('Started creator session: ${session.id} (${sessionType.name})');
    }
    return session;
  }

  /// End the current creator session
  Future<void> endCreatorSession({
    int repsCompleted = 0,
    String? learnings,
    String? blockers,
  }) async {
    if (_activeCreatorSession == null) return;

    final endedSession = _activeCreatorSession!.copyWith(
      endedAt: DateTime.now(),
      repsCompleted: repsCompleted,
      learnings: learnings,
      blockers: blockers,
    );

    // Update in sessions list
    final index = _creatorSessions.indexWhere((s) => s.id == endedSession.id);
    if (index != -1) {
      _creatorSessions[index] = endedSession;
    }

    // Update habit total reps
    final habit = getHabitById(endedSession.habitId);
    if (habit != null) {
      await updateHabit(habit.copyWith(
        totalReps: habit.totalReps + repsCompleted,
      ));
    }

    _activeCreatorSession = null;
    await _saveToStorage();
    notifyListeners();

    if (kDebugMode) {
      debugPrint('Ended creator session: $repsCompleted reps');
    }
  }

  /// Update reps in current session
  Future<void> updateSessionReps(int reps) async {
    if (_activeCreatorSession == null) return;

    _activeCreatorSession = _activeCreatorSession!.copyWith(repsCompleted: reps);
    notifyListeners();
  }

  /// Get creator sessions for a habit
  List<CreatorSession> getSessionsForHabit(String habitId) {
    return _creatorSessions.where((s) => s.habitId == habitId).toList();
  }

  /// Get weekly summary for a creator habit
  CreatorWeeklySummary getWeeklySummary(String habitId) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);

    final weeklySessions = _creatorSessions.where((s) =>
        s.habitId == habitId && s.startedAt.isAfter(weekStartDate)).toList();

    final totalReps = weeklySessions.fold<int>(0, (sum, s) => sum + s.repsCompleted);
    final focusMinutes = weeklySessions.fold<int>(0, (sum, s) => sum + (s.focusMinutes ?? 0));
    final learnings = weeklySessions
        .where((s) => s.learnings != null && s.learnings!.isNotEmpty)
        .map((s) => s.learnings!)
        .toList();

    final habit = getHabitById(habitId);
    final goalProgress = habit != null && habit.weeklyRepGoal > 0
        ? totalReps / habit.weeklyRepGoal
        : 0.0;

    return CreatorWeeklySummary(
      habitId: habitId,
      weekStart: weekStartDate,
      totalReps: totalReps,
      sessionsCompleted: weeklySessions.length,
      focusMinutes: focusMinutes,
      learnings: learnings,
      weeklyGoalProgress: goalProgress,
    );
  }
}
