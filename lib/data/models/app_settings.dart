import 'package:flutter/material.dart';

/// App-wide settings that persist across sessions
/// 
/// **Phase 6: Settings & Polish**
/// Follows the project's data model conventions:
/// - Immutable with copyWith
/// - JSON serialization for Hive persistence
/// - Default values for safe initialization
class AppSettings {
  /// Theme mode: system, light, or dark
  final ThemeMode themeMode;
  
  /// Whether to play sounds on completion/actions
  final bool soundEnabled;
  
  /// Whether to use haptic feedback
  final bool hapticsEnabled;
  
  /// Default notification time for daily reminders (HH:MM format)
  final String defaultNotificationTime;
  
  /// Whether notifications are globally enabled
  final bool notificationsEnabled;
  
  /// Whether to show motivational quotes
  final bool showQuotes;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.defaultNotificationTime = '08:00',
    this.notificationsEnabled = true,
    this.showQuotes = true,
  });

  /// Create a copy with modified values
  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? soundEnabled,
    bool? hapticsEnabled,
    String? defaultNotificationTime,
    bool? notificationsEnabled,
    bool? showQuotes,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      defaultNotificationTime: defaultNotificationTime ?? this.defaultNotificationTime,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      showQuotes: showQuotes ?? this.showQuotes,
    );
  }

  /// Convert to JSON for Hive persistence
  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.index,
      'soundEnabled': soundEnabled,
      'hapticsEnabled': hapticsEnabled,
      'defaultNotificationTime': defaultNotificationTime,
      'notificationsEnabled': notificationsEnabled,
      'showQuotes': showQuotes,
    };
  }

  /// Create from JSON (Hive persistence)
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: ThemeMode.values[json['themeMode'] as int? ?? 0],
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      defaultNotificationTime: json['defaultNotificationTime'] as String? ?? '08:00',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      showQuotes: json['showQuotes'] as bool? ?? true,
    );
  }

  /// Parse notification time to TimeOfDay
  TimeOfDay get notificationTimeOfDay {
    final parts = defaultNotificationTime.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 8,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
  }

  /// Format TimeOfDay to string
  static String timeOfDayToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'AppSettings(theme: $themeMode, sound: $soundEnabled, haptics: $hapticsEnabled, '
        'notifications: $notificationsEnabled @ $defaultNotificationTime, quotes: $showQuotes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.themeMode == themeMode &&
        other.soundEnabled == soundEnabled &&
        other.hapticsEnabled == hapticsEnabled &&
        other.defaultNotificationTime == defaultNotificationTime &&
        other.notificationsEnabled == notificationsEnabled &&
        other.showQuotes == showQuotes;
  }

  @override
  int get hashCode {
    return Object.hash(
      themeMode,
      soundEnabled,
      hapticsEnabled,
      defaultNotificationTime,
      notificationsEnabled,
      showQuotes,
    );
  }
}
