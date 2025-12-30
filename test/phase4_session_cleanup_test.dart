import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:atomic_habits_hook_app/data/services/gemini_voice_note_service.dart';

// Mock PathProvider
class MockPathProviderPlatform extends Fake with MockPlatformInterfaceMixin implements PathProviderPlatform {
  final Directory tempDir;
  
  MockPathProviderPlatform(this.tempDir);
  
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return tempDir.path;
  }
}

void main() {
  late Directory testDir;
  
  setUp(() async {
    testDir = await Directory.systemTemp.createTemp('phase4_session_cleanup_');
    PathProviderPlatform.instance = MockPathProviderPlatform(testDir);
  });
  
  tearDown(() async {
    if (await testDir.exists()) {
      await testDir.delete(recursive: true);
    }
  });

  group('Phase 4: Session Cleanup Integration', () {
    test('Session cleanup deletes TTS files immediately', () async {
      final service = GeminiVoiceNoteService();
      
      // 1. Simulate generated TTS audio by creating dummy files
      final file1 = File('${testDir.path}/sherlock_reply_1.wav');
      final file2 = File('${testDir.path}/sherlock_reply_2.wav');
      
      await file1.writeAsString('dummy audio 1');
      await file2.writeAsString('dummy audio 2');
      
      // 2. Register them with the service (simulating internal tracking)
      service.addAudioPathForTesting(file1.path);
      service.addAudioPathForTesting(file2.path);
      
      // Verify files exist and are tracked
      expect(await file1.exists(), true);
      expect(await file2.exists(), true);
      expect(service.ttsAudioPaths.contains(file1.path), true);
      expect(service.ttsAudioPaths.contains(file2.path), true);
      
      // 3. Call session cleanup
      await service.cleanupSessionAudio();
      
      // 4. Verify files deleted
      expect(await file1.exists(), false, reason: 'File 1 should be deleted');
      expect(await file2.exists(), false, reason: 'File 2 should be deleted');
      
      // 5. Verify tracking cleared
      expect(service.ttsAudioPaths.isEmpty, true, reason: 'Tracking set should be cleared');
    });
  });
}
