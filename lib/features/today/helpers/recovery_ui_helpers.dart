import 'package:flutter/material.dart';
import '../../../data/models/consistency_metrics.dart';

/// RecoveryUiHelpers - Pure helper functions for recovery UI styling
/// 
/// Following vibecoding principles - this is where styling logic lives,
/// not in UI components. Components receive ready-to-use styling via props.
class RecoveryUiHelpers {
  RecoveryUiHelpers._(); // Private constructor - use static methods only
  
  /// Get complete styling for a recovery urgency level
  static RecoveryUrgencyStyling getUrgencyStyling(RecoveryUrgency urgency) {
    switch (urgency) {
      case RecoveryUrgency.gentle:
        return RecoveryUrgencyStyling(
          primaryColor: Colors.amber,
          backgroundColor: Colors.amber.shade50,
          borderColor: Colors.amber.shade300,
          iconBackgroundColor: Colors.amber.shade100,
          iconColor: Colors.amber.shade700,
          titleColor: Colors.amber.shade900,
          subtitleColor: Colors.amber.shade700,
          icon: Icons.wb_sunny,
          title: 'Never Miss Twice',
        );
      case RecoveryUrgency.important:
        return RecoveryUrgencyStyling(
          primaryColor: Colors.orange,
          backgroundColor: Colors.orange.shade50,
          borderColor: Colors.orange.shade300,
          iconBackgroundColor: Colors.orange.shade100,
          iconColor: Colors.orange.shade700,
          titleColor: Colors.orange.shade900,
          subtitleColor: Colors.orange.shade700,
          icon: Icons.warning_amber,
          title: 'Day 2 - Critical',
        );
      case RecoveryUrgency.compassionate:
        return RecoveryUrgencyStyling(
          primaryColor: Colors.purple,
          backgroundColor: Colors.purple.shade50,
          borderColor: Colors.purple.shade300,
          iconBackgroundColor: Colors.purple.shade100,
          iconColor: Colors.purple.shade700,
          titleColor: Colors.purple.shade900,
          subtitleColor: Colors.purple.shade700,
          icon: Icons.favorite,
          title: 'Welcome Back',
        );
    }
  }
  
  /// Get notification color for urgency level
  static Color getNotificationColor(RecoveryUrgency urgency) {
    switch (urgency) {
      case RecoveryUrgency.gentle:
        return const Color(0xFFFFC107); // Amber
      case RecoveryUrgency.important:
        return const Color(0xFFFF9800); // Orange
      case RecoveryUrgency.compassionate:
        return const Color(0xFF9C27B0); // Purple
    }
  }
}

/// Data class containing all styling properties for a recovery urgency
class RecoveryUrgencyStyling {
  final Color primaryColor;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconBackgroundColor;
  final Color iconColor;
  final Color titleColor;
  final Color subtitleColor;
  final IconData icon;
  final String title;
  
  const RecoveryUrgencyStyling({
    required this.primaryColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.icon,
    required this.title,
  });
}
