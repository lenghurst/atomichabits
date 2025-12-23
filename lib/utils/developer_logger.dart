import 'package:flutter/foundation.dart';

/// Developer Logger - Phase 27.17
/// 
/// Centralized logging utility for debugging Voice Coach and AI services.
/// Logs are only active when:
/// 1. App is in debug mode (kDebugMode)
/// 2. Developer Mode is enabled in settings
/// 3. Developer Logging is enabled in settings
/// 
/// Usage:
/// ```dart
/// DevLog.voice('Connecting to WebSocket...');
/// DevLog.token('Fetching ephemeral token from backend');
/// DevLog.audio('Received 1024 bytes of audio data');
/// DevLog.error('Connection failed', details: 'Code: 1006');
/// ```
class DevLog {
  /// Global flag to enable/disable all developer logging
  /// This is set by the app based on settings.developerLogging
  static bool _enabled = false;
  
  /// Enable or disable developer logging globally
  static void setEnabled(bool enabled) {
    _enabled = enabled;
    if (enabled && kDebugMode) {
      debugPrint('═══════════════════════════════════════════════════════════════');
      debugPrint('║  DEVELOPER LOGGING ENABLED - Phase 27.17                     ║');
      debugPrint('║  Voice Coach, Token, Audio, WebSocket logs active            ║');
      debugPrint('═══════════════════════════════════════════════════════════════');
    }
  }
  
  /// Check if logging is enabled
  static bool get isEnabled => _enabled && kDebugMode;
  
  // ═══════════════════════════════════════════════════════════════
  // VOICE COACH LOGGING
  // ═══════════════════════════════════════════════════════════════
  
  /// Log Voice Coach related events
  static void voice(String message, {String? details}) {
    _log('🎙️ VOICE', message, details: details);
  }
  
  /// Log Voice Coach connection phases
  static void voicePhase(String phase, {String? details}) {
    _log('🎙️ PHASE', '[$phase] ${details ?? ''}');
  }
  
  // ═══════════════════════════════════════════════════════════════
  // TOKEN LOGGING
  // ═══════════════════════════════════════════════════════════════
  
  /// Log token-related events
  static void token(String message, {String? details}) {
    _log('🔑 TOKEN', message, details: details);
  }
  
  /// Log token fetch start
  static void tokenFetchStart({bool isRefresh = false}) {
    _log('🔑 TOKEN', isRefresh ? 'Refreshing token...' : 'Fetching new token...');
  }
  
  /// Log token fetch success
  static void tokenFetchSuccess({required String source, DateTime? expiry}) {
    final expiryStr = expiry != null ? ' (expires: ${expiry.toIso8601String()})' : '';
    _log('🔑 TOKEN', '✅ Token obtained from: $source$expiryStr');
  }
  
  /// Log token fetch failure
  static void tokenFetchFailed(String reason) {
    _log('🔑 TOKEN', '❌ Token fetch failed: $reason', isError: true);
  }
  
  // ═══════════════════════════════════════════════════════════════
  // WEBSOCKET LOGGING
  // ═══════════════════════════════════════════════════════════════
  
  /// Log WebSocket events
  static void websocket(String message, {String? details}) {
    _log('🔌 WEBSOCKET', message, details: details);
  }
  
  /// Log WebSocket connection attempt
  static void websocketConnecting(String url) {
    // Mask the token in the URL for security
    final maskedUrl = url.replaceAll(RegExp(r'(key=|access_token=)[^&]+'), r'$1***MASKED***');
    _log('🔌 WEBSOCKET', 'Connecting to: $maskedUrl');
  }
  
  /// Log WebSocket connected
  static void websocketConnected() {
    _log('🔌 WEBSOCKET', '✅ Connected successfully');
  }
  
  /// Log WebSocket message received
  static void websocketMessage(String type, {int? bytes}) {
    final sizeStr = bytes != null ? ' ($bytes bytes)' : '';
    _log('🔌 WEBSOCKET', '← Received: $type$sizeStr');
  }
  
  /// Log WebSocket message sent
  static void websocketSent(String type, {int? bytes}) {
    final sizeStr = bytes != null ? ' ($bytes bytes)' : '';
    _log('🔌 WEBSOCKET', '→ Sent: $type$sizeStr');
  }
  
  /// Log WebSocket closed
  static void websocketClosed({int? code, String? reason}) {
    _log('🔌 WEBSOCKET', '⚠️ Closed - Code: $code, Reason: ${reason ?? 'None'}', isError: code != 1000);
  }
  
  /// Log WebSocket error
  static void websocketError(String error) {
    _log('🔌 WEBSOCKET', '❌ Error: $error', isError: true);
  }
  
  // ═══════════════════════════════════════════════════════════════
  // AUDIO LOGGING
  // ═══════════════════════════════════════════════════════════════
  
  /// Log audio events
  static void audio(String message, {String? details}) {
    _log('🔊 AUDIO', message, details: details);
  }
  
