/// Optimal Timing Predictor - ML Workstream #1
///
/// Predicts the best time to send interventions based on:
/// 1. Historical completion patterns (when user actually completes habits)
/// 2. Day-of-week variations
/// 3. User's intended implementation time
/// 4. Recent behavior trends
///
/// Philosophy: Send interventions when user is READY to act,
/// not when they're likely to ignore them.

import 'dart:math';

import '../entities/context_snapshot.dart';
import '../../data/models/habit.dart';

/// Time window recommendation for interventions
class TimingWindow {
  /// Center of the optimal window (hour of day, 0-23)
  final int optimalHour;

  /// Minutes past the hour (0-59)
  final int optimalMinute;

  /// Confidence in this prediction (0.0-1.0)
  final double confidence;

  /// Window size in minutes (e.g., 30 = +/- 15 min)
  final int windowMinutes;

  /// Reason for this recommendation
  final TimingReason reason;

  /// Day-specific adjustment applied
  final bool isDaySpecific;

  const TimingWindow({
    required this.optimalHour,
    this.optimalMinute = 0,
    required this.confidence,
    this.windowMinutes = 30,
    required this.reason,
    this.isDaySpecific = false,
  });

  /// Check if current time is within this window
  bool isNowInWindow(DateTime now) {
    final windowCenter = DateTime(
      now.year, now.month, now.day,
      optimalHour, optimalMinute,
    );
    final halfWindow = Duration(minutes: windowMinutes ~/ 2);
    return now.isAfter(windowCenter.subtract(halfWindow)) &&
           now.isBefore(windowCenter.add(halfWindow));
  }

  /// Minutes until window opens (negative if already passed)
  int minutesUntilWindow(DateTime now) {
    final windowStart = DateTime(
      now.year, now.month, now.day,
      optimalHour, optimalMinute,
    ).subtract(Duration(minutes: windowMinutes ~/ 2));
    return windowStart.difference(now).inMinutes;
  }

  /// Get DateTime of optimal moment
  DateTime optimalMoment(DateTime referenceDate) {
    return DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
      optimalHour,
      optimalMinute,
    );
  }
}

/// Why this timing was recommended
enum TimingReason {
  /// Based on historical completion pattern
  historicalPattern,

  /// User's stated implementation intention
  implementationIntention,

  /// Pre-habit buffer (before scheduled time)
  preHabitNudge,

  /// Day-of-week specific pattern
  dayOfWeekPattern,

  /// Recent trend adjustment
  recentTrend,

  /// Default fallback (no data)
  defaultFallback,

  /// Cascade prevention (approaching danger zone)
  cascadePrevention,
}

/// Optimal Timing Predictor Service
///
/// Uses historical completion data to predict best intervention times.
/// No external ML dependencies - pure statistical analysis.
class OptimalTimingPredictor {
  /// Minimum completions needed for reliable prediction
  static const int _minCompletionsForPattern = 5;

  /// Days to consider for recent trend analysis
  static const int _recentTrendDays = 14;

  /// Weight for day-of-week patterns vs overall pattern
  static const double _dayOfWeekWeight = 0.4;

  /// Pre-habit nudge offset (minutes before scheduled time)
  static const int _preHabitNudgeMinutes = 15;

  /// Predict optimal intervention timing for a habit
  ///
  /// Returns a prioritized list of timing windows (best first)
  List<TimingWindow> predictOptimalWindows({
    required Habit habit,
    required ContextSnapshot context,
    int maxWindows = 3,
  }) {
    final windows = <TimingWindow>[];

    // === 1. HISTORICAL PATTERN (Primary) ===
    final historicalWindow = _analyzeHistoricalPattern(
      habit.completionHistory,
      context.time,
    );
    if (historicalWindow != null) {
      windows.add(historicalWindow);
    }

    // === 2. DAY-OF-WEEK SPECIFIC ===
    final dayWindow = _analyzeDayOfWeekPattern(
      habit.completionHistory,
      context.time.weekday,
    );
    if (dayWindow != null &&
        (historicalWindow == null ||
         (dayWindow.optimalHour - historicalWindow.optimalHour).abs() > 1)) {
      windows.add(dayWindow);
    }

    // === 3. PRE-HABIT NUDGE (before implementation time) ===
    final preHabitWindow = _calculatePreHabitWindow(habit);
    if (preHabitWindow != null) {
      windows.add(preHabitWindow);
    }

    // === 4. RECENT TREND ADJUSTMENT ===
    final trendWindow = _analyzeRecentTrend(habit.completionHistory);
    if (trendWindow != null && windows.length < maxWindows) {
      windows.add(trendWindow);
    }

    // === 5. DEFAULT FALLBACK ===
    if (windows.isEmpty) {
      windows.add(_defaultWindow(habit));
    }

    // Sort by confidence and return top N
    windows.sort((a, b) => b.confidence.compareTo(a.confidence));
    return windows.take(maxWindows).toList();
  }

