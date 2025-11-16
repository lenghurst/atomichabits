import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// AI-powered suggestion service for Atomic Habits principles
/// 
/// This service provides contextual suggestions with:
/// - Remote LLM integration (with fallback to local heuristics)
/// - Temptation bundling (pairing habits with enjoyable activities)
/// - Pre-habit rituals (mental preparation before action)
/// - Environment cues (visual triggers to start habits)
/// - Environment distractions (friction to remove)
///
/// ARCHITECTURE:
/// 1. Tries to fetch suggestions from remote LLM endpoint (with 5s timeout)
/// 2. Falls back to local heuristic suggestions if remote fails
/// 3. Always returns suggestions - never crashes on errors
class AiSuggestionService {
  // Remote LLM endpoint configuration
  // TODO: Replace with your actual LLM proxy endpoint
  static const String _remoteLlmEndpoint = 'https://example.com/api/habit-suggestions';
  static const Duration _remoteTimeout = Duration(seconds: 5);
  
  /// Returns 3 temptation bundling suggestions (async with remote LLM + local fallback)
  /// 
  /// Temptation bundling: Pair a habit you need to do with something you enjoy.
  /// 
  /// Flow:
  /// 1. Try remote LLM (5s timeout)
  /// 2. If remote fails/empty → use local heuristics
  /// 3. Always returns 3 suggestions
  Future<List<String>> getTemptationBundleSuggestions({
    required String identity,
    required String habitName,
    required String implementationTime,
    required String implementationLocation,
    String? tinyVersion,
    String? existingTemptationBundle,
    String? existingPreRitual,
    String? existingEnvironmentCue,
    String? existingEnvironmentDistraction,
  }) async {
    try {
      // Attempt remote LLM call
      final remoteSuggestions = await _fetchRemoteSuggestions(
        suggestionType: 'temptation_bundle',
        identity: identity,
        habitName: habitName,
        tinyVersion: tinyVersion,
        implementationTime: implementationTime,
        implementationLocation: implementationLocation,
        existingTemptationBundle: existingTemptationBundle,
        existingPreRitual: existingPreRitual,
        existingEnvironmentCue: existingEnvironmentCue,
        existingEnvironmentDistraction: existingEnvironmentDistraction,
      );
      
      // Use remote suggestions if available
      if (remoteSuggestions.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('✅ Using remote LLM suggestions for temptation bundle');
        }
        return remoteSuggestions;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Remote LLM failed for temptation bundle: $e');
      }
    }
    
