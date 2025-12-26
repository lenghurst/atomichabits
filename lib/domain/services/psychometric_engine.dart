import 'dart:async';
import 'dart:isolate';

import '../entities/psychometric_profile.dart';
import '../../data/models/habit.dart';

/// PsychometricEngine: Analyzes behavioral patterns and updates the user's psychological profile.
/// 
/// This service runs in the background, analyzing raw habit logs to update the PsychometricProfile.
/// Satisfies: Fowler (Logic Extraction), Muratori (Incremental updates + Isolate for O(N) ops).
class PsychometricEngine {
  
  /// Analyzes a NEW miss to update resilience incrementally.
  /// Does NOT re-read history (O(1)).
  PsychometricProfile onHabitMiss(PsychometricProfile profile) {
    // Logic: A miss lowers resilience slightly
    double penalty = 0.05;
    
    // Stoic users are more resilient to misses
    if (profile.coachingStyle == CoachingStyle.stoic) {
      penalty = 0.02;
    }

    return profile.copyWith(
      resilienceScore: (profile.resilienceScore - penalty).clamp(0.0, 1.0),
    );
  }

  /// Analyzes a NEW completion to update resilience incrementally.
  /// Does NOT re-read history (O(1)).
  PsychometricProfile onHabitComplete(PsychometricProfile profile, {bool wasRecovery = false}) {
    // Completing a habit boosts resilience
    double boost = 0.02;
    
    // Recovery completions (coming back after a miss) are extra valuable
    if (wasRecovery) {
      boost = 0.05;
    }

    return profile.copyWith(
      resilienceScore: (profile.resilienceScore + boost).clamp(0.0, 1.0),
    );
  }

  /// Called via background job occasionally to recalibrate risks.
  /// This is the heavy O(N) logic that runs in an Isolate OFF the UI thread.
  /// 
  /// MURATORI CAVEAT: This method MUST run in an Isolate to prevent UI jank.
  /// Use [recalibrateRisksAsync] for production code.
  Future<PsychometricProfile> recalibrateRisksAsync(
    PsychometricProfile profile, 
    List<Habit> habits,
  ) async {
    // Prepare serialisable data for the Isolate
    final payload = _RecalibratePayload(
      profileJson: profile.toJson(),
      habitsJson: habits.map((h) => h.toSerializableMap()).toList(),
    );
    
    // Run the heavy computation in an Isolate
    final resultJson = await Isolate.run(() => _recalibrateInIsolate(payload));
    
    // Reconstruct the profile from the result
    return PsychometricProfile.fromJson(resultJson);
  }

  /// Synchronous version for testing or when Isolate overhead isn't worth it.
  /// WARNING: Do NOT call this on the UI thread with large habit lists.
  @Deprecated('Use recalibrateRisksAsync for production code')
  PsychometricProfile recalibrateRisksSync(PsychometricProfile profile, List<Habit> habits) {
    return _performRecalibration(profile, habits);
  }

  /// The actual recalibration logic (pure function, no Flutter dependencies).
  static PsychometricProfile _performRecalibration(
    PsychometricProfile profile, 
    List<Habit> habits,
  ) {
    int newMask = 0;
    final List<String> identifiedRisks = [];
    
    // Analyze all habits for patterns
    final Map<int, int> missCountsByDay = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    
    for (final habit in habits) {
      // Analyze miss history for day-of-week patterns
      for (final recovery in habit.recoveryHistory) {
        final dayOfWeek = recovery.missDate.weekday;
        missCountsByDay[dayOfWeek] = (missCountsByDay[dayOfWeek] ?? 0) + 1;
      }
    }
    
    // Detect weekend slump (Saturday = 6, Sunday = 7)
    final weekendMisses = (missCountsByDay[6] ?? 0) + (missCountsByDay[7] ?? 0);
    final weekdayMisses = (missCountsByDay[1] ?? 0) + (missCountsByDay[2] ?? 0) + 
                          (missCountsByDay[3] ?? 0) + (missCountsByDay[4] ?? 0) + 
                          (missCountsByDay[5] ?? 0);
    
    // If weekend misses are disproportionately high (more than 40% of total)
    final totalMisses = weekendMisses + weekdayMisses;
    if (totalMisses > 3 && weekendMisses / totalMisses > 0.4) {
      newMask |= RiskFlags.weekend;
      identifiedRisks.add('Weekends');
    }
    
    // Detect Monday blues (common drop-off day)
    if ((missCountsByDay[1] ?? 0) > totalMisses * 0.2 && totalMisses > 5) {
      identifiedRisks.add('Mondays');
    }
    
    // Detect Friday fatigue
    if ((missCountsByDay[5] ?? 0) > totalMisses * 0.2 && totalMisses > 5) {
      identifiedRisks.add('Fridays');
      newMask |= RiskFlags.fatigue;
    }
    
    return profile.copyWith(
      riskBitmask: newMask,
      dropOffZones: identifiedRisks,
    );
  }

