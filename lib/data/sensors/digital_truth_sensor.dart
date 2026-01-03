import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:app_usage/app_usage.dart';

/// Represents a single app usage session with precise timing
class AppSession {
  final String packageName;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final bool isActive;

  AppSession({
    required this.packageName,
    required this.startTime,
    required this.endTime,
    required this.duration,
    this.isActive = false,
  });

  factory AppSession.fromMap(Map<dynamic, dynamic> map) {
    return AppSession(
      packageName: map['packageName'] as String,
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime'] as int),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime'] as int),
      duration: Duration(milliseconds: map['durationMs'] as int),
      isActive: map['isActive'] as bool? ?? false,
    );
  }

  /// Human-readable app name (strips package prefix)
  String get appName {
    final parts = packageName.split('.');
    return parts.isNotEmpty ? parts.last : packageName;
  }
}

/// Alert generated when dopamine loop behavior is detected
class DopamineLoopAlert {
  final List<AppSession> sessions;
  final int switchCount;
  final Duration windowDuration;
  final DateTime detectedAt;

  DopamineLoopAlert({
    required this.sessions,
    required this.switchCount,
    required this.windowDuration,
    required this.detectedAt,
  });

  /// Human-readable description
  String get description {
    final apps = sessions.map((s) => s.appName).toSet().join(', ');
    final minutes = windowDuration.inMinutes;
    return 'Switched between $switchCount apps in $minutes min: $apps';
  }
}

/// DigitalTruthSensor: The "Truth" of the Nervous System.
///
/// Monitors digital consumption to detect "Dopamine Binge" states.
///
/// Features:
/// - Event-based tracking via UsageEvents.queryEvents() for precise session data
/// - Dopamine loop detection (rapid app switching patterns)
/// - Session-level analytics (count, avg duration, longest session)
///
/// Platforms:
/// - Android: Uses native UsageEvents API via platform channel + app_usage fallback
/// - iOS: Not supported directly (API restriction). Future: "Honesty Box" screenshot parsing.
class DigitalTruthSensor {
  // Singleton
  static final DigitalTruthSensor _instance = DigitalTruthSensor._internal();
  factory DigitalTruthSensor() => _instance;
  DigitalTruthSensor._internal();

  /// Platform channel for native UsageEvents API
  static const _channel = MethodChannel('co.thepact/usage_events');

  /// Known Dopamine Agonists (Distraction Apps)
  /// These are the enemies of deep work.
  static const Set<String> distractionPackages = {
    'com.zhiliaoapp.musically', // TikTok
    'com.instagram.android',    // Instagram
    'com.twitter.android',      // Twitter/X
    'com.snapchat.android',     // Snapchat
    'com.facebook.katana',      // Facebook
    'com.google.android.youtube', // YouTube
    'tv.twitch.android.app',    // Twitch
    'com.reddit.frontpage',     // Reddit
    'com.pinterest',            // Pinterest
  };

  /// Thresholds for dopamine loop detection
  static const int _loopSwitchThreshold = 3;  // Min switches to trigger alert
  static const Duration _loopWindowDuration = Duration(minutes: 5);

  /// Check if we can collect data on this platform
  bool get isSupported => Platform.isAndroid;

  // ============================================================
  // EVENT-BASED TRACKING (New - uses queryEvents())
  // ============================================================

