import '../../core/cache/cache_manager.dart';
import '../../domain/entities/weather_context.dart';
import '../../domain/interfaces/weather_provider.dart';
import '../adapters/open_meteo_adapter.dart';

/// Facade for weather data retrieval.
///
/// Uses [WeatherProvider] (Adapter pattern) for data source abstraction.
/// Uses [CacheManager] (Decorator/Proxy pattern logic) for caching and resilience.
class WeatherService {
  final WeatherProvider _provider;
  final CacheManager<WeatherContext> _cache;
  
  // Default location (San Francisco) if permission/context fails
  // Can be updated via setters or method args
  double _lastLat = 37.7749;
  double _lastLon = -122.4194;

  WeatherService({
    WeatherProvider? provider,
    CacheManager<WeatherContext>? cache,
  })  : _provider = provider ?? OpenMeteoAdapter(),
        _cache = cache ??
            CacheManager<WeatherContext>(
              ttl: const Duration(minutes: 15),
              debugLabel: 'WeatherService',
            ) {
    // Configure cache refresher
    _cache.refresher = _fetchWeather;
  }

  /// Update current location coordinates
  void updateLocation(double lat, double lon) {
    _lastLat = lat;
    _lastLon = lon;
  }

  /// Get current weather context (cached if fresh)
  ///
  /// Optional [lat]/[lon] overrides the stored location.
  Future<WeatherContext?> getWeatherContext({
    double? lat,
    double? lon,
    bool forceRefresh = false,
  }) async {
    if (lat != null && lon != null) {
      updateLocation(lat, lon);
      // If location changes, we might want to invalidate cache?
      // For now, simple logic: if location changes significantly, maybe force refresh.
      // But CacheManager is simple. We'll rely on TTL or forceRefresh.
    }

    if (forceRefresh) {
      _cache.invalidate();
    }

    return _cache.get();
  }

  // Internal fetcher for CacheManager
  Future<WeatherContext> _fetchWeather() async {
    final result = await _provider.getCurrentWeather(
      latitude: _lastLat,
      longitude: _lastLon,
    );
    if (result == null) {
      throw Exception('Failed to fetch weather data from provider');
    }
    return result;
  }
}
