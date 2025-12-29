import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../config/router/app_routes.dart';
import '../../../data/services/onboarding/onboarding_orchestrator.dart';
import '../../../data/app_state.dart';

/// Bootstrap Screen (Phase 52)
/// 
/// Intercepts app startup to safely handle asynchronous deep link checks
/// before committing the user to a specific onboarding route.
/// 
/// Resolves the "Side Door" race condition where AppRouter would
/// route to ValueProp before OnboardingOrchestrator detected an invite.
class BootstrapScreen extends StatefulWidget {
  const BootstrapScreen({super.key});

  @override
  State<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends State<BootstrapScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Wait for frame to avoid "Navigate during build" errors
    await Future.delayed(Duration.zero);
    
    // Safety 1: Authenticated users should never see this, but double-check
    final appState = context.read<AppState>();
    if (appState.hasCompletedOnboarding) {
       if (mounted) context.go(AppRoutes.dashboard);
       return;
    }

    try {
      final orchestrator = context.read<OnboardingOrchestrator>();
      
      // Wait for deep link checks (up to 2 seconds)
      // This allows the Orchestrator to check Clipboard, Install Referrer, etc.
      final inviteCode = await orchestrator.checkForDeferredDeepLink();
      
      if (!mounted) return;

      if (inviteCode != null) {
        // "Side Door": Route to witness accept flow
        // Construct the path manually since parameters aren't typed yet
        context.go('/witness/accept/$inviteCode'); 
      } else {
        // "Cold Start": Route to Standard Value Prop
        context.go(AppRoutes.home);
      }
    } catch (e) {
      debugPrint('🔴 Bootstrap Error: $e');
      // Safety 2: Fallback to standard flow to prevent soft-lock
      if (mounted) context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0F172A), // Slate-900 (Matches Identity Gate)
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Simple Brand Mark
            Icon(Icons.auto_awesome, color: Color(0xFF22C55E), size: 48),
            SizedBox(height: 24),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF22C55E), // Electric Green
              ),
            ),
          ],
        ),
      ),
    );
  }
}
