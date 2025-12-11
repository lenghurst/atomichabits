import 'consistency_metrics.dart';

/// Represents a single habit in the app
/// Based on Atomic Habits principles
/// 
/// Enhanced with Graceful Consistency metrics and completion history
/// to support the "Never Miss Twice" philosophy.
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
  
  // ========== NEW: Graceful Consistency Fields ==========
  
  /// Complete history of completion dates (for calculating metrics)
  final List<DateTime> completionHistory;
  
  /// History of recovery events (bouncing back from misses)
  final List<RecoveryEvent> recoveryHistory;
  
  /// Last recorded miss reason (for pattern tracking)
  final String? lastMissReason;
  
  /// Failure playbook - user's pre-planned recovery strategy
  final FailurePlaybook? failurePlaybook;
  
  /// Total identity votes cast (cumulative completions)
  final int identityVotes;
  
  /// Longest streak ever achieved (historical best, for encouragement)
  final int longestStreak;
  
  /// Whether the habit is currently paused
  final bool isPaused;
  
  /// Date when habit was paused (if applicable)
  final DateTime? pausedAt;

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
    // New fields with defaults for backward compatibility
    this.completionHistory = const [],
    this.recoveryHistory = const [],
    this.lastMissReason,
    this.failurePlaybook,
    this.identityVotes = 0,
    this.longestStreak = 0,
    this.isPaused = false,
    this.pausedAt,
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
    FailurePlaybook? failurePlaybook,
    int? identityVotes,
    int? longestStreak,
    bool? isPaused,
    DateTime? pausedAt,
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
      failurePlaybook: failurePlaybook ?? this.failurePlaybook,
      identityVotes: identityVotes ?? this.identityVotes,
      longestStreak: longestStreak ?? this.longestStreak,
      isPaused: isPaused ?? this.isPaused,
      pausedAt: pausedAt ?? this.pausedAt,
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
      // New fields
      'completionHistory': completionHistory.map((d) => d.toIso8601String()).toList(),
      'recoveryHistory': recoveryHistory.map((r) => r.toJson()).toList(),
      'lastMissReason': lastMissReason,
      'failurePlaybook': failurePlaybook?.toJson(),
      'identityVotes': identityVotes,
      'longestStreak': longestStreak,
      'isPaused': isPaused,
      'pausedAt': pausedAt?.toIso8601String(),
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
    
    // Parse failure playbook
    FailurePlaybook? failurePlaybook;
    if (json['failurePlaybook'] != null) {
      failurePlaybook = FailurePlaybook.fromJson(
        json['failurePlaybook'] as Map<String, dynamic>
      );
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
      // New fields
      completionHistory: completionHistory,
      recoveryHistory: recoveryHistory,
      lastMissReason: json['lastMissReason'] as String?,
      failurePlaybook: failurePlaybook,
      identityVotes: json['identityVotes'] as int? ?? completionHistory.length,
      longestStreak: json['longestStreak'] as int? ?? json['currentStreak'] as int? ?? 0,
      isPaused: json['isPaused'] as bool? ?? false,
      pausedAt: json['pausedAt'] != null 
          ? DateTime.parse(json['pausedAt'] as String)
          : null,
    );
  }
}

/// Failure Playbook - User's pre-planned recovery strategy
/// 
/// "You don't fail because you mess up. You fail because you 
/// didn't have a plan for the mess up."
class FailurePlaybook {
  /// The scenario this playbook addresses
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
    required this.scenario,
    required this.recoveryAction,
    required this.selfTalk,
    this.environmentTweaks = const [],
    this.timesUsed = 0,
    this.timesSucceeded = 0,
  });
  
  /// Success rate of this playbook
  double get successRate => timesUsed > 0 ? timesSucceeded / timesUsed : 0;
  
  Map<String, dynamic> toJson() => {
    'scenario': scenario,
    'recoveryAction': recoveryAction,
    'selfTalk': selfTalk,
    'environmentTweaks': environmentTweaks,
    'timesUsed': timesUsed,
    'timesSucceeded': timesSucceeded,
  };
  
  factory FailurePlaybook.fromJson(Map<String, dynamic> json) => FailurePlaybook(
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
    String? scenario,
    String? recoveryAction,
    String? selfTalk,
    List<String>? environmentTweaks,
    int? timesUsed,
    int? timesSucceeded,
  }) => FailurePlaybook(
    scenario: scenario ?? this.scenario,
    recoveryAction: recoveryAction ?? this.recoveryAction,
    selfTalk: selfTalk ?? this.selfTalk,
    environmentTweaks: environmentTweaks ?? this.environmentTweaks,
    timesUsed: timesUsed ?? this.timesUsed,
    timesSucceeded: timesSucceeded ?? this.timesSucceeded,
  );
}
