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
import 'package:flutter/widgets.dart';

import '../../domain/entities/context_snapshot.dart';
import '../repositories/jitai_state_repository.dart';
import '../../domain/entities/psychometric_profile.dart';
import '../../domain/services/jitai_decision_engine.dart';
import '../../domain/entities/intervention.dart';
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
  final CascadeRiskReason pattern;

  const CascadeAlert({
    required this.title,
    required this.description,
    required this.severity,
    required this.suggestedAction,
    required this.pattern,
  });
}

class JITAIProvider extends ChangeNotifier with WidgetsBindingObserver {
  // Services
  late final JITAIDecisionEngine _decisionEngine;
  late final ContextSnapshotBuilder _contextBuilder;
  late final JITAINotificationService _notificationService;
  late final OptimalTimingPredictor _timingPredictor;
  late final CascadePatternDetector _cascadeDetector;

  // Sprint 1: Bandit persistence repository
  late final JITAIStateRepository _stateRepository;

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
  final Duration _contextRefreshInterval = const Duration(minutes: 15);

  // === Phase 65: Guardian Mode State ===
  bool _guardianModeEnabled = false;
  Timer? _guardianPollTimer;
  final Duration _guardianPollInterval = const Duration(seconds: 30);

  // Guardian intervention thresholds (configurable)
  final Map<int, Duration> _guardianThresholds = {
    1: const Duration(minutes: 5),  // Tier 1: Gentle nudge
    2: const Duration(minutes: 10), // Tier 2: Moderate intervention
    3: const Duration(minutes: 20), // Tier 3: Strong intervention
  };

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

  // Phase 65: Guardian Mode getters
  bool get guardianModeEnabled => _guardianModeEnabled;
  bool get guardianModeActive => _guardianPollTimer != null && _guardianPollTimer!.isActive;

