/// Session modes for the voice coach
@Deprecated('Use VoiceSessionType and VoiceSessionConfig instead')
enum VoiceSessionMode {
  /// Onboarding mode: Sherlock Protocol with tool calls
  /// Used for initial psychometric profiling
  onboarding,

  /// Coaching mode: Standard voice coaching
  /// Uses PromptFactory with psychometric context
  coaching,

  /// Legacy mode: Uses systemInstruction directly
  /// For backward compatibility
  legacy,

  /// Oracle mode: Future Compass / Vision setting (Step 9)
  oracle,
}
