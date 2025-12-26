import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import '../data/app_state.dart';
import '../data/services/sound_service.dart';

/// Stack Prompt Dialog - Phase 13: Habit Stacking + Phase 18: The Vibe Update
/// 
/// Shows the "Chain Reaction" prompt after completing a habit
/// that has stacked habits waiting to be done next.
/// 
/// Philosophy: "After [COMPLETED HABIT], I will [NEXT HABIT]"
/// This leverages existing momentum to build new behaviors.
/// 
/// Phase 18 Enhancement: "Juice it or lose it"
/// - Pop animation with ScaleTransition/SpringSimulation
/// - Confetti celebration
/// - Haptic + Sound feedback
class StackPromptDialog extends StatefulWidget {
  final String completedHabitName;
  final String nextHabitName;
  final String? nextHabitEmoji;
  final String? nextHabitTinyVersion;
  final bool isBreakHabit;
  final VoidCallback onStartNow;
  final VoidCallback onNotNow;

  const StackPromptDialog({
    super.key,
    required this.completedHabitName,
    required this.nextHabitName,
    this.nextHabitEmoji,
    this.nextHabitTinyVersion,
    this.isBreakHabit = false,
    required this.onStartNow,
    required this.onNotNow,
  });

  @override
  State<StackPromptDialog> createState() => _StackPromptDialogState();
}

class _StackPromptDialogState extends State<StackPromptDialog>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _scaleController;
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;
  
  // Confetti controller
  late ConfettiController _confettiController;
  
  // Chain link bounce controller
  late AnimationController _chainBounceController;
  late Animation<double> _chainBounceAnimation;

  @override
  void initState() {
    super.initState();
    
    // Pop-in scale animation (spring-like)
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );
    
    // Subtle pulse animation for the action button
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Chain link bounce animation
    _chainBounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _chainBounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -10).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -10, end: 0).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 50,
      ),
    ]).animate(_chainBounceController);
    
    // Confetti controller
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    
    // Start animations
    _startEntryAnimation();
  }
  
  void _startEntryAnimation() async {
    // Trigger haptic feedback for dialog appearance
    final appState = context.read<AppState>();
    appState.triggerHaptic(HapticFeedbackType.medium);
    
    // Trigger sound
    try {
      final soundService = context.read<SoundService>();
      await FeedbackPatterns.chainReaction(
        soundService,
        hapticsEnabled: appState.hapticsEnabled,
      );
    } catch (e) {
      // SoundService might not be available in all contexts
    }
    
    // Start scale animation
    await _scaleController.forward();
    
    // Start confetti
    _confettiController.play();
    
    // Start chain bounce
    await Future.delayed(const Duration(milliseconds: 200));
    _chainBounceController.forward();
    
    // Start pulse loop on button
    _bounceController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _bounceController.dispose();
    _chainBounceController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Use purple for break habits, green for build habits
    final accentColor = widget.isBreakHabit ? Colors.purple : Colors.green;
    final actionText = widget.isBreakHabit ? 'Stay Strong' : "Let's Do It";
    final actionDescription = widget.isBreakHabit 
        ? 'Keep your momentum going by avoiding' 
        : 'Continue your momentum with';

    return Stack(
      children: [
        // Dialog
        ScaleTransition(
          scale: _scaleAnimation,
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Chain Reaction Header
                  _buildHeader(accentColor),
                  
                  const SizedBox(height: 20),
                  
                  // Completed Habit Badge (animated entry)
                  _buildCompletedBadge(colorScheme),
                  
                  const SizedBox(height: 16),
                  
                  // Chain Link Animation (bouncing)
                  AnimatedBuilder(
                    animation: _chainBounceAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _chainBounceAnimation.value),
                        child: Icon(
                          Icons.link,
                          color: accentColor.withValues(alpha: 0.7),
                          size: 32,
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Next Habit Card
                  _buildNextHabitCard(context, accentColor, actionDescription),
                  
                  const SizedBox(height: 24),
                  
                  // Action Buttons (with pulse animation)
                  _buildActionButtons(context, accentColor, actionText),
                ],
              ),
            ),
          ),
        ),
        
        // Confetti overlay
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 15,
            gravity: 0.1,
            shouldLoop: false,
            colors: [
              accentColor,
              accentColor.withValues(alpha: 0.7),
              Colors.amber,
              Colors.amber.shade300,
              Colors.white,
            ],
            minimumSize: const Size(5, 5),
            maximumSize: const Size(15, 15),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(Color accentColor) {
    return Column(
      children: [
        // Chain Link Icon with glow effect
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.5, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1 * value),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.3 * value),
                    blurRadius: 20 * value,
                    spreadRadius: 5 * value,
                  ),
                ],
              ),
              child: Icon(
                Icons.link,
                color: accentColor,
                size: 32,
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        // Animated title
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: const Text(
                  'Chain Reaction!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Text(
          'You\'ve built momentum!',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedBadge(ColorScheme colorScheme) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    widget.completedHabitName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.green,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNextHabitCard(BuildContext context, Color accentColor, String actionDescription) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentColor.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Text(
                  actionDescription,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.nextHabitEmoji != null) ...[
                      Text(
                        widget.nextHabitEmoji!,
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        widget.nextHabitName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                if (widget.nextHabitTinyVersion != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.isBreakHabit 
                        ? 'Remember: ${widget.nextHabitTinyVersion}'
                        : 'Just: ${widget.nextHabitTinyVersion}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, Color accentColor, String actionText) {
    return Column(
      children: [
        // Primary Action: Start Now (with pulse animation)
        AnimatedBuilder(
          animation: _bounceAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _bounceAnimation.value,
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    // Trigger haptic on button press
                    final appState = context.read<AppState>();
                    appState.triggerHaptic(HapticFeedbackType.heavy);
                    widget.onStartNow();
                  },
                  icon: Icon(widget.isBreakHabit ? Icons.shield : Icons.play_arrow),
                  label: Text(actionText),
                  style: FilledButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        // Secondary Action: Not Now
        TextButton(
          onPressed: () {
            final appState = context.read<AppState>();
            appState.triggerHaptic(HapticFeedbackType.light);
            widget.onNotNow();
          },
          child: Text(
            'Not right now',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }
}

/// Compact Stack Prompt for use in snackbars or smaller UI contexts
class CompactStackPrompt extends StatelessWidget {
  final String nextHabitName;
  final String? nextHabitEmoji;
  final bool isBreakHabit;
  final VoidCallback onTap;

  const CompactStackPrompt({
    super.key,
    required this.nextHabitName,
    this.nextHabitEmoji,
    this.isBreakHabit = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = isBreakHabit ? Colors.purple : Colors.green;
    
    return GestureDetector(
      onTap: () {
        // Trigger haptic on tap
        context.read<AppState>().triggerHaptic(HapticFeedbackType.selection);
        onTap();
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.8, end: 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accentColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.link, color: accentColor, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Chain: ${nextHabitEmoji ?? ''} $nextHabitName',
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward, color: accentColor, size: 14),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
