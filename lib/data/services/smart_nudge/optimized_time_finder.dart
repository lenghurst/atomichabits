/// Phase 19: The Intelligent Nudge - Optimized Time Finder
/// 
/// Pure Dart service that analyzes habit completion times to detect "drift" -
/// when users consistently complete habits at different times than scheduled.
/// 
/// Philosophy: "The app should observe what you do, not just what you say you'll do."
/// 
/// Algorithm:
/// 1. Filter to recent completions (last 30 days)
/// 2. Remove outliers (> 2 hours from mean)
/// 3. Calculate median time (more robust than average)
/// 4. Compare to scheduled time
/// 5. Flag if drift > 45 minutes with sufficient confidence
library;

import 'dart:math' as math;
import 'drift_analysis.dart';

/// Configuration for drift detection
class DriftDetectionConfig {
  /// Minimum completions needed for analysis
  final int minSampleSize;
  
  /// Days of history to analyze
  final int daysToAnalyze;
  
  /// Minutes of drift required to suggest change
  final int driftThresholdMinutes;
  
  /// Hours away from mean to be considered outlier
  final double outlierThresholdHours;
  
  /// Minimum confidence to suggest change (0.0 - 1.0)
  final double minConfidence;
  
  /// Maximum standard deviation (minutes) to suggest change
  final double maxStdDevMinutes;
  
  const DriftDetectionConfig({
    this.minSampleSize = 7,
    this.daysToAnalyze = 30,
    this.driftThresholdMinutes = 45,
    this.outlierThresholdHours = 2.0,
    this.minConfidence = 0.6,
    this.maxStdDevMinutes = 60,
  });
  
  static const DriftDetectionConfig defaultConfig = DriftDetectionConfig();
  
  /// Stricter config requiring more data and consistency
  static const DriftDetectionConfig strictConfig = DriftDetectionConfig(
    minSampleSize: 14,
    daysToAnalyze: 60,
    driftThresholdMinutes: 30,
    minConfidence: 0.7,
    maxStdDevMinutes: 45,
  );
}

/// Optimized Time Finder Service
/// 
/// Analyzes completion history to find the user's "natural" habit time
/// and detects drift from their scheduled time.
class OptimizedTimeFinder {
  final DriftDetectionConfig config;
  
  OptimizedTimeFinder({
    this.config = DriftDetectionConfig.defaultConfig,
  });
  
  /// Analyze completion times and detect drift
  /// 
  /// [completionHistory] - List of DateTime when habit was completed
  /// [scheduledTime] - The time the habit is scheduled for (e.g., "08:00")
  /// 
  /// Returns a [DriftAnalysis] with findings and suggestions
  DriftAnalysis analyze({
    required List<DateTime> completionHistory,
    required String scheduledTime,
  }) {
    final scheduled = TimeOfDay.fromString(scheduledTime);
    
    // Filter to recent completions
    final cutoff = DateTime.now().subtract(Duration(days: config.daysToAnalyze));
    final recentCompletions = completionHistory
        .where((dt) => dt.isAfter(cutoff))
        .toList();
    
    // Check minimum sample size
    if (recentCompletions.length < config.minSampleSize) {
      return DriftAnalysis.insufficientData(
        scheduledTime: scheduled,
        sampleSize: recentCompletions.length,
      );
    }
    
    // Convert to minutes since midnight
    final completionMinutes = recentCompletions
        .map((dt) => dt.hour * 60 + dt.minute)
        .toList();
    
    // Calculate mean for outlier detection
    final mean = _calculateMean(completionMinutes);
    
    // Remove outliers (more than outlierThresholdHours from mean)
    final outlierThresholdMinutes = (config.outlierThresholdHours * 60).toInt();
    final filteredMinutes = completionMinutes
        .where((m) => (m - mean).abs() <= outlierThresholdMinutes)
        .toList();
    
    // Need enough data after filtering
    if (filteredMinutes.length < config.minSampleSize ~/ 2) {
      return DriftAnalysis.insufficientData(
        scheduledTime: scheduled,
        sampleSize: filteredMinutes.length,
      );
    }
    
    // Calculate median (more robust than mean)
    final medianMinutes = _calculateMedian(filteredMinutes);
    final medianTime = TimeOfDay(
      hour: medianMinutes ~/ 60,
      minute: medianMinutes % 60,
    );
    
    // Calculate standard deviation
    final stdDev = _calculateStdDev(filteredMinutes, medianMinutes.toDouble());
    
    // Calculate drift from scheduled time
    final scheduledMinutes = scheduled.totalMinutes;
    var driftMinutes = medianMinutes - scheduledMinutes;
    
    // Handle crossing midnight (e.g., scheduled 11 PM, actual 1 AM)
    if (driftMinutes > 12 * 60) {
      driftMinutes -= 24 * 60;
    } else if (driftMinutes < -12 * 60) {
      driftMinutes += 24 * 60;
    }
    
    // Calculate confidence based on consistency and sample size
    final confidence = _calculateConfidence(
      sampleSize: filteredMinutes.length,
      stdDev: stdDev,
      outliersRemoved: completionMinutes.length - filteredMinutes.length,
    );
    
    // Determine if we should suggest a change
    final shouldSuggest = 
        driftMinutes.abs() >= config.driftThresholdMinutes &&
        confidence >= config.minConfidence &&
        stdDev <= config.maxStdDevMinutes;
    
    // Generate description
    final description = _generateDescription(
      driftMinutes: driftMinutes,
      medianTime: medianTime,
      confidence: confidence,
      shouldSuggest: shouldSuggest,
    );
    
    // Round suggested time to nearest 15 minutes
    final suggestedTime = shouldSuggest 
        ? _roundToNearest15(medianTime)
        : null;
    
    return DriftAnalysis(
      medianTime: medianTime,
      scheduledTime: scheduled,
      driftMinutes: driftMinutes,
      shouldSuggest: shouldSuggest,
      confidence: confidence,
      sampleSize: filteredMinutes.length,
      standardDeviation: stdDev,
      description: description,
      suggestedTime: suggestedTime,
    );
  }
  
