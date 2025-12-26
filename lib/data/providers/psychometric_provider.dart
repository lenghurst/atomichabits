import 'package:flutter/foundation.dart';
import '../../domain/entities/psychometric_profile.dart';
import '../../domain/entities/psychometric_profile_extensions.dart';
import '../../domain/services/psychometric_engine.dart';
import '../repositories/psychometric_repository.dart';
import '../models/habit.dart';

/// PsychometricProvider: Manages the user's psychological profile for LLM context.
/// 
/// This provider holds the PsychometricProfile and coordinates with the PsychometricEngine
/// to update the profile based on user behavior.
/// 
/// Satisfies: Rousselet (Specific Scope), Uncle Bob (DIP).
class PsychometricProvider extends ChangeNotifier {
  final PsychometricRepository _repository;
  final PsychometricEngine _engine;
  
  PsychometricProfile _profile = PsychometricProfile();
  bool _isLoading = true;

  PsychometricProvider(this._repository, this._engine);

  // === Getters ===
  PsychometricProfile get profile => _profile;
  bool get isLoading => _isLoading;
  
  /// Get the LLM system prompt for this user
  String get llmSystemPrompt => _profile.toSystemPrompt();
  
  /// Check if user is in a vulnerable state right now
  bool get isCurrentlyVulnerable => _profile.isVulnerableAt(DateTime.now());

