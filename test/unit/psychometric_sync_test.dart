import 'package:flutter_test/flutter_test.dart';
import '../../lib/domain/entities/psychometric_profile.dart';

void main() {
  group('PsychometricProfile Sync Logic', () {
    test('Default profile is not synced', () {
      final profile = PsychometricProfile();
      expect(profile.isSynced, false);
      expect(profile.lastUpdated, isNotNull);
    });

    test('toJson includes isSynced and lastUpdated', () {
      final now = DateTime.now();
      final profile = PsychometricProfile(
        isSynced: true,
        lastUpdated: now,
      );
      
      final json = profile.toJson();
      expect(json['isSynced'], true);
      expect(json['lastUpdated'], now.toIso8601String());
    });

    test('fromJson parses isSynced and lastUpdated', () {
      final now = DateTime.now();
      final json = {
        'isSynced': true,
        'lastUpdated': now.toIso8601String(),
        // Add minimal required fields if any (currently none required)
      };
      
      final profile = PsychometricProfile.fromJson(json);
      expect(profile.isSynced, true);
      expect(profile.lastUpdated.isAtSameMomentAs(now), true);
    });

    test('fromJson defaults (legacy data)', () {
      final json = <String, dynamic>{}; // No sync fields
      
      final profile = PsychometricProfile.fromJson(json);
      expect(profile.isSynced, false);
      // lastUpdated should default to now roughly
      expect(profile.lastUpdated.difference(DateTime.now()).inSeconds < 2, true);
    });

    test('copyWith updates fields correctly', () {
      final profile = PsychometricProfile(isSynced: true);
      final updated = profile.copyWith(isSynced: false);
      expect(updated.isSynced, false);
    });
  });
}
