/// ArchetypeEvolutionService - Shadow Archetype Evolution Tracking
///
/// Genspark Recommendation Implementation:
/// Tracks how users evolve from their initial failure archetype
/// (e.g., "REBEL" -> "DISCIPLINED_REBEL").
///
/// Evolution is detected based on:
/// - Streak milestones (21 days, 66 days)
/// - Recovery patterns (Never Miss Twice)
/// - Resilience improvements
/// - Intervention response changes
///
/// Philosophy: Identity is not fixed. Users can become who they want to be.
/// Track and celebrate this transformation.

import '../entities/psychometric_profile.dart';
import '../../data/models/habit.dart';

/// Evolution milestone thresholds
class EvolutionMilestones {
  /// First evolution (e.g., "EMERGING_DISCIPLINED_REBEL")
  static const int firstMilestoneStreak = 21;

  /// Second evolution (e.g., "DISCIPLINED_REBEL")
  static const int secondMilestoneStreak = 66;

  /// Third evolution (e.g., "REFORMED_REBEL")
  static const int thirdMilestoneStreak = 100;

  /// Resilience threshold for positive evolution
  static const double resilienceThreshold = 0.7;

  /// Show up rate threshold for evolution
  static const double showUpRateThreshold = 0.85;

  /// Minimum single miss recoveries for resilience evolution
  static const int minRecoveries = 3;
}

/// Service for detecting and recording archetype evolution
class ArchetypeEvolutionService {
  /// Check if user has reached an evolution milestone
  ///
  /// Call this after habit completions and periodically.
  /// Returns an ArchetypeSnapshot if evolution detected, null otherwise.
  ArchetypeSnapshot? detectEvolution({
    required PsychometricProfile profile,
    required List<Habit> habits,
  }) {
    if (profile.failureArchetype == null) return null;

    final baseArchetype = profile.failureArchetype!.toUpperCase();

    // Get the most recent evolution (if any)
    final lastEvolution = profile.archetypeHistory.isNotEmpty
        ? profile.archetypeHistory.last
        : null;

    // Check each evolution trigger
    final streakEvolution = _checkStreakEvolution(
      baseArchetype: baseArchetype,
      habits: habits,
      lastEvolution: lastEvolution,
    );
    if (streakEvolution != null) return streakEvolution;

    final resilienceEvolution = _checkResilienceEvolution(
      baseArchetype: baseArchetype,
      habits: habits,
      profile: profile,
      lastEvolution: lastEvolution,
    );
    if (resilienceEvolution != null) return resilienceEvolution;

    final recoveryEvolution = _checkRecoveryEvolution(
      baseArchetype: baseArchetype,
      habits: habits,
      lastEvolution: lastEvolution,
    );
    if (recoveryEvolution != null) return recoveryEvolution;

    return null;
  }

  /// Check for streak-based evolution
  ArchetypeSnapshot? _checkStreakEvolution({
    required String baseArchetype,
    required List<Habit> habits,
    ArchetypeSnapshot? lastEvolution,
  }) {
    // Find best streak across all habits
    int bestStreak = 0;
    for (final habit in habits) {
      if (habit.currentStreak > bestStreak) {
        bestStreak = habit.currentStreak;
      }
      if (habit.longestStreak > bestStreak) {
        bestStreak = habit.longestStreak;
      }
    }

    // Determine evolution stage
    final currentStage = _getCurrentStage(lastEvolution);

    // Check for milestone crossings
    if (bestStreak >= EvolutionMilestones.thirdMilestoneStreak && currentStage < 3) {
      return ArchetypeSnapshot(
        baseArchetype: baseArchetype,
        evolvedArchetype: 'REFORMED_$baseArchetype',
        evolutionType: EvolutionType.positive,
        trigger: 'streak_100',
        recordedAt: DateTime.now(),
        metrics: {'streak': bestStreak.toDouble()},
      );
    }

    if (bestStreak >= EvolutionMilestones.secondMilestoneStreak && currentStage < 2) {
      return ArchetypeSnapshot(
        baseArchetype: baseArchetype,
        evolvedArchetype: 'DISCIPLINED_$baseArchetype',
        evolutionType: EvolutionType.positive,
        trigger: 'streak_66',
        recordedAt: DateTime.now(),
        metrics: {'streak': bestStreak.toDouble()},
      );
    }

    if (bestStreak >= EvolutionMilestones.firstMilestoneStreak && currentStage < 1) {
      return ArchetypeSnapshot(
        baseArchetype: baseArchetype,
        evolvedArchetype: 'EMERGING_$baseArchetype',
        evolutionType: EvolutionType.positive,
        trigger: 'streak_21',
        recordedAt: DateTime.now(),
        metrics: {'streak': bestStreak.toDouble()},
      );
    }

    return null;
  }

