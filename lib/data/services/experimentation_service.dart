import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Phase 25.9: The Lab 2.0 - A/B Testing with Dependency Injection
/// 
/// SME Recommendation (Uncle Bob - Clean Architecture):
/// "The ExperimentationService is tightly coupled to SharedPreferences.
/// You cannot unit test your A/B buckets without mocking the entire device storage."
/// 
/// Solution: Introduce StorageProvider and AnalyticsProvider interfaces
/// for proper dependency injection and testability.
/// 
/// Experiments:
/// - theHook: Onboarding opener variant (A/B/C)
/// - theWhisper: Notification timing strategy
/// - theManifesto: Reward format presentation
/// 
/// Analytics Integration:
/// - Bucket assignments are logged to Supabase `experiment_assignments` table
/// - Events are tagged with experiment context for downstream analysis
/// - Supports PostHog/Amplitude integration via user properties

enum Experiment {
  theHook,     // Onboarding Opener
  theWhisper,  // Notification Timing
  theManifesto // Reward Format
}

/// Extension for experiment metadata
extension ExperimentExtension on Experiment {
  /// Human-readable name for analytics
  String get analyticsName {
    switch (this) {
      case Experiment.theHook:
        return 'the_hook';
      case Experiment.theWhisper:
        return 'the_whisper';
      case Experiment.theManifesto:
        return 'the_manifesto';
    }
  }
  
  /// Description for debugging
  String get description {
    switch (this) {
      case Experiment.theHook:
        return 'Onboarding opener variant';
      case Experiment.theWhisper:
        return 'Notification timing strategy';
      case Experiment.theManifesto:
        return 'Reward format presentation';
    }
  }
  
  /// Number of variants for this experiment
  int get variantCount {
    switch (this) {
      case Experiment.theHook:
        return 3; // A, B, C
      case Experiment.theWhisper:
        return 2; // A, B
      case Experiment.theManifesto:
        return 3; // A, B, C
    }
  }
}

// ============================================================
// DEPENDENCY INJECTION INTERFACES (Uncle Bob's Clean Architecture)
// ============================================================

/// Abstract interface for key-value storage
/// 
/// This allows unit tests to inject a mock storage provider
/// instead of requiring SharedPreferences or device storage.
abstract class StorageProvider {
  /// Check if a key exists
  bool containsKey(String key);
  
  /// Get a string value
  String? getString(String key);
  
  /// Set a string value
  Future<bool> setString(String key, String value);
  
  /// Get a boolean value
  bool? getBool(String key);
  
  /// Set a boolean value
  Future<bool> setBool(String key, bool value);
  
  /// Remove a key
  Future<bool> remove(String key);
}

/// Abstract interface for analytics logging
/// 
/// This allows unit tests to inject a mock analytics provider
/// and also enables swapping between Supabase, PostHog, Amplitude, etc.
abstract class AnalyticsProvider {
  /// Log an experiment assignment
  Future<void> logAssignment({
    required String userId,
    required String experimentName,
    required String variant,
    required bool isNewAssignment,
    String? appVersion,
  });
  
  /// Log an experiment event (exposure, conversion, etc.)
  Future<void> logEvent({
    required String userId,
    required String experimentName,
    required String variant,
    required String eventType,
    String? conversionType,
    Map<String, dynamic>? metadata,
  });
}

// ============================================================
// PRODUCTION IMPLEMENTATIONS
// ============================================================

/// Production implementation using SharedPreferences
/// 
/// Import: `import 'package:shared_preferences/shared_preferences.dart';`
class SharedPreferencesStorageProvider implements StorageProvider {
  final dynamic _prefs; // SharedPreferences
  
  SharedPreferencesStorageProvider(this._prefs);
  
  @override
  bool containsKey(String key) => _prefs.containsKey(key);
  
  @override
  String? getString(String key) => _prefs.getString(key);
  
  @override
  Future<bool> setString(String key, String value) => _prefs.setString(key, value);
  
  @override
  bool? getBool(String key) => _prefs.getBool(key);
  
  @override
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);
  
  @override
  Future<bool> remove(String key) => _prefs.remove(key);
}

/// Production implementation using Supabase
class SupabaseAnalyticsProvider implements AnalyticsProvider {
  final SupabaseClient _client;
  
  SupabaseAnalyticsProvider(this._client);
  
  /// Factory constructor using the default Supabase instance
  factory SupabaseAnalyticsProvider.instance() {
    return SupabaseAnalyticsProvider(Supabase.instance.client);
  }
  
  @override
  Future<void> logAssignment({
    required String userId,
    required String experimentName,
    required String variant,
    required bool isNewAssignment,
    String? appVersion,
  }) async {
    final now = DateTime.now().toUtc();
    
    await _client.from('experiment_assignments').upsert({
      'user_id': userId,
      'experiment_name': experimentName,
      'variant': variant,
      'assigned_at': now.toIso8601String(),
      'is_new_assignment': isNewAssignment,
      'app_version': appVersion ?? '5.7.0',
    }, onConflict: 'user_id,experiment_name');
  }
  
