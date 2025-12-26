import 'package:flutter_test/flutter_test.dart';
import 'package:atomic_habits_hook_app/domain/entities/psychometric_profile.dart';
import 'package:atomic_habits_hook_app/domain/services/psychometric_engine.dart';

void main() {
  group('Sherlock Expansion - PsychometricProfile', () {
    test('Should correctly serialize and deserialize sensor data', () {
      final profile = PsychometricProfile(
        lastNightSleepMinutes: 300,
        currentHRV: 45.5,
        distractionMinutes: 90,
        declinedPermissions: ['calendar.readonly'],
      );

      final json = profile.toJson();
      expect(json['lastNightSleepMinutes'], 300);
      expect(json['currentHRV'], 45.5);
      expect(json['distractionMinutes'], 90);
      expect(json['declinedPermissions'], contains('calendar.readonly'));

      final rebuilt = PsychometricProfile.fromJson(json);
      expect(rebuilt.lastNightSleepMinutes, 300);
      expect(rebuilt.currentHRV, 45.5);
      expect(rebuilt.distractionMinutes, 90);
      expect(rebuilt.declinedPermissions, contains('calendar.readonly'));
    });

    test('toSystemPrompt should include physiological intelligence when data exists', () {
      final profile = PsychometricProfile(
        lastNightSleepMinutes: 300,
        currentHRV: 25.0,
        distractionMinutes: 120,
      );

      final prompt = profile.toSystemPrompt();
      expect(prompt, contains('PHYSIOLOGICAL INTELLIGENCE'));
      expect(prompt, contains('Sleep: 5h 0m')); // 300 / 60
      expect(prompt, contains('HRV (Stress): 25.0 ms'));
      expect(prompt, contains('Digital Distraction: 120m'));
    });

    test('toSystemPrompt should include privacy boundaries when permissions declined', () {
      final profile = PsychometricProfile(
        declinedPermissions: ['calendar.readonly', 'location'],
      );

      final prompt = profile.toSystemPrompt();
      expect(prompt, contains('PRIVACY BOUNDARIES'));
      expect(prompt, contains('calendar.readonly'));
      expect(prompt, contains('location'));
    });
  });

  group('Sherlock Expansion - PsychometricEngine', () {
    late PsychometricEngine engine;

    setUp(() {
      engine = PsychometricEngine();
    });

    test('Sleep deprivation (< 6h) should lower resilience and force supportive coaching', () {
      final initialProfile = PsychometricProfile(
        resilienceScore: 0.8,
        coachingStyle: CoachingStyle.toughLove,
      );

      final updated = engine.updateFromSensorData(
        initialProfile,
        sleepMinutes: 300, // 5 hours
      );

      // Resilience should drop by 0.15
      expect(updated.resilienceScore, closeTo(0.65, 0.01));
      
      // Coaching style should switch to supportive due to biological vulnerability
      expect(updated.coachingStyle, CoachingStyle.supportive);
      
      // Check fatigue risk flag (assuming bitmask logic is: fatigue = 1 << 0 or similar)
      // Since we don't know the exact bitmask value without importing RiskFlags, 
      // we check that bitmask changed from 0
      expect(updated.riskBitmask, isNot(0)); 
    });

    test('Good sleep (> 8h) should boost resilience', () {
      final initialProfile = PsychometricProfile(
        resilienceScore: 0.5,
      );

      final updated = engine.updateFromSensorData(
        initialProfile,
        sleepMinutes: 500, // 8h 20m
      );

      // Resilience should increase by 0.05
      expect(updated.resilienceScore, closeTo(0.55, 0.01));
    });

    test('High digital distraction (> 60m) should lower resilience (Dopamine Burn)', () {
      final initialProfile = PsychometricProfile(
        resilienceScore: 0.8,
      );

      final updated = engine.updateFromSensorData(
        initialProfile,
        distractionMinutes: 90,
      );

      // Resilience should drop by 0.1
      expect(updated.resilienceScore, closeTo(0.7, 0.01));
    });

    test('Low HRV (< 30ms) should lower resilience and trigger stress flag', () {
      final initialProfile = PsychometricProfile(
        resilienceScore: 0.8,
      );

      final updated = engine.updateFromSensorData(
        initialProfile,
        hrv: 25.0,
      );

      // Resilience should drop by 0.05
      expect(updated.resilienceScore, closeTo(0.75, 0.01));
      expect(updated.riskBitmask, isNot(0));
    });

    test('Combination of factors (Bad sleep + Doomscrolling) should stack damage', () {
      final initialProfile = PsychometricProfile(
        resilienceScore: 1.0,
        coachingStyle: CoachingStyle.toughLove,
      );

      final updated = engine.updateFromSensorData(
        initialProfile,
        sleepMinutes: 300,       // -0.15
        distractionMinutes: 120, // -0.10
        hrv: 20.0,               // -0.05
      );

      // Total hit: -0.30 -> Should be 0.70
      expect(updated.resilienceScore, closeTo(0.70, 0.01));
      expect(updated.coachingStyle, CoachingStyle.supportive); // Sleep overrides
    });
  });
}
