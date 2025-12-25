/// Phase 14: Pattern Detection - "The Safety Net"
/// 
/// This module provides pattern detection for habit misses,
/// transforming failure data into actionable insights.
/// 
/// Philosophy: "Miss Reasons" → "Actionable Insights"
/// Local-first heuristics for real-time tags, LLM for weekly synthesis.
library;

import 'consistency_metrics.dart';

/// Represents a single miss event with structured data
/// Used for pattern detection and analysis
class MissEvent {
  /// When the miss occurred
  final DateTime date;
  
  /// The reason for missing (structured enum)
  final MissReason? reason;
  
  /// Day of week (1=Monday, 7=Sunday)
  final int dayOfWeek;
  
  /// Hour of day when habit was scheduled (if known)
  final int? scheduledHour;
  
  /// Whether this was a recovery day (bounced back next day)
  final bool wasRecovered;
  
  /// Optional notes from user
  final String? notes;
  
  MissEvent({
    required this.date,
    this.reason,
    int? dayOfWeek,
    this.scheduledHour,
    this.wasRecovered = false,
    this.notes,
  }) : dayOfWeek = dayOfWeek ?? date.weekday;
  
  /// Category of the miss reason
  MissReasonCategory? get category => reason?.category;
  
  /// Is this a weekend miss?
  bool get isWeekend => dayOfWeek >= 6;
  
  /// Is this a morning miss (before noon)?
  bool get isMorning => scheduledHour != null && scheduledHour! < 12;
  
  /// Is this an evening miss (after 6pm)?
  bool get isEvening => scheduledHour != null && scheduledHour! >= 18;
  
  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'reason': reason?.name,
    'dayOfWeek': dayOfWeek,
    'scheduledHour': scheduledHour,
    'wasRecovered': wasRecovered,
    'notes': notes,
  };
  
  factory MissEvent.fromJson(Map<String, dynamic> json) => MissEvent(
    date: DateTime.parse(json['date'] as String),
    reason: MissReason.fromString(json['reason'] as String?),
    dayOfWeek: json['dayOfWeek'] as int?,
    scheduledHour: json['scheduledHour'] as int?,
    wasRecovered: json['wasRecovered'] as bool? ?? false,
    notes: json['notes'] as String?,
  );
}

/// Severity level for detected patterns
enum PatternSeverity {
  /// Low: 2-3 occurrences, gentle nudge
  low('💡', 'Emerging'),
  
  /// Medium: 4-6 occurrences, attention needed
  medium('⚠️', 'Significant'),
  
  /// High: 7+ occurrences, urgent intervention
  high('🚨', 'Critical');
  
  final String emoji;
  final String label;
  const PatternSeverity(this.emoji, this.label);
}

/// Type of detected pattern
enum PatternType {
  /// Time-based pattern (e.g., "always miss Monday mornings")
  wrongTime('Wrong Time', '🌙', 
    "You tend to miss at certain times. Consider rescheduling."),
  
  /// Day-based pattern (e.g., "Mondays are hard")
  problematicDay('Problematic Day', '📅', 
    "Certain days are consistently challenging for you."),
  
  /// Energy pattern (e.g., "tired/stressed misses")
  energyGap('Energy Gap', '⚡', 
    "Energy levels often prevent completion. Try the 2-minute version."),
  
  /// Location pattern (e.g., "misses when traveling")
  locationMismatch('Location Mismatch', '📍', 
    "Location changes disrupt your habit. Create a travel version."),
  
  /// Forgetfulness pattern
  forgettingHabit('Forgetting', '🧠', 
    "You often forget. Consider adding reminders or cues."),
  
  /// Broken chain pattern (stacked habit dependency)
  brokenChain('Broken Chain', '🔗', 
    "Missing an anchor habit causes a cascade. Protect your keystone."),
  
  /// Weekend vs weekday pattern
  weekendVariance('Weekend Variance', '🎉', 
    "Weekends have different patterns. Create a weekend routine."),
  
  /// Recovery pattern (good at bouncing back)
  strongRecovery('Strong Recovery', '💪', 
    "You bounce back quickly! This is Graceful Consistency."),
  
  /// Consistent pattern (no clear issues)
  noPattern('No Clear Pattern', '✨', 
    "No problematic patterns detected. Keep going!");
  
  final String name;
  final String emoji;
  final String suggestion;
  const PatternType(this.name, this.emoji, this.suggestion);
}

/// A detected pattern in habit completion/miss data
/// This is the output of PatternDetectionService
class HabitPattern {
  /// Type of pattern detected
  final PatternType type;
  
  /// Severity/confidence level
  final PatternSeverity severity;
  
  /// Human-readable description
  final String description;
  
  /// Actionable suggestion for the user
  final String suggestion;
  
  /// Confidence score (0.0 - 1.0)
  final double confidence;
  
  /// Number of occurrences that triggered this pattern
  final int occurrences;
  
  /// Total opportunities where pattern could have occurred
  final int totalOpportunities;
  
  /// Supporting data points (dates, reasons, etc.)
  final List<MissEvent> supportingEvents;
  
