
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart'; // Add this import
import 'package:plugin_platform_interface/plugin_platform_interface.dart'; // And this one
import 'package:atomic_habits_hook_app/data/services/audio_cleanup_service.dart';
import 'package:atomic_habits_hook_app/data/services/gemini_voice_note_service.dart';
import 'package:atomic_habits_hook_app/data/services/voice_session_manager.dart'; // Import to check public API if needed, but we test logic mainly

// Mock PathProvider to control where files are written
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
    // Create a temporary directory for tests
    testDir = await Directory.systemTemp.createTemp('phase4_test_');
    // Register the mock
    PathProviderPlatform.instance = MockPathProviderPlatform(testDir);
  });
  
  tearDown(() async {
    // Cleanup the directory
    if (await testDir.exists()) {
      await testDir.delete(recursive: true);
    }
  });

  group('Phase 4: Audio Cleanup Logic', () {
    test('AudioCleanupService deletes files older than 24 hours', () async {
      // 1. Create a "fresh" file (should NOT be deleted)
      final freshFile = File('${testDir.path}/sherlock_reply_fresh.wav');
      await freshFile.writeAsString('fresh content');
      // Set timestamp to now (default)

      // 2. Create an "old" file (SHOULD be deleted)
      final oldFile = File('${testDir.path}/sherlock_reply_old.wav');
      await oldFile.writeAsString('old content');
      
      // Manually set modification time to 25 hours ago
      final oldTime = DateTime.now().subtract(const Duration(hours: 25));
      await oldFile.setLastModified(oldTime);
      
      // 3. Create a non-TTS file (should NOT be deleted even if old)
      final otherFile = File('${testDir.path}/other_data.txt');
      await otherFile.writeAsString('important data');
      await otherFile.setLastModified(oldTime);
      
      // Verify setup
      expect(await freshFile.exists(), true);
      expect(await oldFile.exists(), true);
      expect(await otherFile.exists(), true);
      
      // RUN CLEANUP
      await AudioCleanupService.cleanupOldTTSFiles();
      
      // Verify results
      expect(await freshFile.exists(), true, reason: "Fresh file should persist");
      expect(await oldFile.exists(), false, reason: "Old TTS file should be deleted");
      expect(await otherFile.exists(), true, reason: "Non-TTS file should persist");
    });
  });
}
