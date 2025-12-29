import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/chat_message.dart';
import '../../models/chat_conversation.dart';

/// DeepSeek Service
/// 
/// Phase 24: "Brain Surgery 2.0" - AI Tier Refactor
/// Phase 40: Added response_format: json_object for cleaner output
/// 
/// Tier 1: DeepSeek-V3 ("The Architect")
/// - Reasoning-heavy, distinct personality
/// - Highly efficient and cost-effective
/// - Excellent at structured output (JSON)
/// - OpenAI-compatible API
/// 
/// DeepSeek V3 Optimization Notes:
/// - Uses higher temperature (1.0-1.3) for better reasoning
/// - Responds well to ### HEADERS and CAPITALIZED DIRECTIVES
/// - Excels at step-by-step thinking protocols
/// 
/// API: https://api.deepseek.com (OpenAI-compatible)
/// 
/// Phase 24.D: Refactored for Dependency Injection (Testability)
/// - Accepts optional http.Client for mock testing
/// - Allows "Offline Simulation" without live API keys
class DeepSeekService extends ChangeNotifier {
  static const String _baseUrl = 'https://api.deepseek.com/chat/completions';
  static const String _defaultModel = 'deepseek-chat'; // V3
  
  final String apiKey;
  final String model;
  final double temperature;
  final Duration timeout;
  
  /// HTTP client for API requests (injectable for testing)
  final http.Client _client;
  
  /// Current active conversation
  ChatConversation? _activeConversation;
  
  /// Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  /// Error state
  String? _lastError;
  String? get lastError => _lastError;
  
  /// Phase 24.D: Constructor with optional client for Dependency Injection
  /// 
  /// Usage in production: DeepSeekService(apiKey: 'xxx')
  /// Usage in tests: DeepSeekService(apiKey: 'test', client: mockClient)
  DeepSeekService({
    required this.apiKey,
    this.model = _defaultModel,
    this.temperature = 1.0, // DeepSeek recommends higher temp for reasoning
    this.timeout = const Duration(seconds: 30),
    http.Client? client,
  }) : _client = client ?? http.Client();
  
  /// Check if the service is configured
  bool get isConfigured => apiKey.isNotEmpty;
  
  /// Start a new conversation
  Future<ChatConversation> startConversation({
    ConversationType type = ConversationType.onboarding,
    String? systemPrompt,
  }) async {
    _activeConversation = ChatConversation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      systemPrompt: systemPrompt,
      createdAt: DateTime.now(),
    );
    