  /// Analyzes chat sentiment to update coaching style preference.
  /// Called after AI interactions to learn user preferences.
  PsychometricProfile updateFromChatFeedback(
    PsychometricProfile profile, {
    required String userMessage,
    required bool wasPositiveResponse,
  }) {
    // Simple keyword detection for coaching style preference
    final lowerMessage = userMessage.toLowerCase();
    
    // Detect resistance to tough love
    if (lowerMessage.contains('too harsh') || 
        lowerMessage.contains('stop pushing') ||
        lowerMessage.contains('need support')) {
      if (profile.coachingStyle == CoachingStyle.toughLove) {
        return profile.copyWith(coachingStyle: CoachingStyle.supportive);
      }
    }
    
    // Detect desire for more directness
    if (lowerMessage.contains('be direct') || 
        lowerMessage.contains('no excuses') ||
        lowerMessage.contains('push me')) {
      return profile.copyWith(coachingStyle: CoachingStyle.toughLove);
    }
    
    // Detect preference for data
    if (lowerMessage.contains('show me data') || 
        lowerMessage.contains('statistics') ||
        lowerMessage.contains('analyze')) {
      return profile.copyWith(coachingStyle: CoachingStyle.analytical);
    }
    
    return profile;
  }

  /// Extracts core values from onboarding data.
  /// Called during onboarding to initialize the profile.
  PsychometricProfile initializeFromOnboarding({
    required String identity,
    required String motivation,
    String? bigWhy,
    List<String>? fears,
  }) {
    // Extract potential values from identity statement
    final List<String> extractedValues = [];
    final lowerIdentity = identity.toLowerCase();
    
    if (lowerIdentity.contains('health') || lowerIdentity.contains('fit') || lowerIdentity.contains('strong')) {
      extractedValues.add('Health');
    }
    if (lowerIdentity.contains('learn') || lowerIdentity.contains('grow') || lowerIdentity.contains('master')) {
      extractedValues.add('Mastery');
    }
    if (lowerIdentity.contains('free') || lowerIdentity.contains('independent')) {
      extractedValues.add('Freedom');
    }
    if (lowerIdentity.contains('disciplin') || lowerIdentity.contains('consistent')) {
      extractedValues.add('Discipline');
    }
    if (lowerIdentity.contains('creat') || lowerIdentity.contains('artist') || lowerIdentity.contains('writer')) {
      extractedValues.add('Creativity');
    }
    
    // Default values if none extracted
    if (extractedValues.isEmpty) {
      extractedValues.add('Growth');
    }
    
    return PsychometricProfile(
      coreValues: extractedValues,
      bigWhy: bigWhy ?? motivation,
      antiIdentities: fears ?? [],
      desireFingerprint: [motivation],
      coachingStyle: CoachingStyle.supportive, // Default to supportive
      verbosityPreference: 3, // Middle ground
      resilienceScore: 0.7, // Start optimistic
      baselineSentiment: 'Determined',
    );
  }

  /// Updates profile based on sensor data (Sherlock Expansion).
  /// 
  /// - Sleep < 6h: Lowers resilience, forces SUPPORTIVE persona.
  /// - High Distraction: Logs vulnerability, lowers resilience.
  /// - Low HRV: Logs Stress risk.
  PsychometricProfile updateFromSensorData(
    PsychometricProfile profile, {
    int? sleepMinutes,
    double? hrv,
    int? distractionMinutes,
  }) {
    double newResilience = profile.resilienceScore;
    CoachingStyle newStyle = profile.coachingStyle;
    int newBitmask = profile.riskBitmask;
    
    // 1. Analyze Sleep
    if (sleepMinutes != null) {
      if (sleepMinutes < 360) { // < 6 hours
        // Sleep deprivation significantly lowers willpower (Baumeister)
        newResilience -= 0.15;
        // Switch to supportive if currently tough love (compassion for biology)
        if (newStyle == CoachingStyle.toughLove) {
          newStyle = CoachingStyle.supportive;
        }
        newBitmask |= RiskFlags.fatigue; // Set FATIGUE flag
      } else if (sleepMinutes > 480) { // > 8 hours
        newResilience += 0.05;
        newBitmask &= ~RiskFlags.fatigue; // Clear FATIGUE flag
      }
    }
    
    // 2. Analyze HRV (Stress) - Simplified baseline logic
    // We assume < 30ms is stressed for general population (very rough heuristic)
    // Real implementation should compare against user's running baseline.
    if (hrv != null) {
      if (hrv < 30.0) {
        newBitmask |= RiskFlags.stress;
         newResilience -= 0.05;
      } else {
        newBitmask &= ~RiskFlags.stress;
      }
    }
    
    // 3. Analyze Distraction (Dopamine Burn)
    if (distractionMinutes != null) {
      // > 60 mins of scrolling is a dopamine crash risk
      if (distractionMinutes > 60) {
        newResilience -= 0.1;
      }
    }

    return profile.copyWith(
      resilienceScore: newResilience.clamp(0.0, 1.0),
      coachingStyle: newStyle,
      riskBitmask: newBitmask,
      lastNightSleepMinutes: sleepMinutes,
      currentHRV: hrv,
      distractionMinutes: distractionMinutes,
      lastUpdated: DateTime.now(),
      isSynced: false,
    );
  }

