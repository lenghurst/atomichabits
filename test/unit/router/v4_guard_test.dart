import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:atomic_habits_hook_app/config/router/app_router.dart';
import 'package:atomic_habits_hook_app/config/router/app_routes.dart';
import 'package:atomic_habits_hook_app/data/app_state.dart';
import 'package:atomic_habits_hook_app/data/providers/psychometric_provider.dart';
import 'package:atomic_habits_hook_app/data/providers/user_provider.dart';
import 'package:atomic_habits_hook_app/data/providers/settings_provider.dart';
import 'package:atomic_habits_hook_app/data/providers/habit_provider.dart';
import 'package:atomic_habits_hook_app/data/services/onboarding/onboarding_orchestrator.dart';
import 'package:atomic_habits_hook_app/data/services/voice_session_manager.dart';
import 'package:atomic_habits_hook_app/domain/entities/psychometric_profile.dart';
import 'package:atomic_habits_hook_app/data/models/user_profile.dart';
import 'package:atomic_habits_hook_app/features/onboarding/state/onboarding_state.dart';

// --- FAKES ---

class FakeAppState extends ChangeNotifier implements AppState {
  // Backing fields
  bool _hasCompletedOnboarding = false;
  bool _hasMicrophonePermission = false;
  bool _hasNotificationPermission = false;

  // Implementing the GETTERS from the interface
  @override
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  
  @override
  bool get hasMicrophonePermission => _hasMicrophonePermission;
  
  @override
  bool get hasNotificationPermission => _hasNotificationPermission;

  // Setters for test setup
  void setCompletedOnboarding(bool value) {
    _hasCompletedOnboarding = value;
    notifyListeners();
  }

  void setMicrophonePermission(bool value) {
    _hasMicrophonePermission = value;
    notifyListeners();
  }
  
  void setNotificationPermission(bool value) {
    _hasNotificationPermission = value;
    notifyListeners();
  }
  
  // Guard Logic Replication (Unit Test Logic)
  @override
  String? checkCommitment(String location) {
    if (location.startsWith('/onboarding/oracle') || location.startsWith('/onboarding/screening')) {
       // Exception: If we have completed onboarding fully, allow access (e.g. re-visiting)
       if (_hasCompletedOnboarding) return null;
       
       // Guard 1: Permissions
       if (!_hasMicrophonePermission) {
          return AppRoutes.misalignment;
       }
       if (!_hasNotificationPermission) {
          return AppRoutes.misalignment;
       }
    }
    return null;
  }
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakePsychometricProvider extends ChangeNotifier implements PsychometricProvider {
  PsychometricProfile _profile = PsychometricProfile();
  
  @override
  PsychometricProfile get profile => _profile;
  
  void setProfile(PsychometricProfile p) {
    _profile = p;
    notifyListeners();
  }
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeUserProvider extends ChangeNotifier implements UserProvider {
  UserProfile _user = UserProfile(
    identity: 'Test',
    name: 'Test User',
    createdAt: DateTime.now(),
  );
  
  @override
  UserProfile? get userProfile => _user;
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSettingsProvider extends ChangeNotifier implements SettingsProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeHabitProvider extends ChangeNotifier implements HabitProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}


// Ensure FakeVoiceSessionManager is compatible
// Removed extended ChangeNotifier as real class likely doesn't extend it
class FakeVoiceSessionManager implements VoiceSessionManager {
  @override
  Future<void> dispose() async {}
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeOnboardingOrchestrator extends ChangeNotifier implements OnboardingOrchestrator {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeOnboardingState extends ChangeNotifier implements OnboardingState {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// --- TEST ---

void main() {
  group('v4 Master Journey Guard Tests', () {
    late FakeAppState appState;
    late FakePsychometricProvider psychProvider;
    late FakeUserProvider userProvider;
    late FakeSettingsProvider settingsProvider;
    late FakeHabitProvider habitProvider;
    late FakeOnboardingState onboardingState; // Added
    
    late GoRouter router;

    setUp(() {
      appState = FakeAppState();
      psychProvider = FakePsychometricProvider();
      userProvider = FakeUserProvider();
      settingsProvider = FakeSettingsProvider();
      habitProvider = FakeHabitProvider();
      onboardingState = FakeOnboardingState(); // Added
    });

    Future<void> pumpRouterApp(WidgetTester tester) async {
       router = AppRouter.createRouter(appState, onboardingState, psychProvider);
       
       await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AppState>.value(value: appState),
            ChangeNotifierProvider<PsychometricProvider>.value(value: psychProvider),
            ChangeNotifierProvider<UserProvider>.value(value: userProvider),
            ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
            ChangeNotifierProvider<HabitProvider>.value(value: habitProvider),
            
            // Use Provider (not ChangeNotifierProvider) if the type doesn't extend ChangeNotifier
            // But our Fake DOES extend ChangeNotifier, so we can cast it or use Provider directly.
            // VoiceSessionManager is NOT a ChangeNotifier, so use Provider
            Provider<VoiceSessionManager>.value(value: FakeVoiceSessionManager()),
            
            // OnboardingOrchestrator IS a ChangeNotifier, so use ChangeNotifierProvider
            ChangeNotifierProvider<OnboardingOrchestrator>.value(value: FakeOnboardingOrchestrator()),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
    }

    testWidgets('Guard 0: Blocking Oracle access without Permissions', (WidgetTester tester) async {
      await pumpRouterApp(tester);
      
      // 1. Initial state: No permissions
      appState.setMicrophonePermission(false);
      appState.setNotificationPermission(false);
      
      // 2. Try to go to Oracle (Step 9)
      router.go(AppRoutes.oracle);
      // Wait for any animations or scheduled frames
      await tester.pumpAndSettle(); 
      
      // 3. Assert: Should be redirected to Misalignment
      // Note: We use routeInformationProvider because router.location is often empty in older/newer go_router versions in tests
      // But routeInformationProvider.value.uri should be correct.
      expect(router.routeInformationProvider.value.uri.toString(), AppRoutes.misalignment);
    });

    testWidgets('Guard 0: Allows Oracle access WITH Permissions AND Data', (WidgetTester tester) async {
      await pumpRouterApp(tester);
      
      // 1. Set Permissions
      appState.setMicrophonePermission(true);
      appState.setNotificationPermission(true);
      
      // 2. Set "Holy Trinity" Data (Guard 2 satisfaction)
      psychProvider.setProfile(PsychometricProfile(
        antiIdentityLabel: "The Lazy One",
        failureArchetype: "Perfectionist",
        resistanceLieLabel: "I'll do it tomorrow",
      ));
      
      // 3. Try to go to Oracle
      router.go(AppRoutes.oracle);
      await tester.pump(const Duration(milliseconds: 500));
      
      // 4. Assert: Should allow access
      expect(router.routeInformationProvider.value.uri.toString(), AppRoutes.oracle);
    });
    
    testWidgets('Guard 2: Blocking Oracle access without Psychometric Data', (WidgetTester tester) async {
      await pumpRouterApp(tester);
      
      // 1. Set Permissions OK
      appState.setMicrophonePermission(true);
      appState.setNotificationPermission(true);

      // 2. Set Empty Profile (Data Missing)
      psychProvider.setProfile(PsychometricProfile()); 
      
      // 3. Try to go to Oracle
      router.go(AppRoutes.oracle);
      await tester.pump(const Duration(milliseconds: 500));
      
      // 4. Assert: Should be redirected to Misalignment (Guard 2 logic)
      expect(router.routeInformationProvider.value.uri.toString(), AppRoutes.misalignment);
    });
  });
}
