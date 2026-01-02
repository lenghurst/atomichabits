import 'package:flutter_test/flutter_test.dart';
import 'package:atomic_habits_hook_app/data/services/weather_service.dart';
import 'package:atomic_habits_hook_app/domain/entities/weather_context.dart';
import 'package:atomic_habits_hook_app/domain/interfaces/weather_provider.dart';
import 'package:atomic_habits_hook_app/core/cache/cache_manager.dart';

// Mock Provider
class MockWeatherProvider implements WeatherProvider {
  @override
  Future<WeatherContext?> getCurrentWeather({required double latitude, required double longitude}) async {
    return WeatherContext(
      condition: WeatherCondition.clear,
      temperatureCelsius: 22.0,
      isOutdoorSuitable: true,
      capturedAt: DateTime.now(),
    );
  }
}

void main() {
  group('WeatherService', () {
    test('fetches weather via provider and catches it', () async {
      final mockProvider = MockWeatherProvider();
      final cache = CacheManager<WeatherContext>(
        ttl: Duration(minutes: 15),
        debugLabel: 'TestWeatherCache',
      );
      
      final service = WeatherService(
        provider: mockProvider,
        cache: cache,
      );

      // First call - should hit provider
      final result1 = await service.getWeatherContext(lat: 10, lon: 10);
      expect(result1, isNotNull);
      expect(result1!.temperatureCelsius, 22.0);

      // Verify cache
      expect(cache.hasValue, true);
    });

    test('refreshes cache on location change', () async {
      final mockProvider = MockWeatherProvider();
       final cache = CacheManager<WeatherContext>(
        ttl: Duration(milliseconds: 100), // Short TTL
        debugLabel: 'TestWeatherCache2',
      );
      
      final service = WeatherService(
        provider: mockProvider,
        cache: cache,
      );

      // Call 1
      await service.getWeatherContext(lat: 10, lon: 10);
      
      // Force refresh logic test (simulate expiry)
      await Future.delayed(Duration(milliseconds: 200));
      
      // Call 2
      final result2 = await service.getWeatherContext(lat: 20, lon: 20); // Different location
      expect(result2!.temperatureCelsius, 22.0);
    });
  });
}
