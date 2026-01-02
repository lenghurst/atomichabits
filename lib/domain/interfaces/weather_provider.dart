import '../entities/weather_context.dart';

/// Interface for weather data providers.
/// Follows the Adapter pattern to unify Open-Meteo and OpenWeatherMap.
abstract class WeatherProvider {
  Future<WeatherContext?> getCurrentWeather({
    required double latitude,
    required double longitude,
  });
}
