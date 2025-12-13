/// Configuration for AI model integration
/// 
/// API keys are injected via environment variables at build time:
/// ```bash
/// flutter run --dart-define=GEMINI_API_KEY=your_key
/// flutter run --dart-define=CLAUDE_API_KEY=your_key
/// ```
class AIModelConfig {
  // === API KEYS ===
  // Injected via --dart-define at build time for security
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String claudeApiKey = String.fromEnvironment('CLAUDE_API_KEY');
  
  /// Check if Gemini API is configured
  static bool get hasGeminiKey => geminiApiKey.isNotEmpty;
  
  /// Check if Claude API is configured
  static bool get hasClaudeKey => claudeApiKey.isNotEmpty;
  
  /// Check if any AI is available
  static bool get hasAnyAI => hasGeminiKey || hasClaudeKey;

  // === MODEL VERSIONS ===
  
  /// Tier 1: Speed & Cost (Gemini) - Default for free users
  static const String tier1Model = 'gemini-2.5-flash-preview-05-20';
  static const double tier1Temperature = 0.7;
  
  /// Tier 2: Depth & Warmth (Claude) - Premium/Bad Habits
  static const String tier2Model = 'claude-sonnet-4-20250514'; 
  static const double tier2Temperature = 0.9;
  
  // === GUARDRAILS ===
  
  /// Maximum time to wait for AI response
  static const Duration apiTimeout = Duration(seconds: 10);
  
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
    
    // Default to Gemini (fast, cheap)
    if (hasGeminiKey) {
      return AiTier.tier1;
    }
    
    // No AI configured - use manual fallback
    return AiTier.tier3;
  }
}

/// Available AI tiers
enum AiTier {
  tier1, // Gemini 2.5 Flash - The Architect
  tier2, // Claude 4.5 Sonnet - The Coach
  tier3, // Manual Input - The Safety Net
}

/// Extension for tier display names
extension AiTierExtension on AiTier {
  String get displayName {
    switch (this) {
      case AiTier.tier1:
        return 'AI Assistant';
      case AiTier.tier2:
        return 'AI Coach';
      case AiTier.tier3:
        return 'Manual Entry';
    }
  }
  
  String get description {
    switch (this) {
      case AiTier.tier1:
        return 'Fast, efficient habit creation';
      case AiTier.tier2:
        return 'Deep, personalized coaching';
      case AiTier.tier3:
        return 'Fill in the form yourself';
    }
  }
}
