import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/app_state.dart';
import '../data/services/sound_service.dart';

/// Animated Nudge Button - Phase 18: The Vibe Update
/// 
/// A button with recoil animation and "rocket launch" effect
/// for sending nudges to accountability partners.
/// 
/// "Juice it or lose it" - The button should feel ALIVE.
/// - Recoil animation on press
/// - Rocket/wave icon animation
/// - Haptic + Sound feedback
/// - Satisfying bounce back
class AnimatedNudgeButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String? label;
  final bool isCompact;
  final Color? color;
  final NudgeButtonStyle style;

  const AnimatedNudgeButton({
    super.key,
    required this.onPressed,
    this.label,
    this.isCompact = false,
    this.color,
    this.style = NudgeButtonStyle.rocket,
  });

  @override
  State<AnimatedNudgeButton> createState() => _AnimatedNudgeButtonState();
}

class _AnimatedNudgeButtonState extends State<AnimatedNudgeButton>
    with TickerProviderStateMixin {
  // Recoil animation controller
  late AnimationController _recoilController;
  late Animation<double> _recoilAnimation;
  
  // Icon launch animation controller
  late AnimationController _launchController;
  late Animation<double> _launchAnimation;
  late Animation<double> _launchOpacity;
  
  // Pulse animation for idle state
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  // Ripple animation
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;
  
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    // Recoil animation (button moves back then springs forward)
    _recoilController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _recoilAnimation = TweenSequence<double>([
      // Pull back
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -8.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      // Spring forward
      TweenSequenceItem(
        tween: Tween<double>(begin: -8.0, end: 2.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      // Settle
      TweenSequenceItem(
        tween: Tween<double>(begin: 2.0, end: 0.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
    ]).animate(_recoilController);
    
    // Launch animation (icon flies off)
    _launchController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _launchAnimation = Tween<double>(begin: 0.0, end: -50.0).animate(
      CurvedAnimation(
        parent: _launchController,
        curve: Curves.easeOut,
      ),
    );
    _launchOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _launchController,
        curve: const Interval(0.5, 1.0),
      ),
    );
    
    // Subtle pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Ripple animation
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rippleController,
        curve: Curves.easeOut,
      ),
    );
    
    // Start idle pulse animation
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _recoilController.dispose();
    _launchController.dispose();
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _handlePress() async {
    setState(() => _isPressed = true);
    
    // Stop pulse animation
    _pulseController.stop();
    _pulseController.value = 0.0;
    
    // Trigger haptic feedback
    HapticFeedback.mediumImpact();
    
    // Trigger sound
    try {
      final soundService = context.read<SoundService>();
      final appState = context.read<AppState>();
      await FeedbackPatterns.nudge(
        soundService,
        hapticsEnabled: appState.hapticsEnabled,
      );
    } catch (e) {
      // SoundService might not be available
    }
    
    // Start animations
    _recoilController.forward(from: 0.0);
    _launchController.forward(from: 0.0);
    _rippleController.forward(from: 0.0);
    
    // Trigger callback
    widget.onPressed();
    
    // Wait for animations to complete
    await Future.delayed(const Duration(milliseconds: 600));
    
    setState(() => _isPressed = false);
    
    // Reset launch controller and restart pulse
    _launchController.reset();
    _rippleController.reset();
    _pulseController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.color ?? Theme.of(context).colorScheme.primary;
    
    if (widget.isCompact) {
      return _buildCompactButton(buttonColor);
    }
    
    return _buildFullButton(buttonColor);
  }

  Widget _buildCompactButton(Color buttonColor) {
    return AnimatedBuilder(
      animation: Listenable.merge([_recoilAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_recoilAnimation.value, 0),
          child: Transform.scale(
            scale: _isPressed ? 0.95 : _pulseAnimation.value,
            child: GestureDetector(
              onTap: _handlePress,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: buttonColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: buttonColor.withValues(alpha: 0.3)),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Ripple effect
                    AnimatedBuilder(
                      animation: _rippleAnimation,
                      builder: (context, child) {
                        if (_rippleAnimation.value == 0) return const SizedBox.shrink();
                        return Positioned.fill(
                          child: Transform.scale(
                            scale: 1 + _rippleAnimation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: buttonColor.withValues(alpha: 1 - _rippleAnimation.value),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // Icon
                    AnimatedBuilder(
                      animation: _launchAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _launchAnimation.value),
                          child: Opacity(
                            opacity: _launchOpacity.value,
                            child: Icon(
                              _getIconData(),
                              color: buttonColor,
                              size: 20,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFullButton(Color buttonColor) {
    return AnimatedBuilder(
      animation: Listenable.merge([_recoilAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_recoilAnimation.value, 0),
          child: Transform.scale(
            scale: _isPressed ? 0.95 : _pulseAnimation.value,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _handlePress,
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Main button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: buttonColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: buttonColor.withValues(alpha: 0.3),
                            blurRadius: _isPressed ? 4 : 8,
                            offset: Offset(0, _isPressed ? 2 : 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Animated icon
                          _buildAnimatedIcon(Colors.white),
                          if (widget.label != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              widget.label!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Ripple overlay
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _rippleAnimation,
                        builder: (context, child) {
                          if (_rippleAnimation.value == 0) return const SizedBox.shrink();
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 1 - _rippleAnimation.value),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedIcon(Color color) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Stack(
        children: [
          // Main icon
          AnimatedBuilder(
            animation: _launchAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _launchAnimation.value),
                child: Transform.rotate(
                  angle: _launchAnimation.value * -0.05, // Slight rotation during launch
                  child: Opacity(
                    opacity: _launchOpacity.value,
                    child: Icon(
                      _getIconData(),
                      color: color,
                      size: 24,
                    ),
                  ),
                ),
              );
            },
          ),
          // Replacement icon that fades in
          AnimatedBuilder(
            animation: _launchController,
            builder: (context, child) {
              final showReplacement = _launchController.value > 0.5;
              return AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: showReplacement ? 1.0 : 0.0,
                child: Icon(
                  Icons.check,
                  color: color,
                  size: 24,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _getIconData() {
    switch (widget.style) {
      case NudgeButtonStyle.rocket:
        return Icons.rocket_launch;
      case NudgeButtonStyle.wave:
        return Icons.waving_hand;
      case NudgeButtonStyle.bell:
        return Icons.notifications_active;
      case NudgeButtonStyle.poke:
        return Icons.touch_app;
    }
  }
}

/// Style options for the nudge button icon
enum NudgeButtonStyle {
  rocket,
  wave,
  bell,
  poke,
}

/// Inline animated nudge for contract cards
class InlineNudgeButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Color? color;

  const InlineNudgeButton({
    super.key,
    required this.onPressed,
    this.color,
  });

  @override
  State<InlineNudgeButton> createState() => _InlineNudgeButtonState();
}

class _InlineNudgeButtonState extends State<InlineNudgeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // Shake animation (left-right wiggle)
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: -5), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: -5, end: 5), weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: 5, end: -5), weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: -5, end: 3), weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: 3, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    HapticFeedback.lightImpact();
    
    // Play shake animation
    _shakeController.forward(from: 0.0);
    
    // Wait a moment then trigger callback
    await Future.delayed(const Duration(milliseconds: 100));
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.color ?? Colors.orange;
    
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: TextButton.icon(
            onPressed: _handleTap,
            icon: const Icon(Icons.notifications_active, size: 16),
            label: const Text('Nudge'),
            style: TextButton.styleFrom(
              foregroundColor: buttonColor,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
          ),
        );
      },
    );
  }
}

/// Floating nudge button with particle effect
class FloatingNudgeButton extends StatefulWidget {
  final VoidCallback onPressed;

  const FloatingNudgeButton({
    super.key,
    required this.onPressed,
  });

  @override
  State<FloatingNudgeButton> createState() => _FloatingNudgeButtonState();
}

class _FloatingNudgeButtonState extends State<FloatingNudgeButton>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  void _handlePress() {
    HapticFeedback.heavyImpact();
    
    // Generate particles
    final random = math.Random();
    _particles.clear();
    for (int i = 0; i < 8; i++) {
      _particles.add(_Particle(
        angle: (i * math.pi / 4) + random.nextDouble() * 0.5,
        distance: 30 + random.nextDouble() * 20,
        color: Colors.orange.withValues(alpha: 0.8),
      ));
    }
    
    _particleController.forward(from: 0.0);
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Particles
          ..._particles.map((particle) => AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              final progress = _particleController.value;
              final x = math.cos(particle.angle) * particle.distance * progress;
              final y = math.sin(particle.angle) * particle.distance * progress;
              
              return Transform.translate(
                offset: Offset(x, y),
                child: Opacity(
                  opacity: 1 - progress,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: particle.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          )),
          
          // Main button
          AnimatedNudgeButton(
            onPressed: _handlePress,
            style: NudgeButtonStyle.rocket,
            label: 'Nudge',
          ),
        ],
      ),
    );
  }
}

class _Particle {
  final double angle;
  final double distance;
  final Color color;

  _Particle({
    required this.angle,
    required this.distance,
    required this.color,
  });
}
