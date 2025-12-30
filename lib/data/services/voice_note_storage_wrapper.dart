import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'gemini_voice_note_service.dart';
import 'auth_service.dart';
import 'local_audio_service.dart';
import '../repositories/conversation_repository.dart';
import '../models/local_audio_record.dart';
import '../../config/ai_model_config.dart';

/// Wrapper that adds storage capabilities WITHOUT modifying GeminiVoiceNoteService
class VoiceNoteStorageWrapper {
  final GeminiVoiceNoteService _voiceService;
  final ConversationRepository? _conversationRepo;
  final LocalAudioService? _localAudioService;
  final AuthService _authService;
  
  VoiceNoteStorageWrapper({
    required GeminiVoiceNoteService voiceService,
    required AuthService authService,
    ConversationRepository? conversationRepo,
    LocalAudioService? localAudioService,
  }) : _voiceService = voiceService,
       _authService = authService,
       _conversationRepo = conversationRepo,
       _localAudioService = localAudioService;
  
  /// Process voice note AND save to storage (if enabled)
  Future<VoiceNoteResult> processAndStore(
    String userAudioPath, {
    List<Content>? history,
    String? systemInstruction,
    String? conversationId,
    String? habitId,
    bool enableStorage = true,
  }) async {
    // Step 1: Call existing service
    // ✅ Pass deleteAudioAfter=false so we can copy it first
    final result = await _voiceService.processVoiceNote(
      userAudioPath,
      history: history,
      systemInstruction: systemInstruction,
      deleteAudioAfter: false,  // ✅ FIX: Don't delete yet
    );
    
    // Step 2: If storage enabled, save data (file still exists)
    if (enableStorage && !result.isError) {
      await _saveToStorage(
        result: result,
        conversationId: conversationId,
        habitId: habitId,
      );
    }
    
    return result;
  }
  
  Future<void> _saveToStorage({
    required VoiceNoteResult result,
    String? conversationId,
    String? habitId,
  }) async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        if (kDebugMode) print('⚠️ Cannot save: No user ID');
        return;
      }
      
      // Ensure we have a conversation ID
      String? convId = conversationId;
      if (convId == null && _conversationRepo != null) {
        convId = await _conversationRepo.createConversation(
          userId: userId,
          habitId: habitId,
          sessionType: 'coaching',
        );
      }
      
      if (convId == null) {
        if (kDebugMode) print('⚠️ Cannot save: No conversation ID');
        return;
      }
      
      // Save transcript to cloud
      String? turnId;
      if (_conversationRepo != null) {
        turnId = await _conversationRepo.saveTurn(
          userId: userId,
          conversationId: convId,
          userTranscript: result.userTranscript,
          aiResponse: result.sherlockResponse,
          localUserAudioPath: result.userAudioPath,
          localAiAudioPath: result.sherlockAudioPath,
          modelTranscription: AIModelConfig.transcriptionModel,
          modelReasoning: AIModelConfig.reasoningModel,
          modelTts: AIModelConfig.ttsModel,
        );
      }
      
      // Save audio paths to local storage (this will copy files)
      if (turnId != null && _localAudioService != null) {
        await _localAudioService.saveAudioRecord(
          LocalAudioRecord(
            id: turnId,
            userAudioPath: result.userAudioPath ?? '',
            aiAudioPath: result.sherlockAudioPath,
            userAudioDurationMs: 0, // TODO: Calculate from audio file
            aiAudioDurationMs: 0,
            createdAt: DateTime.now(),
            conversationId: convId,
            isOnboarding: false,
          ),
        );
      }
      
      if (kDebugMode) print('💾 Stored voice note: $turnId');
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Storage failed (non-fatal): $e');
      // Don't throw - storage failure shouldn't break the UI
    }
  }
  
  // Delegate cleanup methods to original service
  Future<void> cleanupTTSAudio(String audioPath) =>
    _voiceService.cleanupTTSAudio(audioPath);
  
  Future<void> cleanupSessionAudio() =>
    _voiceService.cleanupSessionAudio();
}
