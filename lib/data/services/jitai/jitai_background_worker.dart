/// JITAIBackgroundWorker - Periodic Intervention Scheduler
///
/// Runs JITAI decision checks periodically for each active habit.
/// Uses workmanager for background execution on Android/iOS.
///
/// Schedule:
/// - Every 30 minutes when app is in background
/// - Immediate check when app comes to foreground
/// - Smart scheduling based on optimal timing windows
///
/// Battery optimization:
/// - Batches sensor reads
/// - Uses lightweight snapshots when possible
/// - Respects Doze mode

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/entities/psychometric_profile.dart';
import '../../../domain/services/jitai_decision_engine.dart';
import '../../../domain/services/optimal_timing_predictor.dart';
import '../../../data/models/habit.dart';
import '../context/context_snapshot_builder.dart';
import 'jitai_notification_service.dart';

/// Unique task names for Workmanager
const String jitaiPeriodicTask = 'com.atomichabits.jitai.periodic';
const String jitaiOneOffTask = 'com.atomichabits.jitai.oneoff';

/// Background callback for Workmanager
@pragma('vm:entry-point')
void jitaiBackgroundCallback() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('JITAI Background: Executing $task');

    try {
      final worker = JITAIBackgroundWorker();
      await worker.initialize();

      switch (task) {
        case jitaiPeriodicTask:
          await worker.runPeriodicCheck();
          break;
        case jitaiOneOffTask:
          final habitId = inputData?['habitId'] as String?;
          if (habitId != null) {
            await worker.runCheckForHabit(habitId);
          }
          break;
      }

      return true;
    } catch (e) {
      debugPrint('JITAI Background Error: $e');
      return false;
    }
  });
}

class JITAIBackgroundWorker {
  late final ContextSnapshotBuilder _contextBuilder;
  late final JITAIDecisionEngine _decisionEngine;
  late final JITAINotificationService _notificationService;

  /// Minimum interval between checks (battery saving)
  static const Duration _minCheckInterval = Duration(minutes: 15);

  /// Periodic check interval
  static const Duration _periodicInterval = Duration(minutes: 30);

  JITAIBackgroundWorker();

  /// Initialize the worker
  Future<void> initialize() async {
    _contextBuilder = ContextSnapshotBuilder();
    _decisionEngine = JITAIDecisionEngine();
    _notificationService = JITAINotificationService();

    await _notificationService.initialize();
  }

  /// Register background tasks with Workmanager
  static Future<void> registerBackgroundTasks() async {
    await Workmanager().initialize(
      jitaiBackgroundCallback,
      isInDebugMode: kDebugMode,
    );

    // Register periodic task
    await Workmanager().registerPeriodicTask(
      jitaiPeriodicTask,
      jitaiPeriodicTask,
      frequency: _periodicInterval,
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: true,
      ),
      existingWorkPolicy: ExistingWorkPolicy.keep,
    );

