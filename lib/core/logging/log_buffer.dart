import 'package:flutter/foundation.dart';

class LogBuffer {
  static final LogBuffer instance = LogBuffer._();
  LogBuffer._();

  final List<String> _logs = [];
  final List<VoiceTestLogEntry> _structuredLogs = [];
  final int _maxLogs = 1000;

  List<String> get logs => List.unmodifiable(_logs);
  List<VoiceTestLogEntry> get structuredLogs => List.unmodifiable(_structuredLogs);

  void addLog(String log) {
    if (_logs.length >= _maxLogs) _logs.removeAt(0);
    // Add timestamp if not present
    String entry = log;
    if (!log.trim().startsWith('[')) {
        final timestamp = DateTime.now().toIso8601String().split('T').last.substring(0, 8);
        entry = '[$timestamp] $log';
    }
    _logs.add(entry);
  }

  void logVoiceTest(VoiceTestLogEntry entry) {
    _structuredLogs.add(entry);
    addLog('🧪 Voice Test: ${entry.provider} - ${entry.success ? "Success" : "Failed"} (${entry.latencyMs}ms)');
  }

  void clear() {
    _logs.clear();
    _structuredLogs.clear();
  }
}

class VoiceTestLogEntry {
  final String provider;
  final int latencyMs;
  final bool success;
  final String error;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;

  VoiceTestLogEntry({
    required this.provider,
    required this.latencyMs,
    required this.success,
    this.error = '',
    this.metadata = const {},
    required this.timestamp,
  });
}
