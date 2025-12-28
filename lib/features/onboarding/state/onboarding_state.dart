import 'package:flutter/foundation.dart';

/// Manages state for the v4 Commitment Funnel (Onboarding)
/// Isolates routing guards, permissions, and step tracking from the monolithic AppState.
class OnboardingState extends ChangeNotifier {
  // ========== Permissions (Moved from AppState) ==========
  bool _hasMicrophonePermission = false;
  bool _hasNotificationPermission = false;
  
  bool get hasMicrophonePermission => _hasMicrophonePermission;
  bool get hasNotificationPermission => _hasNotificationPermission;

  void setMicrophonePermission(bool value) {
    if (_hasMicrophonePermission != value) {
      _hasMicrophonePermission = value;
      notifyListeners();
    }
  }

  void setNotificationPermission(bool value) {
    if (_hasNotificationPermission != value) {
      _hasNotificationPermission = value;
      notifyListeners();
    }
  }

  /// Guard Logic: Verifies specific commitment step requirements.
  /// Returns a fail route (e.g. misalignment) if check fails, or null if OK.
  /// 
  /// [location] - The route being accessed
  /// [hasCompletedOnboarding] - passed from AppState to allow re-entry if done
  String? checkCommitment(String location, {required bool hasCompletedOnboarding}) {
    // Phase 54: Prevent Side Door
    // If accessing Oracle or Goal Screening, MUST have permissions.
    if (location.startsWith('/onboarding/oracle') || location.startsWith('/onboarding/screening')) {
       // Allow if specifically completing onboarding
       if (hasCompletedOnboarding) return null;

       if (!_hasMicrophonePermission) {
          if (kDebugMode) debugPrint('OnboardingState: Blocked $location due to missing mic permission');
          // In real implementation, this goes to Misalignment.
          // For now, we allow it (development) or strictly block:
          // return '/onboarding/misalignment?reason=permissions';
          return null; 
       }
    }
    return null;
  }
}
