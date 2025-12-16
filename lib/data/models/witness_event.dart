/// Witness Event Model
/// 
/// Phase 22: "The Witness" - Social Accountability Loop
/// 
/// Represents real-time events in the accountability relationship:
/// - Builder completes habit -> Witness gets notified
/// - Witness sends high-five -> Builder gets dopamine hit
/// - Builder is drifting -> Witness can nudge before failure
/// 
/// This transforms the app from Single Player (Tool) to Multiplayer (Network)

/// A real-time event in the witness relationship
class WitnessEvent {
  final String id;
  final String contractId;
  final WitnessEventType type;
  final String actorId;        // Who triggered the event
  final String targetId;       // Who should receive the event
  final String? habitId;
  final String? habitName;
  final String? identity;      // Builder's identity statement
  final String? message;       // Custom message (nudge text, etc.)
  final WitnessReaction? reaction;  // High-five emoji, etc.
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final bool isRead;           // Has the target seen this?
  
  const WitnessEvent({
    required this.id,
    required this.contractId,
    required this.type,
    required this.actorId,
    required this.targetId,
    this.habitId,
    this.habitName,
    this.identity,
    this.message,
    this.reaction,
    this.metadata,
    required this.createdAt,
    this.isRead = false,
  });
  
  /// Whether this event should show a push notification
  bool get shouldNotify {
    switch (type) {
      case WitnessEventType.habitCompleted:
      case WitnessEventType.streakMilestone:
      case WitnessEventType.highFiveReceived:
      case WitnessEventType.nudgeReceived:
      case WitnessEventType.driftWarning:
        return true;
      case WitnessEventType.contractAccepted:
      case WitnessEventType.witnessJoined:
        return true;
      case WitnessEventType.streakBroken:
      case WitnessEventType.contractCompleted:
        return true;
      default:
        return false;
    }
  }
  
  /// Get notification title for this event
  String get notificationTitle {
    switch (type) {
      case WitnessEventType.habitCompleted:
        return 'Vote Cast!';
      case WitnessEventType.streakMilestone:
        final streak = metadata?['streak'] ?? 0;
        return '$streak Day Streak!';
      case WitnessEventType.highFiveReceived:
        return 'High Five!';
      case WitnessEventType.nudgeReceived:
        return 'Nudge from Your Witness';
      case WitnessEventType.driftWarning:
        return 'Your Builder Needs You';
      case WitnessEventType.witnessJoined:
        return 'Witness Accepted!';
      case WitnessEventType.contractAccepted:
        return 'Contract Active!';
      case WitnessEventType.streakBroken:
        return 'Streak Ended';
      case WitnessEventType.contractCompleted:
        return 'Contract Complete!';
      default:
        return 'Activity';
    }
  }
  
  /// Get notification body for this event
  String get notificationBody {
    switch (type) {
      case WitnessEventType.habitCompleted:
        // The key copy: "just cast a vote for [Identity]!"
        return '$habitName just cast a vote for $identity!';
      case WitnessEventType.streakMilestone:
        final streak = metadata?['streak'] ?? 0;
        return '$habitName is on fire! $streak days strong.';
      case WitnessEventType.highFiveReceived:
        return '${reaction?.emoji ?? ""}  ${message ?? "Great job!"}';
      case WitnessEventType.nudgeReceived:
        return message ?? 'Your witness is checking in on you.';
      case WitnessEventType.driftWarning:
        return '$habitName is drifting on $habitId. Nudge them?';
      case WitnessEventType.witnessJoined:
        return 'Your accountability partner is ready!';
      case WitnessEventType.contractAccepted:
        return 'Your habit contract is now active. Let\'s go!';
      case WitnessEventType.streakBroken:
        return 'The streak ended, but the journey continues.';
      case WitnessEventType.contractCompleted:
        final rate = metadata?['completion_rate'] ?? 0;
        return 'Amazing! ${rate.toStringAsFixed(0)}% completion rate.';
      default:
        return message ?? '';
    }
  }
  
