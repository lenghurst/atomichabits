import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Phase 41: Centralised Router
import 'config/router/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/app_state.dart';
import 'data/services/ai/ai_service_manager.dart';
import 'data/services/weekly_review_service.dart';
import 'data/services/onboarding/onboarding_orchestrator.dart';
import 'data/services/auth_service.dart';
import 'data/services/sync_service.dart';
import 'data/services/voice_session_manager.dart';
import 'config/supabase_config.dart';
import 'core/error_boundary.dart';
// Phase 41: Screen imports moved to app_router.dart
import 'data/services/contract_service.dart';
import 'data/services/sound_service.dart';
import 'data/services/feedback_service.dart';
import 'data/services/deep_link_service.dart';
import 'data/services/witness_service.dart';
// Phase 41: Witness screen imports moved to app_router.dart
import 'data/services/audio_cleanup_service.dart';
import 'data/services/gemini_voice_note_service.dart';
import 'data/services/psychometric_extraction_service.dart';

// Phase 2: Storage Infrastructure
import 'data/services/local_audio_service.dart';
import 'data/repositories/conversation_repository.dart';

// Phase 34: Shadow Wiring - New Architecture (Dark Launch)
// These providers are initialized but not yet consumed by UI
// They share the same Hive box as AppState for data consistency
import 'data/repositories/hive_settings_repository.dart';
import 'data/repositories/hive_user_repository.dart';
import 'data/repositories/hive_habit_repository.dart';
import 'data/repositories/hive_psychometric_repository.dart';
import 'data/providers/settings_provider.dart';
import 'data/providers/user_provider.dart';
import 'data/providers/habit_provider.dart';
import 'data/providers/psychometric_provider.dart';
import 'domain/services/psychometric_engine.dart';
import 'data/notification_service.dart';
import 'features/onboarding/state/onboarding_state.dart'; // Phase 7: Strangler State

