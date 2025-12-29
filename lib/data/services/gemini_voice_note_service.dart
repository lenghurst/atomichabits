import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http; 
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:path_provider/path_provider.dart';
import '../../config/ai_model_config.dart';
import '../models/chat_message.dart';

class GeminiVoiceNoteService {
  late final GenerativeModel _brain;
  final String _apiKey = AIModelConfig.geminiApiKey;

  GeminiVoiceNoteService() {
    // 1. The Brain (Reasoning)
    _brain = GenerativeModel(
      model: AIModelConfig.reasoningModel, // 'gemini-3-flash-preview'
      apiKey: _apiKey,
      generationConfig: GenerationConfig(responseMimeType: 'text/plain'),
    );
  }

  Future<ChatMessage> processVoiceNote(String userAudioPath) async {
    try {
      // --- STEP 1: THINK ---
      final audioFile = File(userAudioPath);
      final audioBytes = await audioFile.readAsBytes();

      final prompt = Content.multi([
        TextPart("You are Sherlock, a high-performance habit coach. "
            "Listen to the user. Analyze their emotional state and blocker. "
            "Draft a concise, supportive response (max 3 sentences)."),
        DataPart('audio/mp4', audioBytes),
      ]);

      final brainResponse = await _brain.generateContent([prompt]);
      final sherlockText = brainResponse.text ?? "I analyzed the audio but found no words.";

      // --- STEP 2: SPEAK (REST API FIX) ---
      final audioPath = await _generateSpeechViaRest(sherlockText);

      return ChatMessage.assistant(
        content: sherlockText,
        audioPath: audioPath,
        status: MessageStatus.complete,
      );

    } catch (e) {
      return ChatMessage.assistant(
        content: "Analysis Error: $e",
        status: MessageStatus.error,
      );
    }
  }

  // Fallback for text input
  Future<ChatMessage> processText(String text) async {
    try {
      final prompt = Content.text("You are Sherlock. The user says: \"$text\". "
          "Analyze and respond concisely.");

      final brainResponse = await _brain.generateContent([prompt]);
      final sherlockText = brainResponse.text ?? "I have nothing to say.";

      final audioPath = await _generateSpeechViaRest(sherlockText);

      return ChatMessage.assistant(
        content: sherlockText,
        audioPath: audioPath,
        status: MessageStatus.complete,
      );
    } catch (e) {
      return ChatMessage.assistant(
        content: "Error: $e",
        status: MessageStatus.error,
      );
    }
  }

  Future<String?> _generateSpeechViaRest(String text) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-tts:generateContent?key=$_apiKey'
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [{
            "parts": [{"text": text}]
          }],
          // ✅ FIXED: Changed 'config' to 'generationConfig' to match API spec
          "generationConfig": { 
            "responseModalities": ["AUDIO"],
            "speechConfig": {
              "voiceConfig": {
                "prebuiltVoiceConfig": {
                  "voiceName": "Aoede"
                }
              }
            }
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && (data['candidates'] as List).isNotEmpty) {
           final candidate = data['candidates'][0];
           final parts = candidate['content']['parts'] as List;
           for (var part in parts) {
             if (part.containsKey('inlineData')) {
               final base64Audio = part['inlineData']['data'];
               final bytes = base64Decode(base64Audio);
               return await _saveAudioFile(bytes);
             }
           }
        }
      } else {
        if (kDebugMode) print("TTS REST Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      if (kDebugMode) print("TTS Network Error: $e");
    }
    return null;
  }

  Future<String> _saveAudioFile(List<int> bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'sherlock_${DateTime.now().millisecondsSinceEpoch}.wav';
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
