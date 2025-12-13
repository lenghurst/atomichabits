import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/app_state.dart';
import '../../data/models/chat_message.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/habit.dart';
import '../../data/models/onboarding_data.dart' as onboarding;
import '../../data/services/onboarding/onboarding_orchestrator.dart';
import '../../data/services/onboarding/conversation_guardrails.dart';
import 'widgets/chat_message_bubble.dart';

/// Conversational onboarding screen - Phase 2 Chat UI
///
/// Implements the "Conversational First" experience using Gemini/Claude.
/// Users chat with an AI coach to create their first habit.
/// Falls back to manual form on frustration, timeout, or user request.
///
/// Uses OnboardingOrchestrator as the "brain" - this screen is just the UI.
class ConversationalOnboardingScreen extends StatefulWidget {
  const ConversationalOnboardingScreen({super.key});

  @override
  State<ConversationalOnboardingScreen> createState() =>
      _ConversationalOnboardingScreenState();
}

class _ConversationalOnboardingScreenState
    extends State<ConversationalOnboardingScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();

  bool _isInitialized = false;
  String? _userName;

  @override
  void initState() {
    super.initState();
    // Initialize conversation after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeConversation();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  /// Initialize the AI conversation via the orchestrator
  Future<void> _initializeConversation() async {
    if (_isInitialized) return;

    final orchestrator = context.read<OnboardingOrchestrator>();

    // Check if AI is available
    if (!orchestrator.isAiAvailable) {
      // No AI configured - go directly to manual form
      if (mounted) {
        context.go('/onboarding/manual');
      }
      return;
    }

    try {
      // Start a new onboarding conversation via orchestrator
      final greeting = await orchestrator.startConversation();

      if (greeting == null) {
        // Failed to start - switch to manual mode
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Having trouble connecting to AI. Using manual form.'),
            ),
          );
          context.go('/onboarding/manual');
        }
        return;
      }

      setState(() {
        _isInitialized = true;
      });

      _scrollToBottom();
    } catch (e) {
      // On failure, switch to manual mode
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Having trouble connecting to AI. Using manual form.'),
          ),
        );
        context.go('/onboarding/manual');
      }
    }
  }

  /// Send a message via the orchestrator
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final orchestrator = context.read<OnboardingOrchestrator>();
    if (orchestrator.isLoading) return;

    // Capture user's name if not already set
    if (_userName == null) {
      _userName = _extractUserName(text);
    }

    _messageController.clear();

    // Send message through orchestrator (handles guardrails, rate limiting, etc.)
    final result = await orchestrator.sendMessage(
      text,
      onChunk: (chunk) {
        // Trigger rebuild to show streaming content
        if (mounted) {
          setState(() {});
          _scrollToBottom();
        }
      },
    );

    // Handle result
    if (result.shouldSwitchToManual) {
      if (mounted) {
        _showSwitchToManualDialog(result.switchReason ?? 'Let\'s use the form instead.');
      }
      return;
    }

    // Check if we have complete habit data
    if (result.hasCompleteData && result.extractedData != null) {
      if (mounted) {
        _showHabitConfirmationDialog(result.extractedData!);
      }
    }

    _scrollToBottom();
  }

  /// Extract user's name from their message
  String? _extractUserName(String text) {
    final patterns = [
      RegExp(r"(?:i'm|i am|my name is|call me)\s+(\w+)", caseSensitive: false),
      RegExp(r"^(\w+)\s+here", caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return match.group(1);
      }
    }
    return null;
  }

  /// Scroll chat to bottom
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Show dialog to switch to manual mode
  void _showSwitchToManualDialog(String reason) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.switch_access_shortcut),
            SizedBox(width: 8),
            Text('Switch to Form?'),
          ],
        ),
        content: Text(reason),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keep Chatting'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/onboarding/manual');
            },
            child: const Text('Use Form'),
          ),
        ],
      ),
    );
  }

  /// Show confirmation dialog when habit data is extracted
  void _showHabitConfirmationDialog(onboarding.OnboardingData data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Text(data.habitEmoji ?? ''),
            const SizedBox(width: 8),
            const Expanded(child: Text('Your Habit Plan')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryRow('Identity', data.identity ?? 'Not set'),
              _buildSummaryRow('Habit', data.name ?? 'Not set'),
              _buildSummaryRow('Tiny Version', data.tinyVersion ?? 'Not set'),
              _buildSummaryRow('When', data.implementationTime ?? 'Not set'),
              _buildSummaryRow('Where', data.implementationLocation ?? 'Not set'),
              if (data.environmentCue != null)
                _buildSummaryRow('Cue', data.environmentCue!),
              if (data.temptationBundle != null)
                _buildSummaryRow('Paired With', data.temptationBundle!),
              if (data.preHabitRitual != null)
                _buildSummaryRow('Pre-Ritual', data.preHabitRitual!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Continue chatting
            },
            child: const Text('Keep Editing'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.go('/onboarding/manual');
            },
            child: const Text('Edit in Form'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _saveHabitAndComplete(data);
            },
            child: const Text('Start Building!'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  /// Save the habit and complete onboarding
  Future<void> _saveHabitAndComplete(onboarding.OnboardingData data) async {
    final appState = context.read<AppState>();

    // Create user profile (use extracted name or default)
    final profile = UserProfile(
      name: _userName ?? 'Friend',
      identity: data.identity ?? '',
      createdAt: DateTime.now(),
    );

    // Create habit from extracted data
    final habit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: data.name ?? 'My Habit',
      identity: data.identity ?? '',
      tinyVersion: data.tinyVersion ?? '',
      createdAt: DateTime.now(),
      implementationTime: data.implementationTime ?? '09:00',
      implementationLocation: data.implementationLocation ?? '',
      environmentCue: data.environmentCue,
      temptationBundle: data.temptationBundle,
      preHabitRitual: data.preHabitRitual,
      environmentDistraction: data.environmentDistraction,
      isBreakHabit: data.habitType == onboarding.HabitType.breakHabit,
      replacesHabit: data.replacesHabit,
      rootCause: data.rootCause,
      substitutionPlan: data.substitutionPlan,
      habitEmoji: data.habitEmoji ?? '',
      motivation: data.motivation,
      recoveryPlan: data.recoveryPlan,
    );

    // Save to app state
    await appState.setUserProfile(profile);
    await appState.createHabit(habit);
    await appState.completeOnboarding();

    // Clean up orchestrator state
    context.read<OnboardingOrchestrator>().resetConversation();

    // Navigate to Today screen
    if (mounted) {
      context.go('/today');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text('Habit Coach'),
          ],
        ),
        centerTitle: true,
        actions: [
          // Switch to manual form button
          TextButton.icon(
            onPressed: () => context.go('/onboarding/manual'),
            icon: const Icon(Icons.edit_note, size: 18),
            label: const Text('Form'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Chat messages list
            Expanded(
              child: _buildMessagesList(),
            ),

            // Input area
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    if (!_isInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Connecting to your habit coach...'),
          ],
        ),
      );
    }

    return Consumer<OnboardingOrchestrator>(
      builder: (context, orchestrator, _) {
        final conversation = orchestrator.conversation;

        if (conversation == null || conversation.messages.isEmpty) {
          return const Center(
            child: Text('Starting conversation...'),
          );
        }

        final messages = conversation.messages;

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          itemCount: messages.length + (orchestrator.isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            // Show typing indicator at the end if loading
            if (orchestrator.isLoading && index == messages.length) {
              return const TypingIndicatorBubble();
            }

            final message = messages[index];

            // Skip system messages
            if (message.role == MessageRole.system) {
              return const SizedBox.shrink();
            }

            return ChatMessageBubble(
              message: message,
              showAvatar: true,
            );
          },
        );
      },
    );
  }

  Widget _buildInputArea() {
    final theme = Theme.of(context);

    return Consumer<OnboardingOrchestrator>(
      builder: (context, orchestrator, _) {
        final isLoading = orchestrator.isLoading;

        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Text input
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _messageController,
                    focusNode: _inputFocusNode,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    enabled: !isLoading && _isInitialized,
                    decoration: InputDecoration(
                      hintText: isLoading
                          ? 'Waiting for response...'
                          : 'Type your message...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Send button
              Container(
                decoration: BoxDecoration(
                  color: isLoading
                      ? theme.colorScheme.surfaceContainerHighest
                      : theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: isLoading ? null : _sendMessage,
                  icon: Icon(
                    Icons.send_rounded,
                    color: isLoading
                        ? theme.colorScheme.onSurfaceVariant
                        : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
