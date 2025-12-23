import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Value Proposition Screen (Hook Screen)
/// 
/// Phase 29 - Second Council of Five Implementation
/// 
/// Recommendations Addressed:
/// - K1 (Kahneman): Add "hook" screen before identity to engage System 1
/// - H1 (Hormozi): Lead with dream outcome (social proof stat)
/// - O5 (Ogilvy): Add tagline to onboarding
/// 
/// This screen shows the value proposition BEFORE asking for any commitment.
/// It engages System 1 (fast, intuitive) thinking before the identity screen
/// requires System 2 (slow, deliberate) thinking.
class ValuePropositionScreen extends StatefulWidget {
  const ValuePropositionScreen({super.key});

  @override
  State<ValuePropositionScreen> createState() => _ValuePropositionScreenState();
}

class _ValuePropositionScreenState extends State<ValuePropositionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  int _currentTestimonialIndex = 0;
  
  // Testimonials for the carousel (Phase 30: Replace with real testimonials)
  final List<_Testimonial> _testimonials = [
    _Testimonial(
      quote: "I finally finished my novel after 3 years of procrastinating. Having my best friend as a witness changed everything.",
      author: "Sarah K.",
      identity: "A Published Author",
    ),
    _Testimonial(
      quote: "Lost 15kg in 6 months. When you know someone's watching, you show up differently.",
      author: "Marcus T.",
      identity: "A Marathon Runner",
    ),
    _Testimonial(
      quote: "Shipped my side project in 90 days. The daily check-ins with my witness kept me accountable.",
      author: "Dev J.",
      identity: "A Shipped Founder",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _animationController.forward();
    
    // Auto-rotate testimonials
    _startTestimonialRotation();
  }
  
  void _startTestimonialRotation() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _currentTestimonialIndex = 
              (_currentTestimonialIndex + 1) % _testimonials.length;
        });
        _startTestimonialRotation();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // slate-900
      body: Stack(
        children: [
          // Background gradient accents
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF3B82F6).withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFEC4899).withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      
                      // Progress indicator (Step 0 of 3)
                      _buildProgressIndicator(0, 3),
                      
                      const SizedBox(height: 48),
                      
                      // Hero stat (Hormozi H1)
                      _buildHeroStat(),
                      
                      const SizedBox(height: 32),
                      
                      // Tagline (Ogilvy O5)
                      _buildTagline(),
                      
                      const SizedBox(height: 48),
                      
                      // Testimonial carousel
                      Expanded(
                        child: _buildTestimonialCarousel(),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // CTAs
                      _buildCTAs(),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgressIndicator(int current, int total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total + 1, (index) {
        final isActive = index <= current;
        final isCurrent = index == current;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isCurrent ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive
                ? const Color(0xFF22C55E)
                : const Color(0xFF334155),
          ),
        );
      }),
    );
  }
  
  Widget _buildHeroStat() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The big stat
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "3×",
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w900,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFFEC4899)],
                    ).createShader(const Rect.fromLTWH(0, 0, 150, 80)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "more likely to succeed",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "when you have a witness",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.7),
            height: 1.2,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTagline() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: const Color(0xFF22C55E).withOpacity(0.5),
            width: 3,
          ),
        ),
      ),
      child: Text(
        "Don't rely on willpower.\nRely on your friends.",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.white.withOpacity(0.9),
          fontStyle: FontStyle.italic,
          height: 1.4,
        ),
      ),
    );
  }
  
  Widget _buildTestimonialCarousel() {
    final testimonial = _testimonials[_currentTestimonialIndex];
    
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Container(
        key: ValueKey(_currentTestimonialIndex),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF334155),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Quote icon
            Icon(
              Icons.format_quote,
              color: const Color(0xFF22C55E).withOpacity(0.5),
              size: 32,
            ),
            const SizedBox(height: 16),
            
            // Quote text
            Text(
              testimonial.quote,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            
            // Author
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFFEC4899)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      testimonial.author[0],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      testimonial.author,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      testimonial.identity,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const Spacer(),
            
            // Carousel dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_testimonials.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentTestimonialIndex
                        ? const Color(0xFF22C55E)
                        : const Color(0xFF334155),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCTAs() {
    return Column(
      children: [
        // Primary CTA
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => context.go('/onboarding/identity'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22C55E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Get Started",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Secondary CTA
        SizedBox(
          width: double.infinity,
          height: 48,
          child: TextButton(
            onPressed: () {
              // TODO: Show a dialog to enter invite code
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Enter your invite link in the browser'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white.withOpacity(0.7),
            ),
            child: const Text(
              "I have an invite",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Testimonial {
  final String quote;
  final String author;
  final String identity;
  
  _Testimonial({
    required this.quote,
    required this.author,
    required this.identity,
  });
}
