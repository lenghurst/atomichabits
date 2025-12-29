import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http; // Ensure http is in pubspec.yaml
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:path_provider/path_provider.dart';
import '../../config/ai_model_config.dart';
import '../models/chat_message.dart';

class GeminiVoiceNoteService {
  late final GenerativeModel _brain;
  final String _apiKey = AIModelConfig.geminiApiKey;

  GeminiVoiceNoteService() {
    // 1. The Brain (Reasoning): Uses SDK because we WANT text output
    _brain = GenerativeModel(
      model: AIModelConfig.reasoningModel, // 'gemini-3-flash-preview'
      apiKey: _apiKey,
      generationConfig: GenerationConfig(responseMimeType: 'text/plain'),
    );
  }

  Future<ChatMessage> processVoiceNote(String userAudioPath) async {
    try {
      // --- STEP 1: THINK (Gemini 3) ---
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

      // --- STEP 2: SPEAK (Gemini 2.5 TTS via REST) ---
      final audioPath = await _generateSpeechViaRest(sherlockText);

      return ChatMessage.assistant(
        content: sherlockText,
        audioPath: audioPath, // UI renders player if this is not null
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

  /// ⚡ CORE FIX: Direct REST Call for TTS
  /// Forces 'responseModalities': ['AUDIO'] which the SDK cannot do yet.
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
          "generationConfig": { // 👈 Renamed from 'config' to 'generationConfig'
            "responseModalities": ["AUDIO"],
            "speechConfig": {
              "voiceConfig": {
                "prebuiltVoiceConfig": {
                  "voiceName": "Aoede" // Options: 'Puck', 'Charon', 'Kore', 'Fenrir', 'Aoede'
                }
              }
            }
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Extract Base64 Audio from the JSON response
        if (data['candidates'] != null && (data['candidates'] as List).isNotEmpty) {
           final candidate = data['candidates'][0];
           final parts = candidate['content']['parts'] as List;
           
           // Look for the part that has 'inlineData'
           // Note: The API might return text AND audio, or just audio. We scan for inlineData.
           for (var part in parts) {
             if (part.containsKey('inlineData')) {
               final base64Audio = part['inlineData']['data'];
               final bytes = base64Decode(base64Audio);
               return await _saveAudioFile(bytes);
             }
           }
        }
      } else {
        if (kDebugMode) {
          print("TTS REST Error: ${response.statusCode} - ${response.body}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("TTS Network Error: $e");
      }
    }
    return null; // Graceful fallback (Text only)
  }

  Future<String> _saveAudioFile(List<int> bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'sherlock_${DateTime.now().millisecondsSinceEpoch}.wav';
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
