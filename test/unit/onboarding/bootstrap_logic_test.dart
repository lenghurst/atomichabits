import 'package:atomic_habits_hook_app/features/onboarding/bootstrap_screen.dart';
import 'package:atomic_habits_hook_app/data/services/onboarding/onboarding_orchestrator.dart';
import 'package:atomic_habits_hook_app/data/app_state.dart';
import 'package:atomic_habits_hook_app/config/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Fake Orchestrator for testing
class FakeOnboardingOrchestrator extends ChangeNotifier implements OnboardingOrchestrator {
  String? mockInviteCode;
  bool shouldThrow = false;
  Duration delay = Duration.zero;

  @override
  Future<String?> checkForDeferredDeepLink() async {
    if (delay != Duration.zero) {
      await Future.delayed(delay);
    }
    if (shouldThrow) {
      throw Exception("Simulated Network Error");
    }
    return mockInviteCode;
  }
  
  // Satisfy interface (add other necessary overrides as no-ops if needed)
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAppState extends ChangeNotifier implements AppState {
  bool _completed = false;

  @override
  bool get hasCompletedOnboarding => _completed;

  set hasCompletedOnboarding(bool value) {
    _completed = value;
    notifyListeners();
  }
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeOnboardingOrchestrator fakeOrchestrator;
  late FakeAppState fakeAppState;
  late GoRouter router;

  setUp(() {
    fakeOrchestrator = FakeOnboardingOrchestrator();
    fakeAppState = FakeAppState();
  });

  Future<void> pumpBootstrapScreen(WidgetTester tester) async {
    router = GoRouter(
      initialLocation: AppRoutes.bootstrap,
      routes: [
        GoRoute(
          path: AppRoutes.bootstrap,
          builder: (context, state) => const BootstrapScreen(),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const Scaffold(body: Text('Home Screen')),
        ),
        GoRoute(
          path: '/witness/accept/:code',
          builder: (context, state) => Scaffold(body: Text('Witness Screen: ${state.pathParameters['code']}')),
        ),
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (context, state) => const Scaffold(body: Text('Dashboard')),
        ),
      ],
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<OnboardingOrchestrator>.value(value: fakeOrchestrator),
          ChangeNotifierProvider<AppState>.value(value: fakeAppState),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );
  }

  testWidgets('Test 1: Deep link returns null (Cold Start) -> Navigates to Home', (WidgetTester tester) async {
    fakeOrchestrator.mockInviteCode = null;
    fakeOrchestrator.delay = const Duration(milliseconds: 100); // Simulate delay

    await pumpBootstrapScreen(tester);
    
    // Verify Loading Indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Wait for logic to complete
    await tester.pump(const Duration(seconds: 2));

    // Verify navigation to Home
    expect(find.text('Home Screen'), findsOneWidget);
  });

  testWidgets('Test 2: Deep link returns invite code (Side Door) -> Navigates to Witness Accept', (WidgetTester tester) async {
    fakeOrchestrator.mockInviteCode = 'ABC-123';
    
    await pumpBootstrapScreen(tester);
    await tester.pumpAndSettle();

    // Verify navigation to Witness Screen
    expect(find.text('Witness Screen: ABC-123'), findsOneWidget);
  });

  testWidgets('Test 3: Deep link checks throw (Safety Fallback) -> Navigates to Home', (WidgetTester tester) async {
    fakeOrchestrator.shouldThrow = true;
    
    await pumpBootstrapScreen(tester);
    await tester.pumpAndSettle();

    // Verify fallback to Home
    expect(find.text('Home Screen'), findsOneWidget);
  });
  
  testWidgets('Test 4: Authenticated user -> Navigates to Dashboard', (WidgetTester tester) async {
    fakeAppState.hasCompletedOnboarding = true;
    
    await pumpBootstrapScreen(tester);
    // Allow logic to run and navigation to happen
    await tester.pump(const Duration(milliseconds: 500));

    // Verify navigation to Dashboard
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
