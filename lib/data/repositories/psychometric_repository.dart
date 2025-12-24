import '../../domain/entities/psychometric_profile.dart';

/// Abstract interface for psychometric profile persistence.
abstract class PsychometricRepository {
  /// Initialize the repository
  Future<void> init();
  
  /// Get the psychometric profile
  Future<PsychometricProfile?> getProfile();
  
  /// Save the psychometric profile
  Future<void> saveProfile(PsychometricProfile profile);
  
  /// Clear the profile
  Future<void> clear();
}
