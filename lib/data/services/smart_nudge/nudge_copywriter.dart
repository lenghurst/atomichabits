/// Phase 19: The Intelligent Nudge - Nudge Copywriter
/// 
/// Static helper class that generates context-aware notification copy
/// based on detected patterns. The copy adapts to the user's behavior
/// patterns, providing empathetic and actionable messages.
/// 
/// Philosophy: "A good assistant doesn't nag; they understand."
/// 
/// Tiered Architecture:
/// - Free Tier: Local heuristics with static pattern-based copy
/// - Premium: AI-generated personalized copy (future)
library;

import '../../models/habit_pattern.dart';

/// Configuration for notification copy
class NudgeCopyConfig {
  /// Name of the habit
  final String habitName;
  
  /// User's identity statement (e.g., "reads daily")
  final String? identity;
  
  /// Tiny version of the habit (e.g., "read 1 page")
  final String? tinyVersion;
  
  /// Temptation bundle (reward paired with habit)
  final String? temptationBundle;
  
  /// Whether this is a weekend
  final bool isWeekend;
  
  /// Current hour (0-23)
  final int currentHour;
  
  const NudgeCopyConfig({
    required this.habitName,
    this.identity,
    this.tinyVersion,
    this.temptationBundle,
    this.isWeekend = false,
    this.currentHour = 12,
  });
}

/// Result of generating notification copy
class NudgeCopy {
  /// Notification title
  final String title;
  
  /// Notification body
  final String body;
  
  /// Pattern that influenced the copy (if any)
  final PatternType? influencingPattern;
  
  /// Short description of why this copy was chosen
  final String copyReason;
  
  const NudgeCopy({
    required this.title,
    required this.body,
    this.influencingPattern,
    required this.copyReason,
  });
  
  @override
  String toString() => 'NudgeCopy(title: $title, reason: $copyReason)';
}

/// Static helper class for generating context-aware notification copy
class NudgeCopywriter {
  NudgeCopywriter._(); // Private constructor - use static methods only
  
  /// Generate notification copy based on active patterns
  /// 
  /// [config] - Configuration with habit details
  /// [activePatterns] - List of patterns detected for this habit
  /// 
  /// Returns context-aware notification copy
  static NudgeCopy generateCopy({
    required NudgeCopyConfig config,
    List<HabitPattern> activePatterns = const [],
  }) {
    // Check patterns in order of priority
    for (final pattern in activePatterns) {
      final copy = _getCopyForPattern(pattern, config);
      if (copy != null) return copy;
    }
    
    // No patterns matched - return default copy
    return _getDefaultCopy(config);
  }
  
  /// Generate copy for a specific pattern type
  /// 
  /// [patternType] - The pattern type to generate copy for
  /// [config] - Configuration with habit details
  static NudgeCopy generateCopyForPattern({
    required PatternType patternType,
    required NudgeCopyConfig config,
  }) {
    final pattern = HabitPattern(
      type: patternType,
      severity: PatternSeverity.medium,
      description: '',
      suggestion: '',
      confidence: 0.5,
      occurrences: 1,
      totalOpportunities: 1,
    );
    return _getCopyForPattern(pattern, config) ?? _getDefaultCopy(config);
  }
  
  /// Get copy for a specific pattern
  static NudgeCopy? _getCopyForPattern(HabitPattern pattern, NudgeCopyConfig config) {
    final habitName = config.habitName;
    final tinyVersion = config.tinyVersion ?? '2-minute version';
    
    switch (pattern.type) {
      case PatternType.energyGap:
        return NudgeCopy(
          title: 'Low energy? Keep it tiny.',
          body: 'Just do the $tinyVersion of $habitName. '
              'Showing up matters more than intensity.',
          influencingPattern: PatternType.energyGap,
          copyReason: 'Energy Gap pattern detected - emphasizing tiny version',
        );
        
      case PatternType.wrongTime:
        final detail = pattern.specificDetail?.toLowerCase() ?? 'this time';
        return NudgeCopy(
          title: 'Struggle at $detail?',
          body: "Don't aim for perfect, just show up. "
              "Even a tiny $habitName counts.",
          influencingPattern: PatternType.wrongTime,
          copyReason: 'Wrong Time pattern detected - encouraging show-up mindset',
        );
        
      case PatternType.weekendVariance:
        if (!config.isWeekend) return null;
        return NudgeCopy(
          title: 'Weekend Warrior 💪',
          body: 'Weekends can be tricky. Your $habitName doesn\'t need '
              'to look the same as weekdays. Just keep the vote cast.',
          influencingPattern: PatternType.weekendVariance,
          copyReason: 'Weekend Variance pattern + weekend day - weekend-specific copy',
        );
        
      case PatternType.forgettingHabit:
        return NudgeCopy(
          title: 'Quick reminder ✨',
          body: 'Your $habitName is waiting. Stack it with something '
              'you already do for automatic activation.',
          influencingPattern: PatternType.forgettingHabit,
          copyReason: 'Forgetfulness pattern detected - habit stacking nudge',
        );
        
      case PatternType.locationMismatch:
        return NudgeCopy(
          title: 'Habit travels with you',
          body: 'Different location today? Your $habitName can adapt. '
              'What\'s the travel-friendly version?',
          influencingPattern: PatternType.locationMismatch,
          copyReason: 'Location Mismatch pattern detected - adaptability focus',
        );
        
      case PatternType.problematicDay:
        final dayDetail = pattern.specificDetail ?? 'today';
        return NudgeCopy(
          title: '$dayDetail check-in',
          body: 'This day tends to be tough for $habitName. '
              'Consider a simpler version just for ${dayDetail}s.',
          influencingPattern: PatternType.problematicDay,
          copyReason: 'Problematic Day pattern detected - day-specific encouragement',
        );
        
      case PatternType.brokenChain:
        return NudgeCopy(
          title: 'Chain reaction time ⛓️',
          body: 'Missing an anchor habit can cascade. '
              'Protect your momentum with a quick $habitName.',
          influencingPattern: PatternType.brokenChain,
          copyReason: 'Broken Chain pattern detected - keystone protection nudge',
        );
        
      case PatternType.strongRecovery:
        return NudgeCopy(
          title: 'Graceful consistency 💫',
          body: 'You\'re great at bouncing back. Time for $habitName - '
              'trust the process.',
          influencingPattern: PatternType.strongRecovery,
          copyReason: 'Strong Recovery pattern - positive reinforcement',
        );
        
      case PatternType.noPattern:
        return null; // Use default copy
    }
  }
  
