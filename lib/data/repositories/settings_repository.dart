import '../models/app_settings.dart';

/// Abstract interface for settings persistence.
/// Decouples the Provider layer from the Infrastructure layer (Hive).
abstract class SettingsRepository {
  /// Initialize the repository (open boxes, etc.)
  Future<void> init();
  
  /// Load settings from storage
  Future<AppSettings?> getSettings();
  
  /// Save settings to storage
  Future<void> saveSettings(AppSettings settings);
  
  /// Clear all settings
  Future<void> clear();
}
