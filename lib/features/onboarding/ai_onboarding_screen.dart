import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/app_state.dart';
import '../../data/ai_onboarding_service.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/habit.dart';

/// AI Onboarding Screen - Discovery Call Experience
///
/// A conversational interface that guides users through habit setup
/// using Atomic Habits principles, parsing responses to auto-fill
/// the required onboarding fields.
class AiOnboardingScreen extends StatefulWidget {
  const AiOnboardingScreen({super.key});

  @override
  State<AiOnboardingScreen> createState() => _AiOnboardingScreenState();
}

class _AiOnboardingScreenState extends State<AiOnboardingScreen> {
  final AiOnboardingService _onboardingService = AiOnboardingService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _showCompletionButton = false;

  @override
  void initState() {
    super.initState();
    _startConversation();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _startConversation() {
    final initialMessage = _onboardingService.getInitialMessage();
    setState(() {
      _messages.add(ChatMessage(
        text: initialMessage,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    // Add user message
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Get AI response
    try {
      final response = await _onboardingService.sendMessage(text);

      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
        _showCompletionButton = _onboardingService.isComplete;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: "I apologize, something went wrong. Could you try again?",
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
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

  Future<void> _completeOnboarding() async {
    final fields = _onboardingService.extractedFields;
    final appState = Provider.of<AppState>(context, listen: false);

    // Get name from conversation or use a default
    String userName = _onboardingService.parseNameFromConversation() ?? 'Friend';

    // Create user profile
    final profile = UserProfile(
      name: userName,
      identity: fields['identity'] ?? 'I am someone who shows up consistently',
      createdAt: DateTime.now(),
    );

    // Create habit with extracted fields
    final habit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: fields['habitName'] ?? 'Daily habit',
      identity: fields['identity'] ?? profile.identity,
      tinyVersion: fields['tinyVersion'] ?? 'Start with 2 minutes',
      createdAt: DateTime.now(),
      implementationTime: fields['implementationTime'] ?? '09:00',
      implementationLocation: fields['implementationLocation'] ?? 'At home',
      temptationBundle: fields['temptationBundle'],
      preHabitRitual: fields['preHabitRitual'],
      environmentCue: fields['environmentCue'],
      environmentDistraction: fields['environmentDistraction'],
    );

    // Save to state
    await appState.setUserProfile(profile);
    await appState.createHabit(habit);
    await appState.completeOnboarding();

    // Navigate to Today screen
    if (mounted) {
      context.go('/today');
    }
  }

  void _switchToManualOnboarding() {
    // Navigate to manual onboarding screen
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Discovery'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(),
        ),
        actions: [
          TextButton(
            onPressed: _switchToManualOnboarding,
            child: const Text('Manual Setup'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Expert badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.purple.shade50,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.purple.shade100,
                    child: Icon(Icons.psychology, size: 18, color: Colors.purple.shade700),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Atomic Habits Expert',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.purple.shade800,
                      ),
                    ),
                  ),
                  if (_onboardingService.isComplete)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Ready!',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Chat messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isLoading && index == _messages.length) {
                    return const _TypingIndicator();
                  }
                  return _ChatBubble(message: _messages[index]);
                },
              ),
            ),

            // Completion button (when ready)
            if (_showCompletionButton)
              Container(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _completeOnboarding,
                    icon: const Icon(Icons.rocket_launch),
                    label: const Text(
                      'Start Building Your Habit',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),

            // Input field
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    offset: const Offset(0, -2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _inputFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Type your response...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      maxLines: 3,
                      minLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: _isLoading ? Colors.grey : Colors.purple,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _isLoading ? null : _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showExitDialog() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Discovery Call?'),
        content: const Text(
          'Your progress will be lost. You can always come back and start a new conversation, or switch to manual setup.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continue Chat'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );

    if (shouldExit == true && mounted) {
      context.go('/');
    }
  }
}

/// Chat message model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

/// Chat bubble widget
class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.purple.shade100,
              child: Icon(Icons.psychology, size: 16, color: Colors.purple.shade700),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.purple.shade100 : Colors.grey.shade100,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 16),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 15,
                  color: message.isUser ? Colors.purple.shade900 : Colors.grey.shade800,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.purple.shade200,
              child: const Icon(Icons.person, size: 16, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}

/// Typing indicator widget
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.purple.shade100,
            child: Icon(Icons.psychology, size: 16, color: Colors.purple.shade700),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final delay = index * 0.2;
                    final value = (_controller.value + delay) % 1.0;
                    final opacity = (value < 0.5 ? value : 1.0 - value) * 2;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Opacity(
                        opacity: opacity.clamp(0.3, 1.0),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade500,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
