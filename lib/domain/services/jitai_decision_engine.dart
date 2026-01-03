import '../entities/context_snapshot.dart';
import '../entities/intervention.dart';
import '../entities/psychometric_profile.dart';
import '../../data/models/habit.dart';
import 'vulnerability_opportunity_calculator.dart';
import 'hierarchical_bandit.dart';
import 'optimal_timing_predictor.dart';
import 'cascade_pattern_detector.dart';
import 'population_learning.dart';
import 'archetype_registry.dart';

/// JITAIDecisionEngine: The Orchestrator
///
/// Coordinates the full JITAI pipeline:
/// 1. Context aggregation (ContextSnapshot)
/// 2. V-O calculation (vulnerability + opportunity)
/// 3. Safety gates (Gottman ratio, fatigue)
/// 4. Intervention selection (Hierarchical Bandit)
/// 5. Content generation (copy, audio)
///
/// Phase 63: JITAI Foundation
/// Phase 64: ML Workstreams (Optimal Timing + Cascade Prevention)
/// Phase 65: Enhanced ML (Weather, Travel, Population Learning)
class JITAIDecisionEngine {
  final HierarchicalBandit _bandit;
  final GottmanTracker _gottmanTracker;
  final OptimalTimingPredictor _timingPredictor;
  final CascadePatternDetector _cascadeDetector;
  final PopulationLearningService _populationLearning;

  /// Recent interventions for fatigue tracking
  final List<InterventionEvent> _recentInterventions = [];
  static const _fatigueWindow = Duration(hours: 24);
  static const _maxInterventionsPerDay = 8;

  /// Minimum timing score to proceed (gates poor timing)
  static const _minTimingScore = 0.35;

  /// Minimum cascade risk to trigger proactive intervention
  static const _cascadeRiskThreshold = 0.6;

  JITAIDecisionEngine({
    HierarchicalBandit? bandit,
    GottmanTracker? gottmanTracker,
    OptimalTimingPredictor? timingPredictor,
    CascadePatternDetector? cascadeDetector,
    PopulationLearningService? populationLearning,
  })  : _bandit = bandit ?? HierarchicalBandit(),
        _gottmanTracker = gottmanTracker ?? GottmanTracker(),
        _timingPredictor = timingPredictor ?? OptimalTimingPredictor(),
        _cascadeDetector = cascadeDetector ?? CascadePatternDetector(),
        _populationLearning = populationLearning ?? PopulationLearningService();

  /// Create engine personalized for a user profile
  factory JITAIDecisionEngine.forProfile(PsychometricProfile profile) {
    return JITAIDecisionEngine(
      bandit: HierarchicalBandit.seededForProfile(profile),
    );
  }