  /// Analyze weekly patterns to detect day-specific drift
  WeeklyDriftPattern analyzeWeeklyPattern({
    required List<DateTime> completionHistory,
    required String scheduledTime,
  }) {
    final scheduled = TimeOfDay.fromString(scheduledTime);
    
    // Group completions by day of week
    final byDay = <int, List<int>>{};
    for (final dt in completionHistory) {
      final dayOfWeek = dt.weekday;
      final minutes = dt.hour * 60 + dt.minute;
      byDay.putIfAbsent(dayOfWeek, () => []).add(minutes);
    }
    
    // Calculate average time per day
    final averageByDay = <int, TimeOfDay>{};
    final problematicDays = <int>[];
    
    for (final entry in byDay.entries) {
      if (entry.value.length < 2) continue;
      
      final avg = _calculateMean(entry.value);
      averageByDay[entry.key] = TimeOfDay(
        hour: avg ~/ 60,
        minute: avg.toInt() % 60,
      );
      
      // Check if this day has significant drift
      final drift = (avg - scheduled.totalMinutes).abs();
      if (drift > config.driftThresholdMinutes) {
        problematicDays.add(entry.key);
      }
    }
    
    // Check for weekend variance
    final weekdayTimes = <int>[];
    final weekendTimes = <int>[];
    
    for (final dt in completionHistory) {
      final minutes = dt.hour * 60 + dt.minute;
      if (dt.weekday >= 6) {
        weekendTimes.add(minutes);
      } else {
        weekdayTimes.add(minutes);
      }
    }
    
    TimeOfDay? weekendSuggested;
    bool hasWeekendVariance = false;
    
    if (weekdayTimes.length >= 3 && weekendTimes.length >= 2) {
      final weekdayAvg = _calculateMean(weekdayTimes);
      final weekendAvg = _calculateMean(weekendTimes);
      final variance = (weekendAvg - weekdayAvg).abs();
      
      if (variance > config.driftThresholdMinutes) {
        hasWeekendVariance = true;
        weekendSuggested = TimeOfDay(
          hour: weekendAvg ~/ 60,
          minute: weekendAvg.toInt() % 60,
        );
      }
    }
    
    return WeeklyDriftPattern(
      averageTimesByDay: averageByDay,
      problematicDays: problematicDays,
      hasWeekendVariance: hasWeekendVariance,
      weekendSuggestedTime: weekendSuggested,
    );
  }
  
  /// Calculate mean of a list of values
  double _calculateMean(List<int> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }
  
  /// Calculate median of a sorted list
  int _calculateMedian(List<int> values) {
    if (values.isEmpty) return 0;
    
    final sorted = List<int>.from(values)..sort();
    final mid = sorted.length ~/ 2;
    
    if (sorted.length.isOdd) {
      return sorted[mid];
    } else {
      return (sorted[mid - 1] + sorted[mid]) ~/ 2;
    }
  }
  
  /// Calculate standard deviation
  double _calculateStdDev(List<int> values, double mean) {
    if (values.length < 2) return 0;
    
    final squaredDiffs = values.map((v) => math.pow(v - mean, 2));
    final variance = squaredDiffs.reduce((a, b) => a + b) / (values.length - 1);
    
    return math.sqrt(variance);
  }
  
  /// Calculate confidence score based on data quality
  double _calculateConfidence({
    required int sampleSize,
    required double stdDev,
    required int outliersRemoved,
  }) {
    // Base confidence from sample size (caps at 21+ samples)
    final sampleConfidence = math.min(1.0, sampleSize / 21);
    
    // Penalty for high variance (stdDev > 60 mins reduces confidence)
    final variancePenalty = math.max(0, (stdDev - 30) / 60);
    
    // Penalty for many outliers (more than 30% removed)
    final outlierRate = outliersRemoved / (sampleSize + outliersRemoved);
    final outlierPenalty = outlierRate > 0.3 ? 0.2 : 0;
    
    final confidence = sampleConfidence - variancePenalty - outlierPenalty;
    return confidence.clamp(0.0, 1.0);
  }
  
  /// Generate human-readable description
  String _generateDescription({
    required int driftMinutes,
    required TimeOfDay medianTime,
    required double confidence,
    required bool shouldSuggest,
  }) {
    final absDrift = driftMinutes.abs();
    final direction = driftMinutes > 0 ? 'later' : 'earlier';
    final timeString = medianTime.formatAmPm();
    
    if (absDrift < 15) {
      return 'You\'re completing this habit on schedule. Great consistency!';
    }
    
    if (!shouldSuggest) {
      if (confidence < config.minConfidence) {
        return 'Your completion times vary quite a bit. Keep tracking for better insights.';
      }
      return 'You tend to do this around $timeString, about $absDrift minutes $direction than scheduled.';
    }
    
    return 'You naturally do this habit around $timeString. '
        'Want to update your reminder to match your rhythm?';
  }
  
  /// Round time to nearest 15 minutes
  TimeOfDay _roundToNearest15(TimeOfDay time) {
    final totalMinutes = time.totalMinutes;
    final rounded = ((totalMinutes + 7.5) ~/ 15) * 15;
    return TimeOfDay(
      hour: (rounded ~/ 60) % 24,
      minute: rounded % 60,
    );
  }
}
