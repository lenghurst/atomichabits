import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// High Five Sheet
/// 
/// Phase 22: "The Witness" - Social Accountability Loop
/// 
/// A bottom sheet for sending emoji reactions (High Fives) to builders.
/// This creates the SECOND dopamine hit for the builder (social validation).
/// 
/// Quick reactions:
/// - 🖐️ High five!
/// - 🔥 On fire!
/// - 💪 Keep it up!
/// - ⚡ Crushing it!
/// - 🏆 Champion!
/// - 🎯 Bullseye!
class HighFiveSheet extends StatefulWidget {
  final String contractId;
  final String builderId;
  final String? builderName;
  final String? habitName;
  final Function(String emoji, String? message) onSend;
  
  const HighFiveSheet({
    super.key,
    required this.contractId,
    required this.builderId,
    this.builderName,
    this.habitName,
    required this.onSend,
  });

  /// Show the high five sheet
  static Future<void> show(
    BuildContext context, {
    required String contractId,
    required String builderId,
    String? builderName,
    String? habitName,
    required Function(String emoji, String? message) onSend,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HighFiveSheet(
        contractId: contractId,
        builderId: builderId,
        builderName: builderName,
        habitName: habitName,
        onSend: onSend,
      ),
    );
  }

  @override
  State<HighFiveSheet> createState() => _HighFiveSheetState();
}

class _HighFiveSheetState extends State<HighFiveSheet> 
    with SingleTickerProviderStateMixin {
  String? _selectedEmoji;
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  static const List<_QuickReaction> _quickReactions = [
    _QuickReaction(emoji: '🖐️', label: 'High five!'),
    _QuickReaction(emoji: '🔥', label: 'On fire!'),
    _QuickReaction(emoji: '💪', label: 'Keep it up!'),
    _QuickReaction(emoji: '⚡', label: 'Crushing it!'),
    _QuickReaction(emoji: '🏆', label: 'Champion!'),
    _QuickReaction(emoji: '🎯', label: 'Bullseye!'),
  ];
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  void _selectEmoji(String emoji) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedEmoji = emoji;
    });
    
    // Animate selection
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }
  
  Future<void> _sendHighFive() async {
    if (_selectedEmoji == null) return;
    
    setState(() => _isSending = true);
    
    // Haptic feedback for send
    HapticFeedback.mediumImpact();
    
    await widget.onSend(
      _selectedEmoji!,
      _messageController.text.isNotEmpty ? _messageController.text : null,
    );
    
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Title
              Text(
                'Send a High Five! 🖐️',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              if (widget.builderName != null)
                Text(
                  'Let ${widget.builderName} know you saw their progress',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              
              const SizedBox(height: 24),
              
              // Quick reactions grid
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: _quickReactions.map((reaction) {
                  final isSelected = _selectedEmoji == reaction.emoji;
                  
                  return AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, _) {
                      final scale = isSelected ? _scaleAnimation.value : 1.0;
                      return Transform.scale(
                        scale: scale,
                        child: _ReactionButton(
                          emoji: reaction.emoji,
                          label: reaction.label,
                          isSelected: isSelected,
                          onTap: () => _selectEmoji(reaction.emoji),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24),
              
              // Custom message input
              TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: 'Add a message (optional)',
                  hintText: 'Great job! Keep it going!',
                  border: const OutlineInputBorder(),
                  prefixIcon: _selectedEmoji != null
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            _selectedEmoji!,
                            style: const TextStyle(fontSize: 24),
                          ),
                        )
                      : null,
                ),
                maxLines: 2,
              ),
              
              const SizedBox(height: 24),
              
              // Send button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _selectedEmoji == null || _isSending 
                      ? null 
                      : _sendHighFive,
                  icon: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _selectedEmoji ?? '🖐️',
                          style: const TextStyle(fontSize: 20),
                        ),
                  label: Text(_isSending ? 'Sending...' : 'Send High Five'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Cancel button
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickReaction {
  final String emoji;
  final String label;
  
  const _QuickReaction({
    required this.emoji,
    required this.label,
  });
}

class _ReactionButton extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _ReactionButton({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Note: Use Flutter's built-in AnimatedBuilder from 'package:flutter/material.dart'
// which is available as part of the animation framework

/// High Five Received Animation Widget
/// 
/// Shows a celebratory animation when a high five is received.
class HighFiveReceivedOverlay extends StatefulWidget {
  final String emoji;
  final String? message;
  final String? senderName;
  final VoidCallback? onDismiss;
  
  const HighFiveReceivedOverlay({
    super.key,
    required this.emoji,
    this.message,
    this.senderName,
    this.onDismiss,
  });
  
  /// Show the overlay
  static Future<void> show(
    BuildContext context, {
    required String emoji,
    String? message,
    String? senderName,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => HighFiveReceivedOverlay(
        emoji: emoji,
        message: message,
        senderName: senderName,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  State<HighFiveReceivedOverlay> createState() => _HighFiveReceivedOverlayState();
}

class _HighFiveReceivedOverlayState extends State<HighFiveReceivedOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.2),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    
    _controller.forward();
    
    // Haptic feedback
    HapticFeedback.heavyImpact();
    
    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onDismiss?.call();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Center(
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.emoji,
                        style: const TextStyle(fontSize: 80),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.senderName != null
                            ? 'High Five from ${widget.senderName}!'
                            : 'High Five!',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.message != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.message!,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
