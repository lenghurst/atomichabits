/// Represents the user's psychological operating system.
/// This is the "System Context" fed to the LLM before every interaction.
/// 
/// Satisfies: Fowler (Domain Logic), Uncle Bob (No Infrastructure Dependencies).
/// 
/// Phase 42: Added "Holy Trinity" fields for Sherlock Protocol onboarding:
/// - Anti-Identity (Fear): The named villain they fear becoming
/// - Failure Archetype (History): The historical reason for quitting
/// - Resistance Pattern (The Lie): The specific excuse they tell themselves
class PsychometricProfile {
  // === CORE DRIVERS (The "Why") ===
  final List<String> coreValues;       // e.g., ["Freedom", "Mastery", "Health"]
  final String bigWhy;                 // The singular life goal driving them
  final List<String> antiIdentities;   // Who they fear becoming (e.g., "The Lazy Stoner")
  final List<String> desireFingerprint; // Specific desires (e.g., "Look good naked", "Publish a book")

  // === THE HOLY TRINITY (Sherlock Protocol - Phase 42) ===
  
  // 1. Anti-Identity (Fear) - Day 1 Activation
  final String? antiIdentityLabel;     // e.g., "The Sleepwalker", "The Ghost"
  final String? antiIdentityContext;   // e.g., "Hits snooze 5 times, hates the mirror"
  
  // 2. Failure Archetype (History) - Day 7 Trial Conversion
  final String? failureArchetype;      // e.g., "PERFECTIONIST", "NOVELTY_SEEKER"
  final String? failureTriggerContext; // e.g., "Missed 3 days, felt guilty, quit"
  
  // 3. Resistance Pattern (The Lie) - Day 30+ Retention
  final String? resistanceLieLabel;    // e.g., "The Bargain", "The Tomorrow Trap"
  final String? resistanceLieContext;  // e.g., "I'll do double tomorrow"
  
  // === AI-INFERRED DATA ===
  final List<String> inferredFears;    // e.g., ["Physical Shame", "Career Regret"]
  final List<String> declinedPermissions; // e.g. ["calendar.readonly", "youtube.readonly"]

  // === COMMUNICATION MATRIX (The "How") ===
  final CoachingStyle coachingStyle;   // The persona they respond to best
  final int verbosityPreference;       // 1 (Bullet points) to 5 (Long prose)
  final List<String> resonanceWords;   // Words that trigger action (e.g., "Grind", "Flow")
  final List<String> avoidWords;       // Words that cause resistance (e.g., "Discipline", "Obey")

  // === BEHAVIORAL INTELLIGENCE (The "When") ===
  // These are calculated by the Analyzer Service based on actual habit data
  final List<String> dropOffZones;     // e.g., "Weekends", "Travel", "Post-Lunch"
  final String peakEnergyWindow;       // e.g., "08:00 - 11:00"
  final double resilienceScore;        // 0.0-1.0 (Likelihood to quit after a miss)
  
  // === EMOTIONAL BASELINE ===
  final String baselineSentiment;      // e.g., "Anxious", "Determined", "Skeptical"

  // === REAL-TIME SENSOR DATA (Sherlock Expansion) ===
  final int? lastNightSleepMinutes;    // e.g., 350
  final double? currentHRV;            // e.g., 45.0 (SDNN)
  final int? distractionMinutes;       // e.g., 120 (TikTok + IG)

  // === SYNC STATE (Phase 45: Cloud Prep) ===
  final bool isSynced;                 // True if pushed to cloud
  final DateTime lastUpdated;          // Last local modification time

  // === BEHAVIORAL RISK BITMASK (Performance Optimization per Muratori) ===
  final int riskBitmask;               // Bitmask for O(1) risk checks

  // === ARCHETYPE EVOLUTION (Genspark Recommendation - Shadow Archetype Tracking) ===
  final List<ArchetypeSnapshot> archetypeHistory;  // Track how archetype evolves over time

