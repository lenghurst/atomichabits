import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'models/habit.dart';
import 'models/user_profile.dart';
import 'notification_ids.dart';

/// Notification Service for Daily Habit Reminders
/// Implements the "Trigger" part of Nir Eyal's Hook Model
/// 
/// Key Features:
/// - Daily scheduled notifications at user's chosen time
/// - Action buttons: "Mark Done" and "Snooze 30 mins"
/// - Handles both Android and Web (gracefully degrades on web)
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // Callback for when notification actions are tapped
  Function(String action)? onNotificationAction;

  // Callback for when notification body is tapped (for navigation)
  Function()? onNotificationTap;

  /// Initialize notification system
  /// Called once when app starts in main.dart
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize timezone data for scheduled notifications
      tz.initializeTimeZones();
      
      // Find local timezone (defaults to UTC if not found)
      final String timeZoneName = 'UTC'; // You can make this dynamic later
      tz.setLocalLocation(tz.getLocation(timeZoneName));

      // Android initialization settings
      const AndroidInitializationSettings androidSettings = 
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings (for future iOS support)
      const DarwinInitializationSettings iosSettings = 
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Combined initialization settings
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize with callback for notification taps
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request permissions (required for Android 13+)
      await _requestPermissions();

      _initialized = true;
      
      if (kDebugMode) {
        debugPrint('✅ NotificationService initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ NotificationService initialization error: $e');
        debugPrint('Notifications may not work (common on web platform)');
      }
      // Don't throw - allow app to continue without notifications
    }
  }

  /// Request notification permissions (Android 13+)
  Future<void> _requestPermissions() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Permission request not available on this platform');
      }
    }
  }

  /// Handle notification tap (when user interacts with notification)
  void _onNotificationTapped(NotificationResponse response) {
    final String? payload = response.payload;

    if (kDebugMode) {
      debugPrint('📱 Notification tapped - Action: ${response.actionId}, Payload: $payload');
    }

    // Handle action button presses
    if (response.actionId != null) {
      onNotificationAction?.call(response.actionId!);
    } else {
      // Notification body was tapped (not an action button) - navigate to Today screen
      onNotificationTap?.call();
    }
  }

  /// Schedule daily notification for habit
  /// Called after onboarding and when reminder time changes
  Future<void> scheduleDailyHabitReminder({
    required Habit habit,
    required UserProfile profile,
  }) async {
    if (!_initialized) {
      if (kDebugMode) {
        debugPrint('⚠️ Cannot schedule notification - service not initialized');
      }
      return;
    }

    try {
      // Cancel any existing notifications first
      await cancelAllNotifications();

      // Parse implementation time (format: "HH:MM")
      final timeParts = habit.implementationTime.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // Create scheduled time
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If scheduled time is in the past today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Notification details
      final androidDetails = AndroidNotificationDetails(
        'habit_reminders', // Channel ID
        'Habit Reminders', // Channel name
        channelDescription: 'Daily reminders for your habits',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'Time for your habit!',
        // Action buttons
        actions: <AndroidNotificationAction>[
          const AndroidNotificationAction(
            'mark_done',
            'Mark Done',
            showsUserInterface: true,
            cancelNotification: true,
          ),
          const AndroidNotificationAction(
            'snooze',
            'Snooze 30 mins',
            showsUserInterface: false,
            cancelNotification: true,
          ),
        ],
      );

      final notificationDetails = NotificationDetails(android: androidDetails);

      // Build identity-aligned notification text (calm, supportive, British English)
      final String notificationTitle = 'Your tiny proof for today';
      final String notificationBody = _buildDailyReminderBody(profile, habit);

      // Schedule repeating daily notification
      await _notifications.zonedSchedule(
        NotificationIds.dailyReminder,
        notificationTitle,
        notificationBody,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily at same time
        payload: habit.id, // Pass habit ID for reference
      );

      if (kDebugMode) {
        debugPrint('✅ Daily notification scheduled for ${habit.implementationTime}');
        debugPrint('   Next notification: $scheduledDate');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to schedule notification: $e');
      }
    }
  }

  /// Schedule one-time snooze notification (30 minutes from now)
  /// Called when user taps "Snooze 30 mins" action
  Future<void> scheduleSnoozeNotification({
    required Habit habit,
    required UserProfile profile,
  }) async {
    if (!_initialized) return;

    try {
      final snoozeTime = tz.TZDateTime.now(tz.local).add(const Duration(minutes: 30));

      final androidDetails = AndroidNotificationDetails(
        'habit_reminders',
        'Habit Reminders',
        channelDescription: 'Daily reminders for your habits',
        importance: Importance.high,
        priority: Priority.high,
        // Same action buttons as daily notification
        actions: <AndroidNotificationAction>[
          const AndroidNotificationAction(
            'mark_done',
            'Mark Done',
            showsUserInterface: true,
            cancelNotification: true,
          ),
          const AndroidNotificationAction(
            'snooze',
            'Snooze 30 mins',
            showsUserInterface: false,
            cancelNotification: true,
          ),
        ],
      );

      final notificationDetails = NotificationDetails(android: androidDetails);

      // Build identity-aligned snooze reminder text
      final String notificationTitle = 'Gentle nudge for your tiny habit';
      final String notificationBody = _buildSnoozeReminderBody(profile, habit);

      // Schedule one-time notification (uses different ID to not conflict with daily)
      await _notifications.zonedSchedule(
        NotificationIds.snoozeReminder,
        notificationTitle,
        notificationBody,
        snoozeTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: habit.id,
      );

      if (kDebugMode) {
        debugPrint('⏰ Snooze notification scheduled for $snoozeTime');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to schedule snooze: $e');
      }
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (!_initialized) return;
    
    try {
      await _notifications.cancelAll();
      if (kDebugMode) {
        debugPrint('🚫 All notifications cancelled');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to cancel notifications: $e');
      }
    }
  }

  /// Get list of pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_initialized) return [];
    
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to get pending notifications: $e');
      }
      return [];
    }
  }

  /// Show immediate test notification (for testing purposes)
  Future<void> showTestNotification() async {
    if (!_initialized) return;

    try {
      const androidDetails = AndroidNotificationDetails(
        'habit_reminders',
        'Habit Reminders',
        channelDescription: 'Daily reminders for your habits',
        importance: Importance.high,
        priority: Priority.high,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            'mark_done',
            'Mark Done',
            showsUserInterface: true,
            cancelNotification: true,
          ),
          AndroidNotificationAction(
            'snooze',
            'Snooze 30 mins',
            showsUserInterface: false,
            cancelNotification: true,
          ),
        ],
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      await _notifications.show(
        NotificationIds.test,
        'Test: Your tiny proof for today',
        'This is a test notification with action buttons',
        notificationDetails,
      );

      if (kDebugMode) {
        debugPrint('🧪 Test notification shown');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to show test notification: $e');
      }
    }
  }

  /// Build identity-aligned body for daily reminder
  /// Calm, supportive, British English
  String _buildDailyReminderBody(UserProfile profile, Habit habit) {
    // Extract the core identity (remove "I am " prefix if present)
    String identity = profile.identity;
    if (identity.toLowerCase().startsWith('i am ')) {
      identity = identity.substring(5);
    }

    // Capitalise first letter if needed
    if (identity.isNotEmpty) {
      identity = identity[0].toUpperCase() + identity.substring(1);
    }

    // Build identity-first message with tiny version
    return '$identity? Time for your tiny habit: ${habit.tinyVersion}.';
  }

  /// Build identity-aligned body for snooze reminder
  /// Gentle nudge, not guilt-laden
  String _buildSnoozeReminderBody(UserProfile profile, Habit habit) {
    return 'A gentle reminder for your tiny habit: ${habit.tinyVersion}.';
  }

  /// Cancel a specific notification by ID
  Future<void> cancelNotification(int id) async {
    if (!_initialized) return;

    try {
      await _notifications.cancel(id);
      if (kDebugMode) {
        debugPrint('🚫 Notification $id cancelled');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to cancel notification $id: $e');
      }
    }
  }
}
