/// Represents the user's profile and identity
/// Based on Atomic Habits identity-based approach
class UserProfile {
  final String identity; // "I am a person who..."
  final String name;
  final DateTime createdAt;

  // Contact information for alternative reminder channels
  final String? email;
  final String? phone;

  // Reminder channel preferences
  final bool emailRemindersEnabled;
  final bool smsRemindersEnabled;

  UserProfile({
    required this.identity,
    required this.name,
    required this.createdAt,
    this.email,
    this.phone,
    this.emailRemindersEnabled = false,
    this.smsRemindersEnabled = false,
  });

  /// Converts profile to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'identity': identity,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'email': email,
      'phone': phone,
      'emailRemindersEnabled': emailRemindersEnabled,
      'smsRemindersEnabled': smsRemindersEnabled,
    };
  }

  /// Creates profile from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      identity: json['identity'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      emailRemindersEnabled: json['emailRemindersEnabled'] as bool? ?? false,
      smsRemindersEnabled: json['smsRemindersEnabled'] as bool? ?? false,
    );
  }

  /// Creates a copy with updated fields
  UserProfile copyWith({
    String? identity,
    String? name,
    String? email,
    String? phone,
    bool? emailRemindersEnabled,
    bool? smsRemindersEnabled,
  }) {
    return UserProfile(
      identity: identity ?? this.identity,
      name: name ?? this.name,
      createdAt: createdAt,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      emailRemindersEnabled: emailRemindersEnabled ?? this.emailRemindersEnabled,
      smsRemindersEnabled: smsRemindersEnabled ?? this.smsRemindersEnabled,
    );
  }

  /// Check if email is valid format
  bool get hasValidEmail {
    if (email == null || email!.isEmpty) return false;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email!);
  }

  /// Check if phone is valid format (basic check)
  bool get hasValidPhone {
    if (phone == null || phone!.isEmpty) return false;
    // Basic phone validation - at least 10 digits
    final digitsOnly = phone!.replaceAll(RegExp(r'[^\d]'), '');
    return digitsOnly.length >= 10;
  }
}
