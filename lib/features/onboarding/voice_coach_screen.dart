import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/enums/voice_session_type.dart';
import '../../data/services/voice_session_manager.dart';
import '../../config/router/app_routes.dart';
import '../../data/providers/user_provider.dart';
import 'widgets/chat_message_bubble.dart';
import '../../data/services/ai/prompt_factory.dart';
import '../../data/models/voice_session_config.dart';

class VoiceCoachScreen extends StatefulWidget {
  final VoiceSessionConfig config;
  
  const VoiceCoachScreen({
    super.key, 
    this.config = VoiceSessionConfig.sherlock, // Default to Sherlock
  });

  @override
  State<VoiceCoachScreen> createState() => _VoiceCoachScreenState();
}

class _VoiceCoachScreenState extends State<VoiceCoachScreen> {
  final ScrollController _scrollController = ScrollController();
  late final VoiceSessionManager _voiceManager;
  
  // -- Gesture State --
  bool _isLocked = false;
  double _dragOffset = 0.0;
  Timer? _durationTimer;
  Duration _recordDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _voiceManager = context.read<VoiceSessionManager>();
    
    // Listen for completion
    _voiceManager.addListener(_onSessionUpdate);
    
    // Auto-scroll on new messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
       if (mounted) {
         _voiceManager.addListener(_scrollToBottom);

         // 1. Handle Context Reset (Oracle) - MUST BE FIRST
         if (widget.config.shouldResetContext) {
            _voiceManager.resetSession();
         }

         // 2. INJECT SYSTEM PROMPT (Track F) - Uses UserProvider (Strangler Fig)
         final userProvider = context.read<UserProvider>();
         final systemPrompt = PromptFactory.getSystemInstruction(
           type: widget.config.type,
           profile: userProvider.userProfile,
         );
         _voiceManager.setSystemPrompt(systemPrompt);
         
         // 3. Handle Initial Message / Greeting
         if (widget.config.greeting != null) {
           // Sherlock speaks first (Assistant Message)
           if (_voiceManager.messages.isEmpty) {
              _voiceManager.addSystemGreeting(widget.config.greeting!);
           }
         } else if (widget.config.initialMessage != null) {
           // Legacy / Scripted User Message
           _injectInitialMessage(widget.config.initialMessage!);
         }
       }
    });
  }

  void _injectInitialMessage(String message) {
    // Only inject if history is empty to avoid double-sending
    if (_voiceManager.messages.isNotEmpty) return;
    
    // FOR BACKWARD COMPATIBILITY with the test prompt:
    if (widget.config.type == VoiceSessionType.sherlock && message.contains("{Name}")) {
        final userProvider = context.read<UserProvider>();
        final name = userProvider.userProfile?.name ?? "I";
        final interpolated = message.replaceAll("{Name}", name);
        _voiceManager.sendText(interpolated);
    } else {
        _voiceManager.sendText(message);
    }
  }

  void _onSessionUpdate() {
    if (_voiceManager.isSessionComplete) {
      // ✅ SUCCESS: Navigate to result (Configurable)
      
      // CRITICAL FIX: If this is Oracle, we MUST complete onboarding in AppState
      // BEFORE navigating, otherwise the Router will bounce us back to Start.
      if (widget.config.type == VoiceSessionType.oracle) {
        context.read<AppState>().completeOnboarding();
      }

      // Wait a moment for the user to hear the approval or see the text
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
           context.go(widget.config.nextRoute);
        }
      });
    }
  }

  @override
  void dispose() {
    _voiceManager.removeListener(_onSessionUpdate);
    _durationTimer?.cancel();
    _scrollController.dispose();
    
    // ✅ PRIVACY & FIX: Clean up TTS audio safely avoiding race conditions
    Future.microtask(() async {
      try {
        await _voiceManager.cleanupSession();
      } catch (e) {
        if (kDebugMode) debugPrint('Session cleanup failed: $e');
      }
    });

    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
  }

  // --- Recording Logic ---

  void _startRecording(VoiceSessionManager session) {
    HapticFeedback.lightImpact();
    setState(() {
      _isLocked = false;
      _dragOffset = 0.0;
      _recordDuration = Duration.zero;
    });
    
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) setState(() => _recordDuration += const Duration(seconds: 1));
    });

    session.startRecording();
  }

  void _stopRecording(VoiceSessionManager session) {
    _durationTimer?.cancel();
    session.stopRecordingAndSend(); 
  }

  void _handleDragUpdate(LongPressMoveUpdateDetails details) {
    if (_isLocked) return;

    setState(() {
      _dragOffset = details.localOffsetFromOrigin.dy;
    });

    // Threshold: Drag up 80 pixels to lock
    if (_dragOffset < -80) { 
      HapticFeedback.heavyImpact(); 
      setState(() => _isLocked = true);
    }
  }

  void _handleCancel(VoiceSessionManager session) {
    HapticFeedback.mediumImpact();
    _durationTimer?.cancel();
    setState(() {
      _isLocked = false;
      _recordDuration = Duration.zero;
    });
  }

  void _handleSendLocked(VoiceSessionManager session) {
    HapticFeedback.selectionClick();
    setState(() => _isLocked = false);
    _stopRecording(session);
  }

  Widget build(BuildContext context) {
    final session = context.watch<VoiceSessionManager>();
    // Use config for theme
    final themeColor = widget.config.themeColor;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0B141A), // Deep Dark Background
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2C34),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: themeColor,
              child: Icon(widget.config.icon, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.config.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Text(widget.config.subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. Chat List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: session.messages.length + (session.isThinking ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= session.messages.length) {
                  return _buildThinkingIndicator(themeColor);
                }
                return ChatMessageBubble(message: session.messages[index]);
              },
            ),
          ),

          // 2. Input Zone
          _buildInputZone(session, themeColor),
        ],
      ),
    );
  }

  Widget _buildThinkingIndicator(Color themeColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 10, bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF1F2C34),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: themeColor)),
                const SizedBox(width: 12),
                Text("Analysing...", style: TextStyle(color: themeColor, fontSize: 13, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputZone(VoiceSessionManager session, Color themeColor) {
    final isRecording = session.isRecording;
    final durationStr = "${_recordDuration.inMinutes}:${(_recordDuration.inSeconds % 60).toString().padLeft(2, '0')}";

    return Container(
      color: const Color(0xFF1F2C34),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lock UI (Floating)
            if (isRecording && !_isLocked)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Transform.translate(
                  offset: Offset(0, _dragOffset),
                  child: Opacity(
                    opacity: (1.0 - (-_dragOffset / 80)).clamp(0.0, 1.0),
                    child: const Column(
                      children: [
                        Icon(Icons.lock_open, color: Colors.white54, size: 20),
                        SizedBox(height: 4),
                        Text("Swipe up to lock", style: TextStyle(color: Colors.white38, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ),

            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A3942),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: isRecording
                        ? Row( // Recording Active UI
                            children: [
                               const Icon(Icons.mic, color: Colors.redAccent, size: 20),
                               const SizedBox(width: 12),
                               Text(durationStr, style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'monospace')),
                               if (_isLocked) const Text(" (Locked)", style: TextStyle(color: Colors.white38, fontSize: 12)),
                               const Spacer(),
                               GestureDetector(
                                 onTap: () => _handleCancel(session),
                                 child: const Text("Cancel", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                               )
                            ],
                          )
                        : const Align( // Idle UI
                            alignment: Alignment.centerLeft,
                            child: Text("Hold mic to speak...", style: TextStyle(color: Colors.white38, fontSize: 16)),
                          ),
                  ),
                ),
                
                const SizedBox(width: 8),

                // THE BUTTON
                GestureDetector(
                  onLongPressStart: (_) => _isLocked ? null : _startRecording(session),
                  onLongPressEnd: (_) => _isLocked ? null : _stopRecording(session),
                  onLongPressMoveUpdate: _handleDragUpdate,
                  onTap: _isLocked ? () => _handleSendLocked(session) : null, // Tap to send if locked
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: isRecording ? 60 : 50,
                    width: isRecording ? 60 : 50,
                    decoration: BoxDecoration(
                      color: themeColor,
                      shape: BoxShape.circle,
                      boxShadow: isRecording 
                        ? [BoxShadow(color: themeColor.withOpacity(0.4), blurRadius: 12, spreadRadius: 4)]
                        : [],
                    ),
                    child: Icon(
                      _isLocked ? Icons.send : (isRecording ? Icons.mic : Icons.mic_none),
                      color: Colors.white,
                      size: isRecording ? 32 : 24,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
