import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/services/onboarding/onboarding_orchestrator.dart';
import '../../../data/models/onboarding_data.dart';

/// Magic Wand button for AI-powered habit auto-completion
/// 
/// The "Body" of the Phase 1 AI feature.
/// When tapped, uses Gemini AI to suggest:
/// - Tiny Version (2-minute rule)
/// - Implementation Time
/// - Implementation Location
/// - Environment Cue
/// - Temptation Bundle (optional)
/// - Pre-Habit Ritual (optional)
class MagicWandButton extends StatefulWidget {
  /// Current habit name entered by user (used as context)
  final String habitName;
  
  /// Current identity entered by user (used as context)
  final String identity;
  
  /// Whether this is a break habit (breaking bad habit)
  final bool isBreakHabit;
  
  /// Callback when AI successfully generates habit data
  final void Function(OnboardingData data) onHabitGenerated;
  
  /// Callback when AI generation starts/ends (for loading state)
  final void Function(bool isLoading)? onLoadingChanged;
  
  /// Callback when an error occurs
  final void Function(String error)? onError;

  const MagicWandButton({
    super.key,
    required this.habitName,
    required this.identity,
    this.isBreakHabit = false,
    required this.onHabitGenerated,
    this.onLoadingChanged,
    this.onError,
  });

  @override
  State<MagicWandButton> createState() => _MagicWandButtonState();
}

class _MagicWandButtonState extends State<MagicWandButton> 
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    // Setup sparkle animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Validate that we have enough context to call AI
  bool get _hasMinimumContext {
    return widget.habitName.trim().isNotEmpty || 
           widget.identity.trim().isNotEmpty;
  }

  /// Check if AI is available
  bool get _isAiAvailable {
    try {
      final orchestrator = context.read<OnboardingOrchestrator>();
      return orchestrator.isAiAvailable;
    } catch (e) {
      return false;
    }
  }

  /// Get tooltip message based on state
  String get _tooltipMessage {
    if (_isLoading) return 'Generating suggestions...';
    if (!_isAiAvailable) return 'AI not configured';
    if (!_hasMinimumContext) return 'Enter a habit name or identity first';
    return 'Auto-fill with AI suggestions';
  }

  /// Handle button tap - trigger AI generation
  Future<void> _onTap() async {
    if (_isLoading || !_isAiAvailable) return;
    
    // Require at least habit name or identity
    if (!_hasMinimumContext) {
      widget.onError?.call('Please enter a habit name or identity first.');
      return;
    }

    setState(() => _isLoading = true);
    widget.onLoadingChanged?.call(true);
    
    // Start sparkle animation
    _animationController.repeat(reverse: true);

    try {
      final orchestrator = context.read<OnboardingOrchestrator>();
      
      final result = await orchestrator.magicWandComplete(
        habitName: widget.habitName.trim().isEmpty 
            ? 'a good habit' 
            : widget.habitName.trim(),
        identity: widget.identity.trim().isEmpty 
            ? 'someone who achieves their goals' 
            : widget.identity.trim(),
        isBreakHabit: widget.isBreakHabit,
      );

      if (!mounted) return;

      if (result != null) {
        // Success - trigger callback
        widget.onHabitGenerated(result);
        
        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('AI suggestions applied!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Error was already handled by orchestrator
        widget.onError?.call('Failed to generate suggestions. Please try again or fill in manually.');
      }
    } catch (e) {
      if (mounted) {
        widget.onError?.call('An error occurred. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        widget.onLoadingChanged?.call(false);
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEnabled = _isAiAvailable && !_isLoading;
    
    return Tooltip(
      message: _tooltipMessage,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _isLoading ? _scaleAnimation.value : 1.0,
            child: Transform.rotate(
              angle: _isLoading ? _rotationAnimation.value : 0.0,
              child: child,
            ),
          );
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? _onTap : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                gradient: isEnabled
                    ? LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isEnabled ? null : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isEnabled
                    ? [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isLoading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else
                    Icon(
                      Icons.auto_awesome,
                      size: 18,
                      color: isEnabled ? Colors.white : Colors.grey.shade600,
                    ),
                  const SizedBox(width: 6),
                  Text(
                    _isLoading ? 'AI...' : 'AI',
                    style: TextStyle(
                      color: isEnabled ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Larger Magic Wand button variant for prominent placement
class MagicWandButtonLarge extends StatelessWidget {
  final String habitName;
  final String identity;
  final bool isBreakHabit;
  final void Function(OnboardingData data) onHabitGenerated;
  final void Function(bool isLoading)? onLoadingChanged;
  final void Function(String error)? onError;

  const MagicWandButtonLarge({
    super.key,
    required this.habitName,
    required this.identity,
    this.isBreakHabit = false,
    required this.onHabitGenerated,
    this.onLoadingChanged,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Delegate to regular MagicWandButton
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withValues(alpha: 0.1),
                colorScheme.secondary.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Magic Wand',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Let AI fill in the details for you',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
