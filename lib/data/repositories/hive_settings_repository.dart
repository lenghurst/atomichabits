import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/app_settings.dart';
import 'settings_repository.dart';

/// Hive implementation of SettingsRepository.
/// All Hive-specific code is isolated here.
class HiveSettingsRepository implements SettingsRepository {
  Box? _dataBox;
  static const String _boxName = 'habit_data';
  static const String _settingsKey = 'appSettings';
  
  @override
  Future<void> init() async {
    try {
      _dataBox = await Hive.openBox(_boxName);
    } catch (e) {
      if (kDebugMode) debugPrint('HiveSettingsRepository: Error opening box: $e');
    }
  }
  
  @override
  Future<AppSettings?> getSettings() async {
    if (_dataBox == null) return null;
    final settingsJson = _dataBox!.get(_settingsKey);
    if (settingsJson != null) {
      return AppSettings.fromJson(Map<String, dynamic>.from(settingsJson));
    }
    return null;
  }
  
  @override
  Future<void> saveSettings(AppSettings settings) async {
    if (_dataBox == null) return;
    await _dataBox!.put(_settingsKey, settings.toJson());
  }
  
  @override
  Future<void> clear() async {
    if (_dataBox == null) return;
    await _dataBox!.delete(_settingsKey);
  }
}
