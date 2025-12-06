import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/chat_message.dart';
import '../models/chat_conversation.dart';
import '../models/habit.dart';

/// System prompts for different conversation contexts
class AtomicHabitsPrompts {
  /// Expert onboarding coach system prompt
  static const String onboarding = '''
You are an expert habit coach deeply versed in James Clear's "Atomic Habits" methodology. Your role is to guide users through creating their first habit using proven behavioral science principles.

## Your Expertise Includes:
- **Identity-Based Habits**: Help users define WHO they want to become, not just what they want to do
- **The 2-Minute Rule**: Make habits so small they're impossible to fail
- **Implementation Intentions**: "I will [BEHAVIOR] at [TIME] in [LOCATION]"
- **Habit Stacking**: Linking new habits to existing routines
- **The Four Laws of Behavior Change**: Make it obvious, attractive, easy, and satisfying
- **Environment Design**: Shaping surroundings to support good habits

## Conversation Guidelines:

### Be Constructively Critical:
- If a user's habit idea is too vague, ask for specifics
- If it's too ambitious, gently suggest a smaller version
- If their identity statement is weak, help strengthen it
- Challenge goals like "exercise more" to become "do 5 pushups after I wake up"

### Ask Probing Questions:
- "What does success look like for you?"
- "Who is the type of person who does this naturally?"
- "What's the smallest version of this habit?"
- "What might get in the way?"

### Provide Expert Suggestions:
- Offer specific, actionable alternatives when ideas are vague
- Suggest environment cues based on their location
- Recommend temptation bundles that match their interests
- Point out potential failure points before they happen

### Onboarding Flow (gather this information naturally):
1. **Identity**: Who do they want to become? (e.g., "I am a reader", "I am someone who exercises daily")
2. **Habit**: What specific behavior supports this identity?
3. **2-Minute Version**: How can this be done in under 2 minutes to start?
4. **Implementation Intention**: When and where will they do this?
5. **Optional Enhancements**: Temptation bundle, pre-ritual, environment cue

### Formatting:
- Keep responses concise (2-4 sentences typically)
- Use encouraging but direct language
- Don't be overly enthusiastic or use excessive praise
- Be warm but professional
- If you're asking a question, usually just ask ONE question at a time

### Data Extraction:
When the user provides information, acknowledge it and confirm you've captured it correctly before moving on. At any point you can summarize what you've learned so far.

Remember: Your goal is to help them create ONE well-designed habit that they'll actually stick to. Quality over quantity. A tiny habit done consistently beats an ambitious habit that fails.
''';

  /// General coaching system prompt
  static const String coaching = '''
You are an expert habit coach deeply versed in James Clear's "Atomic Habits" and behavioral psychology. You help users optimize existing habits, troubleshoot problems, and deepen their understanding of behavior change.

## Your Role:
- Answer questions about habit formation
- Help troubleshoot when habits aren't sticking
- Suggest optimizations using the Four Laws
- Provide science-backed insights
- Be encouraging but honest

## Key Principles to Reference:
- **Habit Loop**: Cue → Craving → Response → Reward
- **1% Improvements**: Small gains compound over time
- **Environment > Willpower**: Design your space, don't rely on motivation
- **Identity Reinforcement**: Every action is a vote for who you want to become
- **Never Miss Twice**: Missing once is human, missing twice starts a new habit

Keep responses focused and actionable. Be direct about what's working and what isn't.
''';

  /// Check-in conversation system prompt
  static const String checkIn = '''
You are a supportive habit coach conducting a brief check-in. Your tone is warm, non-judgmental, and focused on learning and growth.

## Check-In Goals:
- Celebrate wins without being over-the-top
- Explore misses without blame or guilt
- Identify patterns (what's working, what isn't)
- Suggest small adjustments
- Reinforce identity ("You showed up as a reader today")

## Guidelines:
- Start by acknowledging their progress data (if provided)
- Ask ONE focused question at a time
- Look for root causes, not surface symptoms
- End with encouragement or a concrete next step
- Keep it brief - this should feel quick and supportive

## For Misses:
- "What got in the way?" (curious, not accusatory)
- "How could we make this easier next time?"
- "Is the habit still too big?"
- Never shame or guilt-trip

## For Wins:
- Acknowledge the effort, not just the outcome
- Connect it to their identity
- Note streaks and consistency
- Ask what made it work
''';

