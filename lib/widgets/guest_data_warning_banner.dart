import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/services/auth_service.dart';
import '../data/services/contract_service.dart';

/// Guest Data Warning Banner
/// 
/// Phase 24: "The Guest Badge" - Data Persistence Safety
/// 
/// A persistent (but dismissible) banner that warns anonymous users
/// about the risk of data loss. Shown when:
/// 1. User is anonymous (AuthService.isAnonymous)
/// 2. User has active pacts (ContractService.witnessContracts.isNotEmpty)
/// 
/// Strategic Purpose:
/// - Prevents data loss for viral users (high churn risk)
/// - Drives account creation (Growth)
/// - Converts "Ghosts" into "Members"
/// 
/// Behavioral Psychology:
/// - Loss Aversion: "You could lose your pact" is more motivating than "Sign up for features"
/// - Commitment Escalation: They've already made a pact, now seal it with an account
/// 
/// Usage:
/// ```dart
/// GuestDataWarningBanner(
///   onSignUp: () => Navigator.pushNamed(context, '/settings/account'),
/// )
/// ```
class GuestDataWarningBanner extends StatefulWidget {
  /// Callback when user taps "Sign Up"
  final VoidCallback? onSignUp;
  
  /// Callback when user dismisses the banner
  final VoidCallback? onDismiss;
  
  /// Whether to show even without active pacts (for testing)
  final bool forceShow;
  
  const GuestDataWarningBanner({
    super.key,
    this.onSignUp,
    this.onDismiss,
    this.forceShow = false,
  });

  @override
  State<GuestDataWarningBanner> createState() => _GuestDataWarningBannerState();
}

class _GuestDataWarningBannerState extends State<GuestDataWarningBanner>
    with SingleTickerProviderStateMixin {
  bool _isDismissed = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Subtle pulse animation to draw attention
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Repeat the pulse
    _pulseController.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
  
  /// Check if banner should be shown
  bool _shouldShow(AuthService authService, ContractService contractService) {
    if (_isDismissed) return false;
    if (widget.forceShow) return true;
    
    // Must be anonymous
    if (!authService.isAnonymous) return false;
    
    // Must have active pacts (either as builder or witness)
    final hasActivePacts = contractService.allContracts.isNotEmpty;
    
    return hasActivePacts;
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final contractService = context.watch<ContractService>();
    
    if (!_shouldShow(authService, contractService)) {
      return const SizedBox.shrink();
    }
    
    // ignore: unused_local_variable - theme kept for potential future use
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.amber.shade700,
              Colors.orange.shade700,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Warning icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'You\'re a Guest Witness',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Sign up to permanently seal your pact',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Action buttons
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Sign up button
                    ElevatedButton(
                      onPressed: () {
                        widget.onSignUp?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.orange.shade800,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Dismiss button
                    GestureDetector(
                      onTap: () {
                        setState(() => _isDismissed = true);
                        widget.onDismiss?.call();
                      },
                      child: Text(
                        'Later',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 10,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact version of the banner for use in app bars or tight spaces
class GuestDataWarningChip extends StatelessWidget {
  final VoidCallback? onTap;
  
  const GuestDataWarningChip({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final contractService = context.watch<ContractService>();
    
    // Only show if anonymous AND has pacts
    if (!authService.isAnonymous || contractService.allContracts.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.amber.shade700,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 14,
            ),
            SizedBox(width: 4),
            Text(
              'Guest',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