  /// Initialize the provider by loading from repository
  Future<void> initialize() async {
    try {
      final loadedProfile = await _repository.getProfile();
      if (loadedProfile != null) {
        _profile = loadedProfile;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('PsychometricProvider: Error initializing: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Initialize profile from onboarding data
  Future<void> initializeFromOnboarding({
    required String identity,
    required String motivation,
    String? bigWhy,
    List<String>? fears,
  }) async {
    _profile = _engine.initializeFromOnboarding(
      identity: identity,
      motivation: motivation,
      bigWhy: bigWhy,
      fears: fears,
    ).copyWith(
      isSynced: false,
      lastUpdated: DateTime.now(),
    );
    await _repository.saveProfile(_profile);
    notifyListeners();
  }

  /// Record a habit miss (updates resilience)
  Future<void> recordMiss() async {
    _profile = _engine.onHabitMiss(_profile).copyWith(
      isSynced: false, 
      lastUpdated: DateTime.now(),
    );
    await _repository.saveProfile(_profile);
    notifyListeners();
  }

  /// Record a habit completion (updates resilience)
  Future<void> recordCompletion({bool wasRecovery = false}) async {
    _profile = _engine.onHabitComplete(_profile, wasRecovery: wasRecovery).copyWith(
      isSynced: false, 
      lastUpdated: DateTime.now(),
    );
    await _repository.saveProfile(_profile);
    notifyListeners();
  }

  /// Update coaching style preference
  Future<void> setCoachingStyle(CoachingStyle style) async {
    _profile = _profile.copyWith(
      coachingStyle: style,
      isSynced: false,
      lastUpdated: DateTime.now(),
    );
    await _repository.saveProfile(_profile);
    notifyListeners();
  }

  /// Update verbosity preference
  Future<void> setVerbosityPreference(int level) async {
    _profile = _profile.copyWith(
      verbosityPreference: level.clamp(1, 5),
      isSynced: false,
      lastUpdated: DateTime.now(),
    );
    await _repository.saveProfile(_profile);
    notifyListeners();
  }

  /// Update core values
  Future<void> setCoreValues(List<String> values) async {
    _profile = _profile.copyWith(
      coreValues: values,
      isSynced: false,
      lastUpdated: DateTime.now(),
    );
    await _repository.saveProfile(_profile);
    notifyListeners();
  }

  /// Update anti-identities (fears)
  Future<void> setAntiIdentities(List<String> fears) async {
    _profile = _profile.copyWith(
      antiIdentities: fears,
      isSynced: false,
      lastUpdated: DateTime.now(),
    );
    await _repository.saveProfile(_profile);
    notifyListeners();
  }

  /// Update the big why
  Future<void> setBigWhy(String bigWhy) async {
    _profile = _profile.copyWith(
      bigWhy: bigWhy,
      isSynced: false,
      lastUpdated: DateTime.now(),
    );
    await _repository.saveProfile(_profile);
    notifyListeners();
  }

  /// Update resonance words (words that motivate)
  Future<void> setResonanceWords(List<String> words) async {
    _profile = _profile.copyWith(
      resonanceWords: words,
      isSynced: false,
      lastUpdated: DateTime.now(),
    );
    await _repository.saveProfile(_profile);
    notifyListeners();
  }

  /// Update avoid words (words that cause resistance)
  Future<void> setAvoidWords(List<String> words) async {
    _profile = _profile.copyWith(
      avoidWords: words,
      isSynced: false,
      lastUpdated: DateTime.now(),
    );
    await _repository.saveProfile(_profile);
    notifyListeners();
  }

  /// Recalibrate risks based on habit history (call periodically)
  /// Uses Isolate for heavy O(N) computation per Muratori's recommendation.
  Future<void> recalibrateRisks(List<Habit> habits) async {
    _profile = await _engine.recalibrateRisksAsync(_profile, habits);
    
    // Also update peak energy window
    final peakWindow = await _engine.calculatePeakEnergyWindowAsync(habits);
    _profile = _profile.copyWith(
      peakEnergyWindow: peakWindow,
      isSynced: false,
      lastUpdated: DateTime.now(),
    );
    
    await _repository.saveProfile(_profile);
    notifyListeners();
  }

  /// Update profile based on chat feedback
  Future<void> updateFromChatFeedback({
    required String userMessage,
    required bool wasPositiveResponse,
  }) async {
    _profile = _engine.updateFromChatFeedback(
      _profile,
      userMessage: userMessage,
      wasPositiveResponse: wasPositiveResponse,
    );
    await _repository.saveProfile(_profile);
    notifyListeners();
  }

  /// Clear all psychometric data
  Future<void> clear() async {
    _profile = PsychometricProfile();
    await _repository.clear();
    notifyListeners();
  }
  
  // ============================================================
  // PHASE 42: TOOL CALL HANDLERS (Sherlock Protocol)
  // ============================================================
  
  /// Update profile from AI tool call arguments.
  /// 
  /// This method is called by VoiceSessionManager when the AI invokes
  /// the `update_user_psychometrics` tool during onboarding.
  /// 
  /// IMPORTANT: Saves to Hive IMMEDIATELY (crash recovery per Margaret Hamilton).
  /// Each trait is saved independently - we don't wait for all 3 traits.
  /// 
  /// Arguments use snake_case to match the tool schema.
  Future<void> updateFromToolCall(Map<String, dynamic> args) async {
    if (kDebugMode) {
      debugPrint('PsychometricProvider: Received tool call with args: $args');
    }
    
    // Build the update using only the fields that were provided
    _profile = _profile.copyWith(
      // Trait 1: Anti-Identity
      antiIdentityLabel: args['anti_identity_label'] as String? ?? _profile.antiIdentityLabel,
      antiIdentityContext: args['anti_identity_context'] as String? ?? _profile.antiIdentityContext,
      
      // Trait 2: Failure Archetype
      failureArchetype: args['failure_archetype'] as String? ?? _profile.failureArchetype,
      failureTriggerContext: args['failure_trigger_context'] as String? ?? _profile.failureTriggerContext,
      
      // Trait 3: Resistance Pattern
      resistanceLieLabel: args['resistance_lie_label'] as String? ?? _profile.resistanceLieLabel,
      resistanceLieContext: args['resistance_lie_context'] as String? ?? _profile.resistanceLieContext,
      
      // Inferred fears (merge with existing if provided)
      inferredFears: args['inferred_fears'] != null 
          ? List<String>.from(args['inferred_fears'] as List)
          : _profile.inferredFears,
    );
    
    // CRITICAL: Save immediately (crash recovery)
    await _repository.saveProfile(_profile);
    
    if (kDebugMode) {
      debugPrint('PsychometricProvider: Profile saved. Onboarding complete: ${_profile.isOnboardingComplete}');
    }
    
    notifyListeners();
  }
  
  /// Check if the Holy Trinity has been captured
  bool get hasHolyTrinity => _profile.hasHolyTrinity;
  
  /// Check if onboarding is complete (all 3 traits captured)
  bool get isOnboardingComplete => _profile.isOnboardingComplete;
  
  // ============================================================
  // PHASE 44: THE INVESTMENT (Persistence & Transition)
  // ============================================================
  
  /// Finalize onboarding by persisting the profile and marking onboarding complete.
  /// 
  /// This is the "Investment" in Nir Eyal's Hook Model - the user has invested
  /// their time and psychological insights into The Pact. This stored value
  /// makes them more likely to return.
  /// 
  /// Returns true if finalization succeeded.
  Future<bool> finalizeOnboarding() async {
    try {
      if (kDebugMode) {
        debugPrint('PsychometricProvider: Finalizing onboarding...');
        debugPrint('  - hasHolyTrinity: $hasHolyTrinity');
        debugPrint('  - antiIdentityLabel: ${_profile.antiIdentityLabel}');
        debugPrint('  - failureArchetype: ${_profile.failureArchetype}');
        debugPrint('  - resistanceLieLabel: ${_profile.resistanceLieLabel}');
      }
      
      // Ensure profile is saved (redundant but safe - crash recovery)
      await _repository.saveProfile(_profile);
      
      if (kDebugMode) {
        debugPrint('PsychometricProvider: Profile persisted to Hive');
        debugPrint('  - Onboarding finalized: TRUE');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PsychometricProvider: Error finalizing onboarding: $e');
      }
      return false;
    }
  }
  
  /// Check if the profile has enough data to display (for fallback logic)
  bool get hasDisplayableData => _profile.hasDisplayableData;
}
