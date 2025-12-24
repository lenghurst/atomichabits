import '../entities/psychometric_profile.dart';
import '../../data/models/habit.dart';

/// PsychometricEngine: Analyzes behavioral patterns and updates the user's psychological profile.
/// 
/// This service runs in the background, analyzing raw habit logs to update the PsychometricProfile.
/// Satisfies: Fowler (Logic Extraction), Muratori (Incremental updates).
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
  /// This is the heavy O(N) logic that happens OFF the UI thread.
  PsychometricProfile recalibrateRisks(PsychometricProfile profile, List<Habit> habits) {
    int newMask = 0;
    final List<String> identifiedRisks = [];
    
    // Analyze all habits for patterns
    final Map<int, int> missCountsByDay = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    final Map<int, int> missCountsByHour = {};
    
    for (final habit in habits) {
      // Analyze miss history for day-of-week patterns
      for (final recovery in habit.recoveryHistory) {
        final dayOfWeek = recovery.missDate.weekday;
        missCountsByDay[dayOfWeek] = (missCountsByDay[dayOfWeek] ?? 0) + 1;
        
        // If we had time data, we'd analyze hours too
        // final hour = recovery.missDate.hour;
        // missCountsByHour[hour] = (missCountsByHour[hour] ?? 0) + 1;
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

  /// Calculates peak energy window based on completion times.
  String calculatePeakEnergyWindow(List<Habit> habits) {
    final Map<int, int> completionsByHour = {};
    
    for (final habit in habits) {
      for (final completion in habit.completionHistory) {
        final hour = completion.hour;
        completionsByHour[hour] = (completionsByHour[hour] ?? 0) + 1;
      }
    }
    
    if (completionsByHour.isEmpty) return '09:00';
    
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
}
