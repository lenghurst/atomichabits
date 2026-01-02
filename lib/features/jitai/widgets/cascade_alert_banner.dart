/// CascadeAlertBanner - Urgent Cascade Warning Display
///
/// Shows prominent warnings when cascade risk is high.
/// Designed to be displayed at the top of the habit detail screen.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/jitai_provider.dart';
import '../../../domain/services/cascade_pattern_detector.dart';

class CascadeAlertBanner extends StatelessWidget {
  final VoidCallback? onActionTap;
  final bool dismissible;

  const CascadeAlertBanner({
    super.key,
    this.onActionTap,
    this.dismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    final jitai = context.watch<JITAIProvider>();

    if (!jitai.isInitialized || !jitai.isEnabled) {
      return const SizedBox.shrink();
    }

    // Get the most severe alert
    final alerts = jitai.cascadeAlerts;
    if (alerts.isEmpty) return const SizedBox.shrink();

    final primaryAlert = alerts.reduce((a, b) =>
        a.severity > b.severity ? a : b);

    if (primaryAlert.severity < 0.4) return const SizedBox.shrink();

    return _CascadeAlertCard(
      alert: primaryAlert,
      onActionTap: onActionTap,
      dismissible: dismissible,
    );
  }
}

class _CascadeAlertCard extends StatefulWidget {
  final CascadeAlert alert;
  final VoidCallback? onActionTap;
  final bool dismissible;

  const _CascadeAlertCard({
    required this.alert,
    this.onActionTap,
    this.dismissible = true,
  });

  @override
  State<_CascadeAlertCard> createState() => _CascadeAlertCardState();
}

class _CascadeAlertCardState extends State<_CascadeAlertCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) return const SizedBox.shrink();

    final severity = widget.alert.severity;
    final (bgColor, borderColor, iconColor) = _colorsForSeverity(severity);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: severity >= 0.7 ? _pulseAnimation.value : 1.0,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  bgColor,
                  bgColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _iconForPattern(widget.alert.pattern),
                          size: 24,
                          color: iconColor,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.alert.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: iconColor,
                                    ),
                                  ),
                                ),
                                if (widget.dismissible)
                                  IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      size: 20,
                                      color: iconColor.withOpacity(0.7),
                                    ),
                                    onPressed: () {
                                      setState(() => _isDismissed = true);
                                    },
                                    visualDensity: VisualDensity.compact,
                                  ),
                              ],
                            ),
                            Text(
                              widget.alert.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: iconColor.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Action section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(14),
                    ),
                  ),
                  child: InkWell(
                    onTap: widget.onActionTap,
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 18,
                          color: iconColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.alert.suggestedAction,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: iconColor,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward,
                          size: 18,
                          color: iconColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  (Color, Color, Color) _colorsForSeverity(double severity) {
    if (severity >= 0.7) {
      return (
        Colors.red.shade50,
        Colors.red.shade400,
        Colors.red.shade800,
      );
    }
    if (severity >= 0.5) {
      return (
        Colors.orange.shade50,
        Colors.orange.shade400,
        Colors.orange.shade800,
      );
    }
    return (
      Colors.amber.shade50,
      Colors.amber.shade400,
      Colors.amber.shade800,
    );
  }

  IconData _iconForPattern(CascadePattern pattern) {
    switch (pattern) {
      case CascadePattern.weatherBlocking:
        return Icons.cloud_off;
      case CascadePattern.travelDisruption:
        return Icons.flight;
      case CascadePattern.weekendPattern:
        return Icons.weekend;
      case CascadePattern.energyGap:
        return Icons.battery_alert;
      case CascadePattern.yesterdayMiss:
        return Icons.warning_amber;
      case CascadePattern.multiDayMiss:
        return Icons.trending_down;
    }
  }
}

/// Compact cascade risk indicator for list items
class CascadeRiskIndicator extends StatelessWidget {
  final double risk;
  final bool showLabel;

  const CascadeRiskIndicator({
    super.key,
    required this.risk,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    if (risk < 0.3) return const SizedBox.shrink();

    final color = _colorForRisk(risk);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showLabel ? 8 : 4,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 14,
            color: color,
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              _labelForRisk(risk),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _colorForRisk(double risk) {
    if (risk >= 0.7) return Colors.red;
    if (risk >= 0.5) return Colors.orange;
    return Colors.amber;
  }

  String _labelForRisk(double risk) {
    if (risk >= 0.7) return 'High Risk';
    if (risk >= 0.5) return 'At Risk';
    return 'Watch';
  }
}
