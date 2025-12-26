import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:app_usage/app_usage.dart';

/// DigitalTruthSensor: The "Truth" of the Nervous System.
/// 
/// Monitors digital consumption to detect "Dopamine Binge" states.
/// 
/// Platforms:
/// - Android: Uses `app_usage` (UsageStatsManager).
/// - iOS: Not supported directly (API restriction). Future: "Honesty Box" screenshot parsing.
class DigitalTruthSensor {
  // Singleton
  static final DigitalTruthSensor _instance = DigitalTruthSensor._internal();
  factory DigitalTruthSensor() => _instance;
  DigitalTruthSensor._internal();

  /// Known Dopamine Agonists (Distraction Apps)
  /// These are the enemies of deep work.
  static const Set<String> _distractionPackages = {
    'com.zhiliaoapp.musically', // TikTok
    'com.instagram.android',    // Instagram
    'com.twitter.android',      // Twitter/X
    'com.snapchat.android',     // Snapchat
    'com.facebook.katana',      // Facebook
    'com.google.android.youtube', // YouTube
    'tv.twitch.android.app',    // Twitch
  };

  /// Check if we can collect data on this platform
  bool get isSupported => Platform.isAndroid;

  /// Get usage statistics for today
  /// Returns a map of Package Name -> Minutes Used
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
        // AppUsageInfo returns usage in Duration or similar
        // Based on plugin: info.usage is Duration
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
    final usage = await getDailyUsage();
    int totalBurn = 0;

    usage.forEach((pkg, minutes) {
       if (_distractionPackages.contains(pkg)) {
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
      if (_distractionPackages.contains(pkg)) {
        if (minutes > maxMinutes) {
          maxMinutes = minutes;
          topApp = pkg;
        }
      }
    });

    return topApp;
  }
}
