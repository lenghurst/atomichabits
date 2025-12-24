/// Represents the user's profile and identity
/// Based on Atomic Habits identity-based approach
class UserProfile {
  final String identity; // "I am a person who..."
  final String name;
  final String? witnessName; // Added for Phase 33
  final String? witnessContact; // Added for Phase 33
  final DateTime createdAt;

  UserProfile({
    required this.identity,
    required this.name,
    this.witnessName,
    this.witnessContact,
    required this.createdAt,
  });

  /// Converts profile to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'identity': identity,
      'name': name,
      'witnessName': witnessName, // Persist witness name
      'witnessContact': witnessContact,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Creates profile from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      identity: json['identity'] as String,
      name: json['name'] as String,
      witnessName: json['witnessName'] as String?, // Load witness name
      witnessContact: json['witnessContact'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Creates a copy with updated fields
  UserProfile copyWith({
    String? identity,
    String? name,
    String? witnessName,
    String? witnessContact,
  }) {
    return UserProfile(
      identity: identity ?? this.identity,
      name: name ?? this.name,
      witnessName: witnessName ?? this.witnessName,
      witnessContact: witnessContact ?? this.witnessContact,
      createdAt: createdAt,
    );
  }
}
