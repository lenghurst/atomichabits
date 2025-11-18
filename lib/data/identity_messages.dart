/// Local identity messages for completion feedback
/// Based on Atomic Habits principle: "Every action is a vote for the person you want to become"
///
/// These messages are shown after completion to reinforce identity-based habits.
/// No AI required - all messages are local and deterministic.

class IdentityMessages {
  /// Generic messages for standard completions
  static const List<String> genericIdentityMessages = [
    "That's another small vote for the person you're becoming.",
    "Tiny actions like this quietly reshape who you are.",
    "Small choices, big identity shifts.",
    "You're proving to yourself who you are, one small action at a time.",
    "This is what people like you do—and you just did it.",
    "Identity isn't born, it's built. You just added another brick.",
  ];

  /// Messages for coming back after a miss (yesterday was missed)
  static const List<String> comebackMessages = [
    "You picked it back up. That matters more than a perfect streak.",
    "Coming back after a miss is how real habits are built.",
    "The identity you're building doesn't require perfection.",
    "You showed up again. That's the real habit.",
    "Missing yesterday doesn't erase who you're becoming today.",
  ];

  /// Messages for consistency (streak >= threshold)
  static const List<String> consistencyMessages = [
    "This kind of consistency is how identities become automatic.",
    "People like you just do this now—it's becoming part of you.",
    "Your identity is showing in your actions.",
    "You're not trying to build this habit any more. You're just being who you are.",
    "Consistency like this quietly becomes who you are.",
  ];

  /// Get an appropriate message based on context
  ///
  /// [currentStreak] - Current consecutive days
  /// [wasPreviousDayMissed] - Whether yesterday was not completed
  /// [messageIndex] - Which message to show (cycles through)
  static String getMessage({
    required int currentStreak,
    required bool wasPreviousDayMissed,
    int messageIndex = 0,
  }) {
    // Determine message category
    if (wasPreviousDayMissed && currentStreak == 1) {
      // Comeback scenario: missed yesterday, back today
      return comebackMessages[messageIndex % comebackMessages.length];
    } else if (currentStreak >= 7) {
      // Consistency scenario: 7+ day streak
      return consistencyMessages[messageIndex % consistencyMessages.length];
    } else {
      // Generic scenario
      return genericIdentityMessages[messageIndex % genericIdentityMessages.length];
    }
  }
}
