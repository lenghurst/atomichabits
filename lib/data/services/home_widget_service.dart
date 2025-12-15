import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../models/habit.dart';
import '../models/consistency_metrics.dart';

/// Service for managing Home Screen Widget data synchronization
/// 
/// **Phase 9: Home Screen Widgets**
/// This service handles:
/// - Saving habit data to shared storage (accessible by native widgets)
/// - Triggering widget updates when habit state changes
/// - Processing widget tap callbacks for habit completion
/// - Managing widget configuration state
/// 
/// **Architecture:**
/// ```
/// Flutter App ←→ HomeWidgetService ←→ SharedPreferences ←→ Native Widget
///                                            ↑
///                                     (iOS: App Group)
///                                     (Android: SharedPreferences)
/// ```
class HomeWidgetService {
  // Widget identifiers (must match native widget class names)
  static const String androidWidgetName = 'HabitWidgetProvider';
  static const String iosWidgetName = 'HabitWidget';
  
  // App Group ID for iOS (must match Xcode configuration)
  static const String appGroupId = 'group.com.atomichabits.hook.widget';
  
  // Shared data keys (used by both Flutter and native code)
  static const String keyHabitId = 'habit_id';
  static const String keyHabitName = 'habit_name';
  static const String keyHabitEmoji = 'habit_emoji';
  static const String keyIdentity = 'identity';
  static const String keyIsCompleted = 'is_completed_today';
  static const String keyCurrentStreak = 'current_streak';
  static const String keyGracefulScore = 'graceful_score';
  static const String keyTinyVersion = 'tiny_version';
  static const String keyLastUpdate = 'last_update';
  
  // Callback URI scheme
  static const String uriScheme = 'atomichabits';
  static const String completeHabitAction = 'complete_habit';
  
  /// Initialize the home widget service
  /// Call this once at app startup
  Future<void> initialize() async {
    try {
      // Set the App Group ID for iOS
      await HomeWidget.setAppGroupId(appGroupId);
      
      // Register the interactivity callback for widget taps
      await HomeWidget.registerInteractivityCallback(backgroundCallback);
      
      if (kDebugMode) {
        debugPrint('HomeWidgetService initialized with appGroupId: $appGroupId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error initializing HomeWidgetService: $e');
      }
    }
  }
  
  /// Update widget with habit data
  /// Call this whenever habit state changes (completion, new day, etc.)
  Future<void> updateWidgetData({
    required Habit habit,
    required bool isCompletedToday,
  }) async {
    try {
      // Calculate metrics
      final metrics = habit.consistencyMetrics;
      
      // Save all data to shared storage
      await Future.wait([
        HomeWidget.saveWidgetData<String>(keyHabitId, habit.id),
        HomeWidget.saveWidgetData<String>(keyHabitName, habit.name),
        HomeWidget.saveWidgetData<String>(keyHabitEmoji, habit.habitEmoji ?? ''),
        HomeWidget.saveWidgetData<String>(keyIdentity, habit.identity),
        HomeWidget.saveWidgetData<bool>(keyIsCompleted, isCompletedToday),
        HomeWidget.saveWidgetData<int>(keyCurrentStreak, habit.currentStreak),
        HomeWidget.saveWidgetData<double>(keyGracefulScore, metrics.gracefulScore),
        HomeWidget.saveWidgetData<String>(keyTinyVersion, habit.tinyVersion),
        HomeWidget.saveWidgetData<String>(keyLastUpdate, DateTime.now().toIso8601String()),
      ]);
      
      // Trigger widget refresh on both platforms
      await _refreshWidgets();
      
      if (kDebugMode) {
        debugPrint('Widget updated for habit: ${habit.name} (completed: $isCompletedToday)');
        debugPrint('  Streak: ${habit.currentStreak}, Score: ${metrics.gracefulScore.toStringAsFixed(1)}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating widget data: $e');
      }
    }
  }
  
