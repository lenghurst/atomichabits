import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// Pre-Permission Glass Pane
/// 
/// Phase 33: Investment Screen
/// 
/// A contextual wrapper that explains WHY a permission is needed BEFORE
/// triggering the OS permission dialog. This dramatically increases
/// permission grant rates by:
/// 
/// 1. Providing context (users understand the value)
/// 2. Reducing surprise (users expect the dialog)
/// 3. Creating commitment (users have already mentally agreed)
/// 
/// Usage:
/// ```dart
/// await PermissionGlassPane.show(
///   context: context,
///   permission: Permission.contacts,
///   title: 'Find Your Witness',
///   description: 'To search your contacts, we need access...',
///   icon: Icons.contacts,
///   onGranted: () => _loadContacts(),
///   onDenied: () => _showManualEntry(),
/// );
/// ```
class PermissionGlassPane extends StatelessWidget {
  final Permission permission;
  final String title;
  final String description;
  final String benefit;
  final IconData icon;
  final VoidCallback onGranted;
  final VoidCallback onDenied;
  final VoidCallback? onSkip;
  
  const PermissionGlassPane({
    super.key,
    required this.permission,
    required this.title,
    required this.description,
    required this.benefit,
    required this.icon,
    required this.onGranted,
    required this.onDenied,
    this.onSkip,
  });
  
  /// Show the permission glass pane as a modal bottom sheet.
  static Future<void> show({
    required BuildContext context,
    required Permission permission,
    required String title,
    required String description,
    required String benefit,
    required IconData icon,
    required VoidCallback onGranted,
    required VoidCallback onDenied,
    VoidCallback? onSkip,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => PermissionGlassPane(
        permission: permission,
        title: title,
        description: description,
        benefit: benefit,
        icon: icon,
        onGranted: onGranted,
        onDenied: onDenied,
        onSkip: onSkip,
      ),
    );
  }
  
  Future<void> _handleAllow(BuildContext context) async {
    // Haptic feedback for commitment
    HapticFeedback.mediumImpact();
    
    // Request the actual OS permission
    final status = await permission.request();
    
    // Close the glass pane
    if (context.mounted) {
      Navigator.of(context).pop();
    }
    
    // Handle the result
    if (status.isGranted) {
      onGranted();
    } else if (status.isPermanentlyDenied) {
      // User has permanently denied - offer to open settings
      _showSettingsDialog(context);
    } else {
      onDenied();
    }
  }
  
  void _handleSkip(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
    if (onSkip != null) {
      onSkip!();
    } else {
      onDenied();
    }
  }
  
  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(
          'You have previously denied this permission. '
          'To enable it, please open Settings and grant access to $title.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDenied();
            },
            child: const Text('Not Now'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              
              // Icon with gradient background
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.tertiary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              
              // Title
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Description
              Text(
                description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Benefit highlight
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        benefit,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Allow button (primary action)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _handleAllow(context),
                  icon: const Icon(Icons.check),
                  label: const Text('Allow Access'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Skip button (secondary action)
              if (onSkip != null)
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => _handleSkip(context),
                    child: const Text('Skip for now'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pre-built permission configurations for common use cases.
class PermissionConfigs {
  /// Configuration for contacts permission (witness selection).
  static const contacts = (
    permission: Permission.contacts,
    title: 'Find Your Witness',
    description: 'Search your contacts to find someone who will hold you accountable. '
        'They\'ll receive updates on your progress.',
    benefit: 'People with a witness are 3x more likely to achieve their goals.',
    icon: Icons.contacts,
  );
  
  /// Configuration for notifications permission.
  static const notifications = (
    permission: Permission.notification,
    title: 'Stay on Track',
    description: 'Receive gentle reminders to complete your habits and updates '
        'from your witness.',
    benefit: 'Users with notifications enabled complete 40% more habits.',
    icon: Icons.notifications_active,
  );
  
  /// Configuration for microphone permission (voice coach).
  static const microphone = (
    permission: Permission.microphone,
    title: 'Talk to Your Coach',
    description: 'Use your voice to speak with your AI coach. '
        'It\'s faster and more natural than typing.',
    benefit: 'Voice conversations feel more personal and build stronger habits.',
    icon: Icons.mic,
  );
}