    notifyListeners();
    return _activeConversation!;
  }
  
  /// Send a message and get a response
  /// 
  /// This is the main interface for chat interactions.
  /// Handles conversation history, API calls, and response parsing.
  Future<ChatMessage> sendMessage({
    required String userMessage,
    required ChatConversation conversation,
    String? systemPromptOverride,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    
    try {
      // Add user message to conversation
      final userMsg = ChatMessage.user(
        content: userMessage,
      );
      conversation.messages.add(userMsg);
      
      // Build messages array for API
      final messages = _buildMessagesArray(
        conversation: conversation,
        systemPromptOverride: systemPromptOverride,
      );
      
      // Make API request
      final responseContent = await _makeApiRequest(messages);
      
      // Create assistant message
      final assistantMsg = ChatMessage.assistant(
        content: responseContent,
        status: MessageStatus.sent,
      );
      
      // Add to conversation
      conversation.messages.add(assistantMsg);
      
      _isLoading = false;
      notifyListeners();
      
      return assistantMsg;
      
    } catch (e) {
      _isLoading = false;
      _lastError = e.toString();
      notifyListeners();
      
      // Return error message
      return ChatMessage.assistant(
        content: 'I encountered an issue. Please try again.',
        status: MessageStatus.error,
      );
    }
  }
  
  /// Send a single-turn request (no conversation history)
  /// 
  /// Useful for one-shot completions like Magic Wand
  Future<String> singleTurn({
    required String prompt,
    String? systemPrompt,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    
    try {
      final messages = <Map<String, dynamic>>[];
      
      if (systemPrompt != null) {
        messages.add({
          'role': 'system',
          'content': systemPrompt,
        });
      }
      
      messages.add({
        'role': 'user',
        'content': prompt,
      });
      
      final response = await _makeApiRequest(messages);
      
      _isLoading = false;
      notifyListeners();
      
      return response;
      
    } catch (e) {
      _isLoading = false;
      _lastError = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  /// Build the messages array for the API request
  List<Map<String, dynamic>> _buildMessagesArray({
    required ChatConversation conversation,
    String? systemPromptOverride,
  }) {
    final messages = <Map<String, dynamic>>[];
    
    // Add system prompt
    final systemPrompt = systemPromptOverride ?? 
        conversation.systemPrompt ?? 
        _defaultSystemPrompt;
    
    messages.add({
      'role': 'system',
      'content': systemPrompt,
    });
    
    // Add conversation history
    for (final msg in conversation.messages) {
      messages.add({
        'role': msg.isUser ? 'user' : 'assistant',
        'content': msg.content,
      });
    }
    
    return messages;
  }
  
  /// Make the actual API request
  /// 
  /// Phase 24.D: Uses injected _client for testability
  Future<String> _makeApiRequest(List<Map<String, dynamic>> messages) async {
    // Phase 34.4: Validate API key before making request
    if (apiKey.isEmpty) {
      debugPrint('❌ DeepSeekService: API Key is MISSING!');
      debugPrint('❌ Build with: flutter build apk --debug --dart-define-from-file=secrets.json');
      throw DeepSeekException('API key not configured. Check secrets.json and rebuild.');
    }
    
    if (kDebugMode) {
      debugPrint('DeepSeekService: Sending request with ${messages.length} messages');
      debugPrint('DeepSeekService: API key starts with: ${apiKey.substring(0, apiKey.length > 5 ? 5 : apiKey.length)}...');
    }
    
    try {
      final response = await _client.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': model,
          'messages': messages,
          'temperature': temperature,
          'max_tokens': 2048,
          'stream': false,
          // Phase 40: Force JSON output to reduce Markdown pollution
          // Note: System prompt MUST contain the word "JSON" for this to work
          'response_format': {'type': 'json_object'},
        }),
      ).timeout(timeout);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'] as String;
        
        if (kDebugMode) {
          debugPrint('DeepSeekService: Response received (${content.length} chars)');
        }
        
        return content;
        
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        if (kDebugMode) {
          debugPrint('DeepSeekService: API Error ${response.statusCode}: $errorBody');
        }
        throw DeepSeekException(
          'API Error: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
      
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('DeepSeekService: Request timed out');
      }
      throw DeepSeekException('Request timed out. Please try again.');
      
    } catch (e) {
      if (e is DeepSeekException) rethrow;
      
      if (kDebugMode) {
        debugPrint('DeepSeekService: Connection error: $e');
      }
      throw DeepSeekException('Failed to connect to DeepSeek: $e');
    }
  }
  
  /// Default system prompt for The Architect
  static const String _defaultSystemPrompt = '''
### IDENTITY
You are "The Architect" - a behavioral engineer specializing in Atomic Habits methodology.
You build systems that cannot fail, rather than relying on motivation (which will fail).

### CORE PHILOSOPHY
- "Graceful Consistency > Fragile Streaks"
- Missing a day is data, not defeat
- The goal is "Never Miss Twice"
- Identity precedes behavior ("I am someone who..." before "I will...")

### THINKING PROTOCOL
Before EVERY response, reason through:
1. Is this habit specific enough to track?
2. Can this be done in 2 MINUTES or less?
3. Does it connect to an identity?
4. What will cause it to fail?

### NEGATIVE CONSTRAINTS (ENFORCE STRICTLY)
- REJECT habits over 2 minutes (negotiate down)
- REJECT vague habits ("exercise more" -> ask for specific action)
- REJECT outcome goals ("lose weight" -> ask for daily action)
- REJECT multiple habits (focus on ONE)

### RESPONSE STYLE
- Warm but direct
- 2-3 sentences max per response
- Ask ONE question at a time
- Use "You" not "We"

### OUTPUT FORMAT
Respond in JSON format with the following structure:
{"message": "your conversational response", "data": {optional structured data}}
''';
  
  /// Get the current conversation
  ChatConversation? get activeConversation => _activeConversation;
  
  /// Clear the current conversation
  void clearConversation() {
    _activeConversation = null;
    notifyListeners();
  }
}

/// Custom exception for DeepSeek API errors
class DeepSeekException implements Exception {
  final String message;
  final int? statusCode;
  
  DeepSeekException(this.message, {this.statusCode});
  
  @override
  String toString() => 'DeepSeekException: $message';
}
