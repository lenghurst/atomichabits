import 'dart:math';
import 'package:flutter/material.dart';

/// Habit Contract Model
/// 
/// Phase 16.2: Habit Contracts
/// Phase 21.3: Data Schema Enhancement - Nudge Effectiveness Tracking
/// 
/// Represents an accountability partnership between a Builder and a Witness.
/// The Builder commits to a habit, and the Witness holds them accountable.
/// 
/// Lifecycle:
/// 1. draft     - Builder is creating the contract
/// 2. pending   - Invite sent, waiting for witness to join
/// 3. active    - Witness joined, contract is running
/// 4. completed - Contract finished successfully
/// 5. broken    - Builder missed too many days
/// 6. cancelled - Manually cancelled by either party
/// 
/// Phase 21.3: Nudge Effectiveness Tracking
/// - lastNudgeSentAt: When the last nudge was sent
/// - lastNudgeResponseAt: When the builder completed after a nudge
/// - nudgesReceivedCount: Total nudges received
/// - nudgesRespondedCount: How many nudges led to completion
/// - nudgeEffectivenessRate: nudgesResponded / nudgesReceived
class HabitContract {
  final String id;
  final String builderId;
  final String? witnessId;  // null until witness joins
  final String habitId;
  
  // Invite mechanism
  final String inviteCode;
  final String? inviteUrl;
  
  // Contract terms
  final String title;
  final String? commitmentStatement;
  final int durationDays;
  final DateTime? startDate;
  final DateTime? endDate;
  
  // Status
  final ContractStatus status;
  
  // Success criteria
  final int minimumCompletionRate;
  final int gracePeriodDays;
  
  // Witness preferences
  final bool nudgeEnabled;
  final NudgeFrequency nudgeFrequency;
  final NudgeStyle nudgeStyle;
  
  // Progress tracking
  final int daysCompleted;
  final int daysMissed;
  final int currentStreak;
  final int longestStreak;
  
  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? inviteSentAt;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  
  // Messages
  final String? builderMessage;
  final String? witnessMessage;
  
  // Display fields (for witness accept screen)
  final String? builderDisplayName;
  final String? habitEmoji;
  
  String? get builderName => builderDisplayName ?? "The Builder";
  
  // Phase 4: Identity Privacy (Alternative Identity)
  // Allows user to use a different identity for specific pacts
  // to prevent forced disclosure of sensitive global identity.
  final String? alternativeIdentity;
  
  // Phase 21.3: Nudge Effectiveness Tracking
  // These fields enable building a "Behavior Model" by tracking
  // how nudges influence completion behavior
  final DateTime? lastNudgeSentAt;     // When witness last sent a nudge
  final DateTime? lastNudgeResponseAt; // When builder completed after nudge
  final int nudgesReceivedCount;       // Total nudges received
  final int nudgesRespondedCount;      // Nudges that led to completion
  
  // Phase 61: Safety by Design
  final bool sharePsychometrics;       // Explicit consent for psychometric data
  final bool allowNudges;              // Global nudge toggle
  
  // Nudge rate limiting (Fairness Algorithm)
  final Map<String, List<DateTime>> nudgeHistory;  // witnessId -> list of nudge times
  final TimeOfDay? nudgeQuietStart;               // Quiet hours start
  final TimeOfDay? nudgeQuietEnd;                 // Quiet hours end
  
  // Boundary controls
  final List<String> blockedWitnessIds;           // Users blocked by owner
  final bool allowEmergencyExit;                  // Can leave without penalty
  
  // Emergency override (admin use)
  final bool isUnderReview;                       // Flagged for admin review
  final DateTime? reportedAt;                     // When abuse was reported
  