void main() async {
  // Ensure Flutter is initialized before async operations
  WidgetsFlutterBinding.ensureInitialized();
  
  // Phase 4: Background cleanup for orphaned audio files
  AudioCleanupService.cleanupOldTTSFiles().catchError((e) {
    if (kDebugMode) debugPrint('Startup cleanup failed: $e');
  });
  
  // Phase 6: Setup global error handling
  setupGlobalErrorHandling();
  
  // Initialize Hive for local data persistence
  await Hive.initFlutter();
  
  // Phase 2: Initialize Local Audio Service (Hive)
  final localAudioService = LocalAudioService();
  await localAudioService.init();
  
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

  // 1. Initialize Repositories (Infrastructure Layer)
  final settingsRepository = HiveSettingsRepository();
  final userRepository = HiveUserRepository();
  final habitRepository = HiveHabitRepository();
  final psychometricRepository = HivePsychometricRepository();
  
  // 2. Initialize Domain Services
  final psychometricEngine = PsychometricEngine();
  
  // 3. Initialize Domain Providers (consuming Repositories)
  final settingsProvider = SettingsProvider(settingsRepository);
  final userProvider = UserProvider(userRepository);
  final notificationService = NotificationService();
  final habitProvider = HabitProvider(habitRepository, notificationService);
  final psychometricProvider = PsychometricProvider(
    psychometricRepository,
    psychometricEngine,
  );

  // Phase 15: Initialize Auth service
  final authService = AuthService(supabaseClient: supabaseClient);
  await authService.initialize();

  // Phase 4.5: Initialize Psychometric Extraction Service
  final psychometricExtractionService = PsychometricExtractionService(psychometricProvider);
  
  // Initialize Gemini Service with Psychometrics
  final geminiVoiceNoteService = GeminiVoiceNoteService(
    psychometricService: psychometricExtractionService,
    authService: authService,
  );

  // Phase 32: Initialize Voice Session Manager (The Silent Coach)
  final voiceSessionManager = VoiceSessionManager(service: geminiVoiceNoteService);
  
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

  // Phase 7.1: Initialize OnboardingState (The Fig)
  final onboardingState = OnboardingState();

  // Initialize AppState (moved from MultiProvider to main to prevent router recreation loops)
  final appState = AppState(onboardingState: onboardingState); // Inject dependency
  await appState.initialize();

  // Initialize dependent services
  final weeklyReviewService = WeeklyReviewService(aiServiceManager);
  final onboardingOrchestrator = OnboardingOrchestrator(aiServiceManager: aiServiceManager);
  
  // Phase 47: Link AppState to OnboardingOrchestrator (Fix for Dev Mode Toggle)
  // Ensure the orchestrator knows about premium status changes immediately
  appState.addListener(() {
    onboardingOrchestrator.setPremiumUser(appState.settings.developerMode);
  });
  // Initialize with current state
  onboardingOrchestrator.setPremiumUser(appState.settings.developerMode);
  
  // ========== Phase 34: Shadow Wiring (Dark Launch) ==========
  // Initialize new architecture providers alongside AppState
  // These share the same Hive box - no conflict, just different access patterns
  // UI still consumes AppState; these are "shadow" providers for testing
  
  // Repositories and Providers moved up for dependency injection (Phase 4.5)
  
  // Initialize providers (async operations)
  // These run in parallel with AppState, reading from same Hive box
  await Future.wait([
    settingsProvider.initialize(),
    userProvider.initialize(),
    habitProvider.initialize(),
    psychometricProvider.initialize(),
  ]);
  
  if (kDebugMode) {
    debugPrint('Phase 34: Shadow Wiring initialized (Dark Launch)');
    debugPrint('  - SettingsProvider: ready');
    debugPrint('  - UserProvider: ready');
    debugPrint('  - HabitProvider: ready');
    debugPrint('  - PsychometricProvider: ready');
  }
  // ========== End Phase 34 Shadow Wiring ==========
  
  runApp(
    MultiProvider(
      providers: [
        // Phase 2: Storage Infrastructure Providers
        Provider<LocalAudioService>(
          create: (_) => localAudioService,
          dispose: (_, service) => service.close(),
        ),
        Provider<ConversationRepository>(
          create: (_) => ConversationRepository(
            supabaseClient ?? Supabase.instance.client
          ),
        ),

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
        
        // Phase 7.1: Provide OnboardingState
        ChangeNotifierProvider.value(value: onboardingState),
        
        // Phase 32: Voice Session Manager
        ChangeNotifierProvider.value(value: voiceSessionManager),
        
        // ========== Phase 34: Shadow Providers (Dark Launch) ==========
        // These are available but not yet consumed by UI screens
        // They will replace AppState usage in Phase 35
        Provider.value(value: settingsRepository),
        Provider.value(value: userRepository),
        Provider.value(value: habitRepository),
        Provider.value(value: psychometricRepository),
        Provider.value(value: psychometricEngine),
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: userProvider),
        ChangeNotifierProvider.value(value: habitProvider),
        ChangeNotifierProvider.value(value: psychometricProvider),
        // ========== End Phase 34 Shadow Providers ==========
      ],
      child: MyApp(
        appState: appState,
        onboardingState: onboardingState, // Pass to MyApp
        deepLinkService: deepLinkService,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final AppState appState;
  final OnboardingState onboardingState; // Add this
  final DeepLinkService deepLinkService;
  
  const MyApp({
    super.key, 
    required this.appState,
    required this.onboardingState, // Add this
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
    
    // Phase 41: Use centralised AppRouter instead of inline routes
    // This reduces main.dart by ~180 lines and enables:
    // - Route constants (AppRoutes.dashboard)
    // - Redirect logic (auth/onboarding guards)
    // - Single source of truth for navigation
    // - Route constants (AppRoutes.dashboard)
    // - Redirect logic (auth/onboarding guards)
    // - Single source of truth for navigation
    _router = AppRouter.createRouter(
      widget.appState, 
      widget.onboardingState, // Pass the Fig
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
