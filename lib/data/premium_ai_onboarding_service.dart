import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'elevenlabs_service.dart';

/// Premium AI Onboarding Service - Discovery Call Experience
///
/// Creates a human-like conversation using:
/// - Claude API for intelligent, context-aware dialogue
/// - Conversation state machine for natural flow
/// - Active listening patterns (reflect-then-ask)
/// - ElevenLabs integration for voice synthesis
///
/// Based on professional coaching psychology:
/// - Motivational Interviewing techniques
/// - Identity-based change (James Clear)
/// - GROW coaching model elements
class PremiumAiOnboardingService {
  // API Configuration
  String? _claudeApiKey;
  String? _elevenLabsApiKey;

  // Services
  ElevenLabsService? _voiceService;

  // Conversation state
  ConversationState _state = ConversationState.greeting;
  final List<Map<String, String>> _conversationHistory = [];
  final Map<String, String?> _extractedFields = {};

  // Callbacks
  Function(String)? onVoiceStart;
  Function()? onVoiceEnd;
  Function(ConversationState)? onStateChange;

  /// Premium system prompt based on coaching psychology
  static const String systemPrompt = '''
You are a warm, expert habit coach having a discovery call with someone who wants to build better habits. You've deeply studied James Clear's Atomic Habits and have years of experience helping people transform their lives through small changes.

## YOUR COACHING PHILOSOPHY

You believe that lasting change comes from identity, not willpower. You help people see themselves differently first, then the behaviors follow naturally. Your favorite quote is "Every action is a vote for the type of person you wish to become."

## CONVERSATION PRINCIPLES

### 1. ACTIVE LISTENING (Most Important)
- Before asking your next question, ALWAYS reflect back what you heard
- Use phrases like "So what I'm hearing is...", "It sounds like...", "That's really insightful..."
- Show genuine curiosity about their specific situation
- Notice emotional cues and acknowledge them

### 2. ONE THING AT A TIME
- Ask only ONE question per response
- Keep responses to 2-3 sentences maximum
- Let silences breathe - don't fill every gap

### 3. IDENTITY-FIRST APPROACH
- Always start with WHO they want to become, not WHAT they want to do
- Help them articulate their identity in their own words
- Reframe goals as identity statements naturally

### 4. THE 2-MINUTE RULE
- When discussing habits, guide them to find the "gateway habit"
- Make it impossibly small - "so easy you can't say no"
- Use examples: "read one page", "do 2 pushups", "meditate for 60 seconds"

### 5. MAKE IT CONCRETE
- Implementation intentions must be specific: exact time, exact place
- Help them visualize the moment: "Picture yourself at 7am in your kitchen..."
- Connect to existing routines (habit stacking)

## CONVERSATION FLOW

1. **Opening**: Warm greeting, set the tone, ask about their aspirations
2. **Identity Exploration**: Deep dive into who they want to become
3. **Habit Discovery**: What behavior would that person do?
4. **Tiny Version**: Apply 2-minute rule
5. **Implementation**: Nail down specific time and place
6. **Enhancement** (optional): Environment design, temptation bundling
7. **Commitment**: Summarize and celebrate their plan

## YOUR PERSONALITY

- Warm but professional - like a trusted friend who happens to be an expert
- Genuinely curious - you find people's stories fascinating
- Encouraging without being cheesy or over-the-top
- Direct when needed - you respect their time
- Use natural language - contractions, conversational tone
- Occasionally share brief, relevant insights from the book

## WHAT TO AVOID

- Never lecture or give long explanations
- Don't use bullet points or structured lists in conversation
- Avoid generic motivational phrases ("You've got this!")
- Don't rush to solutions - sit with their answers
- Never make them feel judged for past failures
- Don't extract data robotically - this is a real conversation

## FIELD EXTRACTION

As you learn information naturally through conversation, note it mentally. When you have enough for a complete habit setup (identity, habit name, tiny version, time, location), include this at the end of your response in a special format:

When ready, include exactly this format at the END of your message:
[FIELDS:{"identity":"...","habitName":"...","tinyVersion":"...","time":"HH:MM","location":"...","temptationBundle":"...or null","environmentCue":"...or null","complete":true}]

Only include this when you have AT MINIMUM: identity, habitName, tinyVersion, time, and location.

## EXAMPLE EXCHANGE

User: "I want to read more books"

BAD Response: "Great! What's the 2-minute version? When and where will you do it?"

GOOD Response: "Reading more - I love that. Before we dive into the how, I'm curious... when you imagine yourself as someone who reads regularly, what does that person look like? What kind of person do you want to become?"

Remember: You're not filling out a form. You're having a meaningful conversation that happens to result in a solid habit plan.
''';

