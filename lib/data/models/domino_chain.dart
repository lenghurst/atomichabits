/// Domino Chain - A sequence of habits that trigger each other
/// 
/// Based on the concept that habits don't exist in isolation - they trigger
/// other behaviors. By consciously designing these chains, users can build
/// powerful morning routines, wind-down sequences, etc.
/// 
/// Example: Wake up → Make bed → Meditate → Shower → Review goals
class DominoChain {
  final String id;
  final String name;
  
  /// Description of what this chain accomplishes
  final String description;
  
  /// Ordered list of habit IDs in the chain
  final List<String> habitIds;
  
  /// Whether this chain is currently active
  final bool isActive;
  
  /// When this chain should be triggered
  /// e.g., "morning", "evening", "after work", "weekend"
  final String triggerContext;
  
  /// Specific time to start the chain (optional)
  final String? startTime;
  
  /// Days of week this chain applies (empty = all days)
  /// 1 = Monday, 7 = Sunday
  final List<int> activeDays;
  
  /// Total estimated duration of the chain in minutes
  final int estimatedDuration;
  
  /// Statistics
  final int timesStarted;
  final int timesCompleted;
  final DateTime? lastCompletedAt;
  
  /// Created/updated timestamps
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  DominoChain({
    required this.id,
    required this.name,
    this.description = '',
    required this.habitIds,
    this.isActive = true,
    this.triggerContext = 'anytime',
    this.startTime,
    this.activeDays = const [],
    this.estimatedDuration = 0,
    this.timesStarted = 0,
    this.timesCompleted = 0,
    this.lastCompletedAt,
    required this.createdAt,
    this.updatedAt,
  });
  
  /// Number of habits in the chain
  int get length => habitIds.length;
  
  /// Whether the chain is empty
  bool get isEmpty => habitIds.isEmpty;
  
  /// Completion rate of the chain
  double get completionRate => 
      timesStarted > 0 ? timesCompleted / timesStarted : 0;
  
  /// Whether this chain is scheduled for today
  bool get isScheduledForToday {
    if (activeDays.isEmpty) return true;
    final todayWeekday = DateTime.now().weekday;
    return activeDays.contains(todayWeekday);
  }
  
  /// Add a habit to the chain at a specific position
  DominoChain addHabit(String habitId, {int? position}) {
    final newHabits = List<String>.from(habitIds);
    if (position != null && position >= 0 && position <= newHabits.length) {
      newHabits.insert(position, habitId);
    } else {
      newHabits.add(habitId);
    }
    return copyWith(habitIds: newHabits);
  }
  
  /// Remove a habit from the chain
  DominoChain removeHabit(String habitId) {
    return copyWith(
      habitIds: habitIds.where((id) => id != habitId).toList(),
    );
  }
  
  /// Reorder habits in the chain
  DominoChain reorderHabits(int oldIndex, int newIndex) {
    final newHabits = List<String>.from(habitIds);
    final item = newHabits.removeAt(oldIndex);
    newHabits.insert(newIndex, item);
    return copyWith(habitIds: newHabits);
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'habitIds': habitIds,
    'isActive': isActive,
    'triggerContext': triggerContext,
    'startTime': startTime,
    'activeDays': activeDays,
    'estimatedDuration': estimatedDuration,
    'timesStarted': timesStarted,
    'timesCompleted': timesCompleted,
    'lastCompletedAt': lastCompletedAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };
  
  factory DominoChain.fromJson(Map<String, dynamic> json) => DominoChain(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    habitIds: (json['habitIds'] as List?)?.map((e) => e as String).toList() ?? [],
    isActive: json['isActive'] as bool? ?? true,
    triggerContext: json['triggerContext'] as String? ?? 'anytime',
    startTime: json['startTime'] as String?,
    activeDays: (json['activeDays'] as List?)?.map((e) => e as int).toList() ?? [],
    estimatedDuration: json['estimatedDuration'] as int? ?? 0,
    timesStarted: json['timesStarted'] as int? ?? 0,
    timesCompleted: json['timesCompleted'] as int? ?? 0,
    lastCompletedAt: json['lastCompletedAt'] != null
        ? DateTime.parse(json['lastCompletedAt'] as String)
        : null,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'] as String)
        : null,
  );
  
