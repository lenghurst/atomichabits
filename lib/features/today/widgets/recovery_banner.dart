import 'package:flutter/material.dart';
import '../../../data/models/consistency_metrics.dart';
import '../helpers/recovery_ui_helpers.dart';

/// RecoveryBanner - Inline banner showing recovery is needed
/// 
/// Purely presentational - styling logic extracted to helpers.
class RecoveryBanner extends StatelessWidget {
  final RecoveryUrgency urgency;
  final VoidCallback onTap;
  
  const RecoveryBanner({
    super.key,
    required this.urgency,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final styling = RecoveryUiHelpers.getUrgencyStyling(urgency);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: styling.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: styling.borderColor, width: 2),
        ),
        child: Row(
          children: [
            _IconCircle(
              backgroundColor: styling.iconBackgroundColor,
              icon: styling.icon,
              iconColor: styling.iconColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _BannerContent(
                title: styling.title,
                titleColor: styling.titleColor,
                subtitleColor: styling.subtitleColor,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: styling.iconColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;
  
  const _IconCircle({
    required this.backgroundColor,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 24,
      ),
    );
  }
}

class _BannerContent extends StatelessWidget {
  final String title;
  final Color titleColor;
  final Color subtitleColor;
  
  const _BannerContent({
    required this.title,
    required this.titleColor,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Tap to see your comeback plan',
          style: TextStyle(
            fontSize: 13,
            color: subtitleColor,
          ),
        ),
      ],
    );
  }
}
