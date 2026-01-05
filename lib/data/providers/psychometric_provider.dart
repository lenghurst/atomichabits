import 'package:flutter/foundation.dart';
import 'dart:convert'; // For jsonDecode
import '../../domain/entities/psychometric_profile.dart';
import '../../domain/entities/psychometric_profile_extensions.dart';
import '../../domain/services/psychometric_engine.dart';
import '../repositories/psychometric_repository.dart';
import '../models/habit.dart';
import '../models/onboarding_data.dart' as onboarding;
// Sensors (Phase 47)
import '../sensors/biometric_sensor.dart';
import '../sensors/digital_truth_sensor.dart';
import '../sensors/environmental_sensor.dart';
import 'package:http/http.dart' as http;
import '../../config/ai_model_config.dart';
import '../repositories/supabase_psychometric_repository.dart';
import '../../core/utils/retry_policy.dart'; // Correct import for RetryPolicy
import 'package:supabase_flutter/supabase_flutter.dart'; // For PostgrestException
import 'dart:io'; // For SocketException

/// PsychometricProvider: Manages the user's psychological profile for LLM context.
/// 
/// This provider holds the PsychometricProfile and coordinates with the PsychometricEngine
/// to update the profile based on user behavior.
/// 
/// Satisfies: Rousselet (Specific Scope), Uncle Bob (DIP).
class PsychometricProvider extends ChangeNotifier {
  final PsychometricRepository _repository; // Hive (Primary)
  final SupabasePsychometricRepository? _cloudRepository; // Supabase (Secondary/Cloud)
  final PsychometricEngine _engine;
  
  PsychometricProfile _profile = PsychometricProfile();
  bool _isLoading = true;

  PsychometricProvider(this._repository, this._engine, {SupabasePsychometricRepository? cloudRepository}) 
      : _cloudRepository = cloudRepository;

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
      // 1. Load Local (Fast)
      final loadedProfile = await _repository.getProfile();
      if (loadedProfile != null) {
        _profile = loadedProfile;
      }
      
