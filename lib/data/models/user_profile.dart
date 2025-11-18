/// Represents the user's profile and identity
/// Based on Atomic Habits identity-based approach
class UserProfile {
  final String identity; // "I am a person who..."
  final String name;
  final DateTime createdAt;

  // Phase 4: Identity Avatar & Cosmetic Progression
  final bool avatarEnabled; // Optional visual avatar (default: false for minimalism)
  final List<String> unlockedCosmeticsIds; // IDs of unlocked cosmetics
  final Map<String, String> equippedCosmetics; // category → cosmetic id

  UserProfile({
    required this.identity,
    required this.name,
    required this.createdAt,
    this.avatarEnabled = false,
    this.unlockedCosmeticsIds = const [],
    this.equippedCosmetics = const {},
  });

  /// Converts profile to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'identity': identity,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      // Phase 4: Avatar fields (always write for backwards compat)
      'avatarEnabled': avatarEnabled,
      'unlockedCosmeticsIds': unlockedCosmeticsIds,
      'equippedCosmetics': equippedCosmetics,
    };
  }

  /// Creates profile from JSON
  /// Handles backward compatibility - new avatar fields default if missing
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      identity: json['identity'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      // Phase 4: Avatar fields with safe defaults for old profiles
      avatarEnabled: json['avatarEnabled'] as bool? ?? false,
      unlockedCosmeticsIds: json['unlockedCosmeticsIds'] != null
          ? List<String>.from(json['unlockedCosmeticsIds'] as List)
          : [],
      equippedCosmetics: json['equippedCosmetics'] != null
          ? Map<String, String>.from(json['equippedCosmetics'] as Map)
          : {},
    );
  }

  /// Creates a copy with updated fields
  UserProfile copyWith({
    String? identity,
    String? name,
    bool? avatarEnabled,
    List<String>? unlockedCosmeticsIds,
    Map<String, String>? equippedCosmetics,
  }) {
    return UserProfile(
      identity: identity ?? this.identity,
      name: name ?? this.name,
      createdAt: createdAt,
      avatarEnabled: avatarEnabled ?? this.avatarEnabled,
      unlockedCosmeticsIds: unlockedCosmeticsIds ?? this.unlockedCosmeticsIds,
      equippedCosmetics: equippedCosmetics ?? this.equippedCosmetics,
    );
  }
}
