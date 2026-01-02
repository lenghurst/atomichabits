/// WitnessInfluenceService - Witness Network Influence Modeling
///
/// Genspark Recommendation Implementation:
/// Ranks witnesses by their effectiveness for cascade prevention.
///
/// Tracks:
/// - Response time (how quickly witness reacts to completions/drift)
/// - Completion correlation (does user complete more after witness interaction?)
/// - Nudge effectiveness (does nudge lead to completion?)
/// - Emotional support quality (variety and timing of reactions)
/// - Recovery influence (does witness help prevent cascades?)
///
/// Philosophy: Not all accountability partners are created equal.
/// Some witnesses inspire action; others are passive observers.
/// Surface the most effective witnesses for critical moments.

import 'dart:math';

import '../entities/psychometric_profile.dart';
import '../../data/models/witness_event.dart';
import '../../data/models/habit.dart';

/// Metrics for a single witness
class WitnessInfluenceMetrics {
  /// Witness user ID
  final String witnessId;

  /// Display name (for UI)
  final String? witnessName;

  /// Response time in minutes (average time to react to events)
  final double avgResponseMinutes;

  /// Completion rate after witness interaction (0.0 - 1.0)
  final double completionCorrelation;

  /// Nudge effectiveness (% of nudges that lead to completion within 2h)
  final double nudgeEffectiveness;

  /// High-five frequency (reactions per week)
  final double highFiveFrequency;

  /// Recovery influence (% of near-misses saved after witness nudge)
  final double recoveryInfluence;

  /// Overall influence score (0.0 - 1.0)
  final double overallScore;

  /// Total interactions counted
  final int totalInteractions;

  /// Last interaction timestamp
  final DateTime? lastInteraction;

  const WitnessInfluenceMetrics({
    required this.witnessId,
    this.witnessName,
    this.avgResponseMinutes = 60.0,
    this.completionCorrelation = 0.5,
    this.nudgeEffectiveness = 0.5,
    this.highFiveFrequency = 0.0,
    this.recoveryInfluence = 0.5,
    this.overallScore = 0.5,
    this.totalInteractions = 0,
    this.lastInteraction,
  });

  /// Influence tier (for UI display)
  InfluenceTier get tier {
    if (overallScore >= 0.8) return InfluenceTier.champion;
    if (overallScore >= 0.6) return InfluenceTier.supporter;
    if (overallScore >= 0.4) return InfluenceTier.observer;
    return InfluenceTier.passive;
  }

  /// Is this witness highly effective?
  bool get isHighlyEffective => overallScore >= 0.7;

  /// Is this witness responsive?
  bool get isResponsive => avgResponseMinutes < 30;

  /// Copy with updates
  WitnessInfluenceMetrics copyWith({
    String? witnessId,
    String? witnessName,
    double? avgResponseMinutes,
    double? completionCorrelation,
    double? nudgeEffectiveness,
    double? highFiveFrequency,
    double? recoveryInfluence,
    double? overallScore,
    int? totalInteractions,
    DateTime? lastInteraction,
  }) {
    return WitnessInfluenceMetrics(
      witnessId: witnessId ?? this.witnessId,
      witnessName: witnessName ?? this.witnessName,
      avgResponseMinutes: avgResponseMinutes ?? this.avgResponseMinutes,
      completionCorrelation: completionCorrelation ?? this.completionCorrelation,
      nudgeEffectiveness: nudgeEffectiveness ?? this.nudgeEffectiveness,
      highFiveFrequency: highFiveFrequency ?? this.highFiveFrequency,
      recoveryInfluence: recoveryInfluence ?? this.recoveryInfluence,
      overallScore: overallScore ?? this.overallScore,
      totalInteractions: totalInteractions ?? this.totalInteractions,
      lastInteraction: lastInteraction ?? this.lastInteraction,
    );
  }

  Map<String, dynamic> toJson() => {
        'witnessId': witnessId,
        'witnessName': witnessName,
        'avgResponseMinutes': avgResponseMinutes,
        'completionCorrelation': completionCorrelation,
        'nudgeEffectiveness': nudgeEffectiveness,
        'highFiveFrequency': highFiveFrequency,
        'recoveryInfluence': recoveryInfluence,
        'overallScore': overallScore,
        'totalInteractions': totalInteractions,
        'lastInteraction': lastInteraction?.toIso8601String(),
      };

