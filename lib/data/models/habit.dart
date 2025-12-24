import 'consistency_metrics.dart';
import 'habit_pattern.dart'; // Phase 14: Pattern Detection

/// Represents a single habit in the app
/// Based on Atomic Habits principles
/// 
/// Enhanced with:
/// - Graceful Consistency metrics and completion history
/// - "Never Miss Twice" philosophy support
/// - Habit Stacking (anchor habits/events)
/// - Flexible Tracking (days showed up, minimum versions, recoveries)
/// - Bright-Line Rules
/// - Failure Playbooks
/// - Focus Mode for multi-habit management
/// - Phase 14: Pattern Detection (missHistory tracking)
class Habit {
  final String id;
  final String name;
  final String identity; // "I am a person who..."
  final String tinyVersion; // 2-minute rule version
  final int currentStreak; // De-emphasized, kept for compatibility
  final DateTime? lastCompletedDate;
  final DateTime createdAt;
  
  // Implementation intentions (James Clear)
  final String implementationTime; // "22:00" - when to do the habit
  final String implementationLocation; // "In bed before sleep" - where to do it
  
  // Make it Attractive (James Clear's 2nd Law)
  final String? temptationBundle; // Enjoyable thing to pair with habit
  // e.g., "Have herbal tea while reading"
  
  // Pre-habit ritual (motivation/mindset ritual)
  final String? preHabitRitual; // Short 10-30 second ritual before habit
  // e.g., "3 deep breaths", "Put phone on airplane mode"
  
  // Environment design (Make it Obvious)
  final String? environmentCue; // Concrete environmental reminder
  // e.g., "Put book on pillow at 21:45"
  
  final String? environmentDistraction; // Distraction to remove/hide
  // e.g., "Charge phone in kitchen"
  
  // ========== Graceful Consistency Fields ==========
  
  /// Complete history of completion dates (for calculating metrics)
  final List<DateTime> completionHistory;
  
  /// History of recovery events (bouncing back from misses)
  final List<RecoveryEvent> recoveryHistory;
  
  /// Last recorded miss reason (for pattern tracking)
  /// @deprecated Use missHistory instead for structured data
  final String? lastMissReason;
  
  /// Phase 14: Structured miss history for pattern detection
  /// Stores detailed miss events with reasons, timing, and recovery status
  final List<MissEvent> missHistory;
  
  /// Failure playbooks - user's pre-planned recovery strategies
  final List<FailurePlaybook> failurePlaybooks;
  
  /// Legacy single playbook support
  final FailurePlaybook? failurePlaybook;
  
  /// Total identity votes cast (cumulative completions - never resets!)
  final int identityVotes;
  
  /// Longest streak ever achieved (historical best, for encouragement)
  final int longestStreak;
  
  /// Whether the habit is currently paused
  final bool isPaused;
  
  /// Date when habit was paused (if applicable)
  final DateTime? pausedAt;
  
  // ========== NEW: Habit Stacking ==========
  
  /// ID of another habit to stack this one onto
  /// "After I [ANCHOR HABIT], I will [THIS HABIT]"
  final String? anchorHabitId;
  
  /// Event to stack this habit onto (if not using another habit)
  /// e.g., "morning coffee", "brushing teeth", "getting home from work"
  final String? anchorEvent;
  
  /// Position in stack: 'before' or 'after' the anchor
  final String stackPosition; // 'before' or 'after'
  
  // ========== NEW: Flexible Tracking ==========
  
  /// Total days user "showed up" (completed any version) - NEVER resets
  /// This is the primary metric: "Did I show up today?"
  final int daysShowedUp;
  
  /// Count of times user did the 2-minute/minimum version
  /// Shows commitment even on hard days
  final int minimumVersionCount;
  
  /// Count of "Never Miss Twice" wins (recovered after single miss)
  final int singleMissRecoveries;
  
  /// Full completion count (distinguished from minimum version)
  final int fullCompletionCount;
  
  // ========== NEW: Bright-Line Rules ==========
  
  /// Clear, non-negotiable rule for this habit
  /// e.g., "I don't check email before 9am"
  /// e.g., "I don't eat after 8pm"
  final String? brightLineRule;
  
  /// Whether the bright-line rule is active
  final bool brightLineActive;
  
  /// Times the bright-line rule was upheld
  final int brightLineStreak;
  
  // ========== NEW: Focus Mode ==========
  
