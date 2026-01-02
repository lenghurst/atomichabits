import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/services/jitai/context_snapshot_aggregator.dart';

/// ThermostatWidget: Manual V-O Override Control
///
/// Allows users to explicitly set their vulnerability state:
/// - Shield Mode (high support needed)
/// - Beast Mode (minimal support needed)
///
/// This provides the strongest signal for JITAI - user explicitly stating their state.
///
/// Phase 63: JITAI Foundation
class ThermostatWidget extends StatefulWidget {
  final double? currentValue;
  final Duration expiresIn;
  final VoidCallback? onChanged;

  const ThermostatWidget({
    super.key,
    this.currentValue,
    this.expiresIn = const Duration(hours: 4),
    this.onChanged,
  });

  @override
  State<ThermostatWidget> createState() => _ThermostatWidgetState();
}

class _ThermostatWidgetState extends State<ThermostatWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  double _sliderValue = 0.5;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.currentValue ?? 0.5;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getGradientStart().withOpacity(0.3),
            Colors.black.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _getAccentColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'How are you feeling?',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              _buildModeIndicator(),
            ],
          ),

          const SizedBox(height: 24),

          // Mode Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildModeIcon(
                icon: Icons.shield,
                label: 'Shield',
                isActive: _sliderValue > 0.6,
                color: Colors.purple,
              ),
              _buildModeIcon(
                icon: Icons.flash_on,
                label: 'Beast',
                isActive: _sliderValue < 0.4,
                color: Colors.orange,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
              activeTrackColor: _getAccentColor(),
              inactiveTrackColor: Colors.white.withOpacity(0.2),
              thumbColor: Colors.white,
              overlayColor: _getAccentColor().withOpacity(0.2),
            ),
            child: Slider(
              value: _sliderValue,
              onChanged: (value) {
                setState(() {
                  _sliderValue = value;
                  _isDragging = true;
                });
                HapticFeedback.selectionClick();
              },
              onChangeEnd: (value) {
                setState(() => _isDragging = false);
                _applyOverride(value);
              },
            ),
          ),

          const SizedBox(height: 8),

          // Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'More support',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              Text(
                'Less support',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Description
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _getModeDescription(),
              key: ValueKey(_sliderValue > 0.6
                  ? 'shield'
                  : _sliderValue < 0.4
                      ? 'beast'
                      : 'neutral'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.7),
                height: 1.4,
              ),
            ),
          ),

          // Active indicator
          if (widget.currentValue != null) ...[
            const SizedBox(height: 16),
            _buildActiveIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildModeIndicator() {
    final mode = _sliderValue > 0.6
        ? 'Shield Mode'
        : _sliderValue < 0.4
            ? 'Beast Mode'
            : 'Balanced';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getAccentColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getAccentColor().withOpacity(0.4),
        ),
      ),
      child: Text(
        mode,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _getAccentColor(),
        ),
      ),
    );
  }

  Widget _buildModeIcon({
    required IconData icon,
    required String label,
    required bool isActive,
    required Color color,
  }) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = isActive ? 1.0 + (_pulseController.value * 0.1) : 1.0;
        return Transform.scale(
          scale: scale,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? color.withOpacity(0.2) : Colors.transparent,
                  border: Border.all(
                    color: isActive ? color : Colors.white.withOpacity(0.2),
                    width: isActive ? 2 : 1,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isActive ? color : Colors.white.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? color : Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 14,
            color: Colors.white.withOpacity(0.6),
          ),
          const SizedBox(width: 6),
          Text(
            'Active for ${widget.expiresIn.inHours}h',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _clearOverride,
            child: Text(
              'Clear',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.redAccent.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAccentColor() {
    if (_sliderValue > 0.6) return Colors.purple;
    if (_sliderValue < 0.4) return Colors.orange;
    return Colors.blue;
  }

  Color _getGradientStart() {
    if (_sliderValue > 0.6) return Colors.purple.shade900;
    if (_sliderValue < 0.4) return Colors.orange.shade900;
    return Colors.blue.shade900;
  }

  String _getModeDescription() {
    if (_sliderValue > 0.6) {
      return 'Shield Mode: Extra support and gentler nudges. Perfect for tough days.';
    }
    if (_sliderValue < 0.4) {
      return 'Beast Mode: Minimal intervention. The app will stay quiet and let you handle it.';
    }
    return 'Balanced: Smart interventions based on context. The algorithm decides.';
  }

  void _applyOverride(double value) {
    // High slider = more support needed = higher vulnerability
    // Inverted because "Beast Mode" (low support) should be low vulnerability
    final vulnerabilityValue = value;

    ContextSnapshotAggregator().setVulnerabilityOverride(
      vulnerabilityValue,
      expiresIn: widget.expiresIn,
    );

    widget.onChanged?.call();

    HapticFeedback.mediumImpact();
  }

  void _clearOverride() {
    ContextSnapshotAggregator().clearVulnerabilityOverride();
    setState(() => _sliderValue = 0.5);
    widget.onChanged?.call();
    HapticFeedback.lightImpact();
  }
}

/// Compact version for home screen or quick access
class ThermostatQuickToggle extends StatelessWidget {
  final double? currentValue;
  final VoidCallback? onTap;

  const ThermostatQuickToggle({
    super.key,
    this.currentValue,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isShieldMode = currentValue != null && currentValue! > 0.6;
    final isBeastMode = currentValue != null && currentValue! < 0.4;

    final icon = isShieldMode
        ? Icons.shield
        : isBeastMode
            ? Icons.flash_on
            : Icons.tune;

    final color = isShieldMode
        ? Colors.purple
        : isBeastMode
            ? Colors.orange
            : Colors.blue;

    final label = isShieldMode
        ? 'Shield'
        : isBeastMode
            ? 'Beast'
            : 'Auto';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
