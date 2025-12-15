import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';
import '../models/user_profile.dart';
import '../models/app_settings.dart';

/// Phase 11: Data Safety (Backup & Restore) Service
/// 
/// Provides comprehensive backup and restore functionality for all app data:
/// - Habits with completion history, streaks, and metrics
/// - User profile with identity information
/// - App settings and preferences
/// 
/// **Data Safety Philosophy:**
/// "Protecting user investment is as important as enabling it."
/// - After analytics, users have significant data worth protecting
/// - Essential for Release Candidate status
/// 
/// **Backup Format:** JSON with versioning for future compatibility
/// **File Naming:** atomic_habits_backup_YYYY-MM-DD.json

class BackupService {
  // Backup file version for future compatibility
  static const int _backupVersion = 1;
  
  // Required keys for validation
  static const List<String> _requiredKeys = ['version', 'exportedAt', 'habits', 'userProfile'];
  
  /// Result of a backup operation
  factory BackupResult.success({String? filePath, String? message}) = BackupSuccess;
  factory BackupResult.failure(String error) = BackupFailure;
  
  /// Generate a complete backup of all app data
  /// Returns a BackupResult indicating success or failure
  Future<BackupResult> exportBackup() async {
    try {
      // Open the Hive box
      final box = await Hive.openBox('habit_data');
      
      // Gather all data
      final exportData = await _gatherExportData(box);
      
      // Convert to JSON
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      
      // Generate filename with timestamp
      final timestamp = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final filename = 'atomic_habits_backup_$timestamp.json';
      
      // Get temporary directory for file
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$filename';
      
      // Write file
      final file = File(filePath);
      await file.writeAsString(jsonString);
      
      if (kDebugMode) {
        debugPrint('📦 Backup created: $filePath');
        debugPrint('   Size: ${jsonString.length} bytes');
      }
      
      // Open system share sheet
      final result = await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Atomic Habits Backup - $timestamp',
        text: 'My Atomic Habits app data backup',
      );
      
      if (result.status == ShareResultStatus.success) {
        return BackupSuccess(
          filePath: filePath,
          message: 'Backup exported successfully',
        );
      } else if (result.status == ShareResultStatus.dismissed) {
        // User dismissed the share sheet - still a valid backup was created
        return BackupSuccess(
          filePath: filePath,
          message: 'Backup file created (share dismissed)',
        );
      } else {
        return BackupFailure('Share was unsuccessful');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Backup export failed: $e');
      }
      return BackupFailure('Failed to export backup: $e');
    }
  }
  
  /// Import and restore from a backup file
  /// Returns a BackupResult indicating success or failure
  /// 
  /// **DESTRUCTIVE**: This will overwrite all current data!
  Future<BackupResult> importBackup() async {
    try {
      // Open file picker for JSON files
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );
      
      if (result == null || result.files.isEmpty) {
        return BackupFailure('No file selected');
      }
      
      final file = result.files.first;
      
      // Read file content
      String jsonString;
      if (file.bytes != null) {
        // Web platform returns bytes
        jsonString = utf8.decode(file.bytes!);
      } else if (file.path != null) {
        // Mobile/desktop returns path
        jsonString = await File(file.path!).readAsString();
      } else {
        return BackupFailure('Could not read file content');
      }
      
      // Parse and validate JSON
      final validationResult = _validateBackupJson(jsonString);
      if (validationResult != null) {
        return BackupFailure(validationResult);
      }
      
      // Parse the backup data
      final backupData = json.decode(jsonString) as Map<String, dynamic>;
      
      if (kDebugMode) {
        debugPrint('📥 Importing backup from: ${file.name}');
        debugPrint('   Version: ${backupData['version']}');
        debugPrint('   Exported: ${backupData['exportedAt']}');
      }
      
      return BackupPendingRestore(backupData);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Backup import failed: $e');
      }
      return BackupFailure('Failed to import backup: $e');
    }
  }
  
  /// Actually restore the backup data to Hive storage
  /// Call this after user confirms the overwrite warning
  Future<BackupResult> restoreBackup(Map<String, dynamic> backupData) async {
    try {
      final box = await Hive.openBox('habit_data');
      
      // Clear existing data
      await box.clear();
      
      // Restore habits
      if (backupData['habits'] != null) {
        final habitsJson = backupData['habits'] as List;
        await box.put('habits', habitsJson);
        
        if (kDebugMode) {
          debugPrint('   ✅ Restored ${habitsJson.length} habits');
        }
      }
      
      // Restore user profile
      if (backupData['userProfile'] != null) {
        await box.put('userProfile', backupData['userProfile']);
        
        if (kDebugMode) {
          debugPrint('   ✅ Restored user profile');
        }
      }
      
      // Restore settings
      if (backupData['appSettings'] != null) {
        await box.put('appSettings', backupData['appSettings']);
        
        if (kDebugMode) {
          debugPrint('   ✅ Restored app settings');
        }
      }
      
      // Restore focused habit ID
      if (backupData['focusedHabitId'] != null) {
        await box.put('focusedHabitId', backupData['focusedHabitId']);
      }
      
      // Restore onboarding status
      if (backupData['hasCompletedOnboarding'] != null) {
        await box.put('hasCompletedOnboarding', backupData['hasCompletedOnboarding']);
      }
      
      // Store last restore timestamp
      await box.put('lastRestoreDate', DateTime.now().toIso8601String());
      
      if (kDebugMode) {
        debugPrint('✅ Backup restored successfully!');
      }
      
      return BackupSuccess(
        message: 'Backup restored successfully. Please restart the app.',
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Backup restore failed: $e');
      }
      return BackupFailure('Failed to restore backup: $e');
    }
  }
  
  /// Get backup summary from parsed data (for preview)
  BackupSummary getBackupSummary(Map<String, dynamic> backupData) {
    final habits = backupData['habits'] as List? ?? [];
    final profile = backupData['userProfile'] as Map<String, dynamic>?;
    final exportedAt = backupData['exportedAt'] as String?;
    
    int totalCompletions = 0;
    int totalRecoveries = 0;
    
    for (final habitJson in habits) {
      final habit = habitJson as Map<String, dynamic>;
      final completionHistory = habit['completionHistory'] as List? ?? [];
      final recoveryHistory = habit['recoveryHistory'] as List? ?? [];
      totalCompletions += completionHistory.length;
      totalRecoveries += recoveryHistory.length;
    }
    
    return BackupSummary(
      habitCount: habits.length,
      userName: profile?['name'] as String?,
      totalCompletions: totalCompletions,
      totalRecoveries: totalRecoveries,
      exportedAt: exportedAt != null ? DateTime.tryParse(exportedAt) : null,
      version: backupData['version'] as int? ?? 1,
    );
  }
  
  /// Get the last backup date (if stored)
  Future<DateTime?> getLastBackupDate() async {
    try {
      final box = await Hive.openBox('habit_data');
      final dateString = box.get('lastBackupDate') as String?;
      return dateString != null ? DateTime.tryParse(dateString) : null;
    } catch (e) {
      return null;
    }
  }
  
  /// Store the last backup date
  Future<void> recordBackupDate() async {
    try {
      final box = await Hive.openBox('habit_data');
      await box.put('lastBackupDate', DateTime.now().toIso8601String());
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to record backup date: $e');
      }
    }
  }
  
  /// Get the last restore date (if any)
  Future<DateTime?> getLastRestoreDate() async {
    try {
      final box = await Hive.openBox('habit_data');
      final dateString = box.get('lastRestoreDate') as String?;
      return dateString != null ? DateTime.tryParse(dateString) : null;
    } catch (e) {
      return null;
    }
  }
  
  // ========== Private Methods ==========
  
  /// Gather all data for export
  Future<Map<String, dynamic>> _gatherExportData(Box box) async {
    // Get habits
    final habitsJson = box.get('habits') as List?;
    
    // Get user profile
    final profileJson = box.get('userProfile') as Map?;
    
    // Get app settings
    final settingsJson = box.get('appSettings') as Map?;
    
    // Get focused habit ID
    final focusedHabitId = box.get('focusedHabitId') as String?;
    
    // Get onboarding status
    final hasCompletedOnboarding = box.get('hasCompletedOnboarding', defaultValue: false) as bool;
    
    return {
      'version': _backupVersion,
      'appName': 'Atomic Habits Hook App',
      'exportedAt': DateTime.now().toIso8601String(),
      'habits': habitsJson ?? [],
      'userProfile': profileJson,
      'appSettings': settingsJson,
      'focusedHabitId': focusedHabitId,
      'hasCompletedOnboarding': hasCompletedOnboarding,
    };
  }
  
  /// Validate backup JSON structure
  /// Returns null if valid, error message if invalid
  String? _validateBackupJson(String jsonString) {
    try {
      final data = json.decode(jsonString);
      
      if (data is! Map<String, dynamic>) {
        return 'Invalid backup format: not a JSON object';
      }
      
      // Check for required keys
      for (final key in _requiredKeys) {
        if (!data.containsKey(key)) {
          return 'Invalid backup format: missing "$key" field';
        }
      }
      
      // Validate version
      final version = data['version'];
      if (version is! int || version < 1) {
        return 'Invalid backup version';
      }
      
      // Validate habits is a list
      if (data['habits'] is! List) {
        return 'Invalid backup format: habits must be a list';
      }
      
      // Basic validation of habit structure
      final habits = data['habits'] as List;
      for (int i = 0; i < habits.length; i++) {
        final habit = habits[i];
        if (habit is! Map<String, dynamic>) {
          return 'Invalid habit at index $i';
        }
        if (!habit.containsKey('id') || !habit.containsKey('name')) {
          return 'Invalid habit at index $i: missing id or name';
        }
      }
      
      return null; // Valid!
    } catch (e) {
      return 'Invalid JSON format: $e';
    }
  }
}

/// Result of a backup operation
sealed class BackupResult {
  const BackupResult();
}

/// Successful backup operation
class BackupSuccess extends BackupResult {
  final String? filePath;
  final String? message;
  
  const BackupSuccess({this.filePath, this.message});
}

/// Failed backup operation
class BackupFailure extends BackupResult {
  final String error;
  
  const BackupFailure(this.error);
}

/// Backup loaded and validated, pending user confirmation for restore
class BackupPendingRestore extends BackupResult {
  final Map<String, dynamic> backupData;
  
  const BackupPendingRestore(this.backupData);
}

/// Summary of backup contents for preview
class BackupSummary {
  final int habitCount;
  final String? userName;
  final int totalCompletions;
  final int totalRecoveries;
  final DateTime? exportedAt;
  final int version;
  
  const BackupSummary({
    required this.habitCount,
    this.userName,
    required this.totalCompletions,
    required this.totalRecoveries,
    this.exportedAt,
    required this.version,
  });
  
  String get formattedExportDate {
    if (exportedAt == null) return 'Unknown';
    return DateFormat('MMM d, yyyy • h:mm a').format(exportedAt!);
  }
}
