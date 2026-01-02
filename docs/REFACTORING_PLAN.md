# JITAI Refactoring Plan - Finalized

## Directory Structure
```
lib/
├── core/
│   ├── cache/
│   │   └── cache_manager.dart
│   ├── retry/
│   │   └── retry_policy.dart
│   └── math/
│       └── beta_distribution.dart
│   └── utils/
│       └── risk_calculator.dart
├── domain/
│   ├── entities/
│   │   ├── weather_context.dart
│   │   └── archetype.dart
│   └── services/
│       └── archetype_registry.dart
└── data/
    ├── adapters/
    │   ├── open_meteo_adapter.dart
    │   └── openweathermap_adapter.dart
    └── services/
        └── weather_service.dart
```

## Phase 1: Foundational Utilities

### 1.1 CacheManager (Class)

**Implementation:**
```dart
// lib/core/cache/cache_manager.dart
class CacheManager<T> {
  final Duration ttl;
  // FIXED: Changed to Future<T> for async support
  final Future<T> Function()? refresher;
  final Future<void> Function(T)? onRefresh;

  T? _cached;
  DateTime? _lastFetch;

  CacheManager({
    this.ttl = const Duration(minutes: 15),
    this.refresher,
    this.onRefresh,
  });

  Future<T?> get() async {
    if (_isValid()) return _cached;
    
    if (refresher != null) {
      try {
        // Now awaited correctly
        final val = await refresher!();
        await set(val);
        return val;
      } catch (e) {
        if (_cached != null) return _cached;
        rethrow;
      }
    }
    return null;
  }
  // ... rest of implementation
}
```

### 1.2 RetryPolicy (Strategy Pattern)
(As previously defined with Jitter support)

### 1.3 BetaDistribution (Utility)

**Implementation:**
```dart
// lib/core/math/beta_distribution.dart
import 'dart:math';

class BetaDistribution {
  final double alpha;
  final double beta;

  const BetaDistribution(this.alpha, this.beta);

  double sample(Random random) {
    if (alpha <= 0 || beta <= 0) return 0.5; // Fallback
    final x = _sampleGamma(alpha, random);
    final y = _sampleGamma(beta, random);
    if (x + y == 0) return 0.5;
    return x / (x + y);
  }

  // Marsaglia/Tsang implementation needed here
  double _sampleGamma(double a, Random random) {
    // Implementation of Gamma sampling...
    if (a < 1) {
       final u = random.nextDouble();
       return _sampleGamma(1 + a, random) * pow(u, 1.0 / a);
    }
    // ...
    // Placeholder for full algorithm
    return 1.0; 
  }
  
  // ... update and blend methods
}
```

### 1.4 RiskCalculator (Utility)

**Implementation:**
```dart
// lib/core/utils/risk_calculator.dart
class RiskCalculator {
  static const int RISK_NONE = 0;
  static const int RISK_WEATHER = 1 << 0;
  static const int RISK_SOCIAL = 1 << 1;
  static const int RISK_INTERNAL = 1 << 2;
  // ...

  static bool hasRisk(int mask, int risk) => (mask & risk) != 0;
  
  static int combine(List<int> risks) {
    return risks.fold(0, (acc, curr) => acc | curr);
  }
}
```

## Phase 5: Migration Strategy

1.  **Week 1**: Create new utilities (non-breaking).
2.  **Week 2**: Add adapters alongside old services.
3.  **Week 3**: Update consumers to new APIs.
4.  **Week 4**: Deprecate old services.
5.  **Week 5**: Remove deprecated code.