  /// Whether this is the current primary/focus habit
  /// Only one habit should be primary at a time (60-90 day focus)
  final bool isPrimaryHabit;
  
  /// When the current focus cycle started
  final DateTime? focusCycleStart;
  
  /// Target days for this focus cycle (default 60-90)
  final int targetCycleDays;
  
  /// Whether this habit has "graduated" from focus mode
  /// (successfully completed a focus cycle)
  final bool hasGraduated;
  
  /// Date when habit graduated from focus mode
  final DateTime? graduatedAt;
  
  // ========== NEW: Habit Category/Tags ==========
  
  /// Category for organizing habits
  /// e.g., "health", "productivity", "relationships", "learning"
  final String? category;
  
  /// Custom tags for filtering
  final List<String> tags;
  
  // ========== NEW: Difficulty & Progression ==========
  
  /// Current difficulty level (for progressive overload)
  /// 1 = tiny version, 2 = easy, 3 = medium, 4 = challenging, 5 = mastery
  final int difficultyLevel;
  
  /// Description of current difficulty version
  final String? currentDifficultyDescription;
  
  /// Progression milestones achieved
  final List<HabitMilestone> milestones;

  // ========== NEW: AI Onboarding Fields (v4.0.0) ==========

  /// Whether this is a "break" habit (vs "build" habit)
  /// true = breaking a bad habit, false = building a good habit
  final bool isBreakHabit;

  /// For break habits: what bad habit this replaces
  /// e.g., "Doomscrolling", "Smoking", "Stress eating"
  final String? replacesHabit;

  /// Root cause/trigger for the habit being replaced
  /// e.g., "Boredom", "Anxiety", "Stress relief"
  final String? rootCause;

  /// The healthy substitution plan for break habits
  /// e.g., "5-minute walk instead", "Breathing exercises"
  final String? substitutionPlan;

  /// Emoji representing this habit (for visual identity)
  /// e.g., "📚", "🏃", "🧘"
  final String? habitEmoji;

  /// User's motivation/why for this habit
  /// e.g., "To be healthier", "Expand my knowledge"
  final String? motivation;

  /// Simple recovery plan (for Never Miss Twice)
  /// e.g., "If I slip, take one deep breath and try again"
  final String? recoveryPlan;
  
  /// Scheduled time for this habit (ISO format or time string)
  /// Used for cloud sync and notifications
  final String? scheduledTime;

  Habit({
    required this.id,
    required this.name,
    required this.identity,
    required this.tinyVersion,
    this.currentStreak = 0,
    this.lastCompletedDate,
    required this.createdAt,
    required this.implementationTime,
    required this.implementationLocation,
    this.temptationBundle,
    this.preHabitRitual,
    this.environmentCue,
    this.environmentDistraction,
    // Graceful consistency fields
    this.completionHistory = const [],
    this.recoveryHistory = const [],
    this.lastMissReason,
    this.missHistory = const [], // Phase 14: Pattern Detection
    this.failurePlaybooks = const [],
    this.failurePlaybook,
    this.identityVotes = 0,
    this.longestStreak = 0,
    this.isPaused = false,
    this.pausedAt,
    // Habit stacking
    this.anchorHabitId,
    this.anchorEvent,
    this.stackPosition = 'after',
    // Flexible tracking
    this.daysShowedUp = 0,
    this.minimumVersionCount = 0,
    this.singleMissRecoveries = 0,
    this.fullCompletionCount = 0,
    // Bright-line rules
    this.brightLineRule,
    this.brightLineActive = false,
    this.brightLineStreak = 0,
    // Focus mode
    this.isPrimaryHabit = false,
    this.focusCycleStart,
    this.targetCycleDays = 66, // Average habit formation time
    this.hasGraduated = false,
    this.graduatedAt,
    // Category/tags
    this.category,
    this.tags = const [],
    // Difficulty
    this.difficultyLevel = 1,
    this.currentDifficultyDescription,
    this.milestones = const [],
    // AI Onboarding fields
    this.isBreakHabit = false,
    this.replacesHabit,
    this.rootCause,
    this.substitutionPlan,
    this.habitEmoji,
    this.motivation,
    this.recoveryPlan,
    this.scheduledTime,
  });

