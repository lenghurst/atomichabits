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
      final success = await _sessionManager!.startSession();
      if (success) {
        setState(() {
          _isConnected = true;
          _voiceState = VoiceState.idle;
        });
      } else {
        // State change handled by onStateChanged or onError, but explicit fallback here
         if (mounted && !_isConnected) {
            setState(() {
              _isConnected = false;
              _voiceState = VoiceState.error;
            });
         }
      }
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
          _voiceState = VoiceState.idle;
          _pulseController.stop();
          break;
        case VoiceSessionState.paused:
          _voiceState = VoiceState.ready;
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
      case VoiceState.ready: return 'Ready';
    }
  }
  
  String _getMicButtonLabel() {
    if (_voiceState == VoiceState.speaking) return 'Locked (AI Speaking)';
    if (_voiceState == VoiceState.thinking) return 'Processing...';
    if (_voiceState == VoiceState.listening) return 'Release to Send'; // Active
    if (_voiceState == VoiceState.idle) return 'Tap to Connect'; // Initial
    if (_voiceState == VoiceState.ready) return 'Hold to Speak';
    // Default fallback
    return 'Hold to Speak'; 
  }

  Color _getOrbColor() {
    if (_voiceState == VoiceState.speaking) return Colors.purpleAccent;
    if (_voiceState == VoiceState.thinking) return Colors.amber;
    if (_voiceState == VoiceState.listening || _isUserSpeaking) return Colors.greenAccent;
    if (_voiceState == VoiceState.connecting) return Colors.blue;
    if (_voiceState == VoiceState.ready) return Colors.blueGrey;
    
    // Oracle Mode Default
    if (widget.mode == VoiceSessionMode.oracle) return const Color(0xFFFFD700); // Gold
    
    return Colors.grey;
  }
  
  Color _getMicButtonColor() {
    if (_voiceState == VoiceState.speaking) return Colors.white10; // Locked visually
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
       // Phase 51: Lockdown - User cannot interrupt AI
       context.read<SettingsProvider>().triggerHaptic(HapticFeedbackType.heavy);
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
                  colors: widget.mode == VoiceSessionMode.oracle 
                      ? [
                          const Color(0xFFB45309).withOpacity(0.3), // Amber-700
                          Colors.black,
                        ]
                      : [
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
                        widget.mode == VoiceSessionMode.onboarding 
                            ? 'SHERLOCK SCREENING' 
                            : widget.mode == VoiceSessionMode.oracle
                                ? 'ORACLE COACH'
                                : 'VOICE COACH',
                        style: TextStyle(
                            color: widget.mode == VoiceSessionMode.oracle ? const Color(0xFFFFD700) : Colors.white70,
                            fontSize: 14, 
                            fontFamily: 'monospace', 
                            letterSpacing: 2.0, 
                            fontWeight: FontWeight.bold
                        ),
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
          // PHASE 52: Push-to-Talk (PTT) Implementation
          // Tap: Connect (Initial)
          // Long Press: Hold to Speak
          onTap: () {
            if (_voiceState == VoiceState.idle || _voiceState == VoiceState.error) {
               _handleMicTap(); // Connect
            } else if (_voiceState == VoiceState.speaking) {
               // Locked - Do nothing or Haptic
               context.read<SettingsProvider>().triggerHaptic(HapticFeedbackType.heavy);
            }
          },
          onLongPressStart: (_) async {
            if (_voiceState == VoiceState.speaking) {
               // Locked - Do nothing
               context.read<SettingsProvider>().triggerHaptic(HapticFeedbackType.heavy);
               return;
            }
            
            if (_voiceState == VoiceState.idle) {
               await _handleMicTap(); 
            } else {
               context.read<SettingsProvider>().triggerHaptic(HapticFeedbackType.selection);
               await _sessionManager?.startRecording();
               setState(() => _voiceState = VoiceState.listening);
            }
          },
          onLongPressEnd: (_) async {
            if (_voiceState == VoiceState.listening) {
               context.read<SettingsProvider>().triggerHaptic(HapticFeedbackType.selection);
               await _sessionManager?.stopRecording();
               setState(() => _voiceState = VoiceState.thinking);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100), // Faster animation for PTT
            width: isActive ? 100 : 80, // Grow when holding
            height: isActive ? 100 : 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getMicButtonColor(),
              boxShadow: isActive ? [BoxShadow(color: Colors.greenAccent.withOpacity(0.6), blurRadius: 30, spreadRadius: 8)] : [],
            ),
            child: Icon(
              isActive ? Icons.mic : Icons.mic_none,
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
  ready, // Connected but mic closed (PTT Ready)
}
