/// Identity-First Intervention Taxonomy for JITAI System
///
/// Philosophy: Every intervention should strengthen the user's identity,
/// not just drive compliance. Completion is a side effect of identity.
///
/// Simplified Architecture:
/// - 3 MetaLevers (not 5): Activate, Support, Trust
/// - 12 Arms (not 35): Only identity-compatible interventions
/// - No dead features: Removed trait affinity, regulatory focus, vulnerability range
///
/// Phase 63b: Identity-First JITAI Refactor

// =============================================================================
// TIER 1: META-LEVERS (3 Strategic Options)
// =============================================================================

/// High-level intervention strategies aligned with identity formation.
///
/// Three levers that map to psychological states:
/// - ACTIVATE: "Remember who you're becoming" (motivation through identity)
/// - SUPPORT: "Make it easier / Handle the hard" (ability + emotional)
/// - TRUST: "You've got this / Your choice" (autonomy + reverse psychology)
enum MetaLever {
  /// ACTIVATE: Identity-based motivation
  /// "What would a [identity] do right now?"
  activate,

  /// SUPPORT: Barrier reduction + emotional support
  /// "Just 2 minutes" or "Rough day. That's real."
  support,

  /// TRUST: Autonomy preservation + reverse psychology
  /// Strategic silence or "Your call today"
  trust,
}

extension MetaLeverExtension on MetaLever {
  String get displayName {
    switch (this) {
      case MetaLever.activate:
        return 'Activation';
      case MetaLever.support:
        return 'Support';
      case MetaLever.trust:
        return 'Trust';
    }
  }

  String get description {
    switch (this) {
      case MetaLever.activate:
        return 'Strengthen identity through mirror, vote, or witness';
      case MetaLever.support:
        return 'Lower barriers or provide emotional support';
      case MetaLever.trust:
        return 'Preserve autonomy or use reverse psychology';
    }
  }

  /// Categories that belong to this meta-lever
  List<InterventionCategory> get categories {
    switch (this) {
      case MetaLever.activate:
        return [
          InterventionCategory.identityActivation,
          InterventionCategory.socialWitness,
        ];
      case MetaLever.support:
        return [
          InterventionCategory.frictionReduction,
          InterventionCategory.emotionalRegulation,
          InterventionCategory.cognitiveReframe,
        ];
      case MetaLever.trust:
        return [
          InterventionCategory.silence,
          InterventionCategory.shadowIntervention,
        ];
    }
  }

  /// Population prior success rate (cold start)
  double get priorSuccessRate {
    switch (this) {
      case MetaLever.activate:
        return 0.50; // Identity works well for most
      case MetaLever.support:
        return 0.55; // Support is broadly effective
      case MetaLever.trust:
        return 0.35; // Risky but important for autonomy
    }
  }
}

// =============================================================================
// TIER 2: INTERVENTION CATEGORIES
// =============================================================================

/// Intervention categories - simplified from 9 to 7.
enum InterventionCategory {
  // === ACTIVATE ===
  identityActivation, // "What would a runner do?"
  socialWitness, // Accountability partner awareness

  // === SUPPORT ===
  frictionReduction, // Tiny version, environment design
  emotionalRegulation, // Compassion, urge surfing
  cognitiveReframe, // Zoom out, lie callout

  // === TRUST ===
  silence, // Strategic absence
  shadowIntervention, // Reverse psychology for rebels
}

extension InterventionCategoryExtension on InterventionCategory {
  String get displayName {
    switch (this) {
      case InterventionCategory.identityActivation:
        return 'Identity Activation';
      case InterventionCategory.socialWitness:
        return 'Social Witness';
      case InterventionCategory.frictionReduction:
        return 'Friction Reduction';
      case InterventionCategory.emotionalRegulation:
        return 'Emotional Regulation';
      case InterventionCategory.cognitiveReframe:
        return 'Cognitive Reframe';
      case InterventionCategory.silence:
        return 'Strategic Silence';
      case InterventionCategory.shadowIntervention:
        return 'Shadow Challenge';
    }
  }