  /// Get the single best intervention time for right now
  TimingWindow? getBestWindowForNow({
    required Habit habit,
    required ContextSnapshot context,
  }) {
    final windows = predictOptimalWindows(
      habit: habit,
      context: context,
      maxWindows: 5,
    );

    final now = context.time;

    // Find windows that are upcoming (within 2 hours) or current
    for (final window in windows) {
      final minutesUntil = window.minutesUntilWindow(now);
      if (minutesUntil >= -30 && minutesUntil <= 120) {
        return window;
      }
    }

    // If no good window, return highest confidence one
    return windows.isNotEmpty ? windows.first : null;
  }

  /// Check if NOW is a good time to intervene
  InterventionTimingScore scoreCurrentTiming({
    required Habit habit,
    required ContextSnapshot context,
  }) {
    final windows = predictOptimalWindows(
      habit: habit,
      context: context,
      maxWindows: 5,
    );

    final now = context.time;

    // Check if we're in any optimal window
    for (final window in windows) {
      if (window.isNowInWindow(now)) {
        return InterventionTimingScore(
          score: 0.8 + (window.confidence * 0.2),
          isOptimalWindow: true,
          window: window,
          recommendation: 'Good time - in optimal window',
        );
      }
    }

    // Check if we're approaching a window
    final nextWindow = windows.isNotEmpty ? windows.first : null;
    if (nextWindow != null) {
      final minutesUntil = nextWindow.minutesUntilWindow(now);
      if (minutesUntil > 0 && minutesUntil <= 30) {
        return InterventionTimingScore(
          score: 0.6,
          isOptimalWindow: false,
          window: nextWindow,
          recommendation: 'Approaching optimal window in $minutesUntil min',
        );
      }
    }

    // Check for cascade prevention (habit at risk)
    if (_isAtRiskOfCascade(habit, now)) {
      return InterventionTimingScore(
        score: 0.9,
        isOptimalWindow: false,
        window: TimingWindow(
          optimalHour: now.hour,
          optimalMinute: now.minute,
          confidence: 0.7,
          reason: TimingReason.cascadePrevention,
        ),
        recommendation: 'Cascade prevention - habit at risk',
      );
    }

    // Default: not optimal but not terrible
    return InterventionTimingScore(
      score: 0.4,
      isOptimalWindow: false,
      window: null,
      recommendation: 'Not in optimal window',
    );
  }

  // === Private Analysis Methods ===

  /// Analyze historical completion times to find modal pattern
  TimingWindow? _analyzeHistoricalPattern(
    List<DateTime> completionHistory,
    DateTime referenceDate,
  ) {
    if (completionHistory.length < _minCompletionsForPattern) {
      return null;
    }

    // Extract hours and calculate distribution
    final hourCounts = List.filled(24, 0);
    final hourMinuteSum = List.filled(24, 0);

    for (final completion in completionHistory) {
      hourCounts[completion.hour]++;
      hourMinuteSum[completion.hour] += completion.minute;
    }

    // Find peak hour
    int peakHour = 0;
    int peakCount = 0;
    for (int h = 0; h < 24; h++) {
      if (hourCounts[h] > peakCount) {
        peakCount = hourCounts[h];
        peakHour = h;
      }
    }

    if (peakCount < 2) return null;

    // Calculate average minute within peak hour
    final avgMinute = (hourMinuteSum[peakHour] / hourCounts[peakHour]).round();

    // Calculate confidence based on concentration
    final totalCompletions = completionHistory.length;
    final concentration = peakCount / totalCompletions;

    // Also consider adjacent hours
    final adjacentCount = (peakHour > 0 ? hourCounts[peakHour - 1] : 0) +
                          (peakHour < 23 ? hourCounts[peakHour + 1] : 0);
    final windowConcentration = (peakCount + adjacentCount) / totalCompletions;

    final confidence = (concentration * 0.6 + windowConcentration * 0.4)
        .clamp(0.3, 0.95);

    return TimingWindow(
      optimalHour: peakHour,
      optimalMinute: avgMinute,
      confidence: confidence,
      windowMinutes: _calculateWindowSize(concentration),
      reason: TimingReason.historicalPattern,
    );
  }

  /// Analyze patterns specific to day of week
  TimingWindow? _analyzeDayOfWeekPattern(
    List<DateTime> completionHistory,
    int targetWeekday,
  ) {
    // Filter to same day of week
    final sameDayCompletions = completionHistory
        .where((d) => d.weekday == targetWeekday)
        .toList();

    if (sameDayCompletions.length < 3) return null;

    // Extract hours for this day
    final hourCounts = List.filled(24, 0);
    for (final completion in sameDayCompletions) {
      hourCounts[completion.hour]++;
    }

    // Find peak
    int peakHour = 0;
    int peakCount = 0;
    for (int h = 0; h < 24; h++) {
      if (hourCounts[h] > peakCount) {
        peakCount = hourCounts[h];
        peakHour = h;
      }
    }

    if (peakCount < 2) return null;

    final concentration = peakCount / sameDayCompletions.length;
    final confidence = (concentration * _dayOfWeekWeight).clamp(0.2, 0.7);

    return TimingWindow(
      optimalHour: peakHour,
      confidence: confidence,
      windowMinutes: 45, // Wider window for day-specific
      reason: TimingReason.dayOfWeekPattern,
      isDaySpecific: true,
    );
  }

