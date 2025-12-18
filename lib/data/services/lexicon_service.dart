import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/lexicon_entry.dart';

class LexiconService {
  final SupabaseClient _supabase;

  LexiconService(this._supabase);

  // Fetch user's lexicon
  Future<List<LexiconEntry>> getLexicon() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final response = await _supabase
        .from('lexicon_entries')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => LexiconEntry.fromJson(json)).toList();
  }

  // Add a new word (initial capture)
  Future<LexiconEntry> addWord(String word, {String? identityTag}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final entry = LexiconEntry.create(
      userId: userId,
      word: word,
      identityTag: identityTag,
    );

    final response = await _supabase
        .from('lexicon_entries')
        .insert(entry.toJson())
        .select()
        .single();

    return LexiconEntry.fromJson(response);
  }

  // Update enriched data (from AI)
  Future<void> updateEnrichment(String entryId, {
    required String definition,
    required String etymology,
  }) async {
    await _supabase.from('lexicon_entries').update({
      'definition': definition,
      'etymology': etymology,
    }).eq('id', entryId);
  }

  // Mark word as practiced
  Future<void> markPracticed(String entryId) async {
    // Increment mastery level and update last practiced time
    // Note: This is a simple client-side increment. 
    // For robustness, consider an RPC function or atomic update if concurrency is high.
    
    // First, get current level
    final response = await _supabase
        .from('lexicon_entries')
        .select('mastery_level')
        .eq('id', entryId)
        .single();
        
    final currentLevel = response['mastery_level'] as int;
    
    await _supabase.from('lexicon_entries').update({
      'mastery_level': currentLevel + 1,
      'last_practiced_at': DateTime.now().toIso8601String(),
    }).eq('id', entryId);
  }

  // Delete a word
  Future<void> deleteWord(String entryId) async {
    await _supabase.from('lexicon_entries').delete().eq('id', entryId);
  }
}
