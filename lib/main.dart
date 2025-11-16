import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/app_state.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/today/today_screen.dart';
import 'features/settings/settings_screen.dart';

void main() async {
  // Ensure Flutter is initialized before async operations
  WidgetsFlutterBinding.ensureInitialized();
  
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

          // Configure navigation routes
          final router = GoRouter(
            initialLocation: appState.hasCompletedOnboarding ? '/today' : '/',
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const OnboardingScreen(),
              ),
              GoRoute(
                path: '/today',
                builder: (context, state) => const TodayScreen(),
              ),
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          );

          return MaterialApp.router(
            title: 'Atomic Habits Hook App',
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
