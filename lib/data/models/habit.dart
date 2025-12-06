/// Represents a single habit in the app
/// Based on Atomic Habits principles
/// Supports both good habits (build) and bad habits (reduce/change)
class Habit {
  final String id;
  final String name;
  final String identity; // "I am a person who..."
  final String tinyVersion; // 2-minute rule version
  final int currentStreak;
  final DateTime? lastCompletedDate;
  final DateTime createdAt;

  // Habit type: 'good' (build) or 'bad' (reduce/change)
  final HabitType habitType;

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

  // === BAD HABIT FIELDS (Change / Reduce Habit Toolkit) ===

  // Substitution: alternate behavior that meets the same need
  final String? substitutionBehavior; // e.g., "Drink sparkling water instead of beer"
  final String? underlyingNeed; // e.g., "Relaxation", "Social connection", "Stress relief"

  // Cue Firewall: triggers to avoid or weaken
  final List<CueFirewall> cueFirewalls; // Time, place, people, emotion triggers to avoid

  // Bright-line rules: crisp "I don't..." rules
  final List<BrightLineRule> brightLineRules; // e.g., "I don't drink on weekdays"

  // Impulse guardrails: friction/steps to add
  final int frictionSteps; // Number of steps between cue and bad behavior
  final String? frictionDescription; // e.g., "Keep snacks in garage, not kitchen"

  // Progressive tracking for bad habits
  final int avoidedCount; // Times successfully avoided the bad habit
  final DateTime? lastAvoidedDate;

  // === SOCIAL LAYER FIELDS ===

  // People cues: "When I'm with X, I do Y"
  final List<PeopleCue> peopleCues;

  // Habit circle reference (if part of a group)
  final String? habitCircleId;

  // === CREATOR MODE FIELDS ===

  // Creator mode settings
  final bool isCreatorModeEnabled;
  final CreatorSessionType? creatorSessionType; // generate vs refine
  final int totalReps; // Total creative outputs (quantity-first)
  final int weeklyRepGoal; // Weekly target for reps
  final String? creatorWorkspace; // Minimal workspace description

  Habit({
    required this.id,
    required this.name,
    required this.identity,
    required this.tinyVersion,
    this.currentStreak = 0,
    this.lastCompletedDate,
    required this.createdAt,
    this.habitType = HabitType.good,
    required this.implementationTime,
    required this.implementationLocation,
    this.temptationBundle,
    this.preHabitRitual,
    this.environmentCue,
    this.environmentDistraction,
    // Bad habit fields
    this.substitutionBehavior,
    this.underlyingNeed,
    this.cueFirewalls = const [],
    this.brightLineRules = const [],
    this.frictionSteps = 0,
    this.frictionDescription,
    this.avoidedCount = 0,
    this.lastAvoidedDate,
    // Social fields
    this.peopleCues = const [],
    this.habitCircleId,
    // Creator mode fields
    this.isCreatorModeEnabled = false,
    this.creatorSessionType,
    this.totalReps = 0,
    this.weeklyRepGoal = 0,
    this.creatorWorkspace,
  });

