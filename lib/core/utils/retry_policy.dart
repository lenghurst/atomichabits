import 'dart:async';
import 'dart:math';

/// RetryPolicy - Standardized retry logic with exponential backoff
///
/// Implements the Strategy pattern for handling failures.
/// supports configurable backoff, max attempts, and jitter.
class RetryPolicy {
  final int maxAttempts;
  final Duration initialDelay;
  final double backoffFactor;
  final bool useJitter;
  final bool Function(dynamic error)? retryIf;

  const RetryPolicy({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.backoffFactor = 2.0,
    this.useJitter = true,
    this.retryIf,
  });

  /// Execute an operation with retry logic
  Future<T> execute<T>(Future<T> Function() operation) async {
    int attempts = 0;
    while (true) {
      try {
        attempts++;
        return await operation();
      } catch (e) {
        // Check if we should stop
        if (attempts >= maxAttempts) rethrow;

        // Check conditional retry
        if (retryIf != null && !retryIf!(e)) rethrow;

        // Calculate delay with exponential backoff
        var delay = initialDelay * pow(backoffFactor, attempts - 1);

        // Add jitter to prevent thundering herd
        if (useJitter) {
          final random = Random();
          // +/- 20% jitter
          final jitterMs = delay.inMilliseconds * 0.2;
          final maxRange = (jitterMs * 2).toInt();
          if (maxRange > 0) {
            final offset = random.nextInt(maxRange) - jitterMs;
            delay = Duration(
                milliseconds: max(0, delay.inMilliseconds + offset.toInt()));
          }
        }

        await Future.delayed(delay);
      }
    }
  }

  /// Predefined strategies
  static const RetryPolicy noRetry = RetryPolicy(maxAttempts: 1);

  static const RetryPolicy network = RetryPolicy(
    maxAttempts: 3,
    initialDelay: Duration(seconds: 1),
    backoffFactor: 2.0,
    useJitter: true,
  );

  static const RetryPolicy aggressive = RetryPolicy(
    maxAttempts: 5,
    initialDelay: Duration(milliseconds: 500),
    backoffFactor: 1.5,
    useJitter: true,
  );
}