  /// Main decision function: should we intervene, and how?
  Future<JITAIDecision> decide({
    required ContextSnapshot context,
    required PsychometricProfile profile,
    required Habit habit,
    DecisionTrigger trigger = DecisionTrigger.scheduled,
  }) async {
    // === STEP 1: Calculate V-O State ===
    final voState = VulnerabilityOpportunityCalculator.calculate(
      context: context,
      profile: profile,
    );

    // === STEP 1.5: Optimal Timing Analysis (ML Workstream #1) ===
    final timingScore = _timingPredictor.scoreCurrentTiming(
      habit: habit,
      context: context,
    );

    // === STEP 2: Safety Gates ===
    final safetyResult = _checkSafetyGates(context, voState, profile);
    if (!safetyResult.proceed) {
      return JITAIDecision.noIntervention(
        reason: safetyResult.reason!,
        voState: voState,
      );
    }

    // === STEP 2.5: Enhanced Cascade Detection (Weather, Travel, Patterns) ===
    final cascadeRisk = _cascadeDetector.detectRisk(
      habit: habit,
      context: context,
    );

    // If high cascade risk, trigger proactive intervention
    if (cascadeRisk.isHighRisk) {
      return _handleProactiveCascadePrevention(
        context: context,
        voState: voState,
        profile: profile,
        habit: habit,
        cascadeRisk: cascadeRisk,
      );
    }

    // === STEP 2.5b: Legacy Cascade Prevention (timing-based) ===
    if (timingScore.window?.reason == TimingReason.cascadePrevention) {
      return _handleCascadePrevention(context, voState, profile, habit, timingScore);
    }

    // === STEP 2.6: Timing Gate (poor timing = defer) ===
    // Skip this gate for manual triggers or very high VO states
    if (trigger != DecisionTrigger.manual && !voState.isCritical) {
      if (timingScore.score < _minTimingScore) {
        // Poor timing - defer to optimal window
        final window = timingScore.window;
        final retryMinutes = window != null
            ? window.minutesUntilWindow(context.time).clamp(10, 120)
            : 30;
        return JITAIDecision.deferred(
          voState: voState,
          retryAfter: Duration(minutes: retryMinutes),
        );
      }
    }

    // === STEP 3: Quadrant-based Strategy ===
    switch (voState.quadrant) {
      case VOQuadrant.silence:
        // Low vulnerability, low opportunity - stay silent
        return JITAIDecision.noIntervention(
          reason: NoInterventionReason.lowPriority,
          voState: voState,
        );

      case VOQuadrant.waitForMoment:
        // High vulnerability but low opportunity - defer
        return JITAIDecision.deferred(
          voState: voState,
          retryAfter: const Duration(minutes: 30),
        );

      case VOQuadrant.lightTouch:
      case VOQuadrant.interveneNow:
        // Proceed with intervention selection
        break;
    }

    // === STEP 4: Shadow Trigger Check (Crisis Gate) ===
    if (voState.isShadowTrigger && _isRebelArchetype(profile)) {
      return _forceShadowIntervention(context, voState, profile, habit);
    }

    // === STEP 5: Hierarchical Bandit Selection ===
    final selection = _bandit.select(
      context: context,
      voState: voState,
      profile: profile,
      isBreakHabit: habit.isBreakHabit ?? false,
      excludeArms: _getRecentArmIds(),
    );

    // === STEP 6: Generate Intervention Event ===
    final event = InterventionEvent(
      eventId: _generateEventId(),
      timestamp: DateTime.now(),
      habitId: habit.id,
      arm: selection.arm,
      selectedMetaLever: selection.lever,
      contextFeatures: context.toFeatureVector(),
      thompsonSampleValue: selection.armThompsonValue,
      wasExploration: selection.wasExploration,
      armExposureCount: selection.armExposureCount,
    );

    // Track intervention
    _trackIntervention(event);

    // === STEP 7: Build Decision ===
    return JITAIDecision.intervene(
      event: event,
      voState: voState,
      content: _generateContent(selection.arm, habit, profile, voState, context: context),
      burdenType: _classifyBurden(selection.arm),
    );
  }

  /// Force shadow intervention for rebels in crisis
  JITAIDecision _forceShadowIntervention(
    ContextSnapshot context,
    VOState voState,
    PsychometricProfile profile,
    Habit habit,
  ) {
    // Get the shadow arm (only SHADOW_AUTONOMY in simplified taxonomy)
    final arm = InterventionTaxonomy.getArm('SHADOW_AUTONOMY') ??
        InterventionTaxonomy.getArm('SILENCE_TRUST')!;

    final event = InterventionEvent(
      eventId: _generateEventId(),
      timestamp: DateTime.now(),
      habitId: habit.id,
      arm: arm,
      selectedMetaLever: MetaLever.trust,
      contextFeatures: context.toFeatureVector(),
      thompsonSampleValue: 0.8, // High confidence for forced selection
      wasExploration: false,
      armExposureCount: 0,
    );

    _trackIntervention(event);

    return JITAIDecision.intervene(
      event: event,
      voState: voState,
      content: _generateShadowContent(arm, habit, profile, voState),
      burdenType: BurdenType.withdrawal, // Shadow is a withdrawal
      isForcedShadow: true,
    );
  }