  PsychometricProfile({
    this.coreValues = const [],
    this.bigWhy = '',
    this.antiIdentities = const [],
    this.desireFingerprint = const [],
    // Holy Trinity fields
    this.antiIdentityLabel,
    this.antiIdentityContext,
    this.failureArchetype,
    this.failureTriggerContext,
    this.resistanceLieLabel,
    this.resistanceLieContext,
    this.inferredFears = const [],
    this.declinedPermissions = const [],
    // Communication matrix
    this.coachingStyle = CoachingStyle.supportive,
    this.verbosityPreference = 3,
    this.resonanceWords = const [],
    this.avoidWords = const [],
    this.dropOffZones = const [],
    this.peakEnergyWindow = '09:00',
    this.resilienceScore = 0.5,
    this.baselineSentiment = 'Neutral',
    // Sensor Data
    this.lastNightSleepMinutes,
    this.currentHRV,
    this.distractionMinutes,
    
    this.riskBitmask = 0,
    this.archetypeHistory = const [],
    this.isSynced = false,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  /// Generates the "System Prompt" block for the LLM.
  /// This is the key method that transforms structured data into AI context.
  String toSystemPrompt() {
    final buffer = StringBuffer();
    
    buffer.writeln('[[USER PSYCHOMETRICS]]');
    buffer.writeln('');
    
    // === THE HOLY TRINITY (Phase 42) ===
    if (hasHolyTrinity) {
      buffer.writeln('USER DOSSIER (Sherlock Protocol):');
      if (antiIdentityLabel != null) {
        buffer.writeln('- THE ENEMY (Anti-Identity): "$antiIdentityLabel"');
        if (antiIdentityContext != null) {
          buffer.writeln('  Context: $antiIdentityContext');
        }
      }
      if (failureArchetype != null) {
        buffer.writeln('- FAILURE RISK: $failureArchetype');
        if (failureTriggerContext != null) {
          buffer.writeln('  History: $failureTriggerContext');
        }
      }
      if (resistanceLieLabel != null) {
        buffer.writeln('- THE RESISTANCE LIE: "$resistanceLieLabel"');
        if (resistanceLieContext != null) {
          buffer.writeln('  Exact phrase: "$resistanceLieContext"');
        }
      }
      if (inferredFears.isNotEmpty) {
        buffer.writeln('- INFERRED FEARS: ${inferredFears.join(", ")}');
      }
      buffer.writeln('');
    }
    
    // Log declined permissions as context (neutral facts)
    if (declinedPermissions.isNotEmpty) {
      buffer.writeln('PRIVACY BOUNDARIES (Declined Permissions):');
      buffer.writeln('- The user declined access to: ${declinedPermissions.join(", ")}');
      buffer.writeln('  (Respect this boundary but infer potential blind spots)');
      buffer.writeln('');
    }
    
    buffer.writeln('CORE DRIVERS:');
    if (coreValues.isNotEmpty) {
      buffer.writeln('- Values: ${coreValues.join(", ")}');
    }
    if (bigWhy.isNotEmpty) {
      buffer.writeln('- Primary Drive: $bigWhy');
    }
    if (antiIdentities.isNotEmpty) {
      buffer.writeln('- FEARS (Anti-Identity): ${antiIdentities.join(", ")}');
    }
    if (desireFingerprint.isNotEmpty) {
      buffer.writeln('- DESIRES: ${desireFingerprint.join(", ")}');
    }
    buffer.writeln('');
    
    buffer.writeln('COMMUNICATION PROTOCOL:');
    buffer.writeln('- Adopt Persona: ${coachingStyle.displayName}');
    buffer.writeln('- Verbosity Level: $verbosityPreference/5');
    if (resonanceWords.isNotEmpty) {
      buffer.writeln('- USE these words: ${resonanceWords.join(", ")}');
    }
    if (avoidWords.isNotEmpty) {
      buffer.writeln('- AVOID these words: ${avoidWords.join(", ")}');
    }
    buffer.writeln('');
    
    buffer.writeln('BEHAVIORAL RISKS:');
    if (dropOffZones.isNotEmpty) {
      buffer.writeln('- High-Risk Drop-off Zones: ${dropOffZones.join(", ")}');
    }
    buffer.writeln('- Best Energy Window: $peakEnergyWindow');
    // Enhanced resilience reporting from sensors
    final resiliencePercent = (resilienceScore * 100).toStringAsFixed(0);
    String resilienceContext = "";
    if (lastNightSleepMinutes != null && lastNightSleepMinutes! < 360) {
      resilienceContext = " (COMPROMISED: Low Sleep)";
    }
    buffer.writeln('- Current Resilience: $resiliencePercent%$resilienceContext');
    buffer.writeln('- Baseline Mood: $baselineSentiment');
    
    // === SENSOR DATA EXPOSURE ===
    if (lastNightSleepMinutes != null || currentHRV != null || distractionMinutes != null) {
      buffer.writeln('\nPHYSIOLOGICAL INTELLIGENCE (Sherlock Sensors):');
      if (lastNightSleepMinutes != null) {
        buffer.writeln('- Sleep: ${lastNightSleepMinutes! ~/ 60}h ${lastNightSleepMinutes! % 60}m');
      }
      if (currentHRV != null) {
        buffer.writeln('- HRV (Stress): $currentHRV ms');
      }
      if (distractionMinutes != null) {
        buffer.writeln('- Digital Distraction: ${distractionMinutes}m (Dopamine Burn)');
      }
    }
    
    return buffer.toString();
  }
  
  /// Check if the holy trinity is captured
  bool get hasHolyTrinity => 
      antiIdentityLabel != null || 
      failureArchetype != null || 
      resistanceLieLabel != null;
  
  /// Check if onboarding is complete (all 3 traits captured)
  bool get isOnboardingComplete =>
      antiIdentityLabel != null &&
      failureArchetype != null &&
      resistanceLieLabel != null;

  /// Quick O(1) check for weekend risk
  bool get isWeekendRisk => (riskBitmask & RiskFlags.weekend) != 0;

  /// Quick O(1) check for travel risk
  bool get isTravelRisk => (riskBitmask & RiskFlags.travel) != 0;

  /// Quick O(1) check for evening risk
  bool get isEveningRisk => (riskBitmask & RiskFlags.evening) != 0;

  /// Quick O(1) check for morning risk
  bool get isMorningRisk => (riskBitmask & RiskFlags.morning) != 0;

  /// Quick O(1) check for social risk
  bool get isSocialRisk => (riskBitmask & RiskFlags.social) != 0;

  /// Quick O(1) check for stress risk
  bool get isStressRisk => (riskBitmask & RiskFlags.stress) != 0;

  /// Quick O(1) check for fatigue risk
  bool get isFatigueRisk => (riskBitmask & RiskFlags.fatigue) != 0;

  /// Calculate base vulnerability score from risk bitmask (O(1))
  /// Returns 0.0-1.0 normalized score based on active risk flags
  double get riskScore {
    int activeFlags = 0;
    int mask = riskBitmask;
    while (mask > 0) {
      activeFlags += mask & 1;
      mask >>= 1;
    }
    // 7 possible flags, normalize to 0-1
    // Each flag contributes ~0.14 to base vulnerability
    return (activeFlags / 7.0).clamp(0.0, 1.0);
  }

  /// Get the dominant risk factor name for explainability
  String? get dominantRiskFactor {
    if (isWeekendRisk) return 'weekend';
    if (isEveningRisk) return 'evening';
    if (isMorningRisk) return 'morning';
    if (isStressRisk) return 'stress';
    if (isFatigueRisk) return 'fatigue';
    if (isSocialRisk) return 'social';
    if (isTravelRisk) return 'travel';
    return null;
  }

  /// Domain Logic: Can the user handle a challenge today?
  bool isResilientEnough(int difficultyLevel) {
    return resilienceScore > (difficultyLevel * 0.1);
  }

  /// Check if user is in a vulnerable state
  bool isVulnerableAt(DateTime dateTime) {
    // Weekend check
    if (isWeekendRisk && (dateTime.weekday == DateTime.saturday || dateTime.weekday == DateTime.sunday)) {
      return true;
    }
    // Evening check (after 6pm)
    if (isEveningRisk && dateTime.hour >= 18) {
      return true;
    }
    return false;
  }

  PsychometricProfile copyWith({
    List<String>? coreValues,
    String? bigWhy,
    List<String>? antiIdentities,
    List<String>? desireFingerprint,
    // Holy Trinity fields
    String? antiIdentityLabel,
    String? antiIdentityContext,
    String? failureArchetype,
    String? failureTriggerContext,
    String? resistanceLieLabel,
    String? resistanceLieContext,
    List<String>? inferredFears,
    List<String>? declinedPermissions,
    // Communication matrix
    CoachingStyle? coachingStyle,
    int? verbosityPreference,
    List<String>? resonanceWords,
    List<String>? avoidWords,
    List<String>? dropOffZones,
    String? peakEnergyWindow,
    double? resilienceScore,
    String? baselineSentiment,
    // Sensor Data (Phase 47)
    int? lastNightSleepMinutes,
    double? currentHRV,
    int? distractionMinutes,
    
    int? riskBitmask,
    List<ArchetypeSnapshot>? archetypeHistory,
    bool? isSynced,
    DateTime? lastUpdated,
  }) {
    return PsychometricProfile(
      coreValues: coreValues ?? this.coreValues,
      bigWhy: bigWhy ?? this.bigWhy,
      antiIdentities: antiIdentities ?? this.antiIdentities,
      desireFingerprint: desireFingerprint ?? this.desireFingerprint,
      // Holy Trinity fields
      antiIdentityLabel: antiIdentityLabel ?? this.antiIdentityLabel,
      antiIdentityContext: antiIdentityContext ?? this.antiIdentityContext,
      failureArchetype: failureArchetype ?? this.failureArchetype,
      failureTriggerContext: failureTriggerContext ?? this.failureTriggerContext,
      resistanceLieLabel: resistanceLieLabel ?? this.resistanceLieLabel,
      resistanceLieContext: resistanceLieContext ?? this.resistanceLieContext,
      inferredFears: inferredFears ?? this.inferredFears,
      declinedPermissions: declinedPermissions ?? this.declinedPermissions,
      // Communication matrix
      coachingStyle: coachingStyle ?? this.coachingStyle,
      verbosityPreference: verbosityPreference ?? this.verbosityPreference,
      resonanceWords: resonanceWords ?? this.resonanceWords,
      avoidWords: avoidWords ?? this.avoidWords,
      dropOffZones: dropOffZones ?? this.dropOffZones,
      peakEnergyWindow: peakEnergyWindow ?? this.peakEnergyWindow,
      resilienceScore: resilienceScore ?? this.resilienceScore,
      baselineSentiment: baselineSentiment ?? this.baselineSentiment,
      
      // Sensor Data
      lastNightSleepMinutes: lastNightSleepMinutes ?? this.lastNightSleepMinutes,
      currentHRV: currentHRV ?? this.currentHRV,
      distractionMinutes: distractionMinutes ?? this.distractionMinutes,
      
      riskBitmask: riskBitmask ?? this.riskBitmask,
      archetypeHistory: archetypeHistory ?? this.archetypeHistory,
      isSynced: isSynced ?? this.isSynced,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Get the current evolved archetype (with modifiers like DISCIPLINED_REBEL)
  String get evolvedArchetype {
    if (archetypeHistory.isEmpty) {
      return failureArchetype ?? 'UNKNOWN';
    }
    return archetypeHistory.last.evolvedArchetype ?? failureArchetype ?? 'UNKNOWN';
  }

  /// Check if user has evolved from their original archetype
  bool get hasEvolved =>
      archetypeHistory.isNotEmpty &&
      archetypeHistory.last.evolvedArchetype != null;

  /// Get evolution progress (0.0 - 1.0) based on archetype transitions
  double get evolutionProgress {
    if (archetypeHistory.isEmpty) return 0.0;

    final positiveTransitions = archetypeHistory.where(
      (s) => s.evolutionType == EvolutionType.positive
    ).length;

    // 5 positive transitions = full evolution
    return (positiveTransitions / 5.0).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() {
    return {
      'coreValues': coreValues,
      'bigWhy': bigWhy,
      'antiIdentities': antiIdentities,
      'desireFingerprint': desireFingerprint,
      // Holy Trinity fields (Phase 42)
      'antiIdentityLabel': antiIdentityLabel,
      'antiIdentityContext': antiIdentityContext,
      'failureArchetype': failureArchetype,
      'failureTriggerContext': failureTriggerContext,
      'resistanceLieLabel': resistanceLieLabel,
      'resistanceLieContext': resistanceLieContext,
      'inferredFears': inferredFears,
      'declinedPermissions': declinedPermissions,
      // Communication matrix
      'coachingStyle': coachingStyle.name,
      'verbosityPreference': verbosityPreference,
      'resonanceWords': resonanceWords,
      'avoidWords': avoidWords,
      'dropOffZones': dropOffZones,
      'peakEnergyWindow': peakEnergyWindow,
      'resilienceScore': resilienceScore,
      'baselineSentiment': baselineSentiment,
      // Sensor Data
      'lastNightSleepMinutes': lastNightSleepMinutes,
      'currentHRV': currentHRV,
      'distractionMinutes': distractionMinutes,
      
      'riskBitmask': riskBitmask,
      'archetypeHistory': archetypeHistory.map((s) => s.toJson()).toList(),
      'isSynced': isSynced,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory PsychometricProfile.fromJson(Map<String, dynamic> json) {
    return PsychometricProfile(
      coreValues: List<String>.from(json['coreValues'] ?? []),
      bigWhy: json['bigWhy'] ?? '',
      antiIdentities: List<String>.from(json['antiIdentities'] ?? []),
      desireFingerprint: List<String>.from(json['desireFingerprint'] ?? []),
      // Holy Trinity fields (Phase 42)
      antiIdentityLabel: json['antiIdentityLabel'] as String?,
      antiIdentityContext: json['antiIdentityContext'] as String?,
      failureArchetype: json['failureArchetype'] as String?,
      failureTriggerContext: json['failureTriggerContext'] as String?,
      resistanceLieLabel: json['resistanceLieLabel'] as String?,
      resistanceLieContext: json['resistanceLieContext'] as String?,
      inferredFears: List<String>.from(json['inferredFears'] ?? []),
      declinedPermissions: List<String>.from(json['declinedPermissions'] ?? []),
      // Communication matrix
      coachingStyle: CoachingStyle.values.firstWhere(
        (e) => e.name == json['coachingStyle'],
        orElse: () => CoachingStyle.supportive,
      ),
      verbosityPreference: json['verbosityPreference'] ?? 3,
      resonanceWords: List<String>.from(json['resonanceWords'] ?? []),
      avoidWords: List<String>.from(json['avoidWords'] ?? []),
      dropOffZones: List<String>.from(json['dropOffZones'] ?? []),
      peakEnergyWindow: json['peakEnergyWindow'] ?? '09:00',
      resilienceScore: (json['resilienceScore'] ?? 0.5).toDouble(),
      baselineSentiment: json['baselineSentiment'] ?? 'Neutral',
      
      // Sensor Data
      lastNightSleepMinutes: json['lastNightSleepMinutes'] as int?,
      currentHRV: (json['currentHRV'] as num?)?.toDouble(),
      distractionMinutes: json['distractionMinutes'] as int?,
      
      riskBitmask: json['riskBitmask'] ?? 0,
      archetypeHistory: (json['archetypeHistory'] as List<dynamic>?)
          ?.map((e) => ArchetypeSnapshot.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      isSynced: json['isSynced'] ?? false,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
    );
  }
}

/// Represents a point-in-time snapshot of archetype evolution
class ArchetypeSnapshot {
  /// Original archetype from onboarding (e.g., "REBEL")
  final String baseArchetype;

  /// Evolved archetype with modifiers (e.g., "DISCIPLINED_REBEL", "RECOVERING_PERFECTIONIST")
  final String? evolvedArchetype;

  /// Type of evolution that occurred
  final EvolutionType evolutionType;

  /// What triggered this evolution snapshot
  final String trigger;

  /// When this snapshot was taken
  final DateTime recordedAt;

  /// Metrics that influenced this evolution
  final Map<String, double>? metrics;

  const ArchetypeSnapshot({
    required this.baseArchetype,
    this.evolvedArchetype,
    required this.evolutionType,
    required this.trigger,
    required this.recordedAt,
    this.metrics,
  });

  Map<String, dynamic> toJson() => {
        'baseArchetype': baseArchetype,
        'evolvedArchetype': evolvedArchetype,
        'evolutionType': evolutionType.name,
        'trigger': trigger,
        'recordedAt': recordedAt.toIso8601String(),
        'metrics': metrics,
      };

  factory ArchetypeSnapshot.fromJson(Map<String, dynamic> json) {
    return ArchetypeSnapshot(
      baseArchetype: json['baseArchetype'] as String,
      evolvedArchetype: json['evolvedArchetype'] as String?,
      evolutionType: EvolutionType.values.firstWhere(
        (e) => e.name == json['evolutionType'],
        orElse: () => EvolutionType.neutral,
      ),
      trigger: json['trigger'] as String,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      metrics: json['metrics'] != null
          ? Map<String, double>.from(json['metrics'] as Map)
          : null,
    );
  }
}

/// Types of archetype evolution
enum EvolutionType {
  /// Positive growth (e.g., REBEL -> DISCIPLINED_REBEL)
  positive,

  /// Regression (e.g., DISCIPLINED_REBEL -> REBEL)
  regression,

  /// No change detected
  neutral,

  /// Archetype shift (e.g., PERFECTIONIST -> OVERTHINKING_PERFECTIONIST)
  shift,
}

/// Coaching styles that determine how the AI communicates with the user.
enum CoachingStyle {
  toughLove,    // "Get up. No excuses."
  socratic,     // "Why do you think you missed today?"
  supportive,   // "You're doing great! One miss is okay!"
  analytical,   // "Data shows you miss on Tuesdays. Let's optimize."
  stoic,        // "The obstacle is the way."
}

extension CoachingStyleExtension on CoachingStyle {
  String get displayName {
    switch (this) {
      case CoachingStyle.toughLove:
        return 'TOUGH_LOVE';
      case CoachingStyle.socratic:
        return 'SOCRATIC';
      case CoachingStyle.supportive:
        return 'SUPPORTIVE';
      case CoachingStyle.analytical:
        return 'ANALYTICAL';
      case CoachingStyle.stoic:
        return 'STOIC';
    }
  }

  String get description {
    switch (this) {
      case CoachingStyle.toughLove:
        return 'Direct and demanding. No excuses accepted.';
      case CoachingStyle.socratic:
        return 'Asks questions to help you discover answers.';
      case CoachingStyle.supportive:
        return 'Encouraging and understanding. Celebrates small wins.';
      case CoachingStyle.analytical:
        return 'Data-driven insights and optimization suggestions.';
      case CoachingStyle.stoic:
        return 'Philosophical wisdom. Obstacles become opportunities.';
    }
  }
}

/// Bitmask flags for O(1) risk checks (per Muratori's performance recommendation).
class RiskFlags {
  static const int weekend = 1 << 0;    // 1
  static const int travel = 1 << 1;     // 2
  static const int evening = 1 << 2;    // 4
  static const int morning = 1 << 3;    // 8
  static const int social = 1 << 4;     // 16
  static const int stress = 1 << 5;     // 32
  static const int fatigue = 1 << 6;    // 64
}
