import 'package:flutter/foundation.dart';
import '../../../config/ai_model_config.dart';
import '../../models/chat_message.dart';
import '../../models/chat_conversation.dart';
import '../gemini_chat_service.dart';
import 'deep_seek_service.dart';
import 'claude_service.dart';

/// AI Service Manager
/// 
/// Phase 24: "Brain Surgery 2.0" - Unified AI Tier Management
/// 
/// Architecture:
/// - Tier 1 (Default): DeepSeek-V3 "The Architect" - Reasoning-heavy, cost-effective
/// - Tier 2 (Premium): Claude 3.5 Sonnet "The Coach" - Empathetic, high EQ
/// - Tier 3 (Fallback): Gemini 2.5 Flash - Fast, reliable backup
/// - Tier 4 (Manual): No AI - User fills form manually
/// 
/// Tier Selection Logic:
/// 1. Bad Habit breaking → Claude (deeper psychology needed)
/// 2. Premium user → Claude (premium experience)
/// 3. Standard user → DeepSeek (cost-effective reasoning)
/// 4. DeepSeek fails → Gemini (fallback)
/// 5. All fail → Manual mode
class AIServiceManager extends ChangeNotifier {
  // Service instances
  DeepSeekService? _deepSeekService;
  ClaudeService? _claudeService;
  GeminiChatService? _geminiService;
  
  // Current active service
  AiProvider? _activeProvider;
  AiProvider? get activeProvider => _activeProvider;
  
  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  // Error state
  String? _lastError;
  String? get lastError => _lastError;
  
  // Active conversation
  ChatConversation? _activeConversation;
  ChatConversation? get activeConversation => _activeConversation;
  
  /// Initialize the service manager with available API keys
  AIServiceManager() {
    _initializeServices();
  }
  
  void _initializeServices() {
    // Initialize DeepSeek if key available
    if (AIModelConfig.hasDeepSeekKey) {
      _deepSeekService = DeepSeekService(
        apiKey: AIModelConfig.deepSeekApiKey,
        temperature: AIModelConfig.tier1Temperature,
      );
      if (kDebugMode) {
        debugPrint('AIServiceManager: DeepSeek service initialized');
      }
    }
    
    // Initialize Claude if key available
    if (AIModelConfig.hasClaudeKey) {
      _claudeService = ClaudeService(
        apiKey: AIModelConfig.claudeApiKey,
        temperature: AIModelConfig.tier2Temperature,
      );
      if (kDebugMode) {
        debugPrint('AIServiceManager: Claude service initialized');
      }
    }
    
    // Initialize Gemini if key available (fallback)
    if (AIModelConfig.hasGeminiKey) {
      _geminiService = GeminiChatService(
        apiKey: AIModelConfig.geminiApiKey,
      );
      if (kDebugMode) {
        debugPrint('AIServiceManager: Gemini service initialized (fallback)');
      }
    }
  }
  
  /// Check if any AI service is available
  bool get hasAnyAI => 
      _deepSeekService != null || 
      _claudeService != null || 
      _geminiService != null;
  
  /// Select the appropriate AI provider based on context
  AiProvider selectProvider({
    required bool isPremiumUser,
    required bool isBreakHabit,
  }) {
    // Bad habits always use Claude (deeper psychology needed)
    if (isBreakHabit && _claudeService != null) {
      return AiProvider.claude;
    }
    
    // Premium users get Claude
    if (isPremiumUser && _claudeService != null) {
      return AiProvider.claude;
    }
    
    // Default to DeepSeek (The Architect)
    if (_deepSeekService != null) {
      return AiProvider.deepSeek;
    }
    
    // Fallback to Gemini
    if (_geminiService != null) {
      return AiProvider.gemini;
    }
    
    // No AI available
    return AiProvider.manual;
  }
  
  /// Start a new conversation with the appropriate provider
  Future<ChatConversation?> startConversation({
    required bool isPremiumUser,
    required bool isBreakHabit,
    ConversationType type = ConversationType.onboarding,
    String? systemPrompt,
  }) async {
    _activeProvider = selectProvider(
      isPremiumUser: isPremiumUser,
      isBreakHabit: isBreakHabit,
    );
    
    if (kDebugMode) {
      debugPrint('AIServiceManager: Starting conversation with ${_activeProvider?.name}');
    }
    
    try {
      switch (_activeProvider) {
        case AiProvider.deepSeek:
          _activeConversation = await _deepSeekService!.startConversation(
            type: type,
            systemPrompt: systemPrompt,
          );
          break;
          
        case AiProvider.claude:
          _activeConversation = await _claudeService!.startConversation(
            type: type,
            systemPrompt: systemPrompt,
          );
          break;
          
        case AiProvider.gemini:
          _activeConversation = await _geminiService!.startConversation(
            type: type,
          );
          break;
          
        case AiProvider.manual:
        case null:
          return null;
      }
      
      notifyListeners();
      return _activeConversation;
      
    } catch (e) {
      _lastError = e.toString();
      notifyListeners();
      return null;
    }
  }
  
