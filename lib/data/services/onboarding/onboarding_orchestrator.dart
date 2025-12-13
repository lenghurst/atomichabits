import 'dart:async';
import 'package:flutter/foundation.dart';
import '../gemini_chat_service.dart';
import '../../models/onboarding_data.dart';
import '../../models/chat_conversation.dart';
import '../../models/chat_message.dart';
import '../../../config/ai_model_config.dart';
import 'ai_response_parser.dart';
import 'conversation_guardrails.dart';

/// Result of a conversational message exchange
class ConversationResult {
  final ChatMessage? response;
  final OnboardingData? extractedData;
  final String? displayText;
  final String? error;
  final bool shouldFallbackToManual;

  ConversationResult({
    this.response,
    this.extractedData,
    this.displayText,
    this.error,
    this.shouldFallbackToManual = false,
  });

  factory ConversationResult.success({
    required ChatMessage response,
    OnboardingData? extractedData,
    String? displayText,
  }) {
    return ConversationResult(
      response: response,
      extractedData: extractedData,
      displayText: displayText,
    );
  }

  factory ConversationResult.error(String message) {
    return ConversationResult(error: message);
  }

  factory ConversationResult.fallback() {
    return ConversationResult(shouldFallbackToManual: true);
  }
}

/// Orchestrates the AI onboarding flow
/// 
/// The "Brain" of both Phase 1 (Magic Wand) and Phase 2 (Conversational UI).
/// Connects UI to AI services, handles tier selection, and manages fallbacks.
class OnboardingOrchestrator extends ChangeNotifier {
  final GeminiChatService _geminiService;
  
  /// Current conversation state
  ChatConversation? _conversation;
  
  /// Number of messages sent in current conversation
  int _messageCount = 0;
  
  /// Last request timestamp for rate limiting
  DateTime? _lastRequestTime;
  
  /// Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  /// Error state
  String? _error;
  String? get error => _error;
  
  /// Extracted habit data (Phase 2)
  OnboardingData? _extractedData;
  OnboardingData? get extractedData => _extractedData;
  
  /// Current conversation accessor
  ChatConversation? get conversation => _conversation;
  
  /// Loading state callback (legacy - kept for backward compatibility)
  final void Function(bool isLoading)? onLoadingChanged;
  
  /// Error callback (legacy - kept for backward compatibility)
  final void Function(String error)? onError;

  OnboardingOrchestrator({
    required GeminiChatService geminiService,
    this.onLoadingChanged,
    this.onError,
  }) : _geminiService = geminiService;

  /// Check if AI services are available
  bool get isAiAvailable => AIModelConfig.hasAnyAI;

  /// Get current tier based on configuration
  AiTier getCurrentTier({bool isBreakHabit = false, bool isPremiumUser = false}) {
    return AIModelConfig.selectTier(
      isPremiumUser: isPremiumUser,
      isBreakHabit: isBreakHabit,
    );
  }

