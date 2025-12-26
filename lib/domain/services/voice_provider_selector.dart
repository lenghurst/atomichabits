import '../../config/ai_model_config.dart';
import '../../core/logging/log_buffer.dart';

class VoiceProviderRecommendation {
  final String provider;
  final Map<String, dynamic> metrics;
  final DateTime timestamp;

  VoiceProviderRecommendation({
    required this.provider,
    required this.metrics,
    required this.timestamp,
  });
}

class VoiceProviderSelector {
  Future<VoiceProviderRecommendation> runDiagnostics() async {
    // This is a placeholder for the actual comparative test logic.
    // In a real implementation, it would instantiate both services,
    // run a short test, measure latency/success, and return a recommendation.

    LogBuffer.instance.addLog('Running voice provider diagnostics...');

    // Simulate test
    await Future.delayed(const Duration(seconds: 1));

    final geminiAvailable = AIModelConfig.hasGeminiKey;
    final openAiAvailable = AIModelConfig.hasOpenAiKey;

    String recommended = 'gemini';
    if (geminiAvailable && !openAiAvailable) {
      recommended = 'gemini';
    } else if (!geminiAvailable && openAiAvailable) {
      recommended = 'openai';
    } else if (geminiAvailable && openAiAvailable) {
      // Preference logic here
      if (AIModelConfig.voiceProvider == 'openai') {
        recommended = 'openai';
      }
    }

    return VoiceProviderRecommendation(
      provider: recommended,
      metrics: {
        'gemini_available': geminiAvailable,
        'openai_available': openAiAvailable,
      },
      timestamp: DateTime.now(),
    );
  }
}
