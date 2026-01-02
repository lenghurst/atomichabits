import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/interfaces/weather_provider.dart';
import '../../domain/entities/weather_context.dart';

class OpenWeatherMapAdapter implements WeatherProvider {
  static const _baseUrl = 'https://api.openweathermap.org/data/2.5';
  final String apiKey;

  OpenWeatherMapAdapter({
    this.apiKey = const String.fromEnvironment('OPEN_WEATHER_API_KEY'),
  });

  @override
  Future<WeatherContext?> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    if (apiKey.isEmpty) return null;

    try {
      // Current weather
      final url = Uri.parse(
        '$_baseUrl/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric',
      );

      final response = await http.get(url);
      if (response.statusCode != 200) throw Exception('OWM Error: ${response.statusCode}');

      final data = json.decode(response.body);
      final weatherList = data['weather'] as List;
      final main = data['main'];
      
      final conditionId = (weatherList.isNotEmpty) ? weatherList[0]['id'] as int : 800;
      final temp = (main['temp'] as num).toDouble();

      return WeatherContext(
        condition: _mapConditionId(conditionId),
        temperatureCelsius: temp,
        isOutdoorSuitable: _isSuitable(conditionId, temp),
        capturedAt: DateTime.now(),
        // OWM requires separate call for forecast (One Call API or 5 day forecast)
        // For MVP adapter, we might leave forecast null or make second call
        // Leaving null for now to match interface speed
      );
    } catch (e) {
      return null;
    }
  }

  WeatherCondition _mapConditionId(int id) {
    if (id >= 200 && id < 300) return WeatherCondition.thunderstorm;
    if (id >= 300 && id < 400) return WeatherCondition.drizzle;
    if (id >= 500 && id < 600) return WeatherCondition.rain;
    if (id >= 600 && id < 700) return WeatherCondition.snow;
    if (id >= 700 && id < 800) return WeatherCondition.mist; // Atmosphere
    if (id == 800) return WeatherCondition.clear;
    if (id > 800) return WeatherCondition.clouds;
    return WeatherCondition.unknown;
  }

   bool _isSuitable(int id, double temp) {
    final condition = _mapConditionId(id);
    final isRaining = condition == WeatherCondition.rain ||
        condition == WeatherCondition.thunderstorm ||
        condition == WeatherCondition.snow;
    return !isRaining && temp >= 0 && temp <= 35;
  }
}
