import 'package:flutter/foundation.dart';

import '../../../domain/entities/context_snapshot.dart';
import '../../../domain/entities/psychometric_profile.dart';
import '../../models/habit.dart';
import '../../sensors/biometric_sensor.dart';
import '../../sensors/digital_truth_sensor.dart';
import '../../sensors/environmental_sensor.dart';
import '../weather_service.dart';
import '../../../domain/entities/weather_context.dart';

/// ContextSnapshotAggregator: The "Nervous System Hub"
///
/// Aggregates all sensor data into a unified ContextSnapshot for JITAI processing.
/// Handles graceful degradation when sensors are unavailable.
///
/// Phase 63: JITAI Foundation
@deprecated // Use JITAIContextService instead
class ContextSnapshotAggregator {
  // Singleton
  static final ContextSnapshotAggregator _instance = ContextSnapshotAggregator._internal();
  factory ContextSnapshotAggregator() => _instance;
  ContextSnapshotAggregator._internal();

  // Sensors
  final BiometricSensor _biometricSensor = BiometricSensor();
  final DigitalTruthSensor _digitalSensor = DigitalTruthSensor();
  final EnvironmentalSensor _environmentalSensor = EnvironmentalSensor();
  final WeatherService _weatherService = WeatherService();

  // Baseline tracking for Z-scores
  final BaselineTracker _baselineTracker = BaselineTracker();

  // User location zones (configured during onboarding)
  LocationZones? _userZones;

  // Manual V-O override (Thermostat)
  double? _userVulnerabilityOverride;
  DateTime? _overrideExpiresAt;

  /// Initialize all sensors
  Future<void> initialize() async {
    try {
      await _biometricSensor.initialize();
    } catch (e) {
      debugPrint('ContextSnapshotAggregator: Biometric sensor init failed: $e');
    }

    try {
      await _environmentalSensor.initialize();
    } catch (e) {
      debugPrint('ContextSnapshotAggregator: Environmental sensor init failed: $e');
    }
  }

  /// Set user's location zones (home, work, gym)
  void setLocationZones(LocationZones zones) {
    _userZones = zones;
  }

  /// Set manual vulnerability override (Thermostat)
  /// Expires after the specified duration
  void setVulnerabilityOverride(double value, {Duration? expiresIn}) {
    _userVulnerabilityOverride = value.clamp(0.0, 1.0);
    _overrideExpiresAt = expiresIn != null
        ? DateTime.now().add(expiresIn)
        : DateTime.now().add(const Duration(hours: 4)); // Default 4 hours

    debugPrint('ContextSnapshotAggregator: Thermostat set to $value, expires at $_overrideExpiresAt');
  }

  /// Clear manual override
  void clearVulnerabilityOverride() {
    _userVulnerabilityOverride = null;
    _overrideExpiresAt = null;
  }

  /// Get current manual override (if valid)
  double? get currentOverride {
    if (_userVulnerabilityOverride == null) return null;
    if (_overrideExpiresAt != null && DateTime.now().isAfter(_overrideExpiresAt!)) {
      // Expired
      _userVulnerabilityOverride = null;
      _overrideExpiresAt = null;
      return null;
    }
    return _userVulnerabilityOverride;
  }

  /// Capture a full context snapshot
  /// Call this at intervention decision points
  Future<ContextSnapshot> capture({
    required Habit habit,
    required HistoricalContext history,
    List<String> activePatterns = const [],
  }) async {
    final now = DateTime.now();

    // Gather all context in parallel for speed
    final futures = await Future.wait([
      _captureBiometrics(),
      _captureDigital(),
      _captureLocation(habit),
      _captureWeather(habit),
    ]);

    final biometrics = futures[0] as BiometricContext?;
    final digital = futures[1] as DigitalContext?;
    final location = futures[2] as LocationContext?;
    final weather = futures[3] as WeatherContext?;

    // TODO: Integrate CalendarContext when Google Calendar service is ready
    CalendarContext? calendar;

    return ContextSnapshot(
      snapshotId: '${now.millisecondsSinceEpoch}',
      capturedAt: now,
      time: TimeContext.fromDateTime(now),
      biometrics: biometrics,
      calendar: calendar,
      weather: weather,
      location: location,
      digital: digital,
      history: history,
      userVulnerabilityOverride: currentOverride,
      activePatterns: activePatterns,
    );
  }

  /// Capture biometric context (sleep, HRV)
  Future<BiometricContext?> _captureBiometrics() async {
    try {
      final sleepMinutes = await _biometricSensor.getLastNightSleepMinutes();
      final hrv = await _biometricSensor.getLatestHRV();

      // If no data available, return null
      if (sleepMinutes == -1 && hrv == -1) {
        return null;
      }

      // Calculate Z-scores relative to baseline
      final sleepZ = sleepMinutes != -1
          ? _baselineTracker.sleepZScore(sleepMinutes)
          : 0.0;
      final hrvZ = hrv != -1
          ? _baselineTracker.hrvZScore(hrv)
          : 0.0;

      // Update baselines with new data
      if (sleepMinutes != -1) {
        _baselineTracker.updateSleepBaseline(sleepMinutes);
      }
      if (hrv != -1) {
        _baselineTracker.updateHrvBaseline(hrv);
      }

      return BiometricContext(
        sleepMinutes: sleepMinutes != -1 ? sleepMinutes : null,
        hrvSdnn: hrv != -1 ? hrv : null,
        capturedAt: DateTime.now(),
        sleepZScore: sleepZ,
        hrvZScore: hrvZ,
      );
    } catch (e) {
      debugPrint('ContextSnapshotAggregator: Biometric capture failed: $e');
      return null;
    }
  }

