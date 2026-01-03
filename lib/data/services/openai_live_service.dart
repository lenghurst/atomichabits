import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

import '../../config/ai_model_config.dart';
import '../../core/logging/app_logger.dart';
import 'voice_api_service.dart';

/// Phase 65: Emotion metadata from OpenAI Realtime API (2025)
///
/// OpenAI's Realtime API provides explicit emotion metadata in JSON responses,
/// unlike other providers that require inference from audio analysis.
class EmotionMetadata {
  /// Primary detected emotion (e.g., "joy", "sadness", "anger", "fear", "surprise")
  final String? primaryEmotion;

  /// Confidence score for primary emotion (0.0 - 1.0)
  final double? confidence;

  /// Detected tone (e.g., "assertive", "hesitant", "defensive", "open")
  final String? tone;

  /// Speech emphasis indicators (e.g., words with increased emphasis)
  final List<String>? emphasizedWords;

  /// Secondary emotions detected
  final Map<String, double>? secondaryEmotions;

  /// Raw metadata from API
  final Map<String, dynamic>? rawMetadata;

  EmotionMetadata({
    this.primaryEmotion,
    this.confidence,
    this.tone,
    this.emphasizedWords,
    this.secondaryEmotions,
    this.rawMetadata,
  });

  factory EmotionMetadata.fromJson(Map<String, dynamic> json) {
    return EmotionMetadata(
      primaryEmotion: json['primary_emotion'] as String? ?? json['emotion'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      tone: json['tone'] as String?,
      emphasizedWords: (json['emphasized_words'] as List<dynamic>?)?.cast<String>(),
      secondaryEmotions: (json['secondary_emotions'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, (v as num).toDouble()),
      ),
      rawMetadata: json,
    );
  }

  @override
  String toString() => 'EmotionMetadata(primary: $primaryEmotion, confidence: $confidence, tone: $tone)';
}

/// OpenAI Live API Service
///
/// Implements Realtime API using WebSocket.
/// Endpoint: wss://api.openai.com/v1/realtime?model=...
/// Docs: https://platform.openai.com/docs/guides/realtime
///
/// Phase 65: Hybrid Voice Provider Routing
/// - Used for emotion-critical sessions (sherlock, toughTruths)
/// - Provides explicit emotion metadata in JSON responses
/// - Trade-off: ~$0.06/min vs Gemini's token-based pricing
class OpenAILiveService implements VoiceApiService {
  /// OpenAI Realtime API model
  ///
  /// Phase 65: Updated for 2025 API
  /// - Preview: gpt-4o-realtime-preview-2024-10-01
  /// - Production (when available): gpt-4o-realtime-2025-xx-xx
  ///
  /// The model can be configured via AIModelConfig for easy updates.
  static const String _defaultModel = 'gpt-4o-realtime-preview-2024-10-01';

  /// Get the model to use (allows for future config-based selection)
  static String get _model => AIModelConfig.openAiRealtimeModel.isNotEmpty
      ? AIModelConfig.openAiRealtimeModel
      : _defaultModel;

  static String get _wsUrl => 'wss://api.openai.com/v1/realtime?model=$_model';

  // === STATE ===
  WebSocketChannel? _channel;
  bool _isConnected = false;
  bool _isListening = false;
  String? _sessionId;

  // === CALLBACKS ===
  final void Function(Uint8List)? onAudioReceived;
  final void Function(String, bool)? onTranscription;
  final void Function(bool)? onModelSpeakingChanged;
  final void Function(String)? onError;
  final void Function(String toolName, Map<String, dynamic> args, String callId)? onToolCall;
  final void Function(List<String> log)? onDebugLogUpdated;

  /// Phase 65: Emotion metadata callback
  ///
  /// Called when OpenAI provides emotion metadata for the user's speech.
  /// This is a key differentiator from Gemini - explicit emotion data vs inference.
  final void Function(EmotionMetadata)? onEmotionDetected;

  /// Phase 65: Accumulated emotion data for the current turn
  EmotionMetadata? _lastEmotionMetadata;

  final List<String> _debugLog = [];

  OpenAILiveService({
    this.onAudioReceived,
    this.onTranscription,
    this.onModelSpeakingChanged,
    this.onError,
    this.onToolCall,
    this.onDebugLogUpdated,
    this.onEmotionDetected,
  });

  /// Get the last detected emotion metadata (for post-processing)
  EmotionMetadata? get lastEmotionMetadata => _lastEmotionMetadata;