  /// Get app sessions for today with precise timing
  /// Uses native UsageEvents.queryEvents() for event-based tracking
  Future<List<AppSession>> getAppSessions({Set<String>? packageFilter}) async {
    if (!isSupported) return [];

    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      final result = await _channel.invokeMethod('getAppSessions', {
        'startTime': midnight.millisecondsSinceEpoch,
        'endTime': now.millisecondsSinceEpoch,
        if (packageFilter != null) 'packages': packageFilter.toList(),
      });

      if (result == null) return [];

      return (result as List)
          .map((e) => AppSession.fromMap(e as Map))
          .toList();
    } catch (e) {
      debugPrint('DigitalTruthSensor: Error fetching app sessions: $e');
      return [];
    }
  }

  /// Get distraction app sessions only
  Future<List<AppSession>> getDistractionSessions() async {
    return getAppSessions(packageFilter: distractionPackages);
  }

  /// Detect dopamine loop patterns (rapid switching between distraction apps)
  /// Returns alert if user switched between 3+ distraction apps within 5 minutes
  Future<DopamineLoopAlert?> detectDopamineLoop() async {
    if (!isSupported) return null;

    try {
      final now = DateTime.now();
      final windowStart = now.subtract(_loopWindowDuration);

      // Get all sessions in the detection window
      final result = await _channel.invokeMethod('getAppSessions', {
        'startTime': windowStart.millisecondsSinceEpoch,
        'endTime': now.millisecondsSinceEpoch,
        'packages': distractionPackages.toList(),
      });

      if (result == null) return null;

      final sessions = (result as List)
          .map((e) => AppSession.fromMap(e as Map))
          .toList();

      // Need at least N switches to constitute a loop
      if (sessions.length < _loopSwitchThreshold) return null;

      // Count unique apps switched between
      final uniqueApps = sessions.map((s) => s.packageName).toSet();

      // Must be switching between multiple apps (not just reopening same app)
      if (uniqueApps.length < 2) return null;

      return DopamineLoopAlert(
        sessions: sessions,
        switchCount: sessions.length,
        windowDuration: _loopWindowDuration,
        detectedAt: now,
      );
    } catch (e) {
      debugPrint('DigitalTruthSensor: Error detecting dopamine loop: $e');
      return null;
    }
  }

  /// Get session statistics for distraction apps
  Future<Map<String, dynamic>> getDistractionStats() async {
    final sessions = await getDistractionSessions();

    if (sessions.isEmpty) {
      return {
        'sessionCount': 0,
        'totalMinutes': 0,
        'avgSessionMinutes': 0.0,
        'longestSessionMinutes': 0,
        'uniqueApps': 0,
      };
    }

    final totalMs = sessions.fold<int>(
      0,
      (sum, s) => sum + s.duration.inMilliseconds,
    );
    final longestMs = sessions.map((s) => s.duration.inMilliseconds).reduce(
      (a, b) => a > b ? a : b,
    );
    final uniqueApps = sessions.map((s) => s.packageName).toSet().length;

    return {
      'sessionCount': sessions.length,
      'totalMinutes': (totalMs / 60000).round(),
      'avgSessionMinutes': (totalMs / sessions.length / 60000).toStringAsFixed(1),
      'longestSessionMinutes': (longestMs / 60000).round(),
      'uniqueApps': uniqueApps,
      'sessions': sessions,
    };
  }

  // ============================================================
  // LEGACY API (Fallback - uses queryUsageStats())
  // ============================================================

  /// Get usage statistics for today (aggregated, less precise)
  /// Returns a map of Package Name -> Minutes Used
  ///
  /// Note: Prefer getAppSessions() for event-level precision
  Future<Map<String, int>> getDailyUsage() async {
    if (!isSupported) return {};

    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      // Get usage from midnight to now
      List<AppUsageInfo> infos = await AppUsage().getAppUsage(
        midnight,
        now
      );

      final usageMap = <String, int>{};
      for (var info in infos) {
        final minutes = info.usage.inMinutes;
        if (minutes > 0) {
          usageMap[info.packageName] = minutes;
        }
      }
      return usageMap;

    } catch (e) {
      debugPrint('DigitalTruthSensor: Error fetching usage stats: $e');
      return {};
    }
  }

  /// Calculate "Dopamine Burn" (Total minutes on distraction apps)
  Future<int> getDopamineBurnMinutes() async {
    // Try event-based first for accuracy
    try {
      final stats = await getDistractionStats();
      final minutes = stats['totalMinutes'] as int?;
      if (minutes != null && minutes > 0) return minutes;
    } catch (_) {}

    // Fallback to legacy aggregated stats
    final usage = await getDailyUsage();
    int totalBurn = 0;

    usage.forEach((pkg, minutes) {
       if (distractionPackages.contains(pkg)) {
         totalBurn += minutes;
       }
    });

    return totalBurn;
  }

  /// Identify the "Apex Distractor" (Most used distraction app)
  Future<String?> getApexDistractor() async {
    final usage = await getDailyUsage();
    String? topApp;
    int maxMinutes = 0;

    usage.forEach((pkg, minutes) {
      if (distractionPackages.contains(pkg)) {
        if (minutes > maxMinutes) {
          maxMinutes = minutes;
          topApp = pkg;
        }
      }
    });

    return topApp;
  }
}