  /// Troubleshooting system prompt
  static const String troubleshooting = '''
You are a diagnostic habit coach helping users figure out why a habit isn't sticking. You think systematically through the Four Laws of Behavior Change.

## Diagnostic Framework:

### 1. Is it OBVIOUS? (Cue problems)
- Is there a clear trigger?
- Is the habit visible in their environment?
- Do they have implementation intentions?

### 2. Is it ATTRACTIVE? (Motivation problems)
- Is there any reward or pleasure associated?
- Can we add temptation bundling?
- Is there social support?

### 3. Is it EASY? (Friction problems)
- Is the habit too big?
- Are there too many steps to start?
- Is the 2-minute version clear?

### 4. Is it SATISFYING? (Reward problems)
- Is there immediate satisfaction?
- Are they tracking progress?
- Do they feel good after doing it?

## Approach:
- Ask targeted diagnostic questions
- Identify the specific failure point
- Suggest ONE concrete fix at a time
- Test hypotheses before major changes
''';

  /// Get the appropriate prompt for a conversation type
  static String getPrompt(ConversationType type) {
    switch (type) {
      case ConversationType.onboarding:
        return onboarding;
      case ConversationType.coaching:
        return coaching;
      case ConversationType.checkIn:
        return checkIn;
      case ConversationType.troubleshooting:
        return troubleshooting;
    }
  }
}

/// Service for conversational AI using Gemini 2.5 Flash
class GeminiChatService {
  // TODO: Replace with your actual API key (use environment variables in production)
  // For development, you can get a free API key at https://makersuite.google.com/app/apikey
  static const String _defaultApiKey = 'AIzaSyB6BVpzg6lXxY_AAi3rPcSuGpcjV89H8dE';

  final String apiKey;
  GenerativeModel? _model;
  final Connectivity _connectivity = Connectivity();
  final ConversationStorage _storage = ConversationStorage();

  /// Callback for streaming updates
  final void Function(String chunk)? onStreamChunk;

  /// Current conversation
  ChatConversation? _currentConversation;

  GeminiChatService({
    String? apiKey,
    this.onStreamChunk,
  }) : apiKey = apiKey ?? _defaultApiKey;

  /// Initialize the Gemini model
  Future<void> init() async {
    await _storage.init();

    if (apiKey == _defaultApiKey || apiKey.isEmpty) {
      if (kDebugMode) {
        debugPrint('WARNING: Using placeholder API key. Set your Gemini API key.');
      }
      return;
    }

    _model = GenerativeModel(
      model: 'gemini-2.5-flash-preview-05-20',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topP: 0.9,
        maxOutputTokens: 1024,
      ),
    );

