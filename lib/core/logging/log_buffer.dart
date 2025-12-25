// lib/core/logging/log_buffer.dart
// Phase 38: In-App Log Console - The "Black Box" Recorder
//
// This singleton acts as a centralized logging buffer for the entire app.
// It stores the last 1000 log entries and notifies listeners when new logs arrive.
// Perfect for debugging Gemini Live connection issues in production.

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// Centralized log buffer for debugging.
/// 
/// Usage:
/// ```dart
/// LogBuffer().add('GeminiLive', '🚀 Starting connection...');
/// LogBuffer().add('GeminiLive', '❌ Connection failed', isError: true);
/// ```
class LogBuffer {
  // Singleton pattern
  static final LogBuffer _instance = LogBuffer._internal();
  factory LogBuffer() => _instance;
  LogBuffer._internal();

  final List<String> _logs = [];
  final int _maxLogs = 1000;
  
  /// Notifies listeners when logs change (for UI rebuilds)
  final ValueNotifier<int> notifyListeners = ValueNotifier(0);

  /// Add a log entry with timestamp, source, and optional error flag.
  /// 
  /// [source] - The component name (e.g., 'GeminiLive', 'Auth', 'Network')
  /// [message] - The log message
  /// [isError] - If true, marks the log as an error (red in UI)
  void add(String source, String message, {bool isError = false}) {
    final timestamp = DateFormat('HH:mm:ss.SSS').format(DateTime.now());
    final icon = isError ? '❌' : 'ℹ️';
    final logEntry = '[$timestamp] $icon [$source] $message';
    
    _logs.add(logEntry);
    if (_logs.length > _maxLogs) {
      _logs.removeAt(0);
    }
    
    // Notify UI to rebuild
    notifyListeners.value++;
    
    // Also print to console in debug mode
    if (kDebugMode) {
      // ignore: avoid_print
      print(logEntry);
    }
  }

  /// Get all logs as a single string (for clipboard copy)
  String get allLogs => _logs.join('\n');
  
  /// Get logs as a list (for ListView)
  List<String> get logs => List.unmodifiable(_logs);
  
  /// Get the number of logs
  int get length => _logs.length;
  
  /// Clear all logs
  void clear() {
    _logs.clear();
    notifyListeners.value++;
  }
  
  /// Add a separator line (useful for marking connection attempts)
  void addSeparator([String? label]) {
    final separator = label != null 
        ? '═══════════════ $label ═══════════════'
        : '════════════════════════════════════════';
    _logs.add(separator);
    notifyListeners.value++;
  }
}
