import 'user_profile.dart';

/// Configuration for celebration animations and feedback
/// Maps CelebrationStyle to concrete behaviour
class CelebrationConfig {
  final bool enableHaptic; // Whether to trigger haptic feedback
  final double bounceScale; // Scale factor for bounce animation (1.0 = no scale)
  final Duration animationDuration; // How long animations last
  final bool enableSparkles; // Whether to show subtle sparkle effects

  const CelebrationConfig({
    required this.enableHaptic,
    required this.bounceScale,
    required this.animationDuration,
    required this.enableSparkles,
  });
}

/// Maps celebration style to concrete celebration behaviour
/// Keeps animations subtle and appropriate for calm, identity-first app
CelebrationConfig configForStyle(CelebrationStyle style) {
  switch (style) {
    case CelebrationStyle.calm:
      return const CelebrationConfig(
        enableHaptic: false, // No haptics for bedtime/quiet habits
        bounceScale: 1.02, // Very subtle scale (2% increase)
        animationDuration: Duration(milliseconds: 150), // Quick and gentle
        enableSparkles: false, // No visual distractions
      );

    case CelebrationStyle.standard:
      return const CelebrationConfig(
        enableHaptic: true, // Light haptic tap
        bounceScale: 1.05, // Modest scale (5% increase)
        animationDuration: Duration(milliseconds: 180), // Balanced timing
        enableSparkles: false, // Keep it clean
      );

    case CelebrationStyle.lively:
      return const CelebrationConfig(
        enableHaptic: true, // Haptic feedback
        bounceScale: 1.08, // More noticeable scale (8% increase)
        animationDuration: Duration(milliseconds: 200), // Slightly longer
        enableSparkles: true, // Very subtle sparkle effect (if implemented)
      );
  }
}
