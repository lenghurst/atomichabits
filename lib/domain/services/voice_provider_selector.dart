import 'package:http/http.dart' as http;
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
  static const int _timeoutMs = 5000;

  Future<VoiceProviderRecommendation> runDiagnostics() async {
    LogBuffer.instance.addLog('Running voice provider diagnostics...');

    // 1. Check Capabilities based on Keys
    final geminiKey = AIModelConfig.hasGeminiKey;
    final openAiKey = AIModelConfig.hasOpenAiKey;

    int geminiLatency = -1;
    int openAiLatency = -1;

    // 2. Test OpenAI Latency (if key exists)
    if (openAiKey) {
      openAiLatency = await _measureLatency(
        'https://api.openai.com/v1/models', 
        'OpenAI'
      );
    }

    // 3. Test Gemini Latency (if key exists)
    if (geminiKey) {
      // Using a reliable Google endpoint for latency proxy if specific API is auth-blocked on HEAD
      geminiLatency = await _measureLatency(
        'https://generativelanguage.googleapis.com', 
        'Gemini'
      );
    }

    // 4. Determine Winner
    String recommended = 'gemini'; // Default fallback
    
    // Logic: vital to have a key. If both have keys, pick lowest latency or config preference.
    if (openAiKey && !geminiKey) {
      recommended = 'openai';
    } else if (geminiKey && !openAiKey) {
      recommended = 'gemini';
    } else if (geminiKey && openAiKey) {
      // Both available.
      // If one failed connection (latency -1), pick the other.
      if (openAiLatency == -1 && geminiLatency != -1) {
        recommended = 'gemini';
      } else if (geminiLatency == -1 && openAiLatency != -1) {
        recommended = 'openai';
      } else {
        // Both responsive. Use config preference or latency?
        // Current logic: Stick to config per user choice, unless "Automatic" mode (future)
        // For now, let's respect the hard setting if explicit, otherwise bias to Gemini for cost?
        // Actually, let's stick to the current simplified logic: Config is king, but metrics are useful.
        if (AIModelConfig.voiceProvider == 'openai') {
          recommended = 'openai';
        } else {
          recommended = 'gemini';
        }
      }
    }

    LogBuffer.instance.addLog('Diagnostics complete. Recommended: $recommended');

    return VoiceProviderRecommendation(
      provider: recommended,
      metrics: {
        'gemini_available': geminiKey,
        'openai_available': openAiKey,
        'gemini_latency_ms': geminiLatency,
        'openai_latency_ms': openAiLatency,
      },
      timestamp: DateTime.now(),
    );
  }

  Future<int> _measureLatency(String url, String label) async {
    final stopwatch = Stopwatch()..start();
    try {
      // Use HEAD request for minimal overhead, or GET if HEAD not allowed
      await http.head(Uri.parse(url)).timeout(const Duration(milliseconds: _timeoutMs));
      stopwatch.stop();
      final ms = stopwatch.elapsedMilliseconds;
      LogBuffer.instance.addLog('✅ $label RTT: ${ms}ms');
      return ms;
    } catch (e) {
      stopwatch.stop();
      LogBuffer.instance.addLog('❌ $label Ping Failed: $e');
      return -1;
    }
  }
}
