import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  bool _isPremium = false;
  bool _isLoading = true;

  UserProvider(this._repository);

  // === Getters ===
  UserProfile? get userProfile => _userProfile;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get isLoading => _isLoading;
  
  /// Premium status with verification backdoor
  /// Phase 41 Security Fix: Oliver Backdoor REMOVED
  /// Premium status is now determined solely by stored value.
  bool get isPremium => _isPremium;
  
  /// Convenience getters for common profile fields
  String get userName => _userProfile?.name ?? '';
  String get identity => _userProfile?.identity ?? '';

  /// Initialize the provider by loading from repository
  Future<void> initialize() async {
    try {
      _userProfile = await _repository.getProfile();
      _hasCompletedOnboarding = await _repository.hasCompletedOnboarding();
      _isPremium = await _repository.isPremium();
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
    _isPremium = status;
    await _repository.setPremiumStatus(status);
    notifyListeners();
  }

  /// Clear all user data (for account reset)
  Future<void> clearUserData() async {
    _userProfile = null;
    _hasCompletedOnboarding = false;
    _isPremium = false;
    await _repository.clear();
    notifyListeners();
  }
}
