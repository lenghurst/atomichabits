import 'package:flutter/material.dart';
import '../../config/router/app_routes.dart';
import '../enums/voice_session_type.dart';

/// Configuration for a voice session (Strategy Pattern).
/// Uses static const instances for type safety and immutability.
class VoiceSessionConfig {
  final VoiceSessionType type;
  final String title;
  final String subtitle;
  final Color themeColor;
  final IconData icon;

  /// Optional: Message to inject immediately on session start
  final String? initialMessage;

  /// Optional: Initial greeting from the Assistant (Sherlock speaks first)
  final String? greeting;

  /// Optional: Whether to reset session context (true for Oracle)
  final bool shouldResetContext;

  /// The route to navigate to upon successful completion
  final String nextRoute;

  // Private const constructor
  const VoiceSessionConfig._({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.themeColor,
    required this.icon,
    required this.nextRoute,
    this.initialMessage,
    this.greeting,
    this.shouldResetContext = false,
  });

  // --- Static Const Instances ---

  /// Sherlock: The Parts Detective (Onboarding)
  static const sherlock = VoiceSessionConfig._(
    type: VoiceSessionType.sherlock,
    title: 'Sherlock',
    subtitle: 'Parts Detective',
    themeColor: Color(0xFF00A884), // Green
    icon: Icons.smart_toy,
    nextRoute: AppRoutes.pactReveal,
    greeting: "Hello, I'm Sherlock. I'm here to help you identify the parts of yourself that are holding you back. Shall we begin?",
    // initialMessage can be overridden in UI if needed, but not here as const
  );

  /// The Oracle: Future Architect (Step 9)
  static const oracle = VoiceSessionConfig._(
    type: VoiceSessionType.oracle,
    title: 'The Oracle',
    subtitle: 'Future Architect',
    themeColor: Color(0xFFD4AF37), // Gold
    icon: Icons.auto_awesome,
    shouldResetContext: true,
    nextRoute: AppRoutes.dashboard, // Confirmed Step 9 destination
    greeting: "Welcome back. I am the Oracle. Let us architect your future.",
  );

  /// Tough Truths: Non-Human Witness (Step 7.5 Option)
  static const toughTruths = VoiceSessionConfig._(
    type: VoiceSessionType.toughTruths,
    title: 'Tough Truths',
    subtitle: 'Radical Honesty Engine',
    themeColor: Color(0xFF64748B), // Slate Grey / Stern
    icon: Icons.gavel,
    shouldResetContext: false,
    nextRoute: AppRoutes.screening, // Step 7.5 -> Step 8
  );

  /// Create a copy with overrides (e.g. for dynamic initialMessage)
  VoiceSessionConfig copyWith({
    String? initialMessage,
  }) {
    return VoiceSessionConfig._(
      type: type,
      title: title,
      subtitle: subtitle,
      themeColor: themeColor,
      icon: icon,
      nextRoute: nextRoute,
      shouldResetContext: shouldResetContext,
      initialMessage: initialMessage ?? this.initialMessage,
      greeting: greeting,
    );
  }
}
