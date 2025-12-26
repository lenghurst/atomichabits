import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../repositories/user_repository.dart';

/// UserProvider: Manages Identity, Onboarding state, and Premium status.
/// 
/// Decoupled from Hive via UserRepository injection.
/// Satisfies: Uncle Bob (DIP), Flux (Specific Scope).
class UserProvider extends ChangeNotifier {
  final UserRepository _repository;
  
  UserProfile? _userProfile;
  bool _hasCompletedOnboarding = false;
  // bool _isPremium = false; // Phase 35: Removed
  bool _isLoading = true;

  UserProvider(this._repository);

  // === Getters ===
  UserProfile? get userProfile => _userProfile;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get isLoading => _isLoading;
  
  /// Premium status
  /// Phase 35: Now unified in UserProfile
  bool get isPremium => _userProfile?.isPremium ?? false;
  
  /// Convenience getters for common profile fields
  String get userName => _userProfile?.name ?? '';
  String get identity => _userProfile?.identity ?? '';

  /// Initialize the provider by loading from repository
  Future<void> initialize() async {
    try {
      _userProfile = await _repository.getProfile();
      _hasCompletedOnboarding = await _repository.hasCompletedOnboarding();
      // _isPremium is now part of _userProfile
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('UserProvider: Error initializing: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set the user profile
  Future<void> setUserProfile(UserProfile profile) async {
    _userProfile = profile;
    await _repository.saveProfile(profile);
    notifyListeners();
  }

  /// Update specific profile fields
  Future<void> updateProfile({
    String? name,
    String? identity,
  }) async {
    if (_userProfile == null) return;
    
    _userProfile = _userProfile!.copyWith(
      name: name ?? _userProfile!.name,
      identity: identity ?? _userProfile!.identity,
    );
    await _repository.saveProfile(_userProfile!);
    notifyListeners();
  }

  /// Mark onboarding as complete
  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    await _repository.setOnboardingComplete(true);
    notifyListeners();
  }

  /// Reset onboarding (for testing/dev)
  Future<void> resetOnboarding() async {
    _hasCompletedOnboarding = false;
    await _repository.setOnboardingComplete(false);
    notifyListeners();
  }

  /// Set premium status
  Future<void> setPremiumStatus(bool status) async {
    if (_userProfile != null) {
      _userProfile = _userProfile!.copyWith(isPremium: status);
      await _repository.setPremiumStatus(status); // This also updates remote/hive
      notifyListeners();
    }
  }

  /// Clear all user data (for account reset)
  Future<void> clearUserData() async {
    _userProfile = null;
    _hasCompletedOnboarding = false;
    await _repository.clear();
    notifyListeners();
  }
}