  /// Check for resilience-based evolution
  ArchetypeSnapshot? _checkResilienceEvolution({
    required String baseArchetype,
    required List<Habit> habits,
    required PsychometricProfile profile,
    ArchetypeSnapshot? lastEvolution,
  }) {
    // Skip if we already have a resilience evolution
    if (lastEvolution?.trigger.contains('resilience') == true) {
      return null;
    }

    // Check if resilience meets threshold
    if (profile.resilienceScore >= EvolutionMilestones.resilienceThreshold) {
      // Also check show up rate across habits
      double avgShowUpRate = 0;
      for (final habit in habits) {
        avgShowUpRate += habit.showUpRate;
      }
      if (habits.isNotEmpty) {
        avgShowUpRate /= habits.length;
      }

      if (avgShowUpRate >= EvolutionMilestones.showUpRateThreshold) {
        return ArchetypeSnapshot(
          baseArchetype: baseArchetype,
          evolvedArchetype: 'RESILIENT_$baseArchetype',
          evolutionType: EvolutionType.positive,
          trigger: 'resilience_high',
          recordedAt: DateTime.now(),
          metrics: {
            'resilience': profile.resilienceScore,
            'showUpRate': avgShowUpRate,
          },
        );
      }
    }

    return null;
  }

  /// Check for recovery pattern evolution (Never Miss Twice mastery)
  ArchetypeSnapshot? _checkRecoveryEvolution({
    required String baseArchetype,
    required List<Habit> habits,
    ArchetypeSnapshot? lastEvolution,
  }) {
    // Skip if we already have a recovery evolution
    if (lastEvolution?.trigger.contains('recovery') == true) {
      return null;
    }

    // Count total single miss recoveries
    int totalRecoveries = 0;
    for (final habit in habits) {
      totalRecoveries += habit.singleMissRecoveries;
    }

    if (totalRecoveries >= EvolutionMilestones.minRecoveries) {
      return ArchetypeSnapshot(
        baseArchetype: baseArchetype,
        evolvedArchetype: 'RECOVERING_$baseArchetype',
        evolutionType: EvolutionType.positive,
        trigger: 'recovery_mastery',
        recordedAt: DateTime.now(),
        metrics: {'recoveries': totalRecoveries.toDouble()},
      );
    }

    return null;
  }

  /// Check for regression (losing previous progress)
  ArchetypeSnapshot? detectRegression({
    required PsychometricProfile profile,
    required List<Habit> habits,
  }) {
    if (profile.archetypeHistory.isEmpty) return null;

    final lastEvolution = profile.archetypeHistory.last;
    if (lastEvolution.evolutionType != EvolutionType.positive) return null;

    // Check if all streaks have been broken for extended period
    bool allStreaksBroken = true;
    for (final habit in habits) {
      if (habit.currentStreak > 0) {
        allStreaksBroken = false;
        break;
      }
    }

    if (allStreaksBroken && profile.resilienceScore < 0.3) {
      return ArchetypeSnapshot(
        baseArchetype: lastEvolution.baseArchetype,
        evolvedArchetype: null, // Reverts to base
        evolutionType: EvolutionType.regression,
        trigger: 'extended_break',
        recordedAt: DateTime.now(),
        metrics: {'resilience': profile.resilienceScore},
      );
    }

    return null;
  }

  /// Get the current evolution stage (0-3)
  int _getCurrentStage(ArchetypeSnapshot? lastEvolution) {
    if (lastEvolution == null) return 0;

    final evolved = lastEvolution.evolvedArchetype ?? '';
    if (evolved.startsWith('REFORMED_')) return 3;
    if (evolved.startsWith('DISCIPLINED_')) return 2;
    if (evolved.startsWith('EMERGING_') ||
        evolved.startsWith('RESILIENT_') ||
        evolved.startsWith('RECOVERING_')) return 1;
    return 0;
  }

  /// Get a celebratory message for an evolution
  String getEvolutionMessage(ArchetypeSnapshot snapshot) {
    final evolved = snapshot.evolvedArchetype ?? snapshot.baseArchetype;

    switch (snapshot.trigger) {
      case 'streak_21':
        return "You've hit 21 days! You're becoming $evolved. The habit is taking root.";
      case 'streak_66':
        return "66 days! Science says this is automatic now. You ARE $evolved.";
      case 'streak_100':
        return "100 days. You've reformed. $evolved is your new identity.";
      case 'resilience_high':
        return "Your resilience is remarkable. You bounce back. You're $evolved.";
      case 'recovery_mastery':
        return "You've mastered Never Miss Twice. You're $evolved - setbacks don't stop you.";
      case 'extended_break':
        return "It's been a while. That's okay. Let's rebuild together.";
      default:
        return "Your identity is evolving. You're becoming $evolved.";
    }
  }

  /// Get the modifier prefix for display (e.g., "DISCIPLINED" from "DISCIPLINED_REBEL")
  String? getModifierPrefix(String? evolvedArchetype) {
    if (evolvedArchetype == null) return null;

    final parts = evolvedArchetype.split('_');
    if (parts.length < 2) return null;

    return parts.first;
  }

  /// Check if an evolution is positive
  bool isPositiveEvolution(ArchetypeSnapshot snapshot) {
    return snapshot.evolutionType == EvolutionType.positive;
  }
}
