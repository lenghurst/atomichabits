import 'package:flutter/material.dart';
import '../data/models/consistency_metrics.dart';
import '../data/services/recovery_engine.dart';

/// Recovery Prompt Dialog - The "Never Miss Twice" UI
/// 
/// Shows compassionate, urgency-appropriate messaging when user
/// has missed habit completions. Implements the philosophy:
/// "One miss is an accident. Two misses is the start of a new habit."
/// 
/// Features:
/// - Urgency-appropriate messaging (gentle → important → compassionate)
/// - Zoom-out perspective (show overall progress context)
/// - Optional miss reason selection
/// - "Do the 2-minute version" quick action
class RecoveryPromptDialog extends StatefulWidget {
  final RecoveryNeed recoveryNeed;
  final VoidCallback onDoTinyVersion;
  final VoidCallback onDismiss;
  final Function(MissReason)? onMissReasonSelected;
  final String? zoomOutMessage;
  
  const RecoveryPromptDialog({
    super.key,
    required this.recoveryNeed,
    required this.onDoTinyVersion,
    required this.onDismiss,
    this.onMissReasonSelected,
    this.zoomOutMessage,
  });

  @override
  State<RecoveryPromptDialog> createState() => _RecoveryPromptDialogState();
}

class _RecoveryPromptDialogState extends State<RecoveryPromptDialog> 
    with SingleTickerProviderStateMixin {
  bool _showMissReasonPicker = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  MaterialColor _getUrgencyColor() {
    switch (widget.recoveryNeed.urgency) {
      case RecoveryUrgency.gentle:
        return Colors.amber;
      case RecoveryUrgency.important:
        return Colors.orange;
      case RecoveryUrgency.compassionate:
        return Colors.purple;
    }
  }
  
  Color _getUrgencyBackgroundColor() {
    switch (widget.recoveryNeed.urgency) {
      case RecoveryUrgency.gentle:
        return Colors.amber.shade50;
      case RecoveryUrgency.important:
        return Colors.orange.shade50;
      case RecoveryUrgency.compassionate:
        return Colors.purple.shade50;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = RecoveryEngine.getRecoveryTitle(widget.recoveryNeed.urgency);
    final subtitle = RecoveryEngine.getRecoverySubtitle(
      widget.recoveryNeed.urgency,
      widget.recoveryNeed.daysMissed,
    );
    final message = RecoveryEngine.getRecoveryMessage(widget.recoveryNeed);
    final actionText = RecoveryEngine.getRecoveryActionText(widget.recoveryNeed.urgency);
    final emoji = RecoveryEngine.getRecoveryEmoji(widget.recoveryNeed.urgency);
    final urgencyColor = _getUrgencyColor();
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Emoji icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _getUrgencyBackgroundColor(),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 36),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Title
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                
                // Subtitle
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: urgencyColor.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                
                // Main message
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getUrgencyBackgroundColor(),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: urgencyColor.shade200),
                  ),
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Zoom out perspective (if provided)
                if (widget.zoomOutMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.zoom_out,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.zoomOutMessage!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                
                // Primary action button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: widget.onDoTinyVersion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: urgencyColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      actionText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Miss reason picker toggle
                if (widget.onMissReasonSelected != null) ...[
                  if (!_showMissReasonPicker)
                    TextButton.icon(
                      onPressed: () => setState(() => _showMissReasonPicker = true),
                      icon: const Icon(Icons.help_outline, size: 16),
                      label: const Text('Tell us why you missed'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade600,
                      ),
                    )
                  else ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'What got in the way?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => setState(() => _showMissReasonPicker = false),
                                child: const Icon(Icons.close, size: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: MissReason.values.map((reason) {
                              return ActionChip(
                                label: Text('${reason.emoji} ${reason.label}'),
                                onPressed: () {
                                  widget.onMissReasonSelected?.call(reason);
                                  setState(() => _showMissReasonPicker = false);
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 8),
                
                // Secondary action - dismiss
                TextButton(
                  onPressed: widget.onDismiss,
                  child: const Text(
                    'Not now',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Extension on MaterialColor for easier shade access
extension MaterialColorShadeExtension on MaterialColor {
  Color get shade50 => this[50]!;
  Color get shade200 => this[200]!;
  Color get shade700 => this[700]!;
  Color get shade900 => this[900]!;
}
