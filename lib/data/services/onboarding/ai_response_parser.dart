import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../models/onboarding_data.dart';

/// Parser for extracting structured data from AI responses
/// 
/// AI responses contain both conversational text and structured JSON data.
/// The JSON is wrapped in [HABIT_DATA]...[/HABIT_DATA] markers for reliable extraction.
class AiResponseParser {
  /// Regex pattern to find [HABIT_DATA]{...}[/HABIT_DATA]
  static const _habitDataPattern = r'\[HABIT_DATA\](.*?)\[\/HABIT_DATA\]';
  
  /// Start marker for JSON data
  static const _startMarker = '[HABIT_DATA]';
  
  /// End marker for JSON data
  static const _endMarker = '[/HABIT_DATA]';

  /// Extracts structured OnboardingData from AI response text
  /// 
  /// Returns null if no valid JSON block is found or parsing fails.
  /// 
  /// Example AI response:
  /// ```
  /// Great! Here's your habit plan:
  /// [HABIT_DATA]{"identity": "I am a reader", "name": "Read daily"}[/HABIT_DATA]
  /// ```
  static OnboardingData? extractHabitData(String response) {
    try {
      final regex = RegExp(_habitDataPattern, dotAll: true);
      final match = regex.firstMatch(response);
      
      if (match == null) {
        debugPrint('AiResponseParser: No [HABIT_DATA] block found');
        return null;
      }
      
      final jsonStr = match.group(1)!.trim();
      
      // Handle empty JSON
      if (jsonStr.isEmpty || jsonStr == '{}') {
        debugPrint('AiResponseParser: Empty JSON in [HABIT_DATA] block');
        return null;
      }
      
      final Map<String, dynamic> json = jsonDecode(jsonStr);
      return OnboardingData.fromJson(json);
    } catch (e, stackTrace) {
      debugPrint('AiResponseParser: Parsing error: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Removes the JSON block to show only the conversational part to the user
  /// 
  /// Example:
  /// Input: "Great! Here's your plan: [HABIT_DATA]{...}[/HABIT_DATA]"
  /// Output: "Great! Here's your plan:"
  static String extractConversationalText(String response) {
    // Find the start of the JSON block
    final startIdx = response.indexOf(_startMarker);
    
    if (startIdx == -1) {
      // No JSON block - return entire response
      return response.trim();
    }
    
    // Get everything before the JSON block
    final beforeJson = response.substring(0, startIdx).trim();
    
    // Find the end of the JSON block
    final endIdx = response.indexOf(_endMarker);
    
    if (endIdx == -1) {
      // Malformed - just return what's before
      return beforeJson;
    }
    
    // Get everything after the JSON block
    final afterJson = response.substring(endIdx + _endMarker.length).trim();
    
    // Combine before and after, filtering empty strings
    final parts = [beforeJson, afterJson].where((s) => s.isNotEmpty);
    return parts.join('\n\n').trim();
  }

  /// Check if response contains a complete habit data block
  static bool hasCompleteHabitData(String response) {
    final data = extractHabitData(response);
    return data != null && data.isComplete;
  }

  /// Check if response contains any habit data (complete or partial)
  static bool hasAnyHabitData(String response) {
    return response.contains(_startMarker) && response.contains(_endMarker);
  }

  /// Validate extracted data has minimum required fields
  static bool isValidHabitData(OnboardingData? data) {
    if (data == null) return false;
    return data.hasRequiredFields;
  }

  /// Extract partial data even if not marked complete
  /// Useful for progressive updates during conversation
  static OnboardingData? extractPartialData(String response) {
    final data = extractHabitData(response);
    // Return even if not complete - let caller decide what to do
    return data;
  }

  /// Try to extract JSON even from malformed response
  /// More lenient parsing for edge cases
  static OnboardingData? extractWithFallback(String response) {
    // First try normal extraction
    final normal = extractHabitData(response);
    if (normal != null) return normal;
    
    // Try to find any JSON-like object in the response
    try {
      final jsonPattern = RegExp(r'\{[^{}]*"identity"[^{}]*\}', dotAll: true);
      final match = jsonPattern.firstMatch(response);
      
      if (match != null) {
        final json = jsonDecode(match.group(0)!);
        return OnboardingData.fromJson(json as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('AiResponseParser: Fallback parsing failed: $e');
    }
    
    return null;
  }
}