      // 2. Sync from Cloud (Async) - Conflict Resolution
      if (_cloudRepository != null) {
        _syncFromCloud();
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('PsychometricProvider: Error initializing: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Internal: Sync from cloud and resolve conflicts
  Future<void> _syncFromCloud() async {
    if (_cloudRepository == null) return;
    
    
    try {
      final cloudProfile = await RetryPolicy.network.execute(
        () => _cloudRepository!.getProfile(),
      );
      if (cloudProfile != null) {
        // Simple Conflict Resolution: Cloud Last Updated Wins if significantly newer
        // Or if local is empty/default.
        final localTime = _profile.lastUpdated;
        final cloudTime = cloudProfile.lastUpdated;
        
        // If cloud is newer by > 1 minute (to avoid jitter loops), adopt cloud
        if (cloudTime.isAfter(localTime.add(const Duration(minutes: 1)))) {
           if (kDebugMode) debugPrint('PsychometricProvider: Cloud profile is newer. Updating local.');
           _profile = cloudProfile;
           await _repository.saveProfile(_profile); // Save to local Hive
           notifyListeners();
        }
      }
    } catch (e) {
    } on PostgrestException catch (e) {
      if (kDebugMode) debugPrint('PsychometricProvider: Cloud sync failed (Postgrest): ${e.message}');
    } on SocketException catch (e) {
      if (kDebugMode) debugPrint('PsychometricProvider: Cloud sync failed (Network): $e');
    } catch (e) {
      debugPrint('PsychometricProvider: Background cloud sync failed: $e');
    }
  }

  /// Internal: Save profile (Local + Async Cloud)
  Future<void> _saveAndSync(PsychometricProfile profile) async {
    _profile = profile;
    
    // 1. Save Local (Blocking for UI consistency)
    await _repository.saveProfile(_profile);
    notifyListeners();
    
    // 2. Sync Cloud (Fire & Forget / Async)
    if (_cloudRepository != null) {
      RetryPolicy.network.execute(
        () => _cloudRepository!.syncToCloud(_profile),
      ).then((_) {
        // Mark as synced locally if successful
        _repository.markAsSynced();
      }).catchError((e) {
         debugPrint('PsychometricProvider: Cloud sync push failed: $e');
         // Will retry on next save/init logic implicitly as isSynced stays false (if we tracked it that way)
      });
    }
  }

  /// Initialize profile from onboarding data
  Future<void> initializeFromOnboarding({
    required String identity,
    required String motivation,
    String? bigWhy,
    List<String>? fears,
  }) async {
    final newProfile = _engine.initializeFromOnboarding(
      identity: identity,
      motivation: motivation,
      bigWhy: bigWhy,
      fears: fears,
    ).copyWith(
      isSynced: false,
      lastUpdated: DateTime.now(),
    );
    await _saveAndSync(newProfile);
  }

  /// Record a habit miss (updates resilience)
  Future<void> recordMiss() async {
    final newProfile = _engine.onHabitMiss(_profile).copyWith(
      isSynced: false, 
      lastUpdated: DateTime.now(),
    );
    await _saveAndSync(newProfile);
  }

  /// Record a habit completion (updates resilience)
  Future<void> recordCompletion({bool wasRecovery = false}) async {
    final newProfile = _engine.onHabitComplete(_profile, wasRecovery: wasRecovery).copyWith(
      isSynced: false, 
      lastUpdated: DateTime.now(),
    );
    await _saveAndSync(newProfile);
  }

  /// Update coaching style preference
  Future<void> setCoachingStyle(CoachingStyle style) async {
    final newProfile = _profile.copyWith(
      coachingStyle: style,
      isSynced: false,
      lastUpdated: DateTime.now(),
    );
    await _saveAndSync(newProfile);
  }

  /// Update verbosity preference
  Future<void> setVerbosityPreference(int level) async {
    final newProfile = _profile.copyWith(
      verbosityPreference: level.clamp(1, 5),
      isSynced: false,
      lastUpdated: DateTime.now(),
    );
    await _saveAndSync(newProfile);
  }

  /// Update core values
  Future<void> setCoreValues(List<String> values) async {
    final newProfile = _profile.copyWith(
      coreValues: values,
      isSynced: false,
      lastUpdated: DateTime.now(),
    );
    await _saveAndSync(newProfile);
  }

  /// Update anti-identities (fears)
  Future<void> setAntiIdentities(List<String> fears) async {
    final newProfile = _profile.copyWith(
      antiIdentities: fears,
      isSynced: false,
      lastUpdated: DateTime.now(),
    );
    await _saveAndSync(newProfile);
  }

  /// Update the big why
  Future<void> setBigWhy(String bigWhy) async {
    final newProfile = _profile.copyWith(
      bigWhy: bigWhy,
      isSynced: false,
      lastUpdated: DateTime.now(),
    );
    await _saveAndSync(newProfile);
  }

  /// Update resonance words (words that motivate)
  Future<void> setResonanceWords(List<String> words) async {
    final newProfile = _profile.copyWith(
      resonanceWords: words,
      isSynced: false,
      lastUpdated: DateTime.now(),
    );
    await _saveAndSync(newProfile);
  }

  /// Update avoid words (words that cause resistance)
  Future<void> setAvoidWords(List<String> words) async {
    final newProfile = _profile.copyWith(
      avoidWords: words,
      isSynced: false,
      lastUpdated: DateTime.now(),
    );
    await _saveAndSync(newProfile);
  }

  /// Recalibrate risks based on habit history (call periodically)
  /// Uses Isolate for heavy O(N) computation per Muratori's recommendation.
  Future<void> recalibrateRisks(List<Habit> habits) async {
    var updatedProfile = await _engine.recalibrateRisksAsync(_profile, habits);
    
    // Also update peak energy window
    final peakWindow = await _engine.calculatePeakEnergyWindowAsync(habits);
    updatedProfile = updatedProfile.copyWith(
      peakEnergyWindow: peakWindow,
      isSynced: false,
      lastUpdated: DateTime.now(),
    );
    
    await _saveAndSync(updatedProfile);
  }

  /// Update profile based on chat feedback
  Future<void> updateFromChatFeedback({
    required String userMessage,
    required bool wasPositiveResponse,
  }) async {
    final newProfile = _engine.updateFromChatFeedback(
      _profile,
      userMessage: userMessage,
      wasPositiveResponse: wasPositiveResponse,
    );
    await _saveAndSync(newProfile);
  }

  /// Clear all psychometric data
  Future<void> clear() async {
    _profile = PsychometricProfile();
    await _repository.clear();
    // Cloud clear ?? Maybe not.
    notifyListeners();
  }
  
  // ============================================================
  // PHASE 42: TOOL CALL HANDLERS (Sherlock Protocol)
  // ============================================================
  
  /// Update profile from AI tool call arguments.
  Future<void> updateFromToolCall(Map<String, dynamic> args) async {
    if (kDebugMode) {
      debugPrint('PsychometricProvider: Received tool call with args: $args');
    }
    
    // Build the update using only the fields that were provided
    final newProfile = _profile.copyWith(
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
          
      isSynced: false,
      lastUpdated: DateTime.now(),
    );
    
    // CRITICAL: Save immediately (crash recovery)
    await _saveAndSync(newProfile);
    
    if (kDebugMode) {
      debugPrint('PsychometricProvider: Profile saved. Onboarding complete: ${_profile.isOnboardingComplete}');
    }
  }
  
  /// Update profile from OnboardingData (Text Chat flow)
  Future<void> updateFromOnboardingData(onboarding.OnboardingData data) async {
    _profile = _profile.copyWith(
      antiIdentityLabel: data.antiIdentityLabel ?? _profile.antiIdentityLabel,
      failureArchetype: data.failureArchetype ?? _profile.failureArchetype,
      resistanceLieLabel: data.resistanceLieLabel ?? _profile.resistanceLieLabel,
    );
    await _repository.saveProfile(_profile);
    notifyListeners();
  }

  /// Log refusal to grant "Sherlock Sensors" as a psychometric trait.
  /// 
  /// The user's refusal to share data is itself a data point (The Refusal Protocol).
  /// We log *what* was refused (e.g. 'calendar', 'youtube') without immediately
  /// assigning a prescriptive archetype.
  Future<void> logPermissionRefusal(String scope) async {
    // Append to declined permissions if not already present
    if (!_profile.declinedPermissions.contains(scope)) {
      final updatedRefusals = List<String>.from(_profile.declinedPermissions)..add(scope);
      _profile = _profile.copyWith(
        declinedPermissions: updatedRefusals,
      );
      await _repository.saveProfile(_profile);
      notifyListeners();
    }
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

  // ============================================================
  // DEFERRED INTELLIGENCE (Phase 58)
  // ============================================================
  /// Analyze the full session transcript to extract psychometric traits.
  /// 
  /// This replaces the live tool calls that were causing "Reasoning Lock".
  /// It runs AFTER the voice session is complete.
  Future<void> analyzeTranscript(List<Map<String, String>> transcript) async {
    if (transcript.isEmpty) {
      if (kDebugMode) debugPrint('PsychometricProvider: Empty transcript, skipping analysis.');
      return;
    }
    if (kDebugMode) debugPrint('PsychometricProvider: Analyzing ${transcript.length} turns via DeepSeek V3...');
    
    try {
      // 1. Construct Prompt
      final buffer = StringBuffer();
      buffer.writeln("Analyze this specialized coaching session transcript and extract the user's psychometric profile.");
      buffer.writeln("Return ONLY a JSON object with the following schema:");
      buffer.writeln("{");
      buffer.writeln('  "anti_identity_label": "The specific identity they fear becoming (e.g. The Drifter, The Skeptic)",');
      buffer.writeln('  "anti_identity_context": "Why they fear this (1 sentence)",');
      buffer.writeln('  "failure_archetype": "Their specific failure pattern (e.g. Perfectionism, Procrastination, Overthinking)",');
      buffer.writeln('  "failure_trigger_context": "What triggers this failure (1 sentence)",');
      buffer.writeln('  "resistance_lie_label": "The lie they tell themselves to avoid change (e.g. I\'ll do it tomorrow, I need more research)",');
      buffer.writeln('  "resistance_lie_context": "The deeper truth behind the lie (1 sentence)",');
      buffer.writeln('  "inferred_fears": ["fear 1", "fear 2"]');
      buffer.writeln("}");
      buffer.writeln("\nTRANSCRIPT:");
      
      for (final turn in transcript) {
        buffer.writeln("${turn['role']?.toUpperCase()}: ${turn['content']}");
      }
      // 2. Call DeepSeek V3 (REST API)
      final url = Uri.parse('https://api.deepseek.com/chat/completions');
      
      final payload = {
        'model': 'deepseek-chat',
        'messages': [
          {'role': 'system', 'content': 'You are an expert psychometrician. Extract the personality profile from the transcript. Return JSON only.'},
          {'role': 'user', 'content': buffer.toString()}
        ],
        'response_format': {'type': 'json_object'},
        'temperature': 1.0, // Recommended for DeepSeek V3
        'stream': false,
      };
      if (kDebugMode) debugPrint('PsychometricProvider: Sending request to DeepSeek...');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AIModelConfig.deepSeekApiKey}',
        },
        body: jsonEncode(payload),
      );
      if (response.statusCode != 200) {
        throw Exception('DeepSeek API Error: ${response.statusCode} ${response.body}');
      }
      // 3. Parse JSON Response
      final responseBody = jsonDecode(response.body);
      final content = responseBody['choices'][0]['message']['content'] as String;
      
      if (kDebugMode) debugPrint('PsychometricProvider: Analysis complete. Parsing JSON...');
      
      // Clean potential markedown fences just in case
      final cleanJson = content.replaceAll('```json', '').replaceAll('```', '').trim();
      final Map<String, dynamic> data = jsonDecode(cleanJson);
      
      if (kDebugMode) {
        debugPrint('PsychometricProvider: Extracted Data: $data');
      }
      
      // 4. Update Profile
      await updateFromToolCall(data);
      
    } catch (e) {
      if (kDebugMode) debugPrint('PsychometricProvider: Analysis failed: $e');
      // Non-blocking failure - we prefer to proceed with partial data than crash
    }
  }
  
