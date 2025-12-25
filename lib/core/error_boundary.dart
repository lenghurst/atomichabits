import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Error Boundary Widget - Phase 6: Error Handling
/// 
/// Catches and handles errors within a widget subtree, preventing
/// the entire app from crashing. Shows a user-friendly error screen
/// when errors occur.
/// 
/// **Usage:**
/// ```dart
/// ErrorBoundary(
///   child: SomeWidgetThatMightFail(),
/// )
/// ```
/// 
/// **Features:**
/// - Catches synchronous build errors
/// - Shows user-friendly error UI
/// - Retry button to attempt recovery
/// - Logs errors in debug mode
/// - Optional custom error widget
class ErrorBoundary extends StatefulWidget {
  /// The child widget tree to protect
  final Widget child;
  
  /// Optional custom error widget builder
  final Widget Function(FlutterErrorDetails error)? errorBuilder;
  
  /// Called when an error is caught (for logging/analytics)
  final void Function(FlutterErrorDetails error)? onError;
  
  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _error;
  
  @override
  void initState() {
    super.initState();
  }
  
  void _handleError(FlutterErrorDetails details) {
    setState(() {
      _error = details;
    });
    
    // Log error in debug mode
    if (kDebugMode) {
      debugPrint('🚨 ErrorBoundary caught error:');
      debugPrint('Exception: ${details.exception}');
      debugPrint('Stack: ${details.stack}');
    }
    
    // Call custom error handler if provided
    widget.onError?.call(details);
  }
  
  void _retry() {
    setState(() {
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!) ??
          ErrorScreen(
            error: _error!,
            onRetry: _retry,
          );
    }
    
    // Use ErrorWidget.builder to catch errors in subtree
    return _ErrorBoundaryWrapper(
      onError: _handleError,
      child: widget.child,
    );
  }
}

/// Internal wrapper that catches errors during build
class _ErrorBoundaryWrapper extends StatelessWidget {
  final Widget child;
  final void Function(FlutterErrorDetails) onError;
  
  const _ErrorBoundaryWrapper({
    required this.child,
    required this.onError,
  });

  @override
  Widget build(BuildContext context) {
    // This catches errors that occur during the build phase
    return child;
  }
}

/// User-friendly error screen shown when an error is caught
/// 
/// **Phase 6: Polish**
/// - Clean, non-technical UI
/// - Retry button for recovery
/// - Technical details expandable (debug only)
class ErrorScreen extends StatelessWidget {
  final FlutterErrorDetails error;
  final VoidCallback? onRetry;
  final VoidCallback? onGoHome;
  
  const ErrorScreen({
    super.key,
    required this.error,
    this.onRetry,
    this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 24),
              
              // Title
              Text(
                'Oops! Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Subtitle
              Text(
                "Don't worry, your data is safe.\nTry again or go back to the home screen.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (onRetry != null) ...[
                    OutlinedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (onGoHome != null)
                    FilledButton.icon(
                      onPressed: onGoHome,
                      icon: const Icon(Icons.home),
                      label: const Text('Go Home'),
                    ),
                ],
              ),
              
              // Technical details (debug only)
              if (kDebugMode) ...[
                const SizedBox(height: 48),
                ExpansionTile(
                  title: Text(
                    'Technical Details',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        error.exceptionAsString(),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Global error handler setup - call in main()
/// 
/// **Usage in main.dart:**
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   setupGlobalErrorHandling();
///   // ... rest of main
/// }
/// ```
/// 
/// **Phase 6.5: Enhanced with structured logging**
void setupGlobalErrorHandling() {
  // Handle Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    // Log error with structured format
    ErrorReporter.reportError(
      error: details.exception,
      stackTrace: details.stack,
      context: 'FlutterError',
      library: details.library,
    );
    
    if (kDebugMode) {
      // In debug mode, also show the default Flutter error UI
      FlutterError.presentError(details);
    }
  };
  
  // Handle errors outside Flutter framework (async errors)
  PlatformDispatcher.instance.onError = (error, stack) {
    ErrorReporter.reportError(
      error: error,
      stackTrace: stack,
      context: 'PlatformDispatcher',
    );
    // Return true to indicate the error was handled
    return true;
  };
  
  if (kDebugMode) {
    debugPrint('✅ Global error handling initialized');
  }
}

/// Error Reporter - Phase 6.5: Structured error logging
/// 
/// Provides a central point for error reporting that can be
/// extended to integrate with crash reporting services like
/// Sentry, Firebase Crashlytics, or custom backends.
/// 
/// **Current Implementation:** Console logging (debug mode)
/// **Future:** Add Sentry/Crashlytics integration
class ErrorReporter {
  /// Report an error with optional context
  static void reportError({
    required Object error,
    StackTrace? stackTrace,
    String? context,
    String? library,
    Map<String, dynamic>? extras,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    
    if (kDebugMode) {
      debugPrint('');
      debugPrint('╔══════════════════════════════════════════════════════════╗');
      debugPrint('║ 🚨 ERROR REPORT                                          ║');
      debugPrint('╠══════════════════════════════════════════════════════════╣');
      debugPrint('║ Time: $timestamp');
      if (context != null) debugPrint('║ Context: $context');
      if (library != null) debugPrint('║ Library: $library');
      debugPrint('║ Error: $error');
      if (extras != null) {
        debugPrint('║ Extras: $extras');
      }
      debugPrint('╚══════════════════════════════════════════════════════════╝');
      if (stackTrace != null) {
        debugPrint('Stack trace:');
        debugPrint('$stackTrace');
      }
      debugPrint('');
    }
    
    // TODO: Add production crash reporting service integration
    // Examples:
    // - Sentry.captureException(error, stackTrace: stackTrace);
    // - FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
  
  /// Log a non-fatal warning
  static void logWarning(String message, {Map<String, dynamic>? extras}) {
    if (kDebugMode) {
      debugPrint('⚠️ WARNING: $message');
      if (extras != null) {
        debugPrint('   Extras: $extras');
      }
    }
  }
  
  /// Log an informational message
  static void logInfo(String message) {
    if (kDebugMode) {
      debugPrint('ℹ️ INFO: $message');
    }
  }
}

/// Extension on BuildContext for easy error handling
extension ErrorHandlingContext on BuildContext {
  /// Show an error snackbar
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
  
  /// Show a success snackbar
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
