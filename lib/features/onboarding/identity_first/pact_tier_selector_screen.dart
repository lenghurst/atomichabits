import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../data/app_state.dart';

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
  String _selectedTier = 'builder'; // Default to most popular
  bool _isProcessing = false;

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
        
        await appState.completeOnboarding();
        context.go('/dashboard');
      } else {
        setState(() => _isProcessing = false);
      }
    } else {
      // Free tier - proceed directly
      await appState.completeOnboarding();
      
      if (mounted) {
        context.go('/dashboard');
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
                color: const Color(0xFF22C55E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF22C55E).withOpacity(0.3),
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

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final identity = appState.userProfile?.identity.isNotEmpty == true
        ? appState.userProfile!.identity
        : 'A Better Version of Yourself';

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // slate-900
      body: Stack(
        children: [
          // Background gradient accents
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withOpacity(0.05),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF22C55E).withOpacity(0.05),
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
                color: const Color(0xFF06B6D4).withOpacity(0.05),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF06B6D4).withOpacity(0.05),
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
                      _TierCard(
                        tier: _Tier(
                          id: 'free',
                          name: 'Free',
                          price: '\$0',
                          priceSubtext: 'Forever',
                          icon: Icons.shield_outlined,
                          features: const [
                            'Create 1 active pact',
                            'Basic commitment tracking',
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
                      _TierCard(
                        tier: _Tier(
                          id: 'builder',
                          name: 'Builder',
                          price: '\$12',
                          priceSubtext: 'per month',
                          icon: Icons.bolt,
                          features: const [
                            'Unlimited active pacts',
                            'Social accountability partners',
                            'AI Pact Coach guidance',
                            'Advanced streak analytics',
                            'Breach recovery tools',
                          ],
                          buttonText: 'Start Free Trial',
                          isPopular: true,
                        ),
                        isSelected: _selectedTier == 'builder',
                        onSelect: () => _handleSelectTier('builder'),
                      ),
                      const SizedBox(height: 16),
                      _TierCard(
                        tier: _Tier(
                          id: 'ally',
                          name: 'Ally',
                          price: '\$24',
                          priceSubtext: 'per month',
                          icon: Icons.workspace_premium,
                          features: const [
                            'Everything in Builder',
                            'Priority AI coaching',
                            'Community accountability groups',
                            'Custom pact templates',
                            'Lifetime achievement vault',
                          ],
                          buttonText: 'Start Free Trial',
                          isPopular: false,
                        ),
                        isSelected: _selectedTier == 'ally',
                        onSelect: () => _handleSelectTier('ally'),
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
                      color: const Color(0xFF22C55E).withOpacity(0.3),
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
