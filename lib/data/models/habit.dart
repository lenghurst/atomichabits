/// Represents a single habit in the app
/// Based on Atomic Habits principles
class Habit {
  final String id;
  final String name;
  final String identity; // "I am a person who..."
  final String tinyVersion; // 2-minute rule version
  final int currentStreak;
  final int longestStreak; // Best streak ever achieved
  final DateTime? lastCompletedDate;
  final DateTime createdAt;

  // Completion history for calendar view and analytics
  final List<DateTime> completionHistory;
  
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

  Habit({
    required this.id,
    required this.name,
    required this.identity,
    required this.tinyVersion,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCompletedDate,
    required this.createdAt,
    List<DateTime>? completionHistory,
    required this.implementationTime,
    required this.implementationLocation,
    this.temptationBundle,
    this.preHabitRitual,
    this.environmentCue,
    this.environmentDistraction,
  }) : completionHistory = completionHistory ?? [];

  /// Creates a copy of this habit with some fields updated
  Habit copyWith({
    String? name,
    String? identity,
    String? tinyVersion,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastCompletedDate,
    List<DateTime>? completionHistory,
    String? implementationTime,
    String? implementationLocation,
    String? temptationBundle,
    String? preHabitRitual,
    String? environmentCue,
    String? environmentDistraction,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      identity: identity ?? this.identity,
      tinyVersion: tinyVersion ?? this.tinyVersion,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      completionHistory: completionHistory ?? this.completionHistory,
      createdAt: createdAt,
      implementationTime: implementationTime ?? this.implementationTime,
      implementationLocation: implementationLocation ?? this.implementationLocation,
      temptationBundle: temptationBundle ?? this.temptationBundle,
      preHabitRitual: preHabitRitual ?? this.preHabitRitual,
      environmentCue: environmentCue ?? this.environmentCue,
      environmentDistraction: environmentDistraction ?? this.environmentDistraction,
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
      'longestStreak': longestStreak,
      'lastCompletedDate': lastCompletedDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      // Completion history for calendar and analytics
      'completionHistory': completionHistory
          .map((date) => date.toIso8601String())
          .toList(),
      'implementationTime': implementationTime,
      'implementationLocation': implementationLocation,
      // "Make it Attractive" and environment design fields
      'temptationBundle': temptationBundle,
      'preHabitRitual': preHabitRitual,
      'environmentCue': environmentCue,
      'environmentDistraction': environmentDistraction,
    };
  }

  /// Creates habit from JSON
  /// Handles backward compatibility - new fields default to empty/zero if missing
  factory Habit.fromJson(Map<String, dynamic> json) {
    // Parse completion history with backward compatibility
    List<DateTime> parsedHistory = [];
    if (json['completionHistory'] != null) {
      final historyList = json['completionHistory'] as List<dynamic>;
      parsedHistory = historyList
          .map((dateStr) => DateTime.parse(dateStr as String))
          .toList();
    }

    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      identity: json['identity'] as String,
      tinyVersion: json['tinyVersion'] as String,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastCompletedDate: json['lastCompletedDate'] != null
          ? DateTime.parse(json['lastCompletedDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completionHistory: parsedHistory,
      implementationTime: json['implementationTime'] as String? ?? '09:00',
      implementationLocation: json['implementationLocation'] as String? ?? '',
      // Environment/attraction fields - safe to be null (backward compatible)
      temptationBundle: json['temptationBundle'] as String?,
      preHabitRitual: json['preHabitRitual'] as String?,
      environmentCue: json['environmentCue'] as String?,
      environmentDistraction: json['environmentDistraction'] as String?,
    );
  }

  // ========== Analytics Helper Methods ==========

  /// Check if habit was completed on a specific date
  bool wasCompletedOn(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return completionHistory.any((completedDate) {
      final completed = DateTime(
        completedDate.year,
        completedDate.month,
        completedDate.day,
      );
      return completed == targetDate;
    });
  }

  /// Get completion count for a date range
  int getCompletionCount({DateTime? startDate, DateTime? endDate}) {
    if (completionHistory.isEmpty) return 0;

    return completionHistory.where((date) {
      if (startDate != null && date.isBefore(startDate)) return false;
      if (endDate != null && date.isAfter(endDate)) return false;
      return true;
    }).length;
  }

  /// Get completion rate as percentage (0.0 to 1.0)
  /// Calculates based on days since habit creation
  double get completionRate {
    if (completionHistory.isEmpty) return 0.0;

    final now = DateTime.now();
    final daysSinceCreation = now.difference(createdAt).inDays + 1;
    if (daysSinceCreation <= 0) return 0.0;

    // Count unique completed days
    final uniqueDays = completionHistory
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .length;

    return (uniqueDays / daysSinceCreation).clamp(0.0, 1.0);
  }

  /// Get completion rate for the last N days
  double getCompletionRateForLastDays(int days) {
    if (completionHistory.isEmpty || days <= 0) return 0.0;

    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));

    int completedDays = 0;
    for (int i = 0; i < days; i++) {
      final checkDate = startDate.add(Duration(days: i));
      if (wasCompletedOn(checkDate)) {
        completedDays++;
      }
    }

    return completedDays / days;
  }

  /// Get weekly completion rate (last 7 days)
  double get weeklyCompletionRate => getCompletionRateForLastDays(7);

  /// Get monthly completion rate (last 30 days)
  double get monthlyCompletionRate => getCompletionRateForLastDays(30);

  /// Get all completion dates in a date range (for calendar view)
  List<DateTime> getCompletionsInRange(DateTime startDate, DateTime endDate) {
    return completionHistory.where((date) {
      return !date.isBefore(startDate) && !date.isAfter(endDate);
    }).toList()
      ..sort();
  }

  /// Get the total number of completions
  int get totalCompletions => completionHistory.length;
}
