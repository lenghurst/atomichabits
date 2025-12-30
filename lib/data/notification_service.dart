import 'dart:ui' show Color;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'models/habit.dart';
import 'models/user_profile.dart';
import 'models/consistency_metrics.dart';
import 'models/habit_pattern.dart';
import 'services/recovery_engine.dart';
import 'services/smart_nudge/nudge_copywriter.dart';

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
  
  // ✅ PRIVACY: Default to FALSE (Safe Mode)
  bool _showSensitiveNotifications = false;
  
  // Callback for when notification actions are tapped
  Function(String action)? onNotificationAction;
  
  // Helper method for safe, generic encouragements
  String _getRandomEncouragement() {
    final encouragements = [
      'Time to build your future self.',
      'Small steps lead to big changes.',
      'Your discipline is growing.',
      'Ready for today\'s progress?',
      'Consistency is key. You\'ve got this!',
    ];
    return encouragements[DateTime.now().millisecond % encouragements.length];
  }

  // Update privacy preference (Call from Settings Screen)
  void updateNotificationPrivacy(bool showSensitive) {
    _showSensitiveNotifications = showSensitive;
    if (kDebugMode) {
      debugPrint('🔒 Notification Privacy Updated: ShowSensitive = $showSensitive');
    }
  }

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
      // DEFERRED: await requestPermissions();

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
  Future<void> requestPermissions() async {
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
        // ✅ CRITICAL: Lock screen visibility (Default to PRIVATE)
        visibility: _showSensitiveNotifications 
            ? NotificationVisibility.public // User opted in
            : NotificationVisibility.secret, // Default safe
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

      // Build notification body (Safeguard Identity)
      final String notificationBody;
      if (_showSensitiveNotifications) {
        // User opted-in to sensitive content
        if (habit.temptationBundle != null && habit.temptationBundle!.isNotEmpty) {
          notificationBody = 
              'You\'re becoming the type of person who ${profile.identity} (and ${habit.temptationBundle}).';
        } else {
          notificationBody = 
              'You\'re becoming the type of person who ${profile.identity}.';
        }
      } else {
        // ✅ DEFAULT: Safe, generic encouragement
        notificationBody = _getRandomEncouragement();
      }

      // Schedule repeating daily notification
      await _notifications.zonedSchedule(
        0, // Notification ID
        'Time for your 2-minute ${habit.name}', // Title
        notificationBody, // Body (Safe or Sensitive based on preference)
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
  
  // ========== Phase 19: Smart Notifications (The Intelligent Nudge) ==========
  
  /// Schedule a context-aware "smart" notification for a habit
  /// 
  /// Uses [NudgeCopywriter] to generate copy based on detected patterns.
  /// This creates notifications that adapt to the user's behavior instead
  /// of nagging with the same message every day.
  /// 
  /// Philosophy: "A good assistant notices when you're busy or tired and adapts."
  Future<void> scheduleSmartReminder({
    required Habit habit,
    required UserProfile profile,
    List<HabitPattern> activePatterns = const [],
    String? customTime, // Override time (format: "HH:MM")
  }) async {
    if (!_initialized) {
      if (kDebugMode) {
        debugPrint('⚠️ Cannot schedule smart notification - service not initialized');
      }
      return;
    }

    try {
      // Cancel existing notifications first
      await _notifications.cancel(0); // Cancel daily habit notification
      
      // Determine notification time
      final timeString = customTime ?? habit.implementationTime;
      final timeParts = timeString.split(':');
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

      // Generate context-aware copy using NudgeCopywriter
      final copyConfig = NudgeCopyConfig(
        habitName: habit.name,
        identity: profile.identity,
        tinyVersion: habit.tinyVersion,
        temptationBundle: habit.temptationBundle,
        isWeekend: scheduledDate.weekday >= 6,
        currentHour: hour,
      );
      
      final nudgeCopy = NudgeCopywriter.generateCopy(
        config: copyConfig,
        activePatterns: activePatterns,
      );

      // Notification details
      final androidDetails = AndroidNotificationDetails(
        'smart_reminders', // Different channel for smart notifications
        'Smart Reminders',
        channelDescription: 'Context-aware habit reminders',
        importance: Importance.high,
        priority: Priority.high,
        ticker: nudgeCopy.title,
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

      // Schedule the notification
      await _notifications.zonedSchedule(
        0, // Notification ID
        nudgeCopy.title,
        nudgeCopy.body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
        payload: 'smart:${habit.id}',
      );

      if (kDebugMode) {
        debugPrint('🧠 Smart notification scheduled for $timeString');
        debugPrint('   Title: ${nudgeCopy.title}');
        debugPrint('   Reason: ${nudgeCopy.copyReason}');
        if (nudgeCopy.influencingPattern != null) {
          debugPrint('   Pattern: ${nudgeCopy.influencingPattern}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to schedule smart notification: $e');
      }
    }
  }
  
  /// Schedule smart reminder with drift-adjusted time
  /// 
  /// If drift analysis suggests a different time, use that instead.
  /// Called from TodayScreenController or WeeklyReviewService.
  Future<void> scheduleSmartReminderWithDrift({
    required Habit habit,
    required UserProfile profile,
    List<HabitPattern> activePatterns = const [],
    String? suggestedTime, // Drift-adjusted time (format: "HH:MM")
  }) async {
    await scheduleSmartReminder(
      habit: habit,
      profile: profile,
      activePatterns: activePatterns,
      customTime: suggestedTime,
    );
    
    if (kDebugMode && suggestedTime != null) {
      debugPrint('🎯 Smart notification uses drift-adjusted time: $suggestedTime');
      debugPrint('   (Original scheduled: ${habit.implementationTime})');
    }
  }
  
  /// Show immediate smart notification for testing
  /// 
  /// Useful for debugging and demonstrating the smart copy feature.
  Future<void> showSmartTestNotification({
    required Habit habit,
    required UserProfile profile,
    List<HabitPattern> activePatterns = const [],
  }) async {
    if (!_initialized) return;

    try {
      final now = DateTime.now();
      final copyConfig = NudgeCopyConfig(
        habitName: habit.name,
        identity: profile.identity,
        tinyVersion: habit.tinyVersion,
        temptationBundle: habit.temptationBundle,
        isWeekend: now.weekday >= 6,
        currentHour: now.hour,
      );
      
      final nudgeCopy = NudgeCopywriter.generateCopy(
        config: copyConfig,
        activePatterns: activePatterns,
      );

      const androidDetails = AndroidNotificationDetails(
        'smart_reminders',
        'Smart Reminders',
        channelDescription: 'Context-aware habit reminders',
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
        98, // Test smart notification ID
        nudgeCopy.title,
        nudgeCopy.body,
        notificationDetails,
        payload: 'smart_test:${habit.id}',
      );

      if (kDebugMode) {
        debugPrint('🧪 Smart test notification shown');
        debugPrint('   Reason: ${nudgeCopy.copyReason}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to show smart test notification: $e');
      }
    }
  }
  
  // ========== Phase 22: Witness Notifications (The Accountability Loop) ==========
  
  /// Show witness completion notification
  /// 
  /// Called when a builder completes their habit.
  /// The witness receives: "[Name] just cast a vote for [Identity]!"
  /// 
  /// Action button allows witness to send a "High Five" reaction.
  Future<void> showWitnessCompletionNotification({
    required String builderName,
    required String habitName,
    required String identity,
    required String contractId,
    required String builderId,
    int? currentStreak,
    bool isMilestone = false,
    String? milestoneEmoji,
    String? milestoneMessage,
  }) async {
    if (!_initialized) return;

    try {
      final title = isMilestone 
          ? '${milestoneEmoji ?? "🔥"} ${currentStreak ?? 0} Day Streak!'
          : '⚡ Vote Cast!';
      
      final body = isMilestone
          ? '$builderName $milestoneMessage'
          : '$builderName just cast a vote for $identity!';

      final androidDetails = AndroidNotificationDetails(
        'witness_notifications',
        'Witness Notifications',
        channelDescription: 'Notifications from your accountability partners',
        importance: Importance.high,
        priority: Priority.high,
        color: const Color(0xFF4CAF50), // Green for positive
        actions: <AndroidNotificationAction>[
          const AndroidNotificationAction(
            'high_five',
            '🖐️ High Five!',
            showsUserInterface: true,
            cancelNotification: true,
          ),
          const AndroidNotificationAction(
            'view_progress',
            'View Progress',
            showsUserInterface: true,
            cancelNotification: true,
          ),
        ],
      );

      final notificationDetails = NotificationDetails(android: androidDetails);

      await _notifications.show(
        10 + contractId.hashCode.abs() % 90, // Unique ID per contract
        title,
        body,
        notificationDetails,
        payload: 'witness_completion:$contractId:$builderId',
      );

      if (kDebugMode) {
        debugPrint('🤝 Witness notification shown: $title');
        debugPrint('   Body: $body');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to show witness notification: $e');
      }
    }
  }
  
  /// Show high-five received notification
  /// 
  /// Called when the builder receives a high-five from their witness.
  /// This is the SECOND dopamine hit (social validation).
  Future<void> showHighFiveReceivedNotification({
    required String witnessName,
    required String emoji,
    String? message,
    required String contractId,
  }) async {
    if (!_initialized) return;

    try {
      final androidDetails = AndroidNotificationDetails(
        'witness_notifications',
        'Witness Notifications',
        channelDescription: 'Notifications from your accountability partners',
        importance: Importance.high,
        priority: Priority.high,
        color: const Color(0xFFFFEB3B), // Yellow for celebration
      );

      final notificationDetails = NotificationDetails(android: androidDetails);

      await _notifications.show(
        20 + contractId.hashCode.abs() % 80, // Unique ID
        '$emoji High Five from $witnessName!',
        message ?? 'Keep up the great work!',
        notificationDetails,
        payload: 'high_five:$contractId',
      );

      if (kDebugMode) {
        debugPrint('🖐️ High-five notification shown: $emoji from $witnessName');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to show high-five notification: $e');
      }
    }
  }
  
  /// Show nudge received notification
  /// 
  /// Called when the builder receives a nudge from their witness.
  Future<void> showNudgeReceivedNotification({
    required String witnessName,
    required String message,
    required String contractId,
    required String habitId,
  }) async {
    if (!_initialized) return;

    try {
      final androidDetails = AndroidNotificationDetails(
        'witness_notifications',
        'Witness Notifications',
        channelDescription: 'Notifications from your accountability partners',
        importance: Importance.high,
        priority: Priority.high,
        color: const Color(0xFF2196F3), // Blue for nudge
        actions: <AndroidNotificationAction>[
          const AndroidNotificationAction(
            'do_habit_now',
            'Do It Now',
            showsUserInterface: true,
            cancelNotification: true,
          ),
          const AndroidNotificationAction(
            'snooze',
            'Remind Later',
            showsUserInterface: false,
            cancelNotification: true,
          ),
        ],
      );

      final notificationDetails = NotificationDetails(android: androidDetails);

      await _notifications.show(
        30 + contractId.hashCode.abs() % 70,
        '💬 Nudge from $witnessName',
        message,
        notificationDetails,
        payload: 'nudge:$contractId:$habitId',
      );

      if (kDebugMode) {
        debugPrint('💬 Nudge notification shown from $witnessName');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to show nudge notification: $e');
      }
    }
  }
  
  /// Show drift warning notification to witness
  /// 
  /// Called when a builder is about to miss their habit.
  /// "Your builder is drifting. Nudge them?"
  Future<void> showDriftWarningNotification({
    required String builderName,
    required String habitName,
    required String contractId,
    required String builderId,
  }) async {
    if (!_initialized) return;

    try {
      final androidDetails = AndroidNotificationDetails(
        'witness_notifications',
        'Witness Notifications',
        channelDescription: 'Notifications from your accountability partners',
        importance: Importance.high,
        priority: Priority.high,
        color: const Color(0xFFFF9800), // Orange for warning
        actions: <AndroidNotificationAction>[
          const AndroidNotificationAction(
            'send_nudge',
            'Send Nudge',
            showsUserInterface: true,
            cancelNotification: true,
          ),
          const AndroidNotificationAction(
            'dismiss_drift',
            'Not Now',
            showsUserInterface: false,
            cancelNotification: true,
          ),
        ],
      );

      final notificationDetails = NotificationDetails(android: androidDetails);

      await _notifications.show(
        40 + contractId.hashCode.abs() % 60,
        '⚠️ $builderName Needs You',
        '$builderName is drifting on $habitName. Nudge them?',
        notificationDetails,
        payload: 'drift_warning:$contractId:$builderId',
      );

      if (kDebugMode) {
        debugPrint('⚠️ Drift warning notification shown for $builderName');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to show drift warning notification: $e');
      }
    }
  }
  
  /// Show contract accepted notification
  /// 
  /// Called when a witness accepts the contract invitation.
  Future<void> showContractAcceptedNotification({
    required String witnessName,
    required String habitName,
    required String contractId,
  }) async {
    if (!_initialized) return;

    try {
      final androidDetails = AndroidNotificationDetails(
        'witness_notifications',
        'Witness Notifications',
        channelDescription: 'Notifications from your accountability partners',
        importance: Importance.high,
        priority: Priority.high,
        color: const Color(0xFF4CAF50), // Green for success
      );

      final notificationDetails = NotificationDetails(android: androidDetails);

      await _notifications.show(
        50 + contractId.hashCode.abs() % 50,
        '🤝 Witness Accepted!',
        '$witnessName is now your accountability partner for $habitName!',
        notificationDetails,
        payload: 'contract_accepted:$contractId',
      );

      if (kDebugMode) {
        debugPrint('🤝 Contract accepted notification shown');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to show contract accepted notification: $e');
      }
    }
  }
}