  /// Conversation states for natural flow management
  static const Map<ConversationState, StateConfig> stateConfigs = {
    ConversationState.greeting: StateConfig(
      purpose: 'Warm welcome, set expectations, open with identity question',
      requiredFields: [],
      transitionsTo: [ConversationState.identityExploration],
    ),
    ConversationState.identityExploration: StateConfig(
      purpose: 'Deep dive into who they want to become',
      requiredFields: ['identity'],
      transitionsTo: [ConversationState.habitDiscovery],
    ),
    ConversationState.habitDiscovery: StateConfig(
      purpose: 'What behavior aligns with that identity',
      requiredFields: ['habitName'],
      transitionsTo: [ConversationState.tinyVersion],
    ),
    ConversationState.tinyVersion: StateConfig(
      purpose: 'Apply 2-minute rule, make it tiny',
      requiredFields: ['tinyVersion'],
      transitionsTo: [ConversationState.implementation],
    ),
    ConversationState.implementation: StateConfig(
      purpose: 'Specific time and place',
      requiredFields: ['time', 'location'],
      transitionsTo: [ConversationState.enhancement, ConversationState.commitment],
    ),
    ConversationState.enhancement: StateConfig(
      purpose: 'Optional: environment design, temptation bundling',
      requiredFields: [],
      transitionsTo: [ConversationState.commitment],
    ),
    ConversationState.commitment: StateConfig(
      purpose: 'Summarize plan, celebrate, close',
      requiredFields: [],
      transitionsTo: [],
    ),
  };

  // Getters
  Map<String, String?> get extractedFields => Map.unmodifiable(_extractedFields);
  ConversationState get currentState => _state;
  bool get isComplete => _extractedFields['complete'] == 'true';
  List<Map<String, String>> get conversationHistory => List.unmodifiable(_conversationHistory);

  /// Initialize with API keys
  void initialize({
    required String claudeApiKey,
    required String elevenLabsApiKey,
    String voiceId = 'EXAVITQu4vr4xnSDxMaL', // "Sarah" - warm, professional
  }) {
    _claudeApiKey = claudeApiKey;
    _elevenLabsApiKey = elevenLabsApiKey;
    _voiceService = ElevenLabsService(
      apiKey: elevenLabsApiKey,
      voiceId: voiceId,
    );
  }

  /// Reset for new conversation
  void reset() {
    _state = ConversationState.greeting;
    _conversationHistory.clear();
    _extractedFields.clear();
  }

  /// Get initial greeting
  Future<ConversationResponse> startConversation() async {
    const greeting = '''Hi there! I'm so glad you're here. I'm your habit coach, and I've helped hundreds of people build lasting habits using the principles from Atomic Habits.

Before we talk about what you want to do, I'd love to understand something deeper. When you close your eyes and imagine your ideal self six months from now... who is that person? What kind of person do you want to become?''';

    _conversationHistory.add({'role': 'assistant', 'content': greeting});

    // Generate voice if available
    Uint8List? audioData;
    if (_voiceService != null) {
      audioData = await _voiceService!.synthesize(greeting);
    }

    return ConversationResponse(
      text: greeting,
      audioData: audioData,
      state: _state,
    );
  }

  /// Send message and get response
  Future<ConversationResponse> sendMessage(String userMessage) async {
    // Add user message to history
    _conversationHistory.add({'role': 'user', 'content': userMessage});

    String responseText;

    try {
      // Call Claude API
      responseText = await _callClaudeApi(userMessage);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Claude API error: $e');
      }
      // Fallback to local response
      responseText = _generateLocalResponse(userMessage);
    }

    // Extract fields from response
    _parseFieldsFromResponse(responseText);

    // Clean response (remove field extraction markup)
    final cleanResponse = _cleanResponse(responseText);

    // Add to history
    _conversationHistory.add({'role': 'assistant', 'content': cleanResponse});

    // Update state based on extracted fields
    _updateState();

