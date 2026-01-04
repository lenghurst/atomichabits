import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:app_usage/app_usage.dart';

/// DigitalTruthSensor: The "Truth" of the Nervous System.
///
/// Monitors digital consumption to detect "Dopamine Binge" states.
///
/// Platforms:
/// - Android: Uses `app_usage` (UsageStatsManager).
/// - iOS: Not supported directly (API restriction). Future: "Honesty Box" screenshot parsing.
///
/// Sprint 2: Added comprehensive crash protection for native bridge failures.
class DigitalTruthSensor {
  // Singleton
  static final DigitalTruthSensor _instance = DigitalTruthSensor._internal();
  factory DigitalTruthSensor() => _instance;
  DigitalTruthSensor._internal();

  /// Known Dopamine Agonists (Distraction Apps)
  /// These are the enemies of deep work.
  static const Set<String> _distractionPackages = {
    'com.zhiliaoapp.musically', // TikTok
    'com.instagram.android', // Instagram
    'com.twitter.android', // Twitter/X
    'com.snapchat.android', // Snapchat
    'com.facebook.katana', // Facebook
    'com.google.android.youtube', // YouTube
    'tv.twitch.android.app', // Twitch
  };

  /// Sprint 2: Track if we've had a native bridge failure
  bool _hasNativeFailure = false;
  DateTime? _lastFailureTime;

  /// Check if we can collect data on this platform
  bool get isSupported {
    // Don't attempt if we recently had a native failure
    if (_hasNativeFailure && _lastFailureTime != null) {
      final timeSinceFailure = DateTime.now().difference(_lastFailureTime!);
      if (timeSinceFailure < const Duration(minutes: 5)) {
        return false; // Back off after failure
      }
      // Reset after backoff period
      _hasNativeFailure = false;
    }

    try {
      return Platform.isAndroid;
    } catch (e) {
      debugPrint('DigitalTruthSensor: Platform check failed: $e');
      return false;
    }
  }

  /// Get usage statistics for today
  /// Returns a map of Package Name -> Minutes Used
  ///
  /// Sprint 2: Enhanced crash protection with:
  /// - PlatformException handling (missing permission)
  /// - MissingPluginException handling (plugin not registered)
  /// - Backoff after repeated failures
  Future<Map<String, int>> getDailyUsage() async {
    if (!isSupported) return {};

    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      // Get usage from midnight to now
      List<AppUsageInfo> infos = await AppUsage()
          .getAppUsage(midnight, now)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              debugPrint('DigitalTruthSensor: Timeout fetching usage stats');
              return <AppUsageInfo>[];
            },
          );

      final usageMap = <String, int>{};
      for (var info in infos) {
        // AppUsageInfo returns usage in Duration or similar
        // Based on plugin: info.usage is Duration
        final minutes = info.usage.inMinutes;
        if (minutes > 0) {
          usageMap[info.packageName] = minutes;
        }
      }

      // Reset failure state on success
      _hasNativeFailure = false;

      return usageMap;
    } on PlatformException catch (e) {
      // Permission not granted or platform API error
      debugPrint('DigitalTruthSensor: PlatformException: ${e.message}');
      _recordFailure();
      return {};
    } on MissingPluginException catch (e) {
      // Plugin not registered (e.g., running on unsupported platform)
      debugPrint('DigitalTruthSensor: MissingPluginException: ${e.message}');
      _recordFailure();
      return {};
    } catch (e) {
      // Catch-all for any other errors
      debugPrint('DigitalTruthSensor: Error fetching usage stats: $e');
      _recordFailure();
      return {};
    }
  }

  /// Sprint 2: Record a native failure for backoff
  void _recordFailure() {
    _hasNativeFailure = true;
    _lastFailureTime = DateTime.now();
  }

  /// Calculate "Dopamine Burn" (Total minutes on distraction apps)
  ///
  /// Sprint 2: Returns 0 on any error (safe default).
  Future<int> getDopamineBurnMinutes() async {
    try {
      final usage = await getDailyUsage();
      int totalBurn = 0;

      usage.forEach((pkg, minutes) {
        if (_distractionPackages.contains(pkg)) {
          totalBurn += minutes;
        }
      });

      return totalBurn;
    } catch (e) {
      debugPrint('DigitalTruthSensor: Error calculating dopamine burn: $e');
      return 0; // Safe default
    }
  }

  /// Identify the "Apex Distractor" (Most used distraction app)
  ///
  /// Sprint 2: Returns null on any error (safe default).
  Future<String?> getApexDistractor() async {
    try {
      final usage = await getDailyUsage();
      String? topApp;
      int maxMinutes = 0;

      usage.forEach((pkg, minutes) {
        if (_distractionPackages.contains(pkg)) {
          if (minutes > maxMinutes) {
            maxMinutes = minutes;
            topApp = pkg;
          }
        }
      });

      return topApp;
    } catch (e) {
      debugPrint('DigitalTruthSensor: Error finding apex distractor: $e');
      return null; // Safe default
    }
  }

  /// Sprint 2: Check if usage stats permission is granted
  ///
  /// Returns false on any error (safe default).
  Future<bool> hasPermission() async {
    if (!isSupported) return false;

    try {
      // Try to get minimal usage data to check permission
      final now = DateTime.now();
      final oneMinuteAgo = now.subtract(const Duration(minutes: 1));

      await AppUsage().getAppUsage(oneMinuteAgo, now).timeout(
            const Duration(seconds: 5),
            onTimeout: () => <AppUsageInfo>[],
          );

      return true; // If we got here without exception, permission is granted
    } catch (e) {
      debugPrint('DigitalTruthSensor: Permission check failed: $e');
      return false;
    }
  }

  /// Sprint 2: Get friendly app name from package name
  String getAppName(String packageName) {
    const packageNames = {
      'com.zhiliaoapp.musically': 'TikTok',
      'com.instagram.android': 'Instagram',
      'com.twitter.android': 'X (Twitter)',
      'com.snapchat.android': 'Snapchat',
      'com.facebook.katana': 'Facebook',
      'com.google.android.youtube': 'YouTube',
      'tv.twitch.android.app': 'Twitch',
    };

    return packageNames[packageName] ?? packageName.split('.').last;
  }
}