  /// Handle cascade prevention (ML Workstream #2)
  ///
  /// When a habit is at risk of cascade failure (missing 2+ days),
  /// we override normal gates and send a targeted recovery intervention.
  ///
  /// Philosophy: "Never Miss Twice" is the most critical moment.
  /// A cascade failure (3+ days) often leads to permanent abandonment.
  JITAIDecision _handleCascadePrevention(
    ContextSnapshot context,
    VOState voState,
    PsychometricProfile profile,
    Habit habit,
    InterventionTimingScore timingScore,
  ) {
    // Calculate days since last completion
    final daysSinceLast = habit.lastCompletedDate != null
        ? context.time.difference(habit.lastCompletedDate!).inDays
        : 999;

    // Choose intervention based on cascade severity
    InterventionArm arm;
    String cascadeLevel;

    if (daysSinceLast >= 3) {
      // Critical cascade - use compassion (EMO_COMPASSION)
      arm = InterventionTaxonomy.getArm('EMO_COMPASSION') ??
          InterventionTaxonomy.getArm('FRICTION_TINY')!;
      cascadeLevel = 'critical';
    } else if (daysSinceLast >= 2) {
      // Never Miss Twice moment - use friction reduction
      arm = InterventionTaxonomy.getArm('FRICTION_TINY') ??
          InterventionTaxonomy.getArm('ID_VOTE')!;
      cascadeLevel = 'warning';
    } else {
      // Approaching risk - gentle identity reminder
      arm = InterventionTaxonomy.getArm('ID_MIRROR') ??
          InterventionTaxonomy.getArm('ID_VOTE')!;
      cascadeLevel = 'watch';
    }

    final event = InterventionEvent(
      eventId: _generateEventId(),
      timestamp: DateTime.now(),
      habitId: habit.id,
      arm: arm,
      selectedMetaLever: arm.metaLever,
      contextFeatures: context.toFeatureVector(),
      thompsonSampleValue: 0.9, // High confidence for cascade prevention
      wasExploration: false,
      armExposureCount: 0,
    );

    _trackIntervention(event);

    // Generate cascade-specific content
    final content = _generateCascadeContent(
      arm: arm,
      habit: habit,
      profile: profile,
      daysSinceLast: daysSinceLast,
      cascadeLevel: cascadeLevel,
    );

    return JITAIDecision.intervene(
      event: event,
      voState: voState,
      content: content,
      burdenType: BurdenType.deposit, // Always supportive in cascade
    );
  }

  /// Generate cascade-specific intervention content
  InterventionContent _generateCascadeContent({
    required InterventionArm arm,
    required Habit habit,
    required PsychometricProfile profile,
    required int daysSinceLast,
    required String cascadeLevel,
  }) {
    String title;
    String body;
    String actionLabel;

    switch (cascadeLevel) {
      case 'critical':
        title = 'Welcome Back';
        body = 'It\'s been ${daysSinceLast} days. That\'s okay. '
            '${habit.identityVotes} votes for "${habit.identity}" still count. '
            'Today is just the next one.';
        actionLabel = 'Cast my vote';
        break;

      case 'warning':
        title = 'Never Miss Twice';
        body = 'Yesterday was a miss. Today is the comeback. '
            'Just ${habit.tinyVersion}—that\'s all it takes.';
        actionLabel = 'Do the tiny version';
        break;

      case 'watch':
      default:
        title = 'Quick Check-in';
        body = 'A ${habit.identity.toLowerCase()} would do this. '
            'Just a reminder.';
        actionLabel = 'Show up';
        break;
    }

    return InterventionContent(
      title: title,
      body: body,
      actionLabel: actionLabel,
      dismissLabel: 'I\'ll come back',
      armId: arm.armId,
    );
  }

  /// Handle proactive cascade prevention (weather, travel, patterns)
  ///
  /// Triggers BEFORE the cascade happens, not after.
  JITAIDecision _handleProactiveCascadePrevention({
    required ContextSnapshot context,
    required VOState voState,
    required PsychometricProfile profile,
    required Habit habit,
    required CascadeRisk cascadeRisk,
  }) {
    // Select arm based on cascade reason
    final arm = _selectArmForCascadeReason(cascadeRisk.reason);

    final event = InterventionEvent(
      eventId: _generateEventId(),
      timestamp: DateTime.now(),
      habitId: habit.id,
      arm: arm,
      selectedMetaLever: arm.metaLever,
      contextFeatures: context.toFeatureVector(),
      thompsonSampleValue: cascadeRisk.probability,
      wasExploration: false,
      armExposureCount: 0,
    );

    _trackIntervention(event);

    // Get suggestion from cascade detector
    final suggestion = _cascadeDetector.getAlternativeSuggestion(
      habit: habit,
      risk: cascadeRisk,
    );

    final content = InterventionContent(
      title: _getTitleForCascadeReason(cascadeRisk.reason),
      body: suggestion ?? cascadeRisk.explanation,
      actionLabel: _getActionForCascadeReason(cascadeRisk.reason),
      dismissLabel: 'Got it',
      armId: arm.armId,
    );

    return JITAIDecision.intervene(
      event: event,
      voState: voState,
      content: content,
      burdenType: BurdenType.deposit, // Proactive = supportive
    );
  }