    // Fallback to local heuristics
    if (kDebugMode) {
      debugPrint('🔄 Using local fallback for temptation bundle');
    }
    return _localTemptationBundleSuggestions(
      identity: identity,
      habitName: habitName,
      implementationTime: implementationTime,
      implementationLocation: implementationLocation,
    );
  }

  /// Returns 3 pre-habit ritual suggestions (async with remote LLM + local fallback)
  Future<List<String>> getPreHabitRitualSuggestions({
    required String identity,
    required String habitName,
    required String implementationTime,
    required String implementationLocation,
    String? tinyVersion,
    String? existingTemptationBundle,
    String? existingPreRitual,
    String? existingEnvironmentCue,
    String? existingEnvironmentDistraction,
  }) async {
    try {
      final remoteSuggestions = await _fetchRemoteSuggestions(
        suggestionType: 'pre_habit_ritual',
        identity: identity,
        habitName: habitName,
        tinyVersion: tinyVersion,
        implementationTime: implementationTime,
        implementationLocation: implementationLocation,
        existingTemptationBundle: existingTemptationBundle,
        existingPreRitual: existingPreRitual,
        existingEnvironmentCue: existingEnvironmentCue,
        existingEnvironmentDistraction: existingEnvironmentDistraction,
      );
      
      if (remoteSuggestions.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('✅ Using remote LLM suggestions for pre-habit ritual');
        }
        return remoteSuggestions;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Remote LLM failed for pre-habit ritual: $e');
      }
    }
    
    if (kDebugMode) {
      debugPrint('🔄 Using local fallback for pre-habit ritual');
    }
    return _localPreHabitRitualSuggestions(
      identity: identity,
      habitName: habitName,
      implementationTime: implementationTime,
      implementationLocation: implementationLocation,
    );
  }

  /// Returns 3 environment cue suggestions (async with remote LLM + local fallback)
  Future<List<String>> getEnvironmentCueSuggestions({
    required String identity,
    required String habitName,
    required String implementationTime,
    required String implementationLocation,
    String? tinyVersion,
    String? existingTemptationBundle,
    String? existingPreRitual,
    String? existingEnvironmentCue,
    String? existingEnvironmentDistraction,
  }) async {
    try {
      final remoteSuggestions = await _fetchRemoteSuggestions(
        suggestionType: 'environment_cue',
        identity: identity,
        habitName: habitName,
        tinyVersion: tinyVersion,
        implementationTime: implementationTime,
        implementationLocation: implementationLocation,
        existingTemptationBundle: existingTemptationBundle,
        existingPreRitual: existingPreRitual,
        existingEnvironmentCue: existingEnvironmentCue,
        existingEnvironmentDistraction: existingEnvironmentDistraction,
      );
      
      if (remoteSuggestions.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('✅ Using remote LLM suggestions for environment cue');
        }
        return remoteSuggestions;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Remote LLM failed for environment cue: $e');
      }
    }
    
    if (kDebugMode) {
      debugPrint('🔄 Using local fallback for environment cue');
    }
    return _localEnvironmentCueSuggestions(
      identity: identity,
      habitName: habitName,
      implementationTime: implementationTime,
      implementationLocation: implementationLocation,
    );
  }

  /// Returns 3 environment distraction removal suggestions (async with remote LLM + local fallback)
  Future<List<String>> getEnvironmentDistractionSuggestions({
    required String identity,
    required String habitName,
    required String implementationTime,
    required String implementationLocation,
    String? tinyVersion,
    String? existingTemptationBundle,
    String? existingPreRitual,
    String? existingEnvironmentCue,
    String? existingEnvironmentDistraction,
  }) async {
    try {
      final remoteSuggestions = await _fetchRemoteSuggestions(
        suggestionType: 'environment_distraction',
        identity: identity,
        habitName: habitName,
        tinyVersion: tinyVersion,
        implementationTime: implementationTime,
        implementationLocation: implementationLocation,
        existingTemptationBundle: existingTemptationBundle,
        existingPreRitual: existingPreRitual,
        existingEnvironmentCue: existingEnvironmentCue,
        existingEnvironmentDistraction: existingEnvironmentDistraction,
      );
      
      if (remoteSuggestions.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('✅ Using remote LLM suggestions for environment distraction');
        }
        return remoteSuggestions;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Remote LLM failed for environment distraction: $e');
      }
    }
    
    if (kDebugMode) {
      debugPrint('🔄 Using local fallback for environment distraction');
    }
    return _localEnvironmentDistractionSuggestions(
      identity: identity,
      habitName: habitName,
      implementationTime: implementationTime,
      implementationLocation: implementationLocation,
    );
  }

  // ========== REMOTE LLM INTEGRATION ==========

  /// Fetches suggestions from remote LLM endpoint
  /// 
  /// Returns empty list on failure (caller will use local fallback)
  /// 
  /// TODO: Replace endpoint URL with your actual LLM proxy
  /// Expected JSON response format:
  /// {
  ///   "suggestions": ["suggestion 1", "suggestion 2", "suggestion 3"]
  /// }
  Future<List<String>> _fetchRemoteSuggestions({
    required String suggestionType,
    required String identity,
    required String habitName,
    String? tinyVersion,
    required String implementationTime,
    required String implementationLocation,
    String? existingTemptationBundle,
    String? existingPreRitual,
    String? existingEnvironmentCue,
    String? existingEnvironmentDistraction,
  }) async {
    try {
      // Build request payload
      final payload = {
        'suggestion_type': suggestionType,
        'identity': identity,
        'habit_name': habitName,
        'two_minute_version': tinyVersion,
        'time': implementationTime,
        'location': implementationLocation,
        'existing_temptation_bundle': existingTemptationBundle,
        'existing_pre_ritual': existingPreRitual,
        'existing_environment_cue': existingEnvironmentCue,
        'existing_environment_distraction': existingEnvironmentDistraction,
      };

      if (kDebugMode) {
        debugPrint('📡 Attempting remote LLM call for $suggestionType...');
      }

      // Make HTTP POST request with timeout
      // TODO: Replace _remoteLlmEndpoint with your actual LLM proxy URL
      final response = await http.post(
        Uri.parse(_remoteLlmEndpoint),
        headers: {
          'Content-Type': 'application/json',
          // TODO: Add authentication headers if needed
          // 'Authorization': 'Bearer YOUR_API_KEY',
        },
        body: jsonEncode(payload),
      ).timeout(_remoteTimeout);

      // Parse response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        // TODO: Adjust parsing based on your actual API response format
        // Expected format: {"suggestions": ["item1", "item2", "item3"]}
        if (data.containsKey('suggestions') && data['suggestions'] is List) {
          final suggestions = (data['suggestions'] as List)
              .map((item) => item.toString())
              .toList();
          
          if (suggestions.length >= 3) {
            return suggestions.take(3).toList();
          }
        }
      }

      if (kDebugMode) {
        debugPrint('⚠️ Remote LLM returned invalid response (status ${response.statusCode})');
      }
      return [];
      
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('⏱️ Remote LLM timeout after ${_remoteTimeout.inSeconds}s');
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Remote LLM error: $e');
      }
      return [];
    }
  }

  // ========== LOCAL HEURISTIC FALLBACKS ==========
  // These methods contain the original local suggestion logic

  /// Local heuristic temptation bundling suggestions
  List<String> _localTemptationBundleSuggestions({
    required String identity,
    required String habitName,
    required String implementationTime,
    required String implementationLocation,
  }) {
    final timeOfDay = _parseTimeOfDay(implementationTime);
    final habitLower = habitName.toLowerCase();

    // Reading habits
    if (habitLower.contains('read')) {
      if (timeOfDay == 'evening' || timeOfDay == 'night') {
        return [
          'Have a cup of herbal tea while reading',
          'Light a candle and read with soft lighting',
          'Listen to a calm instrumental playlist while you read',
        ];
      } else if (timeOfDay == 'morning') {
        return [
          'Enjoy your morning coffee while reading',
          'Read while having breakfast',
          'Read in a sunny spot with your favourite beverage',
        ];
      } else {
        return [
          'Have a cup of tea or coffee while reading',
          'Read while listening to ambient music',
          'Read in your favourite comfy chair',
        ];
      }
    }

    // Exercise/Movement habits
    if (habitLower.contains('walk') || habitLower.contains('run') || 
        habitLower.contains('exercise') || habitLower.contains('stretch')) {
      return [
        'Listen to your favourite podcast while exercising',
        'Create a pump-up playlist for your workout',
        'Watch an episode of your favourite show while on the treadmill',
      ];
    }

    // Meditation/Mindfulness habits
    if (habitLower.contains('meditate') || habitLower.contains('breathe') ||
        habitLower.contains('mindful')) {
      return [
        'Light incense or a scented candle during meditation',
        'Play nature sounds or calming music',
        'Meditate in your favourite spot with soft lighting',
      ];
    }

    // Writing/Journaling habits
    if (habitLower.contains('write') || habitLower.contains('journal')) {
      return [
        'Write while sipping your favourite hot beverage',
        'Light a candle and play soft background music',
        'Write at a café with a special drink',
      ];
    }

    // Cleaning/Tidying habits
    if (habitLower.contains('clean') || habitLower.contains('tidy') ||
        habitLower.contains('organize')) {
      return [
        'Play your favourite upbeat music while tidying',
        'Listen to a podcast or audiobook while cleaning',
        'Set a timer and make it a game with rewards',
      ];
    }

    // Learning/Study habits
    if (habitLower.contains('learn') || habitLower.contains('study') ||
        habitLower.contains('practice')) {
      return [
        'Study while enjoying your favourite snack',
        'Play focus music (lo-fi, classical) in the background',
        'Work in a cozy spot with good lighting and comfort',
      ];
    }

    // Default generic suggestions based on time of day
    if (timeOfDay == 'morning') {
      return [
        'Pair it with your morning coffee or tea',
        'Do it while listening to energizing music',
        'Combine it with morning sunlight exposure',
      ];
    } else if (timeOfDay == 'evening' || timeOfDay == 'night') {
      return [
        'Pair it with a calming evening beverage',
        'Do it while listening to relaxing music',
        'Combine it with dim, cozy lighting',
      ];
    } else {
      return [
        'Listen to your favourite music or podcast',
        'Enjoy a beverage you love while doing it',
        'Do it in your favourite comfortable spot',
      ];
    }
  }

  /// Local heuristic pre-habit ritual suggestions
  List<String> _localPreHabitRitualSuggestions({
    required String identity,
    required String habitName,
    required String implementationTime,
    required String implementationLocation,
  }) {
    final habitLower = habitName.toLowerCase();

    // Reading habits
    if (habitLower.contains('read')) {
      return [
        'Take 3 slow breaths and open your book to the bookmark',
        'Put your phone in another room, then sit in your reading chair',
        'Write down one thing you\'re curious about, then start reading',
      ];
    }

    // Exercise/Movement habits
    if (habitLower.contains('walk') || habitLower.contains('run') || 
        habitLower.contains('exercise') || habitLower.contains('stretch')) {
      return [
        'Put on your workout clothes immediately when you decide to exercise',
        'Fill your water bottle and take 3 deep breaths',
        'Play your workout playlist and do 5 jumping jacks',
      ];
    }

    // Meditation habits
    if (habitLower.contains('meditate') || habitLower.contains('breathe')) {
      return [
        'Close your eyes and take 3 deep breaths',
        'Roll your shoulders back and relax your jaw',
        'Light a candle or incense before sitting down',
      ];
    }

    // Writing/Journaling habits
    if (habitLower.contains('write') || habitLower.contains('journal')) {
      return [
        'Put your phone on Do Not Disturb mode',
        'Take 3 deep breaths and read your last entry',
        'Close all browser tabs except your writing app',
      ];
    }

    // Cleaning habits
    if (habitLower.contains('clean') || habitLower.contains('tidy')) {
      return [
        'Put on energizing music before you start',
        'Set a visible timer for just 2 minutes',
        'Gather all supplies in one place first',
      ];
    }

    // Learning/Study habits
    if (habitLower.contains('learn') || habitLower.contains('study')) {
      return [
        'Clear your desk and put phone out of sight',
        'Take 3 deep breaths and state your intention aloud',
        'Close all distracting tabs and apps',
      ];
    }

    // Default generic rituals
    return [
      'Take 3 slow, deep breaths before starting',
      'Put your phone in another room or on airplane mode',
      'Say aloud: "I am a person who $identity"',
    ];
  }

  /// Local heuristic environment cue suggestions
  List<String> _localEnvironmentCueSuggestions({
    required String identity,
    required String habitName,
    required String implementationTime,
    required String implementationLocation,
  }) {
    final timeOfDay = _parseTimeOfDay(implementationTime);
    final habitLower = habitName.toLowerCase();
    final locationLower = implementationLocation.toLowerCase();

    // Reading habits
    if (habitLower.contains('read')) {
      if (locationLower.contains('bed') || timeOfDay == 'night') {
        return [
          'Put your book on your pillow at ${_getTimeMinusMinutes(implementationTime, 15)}',
          'Leave your book open on your nightstand',
          'Place your book on top of your phone charger',
        ];
      } else if (locationLower.contains('chair') || locationLower.contains('couch')) {
        return [
          'Place your book on the seat where you usually sit',
          'Put your book on top of the TV remote',
          'Leave your book open on the coffee table',
        ];
      } else {
        return [
          'Put your book where you can\'t miss it in $implementationLocation',
          'Place your book on top of something you use every day',
          'Leave your book open to your current page',
        ];
      }
    }

    // Exercise habits
    if (habitLower.contains('walk') || habitLower.contains('run') || 
        habitLower.contains('exercise') || habitLower.contains('yoga')) {
      return [
        'Lay out your workout clothes the night before',
        'Put your running shoes by the door where you\'ll see them',
        'Leave your yoga mat unrolled in the middle of the room',
      ];
    }

    // Meditation habits
    if (habitLower.contains('meditate') || habitLower.contains('breathe')) {
      return [
        'Set up a dedicated meditation cushion that stays visible',
        'Place a reminder note on your mirror or desk',
        'Put your meditation timer in plain sight',
      ];
    }

    // Writing habits
    if (habitLower.contains('write') || habitLower.contains('journal')) {
      return [
        'Leave your journal open with a pen on top',
        'Put your notebook on your keyboard or phone',
        'Place a "Time to write" sticky note on your desk',
      ];
    }

    // Cleaning habits
    if (habitLower.contains('clean') || habitLower.contains('tidy')) {
      return [
        'Leave cleaning supplies in plain sight',
        'Put a basket in the spot that gets messy',
        'Place a timer or reminder in the target area',
      ];
    }

    // Generic suggestions based on location
    if (locationLower.contains('bed') || locationLower.contains('bedroom')) {
      return [
        'Place your habit trigger item on your pillow',
        'Put a reminder note on your nightstand',
        'Leave the necessary item on your bed',
      ];
    } else if (locationLower.contains('desk') || locationLower.contains('office')) {
      return [
        'Place your habit trigger on your keyboard or mouse',
        'Put a sticky note reminder on your monitor',
        'Leave the necessary item in the center of your desk',
      ];
    } else if (locationLower.contains('kitchen') || locationLower.contains('table')) {
      return [
        'Place your habit trigger on the kitchen counter',
        'Put a reminder note on the fridge',
        'Leave the necessary item on the dining table',
      ];
    }

    // Ultimate fallback
    return [
      'Place your habit trigger where you can\'t miss it',
      'Put a visual reminder in $implementationLocation',
      'Leave everything you need in plain sight',
    ];
  }

  /// Local heuristic environment distraction removal suggestions
  List<String> _localEnvironmentDistractionSuggestions({
    required String identity,
    required String habitName,
    required String implementationTime,
    required String implementationLocation,
  }) {
    final timeOfDay = _parseTimeOfDay(implementationTime);
    final habitLower = habitName.toLowerCase();
    final locationLower = implementationLocation.toLowerCase();

    // Focus-based habits (reading, writing, studying, meditation)
    if (habitLower.contains('read') || habitLower.contains('write') || 
        habitLower.contains('journal') || habitLower.contains('study') ||
        habitLower.contains('meditate') || habitLower.contains('learn')) {
      return [
        'Charge your phone in another room during this time',
        'Log out of social media apps or use website blockers',
        'Turn off TV and close all browser tabs',
      ];
    }

    // Exercise habits
    if (habitLower.contains('walk') || habitLower.contains('run') || 
        habitLower.contains('exercise')) {
      return [
        'Put your phone on Do Not Disturb mode',
        'Remove any comfortable seating from your exercise area',
        'Hide the TV remote before your workout time',
      ];
    }

    // Evening habits (likely competing with screens)
    if (timeOfDay == 'evening' || timeOfDay == 'night') {
      return [
        'Charge your phone in the kitchen overnight',
        'Log out of Netflix and YouTube on weeknights',
        'Set your router to disable Wi-Fi at $implementationTime',
      ];
    }

    // Morning habits (likely competing with snoozing/scrolling)
    if (timeOfDay == 'morning') {
      return [
        'Put your phone across the room so you can\'t snooze',
        'Delete social media apps or move them off your home screen',
        'Use a physical alarm clock instead of your phone',
      ];
    }

    // Location-based suggestions
    if (locationLower.contains('bed') || locationLower.contains('bedroom')) {
      return [
        'Charge your phone outside the bedroom',
        'Remove TV or cover it with a cloth',
        'Keep only habit-related items on your nightstand',
      ];
    } else if (locationLower.contains('desk') || locationLower.contains('office')) {
      return [
        'Use website blockers during habit time',
        'Close all browser tabs except what you need',
        'Put your phone in a drawer or another room',
      ];
    }

    // Generic fallbacks
    return [
      'Put your phone on airplane mode or in another room',
      'Close all apps and browser tabs not related to your habit',
      'Remove or hide any items that tempt you away from this habit',
    ];
  }

  // ========== HELPER METHODS ==========

  /// Parse time string to time of day category
  String _parseTimeOfDay(String time) {
    try {
      final parts = time.split(':');
      if (parts.isEmpty) return 'midday';
      
      final hour = int.parse(parts[0]);
      
      if (hour >= 5 && hour < 12) {
        return 'morning';
      } else if (hour >= 12 && hour < 17) {
        return 'afternoon';
      } else if (hour >= 17 && hour < 21) {
        return 'evening';
      } else {
        return 'night';
      }
    } catch (e) {
      return 'midday';
    }
  }

  /// Get time N minutes before a given time
  String _getTimeMinusMinutes(String time, int minutes) {
    try {
      final parts = time.split(':');
      if (parts.length < 2) return time;
      
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      int newMinute = minute - minutes;
      int newHour = hour;
      
      if (newMinute < 0) {
        newMinute += 60;
        newHour -= 1;
        if (newHour < 0) newHour = 23;
      }
      
      return '${newHour.toString().padLeft(2, '0')}:${newMinute.toString().padLeft(2, '0')}';
    } catch (e) {
      return time;
    }
  }
}
