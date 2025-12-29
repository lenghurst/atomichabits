import 'package:flutter/material.dart';
import '../../../data/models/chat_message.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    
    // Theme Colors
    final bubbleColor = isUser ? const Color(0xFF005C4B) : const Color(0xFF202C33);
    final textColor = Colors.white;
    final secondaryTextColor = Colors.white60;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isUser ? 12 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 12),
          ),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            
            // --- 1. AUDIO PLAYER SECTION (Top) ---
            if (message.audioPath != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.white10)),
                ),
                child: Row(
                  children: [
                    // Play Button
                    _PlayButton(isUser: isUser),
                    const SizedBox(width: 12),
                    
                    // Waveform & Duration
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User gets simple bar, Sherlock gets complex waveform
                          CustomPaint(
                            size: const Size(double.infinity, 24),
                            painter: WaveformPainter(
                              color: isUser ? Colors.white54 : Colors.cyanAccent.withOpacity(0.6),
                              barCount: isUser ? 20 : 30, // Denser for AI
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(message.audioDuration),
                                style: TextStyle(color: secondaryTextColor, fontSize: 11),
                              ),
                              if (!isUser) // Only show speed toggle for Sherlock
                                _SpeedToggle(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // --- 2. TRANSCRIPT SECTION (Bottom) ---
            if (message.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.audioPath != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text("TRANSCRIPT", 
                          style: TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      ),
                    Text(
                      message.content,
                      style: TextStyle(color: textColor, fontSize: 15, height: 1.4),
                    ),
                  ],
                ),
              ),

            // --- 3. METADATA (Time + Status) ---
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 4),
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${message.timestamp.hour.toString().padLeft(2,'0')}:${message.timestamp.minute.toString().padLeft(2,'0')}",
                      style: const TextStyle(color: Colors.white30, fontSize: 10),
                    ),
                    if (isUser) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.done_all, size: 14, color: Colors.blueAccent),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration? d) {
    if (d == null) return "0:00";
    return "${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";
  }
}

// Helper Widgets to clean up the tree

class _PlayButton extends StatelessWidget {
  final bool isUser;
  const _PlayButton({required this.isUser});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: isUser ? Colors.black12 : const Color(0xFF00A884),
      child: const Icon(Icons.play_arrow, color: Colors.white),
    );
  }
}

class _SpeedToggle extends StatefulWidget {
  @override
  State<_SpeedToggle> createState() => _SpeedToggleState();
}

class _SpeedToggleState extends State<_SpeedToggle> {
  double _speed = 1.0;

  void _toggle() {
    setState(() {
      if (_speed == 1.0) _speed = 1.5;
      else if (_speed == 1.5) _speed = 2.0;
      else _speed = 1.0;
    });
    // TODO: Wire up actual player speed
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          "${_speed.toString().replaceAll('.0','')}x",
          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final Color color;
  final int barCount;
  WaveformPainter({required this.color, this.barCount = 20});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 3..strokeCap = StrokeCap.round;
    final spacing = size.width / barCount;
    
    // Simple visual pattern
    final levels = [0.3, 0.5, 0.8, 0.4, 0.6, 0.9, 0.5, 0.3, 0.6, 0.4]; 
    
    for (int i = 0; i < barCount; i++) {
      final h = size.height * levels[i % levels.length];
      final x = i * spacing + 2;
      canvas.drawLine(Offset(x, (size.height - h)/2), Offset(x, (size.height + h)/2), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
