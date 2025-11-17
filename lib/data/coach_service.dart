import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Coach onboarding service for conversational habit discovery
///
/// This service takes collected Q&A from the coach dialog and generates
/// a structured habit plan that auto-populates the onboarding form.
///
/// ARCHITECTURE:
/// 1. Collects conversational context from user
/// 2. Sends to remote coach endpoint (with 5s timeout)
/// 3. Returns structured habit plan to populate onboarding form
/// 4. Handles errors gracefully (user can continue manually)
class CoachService {
  // Remote coach endpoint configuration
  //
  // LOCAL DEVELOPMENT: Points to the Node.js backend running locally
  // Run the backend with: cd backend && npm run dev
  //
  // PRODUCTION: Change this to your deployed backend URL
  // Example: 'https://your-backend-domain.com/api/coach/onboarding'
  static const String _coachEndpoint = 'http://localhost:3000/api/coach/onboarding';
  static const Duration _remoteTimeout = Duration(seconds: 5);

  /// Generate habit plan from conversational context
  ///
  /// Throws:
  /// - TimeoutException if backend doesn't respond within 5 seconds
  /// - HttpException if backend returns error status
  /// - FormatException if response JSON is invalid
  Future<HabitPlanResult> generateHabitPlan({
    required CoachContext context,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('📡 Calling coach onboarding endpoint...');
      }

      // Build request payload matching backend's OnboardingCoachContext interface
      // (backend/src/services/coachOnboardingService.ts)
      // All field names use snake_case to match backend expectations
      final payload = {
        'desired_identity': context.desiredIdentity,
        'habit_idea': context.habitIdea,
        'when_in_day': context.whenInDay,
        'where_location': context.whereLocation,
        'what_makes_it_enjoyable': context.whatMakesItEnjoyable,
        'user_name': context.userName,
      };

      // Make HTTP POST request with timeout
      final response = await http
          .post(
            Uri.parse(_coachEndpoint),
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
          debugPrint('✅ Coach returned habit plan');
        }

        return HabitPlanResult.fromJson(data);
      } else if (response.statusCode == 503) {
        // Service unavailable - coach temporarily down
        throw Exception('Coach service temporarily unavailable');
      } else if (response.statusCode == 400) {
        // Bad request - invalid context
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(data['message'] ?? 'Invalid request');
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('⏱️ Coach endpoint timeout after ${_remoteTimeout.inSeconds}s');
      }
      throw TimeoutException('Coach request timed out');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Coach service error: $e');
      }
      rethrow;
    }
  }
}

/// Conversational context collected from the user during coach dialog
/// This represents the Q&A answers that the coach uses to generate a plan
class CoachContext {
  final String? desiredIdentity;
  final String? habitIdea;
  final String? whenInDay;
  final String? whereLocation;
  final String? whatMakesItEnjoyable;
  final String? userName;

  CoachContext({
    this.desiredIdentity,
    this.habitIdea,
    this.whenInDay,
    this.whereLocation,
    this.whatMakesItEnjoyable,
    this.userName,
  });

  Map<String, dynamic> toJson() => {
        'desired_identity': desiredIdentity,
        'habit_idea': habitIdea,
        'when_in_day': whenInDay,
        'where_location': whereLocation,
        'what_makes_it_enjoyable': whatMakesItEnjoyable,
        'user_name': userName,
      };
}

/// The structured habit plan returned by the coach
/// This will be used to auto-populate the onboarding form
class HabitPlan {
  final String identity;
  final String habitName;
  final String tinyVersion;
  final String implementationTime; // HH:MM format
  final String implementationLocation;
  final String? temptationBundle;
  final String? preHabitRitual;
  final String? environmentCue;
  final String? environmentDistraction;

  HabitPlan({
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

  factory HabitPlan.fromJson(Map<String, dynamic> json) {
    return HabitPlan(
      identity: json['identity'] as String,
      habitName: json['habit_name'] as String,
      tinyVersion: json['tiny_version'] as String,
      implementationTime: json['implementation_time'] as String,
      implementationLocation: json['implementation_location'] as String,
      temptationBundle: json['temptation_bundle'] as String?,
      preHabitRitual: json['pre_habit_ritual'] as String?,
      environmentCue: json['environment_cue'] as String?,
      environmentDistraction: json['environment_distraction'] as String?,
    );
  }
}

/// Metadata about the habit plan generation
/// Helps handle partial/incomplete plans gracefully
class HabitPlanMetadata {
  final double confidence; // 0.0 - 1.0
  final List<String>? missingFields;
  final String? notes;

  HabitPlanMetadata({
    required this.confidence,
    this.missingFields,
    this.notes,
  });

  factory HabitPlanMetadata.fromJson(Map<String, dynamic> json) {
    return HabitPlanMetadata(
      confidence: (json['confidence'] as num).toDouble(),
      missingFields: json['missing_fields'] != null
          ? (json['missing_fields'] as List).map((e) => e.toString()).toList()
          : null,
      notes: json['notes'] as String?,
    );
  }
}

/// Complete result from coach onboarding endpoint
class HabitPlanResult {
  final HabitPlan habitPlan;
  final HabitPlanMetadata metadata;

  HabitPlanResult({
    required this.habitPlan,
    required this.metadata,
  });

  factory HabitPlanResult.fromJson(Map<String, dynamic> json) {
    return HabitPlanResult(
      habitPlan: HabitPlan.fromJson(json['habit_plan'] as Map<String, dynamic>),
      metadata: HabitPlanMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );
  }
}
