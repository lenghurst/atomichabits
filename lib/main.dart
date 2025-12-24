import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:home_widget/home_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/app_state.dart';
import 'data/services/ai/ai_service_manager.dart';
import 'data/services/weekly_review_service.dart';
import 'data/services/onboarding/onboarding_orchestrator.dart';
import 'data/services/home_widget_service.dart';
import 'data/services/auth_service.dart';
import 'data/services/sync_service.dart';
import 'data/services/voice_session_manager.dart';
import 'config/ai_model_config.dart';
import 'config/supabase_config.dart';
import 'core/error_boundary.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/onboarding/conversational_onboarding_screen.dart';
import 'features/onboarding/voice_onboarding_screen.dart';
import 'features/onboarding/identity_first/identity_access_gate_screen.dart';
import 'features/onboarding/identity_first/witness_investment_screen.dart';
import 'features/onboarding/identity_first/pact_tier_selector_screen.dart';
import 'features/onboarding/identity_first/value_proposition_screen.dart';
import 'features/dashboard/habit_list_screen.dart';
import 'features/today/today_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/history/history_screen.dart';
import 'features/analytics/analytics_screen.dart';
import 'features/settings/data_management_screen.dart';
import 'features/settings/habit_edit_screen.dart';
import 'features/contracts/create_contract_screen.dart';
import 'features/contracts/join_contract_screen.dart';
import 'features/contracts/contracts_list_screen.dart';
import 'data/services/contract_service.dart';
import 'data/services/sound_service.dart';
import 'data/services/feedback_service.dart';
import 'data/services/deep_link_service.dart';
import 'data/services/witness_service.dart';
import 'config/niche_config.dart';
import 'features/witness/witness_accept_screen.dart';
import 'features/witness/witness_dashboard.dart';

