/// Tracks user baselines for Z-score calculation
/// Used by JITAIContextService to normalize sensor data.
class BaselineTracker {
  // Rolling windows for baseline calculation
  final List<int> _sleepHistory = [];
  final List<double> _hrvHistory = [];
  final List<int> _distractionHistory = [];

  static const int _windowSize = 14; // 14 days for baseline

  // Calculated baselines
  double? _sleepMean;
  double? _sleepStd;
  double? _hrvMean;
  double? _hrvStd;
  double? _distractionMean;
  double? _distractionStd;

  /// Calculate sleep Z-score
  double sleepZScore(int minutes) {
    if (_sleepMean == null || _sleepStd == null || _sleepStd == 0) {
      return 0.0; // No baseline yet
    }
    return (minutes - _sleepMean!) / _sleepStd!;
  }

  /// Calculate HRV Z-score
  double hrvZScore(double hrv) {
    if (_hrvMean == null || _hrvStd == null || _hrvStd == 0) {
      return 0.0;
    }
    return (hrv - _hrvMean!) / _hrvStd!;
  }

  /// Calculate distraction Z-score
  double distractionZScore(int minutes) {
    if (_distractionMean == null || _distractionStd == null || _distractionStd == 0) {
      return 0.0;
    }
    // Invert: higher distraction = negative Z-score (worse)
    return -((minutes - _distractionMean!) / _distractionStd!);
  }

  /// Update sleep baseline
  void updateSleepBaseline(int minutes) {
    _sleepHistory.add(minutes);
    if (_sleepHistory.length > _windowSize) {
      _sleepHistory.removeAt(0);
    }
    _recalculateSleepStats();
  }

  /// Update HRV baseline
  void updateHrvBaseline(double hrv) {
    _hrvHistory.add(hrv);
    if (_hrvHistory.length > _windowSize) {
      _hrvHistory.removeAt(0);
    }
    _recalculateHrvStats();
  }

  /// Update distraction baseline
  void updateDistractionBaseline(int minutes) {
    _distractionHistory.add(minutes);
    if (_distractionHistory.length > _windowSize) {
      _distractionHistory.removeAt(0);
    }
    _recalculateDistractionStats();
  }

  void _recalculateSleepStats() {
    if (_sleepHistory.isEmpty) return;
    _sleepMean = _sleepHistory.reduce((a, b) => a + b) / _sleepHistory.length;
    _sleepStd = _calculateStd(_sleepHistory.map((e) => e.toDouble()).toList(), _sleepMean!);
  }

  void _recalculateHrvStats() {
    if (_hrvHistory.isEmpty) return;
    _hrvMean = _hrvHistory.reduce((a, b) => a + b) / _hrvHistory.length;
    _hrvStd = _calculateStd(_hrvHistory, _hrvMean!);
  }

  void _recalculateDistractionStats() {
    if (_distractionHistory.isEmpty) return;
    _distractionMean = _distractionHistory.reduce((a, b) => a + b) / _distractionHistory.length;
    _distractionStd = _calculateStd(
      _distractionHistory.map((e) => e.toDouble()).toList(),
      _distractionMean!,
    );
  }

  double _calculateStd(List<double> values, double mean) {
    if (values.length < 2) return 1.0; // Avoid division by zero
    final variance = values.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) / values.length;
    return variance > 0 ? _sqrt(variance) : 1.0;
  }

  // Simple sqrt approximation (avoid dart:math import)
  double _sqrt(double x) {
    if (x <= 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  /// Export state for persistence
  Map<String, dynamic> toJson() => {
        'sleepHistory': _sleepHistory,
        'hrvHistory': _hrvHistory,
        'distractionHistory': _distractionHistory,
      };

  /// Import state from persistence
  void fromJson(Map<String, dynamic> json) {
    _sleepHistory.clear();
    _hrvHistory.clear();
    _distractionHistory.clear();

    if (json['sleepHistory'] != null) {
      _sleepHistory.addAll((json['sleepHistory'] as List).cast<int>());
      _recalculateSleepStats();
    }
    if (json['hrvHistory'] != null) {
      _hrvHistory.addAll((json['hrvHistory'] as List).map((e) => (e as num).toDouble()));
      _recalculateHrvStats();
    }
    if (json['distractionHistory'] != null) {
      _distractionHistory.addAll((json['distractionHistory'] as List).cast<int>());
      _recalculateDistractionStats();
    }
  }
}