  @override
  bool get isConnected => _isConnected;

  @override
  @override
  bool get isListening => _isListening;

  void _addDebugLog(String entry, {bool isError = false}) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    _debugLog.add('[$timestamp] $entry');
    if (_debugLog.length > 100) _debugLog.removeAt(0);
    onDebugLogUpdated?.call(_debugLog);
    if (isError) AppLogger.error(entry); else AppLogger.info(entry);
  }

  @override
  void clearDebugLog() {
    _debugLog.clear();
    onDebugLogUpdated?.call(_debugLog);
  }

  @override
  Future<bool> connect({
    String? systemInstruction,
    bool enableTranscription = true,
    Map<String, dynamic>? tools,
  }) async {
    if (_isConnected) return true;

    _addDebugLog('🚀 Connecting to OpenAI Realtime API...');

    if (!AIModelConfig.hasOpenAiKey) {
      _addDebugLog('❌ No OpenAI API Key found', isError: true);
      onError?.call('No OpenAI API Key found');
      return false;
    }

    try {
      final headers = {
        'Authorization': 'Bearer ${AIModelConfig.openAiApiKey}',
        'OpenAI-Beta': 'realtime=v1',
      };

      _channel = IOWebSocketChannel.connect(Uri.parse(_wsUrl), headers: headers);
      await _channel!.ready;

      _channel!.stream.listen(
        _handleMessage,
        onError: (e) {
          _addDebugLog('❌ WebSocket Error: $e', isError: true);
          onError?.call('WebSocket Error: $e');
          _disconnect();
        },
        onDone: () {
          _addDebugLog('🔌 WebSocket Closed');
          _disconnect();
        },
      );

      _isConnected = true;
      _addDebugLog('✅ Connected to OpenAI');

      // Send Session Update to configure
      await _sendSessionUpdate(systemInstruction, tools);

      return true;
    } catch (e) {
      _addDebugLog('❌ Connection failed: $e', isError: true);
      onError?.call('Connection failed: $e');
      return false;
    }
  }

  Future<void> _sendSessionUpdate(String? instructions, Map<String, dynamic>? tools) async {
    // Map Gemini tools to OpenAI tools format if needed, or assume compatible structure
    // OpenAI expects "tools": [{ "type": "function", "name": "...", "description": "...", "parameters": {...} }]
    // Gemini uses "functionDeclarations": [...]

    List<Map<String, dynamic>> openAiTools = [];
    if (tools != null && tools.containsKey('functionDeclarations')) {
      final funcs = tools['functionDeclarations'] as List;
      for (final f in funcs) {
        openAiTools.add({
          'type': 'function',
          'name': f['name'],
          'description': f['description'],
          'parameters': f['parameters'],
        });
      }
    }

    final event = {
      'type': 'session.update',
      'session': {
        'modalities': ['text', 'audio'],
        'instructions': instructions ?? 'You are a helpful assistant.',
        'voice': 'alloy', // or echo, shimmer
        'input_audio_format': 'pcm16',
        'output_audio_format': 'pcm16',
        'turn_detection': {
           'type': 'server_vad',
        },
        if (openAiTools.isNotEmpty) 'tools': openAiTools,
        'tool_choice': 'auto',
      }
    };

    _sendJson(event);
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String);
      final type = data['type'] as String?;

