import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// AI Onboarding Service - Discovery Call Experience
///
/// Provides a conversational AI experience that acts as an Atomic Habits expert,
/// guiding users through a discovery process to understand their goals and
/// automatically fill in onboarding fields.
///
/// Based on James Clear's Atomic Habits principles:
/// - Identity-based habits ("Who do you want to become?")
/// - The 2-minute rule (Start tiny)
/// - Implementation intentions (When and where)
/// - The 4 Laws of Behavior Change (Make it obvious, attractive, easy, satisfying)
///
/// ARCHITECTURE:
/// 1. Conversational flow with contextual questions
/// 2. Parses responses to extract onboarding fields
/// 3. Remote LLM with local fallback for parsing
class AiOnboardingService {
  // Remote LLM endpoint configuration
  static const String _remoteLlmEndpoint = 'https://example.com/api/onboarding-chat';
  static const Duration _remoteTimeout = Duration(seconds: 10);

  /// System prompt for the Atomic Habits expert persona
  static const String systemPrompt = '''
You are an expert Atomic Habits coach, deeply knowledgeable about James Clear's book and methodology. Your role is to guide someone through setting up their first habit in a warm, consultative discovery call format.

CORE PRINCIPLES TO EMBODY:
1. Identity-First: Always start with WHO they want to become, not WHAT they want to do
2. Start Tiny: Help them find a 2-minute version that's "so easy you can't say no"
3. Implementation Intentions: Be specific about WHEN and WHERE
4. Make It Attractive: Explore temptation bundling and enjoyable pairings
5. Environment Design: Help them make the habit obvious and friction-free

CONVERSATION FLOW:
1. Welcome warmly and ask about their aspirations/who they want to become
2. Explore what habit aligns with that identity
3. Help them create a tiny (2-minute) version
4. Nail down specific time and location
5. Optionally explore: temptation bundling, environment cues, pre-habit rituals

COMMUNICATION STYLE:
- Warm, encouraging, non-judgmental
- Ask ONE question at a time (don't overwhelm)
- Use examples from the book when helpful
- Celebrate their insights and progress
- Keep responses concise (2-3 sentences max for questions)
- Quote James Clear occasionally: "Every action is a vote for the type of person you wish to become"

IMPORTANT GUIDELINES:
- Never shame or criticize past failures
- Focus on small wins and showing up
- Emphasize identity over outcomes
- Be genuinely curious about their life context
- Help them see this as the start of something small but meaningful

When you have gathered enough information, include a JSON block at the end of your response with the extracted fields:
```json
{
  "name": "extracted name if mentioned",
  "identity": "I am someone who...",
  "habitName": "the habit",
  "tinyVersion": "2-minute version",
  "implementationTime": "HH:MM",
  "implementationLocation": "where",
  "temptationBundle": "optional pairing",
  "preHabitRitual": "optional ritual",
  "environmentCue": "optional cue",
  "environmentDistraction": "optional distraction to remove",
  "isComplete": true
}
```

Only set "isComplete": true when you have at minimum: identity, habitName, tinyVersion, implementationTime, and implementationLocation.
''';

  /// Discovery call questions for local fallback
  static const List<Map<String, String>> discoveryQuestions = [
    {
      'question': "Welcome! I'm here to help you build a lasting habit using the principles from Atomic Habits. Before we dive into what you want to do, let's start with something more important: Who do you want to become? What kind of person do you aspire to be?",
      'field': 'identity',
      'hint': 'Think about your ideal self - "I want to be someone who..." or "I am a person who..."'
    },
    {
      'question': "That's a powerful identity to work toward! Now, what's one small habit that would be evidence of that identity? What would that person do regularly?",
      'field': 'habitName',
      'hint': 'E.g., "Read every day", "Exercise regularly", "Meditate daily"'
    },
    {
      'question': "Perfect. Now here's the key from Atomic Habits - we need to make this so tiny you can't say no. What's a 2-minute version of this habit? Something so easy it feels almost silly.",
      'field': 'tinyVersion',
      'hint': 'E.g., "Read one page", "Do 2 pushups", "Meditate for 60 seconds"'
    },
    {
      'question': "Excellent! James Clear says 'Implementation intentions' are crucial - being specific about when and where. What time of day works best for this habit?",
      'field': 'implementationTime',
      'hint': 'E.g., "7:00 AM", "22:00", "Right after work"'
    },
    {
      'question': "And where will you do this? Being specific about location helps your brain create automatic triggers.",
      'field': 'implementationLocation',
      'hint': 'E.g., "In my bedroom", "At my desk", "On the couch", "In the kitchen"'
    },
    {
      'question': "To make this habit more attractive, would you like to pair it with something you enjoy? This is called 'temptation bundling' - linking a habit you need with something you want. (Optional)",
      'field': 'temptationBundle',
      'hint': 'E.g., "Listen to my favorite podcast while walking", "Have tea while reading"'
    },
    {
      'question': "Last question: Is there anything in your environment you could set up as a cue, or any distraction you should remove to make this easier? (Optional)",
      'field': 'environmentCue',
      'hint': 'E.g., "Put book on pillow", "Charge phone in another room"'
    },
  ];

