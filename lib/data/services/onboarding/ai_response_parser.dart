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
    
    // Phase 34.4: Try sanitized extraction (handles Markdown pollution)
    final sanitized = sanitizeAndExtractJson(response);
    if (sanitized != null) {
      try {
        return OnboardingData.fromJson(sanitized);
      } catch (e) {
        debugPrint('AiResponseParser: Sanitized JSON conversion failed: $e');
      }
    }
    
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
  
  /// Phase 34.4: Sanitize raw LLM response and extract JSON
  /// 
  /// Handles common Gemini response issues:
  /// 1. Markdown code blocks (```json ... ```)
  /// 2. Conversational preamble before JSON
  /// 3. Trailing text after JSON
  /// 
  /// Returns the parsed JSON map or null if extraction fails.
  static Map<String, dynamic>? sanitizeAndExtractJson(String rawResponse) {
    try {
      // 1. Strip Markdown code blocks (```json ... ``` or ``` ... ```)
      String clean = rawResponse
          .replaceAll(RegExp(r'```json\s*', caseSensitive: false), '')
          .replaceAll(RegExp(r'```\s*'), '');
      
      // 2. Trim whitespace
      clean = clean.trim();
      
      // 3. Find the first '{' and last '}' to isolate JSON object
      final startIndex = clean.indexOf('{');
      final endIndex = clean.lastIndexOf('}');
      
      if (startIndex == -1 || endIndex == -1 || startIndex >= endIndex) {
        if (kDebugMode) {
          debugPrint('🔴 AiResponseParser: No JSON object found in response');
        }
        return null;
      }
      
      clean = clean.substring(startIndex, endIndex + 1);
      
      // 4. Decode and return
      final result = jsonDecode(clean) as Map<String, dynamic>;
      
      if (kDebugMode) {
        debugPrint('✅ AiResponseParser: Successfully sanitized and parsed JSON');
      }
      
      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🔴 AiResponseParser: Sanitize error: $e');
        debugPrint('🔴 Raw response was: ${rawResponse.substring(0, rawResponse.length > 200 ? 200 : rawResponse.length)}...');
      }
      return null;
    }
  }
  
  /// Phase 34.4: Parse any JSON from response (not just OnboardingData)
  /// 
  /// Generic method for parsing JSON from AI responses that may be
  /// wrapped in Markdown or have conversational text.
  static Map<String, dynamic>? parseGenericJson(String rawResponse) {
    // First try direct parse
    try {
      return jsonDecode(rawResponse) as Map<String, dynamic>;
    } catch (_) {
      // Fall through to sanitized extraction
    }
    
    // Try sanitized extraction
    return sanitizeAndExtractJson(rawResponse);
  }
}
