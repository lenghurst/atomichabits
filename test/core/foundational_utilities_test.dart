import 'package:flutter_test/flutter_test.dart';
import 'package:atomic_habits_hook_app/core/cache/cache_manager.dart';
import 'package:atomic_habits_hook_app/core/utils/retry_policy.dart';
import 'package:atomic_habits_hook_app/core/utils/risk_calculator.dart';
import 'package:atomic_habits_hook_app/core/math/beta_distribution.dart';
import 'dart:math';

void main() {
  group('CacheManager', () {
    test('fetches and caches values', () async {
      int fetchCount = 0;
      final cache = CacheManager<int>(
        ttl: Duration(milliseconds: 100),
        refresher: () async {
          fetchCount++;
          return 42;
        },
      );

      // First fetch
      expect(await cache.get(), 42);
      expect(fetchCount, 1);

      // Cached fetch
      expect(await cache.get(), 42);
      expect(fetchCount, 1); // Should not have increased

      // Expiry
      await Future.delayed(Duration(milliseconds: 200));
      expect(await cache.get(), 42);
      expect(fetchCount, 2); // Should have increased
    });
  });

  group('RetryPolicy', () {
    test('retries failed operations', () async {
      int attempts = 0;
      final policy = RetryPolicy(
        maxAttempts: 3,
        initialDelay: Duration(milliseconds: 1),
        backoffFactor: 1.0,
      );

      try {
        await policy.execute(() async {
          attempts++;
          throw Exception('Fail');
        });
      } catch (e) {
        expect(e.toString(), contains('Fail'));
      }

      expect(attempts, 3);
    });
  });

  group('RiskCalculator', () {
    test('calculates correct bitmasks', () {
      int mask = RiskCalculator.RISK_NONE;
      mask = RiskCalculator.addRisk(mask, RiskCalculator.RISK_WEEKEND);
      mask = RiskCalculator.addRisk(mask, RiskCalculator.RISK_TRAVEL);

      expect(RiskCalculator.hasRisk(mask, RiskCalculator.RISK_WEEKEND), true);
      expect(RiskCalculator.hasRisk(mask, RiskCalculator.RISK_TRAVEL), true);
      expect(RiskCalculator.hasRisk(mask, RiskCalculator.RISK_STRESS), false);

      expect(RiskCalculator.combine([
        RiskCalculator.RISK_WEEKEND,
        RiskCalculator.RISK_TRAVEL
      ]), mask);
    });
  });

  group('BetaDistribution', () {
    test('samples within range [0, 1]', () {
      final beta = BetaDistribution(2.0, 5.0);
      for (int i = 0; i < 100; i++) {
        final sample = beta.sample();
        expect(sample, greaterThanOrEqualTo(0.0));
        expect(sample, lessThanOrEqualTo(1.0));
      }
    });

    test('updates correctly', () {
      final beta = BetaDistribution(1.0, 1.0); // Uniform
      final updated = beta.update(successes: 9, failures: 0); // Becomes (10, 1)
      
      expect(updated.alpha, 10.0);
      expect(updated.beta, 1.0);
      expect(updated.mean, closeTo(10/11, 0.01));
    });
  });
}