  /// Creates a copy of this habit with some fields updated
  Habit copyWith({
    String? name,
    String? identity,
    String? tinyVersion,
    int? currentStreak,
    DateTime? lastCompletedDate,
    String? implementationTime,
    String? implementationLocation,
    String? temptationBundle,
    String? preHabitRitual,
    String? environmentCue,
    String? environmentDistraction,
    List<DateTime>? completionHistory,
    List<RecoveryEvent>? recoveryHistory,
    String? lastMissReason,
    List<MissEvent>? missHistory, // Phase 14
    List<FailurePlaybook>? failurePlaybooks,
    FailurePlaybook? failurePlaybook,
    int? identityVotes,
    int? longestStreak,
    bool? isPaused,
    DateTime? pausedAt,
    String? anchorHabitId,
    String? anchorEvent,
    String? stackPosition,
    int? daysShowedUp,
    int? minimumVersionCount,
    int? singleMissRecoveries,
    int? fullCompletionCount,
    String? brightLineRule,
    bool? brightLineActive,
    int? brightLineStreak,
    bool? isPrimaryHabit,
    DateTime? focusCycleStart,
    int? targetCycleDays,
    bool? hasGraduated,
    DateTime? graduatedAt,
    String? category,
    List<String>? tags,
    int? difficultyLevel,
    String? currentDifficultyDescription,
    List<HabitMilestone>? milestones,
    // AI Onboarding fields
    bool? isBreakHabit,
    String? replacesHabit,
    String? rootCause,
    String? substitutionPlan,
    String? habitEmoji,
    String? motivation,
    String? recoveryPlan,
    String? scheduledTime,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      identity: identity ?? this.identity,
      tinyVersion: tinyVersion ?? this.tinyVersion,
      currentStreak: currentStreak ?? this.currentStreak,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      createdAt: createdAt,
      implementationTime: implementationTime ?? this.implementationTime,
      implementationLocation: implementationLocation ?? this.implementationLocation,
      temptationBundle: temptationBundle ?? this.temptationBundle,
      preHabitRitual: preHabitRitual ?? this.preHabitRitual,
      environmentCue: environmentCue ?? this.environmentCue,
      environmentDistraction: environmentDistraction ?? this.environmentDistraction,
      completionHistory: completionHistory ?? this.completionHistory,
      recoveryHistory: recoveryHistory ?? this.recoveryHistory,
      lastMissReason: lastMissReason ?? this.lastMissReason,
      missHistory: missHistory ?? this.missHistory, // Phase 14
      failurePlaybooks: failurePlaybooks ?? this.failurePlaybooks,
      failurePlaybook: failurePlaybook ?? this.failurePlaybook,
      identityVotes: identityVotes ?? this.identityVotes,
      longestStreak: longestStreak ?? this.longestStreak,
      isPaused: isPaused ?? this.isPaused,
      pausedAt: pausedAt ?? this.pausedAt,
      anchorHabitId: anchorHabitId ?? this.anchorHabitId,
      anchorEvent: anchorEvent ?? this.anchorEvent,
      stackPosition: stackPosition ?? this.stackPosition,
      daysShowedUp: daysShowedUp ?? this.daysShowedUp,
      minimumVersionCount: minimumVersionCount ?? this.minimumVersionCount,
      singleMissRecoveries: singleMissRecoveries ?? this.singleMissRecoveries,
      fullCompletionCount: fullCompletionCount ?? this.fullCompletionCount,
      brightLineRule: brightLineRule ?? this.brightLineRule,
      brightLineActive: brightLineActive ?? this.brightLineActive,
      brightLineStreak: brightLineStreak ?? this.brightLineStreak,
      isPrimaryHabit: isPrimaryHabit ?? this.isPrimaryHabit,
      focusCycleStart: focusCycleStart ?? this.focusCycleStart,
      targetCycleDays: targetCycleDays ?? this.targetCycleDays,
      hasGraduated: hasGraduated ?? this.hasGraduated,
      graduatedAt: graduatedAt ?? this.graduatedAt,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      currentDifficultyDescription: currentDifficultyDescription ?? this.currentDifficultyDescription,
      milestones: milestones ?? this.milestones,
      // AI Onboarding fields
      isBreakHabit: isBreakHabit ?? this.isBreakHabit,
      replacesHabit: replacesHabit ?? this.replacesHabit,
      rootCause: rootCause ?? this.rootCause,
      substitutionPlan: substitutionPlan ?? this.substitutionPlan,
      habitEmoji: habitEmoji ?? this.habitEmoji,
      motivation: motivation ?? this.motivation,
      recoveryPlan: recoveryPlan ?? this.recoveryPlan,
      scheduledTime: scheduledTime ?? this.scheduledTime,
    );
  }
  
