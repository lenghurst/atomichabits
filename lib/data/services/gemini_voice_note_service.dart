import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:async'; // unawaited
import 'psychometric_extraction_service.dart';
import '../../config/ai_model_config.dart';
import '../models/chat_message.dart';
import 'auth_service.dart';

class GeminiVoiceNoteService {
  late final GenerativeModel _reasoningModel;
  late final GenerativeModel _transcriptionModel;
  final PsychometricExtractionService? _psychometricService; // Injectable
  final AuthService? _authService; // Injectable
  final String _apiKey = AIModelConfig.geminiApiKey;

  GeminiVoiceNoteService({
    PsychometricExtractionService? psychometricService,
    AuthService? authService,
  }) : _psychometricService = psychometricService,
       _authService = authService {
    // 1. The Brain: Use the SDK for text/multimodal analysis
    _reasoningModel = GenerativeModel(
      model: AIModelConfig.reasoningModel, // 'gemini-3-flash-preview' or similar
      apiKey: _apiKey,
      generationConfig: GenerationConfig(responseMimeType: 'text/plain'),
    );
    
    // 2. The Ear: Dedicated transcription model (cheaper, faster)
    _transcriptionModel = GenerativeModel(
      model: AIModelConfig.transcriptionModel,
      apiKey: _apiKey,
    );
  }

  // ✅ PRIVACY: Track generated TTS files for cleanup
  final Set<String> _ttsAudioPaths = {};

  @visibleForTesting
  void addAudioPathForTesting(String path) {
    _ttsAudioPaths.add(path);
  }
  
  @visibleForTesting
  Set<String> get ttsAudioPaths => Set.unmodifiable(_ttsAudioPaths);


  Future<VoiceNoteResult> processVoiceNote(String userAudioPath, {
    List<Content>? history,
    String? systemInstruction,
    bool deleteAudioAfter = true, // ✅ NEW: Control deletion (default true for backward compatibility)
  }) async {
    File? audioFile;
    try {
      // 1. Create a reference to the file
      audioFile = File(userAudioPath);
      if (!await audioFile.exists()) {
        return VoiceNoteResult.error("I couldn't hear that.");
      }
      
      final audioBytes = await audioFile.readAsBytes();

      if (kDebugMode) print("Step 1: Audio read (${audioBytes.length} bytes)");

      // --- PARALLEL EXECUTION: Transcribe + Reason ---
      // ✅ Latency Optimization: Run both calls simultaneously
      // ✅ Robustness: Catch errors individually so one failure doesn't block the other
      final results = await Future.wait([
        // Call 1: TRANSCRIPTION (Flash)
        _transcriptionModel.generateContent([
          Content.multi([
            TextPart('Transcribe this audio verbatim. Return only the transcript text with no preamble.'),
            DataPart('audio/mp4', audioBytes),
          ])
        ]).catchError((e) {
          if (kDebugMode) debugPrint('⚠️ Transcription failed: $e');
          // Return empty content to handle gracefully using correct 5-arg constructor
          return GenerateContentResponse(
            [
              Candidate(
                Content.text(''),
                null, // averageScore
                null, // safetyRatings
                null, // index/finishReason? (Fixed type mismatch)
                null  // finishReason
              )
            ], 
            null // promptFeedback
          );
        }),
        
        // Call 2: REASONING (Gemini 3)
        // We inject history and the specific system instruction here.
        () async {
          final promptContent = [
             // System Instruction
             if (systemInstruction != null) Content.text(systemInstruction),
             
             // History (Context Injection)
             if (history != null) ...history,
             
             // Current Turn
             Content.multi([
                TextPart("Here is the user's latest response:"),
                DataPart('audio/mp4', audioBytes),
             ])
          ];
          
          return _reasoningModel.generateContent(promptContent);
        }().catchError((e) {
          if (kDebugMode) debugPrint('⚠️ Reasoning failed: $e');
           return GenerateContentResponse(
            [
              Candidate(
                Content.text("I'm having trouble responding."),
                null, // averageScore
                null, // safetyRatings
                null,    // index
                null  // finishReason
              )
            ], 
            null // promptFeedback
          );
        }),
      ]);

      final transcript = results[0].text?.trim() ?? "Voice note";
      final sherlockText = results[1].text?.trim() ?? "I'm having trouble responding.";
      
      // ✅ ASYNC: Psychometric analysis (Fire and Forget)
      // Doesn't block the UI response
      if (_psychometricService != null) {
        final userId = _authService?.currentUser?.id ?? 'anonymous';
        unawaited(_psychometricService.analyzeTranscript(
          transcript: transcript,
          userId: userId, 
        ));
      }

      // --- STEP 2: SPEECH SYNTHESIS (LAZY) ---
      // Phase 3: We no longer auto-generate audio to save costs.
      // The UI will request audio on demand via generateAudioOnDemand().
      String? sherlockAudioPath; 
      
      // ✅ CONDITIONAL CLEANUP: Only delete if requested
      // This prevents race condition with storage wrapper
      if (deleteAudioAfter) {
        try {
          if (await audioFile.exists()) {
            await audioFile.delete();
            if (kDebugMode) print('🗑️ Deleted raw user audio: $userAudioPath');
          }
        } catch (e) {
          if (kDebugMode) print('⚠️ Failed to cleanup raw audio: $e');
        }
      } else {
        if (kDebugMode) print('📌 Keeping audio for storage: $userAudioPath');
      }

      return VoiceNoteResult(
        userTranscript: transcript,
        sherlockResponse: sherlockText,
        sherlockAudioPath: null, // Lazy TTS
        userAudioPath: userAudioPath, // ✅ Added for storage wrapper
        isError: sherlockText == "I'm having trouble responding.",
      );
      
    } catch (e) {
      // ✅ Ensure cleanup even on error
      if (audioFile != null && await audioFile.exists()) {
        await audioFile.delete().catchError((_) => audioFile!); // Return dummy FS entity
      }
      return VoiceNoteResult.error("My audio processing circuits are jammed. ($e)");
    }
  }
  
