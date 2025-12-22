/// Configuration for AI model integration
/// 
/// Phase 25.3: "The Reality Alignment" - Verified December 2025 Endpoints
/// Phase 25.9: "The Kill Switch" - Model Agnostic Failover (Peter Thiel)
/// 
/// SME Recommendation (Peter Thiel - Zero to One):
/// "You are building a single point of failure on Google's API. If Gemini's
/// native audio has an outage, your entire 'Voice First' pivot is dead.
/// Build a model-agnostic kill switch."
/// 
/// Solution: Implement a provider abstraction layer with automatic failover.
/// If Gemini fails, fall back to DeepSeek + TTS. If both fail, fall back to
/// manual entry. The user should never see a broken experience.
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
  
  /// OpenAI API key (Fallback TTS provider)
  static const String openAiApiKey = String.fromEnvironment('OPENAI_API_KEY');
  
  /// Check if DeepSeek API is configured
  static bool get hasDeepSeekKey => deepSeekApiKey.isNotEmpty;
  
  /// Check if Gemini API is configured
  static bool get hasGeminiKey => geminiApiKey.isNotEmpty;
  
  /// Check if OpenAI API is configured (for TTS fallback)
  static bool get hasOpenAiKey => openAiApiKey.isNotEmpty;
  
  /// Check if any AI is available
  static bool get hasAnyAI => hasDeepSeekKey || hasGeminiKey;

  // === MODEL VERSIONS (DECEMBER 2025 - VERIFIED ENDPOINTS) ===
  
  /// Tier 1: DeepSeek-V3 "The Mirror"
  /// - Text Input / Text Output
  /// - Cost: ~$0.14/1M tokens (Extremely Cheap)
  /// - Role: Basic logging, text chat, fallback
  static const String tier1Model = 'deepseek-chat'; 
  static const double tier1Temperature = 1.0;
  
  /// Tier 2: Gemini 2.5 Live "The Agent" (Phase 27.14 - Live GA)
  /// - Marketing Name: "Gemini 3 Flash"
  /// - Technical Endpoint: gemini-live-2.5-flash-native-audio (LIVE GA - Dec 12, 2025)
  /// - Native Audio/Video Input & Output (Live API)
  /// - Latency: <500ms (Real-time capable)
  /// - Role: Voice Coach, Visual Accountability
  /// - Protocol: WebSocket bidirectional streaming (NOT REST)
  /// - CRITICAL: Gemini 2.0 Live endpoints were SHUT DOWN on Dec 9, 2025!
  /// - NOTE: This is the stable GA Live endpoint, available globally (UK included)
  static const String tier2Model = 'gemini-2.5-flash-native-audio-preview-12-2025'; // Live API (Dec 2025)
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
  
  // === KILL SWITCH CONFIGURATION (Phase 25.9) ===
  
  /// Global kill switch - disables ALL AI features
  /// Set via Remote Config or environment variable
  static bool _globalKillSwitch = false;
  
  /// Provider-specific kill switches
  static bool _geminiKillSwitch = false;
  static bool _deepSeekKillSwitch = false;
  
  /// Voice feature kill switch (disables Live API, falls back to text)
  static bool _voiceKillSwitch = false;
  
  /// Get global kill switch state
  static bool get isGlobalKillSwitchActive => _globalKillSwitch;
  
  /// Get Gemini kill switch state
  static bool get isGeminiKillSwitchActive => _geminiKillSwitch;
  
  /// Get DeepSeek kill switch state
  static bool get isDeepSeekKillSwitchActive => _deepSeekKillSwitch;
  
  /// Get voice kill switch state
  static bool get isVoiceKillSwitchActive => _voiceKillSwitch;
  
  /// Activate global kill switch (disables all AI)
  static void activateGlobalKillSwitch() {
    _globalKillSwitch = true;
  }
  
  /// Deactivate global kill switch
  static void deactivateGlobalKillSwitch() {
    _globalKillSwitch = false;
  }
  
  /// Activate Gemini kill switch (falls back to DeepSeek)
  static void activateGeminiKillSwitch() {
    _geminiKillSwitch = true;
  }
  
  /// Deactivate Gemini kill switch
  static void deactivateGeminiKillSwitch() {
    _geminiKillSwitch = false;
  }
  
  /// Activate DeepSeek kill switch (falls back to Gemini or manual)
  static void activateDeepSeekKillSwitch() {
    _deepSeekKillSwitch = true;
  }
  
  /// Deactivate DeepSeek kill switch
  static void deactivateDeepSeekKillSwitch() {
    _deepSeekKillSwitch = false;
  }
  
  /// Activate voice kill switch (falls back to text + TTS)
  static void activateVoiceKillSwitch() {
    _voiceKillSwitch = true;
  }
  
  /// Deactivate voice kill switch
  static void deactivateVoiceKillSwitch() {
    _voiceKillSwitch = false;
  }
  
  /// Update kill switches from Remote Config
  /// 
  /// Call this on app startup and periodically to sync with server
  static void updateFromRemoteConfig(Map<String, dynamic> config) {
    _globalKillSwitch = config['ai_global_kill_switch'] as bool? ?? false;
    _geminiKillSwitch = config['ai_gemini_kill_switch'] as bool? ?? false;
    _deepSeekKillSwitch = config['ai_deepseek_kill_switch'] as bool? ?? false;
    _voiceKillSwitch = config['ai_voice_kill_switch'] as bool? ?? false;
  }
  
  // === CAPABILITIES ===
  
  /// Does this tier support Native Audio Streaming (Live API)?
  /// 
  /// Phase 25.9: Now respects voice kill switch
  static bool supportsNativeVoice(AiTier tier) {
    if (_voiceKillSwitch) return false;
    return tier == AiTier.tier2 || tier == AiTier.tier3;
  }

  /// Does this tier support Visual Input (Camera)?
  static bool supportsVision(AiTier tier) {
    return tier == AiTier.tier2 || tier == AiTier.tier3;
  }
  
  /// Does this tier require WebSocket (Live API) vs REST?
  /// 
  /// Phase 25.9: Now respects voice kill switch
  static bool requiresLiveApi(AiTier tier) {
    if (_voiceKillSwitch) return false;
    return tier == AiTier.tier2; // Only Tier 2 uses Live API for voice
  }

  // === TIER SELECTION (WITH FAILOVER) ===
  
  /// Determine which tier to use based on user subscription and kill switches
  /// 
  /// Phase 25.9: Now implements automatic failover based on kill switches
  /// Phase 27.3: Added isBreakHabit parameter for deeper reasoning
  /// 
  /// Selection Logic:
  /// 1. If global kill switch → Manual mode
  /// 2. Break habit + Premium → Tier 3 (deeper psychology needed)
  /// 3. Pro user + Gemini available → Gemini 2.5 Pro
  /// 4. Premium user + Gemini available → Gemini 2.5 Flash
  /// 5. Free user + DeepSeek available → DeepSeek-V3
  /// 6. Failover: If primary provider killed, fall back to next available
  /// 7. No AI → Manual mode
  static AiTier selectTier({
    required bool isPremiumUser,
    bool isProUser = false,
    bool isBreakHabit = false,
  }) {
    // Global kill switch - force manual mode
    if (_globalKillSwitch) {
      return AiTier.tier4;
    }
    
    // Breaking bad habits requires deeper reasoning (Tier 3)
    // Premium users get Gemini Pro for break habits
    if (isBreakHabit && isPremiumUser && hasGeminiKey && !_geminiKillSwitch) {
      return AiTier.tier3;
    }
    
    // Tier 3: The Architect (Pro)
    if (isProUser && hasGeminiKey && !_geminiKillSwitch) {
      return AiTier.tier3;
    }
    
    // Tier 2: The Agent (Standard Paid)
    if (isPremiumUser && hasGeminiKey && !_geminiKillSwitch) {
      return AiTier.tier2;
    }
    
    // Tier 1: The Mirror (Free)
    if (hasDeepSeekKey && !_deepSeekKillSwitch) {
      return AiTier.tier1;
    }
    
    // Failover: Gemini killed but DeepSeek available
    if (_geminiKillSwitch && hasDeepSeekKey && !_deepSeekKillSwitch) {
      return AiTier.tier1; // Downgrade to DeepSeek
    }
    
    // Failover: DeepSeek killed but Gemini available
    if (_deepSeekKillSwitch && hasGeminiKey && !_geminiKillSwitch) {
      return AiTier.tier2; // Upgrade to Gemini for free
    }
    
    // Fallback if DeepSeek is down but Gemini works (rare edge case)
    if (hasGeminiKey && !_geminiKillSwitch) {
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
        // Phase 25.9: Force text fallback if voice is killed
        if (_voiceKillSwitch || useTextFallback) {
          return tier2TextModel;
        }
        return tier2Model;
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
  
  /// Get the fallback tier if the current tier is unavailable
  /// 
  /// Phase 25.9: Implements the failover chain
  static AiTier getFallbackTier(AiTier currentTier) {
    switch (currentTier) {
      case AiTier.tier3:
        // Pro → Flash → DeepSeek → Manual
        if (hasGeminiKey && !_geminiKillSwitch) return AiTier.tier2;
        if (hasDeepSeekKey && !_deepSeekKillSwitch) return AiTier.tier1;
        return AiTier.tier4;
      case AiTier.tier2:
        // Flash → DeepSeek → Manual
        if (hasDeepSeekKey && !_deepSeekKillSwitch) return AiTier.tier1;
        return AiTier.tier4;
      case AiTier.tier1:
        // DeepSeek → Flash (upgrade) → Manual
        if (hasGeminiKey && !_geminiKillSwitch) return AiTier.tier2;
        return AiTier.tier4;
      case AiTier.tier4:
        // Manual has no fallback
        return AiTier.tier4;
    }
  }
  
  /// Check if a tier is currently available (not killed)
  static bool isTierAvailable(AiTier tier) {
    if (_globalKillSwitch) return tier == AiTier.tier4;
    
    switch (tier) {
      case AiTier.tier1:
        return hasDeepSeekKey && !_deepSeekKillSwitch;
      case AiTier.tier2:
      case AiTier.tier3:
        return hasGeminiKey && !_geminiKillSwitch;
      case AiTier.tier4:
        return true; // Manual is always available
    }
  }
  
  /// Get status summary for debugging/admin UI
  static Map<String, dynamic> getStatusSummary() {
    return {
      'globalKillSwitch': _globalKillSwitch,
      'geminiKillSwitch': _geminiKillSwitch,
      'deepSeekKillSwitch': _deepSeekKillSwitch,
      'voiceKillSwitch': _voiceKillSwitch,
      'hasGeminiKey': hasGeminiKey,
      'hasDeepSeekKey': hasDeepSeekKey,
      'hasOpenAiKey': hasOpenAiKey,
      'tier1Available': isTierAvailable(AiTier.tier1),
      'tier2Available': isTierAvailable(AiTier.tier2),
      'tier3Available': isTierAvailable(AiTier.tier3),
      'voiceEnabled': !_voiceKillSwitch && hasGeminiKey && !_geminiKillSwitch,
    };
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
    return AIModelConfig.supportsNativeVoice(this);
  }
  
  /// Does this tier support visual input (camera)?
  bool get supportsVision {
    return AIModelConfig.supportsVision(this);
  }
  
  /// Does this tier require WebSocket (Live API) vs REST?
  bool get requiresLiveApi {
    return AIModelConfig.requiresLiveApi(this);
  }
  
  /// Is this tier currently available?
  bool get isAvailable {
    return AIModelConfig.isTierAvailable(this);
  }
  
  /// Get the fallback tier if this one fails
  AiTier get fallback {
    return AIModelConfig.getFallbackTier(this);
  }
}
