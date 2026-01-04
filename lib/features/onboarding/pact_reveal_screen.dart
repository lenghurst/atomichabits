import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart'; // Phase 43: Social Accountability
import '../../config/router/app_routes.dart';
import '../../data/app_state.dart'; // Import AppState to load the specific habit
import '../../data/models/habit.dart'; // Import Habit model
import '../../data/providers/psychometric_provider.dart';
import '../../data/providers/user_provider.dart';
import '../../data/services/gemini_chat_service.dart';
import '../../domain/services/psychometric_engine.dart';

import '../../domain/entities/psychometric_profile.dart';
import '../../domain/entities/psychometric_profile_extensions.dart'; // Added extension import
import 'widgets/pact_identity_card.dart';

class PactRevealScreen extends StatefulWidget {
  // Add the habitId parameter to accept the ID passed from Onboarding
  final String? habitId;

  const PactRevealScreen({super.key, this.habitId});

  @override
  State<PactRevealScreen> createState() => _PactRevealScreenState();
}

class _PactRevealScreenState extends State<PactRevealScreen> 
    with SingleTickerProviderStateMixin {
  bool _showCard = false;
  String? _sherlockReport;
  String _loadingText = "VERIFYING IDENTITY PROTOCOL...";
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  
  // The specific habit created in the chat (The Seed)
  Habit? _createdHabit;

  @override
  void initState() {
    super.initState();
    
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(begin: 0.1, end: 0.3).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    
    _startRevealSequence();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _startRevealSequence() async {
    // Stage 1: Load the Data (Verification Step)
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    try {
      // VALIDATION: Load the habit from AppState using the ID passed in
      // Note: In identity-first flow, habitId may be null (habit created later)
      if (widget.habitId != null) {
        final appState = context.read<AppState>();
        // Ensure AppState is synced/loaded
        _createdHabit = appState.habits.cast<Habit?>().firstWhere(
          (h) => h?.id == widget.habitId,
          orElse: () => null,
        );
        if (_createdHabit != null) {
          debugPrint("✅ VERIFICATION SUCCESS: Found habit '${_createdHabit!.name}'");
        } else {
          debugPrint("ℹ️ Habit not found in state (may be created later in flow)");
        }
      }

      // Existing Sherlock Analysis logic...
      final provider = context.read<PsychometricProvider>();
      final userProvider = context.read<UserProvider>();
      final gemini = context.read<GeminiChatService>();
      
      final engine = PsychometricEngine();
      final prompt = engine.constructSherlockPrompt(
        provider.profile, 
        userProvider.identity,
      );
      
      final apiFuture = gemini.generateSherlockReport(prompt);
      final delayFuture = Future.delayed(const Duration(seconds: 2));
      
      final results = await Future.wait([apiFuture, delayFuture]);
      _sherlockReport = results[0] as String?;
      
    } catch (e) {
      debugPrint("Sherlock/Load Analysis Warning: $e");
      // Fallback delay if analysis fails
      await Future.delayed(const Duration(seconds: 2));
    }

    if (!mounted) return;
    setState(() => _loadingText = "LOCKING IDENTITY PROTOCOL...");
    
    // Stage 2: Finalising (2s)
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    
    HapticFeedback.heavyImpact();
    setState(() => _showCard = true);
  }

  Future<void> _continueToScreening() async {
    HapticFeedback.heavyImpact();
    if (!mounted) return;
    
    // Phase 43: Navigation Logic Update (Dec 2025)
    // We proceed to Step 7.5: Witness Investment
    // The "Pact" is the psychological commitment, but the "Protocol" (Screening/Coach) follows.
    
    if (mounted) {
      context.go(AppRoutes.witnessOnboarding);
    }
  }

  Future<void> _sharePact(Color accentColor) async {
    HapticFeedback.mediumImpact();
    final userProvider = context.read<UserProvider>();
    final identity = userProvider.identity;
    
    // Create a compelling share text that triggers curiosity
    final text = "I just sealed my pact to become a $identity with Atomic Habits. The protocol begins now.";
    
    try {
      // Use share_plus to invoke native share sheet
      await Share.share(text);
    } catch (e) {
      debugPrint("Share failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not launch share: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // If we loaded a specific habit, use its color/vibe, otherwise fallback to profile
    final rawProfile = context.watch<PsychometricProvider>().profile;
    final archetypeColor = rawProfile.archetypeColor;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5,
                    colors: [
                      archetypeColor.withValues(alpha: _glowAnimation.value),
                      Colors.black,
                    ],
                  ),
                ),
              );
            },
          ),

          SafeArea(
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 1200),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeIn,
                child: _showCard
                    // Pass the created habit to the build method
                    ? _buildResult(rawProfile, archetypeColor)
                    : _buildLoadingState(archetypeColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ... _buildLoadingState remains the same ...
  Widget _buildLoadingState(Color accentColor) {
    return Column(
      key: const ValueKey('loading'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 2),
          ),
          child: Center(
            child: SizedBox(
              width: 50, height: 50,
              child: CircularProgressIndicator(color: accentColor, strokeWidth: 2),
            ),
          ),
        ),
        const SizedBox(height: 40),
        Text(
          _loadingText,
          style: const TextStyle(
            color: Colors.white,
            letterSpacing: 3,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildResult(dynamic profile, Color accentColor) {
    return Column(
      key: const ValueKey('result'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: accentColor.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified, color: accentColor, size: 14),
              const SizedBox(width: 8),
              Text(
                "IDENTITY SEED PLANTED", // Changed text to reflect "Third Way"
                style: TextStyle(
                  color: accentColor,
                  letterSpacing: 3,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        
        // Use your existing PactIdentityCard, but we are validating that 
        // the habit data exists by showing this screen at all.
        PactIdentityCard(
          profile: profile,
          sherlockReport: _sherlockReport,
          autoFlip: true,
          autoFlipDelay: const Duration(seconds: 2),
        ),
        
        const SizedBox(height: 20),
        
        // Validation Display: Show the Tiny Step created
        if (_createdHabit != null)
          Text(
            "FIRST STEP: ${_createdHabit!.tinyVersion.toUpperCase()}",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),

        const SizedBox(height: 40),
        _buildShareButton(profile, accentColor),
        const SizedBox(height: 16),
        _buildContinueButton(accentColor),
      ],
    );
  }

  Widget _buildShareButton(PsychometricProfile profile, Color accentColor) {
    return TextButton.icon(
      onPressed: () => _sharePact(accentColor),
      icon: Icon(Icons.share, color: accentColor, size: 18),
      label: Text(
        "SHARE MY PACT",
        style: TextStyle(color: accentColor, letterSpacing: 2, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildContinueButton(Color accentColor) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _continueToScreening,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24),
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: [
                accentColor.withValues(alpha: 0.1),
                Colors.transparent,
              ],
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "CONTINUE PROTOCOL", // Changed from ENTER THE GARDEN to match linear flow
                style: TextStyle(
                  color: Colors.white,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.arrow_forward, color: accentColor, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
