import '../../config/niche_config.dart';

/// Type of habit being created
enum HabitType { build, breakHabit }

/// Data transfer object for AI onboarding flow
/// 
/// Maps directly to Habit model fields for seamless persistence.
/// Used by AI services to extract structured data from conversations.
class OnboardingData {
  // === CORE IDENTITY ===
  final String? identity;           // "I am a person who reads daily"
  final String? name;               // "Read every day" (matches Habit.name)
  final String? habitEmoji;         // "📚"
  
  // === THE HABIT ===
  final HabitType habitType;        // build vs breakHabit
  
  // === IMPLEMENTATION (Build) OR INVERSION (Break) ===
  final String? tinyVersion;        // "Read 1 page" (2-Minute Rule)
  final String? implementationTime; // "22:00"
  final String? implementationLocation; // "In bed"
  final String? environmentCue;     // "After I brush my teeth"
  
  // === ATOMIC HABITS (Law 2 & 3) ===
  final String? temptationBundle;   // "While drinking herbal tea"
  final String? preHabitRitual;     // "Take 3 deep breaths"
  final String? environmentDistraction; // "Put phone in other room"
  
  // === BREAK HABIT SPECIFIC ===
  final String? replacesHabit;      // "Doomscrolling"
  final String? rootCause;          // "Boredom/Anxiety"
  final String? substitutionPlan;   // "5-min stretch instead"
  
  // === METADATA ===
  final String? motivation;         // "Expand knowledge"
  final String? recoveryPlan;       // Maps to FailurePlaybook.recoveryAction
  final bool isComplete;            // Ready to save?
  
  // === NICHE TRACKING (Phase 19: Side Door Strategy) ===
  final UserNiche userNiche;        // Detected persona (developer, writer, etc.)
  final String? entrySource;        // Landing page or referral source
  final bool isStreakRefugee;       // Came from streak-based app burnout

  const OnboardingData({
    this.identity,
    this.name,
    this.habitEmoji,
    this.habitType = HabitType.build,
    this.tinyVersion,
    this.implementationTime,
    this.implementationLocation,
    this.environmentCue,
    this.temptationBundle,
    this.preHabitRitual,
    this.environmentDistraction,
    this.replacesHabit,
    this.rootCause,
    this.substitutionPlan,
    this.motivation,
    this.recoveryPlan,
    this.isComplete = false,
    this.userNiche = UserNiche.general,
    this.entrySource,
    this.isStreakRefugee = false,
  });

  /// Create from JSON (handles AI output aliases)
  factory OnboardingData.fromJson(Map<String, dynamic> json) {
    return OnboardingData(
      habitType: json['isBreakHabit'] == true ? HabitType.breakHabit : HabitType.build,
      identity: json['identity'] as String?,
      name: json['name'] as String? ?? json['habitName'] as String?, // Handle alias
      habitEmoji: json['habitEmoji'] as String?,
      tinyVersion: json['tinyVersion'] as String?,
      implementationTime: json['implementationTime'] as String? ?? json['time'] as String?,
      implementationLocation: json['implementationLocation'] as String? ?? json['location'] as String?,
      environmentCue: json['environmentCue'] as String? ?? json['cue'] as String?,
      temptationBundle: json['temptationBundle'] as String?,
      preHabitRitual: json['preHabitRitual'] as String?,
      environmentDistraction: json['environmentDistraction'] as String?,
      replacesHabit: json['replacesHabit'] as String?,
      rootCause: json['rootCause'] as String?,
      substitutionPlan: json['substitutionPlan'] as String?,
      motivation: json['motivation'] as String?,
      recoveryPlan: json['recoveryPlan'] as String?,
      isComplete: json['isComplete'] == true,
      userNiche: _parseUserNiche(json['userNiche']),
      entrySource: json['entrySource'] as String?,
      isStreakRefugee: json['isStreakRefugee'] == true,
    );
  }
  
  /// Parse UserNiche from string
  static UserNiche _parseUserNiche(dynamic value) {
    if (value == null) return UserNiche.general;
    if (value is UserNiche) return value;
    final name = value.toString().toLowerCase();
    return UserNiche.values.firstWhere(
      (n) => n.name.toLowerCase() == name,
      orElse: () => UserNiche.general,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'isBreakHabit': habitType == HabitType.breakHabit,
    'identity': identity,
    'name': name,
    'habitEmoji': habitEmoji,
    'tinyVersion': tinyVersion,
    'implementationTime': implementationTime,
    'implementationLocation': implementationLocation,
    'environmentCue': environmentCue,
    'temptationBundle': temptationBundle,
    'preHabitRitual': preHabitRitual,
    'environmentDistraction': environmentDistraction,
    'replacesHabit': replacesHabit,
    'rootCause': rootCause,
    'substitutionPlan': substitutionPlan,
    'motivation': motivation,
    'recoveryPlan': recoveryPlan,
    'isComplete': isComplete,
    'userNiche': userNiche.name,
    'entrySource': entrySource,
    'isStreakRefugee': isStreakRefugee,
  };

  /// Check if minimum required fields are present
  bool get hasRequiredFields {
    return identity != null && 
           identity!.isNotEmpty &&
           name != null && 
           name!.isNotEmpty &&
           tinyVersion != null && 
           tinyVersion!.isNotEmpty &&
           implementationTime != null &&
           implementationLocation != null;
  }

  /// Create a copy with updated fields
  OnboardingData copyWith({
    String? identity,
    String? name,
    String? habitEmoji,
    HabitType? habitType,
    String? tinyVersion,
    String? implementationTime,
    String? implementationLocation,
    String? environmentCue,
    String? temptationBundle,
    String? preHabitRitual,
    String? environmentDistraction,
    String? replacesHabit,
    String? rootCause,
    String? substitutionPlan,
    String? motivation,
    String? recoveryPlan,
    bool? isComplete,
    UserNiche? userNiche,
    String? entrySource,
    bool? isStreakRefugee,
  }) {
    return OnboardingData(
      identity: identity ?? this.identity,
      name: name ?? this.name,
      habitEmoji: habitEmoji ?? this.habitEmoji,
      habitType: habitType ?? this.habitType,
      tinyVersion: tinyVersion ?? this.tinyVersion,
      implementationTime: implementationTime ?? this.implementationTime,
      implementationLocation: implementationLocation ?? this.implementationLocation,
      environmentCue: environmentCue ?? this.environmentCue,
      temptationBundle: temptationBundle ?? this.temptationBundle,
      preHabitRitual: preHabitRitual ?? this.preHabitRitual,
      environmentDistraction: environmentDistraction ?? this.environmentDistraction,
      replacesHabit: replacesHabit ?? this.replacesHabit,
      rootCause: rootCause ?? this.rootCause,
      substitutionPlan: substitutionPlan ?? this.substitutionPlan,
      motivation: motivation ?? this.motivation,
      recoveryPlan: recoveryPlan ?? this.recoveryPlan,
      isComplete: isComplete ?? this.isComplete,
      userNiche: userNiche ?? this.userNiche,
      entrySource: entrySource ?? this.entrySource,
      isStreakRefugee: isStreakRefugee ?? this.isStreakRefugee,
    );
  }

  @override
  String toString() {
    return 'OnboardingData(identity: $identity, name: $name, habitType: $habitType, isComplete: $isComplete)';
  }
}
