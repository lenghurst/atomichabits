/// Population Learning Infrastructure - ML Workstream #3 Enhancement
///
/// Aggregates intervention effectiveness across users with same archetype.
/// Accelerates cold-start by using population-level priors.
///
/// Privacy-first design:
/// - Only stores aggregate Beta(alpha, beta) per archetype+arm
/// - No individual user data in population store
/// - Local-first with optional cloud sync
///
/// Philosophy: Users with similar failure patterns respond similarly
/// to interventions. Share learnings, not data.

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../entities/psychometric_profile.dart';
import '../entities/intervention.dart';
import '../../config/supabase_config.dart';

/// Population-level Beta distribution for an arm within an archetype
class PopulationPrior {
  /// Archetype this prior applies to
  final String archetype;

  /// Intervention arm ID
  final String armId;

  /// Success count (Beta alpha)
  final double alpha;

  /// Failure count (Beta beta)
  final double beta;

  /// Number of users who contributed to this prior
  final int contributorCount;

  /// Last updated timestamp
  final DateTime updatedAt;

  const PopulationPrior({
    required this.archetype,
    required this.armId,
    required this.alpha,
    required this.beta,
    required this.contributorCount,
    required this.updatedAt,
  });

  /// Expected success rate from population
  double get expectedRate => alpha / (alpha + beta);

  /// Confidence (higher = more data)
  double get confidence =>
      (contributorCount / 100.0).clamp(0.0, 1.0); // 100 users = max confidence

  /// Create from JSON (Supabase row)
  factory PopulationPrior.fromJson(Map<String, dynamic> json) {
    return PopulationPrior(
      archetype: json['archetype'] as String,
      armId: json['arm_id'] as String,
      alpha: (json['alpha'] as num).toDouble(),
      beta: (json['beta'] as num).toDouble(),
      contributorCount: json['contributor_count'] as int,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'archetype': archetype,
        'arm_id': armId,
        'alpha': alpha,
        'beta': beta,
        'contributor_count': contributorCount,
        'updated_at': updatedAt.toIso8601String(),
      };
}

/// Population Learning Service
///
/// Manages cross-user learning for archetypes.
/// Local storage with optional Supabase sync.
class PopulationLearningService {
  /// In-memory cache of population priors
  final Map<String, Map<String, PopulationPrior>> _priorCache = {};

  /// Pending local updates to sync
  final List<_LocalOutcome> _pendingOutcomes = [];

  /// Default priors for each archetype (research-based)
  static final Map<String, Map<String, (double, double)>> _defaultPriors = {
    'REBEL': {
      'SHADOW_AUTONOMY': (8.0, 2.0), // 80% expected
      'SILENCE_TRUST': (7.0, 3.0), // 70% expected
      'ID_VOTE': (4.0, 6.0), // 40% expected (rebels resist direct asks)
      'ID_MIRROR': (3.0, 7.0), // 30% expected
      'FRICTION_TINY': (5.0, 5.0), // 50% expected
    },
    'PERFECTIONIST': {
      'FRICTION_TINY': (9.0, 1.0), // 90% expected (permission to go small)
      'COG_ZOOM': (8.0, 2.0), // 80% expected (big picture helps)
      'EMO_COMPASSION': (7.0, 3.0), // 70% expected
      'ID_VOTE': (6.0, 4.0), // 60% expected
      'SHADOW_AUTONOMY': (3.0, 7.0), // 30% expected (perfectionist wants guidance)
    },
    'OVERTHINKER': {
      'FRICTION_TINY': (8.0, 2.0), // 80% - reduce decision paralysis
      'EMO_URGE_SURF': (7.0, 3.0), // 70% - mindfulness helps
      'COG_LIE_CALL': (6.0, 4.0), // 60% - expose overthinking
      'ID_MIRROR': (5.0, 5.0), // 50%
      'SILENCE_TRUST': (4.0, 6.0), // 40% - need more structure
    },
    'PROCRASTINATOR': {
      'FRICTION_TINY': (9.0, 1.0), // 90% - tiny wins everything
      'ID_ANTI_WARN': (7.0, 3.0), // 70% - avoid becoming the procrastinator
      'ID_VOTE': (6.0, 4.0), // 60%
      'SOCIAL_WITNESS': (6.0, 4.0), // 60% - accountability helps
      'SILENCE_TRUST': (2.0, 8.0), // 20% - need nudges, not silence
    },
    'EMOTIONAL_REACTOR': {
      'EMO_COMPASSION': (9.0, 1.0), // 90% - emotional validation
      'EMO_URGE_SURF': (8.0, 2.0), // 80% - emotional regulation
      'FRICTION_TINY': (6.0, 4.0), // 60%
      'COG_LIE_CALL': (4.0, 6.0), // 40% - can feel confrontational
      'SHADOW_AUTONOMY': (3.0, 7.0), // 30% - need support not distance
    },
  };

