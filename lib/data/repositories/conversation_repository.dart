import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConversationRepository {
  final SupabaseClient _supabase;
  
  ConversationRepository(this._supabase);
  
  /// Create a new conversation
  Future<String> createConversation({
    required String userId,
    String? habitId,
    String? sessionType,
    String? triggerEvent,
  }) async {
    try {
      final data = await _supabase
        .from('conversations')
        .insert({
          'user_id': userId,
          'habit_id': habitId,
          'session_type': sessionType,
          'trigger_event': triggerEvent,
          'status': 'active',
        })
        .select('id')
        .single();
      
      if (kDebugMode) print('💬 Created conversation: ${data['id']}');
      return data['id'] as String;
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Failed to create conversation: $e');
      rethrow;
    }
  }
  
  /// Save a conversation turn (user + AI exchange)
  Future<String> saveTurn({
    required String userId,
    required String conversationId,
    required String userTranscript,
    required String aiResponse,
    String? localUserAudioPath,
    String? localAiAudioPath,
    int? userAudioDurationMs,
    int? aiAudioDurationMs,
    required String modelTranscription,
    required String modelReasoning,
    String? modelTts,
  }) async {
    try {
      // Get current turn count
      final conversation = await _supabase
        .from('conversations')
        .select('turn_count')
        .eq('id', conversationId)
        .single();
      
      final turnNumber = (conversation['turn_count'] as int) + 1;
      
      // Insert turn
      final turnData = await _supabase
        .from('conversation_turns')
        .insert({
          'conversation_id': conversationId,
          'user_id': userId,
          'user_transcript': userTranscript,
          'ai_response': aiResponse,
          'local_user_audio_path': localUserAudioPath,
          'local_ai_audio_path': localAiAudioPath,
          'user_audio_duration_ms': userAudioDurationMs,
          'ai_audio_duration_ms': aiAudioDurationMs,
          'turn_number': turnNumber,
          'model_transcription': modelTranscription,
          'model_reasoning': modelReasoning,
          'model_tts': modelTts,
        })
        .select('id')
        .single();
      
      // Update conversation turn count
      await _supabase
        .from('conversations')
        .update({'turn_count': turnNumber})
        .eq('id', conversationId);
      
      if (kDebugMode) {
        print('📝 Saved turn ${turnData['id']} (#$turnNumber in conversation)');
      }
      
      return turnData['id'] as String;
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Failed to save turn: $e');
      rethrow;
    }
  }
}
