import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

/// Voice input button with speech-to-text functionality
/// Ported from ai-conversational branch and adapted for reflection use
class VoiceInputButton extends StatefulWidget {
  final void Function(String text) onResult;
  final void Function(bool isListening)? onListeningChanged;
  final void Function(String error)? onError;
  final double size;
  final bool compact;

  const VoiceInputButton({
    super.key,
    required this.onResult,
    this.onListeningChanged,
    this.onError,
    this.size = 48,
    this.compact = false,
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

    if (widget.compact) {
      return IconButton(
        onPressed: _isListening ? _stopListening : _startListening,
        icon: Icon(
          _isListening ? Icons.stop : Icons.mic,
          color: _isListening ? colorScheme.error : colorScheme.primary,
        ),
        tooltip: _isListening ? 'Stop recording' : 'Voice input',
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
              width: widget.size,
              height: widget.size,
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

/// Listening indicator shown when voice input is active
class VoiceListeningIndicator extends StatelessWidget {
  final String currentText;

  const VoiceListeningIndicator({
    super.key,
    required this.currentText,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.error.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const _PulsingDot(),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              currentText.isEmpty ? 'Listening...' : currentText,
              style: TextStyle(
                color: currentText.isEmpty
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onSurface,
                fontStyle: currentText.isEmpty ? FontStyle.italic : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pulsing dot indicator for listening state
class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error.withOpacity(
                  0.5 + (_controller.value * 0.5),
                ),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
