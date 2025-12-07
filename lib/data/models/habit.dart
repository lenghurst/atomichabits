import 'completion_record.dart';

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
  // Key insight: tracks not just completions but also WHY days were missed
  final List<CompletionRecord> completionHistory;

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
    List<CompletionRecord>? completionHistory,
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
    List<CompletionRecord>? completionHistory,
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
      createdAt: createdAt,
      completionHistory: completionHistory ?? this.completionHistory,
      implementationTime: implementationTime ?? this.implementationTime,
      implementationLocation: implementationLocation ?? this.implementationLocation,
      temptationBundle: temptationBundle ?? this.temptationBundle,
      preHabitRitual: preHabitRitual ?? this.preHabitRitual,
      environmentCue: environmentCue ?? this.environmentCue,
      environmentDistraction: environmentDistraction ?? this.environmentDistraction,
    );
  }

  // ========== Completion History Query Methods ==========

  /// Get completion record for a specific date
  CompletionRecord? getRecordForDate(DateTime date) {
    final normalized = CompletionRecord.normalizeDate(date);
    return completionHistory.where((r) =>
      CompletionRecord.normalizeDate(r.date) == normalized
    ).firstOrNull;
  }

  /// Check if habit was completed on a specific date
  bool wasCompletedOn(DateTime date) {
    final record = getRecordForDate(date);
    return record?.completed ?? false;
  }

  /// Check if there's any record (completed or missed) for a date
  bool hasRecordFor(DateTime date) {
    return getRecordForDate(date) != null;
  }

  /// Get all completed dates (for calendar visualization)
  List<DateTime> get completedDates {
    return completionHistory
        .where((r) => r.completed)
        .map((r) => CompletionRecord.normalizeDate(r.date))
        .toList();
  }

  /// Get all missed dates (dates with explicit "not completed" records)
  List<DateTime> get missedDates {
    return completionHistory
        .where((r) => !r.completed)
        .map((r) => CompletionRecord.normalizeDate(r.date))
        .toList();
  }

  /// Get completion count for a date range
  int completionCountInRange(DateTime start, DateTime end) {
    final startNorm = CompletionRecord.normalizeDate(start);
    final endNorm = CompletionRecord.normalizeDate(end);
    return completionHistory.where((r) {
      final date = CompletionRecord.normalizeDate(r.date);
      return r.completed &&
             (date.isAfter(startNorm) || date == startNorm) &&
             (date.isBefore(endNorm) || date == endNorm);
    }).length;
  }

  /// Get completion rate for a date range (0.0 to 1.0)
  double completionRateInRange(DateTime start, DateTime end) {
    final startNorm = CompletionRecord.normalizeDate(start);
    final endNorm = CompletionRecord.normalizeDate(end);
    final totalDays = endNorm.difference(startNorm).inDays + 1;
    if (totalDays <= 0) return 0.0;
    return completionCountInRange(start, end) / totalDays;
  }

  /// Get most common obstacles (for pattern analysis)
  Map<String, int> get obstacleFrequency {
    final obstacles = <String, int>{};
    for (final record in completionHistory) {
      if (!record.completed && record.obstacle != null) {
        obstacles[record.obstacle!] = (obstacles[record.obstacle!] ?? 0) + 1;
      }
    }
    return obstacles;
  }

  /// Get average mood when completing habit
  double? get averageCompletionMood {
    final moods = completionHistory
        .where((r) => r.completed && r.mood != null)
        .map((r) => r.mood!)
        .toList();
    if (moods.isEmpty) return null;
    return moods.reduce((a, b) => a + b) / moods.length;
  }

  /// Total number of completions ever
  int get totalCompletions {
    return completionHistory.where((r) => r.completed).length;
  }

  /// Days since habit was created
  int get daysSinceCreated {
    return DateTime.now().difference(createdAt).inDays;
  }

  /// Overall completion rate since habit creation
  double get overallCompletionRate {
    final days = daysSinceCreated;
    if (days <= 0) return 0.0;
    return totalCompletions / days;
  }

  // ========== Streak Milestone Methods ==========

  /// Check if current streak hits a milestone
  /// Milestones: 7, 14, 21, 30, 50, 66, 100, then every 100
  static bool isStreakMilestone(int streak) {
    const milestones = [7, 14, 21, 30, 50, 66, 100];
    if (milestones.contains(streak)) return true;
    if (streak > 100 && streak % 100 == 0) return true;
    return false;
  }

  /// Get milestone message for current streak
  static String? getMilestoneMessage(int streak) {
    switch (streak) {
      case 7:
        return "1 Week! You're building momentum.";
      case 14:
        return "2 Weeks! The habit is taking root.";
      case 21:
        return "21 Days! You've proven commitment.";
      case 30:
        return "1 Month! This is becoming part of you.";
      case 50:
        return "50 Days! You're in the top tier.";
      case 66:
        return "66 Days! Science says it's automatic now.";
      case 100:
        return "100 Days! Legendary status achieved.";
      default:
        if (streak > 100 && streak % 100 == 0) {
          return "$streak Days! Unstoppable.";
        }
        return null;
    }
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
      'completionHistory': completionHistory.map((r) => r.toJson()).toList(),
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
  /// Handles backward compatibility - new fields default to null if missing
  factory Habit.fromJson(Map<String, dynamic> json) {
    // Parse completion history if present
    List<CompletionRecord> history = [];
    if (json['completionHistory'] != null) {
      history = (json['completionHistory'] as List<dynamic>)
          .map((r) => CompletionRecord.fromJson(Map<String, dynamic>.from(r)))
          .toList();
    }

    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      identity: json['identity'] as String,
      tinyVersion: json['tinyVersion'] as String,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? json['currentStreak'] as int? ?? 0,
      lastCompletedDate: json['lastCompletedDate'] != null
          ? DateTime.parse(json['lastCompletedDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completionHistory: history,
      implementationTime: json['implementationTime'] as String? ?? '09:00',
      implementationLocation: json['implementationLocation'] as String? ?? '',
      // New fields - safe to be null (backward compatible)
      temptationBundle: json['temptationBundle'] as String?,
      preHabitRitual: json['preHabitRitual'] as String?,
      environmentCue: json['environmentCue'] as String?,
      environmentDistraction: json['environmentDistraction'] as String?,
    );
  }
}