  /// Initialize the JITAI system
  ///
  /// Sprint 1: Now hydrates bandit state from persistence on startup.
  Future<void> initialize({
    String? weatherApiKey,
    JITAIStateRepository? stateRepository,
  }) async {
    if (_isInitialized) return;

    try {
      _decisionEngine = JITAIDecisionEngine();
      _contextBuilder = ContextSnapshotBuilder();
      _notificationService = JITAINotificationService();
      _timingPredictor = OptimalTimingPredictor();
      _cascadeDetector = CascadePatternDetector();

      // Sprint 1: Initialize state repository (injectable for testing)
      _stateRepository = stateRepository ?? HiveJITAIStateRepository();
      await _stateRepository.init();

      // Sprint 1: Hydrate bandit state from persistence
      await _hydrateBanditState();

      // Initialize services
      await _contextBuilder.initialize(weatherApiKey: weatherApiKey);
      await _notificationService.initialize();

      // Register background tasks
      await JITAIBackgroundWorker.registerBackgroundTasks();

      // Register lifecycle observers
      JITAILifecycleObserver.register();
      WidgetsBinding.instance.addObserver(this);

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

  /// Sprint 1: Hydrate bandit state from persistence
  Future<void> _hydrateBanditState() async {
    try {
      final savedState = await _stateRepository.loadBanditState();
      if (savedState != null) {
        _decisionEngine.importState(savedState);
        if (kDebugMode) {
          debugPrint('JITAIProvider: Bandit state hydrated from persistence');
        }
      } else {
        if (kDebugMode) {
          debugPrint('JITAIProvider: No saved bandit state, using fresh priors');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('JITAIProvider: Failed to hydrate bandit state: $e');
      }
    }
  }

  /// Sprint 1: Persist bandit state to storage
  Future<void> _persistBanditState() async {
    if (!_isInitialized) return;

    try {
      final state = _decisionEngine.exportState();
      await _stateRepository.saveBanditState(state);
      if (kDebugMode) {
        debugPrint('JITAIProvider: Bandit state persisted');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('JITAIProvider: Failed to persist bandit state: $e');
      }
    }
  }

  /// Sprint 1: Handle app lifecycle changes for persistence
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // Persist bandit state when app goes to background
      _persistBanditState();
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
    DecisionTrigger trigger = DecisionTrigger.scheduled,
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
  ///
  /// Sprint 1: Now persists bandit state after recording outcome.
  Future<void> recordInterventionOutcome({
    required String eventId,
    required bool engaged,
    required bool habitCompleted,
    int? engagementSeconds,
  }) async {
    if (!_isInitialized) return;

    try {
      final outcome = InterventionOutcome(
        eventId: eventId,
        notificationOpened: engaged,
        habitCompleted24h: habitCompleted,
        timeToOpenSeconds: engagementSeconds,
      );

      _decisionEngine.recordOutcome(
        eventId: eventId,
        outcome: outcome,
      );

      // Sprint 1: Persist bandit state after learning (significant event)
      await _persistBanditState();

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
    final nextWindow = _timingPredictor.getBestWindowForNow(
      habit: habit,
      context: _lastContext!,
    );
    
    if (nextWindow != null) {
      final endHour = nextWindow.optimalHour + (nextWindow.windowMinutes / 60).ceil();
      insights.add(TimingInsight(
        title: 'Optimal Window',
        description: '${nextWindow.optimalHour}:00 - $endHour:00',
        score: nextWindow.confidence,
        iconType: IconType.clock,
      ));
    }

    // Historical pattern
    if (habit.completionHistory.isNotEmpty) {
      final peakHour = _calculatePeakHour(habit.completionHistory);
      insights.add(TimingInsight(
        title: 'Your Peak Hour',
        description: 'You usually complete around $peakHour:00',
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
        title: _cascadeTitle(cascadeRisk.reason),
        description: cascadeRisk.explanation,
        severity: cascadeRisk.probability,
        suggestedAction: _cascadeDetector.getAlternativeSuggestion(habit: habit, risk: cascadeRisk) ?? '',
        pattern: cascadeRisk.reason,
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
        pattern: CascadeRiskReason.weatherBlocking,
      ));
    }

    // Travel alert
    if (_lastContext!.calendar?.isTravelDay == true) {
      alerts.add(CascadeAlert(
        title: 'Travel Day',
        description: 'Your routine may be disrupted',
        severity: 0.5,
        suggestedAction: 'Set a flexible reminder',
        pattern: CascadeRiskReason.travelDisruption,
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

  String _cascadeTitle(CascadeRiskReason pattern) {
    switch (pattern) {
      case CascadeRiskReason.weatherBlocking:
        return 'Weather Risk';
      case CascadeRiskReason.travelDisruption:
        return 'Travel Disruption';
      case CascadeRiskReason.weekendPattern:
        return 'Weekend Pattern';
      case CascadeRiskReason.energyGap:
        return 'Energy Gap';
      case CascadeRiskReason.yesterdayMiss:
        return 'Recovery Needed';
      case CascadeRiskReason.multiDayMiss:
        return 'Cascade Alert';
      default:
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

  // === Phase 65: Guardian Mode Methods ===

  /// Enable/disable Guardian Mode (real-time doom scroll detection)
  ///
  /// Guardian Mode uses adaptive polling to detect active doom scrolling sessions
  /// and trigger interventions at configurable thresholds (5min, 10min, 20min).
  ///
  /// When enabled, polls every 30 seconds (baseline) or 5 seconds (when distraction app active).
  /// Requires Usage Stats permission on Android.
  Future<void> setGuardianMode(bool enabled) async {
    if (_guardianModeEnabled == enabled) return;
    if (!_isInitialized) return;

    _guardianModeEnabled = enabled;

    if (enabled) {
      await _startGuardianPolling();
      if (kDebugMode) {
        debugPrint('JITAIProvider: Guardian Mode enabled');
      }
    } else {
      await _stopGuardianPolling();
      if (kDebugMode) {
        debugPrint('JITAIProvider: Guardian Mode disabled');
      }
    }

    notifyListeners();
  }

  /// Start Guardian Mode polling loop
  Future<void> _startGuardianPolling() async {
    if (_guardianPollTimer != null) return;

    // Initial check
    await _guardianCheck();

    // Start periodic polling
    _guardianPollTimer = Timer.periodic(_guardianPollInterval, (_) async {
      await _guardianCheck();
    });
  }

  /// Stop Guardian Mode polling loop
  Future<void> _stopGuardianPolling() async {
    _guardianPollTimer?.cancel();
    _guardianPollTimer = null;
  }

  /// Guardian Mode polling check
  ///
  /// TODO: This is a placeholder implementation. Requires native bridge enhancements:
  /// - DigitalTruthSensor.getAppSessions() for real-time session tracking
  /// - DigitalTruthSensor.detectDopamineLoop() for rapid app switching
  ///
  /// Current implementation uses basic distraction minutes check as fallback.
  Future<void> _guardianCheck() async {
    if (!_guardianModeEnabled || !_isInitialized) return;

    try {
      // TODO: Replace with native bridge call when available
      // final sessions = await _digitalSensor.getAppSessions();
      // final activeSession = sessions.firstWhereOrNull((s) => s.isActive);
      // if (activeSession == null) return;

      // PLACEHOLDER: Use basic digital context check
      if (_lastContext?.digital == null) return;

      final digital = _lastContext!.digital!;

      // Check for active doom scrolling
      // TODO: This will be replaced with real-time session tracking
      if (digital.isHighDistraction) {
        // Check intervention thresholds
        // For now, using daily distraction minutes as proxy
        // TODO: Replace with current session duration
        final sessionMinutes = digital.distractionMinutes; // Placeholder

        // Determine tier based on session duration
        int? tier;
        if (sessionMinutes >= _guardianThresholds[3]!.inMinutes) {
          tier = 3; // Strong intervention
        } else if (sessionMinutes >= _guardianThresholds[2]!.inMinutes) {
          tier = 2; // Moderate intervention
        } else if (sessionMinutes >= _guardianThresholds[1]!.inMinutes) {
          tier = 1; // Gentle nudge
        }

        if (tier != null && _activeIntervention == null) {
          // Trigger Guardian Mode intervention
          // TODO: Pass actual habit and profile
          if (kDebugMode) {
            debugPrint('JITAIProvider: Guardian Mode triggered (Tier $tier) - ${sessionMinutes}min doom scrolling detected');
          }

          // This would trigger a JITAI decision with DecisionTrigger.guardianMode
          // For now, just log it
          // await checkIntervention(
          //   habit: currentHabit,
          //   profile: currentProfile,
          //   trigger: DecisionTrigger.guardianMode,
          // );
        }
      }

      // TODO: Check for dopamine loop detection
      // final loopAlert = await _digitalSensor.detectDopamineLoop();
      // if (loopAlert != null) {
      //   // Trigger intervention with DecisionTrigger.dopamineLoop
      // }

    } catch (e) {
      if (kDebugMode) {
        debugPrint('JITAIProvider: Guardian check failed: $e');
      }
    }
  }

  /// Update Guardian Mode intervention thresholds
  void setGuardianThresholds({
    Duration? tier1,
    Duration? tier2,
    Duration? tier3,
  }) {
    if (tier1 != null) _guardianThresholds[1] = tier1;
    if (tier2 != null) _guardianThresholds[2] = tier2;
    if (tier3 != null) _guardianThresholds[3] = tier3;
    notifyListeners();
  }

  /// Get current Guardian Mode thresholds
  Map<int, Duration> get guardianThresholds => Map.unmodifiable(_guardianThresholds);

  /// Clean up resources
  ///
  /// Sprint 1: Now persists bandit state before disposing.
  @override
  void dispose() {
    // Sprint 1: Persist bandit state before cleanup
    _persistBanditState();

    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);

    _stopGuardianPolling();
    JITAIBackgroundWorker.cancelBackgroundTasks();
    super.dispose();
  }
}
