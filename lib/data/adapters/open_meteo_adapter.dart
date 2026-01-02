import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/interfaces/weather_provider.dart';
import '../../domain/entities/weather_context.dart';

class OpenMeteoAdapter implements WeatherProvider {
  static const _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  @override
  Future<WeatherContext?> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl?latitude=$latitude&longitude=$longitude'
        '&current_weather=true'
        '&daily=weathercode,temperature_2m_max,temperature_2m_min'
        '&timezone=auto',
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('OpenMeteo Error: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final current = data['current_weather'];
      final daily = data['daily'];

      return WeatherContext(
        condition: _mapWmoCode(current['weathercode'] as int),
        temperatureCelsius: (current['temperature'] as num).toDouble(),
        isOutdoorSuitable: _isSuitable(current['weathercode'] as int, (current['temperature'] as num).toDouble()),
        capturedAt: DateTime.now(),
        forecast: _parseForecast(daily),
      );
    } catch (e) {
      // Log error?
      return null;
    }
  }

  WeatherCondition _mapWmoCode(int code) {
    // WMO Weather interpretation codes (WW)
    if (code == 0) return WeatherCondition.clear;
    if (code >= 1 && code <= 3) return WeatherCondition.clouds;
    if (code >= 45 && code <= 48) return WeatherCondition.fog;
    if (code >= 51 && code <= 55) return WeatherCondition.drizzle;
    if (code >= 61 && code <= 67) return WeatherCondition.rain;
    if (code >= 71 && code <= 77) return WeatherCondition.snow;
    if (code >= 80 && code <= 82) return WeatherCondition.rain;
    if (code >= 85 && code <= 86) return WeatherCondition.snow;
    if (code >= 95 && code <= 99) return WeatherCondition.thunderstorm;
    return WeatherCondition.unknown;
  }

  bool _isSuitable(int code, double temp) {
    final condition = _mapWmoCode(code);
    final isRaining = condition == WeatherCondition.rain ||
        condition == WeatherCondition.thunderstorm ||
        condition == WeatherCondition.snow;
    
    // Simple logic: acceptable if not raining and temp is reasonable (0-35 C)
    return !isRaining && temp >= 0 && temp <= 35;
  }

  List<WeatherForecast> _parseForecast(Map<String, dynamic> daily) {
    final List<WeatherForecast> forecasts = [];
    final times = daily['time'] as List;
    final codes = daily['weathercode'] as List;
    
    // Take next 3 days
    for (int i = 0; i < times.length && i < 3; i++) {
        // Daily max temp as proxy for suitability?
        // Logic simplified for adapter
        final code = codes[i] as int;
        final condition = _mapWmoCode(code);
        
        forecasts.add(WeatherForecast(
            date: DateTime.parse(times[i] as String),
            condition: condition,
            isOutdoorSuitable: !(condition == WeatherCondition.rain || condition == WeatherCondition.thunderstorm || condition == WeatherCondition.snow),
        ));
    }
    return forecasts;
  }
}
