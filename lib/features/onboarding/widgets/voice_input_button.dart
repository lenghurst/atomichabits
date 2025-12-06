import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

/// Voice input button with speech-to-text functionality
class VoiceInputButton extends StatefulWidget {
  final void Function(String text) onResult;
  final void Function(bool isListening)? onListeningChanged;
  final void Function(String error)? onError;

  const VoiceInputButton({
    super.key,
    required this.onResult,
    this.onListeningChanged,
    this.onError,
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  String _lastWords = '';

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initSpeech();

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
    _speechToText.stop();
    super.dispose();
  }

  /// Initialize speech recognition
  void _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            _stopListening();
          }
        },
        onError: (error) {
          widget.onError?.call(error.errorMsg);
          _stopListening();
        },
      );
      setState(() {});
    } catch (e) {
      widget.onError?.call('Speech recognition not available');
    }
  }

  /// Start listening for speech
  void _startListening() async {
    if (!_speechEnabled) {
      widget.onError?.call('Speech recognition not available on this device');
      return;
    }

    _lastWords = '';

    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: 'en_US',
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );

    setState(() {
      _isListening = true;
    });

    _pulseController.repeat(reverse: true);
    widget.onListeningChanged?.call(true);
  }

  /// Stop listening for speech
  void _stopListening() async {
    await _speechToText.stop();

    setState(() {
      _isListening = false;
    });

    _pulseController.stop();
    _pulseController.reset();
    widget.onListeningChanged?.call(false);

    // Send the final result if we have text
    if (_lastWords.isNotEmpty) {
      widget.onResult(_lastWords);
      _lastWords = '';
    }
  }

  /// Handle speech recognition results
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });

    // If this is the final result, stop listening
    if (result.finalResult && _lastWords.isNotEmpty) {
      _stopListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!_speechEnabled) {
      // Show disabled mic if speech is not available
      return IconButton(
        onPressed: () {
          widget.onError?.call('Speech recognition is not available on this device');
        },
        icon: Icon(
          Icons.mic_off,
          color: colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
        tooltip: 'Voice input not available',
      );
    }

    return GestureDetector(
      onTap: _isListening ? _stopListening : _startListening,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isListening ? _pulseAnimation.value : 1.0,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _isListening
                    ? colorScheme.error
                    : colorScheme.primaryContainer,
                shape: BoxShape.circle,
                boxShadow: _isListening
                    ? [
                        BoxShadow(
                          color: colorScheme.error.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                _isListening ? Icons.stop : Icons.mic,
                color: _isListening
                    ? colorScheme.onError
                    : colorScheme.onPrimaryContainer,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Listening overlay that shows when voice input is active
class VoiceListeningOverlay extends StatelessWidget {
  final String currentText;
  final VoidCallback onCancel;

  const VoiceListeningOverlay({
    super.key,
    required this.currentText,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated mic icon
              const _AnimatedMicIcon(),
              const SizedBox(height: 24),
              Text(
                'Listening...',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 16),
              // Live transcription
              Container(
                constraints: const BoxConstraints(minHeight: 60),
                child: Text(
                  currentText.isEmpty ? 'Say something...' : currentText,
                  style: TextStyle(
                    fontSize: 16,
                    color: currentText.isEmpty
                        ? colorScheme.onSurfaceVariant.withOpacity(0.6)
                        : colorScheme.onSurface,
                    fontStyle:
                        currentText.isEmpty ? FontStyle.italic : FontStyle.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              // Cancel button
              TextButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.close),
                label: const Text('Cancel'),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated microphone icon with ripple effect
class _AnimatedMicIcon extends StatefulWidget {
  const _AnimatedMicIcon();

  @override
  State<_AnimatedMicIcon> createState() => _AnimatedMicIconState();
}

class _AnimatedMicIconState extends State<_AnimatedMicIcon>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      );
    }).toList();

    // Stagger the ripple animations
    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 400), () {
        if (mounted) {
          _controllers[i].repeat();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ripple effects
          ...List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + _animations[index].value,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.primary
                            .withOpacity(1.0 - _animations[index].value),
                        width: 2,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          // Center mic icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mic,
              color: colorScheme.onPrimary,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}
