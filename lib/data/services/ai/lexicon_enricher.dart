import 'dart:convert';
import 'ai_service_manager.dart';
import '../../models/lexicon_entry.dart';

class LexiconEnricher {
  final AiServiceManager _aiServiceManager;

  LexiconEnricher(this._aiServiceManager);

  Future<Map<String, String>> enrichWord(String word, String identityTag) async {
    final prompt = '''
You are a wise mentor helping a user build their identity as a "$identityTag".
The user has added the word: "$word".

1. Define it briefly.
2. Explain its etymology.
3. Explain why this word is a "Power Word" for a $identityTag.
4. Give a practical challenge to use it today.

Output ONLY valid JSON in this format:
{
  "definition": "...",
  "etymology": "...",
  "power_reason": "...",
  "challenge": "..."
}
''';

    // Use the currently selected AI provider (DeepSeek or Gemini)
    final response = await _aiServiceManager.sendMessage(prompt);
    
    try {
      // Clean up potential markdown code blocks
      final jsonString = response.replaceAll('```json', '').replaceAll('```', '').trim();
      final Map<String, dynamic> data = jsonDecode(jsonString);
      
      return {
        'definition': data['definition'] as String,
        'etymology': data['etymology'] as String,
        'power_reason': data['power_reason'] as String,
        'challenge': data['challenge'] as String,
      };
    } catch (e) {
      // Fallback if JSON parsing fails
      return {
        'definition': 'Could not enrich word.',
        'etymology': 'Unknown',
        'power_reason': 'Keep using it!',
        'challenge': 'Use it in a sentence.',
      };
    }
  }
}
