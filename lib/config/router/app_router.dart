/// App Router Configuration
/// 
/// Phase 41: Navigation Architecture Improvement
/// 
/// Centralised GoRouter configuration with:
/// - Declarative route definitions
/// - Redirect logic for auth/onboarding guards
/// - Deep link integration
/// - Reactive state updates via refreshListenable
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/onboarding/state/onboarding_state.dart'; // Added for Strangler Fig

import '../../data/app_state.dart';
import '../../data/services/onboarding/onboarding_orchestrator.dart';
import '../../data/services/voice_session_manager.dart';
import '../../data/enums/voice_session_mode.dart'; // Added for Unification
import '../../data/providers/psychometric_provider.dart'; // Added for Commitment Checks
import '../../core/logging/app_logger.dart'; // Robust Logging
import '../../features/navigation/scaffold_with_navbar.dart'; // Phase 4: ShellRoute

// Feature screens
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/conversational_onboarding_screen.dart';
import '../../features/onboarding/voice_coach_screen.dart';
import '../../data/models/voice_session_config.dart';

import '../../features/onboarding/identity_first/identity_access_gate_screen.dart';
import '../../features/onboarding/identity_first/witness_investment_screen.dart';
import '../../features/onboarding/identity_first/pact_tier_selector_screen.dart';

import '../../features/onboarding/screens/permissions_screen.dart';
import '../../features/onboarding/screens/loading_insights_screen.dart';
import '../../features/onboarding/screens/tier_selection_screen.dart';
import '../../features/dashboard/habit_list_screen.dart';
import '../../features/today/today_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/analytics/analytics_screen.dart';
import '../../features/settings/data_management_screen.dart';
import '../../features/settings/habit_edit_screen.dart';
import '../../features/contracts/create_contract_screen.dart';
import '../../features/contracts/join_contract_screen.dart';
import '../../features/contracts/contracts_list_screen.dart';
import '../../features/witness/witness_accept_screen.dart';
import '../../features/witness/witness_dashboard.dart';
import '../../features/onboarding/pact_reveal_screen.dart';
import '../../features/onboarding/identity_first/sherlock_permission_screen.dart';
import '../../features/onboarding/screens/goal_screening_screen.dart';
import '../../features/onboarding/screens/oracle_coach_screen.dart';
import '../../features/onboarding/screens/misalignment_screen.dart';
import '../../features/onboarding/identity_first/value_proposition_screen.dart';
import '../../features/onboarding/bootstrap_screen.dart';

import 'app_routes.dart';

/// Creates and configures the app's GoRouter instance
/// 
/// Usage in main.dart:
/// ```dart
/// final router = AppRouter.createRouter(appState, onboardingState);
/// ```
class AppRouter {
  /// Create the GoRouter instance with all routes and redirect logic
  /// 
  /// [appState] - The AppState instance for reactive updates and auth checks
  /// [onboardingState] - The OnboardingState instance (Strangler Fig) for v4 logic
  static GoRouter createRouter(AppState appState, OnboardingState onboardingState) {
    return GoRouter(
      initialLocation: appState.hasCompletedOnboarding 
          ? AppRoutes.dashboard 
          : AppRoutes.bootstrap, // Phase 52: Bootstrap handles async checks
      // Phase 7.2: Listen to BOTH states for routing changes
      refreshListenable: Listenable.merge([appState, onboardingState]),
      debugLogDiagnostics: kDebugMode,
      redirect: (context, state) => _redirect(context, state, appState, onboardingState),
      observers: [
        _NavigationLogger(),
      ],
      routes: _buildRoutes(),
    );
  }
  
