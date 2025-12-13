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
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();

  // Local state
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;
  onboarding.OnboardingData? _extractedData;
  
  // User name (collected first)
  String? _userName;
  bool _awaitingName = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeConversation();
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  /// Initialize the conversation with a greeting
  void _initializeConversation() {
    final orchestrator = context.read<OnboardingOrchestrator>();
    
    // Check if AI is available
    if (!orchestrator.isAiAvailable) {
      // No AI - go directly to manual form
      _goToManualForm();
      return;
    }
    
    // Add initial greeting
    setState(() {
      _messages = [
        ChatMessage.assistant(
          content: "Hi! I'm your Atomic Habits coach. I'll help you build a habit that sticks.\n\nFirst, what's your name?",
          status: MessageStatus.complete,
        ),
      ];
    });
    
    _scrollToBottom();
  }

  /// Send a message to the AI
  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isLoading) return;

    // Check for frustration patterns (escape hatch)
    if (ConversationGuardrails.isFrustrated(text)) {
      _showEscapeHatchDialog();
      return;
    }

    // Add user message
    setState(() {
      _messages.add(ChatMessage.user(content: text));
      _isLoading = true;
      _errorMessage = null;
    });
    
    _inputController.clear();
    _scrollToBottom();

    try {
      // Handle name collection first
      if (_awaitingName) {
        await _handleNameCollection(text);
        return;
      }

      // Get orchestrator and send message
      final orchestrator = context.read<OnboardingOrchestrator>();
      final result = await orchestrator.sendConversationalMessage(
        userMessage: text,
        userName: _userName ?? 'Friend',
      );
      
      if (!mounted) return;
      
      // Handle the result
      if (result.shouldFallbackToManual) {
        _showEscapeHatchDialog();
        return;
      }
      
      if (result.error != null) {
        setState(() {
          _errorMessage = result.error;
          _isLoading = false;
        });
        _addErrorMessage(result.error!);
        return;
      }
      
      // Add AI response
      if (result.response != null) {
        setState(() {
          _messages.add(ChatMessage.assistant(
            content: result.displayText ?? result.response!.content,
            status: MessageStatus.complete,
          ));
          _isLoading = false;
        });
        
        // Check if we have complete habit data
        if (result.extractedData != null && result.extractedData!.hasRequiredFields) {
          setState(() {
            _extractedData = result.extractedData;
          });
          // Show confirmation dialog
          _showHabitConfirmationDialog(result.extractedData!);
        }
      }
      
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
        _isLoading = false;
      });
      _addErrorMessage(_errorMessage!);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _scrollToBottom();
      }
    }
  }

  /// Handle name collection (first step)
  Future<void> _handleNameCollection(String name) async {
    setState(() {
      _userName = name;
      _awaitingName = false;
    });

    // Add AI response about identity
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    setState(() {
      _messages.add(ChatMessage.assistant(
        content: "Great to meet you, $name! Now, let's talk about who you want to become.\n\n"
            "James Clear says: \"Every action is a vote for the type of person you want to become.\"\n\n"
            "Complete this sentence: \"I want to be the type of person who...\"",
        status: MessageStatus.complete,
      ));
      _isLoading = false;
    });
    
    _scrollToBottom();
  }

  /// Add an error message to the chat
  void _addErrorMessage(String error) {
    setState(() {
      _messages.add(ChatMessage.assistant(
        content: "I'm having trouble connecting. Would you like to try again, or switch to manual entry?\n\n"
            "Error: $error",
        status: MessageStatus.error,
      ));
    });
    _scrollToBottom();
  }

  /// Show escape hatch dialog (frustration detected or user request)
  void _showEscapeHatchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit_note, size: 24),
            SizedBox(width: 8),
            Text('Switch to Manual Entry?'),
          ],
        ),
        content: const Text(
          "No problem! You can fill in the form yourself. "
          "Your progress will be saved.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Chatting'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _goToManualForm();
            },
            child: const Text('Use Form'),
          ),
        ],
      ),
    );
  }

  /// Show habit confirmation dialog
  void _showHabitConfirmationDialog(onboarding.OnboardingData data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 24),
            SizedBox(width: 8),
            Text('Your Habit Plan'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildConfirmationRow('Identity', data.identity ?? 'Not set'),
              _buildConfirmationRow('Habit', data.name ?? 'Not set'),
              _buildConfirmationRow('2-Min Version', data.tinyVersion ?? 'Not set'),
              _buildConfirmationRow('Time', data.implementationTime ?? 'Not set'),
              _buildConfirmationRow('Location', data.implementationLocation ?? 'Not set'),
              if (data.environmentCue != null)
                _buildConfirmationRow('Cue', data.environmentCue!),
              if (data.temptationBundle != null)
                _buildConfirmationRow('Bundle', data.temptationBundle!),
              const SizedBox(height: 16),
              const Text(
                'Does this look right?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Add message asking for corrections
              setState(() {
                _messages.add(ChatMessage.assistant(
                  content: "No problem! What would you like to change?",
                  status: MessageStatus.complete,
                ));
                _extractedData = null;
              });
              _scrollToBottom();
            },
            child: const Text('Make Changes'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _saveAndComplete(data);
            },
            child: const Text('Looks Good!'),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
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

  /// Save habit and complete onboarding
  Future<void> _saveAndComplete(onboarding.OnboardingData data) async {
    final appState = context.read<AppState>();

    // Create user profile
    final profile = UserProfile(
      name: _userName ?? 'User',
      identity: data.identity ?? 'Someone who achieves their goals',
      createdAt: DateTime.now(),
    );

    // Create habit from extracted data
    final habit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: data.name ?? 'My Habit',
      identity: data.identity ?? profile.identity,
      tinyVersion: data.tinyVersion ?? 'Do it for 2 minutes',
      createdAt: DateTime.now(),
      implementationTime: data.implementationTime ?? '09:00',
      implementationLocation: data.implementationLocation ?? 'At home',
      temptationBundle: data.temptationBundle,
      preHabitRitual: data.preHabitRitual,
      environmentCue: data.environmentCue,
      environmentDistraction: data.environmentDistraction,
      // AI metadata fields
      isBreakHabit: data.habitType == onboarding.HabitType.breakHabit,
      replacesHabit: data.replacesHabit,
      rootCause: data.rootCause,
      substitutionPlan: data.substitutionPlan,
      habitEmoji: data.habitEmoji ?? '✨',
      motivation: data.motivation,
      recoveryPlan: data.recoveryPlan,
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

  /// Go to manual form
  void _goToManualForm() {
    context.go('/onboarding/manual');
  }

  /// Scroll to bottom of chat
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Coach'),
        centerTitle: true,
        actions: [
          // Manual mode button (escape hatch)
          TextButton.icon(
            onPressed: _showEscapeHatchDialog,
            icon: const Icon(Icons.edit_note, size: 18),
            label: const Text('Manual'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                // Loading indicator at the end
                if (index == _messages.length) {
                  return const TypingIndicatorBubble();
                }
                
                final message = _messages[index];
                return ChatMessageBubble(
                  message: message,
                  showAvatar: true,
                );
              },
            ),
          ),
          
          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  // Text input
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      focusNode: _inputFocusNode,
                      decoration: InputDecoration(
                        hintText: _awaitingName 
                            ? 'Enter your name...' 
                            : 'Type your message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      enabled: !_isLoading,
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Send button
                  IconButton.filled(
                    onPressed: _isLoading ? null : _sendMessage,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
