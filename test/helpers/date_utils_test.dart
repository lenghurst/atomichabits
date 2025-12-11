import 'package:flutter_test/flutter_test.dart';
import 'package:atomic_habits_hook_app/utils/date_utils.dart';

/// Unit Tests for HabitDateUtils
/// 
/// These tests verify the pure helper functions work correctly.
/// Pure functions are the easiest to test: input → output, no side effects.
void main() {
  group('HabitDateUtils', () {
    // ========== isSameDay Tests ==========
    group('isSameDay', () {
      test('returns true for same date different times', () {
        final date1 = DateTime(2024, 3, 15, 9, 30);
        final date2 = DateTime(2024, 3, 15, 22, 45);
        
        expect(HabitDateUtils.isSameDay(date1, date2), isTrue);
      });

      test('returns false for different dates', () {
        final date1 = DateTime(2024, 3, 15);
        final date2 = DateTime(2024, 3, 16);
        
        expect(HabitDateUtils.isSameDay(date1, date2), isFalse);
      });

      test('returns false for same day different months', () {
        final date1 = DateTime(2024, 3, 15);
        final date2 = DateTime(2024, 4, 15);
        
        expect(HabitDateUtils.isSameDay(date1, date2), isFalse);
      });

      test('returns false for same day different years', () {
        final date1 = DateTime(2024, 3, 15);
        final date2 = DateTime(2025, 3, 15);
        
        expect(HabitDateUtils.isSameDay(date1, date2), isFalse);
      });

      test('returns false when first date is null', () {
        final date2 = DateTime(2024, 3, 15);
        
        expect(HabitDateUtils.isSameDay(null, date2), isFalse);
      });

      test('returns false when second date is null', () {
        final date1 = DateTime(2024, 3, 15);
        
        expect(HabitDateUtils.isSameDay(date1, null), isFalse);
      });

      test('returns false when both dates are null', () {
        expect(HabitDateUtils.isSameDay(null, null), isFalse);
      });
    });

    // ========== daysBetween Tests ==========
    group('daysBetween', () {
      test('returns 0 for same day', () {
        final date1 = DateTime(2024, 3, 15, 10, 0);
        final date2 = DateTime(2024, 3, 15, 22, 0);
        
        expect(HabitDateUtils.daysBetween(date1, date2), equals(0));
      });

      test('returns 1 for consecutive days', () {
        final date1 = DateTime(2024, 3, 15);
        final date2 = DateTime(2024, 3, 16);
        
        expect(HabitDateUtils.daysBetween(date1, date2), equals(1));
      });

      test('returns 7 for week apart', () {
        final date1 = DateTime(2024, 3, 8);
        final date2 = DateTime(2024, 3, 15);
        
        expect(HabitDateUtils.daysBetween(date1, date2), equals(7));
      });

      test('returns positive value regardless of order', () {
        final date1 = DateTime(2024, 3, 15);
        final date2 = DateTime(2024, 3, 8);
        
        expect(HabitDateUtils.daysBetween(date1, date2), equals(7));
      });

      test('handles month boundaries', () {
        final date1 = DateTime(2024, 2, 28);
        final date2 = DateTime(2024, 3, 1);
        
        // 2024 is a leap year, so Feb has 29 days
        expect(HabitDateUtils.daysBetween(date1, date2), equals(2));
      });

      test('handles year boundaries', () {
        final date1 = DateTime(2024, 12, 31);
        final date2 = DateTime(2025, 1, 1);
        
        expect(HabitDateUtils.daysBetween(date1, date2), equals(1));
      });
    });

    // ========== startOfDay Tests ==========
    group('startOfDay', () {
      test('returns midnight of given date', () {
        final date = DateTime(2024, 3, 15, 14, 30, 45);
        final startOfDay = HabitDateUtils.startOfDay(date);
        
        expect(startOfDay.year, equals(2024));
        expect(startOfDay.month, equals(3));
        expect(startOfDay.day, equals(15));
        expect(startOfDay.hour, equals(0));
        expect(startOfDay.minute, equals(0));
        expect(startOfDay.second, equals(0));
      });

      test('returns same date if already midnight', () {
        final date = DateTime(2024, 3, 15);
        final startOfDay = HabitDateUtils.startOfDay(date);
        
        expect(startOfDay, equals(date));
      });
    });

    // ========== dateRange Tests ==========
    group('dateRange', () {
      test('returns single date when start equals end', () {
        final date = DateTime(2024, 3, 15);
        final range = HabitDateUtils.dateRange(date, date);
        
        expect(range.length, equals(1));
        expect(HabitDateUtils.isSameDay(range[0], date), isTrue);
      });

      test('returns correct range for 7 days', () {
        final start = DateTime(2024, 3, 8);
        final end = DateTime(2024, 3, 14);
        final range = HabitDateUtils.dateRange(start, end);
        
        expect(range.length, equals(7));
        expect(HabitDateUtils.isSameDay(range.first, start), isTrue);
        expect(HabitDateUtils.isSameDay(range.last, end), isTrue);
      });

      test('returns consecutive dates', () {
        final start = DateTime(2024, 3, 1);
        final end = DateTime(2024, 3, 5);
        final range = HabitDateUtils.dateRange(start, end);
        
        for (int i = 0; i < range.length - 1; i++) {
          final diff = range[i + 1].difference(range[i]).inDays;
          expect(diff, equals(1));
        }
      });
    });

    // ========== lastSevenDays Tests ==========
    group('lastSevenDays', () {
      test('returns exactly 7 dates', () {
        final days = HabitDateUtils.lastSevenDays();
        expect(days.length, equals(7));
      });

      test('first date is today', () {
        final days = HabitDateUtils.lastSevenDays();
        final today = HabitDateUtils.startOfToday();
        
        expect(HabitDateUtils.isSameDay(days[0], today), isTrue);
      });

      test('dates are in reverse chronological order', () {
        final days = HabitDateUtils.lastSevenDays();
        
        for (int i = 0; i < days.length - 1; i++) {
          expect(days[i].isAfter(days[i + 1]), isTrue);
        }
      });
    });

    // ========== formatDuration Tests ==========
    group('formatDuration', () {
      test('formats seconds as just now', () {
        final duration = const Duration(seconds: 30);
        expect(HabitDateUtils.formatDuration(duration), equals('just now'));
      });

      test('formats minutes correctly', () {
        expect(
          HabitDateUtils.formatDuration(const Duration(minutes: 1)),
          equals('1 minute'),
        );
        expect(
          HabitDateUtils.formatDuration(const Duration(minutes: 5)),
          equals('5 minutes'),
        );
      });

      test('formats hours correctly', () {
        expect(
          HabitDateUtils.formatDuration(const Duration(hours: 1)),
          equals('1 hour'),
        );
        expect(
          HabitDateUtils.formatDuration(const Duration(hours: 3)),
          equals('3 hours'),
        );
      });

      test('formats days correctly', () {
        expect(
          HabitDateUtils.formatDuration(const Duration(days: 1)),
          equals('1 day'),
        );
        expect(
          HabitDateUtils.formatDuration(const Duration(days: 7)),
          equals('7 days'),
        );
      });

      test('prioritizes larger units', () {
        // 1 day and 5 hours should show as "1 day"
        final duration = const Duration(days: 1, hours: 5);
        expect(HabitDateUtils.formatDuration(duration), equals('1 day'));
      });
    });

    // ========== parseTimeString Tests ==========
    group('parseTimeString', () {
      test('parses valid time string', () {
        final result = HabitDateUtils.parseTimeString('09:30');
        expect(result.hour, equals(9));
        expect(result.minute, equals(30));
      });

      test('parses midnight', () {
        final result = HabitDateUtils.parseTimeString('00:00');
        expect(result.hour, equals(0));
        expect(result.minute, equals(0));
      });

      test('parses 24-hour format', () {
        final result = HabitDateUtils.parseTimeString('23:59');
        expect(result.hour, equals(23));
        expect(result.minute, equals(59));
      });

      test('returns default for invalid format', () {
        final result = HabitDateUtils.parseTimeString('invalid');
        expect(result.hour, equals(9));
        expect(result.minute, equals(0));
      });

      test('returns default for empty string', () {
        final result = HabitDateUtils.parseTimeString('');
        expect(result.hour, equals(9));
        expect(result.minute, equals(0));
      });
    });

    // ========== formatTimeString Tests ==========
    group('formatTimeString', () {
      test('formats with leading zeros', () {
        expect(HabitDateUtils.formatTimeString(9, 5), equals('09:05'));
      });

      test('formats double digits', () {
        expect(HabitDateUtils.formatTimeString(14, 30), equals('14:30'));
      });

      test('formats midnight', () {
        expect(HabitDateUtils.formatTimeString(0, 0), equals('00:00'));
      });
    });

    // ========== dayOfWeekName Tests ==========
    group('dayOfWeekName', () {
      test('returns full name by default', () {
        // March 15, 2024 is a Friday
        final friday = DateTime(2024, 3, 15);
        expect(HabitDateUtils.dayOfWeekName(friday), equals('Friday'));
      });

      test('returns abbreviated name when requested', () {
        final friday = DateTime(2024, 3, 15);
        expect(
          HabitDateUtils.dayOfWeekName(friday, abbreviated: true),
          equals('Fri'),
        );
      });

      test('returns correct name for Monday', () {
        final monday = DateTime(2024, 3, 11);
        expect(HabitDateUtils.dayOfWeekName(monday), equals('Monday'));
      });

      test('returns correct name for Sunday', () {
        final sunday = DateTime(2024, 3, 17);
        expect(HabitDateUtils.dayOfWeekName(sunday), equals('Sunday'));
      });
    });

    // ========== monthName Tests ==========
    group('monthName', () {
      test('returns full name by default', () {
        final march = DateTime(2024, 3, 15);
        expect(HabitDateUtils.monthName(march), equals('March'));
      });

      test('returns abbreviated name when requested', () {
        final march = DateTime(2024, 3, 15);
        expect(HabitDateUtils.monthName(march, abbreviated: true), equals('Mar'));
      });

      test('returns correct name for January', () {
        final january = DateTime(2024, 1, 15);
        expect(HabitDateUtils.monthName(january), equals('January'));
      });

      test('returns correct name for December', () {
        final december = DateTime(2024, 12, 15);
        expect(HabitDateUtils.monthName(december), equals('December'));
      });
    });
  });
}