  /// Creates a copy of this habit with some fields updated
  Habit copyWith({
    String? name,
    String? identity,
    String? tinyVersion,
    int? currentStreak,
    DateTime? lastCompletedDate,
    HabitType? habitType,
    String? implementationTime,
    String? implementationLocation,
    String? temptationBundle,
    String? preHabitRitual,
    String? environmentCue,
    String? environmentDistraction,
    // Bad habit fields
    String? substitutionBehavior,
    String? underlyingNeed,
    List<CueFirewall>? cueFirewalls,
    List<BrightLineRule>? brightLineRules,
    int? frictionSteps,
    String? frictionDescription,
    int? avoidedCount,
    DateTime? lastAvoidedDate,
    // Social fields
    List<PeopleCue>? peopleCues,
    String? habitCircleId,
    // Creator mode fields
    bool? isCreatorModeEnabled,
    CreatorSessionType? creatorSessionType,
    int? totalReps,
    int? weeklyRepGoal,
    String? creatorWorkspace,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      identity: identity ?? this.identity,
      tinyVersion: tinyVersion ?? this.tinyVersion,
      currentStreak: currentStreak ?? this.currentStreak,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      createdAt: createdAt,
      habitType: habitType ?? this.habitType,
      implementationTime: implementationTime ?? this.implementationTime,
      implementationLocation: implementationLocation ?? this.implementationLocation,
      temptationBundle: temptationBundle ?? this.temptationBundle,
      preHabitRitual: preHabitRitual ?? this.preHabitRitual,
      environmentCue: environmentCue ?? this.environmentCue,
      environmentDistraction: environmentDistraction ?? this.environmentDistraction,
      // Bad habit fields
      substitutionBehavior: substitutionBehavior ?? this.substitutionBehavior,
      underlyingNeed: underlyingNeed ?? this.underlyingNeed,
      cueFirewalls: cueFirewalls ?? this.cueFirewalls,
      brightLineRules: brightLineRules ?? this.brightLineRules,
      frictionSteps: frictionSteps ?? this.frictionSteps,
      frictionDescription: frictionDescription ?? this.frictionDescription,
      avoidedCount: avoidedCount ?? this.avoidedCount,
      lastAvoidedDate: lastAvoidedDate ?? this.lastAvoidedDate,
      // Social fields
      peopleCues: peopleCues ?? this.peopleCues,
      habitCircleId: habitCircleId ?? this.habitCircleId,
      // Creator mode fields
      isCreatorModeEnabled: isCreatorModeEnabled ?? this.isCreatorModeEnabled,
      creatorSessionType: creatorSessionType ?? this.creatorSessionType,
      totalReps: totalReps ?? this.totalReps,
      weeklyRepGoal: weeklyRepGoal ?? this.weeklyRepGoal,
      creatorWorkspace: creatorWorkspace ?? this.creatorWorkspace,
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
      'habitType': habitType.name,
      'implementationTime': implementationTime,
      'implementationLocation': implementationLocation,
      // Make it Attractive and environment design fields
      'temptationBundle': temptationBundle,
      'preHabitRitual': preHabitRitual,
      'environmentCue': environmentCue,
      'environmentDistraction': environmentDistraction,
      // Bad habit fields
      'substitutionBehavior': substitutionBehavior,
      'underlyingNeed': underlyingNeed,
      'cueFirewalls': cueFirewalls.map((c) => c.toJson()).toList(),
      'brightLineRules': brightLineRules.map((r) => r.toJson()).toList(),
      'frictionSteps': frictionSteps,
      'frictionDescription': frictionDescription,
      'avoidedCount': avoidedCount,
      'lastAvoidedDate': lastAvoidedDate?.toIso8601String(),
      // Social fields
      'peopleCues': peopleCues.map((p) => p.toJson()).toList(),
      'habitCircleId': habitCircleId,
      // Creator mode fields
      'isCreatorModeEnabled': isCreatorModeEnabled,
      'creatorSessionType': creatorSessionType?.name,
      'totalReps': totalReps,
      'weeklyRepGoal': weeklyRepGoal,
      'creatorWorkspace': creatorWorkspace,
    };
  }

  /// Creates habit from JSON
  /// Handles backward compatibility - new fields default to null if missing
  factory Habit.fromJson(Map<String, dynamic> json) {
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
      habitType: HabitType.values.firstWhere(
        (e) => e.name == json['habitType'],
        orElse: () => HabitType.good,
      ),
      implementationTime: json['implementationTime'] as String? ?? '09:00',
      implementationLocation: json['implementationLocation'] as String? ?? '',
      // New fields - safe to be null (backward compatible)
      temptationBundle: json['temptationBundle'] as String?,
      preHabitRitual: json['preHabitRitual'] as String?,
      environmentCue: json['environmentCue'] as String?,
      environmentDistraction: json['environmentDistraction'] as String?,
      // Bad habit fields
      substitutionBehavior: json['substitutionBehavior'] as String?,
      underlyingNeed: json['underlyingNeed'] as String?,
      cueFirewalls: (json['cueFirewalls'] as List<dynamic>?)
          ?.map((c) => CueFirewall.fromJson(c as Map<String, dynamic>))
          .toList() ?? [],
      brightLineRules: (json['brightLineRules'] as List<dynamic>?)
          ?.map((r) => BrightLineRule.fromJson(r as Map<String, dynamic>))
          .toList() ?? [],
      frictionSteps: json['frictionSteps'] as int? ?? 0,
      frictionDescription: json['frictionDescription'] as String?,
      avoidedCount: json['avoidedCount'] as int? ?? 0,
      lastAvoidedDate: json['lastAvoidedDate'] != null
          ? DateTime.parse(json['lastAvoidedDate'] as String)
          : null,
      // Social fields
      peopleCues: (json['peopleCues'] as List<dynamic>?)
          ?.map((p) => PeopleCue.fromJson(p as Map<String, dynamic>))
          .toList() ?? [],
      habitCircleId: json['habitCircleId'] as String?,
      // Creator mode fields
      isCreatorModeEnabled: json['isCreatorModeEnabled'] as bool? ?? false,
      creatorSessionType: json['creatorSessionType'] != null
          ? CreatorSessionType.values.firstWhere(
              (e) => e.name == json['creatorSessionType'],
              orElse: () => CreatorSessionType.generate,
            )
          : null,
      totalReps: json['totalReps'] as int? ?? 0,
      weeklyRepGoal: json['weeklyRepGoal'] as int? ?? 0,
      creatorWorkspace: json['creatorWorkspace'] as String?,
    );
  }

  /// Check if this is a bad habit that should be reduced/changed
  bool get isBadHabit => habitType == HabitType.bad;

  /// Get display text for habit type
  String get habitTypeDisplay => habitType == HabitType.good ? 'Build' : 'Reduce';
}

