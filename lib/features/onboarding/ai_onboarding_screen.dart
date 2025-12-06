import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/chat_message.dart';
import '../../data/models/chat_conversation.dart';
import '../../data/models/habit.dart';
import '../../data/services/gemini_chat_service.dart';
import '../../data/app_state.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/voice_input_button.dart';

/// AI-powered conversational onboarding screen
class AiOnboardingScreen extends StatefulWidget {
  const AiOnboardingScreen({super.key});

  @override
  State<AiOnboardingScreen> createState() => _AiOnboardingScreenState();
}

class _AiOnboardingScreenState extends State<AiOnboardingScreen> {
  late GeminiChatService _chatService;
  late TextEditingController _textController;
  late ScrollController _scrollController;
  late FocusNode _textFocusNode;

  ChatConversation? _conversation;
  bool _isLoading = true;
  bool _isSending = false;
  bool _isListening = false;
  String _liveTranscription = '';
  ChatMessage? _streamingMessage;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _scrollController = ScrollController();
    _textFocusNode = FocusNode();
    _initChat();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  Future<void> _initChat() async {
    // Initialize the chat service
    // TODO: Get API key from secure storage or environment
    _chatService = GeminiChatService(
      // apiKey: 'YOUR_GEMINI_API_KEY', // Set this in production
      onStreamChunk: (chunk) {
        if (mounted) {
          setState(() {});
          _scrollToBottom();
        }
      },
    );

    await _chatService.init();

    // Start a new onboarding conversation
    final conversation = await _chatService.startConversation(
      type: ConversationType.onboarding,
    );

    // Get the initial greeting
    final appState = Provider.of<AppState>(context, listen: false);
    await _chatService.getInitialGreeting(
      conversation: conversation,
      existingHabits: appState.habits,
    );

    if (mounted) {
      setState(() {
        _conversation = conversation;
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

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

  Future<void> _sendMessage(String text, {bool isVoice = false}) async {
    if (text.trim().isEmpty || _conversation == null) return;

    _textController.clear();
    _textFocusNode.unfocus();

    setState(() {
      _isSending = true;
    });

    try {
      final appState = Provider.of<AppState>(context, listen: false);

      // Create a placeholder for the streaming message
      _streamingMessage = ChatMessage.assistant();
      _conversation!.addMessage(_streamingMessage!);

      setState(() {});
      _scrollToBottom();

      // Send message and stream response
      await _chatService.sendMessage(
        userMessage: text,
        conversation: _conversation!,
        isVoiceInput: isVoice,
        userHabits: appState.habits,
        onChunk: (chunk) {
          if (mounted) {
            setState(() {});
            _scrollToBottom();
          }
        },
      );

      // Check if onboarding is complete
      if (_conversation!.onboardingData?.isComplete == true) {
        _showCreateHabitDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
          _streamingMessage = null;
        });
      }
    }
  }

  void _showCreateHabitDialog() {
    final data = _conversation!.onboardingData!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Your Habit?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Here's what we've put together:",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Identity', data.identity),
            _buildSummaryRow('Habit', data.habitName),
            if (data.tinyVersion != null)
              _buildSummaryRow('2-min version', data.tinyVersion),
            _buildSummaryRow('When', data.implementationTime),
            _buildSummaryRow('Where', data.implementationLocation),
            if (data.temptationBundle != null)
              _buildSummaryRow('Reward', data.temptationBundle),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Refining'),
          ),
          FilledButton(
            onPressed: () {
              _createHabit();
              Navigator.pop(context);
            },
            child: const Text('Create Habit'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
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

  void _createHabit() {
    final habit = _chatService.createHabitFromOnboarding(_conversation!);
    if (habit != null) {
      final appState = Provider.of<AppState>(context, listen: false);
      appState.addHabit(habit);

      _conversation!.habitCreated = true;
      _chatService.saveCurrentConversation();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Created habit: ${habit.name}'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to home
      context.go('/');
    }
  }

  void _onVoiceResult(String text) {
    if (text.isNotEmpty) {
      _sendMessage(text, isVoice: true);
    }
    setState(() {
      _isListening = false;
      _liveTranscription = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Habit'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitConfirmation(),
        ),
        actions: [
          if (_conversation?.onboardingData?.isComplete == true)
            TextButton.icon(
              onPressed: _showCreateHabitDialog,
              icon: const Icon(Icons.check),
              label: const Text('Done'),
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Progress indicator
              if (_conversation?.onboardingData != null)
                _buildProgressIndicator(),

              // Chat messages
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildChatList(),
              ),

              // Input area
              _buildInputArea(),
            ],
          ),

          // Voice listening overlay
          if (_isListening)
            VoiceListeningOverlay(
              currentText: _liveTranscription,
              onCancel: () {
                setState(() {
                  _isListening = false;
                  _liveTranscription = '';
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final data = _conversation!.onboardingData!;
    int completed = 0;
    if (data.identity != null) completed++;
    if (data.habitName != null) completed++;
    if (data.implementationTime != null) completed++;
    if (data.implementationLocation != null) completed++;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress: $completed/4 key elements',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (data.isComplete)
                Chip(
                  label: const Text('Ready!'),
                  backgroundColor: Colors.green.withOpacity(0.2),
                  labelStyle: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: completed / 4,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    if (_conversation == null) return const SizedBox.shrink();

    final messages = _conversation!.messages;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: messages.length + (_isSending && _streamingMessage == null ? 1 : 0),
      itemBuilder: (context, index) {
        // Show typing indicator at the end while waiting for response
        if (index == messages.length && _isSending && _streamingMessage == null) {
          return const TypingIndicator();
        }

        final message = messages[index];

        // Show streaming bubble for the current streaming message
        if (message.isStreaming) {
          return StreamingChatBubble(message: message);
        }

        // Skip system messages in the UI
        if (message.role == MessageRole.system) {
          return const SizedBox.shrink();
        }

        return ChatBubble(
          message: message,
          showTimestamp: _shouldShowTimestamp(index, messages),
        );
      },
    );
  }

  bool _shouldShowTimestamp(int index, List<ChatMessage> messages) {
    if (index == 0) return true;

    final current = messages[index];
    final previous = messages[index - 1];

    // Show timestamp if more than 5 minutes between messages
    return current.timestamp.difference(previous.timestamp).inMinutes > 5;
  }

  Widget _buildInputArea() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Voice input button
          VoiceInputButton(
            onResult: _onVoiceResult,
            onListeningChanged: (listening) {
              setState(() {
                _isListening = listening;
                if (!listening) {
                  _liveTranscription = '';
                }
              });
            },
            onError: (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error)),
              );
            },
          ),
          const SizedBox(width: 12),

          // Text input
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _textFocusNode,
              maxLines: 4,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onSubmitted: (text) => _sendMessage(text),
            ),
          ),
          const SizedBox(width: 12),

          // Send button
          IconButton.filled(
            onPressed: _isSending
                ? null
                : () => _sendMessage(_textController.text),
            icon: _isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  Future<void> _showExitConfirmation() async {
    final hasProgress = _conversation?.onboardingData != null &&
        (_conversation!.onboardingData!.identity != null ||
            _conversation!.onboardingData!.habitName != null);

    if (!hasProgress) {
      context.go('/');
      return;
    }

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Onboarding?'),
        content: const Text(
          'Your progress will be saved. You can continue later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (shouldExit == true && mounted) {
      await _chatService.saveCurrentConversation();
      context.go('/');
    }
  }
}