  /// Clear widget data (when habit is deleted or user logs out)
  Future<void> clearWidgetData() async {
    try {
      await Future.wait([
        HomeWidget.saveWidgetData<String?>(keyHabitId, null),
        HomeWidget.saveWidgetData<String?>(keyHabitName, null),
        HomeWidget.saveWidgetData<String?>(keyHabitEmoji, null),
        HomeWidget.saveWidgetData<String?>(keyIdentity, null),
        HomeWidget.saveWidgetData<bool?>(keyIsCompleted, null),
        HomeWidget.saveWidgetData<int?>(keyCurrentStreak, null),
        HomeWidget.saveWidgetData<double?>(keyGracefulScore, null),
        HomeWidget.saveWidgetData<String?>(keyTinyVersion, null),
        HomeWidget.saveWidgetData<String?>(keyLastUpdate, null),
      ]);
      
      await _refreshWidgets();
      
      if (kDebugMode) {
        debugPrint('Widget data cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error clearing widget data: $e');
      }
    }
  }
  
  /// Refresh widgets on both platforms
  Future<void> _refreshWidgets() async {
    try {
      // Update Android widget
      await HomeWidget.updateWidget(
        name: androidWidgetName,
        androidName: androidWidgetName,
        qualifiedAndroidName: 'com.example.atomic_habits_hook_app.$androidWidgetName',
      );
      
      // Update iOS widget
      await HomeWidget.updateWidget(
        name: iosWidgetName,
        iOSName: iosWidgetName,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error refreshing widgets: $e');
      }
    }
  }
  
  /// Get the initial URI if app was launched from widget
  /// Returns the habit ID if launched from complete action, null otherwise
  Future<String?> getInitialLaunchData() async {
    try {
      final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
      if (uri != null) {
        return _parseHabitIdFromUri(uri);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting initial launch data: $e');
      }
    }
    return null;
  }
  
  /// Listen for widget click events while app is running
  Stream<Uri?> get widgetClicks => HomeWidget.widgetClicked;
  
  /// Parse habit ID from widget callback URI
  /// URI format: atomichabits://complete_habit?id=<habit_id>
  String? _parseHabitIdFromUri(Uri uri) {
    if (uri.scheme == uriScheme && uri.host == completeHabitAction) {
      return uri.queryParameters['id'];
    }
    return null;
  }
  
  /// Check if a URI is a complete habit action
  bool isCompleteHabitAction(Uri? uri) {
    if (uri == null) return false;
    return uri.scheme == uriScheme && uri.host == completeHabitAction;
  }
  
  /// Get habit ID from widget tap URI
  String? getHabitIdFromUri(Uri? uri) {
    if (uri == null) return null;
    return _parseHabitIdFromUri(uri);
  }
  
  /// Request to pin widget to home screen (Android only)
  /// Returns true if the request was successful
  Future<bool> requestPinWidget() async {
    try {
      final result = await HomeWidget.requestPinWidget(
        name: androidWidgetName,
        androidName: androidWidgetName,
        qualifiedAndroidName: 'com.example.atomic_habits_hook_app.$androidWidgetName',
      );
      return result ?? false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error requesting pin widget: $e');
      }
      return false;
    }
  }
  
  /// Get information about currently installed widgets
  Future<int> getInstalledWidgetCount() async {
    try {
      final widgets = await HomeWidget.getInstalledWidgets();
      return widgets?.length ?? 0;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting installed widgets: $e');
      }
      return 0;
    }
  }
}

