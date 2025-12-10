import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../data/app_state.dart';
import '../../data/premium_ai_onboarding_service.dart';
import '../../data/api_config.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/habit.dart';

/// Premium AI Onboarding Screen - Voice-Enabled Discovery Call
///
/// A premium conversational experience featuring:
/// - Voice synthesis via ElevenLabs
/// - Claude-powered intelligent dialogue
/// - Visual conversation state indicator
/// - Active listening UI patterns
class PremiumAiOnboardingScreen extends StatefulWidget {
  const PremiumAiOnboardingScreen({super.key});

  @override
  State<PremiumAiOnboardingScreen> createState() => _PremiumAiOnboardingScreenState();
}

class _PremiumAiOnboardingScreenState extends State<PremiumAiOnboardingScreen>
    with TickerProviderStateMixin {
  final PremiumAiOnboardingService _service = PremiumAiOnboardingService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isPlayingAudio = false;
  bool _voiceEnabled = true;
  ConversationState _currentState = ConversationState.greeting;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    // Initialize service and start conversation
    _initializeService();
  }

  Future<void> _initializeService() async {
    // Get API keys from config
    final config = ApiConfig.instance;

    _service.initialize(
      claudeApiKey: config.claudeApiKey,
      elevenLabsApiKey: config.elevenLabsApiKey,
    );

    _service.onStateChange = (state) {
      setState(() => _currentState = state);
    };

    // Start the conversation
    await _startConversation();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    _audioPlayer.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _startConversation() async {
    setState(() => _isLoading = true);

    try {
      final response = await _service.startConversation();

      setState(() {
        _messages.add(ChatMessage(
          text: response.text,
          isUser: false,
          timestamp: DateTime.now(),
          audioData: response.audioData,
        ));
        _isLoading = false;
      });

      // Play audio greeting if available and voice is enabled
      if (_voiceEnabled && response.audioData != null) {
        await _playAudio(response.audioData!);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to start conversation');
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    // Stop any playing audio
    await _audioPlayer.stop();

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

    try {
      final response = await _service.sendMessage(text);

      setState(() {
        _messages.add(ChatMessage(
          text: response.text,
          isUser: false,
          timestamp: DateTime.now(),
          audioData: response.audioData,
        ));
        _isLoading = false;
      });

      _scrollToBottom();

      // Play audio response if available and voice is enabled
      if (_voiceEnabled && response.audioData != null) {
        await _playAudio(response.audioData!);
      }
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

  Future<void> _playAudio(Uint8List audioData) async {
    setState(() => _isPlayingAudio = true);

    try {
      await _audioPlayer.play(BytesSource(audioData));
      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() => _isPlayingAudio = false);
        }
      });
    } catch (e) {
      setState(() => _isPlayingAudio = false);
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _completeOnboarding() async {
    final fields = _service.extractedFields;
    final appState = Provider.of<AppState>(context, listen: false);

    // Create user profile
    final profile = UserProfile(
      name: fields['name'] ?? 'Friend',
      identity: fields['identity'] ?? 'I am someone who shows up consistently',
      createdAt: DateTime.now(),
    );

    // Create habit
    final habit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: fields['habitName'] ?? 'Daily habit',
      identity: fields['identity'] ?? profile.identity,
      tinyVersion: fields['tinyVersion'] ?? 'Start with 2 minutes',
      createdAt: DateTime.now(),
      implementationTime: fields['time'] ?? '09:00',
      implementationLocation: fields['location'] ?? 'At home',
      temptationBundle: fields['temptationBundle'],
      preHabitRitual: fields['preHabitRitual'],
      environmentCue: fields['environmentCue'],
      environmentDistraction: fields['environmentDistraction'],
    );

    await appState.setUserProfile(profile);
    await appState.createHabit(habit);
    await appState.completeOnboarding();

    if (mounted) {
      context.go('/today');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: () => _showExitDialog(),
        ),
        title: const Text(
          'Discovery Call',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          // Voice toggle
          IconButton(
            icon: Icon(
              _voiceEnabled ? Icons.volume_up : Icons.volume_off,
              color: _voiceEnabled ? Colors.purple : Colors.grey,
            ),
            onPressed: () {
              setState(() => _voiceEnabled = !_voiceEnabled);
              if (!_voiceEnabled) {
                _audioPlayer.stop();
              }
            },
            tooltip: _voiceEnabled ? 'Disable voice' : 'Enable voice',
          ),
          TextButton(
            onPressed: () => context.go('/onboarding/manual'),
            child: const Text('Manual'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Coach avatar and state indicator
            _CoachHeader(
              state: _currentState,
              isPlaying: _isPlayingAudio,
              pulseController: _pulseController,
              waveController: _waveController,
            ),

            // Progress indicator
            _ProgressIndicator(state: _currentState),

            // Chat messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isLoading && index == _messages.length) {
                    return _TypingIndicator(controller: _waveController);
                  }
                  return _PremiumChatBubble(
                    message: _messages[index],
                    onPlayAudio: _messages[index].audioData != null
                        ? () => _playAudio(_messages[index].audioData!)
                        : null,
                  );
                },
              ),
            ),

            // Completion button
            if (_service.isComplete)
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _completeOnboarding,
                    icon: const Icon(Icons.rocket_launch),
                    label: const Text(
                      'Start My Journey',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),

            // Input area
            _InputArea(
              controller: _messageController,
              focusNode: _inputFocusNode,
              isLoading: _isLoading,
              onSend: _sendMessage,
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
        title: const Text('Leave Discovery Call?'),
        content: const Text(
          'Your conversation progress will be lost. You can start a new discovery call anytime.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leave'),
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
  final Uint8List? audioData;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.audioData,
  });
}

