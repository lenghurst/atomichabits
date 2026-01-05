import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Standardized error handler for onboarding flows.
class OnboardingErrorHandler {
  static void handle(
    BuildContext context, 
    Object error, {
    String? fallbackMessage,
    VoidCallback? onRetry,
  }) {
    final message = fallbackMessage ?? 'Something went wrong. Please try again.';
    
    // Ensure we don't try to show snackbar if context is not valid
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: onRetry != null 
          ? SnackBarAction(label: 'Retry', onPressed: onRetry)
          : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    if (kDebugMode) {
      debugPrint('[OnboardingError] $error');
    }
  }
}
