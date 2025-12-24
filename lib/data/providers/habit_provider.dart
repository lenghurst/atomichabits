import 'package:flutter/foundation.dart';
import '../models/habit.dart';
import '../models/user_profile.dart';
import '../models/completion_result.dart';
import '../repositories/habit_repository.dart';
import '../notification_service.dart';
import '../ai_suggestion_service.dart';
import '../services/recovery_engine.dart';
import '../services/home_widget_service.dart';

/// HabitProvider: Manages the core domain—Habits, Stacking, Recovery, and Widget integration.
/// 
/// Decoupled from Hive via HabitRepository injection.
/// Uses updateUserProfile() for safe dependency injection from UserProvider.
/// Satisfies: Atlas (DI), Uncle Bob (DIP), Flux (Specific Scope).
class HabitProvider extends ChangeNotifier {
  final HabitRepository _repository;
  final NotificationService _notificationService;
  
  // Services (can be injected for testing)
  final AiSuggestionService _aiSuggestionService = AiSuggestionService();
  final HomeWidgetService _homeWidgetService = HomeWidgetService();

  // === State ===
  List<Habit> _habits = [];
  String? _focusedHabitId;
  bool _isLoading = true;
  
  // UI State (separated per Flux's recommendation)
  bool _shouldShowRewardFlow = false;
  
  // Recovery / Never Miss Twice
  RecoveryNeed? _currentRecoveryNeed;
  bool _shouldShowRecoveryPrompt = false;
  
  // Cached dependency (injected via updateUserProfile)
  UserProfile? _cachedUserProfile;

  HabitProvider(this._repository, this._notificationService);

  // === Getters ===
  List<Habit> get habits => List.unmodifiable(_habits);
  int get habitCount => _habits.length;
  bool get hasHabits => _habits.isNotEmpty;
  bool get isLoading => _isLoading;
  bool get shouldShowRewardFlow => _shouldShowRewardFlow;
  RecoveryNeed? get currentRecoveryNeed => _currentRecoveryNeed;
  bool get shouldShowRecoveryPrompt => _shouldShowRecoveryPrompt;
  HomeWidgetService get homeWidgetService => _homeWidgetService;
  Stream<Uri?> get widgetClickStream => _homeWidgetService.widgetClicks;

  // === Initialization ===

