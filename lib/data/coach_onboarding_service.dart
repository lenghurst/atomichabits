import 'package:flutter/foundation.dart';
import 'api_client.dart';
import 'api_config.dart';

/// Service for conversational coach onboarding feedback
///
/// This service provides AI-powered coaching feedback on the user's
/// onboarding plan (identity, habit, tiny version, implementation intentions).
///
/// ARCHITECTURE:
/// 1. Tries to get feedback from remote coach API (with 5s timeout)
/// 2. Falls back to local affirmation if remote fails
/// 3. Always returns a supportive message - never crashes
class CoachOnboardingService {
  final ApiClient _apiClient;

  /// Create a coach onboarding service
  ///
  /// [apiClient] - Optional API client (for testing or custom config)
  CoachOnboardingService({ApiClient? apiClient})
      : _apiClient = apiClient ?? const ApiClient(baseUrl: apiBaseUrl);

  /// Get coaching feedback on onboarding plan
  ///
  /// Returns [CoachPlanResult] with feedback message and optional suggestions
  Future<CoachPlanResult> generatePlan(OnboardingContext context) async {
    if (kDebugMode) {
      debugPrint('📡 Attempting coach onboarding call...');
    }

    // Build request payload
    final payload = {
      'name': context.name,
      'identity': context.identity,
      'habit_name': context.habitName,
      'tiny_version': context.tinyVersion,
      'implementation_time': context.implementationTime,
      'implementation_location': context.implementationLocation,
      'temptation_bundle': context.temptationBundle,
      'pre_habit_ritual': context.preHabitRitual,
      'environment_cue': context.environmentCue,
      'environment_distraction': context.environmentDistraction,
    };

    // Make API call
    final result = await _apiClient.postJson<_CoachPlanResponse>(
      '/api/coach/onboarding',
      body: payload,
      parser: (json) => _CoachPlanResponse.fromJson(json),
    );

    // Handle result
    if (result.isSuccess && result.value != null) {
      final response = result.value!;
      if (kDebugMode) {
        debugPrint('✅ Coach onboarding feedback received');
      }
      return CoachPlanResult(
        message: response.message,
        suggestions: response.suggestions ?? [],
        isRemote: true,
      );
    }

    // Log error and use fallback
    if (kDebugMode) {
      debugPrint('🔄 Using local fallback for onboarding coach');
    }

    return _localOnboardingFeedback(context);
  }

  /// Local fallback: Simple identity-aligned affirmation
  CoachPlanResult _localOnboardingFeedback(OnboardingContext context) {
    // Parse identity to remove "I am" prefix if present
    String identity = context.identity;
    if (identity.toLowerCase().startsWith('i am ')) {
      identity = identity.substring(5);
    }
    if (identity.isNotEmpty) {
      identity = identity[0].toUpperCase() + identity.substring(1);
    }

    // Generate supportive message
    final message = '''
${context.name}, your plan looks solid!

You're becoming ${identity.toLowerCase()}, one tiny action at a time.

Your tiny habit: ${context.tinyVersion}
When: ${context.implementationTime}
Where: ${context.implementationLocation}

This is excellent. Start small, stay consistent, and trust the process.

Every time you do this, you're casting a vote for who you want to become.
''';

    return CoachPlanResult(
      message: message,
      suggestions: [
        'Remember: it only takes 2 minutes to start',
        'Consistency beats intensity every time',
        'Your identity is shaped by your actions, not your thoughts',
      ],
      isRemote: false,
    );
  }
}

/// Context data for onboarding coach request
class OnboardingContext {
  final String name;
  final String identity;
  final String habitName;
  final String tinyVersion;
  final String implementationTime;
  final String implementationLocation;
  final String? temptationBundle;
  final String? preHabitRitual;
  final String? environmentCue;
  final String? environmentDistraction;

  const OnboardingContext({
    required this.name,
    required this.identity,
    required this.habitName,
    required this.tinyVersion,
    required this.implementationTime,
    required this.implementationLocation,
    this.temptationBundle,
    this.preHabitRitual,
    this.environmentCue,
    this.environmentDistraction,
  });
}

/// Result from coach onboarding feedback
class CoachPlanResult {
  /// Main coaching message
  final String message;

  /// Optional suggestions or tips
  final List<String> suggestions;

  /// Whether this came from remote API (true) or local fallback (false)
  final bool isRemote;

  const CoachPlanResult({
    required this.message,
    required this.suggestions,
    required this.isRemote,
  });
}

/// Response model for coach onboarding endpoint
class _CoachPlanResponse {
  final String message;
  final List<String>? suggestions;

  _CoachPlanResponse({
    required this.message,
    this.suggestions,
  });

  factory _CoachPlanResponse.fromJson(Map<String, dynamic> json) {
    return _CoachPlanResponse(
      message: json['message'] as String? ?? '',
      suggestions: json['suggestions'] != null
          ? (json['suggestions'] as List).map((item) => item.toString()).toList()
          : null,
    );
  }
}
