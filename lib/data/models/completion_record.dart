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

  /// Emoji representing the obstacle category (visual quick-select)
  final String? obstacleEmoji;

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
    this.obstacleEmoji,
    this.mood,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Creates a copy with updated fields
  CompletionRecord copyWith({
    bool? completed,
    String? note,
    String? obstacle,
    String? obstacleEmoji,
    int? mood,
  }) {
    return CompletionRecord(
      date: date,
      completed: completed ?? this.completed,
      note: note ?? this.note,
      obstacle: obstacle ?? this.obstacle,
      obstacleEmoji: obstacleEmoji ?? this.obstacleEmoji,
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
      'obstacleEmoji': obstacleEmoji,
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
      obstacleEmoji: json['obstacleEmoji'] as String?,
      mood: json['mood'] as int?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  /// Emoji-based obstacle categories for quick visual selection
  /// Each has an emoji, label, and optional AI coaching tip
  static const List<ObstacleOption> obstacleOptions = [
    ObstacleOption(
      emoji: '😴',
      label: 'Too tired',
      category: 'energy',
      aiTip: 'Consider doing your habit earlier in the day when energy is higher, or try the 2-minute version.',
    ),
    ObstacleOption(
      emoji: '⏰',
      label: 'No time',
      category: 'time',
      aiTip: 'Stack this habit with something you already do. "After I [existing habit], I will [new habit]."',
    ),
    ObstacleOption(
      emoji: '🤯',
      label: 'Forgot',
      category: 'memory',
      aiTip: 'Make it obvious: set a visual cue in your environment or a phone reminder.',
    ),
    ObstacleOption(
      emoji: '😤',
      label: 'Frustrated',
      category: 'emotion',
      aiTip: 'Negative emotions often hijack habits. Try a 10-second pre-habit ritual to reset your mindset.',
    ),
    ObstacleOption(
      emoji: '😰',
      label: 'Stressed',
      category: 'emotion',
      aiTip: 'Stress depletes willpower. Consider making your habit even smaller on tough days.',
    ),
    ObstacleOption(
      emoji: '🤒',
      label: 'Sick',
      category: 'health',
      aiTip: 'Health comes first. A rest day is not a failure—it\'s recovery.',
    ),
    ObstacleOption(
      emoji: '✈️',
      label: 'Traveling',
      category: 'location',
      aiTip: 'Plan a travel-friendly version of your habit before your next trip.',
    ),
    ObstacleOption(
      emoji: '💼',
      label: 'Work crisis',
      category: 'work',
      aiTip: 'Work emergencies happen. The key is getting back on track tomorrow.',
    ),
    ObstacleOption(
      emoji: '🎉',
      label: 'Social event',
      category: 'social',
      aiTip: 'Social obligations are valuable too. Can you do a micro-version before the event?',
    ),
    ObstacleOption(
      emoji: '📱',
      label: 'Distracted',
      category: 'environment',
      aiTip: 'Remove friction: put distractions out of sight and your habit tools in plain view.',
    ),
    ObstacleOption(
      emoji: '😔',
      label: 'Low mood',
      category: 'emotion',
      aiTip: 'On low days, just showing up counts. Even 1 minute reinforces your identity.',
    ),
    ObstacleOption(
      emoji: '🤷',
      label: 'Just didn\'t',
      category: 'motivation',
      aiTip: 'Motivation follows action, not the other way around. Start with just 2 minutes.',
    ),
  ];

  /// Get obstacle option by emoji
  static ObstacleOption? getObstacleByEmoji(String emoji) {
    return obstacleOptions.where((o) => o.emoji == emoji).firstOrNull;
  }

  /// Legacy text-based obstacles (for backward compatibility)
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

  /// Default mood emojis for visual display
  static const Map<int, String> defaultMoodEmojis = {
    1: '😔',
    2: '😕',
    3: '😐',
    4: '🙂',
    5: '😊',
  };

  /// Mood emojis - use default, users can customize in settings
  static Map<int, String> moodEmojis = Map.from(defaultMoodEmojis);

  /// Alternative emoji sets users can choose from
  static const Map<String, Map<int, String>> moodEmojiPresets = {
    'default': {1: '😔', 2: '😕', 3: '😐', 4: '🙂', 5: '😊'},
    'expressive': {1: '😭', 2: '😢', 3: '😌', 4: '😃', 5: '🤩'},
    'simple': {1: '👎', 2: '👇', 3: '👉', 4: '👆', 5: '👍'},
    'energy': {1: '🪫', 2: '🔋', 3: '⚡', 4: '🔥', 5: '💥'},
    'nature': {1: '🌧️', 2: '☁️', 3: '⛅', 4: '🌤️', 5: '☀️'},
    'hearts': {1: '🖤', 2: '🩶', 3: '🤍', 4: '💗', 5: '❤️'},
  };
}

/// Structured obstacle option with emoji, label, and AI coaching
class ObstacleOption {
  final String emoji;
  final String label;
  final String category;
  final String aiTip;

  const ObstacleOption({
    required this.emoji,
    required this.label,
    required this.category,
    required this.aiTip,
  });
}
