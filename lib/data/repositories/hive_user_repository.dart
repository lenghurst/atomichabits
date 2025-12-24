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
    final profileJson = _dataBox!.get(_profileKey);
    if (profileJson != null) {
      return UserProfile.fromJson(Map<String, dynamic>.from(profileJson));
    }
    return null;
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
    if (_dataBox == null) return false;
    return _dataBox!.get(_premiumKey, defaultValue: false);
  }
  
  @override
  Future<void> setPremiumStatus(bool status) async {
    if (_dataBox == null) return;
    await _dataBox!.put(_premiumKey, status);
  }
  
  @override
  Future<void> clear() async {
    if (_dataBox == null) return;
    await _dataBox!.delete(_profileKey);
    await _dataBox!.delete(_onboardingKey);
    await _dataBox!.delete(_premiumKey);
  }
}
