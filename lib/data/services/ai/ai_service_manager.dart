import 'package:flutter/foundation.dart';
import '../../../config/ai_model_config.dart';
import '../../models/chat_message.dart';
import '../../models/chat_conversation.dart';
import '../gemini_chat_service.dart';
import 'deep_seek_service.dart';

/// AI Service Manager
/// 
/// Phase 25.9: "Split Brain" Architecture - Unified AI Tier Management
/// Phase 27.3: Claude Lobotomy - Removed Anthropic dependency
/// 
/// Architecture (Board Approved):
/// - Tier 1 (Free): DeepSeek-V3 "The Architect" - Reasoning-heavy, cost-effective
/// - Tier 2 (Premium): Gemini 2.5 Flash - Fast, multimodal, voice-capable
/// - Tier 3 (Pro): Gemini 2.5 Pro - Deep reasoning for complex habits
/// 
/// Tier Selection Logic:
/// 1. Break Habit + Premium → Tier 3 (Gemini Pro - deeper psychology)
/// 2. Break Habit + Free → Tier 1 (DeepSeek - still capable)
/// 3. Premium user → Tier 2 (Gemini Flash - premium experience)
/// 4. Standard user → Tier 1 (DeepSeek - cost-effective reasoning)
/// 5. DeepSeek fails → Tier 2 (Gemini Flash fallback)
/// 6. All fail → Manual mode
class AIServiceManager extends ChangeNotifier {
  // Service instances
  DeepSeekService? _deepSeekService;
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
    // Initialize DeepSeek if key available (Tier 1)
    if (AIModelConfig.hasDeepSeekKey) {
      _deepSeekService = DeepSeekService(
        apiKey: AIModelConfig.deepSeekApiKey,
        temperature: AIModelConfig.tier1Temperature,
      );
      if (kDebugMode) {
        debugPrint('AIServiceManager: DeepSeek service initialised (Tier 1)');
      }
    }
    
    // Initialize Gemini if key available (Tier 2 & 3)
    if (AIModelConfig.hasGeminiKey) {
      _geminiService = GeminiChatService(
        apiKey: AIModelConfig.geminiApiKey,
      );
      if (kDebugMode) {
        debugPrint('AIServiceManager: Gemini service initialised (Tier 2/3)');
      }
    }
  }
  
  /// Check if any AI service is available
  bool get hasAnyAI => 
      _deepSeekService != null || 
      _geminiService != null;
  
  /// Select the appropriate AI provider based on context
  /// 
  /// Phase 27.3: Aligned with Board-approved "Split Brain" architecture
  /// - No Claude. Route Pro requirements to Gemini Pro (Tier 3).
  AiProvider selectProvider({
    required bool isPremiumUser,
    required bool isBreakHabit,
  }) {
    // Break habits need deeper reasoning
    if (isBreakHabit) {
      // Premium users get Gemini Pro (Tier 3) for break habits
      if (isPremiumUser && _geminiService != null) {
        return AiProvider.geminiPro; // Tier 3
      }
      // Free users still get DeepSeek for break habits (capable reasoning)
      if (_deepSeekService != null) {
        return AiProvider.deepSeek; // Tier 1
      }
    }
    
    // Premium users get Gemini Flash (Tier 2)
    if (isPremiumUser && _geminiService != null) {
      return AiProvider.gemini; // Tier 2
    }
    
    // Default to DeepSeek (Tier 1 - The Architect)
    if (_deepSeekService != null) {
      return AiProvider.deepSeek;
    }
    
    // Fallback to Gemini Flash (Tier 2)
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
          
        case AiProvider.gemini:
        case AiProvider.geminiPro:
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
          
        case AiProvider.gemini:
        case AiProvider.geminiPro:
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
          
        case AiProvider.gemini:
        case AiProvider.geminiPro:
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
      case AiProvider.gemini:
        return 'Gemini Flash';
      case AiProvider.geminiPro:
        return 'Gemini Pro';
      case AiProvider.manual:
      case null:
        return 'Manual Entry';
    }
  }
  
  String get providerDescription {
    switch (_activeProvider) {
      case AiProvider.deepSeek:
        return 'Structured habit design with behavioural engineering';
      case AiProvider.gemini:
        return 'Fast, efficient habit creation';
      case AiProvider.geminiPro:
        return 'Deep reasoning for breaking bad habits';
      case AiProvider.manual:
      case null:
        return 'Fill in the form yourself';
    }
  }
}

/// Available AI providers
/// 
/// Phase 27.3: Removed Claude. Split Brain architecture:
/// - Tier 1: DeepSeek (free)
/// - Tier 2: Gemini Flash (premium)
/// - Tier 3: Gemini Pro (pro/break habits)
enum AiProvider {
  deepSeek,   // Tier 1: The Architect (DeepSeek-V3)
  gemini,     // Tier 2: Gemini Flash (Premium)
  geminiPro,  // Tier 3: Gemini Pro (Deep Reasoning)
  manual,     // Tier 4: No AI
}

/// Extension for provider display
extension AiProviderExtension on AiProvider {
  String get displayName {
    switch (this) {
      case AiProvider.deepSeek:
        return 'The Architect';
      case AiProvider.gemini:
        return 'Gemini Flash';
      case AiProvider.geminiPro:
        return 'Gemini Pro';
      case AiProvider.manual:
        return 'Manual Entry';
    }
  }
  
  String get emoji {
    switch (this) {
      case AiProvider.deepSeek:
        return '🏗️';
      case AiProvider.gemini:
        return '✨';
      case AiProvider.geminiPro:
        return '🧠';
      case AiProvider.manual:
        return '✏️';
    }
  }
}
