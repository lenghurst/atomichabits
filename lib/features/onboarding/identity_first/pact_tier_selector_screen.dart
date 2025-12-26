import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import '../../../config/router/app_routes.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../data/app_state.dart';
import '../../../data/services/onboarding/onboarding_orchestrator.dart';

/// Pact Tier Selector Screen
/// 
/// Screen 3 of the Identity First onboarding flow.
/// Displays pricing tiers:
/// - Free: 1 active pact, basic tracking
/// - Builder ($12/mo): Unlimited pacts, AI Coach, social accountability
/// - Ally ($24/mo): Everything + priority coaching, community groups
/// 
/// Design: Bold tier cards with popular badge
class PactTierSelectorScreen extends StatefulWidget {
  const PactTierSelectorScreen({super.key});

  @override
  State<PactTierSelectorScreen> createState() => _PactTierSelectorScreenState();
}

class _PactTierSelectorScreenState extends State<PactTierSelectorScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String _selectedTier = 'builder'; // Default to most popular
  bool _isProcessing = false;
  late String witnessName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appState = context.read<AppState>();
    witnessName = appState.userProfile?.witnessName ?? "Your Supporter";
  }
  
  // Phase 30 (Zhuo Z4): Confetti celebration
  late ConfettiController _confettiController;
  
  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }
  
  @override
  void dispose() {
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _handleSelectTier(String tierId) async {
    if (_isProcessing) return;
    
    setState(() {
      _selectedTier = tierId;
      _isProcessing = true;
    });

    final appState = context.read<AppState>();
    
    // Phase 28.4 (Bezos): "Grandfathered" Trust Grant
    // For premium tiers, show trust dialog instead of payment
    if (tierId == 'builder' || tierId == 'ally') {
      final tierName = tierId == 'builder' ? 'Builder' : 'Ally';
      final confirmed = await _showTrustGrantDialog(tierName);
      
      if (confirmed && mounted) {
        // Grant premium access
        await appState.setPremiumStatus(true);
        
        // Log telemetry event for pricing validation
        // TODO: Send to analytics: payment_intent_captured, tier: tierId
        debugPrint('[Telemetry] payment_intent_captured: tier=$tierId');
        
        // Phase 30 (Zhuo Z4): Celebrate first pact creation!
        _confettiController.play();
        await _showCelebrationDialog();
        
        // Navigate to the Magic Moment (Pact Reveal)
        // Note: We don't complete onboarding here anymore, PactRevealScreen handles it
        if (mounted) context.go(AppRoutes.pactReveal);
      } else {
        setState(() => _isProcessing = false);
      }
    } else {
      // Free tier - proceed directly
      // Phase 30 (Zhuo Z4): Celebrate first pact creation!
      _confettiController.play();
      await _showCelebrationDialog();
      
      // Navigate to the Magic Moment (Pact Reveal)
      // Note: We don't complete onboarding here anymore, PactRevealScreen handles it
      if (mounted) {
        context.go(AppRoutes.pactReveal);
      }
    }
  }
  
  /// Phase 28.4 (Bezos): Show the "Early Access Grant" trust dialog
  Future<bool> _showTrustGrantDialog(String tierName) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF22C55E), Color(0xFF06B6D4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(
            Icons.stars,
            size: 32,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Early Access Grant',
          style: TextStyle(
            color: Color(0xFFF8FAFC),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 15,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(
                    text: 'As an early believer in The Pact, we are upgrading you to ',
                  ),
                  TextSpan(
                    text: tierName,
                    style: const TextStyle(
                      color: Color(0xFF22C55E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(
                    text: ' for free, for life.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.verified,
                    color: Color(0xFF22C55E),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Welcome to the inner circle.',
                      style: TextStyle(
                        color: Color(0xFF22C55E),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Maybe Later',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF22C55E),
            ),
            child: const Text('Accept Grant'),
          ),
        ],
      ),
    ) ?? false;
  }
  
  /// Phase 30 (Zhuo Z4): Show celebration dialog on first pact creation
  Future<void> _showCelebrationDialog() async {
    final appState = context.read<AppState>();
    final identity = appState.userProfile?.identity.isNotEmpty == true
        ? appState.userProfile!.identity
        : 'A Better Version of Yourself';
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(
            Icons.celebration,
            size: 32,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Your Pact is Sealed!',
          style: TextStyle(
            color: Color(0xFFF8FAFC),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 15,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(
                    text: 'You\'ve taken the first step towards becoming ',
                  ),
                  TextSpan(
                    text: identity,
                    style: const TextStyle(
                      color: Color(0xFF22C55E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(
                    text: '. This is where it begins.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.lightbulb,
                    color: Color(0xFFF59E0B),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tip: Check in daily to build momentum.',
                      style: TextStyle(
                        color: Color(0xFFF59E0B),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF22C55E),
            ),
            child: const Text('Let\'s Go!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final orchestrator = context.watch<OnboardingOrchestrator>();
    final habitName = orchestrator.extractedData?.name ?? "My Atomic Habit";
    final witnessName = appState.userProfile?.witnessName;
    final userName = appState.userProfile?.name ?? "I";
    
    final identity = appState.userProfile?.identity.isNotEmpty == true
        ? appState.userProfile!.identity
        : 'A Better Version of Yourself';

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // slate-900
      body: Stack(
        children: [
          // Phase 30 (Zhuo Z4): Confetti widget
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Color(0xFF22C55E),
                Color(0xFF3B82F6),
                Color(0xFFF59E0B),
                Color(0xFFEC4899),
                Color(0xFF8B5CF6),
              ],
              numberOfParticles: 30,
              gravity: 0.1,
            ),
          ),
          // Background gradient accents
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withValues(alpha: 0.05),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.05),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 0,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                color: const Color(0xFF06B6D4).withValues(alpha: 0.05),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF06B6D4).withValues(alpha: 0.05),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header Section
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand mark
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Step indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          border: Border.all(color: const Color(0xFF334155)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.auto_awesome,
                              size: 16,
                              color: Color(0xFF22C55E),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'STEP 3 OF 3',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF22C55E),
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Dynamic headline with identity
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            letterSpacing: -0.02,
                            color: Color(0xFFF8FAFC),
                          ),
                          children: [
                            const TextSpan(text: 'Build your life as '),
                            TextSpan(
                              text: identity,
                              style: const TextStyle(color: Color(0xFF22C55E)),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // --- NEW: THE CONTRACT CARD ---
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.gavel, color: Colors.amber, size: 16),
                                const SizedBox(width: 8),
                                const Text(
                                  "THE PLEDGE",
                                  style: TextStyle(
                                    fontSize: 10, 
                                    letterSpacing: 1.5, 
                                    color: Colors.white54, 
                                    fontWeight: FontWeight.w900
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "I, $userName, stake my reputation and money on:",
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            const SizedBox(height: 12),
                            // Dynamic Habit
                            Row(
                              children: [
                                const Icon(Icons.check_circle, size: 16, color: Color(0xFF4CAF50)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    habitName, 
                                    style: const TextStyle(
                                      color: Colors.white, 
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: Colors.white10, height: 24),
                            if (witnessName != null && witnessName.isNotEmpty)
                              Row(
                                children: [
                                  const Text("Witnessed by: ", style: TextStyle(color: Colors.white54)),
                                  Text(witnessName, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                                ],
                              ),
                          ],
                        ),
                      ),
                      // --- END CONTRACT CARD ---

                      const SizedBox(height: 16),

                      const Text(
                        'Choose your tools.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),

                // Tier Cards
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      // Phase 31 (Zhuo Z3): Pact Preview Card
                      // Shows users what they're about to create
                      _buildPactPreview(identity, witnessName),
                      const SizedBox(height: 16),
                      // Phase 30 (Hormozi H2): AI Coach Audio Sample
                      // Show the value of premium BEFORE asking for payment
                      _buildAICoachSample(),
                      const SizedBox(height: 24),
                      _TierCard(
                        tier: _Tier(
                          id: 'free',
                          name: 'Free',
                          price: '\$0',
                          priceSubtext: 'Forever',
                          icon: Icons.shield_outlined,
                          features: const [
                            'Create 1 active pact',
                            'Text Chat Sherlock Screening', // Changed from Basic tracking
                            'Solo accountability mode',
                            '7-day streak monitoring',
                          ],
                          buttonText: 'Start Free',
                          isPopular: false,
                        ),
                        isSelected: _selectedTier == 'free',
                        onSelect: () => _handleSelectTier('free'),
                      ),
                      const SizedBox(height: 16),
                      // Phase 30 (Kahneman K4): Simplified to Binary Choice
                      // Reduced cognitive load by removing the "Ally" tier
                      // Users now choose between Free and Premium (Builder)
                      _TierCard(
                        tier: _Tier(
                          id: 'builder',
                          name: 'Premium',
                          price: '\$12',
                          priceSubtext: 'per month',
                          icon: Icons.bolt,
                          features: const [
                            'Unlimited active pacts',
                            'Voice Flow (AI Voice Coach)', // Changed from AI Voice Coach (Gemini)
                            'Social accountability partners',
                            'Advanced analytics & insights',
                            'Priority support',
                          ],
                          buttonText: 'Seal the Pact',
                          isPopular: true,
                        ),
                        isSelected: _selectedTier == 'builder',
                        onSelect: () => _handleSelectTier('builder'),
                      ),
                      const SizedBox(height: 32),

                      // Transparency Statement
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                border: Border.all(color: const Color(0xFF334155)),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: Color(0xFF22C55E),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'All plans include a 14-day free trial. No surprises.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFCBD5E1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Cancel anytime. Your commitment matters more than our subscription.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Phase 30 (Hormozi H2): AI Coach Audio Sample Widget
  /// Shows a preview of the AI coach to demonstrate premium value
  Widget _buildAICoachSample() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E293B),
            const Color(0xFF1E293B).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFFEC4899)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.mic,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Voice Coach',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF8FAFC),
                      ),
                    ),
                    Text(
                      'Premium Feature',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              // Play button
              GestureDetector(
                onTap: () async {
                  // Play signature sound as placeholder
                  await _audioPlayer.play(AssetSource('sounds/sign.mp3'));
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Voice preview: "I am your Pact Coach."'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Sample transcript
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"Good morning! I noticed you\'ve been consistent with your writing habit for 5 days now. That\'s the kind of momentum that builds real change. Ready to make today count?"',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.graphic_eq,
                      size: 16,
                      color: const Color(0xFF22C55E).withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '15 sec sample',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Phase 31 (Zhuo Z3): Pact Preview Card
  /// Shows users what they're about to create before selecting a tier
  Widget _buildPactPreview(String identity, String? witnessName) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF22C55E).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: Color(0xFF22C55E),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Your Pact Preview',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF8FAFC),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Pact details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Identity
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Identity: ',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        identity,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF22C55E),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Supporter
                Row(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Supporter: ',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      witnessName ?? 'Solo mode',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: witnessName != null
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Start date
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Starts: ',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tier {
  final String id;
  final String name;
  final String price;
  final String priceSubtext;
  final IconData icon;
  final List<String> features;
  final String buttonText;
  final bool isPopular;

  _Tier({
    required this.id,
    required this.name,
    required this.price,
    required this.priceSubtext,
    required this.icon,
    required this.features,
    required this.buttonText,
    required this.isPopular,
  });
}

class _TierCard extends StatelessWidget {
  final _Tier tier;
  final bool isSelected;
  final VoidCallback onSelect;

  const _TierCard({
    required this.tier,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            border: Border.all(
              color: tier.isPopular
                  ? const Color(0xFF22C55E)
                  : isSelected
                      ? const Color(0xFF475569)
                      : const Color(0xFF334155),
              width: tier.isPopular ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: tier.isPopular
                ? [
                    BoxShadow(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.3),
                      blurRadius: 24,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: tier.isPopular
                              ? const Color(0xFF22C55E)
                              : const Color(0xFF334155),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          tier.icon,
                          size: 24,
                          color: tier.isPopular
                              ? const Color(0xFF0F172A)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        tier.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFF8FAFC),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        tier.price,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFF8FAFC),
                          letterSpacing: -0.02,
                        ),
                      ),
                      Text(
                        tier.priceSubtext,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Features
              ...tier.features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            color: tier.isPopular
                                ? const Color(0xFF22C55E)
                                : const Color(0xFF334155),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.check,
                            size: 14,
                            color: tier.isPopular
                                ? const Color(0xFF0F172A)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFCBD5E1),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),

              const SizedBox(height: 24),

              // CTA Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onSelect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tier.isPopular
                        ? const Color(0xFF22C55E)
                        : const Color(0xFF334155),
                    foregroundColor: tier.isPopular
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF8FAFC),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    tier.buttonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Popular badge
        if (tier.isPopular)
          Positioned(
            top: -10,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.bolt,
                      size: 12,
                      color: Color(0xFF0F172A),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'MOST POPULAR',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
