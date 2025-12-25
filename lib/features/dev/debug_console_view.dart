// lib/features/dev/debug_console_view.dart
// Phase 38: In-App Log Console - The "Black Box" Viewer
//
// This widget displays the centralized log buffer in a terminal-like UI.
// Features:
// - Real-time log updates via ValueListenableBuilder
// - One-click copy to clipboard
// - Clear logs button
// - Error highlighting (red text)
// - Auto-scroll to latest logs

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/logging/log_buffer.dart';

/// A terminal-like debug console for viewing live logs.
/// 
/// Usage:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   builder: (_) => const SizedBox(height: 600, child: DebugConsoleView()),
/// );
/// ```
class DebugConsoleView extends StatelessWidget {
  const DebugConsoleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1E1E), // VS Code dark theme background
      child: Column(
        children: [
          // === TOOLBAR ===
          _buildToolbar(context),
          
          // === LOG LIST ===
          Expanded(
            child: _buildLogList(),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF252526), // VS Code title bar
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade800),
        ),
      ),
      child: Row(
        children: [
          // Terminal icon
          const Icon(Icons.terminal, color: Colors.greenAccent, size: 18),
          const SizedBox(width: 8),
          
          // Title
          const Text(
            'GEMINI LIVE LOGS',
            style: TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 1.2,
            ),
          ),
          
          const Spacer(),
          
          // Log count badge
          ValueListenableBuilder<int>(
            valueListenable: LogBuffer().notifyListeners,
            builder: (context, _, __) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${LogBuffer().length} logs',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(width: 8),
          
          // Copy All button
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.white70, size: 20),
            tooltip: 'Copy All Logs',
            onPressed: () {
              final logs = LogBuffer().allLogs;
              if (logs.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No logs to copy')),
                );
                return;
              }
              Clipboard.setData(ClipboardData(text: logs));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Logs copied to clipboard'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
          
          // Clear button
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            tooltip: 'Clear Logs',
            onPressed: () {
              LogBuffer().clear();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logs cleared')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogList() {
    return ValueListenableBuilder<int>(
      valueListenable: LogBuffer().notifyListeners,
      builder: (context, _, __) {
        final logs = LogBuffer().logs;
        
        if (logs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, color: Colors.white24, size: 48),
                SizedBox(height: 16),
                Text(
                  'No logs yet',
                  style: TextStyle(color: Colors.white30, fontSize: 14),
                ),
                SizedBox(height: 8),
                Text(
                  'Connect to Gemini Live to see logs',
                  style: TextStyle(color: Colors.white24, fontSize: 12),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: logs.length,
          reverse: true, // Show newest at bottom, auto-scroll
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            // Reverse index to show newest at bottom
            final log = logs[logs.length - 1 - index];
            final isError = log.contains('❌') || log.contains('⛔') || log.contains('FAILURE') || log.contains('REJECTED');
            final isSeparator = log.startsWith('═');
            
            if (isSeparator) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  log,
                  style: const TextStyle(
                    color: Colors.amber,
                    fontFamily: 'monospace',
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: SelectableText(
                log,
                style: TextStyle(
                  color: isError ? Colors.redAccent : Colors.greenAccent.shade100,
                  fontFamily: 'monospace',
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
