/// BiometricsService - Health Connect / HealthKit Integration
///
/// Fetches biometric data for cascade prevention:
/// - Sleep duration (energy gap detection)
/// - Heart rate variability (stress detection)
///
/// Uses health package for cross-platform support.
/// Z-scores are calculated relative to user's 30-day baseline.

import 'dart:math';

import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/entities/context_snapshot.dart';

class BiometricsService {
  final Health _health;

  /// Cache duration for biometrics
  static const Duration _cacheDuration = Duration(minutes: 15);

  /// Days to use for baseline calculation
  static const int _baselineDays = 30;

  BiometricContext? _cachedContext;
  DateTime? _cacheTimestamp;

  /// Historical baselines for z-score calculation
  double? _sleepMean;
  double? _sleepStd;
  double? _hrvMean;
  double? _hrvStd;

  BiometricsService({
    Health? health,
  }) : _health = health ?? Health();

  /// Initialize the service and request permissions
  Future<bool> initialize() async {
    try {
      // Configure health
      await _health.configure();

      // Request permissions
      final types = [
        HealthDataType.SLEEP_ASLEEP,
        HealthDataType.SLEEP_IN_BED,
        HealthDataType.HEART_RATE_VARIABILITY_SDNN,
      ];

      final permissions = types.map((_) => HealthDataAccess.READ).toList();

      final granted = await _health.requestAuthorization(
        types,
        permissions: permissions,
      );

      if (granted) {
        await _loadBaselines();
      }

      return granted;
    } catch (e) {
      return false;
    }
  }

  /// Get biometric context
  Future<BiometricContext?> getBiometricContext() async {
    // Check cache
    if (_cachedContext != null && _cacheTimestamp != null) {
      final age = DateTime.now().difference(_cacheTimestamp!);
      if (age < _cacheDuration) {
        return _cachedContext;
      }
    }

    try {
      final context = await _fetchBiometricContext();
      _cachedContext = context;
      _cacheTimestamp = DateTime.now();
      return context;
    } catch (e) {
      return null;
    }
  }

  /// Fetch biometric data from health APIs
  Future<BiometricContext?> _fetchBiometricContext() async {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(hours: 24));
    final lastNight = DateTime(now.year, now.month, now.day).subtract(
      const Duration(hours: 12),
    );