  const HabitContract({
    required this.id,
    required this.builderId,
    this.witnessId,
    required this.habitId,
    required this.inviteCode,
    this.inviteUrl,
    required this.title,
    this.commitmentStatement,
    this.durationDays = 21,
    this.startDate,
    this.endDate,
    this.status = ContractStatus.draft,
    this.minimumCompletionRate = 80,
    this.gracePeriodDays = 2,
    this.nudgeEnabled = true,
    this.nudgeFrequency = NudgeFrequency.daily,
    this.nudgeStyle = NudgeStyle.encouraging,
    this.daysCompleted = 0,
    this.daysMissed = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    required this.createdAt,
    required this.updatedAt,
    this.inviteSentAt,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.builderMessage,
    this.witnessMessage,
    this.builderDisplayName,
    this.habitEmoji,
    // Phase 4 Privacy
    this.alternativeIdentity,
    // Phase 21.3: Nudge Effectiveness Tracking
    this.lastNudgeSentAt,
    this.lastNudgeResponseAt,
    this.nudgesReceivedCount = 0,
    this.nudgesRespondedCount = 0,
    // Safety Defaults
    this.sharePsychometrics = false,
    this.allowNudges = true,
    this.nudgeHistory = const {},
    this.nudgeQuietStart,
    this.nudgeQuietEnd,
    this.blockedWitnessIds = const [],
    this.allowEmergencyExit = true,
    this.isUnderReview = false,
    this.reportedAt,
  });
  
  /// Generate a unique invite code (8 characters, alphanumeric)
  static String generateInviteCode() {
    // Avoid ambiguous characters: I, O, 0, 1
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }
  
  /// Create a new draft contract
  factory HabitContract.draft({
    required String id,
    required String builderId,
    required String habitId,
    required String title,
    String? commitmentStatement,
    int durationDays = 21,
    String? builderMessage,
  }) {
    final now = DateTime.now();
    return HabitContract(
      id: id,
      builderId: builderId,
      habitId: habitId,
      inviteCode: generateInviteCode(),
      title: title,
      commitmentStatement: commitmentStatement,
      durationDays: durationDays,
      status: ContractStatus.draft,
      createdAt: now,
      updatedAt: now,
      builderMessage: builderMessage,
      sharePsychometrics: false,
      allowNudges: true,
      nudgeHistory: const {},
      blockedWitnessIds: const [],
      allowEmergencyExit: true,
      isUnderReview: false,
    );
  }
  
  /// Whether the contract is waiting for a witness
  bool get isAwaitingWitness => status == ContractStatus.pending && witnessId == null;
  
  /// Whether the contract is currently running
  bool get isActive => status == ContractStatus.active;
  
  /// Whether the contract can be edited
  bool get isEditable => status == ContractStatus.draft;
  
  /// Whether the contract can be shared
  bool get canShare => status == ContractStatus.draft || status == ContractStatus.pending;
  
  /// Phase 24: Deferred Witness (Self-Witnessing)
  bool get isSelfWitness => witnessId == builderId;
  
  bool get hasExternalWitness => witnessId != null && witnessId != builderId;
  
  /// Progress percentage (0-100)
  double get progressPercentage {
    if (durationDays == 0) return 0;
    final totalDays = daysCompleted + daysMissed;
    if (totalDays == 0) return 0;
    return (daysCompleted / totalDays) * 100;
  }
  
  /// Days remaining in contract
  int get daysRemaining {
    if (endDate == null) return durationDays;
    final remaining = endDate!.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }
  
  /// Current completion rate
  double get completionRate {
    final totalDays = daysCompleted + daysMissed;
    if (totalDays == 0) return 100;
    return (daysCompleted / totalDays) * 100;
  }
  
  /// Whether the contract is on track to succeed
  bool get isOnTrack => completionRate >= minimumCompletionRate;
  
  /// Phase 21.3: Nudge effectiveness rate (0-100)
  /// How often do nudges lead to habit completion?
  /// This metric feeds into the "Behavior Model" for 2026
  double get nudgeEffectivenessRate {
    if (nudgesReceivedCount == 0) return 0;
    return (nudgesRespondedCount / nudgesReceivedCount) * 100;
  }
  
