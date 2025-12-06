/// Represents a Creator Mode session
/// Based on the "Quantity Over Quality" principle (photo class story)
/// and WordStar/deep focus mode for writers/creatives
class CreatorSession {
  final String id;
  final String habitId; // Which habit this session is for
  final DateTime startedAt;
  final DateTime? endedAt;
  final CreatorSessionType sessionType;

  // Quantity tracking (reps-first for creative habits)
  final int repsCompleted; // Number of outputs created
  final String? repUnit; // e.g., "words", "photos", "sketches", "lines of code"

  // Session notes
  final String? learnings; // What did you learn this session?
  final String? blockers; // What got in the way?

  // Focus workspace state
  final bool wasMinimalWorkspace; // Was this in WordStar/focus mode?
  final int? focusMinutes; // How long in focus mode

  // Quality vs quantity mode
  final bool isQuantityMode; // Pure creation vs deliberate practice

  CreatorSession({
    required this.id,
    required this.habitId,
    required this.startedAt,
    this.endedAt,
    this.sessionType = CreatorSessionType.generate,
    this.repsCompleted = 0,
    this.repUnit,
    this.learnings,
    this.blockers,
    this.wasMinimalWorkspace = false,
    this.focusMinutes,
    this.isQuantityMode = true,
  });

  CreatorSession copyWith({
    DateTime? endedAt,
    CreatorSessionType? sessionType,
    int? repsCompleted,
    String? repUnit,
    String? learnings,
    String? blockers,
    bool? wasMinimalWorkspace,
    int? focusMinutes,
    bool? isQuantityMode,
  }) {
    return CreatorSession(
      id: id,
      habitId: habitId,
      startedAt: startedAt,
      endedAt: endedAt ?? this.endedAt,
      sessionType: sessionType ?? this.sessionType,
      repsCompleted: repsCompleted ?? this.repsCompleted,
      repUnit: repUnit ?? this.repUnit,
      learnings: learnings ?? this.learnings,
      blockers: blockers ?? this.blockers,
      wasMinimalWorkspace: wasMinimalWorkspace ?? this.wasMinimalWorkspace,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      isQuantityMode: isQuantityMode ?? this.isQuantityMode,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'habitId': habitId,
    'startedAt': startedAt.toIso8601String(),
    'endedAt': endedAt?.toIso8601String(),
    'sessionType': sessionType.name,
    'repsCompleted': repsCompleted,
    'repUnit': repUnit,
    'learnings': learnings,
    'blockers': blockers,
    'wasMinimalWorkspace': wasMinimalWorkspace,
    'focusMinutes': focusMinutes,
    'isQuantityMode': isQuantityMode,
  };

  factory CreatorSession.fromJson(Map<String, dynamic> json) => CreatorSession(
    id: json['id'] as String,
    habitId: json['habitId'] as String,
    startedAt: DateTime.parse(json['startedAt'] as String),
    endedAt: json['endedAt'] != null
        ? DateTime.parse(json['endedAt'] as String)
        : null,
    sessionType: CreatorSessionType.values.firstWhere(
      (e) => e.name == json['sessionType'],
      orElse: () => CreatorSessionType.generate,
    ),
    repsCompleted: json['repsCompleted'] as int? ?? 0,
    repUnit: json['repUnit'] as String?,
    learnings: json['learnings'] as String?,
    blockers: json['blockers'] as String?,
    wasMinimalWorkspace: json['wasMinimalWorkspace'] as bool? ?? false,
    focusMinutes: json['focusMinutes'] as int?,
    isQuantityMode: json['isQuantityMode'] as bool? ?? true,
  );

  /// Get duration of the session
  Duration get duration {
    final end = endedAt ?? DateTime.now();
    return end.difference(startedAt);
  }

  /// Check if session is still active
  bool get isActive => endedAt == null;

  /// Get display string for reps
  String get repsDisplay {
    final unit = repUnit ?? 'reps';
    return '$repsCompleted $unit';
  }
}

/// Types of creative sessions
enum CreatorSessionType {
  generate, // Pure creation, quantity over quality (e.g., write 500 words, take 100 photos)
  refine,   // Deliberate practice, improving specific skills (e.g., edit one paragraph)
}

/// Extension for session type display
extension CreatorSessionTypeExtension on CreatorSessionType {
  String get displayName {
    switch (this) {
      case CreatorSessionType.generate:
        return 'Create (Quantity)';
      case CreatorSessionType.refine:
        return 'Refine (Quality)';
    }
  }

  String get description {
    switch (this) {
      case CreatorSessionType.generate:
        return 'Focus on volume. Don\'t edit, just create.';
      case CreatorSessionType.refine:
        return 'Focus on improving one specific skill or piece.';
    }
  }

  String get icon {
    switch (this) {
      case CreatorSessionType.generate:
        return '🚀';
      case CreatorSessionType.refine:
        return '🎯';
    }
  }
}

/// Weekly summary for creator mode habits
class CreatorWeeklySummary {
  final String habitId;
  final DateTime weekStart;
  final int totalReps;
  final int sessionsCompleted;
  final int focusMinutes;
  final List<String> learnings;
  final double weeklyGoalProgress; // 0.0 to 1.0+

  CreatorWeeklySummary({
    required this.habitId,
    required this.weekStart,
    this.totalReps = 0,
    this.sessionsCompleted = 0,
    this.focusMinutes = 0,
    this.learnings = const [],
    this.weeklyGoalProgress = 0,
  });

  Map<String, dynamic> toJson() => {
    'habitId': habitId,
    'weekStart': weekStart.toIso8601String(),
    'totalReps': totalReps,
    'sessionsCompleted': sessionsCompleted,
    'focusMinutes': focusMinutes,
    'learnings': learnings,
    'weeklyGoalProgress': weeklyGoalProgress,
  };

  factory CreatorWeeklySummary.fromJson(Map<String, dynamic> json) =>
      CreatorWeeklySummary(
        habitId: json['habitId'] as String,
        weekStart: DateTime.parse(json['weekStart'] as String),
        totalReps: json['totalReps'] as int? ?? 0,
        sessionsCompleted: json['sessionsCompleted'] as int? ?? 0,
        focusMinutes: json['focusMinutes'] as int? ?? 0,
        learnings: (json['learnings'] as List<dynamic>?)
            ?.map((l) => l as String)
            .toList() ?? [],
        weeklyGoalProgress: (json['weeklyGoalProgress'] as num?)?.toDouble() ?? 0,
      );

  /// Get formatted focus time
  String get focusTimeDisplay {
    final hours = focusMinutes ~/ 60;
    final mins = focusMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }

  /// Check if goal was met
  bool get goalMet => weeklyGoalProgress >= 1.0;
}
