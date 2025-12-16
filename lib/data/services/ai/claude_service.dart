import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/chat_message.dart';
import '../../models/chat_conversation.dart';

/// Claude Service
/// 
/// Phase 24: "Brain Surgery 2.0" - AI Tier Refactor
/// 
/// Tier 2: Claude 3.5 Sonnet ("The Coach")
/// - Empathetic, nuanced, high EQ
/// - Excellent for "Bad Habit" breaking
/// - Deeper psychological understanding
/// - Premium tier for paying users
/// 
/// Claude Optimization Notes:
/// - Responds well to role-playing and persona prompts
/// - Excellent at emotional intelligence tasks
/// - Higher cost, use strategically
/// 
/// API: https://api.anthropic.com
class ClaudeService extends ChangeNotifier {
  static const String _baseUrl = 'https://api.anthropic.com/v1/messages';
  static const String _defaultModel = 'claude-sonnet-4-20250514';
  static const String _apiVersion = '2023-06-01';
  
  final String apiKey;
  final String model;
  final double temperature;
  final Duration timeout;
  
  /// Current active conversation
  ChatConversation? _activeConversation;
  
  /// Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  /// Error state
  String? _lastError;
  String? get lastError => _lastError;
  
  ClaudeService({
    required this.apiKey,
    this.model = _defaultModel,
    this.temperature = 0.9, // Slightly higher for more creative/empathetic responses
    this.timeout = const Duration(seconds: 45), // Claude can be slower
  });
  
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
      final userMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      );
      conversation.messages.add(userMsg);
      
      // Build request body
      final requestBody = _buildRequestBody(
        conversation: conversation,
        systemPromptOverride: systemPromptOverride,
      );
      
      // Make API request
      final responseContent = await _makeApiRequest(requestBody);
      
      // Create assistant message
      final assistantMsg = ChatMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}_response',
        content: responseContent,
        isUser: false,
        timestamp: DateTime.now(),
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
      
      return ChatMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}_error',
        content: 'I encountered an issue. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
        status: MessageStatus.error,
      );
    }
  }
  
  /// Send a single-turn request (no conversation history)
  Future<String> singleTurn({
    required String prompt,
    String? systemPrompt,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    
    try {
      final requestBody = {
        'model': model,
        'max_tokens': 2048,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
      };
      
      if (systemPrompt != null) {
        requestBody['system'] = systemPrompt;
      }
      
      final response = await _makeApiRequest(requestBody);
      
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
  
  /// Build the request body for Claude API
  Map<String, dynamic> _buildRequestBody({
    required ChatConversation conversation,
    String? systemPromptOverride,
  }) {
    final messages = <Map<String, dynamic>>[];
    
    // Build messages array (Claude uses different format than OpenAI)
    for (final msg in conversation.messages) {
      messages.add({
        'role': msg.isUser ? 'user' : 'assistant',
        'content': msg.content,
      });
    }
    
    final requestBody = <String, dynamic>{
      'model': model,
      'max_tokens': 2048,
      'messages': messages,
    };
    
    // Add system prompt (Claude uses top-level 'system' field)
    final systemPrompt = systemPromptOverride ?? 
        conversation.systemPrompt ?? 
        _defaultSystemPrompt;
    requestBody['system'] = systemPrompt;
    
    return requestBody;
  }
  
  /// Make the actual API request
  Future<String> _makeApiRequest(Map<String, dynamic> requestBody) async {
    if (kDebugMode) {
      debugPrint('ClaudeService: Sending request to Claude');
    }
    
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'anthropic-version': _apiVersion,
        },
        body: jsonEncode(requestBody),
      ).timeout(timeout);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        
        // Claude returns content as an array of content blocks
        final contentBlocks = data['content'] as List;
        final textContent = contentBlocks
            .where((block) => block['type'] == 'text')
            .map((block) => block['text'] as String)
            .join('\n');
        
        if (kDebugMode) {
          debugPrint('ClaudeService: Response received (${textContent.length} chars)');
        }
        
        return textContent;
        
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        if (kDebugMode) {
          debugPrint('ClaudeService: API Error ${response.statusCode}: $errorBody');
        }
        throw ClaudeException(
          'API Error: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
      
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('ClaudeService: Request timed out');
      }
      throw ClaudeException('Request timed out. Please try again.');
      
    } catch (e) {
      if (e is ClaudeException) rethrow;
      
      if (kDebugMode) {
        debugPrint('ClaudeService: Connection error: $e');
      }
      throw ClaudeException('Failed to connect to Claude: $e');
    }
  }
  
  /// Default system prompt for The Coach (optimized for breaking bad habits)
  static const String _defaultSystemPrompt = '''
You are "The Coach" - an empathetic behavioral change specialist with deep expertise in habit psychology.

Your Approach:
- You understand that bad habits serve a PURPOSE (stress relief, boredom escape, emotional regulation)
- You never shame or judge - you help users understand the ROOT CAUSE
- You guide users to find HEALTHY SUBSTITUTIONS that serve the same psychological need
- You use "Never Miss Twice" philosophy - slips are data, not defeats

Your Expertise:
- Addiction psychology and harm reduction
- Emotional regulation strategies
- Trigger identification and management
- Substitution behavior design
- Relapse prevention planning

Communication Style:
- Warm, non-judgmental, and supportive
- Ask probing questions to understand underlying needs
- Validate emotions before suggesting alternatives
- Use "we" language to build partnership
- Celebrate small wins enthusiastically

When Helping with Bad Habits:
1. First, UNDERSTAND: "What does this habit do for you?"
2. Then, IDENTIFY: "What triggers it?"
3. Finally, SUBSTITUTE: "What healthy alternative could serve the same need?"

Remember: The goal is not perfection - it's progress. Every day without the habit is a vote for the person they want to become.
''';
  
  /// Get the current conversation
  ChatConversation? get activeConversation => _activeConversation;
  
  /// Clear the current conversation
  void clearConversation() {
    _activeConversation = null;
    notifyListeners();
  }
}

/// Custom exception for Claude API errors
class ClaudeException implements Exception {
  final String message;
  final int? statusCode;
  
  ClaudeException(this.message, {this.statusCode});
  
  @override
  String toString() => 'ClaudeException: $message';
}