  factory WitnessInfluenceMetrics.fromJson(Map<String, dynamic> json) {
    return WitnessInfluenceMetrics(
      witnessId: json['witnessId'] as String,
      witnessName: json['witnessName'] as String?,
      avgResponseMinutes: (json['avgResponseMinutes'] as num?)?.toDouble() ?? 60.0,
      completionCorrelation: (json['completionCorrelation'] as num?)?.toDouble() ?? 0.5,
      nudgeEffectiveness: (json['nudgeEffectiveness'] as num?)?.toDouble() ?? 0.5,
      highFiveFrequency: (json['highFiveFrequency'] as num?)?.toDouble() ?? 0.0,
      recoveryInfluence: (json['recoveryInfluence'] as num?)?.toDouble() ?? 0.5,
      overallScore: (json['overallScore'] as num?)?.toDouble() ?? 0.5,
      totalInteractions: json['totalInteractions'] as int? ?? 0,
      lastInteraction: json['lastInteraction'] != null
          ? DateTime.parse(json['lastInteraction'] as String)
          : null,
    );
  }
}

/// Witness influence tiers
enum InfluenceTier {
  /// Champion: High engagement, high effectiveness (>80%)
  champion,

  /// Supporter: Regular engagement, moderate effectiveness (60-80%)
  supporter,

  /// Observer: Passive watching, low engagement (40-60%)
  observer,

  /// Passive: Rarely interacts (<40%)
  passive,
}

extension InfluenceTierExtension on InfluenceTier {
  String get displayName {
    switch (this) {
      case InfluenceTier.champion:
        return 'Champion';
      case InfluenceTier.supporter:
        return 'Supporter';
      case InfluenceTier.observer:
        return 'Observer';
      case InfluenceTier.passive:
        return 'Passive';
    }
  }

  String get emoji {
    switch (this) {
      case InfluenceTier.champion:
        return '🏆';
      case InfluenceTier.supporter:
        return '💪';
      case InfluenceTier.observer:
        return '👀';
      case InfluenceTier.passive:
        return '😴';
    }
  }

  String get description {
    switch (this) {
      case InfluenceTier.champion:
        return 'Highly engaged, your #1 accountability partner';
      case InfluenceTier.supporter:
        return 'Regularly checks in and encourages you';
      case InfluenceTier.observer:
        return 'Watches your progress but rarely interacts';
      case InfluenceTier.passive:
        return 'Rarely engages with your habits';
    }
  }
}

/// Service for modeling witness network influence
class WitnessInfluenceService {
  /// Cached metrics per witness
  final Map<String, WitnessInfluenceMetrics> _metricsCache = {};

  /// Interaction history for analysis
  final List<_WitnessInteraction> _interactionHistory = [];

  /// Maximum history size
  static const int _maxHistorySize = 500;

  /// Calculate influence metrics for a witness based on event history
  WitnessInfluenceMetrics calculateMetrics({
    required String witnessId,
    required List<WitnessEvent> events,
    required List<Habit> habits,
    String? witnessName,
  }) {
    // Filter events for this witness
    final witnessEvents = events.where(
      (e) => e.actorId == witnessId || e.targetId == witnessId,
    ).toList();

    if (witnessEvents.isEmpty) {
      return WitnessInfluenceMetrics(
        witnessId: witnessId,
        witnessName: witnessName,
      );
    }

    // Calculate response time (time between completion and high-five)
    final avgResponse = _calculateAvgResponseTime(witnessEvents);

    // Calculate completion correlation
    final completionCorr = _calculateCompletionCorrelation(witnessEvents, habits);

    // Calculate nudge effectiveness
    final nudgeEff = _calculateNudgeEffectiveness(witnessEvents, habits);

    // Calculate high-five frequency
    final highFiveFreq = _calculateHighFiveFrequency(witnessEvents);

    // Calculate recovery influence
    final recoveryInf = _calculateRecoveryInfluence(witnessEvents, habits);

    // Calculate overall score (weighted average)
    final overallScore = _calculateOverallScore(
      avgResponseMinutes: avgResponse,
      completionCorrelation: completionCorr,
      nudgeEffectiveness: nudgeEff,
      highFiveFrequency: highFiveFreq,
      recoveryInfluence: recoveryInf,
    );

    final metrics = WitnessInfluenceMetrics(
      witnessId: witnessId,
      witnessName: witnessName,
      avgResponseMinutes: avgResponse,
      completionCorrelation: completionCorr,
      nudgeEffectiveness: nudgeEff,
      highFiveFrequency: highFiveFreq,
      recoveryInfluence: recoveryInf,
      overallScore: overallScore,
      totalInteractions: witnessEvents.length,
      lastInteraction: witnessEvents.isNotEmpty
          ? witnessEvents.map((e) => e.createdAt).reduce((a, b) => a.isAfter(b) ? a : b)
          : null,
    );

    // Cache the metrics
    _metricsCache[witnessId] = metrics;

    return metrics;
  }

