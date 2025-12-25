// lib/core/logging/app_logger.dart
// Phase 39: Logging Consolidation - Unified AppLogger
//
// This is the PRIMARY logging system for The Pact.
// All logs go through AppLogger, which writes to:
// 1. LogBuffer (for in-app debug console)
// 2. Dart developer.log (for DevTools)
// 3. Console print (in debug mode)

import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'log_buffer.dart';

/// Structured Logging Service for The Pact
/// 
/// Phase 39: Logging Consolidation
/// 
/// Provides severity-tagged logging with structured output for:
/// - In-app debug console (LogBuffer)
/// - DevTools (developer.log)
/// - Console output (debugPrint)
/// 
/// Usage:
/// ```dart
/// final logger = AppLogger('AuthService');
/// logger.info('User signed in', {'userId': '123'});
/// logger.warning('Token expiring soon', {'expiresIn': '5m'});
/// logger.error('Sign-in failed', e, stackTrace, {'userId': '123'});
/// ```
class AppLogger {
  final String tag;
  
  /// Global flag to enable/disable all logging
  static bool globalEnabled = true;

  /// Creates a logger instance with a specific tag (usually the class name).
  const AppLogger(this.tag);

  /// Debug-level logging. Only shown in debug builds.
  void debug(String message, [Map<String, dynamic>? context]) {
    _log(LogLevel.debug, message, context);
  }

  /// Info-level logging. General operational information.
  void info(String message, [Map<String, dynamic>? context]) {
    _log(LogLevel.info, message, context);
  }

  /// Warning-level logging. Potential issues that don't break functionality.
  void warning(String message, [Map<String, dynamic>? context]) {
    _log(LogLevel.warning, message, context);
  }

  /// Error-level logging. Failures that need attention.
  /// 
  /// Automatically captures and formats stack traces.
  void error(String message, [dynamic error, StackTrace? stackTrace, Map<String, dynamic>? context]) {
    final mergedContext = Map<String, dynamic>.from(context ?? {});
    if (error != null) mergedContext['error'] = error.toString();
    
    _log(LogLevel.error, message, mergedContext, stackTrace);
  }

  /// Internal logging method that formats and outputs the log entry.
  void _log(LogLevel level, String message, [Map<String, dynamic>? context, StackTrace? stackTrace]) {
    // Check if logging is enabled
    if (!globalEnabled && !kDebugMode) return;

    // 1. Send to In-App Console (LogBuffer)
    LogBuffer.instance.add(
      tag, 
      message, 
      level: level, 
      context: context,
    );

    // 2. Send to System Console (Dart Developer Log)
    developer.log(
      message,
      name: tag,
      level: _levelToInt(level),
      error: context?['error'],
      stackTrace: stackTrace,
      time: DateTime.now(),
    );

    // 3. Print stack trace in debug mode if present
    if (stackTrace != null && kDebugMode) {
      debugPrint('Stack trace:\n$stackTrace');
    }
  }

  /// Converts log level to an integer for developer.log.
  int _levelToInt(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
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
    log.error('$operationName failed', e, stackTrace, {
      'duration': '${stopwatch.elapsedMilliseconds}ms',
    });
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
    log.error('$operationName failed', e, stackTrace, {
      'duration': '${stopwatch.elapsedMilliseconds}ms',
    });
    rethrow;
  }
}
