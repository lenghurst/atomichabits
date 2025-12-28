import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/router/app_routes.dart';
import '../../../data/models/chat_message.dart';
import '../../../data/providers/user_provider.dart';
import '../widgets/chat_message_bubble.dart';

/// Step 8: Goal Screening Screen within the v4 Master Journey.
/// 
/// Purpose:
/// - Text-based chat interface.
/// - Asks user for "Top 5 Goals for next 12 months".
/// - Tags responses with "suspected_lie" metadata if they seem vague or unrealistic (Mocked for now).
/// - Transitions to Oracle Coach (Step 9).
class GoalScreeningScreen extends StatefulWidget {
  const GoalScreeningScreen({super.key});

  @override
  State<GoalScreeningScreen> createState() => _GoalScreeningScreenState();
}

class _GoalScreeningScreenState extends State<GoalScreeningScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _interactionComplete = false;

  // Suggesions based on common identities
  final List<String> _suggestions = [
    "Run a marathon",
    "Launch my MVP",
    "Save \$10,000",
    "Loss 10kg",
    "Read 20 books",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeChat());
  }

  void _initializeChat() {
    String identity = context.read<UserProvider>().identity;
    if (identity.isEmpty) identity = "High Performer";
    
    setState(() {
      _messages.add(ChatMessage.assistant(
        content: "You said you want to be a **$identity**. To become that, we need a roadmap.\n\nList your top 5 goals for the next 12 months.",
        status: MessageStatus.complete,
      ));
    });
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    
    _inputController.clear();
    setState(() {
      _isLoading = true;
      
      // Phase 17: "Suspected Lie" Logic (Mocked)
      // Real implementation would rely on backend analysis flag.
      // Here we simulate it: Short answers are "suspected lies" (low effort).
      final bool isSuspectedLie = text.length < 15;
      
      _messages.add(ChatMessage.user(
        content: text,
        metadata: isSuspectedLie ? {
            'suspected_lie': true, 
            'confidence': 0.88,
            'reasoning': 'Input lacks specific detail required for high-stakes commitment.'
        } : null,
      ));
    });
    
    _scrollToBottom();

    // Simulate AI Processing & Transition
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _interactionComplete = true; // Hide input
          
          _messages.add(ChatMessage.assistant(
            content: "I've analyzed your goals. Now, I need to understand the gap between where you are and where you want to be. Let's speak.",
            status: MessageStatus.complete,
          ));
        });
        _scrollToBottom();
        
        // Auto-advance to Oracle Coach (Step 9) after reading time
        Future.delayed(const Duration(seconds: 3), () {
           if (mounted) context.go(AppRoutes.oracle);
        });
      }
    });
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
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Slate 900
      appBar: AppBar(
        title: const Text('Goal Screening'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
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
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent, 
                color: Color(0xFF22C55E),
              ),
            ),
            
          // Suggestion Chips
          if (!_interactionComplete && !_isLoading)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: _suggestions.map((suggestion) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ActionChip(
                      label: Text(suggestion),
                      backgroundColor: const Color(0xFF1E293B),
                      labelStyle: const TextStyle(color: Colors.white70),
                      side: BorderSide.none,
                      onPressed: () {
                         _inputController.text = suggestion;
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

          // Input Area
          if (!_interactionComplete)
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B), // Slate 800
                border: Border(top: BorderSide(color: Color(0xFF334155))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Type your goals...',
                        hintStyle: TextStyle(color: Colors.white30),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                      enabled: !_isLoading,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isLoading ? null : _sendMessage,
                    icon: const Icon(Icons.send_rounded, color: Color(0xFF22C55E)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
