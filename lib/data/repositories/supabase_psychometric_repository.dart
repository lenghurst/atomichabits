import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/psychometric_profile.dart';
import 'psychometric_repository.dart';

/// Cloud persistence for PsychometricProfile using Supabase.
///
/// Corresponds to Layer 1 (Evidence Engine) of the architecture.
/// Stores data in 'public.identity_seeds' table.
class SupabasePsychometricRepository implements PsychometricRepository {
  final SupabaseClient _client;

  SupabasePsychometricRepository(this._client);

  @override
  Future<void> init() async {
    // Supabase client is initialized at app startup, nothing specific here yet.
  }

  /// Sync user profile TO cloud (Upsert)
  ///
  /// Called after local Hive save.
  /// Uses 'on conflict' logic implicitly via upsert.
  Future<void> syncToCloud(PsychometricProfile profile) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      if (kDebugMode) {
        debugPrint(
            'SupabasePsychometricRepository: No user logged in, skipping cloud sync.');
      }
      return;
    }

    try {
      final data = {
        'user_id': userId,
        'anti_identity_label': profile.antiIdentityLabel ?? '',
        'anti_identity_context': profile.antiIdentityContext ?? '',
        'failure_archetype': profile.failureArchetype ?? '',
        'failure_trigger_context': profile.failureTriggerContext ?? '',
        'resistance_lie_label': profile.resistanceLieLabel ?? '',
        'resistance_lie_context': profile.resistanceLieContext ?? '',
        'core_values': profile.coreValues,
        'big_why': profile.bigWhy,
        'inferred_fears': profile.inferredFears,
        'resonance_words': profile.resonanceWords,
        'avoid_words': profile.avoidWords,
        'coaching_style': profile.coachingStyle.name,
        'verbosity_preference': profile.verbosityPreference,
        'hive_last_updated': profile.lastUpdated.toIso8601String(),
        'sync_status': 'synced',
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _client.from('identity_seeds').upsert(data, onConflict: 'user_id');

      if (kDebugMode) {
        debugPrint(
            'SupabasePsychometricRepository: Synced profile to cloud for user $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SupabasePsychometricRepository: Error syncing to cloud: $e');
      }
      // We don't rethrow because cloud sync failure shouldn't crash the app flow
      // (local persistence handled by Hive).
    }
  }

  /// Fetch profile FROM cloud
  ///
  /// Used during sync-on-login or conflict resolution.
  @override
  Future<PsychometricProfile?> getProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final response = await _client
          .from('identity_seeds')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return _mapSupabaseDataToProfile(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            'SupabasePsychometricRepository: Error fetching from cloud: $e');
      }
      return null;
    }
  }

  /// Save profile - delegates to syncToCloud for cloud repository
  @override
  Future<void> saveProfile(PsychometricProfile profile) async {
    await syncToCloud(profile);
  }

  @override
  Future<void> markAsSynced() async {
    // Cloud repo doesn't track 'isSynced' flag locally, Hive does.
    // This is a no-op for the cloud repo itself.
  }

  @override
  Future<void> clear() async {
    // We typically don't delete cloud data on local clear,
    // unless it's a "Delete Account" action.
    // Leaving empty for now to protect data,
    // user likely only wants to clear local cache.
  }

  // --- Helper ---

  PsychometricProfile _mapSupabaseDataToProfile(Map<String, dynamic> data) {
    // Convert string back to enum
    CoachingStyle style = CoachingStyle.supportive;
    if (data['coaching_style'] != null) {
      try {
        style = CoachingStyle.values.firstWhere(
          (e) => e.name == data['coaching_style'],
          orElse: () => CoachingStyle.supportive,
        );
      } catch (_) {}
    }

    // Helper to safely get lists
    List<String> getList(String key) {
      if (data[key] is List) {
        return (data[key] as List).map((e) => e.toString()).toList();
      }
      return [];
    }

    return PsychometricProfile(
      antiIdentityLabel: data['anti_identity_label'] as String?,
      antiIdentityContext: data['anti_identity_context'] as String?,
      failureArchetype: data['failure_archetype'] as String?,
      failureTriggerContext: data['failure_trigger_context'] as String?,
      resistanceLieLabel: data['resistance_lie_label'] as String?,
      resistanceLieContext: data['resistance_lie_context'] as String?,
      coreValues: getList('core_values'),
      bigWhy: data['big_why'] as String?,
      inferredFears: getList('inferred_fears'),
      resonanceWords: getList('resonance_words'),
      avoidWords: getList('avoid_words'),
      coachingStyle: style,
      verbosityPreference: (data['verbosity_preference'] as num?)?.toInt() ?? 3,
      lastUpdated: data['hive_last_updated'] != null
          ? DateTime.parse(data['hive_last_updated'] as String)
          : DateTime.now(),
      isSynced: true, // From cloud, so it is synced
    );
  }
}