  DominoChain copyWith({
    String? name,
    String? description,
    List<String>? habitIds,
    bool? isActive,
    String? triggerContext,
    String? startTime,
    List<int>? activeDays,
    int? estimatedDuration,
    int? timesStarted,
    int? timesCompleted,
    DateTime? lastCompletedAt,
    DateTime? updatedAt,
  }) => DominoChain(
    id: id,
    name: name ?? this.name,
    description: description ?? this.description,
    habitIds: habitIds ?? this.habitIds,
    isActive: isActive ?? this.isActive,
    triggerContext: triggerContext ?? this.triggerContext,
    startTime: startTime ?? this.startTime,
    activeDays: activeDays ?? this.activeDays,
    estimatedDuration: estimatedDuration ?? this.estimatedDuration,
    timesStarted: timesStarted ?? this.timesStarted,
    timesCompleted: timesCompleted ?? this.timesCompleted,
    lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
    createdAt: createdAt,
    updatedAt: updatedAt ?? DateTime.now(),
  );
  
  /// Common chain templates
  static DominoChain morningRoutine({required String id}) => DominoChain(
    id: id,
    name: 'Morning Routine',
    description: 'Start your day with intention',
    habitIds: [],
    triggerContext: 'morning',
    startTime: '06:00',
    activeDays: [1, 2, 3, 4, 5, 6, 7], // All days
    createdAt: DateTime.now(),
  );
  
  static DominoChain eveningRoutine({required String id}) => DominoChain(
    id: id,
    name: 'Evening Wind-Down',
    description: 'Prepare for restful sleep',
    habitIds: [],
    triggerContext: 'evening',
    startTime: '21:00',
    activeDays: [1, 2, 3, 4, 5, 6, 7],
    createdAt: DateTime.now(),
  );
  
  static DominoChain workStartRoutine({required String id}) => DominoChain(
    id: id,
    name: 'Work Start Routine',
    description: 'Get focused and productive',
    habitIds: [],
    triggerContext: 'work_start',
    activeDays: [1, 2, 3, 4, 5], // Weekdays
    createdAt: DateTime.now(),
  );
}

/// Progress through a domino chain in a single session
class DominoChainSession {
  final String chainId;
  final DateTime startedAt;
  final List<DominoChainStep> steps;
  final bool isComplete;
  final DateTime? completedAt;
  
  DominoChainSession({
    required this.chainId,
    required this.startedAt,
    this.steps = const [],
    this.isComplete = false,
    this.completedAt,
  });
  
  /// Current step index (0-based)
  int get currentStepIndex => steps.where((s) => s.isComplete).length;
  
  /// Progress through the chain (0.0-1.0)
  double get progress => steps.isEmpty ? 0 : currentStepIndex / steps.length;
  
  /// Total duration so far in minutes
  int get totalDurationMinutes {
    return steps.fold<int>(0, (sum, step) => 
      sum + (step.durationMinutes ?? 0)
    );
  }
  
  Map<String, dynamic> toJson() => {
    'chainId': chainId,
    'startedAt': startedAt.toIso8601String(),
    'steps': steps.map((s) => s.toJson()).toList(),
    'isComplete': isComplete,
    'completedAt': completedAt?.toIso8601String(),
  };
  
  factory DominoChainSession.fromJson(Map<String, dynamic> json) => DominoChainSession(
    chainId: json['chainId'] as String,
    startedAt: DateTime.parse(json['startedAt'] as String),
    steps: (json['steps'] as List?)
        ?.map((s) => DominoChainStep.fromJson(s as Map<String, dynamic>))
        .toList() ?? [],
    isComplete: json['isComplete'] as bool? ?? false,
    completedAt: json['completedAt'] != null
        ? DateTime.parse(json['completedAt'] as String)
        : null,
  );
}

/// A single step in a domino chain session
class DominoChainStep {
  final String habitId;
  final bool isComplete;
  final DateTime? completedAt;
  final int? durationMinutes;
  final bool usedMinimumVersion;
  
  DominoChainStep({
    required this.habitId,
    this.isComplete = false,
    this.completedAt,
    this.durationMinutes,
    this.usedMinimumVersion = false,
  });
  
  Map<String, dynamic> toJson() => {
    'habitId': habitId,
    'isComplete': isComplete,
    'completedAt': completedAt?.toIso8601String(),
    'durationMinutes': durationMinutes,
    'usedMinimumVersion': usedMinimumVersion,
  };
  
  factory DominoChainStep.fromJson(Map<String, dynamic> json) => DominoChainStep(
    habitId: json['habitId'] as String,
    isComplete: json['isComplete'] as bool? ?? false,
    completedAt: json['completedAt'] != null
        ? DateTime.parse(json['completedAt'] as String)
        : null,
    durationMinutes: json['durationMinutes'] as int?,
    usedMinimumVersion: json['usedMinimumVersion'] as bool? ?? false,
  );
}