    if (kDebugMode) {
      debugPrint('GeminiChatService initialized with Gemini 2.5 Flash');
    }
  }

  /// Check if we have network connectivity
  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// Start a new conversation
  Future<ChatConversation> startConversation({
    required ConversationType type,
    String? habitId,
    Habit? relatedHabit,
  }) async {
    ChatConversation conversation;

    switch (type) {
      case ConversationType.onboarding:
        conversation = ChatConversation.onboarding();
        break;
      case ConversationType.coaching:
        conversation = ChatConversation.coaching(habitId: habitId);
        break;
      case ConversationType.checkIn:
        conversation = ChatConversation.checkIn(habitId: habitId);
        break;
      case ConversationType.troubleshooting:
        conversation = ChatConversation.coaching(habitId: habitId);
        break;
    }

    _currentConversation = conversation;
    await _storage.save(conversation);

    return conversation;
  }

  /// Send a message and get a streaming response
  ///
  /// Returns the complete response after streaming finishes.
  /// Use [onStreamChunk] callback to get real-time updates.
  Future<ChatMessage> sendMessage({
    required String userMessage,
    required ChatConversation conversation,
    bool isVoiceInput = false,
    List<Habit>? userHabits,
    void Function(String chunk)? onChunk,
  }) async {
    // Check connectivity
    if (!await isOnline()) {
      final errorMessage = ChatMessage.assistant(
        content: "I'm unable to connect right now. Please check your internet connection and try again.",
        status: MessageStatus.error,
      );
      errorMessage.errorMessage = 'No internet connection';
      return errorMessage;
    }

    // Check if API is configured
    if (_model == null) {
      final errorMessage = ChatMessage.assistant(
        content: "The AI service isn't configured yet. Please add your Gemini API key to get started.",
        status: MessageStatus.error,
      );
      errorMessage.errorMessage = 'API key not configured';
      return errorMessage;
    }

    // Add user message to conversation
    final userMsg = ChatMessage.user(
      content: userMessage,
      isVoiceInput: isVoiceInput,
    );
    conversation.addMessage(userMsg);

    // Create assistant message placeholder
    final assistantMsg = ChatMessage.assistant();
    conversation.addMessage(assistantMsg);

    try {
      // Build the chat history for Gemini
      final history = _buildChatHistory(conversation, userHabits);

      // Get the system prompt
      final systemPrompt = AtomicHabitsPrompts.getPrompt(conversation.type);

      // Create the chat session with history
      final chat = _model!.startChat(
        history: history,
      );

      // Send the message with system instruction embedded
      final prompt = _buildPromptWithContext(
        systemPrompt: systemPrompt,
        userMessage: userMessage,
        conversation: conversation,
        userHabits: userHabits,
      );

      // Stream the response
      final response = await chat.sendMessageStream(Content.text(prompt));

      await for (final chunk in response) {
        final text = chunk.text;
        if (text != null && text.isNotEmpty) {
          assistantMsg.appendContent(text);

          // Call the stream callback
          onChunk?.call(text);
          onStreamChunk?.call(text);
        }
      }

      // Mark as complete
      assistantMsg.markComplete();

      // Extract any onboarding data
      if (conversation.type == ConversationType.onboarding) {
        _extractOnboardingData(conversation);
      }

      // Save conversation
      await _storage.save(conversation);

      return assistantMsg;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Gemini API error: $e');
      }

      assistantMsg.markError('Failed to get response: ${e.toString()}');

      // Provide a helpful fallback message
      assistantMsg.content = _getFallbackResponse(conversation.type, userMessage);

      await _storage.save(conversation);

      return assistantMsg;
    }
  }

  /// Build chat history for Gemini API
  List<Content> _buildChatHistory(
    ChatConversation conversation,
    List<Habit>? userHabits,
  ) {
    final history = <Content>[];

    // Add previous messages (excluding the last user message and current assistant placeholder)
    final messagesToInclude = conversation.messages
        .where((m) => m.status == MessageStatus.complete)
        .take(conversation.messages.length - 2)
        .toList();

    for (final msg in messagesToInclude) {
      if (msg.role == MessageRole.user) {
        history.add(Content('user', [TextPart(msg.content)]));
      } else if (msg.role == MessageRole.assistant) {
        history.add(Content('model', [TextPart(msg.content)]));
      }
    }

    return history;
  }

  /// Build the prompt with context
  String _buildPromptWithContext({
    required String systemPrompt,
    required String userMessage,
    required ChatConversation conversation,
    List<Habit>? userHabits,
  }) {
    final buffer = StringBuffer();

    // Add system instruction as context
    buffer.writeln('[SYSTEM INSTRUCTION]');
    buffer.writeln(systemPrompt);
    buffer.writeln();

    // Add user habits context if available
    if (userHabits != null && userHabits.isNotEmpty) {
      buffer.writeln('[USER\'S CURRENT HABITS]');
      for (final habit in userHabits) {
        buffer.writeln('- ${habit.name} (${habit.currentStreak} day streak)');
        if (habit.identity.isNotEmpty) {
          buffer.writeln('  Identity: "${habit.identity}"');
        }
      }
      buffer.writeln();
    }

    // Add onboarding progress if applicable
    if (conversation.type == ConversationType.onboarding &&
        conversation.onboardingData != null) {
      final data = conversation.onboardingData!;
      buffer.writeln('[ONBOARDING PROGRESS SO FAR]');
      if (data.identity != null) buffer.writeln('- Identity: ${data.identity}');
      if (data.habitName != null) buffer.writeln('- Habit: ${data.habitName}');
      if (data.tinyVersion != null) buffer.writeln('- 2-min version: ${data.tinyVersion}');
      if (data.implementationTime != null) buffer.writeln('- Time: ${data.implementationTime}');
      if (data.implementationLocation != null) buffer.writeln('- Location: ${data.implementationLocation}');
      buffer.writeln();
    }

    // Add the actual user message
    buffer.writeln('[USER MESSAGE]');
    buffer.writeln(userMessage);

    return buffer.toString();
  }

  /// Extract structured data from onboarding conversation
  void _extractOnboardingData(ChatConversation conversation) {
    if (conversation.onboardingData == null) {
      conversation.onboardingData = OnboardingData();
    }

    // Simple heuristic extraction from recent messages
    // In production, you might ask the LLM to extract this in a structured format
    final recentMessages = conversation.messages
        .where((m) => m.status == MessageStatus.complete)
        .toList();

    for (final msg in recentMessages) {
      final content = msg.content.toLowerCase();

      // Look for identity statements
      if (msg.isUser &&
          (content.contains('i am') ||
              content.contains('i want to be') ||
              content.contains('become'))) {
        // Extract potential identity
        final identityMatch = RegExp(r"i (?:am|want to be|want to become) (?:a |an )?(.+?)(?:\.|,|$)")
            .firstMatch(content);
        if (identityMatch != null && conversation.onboardingData!.identity == null) {
          conversation.onboardingData!.identity = identityMatch.group(1)?.trim();
        }
      }

      // Look for time mentions
      if (msg.isUser && conversation.onboardingData!.implementationTime == null) {
        final timePatterns = [
          RegExp(r'(\d{1,2}(?::\d{2})?\s*(?:am|pm))', caseSensitive: false),
          RegExp(r'(morning|afternoon|evening|night|after (?:breakfast|lunch|dinner|waking up|work))', caseSensitive: false),
        ];
        for (final pattern in timePatterns) {
          final match = pattern.firstMatch(content);
          if (match != null) {
            conversation.onboardingData!.implementationTime = match.group(1)?.trim();
            break;
          }
        }
      }

      // Look for location mentions
      if (msg.isUser && conversation.onboardingData!.implementationLocation == null) {
        final locationPatterns = [
          RegExp(r'(?:in|at) (?:my |the )?(.+?)(?:\.|,|$|when)', caseSensitive: false),
        ];
        for (final pattern in locationPatterns) {
          final match = pattern.firstMatch(content);
          if (match != null) {
            final location = match.group(1)?.trim();
            if (location != null &&
                !location.contains('am') &&
                !location.contains('pm') &&
                location.length < 30) {
              conversation.onboardingData!.implementationLocation = location;
              break;
            }
          }
        }
      }
    }
  }

  /// Get a fallback response when API fails
  String _getFallbackResponse(ConversationType type, String userMessage) {
    switch (type) {
      case ConversationType.onboarding:
        return "I'm having trouble connecting right now, but I'd love to help you create your habit! "
            "While we wait, think about: Who do you want to become? What's one small thing that person does daily?";
      case ConversationType.coaching:
        return "I couldn't connect to provide personalized advice. "
            "Remember: Make it obvious, attractive, easy, and satisfying. "
            "What's the smallest version of your habit you could do today?";
      case ConversationType.checkIn:
        return "I couldn't connect, but I see you're checking in - that's great! "
            "Take a moment to reflect: What worked well? What could be easier?";
      case ConversationType.troubleshooting:
        return "I'm having connection issues. While we wait, consider: "
            "Is your habit obvious enough? Easy enough? Satisfying enough?";
    }
  }

  /// Get the initial greeting for a conversation type
  Future<ChatMessage> getInitialGreeting({
    required ChatConversation conversation,
    List<Habit>? existingHabits,
  }) async {
    String greeting;

    switch (conversation.type) {
      case ConversationType.onboarding:
        if (existingHabits != null && existingHabits.isNotEmpty) {
          greeting = "Welcome back! I see you already have some habits going. "
              "Let's add another one to your collection. "
              "What area of your life would you like to improve next?";
        } else {
          greeting = "Hi! I'm here to help you build a lasting habit using proven techniques from Atomic Habits. "
              "Let's start with the most important question: Who do you want to become? "
              "For example, 'I want to be a reader' or 'I want to be someone who exercises daily.'";
        }
        break;

      case ConversationType.checkIn:
        final now = DateTime.now();
        final hour = now.hour;
        final timeOfDay = hour < 12 ? 'morning' : (hour < 17 ? 'afternoon' : 'evening');
        greeting = "Good $timeOfDay! Let's do a quick check-in. "
            "How did your habit practice go today?";
        break;

      case ConversationType.coaching:
        greeting = "I'm here to help you optimize your habits. "
            "What would you like to work on today?";
        break;

      case ConversationType.troubleshooting:
        greeting = "Let's figure out what's getting in the way. "
            "Tell me about the habit that's been challenging - when does it tend to fall apart?";
        break;
    }

    final greetingMessage = ChatMessage.assistant(
      content: greeting,
      status: MessageStatus.complete,
    );

    conversation.addMessage(greetingMessage);
    await _storage.save(conversation);

    return greetingMessage;
  }

  /// Resume an existing conversation
  Future<ChatConversation?> resumeConversation(String conversationId) async {
    final conversation = await _storage.load(conversationId);
    if (conversation != null) {
      _currentConversation = conversation;
    }
    return conversation;
  }

  /// Get current conversation
  ChatConversation? get currentConversation => _currentConversation;

  /// Save current conversation
  Future<void> saveCurrentConversation() async {
    if (_currentConversation != null) {
      await _storage.save(_currentConversation!);
    }
  }

  /// Load recent conversations
  Future<List<ChatConversation>> getRecentConversations() async {
    return _storage.loadRecent();
  }

  /// Create a habit from onboarding data
  Habit? createHabitFromOnboarding(ChatConversation conversation) {
    final data = conversation.onboardingData;
    if (data == null || !data.isComplete) {
      return null;
    }

    return Habit(
      name: data.habitName!,
      identity: data.identity!,
      implementationTime: data.implementationTime!,
      implementationLocation: data.implementationLocation!,
      tinyVersion: data.tinyVersion,
      temptationBundle: data.temptationBundle,
      preHabitRitual: data.preRitual,
    );
  }
}
