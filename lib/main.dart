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
import 'config/ai_model_config.dart';
import 'config/supabase_config.dart';
import 'core/error_boundary.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/onboarding/conversational_onboarding_screen.dart';
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
  
  runApp(MyApp(
    aiServiceManager: aiServiceManager,
    authService: authService,
    syncService: syncService,
    contractService: contractService,
    soundService: soundService,
    deepLinkService: deepLinkService,
    witnessService: witnessService,
  ));
}

class MyApp extends StatefulWidget {
  final AIServiceManager aiServiceManager;
  final AuthService authService;
  final SyncService syncService;
  final ContractService contractService;
  final SoundService soundService;
  final DeepLinkService deepLinkService;
  final WitnessService witnessService;
  
  const MyApp({
    super.key, 
    required this.aiServiceManager,
    required this.authService,
    required this.syncService,
    required this.contractService,
    required this.soundService,
    required this.deepLinkService,
    required this.witnessService,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Phase 9: Stream subscription for widget clicks
  StreamSubscription<Uri?>? _widgetClickSubscription;

  @override
  void dispose() {
    _widgetClickSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // App State (central state management)
        ChangeNotifierProvider(
          create: (context) {
            final appState = AppState();
            appState.initialize();
            return appState;
          },
        ),
        // Phase 24: AI Service Manager (The Brain)
        ChangeNotifierProvider<AIServiceManager>.value(value: widget.aiServiceManager),
        // Phase 15: Auth Service (Identity Foundation)
        ChangeNotifierProvider<AuthService>.value(value: widget.authService),
        // Phase 15: Sync Service (Cloud Backup)
        ChangeNotifierProvider<SyncService>.value(value: widget.syncService),
        // Phase 16.2: Contract Service (Habit Contracts)
        ChangeNotifierProvider<ContractService>.value(value: widget.contractService),
        // Phase 18: Sound Service (The Pulse)
        ChangeNotifierProvider<SoundService>.value(value: widget.soundService),
        // Phase 21.1: Deep Link Service (The Viral Engine)
        ChangeNotifierProvider<DeepLinkService>.value(value: widget.deepLinkService),
        // Phase 22: Witness Service (The Accountability Loop)
        ChangeNotifierProvider<WitnessService>.value(value: widget.witnessService),
        // Weekly Review Service (Phase 7 → Phase 24: Now uses AIServiceManager)
        ProxyProvider<AIServiceManager, WeeklyReviewService>(
          update: (context, aiServiceManager, previous) =>
              previous ?? WeeklyReviewService(aiServiceManager),
        ),
        // Onboarding Orchestrator (Phase 2 → Phase 24: Now uses AIServiceManager)
        ChangeNotifierProxyProvider<AIServiceManager, OnboardingOrchestrator>(
          create: (context) => OnboardingOrchestrator(
            aiServiceManager: context.read<AIServiceManager>(),
          ),
          update: (context, aiServiceManager, previous) {
            return previous ?? OnboardingOrchestrator(aiServiceManager: aiServiceManager);
          },
        ),
      ],
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          // Show loading screen while initializing
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

          // Configure navigation routes
          // Phase 4: Dashboard is home for returning users
          // Phase 2: Chat UI for new users, Form is fallback
          // Phase 21.1: Deep link service gets router reference
          final router = GoRouter(
            initialLocation: appState.hasCompletedOnboarding ? '/dashboard' : '/',
            routes: [
              // Default onboarding: Conversational UI (Phase 2)
              GoRoute(
                path: '/',
                builder: (context, state) => const ConversationalOnboardingScreen(),
              ),
              // Manual onboarding: Form UI (Tier 3 fallback)
              GoRoute(
                path: '/onboarding/manual',
                builder: (context, state) => const OnboardingScreen(),
              ),
              
              // ========== Phase 19: Side Door Landing Pages ==========
              // Each niche gets its own "front door" that sets context
              // The Architect AI adapts based on which door they entered
              
              // Developer door: r/programming, HackerNews
              GoRoute(
                path: '/devs',
                builder: (context, state) {
                  // Set niche context before showing onboarding
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.read<OnboardingOrchestrator>().setNicheFromUrl('/devs');
                  });
                  return const ConversationalOnboardingScreen();
                },
              ),
              // Writer door: r/writing, Medium
              GoRoute(
                path: '/writers',
                builder: (context, state) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.read<OnboardingOrchestrator>().setNicheFromUrl('/writers');
                  });
                  return const ConversationalOnboardingScreen();
                },
              ),
              // Scholar door: r/GradSchool, academic Twitter
              GoRoute(
                path: '/scholars',
                builder: (context, state) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.read<OnboardingOrchestrator>().setNicheFromUrl('/scholars');
                  });
                  return const ConversationalOnboardingScreen();
                },
              ),
              // Language learner door: Duolingo refugees
              GoRoute(
                path: '/languages',
                builder: (context, state) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.read<OnboardingOrchestrator>().setNicheFromUrl('/languages');
                  });
                  return const ConversationalOnboardingScreen();
                },
              ),
              // Indie maker door: IndieHackers
              GoRoute(
                path: '/makers',
                builder: (context, state) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.read<OnboardingOrchestrator>().setNicheFromUrl('/makers');
                  });
                  return const ConversationalOnboardingScreen();
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
          widget.deepLinkService.setRouter(router);

          // Phase 6: Dynamic theming based on AppState settings
          return MaterialApp.router(
            title: 'Atomic Habits Hook App',
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
            routerConfig: router,
          );
        },
      ),
    );
  }
}