  /// Send a message to the active conversation
  Future<ChatMessage?> sendMessage({
    required String userMessage,
    String? systemPromptOverride,
  }) async {
    if (_activeConversation == null || _activeProvider == null) {
      _lastError = 'No active conversation';
      return null;
    }
    
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    
    try {
      ChatMessage response;
      
      switch (_activeProvider) {
        case AiProvider.deepSeek:
          response = await _deepSeekService!.sendMessage(
            userMessage: userMessage,
            conversation: _activeConversation!,
            systemPromptOverride: systemPromptOverride,
          );
          break;
          
        case AiProvider.claude:
          response = await _claudeService!.sendMessage(
            userMessage: userMessage,
            conversation: _activeConversation!,
            systemPromptOverride: systemPromptOverride,
          );
          break;
          
        case AiProvider.gemini:
          response = await _geminiService!.sendMessage(
            userMessage: userMessage,
            conversation: _activeConversation!,
          );
          break;
          
        case AiProvider.manual:
        case null:
          _lastError = 'No AI provider available';
          _isLoading = false;
          notifyListeners();
          return null;
      }
      
      _isLoading = false;
      notifyListeners();
      return response;
      
    } catch (e) {
      _lastError = e.toString();
      _isLoading = false;
      
      // Try fallback if primary fails
      if (_activeProvider == AiProvider.deepSeek && _geminiService != null) {
        if (kDebugMode) {
          debugPrint('AIServiceManager: DeepSeek failed, trying Gemini fallback');
        }
        return _tryFallback(userMessage);
      }
      
      notifyListeners();
      return null;
    }
  }
  
  /// Try fallback to Gemini if primary provider fails
  Future<ChatMessage?> _tryFallback(String userMessage) async {
    try {
      _activeProvider = AiProvider.gemini;
      
      // Start new conversation with Gemini
      _activeConversation = await _geminiService!.startConversation(
        type: ConversationType.onboarding,
      );
      
      final response = await _geminiService!.sendMessage(
        userMessage: userMessage,
        conversation: _activeConversation!,
      );
      
      _isLoading = false;
      notifyListeners();
      return response;
      
    } catch (e) {
      _lastError = 'All AI providers failed: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  /// Single-turn request (no conversation history)
  /// Useful for Magic Wand feature
  Future<String?> singleTurn({
    required String prompt,
    String? systemPrompt,
    bool isPremiumUser = false,
    bool isBreakHabit = false,
  }) async {
    final provider = selectProvider(
      isPremiumUser: isPremiumUser,
      isBreakHabit: isBreakHabit,
    );
    
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    
    try {
      String response;
      
      switch (provider) {
        case AiProvider.deepSeek:
          response = await _deepSeekService!.singleTurn(
            prompt: prompt,
            systemPrompt: systemPrompt,
          );
          break;
          
        case AiProvider.claude:
          response = await _claudeService!.singleTurn(
            prompt: prompt,
            systemPrompt: systemPrompt,
          );
          break;
          
        case AiProvider.gemini:
          response = await _geminiService!.generateWeeklyAnalysis(prompt) ?? 'Analysis unavailable.';
          break;
          
        case AiProvider.manual:
          _lastError = 'No AI provider available';
          _isLoading = false;
          notifyListeners();
          return null;
      }
      
      _isLoading = false;
      notifyListeners();
      return response;
      
    } catch (e) {
      _lastError = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  /// Clear the active conversation
  void clearConversation() {
    _activeConversation = null;
    _activeProvider = null;
    _lastError = null;
    notifyListeners();
  }
  
  /// Get display info for current provider
  String get providerDisplayName {
    switch (_activeProvider) {
      case AiProvider.deepSeek:
        return 'The Architect';
      case AiProvider.claude:
        return 'The Coach';
      case AiProvider.gemini:
        return 'AI Assistant';
      case AiProvider.manual:
      case null:
        return 'Manual Entry';
    }
  }
  
  String get providerDescription {
    switch (_activeProvider) {
      case AiProvider.deepSeek:
        return 'Structured habit design with behavioral engineering';
      case AiProvider.claude:
        return 'Empathetic coaching for breaking bad habits';
      case AiProvider.gemini:
        return 'Fast, efficient habit creation';
      case AiProvider.manual:
      case null:
        return 'Fill in the form yourself';
    }
  }
}

/// Available AI providers
enum AiProvider {
  deepSeek,  // Tier 1: The Architect
  claude,    // Tier 2: The Coach
  gemini,    // Tier 3: Fallback
  manual,    // Tier 4: No AI
}

/// Extension for provider display
extension AiProviderExtension on AiProvider {
  String get displayName {
    switch (this) {
      case AiProvider.deepSeek:
        return 'The Architect';
      case AiProvider.claude:
        return 'The Coach';
      case AiProvider.gemini:
        return 'AI Assistant';
      case AiProvider.manual:
        return 'Manual Entry';
    }
  }
  
  String get emoji {
    switch (this) {
      case AiProvider.deepSeek:
        return '🏗️';
      case AiProvider.claude:
        return '🧠';
      case AiProvider.gemini:
        return '✨';
      case AiProvider.manual:
        return '✏️';
    }
  }
}