  /// Select intervention arm based on cascade reason
  InterventionArm _selectArmForCascadeReason(CascadeRiskReason reason) {
    switch (reason) {
      case CascadeRiskReason.weatherBlocking:
      case CascadeRiskReason.travelDisruption:
      case CascadeRiskReason.calendarCrunch:
        // Friction reduction for external blockers
        return InterventionTaxonomy.getArm('FRICTION_TINY') ??
            InterventionTaxonomy.allArms.first;

      case CascadeRiskReason.yesterdayMiss:
        // Identity for Never Miss Twice
        return InterventionTaxonomy.getArm('ID_VOTE') ??
            InterventionTaxonomy.allArms.first;

      case CascadeRiskReason.multiDayMiss:
        // Compassion for multi-day miss
        return InterventionTaxonomy.getArm('EMO_COMPASSION') ??
            InterventionTaxonomy.allArms.first;

      case CascadeRiskReason.weekendPattern:
        // Pre-emptive identity reminder
        return InterventionTaxonomy.getArm('ID_MIRROR') ??
            InterventionTaxonomy.allArms.first;

      case CascadeRiskReason.energyGap:
        // Compassion for low energy
        return InterventionTaxonomy.getArm('EMO_COMPASSION') ??
            InterventionTaxonomy.allArms.first;

      case CascadeRiskReason.socialIsolation:
        // Social witness to re-engage
        return InterventionTaxonomy.getArm('SOCIAL_WITNESS') ??
            InterventionTaxonomy.allArms.first;

      case CascadeRiskReason.baseline:
        return InterventionTaxonomy.getArm('ID_VOTE') ??
            InterventionTaxonomy.allArms.first;
    }
  }

  String _getTitleForCascadeReason(CascadeRiskReason reason) {
    switch (reason) {
      case CascadeRiskReason.weatherBlocking:
        return 'Weather Alert';
      case CascadeRiskReason.travelDisruption:
        return 'Travel Mode';
      case CascadeRiskReason.weekendPattern:
        return 'Weekend Plan';
      case CascadeRiskReason.energyGap:
        return 'Easy Day';
      case CascadeRiskReason.yesterdayMiss:
        return 'Never Miss Twice';
      case CascadeRiskReason.multiDayMiss:
        return 'Welcome Back';
      case CascadeRiskReason.calendarCrunch:
        return 'Busy Day';
      case CascadeRiskReason.socialIsolation:
        return 'Check In';
      case CascadeRiskReason.baseline:
        return 'Quick Reminder';
    }
  }

  String _getActionForCascadeReason(CascadeRiskReason reason) {
    switch (reason) {
      case CascadeRiskReason.weatherBlocking:
        return 'Try indoor version';
      case CascadeRiskReason.travelDisruption:
        return 'Do travel version';
      case CascadeRiskReason.weekendPattern:
        return 'Set weekend plan';
      case CascadeRiskReason.energyGap:
        return 'Do tiny version';
      case CascadeRiskReason.yesterdayMiss:
        return 'Show up today';
      case CascadeRiskReason.multiDayMiss:
        return 'Start fresh';
      case CascadeRiskReason.calendarCrunch:
        return 'Find 2 minutes';
      case CascadeRiskReason.socialIsolation:
        return 'Update witness';
      case CascadeRiskReason.baseline:
        return 'Show up';
    }
  }

  /// Check safety gates before intervention
  _SafetyResult _checkSafetyGates(
    ContextSnapshot context,
    VOState voState,
    PsychometricProfile profile,
  ) {
    // Gate 1: Sensitive context (driving, sleeping, meeting)
    if (_isInSensitiveContext(context)) {
      return _SafetyResult(
        proceed: false,
        reason: NoInterventionReason.sensitiveContext,
      );
    }

    // Gate 2: Intervention fatigue
    if (_isInterventionFatigued()) {
      return _SafetyResult(
        proceed: false,
        reason: NoInterventionReason.fatigue,
      );
    }

    // Gate 3: Gottman ratio check (5:1 deposits to withdrawals)
    if (!_gottmanTracker.canWithdraw()) {
      // Must use deposit-type intervention only
      return _SafetyResult(
        proceed: true,
        forceDeposit: true,
      );
    }

    // Gate 4: Recent intervention cooldown
    if (_isInCooldown()) {
      return _SafetyResult(
        proceed: false,
        reason: NoInterventionReason.cooldown,
      );
    }

    return _SafetyResult(proceed: true);
  }

  /// Check if in sensitive context
  bool _isInSensitiveContext(ContextSnapshot context) {
    // In meeting
    if (context.calendar?.isInMeeting ?? false) {
      return true;
    }

    // Late night (11pm - 6am)
    final hour = context.time.hour;
    if (hour >= 23 || hour < 6) {
      return true;
    }

    // Driving (would need activity recognition)
    // TODO: Implement driving detection

    return false;
  }