      switch (type) {
        case 'session.created':
          _sessionId = data['session']['id'];
          _addDebugLog('Session Created: $_sessionId');
          _addDebugLog('Model: $_model');
          break;

        case 'response.audio.delta':
          final base64Audio = data['delta'] as String;
          final bytes = base64Decode(base64Audio);
          onAudioReceived?.call(bytes);
          onModelSpeakingChanged?.call(true);
          break;

        case 'response.audio_transcript.delta':
           // OpenAI sends incremental transcript
           final delta = data['delta'] as String;
           onTranscription?.call(delta, false);
           break;

        // Phase 65: Handle emotion/sentiment metadata from OpenAI 2025 API
        case 'input_audio_buffer.speech_started':
           _addDebugLog('🎤 Speech started');
           break;

        case 'input_audio_buffer.speech_stopped':
           _addDebugLog('🎤 Speech stopped');
           break;

        case 'conversation.item.input_audio_transcription.completed':
           // Final transcription with potential emotion metadata
           final transcript = data['transcript'] as String?;
           if (transcript != null) {
             onTranscription?.call(transcript, true);
           }

           // Phase 65: Extract emotion metadata if present (2025 API feature)
           _extractEmotionMetadata(data);
           break;

        // Phase 65: Dedicated emotion event (anticipated 2025 API)
        case 'response.audio.emotion':
        case 'input_audio_buffer.emotion':
           _handleEmotionEvent(data);
           break;

        case 'response.function_call_arguments.done':
           // Handle tool call
           final callId = data['call_id'];
           final name = data['name'];
           final args = jsonDecode(data['arguments']);
           _addDebugLog('🔧 Tool Call: $name');
           onToolCall?.call(name, args, callId);
           break;

        case 'response.done':
           onModelSpeakingChanged?.call(false);
           // Log emotion summary for this turn
           if (_lastEmotionMetadata != null) {
             _addDebugLog('🎭 Turn emotion: ${_lastEmotionMetadata!.primaryEmotion} (${_lastEmotionMetadata!.tone})');
           }
           break;

        case 'error':
           final err = data['error'];
           _addDebugLog('❌ OpenAI Error: ${err['message']}', isError: true);
           onError?.call(err['message'] as String? ?? 'Unknown error');
           break;

        default:
           // Log unknown event types for debugging new API features
           if (kDebugMode && type != null) {
             AppLogger.debug('[OpenAI] Unhandled event type: $type');
           }
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.debug('[OpenAI] Parse error: $e');
      }
    }
  }

  /// Phase 65: Extract emotion metadata from transcription or audio events
  void _extractEmotionMetadata(Map<String, dynamic> data) {
    // Check for emotion data in various possible locations
    final emotionData = data['emotion'] ??
        data['metadata']?['emotion'] ??
        data['audio_metadata']?['emotion'] ??
        data['sentiment'];

    if (emotionData is Map<String, dynamic>) {
      _lastEmotionMetadata = EmotionMetadata.fromJson(emotionData);
      _addDebugLog('🎭 Emotion detected: ${_lastEmotionMetadata!.primaryEmotion}');
      onEmotionDetected?.call(_lastEmotionMetadata!);
    }

    // Also check for tone/emphasis at the data level
    final tone = data['tone'] as String?;
    final emphasis = data['emphasis'] as List<dynamic>?;

    if (tone != null || emphasis != null) {
      _lastEmotionMetadata = EmotionMetadata(
        tone: tone,
        emphasizedWords: emphasis?.cast<String>(),
        rawMetadata: data,
      );
      onEmotionDetected?.call(_lastEmotionMetadata!);
    }
  }

  /// Phase 65: Handle dedicated emotion events (anticipated 2025 API)
  void _handleEmotionEvent(Map<String, dynamic> data) {
    final emotionData = data['emotion'] ?? data;
    _lastEmotionMetadata = EmotionMetadata.fromJson(emotionData);
    _addDebugLog('🎭 Emotion event: ${_lastEmotionMetadata!.primaryEmotion} (conf: ${_lastEmotionMetadata!.confidence})');
    onEmotionDetected?.call(_lastEmotionMetadata!);
  }

  void _sendJson(Map<String, dynamic> data) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(data));
    }
  }

  @override
  void sendAudio(Uint8List audioData) {
    if (!_isConnected) return;

    // OpenAI expects raw PCM16 base64 in "input_audio_buffer.append"
    final base64Audio = base64Encode(audioData);
    _sendJson({
      'type': 'input_audio_buffer.append',
      'audio': base64Audio,
    });
  }

  @override
  void sendText(String text, {bool turnComplete = true}) {
    // For OpenAI Realtime, we send conversation item
    _sendJson({
      'type': 'conversation.item.create',
      'item': {
        'type': 'message',
        'role': 'user',
        'content': [
          {'type': 'input_text', 'text': text}
        ]
      }
    });

    if (turnComplete) {
      _sendJson({'type': 'response.create'});
    }
  }

  @override
  void interrupt() {
    _sendJson({'type': 'response.cancel'});
  }

  @override
  void sendToolResponse(String functionName, String callId, Map<String, dynamic> result) {
    _sendJson({
      'type': 'conversation.item.create',
      'item': {
        'type': 'function_call_output',
        'call_id': callId,
        'output': jsonEncode(result),
      }
    });
    _sendJson({'type': 'response.create'});
  }

  @override
  Future<void> disconnect() async {
    await _disconnect();
  }

  Future<void> _disconnect() async {
    _isConnected = false;
    _isListening = false;
    await _channel?.sink.close();
    _channel = null;
  }

  @override
  void dispose() {
    _disconnect();
  }
}
