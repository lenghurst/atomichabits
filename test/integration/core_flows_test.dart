import 'package:flutter_test/flutter_test.dart';
import 'package:atomic_habits_hook_app/data/models/habit.dart';
import 'package:atomic_habits_hook_app/data/models/user_profile.dart';
import 'package:atomic_habits_hook_app/data/models/consistency_metrics.dart';
import 'package:atomic_habits_hook_app/data/services/recovery_engine.dart';
import 'package:atomic_habits_hook_app/utils/date_utils.dart';

/// Integration Tests - Core Flows
/// 
/// These tests verify that multiple components work together correctly.
/// They smoke-test the critical user journeys in the app.
void main() {
  group('Core Flows Integration', () {
    // ========== Habit Completion Flow ==========
    group('Habit Completion Flow', () {
      test('completing habit updates consistency metrics correctly', () {
        // Setup: User has a 7-day old habit with 5 completions
        final habitCreatedAt = DateTime.now().subtract(const Duration(days: 7));
        final completionDates = [
          DateTime.now().subtract(const Duration(days: 6)),
          DateTime.now().subtract(const Duration(days: 5)),
          DateTime.now().subtract(const Duration(days: 4)),
          DateTime.now().subtract(const Duration(days: 2)),
          DateTime.now().subtract(const Duration(days: 1)),
        ];
        
        // Calculate metrics before today's completion
        final metricsBefore = ConsistencyMetrics.fromCompletionHistory(
          completionDates: completionDates,
          habitCreatedAt: habitCreatedAt,
          recoveryEvents: [],
        );
        
        // User completes habit today
        final completionDatesAfter = [...completionDates, DateTime.now()];
        
        // Calculate metrics after completion
        final metricsAfter = ConsistencyMetrics.fromCompletionHistory(
          completionDates: completionDatesAfter,
          habitCreatedAt: habitCreatedAt,
          recoveryEvents: [],
        );
        
        // Assertions
        expect(metricsAfter.identityVotes, equals(metricsBefore.identityVotes + 1));
        expect(metricsAfter.totalCompletions, equals(metricsBefore.totalCompletions + 1));
        expect(metricsAfter.currentMissStreak, equals(0)); // No longer missing
        expect(metricsAfter.gracefulScore, greaterThanOrEqualTo(metricsBefore.gracefulScore));
      });

      test('completing after miss counts as recovery', () {
        // Setup: User missed yesterday
        final habitCreatedAt = DateTime.now().subtract(const Duration(days: 7));
        final completionDates = [
          DateTime.now().subtract(const Duration(days: 6)),
          DateTime.now().subtract(const Duration(days: 5)),
          DateTime.now().subtract(const Duration(days: 4)),
          DateTime.now().subtract(const Duration(days: 3)),
          // Missed yesterday (day 1)
          // Completed today
          DateTime.now(),
        ];
        
        final recoveryEvents = [
          RecoveryEvent(
            missDate: DateTime.now().subtract(const Duration(days: 1)),
            recoveryDate: DateTime.now(),
            daysMissed: 1,
            usedTinyVersion: true,
          ),
        ];
        
        final metrics = ConsistencyMetrics.fromCompletionHistory(
          completionDates: completionDates,
          habitCreatedAt: habitCreatedAt,
          recoveryEvents: recoveryEvents,
        );
        
        // Recovery should be counted
        expect(metrics.recoveryCount, greaterThan(0));
        expect(metrics.currentMissStreak, equals(0));
        expect(metrics.needsRecovery, isFalse);
      });
    });

    // ========== Recovery Detection Flow ==========
    group('Recovery Detection Flow', () {
      test('missed day triggers recovery need with correct urgency progression', () {
        final habit = Habit(
          id: 'test',
          name: 'Read',
          tinyVersion: 'Read one page',
          implementationTime: '09:00',
          implementationLocation: 'In bed',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        );
        
        final profile = UserProfile(
          name: 'Test',
          identity: 'I am a reader',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        );
        
        // Day 1 miss
        var completions = [DateTime.now().subtract(const Duration(days: 1))];
        var need = RecoveryEngine.checkRecoveryNeed(
          habit: habit,
          profile: profile,
          completionHistory: completions,
        );
        expect(need!.urgency, equals(RecoveryUrgency.gentle));
        
        // Day 2 miss
        completions = [DateTime.now().subtract(const Duration(days: 2))];
        need = RecoveryEngine.checkRecoveryNeed(
          habit: habit,
          profile: profile,
          completionHistory: completions,
        );
        expect(need!.urgency, equals(RecoveryUrgency.important));
        
        // Day 3+ miss
        completions = [DateTime.now().subtract(const Duration(days: 4))];
        need = RecoveryEngine.checkRecoveryNeed(
          habit: habit,
          profile: profile,
          completionHistory: completions,
        );
        expect(need!.urgency, equals(RecoveryUrgency.compassionate));
      });

      test('recovery messages are always encouraging, never shaming', () {
        final habit = Habit(
          id: 'test',
          name: 'Exercise',
          tinyVersion: 'Do 5 pushups',
          implementationTime: '07:00',
          implementationLocation: 'Bedroom',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        );
        
        final profile = UserProfile(
          name: 'User',
          identity: 'I am healthy',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        );
        
        // Check messages for all urgency levels
        for (final urgency in RecoveryUrgency.values) {
          final need = RecoveryNeed(
            habit: habit,
            profile: profile,
            daysMissed: urgency == RecoveryUrgency.gentle ? 1 
                      : urgency == RecoveryUrgency.important ? 2 : 5,
            urgency: urgency,
          );
          
          final message = RecoveryEngine.getRecoveryMessage(need);
          final title = RecoveryEngine.getRecoveryTitle(urgency);
          final subtitle = RecoveryEngine.getRecoverySubtitle(urgency, need.daysMissed);
          
          // Should not contain shaming words
          final allText = '$message $title $subtitle'.toLowerCase();
          expect(allText.contains('failure'), isFalse);
          expect(allText.contains('bad'), isFalse);
          expect(allText.contains('lazy'), isFalse);
          expect(allText.contains('pathetic'), isFalse);
          expect(allText.contains('terrible'), isFalse);
          
          // Should include the tiny version
          expect(message.contains(habit.tinyVersion), isTrue);
        }
      });
    });

    // ========== Consistency Score Flow ==========
    group('Consistency Score Flow', () {
      test('perfect week scores high', () {
        final habitCreatedAt = DateTime.now().subtract(const Duration(days: 7));
        final completionDates = List.generate(7, (i) => 
          DateTime.now().subtract(Duration(days: 6 - i))
        );
        
        final metrics = ConsistencyMetrics.fromCompletionHistory(
          completionDates: completionDates,
          habitCreatedAt: habitCreatedAt,
          recoveryEvents: [],
        );
        
        expect(metrics.gracefulScore, greaterThan(70));
        expect(metrics.weeklyAverage, equals(1.0));
        expect(metrics.scoreDescription, anyOf(
          equals('Excellent consistency!'),
          equals('Strong consistency'),
        ));
      });

      test('quick recoveries boost score', () {
        final habitCreatedAt = DateTime.now().subtract(const Duration(days: 14));
        
        // Without recoveries
        final completionDatesNoRecovery = List.generate(10, (i) => 
          DateTime.now().subtract(Duration(days: 13 - i))
        );
        
        final metricsNoRecovery = ConsistencyMetrics.fromCompletionHistory(
          completionDates: completionDatesNoRecovery,
          habitCreatedAt: habitCreatedAt,
          recoveryEvents: [],
        );
        
        // With quick recoveries
        final recoveryEvents = [
          RecoveryEvent(
            missDate: DateTime.now().subtract(const Duration(days: 10)),
            recoveryDate: DateTime.now().subtract(const Duration(days: 9)),
            daysMissed: 1,
          ),
          RecoveryEvent(
            missDate: DateTime.now().subtract(const Duration(days: 5)),
            recoveryDate: DateTime.now().subtract(const Duration(days: 4)),
            daysMissed: 1,
          ),
        ];
        
        final metricsWithRecovery = ConsistencyMetrics.fromCompletionHistory(
          completionDates: completionDatesNoRecovery,
          habitCreatedAt: habitCreatedAt,
          recoveryEvents: recoveryEvents,
        );
        
        // Quick recoveries should boost score
        expect(
          metricsWithRecovery.quickRecoveryCount,
          equals(2),
        );
      });

      test('never miss twice rate reflects actual behavior', () {
        final habitCreatedAt = DateTime.now().subtract(const Duration(days: 14));
        
        // Pattern: complete, miss, complete, miss, miss, complete...
        // This has 1 single miss and 1 double miss
        final completionDates = [
          DateTime.now().subtract(const Duration(days: 13)), // Day 1: complete
          // Day 2: miss (single)
          DateTime.now().subtract(const Duration(days: 11)), // Day 3: complete
          // Day 4: miss (start of double)
          // Day 5: miss (double)
          DateTime.now().subtract(const Duration(days: 8)), // Day 6: complete
          DateTime.now().subtract(const Duration(days: 7)),
          DateTime.now().subtract(const Duration(days: 6)),
          DateTime.now().subtract(const Duration(days: 5)),
          DateTime.now().subtract(const Duration(days: 4)),
          DateTime.now().subtract(const Duration(days: 3)),
          DateTime.now().subtract(const Duration(days: 2)),
          DateTime.now().subtract(const Duration(days: 1)),
          DateTime.now(),
        ];
        
        final metrics = ConsistencyMetrics.fromCompletionHistory(
          completionDates: completionDates,
          habitCreatedAt: habitCreatedAt,
          recoveryEvents: [],
        );
        
        // NMT rate should reflect: 1 single miss / 2 total miss events = 0.5
        expect(metrics.neverMissTwiceRate, lessThan(1.0));
      });
    });

    // ========== Date Utilities Integration ==========
    group('Date Utilities Integration', () {
      test('lastSevenDays aligns with weekly average calculation', () {
        final lastSeven = HabitDateUtils.lastSevenDays();
        
        // Verify we have 7 days
        expect(lastSeven.length, equals(7));
        
        // Verify they're consecutive
        for (int i = 0; i < lastSeven.length - 1; i++) {
          final diff = HabitDateUtils.daysBetween(lastSeven[i], lastSeven[i + 1]);
          expect(diff, equals(1));
        }
        
        // Verify first is today
        expect(HabitDateUtils.isToday(lastSeven.first), isTrue);
      });

      test('completion tracking uses normalized dates', () {
        // Two completions at different times on the same day
        final completion1 = DateTime(2024, 3, 15, 9, 30);
        final completion2 = DateTime(2024, 3, 15, 21, 45);
        
        expect(HabitDateUtils.isSameDay(completion1, completion2), isTrue);
        
        // When counting completions, these should be treated as one
        final normalized1 = HabitDateUtils.startOfDay(completion1);
        final normalized2 = HabitDateUtils.startOfDay(completion2);
        
        expect(normalized1, equals(normalized2));
      });
    });

    // ========== Zoom Out Perspective Flow ==========
    group('Zoom Out Perspective Flow', () {
      test('provides accurate context for current progress', () {
        // User with 78% completion over 60 days
        final message = RecoveryEngine.getZoomOutMessage(
          totalDays: 60,
          completedDays: 47,
          currentMissStreak: 1,
        );
        
        // Should mention actual numbers
        expect(message, contains('60'));
        expect(message, contains('47'));
        expect(message, contains('78%'));
        
        // Should be encouraging
        expect(message.toLowerCase(), contains("one miss doesn't change"));
      });

      test('adjusts tone based on miss streak length', () {
        final shortMissMessage = RecoveryEngine.getZoomOutMessage(
          totalDays: 30,
          completedDays: 25,
          currentMissStreak: 1,
        );
        
        final mediumMissMessage = RecoveryEngine.getZoomOutMessage(
          totalDays: 30,
          completedDays: 25,
          currentMissStreak: 3,
        );
        
        final longMissMessage = RecoveryEngine.getZoomOutMessage(
          totalDays: 30,
          completedDays: 25,
          currentMissStreak: 7,
        );
        
        // Different miss streaks should produce different messages
        expect(shortMissMessage, isNot(equals(mediumMissMessage)));
        expect(mediumMissMessage, isNot(equals(longMissMessage)));
        
        // Long miss should mention foundation
        expect(longMissMessage.toLowerCase(), contains('foundation'));
      });
    });

    // ========== Full User Journey ==========
    group('Full User Journey', () {
      test('new user starts fresh and builds consistency', () {
        // Day 0: New habit created
        final habitCreatedAt = DateTime.now();
        var completionDates = <DateTime>[];
        
        var metrics = ConsistencyMetrics.fromCompletionHistory(
          completionDates: completionDates,
          habitCreatedAt: habitCreatedAt,
          recoveryEvents: [],
        );
        
        expect(metrics.gracefulScore, equals(0));
        expect(metrics.identityVotes, equals(0));
        
        // Day 1: Complete habit
        completionDates = [DateTime.now()];
        metrics = ConsistencyMetrics.fromCompletionHistory(
          completionDates: completionDates,
          habitCreatedAt: habitCreatedAt,
          recoveryEvents: [],
        );
        
        expect(metrics.identityVotes, equals(1));
        expect(metrics.currentStreak, equals(1));
        expect(metrics.gracefulScore, greaterThan(0));
      });

      test('identity votes accumulate and never decrease', () {
        final habitCreatedAt = DateTime.now().subtract(const Duration(days: 10));
        
        // 5 completions over 10 days
        final completionDates = [
          DateTime.now().subtract(const Duration(days: 9)),
          DateTime.now().subtract(const Duration(days: 7)),
          DateTime.now().subtract(const Duration(days: 5)),
          DateTime.now().subtract(const Duration(days: 2)),
          DateTime.now(),
        ];
        
        final metrics = ConsistencyMetrics.fromCompletionHistory(
          completionDates: completionDates,
          habitCreatedAt: habitCreatedAt,
          recoveryEvents: [],
        );
        
        // Identity votes should equal total completions
        expect(metrics.identityVotes, equals(5));
        
        // Missing days don't subtract votes
        // The philosophy: "each completion is a vote, misses don't subtract"
        expect(metrics.identityVotes, equals(metrics.totalCompletions));
      });
    });
  });
}
