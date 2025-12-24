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
    with SingleTickerProviderStateMixin {
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
    _pulseController.dispose();
    _sessionManager?.dispose();
    super.dispose();
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
      appBar: AppBar(
        title: DevToolsGestureDetector(
          child: const Text('Voice Coach'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => context.go('/settings'),
          ),
          TextButton(
            onPressed: () => context.go('/onboarding/manual'),
            child: const Text('Manual'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Banner
          _buildStatusBanner(theme, colorScheme),
          
          // Transcript
          Expanded(
            child: _transcript.isEmpty
                ? _buildEmptyState(theme, colorScheme)
                : _buildTranscriptList(theme, colorScheme),
          ),
          
          // Voice Control Panel
          _buildVoiceControlPanel(theme, colorScheme),
        ],
      ),
    );
  }
  
  Widget _buildStatusBanner(ThemeData theme, ColorScheme colorScheme) {
    if (_voiceState == VoiceState.connecting) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        color: colorScheme.primaryContainer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Connecting to voice coach...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      );
    }
    
    if (_voiceState == VoiceState.error && _errorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        color: colorScheme.errorContainer,
        child: Row(
          children: [
            Icon(Icons.error, color: colorScheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onErrorContainer,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
  
  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mic,
            size: 64,
            color: colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Tap the microphone to start',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTranscriptList(ThemeData theme, ColorScheme colorScheme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _transcript.length,
      itemBuilder: (context, index) {
        final message = _transcript[index];
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Align(
            alignment: message.isUser
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: message.isSystem
                    ? colorScheme.surfaceContainerHighest
                    : message.isUser
                        ? colorScheme.primaryContainer
                        : colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!message.isSystem)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        message.isUser ? '🎤 You' : '🤖 Coach',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: message.isUser
                              ? colorScheme.onPrimaryContainer.withOpacity(0.7)
                              : colorScheme.onSecondaryContainer.withOpacity(0.7),
                        ),
                      ),
                    ),
                  Text(
                    message.isSystem ? 'ℹ️ ${message.text}' : message.text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: message.isSystem
                          ? colorScheme.onSurfaceVariant
                          : message.isUser
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildVoiceControlPanel(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Audio Level Indicator
          if (_voiceState == VoiceState.listening)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildAudioLevelIndicator(colorScheme),
            ),
          
          // Status Text
          Text(
            _getStatusText(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          
          // Microphone Button with pulse animation
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _voiceState == VoiceState.listening
                    ? _pulseAnimation.value
                    : 1.0,
                child: child,
              );
            },
            child: GestureDetector(
              onTap: _handleMicrophoneTap,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getMicrophoneColor(colorScheme),
                  boxShadow: _voiceState == VoiceState.listening
                      ? [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  _getMicrophoneIcon(),
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAudioLevelIndicator(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(10, (index) {
        final threshold = index / 10;
        final isActive = _audioLevel > threshold;
        return Container(
          width: 6,
          height: 20 + (index * 2),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isActive
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
  
  String _getStatusText() {
    switch (_voiceState) {
      case VoiceState.idle:
        return 'Tap to speak';
      case VoiceState.listening:
        return 'Listening... (tap to pause)';
      case VoiceState.thinking:
        return 'Processing...';
      case VoiceState.speaking:
        return 'Coach is speaking...';
      case VoiceState.connecting:
        return 'Connecting...';
      case VoiceState.error:
        return 'Error - tap to retry';
    }
  }
  
  IconData _getMicrophoneIcon() {
    switch (_voiceState) {
      case VoiceState.listening:
        return Icons.mic;
      case VoiceState.thinking:
      case VoiceState.speaking:
        return Icons.graphic_eq;
      case VoiceState.error:
        return Icons.refresh;
      default:
        return Icons.mic_none;
    }
  }
  
  Color _getMicrophoneColor(ColorScheme colorScheme) {
    switch (_voiceState) {
      case VoiceState.listening:
        return Colors.red;
      case VoiceState.thinking:
      case VoiceState.speaking:
        return colorScheme.tertiary;
      case VoiceState.error:
        return colorScheme.error;
      default:
        return colorScheme.primary;
    }
  }
}

/// Voice interaction states
enum VoiceState {
  idle,
  listening,
  thinking,
  speaking,
  connecting,
  error,
}

/// Transcript message model
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
