import 'dart:math' as math;

import '../entities/intervention.dart';
import '../entities/context_snapshot.dart';
import '../entities/psychometric_profile.dart';
import 'vulnerability_opportunity_calculator.dart';

/// HierarchicalBandit: Identity-First Intervention Selection
///
/// Simplified two-tier Thompson Sampling:
/// - Tier 1: Select MetaLever (Activate/Support/Trust)
/// - Tier 2: Select specific Arm within the chosen lever
///
/// Key Simplifications (Phase 63b):
/// - 3 MetaLevers instead of 5
/// - 12 Arms instead of 35
/// - Removed dead trait affinity code
/// - Simplified prerequisite checking
///
/// Philosophy: Select interventions that strengthen identity, not just drive completion.
class HierarchicalBandit {
  final _random = math.Random();

  /// Beta distributions for each meta-lever (Tier 1)
  final Map<MetaLever, BetaDistribution> _leverPosteriors;

  /// Beta distributions for each arm within levers (Tier 2)
  final Map<String, BetaDistribution> _armPosteriors;

  /// Exploration bonus (decays over time)
  double _explorationBoost = 1.2;
  static const double _explorationDecay = 0.995;

  HierarchicalBandit({
    Map<MetaLever, BetaDistribution>? leverPriors,
    Map<String, BetaDistribution>? armPriors,
  })  : _leverPosteriors = leverPriors ?? _defaultLeverPriors(),
        _armPosteriors = armPriors ?? _defaultArmPriors();

  /// Create bandit with archetypal seeding based on user profile
  factory HierarchicalBandit.seededForProfile(PsychometricProfile profile) {
    final leverPriors = _defaultLeverPriors();
    final armPriors = _defaultArmPriors();

    // Apply archetypal adjustments
    _applyArchetypeSeeding(leverPriors, armPriors, profile);

    return HierarchicalBandit(
      leverPriors: leverPriors,
      armPriors: armPriors,
    );
  }

  /// Select intervention using hierarchical Thompson Sampling
  InterventionSelection select({
    required ContextSnapshot context,
    required VOState voState,
    required PsychometricProfile profile,
    required bool isBreakHabit,
    List<String>? excludeArms,
  }) {
    // === TIER 1: Select Meta-Lever ===
    final leverSelection = _selectMetaLever(
      context: context,
      voState: voState,
      profile: profile,
    );

    // === TIER 2: Select Arm within Lever ===
    final armSelection = _selectArm(
      lever: leverSelection.lever,
      context: context,
      voState: voState,
      profile: profile,
      isBreakHabit: isBreakHabit,
      excludeArms: excludeArms ?? [],
    );

    // Decay exploration
    _explorationBoost *= _explorationDecay;

    return InterventionSelection(
      lever: leverSelection.lever,
      arm: armSelection.arm,
      leverThompsonValue: leverSelection.thompsonValue,
      armThompsonValue: armSelection.thompsonValue,
      leverWasExploration: leverSelection.wasExploration,
      armWasExploration: armSelection.wasExploration,
    );
  }

  /// Thompson Sampling for meta-lever selection
  _LeverSelection _selectMetaLever({
    required ContextSnapshot context,
    required VOState voState,
    required PsychometricProfile profile,
  }) {
    // All 3 levers are always eligible - simplified from complex eligibility
    final eligibleLevers = MetaLever.values.toList();

    // Sample from each lever's beta distribution
    final samples = <MetaLever, double>{};
    for (final lever in eligibleLevers) {
      final posterior = _leverPosteriors[lever]!;
      samples[lever] = _sampleBeta(posterior) * _explorationBoost;
    }

    // Apply context-based modifiers
    _applyLeverContextModifiers(samples, context, voState, profile);

    // Select highest sample
    final selected = samples.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );

    // Determine if this was exploration
    final maxPosteriorMean = eligibleLevers
        .map((l) => _leverPosteriors[l]!.mean)
        .reduce(math.max);
    final wasExploration =
        _leverPosteriors[selected.key]!.mean < maxPosteriorMean * 0.9;

