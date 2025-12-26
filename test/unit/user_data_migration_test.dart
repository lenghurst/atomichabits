import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:atomic_habits_hook_app/data/models/user_profile.dart';
import 'package:atomic_habits_hook_app/data/repositories/hive_user_repository.dart';
// import 'package:path/path.dart' as path; // Unused
import 'dart:io';

/// Test suite for User Data Migration (Phase 35)
/// Verifies that legacy isPremium key is correctly migrated to UserProfile
void main() {
  group('HiveUserRepository Migration Tests', () {
    late HiveUserRepository repository;
    late Directory tempDir;
    
    setUp(() async {
      // Create temp directory for Hive
      tempDir = await Directory.systemTemp.createTemp();
      Hive.init(tempDir.path);
      
      repository = HiveUserRepository();
    });
    
    tearDown(() async {
      await Hive.deleteFromDisk();
      await tempDir.delete(recursive: true);
    });

    test('getProfile migrates legacy isPremium key and deletes it', () async {
      // 1. ARRAGE: Setup legacy state directly in Hive
      final box = await Hive.openBox('habit_data');
      
      // Create a profile WITHOUT isPremium
      final profile = UserProfile(
        name: 'Test User',
        identity: 'Tester',
        createdAt: DateTime.now(),
        // isPremium defaults to false
      );
      
      await box.put('userProfile', profile.toJson());
      await box.put('isPremium', true); // Legacy key says TRUE
      await box.close();
      
      // 2. ACT: Initialize repository and get profile
      await repository.init();
      final migratedProfile = await repository.getProfile();
      
      // 3. ASSERT: Profile should have isPremium=true
      expect(migratedProfile?.isPremium, isTrue);
      
      // 4. ASSERT: Legacy key should be gone
      // We need to re-open box to check raw values or check via repository if exposed
      // Re-opening box is safer to verify underlying storage
      final checkBox = await Hive.openBox('habit_data');
      expect(checkBox.containsKey('isPremium'), isFalse);
      expect(checkBox.containsKey('userProfile'), isTrue);
      
      // Check the stored profile explicitly has isPremium=true
      final storedJson = checkBox.get('userProfile');
      expect(storedJson['isPremium'], isTrue);
    });

    test('getProfile respects existing unified isPremium if no legacy key', () async {
      // 1. ARRANGE: Setup unified state
      final box = await Hive.openBox('habit_data');
      
      final profile = UserProfile(
        name: 'Test User',
        identity: 'Tester',
        createdAt: DateTime.now(),
        isPremium: true, // Already true in profile
      );
      
      await box.put('userProfile', profile.toJson());
      // No 'isPremium' legacy key
      await box.close();
      
      // 2. ACT
      await repository.init();
      final loadedProfile = await repository.getProfile();
      
      // 3. ASSERT
      expect(loadedProfile?.isPremium, isTrue);
    });

    test('setPremiumStatus updates UserProfile', () async {
      // 1. ARRANGE
      await repository.init();
      final profile = UserProfile(
        name: 'Test User',
        identity: 'Tester',
        createdAt: DateTime.now(),
        isPremium: false,
      );
      await repository.saveProfile(profile);
      
      // 2. ACT
      await repository.setPremiumStatus(true);
      
      // 3. ASSERT
      final updatedProfile = await repository.getProfile();
      expect(updatedProfile?.isPremium, isTrue);
    });
  });
}
