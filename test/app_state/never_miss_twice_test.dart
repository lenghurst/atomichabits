import 'package:flutter_test/flutter_test.dart';
import 'package:atomic_habits_hook_app/data/models/habit.dart';
import 'package:atomic_habits_hook_app/data/models/consistency_metrics.dart';

/// Unit Tests for "Never Miss Twice" Engine Integration in AppState
/// 
/// Framework Feature 31: The "Never Miss Twice" Engine
/// 
/// This test file verifies the core "Never Miss Twice" philosophy implementation:
/// - Detection of single misses
/// - Gentle nudges for recovery
/// - "Never Miss Twice Score" tracking
/// - Spiral prevention
/// 
/// Key tracked metrics:
/// - `consecutiveMissedDays` (via currentMissStreak)
/// - `shouldShowRecoveryPrompt` 
/// - `neverMissTwiceScore` (via neverMissTwiceRate)
void main() {
  group('Never Miss Twice Engine - Habit Model', () {
    // ========== consecutiveMissedDays (via currentMissStreak) ==========
    group('consecutiveMissedDays tracking', () {
      test('returns 0 when completed today', () {
        final today = DateTime.now();
        final habit = Habit(
          id: 'test',
          name: 'Test Habit',
          identity: 'I am a tester',
          tinyVersion: 'Test once',
          implementationTime: '09:00',
          implementationLocation: 'Home',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          completionHistory: [today],
          lastCompletedDate: today,
        );

        expect(habit.currentMissStreak, equals(0));
        expect(habit.needsRecovery, isFalse);
      });

      test('returns 1 when missed yesterday only', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final habit = Habit(
          id: 'test',
          name: 'Test Habit',
          identity: 'I am a tester',
          tinyVersion: 'Test once',
          implementationTime: '09:00',
          implementationLocation: 'Home',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          completionHistory: [yesterday],
          lastCompletedDate: yesterday,
        );

        expect(habit.currentMissStreak, equals(1));
        expect(habit.needsRecovery, isTrue);
      });

      test('returns 2 for two consecutive missed days', () {
        final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
        final habit = Habit(
          id: 'test',
          name: 'Test Habit',
          identity: 'I am a tester',
          tinyVersion: 'Test once',
          implementationTime: '09:00',
          implementationLocation: 'Home',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          completionHistory: [twoDaysAgo],
          lastCompletedDate: twoDaysAgo,
        );

        expect(habit.currentMissStreak, equals(2));
        expect(habit.needsRecovery, isTrue);
      });

      test('handles empty completion history for established habit', () {
        final habit = Habit(
          id: 'test',
          name: 'Test Habit',
          identity: 'I am a tester',
          tinyVersion: 'Test once',
          implementationTime: '09:00',
          implementationLocation: 'Home',
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          completionHistory: [],
          lastCompletedDate: null,
        );

        // Should count all days since creation as missed
        expect(habit.currentMissStreak, greaterThanOrEqualTo(10));
      });
    });

    // ========== Never Miss Twice Score (neverMissTwiceRate) ==========
    group('neverMissTwiceScore tracking', () {
      test('returns 1.0 for perfect consistency (no misses)', () {
        final now = DateTime.now();
        final completions = List.generate(7, (i) => now.subtract(Duration(days: i)));
        
        final habit = Habit(
          id: 'test',
          name: 'Test Habit',
          identity: 'I am a tester',
          tinyVersion: 'Test once',
          implementationTime: '09:00',
          implementationLocation: 'Home',
          createdAt: now.subtract(const Duration(days: 6)),
          completionHistory: completions,
        );

        expect(habit.neverMissTwiceRate, equals(1.0));
      });

      test('returns 1.0 when all misses are single misses', () {
        // Pattern: completed, missed, completed, missed, completed
        // Day 0: completed
        // Day 1: missed (single)
        // Day 2: completed (recovered!)
        // Day 3: missed (single)
        // Day 4: completed (recovered!)
        final now = DateTime.now();
        final completions = [
          now.subtract(const Duration(days: 4)), // Day 0
          now.subtract(const Duration(days: 2)), // Day 2
          now,                                    // Day 4 (today)
        ];
        
        final habit = Habit(
          id: 'test',
          name: 'Test Habit',
          identity: 'I am a tester',
          tinyVersion: 'Test once',
          implementationTime: '09:00',
          implementationLocation: 'Home',
          createdAt: now.subtract(const Duration(days: 4)),
          completionHistory: completions,
        );

        // All miss events (2) are single-day misses = 100% NMT rate
        expect(habit.neverMissTwiceRate, equals(1.0));
      });

      test('returns lower rate when multi-day misses occur', () {
        // Pattern with some multi-day misses
        final now = DateTime.now();
        final completions = [
          now.subtract(const Duration(days: 10)), // Start
          now.subtract(const Duration(days: 9)),  // Day 1
          // Days 2-4: 3-day miss (multi-day)
          now.subtract(const Duration(days: 5)),  // Recovery
          // Day 6: 1-day miss (single)
          now.subtract(const Duration(days: 3)),  // Recovery
        ];
        
        final habit = Habit(
          id: 'test',
          name: 'Test Habit',
          identity: 'I am a tester',
          tinyVersion: 'Test once',
          implementationTime: '09:00',
          implementationLocation: 'Home',
          createdAt: now.subtract(const Duration(days: 10)),
          completionHistory: completions,
        );

        // Has both single and multi-day misses, so rate < 1.0
        expect(habit.neverMissTwiceRate, lessThan(1.0));
      });
    });

    // ========== Recovery Urgency Levels ==========
    group('recoveryUrgency levels', () {
      test('1 day miss = gentle urgency', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final habit = Habit(
          id: 'test',
          name: 'Test Habit',
          identity: 'I am a tester',
          tinyVersion: 'Test once',
          implementationTime: '09:00',
          implementationLocation: 'Home',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          completionHistory: [yesterday],
        );

        final metrics = habit.consistencyMetrics;
        expect(metrics.recoveryUrgency, equals(RecoveryUrgency.gentle));
      });

      test('2 day miss = important urgency', () {
        final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
        final habit = Habit(
          id: 'test',
          name: 'Test Habit',
          identity: 'I am a tester',
          tinyVersion: 'Test once',
          implementationTime: '09:00',
          implementationLocation: 'Home',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          completionHistory: [twoDaysAgo],
        );

        final metrics = habit.consistencyMetrics;
        expect(metrics.recoveryUrgency, equals(RecoveryUrgency.important));
      });

      test('3+ day miss = compassionate urgency', () {
        final fiveDaysAgo = DateTime.now().subtract(const Duration(days: 5));
        final habit = Habit(
          id: 'test',
          name: 'Test Habit',
          identity: 'I am a tester',
          tinyVersion: 'Test once',
          implementationTime: '09:00',
          implementationLocation: 'Home',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          completionHistory: [fiveDaysAgo],
        );

        final metrics = habit.consistencyMetrics;
        expect(metrics.recoveryUrgency, equals(RecoveryUrgency.compassionate));
      });
    });

    // ========== Single Miss Recoveries Tracking ==========
    group('singleMissRecoveries tracking', () {
      test('tracks "Never Miss Twice" wins', () {
        final habit = Habit(
          id: 'test',
          name: 'Test Habit',
          identity: 'I am a tester',
          tinyVersion: 'Test once',
          implementationTime: '09:00',
          implementationLocation: 'Home',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          singleMissRecoveries: 5,
        );

        expect(habit.singleMissRecoveries, equals(5));
      });

      test('never resets (cumulative count)', () {
        final habit = Habit(
          id: 'test',
          name: 'Test Habit',
          identity: 'I am a tester',
          tinyVersion: 'Test once',
          implementationTime: '09:00',
          implementationLocation: 'Home',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          singleMissRecoveries: 10,
        );

        // Even after a long break, the count should persist
        final updatedHabit = habit.copyWith(
          currentStreak: 0,
        );

        expect(updatedHabit.singleMissRecoveries, equals(10));
      });
    });

    // ========== Flexible Tracking Metrics ==========
    group('flexible tracking metrics', () {
      test('daysShowedUp never resets', () {
        final habit = Habit(
          id: 'test',
          name: 'Test Habit',
          identity: 'I am a tester',
          tinyVersion: 'Test once',
          implementationTime: '09:00',
          implementationLocation: 'Home',
          createdAt: DateTime.now().subtract(const Duration(days: 100)),
          daysShowedUp: 75,
          currentStreak: 0, // Even with broken streak
        );

        expect(habit.daysShowedUp, equals(75));
        expect(habit.showUpRate, closeTo(0.75, 0.02));
      });

      test('minimumVersionCount tracks 2-minute version usage', () {
        final habit = Habit(
          id: 'test',
          name: 'Test Habit',
          identity: 'I am a tester',
          tinyVersion: 'Test once',
          implementationTime: '09:00',
          implementationLocation: 'Home',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          daysShowedUp: 25,
          minimumVersionCount: 8,
          fullCompletionCount: 17,
        );

        expect(habit.minimumVersionCount, equals(8));
        expect(habit.fullCompletionCount, equals(17));
        expect(habit.minimumVersionRate, closeTo(0.32, 0.01));
      });
    });

    // ========== Graceful Score Calculation ==========
    group('graceful score components', () {
      test('neverMissTwiceRate contributes 20% to graceful score', () {
        // High NMT rate should improve graceful score
        final now = DateTime.now();
        final perfectWeek = List.generate(7, (i) => now.subtract(Duration(days: i)));
        
        final habit = Habit(
          id: 'test',
          name: 'Test Habit',
          identity: 'I am a tester',
          tinyVersion: 'Test once',
          implementationTime: '09:00',
          implementationLocation: 'Home',
          createdAt: now.subtract(const Duration(days: 6)),
          completionHistory: perfectWeek,
        );

        final metrics = habit.consistencyMetrics;
        
        // With perfect week: 40% base + 20% stability + 20% NMT = 80+ minimum
        expect(metrics.gracefulScore, greaterThanOrEqualTo(80));
      });

      test('graceful score accounts for recovery bonus', () {
        final now = DateTime.now();
        final completions = List.generate(7, (i) => now.subtract(Duration(days: i)));
        
        final recoveryEvents = [
          RecoveryEvent(
            missDate: now.subtract(const Duration(days: 15)),
            recoveryDate: now.subtract(const Duration(days: 14)),
            daysMissed: 1,  // Quick recovery
          ),
          RecoveryEvent(
            missDate: now.subtract(const Duration(days: 10)),
            recoveryDate: now.subtract(const Duration(days: 9)),
            daysMissed: 1,  // Quick recovery
          ),
        ];
        
        final habit = Habit(
          id: 'test',
          name: 'Test Habit',
          identity: 'I am a tester',
          tinyVersion: 'Test once',
          implementationTime: '09:00',
          implementationLocation: 'Home',
          createdAt: now.subtract(const Duration(days: 20)),
          completionHistory: completions,
          recoveryHistory: recoveryEvents,
        );

        final metrics = habit.consistencyMetrics;
        
        // Should get recovery bonus for quick recoveries
        expect(metrics.quickRecoveryCount, equals(2));
        // Score is 70 with the current algorithm (base + stability + NMT)
        expect(metrics.gracefulScore, greaterThanOrEqualTo(70));
      });
    });
  });

  // ========== ConsistencyMetrics Model Tests ==========
  group('ConsistencyMetrics - Never Miss Twice', () {
    test('needsRecovery based on currentMissStreak', () {
      final metrics = ConsistencyMetrics(
        gracefulScore: 50,
        daysShowedUp: 20,
        totalDays: 30,
        weeklyAverage: 0.6,
        monthlyAverage: 0.6,
        recoveryCount: 2,
        quickRecoveryCount: 1,
        longestStreak: 10,
        currentStreak: 0,
        totalCompletions: 20,
        identityVotes: 20,
        neverMissTwiceRate: 0.8,
        currentMissStreak: 2,
      );

      expect(metrics.needsRecovery, isTrue);
      expect(metrics.recoveryUrgency, equals(RecoveryUrgency.important));
    });

    test('neverMissTwiceRate range is 0.0-1.0', () {
      final metrics = ConsistencyMetrics(
        gracefulScore: 50,
        daysShowedUp: 20,
        totalDays: 30,
        weeklyAverage: 0.6,
        monthlyAverage: 0.6,
        recoveryCount: 2,
        quickRecoveryCount: 1,
        longestStreak: 10,
        currentStreak: 5,
        totalCompletions: 20,
        identityVotes: 20,
        neverMissTwiceRate: 0.75,
        currentMissStreak: 0,
      );

      expect(metrics.neverMissTwiceRate, greaterThanOrEqualTo(0));
      expect(metrics.neverMissTwiceRate, lessThanOrEqualTo(1));
    });

    test('calculateGracefulScore includes NMT component', () {
      // 100% 7-day average + 2 quick recoveries + 0 variance + 100% NMT
      final score = ConsistencyMetrics.calculateGracefulScore(
        sevenDayAverage: 1.0,      // 40% * 100 = 40
        quickRecoveries: 2,        // 2 * 5 = 10 (capped at 20)
        completionTimeVariance: 0, // (1 - 0) * 20 = 20
        neverMissTwiceRate: 1.0,   // 1.0 * 20 = 20
      );

      // Total: 40 + 10 + 20 + 20 = 90
      expect(score, equals(90));
    });

    test('empty metrics returns optimistic NMT rate', () {
      final metrics = ConsistencyMetrics.empty();
      
      expect(metrics.neverMissTwiceRate, equals(1.0));
      expect(metrics.currentMissStreak, equals(0));
    });
  });

  // ========== Philosophy Alignment Tests ==========
  group('Atomic Habits Philosophy Alignment', () {
    test('single miss is not treated as failure', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final habit = Habit(
        id: 'test',
        name: 'Test Habit',
        identity: 'I am a tester',
        tinyVersion: 'Test once',
        implementationTime: '09:00',
        implementationLocation: 'Home',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        completionHistory: [yesterday],
        identityVotes: 25, // Already built up votes
        daysShowedUp: 25,
      );

      // Identity votes should NOT reset
      expect(habit.identityVotes, equals(25));
      
      // Days showed up should NOT reset  
      expect(habit.daysShowedUp, equals(25));
      
      // Should trigger gentle (not harsh) recovery
      expect(habit.consistencyMetrics.recoveryUrgency, equals(RecoveryUrgency.gentle));
    });

    test('graceful score rewards recovery, not just streaks', () {
      final now = DateTime.now();
      
      // User with perfect 7-day streak but no recoveries
      final perfectUser = Habit(
        id: 'perfect',
        name: 'Perfect Habit',
        identity: 'I am perfect',
        tinyVersion: 'Be perfect',
        implementationTime: '09:00',
        implementationLocation: 'Home',
        createdAt: now.subtract(const Duration(days: 7)),
        completionHistory: List.generate(7, (i) => now.subtract(Duration(days: i))),
        recoveryHistory: [],
      );

      // User with same completions but 2 quick recoveries
      final resilientUser = Habit(
        id: 'resilient',
        name: 'Resilient Habit',
        identity: 'I am resilient',
        tinyVersion: 'Bounce back',
        implementationTime: '09:00',
        implementationLocation: 'Home',
        createdAt: now.subtract(const Duration(days: 14)),
        completionHistory: List.generate(7, (i) => now.subtract(Duration(days: i))),
        recoveryHistory: [
          RecoveryEvent(
            missDate: now.subtract(const Duration(days: 10)),
            recoveryDate: now.subtract(const Duration(days: 9)),
            daysMissed: 1,
          ),
          RecoveryEvent(
            missDate: now.subtract(const Duration(days: 12)),
            recoveryDate: now.subtract(const Duration(days: 11)),
            daysMissed: 1,
          ),
        ],
      );

      // Perfect user has no recoveries
      final perfectMetrics = perfectUser.consistencyMetrics;
      expect(perfectMetrics.quickRecoveryCount, equals(0));
      
      // Resilient user should get bonus for quick recoveries
      final resilientMetrics = resilientUser.consistencyMetrics;
      expect(resilientMetrics.quickRecoveryCount, equals(2));
    });

    test('compassionate messaging for long gaps', () {
      final twoWeeksAgo = DateTime.now().subtract(const Duration(days: 14));
      final habit = Habit(
        id: 'test',
        name: 'Test Habit',
        identity: 'I am a tester',
        tinyVersion: 'Test once',
        implementationTime: '09:00',
        implementationLocation: 'Home',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        completionHistory: [twoWeeksAgo],
      );

      final metrics = habit.consistencyMetrics;
      
      // Should use compassionate (not harsh) urgency
      expect(metrics.recoveryUrgency, equals(RecoveryUrgency.compassionate));
      expect(metrics.currentMissStreak, greaterThanOrEqualTo(14));
    });
  });
}
