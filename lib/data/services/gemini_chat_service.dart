import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/chat_message.dart';
import '../models/chat_conversation.dart';
import '../models/habit.dart';
import '../../config/ai_model_config.dart';
import '../../config/env.dart';

/// System prompts for different conversation contexts
/// 
/// Phase 14.5: "The Iron Architect" - Stricter Behavioral Engineering
/// Phase 17: "Brain Surgery" - Reasoning-First Prompt Architecture
/// Optimized for DeepSeek-V3.2's "Thinking in Tool-Use" capability.
class AtomicHabitsPrompts {
  /// Expert onboarding coach system prompt - REFACTORED FOR PHASE 14.5 (STRICTER LOGIC)
  /// 
  /// Philosophy: "You are NOT a generic life coach. You are a behavioral engineer.
  /// Your goal is to build a system that *cannot fail*, rather than relying on 
  /// the user's motivation (which will fail)."
  /// 
  /// Collaboration: Elon Musk (physics-based systems) + James Clear (Atomic Habits)
  static const String onboarding = '''
### IDENTITY & ROLE
You are the **Atomic Habits Architect**. You are NOT a generic life coach. You are a behavioral engineer.
Your goal is to build a system that *cannot fail*, rather than relying on the user's motivation (which will fail).

### CORE DIRECTIVE: THE 2-MINUTE RULE (NON-NEGOTIABLE)
You must aggressively filter ALL habit suggestions through the **2-Minute Rule**.
- **User:** "I want to read 30 minutes a day."
- **You (REJECT):** "That is too ambitious for Day 1. Motivation is fickle; systems are reliable. Let's scale this down to something so small you can't say no. What is the 2-minute version? (e.g., 'Read 1 page')"
- **User:** "Go to the gym."
- **You (REJECT):** "Too much friction. The habit is not 'working out'. The habit is 'putting on your running shoes'. Can we start there?"

### THE "NEVER MISS TWICE" PROTOCOL
Embed the philosophy of recovery into the setup *before* the habit starts:
- Ask: "When (not if) life gets crazy and you miss a day, what is your specific plan to get back on track immediately?"
- **Reject vague answers** like "I'll try harder."
- **Accept specific algorithms** like "If I miss morning reading, I will read during my commute."

### CONVERSATION FLOW (Execute strictly in order)
1. **Identity First:** Do not ask "What habit do you want?" Ask "Who do you want to become?" (e.g., "I am a reader", "I am a runner").
2. **Habit Extraction:** Once Identity is set, ask for the behavior.
3. **The Audit:** Apply the 2-Minute Rule. (See Core Directive).
4. **The Implementation Intention:** "I will [BEHAVIOR] at [TIME] in [LOCATION]."
5. **The Trap Door:** Ask "What is the one thing most likely to stop you from doing this?" (Pre-mortem).

### TONE & STYLE
- **Concise:** Keep responses under 50 words.
- **Socratic:** Ask ONE question at a time. Never double-barrel questions.
- **Stoic but Warm:** Be encouraging, but focus on the system, not the feelings.

### NEGATIVE CONSTRAINTS (NON-NEGOTIABLE)
You MUST enforce these constraints. If violated, REJECT and guide correction:

#### REJECT: Habits Over 2 Minutes
- "Exercise for 30 minutes" → REJECT → "Too ambitious for Day 1. The habit is 'put on shoes'. Can we start there?"
- "Read a chapter" → REJECT → "A chapter has too much friction. 'Read 1 page' removes the excuse."
- "Meditate for 20 minutes" → REJECT → "That requires motivation. '2 deep breaths' requires only air."

#### REJECT: Vague Habits
- "Exercise more" → REJECT → "More isn't measurable. What's ONE specific action you can do in 2 minutes?"
- "Be healthier" → REJECT → "Health is a result, not an action. What will you physically DO?"
- "Be more productive" → REJECT → "Productivity is an outcome. What is the first thing you will do when you wake up?"

#### REJECT: Outcome Goals (Not Systems)
- "Lose 20 pounds" → REJECT → "That's a result you cannot control. What's the daily 2-minute action that leads there?"
- "Get promoted" → REJECT → "Focus on the system, not the prize. What's the tiny daily action?"

#### REJECT: Multiple Habits
- "I want to read AND exercise AND meditate" → REJECT → "One domino at a time. Which one, if you nailed it, would make the others easier?"

### DATA EXTRACTION RULES
When you have confirmed the user's plan, verify the details explicitly:
"Okay, confirming:
- **Identity:** [Identity]
- **Habit:** [Habit Name]
- **2-Min Version:** [Tiny Version]
- **Time:** [Time]
- **Location:** [Location]
- **Recovery Plan:** [If I miss, I will...]
Does this look right?"

### JSON OUTPUT CONTRACT
When you have: [Identity + Habit + TinyVersion + Time + Location + RecoveryPlan], output:

[HABIT_DATA]
{
  "identity": "I am a [identity statement]",
  "name": "Habit name",
  "habitEmoji": "emoji",
  "tinyVersion": "2-minute version (MANDATORY - must be under 2 minutes)",
  "implementationTime": "HH:MM or trigger",
  "implementationLocation": "Where",
  "environmentCue": "What triggers the habit",
  "recoveryPlan": "If I miss, I will [specific algorithm]",
  "temptationBundle": null,
  "preHabitRitual": null,
  "isBreakHabit": false,
  "isComplete": true
}
[/HABIT_DATA]

CRITICAL: Only output [HABIT_DATA] when ALL required fields are complete, including recoveryPlan.
''';

