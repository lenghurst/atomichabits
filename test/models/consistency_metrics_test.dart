import 'package:flutter_test/flutter_test.dart';
import 'package:atomic_habits_hook_app/data/models/consistency_metrics.dart';

/// Unit Tests for ConsistencyMetrics
/// 
/// These tests verify the Graceful Consistency scoring system works correctly.
/// This is core business logic that determines how users see their progress.
void main() {
  group('ConsistencyMetrics', () {
    // ========== Score Calculation Tests ==========
    group('calculateGracefulScore', () {
      test('perfect week with no recoveries scores high', () {
        final score = ConsistencyMetrics.calculateGracefulScore(
          sevenDayAverage: 1.0,  // 100% completion
          quickRecoveries: 0,
          completionTimeVariance: 0.0,  // Perfect consistency
          neverMissTwiceRate: 1.0,  // No misses
        );
        
        // Base: 1.0 * 100 * 0.4 = 40
        // Recovery: 0 * 5 = 0 (max 20)
        // Stability: (1 - 0) * 20 = 20
        // NMT: 1.0 * 20 = 20
        // Total: 40 + 0 + 20 + 20 = 80
        expect(score, closeTo(80.0, 0.1));
      });

      test('perfect week with quick recoveries scores higher', () {
        final score = ConsistencyMetrics.calculateGracefulScore(
          sevenDayAverage: 1.0,
          quickRecoveries: 3,  // 3 quick recoveries
          completionTimeVariance: 0.0,
          neverMissTwiceRate: 1.0,
        );
        
        // Base: 40
        // Recovery: 3 * 5 = 15
        // Stability: 20
        // NMT: 20
        // Total: 40 + 15 + 20 + 20 = 95
        expect(score, closeTo(95.0, 0.1));
      });

      test('caps at 100 even with max recoveries', () {
        final score = ConsistencyMetrics.calculateGracefulScore(
          sevenDayAverage: 1.0,
          quickRecoveries: 10,  // More than max
          completionTimeVariance: 0.0,
          neverMissTwiceRate: 1.0,
        );
        
        expect(score, lessThanOrEqualTo(100.0));
      });

      test('50% week scores proportionally', () {
        final score = ConsistencyMetrics.calculateGracefulScore(
          sevenDayAverage: 0.5,
          quickRecoveries: 0,
          completionTimeVariance: 0.5,
          neverMissTwiceRate: 0.5,
        );
        
        // Base: 0.5 * 100 * 0.4 = 20
        // Recovery: 0
        // Stability: (1 - 0.5) * 20 = 10
        // NMT: 0.5 * 20 = 10
        // Total: 20 + 0 + 10 + 10 = 40
        expect(score, closeTo(40.0, 0.1));
      });

      test('zero completion scores minimum', () {
        final score = ConsistencyMetrics.calculateGracefulScore(
          sevenDayAverage: 0.0,
          quickRecoveries: 0,
          completionTimeVariance: 1.0,
          neverMissTwiceRate: 0.0,
        );
        
        expect(score, equals(0.0));
      });

      test('never goes negative', () {
        final score = ConsistencyMetrics.calculateGracefulScore(
          sevenDayAverage: -0.5,  // Invalid but should handle
          quickRecoveries: -1,
          completionTimeVariance: 2.0,
          neverMissTwiceRate: -0.5,
        );
        
        expect(score, greaterThanOrEqualTo(0.0));
      });
    });

    // ========== Score Description Tests ==========
    group('scoreDescription', () {
      test('90+ is Excellent consistency!', () {
        final metrics = _createMetricsWithScore(95);
        expect(metrics.scoreDescription, equals('Excellent consistency!'));
      });

      test('75-89 is Strong consistency', () {
        final metrics = _createMetricsWithScore(80);
        expect(metrics.scoreDescription, equals('Strong consistency'));
      });

      test('60-74 is Good progress', () {
        final metrics = _createMetricsWithScore(65);
        expect(metrics.scoreDescription, equals('Good progress'));
      });

      test('40-59 is Building momentum', () {
        final metrics = _createMetricsWithScore(50);
        expect(metrics.scoreDescription, equals('Building momentum'));
      });

      test('20-39 is Getting started', () {
        final metrics = _createMetricsWithScore(30);
        expect(metrics.scoreDescription, equals('Getting started'));
      });

      test('0-19 is Every day is a fresh start', () {
        final metrics = _createMetricsWithScore(10);
        expect(metrics.scoreDescription, equals('Every day is a fresh start'));
      });
    });

    // ========== Score Emoji Tests ==========
    group('scoreEmoji', () {
      test('90+ is star', () {
        final metrics = _createMetricsWithScore(95);
        expect(metrics.scoreEmoji, equals('🌟'));
      });

      test('75-89 is flexed arm', () {
        final metrics = _createMetricsWithScore(80);
        expect(metrics.scoreEmoji, equals('💪'));
      });

      test('60-74 is thumbs up', () {
        final metrics = _createMetricsWithScore(65);
        expect(metrics.scoreEmoji, equals('👍'));
      });

      test('40-59 is seedling', () {
        final metrics = _createMetricsWithScore(50);
        expect(metrics.scoreEmoji, equals('🌱'));
      });

      test('20-39 is rocket', () {
        final metrics = _createMetricsWithScore(30);
        expect(metrics.scoreEmoji, equals('🚀'));
      });

      test('0-19 is sparkles', () {
        final metrics = _createMetricsWithScore(10);
        expect(metrics.scoreEmoji, equals('✨'));
      });
    });

    // ========== Recovery Urgency Tests ==========
    group('recoveryUrgency', () {
      test('0-1 miss streak is gentle', () {
        final metrics0 = _createMetricsWithMissStreak(0);
        final metrics1 = _createMetricsWithMissStreak(1);
        
        expect(metrics0.recoveryUrgency, equals(RecoveryUrgency.gentle));
        expect(metrics1.recoveryUrgency, equals(RecoveryUrgency.gentle));
      });

      test('2 miss streak is important', () {
        final metrics = _createMetricsWithMissStreak(2);
        expect(metrics.recoveryUrgency, equals(RecoveryUrgency.important));
      });

      test('3+ miss streak is compassionate', () {
        final metrics3 = _createMetricsWithMissStreak(3);
        final metrics5 = _createMetricsWithMissStreak(5);
        final metrics10 = _createMetricsWithMissStreak(10);
        
        expect(metrics3.recoveryUrgency, equals(RecoveryUrgency.compassionate));
        expect(metrics5.recoveryUrgency, equals(RecoveryUrgency.compassionate));
        expect(metrics10.recoveryUrgency, equals(RecoveryUrgency.compassionate));
      });
    });

    // ========== needsRecovery Tests ==========
    group('needsRecovery', () {
      test('returns false when no misses', () {
        final metrics = _createMetricsWithMissStreak(0);
        expect(metrics.needsRecovery, isFalse);
      });

      test('returns true when 1+ misses', () {
        final metrics1 = _createMetricsWithMissStreak(1);
        final metrics3 = _createMetricsWithMissStreak(3);
        
        expect(metrics1.needsRecovery, isTrue);
        expect(metrics3.needsRecovery, isTrue);
      });
    });

    // ========== showUpRate Tests ==========
    group('showUpRate', () {
      test('calculates correct rate', () {
        final metrics = ConsistencyMetrics(
          gracefulScore: 50,
          daysShowedUp: 15,
          totalDays: 30,
          weeklyAverage: 0.5,
          monthlyAverage: 0.5,
          recoveryCount: 0,
          quickRecoveryCount: 0,
          longestStreak: 5,
          currentStreak: 0,
          totalCompletions: 15,
          identityVotes: 15,
          neverMissTwiceRate: 0.5,
          currentMissStreak: 1,
        );
        
        expect(metrics.showUpRate, closeTo(0.5, 0.001));
      });

      test('returns 0 when totalDays is 0', () {
        final metrics = ConsistencyMetrics(
          gracefulScore: 0,
          daysShowedUp: 0,
          totalDays: 0,
          weeklyAverage: 0,
          monthlyAverage: 0,
          recoveryCount: 0,
          quickRecoveryCount: 0,
          longestStreak: 0,
          currentStreak: 0,
          totalCompletions: 0,
          identityVotes: 0,
          neverMissTwiceRate: 1.0,
          currentMissStreak: 0,
        );
        
        expect(metrics.showUpRate, equals(0.0));
      });
    });

    // ========== empty() Factory Tests ==========
    group('empty factory', () {
      test('creates metrics with all zeros', () {
        final metrics = ConsistencyMetrics.empty();
        
        expect(metrics.gracefulScore, equals(0));
        expect(metrics.daysShowedUp, equals(0));
        expect(metrics.totalDays, equals(0));
        expect(metrics.weeklyAverage, equals(0));
        expect(metrics.monthlyAverage, equals(0));
        expect(metrics.recoveryCount, equals(0));
        expect(metrics.quickRecoveryCount, equals(0));
        expect(metrics.currentStreak, equals(0));
        expect(metrics.longestStreak, equals(0));
        expect(metrics.currentMissStreak, equals(0));
      });

      test('empty starts with optimistic NMT rate', () {
        final metrics = ConsistencyMetrics.empty();
        expect(metrics.neverMissTwiceRate, equals(1.0));
      });
    });

    // ========== JSON Serialization Tests ==========
    group('JSON serialization', () {
      test('toJson and fromJson roundtrip', () {
        final original = ConsistencyMetrics(
          gracefulScore: 75.5,
          daysShowedUp: 20,
          totalDays: 30,
          weeklyAverage: 0.85,
          monthlyAverage: 0.67,
          recoveryCount: 3,
          quickRecoveryCount: 2,
          longestStreak: 10,
          currentStreak: 5,
          totalCompletions: 20,
          identityVotes: 20,
          neverMissTwiceRate: 0.8,
          currentMissStreak: 0,
          recentRecoveries: [],
          scoreChange: 2.5,
        );
        
        final json = original.toJson();
        final restored = ConsistencyMetrics.fromJson(json);
        
        expect(restored.gracefulScore, equals(original.gracefulScore));
        expect(restored.daysShowedUp, equals(original.daysShowedUp));
        expect(restored.weeklyAverage, equals(original.weeklyAverage));
        expect(restored.neverMissTwiceRate, equals(original.neverMissTwiceRate));
        expect(restored.scoreChange, equals(original.scoreChange));
      });

      test('fromJson handles missing fields with defaults', () {
        final json = <String, dynamic>{};
        final metrics = ConsistencyMetrics.fromJson(json);
        
        expect(metrics.gracefulScore, equals(0));
        expect(metrics.neverMissTwiceRate, equals(1.0));
        expect(metrics.recentRecoveries, isEmpty);
      });
    });

    // ========== copyWith Tests ==========
    group('copyWith', () {
      test('copies with updated field', () {
        final original = _createMetricsWithScore(50);
        final updated = original.copyWith(gracefulScore: 75);
        
        expect(updated.gracefulScore, equals(75));
        expect(updated.daysShowedUp, equals(original.daysShowedUp));
      });

      test('does not modify original', () {
        final original = _createMetricsWithScore(50);
        original.copyWith(gracefulScore: 75);
        
        expect(original.gracefulScore, equals(50));
      });
    });
  });

  // ========== RecoveryEvent Tests ==========
  group('RecoveryEvent', () {
    test('isQuickRecovery is true for 1 day miss', () {
      final event = RecoveryEvent(
        missDate: DateTime(2024, 3, 14),
        recoveryDate: DateTime(2024, 3, 15),
        daysMissed: 1,
      );
      
      expect(event.isQuickRecovery, isTrue);
    });

    test('isQuickRecovery is false for 2+ day miss', () {
      final event = RecoveryEvent(
        missDate: DateTime(2024, 3, 13),
        recoveryDate: DateTime(2024, 3, 15),
        daysMissed: 2,
      );
      
      expect(event.isQuickRecovery, isFalse);
    });

    test('JSON roundtrip preserves all fields', () {
      final original = RecoveryEvent(
        missDate: DateTime(2024, 3, 14),
        recoveryDate: DateTime(2024, 3, 15),
        daysMissed: 1,
        missReason: 'Busy',
        usedTinyVersion: true,
      );
      
      final json = original.toJson();
      final restored = RecoveryEvent.fromJson(json);
      
      expect(restored.daysMissed, equals(original.daysMissed));
      expect(restored.missReason, equals(original.missReason));
      expect(restored.usedTinyVersion, equals(original.usedTinyVersion));
    });
  });

  // ========== MissReason Tests ==========
  group('MissReason', () {
    test('fromString returns correct enum', () {
      expect(MissReason.fromString('busy'), equals(MissReason.busy));
      expect(MissReason.fromString('tired'), equals(MissReason.tired));
      expect(MissReason.fromString('forgot'), equals(MissReason.forgot));
    });

    test('fromString returns null for invalid value', () {
      expect(MissReason.fromString('invalid'), isNull);
      expect(MissReason.fromString(null), isNull);
    });

    test('all miss reasons have emoji', () {
      for (final reason in MissReason.values) {
        expect(reason.emoji, isNotEmpty);
      }
    });

    test('all miss reasons have label', () {
      for (final reason in MissReason.values) {
        expect(reason.label, isNotEmpty);
      }
    });
  });

  // ========== RecoveryUrgency Tests ==========
  group('RecoveryUrgency', () {
    test('enum has exactly 3 values', () {
      expect(RecoveryUrgency.values.length, equals(3));
    });

    test('values are gentle, important, compassionate', () {
      expect(RecoveryUrgency.values, contains(RecoveryUrgency.gentle));
      expect(RecoveryUrgency.values, contains(RecoveryUrgency.important));
      expect(RecoveryUrgency.values, contains(RecoveryUrgency.compassionate));
    });
  });
}

// ========== Test Helpers ==========

/// Creates metrics with a specific graceful score
ConsistencyMetrics _createMetricsWithScore(double score) {
  return ConsistencyMetrics(
    gracefulScore: score,
    daysShowedUp: 10,
    totalDays: 14,
    weeklyAverage: 0.7,
    monthlyAverage: 0.65,
    recoveryCount: 1,
    quickRecoveryCount: 1,
    longestStreak: 5,
    currentStreak: 3,
    totalCompletions: 10,
    identityVotes: 10,
    neverMissTwiceRate: 0.8,
    currentMissStreak: 0,
  );
}

/// Creates metrics with a specific miss streak
ConsistencyMetrics _createMetricsWithMissStreak(int missStreak) {
  return ConsistencyMetrics(
    gracefulScore: 50,
    daysShowedUp: 10,
    totalDays: 14,
    weeklyAverage: 0.7,
    monthlyAverage: 0.65,
    recoveryCount: 1,
    quickRecoveryCount: 1,
    longestStreak: 5,
    currentStreak: missStreak == 0 ? 3 : 0,
    totalCompletions: 10,
    identityVotes: 10,
    neverMissTwiceRate: 0.8,
    currentMissStreak: missStreak,
  );
}