  /// Create from JSON (Supabase response)
  factory WitnessEvent.fromJson(Map<String, dynamic> json) {
    return WitnessEvent(
      id: json['id'] as String,
      contractId: json['contract_id'] as String,
      type: WitnessEventType.fromString(json['event_type'] as String),
      actorId: json['actor_id'] as String,
      targetId: json['target_id'] as String,
      habitId: json['habit_id'] as String?,
      habitName: json['habit_name'] as String?,
      identity: json['identity'] as String?,
      message: json['message'] as String?,
      reaction: json['reaction'] != null 
          ? WitnessReaction.fromJson(json['reaction'] as Map<String, dynamic>)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
    );
  }
  
  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contract_id': contractId,
      'event_type': type.name,
      'actor_id': actorId,
      'target_id': targetId,
      'habit_id': habitId,
      'habit_name': habitName,
      'identity': identity,
      'message': message,
      'reaction': reaction?.toJson(),
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
    };
  }
  
  WitnessEvent copyWith({
    String? id,
    String? contractId,
    WitnessEventType? type,
    String? actorId,
    String? targetId,
    String? habitId,
    String? habitName,
    String? identity,
    String? message,
    WitnessReaction? reaction,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return WitnessEvent(
      id: id ?? this.id,
      contractId: contractId ?? this.contractId,
      type: type ?? this.type,
      actorId: actorId ?? this.actorId,
      targetId: targetId ?? this.targetId,
      habitId: habitId ?? this.habitId,
      habitName: habitName ?? this.habitName,
      identity: identity ?? this.identity,
      message: message ?? this.message,
      reaction: reaction ?? this.reaction,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// Types of witness events
enum WitnessEventType {
  // Builder -> Witness notifications
  habitCompleted,      // "User A just cast a vote for [Identity]!"
  streakMilestone,     // 7-day, 21-day, 30-day milestones
  streakBroken,        // Streak ended (informational)
  
  // Witness -> Builder notifications
  highFiveReceived,    // Emoji reaction (second dopamine hit)
  nudgeReceived,       // "Your witness is checking in"
  
  // Witness "Shame Nudge" system (pre-miss)
  driftWarning,        // "[User] is drifting. Nudge them?"
  
  // Contract lifecycle
  witnessJoined,       // Witness accepted the invite
  contractAccepted,    // Contract is now active
  contractCompleted,   // Contract finished successfully
  contractBroken,      // Contract failed
  ;
  
  static WitnessEventType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'habit_completed':
      case 'habitcompleted':
        return WitnessEventType.habitCompleted;
      case 'streak_milestone':
      case 'streakmilestone':
        return WitnessEventType.streakMilestone;
      case 'streak_broken':
      case 'streakbroken':
        return WitnessEventType.streakBroken;
      case 'high_five_received':
      case 'highfivereceived':
        return WitnessEventType.highFiveReceived;
      case 'nudge_received':
      case 'nudgereceived':
        return WitnessEventType.nudgeReceived;
      case 'drift_warning':
      case 'driftwarning':
        return WitnessEventType.driftWarning;
      case 'witness_joined':
      case 'witnessjoined':
        return WitnessEventType.witnessJoined;
      case 'contract_accepted':
      case 'contractaccepted':
        return WitnessEventType.contractAccepted;
      case 'contract_completed':
      case 'contractcompleted':
        return WitnessEventType.contractCompleted;
      case 'contract_broken':
      case 'contractbroken':
        return WitnessEventType.contractBroken;
      default:
        return WitnessEventType.habitCompleted;
    }
  }
}

/// High-five emoji reactions
class WitnessReaction {
  final String emoji;
  final String? message;
  final DateTime sentAt;
  
  const WitnessReaction({
    required this.emoji,
    this.message,
    required this.sentAt,
  });
  
  /// Pre-defined high-five reactions
  static const List<WitnessReaction> quickReactions = [
    WitnessReaction(emoji: '🖐️', message: 'High five!', sentAt: DateTime(2024)),
    WitnessReaction(emoji: '🔥', message: 'On fire!', sentAt: DateTime(2024)),
    WitnessReaction(emoji: '💪', message: 'Keep it up!', sentAt: DateTime(2024)),
    WitnessReaction(emoji: '⚡', message: 'Crushing it!', sentAt: DateTime(2024)),
    WitnessReaction(emoji: '🏆', message: 'Champion!', sentAt: DateTime(2024)),
    WitnessReaction(emoji: '🎯', message: 'Bullseye!', sentAt: DateTime(2024)),
  ];
  
  /// Create a quick reaction by emoji
  factory WitnessReaction.quick(String emoji) {
    final preset = quickReactions.firstWhere(
      (r) => r.emoji == emoji,
      orElse: () => WitnessReaction(
        emoji: emoji,
        message: null,
        sentAt: DateTime.now(),
      ),
    );
    return WitnessReaction(
      emoji: preset.emoji,
      message: preset.message,
      sentAt: DateTime.now(),
    );
  }
  
  /// Create from JSON
  factory WitnessReaction.fromJson(Map<String, dynamic> json) {
    return WitnessReaction(
      emoji: json['emoji'] as String,
      message: json['message'] as String?,
      sentAt: DateTime.parse(json['sent_at'] as String),
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'message': message,
      'sent_at': sentAt.toIso8601String(),
    };
  }
}

/// Streak milestone definitions
class StreakMilestones {
  static const List<int> milestones = [7, 14, 21, 30, 60, 90, 180, 365];
  
  /// Check if a streak count is a milestone
  static bool isMilestone(int streak) {
    return milestones.contains(streak);
  }
  
  /// Get celebration message for milestone
  static String getMilestoneMessage(int streak) {
    switch (streak) {
      case 7:
        return 'One week strong! The habit is taking root.';
      case 14:
        return 'Two weeks! The neural pathways are forming.';
      case 21:
        return 'Three weeks! They say this is when habits stick.';
      case 30:
        return 'One month! You\'re proving who you are.';
      case 60:
        return 'Two months! This is becoming automatic.';
      case 90:
        return 'Three months! You\'ve built a new identity.';
      case 180:
        return 'Six months! Half a year of showing up.';
      case 365:
        return 'ONE YEAR! You\'ve transformed your life.';
      default:
        return '$streak days! Keep going!';
    }
  }
  
  /// Get emoji for milestone
  static String getMilestoneEmoji(int streak) {
    switch (streak) {
      case 7:
        return '🌱';
      case 14:
        return '🌿';
      case 21:
        return '🌳';
      case 30:
        return '⭐';
      case 60:
        return '🌟';
      case 90:
        return '💫';
      case 180:
        return '🏅';
      case 365:
        return '🏆';
      default:
        return '✨';
    }
  }
}
