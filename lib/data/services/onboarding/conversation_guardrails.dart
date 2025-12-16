/// Guardrails for AI conversation flow
/// 
/// Phase 17: "Brain Surgery" Enhanced Guardrails
/// 
/// Implements:
/// - Frustration detection and escape hatch
/// - Habit size enforcement (2-minute rule)
/// - Specificity validation
/// - Multiple habit prevention
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

  /// Patterns indicating a habit is too big (violates 2-minute rule)
  /// Phase 17: "Brain Surgery" - Hard constraint enforcement
  static const List<String> oversizedHabitPatterns = [
    r'\d+\s*(hour|hr)s?',           // "1 hour", "2 hours"
    r'(\d{2,}|[3-9])\s*min',        // "30 min", "45 min"
    r'half\s*(an?\s*)hour',         // "half hour"
    r'(a|one|1)\s*chapter',         // "a chapter"
    r'(a|one|1)\s*(full|whole)',    // "a full workout"
    r'(complete|finish|entire)',    // "complete the book"
    r'(morning|evening)\s*routine', // "morning routine"
    r'(deep\s+)?work\s+(session|block)', // "deep work session"
    r'full\s*(body\s+)?(workout|exercise)', // "full workout"
  ];

  /// Patterns indicating vague habits that need specificity
  static const List<String> vagueHabitPatterns = [
    r'^(exercise|workout)\s*more$',
    r'^be\s+(more\s+)?(healthy|productive|focused)$',
    r'^(eat|sleep|work)\s+better$',
    r'^(lose|gain)\s+\d+\s*(pounds?|kg|lbs?)$',
    r'^get\s+(fit|strong|thin)$',
    r'^improve\s+(my\s+)?\w+$',
    r'^(start|begin)\s+\w+ing$',
  ];

  /// Patterns indicating user wants multiple habits
  static const List<String> multipleHabitPatterns = [
    r'\b(and|also|plus)\b.*\b(habit|exercise|read|meditate|run|write)\b',
    r'(\d+|several|multiple|few)\s+habits',
    r'(first|then|also|and then)\s+I',
    r',\s*(and|then)\s+',
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

  /// Check if a habit description is too big (violates 2-minute rule)
  /// Phase 17: Hard constraint - AI should reject these
  static bool isOversizedHabit(String habitDescription) {
    final lower = habitDescription.toLowerCase();
    for (final pattern in oversizedHabitPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(lower)) {
        return true;
      }
    }
    return false;
  }

  /// Check if a habit description is too vague
  static bool isVagueHabit(String habitDescription) {
    final lower = habitDescription.toLowerCase().trim();
    for (final pattern in vagueHabitPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(lower)) {
        return true;
      }
    }
    return false;
  }

  /// Check if user is trying to create multiple habits
  static bool isMultipleHabits(String habitDescription) {
    final lower = habitDescription.toLowerCase();
    for (final pattern in multipleHabitPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(lower)) {
        return true;
      }
    }
    return false;
  }

  /// Validate a habit description and return specific feedback
  /// Phase 17: Returns guidance for AI to use in response
  static HabitGuardrailResult validateHabit(String habitDescription) {
    if (isMultipleHabits(habitDescription)) {
      return HabitGuardrailResult(
        type: HabitGuardrailType.multiple,
        guidance: "Let's focus on ONE habit first. Which matters most right now?",
      );
    }

    if (isOversizedHabit(habitDescription)) {
      return HabitGuardrailResult(
        type: HabitGuardrailType.oversized,
        guidance: "That sounds too big for a tiny habit. What's the 2-minute version you could do on your worst day?",
      );
    }

    if (isVagueHabit(habitDescription)) {
      return HabitGuardrailResult(
        type: HabitGuardrailType.vague,
        guidance: "That's a bit vague. What's ONE specific action you'll take?",
      );
    }

    return HabitGuardrailResult(type: HabitGuardrailType.valid);
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

  /// Message shown when habit is too big
  static const String habitTooBigMessage =
    "That habit sounds too big to start with. Let's make it smaller — "
    "what's the 2-minute version you could do even on your worst day?";

  /// Message shown when habit is too vague
  static const String habitTooVagueMessage =
    "That's a great goal, but let's make it specific. "
    "What's ONE action you'll take? When and where?";

  /// Message shown when user tries multiple habits
  static const String multipleHabitsMessage =
    "I love the ambition! But research shows starting with ONE habit "
    "is 3x more effective. Which one matters most right now?";

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

/// Result of habit guardrail validation
class HabitGuardrailResult {
  final HabitGuardrailType type;
  final String? guidance;

  const HabitGuardrailResult({
    required this.type,
    this.guidance,
  });

  bool get isValid => type == HabitGuardrailType.valid;
  bool get needsCorrection => type != HabitGuardrailType.valid;
}

/// Types of habit guardrail issues
enum HabitGuardrailType {
  valid,
  oversized,
  vague,
  multiple,
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
