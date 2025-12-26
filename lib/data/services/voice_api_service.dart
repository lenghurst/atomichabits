import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../enums/voice_session_mode.dart';

/// Abstract interface for voice API services (Gemini, OpenAI, etc.)
abstract class VoiceApiService {
  // === GETTERS ===
  bool get isConnected;
  bool get isListening;

  // === CALLBACKS ===
  // These should be set via constructor or setters, depending on implementation

  // === METHODS ===

  /// Start a voice session
  Future<bool> connect({
    String? systemInstruction,
    bool enableTranscription = true,
    Map<String, dynamic>? tools,
  });

  /// Send audio data to the AI
  void sendAudio(Uint8List audioData);

  /// Send text input to the AI
  void sendText(String text, {bool turnComplete = true});

  /// Interrupt the AI
  void interrupt();

  /// Send a tool response
  void sendToolResponse(String functionName, String callId, Map<String, dynamic> result);

  /// Disconnect the session
  Future<void> disconnect();

  /// Clear the debug log
  void clearDebugLog();

  /// Dispose resources
  void dispose();
}
