/// Centralised notification IDs for the app
/// Prevents ID collisions and makes intent clear
class NotificationIds {
  // Private constructor to prevent instantiation
  NotificationIds._();

  /// Daily habit reminder (repeating)
  static const int dailyReminder = 1001;

  /// One-off snooze reminder (30 minutes later)
  static const int snoozeReminder = 1002;

  /// Test notification (for debugging)
  static const int test = 9999;
}
