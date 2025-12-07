import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'models/habit.dart';
import 'models/user_profile.dart';

/// Notification Service for Daily Habit Reminders
/// Implements the "Trigger" part of the Hook Model (Nir Eyal)
/// And "Make it Obvious" - Law 1 from Atomic Habits (James Clear)
///
/// Key Features:
/// - Daily scheduled notifications at user's chosen time
/// - Action buttons: "Mark Done" and "Snooze 30 mins"
/// - Proper permission handling for Android 13+ and iOS
/// - Dynamic timezone detection
/// - Enable/disable toggle support
/// - Boot receiver for notification persistence after device restart
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _notificationsEnabled = true;

  // Permission status
  bool _hasPermission = false;

  // Callback for when notification actions are tapped
  Function(String action)? onNotificationAction;

  // Callback for when app is opened from notification
  Function(String? habitId)? onNotificationTapped;

  // Getters
  bool get isInitialized => _initialized;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get hasPermission => _hasPermission;

  /// Initialize notification system
  /// Called once when app starts in main.dart
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize timezone data for scheduled notifications
      tz_data.initializeTimeZones();

      // Detect local timezone
      final String localTimeZone = await _getLocalTimeZone();
      tz.setLocalLocation(tz.getLocation(localTimeZone));

      if (kDebugMode) {
        debugPrint('Timezone set to: $localTimeZone');
      }

      // Android initialization settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      final DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false, // We'll request manually
        requestBadgePermission: true,
        requestSoundPermission: true,
        notificationCategories: [
          DarwinNotificationCategory(
            'habit_reminder',
            actions: <DarwinNotificationAction>[
              DarwinNotificationAction.plain(
                'mark_done',
                'Mark Done',
                options: <DarwinNotificationActionOption>{
                  DarwinNotificationActionOption.foreground,
                },
              ),
              DarwinNotificationAction.plain(
                'snooze',
                'Snooze 30 mins',
              ),
            ],
            options: <DarwinNotificationCategoryOption>{
              DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
            },
          ),
        ],
      );

      // Combined initialization settings
      final InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: iosSettings, // Same settings for macOS
      );

      // Initialize with callback for notification taps
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
        onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTapped,
      );

      _initialized = true;

      if (kDebugMode) {
        debugPrint('NotificationService initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('NotificationService initialization error: $e');
        debugPrint('Notifications may not work (common on web platform)');
      }
      // Don't throw - allow app to continue without notifications
    }
  }

  /// Get local timezone name
  Future<String> _getLocalTimeZone() async {
    try {
      // Try to get the device timezone
      final now = DateTime.now();
      final offset = now.timeZoneOffset;

      // Map common offsets to timezone names
      // This is a simplified approach - in production you might want to use
      // a more comprehensive timezone detection library
      final hours = offset.inHours;
      final minutes = offset.inMinutes.remainder(60);

      // Common timezone mappings
      final timezoneMap = {
        -12: 'Etc/GMT+12',
        -11: 'Pacific/Pago_Pago',
        -10: 'Pacific/Honolulu',
        -9: 'America/Anchorage',
        -8: 'America/Los_Angeles',
        -7: 'America/Denver',
        -6: 'America/Chicago',
        -5: 'America/New_York',
        -4: 'America/Halifax',
        -3: 'America/Sao_Paulo',
        -2: 'Atlantic/South_Georgia',
        -1: 'Atlantic/Azores',
        0: 'UTC',
        1: 'Europe/London',
        2: 'Europe/Paris',
        3: 'Europe/Moscow',
        4: 'Asia/Dubai',
        5: 'Asia/Karachi',
        6: 'Asia/Dhaka',
        7: 'Asia/Bangkok',
        8: 'Asia/Singapore',
        9: 'Asia/Tokyo',
        10: 'Australia/Sydney',
        11: 'Pacific/Noumea',
        12: 'Pacific/Auckland',
      };

      // Handle half-hour offsets
      if (minutes == 30) {
        if (hours == 5) return 'Asia/Kolkata';
        if (hours == 9) return 'Australia/Darwin';
        if (hours == -3) return 'America/St_Johns';
      }

      return timezoneMap[hours] ?? 'UTC';
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error detecting timezone: $e, using UTC');
      }
      return 'UTC';
    }
  }

  /// Request notification permissions
  /// Returns true if permission granted, false otherwise
  Future<bool> requestPermission() async {
    if (!_initialized) {
      await initialize();
    }

    try {
      // Request Android 13+ permissions
      if (!kIsWeb && Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
            _notifications.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        if (androidPlugin != null) {
          // Request notification permission (Android 13+)
          final bool? granted = await androidPlugin.requestNotificationsPermission();
          _hasPermission = granted ?? false;

          // Also request exact alarm permission (Android 12+)
          await androidPlugin.requestExactAlarmsPermission();

          if (kDebugMode) {
            debugPrint('Android notification permission: $_hasPermission');
          }
        }
      }

      // Request iOS permissions
      if (!kIsWeb && Platform.isIOS) {
        final IOSFlutterLocalNotificationsPlugin? iosPlugin =
            _notifications.resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();

        if (iosPlugin != null) {
          final bool? granted = await iosPlugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: false,
          );
          _hasPermission = granted ?? false;

          if (kDebugMode) {
            debugPrint('iOS notification permission: $_hasPermission');
          }
        }
      }

      // Request macOS permissions
      if (!kIsWeb && Platform.isMacOS) {
        final MacOSFlutterLocalNotificationsPlugin? macPlugin =
            _notifications.resolvePlatformSpecificImplementation<
                MacOSFlutterLocalNotificationsPlugin>();

        if (macPlugin != null) {
          final bool? granted = await macPlugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          _hasPermission = granted ?? false;
        }
      }

      return _hasPermission;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Permission request error: $e');
      }
      return false;
    }
  }

  /// Check current permission status without requesting
  Future<bool> checkPermissionStatus() async {
    if (!_initialized) return false;

    try {
      if (!kIsWeb && Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
            _notifications.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        if (androidPlugin != null) {
          _hasPermission = await androidPlugin.areNotificationsEnabled() ?? false;
        }
      } else if (!kIsWeb && Platform.isIOS) {
        // iOS doesn't have a direct check, assume granted if we've requested before
        // The notification will just not show if permission was denied
        _hasPermission = true;
      } else {
        // Web and other platforms - assume no permission
        _hasPermission = false;
      }

      return _hasPermission;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking permission status: $e');
      }
      return false;
    }
  }

  /// Enable or disable notifications
  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    if (!enabled) {
      cancelAllNotifications();
    }
    if (kDebugMode) {
      debugPrint('Notifications ${enabled ? "enabled" : "disabled"}');
    }
  }

  /// Handle notification tap (when user interacts with notification)
  void _onNotificationTapped(NotificationResponse response) {
    final String? payload = response.payload;

    if (kDebugMode) {
      debugPrint('Notification tapped - Action: ${response.actionId}, Payload: $payload');
    }

    // Handle action button presses
    if (response.actionId != null && response.actionId!.isNotEmpty) {
      onNotificationAction?.call(response.actionId!);
    } else {
      // User tapped the notification body itself
      onNotificationTapped?.call(payload);
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
        debugPrint('Cannot schedule notification - service not initialized');
      }
      return;
    }

    if (!_notificationsEnabled) {
      if (kDebugMode) {
        debugPrint('Notifications disabled - skipping schedule');
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

      // Create scheduled time in local timezone
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

      // Build notification body (include temptation bundle if present)
      final String notificationBody = _buildNotificationBody(habit, profile);

      // Android notification details with action buttons
      final androidDetails = AndroidNotificationDetails(
        'habit_reminders',
        'Habit Reminders',
        channelDescription: 'Daily reminders for your habits',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'Time for your habit!',
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        enableVibration: true,
        playSound: true,
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

      // iOS notification details
      const iosDetails = DarwinNotificationDetails(
        categoryIdentifier: 'habit_reminder',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        macOS: iosDetails,
      );

      // Schedule repeating daily notification
      await _notifications.zonedSchedule(
        0, // Notification ID
        'Time for your 2-minute ${habit.name}',
        notificationBody,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily at same time
        payload: habit.id,
      );

      if (kDebugMode) {
        debugPrint('Daily notification scheduled for ${habit.implementationTime}');
        debugPrint('Next notification: $scheduledDate');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to schedule notification: $e');
      }
    }
  }

  /// Build notification body text
  String _buildNotificationBody(Habit habit, UserProfile profile) {
    if (habit.temptationBundle != null && habit.temptationBundle!.isNotEmpty) {
      return 'You\'re becoming the type of person who ${profile.identity} (and ${habit.temptationBundle}).';
    }
    return 'You\'re becoming the type of person who ${profile.identity}.';
  }

  /// Schedule one-time snooze notification (30 minutes from now)
  /// Called when user taps "Snooze 30 mins" action
  Future<void> scheduleSnoozeNotification({
    required Habit habit,
    required UserProfile profile,
  }) async {
    if (!_initialized || !_notificationsEnabled) return;

    try {
      final snoozeTime = tz.TZDateTime.now(tz.local).add(const Duration(minutes: 30));

      final String notificationBody = _buildNotificationBody(habit, profile);

      final androidDetails = AndroidNotificationDetails(
        'habit_reminders',
        'Habit Reminders',
        channelDescription: 'Daily reminders for your habits',
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
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

      const iosDetails = DarwinNotificationDetails(
        categoryIdentifier: 'habit_reminder',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        macOS: iosDetails,
      );

      // Schedule one-time notification (uses different ID to not conflict with daily)
      await _notifications.zonedSchedule(
        1, // Different ID for snooze notifications
        'Time for your 2-minute ${habit.name}',
        notificationBody,
        snoozeTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: habit.id,
      );

      if (kDebugMode) {
        debugPrint('Snooze notification scheduled for $snoozeTime');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to schedule snooze: $e');
      }
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (!_initialized) return;

    try {
      await _notifications.cancelAll();
      if (kDebugMode) {
        debugPrint('All notifications cancelled');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to cancel notifications: $e');
      }
    }
  }

  /// Cancel specific notification by ID
  Future<void> cancelNotification(int id) async {
    if (!_initialized) return;

    try {
      await _notifications.cancel(id);
      if (kDebugMode) {
        debugPrint('Notification $id cancelled');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to cancel notification $id: $e');
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
        debugPrint('Failed to get pending notifications: $e');
      }
      return [];
    }
  }

  /// Show immediate test notification (for testing purposes)
  Future<void> showTestNotification() async {
    if (!_initialized) {
      if (kDebugMode) {
        debugPrint('Cannot show test notification - service not initialized');
      }
      return;
    }

    if (!_notificationsEnabled) {
      if (kDebugMode) {
        debugPrint('Notifications disabled - cannot show test');
      }
      return;
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'habit_reminders',
        'Habit Reminders',
        channelDescription: 'Daily reminders for your habits',
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
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

      const iosDetails = DarwinNotificationDetails(
        categoryIdentifier: 'habit_reminder',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        macOS: iosDetails,
      );

      await _notifications.show(
        99, // Test notification ID
        'Test: Time for your habit!',
        'This is a test notification with action buttons',
        notificationDetails,
      );

      if (kDebugMode) {
        debugPrint('Test notification shown');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to show test notification: $e');
      }
    }
  }

  /// Get scheduled notification time as readable string
  Future<String?> getScheduledTimeDescription() async {
    final pending = await getPendingNotifications();
    if (pending.isEmpty) return null;

    // Find the daily notification (ID 0)
    final dailyNotification = pending.where((n) => n.id == 0).firstOrNull;
    if (dailyNotification == null) return null;

    return dailyNotification.title;
  }
}

/// Background notification response handler (must be top-level function)
@pragma('vm:entry-point')
void _onBackgroundNotificationTapped(NotificationResponse response) {
  // Handle background notification tap
  // This is called when the app is terminated and user taps notification
  if (kDebugMode) {
    debugPrint('Background notification tapped: ${response.payload}');
  }
}