  @override
  Future<void> logEvent({
    required String userId,
    required String experimentName,
    required String variant,
    required String eventType,
    String? conversionType,
    Map<String, dynamic>? metadata,
  }) async {
    final now = DateTime.now().toUtc();
    
    await _client.from('experiment_events').insert({
      'user_id': userId,
      'experiment_name': experimentName,
      'variant': variant,
      'event_type': eventType,
      if (conversionType != null) 'conversion_type': conversionType,
      if (metadata != null) 'metadata': jsonEncode(metadata),
      'created_at': now.toIso8601String(),
    });
  }
}

// ============================================================
// TEST IMPLEMENTATIONS (for unit testing)
// ============================================================

/// In-memory storage provider for unit tests
class InMemoryStorageProvider implements StorageProvider {
  final Map<String, dynamic> _storage = {};
  
  @override
  bool containsKey(String key) => _storage.containsKey(key);
  
  @override
  String? getString(String key) => _storage[key] as String?;
  
  @override
  Future<bool> setString(String key, String value) async {
    _storage[key] = value;
    return true;
  }
  
  @override
  bool? getBool(String key) => _storage[key] as bool?;
  
  @override
  Future<bool> setBool(String key, bool value) async {
    _storage[key] = value;
    return true;
  }
  
  @override
  Future<bool> remove(String key) async {
    _storage.remove(key);
    return true;
  }
  
  /// Clear all storage (useful between tests)
  void clear() => _storage.clear();
  
  /// Get all stored data (for test assertions)
  Map<String, dynamic> get allData => Map.unmodifiable(_storage);
}

/// No-op analytics provider for unit tests
class NoOpAnalyticsProvider implements AnalyticsProvider {
  final List<Map<String, dynamic>> assignments = [];
  final List<Map<String, dynamic>> events = [];
  
  @override
  Future<void> logAssignment({
    required String userId,
    required String experimentName,
    required String variant,
    required bool isNewAssignment,
    String? appVersion,
  }) async {
    assignments.add({
      'userId': userId,
      'experimentName': experimentName,
      'variant': variant,
      'isNewAssignment': isNewAssignment,
      'appVersion': appVersion,
    });
  }
  
  @override
  Future<void> logEvent({
    required String userId,
    required String experimentName,
    required String variant,
    required String eventType,
    String? conversionType,
    Map<String, dynamic>? metadata,
  }) async {
    events.add({
      'userId': userId,
      'experimentName': experimentName,
      'variant': variant,
      'eventType': eventType,
      'conversionType': conversionType,
      'metadata': metadata,
    });
  }
  
  /// Clear all logged data (useful between tests)
  void clear() {
    assignments.clear();
    events.clear();
  }
}

// ============================================================
// EXPERIMENTATION SERVICE
// ============================================================

class ExperimentationService {
  static const String _storageKeyPrefix = 'exp_bucket_';
  static const String _assignmentLoggedPrefix = 'exp_logged_';
  
  final StorageProvider _storage;
  final AnalyticsProvider? _analytics;
  
  /// Flag to enable/disable analytics logging
  bool analyticsEnabled = true;
  
  /// App version for analytics (injected for testability)
  String appVersion = '5.7.0';

  /// Production constructor using SharedPreferences and Supabase
  /// 
  /// Usage:
  /// ```dart
  /// final prefs = await SharedPreferences.getInstance();
  /// final service = ExperimentationService.production(prefs);
  /// ```
  factory ExperimentationService.production(dynamic sharedPreferences) {
    return ExperimentationService(
      storage: SharedPreferencesStorageProvider(sharedPreferences),
      analytics: SupabaseAnalyticsProvider.instance(),
    );
  }
  
  /// Test constructor with injectable dependencies
  /// 
  /// Usage:
  /// ```dart
  /// final storage = InMemoryStorageProvider();
  /// final analytics = NoOpAnalyticsProvider();
  /// final service = ExperimentationService(storage: storage, analytics: analytics);
  /// ```
  ExperimentationService({
    required StorageProvider storage,
    AnalyticsProvider? analytics,
  }) : _storage = storage, _analytics = analytics;

