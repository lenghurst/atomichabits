import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/habit.dart';
import '../models/completion_record.dart';

/// Service for AI-powered reflection coaching
/// Uses Gemini to provide personalized advice based on obstacles and habit context
class ReflectionCoachService {
  GenerativeModel? _model;
  ChatSession? _chatSession;
  bool _isInitialized = false;

  /// System prompt for the reflection coach
  static const String _systemPrompt = '''
You are a compassionate habit coach helping someone reflect on a missed day. Your approach is based on James Clear's "Atomic Habits" methodology.

## Your Role:
- Help users understand WHY they missed their habit (not to blame, but to learn)
- Identify patterns and systemic issues, not character flaws
- Suggest specific, actionable adjustments using the Four Laws
- Be warm, non-judgmental, and encouraging
- Focus on systems over willpower

## Key Principles:
- **Environment > Willpower**: If they forgot, suggest making cues more visible
- **Reduce Friction**: If they were too tired, suggest a smaller version or earlier time
- **Identity Focus**: Remind them that missing once doesn't change who they are
- **Never Miss Twice**: The goal is getting back on track, not perfection
- **1% Better**: Small adjustments compound over time

## Response Guidelines:
- Keep responses concise (2-4 sentences)
- Ask ONE follow-up question if you need more context
- End with one specific, actionable suggestion
- Be warm but practical - avoid excessive validation
- Reference the specific obstacle they mentioned

Remember: You're helping them design better systems, not fix character flaws.
''';

  /// Initialize the service with API key
  Future<void> initialize(String apiKey) async {
    if (apiKey.isEmpty) {
      if (kDebugMode) {
        debugPrint('ReflectionCoachService: No API key provided');
      }
      return;
    }

    try {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 300,
        ),
        systemInstruction: Content.text(_systemPrompt),
      );
      _isInitialized = true;
      if (kDebugMode) {
        debugPrint('ReflectionCoachService: Initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ReflectionCoachService: Failed to initialize: $e');
      }
    }
  }

  /// Check if we have internet connectivity
  Future<bool> _hasConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result.isNotEmpty && !result.contains(ConnectivityResult.none);
    } catch (e) {
      return false;
    }
  }

  /// Start a new coaching conversation for a missed day reflection
  Future<String?> startReflectionConversation({
    required Habit habit,
    required ObstacleOption obstacle,
    String? additionalContext,
    int? mood,
  }) async {
    if (!_isInitialized || _model == null) {
      return _getFallbackResponse(obstacle);
    }

    if (!await _hasConnectivity()) {
      return _getFallbackResponse(obstacle);
    }

    try {
      // Create context message
      final contextParts = <String>[
        'The user missed their habit "${habit.name}" today.',
        'They selected "${obstacle.label}" (${obstacle.emoji}) as what got in the way.',
      ];

      if (additionalContext != null && additionalContext.isNotEmpty) {
        contextParts.add('Additional context they shared: "$additionalContext"');
      }

      if (mood != null) {
        final moodLabel = CompletionRecord.moodLabels[mood] ?? 'unknown';
        contextParts.add('They reported feeling "$moodLabel" (${mood}/5).');
      }

      // Add habit context
      contextParts.add('');
      contextParts.add('Habit context:');
      contextParts.add('- Current streak before miss: ${habit.currentStreak} days');
      contextParts.add('- Scheduled time: ${habit.implementationTime}');
      contextParts.add('- Location: ${habit.implementationLocation}');
      contextParts.add('- 2-minute version: ${habit.tinyVersion}');

      if (habit.temptationBundle != null) {
        contextParts.add('- Temptation bundle: ${habit.temptationBundle}');
      }

      // Check for patterns
      final obstacleFreq = habit.obstacleFrequency;
      if (obstacleFreq.isNotEmpty) {
        final topObstacle = obstacleFreq.entries.reduce(
          (a, b) => a.value > b.value ? a : b,
        );
        if (topObstacle.value >= 2) {
          contextParts.add('');
          contextParts.add('Pattern noticed: They\'ve missed due to "${topObstacle.key}" ${topObstacle.value} times before.');
        }
      }

      final prompt = contextParts.join('\n');

      // Start chat session
      _chatSession = _model!.startChat();
      final response = await _chatSession!.sendMessage(Content.text(prompt));

      return response.text;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ReflectionCoachService: Error in conversation: $e');
      }
      return _getFallbackResponse(obstacle);
    }
  }

  /// Continue an existing conversation
  Future<String?> sendMessage(String message) async {
    if (_chatSession == null) {
      return null;
    }

    if (!await _hasConnectivity()) {
      return "I'm offline right now. Try again when you have internet.";
    }

    try {
      final response = await _chatSession!.sendMessage(Content.text(message));
      return response.text;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ReflectionCoachService: Error sending message: $e');
      }
      return "Sorry, I couldn't process that. Please try again.";
    }
  }

  /// Get a one-shot coaching response without starting a conversation
  Future<String?> getQuickCoachingTip({
    required Habit habit,
    required String obstacleLabel,
  }) async {
    if (!_isInitialized || _model == null) {
      return null;
    }

    if (!await _hasConnectivity()) {
      return null;
    }

    try {
      final prompt = '''
The user missed their habit "${habit.name}" because of: "$obstacleLabel".
Their 2-minute version is: "${habit.tinyVersion}"
Give ONE specific, actionable suggestion to prevent this next time.
Keep it to 1-2 sentences, no fluff.
''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ReflectionCoachService: Error getting quick tip: $e');
      }
      return null;
    }
  }

  /// Fallback response when AI is not available
  String _getFallbackResponse(ObstacleOption obstacle) {
    return obstacle.aiTip;
  }

  /// End the current conversation
  void endConversation() {
    _chatSession = null;
  }

  /// Check if the service is ready to use
  bool get isReady => _isInitialized && _model != null;
}

/// Singleton instance for app-wide use
class ReflectionCoach {
  static final ReflectionCoachService _instance = ReflectionCoachService();

  static ReflectionCoachService get instance => _instance;

  /// Initialize with API key from environment or config
  static Future<void> initialize(String apiKey) async {
    await _instance.initialize(apiKey);
  }
}
