import 'completion_record.dart';

/// User preferences for app customization
/// Stores personalization settings that persist across sessions
class UserPreferences {
  /// Selected mood emoji preset name
  /// Options: 'default', 'expressive', 'simple', 'energy', 'nature', 'hearts'
  final String moodEmojiPreset;

  /// Custom mood emojis (if user wants fully custom)
  /// Map of mood level (1-5) to emoji string
  final Map<int, String>? customMoodEmojis;

  /// Whether to show AI coaching tips after selecting obstacles
  final bool showAiCoaching;

  /// Whether to prompt for reflection after completing a habit
  final bool promptForReflection;

  /// Whether voice input is enabled for notes
  final bool voiceInputEnabled;

  UserPreferences({
    this.moodEmojiPreset = 'default',
    this.customMoodEmojis,
    this.showAiCoaching = true,
    this.promptForReflection = false,
    this.voiceInputEnabled = false,
  });

  /// Get the active mood emojis based on preferences
  Map<int, String> get activeMoodEmojis {
    if (customMoodEmojis != null && customMoodEmojis!.isNotEmpty) {
      return customMoodEmojis!;
    }
    return CompletionRecord.moodEmojiPresets[moodEmojiPreset] ??
        CompletionRecord.defaultMoodEmojis;
  }

  /// Creates a copy with updated fields
  UserPreferences copyWith({
    String? moodEmojiPreset,
    Map<int, String>? customMoodEmojis,
    bool? showAiCoaching,
    bool? promptForReflection,
    bool? voiceInputEnabled,
  }) {
    return UserPreferences(
      moodEmojiPreset: moodEmojiPreset ?? this.moodEmojiPreset,
      customMoodEmojis: customMoodEmojis ?? this.customMoodEmojis,
      showAiCoaching: showAiCoaching ?? this.showAiCoaching,
      promptForReflection: promptForReflection ?? this.promptForReflection,
      voiceInputEnabled: voiceInputEnabled ?? this.voiceInputEnabled,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'moodEmojiPreset': moodEmojiPreset,
      'customMoodEmojis': customMoodEmojis?.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      'showAiCoaching': showAiCoaching,
      'promptForReflection': promptForReflection,
      'voiceInputEnabled': voiceInputEnabled,
    };
  }

  /// Create from JSON
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    Map<int, String>? customEmojis;
    if (json['customMoodEmojis'] != null) {
      final raw = json['customMoodEmojis'] as Map<String, dynamic>;
      customEmojis = raw.map(
        (key, value) => MapEntry(int.parse(key), value as String),
      );
    }

    return UserPreferences(
      moodEmojiPreset: json['moodEmojiPreset'] as String? ?? 'default',
      customMoodEmojis: customEmojis,
      showAiCoaching: json['showAiCoaching'] as bool? ?? true,
      promptForReflection: json['promptForReflection'] as bool? ?? false,
      voiceInputEnabled: json['voiceInputEnabled'] as bool? ?? false,
    );
  }

  /// Get emoji preset display name
  static String getPresetDisplayName(String preset) {
    switch (preset) {
      case 'default':
        return 'Classic';
      case 'expressive':
        return 'Expressive';
      case 'simple':
        return 'Thumbs';
      case 'energy':
        return 'Energy';
      case 'nature':
        return 'Weather';
      case 'hearts':
        return 'Hearts';
      default:
        return 'Classic';
    }
  }
}
