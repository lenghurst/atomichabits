import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/app_state.dart';
import 'data/services/gemini_chat_service.dart';
import 'data/services/weekly_review_service.dart';
import 'data/services/onboarding/onboarding_orchestrator.dart';
import 'config/ai_model_config.dart';
import 'core/error_boundary.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/onboarding/conversational_onboarding_screen.dart';
import 'features/dashboard/habit_list_screen.dart';
import 'features/today/today_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/history/history_screen.dart';

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

class MyApp extends StatelessWidget {
  final GeminiChatService geminiService;
  
  const MyApp({super.key, required this.geminiService});

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
        Provider<GeminiChatService>.value(value: geminiService),
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
