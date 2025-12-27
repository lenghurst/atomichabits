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

import '../../data/app_state.dart';
import '../../data/services/onboarding/onboarding_orchestrator.dart';
import '../../data/services/voice_session_manager.dart';
import '../../data/enums/voice_session_mode.dart'; // Added for Unification

// Feature screens
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/conversational_onboarding_screen.dart';
import '../../features/onboarding/voice_coach_screen.dart';

import '../../features/onboarding/identity_first/identity_access_gate_screen.dart';
import '../../features/onboarding/identity_first/witness_investment_screen.dart';
import '../../features/onboarding/identity_first/pact_tier_selector_screen.dart';

import '../../features/onboarding/screens/value_prop_screen.dart';
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

import 'app_routes.dart';

/// Creates and configures the app's GoRouter instance
/// 
/// Usage in main.dart:
/// ```dart
/// final router = AppRouter.createRouter(appState);
/// ```
class AppRouter {
  /// Create the GoRouter instance with all routes and redirect logic
  /// 
  /// [appState] - The AppState instance for reactive updates and auth checks
  static GoRouter createRouter(AppState appState) {
    return GoRouter(
      initialLocation: appState.hasCompletedOnboarding 
          ? AppRoutes.dashboard 
          : AppRoutes.home,
      refreshListenable: appState,
      debugLogDiagnostics: kDebugMode,
      redirect: (context, state) => _redirect(context, state, appState),
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
  ) {
    final location = state.matchedLocation;
    final isOnboardingRoute = location.startsWith('/onboarding') || 
                               location == AppRoutes.home ||
                               AppRoutes.nicheRoutes.contains(location);
    
    // Guard 1: Redirect authenticated users away from onboarding
    // Exception: Allow access to voice coach from dashboard
    if (appState.hasCompletedOnboarding && 
        location == AppRoutes.home) {
      if (kDebugMode) {
        debugPrint('AppRouter: Redirecting from home to dashboard (onboarding complete)');
      }
      return AppRoutes.dashboard;
    }
    
    // Guard 2: Redirect unauthenticated users to onboarding
    // Exception: Allow public routes (niche landing pages, onboarding flow)
    if (!appState.hasCompletedOnboarding && 
        !isOnboardingRoute &&
        !location.startsWith('/contracts/join')) {
      if (kDebugMode) {
        debugPrint('AppRouter: Redirecting to home (onboarding not complete)');
      }
      return AppRoutes.home;
    }
    
    // No redirect needed
    return null;
  }
  
  /// Build all route definitions
  static List<RouteBase> _buildRoutes() {
    return [
      // ============================================================
      // ONBOARDING ROUTES
      // ============================================================
      
      // Phase 29: Value First Flow (Hook Screen)
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const ValuePropScreen(),
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
        builder: (context, state) => const VoiceCoachScreen(mode: VoiceSessionMode.onboarding), // Unified Screen
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
        builder: (context, state) => const VoiceCoachScreen(),
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
        builder: (context, state) => const PactRevealScreen(),
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
      // MAIN APP ROUTES
      // ============================================================
      
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const HabitListScreen(),
      ),
      GoRoute(
        path: AppRoutes.today,
        builder: (context, state) => const TodayScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
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