  /// Whether the builder has received any nudges
  bool get hasReceivedNudges => nudgesReceivedCount > 0;
  
  /// Whether there's an open nudge (sent but not responded to)
  bool get hasOpenNudge {
    if (lastNudgeSentAt == null) return false;
    if (lastNudgeResponseAt == null) return true;
    return lastNudgeSentAt!.isAfter(lastNudgeResponseAt!);
  }
  
  /// Copy with new values
  HabitContract copyWith({
    String? id,
    String? builderId,
    String? witnessId,
    String? habitId,
    String? inviteCode,
    String? inviteUrl,
    String? title,
    String? commitmentStatement,
    int? durationDays,
    DateTime? startDate,
    DateTime? endDate,
    ContractStatus? status,
    int? minimumCompletionRate,
    int? gracePeriodDays,
    bool? nudgeEnabled,
    NudgeFrequency? nudgeFrequency,
    NudgeStyle? nudgeStyle,
    int? daysCompleted,
    int? daysMissed,
    int? currentStreak,
    int? longestStreak,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? inviteSentAt,
    DateTime? acceptedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    String? builderMessage,
    String? witnessMessage,
    String? builderDisplayName,
    String? habitEmoji,
    // Phase 4 Privacy
    String? alternativeIdentity,
    // Phase 21.3: Nudge Effectiveness Tracking
    DateTime? lastNudgeSentAt,
    DateTime? lastNudgeResponseAt,
    int? nudgesReceivedCount,
    int? nudgesRespondedCount,
    // Safety fields
    bool? sharePsychometrics,
    bool? allowNudges,
    Map<String, List<DateTime>>? nudgeHistory,
    TimeOfDay? nudgeQuietStart,
    TimeOfDay? nudgeQuietEnd,
    List<String>? blockedWitnessIds,
    bool? allowEmergencyExit,
    bool? isUnderReview,
    DateTime? reportedAt,
    // Special flags
    bool clearWitness = false,
  }) {
    return HabitContract(
      id: id ?? this.id,
      builderId: builderId ?? this.builderId,
      habitId: habitId ?? this.habitId,
      // If clearWitness is true, set to null. Otherwise use new val or keep existing.
      witnessId: clearWitness ? null : (witnessId ?? this.witnessId),
      inviteCode: inviteCode ?? this.inviteCode,
      inviteUrl: inviteUrl ?? this.inviteUrl,
      title: title ?? this.title,
      commitmentStatement: commitmentStatement ?? this.commitmentStatement,
      durationDays: durationDays ?? this.durationDays,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      minimumCompletionRate: minimumCompletionRate ?? this.minimumCompletionRate,
      gracePeriodDays: gracePeriodDays ?? this.gracePeriodDays,
      nudgeEnabled: nudgeEnabled ?? this.nudgeEnabled,
      nudgeFrequency: nudgeFrequency ?? this.nudgeFrequency,
      nudgeStyle: nudgeStyle ?? this.nudgeStyle,
      daysCompleted: daysCompleted ?? this.daysCompleted,
      daysMissed: daysMissed ?? this.daysMissed,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      inviteSentAt: inviteSentAt ?? this.inviteSentAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      builderMessage: builderMessage ?? this.builderMessage,
      witnessMessage: witnessMessage ?? this.witnessMessage,
      builderDisplayName: builderDisplayName ?? this.builderDisplayName,
      habitEmoji: habitEmoji ?? this.habitEmoji,
      // Phase 4 Privacy
      alternativeIdentity: alternativeIdentity ?? this.alternativeIdentity,
      // Phase 21.3: Nudge Effectiveness Tracking
      lastNudgeSentAt: lastNudgeSentAt ?? this.lastNudgeSentAt,
      lastNudgeResponseAt: lastNudgeResponseAt ?? this.lastNudgeResponseAt,
      nudgesReceivedCount: nudgesReceivedCount ?? this.nudgesReceivedCount,
      nudgesRespondedCount: nudgesRespondedCount ?? this.nudgesRespondedCount,
      sharePsychometrics: sharePsychometrics ?? this.sharePsychometrics,
      allowNudges: allowNudges ?? this.allowNudges,
      nudgeHistory: nudgeHistory ?? this.nudgeHistory,
      nudgeQuietStart: nudgeQuietStart ?? this.nudgeQuietStart,
      nudgeQuietEnd: nudgeQuietEnd ?? this.nudgeQuietEnd,
      blockedWitnessIds: blockedWitnessIds ?? this.blockedWitnessIds,
      allowEmergencyExit: allowEmergencyExit ?? this.allowEmergencyExit,
      isUnderReview: isUnderReview ?? this.isUnderReview,
      reportedAt: reportedAt ?? this.reportedAt,
    );
  }
  
  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'builder_id': builderId,
      'witness_id': witnessId,
      'habit_id': habitId,
      'invite_code': inviteCode,
      'invite_url': inviteUrl,
      'title': title,
      'commitment_statement': commitmentStatement,
      'duration_days': durationDays,
      'start_date': startDate?.toIso8601String().split('T')[0],
      'end_date': endDate?.toIso8601String().split('T')[0],
      'status': status.name,
      'minimum_completion_rate': minimumCompletionRate,
      'grace_period_days': gracePeriodDays,
      'nudge_enabled': nudgeEnabled,
      'nudge_frequency': nudgeFrequency.name,
      'nudge_style': nudgeStyle.name,
      'days_completed': daysCompleted,
      'days_missed': daysMissed,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'invite_sent_at': inviteSentAt?.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'builder_message': builderMessage,
      'witness_message': witnessMessage,
      // Phase 21.3: Nudge Effectiveness Tracking
      'last_nudge_sent_at': lastNudgeSentAt?.toIso8601String(),
      'last_nudge_response_at': lastNudgeResponseAt?.toIso8601String(),
      'nudges_received_count': nudgesReceivedCount,
      'nudges_responded_count': nudgesRespondedCount,
      // Safety Fields
      'share_psychometrics': sharePsychometrics,
      'allow_nudges': allowNudges,
      'nudge_history': nudgeHistory.map((key, value) => 
          MapEntry(key, value.map((e) => e.toIso8601String()).toList())),
      'nudge_quiet_start': nudgeQuietStart != null 
          ? '${nudgeQuietStart!.hour}:${nudgeQuietStart!.minute}' : null,
      'nudge_quiet_end': nudgeQuietEnd != null 
          ? '${nudgeQuietEnd!.hour}:${nudgeQuietEnd!.minute}' : null,
      'blocked_witness_ids': blockedWitnessIds,
      'allow_emergency_exit': allowEmergencyExit,
      'is_under_review': isUnderReview,
      'reported_at': reportedAt?.toIso8601String(),
    };
  }
  
  /// Create from JSON (Supabase response)
  factory HabitContract.fromJson(Map<String, dynamic> json) {
    return HabitContract(
      id: json['id'] as String,
      builderId: json['builder_id'] as String,
      witnessId: json['witness_id'] as String?,
      habitId: json['habit_id'] as String,
      inviteCode: json['invite_code'] as String,
      inviteUrl: json['invite_url'] as String?,
      title: json['title'] as String,
      commitmentStatement: json['commitment_statement'] as String?,
      durationDays: json['duration_days'] as int? ?? 21,
      startDate: json['start_date'] != null 
          ? DateTime.parse(json['start_date'] as String) 
          : null,
      endDate: json['end_date'] != null 
          ? DateTime.parse(json['end_date'] as String) 
          : null,
      status: ContractStatus.fromString(json['status'] as String? ?? 'draft'),
      minimumCompletionRate: json['minimum_completion_rate'] as int? ?? 80,
      gracePeriodDays: json['grace_period_days'] as int? ?? 2,
      nudgeEnabled: json['nudge_enabled'] as bool? ?? true,
      nudgeFrequency: NudgeFrequency.fromString(
          json['nudge_frequency'] as String? ?? 'daily'),
      nudgeStyle: NudgeStyle.fromString(
          json['nudge_style'] as String? ?? 'encouraging'),
      daysCompleted: json['days_completed'] as int? ?? 0,
      daysMissed: json['days_missed'] as int? ?? 0,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      inviteSentAt: json['invite_sent_at'] != null 
          ? DateTime.parse(json['invite_sent_at'] as String) 
          : null,
      acceptedAt: json['accepted_at'] != null 
          ? DateTime.parse(json['accepted_at'] as String) 
          : null,
      startedAt: json['started_at'] != null 
          ? DateTime.parse(json['started_at'] as String) 
          : null,
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'] as String) 
          : null,
      builderMessage: json['builder_message'] as String?,
      witnessMessage: json['witness_message'] as String?,
      // Phase 21.3: Nudge Effectiveness Tracking
      lastNudgeSentAt: json['last_nudge_sent_at'] != null 
          ? DateTime.parse(json['last_nudge_sent_at'] as String) 
          : null,
      lastNudgeResponseAt: json['last_nudge_response_at'] != null 
          ? DateTime.parse(json['last_nudge_response_at'] as String) 
          : null,
      nudgesReceivedCount: json['nudges_received_count'] as int? ?? 0,
      nudgesRespondedCount: json['nudges_responded_count'] as int? ?? 0,
      
      // Safety Fields
      sharePsychometrics: json['share_psychometrics'] as bool? ?? false,
      allowNudges: json['allow_nudges'] as bool? ?? true, // Default ON
      
      nudgeHistory: (json['nudge_history'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(
          key,
          (value as List).map((e) => DateTime.parse(e as String)).toList(),
        ),
      ) ?? {},
      
      nudgeQuietStart: json['nudge_quiet_start'] != null
          ? TimeOfDay(
              hour: int.parse((json['nudge_quiet_start'] as String).split(':')[0]),
              minute: int.parse((json['nudge_quiet_start'] as String).split(':')[1]))
          : null,
          
      nudgeQuietEnd: json['nudge_quiet_end'] != null
          ? TimeOfDay(
              hour: int.parse((json['nudge_quiet_end'] as String).split(':')[0]),
              minute: int.parse((json['nudge_quiet_end'] as String).split(':')[1]))
          : null,
          
      blockedWitnessIds: (json['blocked_witness_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
          
      allowEmergencyExit: json['allow_emergency_exit'] as bool? ?? true,
      isUnderReview: json['is_under_review'] as bool? ?? false,
      reportedAt: json['reported_at'] != null 
          ? DateTime.parse(json['reported_at'] as String) 
          : null,
    );
  }
}

/// Contract status lifecycle
enum ContractStatus {
  draft,      // Builder is creating, not yet shared
  pending,    // Invite sent, waiting for witness
  active,     // Witness joined, contract running
  completed,  // Duration finished successfully
  broken,     // Builder missed too many days
  cancelled,  // Manually cancelled
  ;
  
  static ContractStatus fromString(String value) {
    return ContractStatus.values.firstWhere(
      (s) => s.name == value.toLowerCase(),
      orElse: () => ContractStatus.draft,
    );
  }
  
  String get displayName {
    switch (this) {
      case ContractStatus.draft:
        return 'Draft';
      case ContractStatus.pending:
        return 'Awaiting Witness';
      case ContractStatus.active:
        return 'Active';
      case ContractStatus.completed:
        return 'Completed';
      case ContractStatus.broken:
        return 'Broken';
      case ContractStatus.cancelled:
        return 'Cancelled';
    }
  }
  
  String get emoji {
    switch (this) {
      case ContractStatus.draft:
        return '📝';
      case ContractStatus.pending:
        return '⏳';
      case ContractStatus.active:
        return '🤝';
      case ContractStatus.completed:
        return '🏆';
      case ContractStatus.broken:
        return '💔';
      case ContractStatus.cancelled:
        return '❌';
    }
  }
}

/// How often witness can nudge
enum NudgeFrequency {
  never,
  daily,
  onMiss,  // Only when builder misses
  weekly,
  ;
  
  static NudgeFrequency fromString(String value) {
    switch (value.toLowerCase()) {
      case 'never':
        return NudgeFrequency.never;
      case 'on_miss':
      case 'onmiss':
        return NudgeFrequency.onMiss;
      case 'weekly':
        return NudgeFrequency.weekly;
      default:
        return NudgeFrequency.daily;
    }
  }
  
  String get displayName {
    switch (this) {
      case NudgeFrequency.never:
        return 'Never';
      case NudgeFrequency.daily:
        return 'Daily check-ins';
      case NudgeFrequency.onMiss:
        return 'Only when I miss';
      case NudgeFrequency.weekly:
        return 'Weekly summary';
    }
  }
}

/// Style of nudges from witness
enum NudgeStyle {
  encouraging,
  firm,
  playful,
  dataOnly,
  ;
  
  static NudgeStyle fromString(String value) {
    switch (value.toLowerCase()) {
      case 'firm':
        return NudgeStyle.firm;
      case 'playful':
        return NudgeStyle.playful;
      case 'data_only':
      case 'dataonly':
        return NudgeStyle.dataOnly;
      default:
        return NudgeStyle.encouraging;
    }
  }
  
  String get displayName {
    switch (this) {
      case NudgeStyle.encouraging:
        return 'Encouraging';
      case NudgeStyle.firm:
        return 'Firm';
      case NudgeStyle.playful:
        return 'Playful';
      case NudgeStyle.dataOnly:
        return 'Just the data';
    }
  }
  
  String get description {
    switch (this) {
      case NudgeStyle.encouraging:
        return '"I believe in you! Keep going!"';
      case NudgeStyle.firm:
        return '"You committed to this. Get it done."';
      case NudgeStyle.playful:
        return '"Hey lazy bones, time to move!"';
      case NudgeStyle.dataOnly:
        return '"Day 5/21: 0 completions this week."';
    }
  }
}

/// Contract event for activity log
class ContractEvent {
  final String id;
  final String contractId;
  final ContractEventType eventType;
  final String? actorId;
  final String? actorRole;
  final String? message;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  
  const ContractEvent({
    required this.id,
    required this.contractId,
    required this.eventType,
    this.actorId,
    this.actorRole,
    this.message,
    this.metadata,
    required this.createdAt,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contract_id': contractId,
      'event_type': eventType.name,
      'actor_id': actorId,
      'actor_role': actorRole,
      'message': message,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  factory ContractEvent.fromJson(Map<String, dynamic> json) {
    return ContractEvent(
      id: json['id'] as String,
      contractId: json['contract_id'] as String,
      eventType: ContractEventType.fromString(json['event_type'] as String),
      actorId: json['actor_id'] as String?,
      actorRole: json['actor_role'] as String?,
      message: json['message'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// Types of contract events
enum ContractEventType {
  created,
  inviteSent,
  witnessJoined,
  started,
  dayCompleted,
  dayMissed,
  nudgeSent,
  message,
  completed,
  broken,
  cancelled,
  updated,
  ;
  
  static ContractEventType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'invite_sent':
      case 'invitesent':
        return ContractEventType.inviteSent;
      case 'witness_joined':
      case 'witnessjoined':
        return ContractEventType.witnessJoined;
      case 'day_completed':
      case 'daycompleted':
        return ContractEventType.dayCompleted;
      case 'day_missed':
      case 'daymissed':
        return ContractEventType.dayMissed;
      case 'nudge_sent':
      case 'nudgesent':
        return ContractEventType.nudgeSent;
      default:
        return ContractEventType.values.firstWhere(
          (t) => t.name == value.toLowerCase(),
          orElse: () => ContractEventType.message,
        );
    }
  }
}
