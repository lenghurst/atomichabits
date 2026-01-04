import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/services/ai/ai_service_manager.dart';

/// Comms FAB: AI Persona Selector with RAG
///
/// Phase 67: Dashboard Redesign
///
/// A floating action button that expands to show AI persona options.
/// Each persona has a distinct coaching style and uses RAG for context.
///
/// Personas:
/// - Sherlock: Pattern detection, analytical ("I've noticed...")
/// - Oracle: Future projection, prophetic ("The you from tomorrow...")
/// - Stoic: Philosophical, grounding ("Control what you can...")
class CommsFab extends StatefulWidget {
  final Function(String personaId, String prompt)? onPersonaSelected;
  final bool isExpanded;
  final VoidCallback? onToggle;

  const CommsFab({
    super.key,
    this.onPersonaSelected,
    this.isExpanded = false,
    this.onToggle,
  });

  @override
  State<CommsFab> createState() => _CommsFabState();
}

class _CommsFabState extends State<CommsFab> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    if (widget.isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CommsFab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Expanded persona options
        AnimatedBuilder(
          animation: _expandAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _expandAnimation.value,
              child: Transform.scale(
                scale: _expandAnimation.value,
                alignment: Alignment.bottomRight,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _PersonaOption(
                persona: _Persona.sherlock,
                onTap: () => _selectPersona(_Persona.sherlock),
              ),
              const SizedBox(height: 8),
              _PersonaOption(
                persona: _Persona.oracle,
                onTap: () => _selectPersona(_Persona.oracle),
              ),
              const SizedBox(height: 8),
              _PersonaOption(
                persona: _Persona.stoic,
                onTap: () => _selectPersona(_Persona.stoic),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),

        // Main FAB
        FloatingActionButton.extended(
          onPressed: widget.onToggle,
          icon: AnimatedRotation(
            turns: widget.isExpanded ? 0.125 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: const Icon(Icons.chat_bubble_outline),
          ),
          label: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              widget.isExpanded ? 'Close' : 'Comms',
              key: ValueKey(widget.isExpanded),
            ),
          ),
          backgroundColor: widget.isExpanded
              ? Theme.of(context).colorScheme.surfaceContainerHighest
              : Theme.of(context).colorScheme.primaryContainer,
        ),
      ],
    );
  }

  void _selectPersona(_Persona persona) {
    widget.onToggle?.call(); // Close the FAB

    // Generate a RAG-enhanced prompt for this persona
    final prompt = _getPersonaPrompt(persona);

    widget.onPersonaSelected?.call(persona.id, prompt);
  }

  String _getPersonaPrompt(_Persona persona) {
    switch (persona) {
      case _Persona.sherlock:
        return '''You are Sherlock, an analytical coach who detects patterns in the user's behavior.
Your style is observational and insightful. You notice things others miss.
Start with "I've noticed..." and reference specific patterns from their history.
Be precise and evidence-based. Never guess - only state what the data shows.''';

      case _Persona.oracle:
        return '''You are Oracle, a prophetic coach who projects the user's future based on current trajectories.
Your style is visionary and forward-looking. You help them see who they're becoming.
Start with "The you from tomorrow..." or "I see..." and paint a vivid picture.
Be hopeful but honest. Show both the path of consistency and the path of drift.''';

      case _Persona.stoic:
        return '''You are Stoic, a philosophical coach who grounds the user in what they can control.
Your style is calm, wise, and grounding. You quote ancient wisdom when relevant.
Start with "Control what you can..." or reference a Stoic principle.
Be practical and focused on the present moment. Reduce anxiety, increase agency.''';
    }
  }
}

/// Persona option button
class _PersonaOption extends StatelessWidget {
  final _Persona persona;
  final VoidCallback onTap;

