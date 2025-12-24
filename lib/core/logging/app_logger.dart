import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Structured Logging Service for The Pact
/// 
/// Phase 32: Robustness Implementation
/// 
/// Provides severity-tagged logging with structured output for:
/// - Production debugging
/// - Error tracking
/// - Performance monitoring
/// 
/// Usage:
/// ```dart
/// final logger = AppLogger('AuthService');
/// logger.info('User signed in', {'userId': '123'});
/// logger.warning('Token expiring soon', {'expiresIn': '5m'});
/// logger.error('Sign-in failed', {'error': e.toString()}, stackTrace);
/// ```
class AppLogger {
  final String tag;
  
  /// Creates a logger instance with a specific tag (usually the class name).
  AppLogger(this.tag);
  
  /// Log levels for structured logging.
  static const String _levelDebug = 'DEBUG';
  static const String _levelInfo = 'INFO';
  static const String _levelWarning = 'WARNING';
  static const String _levelError = 'ERROR';
  
  /// Debug-level logging. Only shown in debug builds.
  void debug(String message, [Map<String, dynamic>? context]) {
    if (kDebugMode) {
      _log(_levelDebug, message, context);
    }
  }
  
  /// Info-level logging. General operational information.
  void info(String message, [Map<String, dynamic>? context]) {
    _log(_levelInfo, message, context);
  }
  
  /// Warning-level logging. Potential issues that don't break functionality.
  void warning(String message, [Map<String, dynamic>? context]) {
    _log(_levelWarning, message, context);
  }
  
  /// Error-level logging. Failures that need attention.
  /// 
  /// Automatically captures and formats stack traces.
  void error(String message, [Map<String, dynamic>? context, StackTrace? stackTrace]) {
    _log(_levelError, message, context, stackTrace);
  }
  
  /// Internal logging method that formats and outputs the log entry.
  void _log(String level, String message, [Map<String, dynamic>? context, StackTrace? stackTrace]) {
    final timestamp = DateTime.now().toIso8601String();
    final contextStr = context != null ? ' | ${_formatContext(context)}' : '';
    final logMessage = '[$timestamp] [$level] [$tag] $message$contextStr';
    
    // Use developer.log for structured output in DevTools
    developer.log(
      logMessage,
      name: tag,
      level: _levelToInt(level),
      stackTrace: stackTrace,
    );
    
    // Also print to console in debug mode for visibility
    if (kDebugMode) {
      final emoji = _levelToEmoji(level);
      debugPrint('$emoji $logMessage');
      if (stackTrace != null) {
        debugPrint('Stack trace:\n$stackTrace');
      }
    }
  }
  
  /// Formats context map into a readable string.
  String _formatContext(Map<String, dynamic> context) {
    return context.entries.map((e) => '${e.key}=${e.value}').join(', ');
  }
  
  /// Converts log level to an integer for developer.log.
  int _levelToInt(String level) {
    switch (level) {
      case _levelDebug:
        return 500;
      case _levelInfo:
        return 800;
      case _levelWarning:
        return 900;
      case _levelError:
        return 1000;
      default:
        return 800;
    }
  }
  
  /// Returns an emoji for visual distinction in console output.
  String _levelToEmoji(String level) {
    switch (level) {
      case _levelDebug:
        return '🔍';
      case _levelInfo:
        return 'ℹ️';
      case _levelWarning:
        return '⚠️';
      case _levelError:
        return '❌';
      default:
        return '📝';
    }
  }
}

/// Mixin for classes that need logging capabilities.
/// 
/// Usage:
/// ```dart
/// class AuthService with Loggable {
///   @override
///   String get logTag => 'AuthService';
///   
///   void signIn() {
///     logger.info('Attempting sign-in');
///   }
/// }
/// ```
mixin Loggable {
  String get logTag;
  
  late final AppLogger logger = AppLogger(logTag);
}

/// Function timing decorator for performance monitoring.
/// 
/// Usage:
/// ```dart
/// final result = await timeAsync('fetchUserData', () => api.getUser());
/// ```
Future<T> timeAsync<T>(String operationName, Future<T> Function() operation, [AppLogger? logger]) async {
  final stopwatch = Stopwatch()..start();
  final log = logger ?? AppLogger('Timer');
  
  try {
    final result = await operation();
    stopwatch.stop();
    log.debug('$operationName completed', {'duration': '${stopwatch.elapsedMilliseconds}ms'});
    return result;
  } catch (e, stackTrace) {
    stopwatch.stop();
    log.error('$operationName failed', {
      'duration': '${stopwatch.elapsedMilliseconds}ms',
      'error': e.toString(),
    }, stackTrace);
    rethrow;
  }
}

/// Synchronous timing decorator.
T timeSync<T>(String operationName, T Function() operation, [AppLogger? logger]) {
  final stopwatch = Stopwatch()..start();
  final log = logger ?? AppLogger('Timer');
  
  try {
    final result = operation();
    stopwatch.stop();
    log.debug('$operationName completed', {'duration': '${stopwatch.elapsedMilliseconds}ms'});
    return result;
  } catch (e, stackTrace) {
    stopwatch.stop();
    log.error('$operationName failed', {
      'duration': '${stopwatch.elapsedMilliseconds}ms',
      'error': e.toString(),
    }, stackTrace);
    rethrow;
  }
}
