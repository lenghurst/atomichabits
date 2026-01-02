/// JITAI Configuration
///
/// Just-In-Time Adaptive Interventions configuration.
/// API keys and settings for context sensing services.
///
/// SECURITY PROTOCOL:
/// - All secrets are injected at runtime via --dart-define-from-file
/// - NO hardcoded API keys in source code
/// - Local development: secrets.json (git-ignored)
/// - CI/CD: GitHub Secrets or Codemagic environment variables
///
/// To configure locally:
/// 1. Add keys to `secrets.json` in the project root
/// 2. Ensure secrets.json is in .gitignore
/// 3. Configure .vscode/launch.json with --dart-define-from-file=secrets.json
class JITAIConfig {
  /// OpenWeatherMap API Key
  ///
  /// Free tier: 1000 calls/day
  /// Get your key at: https://openweathermap.org/api
  ///
  /// Used for:
  /// - Current weather conditions
  /// - 3-day forecast for cascade prevention
  /// - Outdoor suitability detection
  static const String openWeatherMapApiKey = String.fromEnvironment(
    'OPENWEATHERMAP_API_KEY',
    defaultValue: '', // Set via --dart-define=OPENWEATHERMAP_API_KEY=your_key
  );

  /// Check if weather API is configured
  static bool get isWeatherConfigured => openWeatherMapApiKey.isNotEmpty;

  // ============================================================
  // JITAI Behavior Settings
  // ============================================================

  /// Minimum interval between JITAI checks (battery saving)
  static const Duration minCheckInterval = Duration(minutes: 15);

  /// Periodic background check interval
  static const Duration periodicCheckInterval = Duration(minutes: 30);

  /// Context cache duration
  static const Duration contextCacheDuration = Duration(minutes: 5);

  /// Maximum interventions per day per habit
  static const int maxInterventionsPerDay = 5;

  /// Minimum time between interventions for same habit
  static const Duration minInterventionInterval = Duration(hours: 2);

  /// Intervention fatigue threshold (interventions in 24h before reducing)
  static const int fatigueTriggerCount = 3;

  // ============================================================
  // Cascade Prevention Settings
  // ============================================================

  /// Days of weather forecast to fetch
  static const int weatherForecastDays = 3;

  /// Cascade risk threshold for proactive intervention
  static const double cascadeRiskThreshold = 0.5;

  /// Sleep deficit threshold (hours below baseline)
  static const double sleepDeficitThreshold = 1.5;

  /// HRV z-score threshold for stress detection
  static const double stressHrvThreshold = -1.5;

  // ============================================================
  // Optimal Timing Settings
  // ============================================================

  /// Minimum timing score to trigger intervention
  static const double minTimingScore = 0.35;

  /// Weight for historical completion patterns
  static const double historicalPatternWeight = 0.4;

  /// Weight for current context signals
  static const double contextSignalWeight = 0.3;

  /// Weight for profile-based predictions
  static const double profilePredictionWeight = 0.3;

  // ============================================================
  // Thompson Sampling Settings
  // ============================================================

  /// Initial alpha for Beta distribution (successes)
  static const double initialAlpha = 1.0;

  /// Initial beta for Beta distribution (failures)
  static const double initialBeta = 1.0;

  /// Exploration bonus for new arms
  static const double explorationBonus = 0.1;

  /// Decay rate for old outcomes
  static const double outcomeDecayRate = 0.95;
}

/// JITAI Feature Flags
///
/// Toggle individual JITAI features for gradual rollout.
class JITAIFeatureFlags {
  /// Enable weather-based cascade prevention
  static const bool enableWeatherPrevention = true;

  /// Enable travel detection from calendar
  static const bool enableTravelDetection = true;

  /// Enable biometric context (sleep, HRV)
  static const bool enableBiometrics = true;

  /// Enable population learning from Supabase
  static const bool enablePopulationLearning = true;

  /// Enable Thompson Sampling for arm selection
  static const bool enableBanditOptimization = true;

  /// Enable proactive cascade alerts
  static const bool enableCascadeAlerts = true;

  /// Enable optimal timing predictions
  static const bool enableTimingPredictions = true;
}
