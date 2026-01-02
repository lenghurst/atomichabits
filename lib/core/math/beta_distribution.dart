import 'dart:math';

/// BetaDistribution - Statistical utility for Thompson Sampling
///
/// Implements Beta distribution logic used in bandit algorithms.
/// Includes Gamma distribution sampling via Marsaglia and Tsang's method.
class BetaDistribution {
  final double alpha;
  final double beta;

  const BetaDistribution(this.alpha, this.beta);

  /// Sample a value from the Beta distribution [0, 1]
  ///
  /// Uses the property that if X ~ Gamma(a, 1) and Y ~ Gamma(b, 1),
  /// then X / (X + Y) ~ Beta(a, b).
  double sample([Random? random]) {
    final r = random ?? Random();

    if (alpha <= 0 || beta <= 0) {
      // Degenerate case, return mean or fallback
      if (alpha == beta) return 0.5;
      return alpha > beta ? 1.0 : 0.0;
    }

    final x = _sampleGamma(alpha, r);
    final y = _sampleGamma(beta, r);

    // Handle edge case where both are near zero
    if (x + y == 0) {
      return alpha / (alpha + beta);
    }

    return x / (x + y);
  }

  /// Update distribution with new observations
  BetaDistribution update({double successes = 0, double failures = 0}) {
    return BetaDistribution(alpha + successes, beta + failures);
  }

  /// Blend with another distribution (e.g., priors)
  BetaDistribution blend(BetaDistribution other, {double weight = 0.5}) {
    return BetaDistribution(
      alpha * (1 - weight) + other.alpha * weight,
      beta * (1 - weight) + other.beta * weight,
    );
  }

  /// Get the mean of the distribution
  double get mean => alpha / (alpha + beta);

  /// Get the variance of the distribution
  double get variance {
    final sum = alpha + beta;
    return (alpha * beta) / (sum * sum * (sum + 1));
  }

  /// Marsaglia and Tsang's Method for generating Gamma(a, 1) variables
  /// Reference: "A Simple Method for Generating Gamma Variables" (2000)
  ///
  /// For a < 1, uses the boosting property: Gamma(a, 1) = Gamma(a+1, 1) * U^(1/a)
  double _sampleGamma(double a, Random random) {
    if (a < 1) {
      final u = random.nextDouble();
      return _sampleGamma(1 + a, random) * pow(u, 1.0 / a);
    }

    final d = a - 1.0 / 3.0;
    final c = 1.0 / sqrt(9.0 * d);
    double v = 0.0;
    double x = 0.0;

    while (true) {
      double z;
      // Generate normal variable
      do {
        final u1 = random.nextDouble();
        final u2 = random.nextDouble();
        // Box-Muller transform
        z = sqrt(-2.0 * log(u1)) * cos(2.0 * pi * u2);
        v = 1.0 + c * z;
      } while (v <= 0);

      v = v * v * v;
      final u = random.nextDouble();

      // Squeeze check
      if (u < 1.0 - 0.0331 * pow(z, 4)) return d * v;

      // Logarithmic check
      if (log(u) < 0.5 * z * z + d * (1.0 - v + log(v))) return d * v;
    }
  }
  
  @override
  String toString() => 'Beta($alpha, $beta)';
}
