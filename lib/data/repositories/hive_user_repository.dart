import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_profile.dart';
import 'user_repository.dart';

/// Hive implementation of UserRepository.
/// All Hive-specific code is isolated here.
class HiveUserRepository implements UserRepository {
  Box? _dataBox;
  static const String _boxName = 'habit_data';
  static const String _profileKey = 'userProfile';
  static const String _onboardingKey = 'hasCompletedOnboarding';
  static const String _premiumKey = 'isPremium';
  
  @override
  Future<void> init() async {
    try {
      _dataBox = await Hive.openBox(_boxName);
    } catch (e) {
      if (kDebugMode) debugPrint('HiveUserRepository: Error opening box: $e');
    }
  }
  
  @override
  Future<UserProfile?> getProfile() async {
    if (_dataBox == null) return null;
    
    // === MIGRATION LOGIC Phase 35 START ===
    // Check for legacy isPremium key
    final bool? legacyIsPremium = _dataBox!.get(_premiumKey);
    final profileJson = _dataBox!.get(_profileKey);
    
    UserProfile? profile;
    if (profileJson != null) {
      profile = UserProfile.fromJson(Map<String, dynamic>.from(profileJson));
      
      // If legacy key exists, we need to migrate
      if (legacyIsPremium != null) {
        if (kDebugMode) debugPrint('HiveUserRepository: Migrating legacy isPremium ($legacyIsPremium) to UserProfile');
        
        // 1. Update profile with legacy value
        profile = profile.copyWith(isPremium: legacyIsPremium);
        
        // 2. Save updated profile
        await _dataBox!.put(_profileKey, profile.toJson());
        
        // 3. Delete legacy key
        await _dataBox!.delete(_premiumKey);
        
        if (kDebugMode) debugPrint('HiveUserRepository: Migration complete. Legacy key deleted.');
      }
    }
    // === MIGRATION LOGIC END ===
    
    return profile;
  }
  
  @override
  Future<void> saveProfile(UserProfile profile) async {
    if (_dataBox == null) return;
    await _dataBox!.put(_profileKey, profile.toJson());
  }
  
  @override
  Future<bool> hasCompletedOnboarding() async {
    if (_dataBox == null) return false;
    return _dataBox!.get(_onboardingKey, defaultValue: false);
  }
  
  @override
  Future<void> setOnboardingComplete(bool complete) async {
    if (_dataBox == null) return;
    await _dataBox!.put(_onboardingKey, complete);
  }
  
  @override
  Future<bool> isPremium() async {
    // Phase 35: Read from UserProfile instead of separate key
    // We call getProfile() which handles the migration if needed
    final profile = await getProfile();
    return profile?.isPremium ?? false;
  }
  
  @override
  Future<void> setPremiumStatus(bool status) async {
    // Phase 35: Update UserProfile instead of separate key
    final profile = await getProfile();
    if (profile != null) {
      final updatedProfile = profile.copyWith(isPremium: status);
      await saveProfile(updatedProfile);
    }
  }
  
  @override
  Future<void> clear() async {
    if (_dataBox == null) return;
    await _dataBox!.delete(_profileKey);
    await _dataBox!.delete(_onboardingKey);
    // _premiumKey is deleted during migration or not used anymore
  }
}