  /// Check intervention fatigue
  bool _isInterventionFatigued() {
    _cleanupOldInterventions();
    return _recentInterventions.length >= _maxInterventionsPerDay;
  }

  /// Check cooldown since last intervention
  bool _isInCooldown() {
    if (_recentInterventions.isEmpty) return false;

    final lastIntervention = _recentInterventions.last;
    final timeSince = DateTime.now().difference(lastIntervention.timestamp);

    // Minimum 30 minutes between interventions
    return timeSince < const Duration(minutes: 30);
  }

  /// Get recent arm IDs to avoid repetition
  List<String> _getRecentArmIds() {
    final cutoff = DateTime.now().subtract(const Duration(hours: 4));
    return _recentInterventions
        .where((e) => e.timestamp.isAfter(cutoff))
        .map((e) => e.arm.armId)
        .toList();
  }

  /// Cleanup old interventions from tracking
  void _cleanupOldInterventions() {
    final cutoff = DateTime.now().subtract(_fatigueWindow);
    _recentInterventions.removeWhere((e) => e.timestamp.isBefore(cutoff));
  }

  /// Track intervention for fatigue/cooldown
  void _trackIntervention(InterventionEvent event) {
    _recentInterventions.add(event);
    _cleanupOldInterventions();
  }

  /// Classify burden type for Gottman tracking
  BurdenType _classifyBurden(InterventionArm arm) {
    // Positive emotional valence = deposit
    if (arm.emotionalValence > 0.3) {
      return BurdenType.deposit;
    }
    // Negative valence or high intrusiveness = withdrawal
    if (arm.emotionalValence < 0 || arm.intrusiveness > 0.5) {
      return BurdenType.withdrawal;
    }
    // Neutral
    return BurdenType.neutral;
  }

  /// Generate intervention content
  ///
  /// Uses archetype-specific messaging when available.
  InterventionContent _generateContent(
    InterventionArm arm,
    Habit habit,
    PsychometricProfile profile,
    VOState voState, {
    ContextSnapshot? context,
  }) {
    final archetype = _getArchetype(profile);

    // Use archetype greeting for identity activation arms
    String body;
    if (arm.category == InterventionCategory.identityActivation && context != null) {
      body = archetype.getGreeting(context, profile);
    } else {
      // Template-based content generation
      final template = _getTemplate(arm.armId);
      body = _fillTemplate(template, habit, profile, voState);
    }

    return InterventionContent(
      title: _getTitle(arm, voState),
      body: body,
      actionLabel: _getActionLabel(arm),
      dismissLabel: arm.category == InterventionCategory.shadowIntervention
          ? 'I\'ll prove you wrong'
          : 'Not now',
      armId: arm.armId,
    );
  }

  /// Generate shadow-specific content (simplified for identity-first)
  InterventionContent _generateShadowContent(
    InterventionArm arm,
    Habit habit,
    PsychometricProfile profile,
    VOState voState,
  ) {
    // Only SHADOW_AUTONOMY in simplified taxonomy
    final body = 'You\'ve cast ${habit.identityVotes ?? 0} votes for "${habit.identity ?? habit.name}". '
        'Today is your call.';

    return InterventionContent(
      title: 'Your Choice',
      body: body,
      actionLabel: 'Cast another vote',
      dismissLabel: 'Your call',
      armId: arm.armId,
    );
  }

  String _getTemplate(String armId) {
    // Base templates - will be personalized by LLM
    final templates = {
      'ID_MIRROR': 'What would a {{identity}} do right now?',
      'ID_ANTI_WARN': 'The {{antiIdentity}} hits snooze. You?',
      'ID_VOTE': 'Cast your vote: I am a {{identity}}.',
      'ID_FUTURE': '365 days of this: who are you then?',
      'FRICTION_TINY': 'Just {{tinyVersion}}. That\'s all.',
      'FRICTION_OBSTACLE': '{{obstacle}} blocked you before. Alternative: {{alternative}}',
      'EMO_ACK_STRESS': 'Rough day. That\'s real. Tiny win?',
      'EMO_COMPASSION': 'Welcome back. No judgment.',
      'COG_ZOOM': '{{completed}} of {{total}} days. This is noise.',
      'COG_LIE_CALL': 'That\'s "{{resistanceLie}}" talking.',
      'TIME_CASCADE': 'Weather ahead: {{forecast}}. Here\'s your plan.',
    };

    return templates[armId] ?? 'Time to show up for {{habit}}.';
  }