  /// Chat history for context
  List<Map<String, String>> _chatHistory = [];

  /// Extracted fields from conversation
  Map<String, String?> _extractedFields = {
    'name': null,
    'identity': null,
    'habitName': null,
    'tinyVersion': null,
    'implementationTime': null,
    'implementationLocation': null,
    'temptationBundle': null,
    'preHabitRitual': null,
    'environmentCue': null,
    'environmentDistraction': null,
  };

  /// Current question index for local fallback
  int _currentQuestionIndex = 0;

  /// Whether onboarding is complete
  bool _isComplete = false;

  /// Getters
  Map<String, String?> get extractedFields => Map.unmodifiable(_extractedFields);
  bool get isComplete => _isComplete;
  List<Map<String, String>> get chatHistory => List.unmodifiable(_chatHistory);

  /// Reset the service for a new conversation
  void reset() {
    _chatHistory = [];
    _extractedFields = {
      'name': null,
      'identity': null,
      'habitName': null,
      'tinyVersion': null,
      'implementationTime': null,
      'implementationLocation': null,
      'temptationBundle': null,
      'preHabitRitual': null,
      'environmentCue': null,
      'environmentDistraction': null,
    };
    _currentQuestionIndex = 0;
    _isComplete = false;
  }

  /// Get the initial greeting message
  String getInitialMessage() {
    final greeting = discoveryQuestions[0]['question']!;
    _chatHistory.add({'role': 'assistant', 'content': greeting});
    return greeting;
  }

  /// Send a message and get a response
  /// Returns the AI response
  Future<String> sendMessage(String userMessage) async {
    // Add user message to history
    _chatHistory.add({'role': 'user', 'content': userMessage});

    try {
      // Try remote LLM first
      final remoteResponse = await _sendToRemoteLLM(userMessage);
      if (remoteResponse != null) {
        _chatHistory.add({'role': 'assistant', 'content': remoteResponse});
        return remoteResponse;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Remote LLM failed for onboarding: $e');
      }
    }

    // Fallback to local guided flow
    return _handleLocalFlow(userMessage);
  }

  /// Handle local guided conversation flow
  String _handleLocalFlow(String userMessage) {
    // Extract field from current question
    if (_currentQuestionIndex < discoveryQuestions.length) {
      final currentField = discoveryQuestions[_currentQuestionIndex]['field']!;

      // Parse and store the response
      _extractFieldFromResponse(currentField, userMessage);

      // Move to next question
      _currentQuestionIndex++;
    }

    // Check if we have enough fields for completion
    _checkCompletion();

    // Get next question or completion message
    String response;
    if (_isComplete) {
      response = _getCompletionMessage();
    } else if (_currentQuestionIndex < discoveryQuestions.length) {
      // Get acknowledgment + next question
      response = _getAcknowledgment(userMessage) + '\n\n' + discoveryQuestions[_currentQuestionIndex]['question']!;
    } else {
      // All questions asked but missing required fields
      response = _getMissingFieldsPrompt();
    }

    _chatHistory.add({'role': 'assistant', 'content': response});
    return response;
  }

  /// Extract field value from user response
  void _extractFieldFromResponse(String field, String response) {
    String cleanedResponse = response.trim();

    switch (field) {
      case 'identity':
        // Format as identity statement if needed
        if (!cleanedResponse.toLowerCase().startsWith('i am') &&
            !cleanedResponse.toLowerCase().startsWith('i want to be')) {
          cleanedResponse = 'I am someone who $cleanedResponse';
        }
        _extractedFields['identity'] = cleanedResponse;
        break;

      case 'implementationTime':
        // Try to extract time format
        _extractedFields['implementationTime'] = _parseTime(cleanedResponse);
        break;

      default:
        // Direct assignment for other fields
        if (cleanedResponse.isNotEmpty &&
            cleanedResponse.toLowerCase() != 'skip' &&
            cleanedResponse.toLowerCase() != 'no' &&
            cleanedResponse.toLowerCase() != 'none') {
          _extractedFields[field] = cleanedResponse;
        }
    }
  }

  /// Parse time from various formats
  String _parseTime(String input) {
    // Try to extract HH:MM format
    final timeRegex = RegExp(r'(\d{1,2})[:\.]?(\d{2})?\s*(am|pm)?', caseSensitive: false);
    final match = timeRegex.firstMatch(input);

    if (match != null) {
      int hour = int.parse(match.group(1)!);
      int minute = int.tryParse(match.group(2) ?? '0') ?? 0;
      final amPm = match.group(3)?.toLowerCase();

      // Handle AM/PM
      if (amPm == 'pm' && hour != 12) {
        hour += 12;
      } else if (amPm == 'am' && hour == 12) {
        hour = 0;
      }

      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    }

    // Default fallback
    return '09:00';
  }