void main() async {
  // Ensure Flutter is initialized before async operations
  WidgetsFlutterBinding.ensureInitialized();
  
  // Phase 6: Setup global error handling
  setupGlobalErrorHandling();
  
  // Initialize Hive for local data persistence
  await Hive.initFlutter();
  
  // Phase 15: Initialize Supabase for cloud sync (if configured)
  SupabaseClient? supabaseClient;
  if (SupabaseConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );
      supabaseClient = Supabase.instance.client;
      if (kDebugMode) {
        debugPrint('Supabase initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Supabase initialization failed: $e');
        debugPrint('App will continue in offline mode');
      }
    }
  } else {
    if (kDebugMode) {
      debugPrint('Supabase not configured - running in local-only mode');
      debugPrint('Set SUPABASE_URL and SUPABASE_ANON_KEY to enable cloud sync');
    }
  }
  
  // Phase 24: Initialize AI Service Manager (The Brain Transplant)
  final aiServiceManager = AIServiceManager();

  // Phase 32: Initialize Voice Session Manager (The Silent Coach)
  final voiceSessionManager = VoiceSessionManager();
  
  // Phase 15: Initialize Auth service
  final authService = AuthService(supabaseClient: supabaseClient);
  await authService.initialize();
  
  // Phase 15: Initialize Sync service
  final syncService = SyncService(
    supabaseClient: supabaseClient,
    authService: authService,
  );
  await syncService.initialize();
  
  // Phase 16.2: Initialize Contract service
  final contractService = ContractService(
    supabaseClient: supabaseClient,
    authService: authService,
  );
  
  // Phase 18: Initialize Sound service
  final soundService = SoundService();
  await soundService.initialize();
  
  // Phase 20: Initialize Feedback service (Destroyer Defense)
  await FeedbackService.initialize();
  
  // Phase 21.1: Initialize Deep Link service (The Viral Engine)
  final deepLinkService = DeepLinkService();
  
  // Phase 22: Initialize Witness service (The Accountability Loop)
  final witnessService = WitnessService(
    supabaseClient: supabaseClient,
    authService: authService,
    contractService: contractService,
  );
  await witnessService.initialize();

  // Initialize AppState (moved from MultiProvider to main to prevent router recreation loops)
  final appState = AppState();
  await appState.initialize();

  // Initialize dependent services
  final weeklyReviewService = WeeklyReviewService(aiServiceManager);
  final onboardingOrchestrator = OnboardingOrchestrator(aiServiceManager: aiServiceManager);
  
  runApp(
    MultiProvider(
      providers: [
        // App State (central state management)
        ChangeNotifierProvider.value(value: appState),
        // Phase 24: AI Service Manager (The Brain)
        ChangeNotifierProvider.value(value: aiServiceManager),
        // Phase 15: Auth Service (Identity Foundation)
        ChangeNotifierProvider.value(value: authService),
        // Phase 15: Sync Service (Cloud Backup)
        ChangeNotifierProvider.value(value: syncService),
        // Phase 16.2: Contract Service (Habit Contracts)
        ChangeNotifierProvider.value(value: contractService),
        // Phase 18: Sound Service (The Pulse)
        ChangeNotifierProvider.value(value: soundService),
        // Phase 21.1: Deep Link Service (The Viral Engine)
        ChangeNotifierProvider.value(value: deepLinkService),
        // Phase 22: Witness Service (The Accountability Loop)
        ChangeNotifierProvider.value(value: witnessService),
        // Weekly Review Service
        Provider.value(value: weeklyReviewService),
        // Onboarding Orchestrator
        ChangeNotifierProvider.value(value: onboardingOrchestrator),
        
        // Phase 32: Voice Session Manager
        Provider.value(value: voiceSessionManager),
      ],
      child: MyApp(
        appState: appState,
        deepLinkService: deepLinkService,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final AppState appState;
  final DeepLinkService deepLinkService;
  
  const MyApp({
    super.key, 
    required this.appState,
    required this.deepLinkService,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Phase 9: Stream subscription for widget clicks
  StreamSubscription<Uri?>? _widgetClickSubscription;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    
    // Initialize Router ONCE to prevent recreation loops on state changes
    _router = GoRouter(
      initialLocation: widget.appState.hasCompletedOnboarding ? '/dashboard' : '/',
      refreshListenable: widget.appState, // Listen to app state changes for redirects
      routes: [
        // Phase 29: Value First Flow (Second Council of Five)
        // All new users start with the Hook Screen (value proposition)
        // Then proceed to identity declaration + OAuth
        GoRoute(
          path: '/',
          builder: (context, state) => const ValuePropositionScreen(),
        ),
        // Legacy onboarding routes (accessible via Developer Mode or direct navigation)
        GoRoute(
          path: '/onboarding/chat',
          builder: (context, state) => const ConversationalOnboardingScreen(isOnboarding: true),
        ),
        // Phase 64: Distinct route for adding habits (avoids onboarding loop)
        GoRoute(
          path: '/habit/add',
          builder: (context, state) => const ConversationalOnboardingScreen(isOnboarding: false),
        ),
        // Voice onboarding: Gemini Live API (Phase 27.5)
        GoRoute(
          path: '/onboarding/voice',
          builder: (context, state) => const VoiceOnboardingScreen(),
        ),
        // Manual onboarding: Form UI (Tier 3 fallback)
        GoRoute(
          path: '/onboarding/manual',
          builder: (context, state) => const OnboardingScreen(),
        ),
        
        // ========== Identity First Onboarding (Phase 27.17) ==========
        // New onboarding flow based on Figma designs
        GoRoute(
          path: '/onboarding/identity',
          builder: (context, state) => const IdentityAccessGateScreen(),
        ),
        GoRoute(
          path: '/onboarding/witness',
          builder: (context, state) => WitnessInvestmentScreen(
            voiceSessionManager: context.read<VoiceSessionManager>(),
          ),
        ),
        GoRoute(
          path: '/onboarding/tier',
          builder: (context, state) => const PactTierSelectorScreen(),
        ),
        
        // ========== Phase 19: Side Door Landing Pages ==========
        // Phase 28.4 (Musk): Route consolidation with preset identities
        // Each niche gets its own "front door" with pre-filled identity
        // Eliminates the old ConversationalOnboardingScreen entirely
        
        // Developer door: r/programming, HackerNews
        GoRoute(
          path: '/devs',
          builder: (context, state) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<OnboardingOrchestrator>().setNicheFromUrl('/devs');
            });
            return const IdentityAccessGateScreen(
              presetIdentity: 'A World-Class Developer',
            );
          },
        ),
        // Writer door: r/writing, Medium
        GoRoute(
          path: '/writers',
          builder: (context, state) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<OnboardingOrchestrator>().setNicheFromUrl('/writers');
            });
            return const IdentityAccessGateScreen(
              presetIdentity: 'A Best-Selling Author',
            );
          },
        ),
        // Scholar door: r/GradSchool, academic Twitter
        GoRoute(
          path: '/scholars',
          builder: (context, state) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<OnboardingOrchestrator>().setNicheFromUrl('/scholars');
            });
            return const IdentityAccessGateScreen(
              presetIdentity: 'A Distinguished Scholar',
            );
          },
        ),
        // Language learner door: Duolingo refugees
        GoRoute(
          path: '/languages',
          builder: (context, state) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<OnboardingOrchestrator>().setNicheFromUrl('/languages');
            });
            return const IdentityAccessGateScreen(
              presetIdentity: 'A Fluent Polyglot',
            );
          },
        ),
        // Indie maker door: IndieHackers
        GoRoute(
          path: '/makers',
          builder: (context, state) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<OnboardingOrchestrator>().setNicheFromUrl('/makers');
            });
            return const IdentityAccessGateScreen(
              presetIdentity: 'A Prolific Maker',
            );
          },
        ),
        // Dashboard: Multi-habit list (Phase 4)
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const HabitListScreen(),
        ),
        // Today: Focus mode for single habit (Phase 4 updated)
        GoRoute(
          path: '/today',
          builder: (context, state) => const TodayScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        // History: Calendar view (Phase 5)
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryScreen(),
        ),
        // Analytics: Dashboard with charts (Phase 10)
        GoRoute(
          path: '/analytics',
          builder: (context, state) => const AnalyticsScreen(),
        ),
        // Data Management: Backup & Restore (Phase 11)
        GoRoute(
          path: '/data-management',
          builder: (context, state) => const DataManagementScreen(),
        ),
        // Habit Edit: Edit habit properties + stacking (Phase 13)
        GoRoute(
          path: '/habit/:habitId/edit',
          builder: (context, state) {
            final habitId = state.pathParameters['habitId'] ?? '';
            return HabitEditScreen(habitId: habitId);
          },
        ),
        // Phase 16.2: Contracts routes
        GoRoute(
          path: '/contracts',
          builder: (context, state) => const ContractsListScreen(),
        ),
        GoRoute(
          path: '/contracts/create',
          builder: (context, state) {
            final habitId = state.uri.queryParameters['habitId'];
            return CreateContractScreen(habitId: habitId);
          },
        ),
        // Phase 16.4: Deep Link for contract join
        GoRoute(
          path: '/contracts/join/:inviteCode',
          builder: (context, state) {
            final inviteCode = state.pathParameters['inviteCode'] ?? '';
            return JoinContractScreen(inviteCode: inviteCode);
          },
        ),
        // Phase 22: Witness routes (The Accountability Loop)
        GoRoute(
          path: '/witness',
          builder: (context, state) => const WitnessDashboard(),
        ),
        GoRoute(
          path: '/witness/accept/:inviteCode',
          builder: (context, state) {
            final inviteCode = state.pathParameters['inviteCode'] ?? '';
            return WitnessAcceptScreen(inviteCode: inviteCode);
          },
        ),
      ],
    );
    
    // Phase 21.1: Initialize deep link service with router
    widget.deepLinkService.setRouter(_router);
  }

  @override
  void dispose() {
    _widgetClickSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Consumer is no longer needed for AppState creation, but we still watch it for UI updates
    // However, MaterialApp.router listens to the router, which listens to AppState (refreshListenable)
    // So we don't strictly need Consumer here unless we want to rebuild MaterialApp on other changes
    // like themeMode.
    
    final appState = context.watch<AppState>();
    
    // Show loading screen while initializing (though main() waits for it now, so this might be redundant but safe)
    if (appState.isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Loading your habits...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Phase 9: Set up widget click listener (once app is loaded)
    _widgetClickSubscription?.cancel();
    _widgetClickSubscription = appState.widgetClickStream.listen((uri) {
      if (uri != null) {
        if (kDebugMode) {
          debugPrint('Widget click received: $uri');
        }
        appState.handleWidgetUri(uri);
      }
    });

    // Phase 6: Dynamic theming based on AppState settings
    return MaterialApp.router(
      title: 'The Pact',
      debugShowCheckedModeBanner: false,
      themeMode: appState.themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: const CardThemeData(
          elevation: 2,
          margin: EdgeInsets.zero,
        ),
        // Custom snackbar theme for AI feedback
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        cardTheme: const CardThemeData(
          elevation: 2,
          margin: EdgeInsets.zero,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
      routerConfig: _router,
    );
  }
}
