import 'dart:math' as math;

/// Intervention Taxonomy for JITAI System
///
/// Structured for Hierarchical Bandit learning:
/// - Tier 1: MetaLever (4-5 options) - fast convergence
/// - Tier 2: InterventionArm (within category) - personalization
///
/// Phase 63: JITAI Foundation

// =============================================================================
// TIER 1: META-LEVERS (The "General" - 5 strategic options)
// =============================================================================

/// High-level intervention strategies for fast bandit convergence.
/// The ML system learns "this user responds to Kick, not Ease" quickly.
enum MetaLever {
  /// KICK: Activation interventions (motivation boost)
  /// Maps to: Identity Activation, Social Leverage, Reward Reinforcement
  kick,

  /// EASE: Ability interventions (friction reduction)
  /// Maps to: Friction Reduction, Cognitive Reframe, Temporal
  ease,

  /// HOLD: Resilience interventions (emotional coping)
  /// Maps to: Emotional Regulation (Urge Surfing, Coping Cards)
  hold,

  /// HUSH: Strategic silence (autonomy preservation)
  /// Maps to: Silence interventions (test automaticity)
  hush,

  /// SHADOW: Reverse psychology for Rebel archetypes
  /// Uses reactance to trigger action by suggesting NOT to do the habit
  shadow,
}

extension MetaLeverExtension on MetaLever {
  String get displayName {
    switch (this) {
      case MetaLever.kick:
        return 'Activation';
      case MetaLever.ease:
        return 'Simplification';
      case MetaLever.hold:
        return 'Support';
      case MetaLever.hush:
        return 'Autonomy';
      case MetaLever.shadow:
        return 'Challenge';
    }
  }

  String get description {
    switch (this) {
      case MetaLever.kick:
        return 'Boost motivation through identity, social, or reward cues';
      case MetaLever.ease:
        return 'Lower barriers through friction reduction or reframing';
      case MetaLever.hold:
        return 'Provide emotional support and coping strategies';
      case MetaLever.hush:
        return 'Step back to test and build autonomy';
      case MetaLever.shadow:
        return 'Trigger reactance by suggesting they skip today';
    }
  }

  /// Categories that belong to this meta-lever
  List<InterventionCategory> get categories {
    switch (this) {
      case MetaLever.kick:
        return [
          InterventionCategory.identityActivation,
          InterventionCategory.socialLeverage,
          InterventionCategory.rewardReinforcement,
        ];
      case MetaLever.ease:
        return [
          InterventionCategory.frictionReduction,
          InterventionCategory.cognitiveReframe,
          InterventionCategory.temporal,
        ];
      case MetaLever.hold:
        return [
          InterventionCategory.emotionalRegulation,
        ];
      case MetaLever.hush:
        return [
          InterventionCategory.silence,
        ];
      case MetaLever.shadow:
        return [
          InterventionCategory.shadowIntervention,
        ];
    }
  }

  /// Population prior success rate (cold start)
  double get priorSuccessRate {
    switch (this) {
      case MetaLever.kick:
        return 0.45; // Identity works well for most
      case MetaLever.ease:
        return 0.50; // Friction reduction is broadly effective
      case MetaLever.hold:
        return 0.55; // Emotional support when triggered correctly
      case MetaLever.hush:
        return 0.30; // Risky but important for autonomy
      case MetaLever.shadow:
        return 0.35; // Only works for rebels, risky otherwise
    }
  }
}

// =============================================================================
// TIER 2: INTERVENTION CATEGORIES (Psychological mechanisms)
// =============================================================================

/// Detailed intervention categories mapping to psychological levers.
enum InterventionCategory {
  // === KICK (Activation) ===
  identityActivation, // "What would a runner do?"
  socialLeverage, // Accountability, social proof
  rewardReinforcement, // Variable rewards, milestones

  // === EASE (Ability) ===
  frictionReduction, // Tiny version, environment design
  cognitiveReframe, // Zoom out, lie callout
  temporal, // Optimal window, cascade prevention

  // === HOLD (Resilience) ===
  emotionalRegulation, // Urge surfing, coping cards

  // === HUSH (Autonomy) ===
  silence, // Strategic absence

  // === SHADOW (Reverse Psychology) ===
  shadowIntervention, // "Skip today" for rebels
}

