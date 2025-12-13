import 'package:flutter/material.dart';
import '../../../data/models/chat_message.dart';

/// Chat bubble widget for displaying user and AI messages
///
/// User messages appear on the right with primary color.
/// AI messages appear on the left with a subtle background.
/// Supports streaming state with animated indicator.
class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showAvatar;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.showAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.isUser;
    final isStreaming = message.isStreaming;
    final hasError = message.status == MessageStatus.error;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Avatar (left side)
          if (!isUser && showAvatar) ...[
            _buildAvatar(context, isUser: false),
            const SizedBox(width: 8),
          ] else if (!isUser) ...[
            const SizedBox(width: 40), // Placeholder for alignment
          ],

          // Message bubble
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: _getBubbleColor(context, isUser, hasError),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message content
                  if (message.content.isNotEmpty)
                    Text(
                      message.content,
                      style: TextStyle(
                        color: isUser ? Colors.white : theme.colorScheme.onSurface,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),

                  // Streaming indicator
                  if (isStreaming) ...[
                    if (message.content.isNotEmpty) const SizedBox(height: 8),
                    _StreamingIndicator(),
                  ],

                  // Error message
                  if (hasError && message.errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 14,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            message.errorMessage!,
                            style: TextStyle(
                              color: theme.colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // User Avatar (right side)
          if (isUser && showAvatar) ...[
            const SizedBox(width: 8),
            _buildAvatar(context, isUser: true),
          ] else if (isUser) ...[
            const SizedBox(width: 40), // Placeholder for alignment
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, {required bool isUser}) {
    final theme = Theme.of(context);

    return CircleAvatar(
      radius: 16,
      backgroundColor: isUser
          ? theme.colorScheme.primary.withOpacity(0.2)
          : theme.colorScheme.secondary.withOpacity(0.2),
      child: Icon(
        isUser ? Icons.person : Icons.auto_awesome,
        size: 18,
        color: isUser
            ? theme.colorScheme.primary
            : theme.colorScheme.secondary,
      ),
    );
  }

  Color _getBubbleColor(BuildContext context, bool isUser, bool hasError) {
    final theme = Theme.of(context);

    if (hasError) {
      return theme.colorScheme.errorContainer;
    }

    if (isUser) {
      return theme.colorScheme.primary;
    }

    return theme.colorScheme.surfaceContainerHighest;
  }
}

/// Animated streaming indicator (three dots)
class _StreamingIndicator extends StatefulWidget {
  @override
  State<_StreamingIndicator> createState() => _StreamingIndicatorState();
}

class _StreamingIndicatorState extends State<_StreamingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animValue = (_controller.value - delay).clamp(0.0, 1.0);
            final opacity = (animValue < 0.5)
                ? (animValue * 2)
                : (1 - (animValue - 0.5) * 2);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: Opacity(
                opacity: 0.3 + (opacity * 0.7),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Typing indicator bubble (shown when AI is thinking)
class TypingIndicatorBubble extends StatelessWidget {
  const TypingIndicatorBubble({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
            child: Icon(
              Icons.auto_awesome,
              size: 18,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: _StreamingIndicator(),
          ),
        ],
      ),
    );
  }
}
