import 'package:flutter/foundation.dart';
import 'api_client.dart';
import 'api_config.dart';

/// Service for daily coaching and reflection after habit completion
///
/// This service provides AI-powered coaching feedback on daily habits,
/// helping users reflect on what worked, what didn't, and how to improve.
///
/// ARCHITECTURE:
/// 1. Tries to get feedback from remote coach API (with 5s timeout)
/// 2. Falls back to local reflection prompts if remote fails
/// 3. Always returns supportive guidance - never crashes
class DailyCoachService {
  final ApiClient _apiClient;

  /// Create a daily coach service
  ///
  /// [apiClient] - Optional API client (for testing or custom config)
  DailyCoachService({ApiClient? apiClient})
      : _apiClient = apiClient ?? const ApiClient(baseUrl: apiBaseUrl);

  /// Get daily coaching reflection
  ///
  /// Returns [DailyCoachResult] with coaching message and insights
  Future<DailyCoachResult> getDailyReflection(
      DailyReflectionContext context) async {
    if (kDebugMode) {
      debugPrint('📡 Attempting daily coach reflection call...');
    }

    // Build request payload with snake_case keys
    final payload = {
      'identity': context.identity,
      'habit_name': context.habitName,
      'tiny_version': context.tinyVersion,
      'date': context.date.toIso8601String(),
      'status': context.status,
      'current_streak': context.currentStreak,
      'total_completions': context.totalCompletions,
      'user_note': context.userNote,
    };

    // Make API call
    final result = await _apiClient.postJson<_DailyCoachResponse>(
      '/api/coach/daily-reflection',
      body: payload,
      parser: (json) => _DailyCoachResponse.fromJson(json),
    );

    // Handle result
    if (result.isSuccess && result.value != null) {
      final response = result.value!;
      if (kDebugMode) {
        debugPrint('✅ Daily coach reflection received');
      }
      return DailyCoachResult(
        message: response.message,
        insights: response.insights ?? [],
        isRemote: true,
      );
    }

    // Log error and use fallback
    if (kDebugMode) {
      debugPrint('🔄 Using local fallback for daily coach reflection');
    }

    return _localDailyReflection(context);
  }

  /// Local fallback: Simple reflection prompts based on context
  DailyCoachResult _localDailyReflection(DailyReflectionContext context) {
    // Parse identity to remove "I am" prefix if present
    String identity = context.identity;
    if (identity.toLowerCase().startsWith('i am ')) {
      identity = identity.substring(5);
    }
    if (identity.isNotEmpty) {
      identity = identity[0].toUpperCase() + identity.substring(1);
    }

    // Generate message based on status
    String message;
    List<String> insights;

    if (context.status == 'completed') {
      if (context.currentStreak == 1) {
        // First completion or streak restart
        message = '''
Brilliant! You've cast a vote for being ${identity.toLowerCase()}.

${context.userNote != null && context.userNote!.isNotEmpty ? 'You noted: "${context.userNote}"\n\n' : ''}Every action counts. This is how change happens—one tiny habit at a time.
''';
        insights = [
          'Small wins compound into remarkable results',
          'You proved you can do this',
          'Tomorrow, do it again',
        ];
      } else if (context.currentStreak % 7 == 0) {
        // Weekly milestone
        message = '''
${context.currentStreak} days in a row! You're building real momentum.

${context.userNote != null && context.userNote!.isNotEmpty ? 'You noted: "${context.userNote}"\n\n' : ''}This is evidence of who you're becoming: ${identity.toLowerCase()}.
''';
        insights = [
          'Consistency is your superpower',
          'Your identity is reinforced by every repetition',
          'Keep the chain going',
        ];
      } else {
        // Regular completion
        message = '''
Day ${context.currentStreak} complete. Another vote for your identity.

${context.userNote != null && context.userNote!.isNotEmpty ? 'You noted: "${context.userNote}"\n\n' : ''}You're not just doing the habit—you're becoming ${identity.toLowerCase()}.
''';
        insights = [
          'Progress, not perfection',
          'Small actions, big impact',
          'You're proving it to yourself daily',
        ];
      }
    } else {
      // Missed or partial completion
      message = '''
Life happens. Missing one day doesn't erase your progress.

${context.userNote != null && context.userNote!.isNotEmpty ? 'You noted: "${context.userNote}"\n\n' : ''}You've completed this habit ${context.totalCompletions} times total. That's real evidence of who you are.

Tomorrow is a fresh start.
''';
      insights = [
        'Never miss twice—that's the real rule',
        'Your identity is the sum of your actions, not one day',
        'Get back on track tomorrow',
      ];
    }

    return DailyCoachResult(
      message: message,
      insights: insights,
      isRemote: false,
    );
  }
}

/// Context data for daily reflection request
class DailyReflectionContext {
  final String identity;
  final String habitName;
  final String tinyVersion;
  final DateTime date;
  final String status; // 'completed', 'missed', 'partial'
  final int currentStreak;
  final int totalCompletions;
  final String? userNote; // Optional reflection note from user

  const DailyReflectionContext({
    required this.identity,
    required this.habitName,
    required this.tinyVersion,
    required this.date,
    required this.status,
    required this.currentStreak,
    required this.totalCompletions,
    this.userNote,
  });
}

/// Result from daily coach reflection
class DailyCoachResult {
  /// Main coaching message
  final String message;

  /// Optional insights or tips
  final List<String> insights;

  /// Whether this came from remote API (true) or local fallback (false)
  final bool isRemote;

  const DailyCoachResult({
    required this.message,
    required this.insights,
    required this.isRemote,
  });
}

/// Response model for daily coach endpoint
class _DailyCoachResponse {
  final String message;
  final List<String>? insights;

  _DailyCoachResponse({
    required this.message,
    this.insights,
  });

  factory _DailyCoachResponse.fromJson(Map<String, dynamic> json) {
    return _DailyCoachResponse(
      message: json['message'] as String? ?? '',
      insights: json['insights'] != null
          ? (json['insights'] as List).map((item) => item.toString()).toList()
          : null,
    );
  }
}