  /// Check if the profile has enough data to display (for fallback logic)
  bool get hasDisplayableData => _profile.hasDisplayableData;

  // ============================================================
  // PHASE 47: SENSOR FUSION (Sherlock Expansion)
  // ============================================================
  /// Syncs data from all Sherlock sensors (Biometric, Digital Truth, etc.)
  /// and updates the psychometric profile accordingly.
  Future<void> syncSensors() async {
    if (kDebugMode) debugPrint('PsychometricProvider: Syncing Sherlock Sensors...');
    
    // 1. Initialize sensors
    final bioSensor = BiometricSensor();
    final truthSensor = DigitalTruthSensor();
    final envSensor = EnvironmentalSensor();
    
    await bioSensor.initialize();
    await envSensor.initialize();
    
    // 2. Fetch Data
    
    // Biometrics
    int? sleepMinutes;
    double? hrv;
    try {
      sleepMinutes = await bioSensor.getLastNightSleepMinutes();
      hrv = await bioSensor.getLatestHRV();
      // Filter out invalid/empty (-1)
      if (sleepMinutes == -1) sleepMinutes = null;
      if (hrv == -1) hrv = null;
    } catch (e) {
      debugPrint('PsychometricProvider: Error fetching biometrics: $e');
    }
    
    // Digital Truth (App Usage)
    int? distractionMinutes;
    try {
      if (truthSensor.isSupported) {
        distractionMinutes = await truthSensor.getDopamineBurnMinutes();
      }
    } catch (e) {
      debugPrint('PsychometricProvider: Error fetching digital truth: $e');
    }
    
    // 3. Update Profile via Engine
    _profile = _engine.updateFromSensorData(
      _profile,
      sleepMinutes: sleepMinutes,
      hrv: hrv,
      distractionMinutes: distractionMinutes,
    );
    
    // 4. Persist
    await _saveAndSync(_profile);
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('PsychometricProvider: Sensor Sync Complete.');
      debugPrint('  - Sleep: $sleepMinutes min');
      debugPrint('  - HRV: $hrv');
      debugPrint('  - Distraction: $distractionMinutes min');
      debugPrint('  - New Resilience: ${_profile.resilienceScore}');
    }
  }
}