  const _PersonaOption({
    required this.persona,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: persona.color.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Persona avatar
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: persona.color.withValues(alpha: 0.2),
                    child: Text(
                      persona.emoji,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Persona info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        persona.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: persona.color,
                        ),
                      ),
                      Text(
                        persona.tagline,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// AI Personas
enum _Persona {
  sherlock(
    id: 'sherlock',
    name: 'Sherlock',
    emoji: '🔍',
    tagline: 'Pattern detection',
    color: Colors.blue,
  ),
  oracle(
    id: 'oracle',
    name: 'Oracle',
    emoji: '🔮',
    tagline: 'Future projection',
    color: Colors.purple,
  ),
  stoic(
    id: 'stoic',
    name: 'Stoic',
    emoji: '🏛️',
    tagline: 'Philosophical grounding',
    color: Colors.teal,
  );

  const _Persona({
    required this.id,
    required this.name,
    required this.emoji,
    required this.tagline,
    required this.color,
  });

  final String id;
  final String name;
  final String emoji;
  final String tagline;
  final Color color;
}

/// Comms Chat Sheet
/// Shows chat interface after persona selection
class CommsChatSheet extends StatefulWidget {
  final String personaId;
  final String systemPrompt;

  const CommsChatSheet({
    super.key,
    required this.personaId,
    required this.systemPrompt,
  });

  @override
  State<CommsChatSheet> createState() => _CommsChatSheetState();
}

class _CommsChatSheetState extends State<CommsChatSheet> {
  final _controller = TextEditingController();
  final _messages = <_ChatMessage>[];
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      _getPersonaName(widget.personaId),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getPersonaEmoji(widget.personaId),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ],
                ),
              ),

              const Divider(height: 24),

              // Messages
              Expanded(
                child: _messages.isEmpty
                    ? _buildWelcome(context)
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          return _buildMessage(context, _messages[index]);
                        },
                      ),
              ),

              // Loading indicator
              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_getPersonaName(widget.personaId)} is thinking...',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

              // Input
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  border: Border(
                    top: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Ask ${_getPersonaName(widget.personaId)}...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _isLoading ? null : () => _sendMessage(_controller.text),
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcome(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _getPersonaEmoji(widget.personaId),
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),
          Text(
            _getWelcomeMessage(widget.personaId),
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(BuildContext context, _ChatMessage message) {
    final theme = Theme.of(context);
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isUser
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    final userMessage = text.trim();
    _controller.clear();

    setState(() {
      _messages.add(_ChatMessage(text: userMessage, isUser: true));
      _isLoading = true;
    });

    try {
      final aiManager = context.read<AIServiceManager>();

      // Use RAG-enhanced single turn
      final response = await aiManager.singleTurnWithRAG(
        prompt: userMessage,
        baseSystemPrompt: widget.systemPrompt,
        isPremiumUser: true, // TODO: Get from user provider
        maxMemories: 5,
      );

      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: response ?? 'I apologize, I cannot respond right now.',
            isUser: false,
          ));
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: 'Something went wrong. Please try again.',
            isUser: false,
          ));
          _isLoading = false;
        });
      }
    }
  }

  String _getPersonaName(String id) {
    switch (id) {
      case 'sherlock':
        return 'Sherlock';
      case 'oracle':
        return 'Oracle';
      case 'stoic':
        return 'Stoic';
      default:
        return 'Coach';
    }
  }

  String _getPersonaEmoji(String id) {
    switch (id) {
      case 'sherlock':
        return '🔍';
      case 'oracle':
        return '🔮';
      case 'stoic':
        return '🏛️';
      default:
        return '💬';
    }
  }

  String _getWelcomeMessage(String id) {
    switch (id) {
      case 'sherlock':
        return 'I observe patterns others miss.\nWhat would you like me to analyze?';
      case 'oracle':
        return 'I see the paths ahead.\nWhat future would you like to explore?';
      case 'stoic':
        return 'Focus on what you can control.\nWhat weighs on your mind?';
      default:
        return 'How can I help?';
    }
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  const _ChatMessage({
    required this.text,
    required this.isUser,
  });
}
