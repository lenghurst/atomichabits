import 'package:flutter/foundation.dart';
import 'api_client.dart';
import 'api_config.dart';

/// Service for generating weekly habit reviews and progress summaries
///
/// This service provides AI-powered weekly reviews that highlight:
/// - What's working well
/// - Opportunities for improvement
/// - Overall progress trends
///
/// ARCHITECTURE:
/// 1. Tries to get review from remote coach API (with 5s timeout)
/// 2. Falls back to local stats-based review if remote fails
/// 3. Always returns a supportive summary - never crashes
class ReviewService {
  final ApiClient _apiClient;

  /// Create a review service
  ///
  /// [apiClient] - Optional API client (for testing or custom config)
  ReviewService({ApiClient? apiClient})
      : _apiClient = apiClient ?? const ApiClient(baseUrl: apiBaseUrl);

  /// Generate weekly habit review
  ///
  /// Returns [WeeklyReviewResult] with summary, highlights, and opportunities
  Future<WeeklyReviewResult> generateWeeklyReview(
      WeeklyReviewContext context) async {
    if (kDebugMode) {
      debugPrint('📡 Attempting weekly review generation...');
    }

    // Build request payload with snake_case keys
    final payload = {
      'identity': context.identity,
      'habit_name': context.habitName,
      'tiny_version': context.tinyVersion,
      'current_streak': context.currentStreak,
      'total_completions': context.totalCompletions,
      'completion_history': context.completionHistory, // Map of date strings to bools
      'days_to_review': context.daysToReview,
    };

    // Make API call
    final result = await _apiClient.postJson<_WeeklyReviewResponse>(
      '/api/habit-review',
      body: payload,
      parser: (json) => _WeeklyReviewResponse.fromJson(json),
    );

    // Handle result
    if (result.isSuccess && result.value != null) {
      final response = result.value!;
      if (kDebugMode) {
        debugPrint('✅ Weekly review received');
      }
      return WeeklyReviewResult(
        summary: response.summary,
        highlights: response.highlights ?? [],
        opportunities: response.opportunities ?? [],
        isRemote: true,
      );
    }

    // Log error and use fallback
    if (kDebugMode) {
      debugPrint('🔄 Using local fallback for weekly review');
    }

    return _localWeeklyReview(context);
  }

  /// Local fallback: Stats-based review from completion history
  WeeklyReviewResult _localWeeklyReview(WeeklyReviewContext context) {
    // Parse identity to remove "I am" prefix if present
    String identity = context.identity;
    if (identity.toLowerCase().startsWith('i am ')) {
      identity = identity.substring(5);
    }
    if (identity.isNotEmpty) {
      identity = identity[0].toUpperCase() + identity.substring(1);
    }

    // Calculate stats from completion history
    final now = DateTime.now();
    int completedDays = 0;
    int missedDays = 0;

    for (int i = 0; i < context.daysToReview; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      if (context.completionHistory.containsKey(dateKey)) {
        if (context.completionHistory[dateKey] == true) {
          completedDays++;
        } else {
          missedDays++;
        }
      }
    }

    final completionRate = context.daysToReview > 0
        ? (completedDays / context.daysToReview * 100).round()
        : 0;

    // Generate summary
    String summary;
    List<String> highlights = [];
    List<String> opportunities = [];

    if (completionRate >= 80) {
      // Excellent performance
      summary = '''
Brilliant work over the past ${context.daysToReview} days!

You completed your habit $completedDays out of ${context.daysToReview} days (${completionRate}% completion rate). That's exceptional consistency.

You're not just doing the actions—you're becoming ${identity.toLowerCase()}. Every completion is a vote for your identity.
''';
      highlights = [
        'Outstanding consistency (${completionRate}% completion rate)',
        '${context.currentStreak}-day current streak',
        '${context.totalCompletions} total completions to date',
      ];

      if (missedDays > 0) {
        opportunities = [
          'Even the best performers miss occasionally—never miss twice',
          'Consider what triggered the ${missedDays == 1 ? 'missed day' : '$missedDays missed days'}',
        ];
      } else {
        opportunities = [
          'Perfect streak! Keep the momentum going',
          'Consider sharing your strategy with others',
        ];
      }
    } else if (completionRate >= 50) {
      // Good performance
      summary = '''
Solid progress over the past ${context.daysToReview} days.

You completed your habit $completedDays out of ${context.daysToReview} days (${completionRate}% completion rate). You're building real momentum.

Remember: it's about progress, not perfection. You're proving to yourself that you're ${identity.toLowerCase()}.
''';
      highlights = [
        'Good consistency (${completionRate}% completion rate)',
        '${context.totalCompletions} total completions',
        'Building the habit successfully',
      ];

      opportunities = [
        'Aim for 80%+ completion rate for stronger identity reinforcement',
        'Identify patterns: when do you tend to miss?',
        'Focus on making it easier to start (reduce friction)',
      ];
    } else {
      // Needs improvement
      summary = '''
Over the past ${context.daysToReview} days, you completed your habit $completedDays times.

That's ${completionRate}% completion rate. There's room to grow here, but remember: you're still ${context.totalCompletions} completions ahead of where you started.

Every action counts. Small improvements in consistency compound over time.
''';
      highlights = [
        '${context.totalCompletions} total completions (that matters!)',
        'You\'re still showing up',
        'Awareness is the first step to improvement',
      ];

      opportunities = [
        'Review your implementation intention: is the time/location still working?',
        'Make the habit even smaller—can you do it in 30 seconds?',
        'Never miss twice—that\'s the golden rule',
        'Consider pairing with an existing daily routine',
      ];
    }

    return WeeklyReviewResult(
      summary: summary,
      highlights: highlights,
      opportunities: opportunities,
      isRemote: false,
    );
  }
}

/// Context data for weekly review request
class WeeklyReviewContext {
  final String identity;
  final String habitName;
  final String tinyVersion;
  final int currentStreak;
  final int totalCompletions;
  final Map<String, bool> completionHistory; // Date string keys (YYYY-MM-DD)
  final int daysToReview; // Usually 7 or 14

  const WeeklyReviewContext({
    required this.identity,
    required this.habitName,
    required this.tinyVersion,
    required this.currentStreak,
    required this.totalCompletions,
    required this.completionHistory,
    this.daysToReview = 7,
  });
}

/// Result from weekly review generation
class WeeklyReviewResult {
  /// Main review summary
  final String summary;

  /// Key highlights (what's working well)
  final List<String> highlights;

  /// Opportunities for improvement
  final List<String> opportunities;

  /// Whether this came from remote API (true) or local fallback (false)
  final bool isRemote;

  const WeeklyReviewResult({
    required this.summary,
    required this.highlights,
    required this.opportunities,
    required this.isRemote,
  });
}

/// Response model for weekly review endpoint
class _WeeklyReviewResponse {
  final String summary;
  final List<String>? highlights;
  final List<String>? opportunities;

  _WeeklyReviewResponse({
    required this.summary,
    this.highlights,
    this.opportunities,
  });

  factory _WeeklyReviewResponse.fromJson(Map<String, dynamic> json) {
    return _WeeklyReviewResponse(
      summary: json['summary'] as String? ?? '',
      highlights: json['highlights'] != null
          ? (json['highlights'] as List).map((item) => item.toString()).toList()
          : null,
      opportunities: json['opportunities'] != null
          ? (json['opportunities'] as List)
              .map((item) => item.toString())
              .toList()
          : null,
    );
  }
}
