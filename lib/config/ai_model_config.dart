/// Configuration for AI model integration
/// 
/// Phase 25.3: "The Reality Alignment" - Verified December 2025 Endpoints
/// 
/// Tier Architecture:
/// - Tier 1 (Free): DeepSeek-V3 "The Mirror" - Text-only, high reasoning, low cost
/// - Tier 2 (Paid): Gemini 2.5 Flash Native Audio "The Agent" - Real-time voice
/// - Tier 3 (Premium): Gemini 2.5 Pro "The Architect" - Deep reasoning + Long Context
/// 
/// IMPORTANT: Marketing vs Technical Reality
/// - Marketing: "Gemini 3 Flash" / "Gemini 3 Pro" (December 2025 branding)
/// - Technical: "gemini-2.5-flash-native-audio-preview-12-2025" / "gemini-2.5-pro"
/// - The "3.0" endpoints do NOT exist. Always use the 2.5 series for API calls.
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

  // === MODEL VERSIONS (DECEMBER 2025 - VERIFIED ENDPOINTS) ===
  
  /// Tier 1: DeepSeek-V3 "The Mirror"
  /// - Text Input / Text Output
  /// - Cost: ~$0.14/1M tokens (Extremely Cheap)
  /// - Role: Basic logging, text chat, fallback
  static const String tier1Model = 'deepseek-chat'; 
  static const double tier1Temperature = 1.0;
  
  /// Tier 2: Gemini 2.5 Flash Native Audio "The Agent"
  /// - Marketing Name: "Gemini 3 Flash"
  /// - Technical Endpoint: gemini-2.5-flash-native-audio-preview-12-2025
  /// - Native Audio/Video Input & Output (Live API)
  /// - Latency: <500ms (Real-time capable)
  /// - Role: Voice Coach, Visual Accountability
  /// - Protocol: WebSocket bidirectional streaming (NOT REST)
  static const String tier2Model = 'gemini-2.5-flash-native-audio-preview-12-2025';
  static const double tier2Temperature = 0.7;
  
  /// Tier 2 Text-Only Fallback (for non-voice interactions)
  /// - Used when Live API is not required (text chat)
  /// - Standard REST API compatible
  static const String tier2TextModel = 'gemini-2.5-flash';
  
  /// Tier 3: Gemini 2.5 Pro "The Architect"
  /// - Marketing Name: "Gemini 3 Pro"
  /// - Technical Endpoint: gemini-2.5-pro
  /// - Deep Reasoning + Agentic Planning
  /// - Role: Complex schedule restructuring, long-term pattern analysis
  static const String tier3Model = 'gemini-2.5-pro';
  static const double tier3Temperature = 0.9;
  
  // === LIVE API CONFIGURATION ===
  
  /// Live API version required for native audio streaming
  static const String liveApiVersion = 'v1alpha';
  
  /// Audio input format: 16-bit PCM, 16kHz, mono
  static const String audioInputMimeType = 'audio/pcm;rate=16000';
  
  /// Audio output sample rate: 24kHz
  static const int audioOutputSampleRate = 24000;
  
  /// Audio input sample rate: 16kHz
  static const int audioInputSampleRate = 16000;
  
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
  
  /// Does this tier support Native Audio Streaming (Live API)?
  static bool supportsNativeVoice(AiTier tier) {
    return tier == AiTier.tier2 || tier == AiTier.tier3;
  }

  /// Does this tier support Visual Input (Camera)?
  static bool supportsVision(AiTier tier) {
    return tier == AiTier.tier2 || tier == AiTier.tier3;
  }
  
  /// Does this tier require WebSocket (Live API) vs REST?
  static bool requiresLiveApi(AiTier tier) {
    return tier == AiTier.tier2; // Only Tier 2 uses Live API for voice
  }

  // === TIER SELECTION ===
  
  /// Determine which tier to use based on user subscription
  /// 
  /// Selection Logic:
  /// 1. Pro user → Gemini 2.5 Pro (The Architect)
  /// 2. Premium user → Gemini 2.5 Flash Native Audio (The Agent)
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
  
  /// Get the model string for a tier
  /// 
  /// [useTextFallback] - If true, returns text-only model for Tier 2
  /// (used when Live API is not needed, e.g., text chat)
  static String getModelForTier(AiTier tier, {bool useTextFallback = false}) {
    switch (tier) {
      case AiTier.tier1:
        return tier1Model;
      case AiTier.tier2:
        return useTextFallback ? tier2TextModel : tier2Model;
      case AiTier.tier3:
        return tier3Model;
      case AiTier.tier4:
        return ''; // Manual mode, no model
    }
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
  
  /// Get the marketing name for UI display
  /// (Users see "Gemini 3", code calls "Gemini 2.5")
  static String getMarketingName(AiTier tier) {
    switch (tier) {
      case AiTier.tier1:
        return 'DeepSeek-V3';
      case AiTier.tier2:
        return 'Gemini 3 Flash'; // Marketing name
      case AiTier.tier3:
        return 'Gemini 3 Pro'; // Marketing name
      case AiTier.tier4:
        return 'Manual';
    }
  }
}

/// Available AI tiers
enum AiTier {
  tier1, // DeepSeek-V3 - The Mirror
  tier2, // Gemini 2.5 Flash Native Audio - The Agent
  tier3, // Gemini 2.5 Pro - The Architect
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
        return 'Text-based habit design with behavioural engineering';
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
  
  /// Marketing name for UI display
  /// (Users see "Gemini 3", code calls "Gemini 2.5")
  String get marketingName {
    switch (this) {
      case AiTier.tier1:
        return 'DeepSeek-V3';
      case AiTier.tier2:
        return 'Gemini 3 Flash';
      case AiTier.tier3:
        return 'Gemini 3 Pro';
      case AiTier.tier4:
        return 'Manual';
    }
  }
  
  /// Technical provider name (actual API endpoint)
  String get providerName {
    switch (this) {
      case AiTier.tier1:
        return 'DeepSeek-V3';
      case AiTier.tier2:
        return 'Gemini 2.5 Flash Native Audio';
      case AiTier.tier3:
        return 'Gemini 2.5 Pro';
      case AiTier.tier4:
        return 'None';
    }
  }
  
  /// Does this tier support native voice input/output (Live API)?
  bool get supportsNativeVoice {
    return this == AiTier.tier2 || this == AiTier.tier3;
  }
  
  /// Does this tier support visual input (camera)?
  bool get supportsVision {
    return this == AiTier.tier2 || this == AiTier.tier3;
  }
  
  /// Does this tier require WebSocket (Live API) vs REST?
  bool get requiresLiveApi {
    return this == AiTier.tier2;
  }
}
