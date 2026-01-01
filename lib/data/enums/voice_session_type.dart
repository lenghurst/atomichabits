/// Defines the distinct types of voice sessions available in the app.
/// Used by VoiceSessionConfig to determine behavior and PromptFactory for system instructions.
enum VoiceSessionType {
  /// Sherlock: The Onboarding Profiler (Parts Detective)
  sherlock,

  /// The Oracle: Future Architect (Step 9)
  oracle,

  /// Tough Truths: Radical Honesty Engine (Step 7.5)
  toughTruths,
  
  /// Standard Coaching: General habit coaching
  coaching,
}
