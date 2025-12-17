import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../config/deep_link_config.dart';
import '../data/models/habit_contract.dart';
import '../data/services/contract_service.dart';
import '../data/services/deep_link_service.dart';

/// Share Contract Bottom Sheet
/// 
/// Phase 21.1: "The Viral Engine" - Share Flow
/// Phase 24: "The Clipboard Bridge" - Deferred Deep Linking
/// Phase 24.B: "The Standard Protocol" - Install Referrer Smart Links
/// 
/// A beautiful, shareable modal for distributing contract invite links.
/// Inspired by: Twitter share sheets, Spotify share flows
/// 
/// Features:
/// - Copy link button with haptic feedback
/// - Native share sheet integration
/// - QR code display (for in-person sharing)
/// - Preview of what recipient will see
/// - Social proof messaging
/// - [NEW] Smart Links with Play Store referrer for Android
/// 
/// Phase 24 Enhancement:
/// ALWAYS copies to clipboard BEFORE opening share sheet.
/// This ensures the "Clipboard Bridge" works even if standard deep links fail.
/// User A shares -> Clipboard populated -> User B installs -> Clipboard detected
/// 
/// Phase 24.B Enhancement:
/// Generates platform-aware "Smart Links":
/// - Android: Play Store link with referrer parameter (invite_code passed through)
/// - iOS: Universal Link (standard deep link)
/// - Web: Landing page with platform detection
class ShareContractSheet extends StatefulWidget {
  final HabitContract contract;
  final ContractService contractService;
  final VoidCallback? onShared;

  const ShareContractSheet({
    super.key,
    required this.contract,
    required this.contractService,
    this.onShared,
  });

  /// Show the share sheet as a modal bottom sheet
  static Future<void> show({
    required BuildContext context,
    required HabitContract contract,
    required ContractService contractService,
    VoidCallback? onShared,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareContractSheet(
        contract: contract,
        contractService: contractService,
        onShared: onShared,
      ),
    );
  }

  @override
  State<ShareContractSheet> createState() => _ShareContractSheetState();
}