  /// Tags for display (e.g., "🌙 Night Owl", "⚡ Low Energy")
  final List<String> tags;
  
  /// Specific details (e.g., "Mondays", "After 8 PM", etc.)
  final String? specificDetail;
  
  HabitPattern({
    required this.type,
    required this.severity,
    required this.description,
    required this.suggestion,
    required this.confidence,
    required this.occurrences,
    required this.totalOpportunities,
    this.supportingEvents = const [],
    this.tags = const [],
    this.specificDetail,
  });
  
  /// Percentage of times this pattern occurred
  double get patternRate => totalOpportunities > 0 
      ? occurrences / totalOpportunities 
      : 0;
  
  /// Display string with emoji and description
  String get displayTitle => '${type.emoji} ${type.name}';
  
  /// Is this a positive pattern (like strong recovery)?
  bool get isPositive => type == PatternType.strongRecovery || 
                         type == PatternType.noPattern;
  
  /// Create a "no pattern" result
  factory HabitPattern.noPattern() => HabitPattern(
    type: PatternType.noPattern,
    severity: PatternSeverity.low,
    description: 'No problematic patterns detected',
    suggestion: 'Keep up the great work!',
    confidence: 1.0,
    occurrences: 0,
    totalOpportunities: 0,
    tags: ['✨ Clean Slate'],
  );
  
  Map<String, dynamic> toJson() => {
    'type': type.name,
    'severity': severity.name,
    'description': description,
    'suggestion': suggestion,
    'confidence': confidence,
    'occurrences': occurrences,
    'totalOpportunities': totalOpportunities,
    'supportingEvents': supportingEvents.map((e) => e.toJson()).toList(),
    'tags': tags,
    'specificDetail': specificDetail,
  };
  
  factory HabitPattern.fromJson(Map<String, dynamic> json) {
    return HabitPattern(
      type: PatternType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => PatternType.noPattern,
      ),
      severity: PatternSeverity.values.firstWhere(
        (s) => s.name == json['severity'],
        orElse: () => PatternSeverity.low,
      ),
      description: json['description'] as String? ?? '',
      suggestion: json['suggestion'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      occurrences: json['occurrences'] as int? ?? 0,
      totalOpportunities: json['totalOpportunities'] as int? ?? 0,
      supportingEvents: (json['supportingEvents'] as List?)
          ?.map((e) => MissEvent.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
      specificDetail: json['specificDetail'] as String?,
    );
  }
}

/// Summary of all detected patterns for a habit
class PatternSummary {
  /// The habit ID this summary is for
  final String habitId;
  
  /// When this summary was generated
  final DateTime generatedAt;
  
  /// List of detected patterns, sorted by severity
  final List<HabitPattern> patterns;
  
  /// Primary pattern (most significant)
  final HabitPattern? primaryPattern;
  
  /// All generated tags for display
  final List<String> allTags;
  
  /// Overall pattern health score (0-100)
  final double healthScore;
  
  PatternSummary({
    required this.habitId,
    required this.generatedAt,
    required this.patterns,
    this.primaryPattern,
    this.allTags = const [],
    this.healthScore = 100,
  });
  
  /// Does this habit have significant patterns?
  bool get hasSignificantPatterns => patterns.any(
    (p) => p.severity != PatternSeverity.low && !p.isPositive
  );
  
  /// Get patterns by type
  List<HabitPattern> patternsOfType(PatternType type) =>
      patterns.where((p) => p.type == type).toList();
  
  /// Get only negative/problematic patterns
  List<HabitPattern> get problematicPatterns =>
      patterns.where((p) => !p.isPositive).toList();
  
  /// Get only positive patterns
  List<HabitPattern> get positivePatterns =>
      patterns.where((p) => p.isPositive).toList();
  
  factory PatternSummary.empty(String habitId) => PatternSummary(
    habitId: habitId,
    generatedAt: DateTime.now(),
    patterns: [],
    allTags: [],
    healthScore: 100,
  );
  
  Map<String, dynamic> toJson() => {
    'habitId': habitId,
    'generatedAt': generatedAt.toIso8601String(),
    'patterns': patterns.map((p) => p.toJson()).toList(),
    'primaryPattern': primaryPattern?.toJson(),
    'allTags': allTags,
    'healthScore': healthScore,
  };
  
  factory PatternSummary.fromJson(Map<String, dynamic> json) {
    final patterns = (json['patterns'] as List?)
        ?.map((p) => HabitPattern.fromJson(p as Map<String, dynamic>))
        .toList() ?? [];
    
    return PatternSummary(
      habitId: json['habitId'] as String? ?? '',
      generatedAt: DateTime.tryParse(json['generatedAt'] as String? ?? '') 
          ?? DateTime.now(),
      patterns: patterns,
      primaryPattern: json['primaryPattern'] != null
          ? HabitPattern.fromJson(json['primaryPattern'] as Map<String, dynamic>)
          : null,
      allTags: (json['allTags'] as List?)?.cast<String>() ?? [],
      healthScore: (json['healthScore'] as num?)?.toDouble() ?? 100,
    );
  }
}
