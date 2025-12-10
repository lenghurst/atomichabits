import 'package:flutter/foundation.dart';

/// API Configuration for Premium AI Features
///
/// Manages API keys for:
/// - Claude API (conversational AI)
/// - ElevenLabs (voice synthesis)
///
/// SECURITY NOTE:
/// In production, these should be:
/// 1. Stored securely (not in code)
/// 2. Loaded from environment variables or secure storage
/// 3. Proxied through your backend (never expose keys in client)
///
/// For development/testing, you can set keys here temporarily.
class ApiConfig {
  // Singleton instance
  static final ApiConfig _instance = ApiConfig._internal();
  static ApiConfig get instance => _instance;

  ApiConfig._internal();

  // API Keys - Set these for development
  // In production, load from secure storage or backend
  String _claudeApiKey = '';
  String _elevenLabsApiKey = '';

  // Voice configuration
  String _voiceId = 'EXAVITQu4vr4xnSDxMaL'; // Sarah - warm coach

  /// Claude API key for conversational AI
  String get claudeApiKey => _claudeApiKey;

  /// ElevenLabs API key for voice synthesis
  String get elevenLabsApiKey => _elevenLabsApiKey;

  /// Selected voice ID for ElevenLabs
  String get voiceId => _voiceId;

  /// Whether premium AI features are available
  bool get isPremiumAvailable =>
      _claudeApiKey.isNotEmpty && _elevenLabsApiKey.isNotEmpty;

  /// Whether voice is available
  bool get isVoiceAvailable => _elevenLabsApiKey.isNotEmpty;

  /// Configure API keys
  /// Call this during app initialization
  void configure({
    String? claudeApiKey,
    String? elevenLabsApiKey,
    String? voiceId,
  }) {
    if (claudeApiKey != null) _claudeApiKey = claudeApiKey;
    if (elevenLabsApiKey != null) _elevenLabsApiKey = elevenLabsApiKey;
    if (voiceId != null) _voiceId = voiceId;

    if (kDebugMode) {
      debugPrint('API Config updated:');
      debugPrint('  Claude: ${_claudeApiKey.isNotEmpty ? "configured" : "not set"}');
      debugPrint('  ElevenLabs: ${_elevenLabsApiKey.isNotEmpty ? "configured" : "not set"}');
      debugPrint('  Voice ID: $_voiceId');
    }
  }

  /// Load keys from environment (for CI/CD or secure builds)
  void loadFromEnvironment() {
    // These would typically come from dart-define or .env
    const claudeKey = String.fromEnvironment('CLAUDE_API_KEY');
    const elevenLabsKey = String.fromEnvironment('ELEVENLABS_API_KEY');
    const voice = String.fromEnvironment('ELEVENLABS_VOICE_ID');

    if (claudeKey.isNotEmpty) _claudeApiKey = claudeKey;
    if (elevenLabsKey.isNotEmpty) _elevenLabsApiKey = elevenLabsKey;
    if (voice.isNotEmpty) _voiceId = voice;
  }

  /// Clear all keys (for logout/security)
  void clear() {
    _claudeApiKey = '';
    _elevenLabsApiKey = '';
  }
}

/// Voice presets for different coaching styles
class VoicePresets {
  /// Warm, professional female coach (recommended)
  static const String warmCoach = 'EXAVITQu4vr4xnSDxMaL'; // Sarah

  /// Calm, soothing female (good for mindfulness habits)
  static const String calmGuide = '21m00Tcm4TlvDq8ikWAM'; // Rachel

  /// Confident male coach (good for fitness habits)
  static const String motivator = 'pNInz6obpgDQGcFmaJgB'; // Adam

  /// Friendly British male (good for intellectual habits)
  static const String scholarly = 'ErXwobaYiN019PkySvjV'; // Antoni
}
