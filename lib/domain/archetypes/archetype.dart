import '../entities/context_snapshot.dart';
import '../entities/psychometric_profile.dart';

/// Base class for all Behavioral Archetypes
///
/// Encapsulates the logic for how different personality types respond to:
/// - Coaching
/// - Failure
/// - Success
abstract class Archetype {
  String get id;
  String get displayName;
  String get description;

  /// Generate a greeting based on context
  String getGreeting(ContextSnapshot context, PsychometricProfile profile);

  /// Generate a reaction to a missed habit
  String getMissReaction(ContextSnapshot context, PsychometricProfile profile);

  /// Generate a reaction to success
  String getSuccessReaction(ContextSnapshot context, PsychometricProfile profile);

  /// Get recommended coaching style for this archetype
  CoachingStyle get defaultCoachingStyle;
}
