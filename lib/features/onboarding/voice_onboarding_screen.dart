import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:typed_data';
import '../../data/app_state.dart';
import '../../data/services/gemini_live_service.dart';
import '../../data/models/habit.dart';

/// Voice-First Onboarding Screen - MVP
/// 
/// Phase 27.5: Voice First Pivot
/// Simple voice interface for Tier 2 (Premium) users using Gemini Live API.
/// 
/// MVP Features:
/// - Tap to talk microphone button
/// - Visual status indicators (listening, thinking, speaking)
/// - Text display of conversation
/// - Fallback to manual entry
class VoiceOnboardingScreen extends StatefulWidget {
  const VoiceOnboardingScreen({super.key});

  @override
  State<VoiceOnboardingScreen> createState() => _VoiceOnboardingScreenState();
}

class _VoiceOnboardingScreenState extends State<VoiceOnboardingScreen> {
  GeminiLiveService? _liveService;
  VoiceState _voiceState = VoiceState.idle;
  final List<String> _transcript = [];
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _initializeVoiceService();
  }
  
  @override
  void dispose() {
    _liveService?.disconnect();
    super.dispose();
  }
  
  /// Initialize Gemini Live service with callbacks
  Future<void> _initializeVoiceService() async {
    setState(() => _voiceState = VoiceState.connecting);
    
    _liveService = GeminiLiveService(
      onTranscription: (text, isInput) {
        setState(() {
          final prefix = isInput ? '🎤 You: ' : '🤖 Coach: ';
          _transcript.add('$prefix$text');
        });
      },
      onModelSpeakingChanged: (isSpeaking) {
        setState(() {
          _voiceState = isSpeaking ? VoiceState.speaking : VoiceState.idle;
        });
      },
      onConnectionStateChanged: (state) {
        setState(() {
          switch (state) {
            case LiveConnectionState.connecting:
              _voiceState = VoiceState.connecting;
              break;
            case LiveConnectionState.connected:
              _voiceState = VoiceState.idle;
              _addSystemMessage('Voice coach connected. Tap the microphone to start.');
              break;
            case LiveConnectionState.disconnected:
              _voiceState = VoiceState.error;
              _errorMessage = 'Connection lost';
              break;
          }
        });
      },
      onError: (error) {
        setState(() {
          _voiceState = VoiceState.error;
          _errorMessage = error;
          _addSystemMessage('⚠️ Error: $error');
        });
      },
      onFallbackToTextMode: () {
        _showFallbackDialog();
      },
      onTurnComplete: () {
        setState(() => _voiceState = VoiceState.idle);
      },
    );
    
    // Connect with onboarding system instruction
    final systemInstruction = '''You are The Pact's voice coach helping users create their first habit.

Your role:
1. Ask for their name
2. Ask about their identity: "I want to be the type of person who..."
3. Help them design a tiny habit using James Clear's principles
4. Extract: habit name, frequency, time, location, trigger

Keep responses SHORT (1-2 sentences). This is voice, not text.
Be warm, encouraging, and conversational.''';
    
    final connected = await _liveService!.connect(
      systemInstruction: systemInstruction,
      enableTranscription: true,
    );
    
    if (!connected) {
      setState(() {
        _voiceState = VoiceState.error;
        _errorMessage = 'Failed to connect to voice service';
      });
      _showFallbackDialog();
    }
  }
  
  /// Add system message to transcript
  void _addSystemMessage(String message) {
    setState(() {
      _transcript.add('ℹ️ $message');
    });
  }
  
  /// Handle microphone button tap
  void _handleMicrophoneTap() {
    if (_voiceState == VoiceState.listening) {
      // Stop listening
      // TODO: Implement stop recording
      setState(() => _voiceState = VoiceState.thinking);
    } else if (_voiceState == VoiceState.idle) {
      // Start listening
      // TODO: Implement start recording
      setState(() => _voiceState = VoiceState.listening);
    }
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
              context.go('/'); // Text chat
            },
            child: const Text('Text Chat'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/onboarding/manual'); // Manual form
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
        title: const Text('Voice Coach'),
        actions: [
          TextButton(
            onPressed: () => context.go('/onboarding/manual'),
            child: const Text('Manual'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Banner
          if (_voiceState == VoiceState.connecting)
            Container(
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
            ),
          
          if (_voiceState == VoiceState.error && _errorMessage != null)
            Container(
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
                    ),
                  ),
                ],
              ),
            ),
          
          // Transcript
          Expanded(
            child: _transcript.isEmpty
                ? Center(
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
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _transcript.length,
                    itemBuilder: (context, index) {
                      final message = _transcript[index];
                      final isUser = message.startsWith('🎤');
                      final isSystem = message.startsWith('ℹ️');
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Align(
                          alignment: isUser 
                              ? Alignment.centerRight 
                              : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSystem
                                  ? colorScheme.surfaceContainerHighest
                                  : isUser
                                      ? colorScheme.primaryContainer
                                      : colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              message,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isSystem
                                    ? colorScheme.onSurfaceVariant
                                    : isUser
                                        ? colorScheme.onPrimaryContainer
                                        : colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          // Voice Control Panel
          Container(
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
                // Status Text
                Text(
                  _getStatusText(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Microphone Button
                GestureDetector(
                  onTap: _voiceState == VoiceState.idle || 
                         _voiceState == VoiceState.listening
                      ? _handleMicrophoneTap
                      : null,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _getStatusText() {
    switch (_voiceState) {
      case VoiceState.idle:
        return 'Tap to speak';
      case VoiceState.listening:
        return 'Listening...';
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
        return Icons.stop;
      case VoiceState.thinking:
      case VoiceState.speaking:
        return Icons.graphic_eq;
      default:
        return Icons.mic;
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

/// Connection states from GeminiLiveService
enum LiveConnectionState {
  connecting,
  connected,
  disconnected,
}