    return _LeverSelection(
      lever: selected.key,
      thompsonValue: selected.value,
      wasExploration: wasExploration,
    );
  }

  /// Thompson Sampling for arm selection within lever
  _ArmSelection _selectArm({
    required MetaLever lever,
    required ContextSnapshot context,
    required VOState voState,
    required PsychometricProfile profile,
    required bool isBreakHabit,
    required List<String> excludeArms,
  }) {
    // Get eligible arms for this lever
    var eligibleArms = InterventionTaxonomy.armsForMetaLever(lever)
        .where((arm) => !excludeArms.contains(arm.armId))
        .where((arm) => _meetsPrerequisites(arm, profile))
        .where((arm) => isBreakHabit || arm.applicableToBreakHabits)
        .toList();

    if (eligibleArms.isEmpty) {
      // Fallback to silence
      final silenceArm = InterventionTaxonomy.getArm('SILENCE_TRUST')!;
      return _ArmSelection(
        arm: silenceArm,
        thompsonValue: 0.5,
        wasExploration: false,
      );
    }

    // Sample from each arm's beta distribution
    final samples = <InterventionArm, double>{};
    for (final arm in eligibleArms) {
      final posterior = _armPosteriors[arm.armId] ??
          BetaDistribution(alpha: arm.priorAlpha, beta: arm.priorBeta);
      samples[arm] = _sampleBeta(posterior) * _explorationBoost;
    }

    // Apply arm context modifiers
    _applyArmContextModifiers(samples, context, voState, profile);

    // Select highest sample
    final selected = samples.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );

    // Determine if exploration
    final maxPosteriorMean = eligibleArms
        .map((a) => (_armPosteriors[a.armId]?.mean ?? a.priorSuccessRate))
        .reduce(math.max);
    final selectedMean =
        _armPosteriors[selected.key.armId]?.mean ?? selected.key.priorSuccessRate;
    final wasExploration = selectedMean < maxPosteriorMean * 0.9;

    return _ArmSelection(
      arm: selected.key,
      thompsonValue: selected.value,
      wasExploration: wasExploration,
    );
  }

  /// Simplified prerequisite check
  bool _meetsPrerequisites(InterventionArm arm, PsychometricProfile profile) {
    // Check rebel archetype requirement
    if (arm.requiresRebelArchetype && !_isRebelArchetype(profile)) {
      return false;
    }

    // Check witness requirement (TODO: add witness state to profile)
    if (arm.requiresWitness) {
      // For now, allow - will be filtered if no witness
      return true;
    }

    return true;
  }

  /// Apply context-based modifiers to lever samples
  void _applyLeverContextModifiers(
    Map<MetaLever, double> samples,
    ContextSnapshot context,
    VOState voState,
    PsychometricProfile profile,
  ) {
    // High vulnerability → boost Support
    if (voState.vulnerability > 0.7 && samples.containsKey(MetaLever.support)) {
      samples[MetaLever.support] = samples[MetaLever.support]! * 1.3;
    }

    // Strong habit (high identity fusion) → boost Trust
    if (context.history.habitStrength > 0.7 && samples.containsKey(MetaLever.trust)) {
      samples[MetaLever.trust] = samples[MetaLever.trust]! * 1.4;
    }

    // Rebel with high failure prediction → boost Trust (includes shadow)
    if (_isRebelArchetype(profile) &&
        voState.predictiveFailureProbability > 0.6 &&
        samples.containsKey(MetaLever.trust)) {
      samples[MetaLever.trust] = samples[MetaLever.trust]! * 1.5;
    }

    // Intervention fatigue → boost Trust (silence)
    if (context.history.isInterventionFatigued && samples.containsKey(MetaLever.trust)) {
      samples[MetaLever.trust] = samples[MetaLever.trust]! * 1.6;
    }

    // Low identity fusion → boost Activate (need identity reminders)
    if (context.history.identityFusionScore < 0.4 && samples.containsKey(MetaLever.activate)) {
      samples[MetaLever.activate] = samples[MetaLever.activate]! * 1.3;
    }
  }

  /// Apply context-based modifiers to arm samples
  void _applyArmContextModifiers(
    Map<InterventionArm, double> samples,
    ContextSnapshot context,
    VOState voState,
    PsychometricProfile profile,
  ) {
    for (final entry in samples.entries) {
      final arm = entry.key;
      var multiplier = 1.0;

      // Energy cost vs current energy state
      if (context.biometrics?.isSleepDeprived ?? false) {
        // Prefer low energy cost when tired
        multiplier *= (1.0 - arm.energyCost * 0.5);
      }

      // Intrusiveness vs intervention fatigue
      if (context.history.interventionCount24h > 2) {
        multiplier *= (1.0 - arm.intrusiveness * 0.3);
      }

      // Boost high identity reinforcement arms (our optimization target)
      multiplier *= (1.0 + arm.identityReinforcement * 0.2);

      samples[arm] = entry.value * multiplier;
    }
  }

  /// Sample from Beta distribution using gamma sampling
  double _sampleBeta(BetaDistribution beta) {
    final ga = _sampleGamma(beta.alpha);
    final gb = _sampleGamma(beta.beta);
    return ga / (ga + gb);
  }

  /// Sample from Gamma distribution using Marsaglia's method
  double _sampleGamma(double alpha) {
    if (alpha < 1) {
      return _sampleGamma(alpha + 1) * math.pow(_random.nextDouble(), 1 / alpha);
    }

    final d = alpha - 1.0 / 3.0;
    final c = 1.0 / math.sqrt(9.0 * d);

    while (true) {
      double x, v;
      do {
        x = _randomNormal();
        v = 1.0 + c * x;
      } while (v <= 0);

      v = v * v * v;
      final u = _random.nextDouble();

      if (u < 1.0 - 0.0331 * x * x * x * x) {
        return d * v;
      }

      if (math.log(u) < 0.5 * x * x + d * (1.0 - v + math.log(v))) {
        return d * v;
      }
    }
  }

  /// Generate standard normal random variable (Box-Muller)
  double _randomNormal() {
    final u1 = _random.nextDouble();
    final u2 = _random.nextDouble();
    return math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2);
  }

  /// Update posteriors based on outcome
  void update({
    required MetaLever lever,
    required String armId,
    required double reward, // 0.0 to 1.0
  }) {
    // Update lever posterior
    final leverPost = _leverPosteriors[lever]!;
    _leverPosteriors[lever] = BetaDistribution(
      alpha: leverPost.alpha + reward,
      beta: leverPost.beta + (1.0 - reward),
    );

    // Update arm posterior
    final armPost = _armPosteriors[armId] ??
        BetaDistribution(alpha: 1.0, beta: 1.0);
    _armPosteriors[armId] = BetaDistribution(
      alpha: armPost.alpha + reward,
      beta: armPost.beta + (1.0 - reward),
    );
  }

  /// Check if user has rebel archetype
  bool _isRebelArchetype(PsychometricProfile profile) {
    final archetype = profile.failureArchetype?.toUpperCase() ?? '';
    return archetype.contains('REBEL') ||
        archetype.contains('DEFIANT') ||
        archetype.contains('CONTRARIAN');
  }

  /// Default lever priors (cold start) - simplified for 3 levers
  static Map<MetaLever, BetaDistribution> _defaultLeverPriors() {
    return {
      MetaLever.activate: BetaDistribution(alpha: 5.0, beta: 5.0), // 50%
      MetaLever.support: BetaDistribution(alpha: 5.5, beta: 4.5), // 55%
      MetaLever.trust: BetaDistribution(alpha: 3.5, beta: 6.5), // 35%
    };
  }

  /// Default arm priors (from taxonomy)
  static Map<String, BetaDistribution> _defaultArmPriors() {
    final priors = <String, BetaDistribution>{};
    for (final arm in InterventionTaxonomy.allArms) {
      priors[arm.armId] = BetaDistribution(
        alpha: arm.priorAlpha,
        beta: arm.priorBeta,
      );
    }
    return priors;
  }

  /// Apply archetypal seeding based on profile
  static void _applyArchetypeSeeding(
    Map<MetaLever, BetaDistribution> leverPriors,
    Map<String, BetaDistribution> armPriors,
    PsychometricProfile profile,
  ) {
    final archetype = profile.failureArchetype?.toUpperCase() ?? '';

    // Rebel archetype: boost Trust (includes shadow)
    if (archetype.contains('REBEL') ||
        archetype.contains('DEFIANT') ||
        archetype.contains('CONTRARIAN')) {
      leverPriors[MetaLever.trust] =
          BetaDistribution(alpha: 5.0, beta: 5.0); // 50% (boosted from 35%)
      // Boost shadow arm
      _boostArm(armPriors, 'SHADOW_AUTONOMY', 1.3);
    }

    // Perfectionist: boost Support (make it easy)
    if (archetype.contains('PERFECTIONIST') || archetype.contains('ALL_OR')) {
      leverPriors[MetaLever.support] =
          BetaDistribution(alpha: 6.0, beta: 4.0); // 60% (boosted)
      _boostArm(armPriors, 'FRICTION_TINY', 1.3);
      _boostArm(armPriors, 'COG_ZOOM', 1.3);
    }

    // High neuroticism (from coaching style inference): boost Support
    if (profile.coachingStyle == CoachingStyle.supportive) {
      leverPriors[MetaLever.support] =
          BetaDistribution(alpha: 6.0, beta: 4.0); // 60%
      _boostArm(armPriors, 'EMO_COMPASSION', 1.3);
    }
  }

  static void _boostArm(
    Map<String, BetaDistribution> armPriors,
    String armId,
    double multiplier,
  ) {
    final current = armPriors[armId];
    if (current != null) {
      armPriors[armId] = BetaDistribution(
        alpha: current.alpha * multiplier,
        beta: current.beta,
      );
    }
  }

  /// Export posteriors for persistence
  Map<String, dynamic> exportState() {
    return {
      'leverPosteriors': _leverPosteriors.map(
        (k, v) => MapEntry(k.name, v.toJson()),
      ),
      'armPosteriors': _armPosteriors.map(
        (k, v) => MapEntry(k, v.toJson()),
      ),
      'explorationBoost': _explorationBoost,
    };
  }

  /// Import posteriors from persistence
  void importState(Map<String, dynamic> state) {
    // Import lever posteriors
    final leverData = state['leverPosteriors'] as Map<String, dynamic>?;
    if (leverData != null) {
      for (final entry in leverData.entries) {
        final lever = MetaLever.values.firstWhere(
          (l) => l.name == entry.key,
          orElse: () => MetaLever.trust,
        );
        _leverPosteriors[lever] =
            BetaDistribution.fromJson(entry.value as Map<String, dynamic>);
      }
    }

    // Import arm posteriors
    final armData = state['armPosteriors'] as Map<String, dynamic>?;
    if (armData != null) {
      for (final entry in armData.entries) {
        _armPosteriors[entry.key] =
            BetaDistribution.fromJson(entry.value as Map<String, dynamic>);
      }
    }

    // Import exploration boost
    _explorationBoost = (state['explorationBoost'] as num?)?.toDouble() ?? 1.2;
  }
}

