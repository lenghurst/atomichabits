import 'package:flutter/foundation.dart';
import 'log_buffer.dart';

class AppLogger {
  static bool globalEnabled = true;

  static void debug(String message) => _log('🐛 $message');
  static void info(String message) => _log('ℹ️ $message');
  static void warning(String message) => _log('⚠️ $message');
  static void error(String message) => _log('❌ $message');

  static void _log(String message) {
    if (!globalEnabled && !kDebugMode) return;
    debugPrint(message); // Prints to IDE console
    LogBuffer.instance.addLog(message); // Adds to in-app Debug Console
  }
}
