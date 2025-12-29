import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../config/ai_model_config.dart';
import '../models/chat_message.dart';

class GeminiVoiceNoteService {
  late final GenerativeModel _reasoningModel;
  final String _apiKey = AIModelConfig.geminiApiKey;

  GeminiVoiceNoteService() {
    // 1. The Brain: Use the SDK for text/multimodal analysis
    // KEEPING Gemini 3 as the reasoning brain as requested.
    _reasoningModel = GenerativeModel(
      model: AIModelConfig.reasoningModel, // 'gemini-3-flash-preview'
      apiKey: _apiKey,
      generationConfig: GenerationConfig(responseMimeType: 'text/plain'),
    );
  }

  Future<ChatMessage> processVoiceNote(String userAudioPath) async {
    try {
      // --- STEP 1: REASONING (SDK) ---
      final audioFile = File(userAudioPath);
      if (!await audioFile.exists()) {
        return ChatMessage(
          id: 'error',
          role: MessageRole.assistant,
          content: "Error: Audio file not found.",
          timestamp: DateTime.now(),
          status: MessageStatus.error,
        );
      }
      
      final audioBytes = await audioFile.readAsBytes();

      final prompt = Content.multi([
        TextPart("You are Sherlock, a high-performance habit coach. "
            "Analyze the user's voice note. "
            "Be incisive, supportive, and analytical. "
            "Keep your response concise (under 3 sentences) and conversational."),
        DataPart('audio/mp4', audioBytes), // M4A is mp4 audio
      ]);

      final brainResponse = await _reasoningModel.generateContent([prompt]);
      final sherlockText = brainResponse.text ?? "I analyzed the data but found nothing.";

      // --- STEP 2: SPEECH SYNTHESIS (REST API) ---
      String? sherlockAudioPath;
      try {
        sherlockAudioPath = await _generateSpeechViaRest(sherlockText);
      } catch (e) {
        if (kDebugMode) print("TTS Generation Failed: $e");
      }

      return ChatMessage.sherlock(
        text: sherlockText,
        audioPath: sherlockAudioPath,
      );

    } catch (e) {
      return ChatMessage(
        id: 'error',
        role: MessageRole.assistant,
        content: "Deduction failed: $e",
        timestamp: DateTime.now(),
        status: MessageStatus.error,
      );
    }
  }

  // Fallback for text input
  Future<ChatMessage> processText(String text) async {
    try {
      // Generate speech for text-only input
      final audioPath = await _generateSpeechViaRest(text);
      
      return ChatMessage.sherlock(
        text: text,
        audioPath: audioPath,
      );
    } catch (e) {
      return ChatMessage(
        id: 'error',
        role: MessageRole.assistant,
        content: "Speech synthesis failed: $e",
        timestamp: DateTime.now(),
        status: MessageStatus.error,
      );
    }
  }

  /// Manually calls the Gemini 2.5 TTS endpoint via REST to bypass SDK constraints
  Future<String?> _generateSpeechViaRest(String text) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-tts:generateContent',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': _apiKey,
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": text}
              ]
            }
          ],
          "generationConfig": {
            "responseModalities": ["AUDIO"],
            "speechConfig": {
              "voiceConfig": {
                "prebuiltVoiceConfig": {
                  "voiceName": "Aoede" // Options: Puck, Charon, Kore, Fenrir, Aoede
                }
              }
            }
          },
          // ✅ Specify the model in the request body as well
          "model": "gemini-2.5-flash-preview-tts",
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
              final pcmBytes = base64Decode(base64Audio);
              
              // Convert Raw PCM to WAV so Flutter players can read it
              final wavBytes = _pcmBytesToWav(pcmBytes);
              
              return await _saveAudioFile(wavBytes, extension: '.wav');
            }
          }
        }
      } else {
        if (kDebugMode) {
          print("TTS REST Error: ${response.statusCode} - ${response.body}");
        }
      }
    } catch (e) {
      if (kDebugMode) print("TTS Network Error: $e");
    }
    return null;
  }

  /// Wraps raw PCM data with a WAV header
  /// Gemini returns: PCM 24kHz, 1 channel, 16-bit (s16le)
  Uint8List _pcmBytesToWav(List<int> pcmBytes) {
    if (pcmBytes.isEmpty) {
      throw ArgumentError('Cannot create WAV from empty PCM data');
    }
    
    const sampleRate = 24000;
    const channels = 1;
    const bitsPerSample = 16;
    const blockAlign = channels * bitsPerSample ~/ 8;
    const byteRate = sampleRate * blockAlign;

    final dataSize = pcmBytes.length;
    final totalSize = 36 + dataSize; 

    final header = ByteData(44);
    // RIFF chunk
    header.setUint32(0, 0x46464952, Endian.little); // "RIFF"
    header.setUint32(4, totalSize, Endian.little);
    header.setUint32(8, 0x45564157, Endian.little); // "WAVE"
    // fmt chunk
    header.setUint32(12, 0x20746D66, Endian.little); // "fmt "
    header.setUint32(16, 16, Endian.little); // chunk size
    header.setUint16(20, 1, Endian.little); // audio format (1 = PCM)
    header.setUint16(22, channels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, bitsPerSample, Endian.little);
    // data chunk
    header.setUint32(36, 0x61746164, Endian.little); // "data"
    header.setUint32(40, dataSize, Endian.little);

    final wavBytes = Uint8List(44 + pcmBytes.length);
    wavBytes.setRange(0, 44, header.buffer.asUint8List());
    wavBytes.setRange(44, wavBytes.length, pcmBytes);
    return wavBytes;
  }

  Future<String> _saveAudioFile(List<int> bytes, {String extension = '.wav'}) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'sherlock_${DateTime.now().millisecondsSinceEpoch}$extension';
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);
    
    if (kDebugMode) {
      print("🔊 Saved Sherlock Audio (WAV): ${file.path} (${bytes.length} bytes)");
    }
    return file.path;
  }
}