class _ShareContractSheetState extends State<ShareContractSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  bool _linkCopied = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Standard invite URL (Universal Link / App Link)
  String get _inviteUrl => widget.contract.inviteUrl ?? 
      DeepLinkConfig.getContractInviteUrl(widget.contract.inviteCode);
  
  /// Phase 24.E: Smart Link that works across ALL platforms
  /// 
  /// The "Web Anchor" (Trojan Horse) Strategy:
  /// - All platforms share the same URL: https://atomichabits.app/join/CODE
  /// - The React landing page detects OS and:
  ///   - Android: Redirects to Play Store with referrer (Install Referrer API)
  ///   - iOS: Redirects to App Store (when available)
  ///   - Desktop: Shows landing page with invite banner + email capture
  /// 
  /// This converts "failed redirects" (desktop) into email signups!
  String get _smartInviteUrl {
    // Phase 24.E: Use the Web Anchor URL for all platforms
    // The React landing page handles OS detection and appropriate redirects
    return DeepLinkConfig.getWebAnchorUrl(widget.contract.inviteCode);
  }
  
  /// Phase 24.B: Play Store link with referrer (for direct Android sharing)
  String get _playStoreReferrerUrl => 
      DeepLinkService.getPlayStoreReferrerLink(widget.contract.inviteCode);

  String get _shareText {
    final buffer = StringBuffer();
    
    // Opening hook - The Pact branding
    buffer.writeln('I need a witness.');
    buffer.writeln();
    
    // The habit
    if (widget.contract.commitmentStatement != null) {
      buffer.writeln('"${widget.contract.commitmentStatement}"');
      buffer.writeln();
    }
    
    // CTA - The Pact branding
    buffer.writeln('Sign The Pact with me:');
    buffer.writeln(_smartInviteUrl);
    buffer.writeln();
    buffer.write('#ThePact');
    
    // Phase 24.B: Add Play Store link for Android recipients
    // This ensures the Install Referrer works even if the web redirect fails
    if (Platform.isAndroid) {
      buffer.writeln();
      buffer.writeln();
      buffer.writeln('Android direct install: $_playStoreReferrerUrl');
    }
    
    return buffer.toString();
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _inviteUrl));
    HapticFeedback.mediumImpact();
    
    setState(() {
      _linkCopied = true;
    });
    
    // Reset after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _linkCopied = false;
        });
      }
    });
  }

  Future<void> _shareNative() async {
    // Phase 24: ALWAYS copy to clipboard BEFORE sharing
    // This enables the "Clipboard Bridge" for deferred deep linking
    // Even if the deep link fails, User B can detect the invite from clipboard
    await Clipboard.setData(ClipboardData(text: _shareText));
    
    await Share.share(
      _shareText,
      subject: '${widget.contract.title} - Join my pact!',
    );
    HapticFeedback.lightImpact();
    widget.onShared?.call();
  }

  Future<void> _shareToTwitter() async {
    final twitterUrl = Uri.parse(
      'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(_shareText)}',
    );
    
    await Clipboard.setData(ClipboardData(text: _shareText));
    HapticFeedback.lightImpact();
    
    // Show snackbar since we can't directly open URL without url_launcher
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tweet copied! Open Twitter to post.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.share_outlined,
                    size: 32,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Share Your Contract',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Find your accountability partner',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            // Contract preview card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.handshake_outlined,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.contract.title,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${widget.contract.durationDays} days',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (widget.contract.commitmentStatement != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      '"${widget.contract.commitmentStatement}"',
                      style: textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Link display with copy button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _inviteUrl,
                      style: textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _linkCopied
                        ? Icon(
                            Icons.check_circle,
                            key: const ValueKey('check'),
                            color: colorScheme.primary,
                            size: 24,
                          )
                        : IconButton(
                            key: const ValueKey('copy'),
                            icon: Icon(
                              Icons.copy_outlined,
                              color: colorScheme.primary,
                            ),
                            onPressed: _copyToClipboard,
                            tooltip: 'Copy link',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 24,
                              minHeight: 24,
                            ),
                          ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Share buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Primary share button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _shareNative,
                      icon: const Icon(Icons.share),
                      label: const Text('Share Invite Link'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Secondary options row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _shareToTwitter,
                          icon: const Icon(Icons.tag, size: 18),
                          label: const Text('Twitter'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _copyToClipboard,
                          icon: Icon(
                            _linkCopied ? Icons.check : Icons.link,
                            size: 18,
                          ),
                          label: Text(_linkCopied ? 'Copied!' : 'Copy Link'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Social proof / tip
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tips_and_updates_outlined,
                    size: 20,
                    color: colorScheme.secondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tip: People who share with a specific friend are 3x more likely to complete their habit.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// A compact share button for use in lists and cards
class ShareContractButton extends StatelessWidget {
  final HabitContract contract;
  final ContractService contractService;
  final bool compact;
  final VoidCallback? onShared;

  const ShareContractButton({
    super.key,
    required this.contract,
    required this.contractService,
    this.compact = false,
    this.onShared,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return IconButton(
        icon: const Icon(Icons.share_outlined),
        onPressed: () => ShareContractSheet.show(
          context: context,
          contract: contract,
          contractService: contractService,
          onShared: onShared,
        ),
        tooltip: 'Share contract',
      );
    }
    
    return OutlinedButton.icon(
      onPressed: () => ShareContractSheet.show(
        context: context,
        contract: contract,
        contractService: contractService,
        onShared: onShared,
      ),
      icon: const Icon(Icons.share_outlined, size: 18),
      label: const Text('Share'),
    );
  }
}

/// Invitation preview card (shown to the person receiving the link)
class ContractInvitePreview extends StatelessWidget {
  final HabitContract contract;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final bool isLoading;

  const ContractInvitePreview({
    super.key,
    required this.contract,
    this.onAccept,
    this.onDecline,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.handshake,
                size: 40,
                color: colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Title
            Text(
              "You're Invited!",
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Someone wants you to be their accountability partner',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Contract details
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contract.title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${contract.durationDays} days',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  
                  if (contract.commitmentStatement != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        '"${contract.commitmentStatement}"',
                        style: textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                  
                  if (contract.builderMessage != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            contract.builderMessage!,
                            style: textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // What it means section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'As a Witness, you can:',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildBulletPoint(context, 'See their progress'),
                  _buildBulletPoint(context, 'Send encouraging nudges'),
                  _buildBulletPoint(context, 'Celebrate their wins'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action buttons
            if (isLoading)
              const CircularProgressIndicator()
            else ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onAccept,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Accept & Become Witness'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              TextButton(
                onPressed: onDecline,
                child: const Text("Not right now"),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.check,
            size: 16,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
