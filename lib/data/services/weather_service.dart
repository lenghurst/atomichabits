import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../domain/entities/context_snapshot.dart';

/// WeatherService: Environmental context for JITAI
///
/// Uses Open-Meteo API (free, no API key required).
/// Provides current conditions and 3-day forecast for cascade prevention.
///
/// Tracer Bullet: Rain → Runner → Alternative Suggestion
///
/// Phase 63: JITAI Foundation
class WeatherService {
  // Singleton
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();

  /// Open-Meteo base URL (free, no API key)
  static const _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  /// Cache duration (15 minutes)
  static const _cacheDuration = Duration(minutes: 15);

  /// Cached weather context
  WeatherContext? _cachedWeather;
  DateTime? _cacheTime;

  /// Get current weather context
  /// Returns cached data if available and fresh
  Future<WeatherContext?> getWeatherContext({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  }) async {
    // Check cache
    if (!forceRefresh && _cachedWeather != null && _cacheTime != null) {
      final age = DateTime.now().difference(_cacheTime!);
      if (age < _cacheDuration) {
        return _cachedWeather;
      }
    }

    try {
      final weather = await _fetchWeather(latitude, longitude);
      _cachedWeather = weather;
      _cacheTime = DateTime.now();
      return weather;
    } catch (e) {
      debugPrint('WeatherService: Error fetching weather: $e');
      // Return stale cache if available
      return _cachedWeather;
    }
  }

  /// Fetch weather from Open-Meteo
  Future<WeatherContext> _fetchWeather(double lat, double lon) async {
    final url = Uri.parse(
      '$_baseUrl?latitude=$lat&longitude=$lon'
      '&current=temperature_2m,weather_code,is_day'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min'
      '&timezone=auto'
      '&forecast_days=4',
    );

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Weather API returned ${response.statusCode}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    return _parseWeatherResponse(data);
  }

  /// Parse Open-Meteo response into WeatherContext
  WeatherContext _parseWeatherResponse(Map<String, dynamic> data) {
    final current = data['current'] as Map<String, dynamic>;
    final daily = data['daily'] as Map<String, dynamic>;

    // Parse current weather
    final weatherCode = current['weather_code'] as int;
    final temperature = (current['temperature_2m'] as num).toDouble();
    final condition = _weatherCodeToCondition(weatherCode);

    // Parse forecast (next 3 days, skip today)
    final dailyCodes = (daily['weather_code'] as List).cast<int>();
    final dailyDates = (daily['time'] as List).cast<String>();

    final forecast = <WeatherForecast>[];
    for (int i = 1; i < dailyCodes.length && i <= 3; i++) {
      final code = dailyCodes[i];
      final forecastCondition = _weatherCodeToCondition(code);
      forecast.add(WeatherForecast(
        date: DateTime.parse(dailyDates[i]),
        condition: forecastCondition,
        isOutdoorSuitable: _isOutdoorSuitable(forecastCondition, temperature),
      ));
    }

    return WeatherContext(
      condition: condition,
      temperatureCelsius: temperature,
      isOutdoorSuitable: _isOutdoorSuitable(condition, temperature),
      forecast: forecast,
      capturedAt: DateTime.now(),
    );
  }

  /// Convert WMO weather code to WeatherCondition
  /// See: https://open-meteo.com/en/docs#weathervariables
  WeatherCondition _weatherCodeToCondition(int code) {
    // Clear
    if (code == 0) return WeatherCondition.clear;

    // Mainly clear, partly cloudy
    if (code == 1 || code == 2) return WeatherCondition.clear;

    // Overcast
    if (code == 3) return WeatherCondition.clouds;

    // Fog
    if (code >= 45 && code <= 48) return WeatherCondition.fog;

    // Drizzle
    if (code >= 51 && code <= 55) return WeatherCondition.drizzle;

    // Freezing drizzle
    if (code >= 56 && code <= 57) return WeatherCondition.drizzle;

    // Rain
    if (code >= 61 && code <= 65) return WeatherCondition.rain;

    // Freezing rain
    if (code >= 66 && code <= 67) return WeatherCondition.rain;

    // Snow
    if (code >= 71 && code <= 77) return WeatherCondition.snow;

    // Rain showers
    if (code >= 80 && code <= 82) return WeatherCondition.rain;

    // Snow showers
    if (code >= 85 && code <= 86) return WeatherCondition.snow;

    // Thunderstorm
    if (code >= 95 && code <= 99) return WeatherCondition.thunderstorm;

    return WeatherCondition.unknown;
  }