  MetaLever get metaLever {
    switch (this) {
      case InterventionCategory.identityActivation:
      case InterventionCategory.socialWitness:
        return MetaLever.activate;
      case InterventionCategory.frictionReduction:
      case InterventionCategory.emotionalRegulation:
      case InterventionCategory.cognitiveReframe:
        return MetaLever.support;
      case InterventionCategory.silence:
      case InterventionCategory.shadowIntervention:
        return MetaLever.trust;
    }
  }
}

// =============================================================================
// INTERVENTION ARMS (Simplified - 12 Identity-Compatible)
// =============================================================================

/// An individual intervention type - simplified for identity focus.
///
/// Removed:
/// - traitAffinity (Big Five) - dead code, always returned 1.0
/// - RegulatoryFocus - no effect on selection
/// - VulnerabilityRange - always (0.0, 1.0)
/// - Most prerequisites - only 2 actually worked
class InterventionArm {
  final String armId;
  final InterventionCategory category;
  final String displayName;
  final String description;

  // === CORE FEATURES ===
  final double energyCost; // 0.0-1.0 (user effort required)
  final double intrusiveness; // 0.0-1.0 (attention disruption)
  final double identityReinforcement; // 0.0-1.0 (identity salience boost)
  final double emotionalValence; // -1.0 to 1.0 (negative to positive)

  // === CONTEXT REQUIREMENTS (Simplified) ===
  final bool requiresWitness; // Has accountability partner
  final bool requiresRebelArchetype; // Only for rebels
  final bool applicableToBreakHabits;

  // === ML PRIORS ===
  final double priorAlpha; // Beta distribution alpha (successes)
  final double priorBeta; // Beta distribution beta (failures)

  const InterventionArm({
    required this.armId,
    required this.category,
    required this.displayName,
    required this.description,
    required this.energyCost,
    required this.intrusiveness,
    required this.identityReinforcement,
    required this.emotionalValence,
    this.requiresWitness = false,
    this.requiresRebelArchetype = false,
    this.applicableToBreakHabits = true,
    this.priorAlpha = 1.0,
    this.priorBeta = 1.0,
  });

  MetaLever get metaLever => category.metaLever;

  /// Prior success rate from population data
  double get priorSuccessRate => priorAlpha / (priorAlpha + priorBeta);

  /// Simplified feature vector for bandit context
  Map<String, double> toFeatureVector() {
    return {
      'energy_cost': energyCost,
      'intrusiveness': intrusiveness,
      'identity_reinforcement': identityReinforcement,
      'emotional_valence': emotionalValence,
    };
  }
}

// =============================================================================
// INTERVENTION TAXONOMY REGISTRY (12 Arms)
// =============================================================================

