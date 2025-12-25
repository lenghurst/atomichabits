/// Phase 14: Pattern Detection Service - "The Safety Net"
/// 
/// A pure Dart service that analyzes habit miss data to detect patterns.
/// Uses local heuristics for real-time pattern detection (O(n) complexity).
/// 
/// Philosophy: Transform "Miss Reasons" into actionable insights
/// - Local-First: Real-time tags without server dependency
/// - Cloud-Boosted: LLM synthesis in WeeklyReviewService
/// 
/// Supported Patterns:
/// - Wrong Time: Habit scheduled at suboptimal time
/// - Energy Gap: Energy-related misses dominate
/// - Location Mismatch: Environment disrupts habit
/// - Forgetting: Memory/reminder issues
/// - Broken Chain: Stacked habit dependency failures
/// - Weekend Variance: Different weekend behavior
/// - Strong Recovery: Positive - good at bouncing back
library;

import '../models/habit.dart';
import '../models/habit_pattern.dart';
import '../models/consistency_metrics.dart';

/// Configuration for pattern detection thresholds
class PatternDetectionConfig {
  /// Minimum occurrences to consider a pattern
  final int minOccurrences;
  
  /// Minimum confidence threshold (0.0 - 1.0)
  final double minConfidence;
  
  /// Days of history to analyze
  final int daysToAnalyze;
  
  /// Minimum rate to flag a pattern (e.g., 0.3 = 30% of misses)
  final double minPatternRate;
  
  const PatternDetectionConfig({
    this.minOccurrences = 2,
    this.minConfidence = 0.3,
    this.daysToAnalyze = 30,
    this.minPatternRate = 0.25,
  });
  
  static const PatternDetectionConfig defaultConfig = PatternDetectionConfig();
  
  /// Stricter config for fewer but more confident patterns
  static const PatternDetectionConfig strictConfig = PatternDetectionConfig(
    minOccurrences: 4,
    minConfidence: 0.5,
    daysToAnalyze: 60,
    minPatternRate: 0.35,
  );
}

/// Pattern Detection Service
/// 
/// Analyzes habit miss data and returns detected patterns.
/// O(n) complexity where n = number of miss events.
class PatternDetectionService {
  final PatternDetectionConfig config;
  
  PatternDetectionService({
    this.config = PatternDetectionConfig.defaultConfig,
  });
  
  /// Analyze a habit and return pattern summary
  /// 
  /// Takes a [habit] with its [missHistory] and [completionHistory]
  /// Returns a [PatternSummary] with detected patterns
  PatternSummary analyzeHabit({
    required Habit habit,
    required List<MissEvent> missHistory,
    required List<DateTime> completionHistory,
    List<RecoveryEvent>? recoveryHistory,
  }) {
    if (missHistory.isEmpty) {
      return PatternSummary.empty(habit.id);
    }
    
    // Filter to analysis window
    final cutoff = DateTime.now().subtract(Duration(days: config.daysToAnalyze));
    final recentMisses = missHistory
        .where((m) => m.date.isAfter(cutoff))
        .toList();
    
    if (recentMisses.isEmpty) {
      return PatternSummary.empty(habit.id);
    }
    
    // Run all heuristics
    final patterns = <HabitPattern>[];
    
    // 1. Detect time-based patterns
    final timePattern = _detectTimePattern(recentMisses, habit);
    if (timePattern != null) patterns.add(timePattern);
    
    // 2. Detect day-of-week patterns
    final dayPattern = _detectDayPattern(recentMisses);
    if (dayPattern != null) patterns.add(dayPattern);
    
    // 3. Detect energy patterns
    final energyPattern = _detectEnergyPattern(recentMisses);
    if (energyPattern != null) patterns.add(energyPattern);
    
    // 4. Detect location patterns
    final locationPattern = _detectLocationPattern(recentMisses);
    if (locationPattern != null) patterns.add(locationPattern);
    
    // 5. Detect forgetfulness patterns
    final forgetPattern = _detectForgetfulnessPattern(recentMisses);
    if (forgetPattern != null) patterns.add(forgetPattern);
    
    // 6. Detect weekend variance
    final weekendPattern = _detectWeekendPattern(recentMisses);
    if (weekendPattern != null) patterns.add(weekendPattern);
    
    // 7. Detect recovery patterns (positive!)
    final recoveryPattern = _detectRecoveryPattern(
      recentMisses, 
      recoveryHistory ?? [],
    );
    if (recoveryPattern != null) patterns.add(recoveryPattern);
    
    // Sort by severity and confidence
    patterns.sort((a, b) {
      final severityCompare = b.severity.index.compareTo(a.severity.index);
      if (severityCompare != 0) return severityCompare;
      return b.confidence.compareTo(a.confidence);
    });
    
    // Generate tags
    final allTags = _generateTags(patterns, recentMisses);
    
    // Calculate health score
    final healthScore = _calculateHealthScore(patterns, recentMisses.length);
    
    return PatternSummary(
      habitId: habit.id,
      generatedAt: DateTime.now(),
      patterns: patterns,
      primaryPattern: patterns.isNotEmpty ? patterns.first : null,
      allTags: allTags,
      healthScore: healthScore,
    );
  }
  
