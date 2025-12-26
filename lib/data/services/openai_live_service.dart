import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

import '../../config/ai_model_config.dart';
import '../../core/logging/app_logger.dart';
import 'voice_api_service.dart';

/// OpenAI Live API Service
///
/// Implements Realtime API using WebSocket.
/// Endpoint: wss://api.openai.com/v1/realtime?model=gpt-4o-realtime-preview-2024-10-01
/// Docs: https://platform.openai.com/docs/guides/realtime
class OpenAILiveService implements VoiceApiService {
  static const String _wsUrl = 'wss://api.openai.com/v1/realtime?model=gpt-4o-realtime-preview-2024-10-01';

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

  final List<String> _debugLog = [];

  OpenAILiveService({
    this.onAudioReceived,
    this.onTranscription,
    this.onModelSpeakingChanged,
    this.onError,
    this.onToolCall,
    this.onDebugLogUpdated,
  });

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
          break;

        case 'response.audio.delta':
          final base64Audio = data['delta'] as String;
          final bytes = base64Decode(base64Audio);
          onAudioReceived?.call(bytes);
          onModelSpeakingChanged?.call(true);
          break;

        case 'response.audio_transcript.delta':
           // OpenAI sends incremental transcript
           // We might want to accumulate or just notify
           final delta = data['delta'] as String;
           onTranscription?.call(delta, false);
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
           break;

        case 'error':
           final err = data['error'];
           _addDebugLog('❌ OpenAI Error: ${err['message']}', isError: true);
           break;
      }
    } catch (e) {
      // _addDebugLog('Parse error: $e');
    }
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
