/// Local AI-like suggestion service for Atomic Habits principles
/// 
/// This service provides contextual suggestions for:
/// - Temptation bundling (pairing habits with enjoyable activities)
/// - Pre-habit rituals (mental preparation before action)
/// - Environment cues (visual triggers to start habits)
/// - Environment distractions (friction to remove)
///
/// FUTURE ITERATION: Replace the heuristic methods below with real LLM API calls
/// (e.g., OpenAI, Google Gemini, Anthropic Claude) to generate personalized,
/// natural language suggestions based on user context.
class AiSuggestionService {
  /// Returns 3 temptation bundling suggestions
  /// 
  /// Temptation bundling: Pair a habit you need to do with something you enjoy.
  /// Strategy: Match time of day, habit type, and identity to suggest enjoyable pairings.
  List<String> getTemptationBundleSuggestions({
    required String identity,
    required String habitName,
    required String implementationTime,
    required String implementationLocation,
  }) {
    final timeOfDay = _parseTimeOfDay(implementationTime);
    final habitLower = habitName.toLowerCase();
    // locationLower reserved for future location-based suggestions

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

  /// Returns 3 pre-habit ritual suggestions
  /// 
  /// Pre-habit rituals: 10-30 second actions that prime your brain for the habit.
  /// Strategy: Suggest simple, calming actions appropriate for the habit type.
  List<String> getPreHabitRitualSuggestions({
    required String identity,
    required String habitName,
    required String implementationTime,
    required String implementationLocation,
  }) {
    final habitLower = habitName.toLowerCase();
    // locationLower reserved for future location-based suggestions

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

  /// Returns 3 environment cue suggestions
  /// 
  /// Environment cues: Make the habit obvious by designing visible triggers.
  /// Strategy: Suggest placement strategies based on location and time.
  List<String> getEnvironmentCueSuggestions({
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

  /// Returns 3 environment distraction removal suggestions
  /// 
  /// Remove friction and distractions that compete with your habit.
  /// Strategy: Suggest barriers to common distractions based on habit type.
  List<String> getEnvironmentDistractionSuggestions({
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
        'Set your router to disable Wi-Fi at ${implementationTime}',
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

  // Helper: Parse time string to time of day category
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

  // Helper: Get time N minutes before a given time
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
