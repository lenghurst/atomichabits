import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Experiment {
  theHook,    // Onboarding Opener
  theWhisper, // Notification Timing
  theManifesto // Reward Format
}

class ExperimentationService {
  static const String _storageKeyPrefix = 'exp_bucket_';
  final SharedPreferences _prefs;

  ExperimentationService(this._prefs);

  /// Returns the assigned variant for a given experiment (A, B, C, etc.)
  /// Uses deterministic hashing: hash(userId + experimentId) % variantCount
  String getVariant(Experiment experiment, String userId, {int variantCount = 3}) {
    final experimentId = experiment.toString().split('.').last;
    final storageKey = '$_storageKeyPrefix$experimentId';

    // 1. Check local cache first (Sticky Bucketing)
    if (_prefs.containsKey(storageKey)) {
      return _prefs.getString(storageKey)!;
    }

    // 2. Deterministic Assignment
    final input = '$userId$experimentId';
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    
    // Convert first byte to integer and mod by variant count
    final bucketIndex = digest.bytes[0] % variantCount;
    
    // Map index to Variant Label (A, B, C...)
    final variantLabel = String.fromCharCode(65 + bucketIndex); // 65 is 'A'

    // 3. Persist assignment
    _prefs.setString(storageKey, variantLabel);

    return variantLabel;
  }

  /// Returns a map of all active experiments and their assigned variants
  /// Useful for analytics tagging
  Map<String, String> getExperimentContext(String userId) {
    final context = <String, String>{};
    for (var exp in Experiment.values) {
      context[exp.name] = getVariant(exp, userId);
    }
    return context;
  }
}
