/// Configuration for AI model integration
/// 
/// Phase 25: "The Gemini Pivot" - Multimodal Native Architecture
/// 
/// Tier Architecture:
/// - Tier 1 (Free): DeepSeek-V3 "The Mirror" - Text-only, high reasoning, low cost
/// - Tier 2 (Paid): Gemini 3 Flash "The Agent" - Native Audio/Vision, real-time voice
/// - Tier 3 (Premium): Gemini 3 Pro "The Architect" - Deep reasoning + Long Context
/// 
/// API keys are injected via environment variables at build time:
/// ```bash
/// flutter run --dart-define=DEEPSEEK_API_KEY=your_key
/// flutter run --dart-define=GEMINI_API_KEY=your_key
/// ```
class AIModelConfig {
  // === API KEYS ===
  
  /// DeepSeek API key (Tier 1 - Text Only)
  static const String deepSeekApiKey = String.fromEnvironment('DEEPSEEK_API_KEY');
  
  /// Gemini API key (Tier 2/3 - Multimodal Native)
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
  
  /// Check if DeepSeek API is configured
  static bool get hasDeepSeekKey => deepSeekApiKey.isNotEmpty;
  
  /// Check if Gemini API is configured
  static bool get hasGeminiKey => geminiApiKey.isNotEmpty;
  
  /// Check if any AI is available
  static bool get hasAnyAI => hasDeepSeekKey || hasGeminiKey;

  // === MODEL VERSIONS (DECEMBER 2025 STANDARDS) ===
  
  /// Tier 1: DeepSeek-V3 "The Mirror"
  /// - Text Input / Text Output
  /// - Cost: ~$0.14/1M tokens (Extremely Cheap)
  /// - Role: Basic logging, text chat, fallback
  static const String tier1Model = 'deepseek-chat'; 
  static const double tier1Temperature = 1.0;
  
  /// Tier 2: Gemini 3 Flash "The Agent"
  /// - Native Audio/Video Input & Output
  /// - Latency: <500ms (Real-time capable)
  /// - Role: Voice Coach, Visual Accountability
  static const String tier2Model = 'gemini-3.0-flash-exp';
  static const double tier2Temperature = 0.7;
  
  /// Tier 3: Gemini 3 Pro "The Architect"
  /// - Deep Reasoning + Agentic Planning
  /// - Role: Complex schedule restructuring, long-term pattern analysis
  static const String tier3Model = 'gemini-3.0-pro-exp';
  static const double tier3Temperature = 0.9;
  
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
  
  // === CAPABILITIES ===
  
  /// Does this tier support Native Audio Streaming?
  static bool supportsNativeVoice(AiTier tier) {
    return tier == AiTier.tier2 || tier == AiTier.tier3;
  }

  /// Does this tier support Visual Input (Camera)?
  static bool supportsVision(AiTier tier) {
    return tier == AiTier.tier2 || tier == AiTier.tier3;
  }

  // === TIER SELECTION ===
  
  /// Determine which tier to use based on user subscription
  /// 
  /// Selection Logic:
  /// 1. Pro user → Gemini 3 Pro (The Architect)
  /// 2. Premium user → Gemini 3 Flash (The Agent)
  /// 3. Free user → DeepSeek-V3 (The Mirror)
  /// 4. Fallback → Upgrade free user to Gemini if DeepSeek down
  /// 5. No AI → Manual mode
  static AiTier selectTier({
    required bool isPremiumUser,
    required bool isProUser, // Higher than premium
  }) {
    // Tier 3: The Architect (Pro)
    if (isProUser && hasGeminiKey) {
      return AiTier.tier3;
    }
    
    // Tier 2: The Agent (Standard Paid)
    if (isPremiumUser && hasGeminiKey) {
      return AiTier.tier2;
    }
    
    // Tier 1: The Mirror (Free)
    if (hasDeepSeekKey) {
      return AiTier.tier1;
    }
    
    // Fallback if DeepSeek is down but Gemini works (rare edge case)
    if (hasGeminiKey) {
      return AiTier.tier2; // Upgrade them for free temporarily
    }
    
    return AiTier.tier4;
  }
  
  /// Get the display name for a tier
  static String getTierDisplayName(AiTier tier) {
    switch (tier) {
      case AiTier.tier1:
        return 'The Mirror';
      case AiTier.tier2:
        return 'The Agent';
      case AiTier.tier3:
        return 'The Architect';
      case AiTier.tier4:
        return 'Manual Entry';
    }
  }
  
  /// Get the emoji for a tier
  static String getTierEmoji(AiTier tier) {
    switch (tier) {
      case AiTier.tier1:
        return '🪞';
      case AiTier.tier2:
        return '🎙️';
      case AiTier.tier3:
        return '🏗️';
      case AiTier.tier4:
        return '✏️';
    }
  }
}

/// Available AI tiers
enum AiTier {
  tier1, // DeepSeek-V3 - The Mirror
  tier2, // Gemini 3 Flash - The Agent
  tier3, // Gemini 3 Pro - The Architect
  tier4, // Manual Input - The Safety Net
}

/// Extension for tier display names
extension AiTierExtension on AiTier {
  String get displayName {
    switch (this) {
      case AiTier.tier1:
        return 'The Mirror';
      case AiTier.tier2:
        return 'The Agent';
      case AiTier.tier3:
        return 'The Architect';
      case AiTier.tier4:
        return 'Manual Entry';
    }
  }
  
  String get description {
    switch (this) {
      case AiTier.tier1:
        return 'Text-based habit design with behavioral engineering';
      case AiTier.tier2:
        return 'Voice-first coaching with real-time accountability';
      case AiTier.tier3:
        return 'Deep reasoning for complex habit systems';
      case AiTier.tier4:
        return 'Fill in the form yourself';
    }
  }
  
  String get emoji {
    switch (this) {
      case AiTier.tier1:
        return '🪞';
      case AiTier.tier2:
        return '🎙️';
      case AiTier.tier3:
        return '🏗️';
      case AiTier.tier4:
        return '✏️';
    }
  }
  
  String get providerName {
    switch (this) {
      case AiTier.tier1:
        return 'DeepSeek-V3';
      case AiTier.tier2:
        return 'Gemini 3 Flash';
      case AiTier.tier3:
        return 'Gemini 3 Pro';
      case AiTier.tier4:
        return 'None';
    }
  }
  
  /// Does this tier support native voice input/output?
  bool get supportsNativeVoice {
    return this == AiTier.tier2 || this == AiTier.tier3;
  }
  
  /// Does this tier support visual input (camera)?
  bool get supportsVision {
    return this == AiTier.tier2 || this == AiTier.tier3;
  }
}
