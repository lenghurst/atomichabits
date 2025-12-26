import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// EnvironmentalSensor: The "Where" of the Nervous System.
/// 
/// Detects if the user is in a specific context (Gym, Bar, Library) 
/// to trigger accurate interventions.
/// 
/// MVP Strategy (Free Tier):
/// Since we are using `geolocator` (not the paid background-geolocation plugin),
/// we rely on:
/// 1. Foreground checks (App Open / Resume)
/// 2. Stream updates while app is alive
/// 
/// Future: Upgrade to `flutter_background_geolocation` for true "Always On" sentry mode.
class EnvironmentalSensor {
  // Singleton pattern
  static final EnvironmentalSensor _instance = EnvironmentalSensor._internal();
  factory EnvironmentalSensor() => _instance;
  EnvironmentalSensor._internal();

  bool _isMonitoring = false;
  Position? _lastKnownPosition;

  /// Start monitoring the environment
  Future<bool> initialize() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('EnvironmentalSensor: Location services are disabled.');
      return false;
    }

    // 2. Check permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('EnvironmentalSensor: Location permissions are denied');
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      debugPrint('EnvironmentalSensor: Location permissions are permanently denied.');
      return false;
    } 

    _isMonitoring = true;
    _startListening();
    return true;
  }

  /// Listen to location stream (Foreground)
  void _startListening() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100, // Notify every 100 meters
    );

    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        _lastKnownPosition = position;
        if (kDebugMode) {
          debugPrint('EnvironmentalSensor: Location updated: ${position.latitude}, ${position.longitude}');
        }
        // TODO: Trigger "Check Zones" logic here
      },
      onError: (e) {
        debugPrint('EnvironmentalSensor: Error in stream: $e');
      },
    );
  }
  
  /// Check if user is currently near a target zone
  /// Returns distance in meters, or -1 if usage failed
  Future<double> distanceFromTarget(double targetLat, double targetLng) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );
      _lastKnownPosition = position;
      
      return Geolocator.distanceBetween(
        position.latitude, 
        position.longitude, 
        targetLat, 
        targetLng
      );
    } catch (e) {
      debugPrint('EnvironmentalSensor: Failed to get current position: $e');
      // Fallback to last known
      if (_lastKnownPosition != null) {
        return Geolocator.distanceBetween(
          _lastKnownPosition!.latitude, 
          _lastKnownPosition!.longitude, 
          targetLat, 
          targetLng
        );
      }
      return -1;
    }
  }

  /// Calculate distance between two points in meters (Haversine formula wrapper)
  double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }
}
