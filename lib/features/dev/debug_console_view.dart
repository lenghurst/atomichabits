// lib/features/dev/debug_console_view.dart
// Phase 39: Logging Consolidation - Enhanced Debug Console
//
// This widget displays the centralized log buffer in a terminal-like UI.
// Features:
// - Real-time log updates via ValueListenableBuilder
// - Level-based coloring (debug, info, warning, error)
// - One-click copy to clipboard
// - Clear logs button
// - Auto-scroll to latest logs

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/logging/log_buffer.dart';

/// A terminal-like debug console for viewing live logs.
/// 
/// Phase 39: Now uses structured LogEntry with level-based coloring.
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
            'DEBUG CONSOLE',
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
            valueListenable: LogBuffer.instance.notifyListeners,
            builder: (context, _, __) {
              final errorCount = LogBuffer.instance.errors.length;
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${LogBuffer.instance.length} logs',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  if (errorCount > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.shade900,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$errorCount errors',
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          
          const SizedBox(width: 8),
          
          // Copy All button
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.white70, size: 20),
            tooltip: 'Copy All Logs',
            onPressed: () {
              final logs = LogBuffer.instance.allLogs;
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
              LogBuffer.instance.clear();
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
      valueListenable: LogBuffer.instance.notifyListeners,
      builder: (context, _, __) {
        final entries = LogBuffer.instance.entries;
        
        if (entries.isEmpty) {
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
                  'Logs will appear here automatically',
                  style: TextStyle(color: Colors.white24, fontSize: 12),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: entries.length,
          reverse: true, // Show newest at bottom, auto-scroll
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            // Reverse index to show newest at bottom
            final entry = entries[entries.length - 1 - index];
            final displayText = entry.toDisplayString();
            
            // Check if it's a separator
            if (entry.tag == 'SYSTEM' && displayText.contains('═')) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  entry.message,
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
                displayText,
                style: TextStyle(
                  color: _getColorForLevel(entry.level),
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

  /// Get the appropriate color for a log level
  Color _getColorForLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return Colors.grey.shade500;
      case LogLevel.info:
        return Colors.greenAccent.shade100;
      case LogLevel.warning:
        return Colors.orange.shade300;
      case LogLevel.error:
        return Colors.redAccent;
    }
  }
}
