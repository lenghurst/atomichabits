import '../models/habit.dart';
import '../models/user_profile.dart';
import '../models/consistency_metrics.dart';

/// Recovery Engine - The "Never Miss Twice" System
/// 
/// This service detects missed habits and provides recovery support,
/// implementing the core philosophy: "Missing once is an accident.
/// Missing twice is the start of a new habit."
/// 
/// Key responsibilities:
/// 1. Detect missed days and calculate miss streaks
/// 2. Generate appropriate recovery prompts based on urgency
/// 3. Track recovery events and success rates
/// 4. Provide compassionate, non-shaming messaging
class RecoveryEngine {
  /// Checks if a habit needs recovery (has missed days)
  static RecoveryNeed? checkRecoveryNeed({
    required Habit habit,
    required UserProfile profile,
    required List<DateTime> completionHistory,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Normalize completion dates
    final completions = completionHistory.map((d) => 
      DateTime(d.year, d.month, d.day)
    ).toSet();
    
    // Check if completed today
    if (completions.contains(today)) {
      return null; // No recovery needed
    }
    
    // Calculate consecutive misses (including today)
    int consecutiveMisses = 1; // Today is already a miss
    var checkDate = today.subtract(const Duration(days: 1));
    
    // Don't count days before habit creation
    final habitStart = DateTime(
      habit.createdAt.year,
      habit.createdAt.month,
      habit.createdAt.day,
    );
    
    while (!completions.contains(checkDate) && 
           checkDate.isAfter(habitStart.subtract(const Duration(days: 1)))) {
      consecutiveMisses++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    
    // If this is a new habit (created today), no recovery needed yet
    if (habitStart == today) {
      return null;
    }
    
    // Generate recovery need
    return RecoveryNeed(
      habit: habit,
      profile: profile,
      daysMissed: consecutiveMisses,
      lastCompletionDate: _findLastCompletion(completions, today),
      urgency: _calculateUrgency(consecutiveMisses),
    );
  }
  
  /// Find the most recent completion date
  static DateTime? _findLastCompletion(Set<DateTime> completions, DateTime beforeDate) {
    if (completions.isEmpty) return null;
    
    final sorted = completions.toList()..sort((a, b) => b.compareTo(a));
    return sorted.firstWhere(
      (d) => d.isBefore(beforeDate),
      orElse: () => sorted.first,
    );
  }
  
  /// Calculate recovery urgency based on consecutive misses
  static RecoveryUrgency _calculateUrgency(int daysMissed) {
    if (daysMissed <= 1) return RecoveryUrgency.gentle;
    if (daysMissed == 2) return RecoveryUrgency.important;
    return RecoveryUrgency.compassionate;
  }
  
  /// Generate recovery message based on urgency and context
  static String getRecoveryMessage(RecoveryNeed need) {
    final habitName = need.habit.name;
    final tinyVersion = need.habit.tinyVersion;
    final identity = need.profile.identity;
    
    switch (need.urgency) {
      case RecoveryUrgency.gentle:
        return _getGentleMessage(habitName, tinyVersion, identity);
      case RecoveryUrgency.important:
        return _getImportantMessage(habitName, tinyVersion, identity);
      case RecoveryUrgency.compassionate:
        return _getCompassionateMessage(habitName, tinyVersion, identity, need.daysMissed);
    }
  }
  
  /// Day 1 miss - gentle "never miss twice" nudge
  static String _getGentleMessage(String habitName, String tinyVersion, String identity) {
    final messages = [
      "Missed yesterday? No drama. Let's not miss two in a row.\n\nYour 2-minute version: \"$tinyVersion\"",
      "One miss is an accident. Two is a pattern.\n\nJust do: \"$tinyVersion\" and you're back on track.",
      "Yesterday didn't happen. Today still can.\n\nYour tiny win: \"$tinyVersion\"",
      "The person who $identity doesn't miss twice.\n\nJust: \"$tinyVersion\"",
    ];
    return messages[DateTime.now().millisecond % messages.length];
  }
  
  /// Day 2 miss - more urgent, last chance
  static String _getImportantMessage(String habitName, String tinyVersion, String identity) {
    final messages = [
      "Two days is the danger zone. But you're here now.\n\nJust \"$tinyVersion\" – that's a win.",
      "This is the critical moment. Miss twice and it gets harder.\n\nYour move: \"$tinyVersion\"",
      "Day 2 is when most people give up. You're not most people.\n\n\"$tinyVersion\" – do it now.",
      "The streak doesn't matter. What matters: not letting two become three.\n\n\"$tinyVersion\"",
    ];
    return messages[DateTime.now().millisecond % messages.length];
  }
  
  /// Day 3+ miss - compassionate re-engagement
  static String _getCompassionateMessage(String habitName, String tinyVersion, String identity, int days) {
    final messages = [
      "Life happens. You're back, and that's what matters.\n\nWhen you're ready: \"$tinyVersion\"\n\nNo judgment. Just start.",
      "You haven't failed. You just paused.\n\nThe person who $identity is still in there.\n\nStart with: \"$tinyVersion\"",
      "It's been $days days. That's okay.\n\nEvery expert was once a beginner who kept coming back.\n\n\"$tinyVersion\" – your fresh start.",
      "Welcome back. The goal isn't perfection – it's persistence.\n\nYour next step: \"$tinyVersion\"",
    ];
    return messages[DateTime.now().millisecond % messages.length];
  }
  
  /// Get the title for recovery prompt based on urgency
  static String getRecoveryTitle(RecoveryUrgency urgency) {
    switch (urgency) {
      case RecoveryUrgency.gentle:
        return "Never Miss Twice";
      case RecoveryUrgency.important:
        return "Day 2 – Critical Moment";
      case RecoveryUrgency.compassionate:
        return "Welcome Back";
    }
  }
  
  /// Get encouraging subtitle based on urgency
  static String getRecoverySubtitle(RecoveryUrgency urgency, int daysMissed) {
    switch (urgency) {
      case RecoveryUrgency.gentle:
        return "One miss doesn't define you";
      case RecoveryUrgency.important:
        return "This is where champions are made";
      case RecoveryUrgency.compassionate:
        return "$daysMissed days away • Ready when you are";
    }
  }
  
  /// Get the action button text based on urgency
  static String getRecoveryActionText(RecoveryUrgency urgency) {
    switch (urgency) {
      case RecoveryUrgency.gentle:
        return "Do the 2-min version now";
      case RecoveryUrgency.important:
        return "Break the pattern – do it now";
      case RecoveryUrgency.compassionate:
        return "Start fresh today";
    }
  }
  
  /// Get icon for recovery urgency
  static String getRecoveryEmoji(RecoveryUrgency urgency) {
    switch (urgency) {
      case RecoveryUrgency.gentle:
        return "💪";
      case RecoveryUrgency.important:
        return "⚡";
      case RecoveryUrgency.compassionate:
        return "🤗";
    }
  }
  
  /// Generate notification message for recovery
  static String getRecoveryNotificationMessage(RecoveryNeed need) {
    switch (need.urgency) {
      case RecoveryUrgency.gentle:
        return "Don't let yesterday become a pattern. Your 2-min version is waiting: ${need.habit.tinyVersion}";
      case RecoveryUrgency.important:
        return "Day 2 is make-or-break. Just ${need.habit.tinyVersion} – that's all it takes to stay on track.";
      case RecoveryUrgency.compassionate:
        return "We miss you! When you're ready, ${need.habit.tinyVersion} is your path back. No pressure.";
    }
  }
  
  /// Calculate statistics about recovery success
  static RecoveryStats calculateRecoveryStats(List<RecoveryEvent> events) {
    if (events.isEmpty) {
      return RecoveryStats(
        totalRecoveries: 0,
        quickRecoveries: 0,
        averageRecoveryDays: 0,
        longestGap: 0,
        recoveryRate: 1.0, // Optimistic default
      );
    }
    
    final quickRecoveries = events.where((e) => e.isQuickRecovery).length;
    final totalDaysMissed = events.fold<int>(0, (sum, e) => sum + e.daysMissed);
    final longestGap = events.fold<int>(0, (max, e) => e.daysMissed > max ? e.daysMissed : max);
    
    return RecoveryStats(
      totalRecoveries: events.length,
      quickRecoveries: quickRecoveries,
      averageRecoveryDays: totalDaysMissed / events.length,
      longestGap: longestGap,
      recoveryRate: events.isNotEmpty ? quickRecoveries / events.length : 1.0,
    );
  }
  
  /// Get a "zoom out" perspective message
  static String getZoomOutMessage({
    required int totalDays,
    required int completedDays,
    required int currentMissStreak,
  }) {
    final completionRate = totalDays > 0 ? (completedDays / totalDays * 100).round() : 0;
    
    if (currentMissStreak == 1) {
      return "In the context of $totalDays days, today is just 1. "
             "You've shown up $completedDays times ($completionRate%). "
             "One miss doesn't change that.";
    } else if (currentMissStreak <= 3) {
      return "You've completed $completedDays of $totalDays days ($completionRate%). "
             "A few missed days don't erase that progress.";
    } else {
      return "You've shown up $completedDays times over $totalDays days. "
             "That foundation is still there. Ready to build on it?";
    }
  }
  
  // ========== Phase 12: Bad Habit Protocol Recovery Messages ==========
  
  /// Get the title for break habit recovery prompt
  static String getBreakHabitRecoveryTitle(RecoveryUrgency urgency) {
    switch (urgency) {
      case RecoveryUrgency.gentle:
        return "Slipped Up?";
      case RecoveryUrgency.important:
        return "Getting Back on Track";
      case RecoveryUrgency.compassionate:
        return "Welcome Back";
    }
  }
  
  /// Get subtitle for break habit recovery
  static String getBreakHabitRecoverySubtitle(RecoveryUrgency urgency, int daysMissed) {
    switch (urgency) {
      case RecoveryUrgency.gentle:
        return "One slip doesn't define you";
      case RecoveryUrgency.important:
        return "Relapses are part of recovery";
      case RecoveryUrgency.compassionate:
        return "$daysMissed days • Every day is a fresh start";
    }
  }
  
  /// Generate break habit recovery message
  static String getBreakHabitRecoveryMessage(RecoveryNeed need) {
    final habitName = need.habit.name;
    final substitution = need.habit.substitutionPlan ?? "your healthy alternative";
    final identity = need.profile.identity;
    
    switch (need.urgency) {
      case RecoveryUrgency.gentle:
        return _getBreakHabitGentleMessage(habitName, substitution, identity);
      case RecoveryUrgency.important:
        return _getBreakHabitImportantMessage(habitName, substitution, identity);
      case RecoveryUrgency.compassionate:
        return _getBreakHabitCompassionateMessage(habitName, substitution, identity, need.daysMissed);
    }
  }
  
  static String _getBreakHabitGentleMessage(String habitName, String substitution, String identity) {
    final messages = [
      "Gave in yesterday? No judgment. Today you can try again.\n\nWhen the urge hits, try: \"$substitution\"",
      "One slip is just data, not defeat.\n\nNext time you're tempted: \"$substitution\"",
      "The person who $identity doesn't give up after one setback.\n\nYour go-to: \"$substitution\"",
    ];
    return messages[DateTime.now().millisecond % messages.length];
  }
  
  static String _getBreakHabitImportantMessage(String habitName, String substitution, String identity) {
    final messages = [
      "Two days is a pattern forming. Let's break it now.\n\nYour weapon: \"$substitution\"",
      "This is the moment that matters. You're not defined by slips.\n\nTry: \"$substitution\"",
      "Day 2 is tough, but you're tougher.\n\n\"$substitution\" is your way forward.",
    ];
    return messages[DateTime.now().millisecond % messages.length];
  }
  
  static String _getBreakHabitCompassionateMessage(String habitName, String substitution, String identity, int days) {
    final messages = [
      "It's been $days days. That's okay – recovery isn't linear.\n\nWhen you're ready: \"$substitution\"\n\nEvery attempt counts.",
      "Relapses happen. What matters is that you're back.\n\nThe person who $identity keeps trying.\n\nStart with: \"$substitution\"",
      "Breaking habits is hard. $days days doesn't erase your progress.\n\nYour fresh start: \"$substitution\"",
    ];
    return messages[DateTime.now().millisecond % messages.length];
  }
  
  /// Get action button text for break habits
  static String getBreakHabitRecoveryActionText(RecoveryUrgency urgency) {
    switch (urgency) {
      case RecoveryUrgency.gentle:
        return "I'm staying strong today";
      case RecoveryUrgency.important:
        return "Break the pattern now";
      case RecoveryUrgency.compassionate:
        return "Start fresh today";
    }
  }
}

/// Represents a need for recovery (habit with missed days)
class RecoveryNeed {
  final Habit habit;
  final UserProfile profile;
  final int daysMissed;
  final DateTime? lastCompletionDate;
  final RecoveryUrgency urgency;
  
  RecoveryNeed({
    required this.habit,
    required this.profile,
    required this.daysMissed,
    this.lastCompletionDate,
    required this.urgency,
  });
  
  /// Human-readable description of time since last completion
  String get timeSinceLastCompletion {
    if (lastCompletionDate == null) return "No completions yet";
    
    if (daysMissed == 1) return "Missed yesterday";
    if (daysMissed == 2) return "2 days ago";
    if (daysMissed < 7) return "$daysMissed days ago";
    if (daysMissed < 14) return "About a week ago";
    if (daysMissed < 30) return "${(daysMissed / 7).round()} weeks ago";
    return "Over a month ago";
  }
}

/// Statistics about recovery patterns
class RecoveryStats {
  final int totalRecoveries;
  final int quickRecoveries;
  final double averageRecoveryDays;
  final int longestGap;
  final double recoveryRate;
  
  RecoveryStats({
    required this.totalRecoveries,
    required this.quickRecoveries,
    required this.averageRecoveryDays,
    required this.longestGap,
    required this.recoveryRate,
  });
  
  /// Human-readable recovery rate description
  String get recoveryRateDescription {
    final percentage = (recoveryRate * 100).round();
    if (percentage >= 80) return "Excellent recovery rate!";
    if (percentage >= 60) return "Good at bouncing back";
    if (percentage >= 40) return "Building recovery skills";
    return "Room to improve";
  }
}