/// Background callback for widget interactivity
/// This is called when user taps the complete button on the widget
/// 
/// IMPORTANT: This function must be top-level (not inside a class)
/// and annotated with @pragma('vm:entry-point')
@pragma('vm:entry-point')
Future<void> backgroundCallback(Uri? uri) async {
  if (kDebugMode) {
    debugPrint('Widget background callback received: $uri');
  }
  
  if (uri == null) return;
  
  // Check if this is a complete habit action
  if (uri.scheme == HomeWidgetService.uriScheme && 
      uri.host == HomeWidgetService.completeHabitAction) {
    final habitId = uri.queryParameters['id'];
    
    if (habitId != null) {
      // Mark habit as completed
      // Note: In background mode, we need to update the widget data directly
      // The actual habit completion will be synced when the app opens
      await HomeWidget.saveWidgetData<bool>(HomeWidgetService.keyIsCompleted, true);
      await HomeWidget.saveWidgetData<String>('pending_completion_id', habitId);
      await HomeWidget.saveWidgetData<String>('pending_completion_time', DateTime.now().toIso8601String());
      
      // Refresh the widget to show completed state
      await HomeWidget.updateWidget(
        name: HomeWidgetService.androidWidgetName,
        androidName: HomeWidgetService.androidWidgetName,
      );
      await HomeWidget.updateWidget(
        name: HomeWidgetService.iosWidgetName,
        iOSName: HomeWidgetService.iosWidgetName,
      );
      
      if (kDebugMode) {
        debugPrint('Habit $habitId marked for completion from widget');
      }
    }
  }
}

/// Widget data model for easier data transfer
class HomeWidgetData {
  final String? habitId;
  final String? habitName;
  final String? habitEmoji;
  final String? identity;
  final bool isCompletedToday;
  final int currentStreak;
  final double gracefulScore;
  final String? tinyVersion;
  final DateTime? lastUpdate;
  
  HomeWidgetData({
    this.habitId,
    this.habitName,
    this.habitEmoji,
    this.identity,
    this.isCompletedToday = false,
    this.currentStreak = 0,
    this.gracefulScore = 0,
    this.tinyVersion,
    this.lastUpdate,
  });
  
  /// Create from stored widget data
  static Future<HomeWidgetData> load() async {
    try {
      final habitId = await HomeWidget.getWidgetData<String>(HomeWidgetService.keyHabitId);
      final habitName = await HomeWidget.getWidgetData<String>(HomeWidgetService.keyHabitName);
      final habitEmoji = await HomeWidget.getWidgetData<String>(HomeWidgetService.keyHabitEmoji);
      final identity = await HomeWidget.getWidgetData<String>(HomeWidgetService.keyIdentity);
      final isCompleted = await HomeWidget.getWidgetData<bool>(HomeWidgetService.keyIsCompleted);
      final streak = await HomeWidget.getWidgetData<int>(HomeWidgetService.keyCurrentStreak);
      final score = await HomeWidget.getWidgetData<double>(HomeWidgetService.keyGracefulScore);
      final tinyVersion = await HomeWidget.getWidgetData<String>(HomeWidgetService.keyTinyVersion);
      final lastUpdateStr = await HomeWidget.getWidgetData<String>(HomeWidgetService.keyLastUpdate);
      
      return HomeWidgetData(
        habitId: habitId,
        habitName: habitName,
        habitEmoji: habitEmoji,
        identity: identity,
        isCompletedToday: isCompleted ?? false,
        currentStreak: streak ?? 0,
        gracefulScore: score ?? 0,
        tinyVersion: tinyVersion,
        lastUpdate: lastUpdateStr != null ? DateTime.tryParse(lastUpdateStr) : null,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading widget data: $e');
      }
      return HomeWidgetData();
    }
  }
  
  /// Check if there's a pending completion from widget tap
  static Future<String?> getPendingCompletionId() async {
    try {
      return await HomeWidget.getWidgetData<String>('pending_completion_id');
    } catch (e) {
      return null;
    }
  }
  
  /// Clear pending completion after it's been processed
  static Future<void> clearPendingCompletion() async {
    try {
      await HomeWidget.saveWidgetData<String?>('pending_completion_id', null);
      await HomeWidget.saveWidgetData<String?>('pending_completion_time', null);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error clearing pending completion: $e');
      }
    }
  }
}
