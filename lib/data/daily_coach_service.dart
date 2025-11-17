import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Daily reflection coach service for post-habit coaching
///
/// This service helps users understand why their habit completion succeeded or failed
/// and suggests tiny adjustments for tomorrow based on Atomic Habits principles.
///
/// ARCHITECTURE:
/// 1. Collects daily status (completed/partial/missed) and reflection context
/// 2. Sends to remote coach endpoint (with 5s timeout)
/// 3. Returns personalized coaching message, insights, and 1% improvements
/// 4. Handles errors gracefully (user sees fallback message)
class DailyCoachService {
  // Remote coach endpoint configuration
  //
  // LOCAL DEVELOPMENT: Points to the Node.js backend running locally
  // Run the backend with: cd backend && npm run dev
  //
  // PRODUCTION: Change this to your deployed backend URL
  // Example: 'https://your-backend-domain.com/api/coach/daily-reflection'
  static const String _endpoint = 'http://localhost:3000/api/coach/daily-reflection';
  static const Duration _timeout = Duration(seconds: 5);

  /// Generate daily reflection from habit status and user context
  ///
  /// Throws:
  /// - TimeoutException if backend doesn't respond within 5 seconds
  /// - HttpException if backend returns error status
  /// - FormatException if response JSON is invalid
  Future<DailyCoachResponse> generateReflection({
    required DailyReflectionRequest request,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('📡 Calling daily coach endpoint...');
      }

      // Build request payload matching backend's DailyReflectionRequest interface
      // (backend/src/services/dailyCoachService.ts)
      // All field names use snake_case to match backend expectations
      final payload = {
        'habit': {
          'habit_name': request.habit.habitName,
          'identity': request.habit.identity,
          'two_minute_version': request.habit.twoMinuteVersion,
          'time': request.habit.time,
          'location': request.habit.location,
        },
        'date': request.date,
        'status': request.status,
        'reflection': {
          'what_happened': request.reflection.whatHappened,
          'what_helped_or_blocked': request.reflection.whatHelpedOrBlocked,
          'what_might_help_tomorrow': request.reflection.whatMightHelpTomorrow,
        },
      };

      // Make HTTP POST request with timeout
      final response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(_timeout);

      // Parse response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        if (kDebugMode) {
          debugPrint('✅ Daily coach returned reflection');
        }

        return DailyCoachResponse.fromJson(data);
      } else if (response.statusCode == 503) {
        // Service unavailable - coach temporarily down
        throw Exception('Daily coach service temporarily unavailable');
      } else if (response.statusCode == 400) {
        // Bad request - invalid context
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(data['message'] ?? 'Invalid request');
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('⏱️ Daily coach endpoint timeout after ${_timeout.inSeconds}s');
      }
      throw TimeoutException('Daily coach request timed out');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Daily coach service error: $e');
      }
      rethrow;
    }
  }
}

/// Daily reflection request sent to the coach
class DailyReflectionRequest {
  final DailyHabitInfo habit;
  final String date; // yyyy-MM-dd format
  final String status; // "completed" | "missed" | "partial"
  final DailyReflectionContext reflection;

  DailyReflectionRequest({
    required this.habit,
    required this.date,
    required this.status,
    required this.reflection,
  });

  Map<String, dynamic> toJson() => {
        'habit': habit.toJson(),
        'date': date,
        'status': status,
        'reflection': reflection.toJson(),
      };
}

/// Habit information for daily reflection
class DailyHabitInfo {
  final String habitName;
  final String? identity;
  final String? twoMinuteVersion;
  final String? time;
  final String? location;

  DailyHabitInfo({
    required this.habitName,
    this.identity,
    this.twoMinuteVersion,
    this.time,
    this.location,
  });

  Map<String, dynamic> toJson() => {
        'habit_name': habitName,
        'identity': identity,
        'two_minute_version': twoMinuteVersion,
        'time': time,
        'location': location,
      };
}

/// Reflection context collected from the user
class DailyReflectionContext {
  final String? whatHappened;
  final String? whatHelpedOrBlocked;
  final String? whatMightHelpTomorrow;

  DailyReflectionContext({
    this.whatHappened,
    this.whatHelpedOrBlocked,
    this.whatMightHelpTomorrow,
  });

  Map<String, dynamic> toJson() => {
        'what_happened': whatHappened,
        'what_helped_or_blocked': whatHelpedOrBlocked,
        'what_might_help_tomorrow': whatMightHelpTomorrow,
      };
}

/// Daily coach response with personalized insights
class DailyCoachResponse {
  final String coachMessage;
  final List<String> insights;
  final List<String> suggestedAdjustments;
  final String suggestedTomorrowExperiment;

  DailyCoachResponse({
    required this.coachMessage,
    required this.insights,
    required this.suggestedAdjustments,
    required this.suggestedTomorrowExperiment,
  });

  factory DailyCoachResponse.fromJson(Map<String, dynamic> json) {
    return DailyCoachResponse(
      coachMessage: json['coach_message'] as String,
      insights: (json['insights'] as List).map((e) => e.toString()).toList(),
      suggestedAdjustments: (json['suggested_adjustments'] as List)
          .map((e) => e.toString())
          .toList(),
      suggestedTomorrowExperiment:
          json['suggested_tomorrow_experiment'] as String,
    );
  }
}
