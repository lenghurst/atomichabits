import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart'; // REQUIRED for Content
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/chat_message.dart';
import 'gemini_voice_note_service.dart';
import 'audio_recording_service.dart';
import 'evidence_service.dart';

class VoiceSessionManager extends ChangeNotifier {
  final GeminiVoiceNoteService _sherlockService;
  final AudioRecordingService _audioRecorder = AudioRecordingService();
  
  VoiceSessionManager({GeminiVoiceNoteService? service}) 
      : _sherlockService = service ?? GeminiVoiceNoteService();
  
  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  
  bool _isRecording = false;
  bool get isRecording => _isRecording;
  
  bool _isThinking = false;
  bool get isThinking => _isThinking;

  // Dynamic System Prompt (injected by VoiceCoachScreen)
  String? _currentSystemPrompt;
  
  void setSystemPrompt(String prompt) {
    _currentSystemPrompt = prompt;
  }

  // Track if Sherlock has approved the pact
  bool _isSessionComplete = false;
  bool get isSessionComplete => _isSessionComplete;

  DateTime? _recordingStartTime; // ⏱️ Added duration tracking

  /// Resets the session state (clears messages, flags, etc.)
  void resetSession() {
    _messages.clear();
    _isSessionComplete = false;
    _currentSystemPrompt = null;
    notifyListeners();
  }

  /// Adds a greeting message from the System/Assistant
  void addSystemGreeting(String greeting) {
    _addMessage(ChatMessage.sherlock(text: greeting));
  }

  /// Sends a text message to Sherlock
  Future<void> sendText(String text) async {
    if (_isThinking || _isSessionComplete || text.trim().isEmpty) return;

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
      final responseMessage = await _sherlockService.processText(text);
      _addMessage(responseMessage);

      // Check for [APPROVED] token (e.g. "cheat code")
      if (responseMessage.content.contains('[APPROVED]')) {
        _isSessionComplete = true; // Signal completion
        notifyListeners();
      }
    } catch (e) {
      _addMessage(ChatMessage(
        id: 'error',
        role: MessageRole.assistant,
        content: "I couldn't process that text. ($e)",
        timestamp: DateTime.now(),
        status: MessageStatus.error,
      ));
    } finally {
      _isThinking = false;
      notifyListeners();
    }
  }

  Future<void> startRecording() async {
    if (_isThinking || _isSessionComplete) return;

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
    String? audioPath;
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
      audioPath: audioPath,
      duration: duration, 
    ));

    // 2. Trigger Sherlock
    _processSherlockTurn(audioPath);
  }

  // Refined Prompt: Philosophical Integration (IFS)
  // Replaces "Anti-Identity" with "Protector Parts" to align with Taoist/Therapeutic vision
  // DEPRECATED: Now injected via setSystemPrompt()
  // static const String _sherlockSystemPrompt = ...

  Future<void> _processSherlockTurn(String audioPath) async {
    _isThinking = true;
    notifyListeners();

    try {
      // Build history from existing messages for Context Memory
      final history = _messages
          .where((m) => m.role != MessageRole.system && m.status != MessageStatus.error)
          .map((m) {
            if (m.role == MessageRole.user) {
              return Content.text(m.content);
            } else {
              return Content.model([TextPart(m.content)]);
            }
          })
          .toList();

      final result = await _sherlockService.processVoiceNote(
        audioPath,
        history: history,
        systemInstruction: _currentSystemPrompt,
      );
      
      // ✅ UX: Delay removal so user sees the "Sent" state for a moment
      // This prevents the jarring "disappearing bubble" effect
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // ✅ UX IMPROVEMENT: Smoother transition
      // We keep the bubble but update its content to the transcript.
      if (_messages.isNotEmpty && _messages.last.audioPath != null) {
          _messages.removeLast();
      }
      _addMessage(ChatMessage.user(content: result.userTranscript));

      // ✅ Add Sherlock Response
      // Check for [APPROVED] token to trigger exit
      final cleanResponse = result.sherlockResponse.replaceAll('[APPROVED]', '').trim();
      
      _addMessage(ChatMessage.sherlock(
        text: cleanResponse,
        audioPath: result.sherlockAudioPath,
      ));
      
      if (result.sherlockResponse.contains('[APPROVED]')) {
        _isSessionComplete = true; // Signal completion
        notifyListeners();
      }
      
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
  
  // === Phase 3: Lazy TTS Trigger ===
  
  /// Generates audio for a specific message on demand
  Future<void> generateAudioForMessage(ChatMessage message) async {
    if (message.audioPath != null) return; // Already has audio
    
    try {
      // 1. Set status to loading (optional, or just rely on async)
      // We might need a loading state in ChatMessage? For now, we assume UI shows spinner if button pressed
      
      final audioPath = await _sherlockService.generateAudioOnDemand(message.content);
      
      if (audioPath != null) {
        // 2. Update message with audio path
        // We need to find and replace the message instance since it's immutable-ish
        final index = _messages.indexWhere((m) => m.id == message.id);
        if (index != -1) {
          _messages[index] = ChatMessage(
            id: message.id,
            role: message.role,
            content: message.content,
            timestamp: message.timestamp,
            audioPath: audioPath, // ✅ Updated
            status: message.status,
            audioDuration: message.audioDuration,
          );
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('VoiceSessionManager: Lazy TTS failed: $e');
    }
  }

  /// Cleans up TTS audio files generated during the session.
  Future<void> cleanupSession() async {
    await _sherlockService.cleanupSessionAudio();
  }

  // === Phase 65: Emotion Metadata Storage ===

  /// Store emotion metadata from voice session for JITAI integration
  ///
  /// This data is used to boost vulnerability calculations in the JITAI decision engine.
  /// Emotion data is stored locally only (never synced) and expires after 2 hours.
  ///
  /// Call this after processing voice sessions when emotion data is available.
  /// Example: After OpenAI Realtime API analysis or Gemini emotion extraction.
  Future<void> storeEmotionMetadata({
    required String primaryEmotion,
    required double confidence,
    String? tone,
    String? emphasis,
  }) async {
    try {
      final box = await Hive.openBox('emotion_metadata');

      await box.put('latest_emotion', {
        'primaryEmotion': primaryEmotion,
        'confidence': confidence,
        'tone': tone,
        'emphasis': emphasis,
        'capturedAt': DateTime.now().toIso8601String(),
      });

      debugPrint('VoiceSessionManager: Stored emotion - $primaryEmotion (${(confidence * 100).toStringAsFixed(0)}%)');
      
      // Phase 3: Log Evidence (Evidence Foundation)
      await EvidenceService.instance.logEmotionDetected(
        emotion: primaryEmotion,
        confidence: confidence,
        source: 'voice_session', // or get from context if available
      );
    } catch (e) {
      debugPrint('VoiceSessionManager: Failed to store emotion metadata: $e');
    }
  }

  /// Clear emotion metadata (called when emotion becomes stale or irrelevant)
  Future<void> clearEmotionMetadata() async {
    try {
      final box = await Hive.openBox('emotion_metadata');
      await box.delete('latest_emotion');
      debugPrint('VoiceSessionManager: Cleared emotion metadata');
    } catch (e) {
      debugPrint('VoiceSessionManager: Failed to clear emotion metadata: $e');
    }
  }

  @override
  void dispose() {
    // ✅ PRIVACY: Cleanup TTS audio when session ends
    _sherlockService.cleanupSessionAudio();
    _audioRecorder.dispose();
    super.dispose();
  }
}
