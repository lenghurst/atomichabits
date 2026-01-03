import 'package:http/http.dart' as http;
import '../../config/ai_model_config.dart';
import '../../core/logging/log_buffer.dart';
import '../../data/enums/voice_session_type.dart';

class VoiceProviderRecommendation {
  final String provider;
  final Map<String, dynamic> metrics;
  final DateTime timestamp;
  final String? reason;

  VoiceProviderRecommendation({
    required this.provider,
    required this.metrics,
    required this.timestamp,
    this.reason,
  });
}

class VoiceProviderSelector {
  static const int _timeoutMs = 5000;

  /// Phase 65: Hybrid Voice Provider Routing
  ///
  /// Selects the optimal voice provider based on session type.
  ///
  /// Routing Logic:
  /// - Emotion-critical sessions (sherlock, toughTruths) → OpenAI Realtime API
  ///   - Explicit emotion metadata in JSON responses
  ///   - Better for detecting defensiveness, shadow parts
  ///   - Trade-off: ~$0.06/min
  ///
  /// - Cost-efficient sessions (oracle, coaching) → Gemini Live API
  ///   - Token-based pricing (cheaper for longer sessions)
  ///   - Adequate for cognitive/planning conversations
  ///
  /// Fallback: If preferred provider unavailable, falls back to the other.
  VoiceProviderRecommendation selectForSession({
    required VoiceSessionType sessionType,
    bool forceOpenAI = false,
    bool forceGemini = false,
  }) {
    final hasOpenAI = AIModelConfig.hasOpenAiKey;
    final hasGemini = AIModelConfig.hasGeminiKey;

    // Honor force flags first
    if (forceOpenAI && hasOpenAI) {
      LogBuffer.instance.addLog('🎯 Provider forced to OpenAI');
      return VoiceProviderRecommendation(
        provider: 'openai',
        metrics: {'forced': true, 'session_type': sessionType.name},
        timestamp: DateTime.now(),
        reason: 'Forced by user/config',
      );
    }
    if (forceGemini && hasGemini) {
      LogBuffer.instance.addLog('🎯 Provider forced to Gemini');
      return VoiceProviderRecommendation(
        provider: 'gemini',
        metrics: {'forced': true, 'session_type': sessionType.name},
        timestamp: DateTime.now(),
        reason: 'Forced by user/config',
      );
    }

    // Session-based routing
    final prefersOpenAI = sessionType.prefersOpenAI;
    final reason = sessionType.providerReason;

    if (prefersOpenAI) {
      // Prefer OpenAI for emotion-critical sessions
      if (hasOpenAI) {
        LogBuffer.instance.addLog('🎭 ${sessionType.name}: Using OpenAI ($reason)');
        return VoiceProviderRecommendation(
          provider: 'openai',
          metrics: {
            'session_type': sessionType.name,
            'prefers_openai': true,
            'has_openai': hasOpenAI,
            'has_gemini': hasGemini,
          },
          timestamp: DateTime.now(),
          reason: reason,
        );
      } else if (hasGemini) {
        // Fallback to Gemini
        LogBuffer.instance.addLog('⚠️ ${sessionType.name}: OpenAI preferred but unavailable, using Gemini');
        return VoiceProviderRecommendation(
          provider: 'gemini',
          metrics: {
            'session_type': sessionType.name,
            'prefers_openai': true,
            'fallback': true,
          },
          timestamp: DateTime.now(),
          reason: 'OpenAI unavailable, fallback to Gemini',
        );
      }
    } else {
      // Prefer Gemini for cost-efficient sessions
      if (hasGemini) {
        LogBuffer.instance.addLog('💰 ${sessionType.name}: Using Gemini ($reason)');
        return VoiceProviderRecommendation(
          provider: 'gemini',
          metrics: {
            'session_type': sessionType.name,
            'prefers_openai': false,
            'has_openai': hasOpenAI,
            'has_gemini': hasGemini,
          },
          timestamp: DateTime.now(),
          reason: reason,
        );
      } else if (hasOpenAI) {
        // Fallback to OpenAI
        LogBuffer.instance.addLog('⚠️ ${sessionType.name}: Gemini preferred but unavailable, using OpenAI');
        return VoiceProviderRecommendation(
          provider: 'openai',
          metrics: {
            'session_type': sessionType.name,
            'prefers_openai': false,
            'fallback': true,
          },
          timestamp: DateTime.now(),
          reason: 'Gemini unavailable, fallback to OpenAI',
        );
      }
    }

    // No providers available
    LogBuffer.instance.addLog('❌ No voice providers available');
    return VoiceProviderRecommendation(
      provider: 'none',
      metrics: {'error': 'No voice providers configured'},
      timestamp: DateTime.now(),
      reason: 'No API keys configured',
    );
  }

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
