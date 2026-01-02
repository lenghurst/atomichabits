import '../archetypes/archetype.dart';
import '../entities/context_snapshot.dart';
import '../entities/psychometric_profile.dart';

/// Perfectionist: Needs reassurance, fears failure, paralyzes under pressure.
class PerfectionistArchetype implements Archetype {
  @override
  String get id => 'PERFECTIONIST';
  @override
  String get displayName => 'The Perfectionist';
  @override
  String get description => 'Aims for 100%, often quits after one mistake.';
  @override
  CoachingStyle get defaultCoachingStyle => CoachingStyle.supportive; // Needs "Good enough" validation

  @override
  String getGreeting(ContextSnapshot context, PsychometricProfile profile) {
    if ((context.biometrics?.sleepZScore ?? 0) < -1) {
      return "I know you're tired, but don't let that stop you from doing a tiny version.";
    }
    return "Ready to make it perfect? Remember, done is better than perfect.";
  }

  @override
  String getMissReaction(ContextSnapshot context, PsychometricProfile profile) {
    return "Hey, one miss doesn't ruin the streak. You're still a ${profile.coreValues.firstOrNull ?? 'winner'}.";
  }

  @override
  String getSuccessReaction(ContextSnapshot context, PsychometricProfile profile) {
    return "Excellent execution! But remember to celebrate the effort, not just the result.";
  }
}

/// Rebel: Resists authority, needs autonomy, hates being told what to do.
class RebelArchetype implements Archetype {
  @override
  String get id => 'REBEL';
  @override
  String get displayName => 'The Rebel';
  @override
  String get description => 'Resists expectations. Needs to feel free.';
  @override
  CoachingStyle get defaultCoachingStyle => CoachingStyle.socratic; // Needs to choose for themselves

  @override
  String getGreeting(ContextSnapshot context, PsychometricProfile profile) {
    return "What do you want to create today? It's your call.";
  }

  @override
  String getMissReaction(ContextSnapshot context, PsychometricProfile profile) {
    return "Did you choose to skip, or did life get in the way? Either way, you're in control.";
  }

  @override
  String getSuccessReaction(ContextSnapshot context, PsychometricProfile profile) {
    return "You did it your way. Nice.";
  }
}

/// Registry to manage available archetypes
class ArchetypeRegistry {
  static final Map<String, Archetype> _archetypes = {
    'PERFECTIONIST': PerfectionistArchetype(),
    'REBEL': RebelArchetype(),
    // Add others: OBLIGER, QUESTIONER, etc.
  };

  static Archetype get(String id) {
    return _archetypes[id.toUpperCase()] ?? _archetypes['PERFECTIONIST']!; // Default
  }

  static void register(Archetype archetype) {
    _archetypes[archetype.id.toUpperCase()] = archetype;
  }
}
