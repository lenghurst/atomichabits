import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/app_state.dart';
import '../../data/models/chat_message.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/habit.dart';
import '../../data/models/onboarding_data.dart' as onboarding;
import '../../data/services/onboarding/onboarding_orchestrator.dart';
import '../../data/services/onboarding/conversation_guardrails.dart';
import '../../data/services/experimentation_service.dart';
import 'widgets/chat_message_bubble.dart';
import '../dev/dev_tools_overlay.dart';

/// Conversational onboarding screen - Phase 2 Chat UI
/// 
/// Implements the "Conversational First" experience using Gemini/Claude.
/// Users chat with an AI coach to create their first habit.
/// Falls back to manual form on frustration, timeout, or user request.
/// 
/// Uses OnboardingOrchestrator as the "brain" - this screen is just the UI.
class ConversationalOnboardingScreen extends StatefulWidget {
  final bool isOnboarding;

  const ConversationalOnboardingScreen({
    super.key,
    this.isOnboarding = true,
  });

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

  // Experiment Context
  String _hookVariant = 'A'; // Default to Friend

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeExperiment();
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

  /// Initialize experiment bucket
  Future<void> _initializeExperiment() async {
    final prefs = await SharedPreferences.getInstance();
    final experimentService = ExperimentationService.production(prefs);
    
    // Use a temporary ID if user not logged in yet, or device ID
    // For now, we'll use a random session ID if auth is missing
    final userId = 'temp_user_${DateTime.now().millisecondsSinceEpoch}'; 
    
    setState(() {
      _hookVariant = experimentService.getVariant(Experiment.theHook, userId);
    });
  }

  /// Initialize the conversation with a greeting based on the variant
  void _initializeConversation() {
    final orchestrator = context.read<OnboardingOrchestrator>();
    
    // Check if AI is available
    if (!orchestrator.isAiAvailable) {
      // No AI - go directly to manual form
      _goToManualForm();
      return;
    }
    
    String greeting;
    switch (_hookVariant) {
      case 'B': // Sergeant
        greeting = "Listen up. I'm your Pact coach. We're building a habit that sticks. No excuses.\n\nFirst, state your name.";
        break;
      case 'C': // Visionary
        greeting = "Welcome to the first day of your new life. I'm here to help you build a legacy.\n\nTo begin our journey, what is your name?";
        break;
      case 'A': // Friend (Default)
      default:
        greeting = "Hi! I'm your Pact coach. I'll help you build a habit that sticks.\n\nFirst, what's your name?";
    }

    // Add initial greeting
    setState(() {
      _messages = [
        ChatMessage.assistant(
          content: greeting,
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
      
      // Phase 27.18: Hook variant tone is now handled by the orchestrator
      // The UI just passes the variant ID, orchestrator handles prompt engineering
      orchestrator.setHookVariant(_hookVariant);
      
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
    
    String identityPrompt;
    switch (_hookVariant) {
      case 'B': // Sergeant
        identityPrompt = "Copy that, $name. Now, identify the target. Who do you want to become? Answer me: \"I want to be the type of person who...\"";
        break;
      case 'C': // Visionary
        identityPrompt = "A strong name, $name. Now, envision your future self. James Clear says every action is a vote for who you want to become. Cast your vote: \"I want to be the type of person who...\"";
        break;
      case 'A': // Friend
      default:
        identityPrompt = "Great to meet you, $name! Now, let's talk about who you want to become.\n\nJames Clear says: \"Every action is a vote for the type of person you want to become.\"\n\nComplete this sentence: \"I want to be the type of person who...\"";
    }

    setState(() {
      _messages.add(ChatMessage.assistant(
        content: identityPrompt,
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
        content: "I'm having trouble connecting. Would you like to try again, or switch to manual entry?\n\nError: $error",
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
    try {
      // 1. Convert OnboardingData to Habit
      // Phase 27.3: Fixed field names (tinyVersion, implementationTime, implementationLocation)
      final habit = Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: data.name ?? 'New Habit',
        identity: data.identity ?? 'New Identity',
        tinyVersion: data.tinyVersion ?? 'Start small',
        implementationTime: data.implementationTime ?? '09:00',
        implementationLocation: data.implementationLocation ?? 'At home',
        environmentCue: data.environmentCue,
        temptationBundle: data.temptationBundle,
        createdAt: DateTime.now(),
      );

      // 2. Save to AppState
      // Phase 27.3: Fixed method name (addHabit -> createHabit)
      final appState = context.read<AppState>();
      await appState.createHabit(habit);
      
      // 3. Complete onboarding (only if in onboarding mode)
      if (widget.isOnboarding) {
        await appState.completeOnboarding();
      }
      
      if (!mounted) return;
      
      // 4. Navigate to home
      context.go('/dashboard');
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving habit: $e')),
      );
    }
  }

  /// Fallback to manual form
  void _goToManualForm() {
    context.go('/onboarding/manual');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: DevToolsGestureDetector(
          child: const Text('AI Coach'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => context.go('/settings'),
          ),
          TextButton(
            onPressed: _goToManualForm,
            child: const Text('Manual'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ChatMessageBubble(message: _messages[index]);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    focusNode: _inputFocusNode,
                    decoration: const InputDecoration(
                      hintText: 'Type your answer...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    enabled: !_isLoading,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
