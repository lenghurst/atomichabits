import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../../../domain/entities/psychometric_profile.dart';
import '../../../domain/entities/psychometric_profile_extensions.dart';

/// The Pact Identity Card - A premium digital artifact
/// 
/// Phase 43: The Variable Reward
/// 
/// This widget creates a flip card that reveals the user's psychological
/// profile captured during the Sherlock Protocol onboarding.
/// 
/// Design Philosophy:
/// - Front: Mystery and anticipation ("THE PACT - TAP TO REVEAL")
/// - Back: The full insight ("I AM BECOMING... I AM BURYING...")
/// 
/// The card uses a 3D Matrix transformation for a realistic flip animation
/// that respects the physical laws of card manipulation.
class PactIdentityCard extends StatefulWidget {
  final PsychometricProfile profile;
  final bool autoFlip;
  final Duration autoFlipDelay;
  
  const PactIdentityCard({
    super.key, 
    required this.profile,
    this.autoFlip = false,
    this.autoFlipDelay = const Duration(seconds: 2),
  });

  @override
  State<PactIdentityCard> createState() => _PactIdentityCardState();
}

class _PactIdentityCardState extends State<PactIdentityCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    if (widget.autoFlip) {
      Future.delayed(widget.autoFlipDelay, () {
        if (mounted) _flipCard();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    HapticFeedback.selectionClick();
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * pi;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Perspective
            ..rotateY(angle);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: _controller.value < 0.5
                ? _buildFront()
                : Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: _buildBack(),
                  ),
          );
        },
      ),
    );
  }

  // === FRONT SIDE (THE MYSTERY) ===
  Widget _buildFront() {
    final color = widget.profile.archetypeColor;
    
    return Container(
      width: 320,
      height: 480,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12, width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: -5,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // The Fingerprint Icon (Wax Seal aesthetic)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3), width: 2),
            ),
            child: Icon(Icons.fingerprint, size: 60, color: color),
          ),
          const SizedBox(height: 30),
          
          // The Title
          const Text(
            "THE PACT",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 8,
            ),
          ),
          const SizedBox(height: 8),
          
          // Subtitle
          Text(
            "IDENTITY PROTOCOL",
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 30),
          
          // CTA Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.touch_app, color: Colors.white.withOpacity(0.7), size: 14),
                const SizedBox(width: 8),
                Text(
                  "TAP TO REVEAL",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // === BACK SIDE (THE INSIGHT) ===
  Widget _buildBack() {
    final color = widget.profile.archetypeColor;
    
    return Container(
      width: 320,
      height: 480,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A1A), Color(0xFF000000)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Shield Icon
          Row(
            children: [
              Icon(Icons.shield_outlined, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                "IDENTITY PROTOCOL",
                style: TextStyle(
                  color: color, 
                  fontWeight: FontWeight.bold, 
                  letterSpacing: 1.5, 
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              // Archetype Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.profile.archetypeBadge,
                  style: TextStyle(
                    color: color,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 30),
          
          // Section 1: Identity (I AM BECOMING)
          Text(
            "I AM BECOMING",
            style: TextStyle(
              color: Colors.grey.shade500, 
              fontSize: 10, 
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.profile.identityStatement,
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 22, 
              fontWeight: FontWeight.bold, 
              height: 1.2,
            ),
          ),
          
          const SizedBox(height: 28),
          
          // Section 2: Anti-Identity (I AM BURYING)
          Text(
            "I AM BURYING",
            style: TextStyle(
              color: Colors.grey.shade500, 
              fontSize: 10, 
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.profile.antiIdentityDisplay,
            style: const TextStyle(
              color: Color(0xFFFF5252), 
              fontSize: 20, 
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.lineThrough,
              decorationColor: Color(0xFFFF5252),
              decorationThickness: 2,
            ),
          ),
          
          // Context (if available)
          if (widget.profile.antiIdentityContext != null) ...[
            const SizedBox(height: 4),
            Text(
              '"${widget.profile.antiIdentityContext}"',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const Spacer(),
          
          // Section 3: The Operating Rule
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.gavel, color: color, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      "OPERATING RULE #1",
                      style: TextStyle(
                        color: color, 
                        fontSize: 10, 
                        fontWeight: FontWeight.w900, 
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.profile.ruleStatement,
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 14, 
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.profile.archetypeDescription,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5), 
                    fontSize: 10, 
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Footer: Tap to flip hint
          Center(
            child: Text(
              "TAP TO FLIP",
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 8,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