  /// Detect time-based patterns
  /// "You miss more often in the evening/morning"
  HabitPattern? _detectTimePattern(List<MissEvent> misses, Habit habit) {
    final withSchedule = misses.where((m) => m.scheduledHour != null).toList();
    if (withSchedule.length < config.minOccurrences) return null;
    
    int morningMisses = 0;  // Before noon
    int afternoonMisses = 0; // Noon - 6pm
    int eveningMisses = 0;  // After 6pm
    
    for (final miss in withSchedule) {
      final hour = miss.scheduledHour!;
      if (hour < 12) {
        morningMisses++;
      } else if (hour < 18) {
        afternoonMisses++;
      } else {
        eveningMisses++;
      }
    }
    
    final total = withSchedule.length;
    final morningRate = morningMisses / total;
    final eveningRate = eveningMisses / total;
    
    // Check for strong time preference in misses
    if (eveningRate >= config.minPatternRate && eveningMisses >= config.minOccurrences) {
      return HabitPattern(
        type: PatternType.wrongTime,
        severity: _getSeverity(eveningMisses),
        description: 'You tend to miss this habit in the evening',
        suggestion: 'Try scheduling this habit earlier in the day when your energy is higher.',
        confidence: eveningRate,
        occurrences: eveningMisses,
        totalOpportunities: total,
        supportingEvents: withSchedule.where((m) => m.scheduledHour! >= 18).toList(),
        tags: ['🌙 Night Owl Pattern'],
        specificDetail: 'Evening (after 6 PM)',
      );
    }
    
    if (morningRate >= config.minPatternRate && morningMisses >= config.minOccurrences) {
      return HabitPattern(
        type: PatternType.wrongTime,
        severity: _getSeverity(morningMisses),
        description: 'You tend to miss this habit in the morning',
        suggestion: 'Consider moving this habit to later in the day, or prepare the night before.',
        confidence: morningRate,
        occurrences: morningMisses,
        totalOpportunities: total,
        supportingEvents: withSchedule.where((m) => m.scheduledHour! < 12).toList(),
        tags: ['🌅 Morning Struggle'],
        specificDetail: 'Morning (before noon)',
      );
    }
    
    // Check for afternoon pattern
    final afternoonRate = afternoonMisses / total;
    if (afternoonRate >= config.minPatternRate && afternoonMisses >= config.minOccurrences) {
      return HabitPattern(
        type: PatternType.wrongTime,
        severity: _getSeverity(afternoonMisses),
        description: 'You tend to miss this habit in the afternoon',
        suggestion: 'The post-lunch slump is real! Try scheduling before lunch or after 4 PM.',
        confidence: afternoonRate,
        occurrences: afternoonMisses,
        totalOpportunities: total,
        supportingEvents: withSchedule.where((m) => m.scheduledHour! >= 12 && m.scheduledHour! < 18).toList(),
        tags: ['☀️ Afternoon Slump'],
        specificDetail: 'Afternoon (noon - 6 PM)',
      );
    }
    
    return null;
  }
  