  /// Get the most effective witness for a critical moment
  ///
  /// Use when: cascade risk is high, need immediate accountability
  String? getMostEffectiveWitness(List<String> witnessIds) {
    if (witnessIds.isEmpty) return null;

    String? best;
    double bestScore = 0;

    for (final id in witnessIds) {
      final metrics = _metricsCache[id];
      if (metrics != null && metrics.overallScore > bestScore) {
        bestScore = metrics.overallScore;
        best = id;
      }
    }

    return best;
  }

  /// Get ranked witnesses (most effective first)
  List<WitnessInfluenceMetrics> getRankedWitnesses() {
    final witnesses = _metricsCache.values.toList();
    witnesses.sort((a, b) => b.overallScore.compareTo(a.overallScore));
    return witnesses;
  }

  /// Get the best witness for recovery support
  ///
  /// Use when: user missed yesterday, need Never Miss Twice support
  String? getBestRecoveryWitness(List<String> witnessIds) {
    if (witnessIds.isEmpty) return null;

    String? best;
    double bestRecovery = 0;

    for (final id in witnessIds) {
      final metrics = _metricsCache[id];
      if (metrics != null && metrics.recoveryInfluence > bestRecovery) {
        bestRecovery = metrics.recoveryInfluence;
        best = id;
      }
    }

    return best;
  }

  /// Get the most responsive witness
  ///
  /// Use when: need immediate response (e.g., urge surfing support)
  String? getMostResponsiveWitness(List<String> witnessIds) {
    if (witnessIds.isEmpty) return null;

    String? best;
    double bestResponse = double.infinity;

    for (final id in witnessIds) {
      final metrics = _metricsCache[id];
      if (metrics != null && metrics.avgResponseMinutes < bestResponse) {
        bestResponse = metrics.avgResponseMinutes;
        best = id;
      }
    }

    return best;
  }

  /// Record an interaction for future analysis
  void recordInteraction({
    required String witnessId,
    required WitnessEventType eventType,
    required DateTime timestamp,
    bool? ledToCompletion,
    int? responseTimeMinutes,
  }) {
    _interactionHistory.add(_WitnessInteraction(
      witnessId: witnessId,
      eventType: eventType,
      timestamp: timestamp,
      ledToCompletion: ledToCompletion,
      responseTimeMinutes: responseTimeMinutes,
    ));

    // Trim history
    if (_interactionHistory.length > _maxHistorySize) {
      _interactionHistory.removeRange(0, _interactionHistory.length - _maxHistorySize);
    }
  }

  /// Get influence summary for display
  Map<String, dynamic> getInfluenceSummary() {
    final witnesses = getRankedWitnesses();

    return {
      'totalWitnesses': witnesses.length,
      'champions': witnesses.where((w) => w.tier == InfluenceTier.champion).length,
      'supporters': witnesses.where((w) => w.tier == InfluenceTier.supporter).length,
      'avgOverallScore': witnesses.isEmpty
          ? 0.0
          : witnesses.map((w) => w.overallScore).reduce((a, b) => a + b) / witnesses.length,
      'mostEffective': witnesses.isNotEmpty ? witnesses.first.witnessId : null,
    };
  }

  // === Private Calculation Methods ===

  double _calculateAvgResponseTime(List<WitnessEvent> events) {
    // Find pairs of completion -> high-five events
    final completions = events.where((e) => e.type == WitnessEventType.habitCompleted).toList();
    final highFives = events.where((e) => e.type == WitnessEventType.highFiveReceived).toList();

    if (completions.isEmpty || highFives.isEmpty) {
      return 60.0; // Default 1 hour
    }

    final responseTimes = <double>[];
    for (final completion in completions) {
      // Find the next high-five after this completion
      final nextHighFive = highFives.where(
        (hf) => hf.createdAt.isAfter(completion.createdAt) &&
            hf.createdAt.difference(completion.createdAt).inHours < 24,
      ).firstOrNull;

      if (nextHighFive != null) {
        final responseMinutes = nextHighFive.createdAt.difference(completion.createdAt).inMinutes;
        responseTimes.add(responseMinutes.toDouble());
      }
    }

    if (responseTimes.isEmpty) return 60.0;
    return responseTimes.reduce((a, b) => a + b) / responseTimes.length;
  }

