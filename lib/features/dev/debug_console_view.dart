import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/logging/log_buffer.dart';

class DebugConsoleView extends StatefulWidget {
  const DebugConsoleView({super.key});

  @override
  State<DebugConsoleView> createState() => _DebugConsoleViewState();
}

class _DebugConsoleViewState extends State<DebugConsoleView> {
  // Auto-scroll to bottom like a terminal
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;

  @override
  Widget build(BuildContext context) {
    // Access logs directly from the singleton buffer
    final logs = LogBuffer.instance.logs;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Debug Console', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // SINGLE, CLEAN COPY ACTION
          IconButton(
            icon: const Icon(Icons.copy_all),
            tooltip: 'Copy All Logs',
            onPressed: () => _copyAllLogs(logs),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear Logs',
            onPressed: () {
              LogBuffer.instance.clear();
              setState(() {});
            },
          ),
        ],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
            // Disable auto-scroll if user scrolls up
            final metrics = notification.metrics;
            if (metrics.pixels < metrics.maxScrollExtent - 50) {
              _autoScroll = false;
            } else {
              _autoScroll = true;
            }
          }
          return false;
        },
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(8.0),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            return _buildLogItem(log);
          },
        ),
      ),
      floatingActionButton: _autoScroll ? null : FloatingActionButton.small(
        backgroundColor: Colors.grey[800],
        child: const Icon(Icons.arrow_downward, color: Colors.white),
        onPressed: () {
          _scrollToBottom();
          setState(() => _autoScroll = true);
        },
      ),
    );
  }

  Widget _buildLogItem(String log) {
    Color textColor = Colors.greenAccent; // Default (Info)
    if (log.contains('❌') || log.contains('[ERROR]')) textColor = Colors.redAccent;
    if (log.contains('⚠️') || log.contains('[WARN]')) textColor = Colors.orangeAccent;
    if (log.contains('🐛') || log.contains('[DEBUG]')) textColor = Colors.blueGrey;

    return InkWell(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: log));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Log line copied'), duration: Duration(milliseconds: 500)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Text(
          log,
          style: TextStyle(color: textColor, fontFamily: 'Courier', fontSize: 12),
        ),
      ),
    );
  }

  Future<void> _copyAllLogs(List<String> logs) async {
    final text = logs.join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ All logs copied to clipboard')),
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }
}