  /// Composite (average) priors for unknown archetypes
  static final Map<String, (double, double)> _compositePriors = {
    'FRICTION_TINY': (7.0, 3.0), // Universal helper
    'ID_VOTE': (5.0, 5.0), // Neutral baseline
    'EMO_COMPASSION': (6.0, 4.0), // Generally helpful
    'SILENCE_TRUST': (4.0, 6.0), // Context-dependent
    'SHADOW_AUTONOMY': (4.0, 6.0), // Context-dependent
  };

  /// Get population prior for an archetype+arm combination
  PopulationPrior getPrior({
    required String archetype,
    required String armId,
  }) {
    // Check cache first
    final cached = _priorCache[archetype]?[armId];
    if (cached != null) return cached;

    // Fall back to defaults
    final defaults = _defaultPriors[archetype.toUpperCase()] ??
        _compositePriors;

    final (alpha, beta) = defaults[armId] ?? (5.0, 5.0);

    return PopulationPrior(
      archetype: archetype,
      armId: armId,
      alpha: alpha,
      beta: beta,
      contributorCount: 0, // Default = no real data yet
      updatedAt: DateTime.now(),
    );
  }

  /// Get all priors for an archetype (for cold-start seeding)
  Map<String, PopulationPrior> getPriorsForArchetype(String archetype) {
    final result = <String, PopulationPrior>{};

    // Get cached priors
    _priorCache[archetype]?.forEach((armId, prior) {
      result[armId] = prior;
    });

    // Fill in defaults for missing arms
    final defaults = _defaultPriors[archetype.toUpperCase()] ??
        _compositePriors;

    for (final armId in defaults.keys) {
      if (!result.containsKey(armId)) {
        result[armId] = getPrior(archetype: archetype, armId: armId);
      }
    }

    return result;
  }

  /// Record local outcome (queued for batch sync)
  ///
  /// Privacy: We only store success/failure, not user ID
  void recordOutcome({
    required String archetype,
    required String armId,
    required bool success,
  }) {
    _pendingOutcomes.add(_LocalOutcome(
      archetype: archetype,
      armId: armId,
      success: success,
      timestamp: DateTime.now(),
    ));

    // Update local cache immediately
    _updateLocalCache(archetype, armId, success);
  }

