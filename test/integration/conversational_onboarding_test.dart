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

import 'package:atomic_habits_hook_app/data/services/gemini_chat_service.dart';
import '../helpers/onboarding_fakes.dart';

void main() {
  group('Conversational Onboarding Flow (Regression)', () {
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
       tester.view.physicalSize = const Size(1440, 3000);
       tester.view.devicePixelRatio = 2.0;
       addTearDown(() {
         tester.view.resetPhysicalSize();
         tester.view.resetDevicePixelRatio();
       });

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

    testWidgets('test_chat_based_onboarding', (WidgetTester tester) async {
      await pumpRouterApp(tester);
      
      // Navigate to Chat Onboarding
      router.go(AppRoutes.chatOnboarding);
      await tester.pumpAndSettle();
      
      expect(router.routeInformationProvider.value.uri.toString(), AppRoutes.chatOnboarding);
      expect(find.text('AI Coach'), findsOneWidget); // Title from screen
      
      // Verify initial greeting (from FakeOnboardingOrchestrator)
      expect(find.text('Hello test user!'), findsOneWidget);
    }, skip: true);

    testWidgets('test_tier_selection_legacy_still_works', (WidgetTester tester) async {
      await pumpRouterApp(tester);
      
      // Navigate to legacy tier selection
      router.go(AppRoutes.tierOnboarding);
      await tester.pump(const Duration(seconds: 3));
      
      expect(router.routeInformationProvider.value.uri.toString(), AppRoutes.tierOnboarding);
    }, skip: true);
  });
}
