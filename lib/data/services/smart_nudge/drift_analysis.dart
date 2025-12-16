/// Phase 19: The Intelligent Nudge - Drift Analysis Models
/// 
/// Data models for time drift detection and scheduling optimization.
/// 
/// Philosophy: "The app should observe what you do, not just what you say you'll do."

import 'package:flutter/foundation.dart';

/// Result of analyzing completion time patterns
@immutable
class DriftAnalysis {
  /// The calculated median completion time (hour and minute)
  final TimeOfDay medianTime;
  
  /// The currently scheduled time
  final TimeOfDay scheduledTime;
  
  /// Drift in minutes (positive = later than scheduled, negative = earlier)
  final int driftMinutes;
  
  /// Whether the drift is significant enough to suggest a change
  final bool shouldSuggest;
  
  /// Confidence score (0.0 - 1.0) based on data consistency
  final double confidence;
  
  /// Number of data points used in analysis
  final int sampleSize;
  
  /// Standard deviation in minutes (lower = more consistent)
  final double standardDeviation;
  
  /// Human-readable description of the drift
  final String description;
  
  /// Suggested new time (if shouldSuggest is true)
  final TimeOfDay? suggestedTime;

  const DriftAnalysis({
    required this.medianTime,
    required this.scheduledTime,
    required this.driftMinutes,
    required this.shouldSuggest,
    required this.confidence,
    required this.sampleSize,
    required this.standardDeviation,
    required this.description,
    this.suggestedTime,
  });
  
  /// No significant drift detected
  factory DriftAnalysis.noDrift({
    required TimeOfDay scheduledTime,
    required int sampleSize,
  }) {
    return DriftAnalysis(
      medianTime: scheduledTime,
      scheduledTime: scheduledTime,
      driftMinutes: 0,
      shouldSuggest: false,
      confidence: 1.0,
      sampleSize: sampleSize,
      standardDeviation: 0,
      description: 'You\'re completing this habit on schedule. Great consistency!',
    );
  }
  
  /// Not enough data to analyze
  factory DriftAnalysis.insufficientData({
    required TimeOfDay scheduledTime,
    required int sampleSize,
  }) {
    return DriftAnalysis(
      medianTime: scheduledTime,
      scheduledTime: scheduledTime,
      driftMinutes: 0,
      shouldSuggest: false,
      confidence: 0,
      sampleSize: sampleSize,
      standardDeviation: 0,
      description: 'Not enough data yet. Keep tracking to unlock insights!',
    );
  }
  
  /// Drift magnitude category
  DriftSeverity get severity {
    final absDrift = driftMinutes.abs();
    if (absDrift < 15) return DriftSeverity.minimal;
    if (absDrift < 45) return DriftSeverity.moderate;
    if (absDrift < 90) return DriftSeverity.significant;
    return DriftSeverity.major;
  }
  
  /// Direction of drift
  DriftDirection get direction {
    if (driftMinutes.abs() < 15) return DriftDirection.onTime;
    return driftMinutes > 0 ? DriftDirection.later : DriftDirection.earlier;
  }
  
  /// Whether the user is consistently completing later than scheduled
  bool get isConsistentlyLate => direction == DriftDirection.later && confidence > 0.6;
  
  /// Whether the user is consistently completing earlier than scheduled
  bool get isConsistentlyEarly => direction == DriftDirection.earlier && confidence > 0.6;
  
  @override
  String toString() {
    return 'DriftAnalysis('
        'median: ${_formatTime(medianTime)}, '
        'scheduled: ${_formatTime(scheduledTime)}, '
        'drift: ${driftMinutes}min, '
        'confidence: ${(confidence * 100).toStringAsFixed(0)}%, '
        'suggest: $shouldSuggest)';
  }
  
  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

/// Severity of time drift
enum DriftSeverity {
  /// Less than 15 minutes drift
  minimal,
  
  /// 15-45 minutes drift
  moderate,
  
  /// 45-90 minutes drift
  significant,
  
  /// More than 90 minutes drift
  major,
}

/// Direction of time drift
enum DriftDirection {
  /// Within 15 minutes of scheduled time
  onTime,
  
  /// Completing later than scheduled
  later,
  
  /// Completing earlier than scheduled
  earlier,
}

/// Simple TimeOfDay class for use without Flutter context
@immutable
class TimeOfDay {
  final int hour;
  final int minute;
  
  const TimeOfDay({required this.hour, required this.minute});
  
  /// Create from a string like "14:30"
  factory TimeOfDay.fromString(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: parts.length > 1 ? int.parse(parts[1]) : 0,
    );
  }
  
  /// Create from DateTime
  factory TimeOfDay.fromDateTime(DateTime dateTime) {
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }
  
  /// Convert to total minutes since midnight
  int get totalMinutes => hour * 60 + minute;
  
  /// Format as "HH:MM"
  String format() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
  
  /// Format as "9:30 AM" style
  String formatAmPm() {
    final isPm = hour >= 12;
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final amPm = isPm ? 'PM' : 'AM';
    return '$displayHour:${minute.toString().padLeft(2, '0')} $amPm';
  }
  
  /// Create a new TimeOfDay with added minutes
  TimeOfDay addMinutes(int minutes) {
    final totalMins = (totalMinutes + minutes) % (24 * 60);
    return TimeOfDay(
      hour: totalMins ~/ 60,
      minute: totalMins % 60,
    );
  }
  
  /// Difference in minutes between two times (handles crossing midnight)
  int differenceInMinutes(TimeOfDay other) {
    var diff = totalMinutes - other.totalMinutes;
    
    // Handle crossing midnight - find shortest path
    if (diff > 12 * 60) {
      diff -= 24 * 60;
    } else if (diff < -12 * 60) {
      diff += 24 * 60;
    }
    
    return diff;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeOfDay && other.hour == hour && other.minute == minute;
  }
  
  @override
  int get hashCode => hour.hashCode ^ minute.hashCode;
  
  @override
  String toString() => 'TimeOfDay($hour:${minute.toString().padLeft(2, '0')})';
}

/// Result of analyzing weekly patterns in completion times
@immutable
class WeeklyDriftPattern {
  /// Average completion time by day of week (1=Monday, 7=Sunday)
  final Map<int, TimeOfDay> averageTimesByDay;
  
  /// Days with significant deviation from scheduled time
  final List<int> problematicDays;
  
  /// Whether weekends show different patterns than weekdays
  final bool hasWeekendVariance;
  
  /// Suggested weekend time (if different from weekday)
  final TimeOfDay? weekendSuggestedTime;
  
  const WeeklyDriftPattern({
    required this.averageTimesByDay,
    required this.problematicDays,
    required this.hasWeekendVariance,
    this.weekendSuggestedTime,
  });
}