  /// Detect day-of-week patterns
  /// "Mondays are your hardest day"
  /// 
  /// SAFETY NET FIX: Excludes weekends to avoid overlap with _detectWeekendPattern
  /// and uses normalized rate to account for expected miss distribution.
  HabitPattern? _detectDayPattern(List<MissEvent> misses) {
    if (misses.length < config.minOccurrences) return null;
    
    // Count misses by day of week (WEEKDAYS ONLY to avoid weekend overlap)
    final dayCounts = <int, int>{};
    int weekdayMissCount = 0;
    for (final miss in misses) {
      // Skip weekends (6=Saturday, 7=Sunday) - handled by _detectWeekendPattern
      if (miss.dayOfWeek >= 6) continue;
      dayCounts[miss.dayOfWeek] = (dayCounts[miss.dayOfWeek] ?? 0) + 1;
      weekdayMissCount++;
    }
    
    // Need enough weekday misses to analyze
    if (weekdayMissCount < config.minOccurrences) return null;
    
    // Find the worst weekday
    int? worstDay;
    int worstCount = 0;
    dayCounts.forEach((day, count) {
      if (count > worstCount) {
        worstDay = day;
        worstCount = count;
      }
    });
    
    if (worstDay == null || worstCount < config.minOccurrences) return null;
    
    // Calculate rate among weekday misses only
    final rate = worstCount / weekdayMissCount;
    
    // Expected rate per weekday: 1/5 = 20%
    // Require significantly above expected (1.5x = 30%) to flag
    final expectedRate = 1 / 5; // 20%
    final significanceThreshold = expectedRate * 1.5; // 30%
    
    if (rate < significanceThreshold) return null;
    
    final dayName = _dayName(worstDay!);
    
    return HabitPattern(
      type: PatternType.problematicDay,
      severity: _getSeverity(worstCount),
      description: '${dayName}s are your most challenging day for this habit',
      suggestion: 'Consider a simpler "minimum version" specifically for ${dayName}s.',
      confidence: rate,
      occurrences: worstCount,
      totalOpportunities: weekdayMissCount,
      supportingEvents: misses.where((m) => m.dayOfWeek == worstDay).toList(),
      tags: ['📅 $dayName Struggle'],
      specificDetail: dayName,
    );
  }
  
  /// Detect energy-related patterns
  /// "Low energy is your main blocker"
  HabitPattern? _detectEnergyPattern(List<MissEvent> misses) {
    final energyMisses = misses
        .where((m) => m.category == MissReasonCategory.energy)
        .toList();
    
    if (energyMisses.length < config.minOccurrences) return null;
    
    final rate = energyMisses.length / misses.length;
    if (rate < config.minPatternRate) return null;
    
    // Find most common energy reason
    final reasonCounts = <MissReason, int>{};
    for (final miss in energyMisses) {
      if (miss.reason != null) {
        reasonCounts[miss.reason!] = (reasonCounts[miss.reason!] ?? 0) + 1;
      }
    }
    
    MissReason? topReason;
    int topCount = 0;
    reasonCounts.forEach((reason, count) {
      if (count > topCount) {
        topReason = reason;
        topCount = count;
      }
    });
    
    final reasonDetail = topReason?.label ?? 'Low energy';
    
    return HabitPattern(
      type: PatternType.energyGap,
      severity: _getSeverity(energyMisses.length),
      description: '$reasonDetail often prevents you from completing this habit',
      suggestion: 'When energy is low, commit to just the 2-minute version. '
          'Showing up matters more than intensity.',
      confidence: rate,
      occurrences: energyMisses.length,
      totalOpportunities: misses.length,
      supportingEvents: energyMisses,
      tags: ['⚡ Low Energy Pattern'],
      specificDetail: reasonDetail,
    );
  }
  