  double _calculateCompletionCorrelation(List<WitnessEvent> events, List<Habit> habits) {
    // Check if completions happen more often after witness interactions
    final nudges = events.where((e) => e.type == WitnessEventType.nudgeReceived).toList();
    final highFives = events.where((e) => e.type == WitnessEventType.highFiveReceived).toList();

    if (nudges.isEmpty && highFives.isEmpty) return 0.5;

    // Count completions within 2 hours of witness interaction
    int completionsAfterInteraction = 0;
    int totalInteractions = nudges.length + highFives.length;

    for (final habit in habits) {
      for (final completion in habit.completionHistory) {
        // Check if any interaction happened 0-2 hours before this completion
        final hasRecentInteraction = [...nudges, ...highFives].any(
          (e) => completion.isAfter(e.createdAt) &&
              completion.difference(e.createdAt).inHours <= 2,
        );

        if (hasRecentInteraction) {
          completionsAfterInteraction++;
        }
      }
    }

    if (totalInteractions == 0) return 0.5;
    return (completionsAfterInteraction / totalInteractions).clamp(0.0, 1.0);
  }

  double _calculateNudgeEffectiveness(List<WitnessEvent> events, List<Habit> habits) {
    final nudges = events.where((e) => e.type == WitnessEventType.nudgeReceived).toList();

    if (nudges.isEmpty) return 0.5;

    int effectiveNudges = 0;

    for (final nudge in nudges) {
      // Check if any habit was completed within 2 hours of this nudge
      final completionAfter = habits.any((habit) =>
          habit.completionHistory.any((c) =>
              c.isAfter(nudge.createdAt) &&
              c.difference(nudge.createdAt).inHours <= 2));

      if (completionAfter) {
        effectiveNudges++;
      }
    }

    return (effectiveNudges / nudges.length).clamp(0.0, 1.0);
  }

  double _calculateHighFiveFrequency(List<WitnessEvent> events) {
    final highFives = events.where((e) => e.type == WitnessEventType.highFiveReceived).toList();

    if (highFives.isEmpty) return 0.0;

    // Calculate high-fives per week
    final first = highFives.map((e) => e.createdAt).reduce((a, b) => a.isBefore(b) ? a : b);
    final last = highFives.map((e) => e.createdAt).reduce((a, b) => a.isAfter(b) ? a : b);

    final weeks = last.difference(first).inDays / 7.0;
    if (weeks < 1) return highFives.length.toDouble();

    return highFives.length / weeks;
  }

  double _calculateRecoveryInfluence(List<WitnessEvent> events, List<Habit> habits) {
    // Check if witness interactions correlate with recovery after misses
    final nudges = events.where((e) => e.type == WitnessEventType.nudgeReceived).toList();

    if (nudges.isEmpty) return 0.5;

    int recoveriesAfterNudge = 0;
    int missesWithNudge = 0;

    for (final habit in habits) {
      for (final recovery in habit.recoveryHistory) {
        // Check if a nudge happened on or after the miss date
        final nudgeDuringMiss = nudges.any(
          (n) => n.createdAt.isAfter(recovery.missDate) &&
              n.createdAt.isBefore(recovery.recoveryDate),
        );

        if (nudgeDuringMiss) {
          missesWithNudge++;
          if (recovery.daysMissed <= 1) {
            recoveriesAfterNudge++; // "Never Miss Twice" recovery
          }
        }
      }
    }

    if (missesWithNudge == 0) return 0.5;
    return (recoveriesAfterNudge / missesWithNudge).clamp(0.0, 1.0);
  }

  double _calculateOverallScore({
    required double avgResponseMinutes,
    required double completionCorrelation,
    required double nudgeEffectiveness,
    required double highFiveFrequency,
    required double recoveryInfluence,
  }) {
    // Normalize response time (lower is better)
    // 0 minutes = 1.0, 120 minutes = 0.0
    final responseScore = (1.0 - (avgResponseMinutes / 120.0)).clamp(0.0, 1.0);

    // Normalize high-five frequency (7+ per week = 1.0)
    final frequencyScore = (highFiveFrequency / 7.0).clamp(0.0, 1.0);

    // Weighted average
    const weights = {
      'response': 0.15,
      'completion': 0.25,
      'nudge': 0.25,
      'frequency': 0.15,
      'recovery': 0.20,
    };

    return (responseScore * weights['response']! +
            completionCorrelation * weights['completion']! +
            nudgeEffectiveness * weights['nudge']! +
            frequencyScore * weights['frequency']! +
            recoveryInfluence * weights['recovery']!)
        .clamp(0.0, 1.0);
  }

  /// Clear cached metrics
  void clearCache() {
    _metricsCache.clear();
    _interactionHistory.clear();
  }
}

/// Internal class for tracking interactions
class _WitnessInteraction {
  final String witnessId;
  final WitnessEventType eventType;
  final DateTime timestamp;
  final bool? ledToCompletion;
  final int? responseTimeMinutes;

  _WitnessInteraction({
    required this.witnessId,
    required this.eventType,
    required this.timestamp,
    this.ledToCompletion,
    this.responseTimeMinutes,
  });
}
