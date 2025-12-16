import 'package:flutter/material.dart';
import '../data/services/feedback_service.dart';

/// Alpha Shield Banner
/// 
/// Phase 20: "Destroyer Defense" - Expectation Management
/// 
/// "Put a giant banner on the splash screen: 'ALPHA BUILD: GRACEFUL
/// CONSISTENCY ENGINE ACTIVE. UI IS TEMPORARY.' This manages expectations.
/// They will forgive ugly UI. They will not forgive data loss."
/// 
/// This widget displays a prominent banner indicating the build status
/// and sets appropriate expectations for early adopters.
class AlphaShieldBanner extends StatelessWidget {
  /// Whether to show expanded version with icon
  final bool expanded;
  
  /// Custom message override
  final String? message;
  
  /// Callback when banner is tapped
  final VoidCallback? onTap;
  
  const AlphaShieldBanner({
    super.key,
    this.expanded = false,
    this.message,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    // Don't show in production
    if (!AlphaShieldConfig.showBanner || 
        AlphaShieldConfig.status == BuildStatus.production) {
      return const SizedBox.shrink();
    }
    
    final bannerColor = Color(AlphaShieldConfig.bannerColorValue);
    final textColor = _getContrastingTextColor(bannerColor);
    final displayMessage = message ?? AlphaShieldConfig.bannerMessage;
    
    if (expanded) {
      return _buildExpandedBanner(context, bannerColor, textColor, displayMessage);
    }
    
    return _buildCompactBanner(context, bannerColor, textColor, displayMessage);
  }
  
  Widget _buildCompactBanner(
    BuildContext context,
    Color bannerColor,
    Color textColor,
    String displayMessage,
  ) {
    return GestureDetector(
      onTap: onTap ?? () => _showDisclaimerDialog(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bannerColor,
          boxShadow: [
            BoxShadow(
              color: bannerColor.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getStatusIcon(),
              size: 14,
              color: textColor,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                displayMessage,
                style: TextStyle(
                  color: textColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.info_outline,
              size: 14,
              color: textColor.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildExpandedBanner(
    BuildContext context,
    Color bannerColor,
    Color textColor,
    String displayMessage,
  ) {
    return GestureDetector(
      onTap: onTap ?? () => _showDisclaimerDialog(context),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bannerColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: bannerColor,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getStatusIcon(),
                  size: 24,
                  color: bannerColor,
                ),
                const SizedBox(width: 12),
                Text(
                  _getStatusTitle(),
                  style: TextStyle(
                    color: bannerColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              displayMessage,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Tap for more info',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getStatusIcon() {
    switch (AlphaShieldConfig.status) {
      case BuildStatus.alpha:
        return Icons.science;
      case BuildStatus.beta:
        return Icons.bug_report;
      case BuildStatus.releaseCandidate:
        return Icons.verified;
      case BuildStatus.production:
        return Icons.check_circle;
    }
  }
  
  String _getStatusTitle() {
    switch (AlphaShieldConfig.status) {
      case BuildStatus.alpha:
        return 'ALPHA BUILD';
      case BuildStatus.beta:
        return 'BETA BUILD';
      case BuildStatus.releaseCandidate:
        return 'RELEASE CANDIDATE';
      case BuildStatus.production:
        return 'RELEASED';
    }
  }
  
  Color _getContrastingTextColor(Color background) {
    // Calculate luminance to determine best text color
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
  
  void _showDisclaimerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getStatusIcon(),
              color: Color(AlphaShieldConfig.bannerColorValue),
            ),
            const SizedBox(width: 12),
            Text(_getStatusTitle()),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            AlphaShieldConfig.disclaimer,
            style: const TextStyle(height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              FeedbackService.sendBugReport();
            },
            icon: const Icon(Icons.bug_report, size: 18),
            label: const Text('Report Bug'),
          ),
        ],
      ),
    );
  }
}

/// Splash screen overlay for alpha builds
/// 
/// Shows a brief "Alpha Build" indicator during splash screen
class AlphaShieldSplashOverlay extends StatelessWidget {
  const AlphaShieldSplashOverlay({super.key});
  
  @override
  Widget build(BuildContext context) {
    if (!AlphaShieldConfig.showBanner || 
        AlphaShieldConfig.status == BuildStatus.production) {
      return const SizedBox.shrink();
    }
    
    return Positioned(
      bottom: 48,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Color(AlphaShieldConfig.bannerColorValue).withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.science,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  AlphaShieldConfig.status.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AlphaShieldConfig.shortDisclaimer,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Floating action button for quick bug report
/// 
/// Shows a prominent "Report Bug" FAB during alpha/beta
class AlphaShieldFAB extends StatelessWidget {
  const AlphaShieldFAB({super.key});
  
  @override
  Widget build(BuildContext context) {
    if (!AlphaShieldConfig.showBanner || 
        AlphaShieldConfig.status == BuildStatus.production) {
      return const SizedBox.shrink();
    }
    
    return FloatingActionButton.extended(
      onPressed: () => _showFeedbackOptions(context),
      backgroundColor: Color(AlphaShieldConfig.bannerColorValue),
      icon: const Icon(Icons.bug_report),
      label: const Text('Feedback'),
    );
  }
  
  void _showFeedbackOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Help Us Improve',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your feedback makes the app better. You\'ll be credited in CREDITS.md!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.bug_report, color: Colors.orange),
                title: const Text('Report a Bug'),
                subtitle: const Text('Something broke? Tell us!'),
                onTap: () {
                  Navigator.pop(context);
                  FeedbackService.sendBugReport();
                },
              ),
              ListTile(
                leading: const Icon(Icons.local_fire_department, color: Colors.red),
                title: const Text('Roast the Developer'),
                subtitle: const Text('Tell us why this sucks'),
                onTap: () {
                  Navigator.pop(context);
                  FeedbackService.sendRoast();
                },
              ),
              if (FeedbackService.githubIssues != null)
                ListTile(
                  leading: const Icon(Icons.code, color: Colors.purple),
                  title: const Text('GitHub Issues'),
                  subtitle: const Text('For technical bugs'),
                  onTap: () {
                    Navigator.pop(context);
                    FeedbackService.openGitHubIssues();
                  },
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
