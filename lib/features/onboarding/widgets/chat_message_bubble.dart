import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // ✅ Actual Audio Engine
import '../../../data/models/chat_message.dart';

class ChatMessageBubble extends StatefulWidget {
  final ChatMessage message;
  const ChatMessageBubble({super.key, required this.message});

  @override
  State<ChatMessageBubble> createState() => _ChatMessageBubbleState();
}

class _ChatMessageBubbleState extends State<ChatMessageBubble> {
  late AudioPlayer _player;
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;
  Duration _position = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    
    // Listen to stream states
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });

    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _totalDuration = d);
    });

    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });

    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    _player.dispose(); // Important: Kill audio when bubble leaves screen
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (widget.message.audioPath == null) return;

    if (_isPlaying) {
      await _player.pause();
    } else {
      // ⚡ Play local file
      await _player.setSourceDeviceFile(widget.message.audioPath!);
      await _player.setPlaybackRate(_playbackSpeed);
      await _player.resume();
    }
  }

  void _toggleSpeed() {
    setState(() {
      _playbackSpeed = (_playbackSpeed == 1.0) ? 1.5 : (_playbackSpeed == 1.5 ? 2.0 : 1.0);
    });
    if (_isPlaying) {
      _player.setPlaybackRate(_playbackSpeed);
    }
  }

  String _formatDuration(Duration d) {
    return "${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.role == MessageRole.user;
    final bubbleColor = isUser ? const Color(0xFF005C4B) : const Color(0xFF202C33);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2, offset: const Offset(0, 1))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // --- AUDIO PLAYER SECTION (Top) ---
            if (widget.message.audioPath != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: isUser ? null : const Border(bottom: BorderSide(color: Colors.white10)),
                ),
                child: Row(
                  children: [
                    // Play Button
                    GestureDetector(
                      onTap: _togglePlay,
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: isUser ? Colors.black12 : Colors.cyanAccent,
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: isUser ? Colors.white : Colors.black,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Progress Bar & Waveform
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Progress Bar
                          LinearProgressIndicator(
                            value: (_totalDuration.inMilliseconds > 0) 
                                ? _position.inMilliseconds / _totalDuration.inMilliseconds 
                                : 0.0,
                            backgroundColor: isUser ? Colors.white24 : Colors.grey[800],
                            valueColor: AlwaysStoppedAnimation(isUser ? Colors.white : Colors.cyanAccent),
                            minHeight: 4,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          const SizedBox(height: 8),
                          
                          // Metadata Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _isPlaying ? _formatDuration(_position) : _formatDuration(widget.message.audioDuration ?? _totalDuration),
                                style: TextStyle(color: Colors.white54, fontSize: 11),
                              ),
                              if (!isUser)
                                GestureDetector(
                                  onTap: _toggleSpeed,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                                    child: Text("${_playbackSpeed}x", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // --- TRANSCRIPT SECTION (Bottom) ---
            if (widget.message.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  widget.message.content,
                  style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