/// Coach header with avatar and speaking animation
class _CoachHeader extends StatelessWidget {
  final ConversationState state;
  final bool isPlaying;
  final AnimationController pulseController;
  final AnimationController waveController;

  const _CoachHeader({
    required this.state,
    required this.isPlaying,
    required this.pulseController,
    required this.waveController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // Avatar with speaking animation
          Stack(
            alignment: Alignment.center,
            children: [
              // Pulse animation when speaking
              if (isPlaying)
                AnimatedBuilder(
                  animation: pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 80 + (pulseController.value * 20),
                      height: 80 + (pulseController.value * 20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.purple.withOpacity(0.2 - pulseController.value * 0.15),
                      ),
                    );
                  },
                ),
              // Avatar
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.purple.shade400,
                      Colors.purple.shade700,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.psychology,
                  size: 36,
                  color: Colors.white,
                ),
              ),
              // Speaking indicator
              if (isPlaying)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.volume_up,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Habit Coach',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            _getStateLabel(state),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  String _getStateLabel(ConversationState state) {
    switch (state) {
      case ConversationState.greeting:
        return 'Getting to know you';
      case ConversationState.identityExploration:
        return 'Exploring your identity';
      case ConversationState.habitDiscovery:
        return 'Discovering your habit';
      case ConversationState.tinyVersion:
        return 'Making it tiny';
      case ConversationState.implementation:
        return 'Setting up your plan';
      case ConversationState.enhancement:
        return 'Adding enhancements';
      case ConversationState.commitment:
        return 'Ready to start!';
    }
  }
}

/// Progress indicator showing conversation stages
class _ProgressIndicator extends StatelessWidget {
  final ConversationState state;

  const _ProgressIndicator({required this.state});

  @override
  Widget build(BuildContext context) {
    final stages = ConversationState.values;
    final currentIndex = stages.indexOf(state);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: List.generate(stages.length, (index) {
          final isCompleted = index < currentIndex;
          final isCurrent = index == currentIndex;

          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: isCompleted
                    ? Colors.green
                    : isCurrent
                        ? Colors.purple
                        : Colors.grey.shade300,
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Premium chat bubble with audio playback
class _PremiumChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onPlayAudio;

  const _PremiumChatBubble({
    required this.message,
    this.onPlayAudio,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.purple.shade600],
                ),
              ),
              child: const Icon(Icons.psychology, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.purple.shade100 : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(message.isUser ? 20 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 15,
                      color: message.isUser ? Colors.purple.shade900 : Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  if (!message.isUser && onPlayAudio != null) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: onPlayAudio,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_circle_outline,
                            size: 18,
                            color: Colors.purple.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Play',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.purple.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.purple.shade200,
              child: const Icon(Icons.person, size: 18, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}

/// Typing indicator with wave animation
class _TypingIndicator extends StatelessWidget {
  final AnimationController controller;

  const _TypingIndicator({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.purple.shade600],
              ),
            ),
            child: const Icon(Icons.psychology, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final delay = index * 0.2;
                    final value = (controller.value + delay) % 1.0;
                    final y = (value < 0.5 ? value : 1.0 - value) * 8;
                    return Transform.translate(
                      offset: Offset(0, -y),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.purple.shade300,
                          shape: BoxShape.circle,
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

/// Input area with styled text field
class _InputArea extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final VoidCallback onSend;

  const _InputArea({
    required this.controller,
    required this.focusNode,
    required this.isLoading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F6FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  hintText: 'Share your thoughts...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                maxLines: 3,
                minLines: 1,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isLoading
                    ? [Colors.grey, Colors.grey]
                    : [Colors.purple.shade400, Colors.purple.shade700],
              ),
              boxShadow: isLoading
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: isLoading ? null : onSend,
            ),
          ),
        ],
      ),
    );
  }
}