  /// Calculate current consistency metrics from history
  ConsistencyMetrics get consistencyMetrics {
    return ConsistencyMetrics.fromCompletionHistory(
      completionDates: completionHistory,
      habitCreatedAt: createdAt,
      recoveryEvents: recoveryHistory,
    );
  }
  
  /// Quick check: was the habit completed today?
  bool get isCompletedToday {
    if (lastCompletedDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(
      lastCompletedDate!.year,
      lastCompletedDate!.month,
      lastCompletedDate!.day,
    );
    return lastDate == today;
  }
  
  /// Quick check: how many consecutive days missed (including today if not done)?
  int get currentMissStreak {
    final metrics = consistencyMetrics;
    return metrics.currentMissStreak;
  }
  
  /// Quick check: does this habit need recovery attention?
  bool get needsRecovery {
    return !isCompletedToday && currentMissStreak > 0;
  }
  
  /// Get the graceful consistency score (0-100)
  double get gracefulScore => consistencyMetrics.gracefulScore;
  
  /// Get weekly completion rate (0.0-1.0)
  double get weeklyAverage => consistencyMetrics.weeklyAverage;
  
  /// Check if habit is stacked onto something
  bool get isStacked => anchorHabitId != null || anchorEvent != null;
  
  /// Get the anchor description for display
  String get anchorDescription {
    if (anchorEvent != null) return anchorEvent!;
    if (anchorHabitId != null) return 'another habit';
    return '';
  }
  
  /// Get implementation intention as formatted string
  String get implementationIntention {
    if (isStacked) {
      final position = stackPosition == 'before' ? 'Before' : 'After';
      return '$position $anchorDescription, I will ${tinyVersion.toLowerCase()}';
    }
    return 'I will ${tinyVersion.toLowerCase()} at $implementationTime in $implementationLocation';
  }
  
  /// Check if currently in focus cycle
  bool get isInFocusCycle {
    if (!isPrimaryHabit || focusCycleStart == null) return false;
    final daysSinceStart = DateTime.now().difference(focusCycleStart!).inDays;
    return daysSinceStart < targetCycleDays;
  }
  
  /// Days remaining in focus cycle
  int get focusCycleDaysRemaining {
    if (!isInFocusCycle) return 0;
    final daysSinceStart = DateTime.now().difference(focusCycleStart!).inDays;
    return (targetCycleDays - daysSinceStart).clamp(0, targetCycleDays);
  }
  
  /// Progress through focus cycle (0.0-1.0)
  double get focusCycleProgress {
    if (!isPrimaryHabit || focusCycleStart == null) return 0;
    final daysSinceStart = DateTime.now().difference(focusCycleStart!).inDays;
    return (daysSinceStart / targetCycleDays).clamp(0.0, 1.0);
  }
  
  /// Show-up rate (days showed up / total possible days)
  double get showUpRate {
    final totalDays = DateTime.now().difference(createdAt).inDays + 1;
    if (totalDays <= 0) return 0;
    return daysShowedUp / totalDays;
  }
  
  /// Minimum version usage rate
  double get minimumVersionRate {
    if (daysShowedUp == 0) return 0;
    return minimumVersionCount / daysShowedUp;
  }
  
  /// "Never Miss Twice" success rate
  double get neverMissTwiceRate {
    return consistencyMetrics.neverMissTwiceRate;
  }
  
  /// Get applicable failure playbook for a given trigger
  FailurePlaybook? getPlaybookForTrigger(String trigger) {
    final triggerLower = trigger.toLowerCase();
    return failurePlaybooks.cast<FailurePlaybook?>().firstWhere(
      (p) => p!.trigger.toLowerCase().contains(triggerLower),
      orElse: () => failurePlaybook,
    );
  }

  /// Converts habit to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'identity': identity,
      'tinyVersion': tinyVersion,
      'currentStreak': currentStreak,
      'lastCompletedDate': lastCompletedDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'implementationTime': implementationTime,
      'implementationLocation': implementationLocation,
      'temptationBundle': temptationBundle,
      'preHabitRitual': preHabitRitual,
      'environmentCue': environmentCue,
      'environmentDistraction': environmentDistraction,
      // Graceful consistency
      'completionHistory': completionHistory.map((d) => d.toIso8601String()).toList(),
      'recoveryHistory': recoveryHistory.map((r) => r.toJson()).toList(),
      'lastMissReason': lastMissReason,
      'missHistory': missHistory.map((m) => m.toJson()).toList(), // Phase 14
      'failurePlaybooks': failurePlaybooks.map((p) => p.toJson()).toList(),
      'failurePlaybook': failurePlaybook?.toJson(),
      'identityVotes': identityVotes,
      'longestStreak': longestStreak,
      'isPaused': isPaused,
      'pausedAt': pausedAt?.toIso8601String(),
      // Habit stacking
      'anchorHabitId': anchorHabitId,
      'anchorEvent': anchorEvent,
      'stackPosition': stackPosition,
      // Flexible tracking
      'daysShowedUp': daysShowedUp,
      'minimumVersionCount': minimumVersionCount,
      'singleMissRecoveries': singleMissRecoveries,
      'fullCompletionCount': fullCompletionCount,
      // Bright-line rules
      'brightLineRule': brightLineRule,
      'brightLineActive': brightLineActive,
      'brightLineStreak': brightLineStreak,
      // Focus mode
      'isPrimaryHabit': isPrimaryHabit,
      'focusCycleStart': focusCycleStart?.toIso8601String(),
      'targetCycleDays': targetCycleDays,
      'hasGraduated': hasGraduated,
      'graduatedAt': graduatedAt?.toIso8601String(),
      // Category/tags
      'category': category,
      'tags': tags,
      // Difficulty
      'difficultyLevel': difficultyLevel,
      'currentDifficultyDescription': currentDifficultyDescription,
      'milestones': milestones.map((m) => m.toJson()).toList(),
      // AI Onboarding fields
      'isBreakHabit': isBreakHabit,
      'replacesHabit': replacesHabit,
      'rootCause': rootCause,
      'substitutionPlan': substitutionPlan,
      'habitEmoji': habitEmoji,
      'motivation': motivation,
      'recoveryPlan': recoveryPlan,
    };
  }

  /// Creates habit from JSON
  /// Handles backward compatibility - new fields default to safe values if missing
  factory Habit.fromJson(Map<String, dynamic> json) {
    // Parse completion history
    List<DateTime> completionHistory = [];
    if (json['completionHistory'] != null) {
      completionHistory = (json['completionHistory'] as List)
          .map((d) => DateTime.parse(d as String))
          .toList();
    } else if (json['lastCompletedDate'] != null) {
      // Backward compatibility: create minimal history from lastCompletedDate
      completionHistory = [DateTime.parse(json['lastCompletedDate'] as String)];
    }
    
    // Parse recovery history
    List<RecoveryEvent> recoveryHistory = [];
    if (json['recoveryHistory'] != null) {
      recoveryHistory = (json['recoveryHistory'] as List)
          .map((r) => RecoveryEvent.fromJson(r as Map<String, dynamic>))
          .toList();
    }
    
    // Phase 14: Parse miss history
    List<MissEvent> missHistory = [];
    if (json['missHistory'] != null) {
      missHistory = (json['missHistory'] as List)
          .map((m) => MissEvent.fromJson(m as Map<String, dynamic>))
          .toList();
    }
    
    // Parse failure playbooks (new list format)
    List<FailurePlaybook> failurePlaybooks = [];
    if (json['failurePlaybooks'] != null) {
      failurePlaybooks = (json['failurePlaybooks'] as List)
          .map((p) => FailurePlaybook.fromJson(p as Map<String, dynamic>))
          .toList();
    }
    
    // Parse legacy failure playbook
    FailurePlaybook? failurePlaybook;
    if (json['failurePlaybook'] != null) {
      failurePlaybook = FailurePlaybook.fromJson(
        json['failurePlaybook'] as Map<String, dynamic>
      );
    }
    
    // Parse milestones
    List<HabitMilestone> milestones = [];
    if (json['milestones'] != null) {
      milestones = (json['milestones'] as List)
          .map((m) => HabitMilestone.fromJson(m as Map<String, dynamic>))
          .toList();
    }
    
    // Parse tags
    List<String> tags = [];
    if (json['tags'] != null) {
      tags = (json['tags'] as List).map((t) => t as String).toList();
    }
    
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      identity: json['identity'] as String,
      tinyVersion: json['tinyVersion'] as String,
      currentStreak: json['currentStreak'] as int? ?? 0,
      lastCompletedDate: json['lastCompletedDate'] != null
          ? DateTime.parse(json['lastCompletedDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      implementationTime: json['implementationTime'] as String? ?? '09:00',
      implementationLocation: json['implementationLocation'] as String? ?? '',
      temptationBundle: json['temptationBundle'] as String?,
      preHabitRitual: json['preHabitRitual'] as String?,
      environmentCue: json['environmentCue'] as String?,
      environmentDistraction: json['environmentDistraction'] as String?,
      // Graceful consistency
      completionHistory: completionHistory,
      recoveryHistory: recoveryHistory,
      lastMissReason: json['lastMissReason'] as String?,
      missHistory: missHistory, // Phase 14
      failurePlaybooks: failurePlaybooks,
      failurePlaybook: failurePlaybook,
      identityVotes: json['identityVotes'] as int? ?? completionHistory.length,
      longestStreak: json['longestStreak'] as int? ?? json['currentStreak'] as int? ?? 0,
      isPaused: json['isPaused'] as bool? ?? false,
      pausedAt: json['pausedAt'] != null 
          ? DateTime.parse(json['pausedAt'] as String)
          : null,
      // Habit stacking
      anchorHabitId: json['anchorHabitId'] as String?,
      anchorEvent: json['anchorEvent'] as String?,
      stackPosition: json['stackPosition'] as String? ?? 'after',
      // Flexible tracking
      daysShowedUp: json['daysShowedUp'] as int? ?? completionHistory.length,
      minimumVersionCount: json['minimumVersionCount'] as int? ?? 0,
      singleMissRecoveries: json['singleMissRecoveries'] as int? ?? 0,
      fullCompletionCount: json['fullCompletionCount'] as int? ?? completionHistory.length,
      // Bright-line rules
      brightLineRule: json['brightLineRule'] as String?,
      brightLineActive: json['brightLineActive'] as bool? ?? false,
      brightLineStreak: json['brightLineStreak'] as int? ?? 0,
      // Focus mode
      isPrimaryHabit: json['isPrimaryHabit'] as bool? ?? false,
      focusCycleStart: json['focusCycleStart'] != null
          ? DateTime.parse(json['focusCycleStart'] as String)
          : null,
      targetCycleDays: json['targetCycleDays'] as int? ?? 66,
      hasGraduated: json['hasGraduated'] as bool? ?? false,
      graduatedAt: json['graduatedAt'] != null
          ? DateTime.parse(json['graduatedAt'] as String)
          : null,
      // Category/tags
      category: json['category'] as String?,
      tags: tags,
      // Difficulty
      difficultyLevel: json['difficultyLevel'] as int? ?? 1,
      currentDifficultyDescription: json['currentDifficultyDescription'] as String?,
      milestones: milestones,
      // AI Onboarding fields (backward compatible - default to safe values)
      isBreakHabit: json['isBreakHabit'] as bool? ?? false,
      replacesHabit: json['replacesHabit'] as String?,
      rootCause: json['rootCause'] as String?,
      substitutionPlan: json['substitutionPlan'] as String?,
      habitEmoji: json['habitEmoji'] as String?,
      motivation: json['motivation'] as String?,
      recoveryPlan: json['recoveryPlan'] as String?,
    );
  }

  /// Alias for toJson - used for Isolate serialisation.
  /// Required by PsychometricEngine.recalibrateRisksAsync.
  Map<String, dynamic> toSerializableMap() => toJson();

  /// Alias for fromJson - used for Isolate deserialisation.
  /// Required by PsychometricEngine.recalibrateRisksAsync.
  static Habit fromSerializableMap(Map<String, dynamic> map) => Habit.fromJson(map);
}