/// Type of habit: good (build) or bad (reduce/change)
enum HabitType {
  good, // Habit to build/strengthen
  bad,  // Habit to reduce/change
}

/// Types of creative sessions for Creator Mode
enum CreatorSessionType {
  generate, // Pure creation, quantity over quality
  refine,   // Deliberate practice, improving specific skills
}

/// Cue firewall entry - a trigger to avoid or weaken
/// Based on the Vietnam study concept
class CueFirewall {
  final String id;
  final CueType cueType; // time, place, people, emotion
  final String description; // e.g., "Friday evenings", "Bar with coworkers"
  final String? avoidanceStrategy; // How to avoid or weaken this cue

  CueFirewall({
    required this.id,
    required this.cueType,
    required this.description,
    this.avoidanceStrategy,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'cueType': cueType.name,
    'description': description,
    'avoidanceStrategy': avoidanceStrategy,
  };

  factory CueFirewall.fromJson(Map<String, dynamic> json) => CueFirewall(
    id: json['id'] as String,
    cueType: CueType.values.firstWhere(
      (e) => e.name == json['cueType'],
      orElse: () => CueType.time,
    ),
    description: json['description'] as String,
    avoidanceStrategy: json['avoidanceStrategy'] as String?,
  );
}

/// Type of cue that triggers a habit
enum CueType {
  time,     // e.g., "Friday 6pm", "After dinner"
  place,    // e.g., "Bar", "Couch", "Checkout line"
  people,   // e.g., "Coworkers", "Drinking buddies"
  emotion,  // e.g., "Stressed", "Bored", "Anxious"
  action,   // e.g., "Watching TV", "Opening phone"
}

/// Bright-line rule - crisp "I don't..." rules
/// With support for progressive extremism (rules that tighten over time)
class BrightLineRule {
  final String id;
  final String rule; // e.g., "I don't drink on weekdays"
  final RuleIntensity intensity; // How strict the rule is
  final DateTime createdAt;
  final String? progressionNote; // Note about how rule evolved

  BrightLineRule({
    required this.id,
    required this.rule,
    this.intensity = RuleIntensity.moderate,
    required this.createdAt,
    this.progressionNote,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'rule': rule,
    'intensity': intensity.name,
    'createdAt': createdAt.toIso8601String(),
    'progressionNote': progressionNote,
  };

  factory BrightLineRule.fromJson(Map<String, dynamic> json) => BrightLineRule(
    id: json['id'] as String,
    rule: json['rule'] as String,
    intensity: RuleIntensity.values.firstWhere(
      (e) => e.name == json['intensity'],
      orElse: () => RuleIntensity.moderate,
    ),
    createdAt: DateTime.parse(json['createdAt'] as String),
    progressionNote: json['progressionNote'] as String?,
  );
}

/// Intensity level for bright-line rules
/// Supports progressive extremism concept
enum RuleIntensity {
  gentle,   // Starting point, easier to follow
  moderate, // Standard rule
  strict,   // More demanding
  absolute, // No exceptions ever
}

/// People cue - "When I'm with X, I do Y"
/// Part of the Social Layer
class PeopleCue {
  final String id;
  final String person; // e.g., "Sarah", "My running group"
  final String behavior; // What you do with this person
  final bool isPositive; // Is this a good influence?

  PeopleCue({
    required this.id,
    required this.person,
    required this.behavior,
    this.isPositive = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'person': person,
    'behavior': behavior,
    'isPositive': isPositive,
  };

  factory PeopleCue.fromJson(Map<String, dynamic> json) => PeopleCue(
    id: json['id'] as String,
    person: json['person'] as String,
    behavior: json['behavior'] as String,
    isPositive: json['isPositive'] as bool? ?? true,
  );
}