  /// Capture digital context (screen time)
  Future<DigitalContext?> _captureDigital() async {
    try {
      if (!_digitalSensor.isSupported) {
        return null;
      }

      final distractionMinutes = await _digitalSensor.getDopamineBurnMinutes();
      final apexDistractor = await _digitalSensor.getApexDistractor();

      // Calculate Z-score relative to baseline
      final distractionZ = _baselineTracker.distractionZScore(distractionMinutes);
      _baselineTracker.updateDistractionBaseline(distractionMinutes);

      return DigitalContext(
        distractionMinutes: distractionMinutes,
        apexDistractor: _packageToAppName(apexDistractor),
        distractionZScore: distractionZ,
        capturedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('ContextSnapshotAggregator: Digital capture failed: $e');
      return null;
    }
  }

  /// Capture location context
  Future<LocationContext?> _captureLocation(Habit habit) async {
    try {
      // Get current position
      final position = await _environmentalSensor.distanceFromTarget(0, 0);
      if (position == -1) {
        return null;
      }

      // Determine location zone
      LocationZone zone = LocationZone.unknown;
      double? distanceToHabit;

      if (_userZones != null) {
        // Check home
        if (_userZones!.home != null) {
          final distHome = await _environmentalSensor.distanceFromTarget(
            _userZones!.home!.latitude,
            _userZones!.home!.longitude,
          );
          if (distHome >= 0 && distHome < 200) {
            zone = LocationZone.home;
          }
        }

        // Check work
        if (_userZones!.work != null) {
          final distWork = await _environmentalSensor.distanceFromTarget(
            _userZones!.work!.latitude,
            _userZones!.work!.longitude,
          );
          if (distWork >= 0 && distWork < 200) {
            zone = LocationZone.work;
          }
        }

        // Check gym
        if (_userZones!.gym != null) {
          final distGym = await _environmentalSensor.distanceFromTarget(
            _userZones!.gym!.latitude,
            _userZones!.gym!.longitude,
          );
          if (distGym >= 0 && distGym < 200) {
            zone = LocationZone.gym;
          }
        }
      }

      // Check distance to habit location if set
      if (habit.implementationLocation != null &&
          habit.implementationLocation!.isNotEmpty) {
        // TODO: Parse habit location coordinates
        // For now, habit location is a string description
      }

      return LocationContext(
        zone: zone,
        distanceToHabitLocation: distanceToHabit,
        capturedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('ContextSnapshotAggregator: Location capture failed: $e');
      return null;
    }
  }

  /// Capture weather context
  Future<WeatherContext?> _captureWeather(Habit habit) async {
    try {
      // Need location for weather
      // For MVP, use a default location or last known
      // TODO: Get actual user location

      // Default to a reasonable location (will be replaced with actual)
      const defaultLat = 37.7749; // San Francisco
      const defaultLon = -122.4194;

      return await _weatherService.getWeatherContext(
        lat: defaultLat,
        lon: defaultLon,
      );
    } catch (e) {
      debugPrint('ContextSnapshotAggregator: Weather capture failed: $e');
      return null;
    }
  }

  /// Convert package name to readable app name
  String? _packageToAppName(String? packageName) {
    if (packageName == null) return null;

    const packageNames = {
      'com.zhiliaoapp.musically': 'TikTok',
      'com.instagram.android': 'Instagram',
      'com.twitter.android': 'Twitter/X',
      'com.snapchat.android': 'Snapchat',
      'com.facebook.katana': 'Facebook',
      'com.google.android.youtube': 'YouTube',
      'tv.twitch.android.app': 'Twitch',
    };

    return packageNames[packageName] ?? packageName.split('.').last;
  }
}

/// Tracks user baselines for Z-score calculation
class BaselineTracker {
  // Rolling windows for baseline calculation
  final List<int> _sleepHistory = [];
  final List<double> _hrvHistory = [];
  final List<int> _distractionHistory = [];

  static const int _windowSize = 14; // 14 days for baseline

  // Calculated baselines
  double? _sleepMean;
  double? _sleepStd;
  double? _hrvMean;
  double? _hrvStd;
  double? _distractionMean;
  double? _distractionStd;

  /// Calculate sleep Z-score
  double sleepZScore(int minutes) {
    if (_sleepMean == null || _sleepStd == null || _sleepStd == 0) {
      return 0.0; // No baseline yet
    }
    return (minutes - _sleepMean!) / _sleepStd!;
  }

  /// Calculate HRV Z-score
  double hrvZScore(double hrv) {
    if (_hrvMean == null || _hrvStd == null || _hrvStd == 0) {
      return 0.0;
    }
    return (hrv - _hrvMean!) / _hrvStd!;
  }

  /// Calculate distraction Z-score
  double distractionZScore(int minutes) {
    if (_distractionMean == null || _distractionStd == null || _distractionStd == 0) {
      return 0.0;
    }
    // Invert: higher distraction = negative Z-score (worse)
    return -((minutes - _distractionMean!) / _distractionStd!);
  }

  /// Update sleep baseline
  void updateSleepBaseline(int minutes) {
    _sleepHistory.add(minutes);
    if (_sleepHistory.length > _windowSize) {
      _sleepHistory.removeAt(0);
    }
    _recalculateSleepStats();
  }

  /// Update HRV baseline
  void updateHrvBaseline(double hrv) {
    _hrvHistory.add(hrv);
    if (_hrvHistory.length > _windowSize) {
      _hrvHistory.removeAt(0);
    }
    _recalculateHrvStats();
  }

  /// Update distraction baseline
  void updateDistractionBaseline(int minutes) {
    _distractionHistory.add(minutes);
    if (_distractionHistory.length > _windowSize) {
      _distractionHistory.removeAt(0);
    }
    _recalculateDistractionStats();
  }

  void _recalculateSleepStats() {
    if (_sleepHistory.isEmpty) return;
    _sleepMean = _sleepHistory.reduce((a, b) => a + b) / _sleepHistory.length;
    _sleepStd = _calculateStd(_sleepHistory.map((e) => e.toDouble()).toList(), _sleepMean!);
  }

  void _recalculateHrvStats() {
    if (_hrvHistory.isEmpty) return;
    _hrvMean = _hrvHistory.reduce((a, b) => a + b) / _hrvHistory.length;
    _hrvStd = _calculateStd(_hrvHistory, _hrvMean!);
  }

  void _recalculateDistractionStats() {
    if (_distractionHistory.isEmpty) return;
    _distractionMean = _distractionHistory.reduce((a, b) => a + b) / _distractionHistory.length;
    _distractionStd = _calculateStd(
      _distractionHistory.map((e) => e.toDouble()).toList(),
      _distractionMean!,
    );
  }

  double _calculateStd(List<double> values, double mean) {
    if (values.length < 2) return 1.0; // Avoid division by zero
    final variance = values.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) / values.length;
    return variance > 0 ? _sqrt(variance) : 1.0;
  }

  // Simple sqrt approximation (avoid dart:math import)
  double _sqrt(double x) {
    if (x <= 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  /// Export state for persistence
  Map<String, dynamic> toJson() => {
        'sleepHistory': _sleepHistory,
        'hrvHistory': _hrvHistory,
        'distractionHistory': _distractionHistory,
      };

  /// Import state from persistence
  void fromJson(Map<String, dynamic> json) {
    _sleepHistory.clear();
    _hrvHistory.clear();
    _distractionHistory.clear();

    if (json['sleepHistory'] != null) {
      _sleepHistory.addAll((json['sleepHistory'] as List).cast<int>());
      _recalculateSleepStats();
    }
    if (json['hrvHistory'] != null) {
      _hrvHistory.addAll((json['hrvHistory'] as List).map((e) => (e as num).toDouble()));
      _recalculateHrvStats();
    }
    if (json['distractionHistory'] != null) {
      _distractionHistory.addAll((json['distractionHistory'] as List).cast<int>());
      _recalculateDistractionStats();
    }
  }
}

/// User's known location zones
class LocationZones {
  final LocationCoordinate? home;
  final LocationCoordinate? work;
  final LocationCoordinate? gym;
  final List<LocationCoordinate> customZones;

  LocationZones({
    this.home,
    this.work,
    this.gym,
    this.customZones = const [],
  });

  Map<String, dynamic> toJson() => {
        'home': home?.toJson(),
        'work': work?.toJson(),
        'gym': gym?.toJson(),
        'customZones': customZones.map((z) => z.toJson()).toList(),
      };

  factory LocationZones.fromJson(Map<String, dynamic> json) {
    return LocationZones(
      home: json['home'] != null
          ? LocationCoordinate.fromJson(json['home'] as Map<String, dynamic>)
          : null,
      work: json['work'] != null
          ? LocationCoordinate.fromJson(json['work'] as Map<String, dynamic>)
          : null,
      gym: json['gym'] != null
          ? LocationCoordinate.fromJson(json['gym'] as Map<String, dynamic>)
          : null,
      customZones: (json['customZones'] as List?)
              ?.map((z) => LocationCoordinate.fromJson(z as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class LocationCoordinate {
  final double latitude;
  final double longitude;
  final String? label;

  LocationCoordinate({
    required this.latitude,
    required this.longitude,
    this.label,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'label': label,
      };

  factory LocationCoordinate.fromJson(Map<String, dynamic> json) {
    return LocationCoordinate(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      label: json['label'] as String?,
    );
  }
}