/// Failure Playbook - User's pre-planned recovery strategy
/// 
/// "You don't fail because you mess up. You fail because you 
/// didn't have a plan for the mess up."
class FailurePlaybook {
  /// The trigger/scenario this playbook addresses
  /// e.g., "busy", "travel", "sick", "low energy"
  final String trigger;
  
  /// The scenario description (more detailed)
  /// e.g., "When I miss because I'm too tired"
  final String scenario;
  
  /// The recovery action to take
  /// e.g., "I will do just 1 minute of reading"
  final String recoveryAction;
  
  /// Self-talk script for recovery
  /// e.g., "One miss doesn't define me. I'm still a reader."
  final String selfTalk;
  
  /// Environment tweaks to help prevent future misses
  final List<String> environmentTweaks;
  
  /// How many times this playbook has been used
  final int timesUsed;
  
  /// How many times using this playbook led to successful recovery
  final int timesSucceeded;
  
  FailurePlaybook({
    this.trigger = '',
    this.scenario = '',
    required this.recoveryAction,
    required this.selfTalk,
    this.environmentTweaks = const [],
    this.timesUsed = 0,
    this.timesSucceeded = 0,
  });
  
  /// Success rate of this playbook
  double get successRate => timesUsed > 0 ? timesSucceeded / timesUsed : 0;
  