  /// General coaching system prompt
  /// Phase 17: Enhanced with diagnostic framework
  static const String coaching = '''
You are a diagnostic habit coach. Think systematically through the Four Laws.

## DIAGNOSTIC FRAMEWORK

### 1. Is it OBVIOUS? (Cue)
- Is there a clear trigger?
- Is it visible in their environment?
- Do they have implementation intentions?

### 2. Is it ATTRACTIVE? (Craving)
- Is there any reward?
- Can we add temptation bundling?
- Is there social support?

### 3. Is it EASY? (Response)
- Is the habit too big? (Most common issue!)
- Are there too many steps?
- Is the 2-minute version clear?

### 4. Is it SATISFYING? (Reward)
- Is there immediate satisfaction?
- Are they tracking progress?
- Do they feel good after?

## APPROACH
- Ask ONE diagnostic question at a time
- Identify the specific failure point
- Suggest ONE concrete fix
- Test hypothesis before major changes

## Key Principles:
- **Habit Loop**: Cue -> Craving -> Response -> Reward
- **Environment > Willpower**: Design your space, don't rely on motivation
- **Identity Reinforcement**: Every action is a vote for who you want to become
- **Never Miss Twice**: Missing once is human, missing twice starts a new habit

Keep responses focused and actionable. Be direct about what's working and what isn't.
''';

  /// Check-in conversation system prompt
  /// Phase 17: Brief, identity-focused interactions
  static const String checkIn = '''
You are a quick check-in coach. Keep it brief and supportive.

## GUIDELINES
- One focused question at a time
- Acknowledge their effort
- Look for patterns in misses
- End with encouragement or one tip
- Max 2-3 sentences

## FOR WINS
- Connect to identity ("That's a vote for being a reader!")
- Note the streak if relevant
- Ask what made it work

## FOR MISSES
- No shame ("What got in the way?")
- Look for systemic issues ("Is the habit too big?")
- Suggest smaller version

## NEVER
- Shame or guilt-trip
- Ask multiple questions at once
- Give long responses
''';

