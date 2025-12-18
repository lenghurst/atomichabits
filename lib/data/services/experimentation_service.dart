import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Phase 25.3: The Lab 2.0 - A/B Testing with Analytics Tracking
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

class ExperimentationService {
  static const String _storageKeyPrefix = 'exp_bucket_';
  static const String _assignmentLoggedPrefix = 'exp_logged_';
  final SharedPreferences _prefs;
  
  /// Flag to enable/disable analytics logging (for testing)
  bool analyticsEnabled = true;

  ExperimentationService(this._prefs);

  /// Returns the assigned variant for a given experiment (A, B, C, etc.)
  /// Uses deterministic hashing: hash(userId + experimentId) % variantCount
  /// 
  /// Phase 25.3: Now logs assignment to analytics on first access
  String getVariant(Experiment experiment, String userId, {int? variantCount}) {
    final experimentId = experiment.analyticsName;
    final storageKey = '$_storageKeyPrefix$experimentId';
    final effectiveVariantCount = variantCount ?? experiment.variantCount;

    // 1. Check local cache first (Sticky Bucketing)
    if (_prefs.containsKey(storageKey)) {
      final variant = _prefs.getString(storageKey)!;
      
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
    _prefs.setString(storageKey, variantLabel);
    
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
    if (!analyticsEnabled) return;
    
    final context = getExperimentContext(userId);
    
    try {
      final supabase = Supabase.instance.client;
      
      // Log each experiment assignment
      for (final entry in context.entries) {
        await _logToSupabase(
          supabase,
          userId: userId,
          experimentName: entry.key,
          variant: entry.value,
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
    if (!analyticsEnabled) return;
    
    final loggedKey = '$_assignmentLoggedPrefix${experiment.analyticsName}';
    
    // Check if already logged
    if (_prefs.containsKey(loggedKey) && !isNewAssignment) {
      return;
    }
    
    try {
      final supabase = Supabase.instance.client;
      
      await _logToSupabase(
        supabase,
        userId: userId,
        experimentName: experiment.analyticsName,
        variant: variant,
        isNewAssignment: isNewAssignment,
      );
      
      // Mark as logged
      _prefs.setBool(loggedKey, true);
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ExperimentationService: Failed to log assignment: $e');
      }
    }
  }
  
  /// Log assignment to Supabase
  Future<void> _logToSupabase(
    SupabaseClient supabase, {
    required String userId,
    required String experimentName,
    required String variant,
    bool isNewAssignment = false,
  }) async {
    final now = DateTime.now().toUtc();
    
    // Insert or update the assignment record
    await supabase.from('experiment_assignments').upsert({
      'user_id': userId,
      'experiment_name': experimentName,
      'variant': variant,
      'assigned_at': now.toIso8601String(),
      'is_new_assignment': isNewAssignment,
      'app_version': '5.7.0', // TODO: Get from package_info_plus
    }, onConflict: 'user_id,experiment_name');
    
    // Also log as an event for time-series analysis
    await supabase.from('experiment_events').insert({
      'user_id': userId,
      'experiment_name': experimentName,
      'variant': variant,
      'event_type': isNewAssignment ? 'assignment' : 'exposure',
      'created_at': now.toIso8601String(),
    });
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
    if (!analyticsEnabled) return;
    
    try {
      final supabase = Supabase.instance.client;
      final variant = getVariant(experiment, userId);
      final now = DateTime.now().toUtc();
      
      await supabase.from('experiment_events').insert({
        'user_id': userId,
        'experiment_name': experiment.analyticsName,
        'variant': variant,
        'event_type': 'conversion',
        'conversion_type': conversionType,
        'metadata': metadata != null ? jsonEncode(metadata) : null,
        'created_at': now.toIso8601String(),
      });
      
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
      await _prefs.remove(storageKey);
      await _prefs.remove(loggedKey);
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
    _prefs.setString(storageKey, variant);
    
    debugPrint('ExperimentationService: Forced ${experiment.name} to variant $variant');
  }
}
