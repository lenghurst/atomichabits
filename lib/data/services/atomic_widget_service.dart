import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';

/// Service for managing the Android Home Screen Widget
///
/// **Philosophy: Make it Obvious (Law #1)**
/// The widget provides a persistent visual cue on the user's home screen,
/// making the habit trigger obvious and accessible.
///
/// **Widget/App Sync Architecture:**
/// - Widget updates Hive directly in background isolate
/// - App detects changes via Resume Sync Strategy on foreground
/// - This service handles both directions of sync
///
/// **Data Keys (shared with Android widget):**
/// - `habit_name`: Display name of the focus habit
/// - `habit_streak`: Current streak count
/// - `habit_completed`: Whether completed today (true/false)
/// - `habit_tiny_version`: The 2-minute version reminder
/// - `habit_id`: Unique ID for verification
class AtomicWidgetService {
  static const String _appGroupId = 'group.com.atomichabits.widget';
  static const String _androidWidgetName = 'AtomicWidgetProvider';

  // Data keys for widget
  static const String keyHabitName = 'habit_name';
  static const String keyHabitStreak = 'habit_streak';
  static const String keyHabitCompleted = 'habit_completed';
  static const String keyHabitTinyVersion = 'habit_tiny_version';
  static const String keyHabitId = 'habit_id';

  /// Initialize the widget service
  /// Call once at app startup (in main.dart or AppState.initialize)
  static Future<void> initialize() async {
    try {
      // Set the app group for iOS (Android doesn't need this)
      await HomeWidget.setAppGroupId(_appGroupId);

      // Register the background callback for widget taps
      await HomeWidget.registerInteractivityCallback(backgroundCallback);

      if (kDebugMode) {
        debugPrint('📱 AtomicWidgetService initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ AtomicWidgetService initialization error: $e');
      }
    }
  }

  /// Update the widget with current habit data
  ///
  /// Call this after:
  /// - Habit completion
  /// - Habit data changes
  /// - App comes to foreground (after sync)
  static Future<void> updateWidget({
    required String habitId,
    required String habitName,
    required int streak,
    required bool completedToday,
    String? tinyVersion,
  }) async {
    try {
      // Save data that the widget will read
      await HomeWidget.saveWidgetData<String>(keyHabitId, habitId);
      await HomeWidget.saveWidgetData<String>(keyHabitName, habitName);
      await HomeWidget.saveWidgetData<int>(keyHabitStreak, streak);
      await HomeWidget.saveWidgetData<bool>(keyHabitCompleted, completedToday);

      if (tinyVersion != null && tinyVersion.isNotEmpty) {
        await HomeWidget.saveWidgetData<String>(keyHabitTinyVersion, tinyVersion);
      }

      // Trigger widget to refresh its UI
      await HomeWidget.updateWidget(
        androidName: _androidWidgetName,
        qualifiedAndroidName: 'es.antonborri.home_widget.HomeWidgetProvider',
      );

      if (kDebugMode) {
        debugPrint('📱 Widget updated: $habitName (streak: $streak, done: $completedToday)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to update widget: $e');
      }
    }
  }

  /// Update widget to show empty state (no habit set)
  static Future<void> showEmptyState() async {
    try {
      await HomeWidget.saveWidgetData<String>(keyHabitId, '');
      await HomeWidget.saveWidgetData<String>(keyHabitName, 'No habit set');
      await HomeWidget.saveWidgetData<int>(keyHabitStreak, 0);
      await HomeWidget.saveWidgetData<bool>(keyHabitCompleted, false);
      await HomeWidget.saveWidgetData<String>(keyHabitTinyVersion, 'Tap to set up');

      await HomeWidget.updateWidget(
        androidName: _androidWidgetName,
        qualifiedAndroidName: 'es.antonborri.home_widget.HomeWidgetProvider',
      );

      if (kDebugMode) {
        debugPrint('📱 Widget showing empty state');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to show empty state: $e');
      }
    }
  }

  /// Get the URI that was clicked (if app was launched from widget)
  static Future<Uri?> getInitialUri() async {
    try {
      return await HomeWidget.initiallyLaunchedFromHomeWidget();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to get initial URI: $e');
      }
      return null;
    }
  }

  /// Listen for widget click events while app is running
  static Stream<Uri?> get widgetClicked => HomeWidget.widgetClicked;
}

/// Background callback for widget tap actions
///
/// **CRITICAL: This runs in a separate isolate!**
/// - Cannot access AppState or Provider
/// - Must use Hive directly for persistence
/// - App will reconcile with this data on resume (Resume Sync Strategy)
///
/// @pragma('vm:entry-point') is required for release builds
@pragma('vm:entry-point')
Future<void> backgroundCallback(Uri? uri) async {
  if (uri == null) return;

  if (kDebugMode) {
    debugPrint('📱 Widget background callback: $uri');
  }

  // Handle completion action from widget tap
  if (uri.host == 'complete') {
    await _handleWidgetCompletion();
  }
}

/// Handle habit completion from widget tap
///
/// Runs in background isolate - updates Hive directly.
/// App will sync with this data when it resumes (Resume Sync Strategy).
Future<void> _handleWidgetCompletion() async {
  try {
    // Initialize Hive in background isolate
    await Hive.initFlutter();

    // Open the same box the app uses
    final box = await Hive.openBox('habit_data');

    // Load current habit data
    final habitJson = box.get('currentHabit');
    if (habitJson == null) {
      if (kDebugMode) {
        debugPrint('⚠️ Widget: No habit data found');
      }
      return;
    }

    final habit = Habit.fromJson(Map<String, dynamic>.from(habitJson));

    // Check if already completed today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (habit.lastCompletedDate != null) {
      final lastCompleted = habit.lastCompletedDate!;
      final lastDate = DateTime(
        lastCompleted.year,
        lastCompleted.month,
        lastCompleted.day,
      );

      if (lastDate == today) {
        if (kDebugMode) {
          debugPrint('📱 Widget: Already completed today');
        }
        return;
      }
    }

    // Calculate new streak
    int newStreak = habit.currentStreak;
    if (habit.lastCompletedDate != null) {
      final lastCompleted = habit.lastCompletedDate!;
      final yesterday = today.subtract(const Duration(days: 1));
      final lastDate = DateTime(
        lastCompleted.year,
        lastCompleted.month,
        lastCompleted.day,
      );

      if (lastDate == yesterday) {
        newStreak = habit.currentStreak + 1;
      } else {
        newStreak = 1; // Graceful recovery - start new streak
      }
    } else {
      newStreak = 1;
    }

    // Update completion history
    final newCompletionHistory = List<DateTime>.from(habit.completionHistory)
      ..add(now);

    // Create updated habit
    final updatedHabit = habit.copyWith(
      currentStreak: newStreak,
      lastCompletedDate: now,
      completionHistory: newCompletionHistory,
      identityVotes: habit.identityVotes + 1,
      daysShowedUp: habit.daysShowedUp + 1,
      longestStreak:
          newStreak > habit.longestStreak ? newStreak : habit.longestStreak,
    );

    // Save to Hive (App will sync with this on resume)
    await box.put('currentHabit', updatedHabit.toJson());

    // Update widget display
    await AtomicWidgetService.updateWidget(
      habitId: updatedHabit.id,
      habitName: updatedHabit.name,
      streak: updatedHabit.currentStreak,
      completedToday: true,
      tinyVersion: updatedHabit.tinyVersion,
    );

    if (kDebugMode) {
      debugPrint('📱 Widget: Habit completed! New streak: $newStreak');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('⚠️ Widget completion error: $e');
    }
  }
}