  String _fillTemplate(
    String template,
    Habit habit,
    PsychometricProfile profile,
    VOState voState,
  ) {
    return template
        .replaceAll('{{habit}}', habit.name)
        .replaceAll('{{identity}}', habit.identity ?? 'someone who does this')
        .replaceAll('{{antiIdentity}}', profile.antiIdentityLabel ?? 'the old you')
        .replaceAll('{{tinyVersion}}', habit.tinyVersion ?? '2 minutes')
        .replaceAll('{{resistanceLie}}', profile.resistanceLieLabel ?? 'The Excuse')
        .replaceAll('{{completed}}', '${habit.identityVotes ?? 0}')
        .replaceAll('{{total}}', '${(habit.identityVotes ?? 0) + 5}');
  }

  String _getTitle(InterventionArm arm, VOState voState) {
    if (voState.isCritical) {
      return 'Critical Moment';
    }

    switch (arm.metaLever) {
      case MetaLever.activate:
        return 'Time to Show Up';
      case MetaLever.support:
        return 'You\'ve Got This';
      case MetaLever.trust:
        return ''; // No title for silence/shadow
    }
  }

  String _getActionLabel(InterventionArm arm) {
    switch (arm.category) {
      case InterventionCategory.identityActivation:
        return 'Cast my vote';
      case InterventionCategory.socialWitness:
        return 'Show them who I am';
      case InterventionCategory.frictionReduction:
        return 'Do the tiny version';
      case InterventionCategory.emotionalRegulation:
        return 'I\'ve got this';
      case InterventionCategory.cognitiveReframe:
        return 'See clearly';
      case InterventionCategory.silence:
        return 'Trust myself';
      case InterventionCategory.shadowIntervention:
        return 'My choice';
    }
  }

  String _generateEventId() {
    return 'evt_${DateTime.now().millisecondsSinceEpoch}';
  }

  bool _isRebelArchetype(PsychometricProfile profile) {
    final archetype = ArchetypeRegistry.forProfile(profile);
    return archetype.id == 'REBEL';
  }

  /// Get the archetype object for a profile
  Archetype _getArchetype(PsychometricProfile profile) {
    return ArchetypeRegistry.forProfile(profile);
  }

  /// Record outcome and update learning systems
  ///
  /// Updates:
  /// 1. Local Thompson Sampling bandit
  /// 2. Gottman ratio tracker
  /// 3. Population learning (aggregated, privacy-preserving)
  void recordOutcome({
    required String eventId,
    required InterventionOutcome outcome,
    PsychometricProfile? profile,
  }) {
    // Find the event
    final event = _recentInterventions.cast<InterventionEvent?>().firstWhere(
          (e) => e?.eventId == eventId,
          orElse: () => null,
        );

    if (event == null) return;

    // Calculate reward
    final reward = _calculateReward(outcome);

    // Update bandit posteriors
    _bandit.update(
      lever: event.selectedMetaLever,
      armId: event.arm.armId,
      reward: reward,
    );

    // Update population learning (if profile available)
    if (profile != null) {
      _populationLearning.recordOutcome(
        archetype: profile.archetypeKey,
        armId: event.arm.armId,
        success: reward > 0.5, // Simple success threshold
      );
    }

    // Update Gottman tracker
    final burden = _classifyBurden(event.arm);
    if (burden == BurdenType.deposit) {
      _gottmanTracker.recordDeposit();
    } else if (burden == BurdenType.withdrawal) {
      _gottmanTracker.recordWithdrawal();
    }
  }

