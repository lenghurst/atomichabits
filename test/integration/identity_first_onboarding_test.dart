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
import 'package:atomic_habits_hook_app/features/onboarding/state/onboarding_state.dart';

import '../helpers/onboarding_fakes.dart';

void main() {
  group('Identity-First Onboarding Flow E2E', () {
    late FakeAppState appState;
    late FakePsychometricProvider psychProvider;
    late FakeUserProvider userProvider;
    late FakeSettingsProvider settingsProvider;
    late FakeHabitProvider habitProvider;
    late FakeOnboardingState onboardingState;
    
    late GoRouter router;

    setUp(() {
      appState = FakeAppState();
      psychProvider = FakePsychometricProvider();
      userProvider = FakeUserProvider();
      settingsProvider = FakeSettingsProvider();
      habitProvider = FakeHabitProvider();
      onboardingState = FakeOnboardingState();
    });

    Future<void> pumpRouterApp(WidgetTester tester) async {
       // Set screen size to avoid overflows
       tester.view.physicalSize = const Size(1440, 3000);
       tester.view.devicePixelRatio = 2.0;
       addTearDown(() {
         tester.view.resetPhysicalSize();
         tester.view.resetDevicePixelRatio();
       });

       // Create the router with our mocked providers
       router = AppRouter.createRouter(appState, onboardingState, psychProvider);
       
       await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AppState>.value(value: appState),
            ChangeNotifierProvider<PsychometricProvider>.value(value: psychProvider),
            ChangeNotifierProvider<UserProvider>.value(value: userProvider),
            ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
            ChangeNotifierProvider<HabitProvider>.value(value: habitProvider),
            ChangeNotifierProvider<VoiceSessionManager>.value(value: FakeVoiceSessionManager()),
            ChangeNotifierProvider<OnboardingOrchestrator>.value(value: FakeOnboardingOrchestrator()),
            Provider<GeminiChatService>.value(value: FakeGeminiChatService()),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      
      // Allow BootstrapScreen to complete its async logic and redirection
      await tester.pumpAndSettle();
    }

    testWidgets('test_complete_flow_with_witness', (WidgetTester tester) async {
      await pumpRouterApp(tester);
      
      // Navigate to Identity Onboarding start
      router.go(AppRoutes.identityOnboarding);
      await tester.pumpAndSettle();
      
      // Verify we are on the Identity screen
      expect(router.routeInformationProvider.value.uri.toString(), AppRoutes.identityOnboarding);

      // Simulate capturing identity
      psychProvider.updateProfileForTesting(antiIdentityLabel: "The Procrastinator");
      
      // Navigate to Sherlock Permissions
      router.go(AppRoutes.sherlockPermissions);
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.toString(), AppRoutes.sherlockPermissions);
      
      // Simulate Permissions Grant
      appState.setMicrophonePermission(true);
      appState.setNotificationPermission(true);
      
      // Navigate to Sherlock (Voice)
      router.go(AppRoutes.onboardingSherlock);
      await tester.pumpAndSettle();
      
      // Simulate Sherlock Capturing Holy Trinity
      psychProvider.updateProfileForTesting(
        antiIdentityLabel: "The Procrastinator",
        failureArchetype: "Perfectionist",
        resistanceLieLabel: "I have no time",
      );
      
      // Navigate to Loading Insights
      router.go(AppRoutes.onboardingLoading);
      await tester.pump(const Duration(seconds: 3));
      
      // Navigate to Pact Reveal
      router.go(AppRoutes.pactReveal);
      // Animation might loop, causing pumpAndSettle to timeout
      await tester.pump(const Duration(milliseconds: 500)); 
      await tester.pump(const Duration(seconds: 2));
      
      // Navigate to Witness Investment
      router.go(AppRoutes.witnessOnboarding);
      await tester.pumpAndSettle();
      
      // Navigate to Tier Selection (Final Step)
      router.go(AppRoutes.tierOnboarding);
      await tester.pumpAndSettle();
      
      // Assert: Final route reached
      expect(router.routeInformationProvider.value.uri.toString(), AppRoutes.tierOnboarding);
    });

    testWidgets('test_complete_flow_go_solo', (WidgetTester tester) async {
      await pumpRouterApp(tester);
      
      // Start at Witness Screen
      router.go(AppRoutes.witnessOnboarding);
      await tester.pumpAndSettle();
      
      // Simulate "Go Solo" action via nav
      router.go(AppRoutes.tierOnboarding);
      await tester.pumpAndSettle();
      
      expect(router.routeInformationProvider.value.uri.toString(), AppRoutes.tierOnboarding);
    });

    testWidgets('test_flow_with_null_habit_id', (WidgetTester tester) async {
       await pumpRouterApp(tester);
       
       // Ensure no habit ID causes crashes in PactReveal
       router.go(AppRoutes.pactReveal);
       await tester.pumpAndSettle();
       
       // Should be on PactReveal without error
       expect(router.routeInformationProvider.value.uri.toString(), AppRoutes.pactReveal);
    });

    testWidgets('test_sherlock_captures_holy_trinity', (WidgetTester tester) async {
      await pumpRouterApp(tester);
      
      // Start flow
      router.go(AppRoutes.onboardingSherlock);
      await tester.pumpAndSettle();
      
      // Pre-check
      expect(psychProvider.profile.hasHolyTrinity, false);
      
      // Update data
      psychProvider.updateProfileForTesting(
          antiIdentityLabel: "A", failureArchetype: "B", resistanceLieLabel: "C"
      );
      
      // Check
      expect(psychProvider.profile.hasHolyTrinity, true);
      // Drain timers (VoiceCoachScreen has delayed logic)
      // Navigate away to ensure disposal
      router.go(AppRoutes.onboardingLoading);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
