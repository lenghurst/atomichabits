import '../models/user_profile.dart';

/// Abstract interface for user data persistence.
/// Decouples the Provider layer from the Infrastructure layer (Hive).
abstract class UserRepository {
  /// Initialize the repository
  Future<void> init();
  
  /// Get user profile from storage
  Future<UserProfile?> getProfile();
  
  /// Save user profile to storage
  Future<void> saveProfile(UserProfile profile);
  
  /// Check if onboarding is complete
  Future<bool> hasCompletedOnboarding();
  
  /// Mark onboarding as complete
  Future<void> setOnboardingComplete(bool complete);
  
  /// Get premium status
  Future<bool> isPremium();
  
  /// Set premium status
  Future<void> setPremiumStatus(bool status);
  
  /// Clear all user data
  Future<void> clear();
}
