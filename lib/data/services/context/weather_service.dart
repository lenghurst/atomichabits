/// WeatherService - OpenWeatherMap Integration
///
/// Fetches current weather and 3-day forecast for cascade prevention.
/// Used by CascadePatternDetector to predict outdoor habit disruptions.
///
/// API: OpenWeatherMap (free tier: 1000 calls/day)
/// Caching: 30 min for current, 3 hours for forecast

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/entities/context_snapshot.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const Duration _currentCacheDuration = Duration(minutes: 30);
  static const Duration _forecastCacheDuration = Duration(hours: 3);

  final String? _apiKey;
  final http.Client _client;

  WeatherContext? _cachedContext;
  DateTime? _cacheTimestamp;

  WeatherService({
    String? apiKey,
    http.Client? client,
  })  : _apiKey = apiKey,
        _client = client ?? http.Client();

  /// Get current weather context
  ///
  /// Returns cached data if fresh, otherwise fetches from API.
  /// Falls back to null if API unavailable (graceful degradation).
  Future<WeatherContext?> getWeatherContext({
    required double latitude,
    required double longitude,
  }) async {
    // Check cache
    if (_cachedContext != null && _cacheTimestamp != null) {
      final age = DateTime.now().difference(_cacheTimestamp!);
      if (age < _currentCacheDuration) {
        return _cachedContext;
      }
    }

    // Try to fetch fresh data
    try {
      final context = await _fetchWeatherContext(latitude, longitude);
      _cachedContext = context;
      _cacheTimestamp = DateTime.now();
      await _persistCache(context);
      return context;
    } catch (e) {
      // Fall back to persisted cache
      return await _loadPersistedCache();
    }
  }

  /// Fetch weather from API
  Future<WeatherContext?> _fetchWeatherContext(
    double latitude,
    double longitude,
  ) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      return null;
    }

    // Fetch current weather
    final currentUrl = Uri.parse(
      '$_baseUrl/weather?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric',
    );

    final currentResponse = await _client.get(currentUrl);
    if (currentResponse.statusCode != 200) {
      throw Exception('Weather API error: ${currentResponse.statusCode}');
    }

    final currentData = json.decode(currentResponse.body) as Map<String, dynamic>;

    // Fetch 5-day forecast (we'll use first 3 days)
    final forecastUrl = Uri.parse(
      '$_baseUrl/forecast?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric&cnt=24',
    );

    List<WeatherForecast>? forecasts;
    try {
      final forecastResponse = await _client.get(forecastUrl);
      if (forecastResponse.statusCode == 200) {
        final forecastData = json.decode(forecastResponse.body) as Map<String, dynamic>;
        forecasts = _parseForecast(forecastData);
      }
    } catch (_) {
      // Forecast is optional
    }

    return _parseCurrentWeather(currentData, forecasts);
  }

  /// Parse current weather response
  WeatherContext _parseCurrentWeather(
    Map<String, dynamic> data,
    List<WeatherForecast>? forecasts,
  ) {
    final weather = data['weather'] as List;
    final main = data['main'] as Map<String, dynamic>;

    final conditionId = weather.isNotEmpty
        ? (weather[0]['id'] as int)
        : 800; // Default to clear

    final condition = _mapCondition(conditionId);
    final temp = (main['temp'] as num).toDouble();

    // Determine outdoor suitability
    final isOutdoorSuitable = _isOutdoorSuitable(condition, temp);

    return WeatherContext(
      condition: condition,
      temperatureCelsius: temp,
      isOutdoorSuitable: isOutdoorSuitable,
      forecast: forecasts,
      capturedAt: DateTime.now(),
    );
  }

  /// Parse forecast response (group by day, take first 3)
  List<WeatherForecast> _parseForecast(Map<String, dynamic> data) {
    final list = data['list'] as List;
    final dailyForecasts = <DateTime, List<Map<String, dynamic>>>{};

    // Group by date
    for (final item in list) {
      final dt = DateTime.fromMillisecondsSinceEpoch(
        (item['dt'] as int) * 1000,
      );
      final dateKey = DateTime(dt.year, dt.month, dt.day);
      dailyForecasts.putIfAbsent(dateKey, () => []).add(item as Map<String, dynamic>);
    }

    // Take first 3 days, use worst condition per day
    final forecasts = <WeatherForecast>[];
    final sortedDates = dailyForecasts.keys.toList()..sort();

    for (final date in sortedDates.take(3)) {
      final dayData = dailyForecasts[date]!;

      // Find worst condition for the day
      var worstCondition = WeatherCondition.clear;
      var avgTemp = 0.0;

      for (final item in dayData) {
        final weather = item['weather'] as List;
        final conditionId = weather.isNotEmpty ? (weather[0]['id'] as int) : 800;
        final condition = _mapCondition(conditionId);

        if (_conditionSeverity(condition) > _conditionSeverity(worstCondition)) {
          worstCondition = condition;
        }

        final main = item['main'] as Map<String, dynamic>;
        avgTemp += (main['temp'] as num).toDouble();
      }

      avgTemp /= dayData.length;

      forecasts.add(WeatherForecast(
        date: date,
        condition: worstCondition,
        isOutdoorSuitable: _isOutdoorSuitable(worstCondition, avgTemp),
      ));
    }

    return forecasts;
  }

  /// Map OpenWeatherMap condition ID to our enum
  WeatherCondition _mapCondition(int id) {
    // https://openweathermap.org/weather-conditions
    if (id >= 200 && id < 300) return WeatherCondition.thunderstorm;
    if (id >= 300 && id < 400) return WeatherCondition.drizzle;
    if (id >= 500 && id < 600) return WeatherCondition.rain;
    if (id >= 600 && id < 700) return WeatherCondition.snow;
    if (id >= 700 && id < 800) {
      if (id == 701 || id == 721) return WeatherCondition.mist;
      if (id == 741) return WeatherCondition.fog;
      return WeatherCondition.mist;
    }
    if (id == 800) return WeatherCondition.clear;
    if (id > 800) return WeatherCondition.clouds;
    return WeatherCondition.unknown;
  }

  /// Get severity score for condition comparison
  int _conditionSeverity(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.clear:
        return 0;
      case WeatherCondition.clouds:
        return 1;
      case WeatherCondition.mist:
        return 2;
      case WeatherCondition.fog:
        return 3;
      case WeatherCondition.drizzle:
        return 4;
      case WeatherCondition.rain:
        return 5;
      case WeatherCondition.snow:
        return 6;
      case WeatherCondition.thunderstorm:
        return 7;
      case WeatherCondition.unknown:
        return 0;
    }
  }

  /// Determine if conditions are suitable for outdoor activity
  bool _isOutdoorSuitable(WeatherCondition condition, double tempCelsius) {
    // Bad weather conditions
    if (condition == WeatherCondition.rain ||
        condition == WeatherCondition.thunderstorm ||
        condition == WeatherCondition.snow) {
      return false;
    }

    // Temperature extremes
    if (tempCelsius < 0 || tempCelsius > 35) {
      return false;
    }

    // Heavy fog is marginal
    if (condition == WeatherCondition.fog) {
      return false;
    }

    return true;
  }

  /// Persist cache to SharedPreferences
  Future<void> _persistCache(WeatherContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('weather_cache', json.encode(context.toJson()));
      await prefs.setString('weather_cache_time', DateTime.now().toIso8601String());
    } catch (_) {
      // Cache persistence is optional
    }
  }

  /// Load persisted cache
  Future<WeatherContext?> _loadPersistedCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('weather_cache');
      final cacheTime = prefs.getString('weather_cache_time');

      if (cached == null || cacheTime == null) return null;

      final age = DateTime.now().difference(DateTime.parse(cacheTime));
      // Use stale cache up to 6 hours
      if (age > const Duration(hours: 6)) return null;

      return WeatherContext.fromJson(json.decode(cached) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Clear cache (for testing)
  void clearCache() {
    _cachedContext = null;
    _cacheTimestamp = null;
  }
}