  /// Magic Wand: One-shot completion for Phase 1
  /// 
  /// Takes user's habit name and identity, asks AI to fill in the rest.
  /// Returns [OnboardingData] with suggested values for:
  /// - tinyVersion (2-minute rule)
  /// - implementationTime
  /// - implementationLocation
  /// - environmentCue
  /// - temptationBundle (optional)
  /// - preHabitRitual (optional)
  Future<OnboardingData?> magicWandComplete({
    required String habitName,
    required String identity,
    bool isBreakHabit = false,
  }) async {
    // Check rate limiting
    if (!_checkRateLimit()) {
      onError?.call('Please wait a moment before trying again.');
      return null;
    }

    // Check AI availability
    if (!isAiAvailable) {
      onError?.call('AI service is not configured. Please enter details manually.');
      return null;
    }

    onLoadingChanged?.call(true);

    try {
      // Build the prompt for structured data extraction
      final prompt = _buildMagicWandPrompt(
        habitName: habitName,
        identity: identity,
        isBreakHabit: isBreakHabit,
      );

      // Start a new onboarding conversation
      _conversation = await _geminiService.startConversation(
        type: ConversationType.onboarding,
      );

      // Send the message with timeout
      final response = await _sendWithTimeout(prompt);
      
      if (response == null || response.status == MessageStatus.error) {
        onError?.call('Failed to get AI suggestions. Please try again or enter details manually.');
        return null;
      }

      // Parse the structured response
      final data = AiResponseParser.extractHabitData(response.content);
      
      if (data != null) {
        if (kDebugMode) {
          debugPrint('OnboardingOrchestrator: Magic Wand extracted data: $data');
        }
        return data;
      }
      
      // Try fallback parsing
      final fallbackData = AiResponseParser.extractWithFallback(response.content);
      if (fallbackData != null) {
        if (kDebugMode) {
          debugPrint('OnboardingOrchestrator: Magic Wand used fallback parsing: $fallbackData');
        }
        return fallbackData;
      }

      // No structured data found - return conversational text as error
      final conversationalText = AiResponseParser.extractConversationalText(response.content);
      onError?.call('AI provided suggestions but couldn\'t extract structured data. Please enter details manually.');
      if (kDebugMode) {
        debugPrint('OnboardingOrchestrator: AI response without structured data: $conversationalText');
      }
      return null;

    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('OnboardingOrchestrator: Magic Wand error: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      onError?.call('An error occurred. Please try again or enter details manually.');
      return null;
    } finally {
      onLoadingChanged?.call(false);
    }
  }

  /// Check if we should use manual fallback based on user frustration
  bool shouldFallbackToManual(String userMessage) {
    return ConversationGuardrails.isFrustrated(userMessage);
  }

  /// Validate user message before sending
  MessageValidation validateMessage(String message) {
    return ConversationGuardrails.validateMessage(message);
  }

  /// Build the Magic Wand prompt for structured data extraction
  String _buildMagicWandPrompt({
    required String habitName,
    required String identity,
    required bool isBreakHabit,
  }) {
    final habitTypeDescription = isBreakHabit 
        ? 'breaking a bad habit' 
        : 'building a positive habit';

    return '''
You are an expert habit coach using James Clear's Atomic Habits methodology.

The user wants help $habitTypeDescription. They provided:
- **Habit**: $habitName
- **Identity**: $identity
${isBreakHabit ? '- **Type**: Breaking a bad habit (needs substitution plan)' : '- **Type**: Building a positive habit'}

Please suggest the following to help them succeed:

1. **tinyVersion**: A 2-minute version of this habit (so small it's impossible to fail)
2. **implementationTime**: A specific time of day that would work well (format: "HH:MM" or descriptive like "After breakfast")
3. **implementationLocation**: A specific location that makes sense for this habit
4. **environmentCue**: A visual cue to place in their environment to trigger the habit
5. **temptationBundle**: Something enjoyable they could pair with this habit (optional)
6. **preHabitRitual**: A quick 10-30 second ritual to get into the right mindset (optional)
${isBreakHabit ? '''
7. **replacesHabit**: What bad habit this will replace
8. **rootCause**: The underlying trigger or cause of the bad habit
9. **substitutionPlan**: What to do instead when tempted''' : ''}

IMPORTANT: You MUST respond with a JSON block wrapped in [HABIT_DATA]...[/HABIT_DATA] markers.

Example response format:
Great! Based on your goal to become "$identity" by ${isBreakHabit ? 'stopping' : 'building'} "$habitName", here's your personalized habit plan:

[HABIT_DATA]
{
  "name": "$habitName",
  "identity": "$identity",
  "isBreakHabit": $isBreakHabit,
  "tinyVersion": "Your suggested 2-minute version",
  "implementationTime": "07:30",
  "implementationLocation": "At your desk",
  "environmentCue": "Place X on your Y",
  "temptationBundle": "While enjoying Z",
  "preHabitRitual": "Take 3 deep breaths"${isBreakHabit ? ''',
  "replacesHabit": "The bad habit being replaced",
  "rootCause": "The underlying trigger",
  "substitutionPlan": "What to do instead"''' : ''}
}
[/HABIT_DATA]

Now create a personalized plan for this user!
''';
  }

  /// Send message with timeout and retry logic
  Future<ChatMessage?> _sendWithTimeout(String message) async {
    try {
      final response = await _geminiService
          .sendMessage(
            userMessage: message,
            conversation: _conversation!,
          )
          .timeout(
            AIModelConfig.apiTimeout,
            onTimeout: () {
              throw TimeoutException('AI request timed out');
            },
          );

      _messageCount++;
      _lastRequestTime = DateTime.now();

      return response;
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('OnboardingOrchestrator: Request timed out, attempting retry...');
      }
      
      // One retry as per AIModelConfig.maxRetries
      try {
        final retryResponse = await _geminiService
            .sendMessage(
              userMessage: message,
              conversation: _conversation!,
            )
            .timeout(AIModelConfig.apiTimeout);
        
        _messageCount++;
        _lastRequestTime = DateTime.now();
        
        return retryResponse;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('OnboardingOrchestrator: Retry also failed: $e');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('OnboardingOrchestrator: Send error: $e');
      }
      return null;
    }
  }

  /// Check rate limiting
  bool _checkRateLimit() {
    if (_lastRequestTime == null) return true;
    
    final elapsed = DateTime.now().difference(_lastRequestTime!);
    return elapsed.inSeconds >= AIModelConfig.minSecondsBetweenRequests;
  }

  /// Check if conversation is at turn limit
  bool isAtTurnLimit() {
    return _messageCount >= AIModelConfig.maxConversationTurns;
  }

