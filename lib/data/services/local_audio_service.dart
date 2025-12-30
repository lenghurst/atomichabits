import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/local_audio_record.dart';

class LocalAudioService {
  static const String _boxName = 'audio_records';
  Box<LocalAudioRecord>? _audioBox;
  
  /// Initialize Hive and open box
  Future<void> init() async {
    if (kDebugMode) print('🔧 Initializing LocalAudioService...');
    
    // Hive.initFlutter() is called in main, but we ensure adapter registration here
    if (!Hive.isAdapterRegistered(0)) {
       Hive.registerAdapter(LocalAudioRecordAdapter());
    }
    _audioBox = await Hive.openBox<LocalAudioRecord>(_boxName);
    
    if (kDebugMode) {
      print('✅ LocalAudioService initialized (${_audioBox?.length ?? 0} records)');
    }
  }
  
  /// Save audio record reference
  Future<void> saveAudioRecord(LocalAudioRecord record) async {
    if (_audioBox == null) throw StateError('LocalAudioService not initialized');
    
    // Optionally move file to permanent storage here if not already done
    // For now, we assume the path provided is where we want to keep it or it's managed elsewhere
    // If we want to persist user recordings that are in cache, we should copy them.
    
    // Copy user audio to persistent location
    final persistentUserPath = await _copyToPersistent(record.userAudioPath);
    String? persistentAiPath;
    if (record.aiAudioPath != null) {
      persistentAiPath = await _copyToPersistent(record.aiAudioPath!);
    }

    final persistentRecord = LocalAudioRecord(
      id: record.id,
      userAudioPath: persistentUserPath,
      aiAudioPath: persistentAiPath,
      userAudioDurationMs: record.userAudioDurationMs,
      aiAudioDurationMs: record.aiAudioDurationMs,
      createdAt: record.createdAt,
      conversationId: record.conversationId,
      isOnboarding: record.isOnboarding,
    );
    
    await _audioBox!.put(persistentRecord.id, persistentRecord);
    
    if (kDebugMode) {
      print('🔊 Saved audio record: ${persistentRecord.id}');
    }
  }

  Future<String> _copyToPersistent(String sourcePath) async {
    final file = File(sourcePath);
    if (!await file.exists()) return sourcePath; // Should check/handle error

    final appDir = await getApplicationDocumentsDirectory();
    final fileName = path.basename(sourcePath);
    final targetPath = path.join(appDir.path, 'voice_notes', fileName);
    
    final targetFile = File(targetPath);
    if (!await targetFile.parent.exists()) {
      await targetFile.parent.create(recursive: true);
    }
    
    await file.copy(targetPath);
    return targetPath;
  }
  
  /// Get audio record by turn ID
  LocalAudioRecord? getAudioRecord(String turnId) {
    if (_audioBox == null) return null;
    return _audioBox!.get(turnId);
  }
  
  /// Get all audio records for a conversation
  List<LocalAudioRecord> getConversationAudio(String conversationId) {
    if (_audioBox == null) return [];
    
    return _audioBox!.values
      .where((record) => record.conversationId == conversationId)
      .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }
  
  /// Delete audio files and record
  Future<void> deleteAudioRecord(String turnId) async {
    if (_audioBox == null) return;
    
    final record = _audioBox!.get(turnId);
    if (record == null) return;
    
    // Delete actual audio files
    try {
      final userFile = File(record.userAudioPath);
      if (await userFile.exists()) {
        await userFile.delete();
        if (kDebugMode) print('🗑️ Deleted user audio: ${record.userAudioPath}');
      }
      
      if (record.aiAudioPath != null) {
        final aiFile = File(record.aiAudioPath!);
        if (await aiFile.exists()) {
          await aiFile.delete();
          if (kDebugMode) print('🗑️ Deleted AI audio: ${record.aiAudioPath}');
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Audio cleanup failed: $e');
    }
    
    // Remove record from Hive
    await _audioBox!.delete(turnId);
  }
  
  /// Get total local storage size
  Future<int> getTotalStorageBytes() async {
    if (_audioBox == null) return 0;
    
    int totalBytes = 0;
    
    for (final record in _audioBox!.values) {
      try {
        final userFile = File(record.userAudioPath);
        if (await userFile.exists()) {
          totalBytes += await userFile.length();
        }
        
        if (record.aiAudioPath != null) {
          final aiFile = File(record.aiAudioPath!);
          if (await aiFile.exists()) {
            totalBytes += await aiFile.length();
          }
        }
      } catch (e) {
        if (kDebugMode) debugPrint('⚠️ Size check failed: $e');
      }
    }
    
    return totalBytes;
  }
  
  /// Get storage usage stats
  Future<Map<String, dynamic>> getStorageStats() async {
    final totalBytes = await getTotalStorageBytes();
    final recordCount = _audioBox?.length ?? 0;
    
    return {
      'total_mb': (totalBytes / 1024 / 1024).toStringAsFixed(2),
      'record_count': recordCount,
      'avg_size_kb': recordCount > 0 
        ? ((totalBytes / recordCount) / 1024).toStringAsFixed(2)
        : '0',
    };
  }
  
  /// Close the box (cleanup)
  Future<void> close() async {
    await _audioBox?.close();
    if (kDebugMode) print('📦 LocalAudioService closed');
  }
}
