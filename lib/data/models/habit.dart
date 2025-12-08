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

  // Habit Stacking (James Clear) - "After [X], I will [new habit]"
  final String? anchorEvent; // e.g., "brush my teeth", "pour morning coffee"

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

  // === GRACEFUL CONSISTENCY METRICS (vs fragile streaks) ===

  // Total days user showed up (NEVER resets - this is the key metric)
  final int daysShowedUp;

  // Count of times user completed just the minimum 2-minute version
  final int minimumVersionCount;

  // "Never Miss Twice" tracking - times user recovered after single miss
  final int neverMissTwiceWins;

  // Completion history for rolling average calculation (last 30 days)
  // Stored as ISO8601 date strings for easy serialization
  final List<String> completionHistory;

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
    this.anchorEvent,
    this.temptationBundle,
    this.preHabitRitual,
    this.environmentCue,
    this.environmentDistraction,
    this.daysShowedUp = 0,
    this.minimumVersionCount = 0,
    this.neverMissTwiceWins = 0,
    this.completionHistory = const [],
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
    String? anchorEvent,
    String? temptationBundle,
    String? preHabitRitual,
    String? environmentCue,
    String? environmentDistraction,
    int? daysShowedUp,
    int? minimumVersionCount,
    int? neverMissTwiceWins,
    List<String>? completionHistory,
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
      anchorEvent: anchorEvent ?? this.anchorEvent,
      temptationBundle: temptationBundle ?? this.temptationBundle,
      preHabitRitual: preHabitRitual ?? this.preHabitRitual,
      environmentCue: environmentCue ?? this.environmentCue,
      environmentDistraction: environmentDistraction ?? this.environmentDistraction,
      daysShowedUp: daysShowedUp ?? this.daysShowedUp,
      minimumVersionCount: minimumVersionCount ?? this.minimumVersionCount,
      neverMissTwiceWins: neverMissTwiceWins ?? this.neverMissTwiceWins,
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
      // Habit stacking
      'anchorEvent': anchorEvent,
      // "Make it Attractive" and environment design fields
      'temptationBundle': temptationBundle,
      'preHabitRitual': preHabitRitual,
      'environmentCue': environmentCue,
      'environmentDistraction': environmentDistraction,
      // Graceful consistency metrics
      'daysShowedUp': daysShowedUp,
      'minimumVersionCount': minimumVersionCount,
      'neverMissTwiceWins': neverMissTwiceWins,
      'completionHistory': completionHistory,
    };
  }

  /// Creates habit from JSON
  /// Handles backward compatibility - new fields default to null/0 if missing
  factory Habit.fromJson(Map<String, dynamic> json) {
    // Parse completion history with backward compatibility
    List<String> history = [];
    if (json['completionHistory'] != null && json['completionHistory'] is List) {
      history = (json['completionHistory'] as List)
          .map((item) => item.toString())
          .toList();
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
      // Habit stacking (backward compatible)
      anchorEvent: json['anchorEvent'] as String?,
      // "Make it Attractive" fields (backward compatible)
      temptationBundle: json['temptationBundle'] as String?,
      preHabitRitual: json['preHabitRitual'] as String?,
      environmentCue: json['environmentCue'] as String?,
      environmentDistraction: json['environmentDistraction'] as String?,
      // Graceful consistency metrics (backward compatible - default to 0)
      daysShowedUp: json['daysShowedUp'] as int? ?? 0,
      minimumVersionCount: json['minimumVersionCount'] as int? ?? 0,
      neverMissTwiceWins: json['neverMissTwiceWins'] as int? ?? 0,
      completionHistory: history,
    );
  }

  /// Calculate Graceful Consistency Score (0-100)
  /// Based on rolling 4-week average + never-miss-twice factor
  int get gracefulConsistencyScore {
    if (completionHistory.isEmpty) return 0;

    final now = DateTime.now();
    final fourWeeksAgo = now.subtract(const Duration(days: 28));

    // Count completions in last 4 weeks
    int recentCompletions = 0;
    for (final dateStr in completionHistory) {
      try {
        final date = DateTime.parse(dateStr);
        if (date.isAfter(fourWeeksAgo)) {
          recentCompletions++;
        }
      } catch (_) {
        // Skip invalid dates
      }
    }

    // Base score: percentage of last 28 days completed (max 70 points)
    final baseScore = (recentCompletions / 28 * 70).clamp(0, 70).toInt();

    // Bonus for "never miss twice" wins (max 30 points)
    // Each recovery is worth 5 points, capped at 30
    final recoveryBonus = (neverMissTwiceWins * 5).clamp(0, 30);

    return (baseScore + recoveryBonus).clamp(0, 100);
  }

  /// Get rolling 4-week adherence percentage
  double get rollingAdherencePercent {
    if (completionHistory.isEmpty) return 0.0;

    final now = DateTime.now();
    final fourWeeksAgo = now.subtract(const Duration(days: 28));

    int recentCompletions = 0;
    for (final dateStr in completionHistory) {
      try {
        final date = DateTime.parse(dateStr);
        if (date.isAfter(fourWeeksAgo)) {
          recentCompletions++;
        }
      } catch (_) {}
    }

    return (recentCompletions / 28 * 100).clamp(0, 100);
  }
}
