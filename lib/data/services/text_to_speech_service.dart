import 'dart:io';

/// Abstract service for generating audio from text (TTS)
abstract class TextToSpeechService {
  /// Synthesize text to audio and return the path to the local file
  /// [text]: The text to speak
  /// [voiceProfile]: Optional identifier for the voice (e.g. "sherlock_v1")
  Future<String> synthesize(String text, {String? voiceProfile});
  
  /// Dispose resources
  void dispose();
}

/// Mock implementation that returns a dummy file path (or fails gracefully)
/// Used when no API key is present.
class MockTextToSpeechService implements TextToSpeechService {
  @override
  Future<String> synthesize(String text, {String? voiceProfile}) async {
    // In a real mock, we might return a path to a pre-bundled "beeps" file
    // or just an empty string and handle it in the UI.
    // For now, we'll return an empty string to signify "No Audio".
    return "";
  }
  
  @override
  void dispose() {}
}