  /// Calculate identity-first reward from outcome
  ///
  /// Philosophy: Identity evidence is the PRIMARY optimization target.
  /// Since identityScoreDelta is async (DeepSeek analysis), we use
  /// IDENTITY EVIDENCE PROXIES that work from day 1:
  ///
  /// - Completion = voting for identity (each rep is evidence)
  /// - Streak = consistent identity (pattern of votes)
  /// - Engagement = relationship with identity narrative
  ///
  /// Reward Structure:
  /// - 50% Identity Evidence Proxy (completion + streak)
  /// - 30% Engagement Quality (notification interaction)
  /// - 15% Async Identity Bonus (when DeepSeek data available)
  /// - Penalties for identity undermining signals
  double _calculateReward(InterventionOutcome outcome) {
    double reward = 0.0;

    // === PRIMARY: Identity Evidence Proxy (50%) ===
    // Each completion is a vote for identity - works from day 1
    if (outcome.habitCompleted24h) {
      reward += 0.35; // Completion = identity evidence

      // Streak = consistent identity voting (big bonus)
      if (outcome.streakMaintained) {
        reward += 0.15; // Consistency is identity
      }

      // Tiny version still counts (lowered barrier)
      if (outcome.usedTinyVersion) {
        reward += 0.25;
      }
    } else {
      // Missed habit
      reward -= 0.2; // Penalize mechanism (but not too harshly, avoid death spiral)
    }

    // === ENGAGEMENT: Notification Interaction (30%) ===
    if (outcome.notificationOpened) {
      reward += 0.2;
    }
    if (outcome.interactionType == 'action') {
      reward += 0.1;
    }
    if (outcome.interactionType == 'dismiss') {
      reward -= 0.1;
    }

    // === ASYNC BONUS: Real Identity Delta (15% when available) ===
    // When DeepSeek analysis is ready, add refinement
    if (outcome.identityScoreDelta != null) {
      // Scale delta (-0.05 to +0.05) to bonus range (-0.1 to +0.15)
      final identityBonus = (outcome.identityScoreDelta! * 3.0).clamp(-0.1, 0.15);
      reward += identityBonus;
    }

    // === PENALTIES (Identity Undermining) ===
    // These hurt more because they damage the relationship
    if (outcome.wasAnnoyanceSignal) {
      reward -= 0.4; // Strong penalty - eroding trust
    }
    if (outcome.notificationDisabled) {
      reward -= 0.6; // Catastrophic - user rejected the system
    }

    return reward.clamp(0.0, 1.0);
  }

  // =============================================================================
  // TIMING API (for notification scheduler)
  // =============================================================================

  /// Get optimal intervention windows for a habit
  ///
  /// Used by notification scheduler to plan interventions at ideal times.
  List<TimingWindow> getOptimalWindows({
    required Habit habit,
    required ContextSnapshot context,
    int maxWindows = 3,
  }) {
    return _timingPredictor.predictOptimalWindows(
      habit: habit,
      context: context,
      maxWindows: maxWindows,
    );
  }

  /// Score whether NOW is a good time to intervene
  InterventionTimingScore scoreCurrentTiming({
    required Habit habit,
    required ContextSnapshot context,
  }) {
    return _timingPredictor.scoreCurrentTiming(
      habit: habit,
      context: context,
    );
  }

  /// Check if habit is at risk of cascade failure
  bool isAtCascadeRisk(Habit habit) {
    if (habit.lastCompletedDate == null) return false;
    final daysSinceLast = DateTime.now().difference(habit.lastCompletedDate!).inDays;
    return daysSinceLast >= 1;
  }

  /// Get cascade severity level (0=safe, 1=watch, 2=warning, 3=critical)
  int getCascadeSeverity(Habit habit) {
    if (habit.lastCompletedDate == null) return 3;
    final daysSinceLast = DateTime.now().difference(habit.lastCompletedDate!).inDays;
    if (daysSinceLast >= 3) return 3;
    if (daysSinceLast >= 2) return 2;
    if (daysSinceLast >= 1) return 1;
    return 0;
  }

  /// Get detailed cascade risk assessment
  CascadeRisk getCascadeRisk({
    required Habit habit,
    required ContextSnapshot context,
  }) {
    return _cascadeDetector.detectRisk(
      habit: habit,
      context: context,
    );
  }

  // =============================================================================
  // POPULATION LEARNING API
  // =============================================================================

  /// Get population priors for an archetype
  Map<String, PopulationPrior> getPopulationPriors(String archetype) {
    return _populationLearning.getPriorsForArchetype(archetype);
  }

  /// Sync population learning to cloud (call periodically)
  Future<void> syncPopulationLearning({
    required Future<void> Function(List<Map<String, dynamic>>) uploadBatch,
  }) {
    return _populationLearning.syncToCloud(uploadBatch: uploadBatch);
  }

  /// Load population learning from cloud (call on app start)
  Future<void> loadPopulationLearning({
    required Future<List<Map<String, dynamic>>> Function() fetchPriors,
  }) {
    return _populationLearning.loadFromCloud(fetchPriors: fetchPriors);
  }

  // =============================================================================
  // PERSISTENCE
  // =============================================================================

  /// Export state for persistence
  Map<String, dynamic> exportState() {
    return {
      'bandit': _bandit.exportState(),
      'gottman': _gottmanTracker.toJson(),
      'recentInterventions': _recentInterventions.map((e) => e.toJson()).toList(),
    };
  }

