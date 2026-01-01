import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:ui' show Color;

import '../../../domain/entities/intervention.dart';
import '../../../domain/services/jitai_decision_engine.dart';

/// JITAINotificationService: The Intervention Delivery System
///
/// Connects JITAI decisions to the notification layer.
/// Handles different intervention types with appropriate UI.
///
/// Phase 63: JITAI Foundation
class JITAINotificationService {
  static final JITAINotificationService _instance = JITAINotificationService._internal();
  factory JITAINotificationService() => _instance;
  JITAINotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // Callbacks for tracking
  Function(String eventId, String action)? onInterventionAction;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );

      _initialized = true;
      debugPrint('JITAINotificationService: Initialized');
    } catch (e) {
      debugPrint('JITAINotificationService: Init failed: $e');
    }
  }

  /// Handle notification tap/action
  void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    final actionId = response.actionId;

    debugPrint('JITAI Notification: action=$actionId, payload=$payload');

    if (payload != null && payload.startsWith('jitai:')) {
      final parts = payload.split(':');
      if (parts.length >= 2) {
        final eventId = parts[1];
        onInterventionAction?.call(eventId, actionId ?? 'tap');
      }
    }
  }

  /// Deliver a JITAI intervention as a notification
  Future<void> deliverIntervention(JITAIDecision decision) async {
    if (!_initialized || !decision.shouldIntervene) return;

    final event = decision.event!;
    final content = decision.content!;

    try {
      // Choose notification style based on meta-lever
      final androidDetails = _buildNotificationDetails(
        decision: decision,
        event: event,
        content: content,
      );

      final notificationDetails = NotificationDetails(android: androidDetails);

      // Use event ID hash for notification ID (stable per event)
      final notificationId = event.eventId.hashCode.abs() % 1000 + 100;

      await _notifications.show(
        notificationId,
        content.title,
        content.body,
        notificationDetails,
        payload: 'jitai:${event.eventId}:${event.arm.armId}',
      );

      debugPrint('JITAI: Delivered ${event.arm.armId} notification');
    } catch (e) {
      debugPrint('JITAINotificationService: Delivery failed: $e');
    }
  }

  /// Build Android notification details based on intervention type
  AndroidNotificationDetails _buildNotificationDetails({
    required JITAIDecision decision,
    required InterventionEvent event,
    required InterventionContent content,
  }) {
    // Channel and styling based on meta-lever
    final (channelId, channelName, color) = _getChannelForLever(event.selectedMetaLever);

    // Action buttons based on intervention type
    final actions = _buildActions(event, content);

    return AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'JITAI adaptive interventions',
      importance: _getImportance(decision),
      priority: Priority.high,
      color: color,
      ticker: content.title,
      styleInformation: BigTextStyleInformation(
        content.body,
        contentTitle: content.title,
      ),
      actions: actions,
      // Trust interventions should be more subtle
      silent: event.selectedMetaLever == MetaLever.trust,
    );
  }

  /// Get notification channel based on meta-lever (simplified to 3)
  (String, String, Color) _getChannelForLever(MetaLever lever) {
    switch (lever) {
      case MetaLever.activate:
        return ('jitai_activate', 'Identity Activation', const Color(0xFF4CAF50)); // Green
      case MetaLever.support:
        return ('jitai_support', 'Support', const Color(0xFF2196F3)); // Blue
      case MetaLever.trust:
        return ('jitai_trust', 'Autonomy', const Color(0xFF607D8B)); // Gray
    }
  }

  /// Get notification importance based on V-O state
  Importance _getImportance(JITAIDecision decision) {
    if (decision.voState.isCritical) {
      return Importance.max;
    }
    if (decision.voState.vulnerability > 0.7) {
      return Importance.high;
    }
    return Importance.defaultImportance;
  }

  /// Build action buttons based on intervention type (simplified)
  List<AndroidNotificationAction> _buildActions(
    InterventionEvent event,
    InterventionContent content,
  ) {
    final actions = <AndroidNotificationAction>[];

    // Primary action
    actions.add(AndroidNotificationAction(
      'primary',
      content.actionLabel,
      showsUserInterface: true,
      cancelNotification: true,
    ));

    // Secondary action varies by type
    switch (event.arm.category) {
      case InterventionCategory.emotionalRegulation:
        if (event.arm.armId == 'EMO_URGE_SURF') {
          actions.add(const AndroidNotificationAction(
            'urge_surf',
            'Start Session',
            showsUserInterface: true,
            cancelNotification: true,
          ));
        }
        break;

      case InterventionCategory.frictionReduction:
        actions.add(const AndroidNotificationAction(
          'tiny_version',
          'Do 2-min version',
          showsUserInterface: true,
          cancelNotification: true,
        ));
        break;

      case InterventionCategory.silence:
      case InterventionCategory.shadowIntervention:
        // Autonomy-focused: just dismiss option
        actions.add(AndroidNotificationAction(
          'my_choice',
          content.dismissLabel,
          showsUserInterface: false,
          cancelNotification: true,
        ));
        break;

      case InterventionCategory.identityActivation:
      case InterventionCategory.socialWitness:
      case InterventionCategory.cognitiveReframe:
        // Default dismiss for identity/reframe categories
        actions.add(AndroidNotificationAction(
          'dismiss',
          content.dismissLabel,
          showsUserInterface: false,
          cancelNotification: true,
        ));
        break;
    }

    return actions;
  }

  /// Show a silent test notification (for debugging)
  Future<void> showTestIntervention({
    required String title,
    required String body,
    required MetaLever lever,
  }) async {
    if (!_initialized) return;

    final (channelId, channelName, color) = _getChannelForLever(lever);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'JITAI test notifications',
      importance: Importance.high,
      priority: Priority.high,
      color: color,
      actions: const <AndroidNotificationAction>[
        AndroidNotificationAction(
          'test_action',
          'Test Action',
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      999,
      title,
      body,
      notificationDetails,
      payload: 'jitai:test:${lever.name}',
    );
  }

  /// Cancel all JITAI notifications
  Future<void> cancelAll() async {
    if (!_initialized) return;
    // Cancel notification IDs in the JITAI range (100-1099)
    for (int i = 100; i < 1100; i++) {
      await _notifications.cancel(i);
    }
  }

  /// Track notification outcome
  void trackOutcome({
    required String eventId,
    required String action,
    required Duration timeToAction,
  }) {
    debugPrint('JITAI Outcome: $eventId, action=$action, time=${timeToAction.inSeconds}s');
    // This data will be sent to the JITAI Decision Engine for bandit updates
  }
}