  /// Returns the assigned variant for a given experiment (A, B, C, etc.)
  /// Uses deterministic hashing: hash(userId + experimentId) % variantCount
  /// 
  /// Phase 25.3: Now logs assignment to analytics on first access
  String getVariant(Experiment experiment, String userId, {int? variantCount}) {
    final experimentId = experiment.analyticsName;
    final storageKey = '$_storageKeyPrefix$experimentId';
    final effectiveVariantCount = variantCount ?? experiment.variantCount;

    // 1. Check local cache first (Sticky Bucketing)
    if (_storage.containsKey(storageKey)) {
      final variant = _storage.getString(storageKey)!;
      
      // Log assignment if not already logged
      _logAssignmentIfNeeded(experiment, userId, variant);
      
      return variant;
    }

    // 2. Deterministic Assignment
    final input = '$userId$experimentId';
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    
    // Convert first byte to integer and mod by variant count
    final bucketIndex = digest.bytes[0] % effectiveVariantCount;
    
    // Map index to Variant Label (A, B, C...)
    final variantLabel = String.fromCharCode(65 + bucketIndex); // 65 is 'A'

    // 3. Persist assignment
    _storage.setString(storageKey, variantLabel);
    
    // 4. Log to analytics
    _logAssignmentIfNeeded(experiment, userId, variantLabel, isNewAssignment: true);

    if (kDebugMode) {
      debugPrint('ExperimentationService: Assigned $userId to ${experiment.name} variant $variantLabel');
    }

    return variantLabel;
  }

  /// Returns a map of all active experiments and their assigned variants
  /// Useful for analytics tagging and user properties
  Map<String, String> getExperimentContext(String userId) {
    final context = <String, String>{};
    for (var exp in Experiment.values) {
      context[exp.analyticsName] = getVariant(exp, userId);
    }
    return context;
  }
  
  /// Log all experiment assignments to analytics
  /// Call this after user authentication to ensure all buckets are tracked
  Future<void> logAllAssignments(String userId) async {
    if (!analyticsEnabled || _analytics == null) return;
    
    final context = getExperimentContext(userId);
    
    try {
      for (final entry in context.entries) {
        await _analytics.logAssignment(
          userId: userId,
          experimentName: entry.key,
          variant: entry.value,
          isNewAssignment: false,
          appVersion: appVersion,
        );
      }
      
      if (kDebugMode) {
        debugPrint('ExperimentationService: Logged all assignments for $userId');
        debugPrint('Context: $context');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ExperimentationService: Failed to log assignments: $e');
      }
    }
  }
  
  /// Log a single assignment if not already logged
  Future<void> _logAssignmentIfNeeded(
    Experiment experiment,
    String userId,
    String variant, {
    bool isNewAssignment = false,
  }) async {
    if (!analyticsEnabled || _analytics == null) return;
    
    final loggedKey = '$_assignmentLoggedPrefix${experiment.analyticsName}';
    
    // Check if already logged
    if (_storage.containsKey(loggedKey) && !isNewAssignment) {
      return;
    }
    
    try {
      await _analytics.logAssignment(
        userId: userId,
        experimentName: experiment.analyticsName,
        variant: variant,
        isNewAssignment: isNewAssignment,
        appVersion: appVersion,
      );
      
      // Also log as an event for time-series analysis
      await _analytics.logEvent(
        userId: userId,
        experimentName: experiment.analyticsName,
        variant: variant,
        eventType: isNewAssignment ? 'assignment' : 'exposure',
      );
      
      // Mark as logged
      _storage.setBool(loggedKey, true);
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ExperimentationService: Failed to log assignment: $e');
      }
    }
  }
  
  /// Log a conversion event for an experiment
  /// 
  /// Call this when a user completes a key action that the experiment
  /// is designed to influence (e.g., completing onboarding, first habit check-in)
  Future<void> logConversion(
    String userId,
    Experiment experiment,
    String conversionType, {
    Map<String, dynamic>? metadata,
  }) async {
    if (!analyticsEnabled || _analytics == null) return;
    
    try {
      final variant = getVariant(experiment, userId);
      
      await _analytics.logEvent(
        userId: userId,
        experimentName: experiment.analyticsName,
        variant: variant,
        eventType: 'conversion',
        conversionType: conversionType,
        metadata: metadata,
      );
      
      if (kDebugMode) {
        debugPrint('ExperimentationService: Logged conversion "$conversionType" for ${experiment.name} variant $variant');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ExperimentationService: Failed to log conversion: $e');
      }
    }
  }
  
  /// Reset all experiment assignments (for testing only)
  Future<void> resetAllAssignments() async {
    for (var exp in Experiment.values) {
      final storageKey = '$_storageKeyPrefix${exp.analyticsName}';
      final loggedKey = '$_assignmentLoggedPrefix${exp.analyticsName}';
      await _storage.remove(storageKey);
      await _storage.remove(loggedKey);
    }
    
    if (kDebugMode) {
      debugPrint('ExperimentationService: Reset all experiment assignments');
    }
  }
  
  /// Force a specific variant for testing
  /// 
  /// WARNING: Only use in debug builds
  void forceVariant(Experiment experiment, String variant) {
    if (!kDebugMode) {
      throw StateError('forceVariant can only be used in debug builds');
    }
    
    final storageKey = '$_storageKeyPrefix${experiment.analyticsName}';
    _storage.setString(storageKey, variant);
    
    debugPrint('ExperimentationService: Forced ${experiment.name} to variant $variant');
  }
}
