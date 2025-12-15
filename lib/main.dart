import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:home_widget/home_widget.dart';
import 'data/app_state.dart';
import 'data/services/gemini_chat_service.dart';
import 'data/services/weekly_review_service.dart';
import 'data/services/onboarding/onboarding_orchestrator.dart';
import 'data/services/home_widget_service.dart';
import 'config/ai_model_config.dart';
import 'core/error_boundary.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/onboarding/conversational_onboarding_screen.dart';
import 'features/dashboard/habit_list_screen.dart';
import 'features/today/today_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/history/history_screen.dart';
import 'features/analytics/analytics_screen.dart';
import 'features/settings/data_management_screen.dart';

void main() async {
  // Ensure Flutter is initialized before async operations
  WidgetsFlutterBinding.ensureInitialized();
  
  // Phase 6: Setup global error handling
  setupGlobalErrorHandling();
  
  // Initialize Hive for local data persistence
  await Hive.initFlutter();
  
  // Initialize AI services
  final geminiService = GeminiChatService(
    apiKey: AIModelConfig.geminiApiKey.isNotEmpty 
        ? AIModelConfig.geminiApiKey 
        : null,
  );
  await geminiService.init();
  
  runApp(MyApp(geminiService: geminiService));
}

class MyApp extends StatefulWidget {
  final GeminiChatService geminiService;
  
  const MyApp({super.key, required this.geminiService});

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
        // Gemini Chat Service (AI backend)
        Provider<GeminiChatService>.value(value: widget.geminiService),
        // Weekly Review Service (Phase 7)
        ProxyProvider<GeminiChatService, WeeklyReviewService>(
          update: (context, geminiService, previous) =>
              previous ?? WeeklyReviewService(geminiService),
        ),
        // Onboarding Orchestrator (AI orchestration) - ChangeNotifier for Phase 2
        ChangeNotifierProxyProvider<GeminiChatService, OnboardingOrchestrator>(
          create: (context) => OnboardingOrchestrator(
            geminiService: context.read<GeminiChatService>(),
          ),
          update: (context, geminiService, previous) {
            return previous ?? OnboardingOrchestrator(geminiService: geminiService);
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
            ],
          );

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
