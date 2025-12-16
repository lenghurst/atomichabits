/// Phase 19: The Intelligent Nudge - OptimizedTimeFinder Unit Tests
/// 
/// Tests for drift detection algorithm that identifies when users
/// consistently complete habits at different times than scheduled.
/// 
/// Test Scenarios:
/// - Significant drift detection (9:00 AM -> 9:45 AM)
/// - Outlier handling (ignore one-off 4:00 PM completions)
/// - Midnight crossing (11 PM scheduled, 1 AM actual)
/// - Insufficient data handling
/// - Weekend variance detection
/// - Confidence calculation

import 'package:flutter_test/flutter_test.dart';
import 'package:atomic_habits/data/services/smart_nudge/optimized_time_finder.dart';
import 'package:atomic_habits/data/services/smart_nudge/drift_analysis.dart';

void main() {
  group('OptimizedTimeFinder', () {
    late OptimizedTimeFinder finder;
    
    setUp(() {
      finder = OptimizedTimeFinder();
    });

    group('Basic Drift Detection', () {
      test('detects significant drift (45+ minutes)', () {
        // Habit scheduled for 9:00 AM but consistently done at 10:00 AM
        final completionHistory = _generateCompletions(
          count: 14,
          hour: 10,
          minute: 0,
          varianceMinutes: 10,
        );
        
        final analysis = finder.analyze(
          completionHistory: completionHistory,
          scheduledTime: '09:00',
        );
        
        expect(analysis.shouldSuggest, isTrue);
        expect(analysis.driftMinutes, greaterThanOrEqualTo(45));
        expect(analysis.confidence, greaterThan(0.6));
        expect(analysis.suggestedTime?.hour, equals(10));
      });

      test('does not suggest change for minor drift (<45 minutes)', () {
        // Habit scheduled for 9:00 AM, done around 9:20 AM
        final completionHistory = _generateCompletions(
          count: 14,
          hour: 9,
          minute: 20,
          varianceMinutes: 10,
        );
        
        final analysis = finder.analyze(
          completionHistory: completionHistory,
          scheduledTime: '09:00',
        );
        
        expect(analysis.shouldSuggest, isFalse);
        expect(analysis.driftMinutes.abs(), lessThan(45));
      });

      test('detects drift in earlier direction', () {
        // Habit scheduled for 9:00 AM but done at 7:30 AM
        final completionHistory = _generateCompletions(
          count: 14,
          hour: 7,
          minute: 30,
          varianceMinutes: 10,
        );
        
        final analysis = finder.analyze(
          completionHistory: completionHistory,
          scheduledTime: '09:00',
        );
        
        expect(analysis.shouldSuggest, isTrue);
        expect(analysis.driftMinutes, lessThan(0)); // Earlier = negative
        expect(analysis.direction, equals(DriftDirection.earlier));
      });
    });

    group('Outlier Handling', () {
      test('ignores random one-off 4:00 PM completions', () {
        // Mostly 9:00 AM completions with one 4:00 PM outlier
        final completionHistory = <DateTime>[
          // 13 completions around 9:00 AM
          ..._generateCompletions(count: 13, hour: 9, minute: 0, varianceMinutes: 15),
          // 1 outlier at 4:00 PM
          DateTime.now().subtract(const Duration(days: 5)).copyWith(hour: 16, minute: 0),
        ];
        
        final analysis = finder.analyze(
          completionHistory: completionHistory,
          scheduledTime: '09:00',
        );
        
        // Should not be influenced by the outlier
        expect(analysis.driftMinutes.abs(), lessThan(45));
        expect(analysis.medianTime.hour, equals(9));
      });

      test('handles multiple outliers correctly', () {
        // Mix of 9 AM completions and some wild outliers
        final completionHistory = <DateTime>[
          ..._generateCompletions(count: 10, hour: 9, minute: 15, varianceMinutes: 10),
          // Outliers
          DateTime.now().subtract(const Duration(days: 3)).copyWith(hour: 15, minute: 0),
          DateTime.now().subtract(const Duration(days: 7)).copyWith(hour: 23, minute: 0),
          DateTime.now().subtract(const Duration(days: 12)).copyWith(hour: 5, minute: 0),
        ];
        
        final analysis = finder.analyze(
          completionHistory: completionHistory,
          scheduledTime: '09:00',
        );
        
        // Median should be around 9:15, not influenced by outliers
        expect(analysis.medianTime.hour, equals(9));
        expect(analysis.medianTime.minute, inInclusiveRange(0, 30));
      });
    });

    group('Midnight Crossing', () {
      test('handles scheduled 11 PM, actual 1 AM correctly', () {
        // Habit scheduled at 11 PM but done at 1 AM (2 hours later)
        final completionHistory = _generateCompletions(
          count: 14,
          hour: 1,
          minute: 0,
          varianceMinutes: 15,
        );
        
        final analysis = finder.analyze(
          completionHistory: completionHistory,
          scheduledTime: '23:00',
        );
        
        // Should detect 2 hours drift (not -22 hours)
        expect(analysis.shouldSuggest, isTrue);
        expect(analysis.driftMinutes, greaterThan(0)); // Later = positive
        expect(analysis.driftMinutes, equals(120)); // 2 hours
      });

      test('handles scheduled 1 AM, actual 11 PM correctly', () {
        // Habit scheduled at 1 AM but done at 11 PM (2 hours earlier)
        final completionHistory = _generateCompletions(
          count: 14,
          hour: 23,
          minute: 0,
          varianceMinutes: 15,
        );
        
        final analysis = finder.analyze(
          completionHistory: completionHistory,
          scheduledTime: '01:00',
        );
        
        // Should detect -2 hours drift (not +22 hours)
        expect(analysis.shouldSuggest, isTrue);
        expect(analysis.driftMinutes, lessThan(0)); // Earlier = negative
        expect(analysis.driftMinutes, equals(-120)); // 2 hours earlier
      });
    });

    group('Insufficient Data', () {
      test('returns insufficientData when < 7 completions', () {
        final completionHistory = _generateCompletions(
          count: 5,
          hour: 10,
          minute: 0,
          varianceMinutes: 10,
        );
        
        final analysis = finder.analyze(
          completionHistory: completionHistory,
          scheduledTime: '09:00',
        );
        
        expect(analysis.shouldSuggest, isFalse);
        expect(analysis.confidence, equals(0));
        expect(analysis.description, contains('Not enough data'));
      });

      test('returns insufficientData when completions are too old', () {
        // Completions from 60+ days ago
        final completionHistory = List.generate(14, (i) =>
          DateTime.now()
            .subtract(Duration(days: 60 + i))
            .copyWith(hour: 10, minute: 0),
        );
        
        final analysis = finder.analyze(
          completionHistory: completionHistory,
          scheduledTime: '09:00',
        );
        
        // Should have insufficient recent data
        expect(analysis.shouldSuggest, isFalse);
      });
    });

    group('Confidence Calculation', () {
      test('higher confidence with more consistent data', () {
        // Very consistent completions (low variance)
        final consistentHistory = _generateCompletions(
          count: 21,
          hour: 10,
          minute: 0,
          varianceMinutes: 5, // Low variance
        );
        
        // Less consistent completions (high variance)
        final inconsistentHistory = _generateCompletions(
          count: 21,
          hour: 10,
          minute: 0,
          varianceMinutes: 45, // High variance
        );
        
        final consistentAnalysis = finder.analyze(
          completionHistory: consistentHistory,
          scheduledTime: '09:00',
        );
        
        final inconsistentAnalysis = finder.analyze(
          completionHistory: inconsistentHistory,
          scheduledTime: '09:00',
        );
        
        expect(consistentAnalysis.confidence, 
            greaterThan(inconsistentAnalysis.confidence));
      });

      test('higher confidence with more data points', () {
        final smallSample = _generateCompletions(
          count: 7,
          hour: 10,
          minute: 0,
          varianceMinutes: 15,
        );
        
        final largeSample = _generateCompletions(
          count: 21,
          hour: 10,
          minute: 0,
          varianceMinutes: 15,
        );
        
        final smallAnalysis = finder.analyze(
          completionHistory: smallSample,
          scheduledTime: '09:00',
        );
        
        final largeAnalysis = finder.analyze(
          completionHistory: largeSample,
          scheduledTime: '09:00',
        );
        
        expect(largeAnalysis.confidence, greaterThan(smallAnalysis.confidence));
      });
    });

    group('Time Rounding', () {
      test('suggested time is rounded to nearest 15 minutes', () {
        // Completions around 10:07 AM
        final completionHistory = _generateCompletions(
          count: 14,
          hour: 10,
          minute: 7,
          varianceMinutes: 5,
        );
        
        final analysis = finder.analyze(
          completionHistory: completionHistory,
          scheduledTime: '09:00',
        );
        
        if (analysis.suggestedTime != null) {
          // Should round to 10:00 or 10:15
          expect(analysis.suggestedTime!.minute % 15, equals(0));
        }
      });
    });

    group('Weekly Pattern Detection', () {
      test('detects weekend variance', () {
        // Weekday completions at 8 AM
        final weekdayCompletions = List.generate(10, (i) {
          // Generate dates that fall on weekdays
          var date = DateTime.now().subtract(Duration(days: i * 2));
          while (date.weekday >= 6) {
            date = date.subtract(const Duration(days: 1));
          }
          return date.copyWith(hour: 8, minute: 0);
        });
        
        // Weekend completions at 11 AM
        final weekendCompletions = List.generate(4, (i) {
          // Generate dates that fall on weekends
          var date = DateTime.now().subtract(Duration(days: i * 7));
          while (date.weekday < 6) {
            date = date.add(const Duration(days: 1));
          }
          return date.copyWith(hour: 11, minute: 0);
        });
        
        final allCompletions = [...weekdayCompletions, ...weekendCompletions];
        
        final pattern = finder.analyzeWeeklyPattern(
          completionHistory: allCompletions,
          scheduledTime: '08:00',
        );
        
        expect(pattern.hasWeekendVariance, isTrue);
        expect(pattern.weekendSuggestedTime?.hour, equals(11));
      });

      test('identifies problematic days', () {
        // Completions with Mondays consistently late
        final completionHistory = <DateTime>[];
        
        for (int week = 0; week < 4; week++) {
          for (int day = 0; day < 7; day++) {
            final date = DateTime.now()
                .subtract(Duration(days: week * 7 + day));
            
            // Mondays at 11 AM (late), other days at 8 AM
            final hour = date.weekday == 1 ? 11 : 8;
            completionHistory.add(date.copyWith(hour: hour, minute: 0));
          }
        }
        
        final pattern = finder.analyzeWeeklyPattern(
          completionHistory: completionHistory,
          scheduledTime: '08:00',
        );
        
        // Monday (weekday 1) should be flagged as problematic
        expect(pattern.problematicDays, contains(1));
      });
    });

    group('Severity Classification', () {
      test('classifies minimal drift correctly', () {
        final completionHistory = _generateCompletions(
          count: 14,
          hour: 9,
          minute: 10, // 10 minutes late
          varianceMinutes: 5,
        );
        
        final analysis = finder.analyze(
          completionHistory: completionHistory,
          scheduledTime: '09:00',
        );
        
        expect(analysis.severity, equals(DriftSeverity.minimal));
      });

      test('classifies significant drift correctly', () {
        final completionHistory = _generateCompletions(
          count: 14,
          hour: 10,
          minute: 0, // 60 minutes late
          varianceMinutes: 10,
        );
        
        final analysis = finder.analyze(
          completionHistory: completionHistory,
          scheduledTime: '09:00',
        );
        
        expect(analysis.severity, equals(DriftSeverity.significant));
      });

      test('classifies major drift correctly', () {
        final completionHistory = _generateCompletions(
          count: 14,
          hour: 11,
          minute: 30, // 150 minutes late
          varianceMinutes: 10,
        );
        
        final analysis = finder.analyze(
          completionHistory: completionHistory,
          scheduledTime: '09:00',
        );
        
        expect(analysis.severity, equals(DriftSeverity.major));
      });
    });
  });

  group('TimeOfDay', () {
    test('parses time string correctly', () {
      final time = TimeOfDay.fromString('14:30');
      expect(time.hour, equals(14));
      expect(time.minute, equals(30));
    });

    test('formats AM/PM correctly', () {
      expect(TimeOfDay(hour: 9, minute: 0).formatAmPm(), equals('9:00 AM'));
      expect(TimeOfDay(hour: 14, minute: 30).formatAmPm(), equals('2:30 PM'));
      expect(TimeOfDay(hour: 0, minute: 0).formatAmPm(), equals('12:00 AM'));
      expect(TimeOfDay(hour: 12, minute: 0).formatAmPm(), equals('12:00 PM'));
    });

    test('calculates total minutes correctly', () {
      expect(TimeOfDay(hour: 0, minute: 0).totalMinutes, equals(0));
      expect(TimeOfDay(hour: 1, minute: 30).totalMinutes, equals(90));
      expect(TimeOfDay(hour: 23, minute: 59).totalMinutes, equals(1439));
    });

    test('calculates difference correctly', () {
      final time1 = TimeOfDay(hour: 10, minute: 0);
      final time2 = TimeOfDay(hour: 9, minute: 0);
      
      expect(time1.differenceInMinutes(time2), equals(60));
      expect(time2.differenceInMinutes(time1), equals(-60));
    });

    test('handles midnight crossing in difference', () {
      final lateNight = TimeOfDay(hour: 23, minute: 0);
      final earlyMorning = TimeOfDay(hour: 1, minute: 0);
      
      // 1 AM is 2 hours after 11 PM
      expect(earlyMorning.differenceInMinutes(lateNight), equals(120));
      // 11 PM is 2 hours before 1 AM
      expect(lateNight.differenceInMinutes(earlyMorning), equals(-120));
    });
  });

  group('DriftAnalysis', () {
    test('creates insufficientData analysis correctly', () {
      final analysis = DriftAnalysis.insufficientData(
        scheduledTime: TimeOfDay(hour: 9, minute: 0),
        sampleSize: 3,
      );
      
      expect(analysis.shouldSuggest, isFalse);
      expect(analysis.confidence, equals(0));
      expect(analysis.sampleSize, equals(3));
    });

    test('identifies consistently late behavior', () {
      final analysis = DriftAnalysis(
        medianTime: TimeOfDay(hour: 10, minute: 0),
        scheduledTime: TimeOfDay(hour: 9, minute: 0),
        driftMinutes: 60,
        shouldSuggest: true,
        confidence: 0.8,
        sampleSize: 14,
        standardDeviation: 15,
        description: 'Test',
        suggestedTime: TimeOfDay(hour: 10, minute: 0),
      );
      
      expect(analysis.isConsistentlyLate, isTrue);
      expect(analysis.isConsistentlyEarly, isFalse);
      expect(analysis.direction, equals(DriftDirection.later));
    });
  });

  group('StrictConfig', () {
    test('requires more data with strict config', () {
      final strictFinder = OptimizedTimeFinder(
        config: DriftDetectionConfig.strictConfig,
      );
      
      // Only 10 completions - enough for default, not enough for strict
      final completionHistory = _generateCompletions(
        count: 10,
        hour: 10,
        minute: 0,
        varianceMinutes: 10,
      );
      
      final analysis = strictFinder.analyze(
        completionHistory: completionHistory,
        scheduledTime: '09:00',
      );
      
      // Strict config requires 14 samples minimum
      expect(analysis.shouldSuggest, isFalse);
    });
  });
}

/// Helper to generate completion history with controlled variance
List<DateTime> _generateCompletions({
  required int count,
  required int hour,
  required int minute,
  required int varianceMinutes,
}) {
  final random = _SeededRandom(42); // Deterministic for tests
  final now = DateTime.now();
  
  return List.generate(count, (i) {
    final variance = (random.nextDouble() * 2 - 1) * varianceMinutes;
    final totalMinutes = hour * 60 + minute + variance.toInt();
    final adjustedHour = (totalMinutes ~/ 60).clamp(0, 23);
    final adjustedMinute = totalMinutes % 60;
    
    return now
        .subtract(Duration(days: i + 1))
        .copyWith(
          hour: adjustedHour,
          minute: adjustedMinute.abs(),
        );
  });
}

/// Simple seeded random for deterministic tests
class _SeededRandom {
  int _seed;
  
  _SeededRandom(this._seed);
  
  double nextDouble() {
    _seed = (_seed * 1103515245 + 12345) & 0x7fffffff;
    return _seed / 0x7fffffff;
  }
}
