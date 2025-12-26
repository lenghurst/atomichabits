import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../config/router/app_routes.dart';

import '../../data/services/voice_session_manager.dart';
import '../dev/dev_tools_overlay.dart';

/// Voice-First Onboarding Screen
/// 
/// "The Interrogation"
/// - Audio Buffering to prevent stuttering (Gemini Live)
/// - Visualizer Orb
/// - System Link status
class VoiceCoachScreen extends StatefulWidget {
  const VoiceCoachScreen({super.key});

  @override
  State<VoiceCoachScreen> createState() => _VoiceCoachScreenState();
}

class _VoiceCoachScreenState extends State<VoiceCoachScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  
  // Session Manager
  VoiceSessionManager? _sessionManager;
  VoiceState _voiceState = VoiceState.idle;
  
  // Audio Playback
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<int> _audioBuffer = []; 
  bool _isPlaying = false;
  static const int _bufferingThreshold = 24000; // ~0.5s at 24kHz 16-bit

  // Visualization
  double _audioLevel = 0.0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  // Connection Status
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
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    _audioPlayer.dispose();
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
    
    _sessionManager = VoiceSessionManager(
      onStateChanged: _handleStateChanged,
      onAudioReceived: _handleAudioReceived,
      onError: _handleError,
      onAudioLevelChanged: (level) {
        if (mounted) setState(() => _audioLevel = level);
      },
      onAISpeakingChanged: _handleAISpeakingChanged,
      onUserSpeakingChanged: (_) {}, // Visualiser driven by audio level
      onTurnComplete: _handleTurnComplete,
      // Debug logging if needed, we can add it back if requested but keeping UI clean for now
    );

    try {
      await _sessionManager!.startSession();
      // Auto-start if permission granted/ready?
      // For "Interrogation", maybe we want user to initiate "Link"?
      // Or auto-connect.
       setState(() {
        _isConnected = true;
        _voiceState = VoiceState.idle; // Ready to start
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

  // --- Audio Handling ---

  void _handleAudioReceived(Uint8List audioData) {
    if (!mounted) return;
    if (kDebugMode) debugPrint('VoiceCoachScreen: 📥 Rx Audio Chunk: ${audioData.length} bytes. Buffer: ${_audioBuffer.length}');
    _audioBuffer.addAll(audioData);
    
    if (!_isPlaying && _audioBuffer.length >= _bufferingThreshold) {
      if (kDebugMode) debugPrint('VoiceCoachScreen: ▶️ Threshold reached (${_audioBuffer.length} >= $_bufferingThreshold), starting playback');
      _playBufferedAudio();
    }
  }

  Future<void> _playBufferedAudio() async {
    if (_audioBuffer.isEmpty) {
      _isPlaying = false;
      return;
    }

    _isPlaying = true;
    final List<int> chunk = List.from(_audioBuffer);
    _audioBuffer.clear();
    
    if (kDebugMode) debugPrint('VoiceCoachScreen: 🔊 Playing chunk: ${chunk.length} bytes');

    try {
      final wavBytes = _addWavHeader(Uint8List.fromList(chunk));
      await _audioPlayer.play(BytesSource(wavBytes));
      
      try {
        await _audioPlayer.onPlayerComplete.first.timeout(
          Duration(milliseconds: (chunk.length / 48).round() + 1000),
          onTimeout: () => debugPrint('Audio timeout'),
        );
      } catch (_) {}

      if (_audioBuffer.isNotEmpty) {
        _playBufferedAudio();
      } else {
        _isPlaying = false;
      }
    } catch (e) {
      debugPrint('Audio Playback Error: $e');
      _isPlaying = false;
    }
  }

  Uint8List _addWavHeader(Uint8List pcmData) {
    const int sampleRate = 24000;
    const int numChannels = 1;
    const int bitsPerSample = 16;
    
    final int byteRate = sampleRate * numChannels * bitsPerSample ~/ 8;
    final int blockAlign = numChannels * bitsPerSample ~/ 8;
    final int dataSize = pcmData.length;
    final int fileSize = 36 + dataSize;

    final header = Uint8List(44);
    final view = ByteData.view(header.buffer);

    header.setRange(0, 4, ascii.encode('RIFF'));
    view.setUint32(4, fileSize, Endian.little);
    header.setRange(8, 12, ascii.encode('WAVE'));
    header.setRange(12, 16, ascii.encode('fmt '));
    view.setUint32(16, 16, Endian.little);
    view.setUint16(20, 1, Endian.little);
    view.setUint16(22, numChannels, Endian.little);
    view.setUint32(24, sampleRate, Endian.little);
    view.setUint32(28, byteRate, Endian.little);
    view.setUint16(32, blockAlign, Endian.little);
    view.setUint16(34, bitsPerSample, Endian.little);
    header.setRange(36, 4, ascii.encode('data'));
    view.setUint32(40, dataSize, Endian.little);

    final wavFile = Uint8List(44 + dataSize);
    wavFile.setRange(0, 44, header);
    wavFile.setRange(44, 44 + dataSize, pcmData);
    
    return wavFile;
  }

  // --- State Handlers ---

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
    // Could show snackbar or status text update
  }

  void _handleAISpeakingChanged(bool isSpeaking) {
    if (!mounted) return;
    setState(() {
      if (isSpeaking) {
        if (!_isPlaying && _audioBuffer.isNotEmpty) {
          _playBufferedAudio();
        }
        _voiceState = VoiceState.speaking;
      } else if (_sessionManager?.isActive == true) {
        _voiceState = VoiceState.listening;
      }
    });
  }

  void _handleTurnComplete() {
     if (!_isPlaying && _audioBuffer.isNotEmpty) {
        _playBufferedAudio();
     }
     if (_sessionManager?.isActive == true) {
      if (mounted) setState(() => _voiceState = VoiceState.listening);
    }
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

  Future<void> _onSessionComplete() async {
    await _sessionManager?.endSession();
    if (mounted) context.go(AppRoutes.dashboard);
  }

  // --- UI Helpers ---

  IconData _getButtonIcon() {
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
    switch (_voiceState) {
      case VoiceState.idle: return 'Initialize Link';
      case VoiceState.connecting: return 'Authenticating...';
      case VoiceState.listening: return 'Listening...';
      case VoiceState.thinking: return 'Analyzing...';
      case VoiceState.speaking: return 'Sherlock is Speaking';
      case VoiceState.error: return 'Signal Lost';
    }
  }

  // --- Build ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Void
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
                      const Text(
                        'THE INTERROGATION',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontFamily: 'monospace',
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // Status Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _isConnected ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _isConnected ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                             Container(
                               width: 6, height: 6,
                               decoration: BoxDecoration(
                                 shape: BoxShape.circle,
                                 color: _isConnected ? Colors.green : Colors.red,
                               ),
                             ),
                             const SizedBox(width: 8),
                             Text(
                               _isConnected ? 'LINK ACTIVE' : 'NO SIGNAL',
                               style: TextStyle(
                                 color: _isConnected ? Colors.greenAccent : Colors.redAccent,
                                 fontSize: 10,
                                 fontWeight: FontWeight.bold,
                               ),
                             ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                const Spacer(),

                // Central Orb
                Center(
                  child: GestureDetector(
                    onTap: _handleMicrophoneTap,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        double scale = 1.0;
                        Color orbColor = Colors.grey.shade800;
                        double blur = 20;

                        if (_voiceState == VoiceState.connecting) {
                          orbColor = Colors.blue;
                          scale = _pulseAnimation.value * 0.9;
                          blur = 30;
                        } else if (_voiceState == VoiceState.listening) {
                          orbColor = Colors.redAccent; 
                          scale = 1.0 + (_audioLevel * 5).clamp(0.0, 0.5); 
                          blur = 20 + (_audioLevel * 20);
                        } else if (_voiceState == VoiceState.speaking) {
                          orbColor = Colors.purpleAccent; 
                          scale = _pulseAnimation.value * 1.5; 
                          blur = 60;
                        } else if (_voiceState == VoiceState.thinking) {
                           orbColor = Colors.amber;
                           scale = 1.1;
                           blur = 40;
                        }

                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: orbColor.withOpacity(0.2),
                              boxShadow: [
                                BoxShadow(
                                  color: orbColor.withOpacity(0.6),
                                  blurRadius: blur,
                                  spreadRadius: blur / 2,
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.9),
                                  blurRadius: 10,
                                  spreadRadius: -50,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                _getButtonIcon(),
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                const Spacer(),

                // Instruction Text
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _getInstructionText(),
                    key: ValueKey(_voiceState),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'Roboto', 
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  _voiceState == VoiceState.speaking 
                      ? 'INCOMING TRANSMISSION...' 
                      : 'Tap orb to toggle link',
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                ),

                const SizedBox(height: 40),
                
                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => context.go(AppRoutes.manualOnboarding),
                      child: const Text('MANUAL OVERRIDE', style: TextStyle(color: Colors.white54)),
                    ),
                    if (_isConnected && _voiceState != VoiceState.connecting)
                      TextButton(
                        onPressed: _onSessionComplete,
                         child: const Text('END LINK', style: TextStyle(color: Colors.white54)),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          
          if (kDebugMode) const DevToolsOverlay(),
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