    // Fetch sleep data (last night)
    int? sleepMinutes;
    try {
      final sleepData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.SLEEP_ASLEEP, HealthDataType.SLEEP_IN_BED],
        startTime: lastNight,
        endTime: now,
      );

      if (sleepData.isNotEmpty) {
        // Sum up sleep segments
        var totalSleep = Duration.zero;
        for (final point in sleepData) {
          if (point.value is NumericHealthValue) {
            totalSleep += Duration(
              minutes: (point.value as NumericHealthValue).numericValue.toInt(),
            );
          }
        }
        sleepMinutes = totalSleep.inMinutes;
      }
    } catch (_) {
      // Sleep data unavailable
    }

    // Fetch HRV data (last 24 hours, use most recent)
    double? hrvSdnn;
    try {
      final hrvData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE_VARIABILITY_SDNN],
        startTime: yesterday,
        endTime: now,
      );

      if (hrvData.isNotEmpty) {
        // Sort by date, take most recent
        hrvData.sort((a, b) => b.dateTo.compareTo(a.dateTo));
        final latest = hrvData.first;
        if (latest.value is NumericHealthValue) {
          hrvSdnn = (latest.value as NumericHealthValue).numericValue.toDouble();
        }
      }
    } catch (_) {
      // HRV data unavailable
    }

    // Calculate z-scores
    final sleepZ = _calculateZScore(sleepMinutes?.toDouble(), _sleepMean, _sleepStd);
    final hrvZ = _calculateZScore(hrvSdnn, _hrvMean, _hrvStd);

    // Update baselines periodically
    _maybeUpdateBaselines();

    return BiometricContext(
      sleepMinutes: sleepMinutes,
      hrvSdnn: hrvSdnn,
      capturedAt: now,
      sleepZScore: sleepZ,
      hrvZScore: hrvZ,
    );
  }

  /// Calculate z-score
  double _calculateZScore(double? value, double? mean, double? std) {
    if (value == null || mean == null || std == null || std == 0) {
      return 0.0;
    }
    return ((value - mean) / std).clamp(-3.0, 3.0);
  }

  /// Load baseline statistics from storage
  Future<void> _loadBaselines() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _sleepMean = prefs.getDouble('biometrics_sleep_mean');
      _sleepStd = prefs.getDouble('biometrics_sleep_std');
      _hrvMean = prefs.getDouble('biometrics_hrv_mean');
      _hrvStd = prefs.getDouble('biometrics_hrv_std');

      // If no baselines, calculate them
      if (_sleepMean == null || _hrvMean == null) {
        await _calculateBaselines();
      }
    } catch (_) {
      // Use defaults
      _setDefaultBaselines();
    }
  }

  /// Calculate baselines from historical data
  Future<void> _calculateBaselines() async {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: _baselineDays));

    try {
      // Get sleep data
      final sleepData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.SLEEP_ASLEEP],
        startTime: start,
        endTime: now,
      );

      if (sleepData.length >= 7) {
        final sleepValues = sleepData
            .where((p) => p.value is NumericHealthValue)
            .map((p) => (p.value as NumericHealthValue).numericValue.toDouble())
            .toList();

        final (mean, std) = _calculateMeanStd(sleepValues);
        _sleepMean = mean;
        _sleepStd = std;
      } else {
        _sleepMean = 420.0; // 7 hours default
        _sleepStd = 60.0; // 1 hour std
      }

      // Get HRV data
      final hrvData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE_VARIABILITY_SDNN],
        startTime: start,
        endTime: now,
      );

      if (hrvData.length >= 7) {
        final hrvValues = hrvData
            .where((p) => p.value is NumericHealthValue)
            .map((p) => (p.value as NumericHealthValue).numericValue.toDouble())
            .toList();

        final (mean, std) = _calculateMeanStd(hrvValues);
        _hrvMean = mean;
        _hrvStd = std;
      } else {
        _hrvMean = 50.0; // Average HRV
        _hrvStd = 15.0; // Typical std
      }

      // Save baselines
      await _saveBaselines();
    } catch (_) {
      _setDefaultBaselines();
    }
  }

  /// Set default baselines when no data available
  void _setDefaultBaselines() {
    _sleepMean = 420.0; // 7 hours
    _sleepStd = 60.0; // 1 hour std
    _hrvMean = 50.0; // Average HRV
    _hrvStd = 15.0; // Typical std
  }

  /// Calculate mean and standard deviation
  (double, double) _calculateMeanStd(List<double> values) {
    if (values.isEmpty) return (0.0, 1.0);

    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) / values.length;
    final std = sqrt(variance);

    return (mean, std == 0 ? 1.0 : std);
  }

  /// Save baselines to storage
  Future<void> _saveBaselines() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_sleepMean != null) await prefs.setDouble('biometrics_sleep_mean', _sleepMean!);
      if (_sleepStd != null) await prefs.setDouble('biometrics_sleep_std', _sleepStd!);
      if (_hrvMean != null) await prefs.setDouble('biometrics_hrv_mean', _hrvMean!);
      if (_hrvStd != null) await prefs.setDouble('biometrics_hrv_std', _hrvStd!);
      await prefs.setString('biometrics_baseline_date', DateTime.now().toIso8601String());
    } catch (_) {
      // Storage error, ignore
    }
  }

  /// Update baselines weekly
  Future<void> _maybeUpdateBaselines() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdate = prefs.getString('biometrics_baseline_date');

      if (lastUpdate == null) {
        await _calculateBaselines();
        return;
      }

      final lastDate = DateTime.parse(lastUpdate);
      final daysSinceUpdate = DateTime.now().difference(lastDate).inDays;

      if (daysSinceUpdate >= 7) {
        await _calculateBaselines();
      }
    } catch (_) {
      // Ignore errors
    }
  }

  /// Check if biometrics permission granted
  Future<bool> hasPermission() async {
    try {
      final types = [HealthDataType.SLEEP_ASLEEP];
      return await _health.hasPermissions(types) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Clear cache
  void clearCache() {
    _cachedContext = null;
    _cacheTimestamp = null;
  }
}
