/// Represents a Habit Circle - a small group with shared habits
/// Based on the Social & Norms Layer from Atomic Habits
/// Inspired by the Mozambique model with local champions/guides
class HabitCircle {
  final String id;
  final String name; // e.g., "Morning Runners", "Book Club"
  final String description;
  final DateTime createdAt;

  // Members of the circle
  final List<CircleMember> members;

  // Shared habits that this circle tracks together
  final List<String> sharedHabitIds;

  // Norm message - what this group does (social proof)
  // e.g., "Around here, we walk after lunch"
  final String? normMessage;

  // Local champion/guide for this circle
  final String? championId; // User ID of the guide
  final String? championName;

  // Check-in settings
  final CheckInFrequency checkInFrequency;
  final DateTime? lastCheckIn;

  // Simple group stats for norm messaging
  final int totalCompletionsThisWeek;
  final double averageStreakDays;

  HabitCircle({
    required this.id,
    required this.name,
    this.description = '',
    required this.createdAt,
    this.members = const [],
    this.sharedHabitIds = const [],
    this.normMessage,
    this.championId,
    this.championName,
    this.checkInFrequency = CheckInFrequency.weekly,
    this.lastCheckIn,
    this.totalCompletionsThisWeek = 0,
    this.averageStreakDays = 0,
  });

  HabitCircle copyWith({
    String? name,
    String? description,
    List<CircleMember>? members,
    List<String>? sharedHabitIds,
    String? normMessage,
    String? championId,
    String? championName,
    CheckInFrequency? checkInFrequency,
    DateTime? lastCheckIn,
    int? totalCompletionsThisWeek,
    double? averageStreakDays,
  }) {
    return HabitCircle(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt,
      members: members ?? this.members,
      sharedHabitIds: sharedHabitIds ?? this.sharedHabitIds,
      normMessage: normMessage ?? this.normMessage,
      championId: championId ?? this.championId,
      championName: championName ?? this.championName,
      checkInFrequency: checkInFrequency ?? this.checkInFrequency,
      lastCheckIn: lastCheckIn ?? this.lastCheckIn,
      totalCompletionsThisWeek: totalCompletionsThisWeek ?? this.totalCompletionsThisWeek,
      averageStreakDays: averageStreakDays ?? this.averageStreakDays,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'members': members.map((m) => m.toJson()).toList(),
    'sharedHabitIds': sharedHabitIds,
    'normMessage': normMessage,
    'championId': championId,
    'championName': championName,
    'checkInFrequency': checkInFrequency.name,
    'lastCheckIn': lastCheckIn?.toIso8601String(),
    'totalCompletionsThisWeek': totalCompletionsThisWeek,
    'averageStreakDays': averageStreakDays,
  };

  factory HabitCircle.fromJson(Map<String, dynamic> json) => HabitCircle(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    createdAt: DateTime.parse(json['createdAt'] as String),
    members: (json['members'] as List<dynamic>?)
        ?.map((m) => CircleMember.fromJson(m as Map<String, dynamic>))
        .toList() ?? [],
    sharedHabitIds: (json['sharedHabitIds'] as List<dynamic>?)
        ?.map((s) => s as String)
        .toList() ?? [],
    normMessage: json['normMessage'] as String?,
    championId: json['championId'] as String?,
    championName: json['championName'] as String?,
    checkInFrequency: CheckInFrequency.values.firstWhere(
      (e) => e.name == json['checkInFrequency'],
      orElse: () => CheckInFrequency.weekly,
    ),
    lastCheckIn: json['lastCheckIn'] != null
        ? DateTime.parse(json['lastCheckIn'] as String)
        : null,
    totalCompletionsThisWeek: json['totalCompletionsThisWeek'] as int? ?? 0,
    averageStreakDays: (json['averageStreakDays'] as num?)?.toDouble() ?? 0,
  );

  /// Generate a norm message based on circle stats
  String get generatedNormMessage {
    if (normMessage != null && normMessage!.isNotEmpty) {
      return normMessage!;
    }

    if (members.isEmpty) return 'Join a circle to see group progress!';

    final activeMembers = members.where((m) => m.isActive).length;
    if (totalCompletionsThisWeek > 0) {
      return 'This week, $activeMembers members logged $totalCompletionsThisWeek completions';
    }

    return 'Around here, we support each other\'s habits';
  }

  /// Check if user is the champion
  bool isChampion(String userId) => championId == userId;

  /// Get member count
  int get memberCount => members.length;

  /// Get active member count (completed habit this week)
  int get activeMemberCount => members.where((m) => m.isActive).length;
}

/// A member of a habit circle
class CircleMember {
  final String id;
  final String name;
  final DateTime joinedAt;
  final int currentStreak; // Their streak for the shared habit
  final bool isActive; // Has completed habit this week
  final DateTime? lastCompletedDate;

  CircleMember({
    required this.id,
    required this.name,
    required this.joinedAt,
    this.currentStreak = 0,
    this.isActive = false,
    this.lastCompletedDate,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'joinedAt': joinedAt.toIso8601String(),
    'currentStreak': currentStreak,
    'isActive': isActive,
    'lastCompletedDate': lastCompletedDate?.toIso8601String(),
  };

  factory CircleMember.fromJson(Map<String, dynamic> json) => CircleMember(
    id: json['id'] as String,
    name: json['name'] as String,
    joinedAt: DateTime.parse(json['joinedAt'] as String),
    currentStreak: json['currentStreak'] as int? ?? 0,
    isActive: json['isActive'] as bool? ?? false,
    lastCompletedDate: json['lastCompletedDate'] != null
        ? DateTime.parse(json['lastCompletedDate'] as String)
        : null,
  );

  CircleMember copyWith({
    String? name,
    int? currentStreak,
    bool? isActive,
    DateTime? lastCompletedDate,
  }) => CircleMember(
    id: id,
    name: name ?? this.name,
    joinedAt: joinedAt,
    currentStreak: currentStreak ?? this.currentStreak,
    isActive: isActive ?? this.isActive,
    lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
  );
}

/// How often the circle checks in together
enum CheckInFrequency {
  daily,
  weekly,
  biweekly,
  monthly,
}

/// Extension for check-in frequency display
extension CheckInFrequencyExtension on CheckInFrequency {
  String get displayName {
    switch (this) {
      case CheckInFrequency.daily:
        return 'Daily';
      case CheckInFrequency.weekly:
        return 'Weekly';
      case CheckInFrequency.biweekly:
        return 'Every 2 weeks';
      case CheckInFrequency.monthly:
        return 'Monthly';
    }
  }
}
