import 'dart:convert';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/router/app_routes.dart';
import '../../config/ai_model_config.dart';
import '../../data/providers/psychometric_provider.dart';
import '../../data/services/voice_session_manager.dart';
import '../dev/dev_tools_overlay.dart';

/// Sherlock Protocol Screen
/// 
/// Phase 42: "The Soul Capture"
/// 
/// This screen is a dedicated psychological profiling session.
/// Goal: Extract the "Holy Trinity" using the Sherlock persona:
/// 1. Anti-Identity (The Fear)
/// 2. Failure Archetype (The Reason)
/// 3. Resistance Lie (The Excuse)
/// 
/// It routes to the PactRevealScreen (The "Magic Moment") upon success.
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
  
  // ignore: unused_field
  bool _isConnected = false;
  // ignore: unused_field
  String _connectionStatus = 'Initialising...';
  
  // ignore: unused_field
  List<String> _debugLog = [];
  // ignore: unused_field
  bool _showDebugPanel = false;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  // Audio Playback
  final List<Uint8List> _audioQueue = [];
  bool _isPlaying = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // 1. Initial Speaker Enforcement
    _enforceSpeakerOutput();
    
    _initializePulseAnimation();
    _initializeVoiceSession();
  }

  /// CRITICAL: Helper to force audio to speaker, even if mic is on
  Future<void> _enforceSpeakerOutput() async {
    if (kDebugMode) debugPrint('SherlockScreen: 🔊 Enforcing Speaker Output...');
    
    await _audioPlayer.setVolume(1.0); // Ensure volume is max
    
    await AudioPlayer.global.setAudioContext(AudioContext(
      android: const AudioContextAndroid(
        isSpeakerphoneOn: true,
        stayAwake: true,
        contentType: AndroidContentType.speech,
        usageType: AndroidUsageType.assistant,
        audioFocus: AndroidAudioFocus.gain,
      ),
      iOS: AudioContextIOS(
        // 'playAndRecord' is required to hear audio while mic is active
        category: AVAudioSessionCategory.playAndRecord, 
        options: {
          AVAudioSessionOptions.defaultToSpeaker, 
          AVAudioSessionOptions.allowBluetooth,
          AVAudioSessionOptions.allowAirPlay
        },
      ),
    ));
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
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      if (_sessionManager?.isActive == true) {
        if (kDebugMode) {
          debugPrint('SherlockScreen: App backgrounded, pausing session for security.');
        }
        _sessionManager?.pauseSession();
      }
    }
  }
  
  Future<void> _initializeVoiceSession() async {
    setState(() => _voiceState = VoiceState.connecting);
    
    // SHERLOCK PERSONA (Investigative Journalist)
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
      onDebugLogUpdated: _handleDebugLogUpdated,
    );
    
    final success = await _sessionManager!.startSession();
    
    // 2. CRITICAL FIX: Re-enforce speaker AFTER recording starts
    await _enforceSpeakerOutput();
    
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
  
  void _handleAudioReceived(Uint8List audioData) {
    if (!mounted) return;
    _audioQueue.add(audioData);
    if (!_isPlaying) {
      _processAudioQueue();
    }
  }

  Future<void> _processAudioQueue() async {
    if (_audioQueue.isEmpty) {
      _isPlaying = false;
      return;
    }

    _isPlaying = true;
    final chunk = _audioQueue.removeAt(0);

    try {
      final wavBytes = _addWavHeader(chunk);
      await _audioPlayer.play(BytesSource(wavBytes));
      await _audioPlayer.onPlayerComplete.first;
      _processAudioQueue();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SherlockScreen: Audio playback error: $e');
      }
      _processAudioQueue(); // Skip and continue
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
    setState(() {
      _audioLevel = level;
    });
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
  
  void _handleUserSpeakingChanged(bool isSpeaking) {
    // Optional visual feedback
  }
  
  void _handleTurnComplete() {
    if (_sessionManager?.isActive == true) {
      if (!mounted) return;
      setState(() => _voiceState = VoiceState.listening);
    }
  }
  
  void _handleDebugLogUpdated(List<String> log) {
    if (mounted) {
      setState(() => _debugLog = List.from(log));
    }
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
              const Text('Debugging Info:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SelectableText(
                error,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }
  
  void _showFallbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Voice Unavailable'),
        content: const Text(
          'Connections to Sherlock are unstable. We can proceed with manual entry.',
        ),
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
  
  /// Transition to the "Magic Moment"
  Future<void> _onSessionComplete() async {
    await _sessionManager?.endSession();
    
    if (!mounted) return;
    
    final profile = context.read<PsychometricProvider>().profile;
    // Sherlock Protocol Success Criteria:
    final hasData = profile.antiIdentityLabel != null ||
                    profile.failureArchetype != null ||
                    profile.resistanceLieLabel != null;
    
    if (hasData) {
      // Magic Moment
      context.go(AppRoutes.pactReveal);
    } else {
      // Fallback
      context.go(AppRoutes.dashboard);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: Colors.black, // Cinematic black for Sherlock
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
              // Transcript
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
              
              // Visualiser
              Container(
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black, colorScheme.primary.withValues(alpha: 0.2)],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  border: Border(top: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3))),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getStatusText(),
                      style: const TextStyle(
                        color: Colors.white70,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: _handleMicrophoneTap,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _voiceState == VoiceState.listening ? _pulseAnimation.value : 1.0,
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getButtonColor(),
                                boxShadow: [
                                  BoxShadow(
                                    color: _getButtonColor().withValues(alpha: 0.5),
                                    blurRadius: 30,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _getButtonIcon(),
                                color: Colors.white,
                                size: 36,
                              ),
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
  
  String _getStatusText() {
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
    switch (_voiceState) {
      case VoiceState.idle: return Colors.grey.shade800;
      case VoiceState.connecting: return Colors.blueGrey;
      case VoiceState.listening: return Colors.redAccent; // Recording = Red
      case VoiceState.thinking: return Colors.purpleAccent;
      case VoiceState.speaking: return Colors.cyanAccent;
      case VoiceState.error: return Colors.red;
    }
  }

  IconData _getButtonIcon() {
    if (_voiceState == VoiceState.listening) return Icons.mic;
    if (_voiceState == VoiceState.speaking) return Icons.graphic_eq;
    return Icons.mic_none;
  }
}

class _TranscriptBubble extends StatelessWidget {
  final TranscriptMessage message;
  final bool isDark;

  const _TranscriptBubble({required this.message, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final isSystem = message.isSystem;
    
    if (isSystem) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          message.text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? Colors.white54 : Colors.grey,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser 
              ? (isDark ? Colors.white24 : Colors.blue.shade100)
              : (isDark ? Colors.grey.shade900 : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
          border: isDark ? Border.all(color: Colors.white10) : null,
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

/// Simple state for the voice UI
enum VoiceState {
  idle,
  connecting,
  listening,
  thinking,
  speaking,
  error,
}

/// Represents a message in the transcript
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
