/// Defines the distinct types of voice sessions available in the app.
/// Used by VoiceSessionConfig to determine behavior and PromptFactory for system instructions.
///
/// Phase 65: Hybrid Voice Provider Routing
/// - Some sessions prefer OpenAI for explicit emotion metadata (2025 API)
/// - Others prefer Gemini for cost savings (token-based pricing)
enum VoiceSessionType {
  /// Sherlock: The Onboarding Profiler (Parts Detective)
  /// Prefers OpenAI: Emotion metadata critical for identifying shadow parts
  sherlock,

  /// The Oracle: Future Architect (Step 9)
  /// Prefers Gemini: Cost-efficient for future visioning
  oracle,

  /// Tough Truths: Radical Honesty Engine (Step 7.5)
  /// Prefers OpenAI: Emotion detection for confrontation dynamics
  toughTruths,

  /// Standard Coaching: General habit coaching
  /// Prefers Gemini: Cost-efficient for daily check-ins
  coaching,
}

/// Extension for VoiceSessionType to determine provider preference
extension VoiceSessionTypeExtension on VoiceSessionType {
  /// Returns true if this session type benefits from OpenAI's explicit emotion metadata.
  ///
  /// OpenAI Realtime API (2025) provides:
  /// - Explicit emotion JSON metadata (tone, emphasis, sentiment)
  /// - Direct audio processing preserving emotional nuance
  ///
  /// Trade-off: ~$0.06/min vs Gemini's token-based pricing
  bool get prefersOpenAI {
    switch (this) {
      case VoiceSessionType.sherlock:
        // Parts detective needs emotional cues to identify shadow archetypes
        return true;
      case VoiceSessionType.toughTruths:
        // Radical honesty requires detecting defensiveness/resistance
        return true;
      case VoiceSessionType.oracle:
        // Future visioning is more cognitive than emotional
        return false;
      case VoiceSessionType.coaching:
        // General coaching prioritizes cost efficiency
        return false;
    }
  }

  /// Returns the recommended voice provider for this session type.
  /// Returns 'openai' or 'gemini'.
  String get recommendedProvider => prefersOpenAI ? 'openai' : 'gemini';

  /// Human-readable reason for the provider preference
  String get providerReason {
    switch (this) {
      case VoiceSessionType.sherlock:
        return 'Emotion metadata helps identify shadow parts';
      case VoiceSessionType.toughTruths:
        return 'Detects defensiveness and emotional resistance';
      case VoiceSessionType.oracle:
        return 'Cost-efficient for future visioning';
      case VoiceSessionType.coaching:
        return 'Cost-efficient for daily check-ins';
    }
  }
}
