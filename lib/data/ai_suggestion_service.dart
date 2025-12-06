import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import 'models/habit.dart';

/// AI-powered suggestion service for Atomic Habits principles
///
/// This service provides contextual suggestions with:
/// - Remote LLM integration (with fallback to local heuristics)
/// - Temptation bundling (pairing habits with enjoyable activities)
/// - Pre-habit rituals (mental preparation before action)
/// - Environment cues (visual triggers to start habits)
/// - Environment distractions (friction to remove)
///
/// BAD HABIT SUPPORT (Change / Reduce Habit Toolkit):
/// - Substitution suggestions (swap bad behavior for healthier alternative)
/// - Cue firewall suggestions (avoid/weaken triggers)
/// - Bright-line rule suggestions ("I don't..." rules)
/// - Friction/guardrail suggestions (add steps to bad habits)
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

  // ========== BAD HABIT SUGGESTIONS (Change / Reduce Habit Toolkit) ==========

  /// Returns 3 substitution behavior suggestions for bad habits
  ///
  /// Substitution: Replace the bad habit with a healthier behavior
  /// that meets the same underlying need.
  Future<List<String>> getSubstitutionSuggestions({
    required String badHabitName,
    String? underlyingNeed,
    String? currentTriggers,
  }) async {
    try {
      final remoteSuggestions = await _fetchBadHabitSuggestions(
        suggestionType: 'substitution',
        badHabitName: badHabitName,
        underlyingNeed: underlyingNeed,
        currentTriggers: currentTriggers,
      );

      if (remoteSuggestions.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('Using remote LLM suggestions for substitution');
        }
        return remoteSuggestions;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Remote LLM failed for substitution: $e');
      }
    }

    if (kDebugMode) {
      debugPrint('Using local fallback for substitution');
    }
    return _localSubstitutionSuggestions(
      badHabitName: badHabitName,
      underlyingNeed: underlyingNeed,
    );
  }

  /// Returns 3 cue firewall suggestions for bad habits
  ///
  /// Cue Firewall: Strategies to avoid or weaken triggers (Vietnam study concept)
  Future<List<String>> getCueFirewallSuggestions({
    required String badHabitName,
    CueType? cueType,
    String? specificTrigger,
  }) async {
    try {
      final remoteSuggestions = await _fetchBadHabitSuggestions(
        suggestionType: 'cue_firewall',
        badHabitName: badHabitName,
        cueType: cueType?.name,
        specificTrigger: specificTrigger,
      );

      if (remoteSuggestions.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('Using remote LLM suggestions for cue firewall');
        }
        return remoteSuggestions;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Remote LLM failed for cue firewall: $e');
      }
    }

    if (kDebugMode) {
      debugPrint('Using local fallback for cue firewall');
    }
    return _localCueFirewallSuggestions(
      badHabitName: badHabitName,
      cueType: cueType,
      specificTrigger: specificTrigger,
    );
  }

  /// Returns 3 bright-line rule suggestions for bad habits
  ///
  /// Bright-line rules: Crisp "I don't..." rules with progressive extremism
  Future<List<String>> getBrightLineRuleSuggestions({
    required String badHabitName,
    RuleIntensity? desiredIntensity,
  }) async {
    try {
      final remoteSuggestions = await _fetchBadHabitSuggestions(
        suggestionType: 'bright_line_rule',
        badHabitName: badHabitName,
        intensity: desiredIntensity?.name,
      );

      if (remoteSuggestions.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('Using remote LLM suggestions for bright-line rules');
        }
        return remoteSuggestions;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Remote LLM failed for bright-line rules: $e');
      }
    }

    if (kDebugMode) {
      debugPrint('Using local fallback for bright-line rules');
    }
    return _localBrightLineRuleSuggestions(
      badHabitName: badHabitName,
      desiredIntensity: desiredIntensity,
    );
  }

  /// Returns 3 friction/guardrail suggestions for bad habits
  ///
  /// Friction: Add steps between cue and bad behavior (checkout line pattern)
  Future<List<String>> getFrictionSuggestions({
    required String badHabitName,
    String? currentLocation,
  }) async {
    try {
      final remoteSuggestions = await _fetchBadHabitSuggestions(
        suggestionType: 'friction',
        badHabitName: badHabitName,
        location: currentLocation,
      );

      if (remoteSuggestions.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('Using remote LLM suggestions for friction');
        }
        return remoteSuggestions;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Remote LLM failed for friction: $e');
      }
    }

    if (kDebugMode) {
      debugPrint('Using local fallback for friction');
    }
    return _localFrictionSuggestions(
      badHabitName: badHabitName,
      currentLocation: currentLocation,
    );
  }

  /// Fetch bad habit suggestions from remote LLM
  Future<List<String>> _fetchBadHabitSuggestions({
    required String suggestionType,
    required String badHabitName,
    String? underlyingNeed,
    String? currentTriggers,
    String? cueType,
    String? specificTrigger,
    String? intensity,
    String? location,
  }) async {
    try {
      final payload = {
        'suggestion_type': suggestionType,
        'bad_habit_name': badHabitName,
        'underlying_need': underlyingNeed,
        'current_triggers': currentTriggers,
        'cue_type': cueType,
        'specific_trigger': specificTrigger,
        'intensity': intensity,
        'location': location,
      };

      if (kDebugMode) {
        debugPrint('Attempting remote LLM call for bad habit $suggestionType...');
      }

      final response = await http.post(
        Uri.parse(_remoteLlmEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(_remoteTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data.containsKey('suggestions') && data['suggestions'] is List) {
          final suggestions = (data['suggestions'] as List)
              .map((item) => item.toString())
              .toList();
          if (suggestions.length >= 3) {
            return suggestions.take(3).toList();
          }
        }
      }
      return [];
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('Remote LLM timeout for bad habit suggestions');
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Remote LLM error for bad habit suggestions: $e');
      }
      return [];
    }
  }

  // ========== LOCAL BAD HABIT SUGGESTION FALLBACKS ==========

  /// Local substitution suggestions based on common bad habits
  List<String> _localSubstitutionSuggestions({
    required String badHabitName,
    String? underlyingNeed,
  }) {
    final habitLower = badHabitName.toLowerCase();
    final needLower = underlyingNeed?.toLowerCase() ?? '';

    // Alcohol-related habits
    if (habitLower.contains('drink') || habitLower.contains('alcohol') ||
        habitLower.contains('beer') || habitLower.contains('wine')) {
      return [
        'Drink sparkling water with lime instead',
        'Try a mocktail or non-alcoholic beer',
        'Have herbal tea or kombucha for the ritual feeling',
      ];
    }

    // Smoking habits
    if (habitLower.contains('smok') || habitLower.contains('cigarette') ||
        habitLower.contains('vape')) {
      return [
        'Chew gum or use a toothpick when cravings hit',
        'Take 5 deep breaths instead of a smoke break',
        'Go for a short walk around the block',
      ];
    }

    // Social media / phone scrolling
    if (habitLower.contains('scroll') || habitLower.contains('social media') ||
        habitLower.contains('phone') || habitLower.contains('instagram') ||
        habitLower.contains('tiktok') || habitLower.contains('twitter')) {
      return [
        'Read a physical book or magazine instead',
        'Do a quick stretch or breathing exercise',
        'Write in a notebook or journal',
      ];
    }

    // Junk food / snacking
    if (habitLower.contains('snack') || habitLower.contains('junk') ||
        habitLower.contains('candy') || habitLower.contains('chips') ||
        habitLower.contains('sugar')) {
      return [
        'Eat fruit, nuts, or dark chocolate instead',
        'Drink a glass of water first (often thirst is mistaken for hunger)',
        'Chew gum or brush your teeth to reset your palate',
      ];
    }

    // Procrastination
    if (habitLower.contains('procrastin') || habitLower.contains('delay') ||
        habitLower.contains('avoid')) {
      return [
        'Do just 2 minutes of the task you\'re avoiding',
        'Work on a different task from your list',
        'Write down what you\'re avoiding and why',
      ];
    }

    // Nail biting / nervous habits
    if (habitLower.contains('nail') || habitLower.contains('biting') ||
        habitLower.contains('pick')) {
      return [
        'Keep a stress ball or fidget toy nearby',
        'Apply bitter nail polish as a reminder',
        'Take deep breaths and notice the urge without acting',
      ];
    }

    // Need-based suggestions
    if (needLower.contains('stress') || needLower.contains('relax')) {
      return [
        'Try deep breathing or a 5-minute meditation',
        'Go for a walk or do light stretching',
        'Listen to calming music or nature sounds',
      ];
    }

    if (needLower.contains('bored') || needLower.contains('stimulat')) {
      return [
        'Learn something new (watch an educational video)',
        'Call or text a friend',
        'Do a quick creative activity (doodle, write, play music)',
      ];
    }

    if (needLower.contains('social') || needLower.contains('connect')) {
      return [
        'Call or video chat with a friend instead',
        'Join an online community around a positive interest',
        'Write a message to someone you haven\'t talked to in a while',
      ];
    }

    // Generic fallback
    return [
      'Replace the habit with a 5-minute walk',
      'Do 10 deep breaths when you feel the urge',
      'Drink a glass of water and wait 10 minutes',
    ];
  }

  /// Local cue firewall suggestions based on cue type
  List<String> _localCueFirewallSuggestions({
    required String badHabitName,
    CueType? cueType,
    String? specificTrigger,
  }) {
    // Suggestions based on cue type
    switch (cueType) {
      case CueType.time:
        return [
          'Schedule a different activity during that time',
          'Change your routine to avoid that trigger time',
          'Set an alarm to remind you of your alternative behavior',
        ];
      case CueType.place:
        return [
          'Avoid that location when possible',
          'Change the layout or use of that space',
          'Create a new association with that place (do something positive there)',
        ];
      case CueType.people:
        return [
          'Suggest alternative activities when with these people',
          'Limit time with people who trigger the habit',
          'Be upfront about your goals with supportive friends',
        ];
      case CueType.emotion:
        return [
          'Identify the emotion before acting on it',
          'Have a pre-planned response for that emotional state',
          'Practice recognizing the feeling without reacting',
        ];
      case CueType.action:
        return [
          'Break the chain by adding a pause after the action',
          'Replace what follows that action with something positive',
          'Change the sequence of your routine',
        ];
      default:
        break;
    }

    // Habit-specific suggestions
    final habitLower = badHabitName.toLowerCase();

    if (habitLower.contains('drink') || habitLower.contains('alcohol')) {
      return [
        'Avoid walking past bars or liquor stores',
        'Don\'t keep alcohol at home',
        'Plan alcohol-free activities with friends',
      ];
    }

    if (habitLower.contains('scroll') || habitLower.contains('phone')) {
      return [
        'Remove social media apps from your phone',
        'Charge your phone in another room',
        'Use app blockers during vulnerable times',
      ];
    }

    if (habitLower.contains('snack') || habitLower.contains('junk')) {
      return [
        'Don\'t buy junk food (if it\'s not there, you can\'t eat it)',
        'Store snacks out of sight in hard-to-reach places',
        'Avoid the snack aisle when grocery shopping',
      ];
    }

    // Generic fallback
    return [
      'Identify your top 3 triggers and write them down',
      'Remove or hide items associated with the habit',
      'Change your environment to break the pattern',
    ];
  }

  /// Local bright-line rule suggestions based on intensity
  List<String> _localBrightLineRuleSuggestions({
    required String badHabitName,
    RuleIntensity? desiredIntensity,
  }) {
    final habitLower = badHabitName.toLowerCase();

    // Alcohol rules
    if (habitLower.contains('drink') || habitLower.contains('alcohol')) {
      switch (desiredIntensity) {
        case RuleIntensity.gentle:
          return [
            'I don\'t drink more than 2 drinks in one sitting',
            'I don\'t drink alone at home',
            'I don\'t drink before 6 PM',
          ];
        case RuleIntensity.moderate:
          return [
            'I don\'t drink on weekdays',
            'I don\'t drink at home',
            'I don\'t drink more than once a week',
          ];
        case RuleIntensity.strict:
          return [
            'I don\'t drink unless it\'s a special occasion',
            'I don\'t keep alcohol in my house',
            'I don\'t drink in any situation where I\'m stressed',
          ];
        case RuleIntensity.absolute:
          return [
            'I don\'t drink alcohol, period',
            'I am someone who doesn\'t drink',
            'I never drink, no matter the occasion',
          ];
        default:
          break;
      }
    }

    // Social media / phone rules
    if (habitLower.contains('scroll') || habitLower.contains('phone') ||
        habitLower.contains('social media')) {
      switch (desiredIntensity) {
        case RuleIntensity.gentle:
          return [
            'I don\'t check social media before breakfast',
            'I don\'t scroll for more than 15 minutes at a time',
            'I don\'t use my phone in bed',
          ];
        case RuleIntensity.moderate:
          return [
            'I don\'t check social media before noon',
            'I don\'t use my phone during meals',
            'I don\'t scroll after 9 PM',
          ];
        case RuleIntensity.strict:
          return [
            'I don\'t have social media apps on my phone',
            'I only check social media on my computer, once per day',
            'I don\'t touch my phone for the first hour after waking',
          ];
        case RuleIntensity.absolute:
          return [
            'I don\'t use social media',
            'I am someone who doesn\'t scroll',
            'I never check social media',
          ];
        default:
          break;
      }
    }

    // Junk food rules
    if (habitLower.contains('snack') || habitLower.contains('junk') ||
        habitLower.contains('sugar')) {
      switch (desiredIntensity) {
        case RuleIntensity.gentle:
          return [
            'I don\'t eat junk food before lunch',
            'I don\'t eat snacks while watching TV',
            'I don\'t buy candy at checkout',
          ];
        case RuleIntensity.moderate:
          return [
            'I don\'t eat junk food on weekdays',
            'I don\'t keep junk food at home',
            'I don\'t eat sugar after 6 PM',
          ];
        case RuleIntensity.strict:
          return [
            'I don\'t buy junk food, ever',
            'I don\'t eat processed snacks',
            'I only eat whole foods',
          ];
        case RuleIntensity.absolute:
          return [
            'I don\'t eat junk food, period',
            'I am someone who doesn\'t eat processed food',
            'I never eat sugar',
          ];
        default:
          break;
      }
    }

    // Generic rules based on intensity
    switch (desiredIntensity) {
      case RuleIntensity.gentle:
        return [
          'I don\'t do this habit before noon',
          'I don\'t do this habit more than once a day',
          'I don\'t do this habit when I\'m stressed',
        ];
      case RuleIntensity.moderate:
        return [
          'I don\'t do this habit on weekdays',
          'I don\'t do this habit alone',
          'I don\'t do this habit at home',
        ];
      case RuleIntensity.strict:
        return [
          'I only do this habit once a week maximum',
          'I don\'t do this habit unless planned in advance',
          'I don\'t do this habit in my usual environment',
        ];
      case RuleIntensity.absolute:
        return [
          'I don\'t do this habit, period',
          'I am someone who doesn\'t do this',
          'I never engage in this behavior',
        ];
      default:
        return [
          'I don\'t do this habit on weekdays',
          'I don\'t do this habit when I\'m alone',
          'I don\'t do this habit after 8 PM',
        ];
    }
  }

  /// Local friction suggestions (impulse guardrails)
  List<String> _localFrictionSuggestions({
    required String badHabitName,
    String? currentLocation,
  }) {
    final habitLower = badHabitName.toLowerCase();
    final locationLower = currentLocation?.toLowerCase() ?? '';

    // Alcohol friction
    if (habitLower.contains('drink') || habitLower.contains('alcohol')) {
      return [
        'Don\'t keep alcohol at home - you\'ll have to go out to get it',
        'Keep alcohol locked away or in an inconvenient place',
        'Wait 10 minutes before having a drink (the urge often passes)',
      ];
    }

    // Phone / social media friction
    if (habitLower.contains('scroll') || habitLower.contains('phone')) {
      return [
        'Delete apps from your phone (use browser only - adds friction)',
        'Log out after each use so you have to log in again',
        'Put your phone in another room when at home',
      ];
    }

    // Snacking friction
    if (habitLower.contains('snack') || habitLower.contains('junk')) {
      return [
        'Keep snacks in a hard-to-reach cabinet or the garage',
        'Don\'t buy snacks when grocery shopping',
        'Require yourself to eat at a table, not while doing other things',
      ];
    }

    // Smoking friction
    if (habitLower.contains('smok') || habitLower.contains('cigarette')) {
      return [
        'Don\'t carry cigarettes on you - keep them locked away',
        'Require yourself to go outside and walk to smoke',
        'Wait 5 minutes before lighting up (the urge may pass)',
      ];
    }

    // Location-based friction
    if (locationLower.contains('home')) {
      return [
        'Store items for this habit in the garage or basement',
        'Add a physical lock or barrier to access',
        'Put a sticky note asking "Do you really need this?" on the item',
      ];
    }

    if (locationLower.contains('work') || locationLower.contains('office')) {
      return [
        'Leave items at home that trigger this habit',
        'Use website blockers during work hours',
        'Keep your workspace clear of temptation',
      ];
    }

    // Generic friction suggestions
    return [
      'Add steps between the cue and the behavior',
      'Make the habit physically harder to do (hide, lock, relocate)',
      'Require a waiting period before engaging in the habit',
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
