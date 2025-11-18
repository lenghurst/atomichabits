/// Celebration style determines how completion feedback is presented
enum CelebrationStyle {
  /// Soft feedback, no haptics - ideal for quiet/bedtime habits
  calm,

  /// Gentle animation and light haptic - balanced approach
  standard,

  /// More noticeable animation and feedback - energetic habits
  lively,
}

/// Represents the user's profile and identity
/// Based on Atomic Habits identity-based approach
class UserProfile {
  final String identity; // "I am a person who..."
  final String name;
  final DateTime createdAt;
  final CelebrationStyle celebrationStyle; // How to celebrate completions

  UserProfile({
    required this.identity,
    required this.name,
    required this.createdAt,
    this.celebrationStyle = CelebrationStyle.standard, // Default to standard
  });

  /// Converts profile to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'identity': identity,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'celebrationStyle': celebrationStyle.name, // Store as string (calm/standard/lively)
    };
  }

  /// Creates profile from JSON
  /// Backwards compatible - defaults to standard if field missing
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // Parse celebration style with backwards compatibility
    CelebrationStyle style = CelebrationStyle.standard;
    if (json.containsKey('celebrationStyle')) {
      final styleStr = json['celebrationStyle'] as String?;
      if (styleStr != null) {
        try {
          style = CelebrationStyle.values.firstWhere(
            (e) => e.name == styleStr,
            orElse: () => CelebrationStyle.standard,
          );
        } catch (e) {
          // If parsing fails, default to standard
          style = CelebrationStyle.standard;
        }
      }
    }

    return UserProfile(
      identity: json['identity'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      celebrationStyle: style,
    );
  }

  /// Creates a copy with updated fields
  UserProfile copyWith({
    String? identity,
    String? name,
    CelebrationStyle? celebrationStyle,
  }) {
    return UserProfile(
      identity: identity ?? this.identity,
      name: name ?? this.name,
      createdAt: createdAt,
      celebrationStyle: celebrationStyle ?? this.celebrationStyle,
    );
  }
}
