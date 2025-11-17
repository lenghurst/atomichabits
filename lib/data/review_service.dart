import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'models/habit.dart';

/// Weekly Review data model
class WeeklyReview {
  final String summary;
  final List<String> insights;
  final List<String> suggestedAdjustments;

  WeeklyReview({
    required this.summary,
    required this.insights,
    required this.suggestedAdjustments,
  });

  factory WeeklyReview.fromJson(Map<String, dynamic> json) {
    return WeeklyReview(
      summary: json['summary'] as String? ?? '',
      insights: (json['insights'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      suggestedAdjustments: (json['suggested_adjustments'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
    );
  }
}

/// Service for fetching AI-powered weekly reviews
class ReviewService {
  // Remote endpoint configuration
  //
  // LOCAL DEVELOPMENT: Points to the Node.js backend running locally
  // Run the backend with: cd backend && npm run dev
  //
  // PRODUCTION: Change this to your deployed backend URL
  // Example: 'https://your-backend-domain.com/api/habit-review'
  static const String _remoteReviewEndpoint =
      'http://localhost:3000/api/habit-review';
  static const Duration _remoteTimeout = Duration(seconds: 5);

  /// Fetches weekly review from backend
  ///
  /// CONTRACT WITH BACKEND:
  /// - Sends POST request to /api/habit-review
  /// - Request includes habit info and completion history (last 7-14 days)
  /// - Response includes summary, insights, and suggested_adjustments
  ///
  /// Returns WeeklyReview on success, or throws an error
  Future<WeeklyReview> fetchWeeklyReview({
    required Habit habit,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('📡 Fetching weekly review from backend...');
      }

      // Build payload matching backend's expected format
      final payload = {
        'habit': {
          'identity': habit.identity,
          'habit_name': habit.name,
          'two_minute_version': habit.tinyVersion,
          'time': habit.implementationTime,
          'location': habit.implementationLocation,
          'temptation_bundle': habit.temptationBundle,
          'pre_habit_ritual': habit.preHabitRitual,
          'environment_cue': habit.environmentCue,
          'environment_distraction': habit.environmentDistraction,
        },
        'history': _buildHistoryPayload(habit.completionHistory),
      };

      // Make HTTP POST request with timeout
      final response = await http
          .post(
            Uri.parse(_remoteReviewEndpoint),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(_remoteTimeout);

      // Parse response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        if (kDebugMode) {
          debugPrint('✅ Weekly review received from backend');
        }

        return WeeklyReview.fromJson(data);
      } else {
        if (kDebugMode) {
          debugPrint(
              '⚠️ Backend returned status ${response.statusCode}: ${response.body}');
        }
        throw Exception(
            'Backend returned error: ${response.statusCode} ${response.body}');
      }
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint(
            '⏱️ Backend timeout after ${_remoteTimeout.inSeconds} seconds');
      }
      throw Exception('Request timeout - backend may be down');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error fetching weekly review: $e');
      }
      rethrow;
    }
  }

  /// Build history payload from completion history map
  /// Returns last 14 days in chronological order (oldest to newest)
  List<Map<String, dynamic>> _buildHistoryPayload(
      Map<String, bool> completionHistory) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final history = <Map<String, dynamic>>[];

    // Collect last 14 days
    for (int i = 13; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dateKey = _formatDateKey(date);
      final completed = completionHistory[dateKey] ?? false;

      history.add({
        'date': dateKey,
        'completed': completed,
      });
    }

    return history;
  }

  /// Format DateTime to yyyy-MM-dd string
  String _formatDateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
