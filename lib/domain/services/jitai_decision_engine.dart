import '../entities/context_snapshot.dart';
import '../entities/intervention.dart';
import '../entities/psychometric_profile.dart';
import '../../data/models/habit.dart';
import 'vulnerability_opportunity_calculator.dart';
import 'hierarchical_bandit.dart';

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
class JITAIDecisionEngine {
  final HierarchicalBandit _bandit;
  final GottmanTracker _gottmanTracker;

  /// Recent interventions for fatigue tracking
  final List<InterventionEvent> _recentInterventions = [];
  static const _fatigueWindow = Duration(hours: 24);
  static const _maxInterventionsPerDay = 8;

  JITAIDecisionEngine({
    HierarchicalBandit? bandit,
    GottmanTracker? gottmanTracker,
  })  : _bandit = bandit ?? HierarchicalBandit(),
        _gottmanTracker = gottmanTracker ?? GottmanTracker();

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

    // === STEP 2: Safety Gates ===
    final safetyResult = _checkSafetyGates(context, voState, profile);
    if (!safetyResult.proceed) {
      return JITAIDecision.noIntervention(
        reason: safetyResult.reason!,
        voState: voState,
      );
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
      content: _generateContent(selection.arm, habit, profile, voState),
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
    // Select from shadow arms
    final shadowArms = InterventionTaxonomy.armsForCategory(
      InterventionCategory.shadowIntervention,
    );

    // Prefer SHADOW_SKIP for high failure prediction
    final arm = shadowArms.firstWhere(
      (a) => a.armId == 'SHADOW_SKIP',
      orElse: () => shadowArms.first,
    );

    final event = InterventionEvent(
      eventId: _generateEventId(),
      timestamp: DateTime.now(),
      habitId: habit.id,
      arm: arm,
      selectedMetaLever: MetaLever.shadow,
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
  InterventionContent _generateContent(
    InterventionArm arm,
    Habit habit,
    PsychometricProfile profile,
    VOState voState,
  ) {
    // Template-based content generation
    // Will be enhanced with LLM personalization
    final template = _getTemplate(arm.armId);
    final filled = _fillTemplate(template, habit, profile, voState);

    return InterventionContent(
      title: _getTitle(arm, voState),
      body: filled,
      actionLabel: _getActionLabel(arm),
      dismissLabel: arm.category == InterventionCategory.shadowIntervention
          ? 'I\'ll prove you wrong'
          : 'Not now',
      armId: arm.armId,
    );
  }

  /// Generate shadow-specific content
  InterventionContent _generateShadowContent(
    InterventionArm arm,
    Habit habit,
    PsychometricProfile profile,
    VOState voState,
  ) {
    final failureProb = (voState.predictiveFailureProbability * 100).round();

    String body;
    switch (arm.armId) {
      case 'SHADOW_SKIP':
        body = 'Our model predicts $failureProb% chance you\'ll skip ${habit.name} today. '
            'The data suggests you should rest and try tomorrow.\n\n'
            'Unless you want to prove the algorithm wrong?';
        break;
      case 'SHADOW_DOUBT':
        body = 'Statistically, most people give up at this point. '
            'Your pattern suggests today will be a miss.\n\n'
            'It\'s understandable. Or is it?';
        break;
      case 'SHADOW_AUTONOMY':
      default:
        body = 'You\'ve cast ${habit.identityVotes ?? 0} votes for "${habit.identity ?? habit.name}". '
            'Today is your call.';
        break;
    }

    return InterventionContent(
      title: 'The Algorithm\'s Bet',
      body: body,
      actionLabel: 'Break the prediction',
      dismissLabel: 'Accept the odds',
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
      case MetaLever.kick:
        return 'Time to Show Up';
      case MetaLever.ease:
        return 'Make It Easy';
      case MetaLever.hold:
        return 'You\'ve Got This';
      case MetaLever.hush:
        return ''; // No title for silence
      case MetaLever.shadow:
        return 'The Algorithm\'s Bet';
    }
  }

  String _getActionLabel(InterventionArm arm) {
    switch (arm.category) {
      case InterventionCategory.identityActivation:
        return 'Cast my vote';
      case InterventionCategory.frictionReduction:
        return 'Do the tiny version';
      case InterventionCategory.emotionalRegulation:
        return 'I\'ve got this';
      case InterventionCategory.shadowIntervention:
        return 'Break the prediction';
      default:
        return 'Do it now';
    }
  }

  String _generateEventId() {
    return 'evt_${DateTime.now().millisecondsSinceEpoch}';
  }

  bool _isRebelArchetype(PsychometricProfile profile) {
    final archetype = profile.failureArchetype?.toUpperCase() ?? '';
    return archetype.contains('REBEL') ||
        archetype.contains('DEFIANT') ||
        archetype.contains('CONTRARIAN');
  }

  /// Record outcome and update bandit
  void recordOutcome({
    required String eventId,
    required InterventionOutcome outcome,
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

    // Update Gottman tracker
    final burden = _classifyBurden(event.arm);
    if (burden == BurdenType.deposit) {
      _gottmanTracker.recordDeposit();
    } else if (burden == BurdenType.withdrawal) {
      _gottmanTracker.recordWithdrawal();
    }
  }

  /// Calculate composite reward from outcome
  double _calculateReward(InterventionOutcome outcome) {
    double reward = 0.0;

    // Proximal reward (40%): Did they engage?
    if (outcome.notificationOpened) {
      reward += 0.2;
      if (outcome.interactionType == 'action') {
        reward += 0.2;
      }
    }

    // Distal reward (50%): Did they complete?
    if (outcome.habitCompleted24h) {
      reward += 0.4;
      if (outcome.usedTinyVersion) {
        reward += 0.1; // Bonus for using tiny version
      }
    }

    // Identity reward (10%): Long-term impact
    if (outcome.identityScoreDelta != null && outcome.identityScoreDelta! > 0) {
      reward += 0.1;
    }

    // Penalty for annoyance
    if (outcome.wasAnnoyanceSignal) {
      reward -= 0.3;
    }
    if (outcome.notificationDisabled) {
      reward -= 0.5;
    }

    return reward.clamp(0.0, 1.0);
  }

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