  // Clean up a specific TTS file (e.g., after played)
  Future<void> cleanupTTSAudio(String audioPath) async {
    try {
      final file = File(audioPath);
      if (await file.exists()) {
        await file.delete();
        _ttsAudioPaths.remove(audioPath);
        if (kDebugMode) print('🗑️ Deleted TTS audio: $audioPath');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('TTS cleanup failed: $e');
    }
  }

  // Cleanup all TTS from session
  Future<void> cleanupSessionAudio() async {
    if (kDebugMode) debugPrint('🧹 Cleaning branch session audio (${_ttsAudioPaths.length} files)...');
    // Copy list to avoid concurrent modification during async delete
    for (final path in List<String>.from(_ttsAudioPaths)) {
      await cleanupTTSAudio(path);
    }
  }

  // Fallback for text input
  Future<ChatMessage> processText(String text) async {
    try {
      // Lazy TTS for text input too
      return ChatMessage.sherlock(
        text: text,
        audioPath: null,
      );
    } catch (e) {
      return ChatMessage(
        id: 'error',
        role: MessageRole.assistant,
        content: "Processing failed: $e",
        timestamp: DateTime.now(),
        status: MessageStatus.error,
      );
    }
  }

  /// Manually calls the Gemini 2.5 TTS endpoint via REST to bypass SDK constraints
  Future<String?> generateAudioOnDemand(String text) async {
    final String url = "https://generativelanguage.googleapis.com/v1beta/models/${AIModelConfig.ttsModel}:generateContent";

    // NOTE: Use System variable for API KEY in production!
    final String apiKey = AIModelConfig.geminiApiKey; 

    try {
      final response = await http.post(
        Uri.parse("$url?key=$apiKey"),
        headers: {
          "Content-Type": "application/json",
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
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Extract base64 audio
        if (data['candidates'] != null && 
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
              
          final part = data['candidates'][0]['content']['parts'][0];
          
          if (part.containsKey('inlineData') && part['inlineData'].containsKey('data')) {
            final String base64Audio = part['inlineData']['data'];
            if (base64Audio.isNotEmpty) {
               // Decode base64 to bytes
               final audioBytes = base64Decode(base64Audio);

               // 🛠️ CRITICAL FIX: Convert raw PCM to WAV before saving
               final wavBytes = _pcmBytesToWav(audioBytes);

               final dir = await getApplicationDocumentsDirectory();
               final filePath = "${dir.path}/sherlock_reply_${DateTime.now().millisecondsSinceEpoch}.wav";
               final file = File(filePath);

               await file.writeAsBytes(wavBytes);

               _ttsAudioPaths.add(filePath);

               if (kDebugMode) {
                 print("🔊 Saved Sherlock Audio (WAV): $filePath (${wavBytes.length} bytes)");
               }

               return filePath;
            }
          }
        }
        throw Exception("Invalid response structure or empty audio");
      } else {
        throw Exception("API Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      if (kDebugMode) print("Error generating speech: $e");
      return Future.error(e); // Propagate error
    }
  }

  /// Wraps raw PCM data with a WAV header
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
}

class VoiceNoteResult {
  final String userTranscript;
  final String sherlockResponse;
  final String? sherlockAudioPath;
  final String? userAudioPath;
  final bool isError;
  
  VoiceNoteResult({
    required this.userTranscript,
    required this.sherlockResponse,
    this.sherlockAudioPath,
    this.userAudioPath,
    this.isError = false,
  });
  
  factory VoiceNoteResult.error(String message) {
    return VoiceNoteResult(
      userTranscript: '',
      sherlockResponse: message,
      isError: true,
    );
  }
  
  // Helper to convert to ChatMessage (Sherlock)
  ChatMessage toSherlockMessage() => ChatMessage.sherlock(
    text: sherlockResponse,
    audioPath: sherlockAudioPath,
  );
}
