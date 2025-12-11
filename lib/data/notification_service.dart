import 'dart:ui' show Color;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'models/habit.dart';
import 'models/user_profile.dart';
import 'models/consistency_metrics.dart';
import 'services/recovery_engine.dart';

/// Notification Service for Daily Habit Reminders
/// Implements the "Trigger" part of Nir Eyal's Hook Model
/// 
/// Key Features:
/// - Daily scheduled notifications at user's chosen time
/// - Action buttons: "Mark Done" and "Snooze 30 mins"
/// - **Never Miss Twice** recovery notifications
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

      // Build notification body (include temptation bundle if present)
      final String notificationBody;
      if (habit.temptationBundle != null && habit.temptationBundle!.isNotEmpty) {
        notificationBody = 
            'You\'re becoming the type of person who ${profile.identity} (and ${habit.temptationBundle}).';
      } else {
        notificationBody = 
            'You\'re becoming the type of person who ${profile.identity}.';
      }

      // Schedule repeating daily notification
      await _notifications.zonedSchedule(
        0, // Notification ID
        'Time for your 2-minute ${habit.name}', // Title
        notificationBody, // Body (with optional temptation bundle)
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

      // Build notification body (include temptation bundle if present)
      final String notificationBody;
      if (habit.temptationBundle != null && habit.temptationBundle!.isNotEmpty) {
        notificationBody = 
            'You\'re becoming the type of person who ${profile.identity} (and ${habit.temptationBundle}).';
      } else {
        notificationBody = 
            'You\'re becoming the type of person who ${profile.identity}.';
      }

      // Schedule one-time notification (uses different ID to not conflict with daily)
      await _notifications.zonedSchedule(
        1, // Different ID for snooze notifications
        'Time for your 2-minute ${habit.name}',
        notificationBody, // Body (with optional temptation bundle)
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
        99, // Test notification ID
        'Test: Time for your habit!',
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
  
  // ========== Never Miss Twice Recovery Notifications ==========
  
  /// Schedule a recovery notification for tomorrow morning
  /// Called when user misses a day - reminds them of "Never Miss Twice"
  Future<void> scheduleRecoveryNotification({
    required Habit habit,
    required UserProfile profile,
    required RecoveryNeed recoveryNeed,
  }) async {
    if (!_initialized) return;

    try {
      // Schedule for 9 AM tomorrow morning
      final now = tz.TZDateTime.now(tz.local);
      final scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + 1, // Tomorrow
        9, // 9 AM
        0,
      );

      final title = RecoveryEngine.getRecoveryTitle(recoveryNeed.urgency);
      final body = RecoveryEngine.getRecoveryNotificationMessage(recoveryNeed);

      final androidDetails = AndroidNotificationDetails(
        'recovery_reminders',
        'Recovery Reminders',
        channelDescription: 'Never Miss Twice recovery notifications',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'Time to bounce back!',
        color: _getUrgencyNotificationColor(recoveryNeed.urgency),
        actions: <AndroidNotificationAction>[
          const AndroidNotificationAction(
            'do_tiny_version',
            'Do 2-min version',
            showsUserInterface: true,
            cancelNotification: true,
          ),
          const AndroidNotificationAction(
            'dismiss_recovery',
            'Not now',
            showsUserInterface: false,
            cancelNotification: true,
          ),
        ],
      );

      final notificationDetails = NotificationDetails(android: androidDetails);

      await _notifications.zonedSchedule(
        2, // Recovery notification ID
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'recovery:${habit.id}',
      );

      if (kDebugMode) {
        debugPrint('💪 Recovery notification scheduled for tomorrow 9 AM');
        debugPrint('   Urgency: ${recoveryNeed.urgency}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to schedule recovery notification: $e');
      }
    }
  }
  
  /// Show immediate recovery prompt notification
  /// Used when app detects user hasn't completed habit today
  Future<void> showRecoveryPromptNotification({
    required Habit habit,
    required UserProfile profile,
    required RecoveryNeed recoveryNeed,
  }) async {
    if (!_initialized) return;

    try {
      final title = RecoveryEngine.getRecoveryTitle(recoveryNeed.urgency);
      final body = RecoveryEngine.getRecoveryNotificationMessage(recoveryNeed);

      final androidDetails = AndroidNotificationDetails(
        'recovery_reminders',
        'Recovery Reminders',
        channelDescription: 'Never Miss Twice recovery notifications',
        importance: Importance.high,
        priority: Priority.high,
        color: _getUrgencyNotificationColor(recoveryNeed.urgency),
        actions: <AndroidNotificationAction>[
          const AndroidNotificationAction(
            'do_tiny_version',
            'Do 2-min version',
            showsUserInterface: true,
            cancelNotification: true,
          ),
          const AndroidNotificationAction(
            'dismiss_recovery',
            'Not now',
            showsUserInterface: false,
            cancelNotification: true,
          ),
        ],
      );

      final notificationDetails = NotificationDetails(android: androidDetails);

      await _notifications.show(
        3, // Recovery prompt notification ID
        title,
        body,
        notificationDetails,
        payload: 'recovery:${habit.id}',
      );

      if (kDebugMode) {
        debugPrint('💪 Recovery notification shown immediately');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to show recovery notification: $e');
      }
    }
  }
  
  /// Cancel recovery notification
  Future<void> cancelRecoveryNotification() async {
    if (!_initialized) return;
    
    try {
      await _notifications.cancel(2); // Recovery scheduled notification
      await _notifications.cancel(3); // Recovery prompt notification
      if (kDebugMode) {
        debugPrint('🚫 Recovery notifications cancelled');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to cancel recovery notifications: $e');
      }
    }
  }
  
  /// Get notification color based on recovery urgency
  Color _getUrgencyNotificationColor(RecoveryUrgency urgency) {
    switch (urgency) {
      case RecoveryUrgency.gentle:
        return const Color(0xFFFFC107); // Amber
      case RecoveryUrgency.important:
        return const Color(0xFFFF9800); // Orange
      case RecoveryUrgency.compassionate:
        return const Color(0xFF9C27B0); // Purple
    }
  }
}