extension InterventionCategoryExtension on InterventionCategory {
  String get displayName {
    switch (this) {
      case InterventionCategory.identityActivation:
        return 'Identity Activation';
      case InterventionCategory.socialLeverage:
        return 'Social Leverage';
      case InterventionCategory.rewardReinforcement:
        return 'Reward & Reinforcement';
      case InterventionCategory.frictionReduction:
        return 'Friction Reduction';
      case InterventionCategory.cognitiveReframe:
        return 'Cognitive Reframe';
      case InterventionCategory.temporal:
        return 'Temporal Optimization';
      case InterventionCategory.emotionalRegulation:
        return 'Emotional Regulation';
      case InterventionCategory.silence:
        return 'Strategic Silence';
      case InterventionCategory.shadowIntervention:
        return 'Shadow Challenge';
    }
  }

  MetaLever get metaLever {
    switch (this) {
      case InterventionCategory.identityActivation:
      case InterventionCategory.socialLeverage:
      case InterventionCategory.rewardReinforcement:
        return MetaLever.kick;
      case InterventionCategory.frictionReduction:
      case InterventionCategory.cognitiveReframe:
      case InterventionCategory.temporal:
        return MetaLever.ease;
      case InterventionCategory.emotionalRegulation:
        return MetaLever.hold;
      case InterventionCategory.silence:
        return MetaLever.hush;
      case InterventionCategory.shadowIntervention:
        return MetaLever.shadow;
    }
  }
}

// =============================================================================
// INTERVENTION ARMS (Individual intervention types)
// =============================================================================

/// An individual intervention type with its ML features.
class InterventionArm {
  final String armId;
  final InterventionCategory category;
  final String displayName;
  final String description;

  // === BANDIT FEATURES ===
  final double energyCost; // 0.0-1.0 (user effort required)
  final double intrusiveness; // 0.0-1.0 (attention disruption)
  final double identityReinforcement; // 0.0-1.0 (identity salience boost)
  final double emotionalValence; // -1.0 to 1.0 (negative to positive)

  // === PERSONALIZATION FEATURES ===
  final Map<String, double> traitAffinity; // Big Five fit (O, C, E, A, N)
  final RegulatoryFocus optimalFocus; // Promotion vs Prevention

  // === CONTEXT REQUIREMENTS ===
  final List<ContextRequirement> prerequisites;
  final VulnerabilityRange targetVulnerability;
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
    required this.traitAffinity,
    this.optimalFocus = RegulatoryFocus.either,
    this.prerequisites = const [],
    this.targetVulnerability = const VulnerabilityRange(0.0, 1.0),
    this.applicableToBreakHabits = true,
    this.priorAlpha = 1.0,
    this.priorBeta = 1.0,
  });

  MetaLever get metaLever => category.metaLever;

  /// Prior success rate from population data
  double get priorSuccessRate => priorAlpha / (priorAlpha + priorBeta);

  /// Convert to feature vector for bandit context
  Map<String, double> toFeatureVector() {
    return {
      'energy_cost': energyCost,
      'intrusiveness': intrusiveness,
      'identity_reinforcement': identityReinforcement,
      'emotional_valence': emotionalValence,
      'trait_O': traitAffinity['O'] ?? 0.5,
      'trait_C': traitAffinity['C'] ?? 0.5,
      'trait_E': traitAffinity['E'] ?? 0.5,
      'trait_A': traitAffinity['A'] ?? 0.5,
      'trait_N': traitAffinity['N'] ?? 0.5,
      'regulatory_focus': optimalFocus == RegulatoryFocus.promotion
          ? 1.0
          : (optimalFocus == RegulatoryFocus.prevention ? -1.0 : 0.0),
    };
  }
}

enum RegulatoryFocus { promotion, prevention, either }

/// Context requirements that must be met for an intervention
enum ContextRequirement {
  preHabitWindow, // Within 2 hours of scheduled time
  postCompletion, // After habit completion
  notInMeeting, // Calendar shows free
  outdoorSuitable, // Weather permits outdoor activity
  highVulnerability, // V-O score shows high vulnerability
  lowVulnerability, // V-O score shows low vulnerability
  breakHabitCraving, // Detected urge for break habit
  hasWitness, // Has accountability partner
  rebelArchetype, // User has rebel failure archetype
}

/// Range of vulnerability scores where this intervention is applicable
class VulnerabilityRange {
  final double min;
  final double max;

  const VulnerabilityRange(this.min, this.max);

  bool contains(double value) => value >= min && value <= max;

  @override
  String toString() => '[$min, $max]';
}

// =============================================================================
// INTERVENTION TAXONOMY REGISTRY
// =============================================================================

