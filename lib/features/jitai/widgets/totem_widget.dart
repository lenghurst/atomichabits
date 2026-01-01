import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../domain/services/vulnerability_opportunity_calculator.dart';

/// TotemWidget: Passive V-O State Display
///
/// A visual indicator of the user's current vulnerability-opportunity state.
/// Designed for ambient awareness without demanding attention.
///
/// States:
/// - High Opportunity (Open Door): Glowing, inviting
/// - High Vulnerability (Shield): Protective, alert
/// - Critical (Warning): Pulsing, urgent
/// - Calm (Steady): Subtle, stable
///
/// "Digital Feng Shui" - signals state without buzzing
///
/// Phase 63: JITAI Foundation
class TotemWidget extends StatefulWidget {
  final VOState? voState;
  final bool isCompact;
  final VoidCallback? onTap;

  const TotemWidget({
    super.key,
    this.voState,
    this.isCompact = false,
    this.onTap,
  });

  @override
  State<TotemWidget> createState() => _TotemWidgetState();
}

class _TotemWidgetState extends State<TotemWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _updateAnimationState();
  }

  @override
  void didUpdateWidget(TotemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateAnimationState();
  }

  void _updateAnimationState() {
    final state = widget.voState;
    if (state == null) {
      _pulseController.stop();
      return;
    }

    // Critical state: fast pulsing
    if (state.isCritical) {
      _pulseController.duration = const Duration(milliseconds: 800);
      _pulseController.repeat(reverse: true);
    }
    // High vulnerability: moderate pulsing
    else if (state.vulnerability > 0.7) {
      _pulseController.duration = const Duration(milliseconds: 1500);
      _pulseController.repeat(reverse: true);
    }
    // High opportunity: slow gentle pulsing
    else if (state.opportunity > 0.6) {
      _pulseController.duration = const Duration(milliseconds: 2500);
      _pulseController.repeat(reverse: true);
    }
    // Calm: no pulsing
    else {
      _pulseController.stop();
      _pulseController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCompact) {
      return _buildCompactTotem();
    }
    return _buildFullTotem();
  }

  Widget _buildFullTotem() {
    final state = widget.voState;
    final totemData = _getTotemData(state);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              totemData.primaryColor.withOpacity(0.2),
              Colors.black.withOpacity(0.8),
            ],
            radius: 1.5,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: totemData.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Totem Icon with animations
            AnimatedBuilder(
              animation: Listenable.merge([_pulseAnimation, _rotationController]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow ring (rotates slowly)
                      Transform.rotate(
                        angle: _rotationController.value * 2 * math.pi,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: [
                                totemData.primaryColor.withOpacity(0.0),
                                totemData.primaryColor.withOpacity(0.5),
                                totemData.primaryColor.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Inner circle
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: totemData.primaryColor.withOpacity(0.15),
                          border: Border.all(
                            color: totemData.primaryColor.withOpacity(0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: totemData.primaryColor.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          totemData.icon,
                          size: 36,
                          color: totemData.primaryColor,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // State label
            Text(
              totemData.label,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: totemData.primaryColor,
              ),
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              totemData.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.6),
                height: 1.4,
              ),
            ),

            // V-O bars
            if (state != null) ...[
              const SizedBox(height: 20),
              _buildVOBars(state),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactTotem() {
    final state = widget.voState;
    final totemData = _getTotemData(state);

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: 0.95 + (_pulseAnimation.value * 0.05),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: totemData.primaryColor.withOpacity(0.15),
                border: Border.all(
                  color: totemData.primaryColor.withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: totemData.primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                totemData.icon,
                size: 24,
                color: totemData.primaryColor,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVOBars(VOState state) {
    return Row(
      children: [
        Expanded(
          child: _buildBar(
            label: 'Risk',
            value: state.vulnerability,
            color: _getVulnerabilityColor(state.vulnerability),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildBar(
            label: 'Ready',
            value: state.opportunity,
            color: _getOpportunityColor(state.opportunity),
          ),
        ),
      ],
    );
  }

  Widget _buildBar({
    required String label,
    required double value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            Text(
              '${(value * 100).round()}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  _TotemData _getTotemData(VOState? state) {
    if (state == null) {
      return _TotemData(
        icon: Icons.auto_awesome,
        label: 'Awaiting',
        description: 'Gathering context...',
        primaryColor: Colors.grey,
      );
    }

    // Critical state
    if (state.isCritical) {
      return _TotemData(
        icon: Icons.warning_amber,
        label: 'Critical Moment',
        description: 'High risk but you\'re ready. This is the moment.',
        primaryColor: Colors.red,
      );
    }

    // Shadow trigger (rebel with high predicted failure)
    if (state.isShadowTrigger) {
      return _TotemData(
        icon: Icons.psychology_alt,
        label: 'The Challenge',
        description: 'Algorithm predicts skip. Prove it wrong?',
        primaryColor: Colors.deepOrange,
      );
    }

    // Based on V-O quadrant
    switch (state.quadrant) {
      case VOQuadrant.interveneNow:
        return _TotemData(
          icon: Icons.shield,
          label: 'Need Support',
          description: 'Vulnerability elevated. Support is ready.',
          primaryColor: Colors.purple,
        );

      case VOQuadrant.waitForMoment:
        return _TotemData(
          icon: Icons.hourglass_top,
          label: 'Not Now',
          description: 'Busy or distracted. Better moment coming.',
          primaryColor: Colors.amber,
        );

      case VOQuadrant.lightTouch:
        return _TotemData(
          icon: Icons.door_front_door,
          label: 'Ready',
          description: 'Great moment for action. Low barriers.',
          primaryColor: Colors.green,
        );

      case VOQuadrant.silence:
        return _TotemData(
          icon: Icons.self_improvement,
          label: 'All Good',
          description: 'You\'ve got this. App is quiet.',
          primaryColor: Colors.teal,
        );
    }
  }

  Color _getVulnerabilityColor(double v) {
    if (v > 0.7) return Colors.red;
    if (v > 0.4) return Colors.orange;
    return Colors.green;
  }

  Color _getOpportunityColor(double o) {
    if (o > 0.6) return Colors.green;
    if (o > 0.3) return Colors.blue;
    return Colors.grey;
  }
}

class _TotemData {
  final IconData icon;
  final String label;
  final String description;
  final Color primaryColor;

  _TotemData({
    required this.icon,
    required this.label,
    required this.description,
    required this.primaryColor,
  });
}

/// Mini totem for notification bar or status line
class TotemIndicator extends StatelessWidget {
  final VOState? voState;
  final double size;

  const TotemIndicator({
    super.key,
    this.voState,
    this.size = 12,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getIndicatorColor();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  Color _getIndicatorColor() {
    if (voState == null) return Colors.grey;
    if (voState!.isCritical) return Colors.red;

    switch (voState!.quadrant) {
      case VOQuadrant.interveneNow:
        return Colors.purple;
      case VOQuadrant.waitForMoment:
        return Colors.amber;
      case VOQuadrant.lightTouch:
        return Colors.green;
      case VOQuadrant.silence:
        return Colors.teal;
    }
  }
}