  /// Get default notification copy (no patterns)
  static NudgeCopy _getDefaultCopy(NudgeCopyConfig config) {
    final habitName = config.habitName;
    
    // If identity is provided, use identity-focused copy
    if (config.identity != null && config.identity!.isNotEmpty) {
      return NudgeCopy(
        title: 'Time for $habitName',
        body: 'You\'re becoming the type of person who ${config.identity}. '
            'Cast your vote.',
        copyReason: 'Default with identity statement',
      );
    }
    
    // If temptation bundle is provided, use it
    if (config.temptationBundle != null && config.temptationBundle!.isNotEmpty) {
      return NudgeCopy(
        title: 'Time for $habitName',
        body: 'Your $habitName is ready (and ${config.temptationBundle}).',
        copyReason: 'Default with temptation bundle',
      );
    }
    
    // Simple default
    return NudgeCopy(
      title: 'Time for your 2-minute $habitName',
      body: 'Every action is a vote for your future self. Let\'s cast one.',
      copyReason: 'Simple default copy',
    );
  }
  
  /// Get all available copy variants for a pattern type
  /// Useful for A/B testing or variety
  static List<NudgeCopy> getAllVariantsForPattern(PatternType type) {
    switch (type) {
      case PatternType.energyGap:
        return [
          const NudgeCopy(
            title: 'Low energy? Keep it tiny.',
            body: 'Just do the 2-minute version. Showing up matters more than intensity.',
            influencingPattern: PatternType.energyGap,
            copyReason: 'Energy Gap - tiny version emphasis',
          ),
          const NudgeCopy(
            title: 'Feeling tired?',
            body: 'On low-energy days, tiny wins still count. What\'s the smallest version?',
            influencingPattern: PatternType.energyGap,
            copyReason: 'Energy Gap - question approach',
          ),
          const NudgeCopy(
            title: 'Energy low? Permission granted.',
            body: 'Do 10% of your usual habit. It still counts as a vote.',
            influencingPattern: PatternType.energyGap,
            copyReason: 'Energy Gap - permission granting',
          ),
        ];
        
      case PatternType.weekendVariance:
        return [
          const NudgeCopy(
            title: 'Weekend Warrior 💪',
            body: 'Weekends can be tricky. Your habit doesn\'t need to look the same.',
            influencingPattern: PatternType.weekendVariance,
            copyReason: 'Weekend Variance - warrior mode',
          ),
          const NudgeCopy(
            title: 'Weekend Check-in',
            body: 'Different schedule? Different approach. What works for today?',
            influencingPattern: PatternType.weekendVariance,
            copyReason: 'Weekend Variance - flexible approach',
          ),
          const NudgeCopy(
            title: 'Sunday doesn\'t have to be perfect',
            body: 'Keep the momentum going with any version of your habit.',
            influencingPattern: PatternType.weekendVariance,
            copyReason: 'Weekend Variance - imperfection embrace',
          ),
        ];
        
      default:
        return [];
    }
  }
  
  /// Get time-appropriate greeting prefix
  static String _getTimeGreeting(int hour) {
    if (hour < 6) return 'Early bird';
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    if (hour < 21) return 'Good evening';
    return 'Night owl';
  }
  
  /// Get motivational quote based on current state
  static String getMotivationalQuote({
    int currentStreak = 0,
    bool isRecoveryDay = false,
    bool hadRecentMiss = false,
  }) {
    if (isRecoveryDay) {
      return '"The key is to start, not to finish perfectly."';
    }
    
    if (hadRecentMiss) {
      return '"Every expert was once a beginner who kept showing up."';
    }
    
    if (currentStreak > 21) {
      return '"You\'re not just building a habit, you\'re building a new identity."';
    }
    
    if (currentStreak > 7) {
      return '"Consistency compounds. You\'re proving who you are."';
    }
    
    return '"Small steps lead to big changes."';
  }
}