/// Central registry of all intervention arms with their ML features.
class InterventionTaxonomy {
  static final List<InterventionArm> allArms = [
    // =========================================================================
    // CATEGORY 1: IDENTITY ACTIVATION
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
      traitAffinity: {'O': 0.7, 'C': 0.8, 'E': 0.6, 'A': 0.7, 'N': 0.5},
      optimalFocus: RegulatoryFocus.promotion,
      targetVulnerability: VulnerabilityRange(0.3, 0.7),
      priorAlpha: 4.2,
      priorBeta: 5.8,
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
      traitAffinity: {'O': 0.5, 'C': 0.7, 'E': 0.4, 'A': 0.5, 'N': 0.8},
      optimalFocus: RegulatoryFocus.prevention,
      targetVulnerability: VulnerabilityRange(0.5, 0.9),
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
      traitAffinity: {'O': 0.6, 'C': 0.9, 'E': 0.5, 'A': 0.6, 'N': 0.4},
      optimalFocus: RegulatoryFocus.promotion,
      targetVulnerability: VulnerabilityRange(0.2, 0.6),
      priorAlpha: 4.5,
      priorBeta: 5.5,
    ),
    const InterventionArm(
      armId: 'ID_FUTURE',
      category: InterventionCategory.identityActivation,
      displayName: 'Future Self Projection',
      description: '365 days of this: who are you then?',
      energyCost: 0.3,
      intrusiveness: 0.4,
      identityReinforcement: 0.75,
      emotionalValence: 0.5,
      traitAffinity: {'O': 0.9, 'C': 0.7, 'E': 0.5, 'A': 0.6, 'N': 0.6},
      optimalFocus: RegulatoryFocus.promotion,
      targetVulnerability: VulnerabilityRange(0.3, 0.7),
      priorAlpha: 3.5,
      priorBeta: 6.5,
    ),
    const InterventionArm(
      armId: 'ID_STREAK_VIZ',
      category: InterventionCategory.identityActivation,
      displayName: 'Identity Streak Visualization',
      description: '[N] consecutive votes for [identity]',
      energyCost: 0.05,
      intrusiveness: 0.15,
      identityReinforcement: 0.7,
      emotionalValence: 0.8,
      traitAffinity: {'O': 0.6, 'C': 0.9, 'E': 0.6, 'A': 0.6, 'N': 0.4},
      optimalFocus: RegulatoryFocus.promotion,
      prerequisites: [ContextRequirement.postCompletion],
      targetVulnerability: VulnerabilityRange(0.0, 0.5),
      priorAlpha: 5.0,
      priorBeta: 5.0,
    ),

