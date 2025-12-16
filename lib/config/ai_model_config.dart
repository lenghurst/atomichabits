/// Configuration for AI model integration
/// 
/// Phase 24: "Brain Surgery 2.0" - AI Tier Refactor
/// 
/// Tier Architecture:
/// - Tier 1 (Default): DeepSeek-V3 "The Architect" - Reasoning-heavy, cost-effective
/// - Tier 2 (Premium): Claude 3.5 Sonnet "The Coach" - Empathetic, high EQ
/// - Tier 3 (Fallback): Gemini 2.5 Flash - Fast, reliable backup
/// - Tier 4 (Manual): No AI - User fills form manually
/// 
/// API keys are injected via environment variables at build time:
/// ```bash
/// flutter run --dart-define=DEEPSEEK_API_KEY=your_key
/// flutter run --dart-define=CLAUDE_API_KEY=your_key
/// flutter run --dart-define=GEMINI_API_KEY=your_key
/// ```
class AIModelConfig {
  // === API KEYS ===
  // Injected via --dart-define at build time for security
  
  /// DeepSeek API key (Tier 1 - The Architect)
  static const String deepSeekApiKey = String.fromEnvironment('DEEPSEEK_API_KEY');
  
  /// Claude API key (Tier 2 - The Coach)
  static const String claudeApiKey = String.fromEnvironment('CLAUDE_API_KEY');
  
  /// Gemini API key (Tier 3 - Fallback)
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
  
  /// Check if DeepSeek API is configured
  static bool get hasDeepSeekKey => deepSeekApiKey.isNotEmpty;
  
  /// Check if Claude API is configured
  static bool get hasClaudeKey => claudeApiKey.isNotEmpty;
  
  /// Check if Gemini API is configured
  static bool get hasGeminiKey => geminiApiKey.isNotEmpty;
  
  /// Check if any AI is available
  static bool get hasAnyAI => hasDeepSeekKey || hasClaudeKey || hasGeminiKey;

  // === MODEL VERSIONS ===
  
  /// Tier 1: DeepSeek-V3 "The Architect"
  /// - Reasoning-heavy, excellent at structured output
  /// - Cost-effective for high-volume usage
  /// - Uses higher temperature (1.0-1.3) for reasoning
  static const String tier1Model = 'deepseek-chat'; // V3
  static const double tier1Temperature = 1.0;
  
  /// Tier 2: Claude 3.5 Sonnet "The Coach"
  /// - Empathetic, nuanced, high EQ
  /// - Excellent for bad habit breaking
  /// - Premium tier for paying users
  static const String tier2Model = 'claude-sonnet-4-20250514';
  static const double tier2Temperature = 0.9;
  
  /// Tier 3: Gemini 2.5 Flash (Fallback)
  /// - Fast, reliable
  /// - Used when primary tiers fail
  static const String tier3Model = 'gemini-2.5-flash-preview-05-20';
  static const double tier3Temperature = 0.7;
  
  // === GUARDRAILS ===
  
  /// Maximum time to wait for AI response
  static const Duration apiTimeout = Duration(seconds: 30);
  
  /// Maximum retries on failure
  static const int maxRetries = 1;
  
  /// Maximum conversation turns before forcing manual mode
  static const int maxConversationTurns = 15;
  
  /// Rate limiting: max messages per minute
  static const int maxMessagesPerMinute = 10;
  
  /// Minimum seconds between requests
  static const int minSecondsBetweenRequests = 2;

  // === FALLBACKS ===
  
  /// Fallback models in priority order (if primary fails)
  static const List<String> fallbackModels = [
    'gemini-2.5-flash-preview-05-20',
    'gemini-2.0-flash',
    'gemini-1.5-flash',
  ];
  
  // === TIER SELECTION ===
  
  /// Determine which tier to use based on user status and habit type
  /// 
  /// Selection Logic:
  /// 1. Bad Habit breaking → Claude (deeper psychology needed)
  /// 2. Premium user → Claude (premium experience)
  /// 3. Standard user → DeepSeek (cost-effective reasoning)
  /// 4. DeepSeek unavailable → Gemini (fallback)
  /// 5. All unavailable → Manual mode
  static AiTier selectTier({
    required bool isPremiumUser,
    required bool isBreakHabit,
  }) {
    // Bad habits always use Claude (deeper psychology needed)
    if (isBreakHabit && hasClaudeKey) {
      return AiTier.tier2;
    }
    
    // Premium users get Claude
    if (isPremiumUser && hasClaudeKey) {
      return AiTier.tier2;
    }
    
    // Default to DeepSeek (The Architect)
    if (hasDeepSeekKey) {
      return AiTier.tier1;
    }
    
    // Fallback to Gemini
    if (hasGeminiKey) {
      return AiTier.tier3;
    }
    
    // No AI configured - use manual fallback
    return AiTier.tier4;
  }
  
  /// Get the display name for a tier
  static String getTierDisplayName(AiTier tier) {
    switch (tier) {
      case AiTier.tier1:
        return 'The Architect';
      case AiTier.tier2:
        return 'The Coach';
      case AiTier.tier3:
        return 'AI Assistant';
      case AiTier.tier4:
        return 'Manual Entry';
    }
  }
  
  /// Get the emoji for a tier
  static String getTierEmoji(AiTier tier) {
    switch (tier) {
      case AiTier.tier1:
        return '🏗️';
      case AiTier.tier2:
        return '🧠';
      case AiTier.tier3:
        return '✨';
      case AiTier.tier4:
        return '✏️';
    }
  }
}

/// Available AI tiers
enum AiTier {
  tier1, // DeepSeek-V3 - The Architect
  tier2, // Claude 3.5 Sonnet - The Coach
  tier3, // Gemini 2.5 Flash - Fallback
  tier4, // Manual Input - The Safety Net
}

/// Extension for tier display names
extension AiTierExtension on AiTier {
  String get displayName {
    switch (this) {
      case AiTier.tier1:
        return 'The Architect';
      case AiTier.tier2:
        return 'The Coach';
      case AiTier.tier3:
        return 'AI Assistant';
      case AiTier.tier4:
        return 'Manual Entry';
    }
  }
  
  String get description {
    switch (this) {
      case AiTier.tier1:
        return 'Structured habit design with behavioral engineering';
      case AiTier.tier2:
        return 'Empathetic coaching for breaking bad habits';
      case AiTier.tier3:
        return 'Fast, efficient habit creation';
      case AiTier.tier4:
        return 'Fill in the form yourself';
    }
  }
  
  String get emoji {
    switch (this) {
      case AiTier.tier1:
        return '🏗️';
      case AiTier.tier2:
        return '🧠';
      case AiTier.tier3:
        return '✨';
      case AiTier.tier4:
        return '✏️';
    }
  }
  
  String get providerName {
    switch (this) {
      case AiTier.tier1:
        return 'DeepSeek-V3';
      case AiTier.tier2:
        return 'Claude 3.5 Sonnet';
      case AiTier.tier3:
        return 'Gemini 2.5 Flash';
      case AiTier.tier4:
        return 'None';
    }
  }
}
