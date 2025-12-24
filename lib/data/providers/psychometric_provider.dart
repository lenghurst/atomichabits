import 'package:flutter/foundation.dart';
import '../../domain/entities/psychometric_profile.dart';
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
  
  PsychometricProfile _profile = const PsychometricProfile();
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
    );
    await _repository.saveProfile(_profile);
    notifyListeners();
  }

  /// Record a habit miss (updates resilience)
  Future<void> recordMiss() async {
    _profile = _engine.onHabitMiss(_profile);
    await _repository.saveProfile(_profile);
    notifyListeners();
  }

  /// Record a habit completion (updates resilience)
  Future<void> recordCompletion({bool wasRecovery = false}) async {
    _profile = _engine.onHabitComplete(_profile, wasRecovery: wasRecovery);
    await _repository.saveProfile(_profile);
    notifyListeners();
  }

  /// Update coaching style preference
  Future<void> setCoachingStyle(CoachingStyle style) async {
    _profile = _profile.copyWith(coachingStyle: style);
    await _repository.saveProfile(_profile);
    notifyListeners();
  }

  /// Update verbosity preference
  Future<void> setVerbosityPreference(int level) async {
    _profile = _profile.copyWith(verbosityPreference: level.clamp(1, 5));
    await _repository.saveProfile(_profile);
    notifyListeners();
  }

  /// Update core values
  Future<void> setCoreValues(List<String> values) async {
    _profile = _profile.copyWith(coreValues: values);
    await _repository.saveProfile(_profile);
    notifyListeners();
  }

  /// Update anti-identities (fears)
  Future<void> setAntiIdentities(List<String> fears) async {
    _profile = _profile.copyWith(antiIdentities: fears);
    await _repository.saveProfile(_profile);
    notifyListeners();
  }

  /// Update the big why
  Future<void> setBigWhy(String bigWhy) async {
    _profile = _profile.copyWith(bigWhy: bigWhy);
    await _repository.saveProfile(_profile);
    notifyListeners();
  }

  /// Update resonance words (words that motivate)
  Future<void> setResonanceWords(List<String> words) async {
    _profile = _profile.copyWith(resonanceWords: words);
    await _repository.saveProfile(_profile);
    notifyListeners();
  }

  /// Update avoid words (words that cause resistance)
  Future<void> setAvoidWords(List<String> words) async {
    _profile = _profile.copyWith(avoidWords: words);
    await _repository.saveProfile(_profile);
    notifyListeners();
  }

  /// Recalibrate risks based on habit history (call periodically)
  Future<void> recalibrateRisks(List<Habit> habits) async {
    _profile = _engine.recalibrateRisks(_profile, habits);
    
    // Also update peak energy window
    final peakWindow = _engine.calculatePeakEnergyWindow(habits);
    _profile = _profile.copyWith(peakEnergyWindow: peakWindow);
    
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
    _profile = const PsychometricProfile();
    await _repository.clear();
    notifyListeners();
  }
}