  /// Calculates peak energy window based on completion times.
  /// Runs in Isolate for large habit lists.
  Future<String> calculatePeakEnergyWindowAsync(List<Habit> habits) async {
    if (habits.isEmpty) return '09:00 - 11:00';
    
    // For small lists, run synchronously
    if (habits.length < 10) {
      return _calculatePeakEnergyWindow(habits);
    }
    
    // For large lists, use Isolate
    final habitsJson = habits.map((h) => h.toSerializableMap()).toList();
    return await Isolate.run(() => _calculatePeakEnergyWindowFromJson(habitsJson));
  }

  /// Synchronous version for small habit lists.
  String _calculatePeakEnergyWindow(List<Habit> habits) {
    final Map<int, int> completionsByHour = {};
    
    for (final habit in habits) {
      for (final completion in habit.completionHistory) {
        final hour = completion.hour;
        completionsByHour[hour] = (completionsByHour[hour] ?? 0) + 1;
      }
    }
    
    if (completionsByHour.isEmpty) return '09:00 - 11:00';
    
    // Find the hour with most completions
    int peakHour = 9;
    int maxCompletions = 0;
    
    completionsByHour.forEach((hour, count) {
      if (count > maxCompletions) {
        maxCompletions = count;
        peakHour = hour;
      }
    });
    
    // Return as a window (e.g., "09:00 - 11:00")
    final endHour = (peakHour + 2) % 24;
    return '${peakHour.toString().padLeft(2, '0')}:00 - ${endHour.toString().padLeft(2, '0')}:00';
  }

  /// Static version for Isolate execution.
  static String _calculatePeakEnergyWindowFromJson(List<Map<String, dynamic>> habitsJson) {
    final Map<int, int> completionsByHour = {};
    
    for (final habitJson in habitsJson) {
      final completionHistory = habitJson['completionHistory'] as List<dynamic>? ?? [];
      for (final completion in completionHistory) {
        if (completion is DateTime) {
          final hour = completion.hour;
          completionsByHour[hour] = (completionsByHour[hour] ?? 0) + 1;
        } else if (completion is String) {
          final dt = DateTime.tryParse(completion);
          if (dt != null) {
            final hour = dt.hour;
            completionsByHour[hour] = (completionsByHour[hour] ?? 0) + 1;
          }
        }
      }
    }
    
    if (completionsByHour.isEmpty) return '09:00 - 11:00';
    
    int peakHour = 9;
    int maxCompletions = 0;
    
    completionsByHour.forEach((hour, count) {
      if (count > maxCompletions) {
        maxCompletions = count;
        peakHour = hour;
      }
    });
    
    final endHour = (peakHour + 2) % 24;
    return '${peakHour.toString().padLeft(2, '0')}:00 - ${endHour.toString().padLeft(2, '0')}:00';
  }
}

/// Payload for Isolate communication (must be serialisable).
class _RecalibratePayload {
  final Map<String, dynamic> profileJson;
  final List<Map<String, dynamic>> habitsJson;
  
  _RecalibratePayload({
    required this.profileJson,
    required this.habitsJson,
  });
}

/// Top-level function for Isolate execution.
/// Must be static/top-level to work with Isolate.run().
Map<String, dynamic> _recalibrateInIsolate(_RecalibratePayload payload) {
  // Reconstruct objects from JSON
  final profile = PsychometricProfile.fromJson(payload.profileJson);
  final habits = payload.habitsJson.map((json) => Habit.fromSerializableMap(json)).toList();
  
  // Perform the heavy computation
  final result = PsychometricEngine._performRecalibration(profile, habits);
  
  // Return as JSON for serialisation back to main isolate
  return result.toJson();
}