    debugPrint('JITAI Background: Registered periodic task');
  }

  /// Cancel all background tasks
  static Future<void> cancelBackgroundTasks() async {
    await Workmanager().cancelAll();
    debugPrint('JITAI Background: Cancelled all tasks');
  }

  /// Schedule a one-off check for a specific habit
  static Future<void> scheduleCheckForHabit({
    required String habitId,
    required Duration delay,
  }) async {
    await Workmanager().registerOneOffTask(
      '$jitaiOneOffTask:$habitId',
      jitaiOneOffTask,
      initialDelay: delay,
      inputData: {'habitId': habitId},
      constraints: Constraints(
        networkType: NetworkType.not_required,
      ),
    );

    debugPrint('JITAI Background: Scheduled check for $habitId in $delay');
  }

  /// Run periodic check for all habits
  Future<void> runPeriodicCheck() async {
    // Check rate limiting
    if (!await _shouldRunCheck()) {
      debugPrint('JITAI Background: Skipping check (rate limited)');
      return;
    }

    // Load habits and profile
    final habits = await _loadHabits();
    final profile = await _loadProfile();

    if (habits.isEmpty || profile == null) {
      debugPrint('JITAI Background: No habits or profile');
      return;
    }

    // Check each habit
    for (final habit in habits) {
      await _checkHabit(habit, profile);
    }

    await _recordCheckTime();
  }

  /// Run check for a specific habit
  Future<void> runCheckForHabit(String habitId) async {
    final habits = await _loadHabits();
    final habit = habits.cast<Habit?>().firstWhere(
          (h) => h?.id == habitId,
          orElse: () => null,
        );

    if (habit == null) return;

    final profile = await _loadProfile();
    if (profile == null) return;

    await _checkHabit(habit, profile);
  }

  /// Check a single habit and potentially trigger intervention
  Future<void> _checkHabit(Habit habit, PsychometricProfile profile) async {
    try {
      // Skip if already completed today
      if (habit.isCompletedToday) {
        debugPrint('JITAI Background: ${habit.name} already completed');
        return;
      }

      // Skip paused habits
      if (habit.isPaused) {
        return;
      }

      // Build context snapshot
      final context = await _contextBuilder.build(habit: habit);

      // Check optimal timing first
      final timingScore = _decisionEngine.scoreCurrentTiming(
        habit: habit,
        context: context,
      );

      // Skip if timing is poor (unless cascade risk)
      final cascadeRisk = _decisionEngine.getCascadeRisk(
        habit: habit,
        context: context,
      );

      if (timingScore.score < 0.35 && !cascadeRisk.isHighRisk) {
        debugPrint('JITAI Background: ${habit.name} poor timing, deferring');

        // Schedule for optimal window
        final windows = _decisionEngine.getOptimalWindows(
          habit: habit,
          context: context,
        );

        if (windows.isNotEmpty) {
          final nextWindow = windows.first;
          final minutesUntil = nextWindow.minutesUntilWindow(DateTime.now());
          if (minutesUntil > 0 && minutesUntil < 180) {
            await scheduleCheckForHabit(
              habitId: habit.id,
              delay: Duration(minutes: minutesUntil),
            );
          }
        }

        return;
      }

      // Run full decision
      final decision = await _decisionEngine.decide(
        context: context,
        profile: profile,
        habit: habit,
        trigger: DecisionTrigger.scheduled,
      );

      // Deliver intervention if needed
      if (decision.shouldIntervene) {
        await _notificationService.deliverIntervention(decision);
        debugPrint('JITAI Background: Delivered ${decision.event?.arm.armId} for ${habit.name}');
      } else if (decision.type == JITAIDecisionType.deferred) {
        // Schedule retry
        final retryAfter = decision.retryAfter ?? const Duration(minutes: 30);
        await scheduleCheckForHabit(
          habitId: habit.id,
          delay: retryAfter,
        );
        debugPrint('JITAI Background: Deferred ${habit.name} for $retryAfter');
      }
    } catch (e) {
      debugPrint('JITAI Background: Error checking ${habit.name}: $e');
    }
  }

  /// Check if we should run (rate limiting)
  Future<bool> _shouldRunCheck() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheck = prefs.getString('jitai_last_check');

      if (lastCheck == null) return true;

      final lastTime = DateTime.parse(lastCheck);
      final elapsed = DateTime.now().difference(lastTime);

      return elapsed >= _minCheckInterval;
    } catch (_) {
      return true;
    }
  }

  /// Record check time for rate limiting
  Future<void> _recordCheckTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jitai_last_check', DateTime.now().toIso8601String());
    } catch (_) {
      // Ignore
    }
  }

  /// Load habits from storage
  Future<List<Habit>> _loadHabits() async {
    // TODO: Wire to actual habit repository
    // For now, return empty list (would load from Hive/Supabase)
    try {
      final prefs = await SharedPreferences.getInstance();
      final habitsJson = prefs.getString('habits_cache');
      if (habitsJson == null) return [];

      // Would deserialize habits here
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Load profile from storage
  Future<PsychometricProfile?> _loadProfile() async {
    // TODO: Wire to actual profile provider
    // For now, return null (would load from Hive/Supabase)
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString('profile_cache');
      if (profileJson == null) return null;

      // Would deserialize profile here
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Force immediate check (called when app foregrounds)
  static Future<void> runImmediateCheck() async {
    final worker = JITAIBackgroundWorker();
    await worker.initialize();
    await worker.runPeriodicCheck();
  }
}

/// App lifecycle observer for JITAI
class JITAILifecycleObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App came to foreground - run immediate check
      JITAIBackgroundWorker.runImmediateCheck();
    }
  }

  /// Register the observer
  static void register() {
    WidgetsBinding.instance.addObserver(JITAILifecycleObserver());
  }
}