    // Generate voice if available
    Uint8List? audioData;
    if (_voiceService != null) {
      try {
        audioData = await _voiceService!.synthesize(cleanResponse);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Voice synthesis error: $e');
        }
      }
    }

    return ConversationResponse(
      text: cleanResponse,
      audioData: audioData,
      state: _state,
      extractedFields: Map.from(_extractedFields),
    );
  }

  /// Call Claude API for response
  Future<String> _callClaudeApi(String userMessage) async {
    if (_claudeApiKey == null || _claudeApiKey!.isEmpty) {
      throw Exception('Claude API key not configured');
    }

    // Build messages array with conversation history
    final messages = _conversationHistory.map((msg) {
      return {
        'role': msg['role'],
        'content': msg['content'],
      };
    }).toList();

    // Add context about current state
    final stateContext = '''
[INTERNAL CONTEXT - Current conversation state: ${_state.name}
Fields collected so far: ${_extractedFields.entries.where((e) => e.value != null).map((e) => '${e.key}: ${e.value}').join(', ')}
Remember to reflect what you heard before asking the next question.]''';

    final payload = {
      'model': 'claude-sonnet-4-20250514',
      'max_tokens': 1024,
      'system': systemPrompt + '\n\n' + stateContext,
      'messages': messages,
    };

    final response = await http.post(
      Uri.parse('https://api.anthropic.com/v1/messages'),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': _claudeApiKey!,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode(payload),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final content = data['content'] as List;
      if (content.isNotEmpty) {
        return content[0]['text'] as String;
      }
    }

    throw Exception('Claude API returned status ${response.statusCode}');
  }

  /// Parse extracted fields from response
  void _parseFieldsFromResponse(String response) {
    // Look for [FIELDS:{...}] pattern
    final fieldMatch = RegExp(r'\[FIELDS:(\{[^}]+\})\]').firstMatch(response);

    if (fieldMatch != null) {
      try {
        final jsonStr = fieldMatch.group(1)!;
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;

        data.forEach((key, value) {
          if (value != null && value != 'null' && value.toString().isNotEmpty) {
            _extractedFields[key] = value.toString();
          }
        });
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error parsing fields: $e');
        }
      }
    }
  }

  /// Clean response by removing field extraction markup
  String _cleanResponse(String response) {
    return response.replaceAll(RegExp(r'\[FIELDS:\{[^}]+\}\]'), '').trim();
  }

  /// Update conversation state based on extracted fields
  void _updateState() {
    final previousState = _state;

    // Check what fields we have
    final hasIdentity = _extractedFields['identity'] != null;
    final hasHabit = _extractedFields['habitName'] != null;
    final hasTiny = _extractedFields['tinyVersion'] != null;
    final hasTime = _extractedFields['time'] != null;
    final hasLocation = _extractedFields['location'] != null;

    // Progress through states
    if (_extractedFields['complete'] == 'true') {
      _state = ConversationState.commitment;
    } else if (hasTime && hasLocation) {
      _state = ConversationState.enhancement;
    } else if (hasTiny) {
      _state = ConversationState.implementation;
    } else if (hasHabit) {
      _state = ConversationState.tinyVersion;
    } else if (hasIdentity) {
      _state = ConversationState.habitDiscovery;
    } else {
      _state = ConversationState.identityExploration;
    }

    if (_state != previousState && onStateChange != null) {
      onStateChange!(_state);
    }
  }

  /// Generate local response when API unavailable
  String _generateLocalResponse(String userMessage) {
    // Context-aware fallback responses based on state
    switch (_state) {
      case ConversationState.greeting:
      case ConversationState.identityExploration:
        return '''That's really insightful - ${_reflectUserInput(userMessage)}.

When you think about that version of yourself, what's one small behavior that person would do consistently? Something that would be evidence of that identity?''';

      case ConversationState.habitDiscovery:
        return '''I love that - ${_reflectUserInput(userMessage)}.

Now here's where it gets interesting. James Clear talks about the "2-minute rule" - we want to make this habit so tiny it's impossible to fail. What would a 2-minute version of this look like? Something so small it almost feels silly?''';

      case ConversationState.tinyVersion:
        return '''Perfect - "${_reflectUserInput(userMessage)}" is exactly the kind of tiny start that builds real habits.

Now let's make it concrete. What time of day would work best for you? And where will you be when you do this?''';

      case ConversationState.implementation:
        return '''Great, so ${_reflectUserInput(userMessage)}. That specificity is going to make a huge difference.

One last thing - is there anything you could set up in your environment to make this easier? A visual cue, or maybe something you should put away to remove friction?''';

      case ConversationState.enhancement:
      case ConversationState.commitment:
        return '''This is a solid plan. Let me recap what we've built together:

You're becoming someone who ${_extractedFields['identity'] ?? 'takes action consistently'}. Your gateway habit is "${_extractedFields['habitName'] ?? 'your chosen habit'}", starting with just "${_extractedFields['tinyVersion'] ?? '2 minutes'}". You'll do this at ${_extractedFields['time'] ?? 'your chosen time'} in ${_extractedFields['location'] ?? 'your chosen place'}.

Remember: "You don't rise to the level of your goals. You fall to the level of your systems." You just built your system. Ready to start?''';
    }
  }

  /// Simple reflection of user input for local fallback
  String _reflectUserInput(String input) {
    if (input.length > 50) {
      return input.substring(0, 50) + '...';
    }
    return input.toLowerCase();
  }
}

/// Conversation states
enum ConversationState {
  greeting,
  identityExploration,
  habitDiscovery,
  tinyVersion,
  implementation,
  enhancement,
  commitment,
}

/// State configuration
class StateConfig {
  final String purpose;
  final List<String> requiredFields;
  final List<ConversationState> transitionsTo;

  const StateConfig({
    required this.purpose,
    required this.requiredFields,
    required this.transitionsTo,
  });
}

/// Response from conversation
class ConversationResponse {
  final String text;
  final Uint8List? audioData;
  final ConversationState state;
  final Map<String, String?>? extractedFields;

  ConversationResponse({
    required this.text,
    this.audioData,
    required this.state,
    this.extractedFields,
  });
}
