import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/router/app_routes.dart';
import '../../config/ai_model_config.dart';
import '../../data/providers/psychometric_provider.dart';
import '../../data/services/voice_session_manager.dart';
import '../../data/enums/voice_session_mode.dart';
import '../dev/dev_tools_overlay.dart';

/// Sherlock Protocol Screen
@Deprecated('Use VoiceCoachScreen(mode: VoiceSessionMode.onboarding) instead')
class SherlockScreen extends StatefulWidget {
  const SherlockScreen({super.key});

  @override
  State<SherlockScreen> createState() => _SherlockScreenState();
}

class _SherlockScreenState extends State<SherlockScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  VoiceSessionManager? _sessionManager;
  VoiceState _voiceState = VoiceState.idle;
  final List<TranscriptMessage> _transcript = [];
  
  // ignore: unused_field
  String? _errorMessage;
  // ignore: unused_field
  double _audioLevel = 0.0;
  
  // VAD State (Visual Confidence)
  bool _isUserSpeaking = false;
  
  // ignore: unused_field
  bool _isConnected = false;
  // ignore: unused_field
  String _connectionStatus = 'Initialising...';
  
  // ignore: unused_field
  List<String> _debugLog = [];
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePulseAnimation();
    _initializeVoiceSession();
  }
  
  void _initializePulseAnimation() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    _sessionManager?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      if (_sessionManager?.isActive == true) {
        _sessionManager?.pauseSession();
      }
    }
  }
  
  Future<void> _initializeVoiceSession() async {
    setState(() => _voiceState = VoiceState.connecting);
    
    // Phase 42: We explicitly use .onboarding() factory here if we wanted strictly Sherlock,
    // but the current implementation uses the manual system prompt for specific control.
    // We will stick to the manual prompt logic but ensure VAD is wired.
    
    const systemInstruction = '''You are Sherlock, an investigative journalist for the user's soul.
Your Goal: Uncover the TRUTH about why they fail, so they can finally succeed.

You need to extract 3 specific things (The Holy Trinity):
1. Their "Anti-Identity": The person they fear becoming if they don't change. (e.g. "The Sleepwalker", "The Grey Man").
2. Their "Failure Archetype": Why they quit in the past. (Perfectionist, Novelty Seeker, Obliger, Rebel).
3. Their "Resistance Lie": The specific lie they tell themselves to skip a habit (e.g. "I'll do double tomorrow").

PROTOCOL:
- Be curious, slightly provocative, but deeply empathetic.
- Don't accept surface answers. Dig deeper. "Why?" is your best weapon.
- When they give you a gold nugget (Truth), confirm it and SAVE IT using the `update_user_psychometrics` tool IMMEDIATELY.

Keep responses SHORT (1-2 sentences). You are on a voice call.
Start by asking: "Tell me, who are you afraid of becoming?"''';
    
    _sessionManager = VoiceSessionManager(
      // We pass the provider to enable tool calls for psychometric updates
      psychometricProvider: context.read<PsychometricProvider>(),
      mode: VoiceSessionMode.onboarding, // Enables tools
      systemInstruction: systemInstruction,
      enableTranscription: true,
      onTranscription: _handleTranscription,
      onAudioReceived: null,
      onStateChanged: _handleStateChanged,
      onError: _handleError,
      onAudioLevelChanged: _handleAudioLevelChanged,
      onAISpeakingChanged: _handleAISpeakingChanged,
      onUserSpeakingChanged: _handleUserSpeakingChanged, // VAD Callback
      onTurnComplete: _handleTurnComplete,
      onDebugLogUpdated: _handleDebugLogUpdated,
    );
    
    final success = await _sessionManager!.startSession();
    
    if (!success) {
      setState(() {
        _voiceState = VoiceState.error;
        _errorMessage = 'Failed to connect to Sherlock';
        _isConnected = false;
        _connectionStatus = 'Connection failed';
      });
      _showFallbackDialog();
    } else {
      setState(() {
        _voiceState = VoiceState.idle;
        _isConnected = true;
        _connectionStatus = '✅ Connected to Sherlock (${AIModelConfig.tier2Model})';
      });
      _addSystemMessage('Sherlock is listening...');
    }
  }
  
  // --- Handlers ---

  void _handleTranscription(String text, bool isUser) {
    if (!mounted) return;
    setState(() {
      _transcript.add(TranscriptMessage(
        text: text,
        isUser: isUser,
        timestamp: DateTime.now(),
      ));
    });
  }
  
  void _handleStateChanged(VoiceSessionState state) {
    if (!mounted) return;
    setState(() {
      switch (state) {
        case VoiceSessionState.idle:
          _voiceState = VoiceState.idle;
          break;
        case VoiceSessionState.connecting:
          _voiceState = VoiceState.connecting;
          break;
        case VoiceSessionState.active:
          _voiceState = VoiceState.listening;
          _pulseController.repeat(reverse: true);
          break;
        case VoiceSessionState.paused:
          _voiceState = VoiceState.idle;
          _pulseController.stop();
          break;
        case VoiceSessionState.disconnecting:
          _voiceState = VoiceState.connecting;
          break;
        case VoiceSessionState.thinking:
          _voiceState = VoiceState.thinking;
          _pulseController.repeat(reverse: true);
          break;
        case VoiceSessionState.error:
          _voiceState = VoiceState.error;
          _pulseController.stop();
          break;
      }
    });
  }
  
  void _handleError(String error) {
    if (!mounted) return;
    setState(() {
      _errorMessage = error;
      _addSystemMessage('⚠️ Error: $error');
    });
    _showDetailedErrorDialog(error);
  }
  
  void _handleAudioLevelChanged(double level) {
    if (!mounted) return;
    setState(() => _audioLevel = level);
  }
  
  void _handleAISpeakingChanged(bool isSpeaking) {
    if (!mounted) return;
    setState(() {
      if (isSpeaking) {
        _voiceState = VoiceState.speaking;
      } else if (_sessionManager?.isActive == true) {
        _voiceState = VoiceState.listening;
      }
    });
  }
  
  /// VAD Handler: Updates UI when user starts/stops speaking
  void _handleUserSpeakingChanged(bool isSpeaking) {
    if (!mounted) return;
    setState(() => _isUserSpeaking = isSpeaking);
  }
  
  void _handleTurnComplete() {
    if (_sessionManager?.isActive == true) {
      if (!mounted) return;
      setState(() => _voiceState = VoiceState.listening);
    }
  }
  
  void _handleDebugLogUpdated(List<String> log) {
    if (mounted) setState(() => _debugLog = List.from(log));
  }
  
  void _addSystemMessage(String message) {
    if (!mounted) return;
    setState(() {
      _transcript.add(TranscriptMessage(
        text: message,
        isSystem: true,
        timestamp: DateTime.now(),
      ));
    });
  }
  
  Future<void> _handleMicrophoneTap() async {
    if (_voiceState == VoiceState.error) {
      await _initializeVoiceSession();
      return;
    }
    
    if (_sessionManager == null) return;
    
    if (_sessionManager!.isActive) {
      await _sessionManager!.pauseSession();
      _pulseController.stop();
      setState(() => _voiceState = VoiceState.idle);
    } else {
      if (_sessionManager!.state == VoiceSessionState.paused) {
        await _sessionManager!.resumeSession();
      } else {
        await _sessionManager!.startSession();
      }
      _pulseController.repeat(reverse: true);
      setState(() => _voiceState = VoiceState.listening);
    }
  }
  
  // --- UI Methods ---

  void _showDetailedErrorDialog(String error) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text('Debug Info'),
        content: SingleChildScrollView(
          child: Text(error, style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Dismiss')),
        ],
      ),
    );
  }
  
  void _showFallbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Voice Unavailable'),
        content: const Text('Connections to Sherlock are unstable. We can proceed with manual entry.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRoutes.manualOnboarding);
            },
            child: const Text('Manual Entry'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _onSessionComplete() async {
    await _sessionManager?.endSession();
    if (!mounted) return;
    
    final profile = context.read<PsychometricProvider>().profile;
    if (profile.antiIdentityLabel != null || profile.failureArchetype != null) {
      context.go(AppRoutes.pactReveal);
    } else {
      context.go(AppRoutes.dashboard);
    }
  }
  
  String _getStatusText() {
    if (_isUserSpeaking) return 'I HEAR YOU...';
    
    switch (_voiceState) {
      case VoiceState.idle: return 'TAP TO CONFESS';
      case VoiceState.connecting: return 'ESTABLISHING LINK...';
      case VoiceState.listening: return 'SHERLOCK IS LISTENING...';
      case VoiceState.thinking: return 'ANALYSING...';
      case VoiceState.speaking: return 'SHERLOCK SPEAKING...';
      case VoiceState.error: return 'CONNECTION LOST';
    }
  }

  Color _getButtonColor() {
    if (_isUserSpeaking) return Colors.tealAccent; // Visual feedback for VAD
    
    switch (_voiceState) {
      case VoiceState.idle: return Colors.grey.shade800;
      case VoiceState.connecting: return Colors.blueGrey;
      case VoiceState.listening: return Colors.redAccent;
      case VoiceState.thinking: return Colors.purpleAccent;
      case VoiceState.speaking: return Colors.cyanAccent;
      case VoiceState.error: return Colors.red;
    }
  }

  IconData _getButtonIcon() {
    if (_isUserSpeaking) return Icons.graphic_eq; // Visual feedback
    if (_voiceState == VoiceState.listening) return Icons.mic;
    if (_voiceState == VoiceState.speaking) return Icons.volume_up;
    return Icons.mic_none;
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('THE INTERROGATION'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _onSessionComplete,
            child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _transcript.length,
                  itemBuilder: (context, index) {
                    final message = _transcript[index];
                    return _TranscriptBubble(message: message, isDark: true);
                  },
                ),
              ),
              Container(
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black, colorScheme.primary.withOpacity(0.2)],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  border: Border(top: BorderSide(color: colorScheme.primary.withOpacity(0.3))),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _getStatusText(),
                        key: ValueKey(_getStatusText()),
                        style: const TextStyle(color: Colors.white70, letterSpacing: 2, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: _handleMicrophoneTap,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          // Pulse faster if user is speaking
                          double scale = _voiceState == VoiceState.listening ? _pulseAnimation.value : 1.0;
                          if (_isUserSpeaking) scale *= 1.1; 
                          
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getButtonColor(),
                                boxShadow: [
                                  BoxShadow(
                                    color: _getButtonColor().withOpacity(_isUserSpeaking ? 0.8 : 0.5),
                                    blurRadius: _isUserSpeaking ? 40 : 30,
                                    spreadRadius: _isUserSpeaking ? 5 : 2,
                                  ),
                                ],
                              ),
                              child: Icon(_getButtonIcon(), color: Colors.white, size: 36),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
          if (kDebugMode) const DevToolsOverlay(),
        ],
      ),
    );
  }
}

class _TranscriptBubble extends StatelessWidget {
  final TranscriptMessage message;
  final bool isDark;
  const _TranscriptBubble({required this.message, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    if (message.isSystem) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          message.text,
          textAlign: TextAlign.center,
          style: TextStyle(color: isDark ? Colors.white54 : Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
        ),
      );
    }
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUser ? (isDark ? Colors.white24 : Colors.blue.shade100) : (isDark ? Colors.grey.shade900 : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
          border: isDark ? Border.all(color: Colors.white10) : null,
        ),
        child: Text(message.text, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
      ),
    );
  }
}

class TranscriptMessage {
  final String text;
  final bool isUser;
  final bool isSystem;
  final DateTime timestamp;
  TranscriptMessage({required this.text, this.isUser = false, this.isSystem = false, required this.timestamp});
}

enum VoiceState {
  idle,
  connecting,
  listening,
  thinking,
  speaking,
  error,
}
