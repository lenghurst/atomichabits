/// Date Utility Functions for Habit Tracking
/// 
/// Centralizes all date comparison and manipulation logic
/// to avoid duplication across the codebase.

class HabitDateUtils {
  /// Checks if two dates are the same day (ignoring time)
  static bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
  
  /// Checks if date is today
  static bool isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return isSameDay(date, now);
  }
  
  /// Checks if date is yesterday
  static bool isYesterday(DateTime? date) {
    if (date == null) return false;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }
  
  /// Checks if date is within the last N days (inclusive)
  static bool isWithinLastDays(DateTime? date, int days) {
    if (date == null) return false;
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return date.isAfter(cutoff) || isSameDay(date, cutoff);
  }
  
  /// Gets number of days between two dates (absolute value)
  static int daysBetween(DateTime from, DateTime to) {
    final fromNormalized = DateTime(from.year, from.month, from.day);
    final toNormalized = DateTime(to.year, to.month, to.day);
    return toNormalized.difference(fromNormalized).inDays.abs();
  }
  
  /// Gets the start of today (midnight)
  static DateTime startOfToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
  
  /// Gets the start of a specific day (midnight)
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
  
  /// Gets the end of today (23:59:59)
  static DateTime endOfToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  }
  
  /// Gets the start of this week (Monday)
  static DateTime startOfWeek() {
    final now = DateTime.now();
    final daysSinceMonday = now.weekday - 1;
    return DateTime(now.year, now.month, now.day - daysSinceMonday);
  }
  
  /// Gets the start of this month
  static DateTime startOfMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }
  
  /// Generates a list of dates between start and end (inclusive)
  static List<DateTime> dateRange(DateTime start, DateTime end) {
    final dates = <DateTime>[];
    var current = startOfDay(start);
    final endNormalized = startOfDay(end);
    
    while (!current.isAfter(endNormalized)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    
    return dates;
  }
  
  /// Gets the last 7 days (including today)
  static List<DateTime> lastSevenDays() {
    final today = startOfToday();
    return List.generate(7, (i) => today.subtract(Duration(days: i)));
  }
  
  /// Gets the last 30 days (including today)
  static List<DateTime> lastThirtyDays() {
    final today = startOfToday();
    return List.generate(30, (i) => today.subtract(Duration(days: i)));
  }
  
  /// Formats a duration in a human-readable way
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays == 1 ? '' : 's'}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours == 1 ? '' : 's'}';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minute${duration.inMinutes == 1 ? '' : 's'}';
    } else {
      return 'just now';
    }
  }
  
  /// Formats a date relative to today
  static String formatRelativeDate(DateTime date) {
    final today = startOfToday();
    final dateNormalized = startOfDay(date);
    final difference = today.difference(dateNormalized).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';
    if (difference < 14) return 'Last week';
    if (difference < 30) return '${(difference / 7).round()} weeks ago';
    if (difference < 60) return 'Last month';
    return '${(difference / 30).round()} months ago';
  }
  
  /// Gets the day of week name
  static String dayOfWeekName(DateTime date, {bool abbreviated = false}) {
    const fullNames = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 
      'Friday', 'Saturday', 'Sunday'
    ];
    const shortNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    final index = date.weekday - 1;
    return abbreviated ? shortNames[index] : fullNames[index];
  }
  
  /// Gets the month name
  static String monthName(DateTime date, {bool abbreviated = false}) {
    const fullNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const shortNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    final index = date.month - 1;
    return abbreviated ? shortNames[index] : fullNames[index];
  }
  
  /// Parses a time string (HH:MM) to TimeOfDay-like values
  static ({int hour, int minute}) parseTimeString(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length != 2) {
      return (hour: 9, minute: 0); // Default
    }
    return (
      hour: int.tryParse(parts[0]) ?? 9,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }
  
  /// Formats hour and minute to HH:MM string
  static String formatTimeString(int hour, int minute) {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
  
  /// Checks if a time has passed today
  static bool hasTimePassedToday(String timeStr) {
    final parsed = parseTimeString(timeStr);
    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year, now.month, now.day, 
      parsed.hour, parsed.minute,
    );
    return now.isAfter(scheduledTime);
  }
  
  /// Gets time until a specific time today (or tomorrow if passed)
  static Duration timeUntil(String timeStr) {
    final parsed = parseTimeString(timeStr);
    final now = DateTime.now();
    var scheduledTime = DateTime(
      now.year, now.month, now.day, 
      parsed.hour, parsed.minute,
    );
    
    // If time has passed, calculate for tomorrow
    if (now.isAfter(scheduledTime)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }
    
    return scheduledTime.difference(now);
  }
}
