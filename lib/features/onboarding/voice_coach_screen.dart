import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart'; // Added for context.read
import 'package:go_router/go_router.dart';
import '../../config/router/app_routes.dart';

import '../../data/services/voice_session_manager.dart';
import '../../data/providers/user_provider.dart'; // Added
import '../../data/providers/psychometric_provider.dart'; // Added
import '../../data/providers/settings_provider.dart'; // Added for Haptics
import '../../data/models/user_profile.dart'; // Added
import '../dev/dev_tools_overlay.dart';

import '../../data/enums/voice_session_mode.dart'; // Added

class VoiceCoachScreen extends StatefulWidget {
  final VoiceSessionMode mode;

  const VoiceCoachScreen({
    super.key,
    this.mode = VoiceSessionMode.coaching,
  });

  @override
  State<VoiceCoachScreen> createState() => _VoiceCoachScreenState();
}

class _VoiceCoachScreenState extends State<VoiceCoachScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  
  VoiceSessionManager? _sessionManager;
  VoiceState _voiceState = VoiceState.idle;
  
  // VAD State (Visual Confidence)
  bool _isUserSpeaking = false;
  
  double _audioLevel = 0.0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  bool _isConnected = false;

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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      if (_sessionManager?.isActive == true) {
        _sessionManager?.pauseSession();
      }
    }
  }

  Future<void> _initializeVoiceSession() async {
    setState(() => _voiceState = VoiceState.connecting);
    
    // Phase 46: Dependency Injection
    final userProvider = context.read<UserProvider>();
    final psychometricProvider = context.read<PsychometricProvider>();
    
    // Safety check for user profile
    final safeUser = userProvider.userProfile ?? 
        UserProfile(name: 'Guest', identity: 'Achiever', createdAt: DateTime.now(), isPremium: true);

    // Phase 42: unified session initialization
    if (widget.mode == VoiceSessionMode.coaching) {
      _sessionManager = VoiceSessionManager.coaching(
        psychometricProvider: psychometricProvider,
        userProfile: safeUser,
        psychometricProfile: psychometricProvider.profile,
        onStateChanged: _handleStateChanged,
        onAudioReceived: null, // Routed internally
        onError: _handleError,
        onAudioLevelChanged: (level) {
          if (mounted) setState(() => _audioLevel = level);
        },
        onAISpeakingChanged: _handleAISpeakingChanged,
        onUserSpeakingChanged: _handleUserSpeakingChanged,
        onTurnComplete: _handleTurnComplete,
      );
    } else {
      // Onboarding / Sherlock Mode
      _sessionManager = VoiceSessionManager.onboarding(
        psychometricProvider: psychometricProvider,
        userProfile: safeUser,
        onStateChanged: _handleStateChanged,
        onAudioReceived: null,
        onError: _handleError,
        onAudioLevelChanged: (level) {
          if (mounted) setState(() => _audioLevel = level);
        },
        onAISpeakingChanged: _handleAISpeakingChanged,
        onUserSpeakingChanged: _handleUserSpeakingChanged,
        onTurnComplete: _handleTurnComplete,
        // Phase 42: Tool calls are handled internally by the manager for onboarding
      );
    }

    try {
      await _sessionManager!.startSession();
       setState(() {
        _isConnected = true;
        _voiceState = VoiceState.idle; 
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnected = false;
          _voiceState = VoiceState.error;
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    _sessionManager?.dispose();
    super.dispose();
  }

  // --- Handlers ---

  void _handleStateChanged(VoiceSessionState state) {
    if (!mounted) return;
    setState(() {
      switch (state) {
        case VoiceSessionState.idle:
        case VoiceSessionState.paused:
          _voiceState = VoiceState.idle;
          _pulseController.stop();
          break;
        case VoiceSessionState.connecting:
        case VoiceSessionState.disconnecting:
          _voiceState = VoiceState.connecting;
          break;
        case VoiceSessionState.active:
          _voiceState = VoiceState.listening;
          _pulseController.repeat(reverse: true);
          break;
        case VoiceSessionState.thinking:
           _voiceState = VoiceState.thinking;
           _pulseController.repeat(reverse: true); // Keep pulsing but maybe different color (handled by build)
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
    setState(() => _voiceState = VoiceState.error);
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
  
  /// VAD Handler
  void _handleUserSpeakingChanged(bool isSpeaking) {
    if (!mounted) return;
    setState(() => _isUserSpeaking = isSpeaking);
  }

  void _handleTurnComplete() {
     if (_sessionManager?.isActive == true) {
      if (mounted) setState(() => _voiceState = VoiceState.listening);
    }
  }

  Future<void> _handleMicrophoneTap() async {
    context.read<SettingsProvider>().triggerHaptic(HapticFeedbackType.selection);

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

  Future<void> _onSessionComplete() async {
    await _sessionManager?.endSession();
    // Mark completion in Hive via UserProvider
    if (mounted) {
      await context.read<UserProvider>().completeOnboarding();
      context.go(AppRoutes.dashboard);
    }
  }

  // --- UI Helpers ---

  IconData _getButtonIcon() {
    if (_isUserSpeaking) return Icons.graphic_eq; // VAD Feedback
    
    switch (_voiceState) {
      case VoiceState.idle: return Icons.mic_none;
      case VoiceState.connecting: return Icons.cloud_sync;
      case VoiceState.listening: return Icons.mic;
      case VoiceState.thinking: return Icons.psychology;
      case VoiceState.speaking: return Icons.volume_up;
      case VoiceState.error: return Icons.refresh;
    }
  }

  String _getInstructionText() {
    if (_isUserSpeaking) return 'I hear you...';
    
    switch (_voiceState) {
      case VoiceState.idle: return 'Initialize Link';
      case VoiceState.connecting: return 'Authenticating...';
      case VoiceState.listening: return 'Listening...';
      case VoiceState.thinking: return 'Analyzing...';
      case VoiceState.speaking: return 'Sherlock is Speaking';
      case VoiceState.error: return 'Signal Lost';
    }
  }
  
  Color _getButtonColor() {
    if (_isUserSpeaking) return Colors.greenAccent; // VAD Feedback
    if (_voiceState == VoiceState.connecting) return Colors.blue;
    if (_voiceState == VoiceState.listening) return Colors.redAccent;
    if (_voiceState == VoiceState.speaking) return Colors.purpleAccent;
    if (_voiceState == VoiceState.thinking) return Colors.amber;
    return Colors.grey.shade800;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    Colors.deepPurple.shade900.withOpacity(0.4),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      const Icon(Icons.record_voice_over, color: Colors.white54, size: 20),
                      const SizedBox(width: 12),
                        Text(
                        widget.mode == VoiceSessionMode.onboarding ? 'THE INTERROGATION' : 'VOICE COACH',
                        style: const TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'monospace', letterSpacing: 2.0, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _isConnected ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _isConnected ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                             Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: _isConnected ? Colors.green : Colors.red)),
                             const SizedBox(width: 8),
                             Text(_isConnected ? 'LINK ACTIVE' : 'NO SIGNAL', style: TextStyle(color: _isConnected ? Colors.greenAccent : Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                const Spacer(),

                Center(
                  child: GestureDetector(
                    onTap: _handleMicrophoneTap,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        double scale = 1.0;
                        double blur = 20;

                        if (_voiceState == VoiceState.connecting) {
                          scale = _pulseAnimation.value * 0.9;
                          blur = 30;
                        } else if (_voiceState == VoiceState.listening) {
                          scale = 1.0 + (_audioLevel * 5).clamp(0.0, 0.5); 
                          blur = 20 + (_audioLevel * 20);
                        } else if (_voiceState == VoiceState.speaking) {
                          scale = _pulseAnimation.value * 1.5; 
                          blur = 60;
                        } else if (_voiceState == VoiceState.thinking) {
                           scale = 1.1;
                           blur = 40;
                        }
                        
                        // VAD Pulse
                        if (_isUserSpeaking) scale *= 1.1;

                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 200, height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getButtonColor().withOpacity(0.2),
                              boxShadow: [
                                BoxShadow(color: _getButtonColor().withOpacity(0.6), blurRadius: blur, spreadRadius: blur / 2),
                                BoxShadow(color: Colors.white.withOpacity(0.9), blurRadius: 10, spreadRadius: -50),
                              ],
                            ),
                            child: Center(child: Icon(_getButtonIcon(), color: Colors.white, size: 48)),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                const Spacer(),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(_getInstructionText(), key: ValueKey(_getInstructionText()), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w300, fontFamily: 'Roboto', letterSpacing: 0.5)),
                ),
                
                const SizedBox(height: 16),
                
                Text(_voiceState == VoiceState.speaking ? 'INCOMING TRANSMISSION...' : 'Tap orb to toggle link', style: const TextStyle(color: Colors.white38, fontSize: 14, fontFamily: 'monospace')),

                const SizedBox(height: 40),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(onPressed: () => context.go(AppRoutes.manualOnboarding), child: const Text('MANUAL OVERRIDE', style: TextStyle(color: Colors.white54))),
                    if (_isConnected && _voiceState != VoiceState.connecting)
                      TextButton(onPressed: _onSessionComplete, child: const Text('END LINK', style: TextStyle(color: Colors.white54))),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          
          // DevToolsOverlay removed per user request for simpler UI
          // if (kDebugMode) const DevToolsOverlay(),
        ],
      ),
    );
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
