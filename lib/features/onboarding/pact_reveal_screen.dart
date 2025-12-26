import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/router/app_routes.dart';
import '../../data/providers/psychometric_provider.dart';
import '../../data/providers/user_provider.dart';
import '../../data/services/gemini_chat_service.dart';
import '../../domain/services/psychometric_engine.dart';
import '../../data/app_state.dart';
import '../../domain/entities/psychometric_profile.dart';
import '../../domain/entities/psychometric_profile_extensions.dart';
import 'widgets/pact_identity_card.dart';

/// The Pact Reveal Screen - The "Magic Moment"
/// 
/// Phase 43: The Variable Reward (Nir Eyal's Hook Model)
/// 
/// This screen creates a dramatic reveal sequence after the user completes
/// the Sherlock Protocol onboarding. It transforms the abstract AI conversation
/// into a tangible, screenshot-worthy artifact.
/// 
/// Flow:
/// 1. Loading state with fake "processing" messages (building tension)
/// 2. Heavy haptic feedback (the "unlock" moment)
/// 3. Card reveal with ambient glow based on archetype colour
/// 4. CTA to enter the dashboard
/// 
/// Psychology:
/// - The delay creates perceived value ("This is worth the wait")
/// - The haptic creates physical sensation ("I felt that unlock")
/// - The visual creates shareability ("I need to screenshot this")
class PactRevealScreen extends StatefulWidget {
  const PactRevealScreen({super.key});

  @override
  State<PactRevealScreen> createState() => _PactRevealScreenState();
}