    // =========================================================================
    // CATEGORY 2: FRICTION REDUCTION
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
      traitAffinity: {'O': 0.5, 'C': 0.6, 'E': 0.5, 'A': 0.7, 'N': 0.8},
      optimalFocus: RegulatoryFocus.either,
      targetVulnerability: VulnerabilityRange(0.5, 1.0),
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
      identityReinforcement: 0.2,
      emotionalValence: 0.5,
      traitAffinity: {'O': 0.7, 'C': 0.9, 'E': 0.5, 'A': 0.6, 'N': 0.5},
      optimalFocus: RegulatoryFocus.either,
      prerequisites: [ContextRequirement.postCompletion],
      targetVulnerability: VulnerabilityRange(0.0, 0.5),
      priorAlpha: 4.0,
      priorBeta: 6.0,
    ),
    const InterventionArm(
      armId: 'FRICTION_IMPL',
      category: InterventionCategory.frictionReduction,
      displayName: 'Implementation Intention',
      description: 'After [anchor], I will [habit]...',
      energyCost: 0.15,
      intrusiveness: 0.25,
      identityReinforcement: 0.4,
      emotionalValence: 0.6,
      traitAffinity: {'O': 0.6, 'C': 0.9, 'E': 0.5, 'A': 0.6, 'N': 0.5},
      optimalFocus: RegulatoryFocus.either,
      targetVulnerability: VulnerabilityRange(0.2, 0.6),
      priorAlpha: 4.8,
      priorBeta: 5.2,
    ),
    const InterventionArm(
      armId: 'FRICTION_OBSTACLE',
      category: InterventionCategory.frictionReduction,
      displayName: 'Obstacle Removal Query',
      description: '[Obstacle] blocked you before. Here\'s an alternative.',
      energyCost: 0.25,
      intrusiveness: 0.4,
      identityReinforcement: 0.3,
      emotionalValence: 0.5,
      traitAffinity: {'O': 0.8, 'C': 0.7, 'E': 0.5, 'A': 0.6, 'N': 0.6},
      optimalFocus: RegulatoryFocus.either,
      targetVulnerability: VulnerabilityRange(0.4, 0.8),
      priorAlpha: 4.2,
      priorBeta: 5.8,
    ),
    const InterventionArm(
      armId: 'FRICTION_STACK',
      category: InterventionCategory.frictionReduction,
      displayName: 'Habit Stack Trigger',
      description: '[Anchor] done → [habit] time',
      energyCost: 0.1,
      intrusiveness: 0.2,
      identityReinforcement: 0.35,
      emotionalValence: 0.6,
      traitAffinity: {'O': 0.6, 'C': 0.8, 'E': 0.6, 'A': 0.6, 'N': 0.5},
      optimalFocus: RegulatoryFocus.either,
      targetVulnerability: VulnerabilityRange(0.2, 0.7),
      priorAlpha: 4.5,
      priorBeta: 5.5,
    ),

    // =========================================================================
    // CATEGORY 3: EMOTIONAL REGULATION
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
      traitAffinity: {'O': 0.7, 'C': 0.5, 'E': 0.4, 'A': 0.7, 'N': 0.9},
      optimalFocus: RegulatoryFocus.either,
      prerequisites: [ContextRequirement.breakHabitCraving],
      applicableToBreakHabits: true,
      targetVulnerability: VulnerabilityRange(0.6, 1.0),
      priorAlpha: 6.0,
      priorBeta: 4.0,
    ),
    const InterventionArm(
      armId: 'EMO_COPING',
      category: InterventionCategory.emotionalRegulation,
      displayName: 'Coping Card Display',
      description: 'Anti-Identity + BigWhy + Tiny Version',
      energyCost: 0.15,
      intrusiveness: 0.35,
      identityReinforcement: 0.6,
      emotionalValence: 0.5,
      traitAffinity: {'O': 0.6, 'C': 0.6, 'E': 0.5, 'A': 0.7, 'N': 0.8},
      optimalFocus: RegulatoryFocus.either,
      targetVulnerability: VulnerabilityRange(0.5, 0.9),
      priorAlpha: 4.5,
      priorBeta: 5.5,
    ),
    const InterventionArm(
      armId: 'EMO_ACK_STRESS',
      category: InterventionCategory.emotionalRegulation,
      displayName: 'Stress Acknowledgment',
      description: 'Rough day. That\'s real. Tiny win?',
      energyCost: 0.1,
      intrusiveness: 0.25,
      identityReinforcement: 0.3,
      emotionalValence: 0.4,
      traitAffinity: {'O': 0.5, 'C': 0.5, 'E': 0.5, 'A': 0.8, 'N': 0.9},
      optimalFocus: RegulatoryFocus.either,
      targetVulnerability: VulnerabilityRange(0.6, 1.0),
      priorAlpha: 4.0,
      priorBeta: 6.0,
    ),
    const InterventionArm(
      armId: 'EMO_CELEBRATE',
      category: InterventionCategory.emotionalRegulation,
      displayName: 'Celebration Burst',
      description: 'Haptic + visual celebration + identity statement',
      energyCost: 0.05,
      intrusiveness: 0.3,
      identityReinforcement: 0.7,
      emotionalValence: 0.9,
      traitAffinity: {'O': 0.7, 'C': 0.7, 'E': 0.8, 'A': 0.7, 'N': 0.5},
      optimalFocus: RegulatoryFocus.promotion,
      prerequisites: [ContextRequirement.postCompletion],
      targetVulnerability: VulnerabilityRange(0.0, 0.5),
      priorAlpha: 5.5,
      priorBeta: 4.5,
    ),
    const InterventionArm(
      armId: 'EMO_COMPASSION',
      category: InterventionCategory.emotionalRegulation,
      displayName: 'Compassionate Reset',
      description: 'Welcome back. No judgment.',
      energyCost: 0.2,
      intrusiveness: 0.3,
      identityReinforcement: 0.4,
      emotionalValence: 0.5,
      traitAffinity: {'O': 0.6, 'C': 0.5, 'E': 0.5, 'A': 0.9, 'N': 0.8},
      optimalFocus: RegulatoryFocus.either,
      targetVulnerability: VulnerabilityRange(0.7, 1.0),
      priorAlpha: 4.5,
      priorBeta: 5.5,
    ),

    // =========================================================================
    // CATEGORY 4: SOCIAL LEVERAGE
    // =========================================================================
    const InterventionArm(
      armId: 'SOCIAL_THREAT',
      category: InterventionCategory.socialLeverage,
      displayName: 'Supporter Notification Threat',
      description: 'Your supporter will see this miss',
      energyCost: 0.3,
      intrusiveness: 0.7,
      identityReinforcement: 0.5,
      emotionalValence: -0.3,
      traitAffinity: {'O': 0.4, 'C': 0.7, 'E': 0.8, 'A': 0.5, 'N': 0.3},
      optimalFocus: RegulatoryFocus.prevention,
      prerequisites: [ContextRequirement.hasWitness],
      targetVulnerability: VulnerabilityRange(0.5, 0.8),
      priorAlpha: 3.5,
      priorBeta: 6.5,
    ),
    const InterventionArm(
      armId: 'SOCIAL_PROOF',
      category: InterventionCategory.socialLeverage,
      displayName: 'Social Proof Display',
      description: '[Friend] just completed their habit',
      energyCost: 0.1,
      intrusiveness: 0.25,
      identityReinforcement: 0.4,
      emotionalValence: 0.5,
      traitAffinity: {'O': 0.5, 'C': 0.6, 'E': 0.9, 'A': 0.7, 'N': 0.5},
      optimalFocus: RegulatoryFocus.promotion,
      prerequisites: [ContextRequirement.hasWitness],
      targetVulnerability: VulnerabilityRange(0.3, 0.7),
      priorAlpha: 4.0,
      priorBeta: 6.0,
    ),
    const InterventionArm(
      armId: 'SOCIAL_COOP',
      category: InterventionCategory.socialLeverage,
      displayName: 'Cooperative Goal Frame',
      description: 'Your team needs your vote today',
      energyCost: 0.2,
      intrusiveness: 0.35,
      identityReinforcement: 0.5,
      emotionalValence: 0.4,
      traitAffinity: {'O': 0.5, 'C': 0.6, 'E': 0.7, 'A': 0.9, 'N': 0.5},
      optimalFocus: RegulatoryFocus.promotion,
      prerequisites: [ContextRequirement.hasWitness],
      targetVulnerability: VulnerabilityRange(0.4, 0.8),
      priorAlpha: 3.8,
      priorBeta: 6.2,
    ),
    const InterventionArm(
      armId: 'SOCIAL_COMMIT',
      category: InterventionCategory.socialLeverage,
      displayName: 'Public Commitment Prompt',
      description: 'Share your pact with 3 friends?',
      energyCost: 0.35,
      intrusiveness: 0.4,
      identityReinforcement: 0.6,
      emotionalValence: 0.3,
      traitAffinity: {'O': 0.6, 'C': 0.7, 'E': 0.9, 'A': 0.6, 'N': 0.3},
      optimalFocus: RegulatoryFocus.promotion,
      targetVulnerability: VulnerabilityRange(0.2, 0.5),
      priorAlpha: 3.0,
      priorBeta: 7.0,
    ),

    // =========================================================================
    // CATEGORY 5: COGNITIVE REFRAME
    // =========================================================================
    const InterventionArm(
      armId: 'COG_LIE_CALL',
      category: InterventionCategory.cognitiveReframe,
      displayName: 'Resistance Lie Callout',
      description: 'That\'s The [Resistance Lie] talking',
      energyCost: 0.2,
      intrusiveness: 0.45,
      identityReinforcement: 0.7,
      emotionalValence: 0.3,
      traitAffinity: {'O': 0.8, 'C': 0.8, 'E': 0.5, 'A': 0.5, 'N': 0.6},
      optimalFocus: RegulatoryFocus.either,
      targetVulnerability: VulnerabilityRange(0.4, 0.8),
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
      traitAffinity: {'O': 0.7, 'C': 0.7, 'E': 0.5, 'A': 0.6, 'N': 0.8},
      optimalFocus: RegulatoryFocus.either,
      targetVulnerability: VulnerabilityRange(0.5, 0.9),
      priorAlpha: 4.2,
      priorBeta: 5.8,
    ),
    const InterventionArm(
      armId: 'COG_ARCHETYPE',
      category: InterventionCategory.cognitiveReframe,
      displayName: 'Failure Archetype Mirror',
      description: '[ARCHETYPE] mode detected',
      energyCost: 0.25,
      intrusiveness: 0.5,
      identityReinforcement: 0.75,
      emotionalValence: 0.2,
      traitAffinity: {'O': 0.9, 'C': 0.7, 'E': 0.5, 'A': 0.5, 'N': 0.7},
      optimalFocus: RegulatoryFocus.prevention,
      targetVulnerability: VulnerabilityRange(0.5, 0.9),
      priorAlpha: 4.0,
      priorBeta: 6.0,
    ),
    const InterventionArm(
      armId: 'COG_COUNTER',
      category: InterventionCategory.cognitiveReframe,
      displayName: 'Counterfactual Projection',
      description: 'Skip today → likely skip week',
      energyCost: 0.3,
      intrusiveness: 0.45,
      identityReinforcement: 0.5,
      emotionalValence: -0.1,
      traitAffinity: {'O': 0.8, 'C': 0.8, 'E': 0.5, 'A': 0.5, 'N': 0.7},
      optimalFocus: RegulatoryFocus.prevention,
      targetVulnerability: VulnerabilityRange(0.4, 0.8),
      priorAlpha: 3.8,
      priorBeta: 6.2,
    ),

    // =========================================================================
    // CATEGORY 6: TEMPORAL OPTIMIZATION
    // =========================================================================
    const InterventionArm(
      armId: 'TIME_WINDOW',
      category: InterventionCategory.temporal,
      displayName: 'Optimal Window Alert',
      description: 'Next [N] min is your best window',
      energyCost: 0.1,
      intrusiveness: 0.3,
      identityReinforcement: 0.2,
      emotionalValence: 0.5,
      traitAffinity: {'O': 0.6, 'C': 0.9, 'E': 0.5, 'A': 0.6, 'N': 0.5},
      optimalFocus: RegulatoryFocus.either,
      prerequisites: [ContextRequirement.notInMeeting],
      targetVulnerability: VulnerabilityRange(0.2, 0.6),
      priorAlpha: 4.5,
      priorBeta: 5.5,
    ),
    const InterventionArm(
      armId: 'TIME_DRIFT',
      category: InterventionCategory.temporal,
      displayName: 'Drift Correction',
      description: 'You\'re doing this at [X], not [Y]',
      energyCost: 0.15,
      intrusiveness: 0.35,
      identityReinforcement: 0.3,
      emotionalValence: 0.4,
      traitAffinity: {'O': 0.6, 'C': 0.9, 'E': 0.5, 'A': 0.6, 'N': 0.5},
      optimalFocus: RegulatoryFocus.either,
      targetVulnerability: VulnerabilityRange(0.3, 0.7),
      priorAlpha: 4.0,
      priorBeta: 6.0,
    ),
    const InterventionArm(
      armId: 'TIME_CASCADE',
      category: InterventionCategory.temporal,
      displayName: 'Cascade Prevention',
      description: '[Weather/pattern] ahead. Here\'s your plan.',
      energyCost: 0.25,
      intrusiveness: 0.4,
      identityReinforcement: 0.4,
      emotionalValence: 0.5,
      traitAffinity: {'O': 0.7, 'C': 0.8, 'E': 0.5, 'A': 0.6, 'N': 0.6},
      optimalFocus: RegulatoryFocus.prevention,
      targetVulnerability: VulnerabilityRange(0.3, 0.7),
      priorAlpha: 4.8,
      priorBeta: 5.2,
    ),
    const InterventionArm(
      armId: 'TIME_WEEKEND',
      category: InterventionCategory.temporal,
      displayName: 'Weekend Strategy',
      description: 'Weekends are risky. Pre-commit?',
      energyCost: 0.2,
      intrusiveness: 0.35,
      identityReinforcement: 0.35,
      emotionalValence: 0.4,
      traitAffinity: {'O': 0.6, 'C': 0.8, 'E': 0.6, 'A': 0.6, 'N': 0.6},
      optimalFocus: RegulatoryFocus.prevention,
      targetVulnerability: VulnerabilityRange(0.3, 0.7),
      priorAlpha: 4.2,
      priorBeta: 5.8,
    ),

    // =========================================================================
    // CATEGORY 7: REWARD & REINFORCEMENT
    // =========================================================================
    const InterventionArm(
      armId: 'REWARD_VAR',
      category: InterventionCategory.rewardReinforcement,
      displayName: 'Variable Reward Reveal',
      description: 'Card flip → surprise insight',
      energyCost: 0.05,
      intrusiveness: 0.25,
      identityReinforcement: 0.5,
      emotionalValence: 0.85,
      traitAffinity: {'O': 0.9, 'C': 0.6, 'E': 0.8, 'A': 0.6, 'N': 0.5},
      optimalFocus: RegulatoryFocus.promotion,
      prerequisites: [ContextRequirement.postCompletion],
      targetVulnerability: VulnerabilityRange(0.0, 0.5),
      priorAlpha: 5.0,
      priorBeta: 5.0,
    ),
    const InterventionArm(
      armId: 'REWARD_MILE',
      category: InterventionCategory.rewardReinforcement,
      displayName: 'Progress Milestone',
      description: '[N] votes. Level up: [Title]',
      energyCost: 0.1,
      intrusiveness: 0.3,
      identityReinforcement: 0.7,
      emotionalValence: 0.8,
      traitAffinity: {'O': 0.7, 'C': 0.9, 'E': 0.7, 'A': 0.6, 'N': 0.5},
      optimalFocus: RegulatoryFocus.promotion,
      prerequisites: [ContextRequirement.postCompletion],
      targetVulnerability: VulnerabilityRange(0.0, 0.4),
      priorAlpha: 5.5,
      priorBeta: 4.5,
    ),
    const InterventionArm(
      armId: 'REWARD_SAVE',
      category: InterventionCategory.rewardReinforcement,
      displayName: 'Streak Saver Bonus',
      description: 'Saved! Never Miss Twice honored.',
      energyCost: 0.15,
      intrusiveness: 0.35,
      identityReinforcement: 0.75,
      emotionalValence: 0.85,
      traitAffinity: {'O': 0.6, 'C': 0.8, 'E': 0.7, 'A': 0.6, 'N': 0.7},
      optimalFocus: RegulatoryFocus.promotion,
      prerequisites: [ContextRequirement.postCompletion],
      targetVulnerability: VulnerabilityRange(0.0, 0.5),
      priorAlpha: 5.8,
      priorBeta: 4.2,
    ),
    const InterventionArm(
      armId: 'REWARD_BUNDLE',
      category: InterventionCategory.rewardReinforcement,
      displayName: 'Temptation Bundle Trigger',
      description: '[Reward] + [habit] time!',
      energyCost: 0.1,
      intrusiveness: 0.25,
      identityReinforcement: 0.3,
      emotionalValence: 0.7,
      traitAffinity: {'O': 0.7, 'C': 0.6, 'E': 0.7, 'A': 0.6, 'N': 0.6},
      optimalFocus: RegulatoryFocus.promotion,
      prerequisites: [ContextRequirement.preHabitWindow],
      targetVulnerability: VulnerabilityRange(0.3, 0.7),
      priorAlpha: 4.5,
      priorBeta: 5.5,
    ),

    // =========================================================================
    // CATEGORY 8: SILENCE (Strategic Absence)
    // =========================================================================
    const InterventionArm(
      armId: 'SILENCE_TEST',
      category: InterventionCategory.silence,
      displayName: 'The Silent Test',
      description: 'No intervention - testing automaticity',
      energyCost: 0.0,
      intrusiveness: 0.0,
      identityReinforcement: 0.0,
      emotionalValence: 0.0,
      traitAffinity: {'O': 0.5, 'C': 0.7, 'E': 0.5, 'A': 0.5, 'N': 0.3},
      optimalFocus: RegulatoryFocus.either,
      prerequisites: [ContextRequirement.lowVulnerability],
      targetVulnerability: VulnerabilityRange(0.0, 0.3),
      priorAlpha: 3.0,
      priorBeta: 7.0,
    ),
    const InterventionArm(
      armId: 'SILENCE_FATIGUE',
      category: InterventionCategory.silence,
      displayName: 'Fatigue Respite',
      description: 'No intervention - preventing alert fatigue',
      energyCost: 0.0,
      intrusiveness: 0.0,
      identityReinforcement: 0.0,
      emotionalValence: 0.0,
      traitAffinity: {'O': 0.5, 'C': 0.5, 'E': 0.5, 'A': 0.5, 'N': 0.6},
      optimalFocus: RegulatoryFocus.either,
      targetVulnerability: VulnerabilityRange(0.0, 1.0),
      priorAlpha: 4.0,
      priorBeta: 6.0,
    ),
    const InterventionArm(
      armId: 'SILENCE_AUTONOMY',
      category: InterventionCategory.silence,
      displayName: 'Autonomy Preservation',
      description: 'No intervention - weaning off external cues',
      energyCost: 0.0,
      intrusiveness: 0.0,
      identityReinforcement: 0.0,
      emotionalValence: 0.0,
      traitAffinity: {'O': 0.5, 'C': 0.8, 'E': 0.5, 'A': 0.5, 'N': 0.3},
      optimalFocus: RegulatoryFocus.either,
      prerequisites: [ContextRequirement.lowVulnerability],
      targetVulnerability: VulnerabilityRange(0.0, 0.4),
      priorAlpha: 3.5,
      priorBeta: 6.5,
    ),

    // =========================================================================
    // CATEGORY 9: SHADOW INTERVENTION (Reverse Psychology)
    // =========================================================================
    const InterventionArm(
      armId: 'SHADOW_SKIP',
      category: InterventionCategory.shadowIntervention,
      displayName: 'Permission to Skip',
      description: 'Data suggests you\'re tired. Algorithm recommends skipping.',
      energyCost: 0.1,
      intrusiveness: 0.4,
      identityReinforcement: 0.6, // Triggers identity defense
      emotionalValence: -0.2, // Slightly negative (challenge)
      traitAffinity: {'O': 0.6, 'C': 0.4, 'E': 0.6, 'A': 0.3, 'N': 0.4},
      optimalFocus: RegulatoryFocus.either,
      prerequisites: [ContextRequirement.rebelArchetype],
      targetVulnerability: VulnerabilityRange(0.4, 0.8),
      priorAlpha: 3.5,
      priorBeta: 6.5,
    ),
    const InterventionArm(
      armId: 'SHADOW_DOUBT',
      category: InterventionCategory.shadowIntervention,
      displayName: 'Expressed Doubt',
      description: 'Most people give up at this point. Understandable.',
      energyCost: 0.15,
      intrusiveness: 0.5,
      identityReinforcement: 0.7, // Strong identity trigger
      emotionalValence: -0.3, // Negative (provocation)
      traitAffinity: {'O': 0.5, 'C': 0.3, 'E': 0.7, 'A': 0.2, 'N': 0.4},
      optimalFocus: RegulatoryFocus.either,
      prerequisites: [ContextRequirement.rebelArchetype],
      targetVulnerability: VulnerabilityRange(0.5, 0.9),
      priorAlpha: 3.0,
      priorBeta: 7.0,
    ),
    const InterventionArm(
      armId: 'SHADOW_AUTONOMY',
      category: InterventionCategory.shadowIntervention,
      displayName: 'Autonomy Highlight',
      description: 'You\'ve got [N] votes. Your call on today.',
      energyCost: 0.05,
      intrusiveness: 0.2,
      identityReinforcement: 0.5,
      emotionalValence: 0.3, // Neutral-positive
      traitAffinity: {'O': 0.6, 'C': 0.5, 'E': 0.5, 'A': 0.4, 'N': 0.4},
      optimalFocus: RegulatoryFocus.either,
      prerequisites: [ContextRequirement.rebelArchetype],
      targetVulnerability: VulnerabilityRange(0.3, 0.7),
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
// INTERVENTION VECTOR (ML Feature Representation)
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
  final int armExposureCount; // How many times user has seen this arm

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

/// Outcome tracking for an intervention event.
class InterventionOutcome {
  final String eventId;

  // Proximal outcomes (immediate)
  final bool notificationOpened;
  final int? timeToOpenSeconds;
  final String? interactionType; // 'dismiss', 'expand', 'action'

  // Distal outcomes (within 24h)
  final bool habitCompleted24h;
  final double? completionDelayHours;
  final bool usedTinyVersion;
  final bool usedAlternative; // For break habits

  // Identity outcomes
  final double? identityScoreDelta;
  final bool streakMaintained;

  // Cost signals
  final bool wasAnnoyanceSignal; // User explicitly dismissed
  final bool notificationDisabled; // User turned off notifications

  // Computed reward (set by reward function)
  final double? compositeReward;

  InterventionOutcome({
    required this.eventId,
    this.notificationOpened = false,
    this.timeToOpenSeconds,
    this.interactionType,
    this.habitCompleted24h = false,
    this.completionDelayHours,
    this.usedTinyVersion = false,
    this.usedAlternative = false,
    this.identityScoreDelta,
    this.streakMaintained = false,
    this.wasAnnoyanceSignal = false,
    this.notificationDisabled = false,
    this.compositeReward,
  });

  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'notificationOpened': notificationOpened,
        'timeToOpenSeconds': timeToOpenSeconds,
        'interactionType': interactionType,
        'habitCompleted24h': habitCompleted24h,
        'completionDelayHours': completionDelayHours,
        'usedTinyVersion': usedTinyVersion,
        'usedAlternative': usedAlternative,
        'identityScoreDelta': identityScoreDelta,
        'streakMaintained': streakMaintained,
        'wasAnnoyanceSignal': wasAnnoyanceSignal,
        'notificationDisabled': notificationDisabled,
        'compositeReward': compositeReward,
      };
}
