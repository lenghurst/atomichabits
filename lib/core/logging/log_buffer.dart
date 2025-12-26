import 'package:flutter/foundation.dart';

class LogBuffer {
  static final LogBuffer instance = LogBuffer._();
  LogBuffer._();

  final List<String> _logs = [];
  final int _maxLogs = 1000;

  List<String> get logs => List.unmodifiable(_logs);

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

  void clear() => _logs.clear();
}
