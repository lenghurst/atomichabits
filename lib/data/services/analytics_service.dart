import 'package:flutter/foundation.dart';

/// Analytics Service - Event tracking for user behavior
/// 
/// Phase 68: Onboarding Polish Sprint
/// 
/// Currently logs to console in debug mode.
/// Ready for Firebase/Mixpanel integration.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  /// Log an analytics event
  Future<void> logEvent(
    String name, {
    Map<String, dynamic>? parameters,
  }) async {
    if (kDebugMode) {
      debugPrint('[Analytics] $name: $parameters');
    }
    
    // TODO: Add Firebase Analytics
    // await FirebaseAnalytics.instance.logEvent(
    //   name: name,
    //   parameters: parameters,
    // );
  }

  /// Track screen views
  Future<void> logScreenView(String screenName) async {
    await logEvent('screen_view', parameters: {'screen_name': screenName});
  }

  /// Onboarding-specific events
  Future<void> logTierSelected(String tierId) async {
    await logEvent('tier_selected', parameters: {
      'tier_id': tierId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> logPaymentIntentCaptured(String tierId) async {
    await logEvent('payment_intent_captured', parameters: {
      'tier_id': tierId,
      'flow': 'identity_first',
    });
  }

  Future<void> logOnboardingStep(String step, {String? variant}) async {
    await logEvent('onboarding_step', parameters: {
      'step': step,
      if (variant != null) 'variant': variant,
    });
  }
}
