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

/// Procrastinator: Avoids discomfort, needs friction reduction.
class ProcrastinatorArchetype implements Archetype {
  @override
  String get id => 'PROCRASTINATOR';
  @override
  String get displayName => 'The Procrastinator';
  @override
  String get description => 'Delays until the last moment. Needs tiny starts.';
  @override
  CoachingStyle get defaultCoachingStyle => CoachingStyle.toughLove; // Needs clear next step

  @override
  String getGreeting(ContextSnapshot context, PsychometricProfile profile) {
    return "Just 2 minutes. That's all. Start now, decide later.";
  }

  @override
  String getMissReaction(ContextSnapshot context, PsychometricProfile profile) {
    return "Starting is the hardest part. Tomorrow, just put on your shoes.";
  }

  @override
  String getSuccessReaction(ContextSnapshot context, PsychometricProfile profile) {
    return "You started! That's the magic. The rest was easy, right?";
  }
}

/// Overthinker: Analysis paralysis, needs cognitive reframes.
class OverthinkerArchetype implements Archetype {
  @override
  String get id => 'OVERTHINKER';
  @override
  String get displayName => 'The Overthinker';
  @override
  String get description => 'Paralyzed by analysis. Needs clarity and permission.';
  @override
  CoachingStyle get defaultCoachingStyle => CoachingStyle.supportive; // Needs reassurance

  @override
  String getGreeting(ContextSnapshot context, PsychometricProfile profile) {
    return "Don't think. Just start. You can adjust as you go.";
  }

  @override
  String getMissReaction(ContextSnapshot context, PsychometricProfile profile) {
    return "Overthinking the miss won't help. One action clears the fog.";
  }

  @override
  String getSuccessReaction(ContextSnapshot context, PsychometricProfile profile) {
    return "See? Action beats analysis every time. Well done.";
  }
}

/// PleasureSeeker: Needs temptation bundling and rewards.
class PleasureSeekerArchetype implements Archetype {
  @override
  String get id => 'PLEASURE_SEEKER';
  @override
  String get displayName => 'The Pleasure Seeker';
  @override
  String get description => 'Follows dopamine. Needs bundling and immediate rewards.';
  @override
  CoachingStyle get defaultCoachingStyle => CoachingStyle.supportive; // Needs excitement

  @override
  String getGreeting(ContextSnapshot context, PsychometricProfile profile) {
    return "Make it fun. What can you pair this with?";
  }

  @override
  String getMissReaction(ContextSnapshot context, PsychometricProfile profile) {
    return "The dopamine lied. But the real reward is who you become.";
  }

  @override
  String getSuccessReaction(ContextSnapshot context, PsychometricProfile profile) {
    return "That felt good, didn't it? That's the real reward.";
  }
}

/// PeoplePleaser: Needs social accountability and external validation.
class PeoplePleaserArchetype implements Archetype {
  @override
  String get id => 'PEOPLE_PLEASER';
  @override
  String get displayName => 'The People Pleaser';
  @override
  String get description => 'Motivated by others. Needs witness accountability.';
  @override
  CoachingStyle get defaultCoachingStyle => CoachingStyle.supportive; // Needs connection

  @override
  String getGreeting(ContextSnapshot context, PsychometricProfile profile) {
    if (context.digital?.witnessName != null) {
      return "${context.digital!.witnessName} is counting on you. Show them who you are.";
    }
    return "Someone believes in you. Don't let them down.";
  }

  @override
  String getMissReaction(ContextSnapshot context, PsychometricProfile profile) {
    return "It's okay to disappoint yourself sometimes. But don't make it a habit.";
  }

  @override
  String getSuccessReaction(ContextSnapshot context, PsychometricProfile profile) {
    return "You showed up—for yourself. That's the real win.";
  }
}

/// Registry to manage available archetypes
class ArchetypeRegistry {
  static final Map<String, Archetype> _archetypes = {
    'PERFECTIONIST': PerfectionistArchetype(),
    'REBEL': RebelArchetype(),
    'PROCRASTINATOR': ProcrastinatorArchetype(),
    'OVERTHINKER': OverthinkerArchetype(),
    'PLEASURE_SEEKER': PleasureSeekerArchetype(),
    'PEOPLE_PLEASER': PeoplePleaserArchetype(),
  };

  /// Get archetype by ID (case-insensitive)
  static Archetype get(String id) {
    return _archetypes[id.toUpperCase()] ?? _archetypes['PERFECTIONIST']!;
  }

  /// Check if archetype exists
  static bool exists(String id) {
    return _archetypes.containsKey(id.toUpperCase());
  }

  /// Get all registered archetypes
  static List<Archetype> get all => _archetypes.values.toList();

  /// Get archetype IDs
  static List<String> get ids => _archetypes.keys.toList();

  /// Register a custom archetype
  static void register(Archetype archetype) {
    _archetypes[archetype.id.toUpperCase()] = archetype;
  }

  /// Get archetype for a profile (with fallback)
  static Archetype forProfile(PsychometricProfile profile) {
    final key = profile.failureArchetype?.toUpperCase() ?? 'PERFECTIONIST';
    return get(key);
  }
}