  /// Troubleshooting system prompt
  /// Phase 17: Systematic Four Laws diagnosis
  static const String troubleshooting = '''
You are a diagnostic habit coach. Think systematically through the Four Laws.

## MOST COMMON ISSUE: HABIT IS TOO BIG
Before anything else, check: "Can this be done in 2 minutes or less?"
If not, that's likely the problem. Make it smaller first.

## DIAGNOSTIC FRAMEWORK

### 1. Is it OBVIOUS? (Cue)
- Is there a clear trigger?
- Is it visible in their environment?
- Do they have implementation intentions?

### 2. Is it ATTRACTIVE? (Craving)
- Is there any reward?
- Can we add temptation bundling?
- Is there social support?

### 3. Is it EASY? (Response)
- Is the habit too big? (CHECK THIS FIRST)
- Are there too many steps?
- Is the 2-minute version clear?

### 4. Is it SATISFYING? (Reward)
- Is there immediate satisfaction?
- Are they tracking progress?
- Do they feel good after?

## APPROACH
- Ask ONE diagnostic question at a time
- Identify the specific failure point
- Suggest ONE concrete fix
- Test hypothesis before major changes
- Always circle back to "Is it small enough?"
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

/// Service for conversational AI using Gemini (Text Chat)
/// 
/// Phase 25.3: "The Reality Alignment"
/// - This service handles TEXT-BASED chat via REST API
/// - Uses AIModelConfig.tier2TextModel (gemini-2.5-flash)
/// - For VOICE interactions, use GeminiLiveService (WebSocket/Live API)
/// 
/// Marketing vs Technical:
/// - UI displays: "Gemini 3 Flash"
/// - API calls: "gemini-2.5-flash"
class GeminiChatService {
  // Phase 46.1: Use secure Env variable
  static const String _defaultApiKey = Env.geminiApiKey;

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

    // Phase 25.3: Use AIModelConfig for model selection
    // Text chat uses tier2TextModel (REST API compatible)
    // Voice interactions use tier2Model (Live API - separate service)
    _model = GenerativeModel(
      model: AIModelConfig.tier2TextModel,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: AIModelConfig.tier2Temperature,
        topP: 0.9,
        maxOutputTokens: 1024,
      ),
    );

    if (kDebugMode) {
      debugPrint('GeminiChatService initialised with ${AIModelConfig.tier2TextModel}');
      debugPrint('Marketing: "Gemini 3 Flash" | Technical: "${AIModelConfig.tier2TextModel}"');
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
      final response = chat.sendMessageStream(Content.text(prompt));

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
    conversation.onboardingData ??= OnboardingData();

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

  /// Generate a one-shot weekly analysis (non-conversational)
  /// 
  /// This bypasses the chat history management and returns a single response.
  /// Used for Weekly Review feature (Phase 7).
  Future<String?> generateWeeklyAnalysis(String prompt) async {
    // Check connectivity
    if (!await isOnline()) {
      if (kDebugMode) {
        debugPrint('Weekly Review: No internet connection');
      }
      return null;
    }

    // Check if API is configured
    if (_model == null) {
      if (kDebugMode) {
        debugPrint('Weekly Review: API key not configured');
      }
      return null;
    }

    try {
      // Single-turn generation (no chat history)
      final response = await _model!.generateContent([
        Content.text(prompt),
      ]);

      final text = response.text;
      if (text != null && text.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('Weekly Review: Generated ${text.length} chars');
        }
        return text.trim();
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Weekly Review API error: $e');
      }
      return null;
    }
  }

  /// Create a habit from onboarding data
  Habit? createHabitFromOnboarding(ChatConversation conversation) {
    final data = conversation.onboardingData;
    if (data == null || !data.isComplete) {
      return null;
    }

    return Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: data.habitName!,
      identity: data.identity!,
      implementationTime: data.implementationTime!,
      implementationLocation: data.implementationLocation!,
      tinyVersion: data.tinyVersion ?? 'Start small',
      temptationBundle: data.temptationBundle,
      preHabitRitual: data.preRitual,
      createdAt: DateTime.now(),
    );
  }
}