  /// Update local cache with new outcome
  void _updateLocalCache(String archetype, String armId, bool success) {
    _priorCache.putIfAbsent(archetype, () => {});

    final current = _priorCache[archetype]![armId];
    if (current != null) {
      _priorCache[archetype]![armId] = PopulationPrior(
        archetype: archetype,
        armId: armId,
        alpha: current.alpha + (success ? 1.0 : 0.0),
        beta: current.beta + (success ? 0.0 : 1.0),
        contributorCount: current.contributorCount,
        updatedAt: DateTime.now(),
      );
    } else {
      final (baseAlpha, baseBeta) =
          (_defaultPriors[archetype.toUpperCase()]?[armId]) ?? (5.0, 5.0);
      _priorCache[archetype]![armId] = PopulationPrior(
        archetype: archetype,
        armId: armId,
        alpha: baseAlpha + (success ? 1.0 : 0.0),
        beta: baseBeta + (success ? 0.0 : 1.0),
        contributorCount: 1,
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Sync pending outcomes to Supabase (called periodically)
  Future<void> syncToCloud({
    required Future<void> Function(List<Map<String, dynamic>>) uploadBatch,
  }) async {
    if (_pendingOutcomes.isEmpty) return;

    // Aggregate outcomes by archetype+arm
    final aggregated = <String, _AggregatedOutcome>{};

    for (final outcome in _pendingOutcomes) {
      final key = '${outcome.archetype}:${outcome.armId}';
      aggregated.putIfAbsent(
        key,
        () => _AggregatedOutcome(outcome.archetype, outcome.armId),
      );
      if (outcome.success) {
        aggregated[key]!.successes++;
      } else {
        aggregated[key]!.failures++;
      }
    }

    // Upload aggregated data (no individual outcomes)
    final batch = aggregated.values.map((a) => {
      'archetype': a.archetype,
      'arm_id': a.armId,
      'successes': a.successes,
      'failures': a.failures,
    }).toList();

    await uploadBatch(batch);

    // Clear pending
    _pendingOutcomes.clear();
  }

  /// Load population priors from cloud (called on app start)
  Future<void> loadFromCloud({
    required Future<List<Map<String, dynamic>>> Function() fetchPriors,
  }) async {
    final rows = await fetchPriors();

    for (final row in rows) {
      final prior = PopulationPrior.fromJson(row);
      _priorCache.putIfAbsent(prior.archetype, () => {});
      _priorCache[prior.archetype]![prior.armId] = prior;
    }
  }

  /// Get blended prior (population + local learning)
  ///
  /// Blends population knowledge with individual user's history.
  /// Population weight decreases as user accumulates personal data.
  (double, double) getBlendedPrior({
    required String archetype,
    required String armId,
    required double localAlpha,
    required double localBeta,
  }) {
    final population = getPrior(archetype: archetype, armId: armId);

    // Calculate weights based on local sample size
    final localSamples = localAlpha + localBeta - 2; // Subtract initial prior
    final populationWeight = _calculatePopulationWeight(
      localSamples: localSamples.toInt(),
      populationConfidence: population.confidence,
    );

    // Blend: weighted average
    final blendedAlpha = (population.alpha * populationWeight) +
        (localAlpha * (1 - populationWeight));
    final blendedBeta = (population.beta * populationWeight) +
        (localBeta * (1 - populationWeight));

    return (blendedAlpha, blendedBeta);
  }

  /// Calculate population weight (decreases as user gets more data)
  double _calculatePopulationWeight({
    required int localSamples,
    required double populationConfidence,
  }) {
    // Start at 80%, decay to 20% over 50 samples
    const initialWeight = 0.8;
    const minWeight = 0.2;
    const decayRate = 0.05;

    final decay = exp(-decayRate * localSamples);
    final weight = minWeight + (initialWeight - minWeight) * decay;

    // Scale by population confidence
    return weight * populationConfidence;
  }

  /// Export statistics for debugging
  Map<String, dynamic> exportStats() {
    return {
      'cachedArchetypes': _priorCache.keys.toList(),
      'pendingOutcomes': _pendingOutcomes.length,
      'priorCounts': _priorCache.map(
        (archetype, arms) => MapEntry(archetype, arms.length),
      ),
    };
  }

  /// Seed cache with research-based default priors for an archetype
  void _seedDefaultPriors(String archetype) {
    final normalizedArchetype = archetype.toUpperCase();
    final defaults = _defaultPriors[normalizedArchetype] ?? _compositePriors;

    _priorCache.putIfAbsent(normalizedArchetype, () => {});

    for (final entry in defaults.entries) {
      final armId = entry.key;
      final (alpha, beta) = entry.value;

      _priorCache[normalizedArchetype]![armId] = PopulationPrior(
        archetype: normalizedArchetype,
        armId: armId,
        alpha: alpha,
        beta: beta,
        contributorCount: 0, // Research prior, not population data
        updatedAt: DateTime.now(),
      );
    }
  }

  // ============================================================
  // SUPABASE EDGE FUNCTION INTEGRATION
  // ============================================================

  /// Fetch population priors from Supabase Edge Function
  Future<void> fetchFromEdgeFunction(String archetype) async {
    if (!SupabaseConfig.isConfigured) {
      if (kDebugMode) {
        debugPrint('PopulationLearning: Supabase not configured, using defaults');
      }
      return;
    }

    try {
      final url = Uri.parse(
        '${SupabaseConfig.url}/functions/v1/population-learning-fetch?archetype=$archetype',
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${SupabaseConfig.anonKey}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        if (kDebugMode) {
          debugPrint('PopulationLearning: Fetch failed: ${response.statusCode}');
        }
        return;
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final priors = data['priors'] as Map<String, dynamic>? ?? {};

      // Update cache
      _priorCache.putIfAbsent(archetype, () => {});

      // If Edge Function returns empty priors, seed from research-based defaults
      if (priors.isEmpty) {
        if (kDebugMode) {
          debugPrint('PopulationLearning: No population data for $archetype, using research defaults');
        }
        _seedDefaultPriors(archetype);
        return;
      }

      priors.forEach((armId, values) {
        final v = values as Map<String, dynamic>;
        _priorCache[archetype]![armId] = PopulationPrior(
          archetype: archetype,
          armId: armId,
          alpha: (v['alpha'] as num).toDouble(),
          beta: (v['beta'] as num).toDouble(),
          contributorCount: v['sampleCount'] as int? ?? 0,
          updatedAt: DateTime.now(),
        );
      });

      if (kDebugMode) {
        debugPrint('PopulationLearning: Loaded ${priors.length} priors for $archetype');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PopulationLearning: Fetch error: $e');
      }
    }
  }

  /// Sync pending outcomes to Supabase Edge Function
  Future<void> syncToEdgeFunction({required String userId}) async {
    if (!SupabaseConfig.isConfigured || _pendingOutcomes.isEmpty) {
      return;
    }

    try {
      // Group outcomes by archetype
      final byArchetype = <String, List<_LocalOutcome>>{};
      for (final outcome in _pendingOutcomes) {
        byArchetype.putIfAbsent(outcome.archetype, () => []).add(outcome);
      }

      // Hash user ID for privacy
      final userHash = sha256.convert(utf8.encode(userId)).toString();

      // Sync each archetype
      for (final entry in byArchetype.entries) {
        final archetype = entry.key;
        final outcomes = entry.value;

        final url = Uri.parse(
          '${SupabaseConfig.url}/functions/v1/population-learning-sync',
        );

        final response = await http.post(
          url,
          headers: {
            'Authorization': 'Bearer ${SupabaseConfig.anonKey}',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'userHash': userHash,
            'archetype': archetype,
            'outcomes': outcomes.map((o) => {
              return {
                'armId': o.armId,
                'success': o.success,
              };
            }).toList(),
          }),
        );

        if (response.statusCode == 200) {
          if (kDebugMode) {
            debugPrint('PopulationLearning: Synced ${outcomes.length} outcomes for $archetype');
          }
        } else {
          if (kDebugMode) {
            debugPrint('PopulationLearning: Sync failed: ${response.statusCode}');
          }
        }
      }

      // Clear pending outcomes on success
      _pendingOutcomes.clear();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PopulationLearning: Sync error: $e');
      }
    }
  }

  /// Initialize with population priors for a profile
  Future<void> initializeForProfile(PsychometricProfile profile) async {
    final archetype = profile.archetypeKey;
    if (archetype == 'UNKNOWN') return;

    await fetchFromEdgeFunction(archetype);
  }
}

/// Local outcome awaiting sync
class _LocalOutcome {
  final String archetype;
  final String armId;
  final bool success;
  final DateTime timestamp;

  _LocalOutcome({
    required this.archetype,
    required this.armId,
    required this.success,
    required this.timestamp,
  });
}

/// Aggregated outcomes for batch sync
class _AggregatedOutcome {
  final String archetype;
  final String armId;
  int successes = 0;
  int failures = 0;

  _AggregatedOutcome(this.archetype, this.armId);
}

/// Extension to get population priors for a profile
extension PopulationPriorExtension on PsychometricProfile {
  /// Get archetype string for population learning
  String get archetypeKey {
    return (failureArchetype ?? 'UNKNOWN').toUpperCase();
  }
}