/// Central registry of identity-compatible intervention arms.
///
/// Selection Criteria:
/// - High identity reinforcement (>0.5)
/// - Aligned with The Pact philosophy
/// - Removed: external rewards, streak badges, point systems
class InterventionTaxonomy {
  static final List<InterventionArm> allArms = [
    // =========================================================================
    // ACTIVATE: Identity Activation (3 arms)
    // =========================================================================
    const InterventionArm(
      armId: 'ID_MIRROR',
      category: InterventionCategory.identityActivation,
      displayName: 'Identity Mirror',
      description: 'What would a [identity] do right now?',
      energyCost: 0.1,
      intrusiveness: 0.3,
      identityReinforcement: 0.9,
      emotionalValence: 0.6,
      priorAlpha: 4.5,
      priorBeta: 5.5,
    ),
    const InterventionArm(
      armId: 'ID_ANTI_WARN',
      category: InterventionCategory.identityActivation,
      displayName: 'Anti-Identity Warning',
      description: 'The [anti-identity] hits snooze. You?',
      energyCost: 0.2,
      intrusiveness: 0.5,
      identityReinforcement: 0.85,
      emotionalValence: -0.2, // Slightly negative (fear-based)
      priorAlpha: 3.8,
      priorBeta: 6.2,
    ),
    const InterventionArm(
      armId: 'ID_VOTE',
      category: InterventionCategory.identityActivation,
      displayName: 'Vote Casting Frame',
      description: 'Cast your vote: I am a [identity].',
      energyCost: 0.15,
      intrusiveness: 0.25,
      identityReinforcement: 0.8,
      emotionalValence: 0.7,
      priorAlpha: 4.5,
      priorBeta: 5.5,
    ),

    // =========================================================================
    // ACTIVATE: Social Witness (1 arm)
    // =========================================================================
    const InterventionArm(
      armId: 'SOCIAL_WITNESS',
      category: InterventionCategory.socialWitness,
      displayName: 'Witness Awareness',
      description: 'Your witness is watching. Show them who you are.',
      energyCost: 0.2,
      intrusiveness: 0.35,
      identityReinforcement: 0.7,
      emotionalValence: 0.3,
      requiresWitness: true,
      priorAlpha: 4.0,
      priorBeta: 6.0,
    ),

    // =========================================================================
    // SUPPORT: Friction Reduction (2 arms)
    // =========================================================================
    const InterventionArm(
      armId: 'FRICTION_TINY',
      category: InterventionCategory.frictionReduction,
      displayName: 'Tiny Version Offer',
      description: 'Just 2 minutes. That\'s all.',
      energyCost: 0.05,
      intrusiveness: 0.2,
      identityReinforcement: 0.3,
      emotionalValence: 0.7,
      priorAlpha: 5.5,
      priorBeta: 4.5,
    ),
    const InterventionArm(
      armId: 'FRICTION_ENV',
      category: InterventionCategory.frictionReduction,
      displayName: 'Environment Design Prompt',
      description: 'Put [cue] visible for tomorrow',
      energyCost: 0.2,
      intrusiveness: 0.3,
      identityReinforcement: 0.4,
      emotionalValence: 0.5,
      priorAlpha: 4.0,
      priorBeta: 6.0,
    ),

    // =========================================================================
    // SUPPORT: Emotional Regulation (2 arms)
    // =========================================================================
    const InterventionArm(
      armId: 'EMO_URGE_SURF',
      category: InterventionCategory.emotionalRegulation,
      displayName: 'Urge Surfing Audio',
      description: '2-5 min guided audio for urge management',
      energyCost: 0.4,
      intrusiveness: 0.6,
      identityReinforcement: 0.5,
      emotionalValence: 0.6,
      applicableToBreakHabits: true,
      priorAlpha: 6.0,
      priorBeta: 4.0,
    ),
    const InterventionArm(
      armId: 'EMO_COMPASSION',
      category: InterventionCategory.emotionalRegulation,
      displayName: 'Compassionate Reset',
      description: 'Welcome back. No judgment.',
      energyCost: 0.2,
      intrusiveness: 0.3,
      identityReinforcement: 0.5,
      emotionalValence: 0.6,
      priorAlpha: 4.5,
      priorBeta: 5.5,
    ),

    // =========================================================================
    // SUPPORT: Cognitive Reframe (2 arms)
    // =========================================================================
    const InterventionArm(
      armId: 'COG_LIE_CALL',
      category: InterventionCategory.cognitiveReframe,
      displayName: 'Resistance Lie Callout',
      description: 'That\'s "[Resistance Lie]" talking',
      energyCost: 0.2,
      intrusiveness: 0.45,
      identityReinforcement: 0.7,
      emotionalValence: 0.3,
      priorAlpha: 4.5,
      priorBeta: 5.5,
    ),
    const InterventionArm(
      armId: 'COG_ZOOM',
      category: InterventionCategory.cognitiveReframe,
      displayName: 'Zoom Out Perspective',
      description: '[N] of [M] days. This is noise.',
      energyCost: 0.15,
      intrusiveness: 0.3,
      identityReinforcement: 0.5,
      emotionalValence: 0.6,
      priorAlpha: 4.2,
      priorBeta: 5.8,
    ),

    // =========================================================================
    // TRUST: Strategic Silence (1 arm)
    // =========================================================================
    const InterventionArm(
      armId: 'SILENCE_TRUST',
      category: InterventionCategory.silence,
      displayName: 'Trust Your Identity',
      description: 'No intervention - you know who you are now',
      energyCost: 0.0,
      intrusiveness: 0.0,
      identityReinforcement: 0.0, // Paradoxically high - tests internal identity
      emotionalValence: 0.0,
      priorAlpha: 3.5,
      priorBeta: 6.5,
    ),

    // =========================================================================
    // TRUST: Shadow Intervention (1 arm)
    // =========================================================================
    const InterventionArm(
      armId: 'SHADOW_AUTONOMY',
      category: InterventionCategory.shadowIntervention,
      displayName: 'Autonomy Highlight',
      description: 'You\'ve got [N] votes. Your call today.',
      energyCost: 0.05,
      intrusiveness: 0.2,
      identityReinforcement: 0.6, // Triggers identity defense
      emotionalValence: 0.3,
      requiresRebelArchetype: true,
      priorAlpha: 4.0,
      priorBeta: 6.0,
    ),
  ];

