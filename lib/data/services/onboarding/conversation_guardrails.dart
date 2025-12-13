/// Guardrails for AI conversation flow
/// 
/// Implements frustration detection and escape hatch logic
/// to ensure users can always fall back to manual input.
class ConversationGuardrails {
  /// Patterns that indicate the user wants to exit AI flow
  /// These trigger an immediate transition to Manual Mode (Tier 3)
  static const List<String> frustrationPatterns = [
    r'just let me (type|write|fill)',
    r'\bskip\b',
    r'too (long|slow|many)',
    r'\bstupid\b',
    r'this is taking',
    r'can i just',
    r'never mind',
    r'stop asking',
    r'\bmanual\b',
    r'forget it',
    r'i give up',
    r'let me do it',
    r'boring',
    r"(don'?t|doesn'?t) (work|understand)",
  ];

  /// Check if user message indicates frustration
  /// Returns true if any frustration pattern matches
  static bool isFrustrated(String message) {
    final lower = message.toLowerCase().trim();
    
    // Empty or very short messages aren't frustration
    if (lower.length < 3) return false;
    
    for (final pattern in frustrationPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(lower)) {
        return true;
      }
    }
    return false;
  }

  /// Message shown when transitioning to manual mode
  static const String escapeHatchMessage = 
    "I sense I might be slowing you down. Let's switch to the quick form instead — "
    "you can fill in the details directly. No problem at all!";

  /// Message shown when conversation is too long
  static const String conversationTooLongMessage =
    "We've been chatting for a while! Let me show you the quick form "
    "so you can finish setting up your habit.";

  /// Message shown when AI fails
  static const String aiFailureMessage =
    "I'm having trouble connecting right now. Let's use the quick form instead.";

  /// Message shown when rate limited
  static const String rateLimitMessage =
    "Let's slow down a bit. I'll show you the form to continue.";

  /// Check if conversation has gone on too long
  static bool isTooLong(int turnCount, {int maxTurns = 15}) {
    return turnCount >= maxTurns;
  }

  /// Validate that a message is appropriate to send
  static MessageValidation validateMessage(String message) {
    final trimmed = message.trim();
    
    if (trimmed.isEmpty) {
      return MessageValidation.empty;
    }
    
    if (trimmed.length > 2000) {
      return MessageValidation.tooLong;
    }
    
    if (isFrustrated(trimmed)) {
      return MessageValidation.frustrated;
    }
    
    return MessageValidation.valid;
  }
}

/// Result of message validation
enum MessageValidation {
  valid,
  empty,
  tooLong,
  frustrated,
}

/// Extension for validation display messages
extension MessageValidationExtension on MessageValidation {
  String? get errorMessage {
    switch (this) {
      case MessageValidation.valid:
        return null;
      case MessageValidation.empty:
        return 'Please type a message';
      case MessageValidation.tooLong:
        return 'Message is too long';
      case MessageValidation.frustrated:
        return null; // Handled by escape hatch, not an error
    }
  }
}