  /// Reset conversation state
  void resetConversation() {
    _conversation = null;
    _messageCount = 0;
    _extractedData = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Get conversation summary for debugging
  String get conversationSummary {
    if (_conversation == null) return 'No active conversation';
    return 'Conversation: ${_conversation!.id}, Messages: $_messageCount/${AIModelConfig.maxConversationTurns}';
  }

  // ============================================================
  // PHASE 2: Conversational Chat Methods
  // ============================================================

  /// Start a new onboarding conversation
  Future<ChatConversation> startConversation() async {
    _conversation = await _geminiService.startConversation(
      type: ConversationType.onboarding,
    );
    _messageCount = 0;
    _extractedData = null;
    _error = null;
    notifyListeners();
    return _conversation!;
  }

  /// Send a conversational message and get a response
  /// 
  /// Phase 2: Handles the full chat flow with:
  /// - Frustration detection (escape hatch)
  /// - Rate limiting
  /// - Turn limit enforcement
  /// - Habit data extraction from AI responses
  Future<ConversationResult> sendConversationalMessage({
    required String userMessage,
    required String userName,
  }) async {
    // Check rate limiting
    if (!_checkRateLimit()) {
      return ConversationResult.error('Please wait a moment before trying again.');
    }

    // Check turn limit
    if (isAtTurnLimit()) {
      return ConversationResult.fallback();
    }

    // Check for frustration patterns
    if (shouldFallbackToManual(userMessage)) {
      return ConversationResult.fallback();
    }

    // Start conversation if needed
    if (_conversation == null) {
      await startConversation();
    }

    _isLoading = true;
    _error = null;
    onLoadingChanged?.call(true);
    notifyListeners();

    try {
      // Build the conversational prompt
      final prompt = _buildConversationalPrompt(
        userMessage: userMessage,
        userName: userName,
      );

      // Send message with timeout
      final response = await _sendWithTimeout(prompt);

      if (response == null || response.status == MessageStatus.error) {
        _error = 'Failed to get response. Please try again.';
        onError?.call(_error!);
        return ConversationResult.error(_error!);
      }

      // Extract any habit data from the response
      final extractedData = AiResponseParser.extractHabitData(response.content);
      if (extractedData != null) {
        _extractedData = extractedData;
      }

      // Get display text (strip JSON markers for UI)
      final displayText = AiResponseParser.extractConversationalText(response.content);

      return ConversationResult.success(
        response: response,
        extractedData: extractedData,
        displayText: displayText,
      );

    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('OnboardingOrchestrator: Conversation error: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      _error = 'An error occurred. Please try again.';
      onError?.call(_error!);
      return ConversationResult.error(_error!);
    } finally {
      _isLoading = false;
      onLoadingChanged?.call(false);
      notifyListeners();
    }
  }

  /// Build the conversational prompt for ongoing chat
  String _buildConversationalPrompt({
    required String userMessage,
    required String userName,
  }) {
    // Build context from collected data
    final collectedInfo = <String>[];
    if (_extractedData != null) {
      if (_extractedData!.identity != null) {
        collectedInfo.add('- Identity: ${_extractedData!.identity}');
      }
      if (_extractedData!.name != null) {
        collectedInfo.add('- Habit name: ${_extractedData!.name}');
      }
      if (_extractedData!.tinyVersion != null) {
        collectedInfo.add('- 2-minute version: ${_extractedData!.tinyVersion}');
      }
      if (_extractedData!.implementationTime != null) {
        collectedInfo.add('- Time: ${_extractedData!.implementationTime}');
      }
      if (_extractedData!.implementationLocation != null) {
        collectedInfo.add('- Location: ${_extractedData!.implementationLocation}');
      }
    }

    final contextSection = collectedInfo.isNotEmpty
        ? '''
[PROGRESS SO FAR]
${collectedInfo.join('\n')}

'''
        : '';

    return '''
You are an expert Atomic Habits coach helping $userName create their first habit.

$contextSection[USER MESSAGE]
$userName says: "$userMessage"

[INSTRUCTIONS]
1. Respond naturally as a coach - be warm but concise
2. Guide them through the habit creation process step by step
3. Use the Identity → Habit → 2-Minute Rule → Implementation Intention flow
4. When you have enough information (identity, habit, time, location), include a [HABIT_DATA] JSON block

[HABIT_DATA FORMAT]
When ready to summarize the habit plan, include:
[HABIT_DATA]
{
  "identity": "I am someone who...",
  "name": "The habit name",
  "tinyVersion": "2-minute version",
  "implementationTime": "HH:MM or descriptive",
  "implementationLocation": "Where",
  "environmentCue": "Optional cue",
  "temptationBundle": "Optional bundle",
  "preHabitRitual": "Optional ritual",
  "isComplete": true
}
[/HABIT_DATA]

Only include [HABIT_DATA] when you have collected ALL required fields (identity, name, tinyVersion, time, location).
''';
  }

  /// Set loading state with notification
  void _setLoading(bool loading) {
    _isLoading = loading;
    onLoadingChanged?.call(loading);
    notifyListeners();
  }
}