  Map<String, dynamic> toJson() => {
    'trigger': trigger,
    'scenario': scenario,
    'recoveryAction': recoveryAction,
    'selfTalk': selfTalk,
    'environmentTweaks': environmentTweaks,
    'timesUsed': timesUsed,
    'timesSucceeded': timesSucceeded,
  };
  
  factory FailurePlaybook.fromJson(Map<String, dynamic> json) => FailurePlaybook(
    trigger: json['trigger'] as String? ?? json['scenario'] as String? ?? '',
    scenario: json['scenario'] as String? ?? '',
    recoveryAction: json['recoveryAction'] as String? ?? '',
    selfTalk: json['selfTalk'] as String? ?? '',
    environmentTweaks: (json['environmentTweaks'] as List?)
        ?.map((e) => e as String)
        .toList() ?? [],
    timesUsed: json['timesUsed'] as int? ?? 0,
    timesSucceeded: json['timesSucceeded'] as int? ?? 0,
  );
  
  FailurePlaybook copyWith({
    String? trigger,
    String? scenario,
    String? recoveryAction,
    String? selfTalk,
    List<String>? environmentTweaks,
    int? timesUsed,
    int? timesSucceeded,
  }) => FailurePlaybook(
    trigger: trigger ?? this.trigger,
    scenario: scenario ?? this.scenario,
    recoveryAction: recoveryAction ?? this.recoveryAction,
    selfTalk: selfTalk ?? this.selfTalk,
    environmentTweaks: environmentTweaks ?? this.environmentTweaks,
    timesUsed: timesUsed ?? this.timesUsed,
    timesSucceeded: timesSucceeded ?? this.timesSucceeded,
  );
}

