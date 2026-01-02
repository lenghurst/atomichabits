/// JITAIProvider - Just-In-Time Adaptive Interventions State Manager
///
/// Manages JITAI decision engine state, context sensing, and intervention delivery.
/// Coordinates between the decision engine, background worker, and UI.
///
/// Responsibilities:
/// - Initialize and manage JITAI services
/// - Track intervention history and outcomes
/// - Provide insights for UI display
/// - Handle intervention dismissals and feedback

import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../domain/entities/context_snapshot.dart';
import '../../domain/entities/psychometric_profile.dart';
import '../../domain/services/jitai_decision_engine.dart';
import '../../domain/services/optimal_timing_predictor.dart';
import '../../domain/services/cascade_pattern_detector.dart';
import '../models/habit.dart';
import '../services/context/context_snapshot_builder.dart';
import '../services/jitai/jitai_background_worker.dart';
import '../services/jitai/jitai_notification_service.dart';

/// Provider state for active intervention
class ActiveIntervention {
  final JITAIDecision decision;
  final DateTime triggeredAt;
  final String habitId;
  final String habitName;

  const ActiveIntervention({
    required this.decision,
    required this.triggeredAt,
    required this.habitId,
    required this.habitName,
  });
}

/// Timing insight for UI display
class TimingInsight {
  final String title;
  final String description;
  final double score;
  final DateTime? suggestedTime;
  final IconType iconType;

  const TimingInsight({
    required this.title,
    required this.description,
    required this.score,
    this.suggestedTime,
    this.iconType = IconType.clock,
  });
}

enum IconType { clock, warning, checkCircle, trending, calendar, heart }

/// Cascade risk alert for UI
class CascadeAlert {
  final String title;
  final String description;
  final double severity; // 0.0 - 1.0
  final String suggestedAction;
  final CascadePattern pattern;

  const CascadeAlert({
    required this.title,
    required this.description,
    required this.severity,
    required this.suggestedAction,
    required this.pattern,
  });
}

class JITAIProvider extends ChangeNotifier {
  // Services
  late final JITAIDecisionEngine _decisionEngine;
  late final ContextSnapshotBuilder _contextBuilder;
  late final JITAINotificationService _notificationService;
  late final OptimalTimingPredictor _timingPredictor;
  late final CascadePatternDetector _cascadeDetector;

  // State
  bool _isInitialized = false;
  bool _isEnabled = true;
  ContextSnapshot? _lastContext;
  DateTime? _lastContextUpdate;
  ActiveIntervention? _activeIntervention;

  // Insights cache
  List<TimingInsight> _timingInsights = [];
  List<CascadeAlert> _cascadeAlerts = [];

  // Settings
  Duration _contextRefreshInterval = const Duration(minutes: 5);

  JITAIProvider();

  // === Getters ===
  bool get isInitialized => _isInitialized;
  bool get isEnabled => _isEnabled;
  ContextSnapshot? get lastContext => _lastContext;
  ActiveIntervention? get activeIntervention => _activeIntervention;
  List<TimingInsight> get timingInsights => List.unmodifiable(_timingInsights);
  List<CascadeAlert> get cascadeAlerts => List.unmodifiable(_cascadeAlerts);
  bool get hasActiveIntervention => _activeIntervention != null;
  bool get hasCascadeRisk => _cascadeAlerts.any((a) => a.severity > 0.5);

  /// Initialize the JITAI system
  Future<void> initialize({String? weatherApiKey}) async {
    if (_isInitialized) return;

    try {
      _decisionEngine = JITAIDecisionEngine();
      _contextBuilder = ContextSnapshotBuilder();
      _notificationService = JITAINotificationService();
      _timingPredictor = OptimalTimingPredictor();
      _cascadeDetector = CascadePatternDetector();

      // Initialize services
      await _contextBuilder.initialize(weatherApiKey: weatherApiKey);
      await _notificationService.initialize();

      // Register background tasks
      await JITAIBackgroundWorker.registerBackgroundTasks();

      // Register lifecycle observer
      JITAILifecycleObserver.register();

      _isInitialized = true;
      notifyListeners();

      if (kDebugMode) {
        debugPrint('JITAIProvider: Initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('JITAIProvider: Initialization failed: $e');
      }
    }
  }

  /// Enable/disable JITAI interventions
  Future<void> setEnabled(bool enabled) async {
    if (_isEnabled == enabled) return;

    _isEnabled = enabled;

    if (enabled) {
      await JITAIBackgroundWorker.registerBackgroundTasks();
    } else {
      await JITAIBackgroundWorker.cancelBackgroundTasks();
    }

    notifyListeners();
  }

  /// Refresh context and update insights
  Future<void> refreshContext({
    required Habit habit,
    List<Habit>? allHabits,
  }) async {
    if (!_isInitialized || !_isEnabled) return;

    // Rate limit context refresh
    if (_lastContextUpdate != null) {
      final elapsed = DateTime.now().difference(_lastContextUpdate!);
      if (elapsed < _contextRefreshInterval) {
        return;
      }
    }

    try {
      _lastContext = await _contextBuilder.build(
        habit: habit,
        allHabits: allHabits,
      );
      _lastContextUpdate = DateTime.now();

      // Update insights
      _updateTimingInsights(habit);
      _updateCascadeAlerts(habit);

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('JITAIProvider: Context refresh failed: $e');
      }
    }
  }

