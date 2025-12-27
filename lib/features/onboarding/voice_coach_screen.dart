import 'dart:async';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart'; // Added for context.read
import 'package:go_router/go_router.dart';
import '../../config/router/app_routes.dart';

import '../../data/services/voice_session_manager.dart';
import '../../data/providers/user_provider.dart'; // Added
import '../../data/providers/psychometric_provider.dart'; // Added
import '../../data/providers/settings_provider.dart'; // Added for Haptics
import '../../data/models/user_profile.dart'; // Added


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
    setState(() {
      _isUserSpeaking = isSpeaking;
      // Fix: If user speaks, force state to listening to handle interruptions
      if (isSpeaking && _voiceState == VoiceState.speaking) {
         _voiceState = VoiceState.listening;
      }
    });
  }

  void _handleTurnComplete() {
     if (_sessionManager?.isActive == true) {
       // Manual Mode: Mic stays CLOSED after AI turn. User must tap to speak.
       // This prevents "stuck" listening states.
       if (mounted) setState(() => _voiceState = VoiceState.idle);
    }
  }



  // --- UI Helpers ---

  String _getInstructionText() {
    switch (_voiceState) {
      case VoiceState.idle: return 'Initialize Link';
      case VoiceState.connecting: return 'Authenticating...';
      case VoiceState.listening: return 'Listening...';
      case VoiceState.thinking: return 'Thinking...';
      case VoiceState.speaking: return 'Sherlock Speaking';
      case VoiceState.error: return 'Signal Lost';
    }
  }
  
  String _getMicButtonLabel() {
    if (_voiceState == VoiceState.speaking) return 'Tap to Interrupt';
    if (_voiceState == VoiceState.thinking) return 'Processing...';
    // Default state for Always-On VAD
    return 'Listening...';
  }

  Color _getOrbColor() {
    if (_voiceState == VoiceState.speaking) return Colors.purpleAccent;
    if (_voiceState == VoiceState.thinking) return Colors.amber;
    if (_voiceState == VoiceState.listening || _isUserSpeaking) return Colors.greenAccent;
    if (_voiceState == VoiceState.connecting) return Colors.blue;
    return Colors.grey;
  }
  
  Color _getMicButtonColor() {
    if (_voiceState == VoiceState.speaking) return Colors.grey.withOpacity(0.3); // Disabled color
    if (_voiceState == VoiceState.listening) return Colors.green; // Active recording
    return Colors.white; // Default idle
  }

  // --- Input Handlers (New) ---

  
  Future<void> _handleMicTap() async {
    context.read<SettingsProvider>().triggerHaptic(HapticFeedbackType.selection);
    
    // Tap Logic:
    // 1. AI Speaking -> Interrupt
    // 2. Idle -> Lock Mic (Start)
    // 3. Listening -> Commit (Send)
    
    if (_voiceState == VoiceState.speaking) {
       _sessionManager?.interruptAI();
       await _sessionManager?.resumeSession();
       setState(() => _voiceState = VoiceState.listening);
       return;
    }
    
    if (_voiceState == VoiceState.listening) {
       // Stop & Send
       await _sessionManager?.commitUserTurn();
       setState(() => _voiceState = VoiceState.thinking);
       return;
    }
    
    // Start / Resume (Lock Mode)
    if (_sessionManager?.state == VoiceSessionState.paused) {
      await _sessionManager?.resumeSession();
    } else {
      await _sessionManager?.startSession();
    }
    setState(() => _voiceState = VoiceState.listening);
  }

  Future<void> _onSessionComplete() async {
    await _sessionManager?.endSession();
    // Mark completion in Hive via UserProvider
    if (mounted) {
      await context.read<UserProvider>().completeOnboarding();
      context.go(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background
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
                // Header
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      const Icon(Icons.record_voice_over, color: Colors.white54, size: 20),
                      const SizedBox(width: 12),
                        Text(
                        widget.mode == VoiceSessionMode.onboarding ? 'SHERLOCK SCREENING' : 'VOICE COACH',
                        style: const TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'monospace', letterSpacing: 2.0, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      _buildStatusIndicator(),
                    ],
                  ),
                ),

                const Spacer(),

                // 1. Visualizer (The Orb / Avatar)
                _buildVisualizer(),
                
                const SizedBox(height: 20),
                
                // State Label
                Text(
                  _getInstructionText(),
                  style: const TextStyle(color: Colors.white70, fontSize: 16, letterSpacing: 1.2),
                ),

                const Spacer(),

                // 2. Mic Control (Voice Note Style)
                _buildMicControl(),

                const SizedBox(height: 40),
                
                // Footer Buttons
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
        ],
      ),
    );
  }
  
  Widget _buildStatusIndicator() {
    return Container(
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
    );
  }
  
  Widget _buildVisualizer() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
         double scale = 1.0;
         double opacity = 0.5;
         
         if (_voiceState == VoiceState.speaking) {
           scale = _pulseAnimation.value * 1.5;
           opacity = 1.0;
         } else if (_voiceState == VoiceState.thinking) {
           scale = 1.1;
           opacity = 0.8;
         } else if (_isUserSpeaking) {
           // VAD Feedback: Pulse based on audio level
           scale = 1.0 + (_audioLevel * 5).clamp(0.0, 0.5);
           opacity = 0.8;
         }
         
         return Transform.scale(
           scale: scale,
           child: Container(
             width: 150, height: 150,
             decoration: BoxDecoration(
               shape: BoxShape.circle,
               color: _getOrbColor().withOpacity(opacity * 0.2),
               boxShadow: [
                 BoxShadow(color: _getOrbColor().withOpacity(opacity * 0.5), blurRadius: 40, spreadRadius: 10),
               ],
             ),
             child: Center(
               child: Icon(Icons.psychology, color: Colors.white.withOpacity(opacity), size: 64),
             ),
           ),
         );
      },
    );
  }
  
  Widget _buildMicControl() {
    bool isActive = _voiceState == VoiceState.listening;
    
    return Column(
      children: [
        GestureDetector(
          // PHASE 48: Always-On VAD - Remove Hold Gesture
          // onLongPressStart: ... 
          // onLongPressEnd: ...
          onTap: _handleMicTap, // Single tap to Interrupt or Manual Send
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isActive ? 90 : 80,
            height: isActive ? 90 : 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getMicButtonColor(),
              boxShadow: isActive ? [BoxShadow(color: Colors.greenAccent.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)] : [],
            ),
            child: Icon(
              isActive ? Icons.arrow_upward : Icons.mic, // Arrow up implies "Send"
              color: isActive ? Colors.white : (_voiceState == VoiceState.speaking ? Colors.white24 : Colors.black),
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _getMicButtonLabel(),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
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
