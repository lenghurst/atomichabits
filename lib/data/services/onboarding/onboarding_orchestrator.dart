import 'dart:async';
import 'package:flutter/foundation.dart';
import '../gemini_chat_service.dart';
import '../../models/onboarding_data.dart';
import '../../models/chat_conversation.dart';
import '../../models/chat_message.dart';
import '../../../config/ai_model_config.dart';
import 'ai_response_parser.dart';
import 'conversation_guardrails.dart';

/// Orchestrates the AI onboarding flow
/// 
/// The "Brain" of the Phase 1 Magic Wand feature.
/// Connects UI to AI services, handles tier selection, and manages fallbacks.
class OnboardingOrchestrator {
  final GeminiChatService _geminiService;
  
  /// Current conversation state
  ChatConversation? _conversation;
  
  /// Number of messages sent in current conversation
  int _messageCount = 0;
  
  /// Last request timestamp for rate limiting
  DateTime? _lastRequestTime;
  
  /// Loading state callback
  final void Function(bool isLoading)? onLoadingChanged;
  
  /// Error callback
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
  }

  /// Get conversation summary for debugging
  String get conversationSummary {
    if (_conversation == null) return 'No active conversation';
    return 'Conversation: ${_conversation!.id}, Messages: $_messageCount/${AIModelConfig.maxConversationTurns}';
  }
}