  /// Global redirect logic for auth and onboarding guards
  /// 
  /// Returns:
  /// - null: No redirect, proceed to requested route
  /// - String: Redirect to this route instead
  static String? _redirect(
    BuildContext context, 
    GoRouterState state, 
    AppState appState,
    OnboardingState onboardingState,
  ) {
    final location = state.matchedLocation;
    final isOnboardingRoute = location.startsWith('/onboarding') || 
                               location == AppRoutes.home ||
                               AppRoutes.nicheRoutes.contains(location);
    
    // Guard 0: Commitment Alignment (Phase 5)
    // Prevents Side Door access to deep onboarding steps without verified commitment
    
    // Check 1: Permission Flags (Delegated to OnboardingState via AppState wrapper OR direct)
    // We access via appState's delegated checkCommitment for now to maintain API consistency,
    // but we could also use logical separation here. 
    // Since AppRouter now knows about OnboardingState, let's keep using appState's wrapper 
    // as the "Facade" until full extraction.
    final commitmentRedirect = appState.checkCommitment(location);
    if (commitmentRedirect != null) {
      AppLogger.info('AppRouter: 🛑 Commitment Broker Triggered');
      AppLogger.info('  - Reason: Missing Permissions per v4 Protocol');
      AppLogger.info('  - Action: Redirecting to $commitmentRedirect');
      return commitmentRedirect;
    }

    // Check 2: Data Integrity (Psychometric Profile)
    // Critical: Must have valid "Holy Trinity" data to enter Screening/Oracle
    if (location.startsWith('/onboarding/oracle') || location.startsWith('/onboarding/screening')) {
      // Exception: If we have completed onboarding fully, allow access (e.g. re-visiting)
      if (!appState.hasCompletedOnboarding) {
         try {
           final psychProvider = context.read<PsychometricProvider>();
           if (!psychProvider.profile.hasHolyTrinity) {
              AppLogger.info('AppRouter: 🛑 Data Integrity Guard Triggered');
              AppLogger.info('  - Reason: Missing "Holy Trinity" Psych Data');
              AppLogger.info('  - Action: Redirecting to Misalignment (Step 10)');
              // If they don't have the data, they haven't done the work.
              // We could send them to Sherlock (Start) or Misalignment (Fail).
              // Per v4 spec: "User Commitment Misalignment Detected" if steps skipped.
              return AppRoutes.misalignment;
           }
         } catch (e) {
           AppLogger.error('AppRouter: 🛑 Guard Error: $e');
           return AppRoutes.home;
         }
      }
    }
    
    // Guard 1: Redirect authenticated users away from onboarding
    // Exception: Allow access to voice coach from dashboard
    if (appState.hasCompletedOnboarding && 
        location == AppRoutes.home) {
      AppLogger.info('AppRouter: 🔄 Auto-Redirect (Completed User) -> Dashboard');
      return AppRoutes.dashboard;
    }
    
    // Guard 2: Redirect unauthenticated users to onboarding
    // Exception: Allow public routes (niche landing pages, onboarding flow)
    if (!appState.hasCompletedOnboarding && 
        !isOnboardingRoute &&
        !location.startsWith('/contracts/join') && 
        location != AppRoutes.bootstrap) { // Allow bootstrap to run
      // If user tries to access a protected route (e.g. /dashboard) without auth,
      // redirect them. 
      // Note: Bootstrap will handle determining if they should go to Home or SideDoor.
      AppLogger.info('AppRouter: 🛡️ Security Guard -> Home');
      AppLogger.info('  - Attempted: $location');
      return AppRoutes.home;
    }
    
    // No redirect needed (Explicit Approval)
    // Only log if not just "null" (to reduce spam, or keep at debug level)
    return null;
  }
  
