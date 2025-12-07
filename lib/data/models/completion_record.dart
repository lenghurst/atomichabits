/// Represents a single day's completion record for a habit
/// Supports rich context beyond just "done/not done"
/// Aligns with Atomic Habits: understanding "why" is key to improvement
class CompletionRecord {
  /// The date this record is for (normalized to midnight)
  final DateTime date;

  /// Whether the habit was completed on this day
  final bool completed;

  /// Optional reflection note (for completed days)
  /// e.g., "Felt great after!", "Did the tiny version"
  final String? note;

  /// What got in the way? (for missed days)
  /// This is the key differentiator - helps identify patterns
  /// e.g., "Late work meeting", "Felt tired", "Traveled"
  final String? obstacle;

  /// Optional mood rating (1-5)
  /// 1 = Very Low, 2 = Low, 3 = Neutral, 4 = Good, 5 = Great
  final int? mood;

  /// When this record was created/updated
  final DateTime timestamp;

  CompletionRecord({
    required this.date,
    required this.completed,
    this.note,
    this.obstacle,
    this.mood,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Creates a copy with updated fields
  CompletionRecord copyWith({
    bool? completed,
    String? note,
    String? obstacle,
    int? mood,
  }) {
    return CompletionRecord(
      date: date,
      completed: completed ?? this.completed,
      note: note ?? this.note,
      obstacle: obstacle ?? this.obstacle,
      mood: mood ?? this.mood,
      timestamp: DateTime.now(), // Update timestamp on modification
    );
  }

  /// Normalize date to midnight for consistent comparison
  static DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'completed': completed,
      'note': note,
      'obstacle': obstacle,
      'mood': mood,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create from JSON
  factory CompletionRecord.fromJson(Map<String, dynamic> json) {
    return CompletionRecord(
      date: DateTime.parse(json['date'] as String),
      completed: json['completed'] as bool,
      note: json['note'] as String?,
      obstacle: json['obstacle'] as String?,
      mood: json['mood'] as int?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  /// Common obstacles for quick selection (Atomic Habits aligned)
  static const List<String> commonObstacles = [
    'Too tired',
    'Not enough time',
    'Forgot',
    'Traveling',
    'Sick',
    'Work emergency',
    'Social event',
    'Bad mood',
    'Environment not set up',
    'Other priorities',
  ];

  /// Mood labels for display
  static const Map<int, String> moodLabels = {
    1: 'Struggling',
    2: 'Low Energy',
    3: 'Neutral',
    4: 'Good',
    5: 'Great',
  };

  /// Mood emojis for visual display
  static const Map<int, String> moodEmojis = {
    1: '😔',
    2: '😕',
    3: '😐',
    4: '🙂',
    5: '😊',
  };
}