  /// Get acknowledgment based on user response
  String _getAcknowledgment(String userResponse) {
    final acknowledgments = [
      "That's wonderful!",
      "I love that vision.",
      "That's a great choice.",
      "Perfect!",
      "Excellent thinking.",
      "That makes sense.",
    ];

    return acknowledgments[DateTime.now().millisecond % acknowledgments.length];
  }

  /// Check if we have enough fields to complete onboarding
  void _checkCompletion() {
    _isComplete = _extractedFields['identity'] != null &&
        _extractedFields['habitName'] != null &&
        _extractedFields['tinyVersion'] != null &&
        _extractedFields['implementationTime'] != null &&
        _extractedFields['implementationLocation'] != null;
  }

  /// Get completion message
  String _getCompletionMessage() {
    return '''Fantastic! You've got everything you need to start building a powerful habit.

Here's your plan:
- Identity: ${_extractedFields['identity']}
- Habit: ${_extractedFields['habitName']}
- Tiny version: ${_extractedFields['tinyVersion']}
- When: ${_extractedFields['implementationTime']}
- Where: ${_extractedFields['implementationLocation']}
${_extractedFields['temptationBundle'] != null ? '- Bundled with: ${_extractedFields['temptationBundle']}' : ''}

Remember James Clear's words: "You don't rise to the level of your goals. You fall to the level of your systems."

You've just created your system. Now tap "Start Building" to begin your journey!''';
  }

  /// Get prompt for missing fields
  String _getMissingFieldsPrompt() {
    final missingFields = <String>[];

    if (_extractedFields['identity'] == null) missingFields.add('identity');
    if (_extractedFields['habitName'] == null) missingFields.add('habit name');
    if (_extractedFields['tinyVersion'] == null) missingFields.add('2-minute version');
    if (_extractedFields['implementationTime'] == null) missingFields.add('time');
    if (_extractedFields['implementationLocation'] == null) missingFields.add('location');

    if (missingFields.isEmpty) {
      _isComplete = true;
      return _getCompletionMessage();
    }

    return "We're almost there! Could you tell me more about your ${missingFields.first}?";
  }

  /// Send message to remote LLM
  Future<String?> _sendToRemoteLLM(String userMessage) async {
    try {
      final payload = {
        'system_prompt': systemPrompt,
        'messages': _chatHistory,
        'user_message': userMessage,
      };

      final response = await http.post(
        Uri.parse(_remoteLlmEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(_remoteTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        if (data.containsKey('response')) {
          final aiResponse = data['response'] as String;

          // Try to extract JSON fields from response
          _extractFieldsFromLLMResponse(aiResponse);

          return aiResponse;
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Remote LLM error: $e');
      }
      return null;
    }
  }

  /// Extract fields from LLM response (looks for JSON block)
  void _extractFieldsFromLLMResponse(String response) {
    try {
      // Look for JSON block in response
      final jsonMatch = RegExp(r'```json\s*([\s\S]*?)\s*```').firstMatch(response);

      if (jsonMatch != null) {
        final jsonStr = jsonMatch.group(1)!;
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;

        // Update extracted fields
        if (data['name'] != null) _extractedFields['name'] = data['name'];
        if (data['identity'] != null) _extractedFields['identity'] = data['identity'];
        if (data['habitName'] != null) _extractedFields['habitName'] = data['habitName'];
        if (data['tinyVersion'] != null) _extractedFields['tinyVersion'] = data['tinyVersion'];
        if (data['implementationTime'] != null) _extractedFields['implementationTime'] = data['implementationTime'];
        if (data['implementationLocation'] != null) _extractedFields['implementationLocation'] = data['implementationLocation'];
        if (data['temptationBundle'] != null) _extractedFields['temptationBundle'] = data['temptationBundle'];
        if (data['preHabitRitual'] != null) _extractedFields['preHabitRitual'] = data['preHabitRitual'];
        if (data['environmentCue'] != null) _extractedFields['environmentCue'] = data['environmentCue'];
        if (data['environmentDistraction'] != null) _extractedFields['environmentDistraction'] = data['environmentDistraction'];

        if (data['isComplete'] == true) {
          _isComplete = true;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error parsing LLM JSON: $e');
      }
    }
  }

  /// Parse user name from conversation if mentioned
  String? parseNameFromConversation() {
    for (final message in _chatHistory) {
      if (message['role'] == 'user') {
        final content = message['content']!.toLowerCase();

        // Look for "my name is X" or "I'm X" patterns
        final namePatterns = [
          RegExp(r"my name is (\w+)", caseSensitive: false),
          RegExp(r"i'm (\w+)", caseSensitive: false),
          RegExp(r"i am (\w+)", caseSensitive: false),
          RegExp(r"call me (\w+)", caseSensitive: false),
        ];

        for (final pattern in namePatterns) {
          final match = pattern.firstMatch(content);
          if (match != null) {
            final name = match.group(1)!;
            // Capitalize first letter
            return name[0].toUpperCase() + name.substring(1);
          }
        }
      }
    }

    return _extractedFields['name'];
  }
}
