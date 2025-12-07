import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'data/app_state.dart';
import 'features/auth/login_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/onboarding/ai_onboarding_screen.dart';
import 'features/today/today_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/bad_habit/bad_habit_screen.dart';
import 'features/social/social_screen.dart';
import 'features/creator/creator_mode_screen.dart';

void main() async {
  // Ensure Flutter is initialized before async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Hive for local data persistence
  await Hive.initFlutter();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final appState = AppState();
        // Initialize and load persisted data
        appState.initialize();
        return appState;
      },
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

          // Determine initial location based on auth and onboarding status
          String initialLocation;
          if (!appState.isAuthenticated) {
            // Not signed in → Login screen
            initialLocation = '/login';
          } else if (!appState.hasCompletedOnboarding) {
            // Signed in but not onboarded → AI Onboarding (default)
            initialLocation = '/onboarding';
          } else {
            // Signed in and onboarded → Today screen
            initialLocation = '/today';
          }

          // Configure navigation routes
          final router = GoRouter(
            initialLocation: initialLocation,
            redirect: (context, state) {
              final isAuthenticated = appState.isAuthenticated;
              final hasOnboarded = appState.hasCompletedOnboarding;
              final path = state.uri.path;

              // If not authenticated, redirect to login (except if already on login)
              if (!isAuthenticated && path != '/login') {
                return '/login';
              }

              // If authenticated but on login page, redirect appropriately
              if (isAuthenticated && path == '/login') {
                return hasOnboarded ? '/today' : '/onboarding';
              }

              // No redirect needed
              return null;
            },
            routes: [
              // Authentication
              GoRoute(
                path: '/login',
                builder: (context, state) => const LoginScreen(),
              ),

              // Onboarding (AI-powered by default)
              GoRoute(
                path: '/onboarding',
                builder: (context, state) => const AiOnboardingScreen(),
              ),

              // Form-based onboarding (fallback/alternative)
              GoRoute(
                path: '/form-onboarding',
                builder: (context, state) => const OnboardingScreen(),
              ),

              // Main app screens
              GoRoute(
                path: '/today',
                builder: (context, state) => const TodayScreen(),
              ),
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
              GoRoute(
                path: '/bad-habits',
                builder: (context, state) => const BadHabitScreen(),
              ),
              GoRoute(
                path: '/social',
                builder: (context, state) => const SocialScreen(),
              ),
              GoRoute(
                path: '/creator',
                builder: (context, state) => const CreatorModeScreen(),
              ),

              // Legacy route redirect
              GoRoute(
                path: '/',
                redirect: (context, state) {
                  if (!appState.isAuthenticated) return '/login';
                  if (!appState.hasCompletedOnboarding) return '/onboarding';
                  return '/today';
                },
              ),
            ],
          );

          return MaterialApp.router(
            title: 'Atomic Habits',
            debugShowCheckedModeBanner: false,
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
            ),
            routerConfig: router,
          );
        },
      ),
    );
  }
}