  /// Calculate pre-habit nudge window from implementation intention
  TimingWindow? _calculatePreHabitWindow(Habit habit) {
    // Parse implementation time (e.g., "22:00")
    final timeParts = habit.implementationTime.split(':');
    if (timeParts.length != 2) return null;

    final hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);
    if (hour == null || minute == null) return null;

    // Calculate nudge time (15 min before)
    var nudgeMinute = minute - _preHabitNudgeMinutes;
    var nudgeHour = hour;
    if (nudgeMinute < 0) {
      nudgeMinute += 60;
      nudgeHour = (nudgeHour - 1) % 24;
    }

    return TimingWindow(
      optimalHour: nudgeHour,
      optimalMinute: nudgeMinute,
      confidence: 0.5, // Medium confidence - intention may not match action
      windowMinutes: 20,
      reason: TimingReason.preHabitNudge,
    );
  }

  /// Analyze recent completions for trend
  TimingWindow? _analyzeRecentTrend(List<DateTime> completionHistory) {
    final now = DateTime.now();
    final cutoff = now.subtract(Duration(days: _recentTrendDays));

    final recentCompletions = completionHistory
        .where((d) => d.isAfter(cutoff))
        .toList();

    if (recentCompletions.length < 3) return null;

    // Calculate mean hour of recent completions
    final hourSum = recentCompletions.fold<double>(
      0, (sum, d) => sum + d.hour + (d.minute / 60),
    );
    final meanHour = hourSum / recentCompletions.length;

    // Check if recent pattern differs from overall
    final overallMean = completionHistory.fold<double>(
      0, (sum, d) => sum + d.hour + (d.minute / 60),
    ) / completionHistory.length;

    // Only return if there's a significant shift
    if ((meanHour - overallMean).abs() < 1) return null;

    return TimingWindow(
      optimalHour: meanHour.floor(),
      optimalMinute: ((meanHour % 1) * 60).round(),
      confidence: 0.4, // Lower confidence for trends
      windowMinutes: 40,
      reason: TimingReason.recentTrend,
    );
  }

  /// Calculate window size based on concentration
  int _calculateWindowSize(double concentration) {
    // High concentration = narrow window, low = wide
    if (concentration > 0.6) return 20;
    if (concentration > 0.4) return 30;
    if (concentration > 0.2) return 45;
    return 60;
  }

  /// Check if habit is at risk of cascade failure
  bool _isAtRiskOfCascade(Habit habit, DateTime now) {
    if (habit.lastCompletedDate == null) return false;

    final daysSinceLast = now.difference(habit.lastCompletedDate!).inDays;

    // At risk if missed yesterday AND today is getting late
    if (daysSinceLast >= 1 && now.hour >= 18) {
      return true;
    }

    // At risk if missed two days (Never Miss Twice territory)
    if (daysSinceLast >= 2) {
      return true;
    }

    return false;
  }

  /// Default fallback window
  TimingWindow _defaultWindow(Habit habit) {
    // Use implementation intention if available
    final timeParts = habit.implementationTime.split(':');
    if (timeParts.length == 2) {
      final hour = int.tryParse(timeParts[0]);
      if (hour != null) {
        return TimingWindow(
          optimalHour: hour,
          confidence: 0.3,
          windowMinutes: 60,
          reason: TimingReason.defaultFallback,
        );
      }
    }

    // Generic fallback
    return const TimingWindow(
      optimalHour: 9,
      confidence: 0.2,
      windowMinutes: 120,
      reason: TimingReason.defaultFallback,
    );
  }
}

/// Scoring result for current timing
class InterventionTimingScore {
  /// Overall score (0.0-1.0, higher = better time to intervene)
  final double score;

  /// Whether we're currently in an optimal window
  final bool isOptimalWindow;

  /// The relevant window (if any)
  final TimingWindow? window;

  /// Human-readable recommendation
  final String recommendation;

  const InterventionTimingScore({
    required this.score,
    required this.isOptimalWindow,
    required this.window,
    required this.recommendation,
  });
}

/// Extension for easy access from ContextSnapshot
extension ContextTimingExtension on ContextSnapshot {
  /// Check if this context represents a good intervention time
  bool get isGoodInterventionTime {
    // Quick heuristics without full analysis
    final hour = time.hour;

    // Avoid sleep hours
    if (hour < 7 || hour > 22) return false;

    // Prefer action hours
    return hour >= 8 && hour <= 21;
  }
}
