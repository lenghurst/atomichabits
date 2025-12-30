import 'package:flutter/foundation.dart';
import '../providers/psychometric_provider.dart'; 
import '../../domain/entities/psychometric_profile.dart';

class PsychometricExtractionService {
  final PsychometricProvider _provider;
  final String? _debugUserId; // Optional for logging/future use

  PsychometricExtractionService(this._provider, {String? debugUserId}) 
      : _debugUserId = debugUserId;

  /// Analyzes transcript for psychological patterns
  /// This is ASYNC (fire-and-forget) - doesn't block voice note flow
  Future<void> analyzeTranscript({
    required String transcript,
    required String userId,
  }) async {
    try {
      // Skip analysis for very short transcripts (e.g. "Create habit")
      if (transcript.trim().split(' ').length < 4) {
        if (kDebugMode) debugPrint('PsychometricExtractionService: Skipping analysis (transcript too short)');
        return;
      }
      
      if (kDebugMode) {
        debugPrint('PsychometricExtractionService: Analyzing transcript for user $userId...');
      }

      // Delegate to the provider (which handles DeepSeek call & State update)
      // The provider internally calculates a partial profile
      await _provider.analyzeTranscript([
        {'role': 'user', 'content': transcript}
      ]);
      
      // Note: analyzeTranscript() in provider already updates the profile and notifies listeners.
      // We don't need to manually save insights here as the provider does it.
      
      if (kDebugMode) {
        debugPrint('✅ PsychometricExtractionService: Analysis complete & Profile updated.');
      }
    } catch (e) {
      // Fail silently - psychometrics shouldn't break voice notes
      if (kDebugMode) debugPrint('⚠️ PsychometricExtractionService: Analysis failed: $e');
    }
  }
}
