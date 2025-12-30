import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Service responsible for background cleanup of orphaned audio files.
/// Used to maintain hygiene and ensure 24h retention policy is enforced
/// even if app crashes or proper cleanup wasn't triggered.
class AudioCleanupService {
  /// Delete all TTS files older than 24 hours
  static Future<void> cleanupOldTTSFiles() async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final directory = Directory(docsDir.path);
      
      if (!await directory.exists()) return;
      
      final now = DateTime.now();
      final cutoff = now.subtract(const Duration(hours: 24));
      
      await for (final entity in directory.list()) {
        if (entity is File && entity.path.contains('sherlock_reply_')) {
          final stat = await entity.stat();
          
          if (stat.modified.isBefore(cutoff)) {
            await entity.delete();
            if (kDebugMode) {
              debugPrint('🧹 Deleted old TTS file: ${entity.path}');
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Background cleanup failed: $e');
    }
  }
}
