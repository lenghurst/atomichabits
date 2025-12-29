import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/chat_message.dart';
import '../models/chat_message.dart'; // Ensure correct import if needed, assuming first one is enough or correct relative path
import 'gemini_voice_note_service.dart';
import 'audio_recording_service.dart';

class VoiceSessionManager extends ChangeNotifier {
  final GeminiVoiceNoteService _sherlockService = GeminiVoiceNoteService();
  final AudioRecordingService _audioRecorder = AudioRecordingService();
  
  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  
  bool _isRecording = false;
  bool get isRecording => _isRecording;
  
  bool _isThinking = false;
  bool get isThinking => _isThinking;

  DateTime? _recordingStartTime; // ⏱️ Added duration tracking

  /// Sends a text message to Sherlock
  Future<void> sendText(String text) async {
    if (_isThinking || text.trim().isEmpty) return;

    // 1. Add User Text Bubble (Optimistic UI)
    _addMessage(ChatMessage.user(content: text));
    
    // 2. Trigger AI
    await _processTextNote(text);
  }

  /// Processes text input through the AI pipeline
  Future<void> _processTextNote(String text) async {
    _isThinking = true;
    notifyListeners();

    try {
      // Use the service to process text (Think -> Speak)
      final responseMessage = await _sherlockService.processText(text);
      _addMessage(responseMessage);
    } catch (e) {
      _addMessage(ChatMessage(
        id: 'error',
        role: MessageRole.assistant,
        content: "I couldn't process that text. ($e)",
        timestamp: DateTime.now(),
        status: MessageStatus.error,
      ));
    } finally {
      // 🔓 CRITICAL: UNLOCK INPUT IMMEDIATELY Do not wait for audio playback to finish.
      _isThinking = false;
      notifyListeners();
    }
  }

  Future<void> startRecording() async {
    if (_isThinking) return;

    _isRecording = true;
    _recordingStartTime = DateTime.now(); // Start clock
    notifyListeners();
    try {
      await _audioRecorder.startRecording();
    } catch (e) {
      _isRecording = false;
      notifyListeners();
      _addMessage(ChatMessage(
          id: 'error',
          role: MessageRole.assistant,
          content: "Failed to start recording: $e",
          timestamp: DateTime.now(),
          status: MessageStatus.error,
        ));
    }
  }

  Future<void> stopRecordingAndSend() async {
    if (!_isRecording) return; 

    _isRecording = false;
    audioPath = null;
    try {
       audioPath = await _audioRecorder.stopRecording();
    } catch (e) {
      // Handle stop error
    }
    
    // ⏱️ Calculate duration
    final duration = _recordingStartTime != null 
        ? DateTime.now().difference(_recordingStartTime!) 
        : Duration.zero;

    if (audioPath == null) {
      notifyListeners(); // Update UI immediately
       return; 
    }

    // 1. Add User Voice Bubble (Optimistic)
    _addMessage(ChatMessage.userVoice(
      audioPath: audioPath!,
      duration: duration, // ✅ Pass duration to UI
    ));

    // 2. Trigger Sherlock
    _processSherlockTurn(audioPath!);
  }

  Future<void> _processSherlockTurn(String audioPath) async {
    _isThinking = true;
    notifyListeners();

    try {
      final responseMessage = await _sherlockService.processVoiceNote(audioPath);
      _addMessage(responseMessage);
    } catch (e) {
      _addMessage(ChatMessage(
        id: 'error',
        role: MessageRole.assistant,
        content: "System Malfunction: $e",
        timestamp: DateTime.now(),
        status: MessageStatus.error,
      ));
    } finally {
      // 🔓 CRITICAL: UNLOCK INPUT IMMEDIATELY Do not wait for audio playback to finish.
      _isThinking = false;
      notifyListeners();
    }
  }
  
  void _addMessage(ChatMessage msg) {
    _messages.add(msg);
    notifyListeners();
  }
  
  // Scoping variable to fix build which would happen if I copied user code exactly
  String? audioPath;
}