  /// Detect location-related patterns
  HabitPattern? _detectLocationPattern(List<MissEvent> misses) {
    final locationMisses = misses
        .where((m) => m.category == MissReasonCategory.location)
        .toList();
    
    if (locationMisses.length < config.minOccurrences) return null;
    
    final rate = locationMisses.length / misses.length;
    if (rate < config.minPatternRate) return null;
    
    return HabitPattern(
      type: PatternType.locationMismatch,
      severity: _getSeverity(locationMisses.length),
      description: 'Location changes frequently disrupt this habit',
      suggestion: 'Create a "travel version" of this habit that works anywhere. '
          'Remove environment dependencies.',
      confidence: rate,
      occurrences: locationMisses.length,
      totalOpportunities: misses.length,
      supportingEvents: locationMisses,
      tags: ['📍 Location Dependent'],
    );
  }
  
  /// Detect forgetfulness patterns
  HabitPattern? _detectForgetfulnessPattern(List<MissEvent> misses) {
    final forgetMisses = misses
        .where((m) => m.category == MissReasonCategory.forgetfulness)
        .toList();
    
    if (forgetMisses.length < config.minOccurrences) return null;
    
    final rate = forgetMisses.length / misses.length;
    if (rate < config.minPatternRate) return null;
    
    return HabitPattern(
      type: PatternType.forgettingHabit,
      severity: _getSeverity(forgetMisses.length),
      description: 'You often forget to do this habit',
      suggestion: 'Add more visible cues: stack with an existing habit, '
          'set a specific reminder, or place physical triggers.',
      confidence: rate,
      occurrences: forgetMisses.length,
      totalOpportunities: misses.length,
      supportingEvents: forgetMisses,
      tags: ['🧠 Memory Gap'],
    );
  }
  
  /// Detect weekend vs weekday patterns
  HabitPattern? _detectWeekendPattern(List<MissEvent> misses) {
    final weekendMisses = misses.where((m) => m.isWeekend).length;
    final weekdayMisses = misses.length - weekendMisses;
    
    // Need enough data for both
    if (weekendMisses < 2 && weekdayMisses < 2) return null;
    
    // Calculate rates (2 weekend days vs 5 weekdays)
    // Normalize: weekend gets 2/7 of week, weekday gets 5/7
    final expectedWeekendRate = 2 / 7;
    final actualWeekendRate = misses.isNotEmpty 
        ? weekendMisses / misses.length 
        : 0.0;
    
    // Check if weekend is significantly worse
    if (actualWeekendRate > expectedWeekendRate * 1.5 && 
        weekendMisses >= config.minOccurrences) {
      return HabitPattern(
        type: PatternType.weekendVariance,
        severity: _getSeverity(weekendMisses),
        description: 'Weekends are more challenging for this habit',
        suggestion: 'Create a specific weekend routine or a simpler weekend version.',
        confidence: actualWeekendRate / expectedWeekendRate - 1,
        occurrences: weekendMisses,
        totalOpportunities: misses.length,
        supportingEvents: misses.where((m) => m.isWeekend).toList(),
        tags: ['🎉 Weekend Wobble'],
        specificDetail: 'Weekends (Sat-Sun)',
      );
    }
    
    return null;
  }
  
  /// Detect recovery patterns (positive pattern!)
  HabitPattern? _detectRecoveryPattern(
    List<MissEvent> misses, 
    List<RecoveryEvent> recoveries,
  ) {
    // Check if user is good at recovering
    final recoveredMisses = misses.where((m) => m.wasRecovered).length;
    
    if (recoveredMisses < 2) return null;
    
    final recoveryRate = misses.isNotEmpty 
        ? recoveredMisses / misses.length 
        : 0.0;
    
    // Good recovery rate (> 60%)
    if (recoveryRate >= 0.6) {
      return HabitPattern(
        type: PatternType.strongRecovery,
        severity: PatternSeverity.low, // Positive patterns are "low severity"
        description: 'You\'re great at bouncing back after a miss!',
        suggestion: 'This is Graceful Consistency in action. '
            'Keep trusting the process.',
        confidence: recoveryRate,
        occurrences: recoveredMisses,
        totalOpportunities: misses.length,
        supportingEvents: misses.where((m) => m.wasRecovered).toList(),
        tags: ['💪 Quick Recovery'],
      );
    }
    
    return null;
  }
  