  /// Build all route definitions
  static List<RouteBase> _buildRoutes() {
    return [
      GoRoute(
        path: AppRoutes.bootstrap,
        builder: (context, state) => const BootstrapScreen(),
      ),
      // ============================================================
      // ONBOARDING ROUTES
      // ============================================================
      
      // Phase 29: Value First Flow (Hook Screen)
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const ValuePropositionScreen(),
      ),
      
      GoRoute(
        path: AppRoutes.onboardingPermissions,
        builder: (context, state) => const PermissionsScreen(),
      ),

      GoRoute(
        path: AppRoutes.onboardingLoading,
        builder: (context, state) => const LoadingInsightsScreen(),
      ),

      GoRoute(
        path: AppRoutes.onboardingTierSelection,
        builder: (context, state) => const TierSelectionScreen(),
      ),

      GoRoute(
        path: AppRoutes.onboardingSherlock,
        builder: (context, state) => VoiceCoachScreen(
          config: VoiceSessionConfig.sherlock.copyWith(
            initialMessage: "I ({Name}) want to become a Writer [Identity]. "
                "My Anti-Identity is The Ghost because I fear disappearing without a legacy [Anti-Identity]. "
                "My history of failure is due to Perfectionism, I quit if it's not perfect [Failure Archetype]. "
                "The lie I tell myself is 'I need more research' to avoid starting [Resistance Lie]. "
                "I am ready to seal this Pact",
          ),
        ), 
      ),
      
      // Text chat onboarding
      GoRoute(
        path: AppRoutes.chatOnboarding,
        builder: (context, state) => const ConversationalOnboardingScreen(isOnboarding: true),
      ),
      
      // Add habit via chat (distinct from onboarding)
      GoRoute(
        path: AppRoutes.habitAdd,
        builder: (context, state) => const ConversationalOnboardingScreen(isOnboarding: false),
      ),
      
      // Voice onboarding: Gemini Live API (Phase 27.5)
      GoRoute(
        path: AppRoutes.voiceOnboarding,
        builder: (context, state) => VoiceCoachScreen(), // Not const
      ),
      
      // Manual onboarding: Form UI (Tier 4 fallback)
      GoRoute(
        path: AppRoutes.manualOnboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Identity First Onboarding (Phase 27.17)
      GoRoute(
        path: AppRoutes.identityOnboarding,
        builder: (context, state) => const IdentityAccessGateScreen(),
      ),
      GoRoute(
        path: AppRoutes.witnessOnboarding,
        builder: (context, state) => WitnessInvestmentScreen(
          voiceSessionManager: context.read<VoiceSessionManager>(),
        ),
      ),
      GoRoute(
        path: AppRoutes.tierOnboarding,
        builder: (context, state) => const PactTierSelectorScreen(),
      ),
      
      // Sherlock Permissions (The Data Handshake)
      GoRoute(
        path: AppRoutes.sherlockPermissions,
        builder: (context, state) => const SherlockPermissionScreen(),
      ),
      
      // Phase 43: Pact Reveal Screen (Variable Reward)
      GoRoute(
        path: AppRoutes.pactReveal,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PactRevealScreen(habitId: extra?['habitId']);
        },
      ),

      // Step 8: Goal Screening
      GoRoute(
        path: AppRoutes.screening,
        builder: (context, state) => const GoalScreeningScreen(),
      ),

      // Step 9: Oracle Coach
      GoRoute(
        path: AppRoutes.oracle,
        builder: (context, state) => const OracleCoachScreen(),
      ),

      // Step 10: Misalignment
      GoRoute(
        path: AppRoutes.misalignment,
        builder: (context, state) => const MisalignmentScreen(),
      ),
      
      // ============================================================
      // NICHE LANDING PAGES (Side Doors)
      // ============================================================
      
      _buildNicheRoute(AppRoutes.devs, 'A World-Class Developer'),
      _buildNicheRoute(AppRoutes.writers, 'A Best-Selling Author'),
      _buildNicheRoute(AppRoutes.scholars, 'A Distinguished Scholar'),
      _buildNicheRoute(AppRoutes.languages, 'A Fluent Polyglot'),
      _buildNicheRoute(AppRoutes.makers, 'A Prolific Maker'),
      
      // ============================================================
      // MAIN APP ROUTES (SHELL ROUTE)
      // ============================================================
      
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Branch A: Today (Focus Mode)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.today,
                builder: (context, state) => const TodayScreen(),
              ),
            ],
          ),
          
          // Branch B: Habits (Dashboard)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) => const HabitListScreen(),
              ),
            ],
          ),
          
          // Branch C: Settings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.history,
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.analytics,
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: AppRoutes.dataManagement,
        builder: (context, state) => const DataManagementScreen(),
      ),
      
      // ============================================================
      // HABIT ROUTES
      // ============================================================
      
      GoRoute(
        path: '/habit/:habitId/edit',
        builder: (context, state) {
          final habitId = state.pathParameters['habitId'] ?? '';
          return HabitEditScreen(habitId: habitId);
        },
      ),
      
      // ============================================================
      // CONTRACT ROUTES (Phase 16)
      // ============================================================
      
      GoRoute(
        path: AppRoutes.contracts,
        builder: (context, state) => const ContractsListScreen(),
      ),
      GoRoute(
        path: AppRoutes.contractCreate,
        builder: (context, state) {
          final habitId = state.uri.queryParameters['habitId'];
          return CreateContractScreen(habitId: habitId);
        },
      ),
      GoRoute(
        path: '/contracts/join/:inviteCode',
        builder: (context, state) {
          final inviteCode = state.pathParameters['inviteCode'] ?? '';
          return JoinContractScreen(inviteCode: inviteCode);
        },
      ),
      
      // ============================================================
      // WITNESS ROUTES (Phase 22)
      // ============================================================
      
      GoRoute(
        path: AppRoutes.witness,
        builder: (context, state) => const WitnessDashboard(),
      ),
      GoRoute(
        path: '/witness/accept/:inviteCode',
        builder: (context, state) {
          final inviteCode = state.pathParameters['inviteCode'] ?? '';
          return WitnessAcceptScreen(inviteCode: inviteCode);
        },
      ),
    ];
  }
  
  /// Helper to build niche landing page routes with preset identity
  static GoRoute _buildNicheRoute(String path, String presetIdentity) {
    return GoRoute(
      path: path,
      builder: (context, state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<OnboardingOrchestrator>().setNicheFromUrl(path);
        });
        return IdentityAccessGateScreen(presetIdentity: presetIdentity);
      },
    );
  }
}

/// Simple logger to track active screens
class _NavigationLogger extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (kDebugMode) {
      debugPrint('AppRouter: [NAV] Pushed: ${route.settings.name}');
    }
  }
}
