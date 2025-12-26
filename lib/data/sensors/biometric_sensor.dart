import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

/// BiometricSensor: The "Body" of the Nervous System.
/// 
/// Monitors physiological state (Sleep, HRV) to determine willpower capability.
/// 
/// Privacy:
/// - Data is processed locally to update `PsychometricProfile`.
/// - We only care about deviations from baseline (e.g., "Sleep Deprived").
class BiometricSensor {
  // Singleton
  static final BiometricSensor _instance = BiometricSensor._internal();
  factory BiometricSensor() => _instance;
  BiometricSensor._internal();

  // In recent versions of health package, main class is Health
  final Health _health = Health();

  /// Types of data we care about for the Sherlock Protocol
  static const _types = [
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.HEART_RATE_VARIABILITY_SDNN, // Stress indicator
  ];

  /// Initialize and request permissions
  Future<bool> initialize() async {
    try {
      // Check if health data is available on this device
      // Note: Android requires Health Connect installed
      final requested = await _health.requestAuthorization(_types);
      
      if (!requested) {
        debugPrint('BiometricSensor: Permissions denied or cancelled.');
      }
      return requested;
    } catch (e) {
      debugPrint('BiometricSensor: Error initializing: $e');
      return false;
    }
  }

  /// Get total sleep minutes for the previous night
  /// Returns -1 if no data available
  Future<int> getLastNightSleepMinutes() async {
    try {
      final now = DateTime.now();
      // Look back 24 hours to capture the full night
      final midnight = DateTime(now.year, now.month, now.day);
      final yesterday = midnight.subtract(const Duration(hours: 24));
      
      // Fetch sleep data
      final healthData = await _health.getHealthDataFromTypes(
        startTime: yesterday,
        endTime: now,
        types: [HealthDataType.SLEEP_ASLEEP],
      );

      if (healthData.isEmpty) return -1;

      // Sum up duration of all sleep segments
      int totalMinutes = 0;
      for (var point in healthData) {
         // Fix: point.value might not be reliable for sleep duration across platforms
         // Rely on date difference
         final duration = point.dateTo.difference(point.dateFrom).inMinutes;
         totalMinutes += duration;
      }
      
      return totalMinutes;
    } catch (e) {
      debugPrint('BiometricSensor: Error fetching sleep: $e');
      return -1;
    }
  }

  /// Get latest HRV (Heart Rate Variability) reading (SDNN ms)
  /// Returns -1 if no data available
  Future<double> getLatestHRV() async {
    try {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(hours: 24));

      final healthData = await _health.getHealthDataFromTypes(
        startTime: yesterday,
        endTime: now,
        types: [HealthDataType.HEART_RATE_VARIABILITY_SDNN],
      );
      
      // Health returns a list. We want the most recent.
      // Sort by dateTo descending
      healthData.sort((a, b) => b.dateTo.compareTo(a.dateTo));

      if (healthData.isEmpty) return -1;

      final latest = healthData.first;
      // Extract numeric value
      // This part depends on Health package version API
      // Assuming NumericHealthValue
      if (latest.value is NumericHealthValue) {
        return (latest.value as NumericHealthValue).numericValue.toDouble();
      }
      
      return -1;
    } catch (e) {
      debugPrint('BiometricSensor: Error fetching HRV: $e');
      return -1;
    }
  }
}
