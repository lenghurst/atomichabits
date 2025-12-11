import 'package:flutter_test/flutter_test.dart';
import 'package:atomic_habits_hook_app/data/services/recovery_engine.dart';
import 'package:atomic_habits_hook_app/data/models/habit.dart';
import 'package:atomic_habits_hook_app/data/models/user_profile.dart';
import 'package:atomic_habits_hook_app/data/models/consistency_metrics.dart';

/// Unit Tests for RecoveryEngine
/// 
/// These tests verify the "Never Miss Twice" recovery system logic.
/// This is critical business logic that determines user experience.
void main() {
  late Habit testHabit;
  late UserProfile testProfile;

  setUp(() {
    // Create a habit that was created 30 days ago
    testHabit = Habit(
      id: 'test-habit',
      name: 'Read Daily',
      tinyVersion: 'Read one page',
      implementationTime: '09:00',
      implementationLocation: 'In bed',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );

    testProfile = UserProfile(
      name: 'Test User',
      identity: 'I am a reader',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
  });

  group('RecoveryEngine', () {
    // ========== checkRecoveryNeed Tests ==========
    group('checkRecoveryNeed', () {
      test('returns null when completed today', () {
        final today = DateTime.now();
        final completions = [today];

        final result = RecoveryEngine.checkRecoveryNeed(
          habit: testHabit,
          profile: testProfile,
          completionHistory: completions,
        );

        expect(result, isNull);
      });

      test('returns gentle urgency for 1 day miss', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final completions = [yesterday];

        final result = RecoveryEngine.checkRecoveryNeed(
          habit: testHabit,
          profile: testProfile,
          completionHistory: completions,
        );

        expect(result, isNotNull);
        expect(result!.urgency, equals(RecoveryUrgency.gentle));
        expect(result.daysMissed, equals(1));
      });

      test('returns important urgency for 2 day miss', () {
        final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
        final completions = [twoDaysAgo];

        final result = RecoveryEngine.checkRecoveryNeed(
          habit: testHabit,
          profile: testProfile,
          completionHistory: completions,
        );

        expect(result, isNotNull);
        expect(result!.urgency, equals(RecoveryUrgency.important));
        expect(result.daysMissed, equals(2));
      });

      test('returns compassionate urgency for 3+ day miss', () {
        final fiveDaysAgo = DateTime.now().subtract(const Duration(days: 5));
        final completions = [fiveDaysAgo];

        final result = RecoveryEngine.checkRecoveryNeed(
          habit: testHabit,
          profile: testProfile,
          completionHistory: completions,
        );

        expect(result, isNotNull);
        expect(result!.urgency, equals(RecoveryUrgency.compassionate));
        expect(result.daysMissed, greaterThanOrEqualTo(3));
      });

      test('returns null for new habit created today', () {
        final newHabit = Habit(
          id: 'new-habit',
          name: 'New Habit',
          tinyVersion: 'Start small',
          implementationTime: '09:00',
          implementationLocation: 'Home',
          createdAt: DateTime.now(),
        );

        final result = RecoveryEngine.checkRecoveryNeed(
          habit: newHabit,
          profile: testProfile,
          completionHistory: [],
        );

        expect(result, isNull);
      });

      test('handles empty completion history', () {
        final result = RecoveryEngine.checkRecoveryNeed(
          habit: testHabit,
          profile: testProfile,
          completionHistory: [],
        );

        // Should return recovery need since habit was created 30 days ago
        expect(result, isNotNull);
        expect(result!.urgency, equals(RecoveryUrgency.compassionate));
      });

      test('correctly counts consecutive misses', () {
        // Completed 5 days ago, then stopped
        final completions = [
          DateTime.now().subtract(const Duration(days: 5)),
        ];

        final result = RecoveryEngine.checkRecoveryNeed(
          habit: testHabit,
          profile: testProfile,
          completionHistory: completions,
        );

        expect(result, isNotNull);
        expect(result!.daysMissed, equals(5));
      });
    });

    // ========== Recovery Title Tests ==========
    group('getRecoveryTitle', () {
      test('gentle returns Never Miss Twice', () {
        final title = RecoveryEngine.getRecoveryTitle(RecoveryUrgency.gentle);
        expect(title, equals('Never Miss Twice'));
      });

      test('important returns Day 2 – Critical Moment', () {
        final title = RecoveryEngine.getRecoveryTitle(RecoveryUrgency.important);
        expect(title, equals('Day 2 – Critical Moment'));
      });

      test('compassionate returns Welcome Back', () {
        final title = RecoveryEngine.getRecoveryTitle(RecoveryUrgency.compassionate);
        expect(title, equals('Welcome Back'));
      });
    });

    // ========== Recovery Subtitle Tests ==========
    group('getRecoverySubtitle', () {
      test('gentle subtitle is encouraging', () {
        final subtitle = RecoveryEngine.getRecoverySubtitle(RecoveryUrgency.gentle, 1);
        expect(subtitle, equals("One miss doesn't define you"));
      });

      test('important subtitle motivates', () {
        final subtitle = RecoveryEngine.getRecoverySubtitle(RecoveryUrgency.important, 2);
        expect(subtitle, equals('This is where champions are made'));
      });

      test('compassionate subtitle shows days and welcomes', () {
        final subtitle = RecoveryEngine.getRecoverySubtitle(RecoveryUrgency.compassionate, 5);
        expect(subtitle, contains('5 days away'));
        expect(subtitle, contains('Ready when you are'));
      });
    });

    // ========== Recovery Action Text Tests ==========
    group('getRecoveryActionText', () {
      test('gentle action is do 2-min version', () {
        final action = RecoveryEngine.getRecoveryActionText(RecoveryUrgency.gentle);
        expect(action.toLowerCase(), contains('2-min'));
      });

      test('important action is break the pattern', () {
        final action = RecoveryEngine.getRecoveryActionText(RecoveryUrgency.important);
        expect(action.toLowerCase(), contains('pattern'));
      });

      test('compassionate action is start fresh', () {
        final action = RecoveryEngine.getRecoveryActionText(RecoveryUrgency.compassionate);
        expect(action.toLowerCase(), contains('fresh'));
      });
    });

    // ========== Recovery Emoji Tests ==========
    group('getRecoveryEmoji', () {
      test('gentle returns flexed arm', () {
        expect(RecoveryEngine.getRecoveryEmoji(RecoveryUrgency.gentle), equals('💪'));
      });

      test('important returns lightning', () {
        expect(RecoveryEngine.getRecoveryEmoji(RecoveryUrgency.important), equals('⚡'));
      });

      test('compassionate returns hugging', () {
        expect(RecoveryEngine.getRecoveryEmoji(RecoveryUrgency.compassionate), equals('🤗'));
      });
    });

    // ========== Recovery Message Tests ==========
    group('getRecoveryMessage', () {
      test('includes habit tiny version', () {
        final need = RecoveryNeed(
          habit: testHabit,
          profile: testProfile,
          daysMissed: 1,
          urgency: RecoveryUrgency.gentle,
        );

        final message = RecoveryEngine.getRecoveryMessage(need);
        expect(message, contains(testHabit.tinyVersion));
      });

      test('gentle message mentions never miss twice concept', () {
        final need = RecoveryNeed(
          habit: testHabit,
          profile: testProfile,
          daysMissed: 1,
          urgency: RecoveryUrgency.gentle,
        );

        final message = RecoveryEngine.getRecoveryMessage(need);
        // Should mention the concept of not missing twice
        expect(
          message.toLowerCase().contains('miss') || 
          message.toLowerCase().contains('two') ||
          message.toLowerCase().contains('pattern'),
          isTrue,
        );
      });

      test('compassionate message is non-shaming', () {
        final need = RecoveryNeed(
          habit: testHabit,
          profile: testProfile,
          daysMissed: 5,
          urgency: RecoveryUrgency.compassionate,
        );

        final message = RecoveryEngine.getRecoveryMessage(need);
        
        // Should not contain shame words
        expect(message.toLowerCase().contains('fail'), isFalse);
        expect(message.toLowerCase().contains('bad'), isFalse);
        expect(message.toLowerCase().contains('lazy'), isFalse);
        
        // Should be encouraging
        expect(
          message.toLowerCase().contains('welcome') ||
          message.toLowerCase().contains('okay') ||
          message.toLowerCase().contains('happens'),
          isTrue,
        );
      });
    });

    // ========== Zoom Out Message Tests ==========
    group('getZoomOutMessage', () {
      test('1 day miss emphasizes context', () {
        final message = RecoveryEngine.getZoomOutMessage(
          totalDays: 30,
          completedDays: 25,
          currentMissStreak: 1,
        );

        expect(message, contains('30'));
        expect(message, contains('25'));
        expect(message.toLowerCase(), contains("one miss doesn't change"));
      });

      test('2-3 day miss encourages', () {
        final message = RecoveryEngine.getZoomOutMessage(
          totalDays: 30,
          completedDays: 20,
          currentMissStreak: 2,
        );

        expect(message, contains('20'));
        expect(message.toLowerCase(), contains("don't erase"));
      });

      test('4+ day miss acknowledges foundation', () {
        final message = RecoveryEngine.getZoomOutMessage(
          totalDays: 30,
          completedDays: 15,
          currentMissStreak: 5,
        );

        expect(message, contains('15'));
        expect(message.toLowerCase(), contains('foundation'));
      });

      test('calculates percentage correctly', () {
        final message = RecoveryEngine.getZoomOutMessage(
          totalDays: 100,
          completedDays: 78,
          currentMissStreak: 1,
        );

        expect(message, contains('78%'));
      });
    });

    // ========== Recovery Stats Tests ==========
    group('calculateRecoveryStats', () {
      test('returns optimistic defaults for empty list', () {
        final stats = RecoveryEngine.calculateRecoveryStats([]);

        expect(stats.totalRecoveries, equals(0));
        expect(stats.quickRecoveries, equals(0));
        expect(stats.averageRecoveryDays, equals(0));
        expect(stats.recoveryRate, equals(1.0));
      });

      test('correctly counts quick recoveries', () {
        final events = [
          RecoveryEvent(
            missDate: DateTime(2024, 3, 10),
            recoveryDate: DateTime(2024, 3, 11),
            daysMissed: 1,  // Quick recovery
          ),
          RecoveryEvent(
            missDate: DateTime(2024, 3, 15),
            recoveryDate: DateTime(2024, 3, 16),
            daysMissed: 1,  // Quick recovery
          ),
          RecoveryEvent(
            missDate: DateTime(2024, 3, 20),
            recoveryDate: DateTime(2024, 3, 23),
            daysMissed: 3,  // Not quick
          ),
        ];

        final stats = RecoveryEngine.calculateRecoveryStats(events);

        expect(stats.totalRecoveries, equals(3));
        expect(stats.quickRecoveries, equals(2));
      });

      test('calculates average recovery days', () {
        final events = [
          RecoveryEvent(
            missDate: DateTime(2024, 3, 10),
            recoveryDate: DateTime(2024, 3, 11),
            daysMissed: 1,
          ),
          RecoveryEvent(
            missDate: DateTime(2024, 3, 15),
            recoveryDate: DateTime(2024, 3, 18),
            daysMissed: 3,
          ),
        ];

        final stats = RecoveryEngine.calculateRecoveryStats(events);

        // Average: (1 + 3) / 2 = 2
        expect(stats.averageRecoveryDays, equals(2.0));
      });

      test('finds longest gap', () {
        final events = [
          RecoveryEvent(
            missDate: DateTime(2024, 3, 10),
            recoveryDate: DateTime(2024, 3, 11),
            daysMissed: 1,
          ),
          RecoveryEvent(
            missDate: DateTime(2024, 3, 15),
            recoveryDate: DateTime(2024, 3, 22),
            daysMissed: 7,
          ),
          RecoveryEvent(
            missDate: DateTime(2024, 3, 25),
            recoveryDate: DateTime(2024, 3, 28),
            daysMissed: 3,
          ),
        ];

        final stats = RecoveryEngine.calculateRecoveryStats(events);

        expect(stats.longestGap, equals(7));
      });
    });

    // ========== Notification Message Tests ==========
    group('getRecoveryNotificationMessage', () {
      test('gentle notification mentions 2-min version', () {
        final need = RecoveryNeed(
          habit: testHabit,
          profile: testProfile,
          daysMissed: 1,
          urgency: RecoveryUrgency.gentle,
        );

        final message = RecoveryEngine.getRecoveryNotificationMessage(need);
        expect(message, contains(testHabit.tinyVersion));
      });

      test('important notification emphasizes day 2', () {
        final need = RecoveryNeed(
          habit: testHabit,
          profile: testProfile,
          daysMissed: 2,
          urgency: RecoveryUrgency.important,
        );

        final message = RecoveryEngine.getRecoveryNotificationMessage(need);
        expect(message.toLowerCase(), contains('day 2'));
      });

      test('compassionate notification is welcoming', () {
        final need = RecoveryNeed(
          habit: testHabit,
          profile: testProfile,
          daysMissed: 5,
          urgency: RecoveryUrgency.compassionate,
        );

        final message = RecoveryEngine.getRecoveryNotificationMessage(need);
        expect(message.toLowerCase(), contains('miss you'));
      });
    });
  });

  // ========== RecoveryNeed Tests ==========
  group('RecoveryNeed', () {
    group('timeSinceLastCompletion', () {
      test('returns No completions yet when null', () {
        final need = RecoveryNeed(
          habit: testHabit,
          profile: testProfile,
          daysMissed: 5,
          lastCompletionDate: null,
          urgency: RecoveryUrgency.compassionate,
        );

        expect(need.timeSinceLastCompletion, equals('No completions yet'));
      });

      test('returns Missed yesterday for 1 day', () {
        final need = RecoveryNeed(
          habit: testHabit,
          profile: testProfile,
          daysMissed: 1,
          lastCompletionDate: DateTime.now().subtract(const Duration(days: 1)),
          urgency: RecoveryUrgency.gentle,
        );

        expect(need.timeSinceLastCompletion, equals('Missed yesterday'));
      });

      test('returns 2 days ago for 2 days', () {
        final need = RecoveryNeed(
          habit: testHabit,
          profile: testProfile,
          daysMissed: 2,
          lastCompletionDate: DateTime.now().subtract(const Duration(days: 2)),
          urgency: RecoveryUrgency.important,
        );

        expect(need.timeSinceLastCompletion, equals('2 days ago'));
      });

      test('returns About a week ago for 7-13 days', () {
        final need = RecoveryNeed(
          habit: testHabit,
          profile: testProfile,
          daysMissed: 10,
          lastCompletionDate: DateTime.now().subtract(const Duration(days: 10)),
          urgency: RecoveryUrgency.compassionate,
        );

        expect(need.timeSinceLastCompletion, equals('About a week ago'));
      });

      test('returns Over a month ago for 30+ days', () {
        final need = RecoveryNeed(
          habit: testHabit,
          profile: testProfile,
          daysMissed: 45,
          lastCompletionDate: DateTime.now().subtract(const Duration(days: 45)),
          urgency: RecoveryUrgency.compassionate,
        );

        expect(need.timeSinceLastCompletion, equals('Over a month ago'));
      });
    });
  });

  // ========== RecoveryStats Tests ==========
  group('RecoveryStats', () {
    group('recoveryRateDescription', () {
      test('80%+ is Excellent', () {
        final stats = RecoveryStats(
          totalRecoveries: 10,
          quickRecoveries: 9,
          averageRecoveryDays: 1.2,
          longestGap: 3,
          recoveryRate: 0.9,
        );

        expect(stats.recoveryRateDescription, equals('Excellent recovery rate!'));
      });

      test('60-79% is Good', () {
        final stats = RecoveryStats(
          totalRecoveries: 10,
          quickRecoveries: 7,
          averageRecoveryDays: 1.5,
          longestGap: 4,
          recoveryRate: 0.7,
        );

        expect(stats.recoveryRateDescription, equals('Good at bouncing back'));
      });

      test('40-59% is Building', () {
        final stats = RecoveryStats(
          totalRecoveries: 10,
          quickRecoveries: 5,
          averageRecoveryDays: 2.0,
          longestGap: 5,
          recoveryRate: 0.5,
        );

        expect(stats.recoveryRateDescription, equals('Building recovery skills'));
      });

      test('below 40% is Room to improve', () {
        final stats = RecoveryStats(
          totalRecoveries: 10,
          quickRecoveries: 2,
          averageRecoveryDays: 3.0,
          longestGap: 7,
          recoveryRate: 0.2,
        );

        expect(stats.recoveryRateDescription, equals('Room to improve'));
      });
    });
  });
}