  /// Import state from persistence
  void importState(Map<String, dynamic> state) {
    if (state['bandit'] != null) {
      _bandit.importState(state['bandit'] as Map<String, dynamic>);
    }
    if (state['gottman'] != null) {
      _gottmanTracker.importState(state['gottman'] as Map<String, dynamic>);
    }
  }
}

// =============================================================================
// DATA CLASSES
// =============================================================================

/// The decision output
class JITAIDecision {
  final JITAIDecisionType type;
  final InterventionEvent? event;
  final InterventionContent? content;
  final VOState voState;
  final NoInterventionReason? noInterventionReason;
  final Duration? retryAfter;
  final BurdenType? burdenType;
  final bool isForcedShadow;

  JITAIDecision._({
    required this.type,
    this.event,
    this.content,
    required this.voState,
    this.noInterventionReason,
    this.retryAfter,
    this.burdenType,
    this.isForcedShadow = false,
  });

  factory JITAIDecision.intervene({
    required InterventionEvent event,
    required VOState voState,
    required InterventionContent content,
    required BurdenType burdenType,
    bool isForcedShadow = false,
  }) {
    return JITAIDecision._(
      type: JITAIDecisionType.intervene,
      event: event,
      content: content,
      voState: voState,
      burdenType: burdenType,
      isForcedShadow: isForcedShadow,
    );
  }

  factory JITAIDecision.noIntervention({
    required NoInterventionReason reason,
    required VOState voState,
  }) {
    return JITAIDecision._(
      type: JITAIDecisionType.noIntervention,
      voState: voState,
      noInterventionReason: reason,
    );
  }

  factory JITAIDecision.deferred({
    required VOState voState,
    required Duration retryAfter,
  }) {
    return JITAIDecision._(
      type: JITAIDecisionType.deferred,
      voState: voState,
      retryAfter: retryAfter,
    );
  }

  bool get shouldIntervene => type == JITAIDecisionType.intervene;

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'event': event?.toJson(),
        'content': content?.toJson(),
        'voState': voState.toJson(),
        'noInterventionReason': noInterventionReason?.name,
        'retryAfterMs': retryAfter?.inMilliseconds,
        'burdenType': burdenType?.name,
        'isForcedShadow': isForcedShadow,
      };
}

enum JITAIDecisionType {
  intervene,
  noIntervention,
  deferred,
}

enum NoInterventionReason {
  lowPriority,
  sensitiveContext,
  fatigue,
  cooldown,
  gottmanLimit,
}

enum DecisionTrigger {
  scheduled, // Regular check
  appOpen, // User opened app
  locationChange, // Geofence trigger
  calendarEvent, // Meeting ended
  manual, // User requested
  guardianMode, // Phase 65: Real-time doom scroll detection
  dopamineLoop, // Phase 65: Rapid app switching detected
}

/// Content to display for intervention
class InterventionContent {
  final String title;
  final String body;
  final String actionLabel;
  final String dismissLabel;
  final String armId;

  InterventionContent({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.dismissLabel,
    required this.armId,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'body': body,
        'actionLabel': actionLabel,
        'dismissLabel': dismissLabel,
        'armId': armId,
      };
}

/// Gottman ratio: maintain 5:1 positive to negative interactions
class GottmanTracker {
  int _deposits = 5; // Start with credit
  int _withdrawals = 1;

  static const double _targetRatio = 5.0;

  double get ratio => _deposits / (_withdrawals == 0 ? 1 : _withdrawals);

  bool canWithdraw() => ratio >= _targetRatio;

  void recordDeposit() {
    _deposits++;
  }

  void recordWithdrawal() {
    _withdrawals++;
  }

  void reset() {
    _deposits = 5;
    _withdrawals = 1;
  }

  Map<String, dynamic> toJson() => {
        'deposits': _deposits,
        'withdrawals': _withdrawals,
      };

  void importState(Map<String, dynamic> state) {
    _deposits = state['deposits'] as int? ?? 5;
    _withdrawals = state['withdrawals'] as int? ?? 1;
  }
}

enum BurdenType {
  deposit, // Positive, supportive
  withdrawal, // Demanding, challenging
  neutral, // Neither
}

/// Internal safety check result
class _SafetyResult {
  final bool proceed;
  final NoInterventionReason? reason;
  final bool forceDeposit;

  _SafetyResult({
    required this.proceed,
    this.reason,
    this.forceDeposit = false,
  });
}
