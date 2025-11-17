/// Represents a single habit in the app
/// Based on Atomic Habits principles
class Habit {
  final String id;
  final String name;
  final String identity; // "I am a person who..."
  final String tinyVersion; // 2-minute rule version
  final int currentStreak;
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

  // Completion history tracking
  // Maps date string "yyyy-MM-dd" to completion status
  // e.g., {"2025-11-10": true, "2025-11-09": false}
  // Only stores explicit completions; missing dates are inferred as not completed
  final Map<String, bool> completionHistory;

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
    this.completionHistory = const {},
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
    Map<String, bool>? completionHistory,
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
      // New "Make it Attractive" and environment design fields
      'temptationBundle': temptationBundle,
      'preHabitRitual': preHabitRitual,
      'environmentCue': environmentCue,
      'environmentDistraction': environmentDistraction,
      // Completion history (date string -> bool map)
      'completionHistory': completionHistory,
    };
  }

  /// Creates habit from JSON
  /// Handles backward compatibility - new fields default to null if missing
  factory Habit.fromJson(Map<String, dynamic> json) {
    // Parse completion history with backward compatibility
    Map<String, bool> history = {};
    if (json.containsKey('completionHistory') && json['completionHistory'] != null) {
      final rawHistory = json['completionHistory'] as Map<dynamic, dynamic>;
      // Convert to Map<String, bool> safely
      history = rawHistory.map((key, value) => MapEntry(
        key.toString(),
        value as bool? ?? false,
      ));
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
      // New fields - safe to be null (backward compatible)
      temptationBundle: json['temptationBundle'] as String?,
      preHabitRitual: json['preHabitRitual'] as String?,
      environmentCue: json['environmentCue'] as String?,
      environmentDistraction: json['environmentDistraction'] as String?,
      // Completion history - defaults to empty map if missing
      completionHistory: history,
    );
  }
}
