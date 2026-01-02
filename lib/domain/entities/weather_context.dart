/// Weather context entity
/// Agnostic to provider (Open-Meteo vs OpenWeatherMap)
class WeatherContext {
  final WeatherCondition condition;
  final double temperatureCelsius;
  final bool isOutdoorSuitable;
  final List<WeatherForecast>? forecast; // Next 3 days
  final DateTime capturedAt;

  WeatherContext({
    required this.condition,
    required this.temperatureCelsius,
    required this.isOutdoorSuitable,
    this.forecast,
    required this.capturedAt,
  });

  bool get isRaining =>
      condition == WeatherCondition.rain ||
      condition == WeatherCondition.thunderstorm ||
      condition == WeatherCondition.drizzle;

  bool get isCold => temperatureCelsius < 5;
  bool get isHot => temperatureCelsius > 32;

  /// Predicts if outdoor activities will be blocked for multiple days
  bool get isMultiDayOutdoorBlock {
    if (forecast == null) return false;
    final badDays = forecast!.where((f) => !f.isOutdoorSuitable).length;
    return badDays >= 2;
  }

  Map<String, dynamic> toJson() => {
        'condition': condition.name,
        'temperatureCelsius': temperatureCelsius,
        'isOutdoorSuitable': isOutdoorSuitable,
        'forecast': forecast?.map((f) => f.toJson()).toList(),
        'capturedAt': capturedAt.toIso8601String(),
      };

  factory WeatherContext.fromJson(Map<String, dynamic> json) {
    return WeatherContext(
      condition: WeatherCondition.values.firstWhere(
        (e) => e.name == json['condition'],
        orElse: () => WeatherCondition.clear,
      ),
      temperatureCelsius: (json['temperatureCelsius'] as num).toDouble(),
      isOutdoorSuitable: json['isOutdoorSuitable'] as bool,
      forecast: (json['forecast'] as List?)
          ?.map((f) => WeatherForecast.fromJson(f as Map<String, dynamic>))
          .toList(),
      capturedAt: DateTime.parse(json['capturedAt'] as String),
    );
  }
}

enum WeatherCondition {
  clear,
  clouds,
  rain,
  drizzle,
  thunderstorm,
  snow,
  mist,
  fog,
  unknown,
}

class WeatherForecast {
  final DateTime date;
  final WeatherCondition condition;
  final bool isOutdoorSuitable;

  WeatherForecast({
    required this.date,
    required this.condition,
    required this.isOutdoorSuitable,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'condition': condition.name,
        'isOutdoorSuitable': isOutdoorSuitable,
      };

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      date: DateTime.parse(json['date'] as String),
      condition: WeatherCondition.values.firstWhere(
        (e) => e.name == json['condition'],
        orElse: () => WeatherCondition.unknown,
      ),
      isOutdoorSuitable: json['isOutdoorSuitable'] as bool,
    );
  }
}