  /// Check if intervention is needed for a habit
  Future<JITAIDecision?> checkIntervention({
    required Habit habit,
    required PsychometricProfile profile,
    DecisionTrigger trigger = DecisionTrigger.contextChange,
  }) async {
    if (!_isInitialized || !_isEnabled) return null;
    if (habit.isCompletedToday || habit.isPaused) return null;

    try {
      // Refresh context if stale
      await refreshContext(habit: habit);

      if (_lastContext == null) return null;

      // Run decision
      final decision = await _decisionEngine.decide(
        context: _lastContext!,
        profile: profile,
        habit: habit,
        trigger: trigger,
      );

      // If intervention is triggered, set it as active
      if (decision.shouldIntervene) {
        _activeIntervention = ActiveIntervention(
          decision: decision,
          triggeredAt: DateTime.now(),
          habitId: habit.id,
          habitName: habit.name,
        );
        notifyListeners();
      }

      return decision;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('JITAIProvider: Intervention check failed: $e');
      }
      return null;
    }
  }

  /// Record user response to intervention
  Future<void> recordInterventionOutcome({
    required String eventId,
    required bool engaged,
    required bool habitCompleted,
    int? engagementSeconds,
  }) async {
    if (!_isInitialized) return;

    try {
      await _decisionEngine.recordOutcome(
        eventId: eventId,
        engaged: engaged,
        habitCompleted: habitCompleted,
        engagementSeconds: engagementSeconds,
      );

      // Clear active intervention
      if (_activeIntervention?.decision.event?.eventId == eventId) {
        _activeIntervention = null;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('JITAIProvider: Outcome recording failed: $e');
      }
    }
  }

  /// Dismiss active intervention without engaging
  Future<void> dismissIntervention({String? reason}) async {
    if (_activeIntervention == null) return;

    await recordInterventionOutcome(
      eventId: _activeIntervention!.decision.event?.eventId ?? '',
      engaged: false,
      habitCompleted: false,
    );

    _activeIntervention = null;
    notifyListeners();
  }

  /// Get optimal intervention windows for a habit
  List<TimingWindow> getOptimalWindows({
    required Habit habit,
    int maxWindows = 3,
  }) {
    if (!_isInitialized || _lastContext == null) return [];

    return _timingPredictor.predictOptimalWindows(
      habit: habit,
      context: _lastContext!,
      maxWindows: maxWindows,
    );
  }

  /// Get cascade risk assessment
  CascadeRisk? getCascadeRisk({required Habit habit}) {
    if (!_isInitialized || _lastContext == null) return null;

    return _cascadeDetector.detectRisk(
      habit: habit,
      context: _lastContext!,
    );
  }

  // === Private Methods ===

  void _updateTimingInsights(Habit habit) {
    if (_lastContext == null) return;

    final insights = <TimingInsight>[];

    // Current timing score
    final timingScore = _decisionEngine.scoreCurrentTiming(
      habit: habit,
      context: _lastContext!,
    );

    insights.add(TimingInsight(
      title: 'Current Timing',
      description: _describeTiming(timingScore.score),
      score: timingScore.score,
      iconType: timingScore.score > 0.6 ? IconType.checkCircle : IconType.clock,
    ));

    // Optimal windows
    final windows = getOptimalWindows(habit: habit);
    if (windows.isNotEmpty) {
      final nextWindow = windows.first;
      insights.add(TimingInsight(
        title: 'Optimal Window',
        description: '${nextWindow.startHour}:00 - ${nextWindow.endHour}:00',
        score: nextWindow.score,
        suggestedTime: DateTime.now().copyWith(
          hour: nextWindow.startHour,
          minute: 0,
        ),
        iconType: IconType.trending,
      ));
    }

    // Historical pattern
    if (habit.completionHistory.isNotEmpty) {
      final peakHour = _calculatePeakHour(habit.completionHistory);
      insights.add(TimingInsight(
        title: 'Your Peak Hour',
        description: 'You usually complete around ${peakHour}:00',
        score: 0.8,
        iconType: IconType.calendar,
      ));
    }

    _timingInsights = insights;
  }

  void _updateCascadeAlerts(Habit habit) {
    if (_lastContext == null) return;

    final alerts = <CascadeAlert>[];

    final cascadeRisk = getCascadeRisk(habit: habit);
    if (cascadeRisk != null && cascadeRisk.probability > 0.3) {
      alerts.add(CascadeAlert(
        title: _cascadeTitle(cascadeRisk.pattern),
        description: cascadeRisk.reason,
        severity: cascadeRisk.probability,
        suggestedAction: cascadeRisk.suggestedAction,
        pattern: cascadeRisk.pattern,
      ));
    }

    // Weather alert
    if (_lastContext!.weather != null &&
        !_lastContext!.weather!.isOutdoorSuitable) {
      alerts.add(CascadeAlert(
        title: 'Weather Alert',
        description: 'Outdoor conditions are challenging today',
        severity: 0.4,
        suggestedAction: 'Consider an indoor alternative',
        pattern: CascadePattern.weatherBlocking,
      ));
    }

    // Travel alert
    if (_lastContext!.calendar?.isTravelDay == true) {
      alerts.add(CascadeAlert(
        title: 'Travel Day',
        description: 'Your routine may be disrupted',
        severity: 0.5,
        suggestedAction: 'Set a flexible reminder',
        pattern: CascadePattern.travelDisruption,
      ));
    }

    _cascadeAlerts = alerts;
  }

  String _describeTiming(double score) {
    if (score >= 0.8) return 'Excellent time to act';
    if (score >= 0.6) return 'Good time for your habit';
    if (score >= 0.4) return 'Moderate timing';
    if (score >= 0.2) return 'Challenging time';
    return 'Poor timing';
  }

  String _cascadeTitle(CascadePattern pattern) {
    switch (pattern) {
      case CascadePattern.weatherBlocking:
        return 'Weather Risk';
      case CascadePattern.travelDisruption:
        return 'Travel Disruption';
      case CascadePattern.weekendPattern:
        return 'Weekend Pattern';
      case CascadePattern.energyGap:
        return 'Energy Gap';
      case CascadePattern.yesterdayMiss:
        return 'Recovery Needed';
      case CascadePattern.multiDayMiss:
        return 'Cascade Alert';
    }
  }

  int _calculatePeakHour(List<DateTime> completions) {
    if (completions.isEmpty) return 9; // Default to morning

    final hourCounts = <int, int>{};
    for (final completion in completions) {
      final hour = completion.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    var maxHour = 9;
    var maxCount = 0;
    hourCounts.forEach((hour, count) {
      if (count > maxCount) {
        maxCount = count;
        maxHour = hour;
      }
    });

    return maxHour;
  }

  /// Check available sensors
  Future<Map<String, bool>> checkSensorAvailability() async {
    if (!_isInitialized) return {};
    return await _contextBuilder.checkSensorAvailability();
  }

  /// Request permissions for all sensors
  Future<Map<String, bool>> requestAllPermissions() async {
    if (!_isInitialized) return {};
    return await _contextBuilder.requestAllPermissions();
  }

  /// Run immediate intervention check (called on app foreground)
  Future<void> runForegroundCheck({
    required List<Habit> habits,
    required PsychometricProfile profile,
  }) async {
    if (!_isInitialized || !_isEnabled) return;

    for (final habit in habits) {
      if (habit.isCompletedToday || habit.isPaused) continue;

      await checkIntervention(
        habit: habit,
        profile: profile,
        trigger: DecisionTrigger.appOpen,
      );

      // Only trigger one intervention at a time
      if (_activeIntervention != null) break;
    }
  }

  /// Clean up resources
  @override
  void dispose() {
    JITAIBackgroundWorker.cancelBackgroundTasks();
    super.dispose();
  }
}