  /// Log audio chunk received
  static void audioReceived(int bytes) {
    _log('🔊 AUDIO', '← Received $bytes bytes');
  }
  
  /// Log audio chunk sent
  static void audioSent(int bytes) {
    _log('🔊 AUDIO', '→ Sent $bytes bytes');
  }
  
  /// Log audio playback start
  static void audioPlaybackStart() {
    _log('🔊 AUDIO', '▶️ Playback started');
  }
  
  /// Log audio playback stop
  static void audioPlaybackStop() {
    _log('🔊 AUDIO', '⏹️ Playback stopped');
  }
  
  /// Log microphone start
  static void microphoneStart() {
    _log('🎤 MIC', '🔴 Recording started');
  }
  
  /// Log microphone stop
  static void microphoneStop() {
    _log('🎤 MIC', '⏹️ Recording stopped');
  }
  
  // ═══════════════════════════════════════════════════════════════
  // SUPABASE LOGGING
  // ═══════════════════════════════════════════════════════════════
  
  /// Log Supabase events
  static void supabase(String message, {String? details}) {
    _log('🗄️ SUPABASE', message, details: details);
  }
  
  /// Log Supabase function call
  static void supabaseFunction(String functionName, {Map<String, dynamic>? params}) {
    final paramsStr = params != null ? ' with params: $params' : '';
    _log('🗄️ SUPABASE', '→ Calling function: $functionName$paramsStr');
  }
  
  /// Log Supabase function response
  static void supabaseFunctionResponse(String functionName, {required int status, String? error}) {
    if (error != null) {
      _log('🗄️ SUPABASE', '← $functionName returned $status: $error', isError: true);
    } else {
      _log('🗄️ SUPABASE', '← $functionName returned $status ✅');
    }
  }
  
  /// Log Supabase auth state
  static void supabaseAuth(String state, {String? userId}) {
    final userStr = userId != null ? ' (user: ${userId.substring(0, 8)}...)' : '';
    _log('🗄️ SUPABASE', 'Auth state: $state$userStr');
  }
  
  // ═══════════════════════════════════════════════════════════════
  // AI MODEL LOGGING
  // ═══════════════════════════════════════════════════════════════
  
  /// Log AI model selection
  static void aiModel(String message, {String? details}) {
    _log('🤖 AI', message, details: details);
  }
  
  /// Log tier selection
  static void aiTierSelected(String tier, {String? reason}) {
    final reasonStr = reason != null ? ' - Reason: $reason' : '';
    _log('🤖 AI', 'Selected tier: $tier$reasonStr');
  }
  
  // ═══════════════════════════════════════════════════════════════
  // ERROR LOGGING
  // ═══════════════════════════════════════════════════════════════
  
  /// Log errors (always visible when developer logging is enabled)
  static void error(String message, {String? details, Object? exception, StackTrace? stackTrace}) {
    _log('❌ ERROR', message, details: details, isError: true);
    if (exception != null && kDebugMode) {
      debugPrint('   Exception: $exception');
    }
    if (stackTrace != null && kDebugMode) {
      debugPrint('   Stack trace:\n$stackTrace');
    }
  }
  
  /// Log warnings
  static void warning(String message, {String? details}) {
    _log('⚠️ WARNING', message, details: details);
  }
  
  // ═══════════════════════════════════════════════════════════════
  // GENERAL LOGGING
  // ═══════════════════════════════════════════════════════════════
  
  /// Log general info
  static void info(String message, {String? details}) {
    _log('ℹ️ INFO', message, details: details);
  }
  
  /// Log debug info (more verbose)
  static void debug(String message, {String? details}) {
    _log('🔍 DEBUG', message, details: details);
  }
  
  // ═══════════════════════════════════════════════════════════════
  // INTERNAL
  // ═══════════════════════════════════════════════════════════════
  
  static void _log(String tag, String message, {String? details, bool isError = false}) {
    if (!_enabled || !kDebugMode) return;
    
    final timestamp = DateTime.now().toIso8601String().substring(11, 23);
    final prefix = '[$timestamp] $tag:';
    
    debugPrint('$prefix $message');
    if (details != null) {
      debugPrint('   └─ $details');
    }
  }
  
  /// Print a separator line for visual clarity
  static void separator({String? label}) {
    if (!_enabled || !kDebugMode) return;
    
    if (label != null) {
      debugPrint('───────────────── $label ─────────────────');
    } else {
      debugPrint('─────────────────────────────────────────────────');
    }
  }
  
  /// Print a summary block
  static void summary(String title, Map<String, dynamic> data) {
    if (!_enabled || !kDebugMode) return;
    
    debugPrint('┌─────────────────────────────────────────────────');
    debugPrint('│ $title');
    debugPrint('├─────────────────────────────────────────────────');
    for (final entry in data.entries) {
      debugPrint('│ ${entry.key}: ${entry.value}');
    }
    debugPrint('└─────────────────────────────────────────────────');
  }
}