// =============================================================================
// DATA CLASSES
// =============================================================================

/// Beta distribution for Thompson Sampling
class BetaDistribution {
  final double alpha; // Successes + 1
  final double beta; // Failures + 1

  const BetaDistribution({
    required this.alpha,
    required this.beta,
  });

  /// Mean of the distribution (expected success rate)
  double get mean => alpha / (alpha + beta);

  /// Variance of the distribution (uncertainty)
  double get variance => (alpha * beta) / ((alpha + beta) * (alpha + beta) * (alpha + beta + 1));

  Map<String, dynamic> toJson() => {'alpha': alpha, 'beta': beta};

  factory BetaDistribution.fromJson(Map<String, dynamic> json) {
    return BetaDistribution(
      alpha: (json['alpha'] as num).toDouble(),
      beta: (json['beta'] as num).toDouble(),
    );
  }
}

/// Result of intervention selection (simplified - removed exposure counts)
class InterventionSelection {
  final MetaLever lever;
  final InterventionArm arm;
  final double leverThompsonValue;
  final double armThompsonValue;
  final bool leverWasExploration;
  final bool armWasExploration;

  InterventionSelection({
    required this.lever,
    required this.arm,
    required this.leverThompsonValue,
    required this.armThompsonValue,
    required this.leverWasExploration,
    required this.armWasExploration,
  });

  bool get wasExploration => leverWasExploration || armWasExploration;

  Map<String, dynamic> toJson() => {
        'lever': lever.name,
        'armId': arm.armId,
        'leverThompsonValue': leverThompsonValue,
        'armThompsonValue': armThompsonValue,
        'wasExploration': wasExploration,
      };
}

/// Internal: lever selection result
class _LeverSelection {
  final MetaLever lever;
  final double thompsonValue;
  final bool wasExploration;

  _LeverSelection({
    required this.lever,
    required this.thompsonValue,
    required this.wasExploration,
  });
}

/// Internal: arm selection result
class _ArmSelection {
  final InterventionArm arm;
  final double thompsonValue;
  final bool wasExploration;

  _ArmSelection({
    required this.arm,
    required this.thompsonValue,
    required this.wasExploration,
  });
}
