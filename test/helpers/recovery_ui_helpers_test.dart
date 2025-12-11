import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:atomic_habits_hook_app/features/today/helpers/recovery_ui_helpers.dart';
import 'package:atomic_habits_hook_app/data/models/consistency_metrics.dart';

/// Unit Tests for RecoveryUiHelpers
/// 
/// These tests verify the pure styling helper functions.
/// Pure functions: same input ALWAYS produces same output.
void main() {
  group('RecoveryUiHelpers', () {
    // ========== getUrgencyStyling Tests ==========
    group('getUrgencyStyling', () {
      test('gentle urgency returns amber styling', () {
        final styling = RecoveryUiHelpers.getUrgencyStyling(RecoveryUrgency.gentle);
        
        expect(styling.primaryColor, equals(Colors.amber));
        expect(styling.title, equals('Never Miss Twice'));
        expect(styling.icon, equals(Icons.wb_sunny));
      });

      test('important urgency returns orange styling', () {
        final styling = RecoveryUiHelpers.getUrgencyStyling(RecoveryUrgency.important);
        
        expect(styling.primaryColor, equals(Colors.orange));
        expect(styling.title, equals('Day 2 - Critical'));
        expect(styling.icon, equals(Icons.warning_amber));
      });

      test('compassionate urgency returns purple styling', () {
        final styling = RecoveryUiHelpers.getUrgencyStyling(RecoveryUrgency.compassionate);
        
        expect(styling.primaryColor, equals(Colors.purple));
        expect(styling.title, equals('Welcome Back'));
        expect(styling.icon, equals(Icons.favorite));
      });

      test('styling includes all required properties', () {
        for (final urgency in RecoveryUrgency.values) {
          final styling = RecoveryUiHelpers.getUrgencyStyling(urgency);
          
          expect(styling.primaryColor, isNotNull);
          expect(styling.backgroundColor, isNotNull);
          expect(styling.borderColor, isNotNull);
          expect(styling.iconBackgroundColor, isNotNull);
          expect(styling.iconColor, isNotNull);
          expect(styling.titleColor, isNotNull);
          expect(styling.subtitleColor, isNotNull);
          expect(styling.icon, isNotNull);
          expect(styling.title, isNotEmpty);
        }
      });

      test('same urgency always returns same styling', () {
        // Pure function guarantee: same input → same output
        final styling1 = RecoveryUiHelpers.getUrgencyStyling(RecoveryUrgency.gentle);
        final styling2 = RecoveryUiHelpers.getUrgencyStyling(RecoveryUrgency.gentle);
        
        expect(styling1.primaryColor, equals(styling2.primaryColor));
        expect(styling1.title, equals(styling2.title));
        expect(styling1.icon, equals(styling2.icon));
      });
    });

    // ========== getNotificationColor Tests ==========
    group('getNotificationColor', () {
      test('gentle returns amber hex color', () {
        final color = RecoveryUiHelpers.getNotificationColor(RecoveryUrgency.gentle);
        
        // 0xFFFFC107 is amber
        expect(color, equals(const Color(0xFFFFC107)));
      });

      test('important returns orange hex color', () {
        final color = RecoveryUiHelpers.getNotificationColor(RecoveryUrgency.important);
        
        // 0xFFFF9800 is orange
        expect(color, equals(const Color(0xFFFF9800)));
      });

      test('compassionate returns purple hex color', () {
        final color = RecoveryUiHelpers.getNotificationColor(RecoveryUrgency.compassionate);
        
        // 0xFF9C27B0 is purple
        expect(color, equals(const Color(0xFF9C27B0)));
      });

      test('all urgencies have distinct colors', () {
        final colors = RecoveryUrgency.values
            .map((u) => RecoveryUiHelpers.getNotificationColor(u))
            .toSet();
        
        // All 3 urgencies should have unique colors
        expect(colors.length, equals(3));
      });
    });
  });

  // ========== RecoveryUrgencyStyling Tests ==========
  group('RecoveryUrgencyStyling', () {
    test('can be constructed with all properties', () {
      final styling = RecoveryUrgencyStyling(
        primaryColor: Colors.blue,
        backgroundColor: Colors.blue.shade50,
        borderColor: Colors.blue.shade300,
        iconBackgroundColor: Colors.blue.shade100,
        iconColor: Colors.blue.shade700,
        titleColor: Colors.blue.shade900,
        subtitleColor: Colors.blue.shade700,
        icon: Icons.info,
        title: 'Test Title',
      );
      
      expect(styling.primaryColor, equals(Colors.blue));
      expect(styling.title, equals('Test Title'));
      expect(styling.icon, equals(Icons.info));
    });
  });
}