  /// Calculate severity based on occurrence count
  PatternSeverity _getSeverity(int occurrences) {
    if (occurrences >= 7) return PatternSeverity.high;
    if (occurrences >= 4) return PatternSeverity.medium;
    return PatternSeverity.low;
  }
  
  /// Get day name from weekday number
  String _dayName(int weekday) {
    const days = ['', 'Monday', 'Tuesday', 'Wednesday', 
                  'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday.clamp(1, 7)];
  }
  
  /// Generate display tags from patterns and misses
  List<String> _generateTags(List<HabitPattern> patterns, List<MissEvent> misses) {
    final tags = <String>[];
    
    for (final pattern in patterns) {
      tags.addAll(pattern.tags);
    }
    
    // Add category-based tags if not already covered
    final categoryMap = <MissReasonCategory, int>{};
    for (final miss in misses) {
      if (miss.category != null) {
        categoryMap[miss.category!] = (categoryMap[miss.category!] ?? 0) + 1;
      }
    }
    
    // Add dominant category tag if significant
    categoryMap.forEach((category, count) {
      final rate = count / misses.length;
      if (rate >= 0.3 && count >= 2) {
        final tagString = '${category.emoji} ${category.label}';
        if (!tags.contains(tagString)) {
          // Don't add duplicate concepts
          final hasRelated = tags.any((t) => t.contains(category.emoji));
          if (!hasRelated) {
            tags.add(tagString);
          }
        }
      }
    });
    
    // Limit tags
    return tags.take(5).toList();
  }
  
  /// Calculate overall health score (0-100)
  /// Higher = better (fewer/less severe patterns)
  /// 
  /// SAFETY NET FIX: Uses diminishing returns for multiple patterns
  /// to avoid overly punishing users with interconnected issues.
  double _calculateHealthScore(List<HabitPattern> patterns, int totalMisses) {
    if (patterns.isEmpty || totalMisses == 0) return 100;
    
    double penalty = 0;
    int negativePatternCount = 0;
    
    for (final pattern in patterns) {
      if (pattern.isPositive) {
        // Positive patterns boost score
        penalty -= 5;
      } else {
        negativePatternCount++;
        // Negative patterns reduce score based on severity
        // Apply diminishing penalty for each additional pattern (90% of previous)
        final diminishingFactor = negativePatternCount == 1 
            ? 1.0 
            : 0.9 * (1 / negativePatternCount);
        
        switch (pattern.severity) {
          case PatternSeverity.high:
            penalty += 25 * diminishingFactor;
            break;
          case PatternSeverity.medium:
            penalty += 15 * diminishingFactor;
            break;
          case PatternSeverity.low:
            penalty += 5 * diminishingFactor;
            break;
        }
      }
    }
    
    // Soft cap: Even with many patterns, score shouldn't drop below 30
    // (always leave hope for improvement)
    return (100 - penalty).clamp(30, 100);
  }
  
  /// Quick check for any significant patterns without full analysis
  /// Use for displaying badges/indicators
  bool hasSignificantPatterns({
    required List<MissEvent> missHistory,
    int minMisses = 3,
  }) {
    if (missHistory.length < minMisses) return false;
    
    // Quick category check
    final categoryCount = <MissReasonCategory, int>{};
    for (final miss in missHistory) {
      if (miss.category != null) {
        categoryCount[miss.category!] = (categoryCount[miss.category!] ?? 0) + 1;
      }
    }
    
    // Check if any category dominates (> 40%)
    for (final count in categoryCount.values) {
      if (count >= 2 && count / missHistory.length > 0.4) {
        return true;
      }
    }
    
    return false;
  }
  
  /// Generate a single-sentence insight from patterns
  String generateQuickInsight(PatternSummary summary) {
    if (summary.patterns.isEmpty) {
      return 'No clear patterns yet. Keep tracking!';
    }
    
    final primary = summary.primaryPattern;
    if (primary == null) return 'Tracking your progress...';
    
    if (primary.isPositive) {
      return '${primary.type.emoji} ${primary.description}';
    }
    
    return '${primary.severity.emoji} Friction detected: ${primary.description}';
  }
}
