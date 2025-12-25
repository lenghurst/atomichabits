import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/app_settings.dart';
import '../repositories/settings_repository.dart';
import '../../core/logging/app_logger.dart';

/// Enum for haptic feedback types
enum HapticFeedbackType {
  light,
  medium,
  heavy,
  selection,
}

/// SettingsProvider: Manages app configuration (Theme, Sound, Haptics).
/// 
/// Decoupled from Hive via SettingsRepository injection.
/// Satisfies: Uncle Bob (DIP), Flux (Specific Scope).
class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repository;
  
  AppSettings _settings = const AppSettings();
  bool _isLoading = true;

  SettingsProvider(this._repository);

  // === Getters ===
  AppSettings get settings => _settings;
  ThemeMode get themeMode => _settings.themeMode;
  bool get soundEnabled => _settings.soundEnabled;
  bool get hapticsEnabled => _settings.hapticsEnabled;
  bool get notificationsEnabled => _settings.notificationsEnabled;
  bool get isLoading => _isLoading;
  bool get developerMode => _settings.developerMode;
  bool get developerLogging => _settings.developerLogging;

  /// Initialize the provider by loading from repository
  Future<void> initialize() async {
    try {
      final loadedSettings = await _repository.getSettings();
      if (loadedSettings != null) {
        _settings = loadedSettings;
        // Phase 39: Initialize unified logging based on settings
        AppLogger.globalEnabled = _settings.developerMode && _settings.developerLogging;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('SettingsProvider: Error initializing: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update all settings at once
  Future<void> updateSettings(AppSettings newSettings) async {
    final developerLoggingChanged = _settings.developerLogging != newSettings.developerLogging;
    final developerModeChanged = _settings.developerMode != newSettings.developerMode;
    
    _settings = newSettings;
    await _repository.saveSettings(_settings);

    if (developerLoggingChanged || developerModeChanged) {
      AppLogger.globalEnabled = newSettings.developerMode && newSettings.developerLogging;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    await _repository.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _settings = _settings.copyWith(soundEnabled: enabled);
    await _repository.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    _settings = _settings.copyWith(hapticsEnabled: enabled);
    await _repository.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _settings = _settings.copyWith(notificationsEnabled: enabled);
    await _repository.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setDefaultNotificationTime(String time) async {
    _settings = _settings.copyWith(defaultNotificationTime: time);
    await _repository.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setShowQuotes(bool show) async {
    _settings = _settings.copyWith(showQuotes: show);
    await _repository.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setDeveloperMode(bool enabled) async {
    _settings = _settings.copyWith(developerMode: enabled);
    await _repository.saveSettings(_settings);
    AppLogger.globalEnabled = enabled && _settings.developerLogging;
    notifyListeners();
  }

  Future<void> setDeveloperLogging(bool enabled) async {
    _settings = _settings.copyWith(developerLogging: enabled);
    await _repository.saveSettings(_settings);
    AppLogger.globalEnabled = _settings.developerMode && enabled;
    notifyListeners();
  }

  /// Trigger haptic feedback if enabled
  void triggerHaptic(HapticFeedbackType type) {
    if (!_settings.hapticsEnabled) return;
    switch (type) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selection:
        HapticFeedback.selectionClick();
        break;
    }
  }
}