  /// Determine if conditions are suitable for outdoor activity
  bool _isOutdoorSuitable(WeatherCondition condition, double tempCelsius) {
    // Rain, thunderstorm, heavy snow = not suitable
    if (condition == WeatherCondition.rain ||
        condition == WeatherCondition.thunderstorm ||
        condition == WeatherCondition.snow) {
      return false;
    }

    // Drizzle might be okay for some
    if (condition == WeatherCondition.drizzle) {
      return false; // Conservative for now
    }

    // Extreme temperatures
    if (tempCelsius < 0 || tempCelsius > 35) {
      return false;
    }

    return true;
  }

  /// Clear cache (for testing or forced refresh)
  void clearCache() {
    _cachedWeather = null;
    _cacheTime = null;
  }

  /// Check if rain is expected in the next N days
  Future<bool> isRainExpected({
    required double latitude,
    required double longitude,
    int days = 3,
  }) async {
    final weather = await getWeatherContext(
      latitude: latitude,
      longitude: longitude,
    );

    if (weather == null) return false;

    // Check current
    if (weather.isRaining) return true;

    // Check forecast
    if (weather.forecast != null) {
      for (final day in weather.forecast!.take(days)) {
        if (day.condition == WeatherCondition.rain ||
            day.condition == WeatherCondition.thunderstorm ||
            day.condition == WeatherCondition.drizzle) {
          return true;
        }
      }
    }

    return false;
  }

  /// Get a cascade prevention message if multi-day bad weather
  Future<CascadeWarning?> checkCascadeRisk({
    required double latitude,
    required double longitude,
    required String habitType, // 'outdoor_exercise', 'running', etc.
  }) async {
    final weather = await getWeatherContext(
      latitude: latitude,
      longitude: longitude,
    );

    if (weather == null) return null;

    // Only relevant for outdoor habits
    if (!_isOutdoorHabit(habitType)) return null;

    // Check if multi-day outdoor block
    if (weather.isMultiDayOutdoorBlock) {
      final badDays = weather.forecast!
          .where((f) => !f.isOutdoorSuitable)
          .length;

      return CascadeWarning(
        type: CascadeType.weather,
        message: 'Weather forecast shows $badDays unfavorable days ahead',
        suggestion: _getAlternativeSuggestion(habitType),
        daysAffected: badDays,
      );
    }

    return null;
  }

  bool _isOutdoorHabit(String habitType) {
    final outdoor = {
      'outdoor_exercise',
      'running',
      'cycling',
      'walking',
      'hiking',
      'outdoor',
    };
    return outdoor.contains(habitType.toLowerCase());
  }

  String _getAlternativeSuggestion(String habitType) {
    switch (habitType.toLowerCase()) {
      case 'running':
      case 'outdoor_exercise':
        return 'Consider: Treadmill, indoor workout, or stairs';
      case 'cycling':
        return 'Consider: Stationary bike or indoor spin class';
      case 'walking':
        return 'Consider: Mall walking or indoor stairs';
      default:
        return 'Consider an indoor alternative';
    }
  }
}

/// Warning about potential cascade failure
class CascadeWarning {
  final CascadeType type;
  final String message;
  final String suggestion;
  final int daysAffected;

  CascadeWarning({
    required this.type,
    required this.message,
    required this.suggestion,
    required this.daysAffected,
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'message': message,
        'suggestion': suggestion,
        'daysAffected': daysAffected,
      };
}

enum CascadeType {
  weather,
  travel,
  schedule,
  pattern,
}
