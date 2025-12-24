import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'dart:typed_data';
import '../../data/services/voice_session_manager.dart';
import '../dev/dev_tools_overlay.dart';

/// Voice-First Onboarding Screen
/// 
/// Phase 32: FEAT-01 - Audio Recording Integration
/// 
/// Full voice interface for Tier 2 (Premium) users using:
/// - VoiceSessionManager: Orchestrates audio + AI
/// - AudioRecordingService: Real-time microphone streaming
/// - GeminiLiveService: AI communication
/// 
/// Features:
/// - Push-to-talk microphone button
/// - Real-time audio level visualisation
/// - Visual status indicators (listening, thinking, speaking)
/// - Live transcription display
/// - Graceful fallback to manual entry
class VoiceOnboardingScreen extends StatefulWidget {
  const VoiceOnboardingScreen({super.key});

  @override
  State<VoiceOnboardingScreen> createState() => _VoiceOnboardingScreenState();
}

class _VoiceOnboardingScreenState extends State<VoiceOnboardingScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  VoiceSessionManager? _sessionManager;
  VoiceState _voiceState = VoiceState.idle;
  final List<TranscriptMessage> _transcript = [];
  String? _errorMessage;
  double _audioLevel = 0.0;
  
  // Animation for microphone pulse
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    // Security Fix: Observe app lifecycle to prevent hot mic in background
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
    // Security Fix: Remove observer
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    _sessionManager?.dispose();
    super.dispose();
  }

  /// Security Fix: Handle app backgrounding to prevent hot mic
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      if (_sessionManager?.isActive == true) {
        if (kDebugMode) {
          debugPrint('VoiceOnboardingScreen: App backgrounded, pausing session for security.');
        }
        _sessionManager?.pauseSession();
        // UI updates will happen via the state listener callback
      }
    }
  }
  
  /// Initialize the voice session manager
  Future<void> _initializeVoiceSession() async {
    setState(() => _voiceState = VoiceState.connecting);
    
    // System instruction for onboarding coach
    const systemInstruction = '''You are The Pact's voice coach helping users create their first habit.

Your role:
1. Greet them warmly and ask for their name
2. Ask about their identity: "I want to be the type of person who..."
3. Help them design a tiny habit using James Clear's principles
4. Extract: habit name, frequency, time, location, trigger

Keep responses SHORT (1-2 sentences). This is voice, not text.
Be warm, encouraging, and conversational.
Use British English spelling and phrasing.''';
    
    _sessionManager = VoiceSessionManager(
      systemInstruction: systemInstruction,
      enableTranscription: true,
      onTranscription: _handleTranscription,
      onAudioReceived: _handleAudioReceived,
      onStateChanged: _handleStateChanged,
      onError: _handleError,
      onAudioLevelChanged: _handleAudioLevelChanged,
      onAISpeakingChanged: _handleAISpeakingChanged,
      onUserSpeakingChanged: _handleUserSpeakingChanged,
      onTurnComplete: _handleTurnComplete,
    );
    
    // Start the session
    final success = await _sessionManager!.startSession();
    
    if (!success) {
      setState(() {
        _voiceState = VoiceState.error;
        _errorMessage = 'Failed to start voice session';
      });
      _showFallbackDialog();
    } else {
      setState(() => _voiceState = VoiceState.idle);
      _addSystemMessage('Voice coach connected. Start speaking to begin.');
    }
  }
  
  /// Handle transcription from user or AI
  void _handleTranscription(String text, bool isUser) {
    setState(() {
      _transcript.add(TranscriptMessage(
        text: text,
        isUser: isUser,
        timestamp: DateTime.now(),
      ));
    });
  }
  
  /// Handle audio received from AI (for future audio playback)
  void _handleAudioReceived(Uint8List audioData) {
    // TODO: Implement audio playback
    // For now, audio is handled by the device's default audio output
  }
  
  /// Handle session state changes
  void _handleStateChanged(VoiceSessionState state) {
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
        case VoiceSessionState.error:
          _voiceState = VoiceState.error;
          _pulseController.stop();
          break;
      }
    });
  }
  
  /// Handle errors
  void _handleError(String error) {
    setState(() {
      _errorMessage = error;
      _addSystemMessage('⚠️ Error: $error');
    });
    _showDetailedErrorDialog(error);
  }
  
  /// Handle audio level changes for visualisation
  void _handleAudioLevelChanged(double level) {
    setState(() {
      _audioLevel = level;
    });
  }
  
  /// Handle AI speaking state changes
  void _handleAISpeakingChanged(bool isSpeaking) {
    setState(() {
      if (isSpeaking) {
        _voiceState = VoiceState.speaking;
      } else if (_sessionManager?.isActive == true) {
        _voiceState = VoiceState.listening;
      }
    });
  }
  
  /// Handle user speaking state changes
  void _handleUserSpeakingChanged(bool isSpeaking) {
    // Could add visual feedback here
  }
  
  /// Handle AI turn completion
  void _handleTurnComplete() {
    if (_sessionManager?.isActive == true) {
      setState(() => _voiceState = VoiceState.listening);
    }
  }
  
  /// Add system message to transcript
  void _addSystemMessage(String message) {
    setState(() {
      _transcript.add(TranscriptMessage(
        text: message,
        isSystem: true,
        timestamp: DateTime.now(),
      ));
    });
  }
  
  /// Handle microphone button tap
  Future<void> _handleMicrophoneTap() async {
    if (_voiceState == VoiceState.error) {
      // Retry connection
      await _initializeVoiceSession();
      return;
    }
    
    if (_sessionManager == null) return;
    
    if (_sessionManager!.isActive) {
      // Pause the session (mute)
      await _sessionManager!.pauseSession();
      _pulseController.stop();
      setState(() => _voiceState = VoiceState.idle);
    } else {
      // Resume or start the session
      if (_sessionManager!.state == VoiceSessionState.paused) {
        await _sessionManager!.resumeSession();
      } else {
        await _sessionManager!.startSession();
      }
      _pulseController.repeat(reverse: true);
      setState(() => _voiceState = VoiceState.listening);
    }
  }
  
  /// Show detailed error dialog for debugging
  void _showDetailedErrorDialog(String error) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.bug_report, color: Colors.red),
            SizedBox(width: 8),
            Text('Debug Info'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Screenshot this for debugging:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  error,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: Colors.greenAccent,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Dismiss'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _showFallbackDialog();
            },
            child: const Text('Try Alternatives'),
          ),
        ],
      ),
    );
  }
  
  /// Show fallback dialog when voice fails
  void _showFallbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Voice Unavailable'),
          ],
        ),
        content: const Text(
          'The voice coach is having trouble connecting. '
          'Would you like to use text chat or manual entry instead?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/');
            },
            child: const Text('Text Chat'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/onboarding/manual');
            },
            child: const Text('Manual Entry'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Voice Coach'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.keyboard),
            onPressed: () => context.go('/onboarding/manual'),
            tooltip: 'Switch to Manual Entry',
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Transcript Area
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _transcript.length,
                  itemBuilder: (context, index) {
                    final message = _transcript[index];
                    return _TranscriptBubble(message: message);
                  },
                ),
              ),
              
              // Visualisation Area
              Container(
                height: 200,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Status Text
                    Text(
                      _getStatusText(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: _getStatusColor(colorScheme),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    
                    // Microphone Button
                    GestureDetector(
                      onTap: _handleMicrophoneTap,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _voiceState == VoiceState.listening 
                                ? _pulseAnimation.value 
                                : 1.0,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getButtonColor(colorScheme),
                                boxShadow: [
                                  BoxShadow(
                                    color: _getButtonColor(colorScheme).withOpacity(0.4),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _getButtonIcon(),
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ],
          ),
          
          // Dev Tools Overlay
          const DevToolsOverlay(),
        ],
      ),
    );
  }
  
  String _getStatusText() {
    switch (_voiceState) {
      case VoiceState.idle:
        return 'Tap to Speak';
      case VoiceState.connecting:
        return 'Connecting...';
      case VoiceState.listening:
        return 'Listening...';
      case VoiceState.thinking:
        return 'Thinking...';
      case VoiceState.speaking:
        return 'Speaking...';
      case VoiceState.error:
        return 'Connection Error';
    }
  }
  
  Color _getStatusColor(ColorScheme colorScheme) {
    switch (_voiceState) {
      case VoiceState.idle:
        return colorScheme.onSurfaceVariant;
      case VoiceState.connecting:
        return colorScheme.primary;
      case VoiceState.listening:
        return Colors.redAccent;
      case VoiceState.thinking:
        return Colors.amber;
      case VoiceState.speaking:
        return Colors.green;
      case VoiceState.error:
        return colorScheme.error;
    }
  }
  
  Color _getButtonColor(ColorScheme colorScheme) {
    switch (_voiceState) {
      case VoiceState.idle:
        return colorScheme.primary;
      case VoiceState.connecting:
        return colorScheme.surfaceContainerHighest;
      case VoiceState.listening:
        return Colors.redAccent;
      case VoiceState.thinking:
        return Colors.amber;
      case VoiceState.speaking:
        return Colors.green;
      case VoiceState.error:
        return colorScheme.error;
    }
  }
  
  IconData _getButtonIcon() {
    switch (_voiceState) {
      case VoiceState.idle:
        return Icons.mic_none;
      case VoiceState.connecting:
        return Icons.cloud_sync;
      case VoiceState.listening:
        return Icons.mic;
      case VoiceState.thinking:
        return Icons.psychology;
      case VoiceState.speaking:
        return Icons.volume_up;
      case VoiceState.error:
        return Icons.refresh;
    }
  }
}

enum VoiceState {
  idle,
  connecting,
  listening,
  thinking,
  speaking,
  error,
}

class TranscriptMessage {
  final String text;
  final bool isUser;
  final bool isSystem;
  final DateTime timestamp;
  
  TranscriptMessage({
    required this.text,
    this.isUser = false,
    this.isSystem = false,
    required this.timestamp,
  });
}

class _TranscriptBubble extends StatelessWidget {
  final TranscriptMessage message;
  
  const _TranscriptBubble({required this.message});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    if (message.isSystem) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Text(
            message.text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser 
              ? colorScheme.primaryContainer 
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: message.isUser ? const Radius.circular(4) : null,
            bottomLeft: !message.isUser ? const Radius.circular(4) : null,
          ),
        ),
        child: Text(
          message.text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: message.isUser 
                ? colorScheme.onPrimaryContainer 
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