class _PactRevealScreenState extends State<PactRevealScreen> 
    with SingleTickerProviderStateMixin {
  bool _showCard = false;
  String? _sherlockReport; // Phase 48: AI-generated analysis
  String _loadingText = "ANALYSING SENSOR DATA...";
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  
  /// Fallback profile for resilience (Priority 3 from exec review)
  /// Used if AI analysis fails or times out
  static final _fallbackProfile = PsychometricProfile(
    antiIdentityLabel: "The Drifter",
    antiIdentityContext: "Goes with the flow, never commits",
    failureArchetype: "NOVELTY_SEEKER",
    failureTriggerContext: "Got bored and moved on",
    resistanceLieLabel: "The Tomorrow Trap",
    resistanceLieContext: "I'll start fresh next week",
  );

  @override
  void initState() {
    super.initState();
    
    // Glow animation for ambient effect
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
    // Stage 1: Analysis & Generation (Minimum 2s)
    await Future.delayed(const Duration(milliseconds: 500)); // Brief pause for UI stability
    if (!mounted) return;

    try {
      // Phase 48: Deep Sensor Analysis
      final provider = context.read<PsychometricProvider>();
      final userProvider = context.read<UserProvider>();
      final gemini = context.read<GeminiChatService>();
      
      // Ensure local sensors are synced first (optional, usually done in Permission screen)
      // await provider.syncSensors(); 
      
      final engine = PsychometricEngine();
      final prompt = engine.constructSherlockPrompt(
        provider.profile, 
        userProvider.identity,
      );
      
      // Run generation in parallel with minimum delay for tension
      final apiFuture = gemini.generateSherlockReport(prompt);
      final delayFuture = Future.delayed(const Duration(seconds: 2));
      
      final results = await Future.wait([apiFuture, delayFuture]);
      _sherlockReport = results[0] as String?;
      
    } catch (e) {
      debugPrint("Sherlock Analysis Failed: $e");
      // Fallback: Just wait out the delay
      await Future.delayed(const Duration(seconds: 2));
    }

    if (!mounted) return;
    setState(() => _loadingText = "LOCKING IDENTITY PROTOCOL...");
    
    // Stage 2: Finalising (2s)
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    
    // Stage 3: Final pause before reveal
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    
    // THE MOMENT: Heavy haptic + reveal
    HapticFeedback.heavyImpact();
    setState(() => _showCard = true);
  }

  /// Phase 44: The Investment
  /// 
  /// Finalize onboarding by:
  /// 1. Persisting PsychometricProfile to Hive (already saved per-trait, but ensure final)
  /// 2. Mark onboarding complete in UserProvider AND AppState
  /// 3. Navigate to Dashboard
  /// 
  /// The "Investment" in Nir Eyal's Hook Model:
  /// User has invested time + psychological insight → stored value → higher retention
  Future<void> _navigateToDashboard() async {
    // Heavy haptic for the "lock" moment
    HapticFeedback.heavyImpact();
    
    if (!mounted) return;
    
    // 1. Finalize psychometric profile (ensure persisted)
    final psychometricProvider = context.read<PsychometricProvider>();
    await psychometricProvider.finalizeOnboarding();
    
    // 2. Mark onboarding complete (new architecture)
    final userProvider = context.read<UserProvider>();
    await userProvider.completeOnboarding();
    
    // 3. Mark onboarding complete (legacy AppState - for router guard)
    // This is the "bridge" during Phase 34 Shadow Wiring
    final appState = context.read<AppState>();
    await appState.completeOnboarding();
    
    if (!mounted) return;
    
    // 4. Navigate to Dashboard (new identity unlocked!)
    context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final rawProfile = context.watch<PsychometricProvider>().profile;
    
    // Priority 3: Use fallback if no data was captured (resilience)
    final profile = rawProfile.hasDisplayableData ? rawProfile : _fallbackProfile;
    final archetypeColor = profile.archetypeColor;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Animated Ambient Background
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

          // Main Content
          SafeArea(
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 1200),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeIn,
                child: _showCard
                    ? _buildResult(profile, archetypeColor)
                    : _buildLoadingState(archetypeColor),
              ),
            ),
          ),
          
          // Skip Button (top right, only during loading)
          if (!_showCard)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: TextButton(
                onPressed: _navigateToDashboard,
                child: Text(
                  "SKIP",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(Color accentColor) {
    return Column(
      key: const ValueKey('loading'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pulsing Ring Animation
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 2),
          ),
          child: Center(
            child: SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                color: accentColor,
                strokeWidth: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        
        // Loading Text (changes through sequence)
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Text(
            _loadingText,
            key: ValueKey(_loadingText),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              letterSpacing: 3,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Subtle progress dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildResult(dynamic profile, Color accentColor) {
    return Column(
      key: const ValueKey('result'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Header Badge
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
                "PROFILE LOCKED",
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
        
        // The Card (Auto-flips after 2 seconds)
        PactIdentityCard(
          profile: profile,
          sherlockReport: _sherlockReport,
          autoFlip: true,
          autoFlipDelay: const Duration(seconds: 2),
        ),
        const SizedBox(height: 40),
        
        // Priority 1: Share button for viral growth (Spotify Wrapped effect)
        _buildShareButton(profile, accentColor),
        
        const SizedBox(height: 16),
        
        // The "Continue" CTA
        _buildContinueButton(accentColor),
        
        const SizedBox(height: 16),
        
        // Subtle hint
        Text(
          "TAP CARD TO FLIP",
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 10,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
  
  /// Priority 1: Share Pact button for viral growth
  /// 
  /// Creates a shareable text that captures the user's identity.
  /// This is the "Spotify Wrapped" moment - identity content is the 
  /// most shared type of content (MBTI, Astrology, etc.)
  Widget _buildShareButton(PsychometricProfile profile, Color accentColor) {
    return TextButton.icon(
      onPressed: () => _sharePact(profile),
      icon: Icon(Icons.share, color: accentColor, size: 18),
      label: Text(
        "SHARE MY PACT",
        style: TextStyle(
          color: accentColor,
          letterSpacing: 2,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  /// Generate and share the Pact identity text
  void _sharePact(PsychometricProfile profile) {
    HapticFeedback.lightImpact();
    
    final shareText = '''
🔒 THE PACT 🔒

I AM BECOMING:
${profile.identityStatement}

I AM BURYING:
❌ ${profile.antiIdentityDisplay} ❌

MY RULE:
${profile.ruleStatement}

${profile.archetypeDescription}

Join the pact at thepact.co
#ThePact #IdentityFirst #NeverMissTwice
''';
    
    Share.share(
      shareText.trim(),
      subject: 'My Pact Identity',
    );
  }

  Widget _buildContinueButton(Color accentColor) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _navigateToDashboard,
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
                "ENTER THE PACT",
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