  /// Get all arms for a specific meta-lever
  static List<InterventionArm> armsForMetaLever(MetaLever lever) {
    return allArms.where((arm) => arm.metaLever == lever).toList();
  }

  /// Get all arms for a specific category
  static List<InterventionArm> armsForCategory(InterventionCategory category) {
    return allArms.where((arm) => arm.category == category).toList();
  }

  /// Get arm by ID
  static InterventionArm? getArm(String armId) {
    return allArms.cast<InterventionArm?>().firstWhere(
          (arm) => arm?.armId == armId,
          orElse: () => null,
        );
  }

  /// Get arms applicable to break habits
  static List<InterventionArm> breakHabitArms() {
    return allArms.where((arm) => arm.applicableToBreakHabits).toList();
  }

  /// Total number of arms
  static int get totalArmCount => allArms.length;
}

// =============================================================================
// INTERVENTION EVENT (ML Logging)
// =============================================================================

/// A selected intervention with its context, ready for logging.
class InterventionEvent {
  final String eventId;
  final DateTime timestamp;
  final String habitId;
  final InterventionArm arm;
  final MetaLever selectedMetaLever;
  final Map<String, double> contextFeatures;

  // Bandit metadata
  final double thompsonSampleValue;
  final bool wasExploration;
  final int armExposureCount;

  InterventionEvent({
    required this.eventId,
    required this.timestamp,
    required this.habitId,
    required this.arm,
    required this.selectedMetaLever,
    required this.contextFeatures,
    required this.thompsonSampleValue,
    required this.wasExploration,
    this.armExposureCount = 0,
  });

  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'timestamp': timestamp.toIso8601String(),
        'habitId': habitId,
        'armId': arm.armId,
        'category': arm.category.name,
        'metaLever': selectedMetaLever.name,
        'contextFeatures': contextFeatures,
        'thompsonSampleValue': thompsonSampleValue,
        'wasExploration': wasExploration,
        'armExposureCount': armExposureCount,
      };
}

// =============================================================================
// INTERVENTION OUTCOME (Identity-First Tracking)
// =============================================================================

/// Outcome tracking focused on identity evidence, not just completion.
class InterventionOutcome {
  final String eventId;

  // === ENGAGEMENT ===
  final bool notificationOpened;
  final int? timeToOpenSeconds;
  final String? interactionType; // 'dismiss', 'expand', 'action'

  // === COMPLETION (Constraint, not goal) ===
  final bool habitCompleted24h;
  final bool usedTinyVersion;
  final bool usedAlternative; // For break habits

  // === IDENTITY (Primary metric) ===
  final double? identityScoreDelta; // Change in hexis/fusion score
  final bool streakMaintained;

  // === COST SIGNALS ===
  final bool wasAnnoyanceSignal;
  final bool notificationDisabled;

  InterventionOutcome({
    required this.eventId,
    this.notificationOpened = false,
    this.timeToOpenSeconds,
    this.interactionType,
    this.habitCompleted24h = false,
    this.usedTinyVersion = false,
    this.usedAlternative = false,
    this.identityScoreDelta,
    this.streakMaintained = false,
    this.wasAnnoyanceSignal = false,
    this.notificationDisabled = false,
  });

  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'notificationOpened': notificationOpened,
        'timeToOpenSeconds': timeToOpenSeconds,
        'interactionType': interactionType,
        'habitCompleted24h': habitCompleted24h,
        'usedTinyVersion': usedTinyVersion,
        'usedAlternative': usedAlternative,
        'identityScoreDelta': identityScoreDelta,
        'streakMaintained': streakMaintained,
        'wasAnnoyanceSignal': wasAnnoyanceSignal,
        'notificationDisabled': notificationDisabled,
      };
}