/// Milestone tracking for habit progression
class HabitMilestone {
  final String id;
  final String name;
  final String description;
  final DateTime? achievedAt;
  final int requiredDays; // Days needed to achieve
  final String? reward; // Optional reward description
  
  HabitMilestone({
    required this.id,
    required this.name,
    this.description = '',
    this.achievedAt,
    required this.requiredDays,
    this.reward,
  });
  
  bool get isAchieved => achievedAt != null;
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'achievedAt': achievedAt?.toIso8601String(),
    'requiredDays': requiredDays,
    'reward': reward,
  };
  
  factory HabitMilestone.fromJson(Map<String, dynamic> json) => HabitMilestone(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    achievedAt: json['achievedAt'] != null
        ? DateTime.parse(json['achievedAt'] as String)
        : null,
    requiredDays: json['requiredDays'] as int,
    reward: json['reward'] as String?,
  );
  
  HabitMilestone copyWith({
    String? name,
    String? description,
    DateTime? achievedAt,
    int? requiredDays,
    String? reward,
  }) => HabitMilestone(
    id: id,
    name: name ?? this.name,
    description: description ?? this.description,
    achievedAt: achievedAt ?? this.achievedAt,
    requiredDays: requiredDays ?? this.requiredDays,
    reward: reward ?? this.reward,
  );
  
  /// Default milestones for any habit
  static List<HabitMilestone> defaultMilestones() => [
    HabitMilestone(id: '7days', name: 'First Week', description: '7 days of showing up', requiredDays: 7),
    HabitMilestone(id: '21days', name: 'Three Weeks', description: 'The initial habit formation period', requiredDays: 21),
    HabitMilestone(id: '30days', name: 'One Month', description: 'A full month of consistency', requiredDays: 30),
    HabitMilestone(id: '66days', name: 'Habit Formed', description: 'Average time for automaticity', requiredDays: 66),
    HabitMilestone(id: '90days', name: 'Quarter Year', description: '90 days of identity reinforcement', requiredDays: 90),
    HabitMilestone(id: '180days', name: 'Half Year', description: 'Six months of being this person', requiredDays: 180),
    HabitMilestone(id: '365days', name: 'One Year', description: 'A full year of identity votes', requiredDays: 365),
  ];
}
