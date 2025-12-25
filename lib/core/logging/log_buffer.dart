// lib/core/logging/log_buffer.dart
// Phase 39: Logging Consolidation - Enhanced LogBuffer with structured entries
//
// This singleton acts as a centralized logging buffer for the entire app.
// It stores the last 1000 log entries and notifies listeners when new logs arrive.
// Now integrated with AppLogger for unified logging.

import 'package:flutter/foundation.dart';

/// Log severity levels for structured logging
/// Phase 39: Unified with AppLogger
enum LogLevel { debug, info, warning, error }

/// Structured log entry for the in-app console
/// Phase 39: Enhanced with level and context support
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String tag;
  final String message;
  final Map<String, dynamic>? context;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.tag,
    required this.message,
    this.context,
  });

  /// Format the entry for display in the console
  String toDisplayString() {
    final time = '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}.'
        '${timestamp.millisecond.toString().padLeft(3, '0')}';
    final emoji = _levelEmoji;
    final contextStr = context != null && context!.isNotEmpty 
        ? ' | ${context!.entries.map((e) => '${e.key}=${e.value}').join(', ')}'
        : '';
    return '[$time] $emoji [$tag] $message$contextStr';
  }

  String get _levelEmoji {
    switch (level) {
      case LogLevel.debug:
        return '🐛';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '🚨';
    }
  }

  bool get isError => level == LogLevel.error || level == LogLevel.warning;
}

/// Centralized log buffer for the in-app debug console
/// 
/// Phase 39: Logging Consolidation
/// 
/// This singleton stores the last [_maxLogs] entries and notifies
/// listeners when new logs are added. Used by DebugConsoleView.
/// 
/// Usage:
/// ```dart
/// LogBuffer.instance.add('GeminiLive', 'Connecting...', level: LogLevel.info);
/// ```
class LogBuffer {
  // Singleton pattern
  static final LogBuffer instance = LogBuffer._();
  LogBuffer._();

  // For backward compatibility
  factory LogBuffer() => instance;

  final List<LogEntry> _logs = [];
  static const int _maxLogs = 1000;

  /// Notifier for UI updates (DebugConsoleView listens to this)
  final ValueNotifier<int> notifyListeners = ValueNotifier(0);

  /// Add a log entry to the buffer
  /// 
  /// [tag] - The source component (e.g., 'GeminiLive', 'Auth')
  /// [message] - The log message
  /// [level] - Severity level (default: info)
  /// [context] - Optional structured context data
  void add(String tag, String message, {
    LogLevel level = LogLevel.info,
    Map<String, dynamic>? context,
    bool isError = false, // Backward compatibility
  }) {
    // Handle backward compatibility: isError flag overrides level
    final effectiveLevel = isError ? LogLevel.error : level;

    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: effectiveLevel,
      tag: tag,
      message: message,
      context: context,
    );

    _logs.add(entry);

    if (_logs.length > _maxLogs) {
      _logs.removeAt(0);
    }

    // Notify UI to rebuild
    notifyListeners.value++;

    // Also print to console in debug mode
    if (kDebugMode) {
      debugPrint(entry.toDisplayString());
    }
  }

  /// Add a visual separator (for new connection attempts, etc.)
  void addSeparator([String? label]) {
    final separatorText = label != null 
        ? '═══════════════ $label ═══════════════'
        : '═══════════════════════════════════════════════════';
    add('SYSTEM', separatorText, level: LogLevel.debug);
  }

  /// Get all logs as a single string (for copy-to-clipboard)
  String get allLogs => _logs.map((e) => e.toDisplayString()).join('\n');

  /// Get all log entries (for ListView with structured data)
  List<LogEntry> get entries => List.unmodifiable(_logs);

  /// Get logs as string list (backward compatibility)
  List<String> get logs => _logs.map((e) => e.toDisplayString()).toList();

  /// Get the number of logs
  int get length => _logs.length;

  /// Clear all logs
  void clear() {
    _logs.clear();
    notifyListeners.value++;
  }

  /// Get logs filtered by level
  List<LogEntry> getByLevel(LogLevel level) {
    return _logs.where((e) => e.level == level).toList();
  }

  /// Get only error logs
  List<LogEntry> get errors => _logs.where((e) => e.isError).toList();
}