/// Extension for in-app intervention display (not push notification)
extension InAppIntervention on JITAINotificationService {
  /// Build content for in-app display (e.g., on Value Screen)
  InterventionDisplayData buildInAppDisplay(JITAIDecision decision) {
    if (!decision.shouldIntervene) {
      return InterventionDisplayData.empty();
    }

    final event = decision.event!;
    final content = decision.content!;
    final voState = decision.voState;

    // Determine visual style
    final style = _styleForLever(event.selectedMetaLever);

    return InterventionDisplayData(
      title: content.title,
      body: content.body,
      primaryActionLabel: content.actionLabel,
      secondaryActionLabel: content.dismissLabel,
      armId: event.arm.armId,
      eventId: event.eventId,
      style: style,
      vulnerabilityScore: voState.vulnerability,
      opportunityScore: voState.opportunity,
      explanation: voState.explanation,
      isShadow: decision.isForcedShadow,
    );
  }

  InterventionStyle _styleForLever(MetaLever lever) {
    switch (lever) {
      case MetaLever.kick:
        return InterventionStyle.motivational;
      case MetaLever.ease:
        return InterventionStyle.supportive;
      case MetaLever.hold:
        return InterventionStyle.calming;
      case MetaLever.hush:
        return InterventionStyle.minimal;
      case MetaLever.shadow:
        return InterventionStyle.challenging;
    }
  }
}

/// Data for in-app intervention display
class InterventionDisplayData {
  final String title;
  final String body;
  final String primaryActionLabel;
  final String secondaryActionLabel;
  final String? armId;
  final String? eventId;
  final InterventionStyle style;
  final double vulnerabilityScore;
  final double opportunityScore;
  final String? explanation;
  final bool isShadow;

  InterventionDisplayData({
    required this.title,
    required this.body,
    required this.primaryActionLabel,
    required this.secondaryActionLabel,
    this.armId,
    this.eventId,
    required this.style,
    required this.vulnerabilityScore,
    required this.opportunityScore,
    this.explanation,
    this.isShadow = false,
  });

  factory InterventionDisplayData.empty() {
    return InterventionDisplayData(
      title: '',
      body: '',
      primaryActionLabel: '',
      secondaryActionLabel: '',
      style: InterventionStyle.minimal,
      vulnerabilityScore: 0,
      opportunityScore: 0,
    );
  }

  bool get isEmpty => title.isEmpty;
}

enum InterventionStyle {
  motivational, // Green, energetic
  supportive, // Blue, calm
  calming, // Purple, gentle
  minimal, // Gray, subtle
  challenging, // Orange, provocative
}