  /// Initialize the provider by loading from repository
  Future<void> initialize() async {
    try {
      await _notificationService.initialize();
      _notificationService.onNotificationAction = _handleNotificationAction;
      await _homeWidgetService.initialize();
      
      _habits = await _repository.getAll();
      _focusedHabitId = await _repository.getFocusedHabitId();
      
      // Initial checks
      _processPendingWidgetCompletion();
      _updateHomeWidget();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('HabitProvider: Error initializing: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates the cached user profile. 
  /// Called by ProxyProvider when UserProvider updates.
  /// This is the safe dependency injection pattern recommended by Atlas.
  void updateUserProfile(UserProfile? profile) {
    _cachedUserProfile = profile;
    
    // If we have habits and a profile, ensure notifications are scheduled/consistent
    if (profile != null && hasHabits) {
      _checkRecoveryNeeds();
      _scheduleNotifications();
    }
  }

  // === Habit Accessors ===

  /// Get the currently focused/primary habit
  Habit? get currentHabit {
    if (_habits.isEmpty) return null;
    if (_focusedHabitId != null) {
      final focused = _habits.where((h) => h.id == _focusedHabitId).firstOrNull;
      if (focused != null) return focused;
    }
    return _habits.where((h) => h.isPrimaryHabit).firstOrNull ?? _habits.first;
  }

  Habit? getHabitById(String id) => _habits.where((h) => h.id == id).firstOrNull;
  
  List<Habit> getStackedHabits(String parentHabitId) {
    return _habits.where((h) => h.anchorHabitId == parentHabitId).toList();
  }

  Habit? getNextStackedHabit(String parentHabitId) {
    final stackedHabits = _habits.where((h) => 
      h.anchorHabitId == parentHabitId &&
      h.stackPosition == 'after' &&
      !h.isCompletedToday &&
      !h.isPaused
    ).toList();
    return stackedHabits.isEmpty ? null : stackedHabits.first;
  }

  // === CRUD Operations ===

  Future<void> createHabit(Habit habit) async {
    final isFirst = _habits.isEmpty;
    Habit habitToAdd = habit;
    
    if (isFirst) {
      habitToAdd = habit.copyWith(
        isPrimaryHabit: true,
        focusCycleStart: habit.focusCycleStart ?? DateTime.now(),
      );
    } else if (habit.isPrimaryHabit) {
      _habits = _habits.map((h) => h.copyWith(isPrimaryHabit: false)).toList();
    }
    
    _habits.add(habitToAdd);
    _focusedHabitId = habitToAdd.id;
    await _repository.saveAll(_habits);
    await _repository.setFocusedHabitId(_focusedHabitId);
    await _updateHomeWidget();
    notifyListeners();
  }

  Future<void> updateHabit(Habit updatedHabit) async {
    final index = _habits.indexWhere((h) => h.id == updatedHabit.id);
    if (index == -1) return;
    
    if (updatedHabit.isPrimaryHabit && !_habits[index].isPrimaryHabit) {
      _habits = _habits.map((h) => h.copyWith(isPrimaryHabit: false)).toList();
    }
    
    _habits[index] = updatedHabit;
    await _repository.saveAll(_habits);
    notifyListeners();
  }

  Future<void> deleteHabit(String habitId) async {
    final habitToDelete = _habits.where((h) => h.id == habitId).firstOrNull;
    if (habitToDelete == null) return;
    
    final wasFocused = _focusedHabitId == habitId;
    final wasPrimary = habitToDelete.isPrimaryHabit;
    
    _habits.removeWhere((h) => h.id == habitId);
    
    if (wasFocused) _focusedHabitId = null;
    
    if (wasPrimary && _habits.isNotEmpty) {
      _habits[0] = _habits[0].copyWith(
        isPrimaryHabit: true,
        focusCycleStart: _habits[0].focusCycleStart ?? DateTime.now(),
      );
    }
    
    await _repository.saveAll(_habits);
    await _repository.setFocusedHabitId(_focusedHabitId);
    _currentRecoveryNeed = null;
    _shouldShowRecoveryPrompt = false;
    await _updateHomeWidget();
    notifyListeners();
  }

  Future<void> setFocusHabit(String habitId) async {
    if (!_habits.any((h) => h.id == habitId)) return;
    _focusedHabitId = habitId;
    await _repository.setFocusedHabitId(_focusedHabitId);
    _checkRecoveryNeeds();
    await _updateHomeWidget();
    notifyListeners();
  }

  // === Completion Logic ===

  Future<CompletionResult> completeHabitForToday({
    String? habitId,
    bool fromNotification = false,
    bool usedTinyVersion = false,
  }) async {
    final targetId = habitId ?? currentHabit?.id;
    if (targetId == null) return CompletionResult.noHabit();
    
    final habitIndex = _habits.indexWhere((h) => h.id == targetId);
    if (habitIndex == -1) return CompletionResult.noHabit();
    
    final habit = _habits[habitIndex];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (habit.lastCompletedDate != null) {
      final lastDate = DateTime(
        habit.lastCompletedDate!.year,
        habit.lastCompletedDate!.month,
        habit.lastCompletedDate!.day,
      );
      if (lastDate == today) {
        return CompletionResult.alreadyCompleted(habit.id, habit.name);
      }
    }

    // Streak calculation logic
    int newStreak = habit.currentStreak;
    bool isRecovery = false;
    int daysMissed = 0;
    DateTime? missStartDate;
    
    if (habit.lastCompletedDate != null) {
      final lastDate = DateTime(habit.lastCompletedDate!.year, habit.lastCompletedDate!.month, habit.lastCompletedDate!.day);
      final yesterday = today.subtract(const Duration(days: 1));
      
      if (lastDate == yesterday) {
        newStreak++;
      } else {
        newStreak = 1;
        isRecovery = true;
        daysMissed = today.difference(lastDate).inDays - 1;
        missStartDate = lastDate.add(const Duration(days: 1));
      }
    } else {
      newStreak = 1;
    }
    
    // Update histories
    final newCompletionHistory = List<DateTime>.from(habit.completionHistory)..add(now);
    final newRecoveryHistory = List<RecoveryEvent>.from(habit.recoveryHistory);
    int newSingleMissRecoveries = habit.singleMissRecoveries;
    
    if (isRecovery && missStartDate != null) {
      newRecoveryHistory.add(RecoveryEvent(
        missDate: missStartDate,
        recoveryDate: now,
        daysMissed: daysMissed,
        missReason: habit.lastMissReason,
        usedTinyVersion: usedTinyVersion,
      ));
      if (daysMissed == 1) newSingleMissRecoveries++;
    }
    
    // Update habit object
    _habits[habitIndex] = habit.copyWith(
      currentStreak: newStreak,
      lastCompletedDate: now,
      completionHistory: newCompletionHistory,
      recoveryHistory: newRecoveryHistory,
      identityVotes: habit.identityVotes + 1,
      longestStreak: newStreak > habit.longestStreak ? newStreak : habit.longestStreak,
      lastMissReason: null,
      daysShowedUp: habit.daysShowedUp + 1,
      singleMissRecoveries: newSingleMissRecoveries,
    );
    
    await _repository.saveAll(_habits);
    
    _currentRecoveryNeed = null;
    _shouldShowRecoveryPrompt = false;
    _shouldShowRewardFlow = true;
    
    await _updateHomeWidget();
    notifyListeners();
    
    final nextStackedHabit = getNextStackedHabit(habit.id);
    
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

  bool isHabitCompletedToday({String? habitId}) {
    final habit = habitId != null ? getHabitById(habitId) : currentHabit;
    if (habit?.lastCompletedDate == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(habit!.lastCompletedDate!.year, habit.lastCompletedDate!.month, habit.lastCompletedDate!.day);

    return lastDate == today;
  }

  // === Notifications & Widgets ===

  Future<void> _scheduleNotifications() async {
    if (currentHabit == null || _cachedUserProfile == null) return;
    await _notificationService.scheduleDailyHabitReminder(
      habit: currentHabit!,
      profile: _cachedUserProfile!,
    );
  }

  void _handleNotificationAction(String action) {
    if (action == 'mark_done') {
      completeHabitForToday(fromNotification: true);
    } else if (action == 'snooze' && currentHabit != null && _cachedUserProfile != null) {
      _notificationService.scheduleSnoozeNotification(
        habit: currentHabit!,
        profile: _cachedUserProfile!,
      );
    }
  }

  Future<void> _updateHomeWidget() async {
    if (currentHabit == null) {
      await _homeWidgetService.clearWidgetData();
    } else {
      await _homeWidgetService.updateWidgetData(
        habit: currentHabit!,
        isCompletedToday: isHabitCompletedToday(),
      );
    }
  }

  Future<void> _processPendingWidgetCompletion() async {
    final pendingHabitId = await HomeWidgetData.getPendingCompletionId();
    if (pendingHabitId != null) {
      await completeHabitForToday(habitId: pendingHabitId);
      await HomeWidgetData.clearPendingCompletion();
    }
  }

  Future<bool> handleWidgetUri(Uri? uri) async {
    if (uri == null) return false;
    if (_homeWidgetService.isCompleteHabitAction(uri)) {
      final habitId = _homeWidgetService.getHabitIdFromUri(uri);
      if (habitId != null) {
        final result = await completeHabitForToday(habitId: habitId);
        return result.wasNewCompletion;
      }
    }
    return false;
  }

  // === Recovery & UI State ===

  void _checkRecoveryNeeds() {
    if (currentHabit == null || _cachedUserProfile == null) {
      _currentRecoveryNeed = null;
      _shouldShowRecoveryPrompt = false;
      return;
    }
    _currentRecoveryNeed = RecoveryEngine.checkRecoveryNeed(
      habit: currentHabit!,
      profile: _cachedUserProfile!,
      completionHistory: currentHabit!.completionHistory,
    );
    _shouldShowRecoveryPrompt = _currentRecoveryNeed != null;
  }

  void dismissRewardFlow() {
    _shouldShowRewardFlow = false;
    notifyListeners();
  }

  void dismissRecoveryPrompt() {
    _shouldShowRecoveryPrompt = false;
    notifyListeners();
  }
  
  // === AI Suggestions (Proxied) ===
  
  Future<List<String>> getTemptationBundleSuggestionsForCurrentHabit() async {
    if (currentHabit == null || _cachedUserProfile == null) return [];
    return await _aiSuggestionService.getTemptationBundleSuggestions(
      identity: _cachedUserProfile!.identity,
      habitName: currentHabit!.name,
      tinyVersion: currentHabit!.tinyVersion,
      implementationTime: currentHabit!.implementationTime,
      implementationLocation: currentHabit!.implementationLocation,
      existingTemptationBundle: currentHabit!.temptationBundle,
      existingPreRitual: currentHabit!.preHabitRitual,
      existingEnvironmentCue: currentHabit!.environmentCue,
      existingEnvironmentDistraction: currentHabit!.environmentDistraction,
    );
  }
  
  /// Clear all habit data
  Future<void> clearAllData() async {
    await _repository.clear();
    _habits = [];
    _focusedHabitId = null;
    await _notificationService.cancelAllNotifications();
    notifyListeners();
  }

  /// Reload data from storage
  Future<void> reloadFromStorage() async {
    _isLoading = true;
    notifyListeners();
    _habits = await _repository.getAll();
    _focusedHabitId = await _repository.getFocusedHabitId();
    _checkRecoveryNeeds();
    await _updateHomeWidget();
    _isLoading = false;
    notifyListeners();
  }
}
