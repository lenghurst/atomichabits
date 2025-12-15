import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../data/app_state.dart';
import '../../data/models/app_settings.dart';

/// Settings screen - Phase 6: Full settings persistence
/// 
/// **Features:**
/// - Theme selection (System/Light/Dark)
/// - Notification preferences with time picker
/// - Sound and haptic feedback toggles
/// - Motivational quotes toggle
/// - Reset data option with confirmation
/// - App info and version
/// 
/// **Vibecoding Architecture:**
/// Uses Consumer<AppState> for reactive updates
/// All changes persist via AppState → Hive
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final settings = appState.settings;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/dashboard'),
            ),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 8),
                
                // ========== Appearance Section ==========
                _buildSectionTitle(context, 'Appearance'),
                Card(
                  child: Column(
                    children: [
                      // Theme Selection
                      ListTile(
                        leading: const Icon(Icons.palette),
                        title: const Text('Theme'),
                        subtitle: Text(_getThemeName(settings.themeMode)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showThemeSelector(context, appState),
                      ),
                      const Divider(height: 1),
                      // Show Quotes Toggle
                      SwitchListTile(
                        secondary: const Icon(Icons.format_quote),
                        title: const Text('Motivational Quotes'),
                        subtitle: const Text('Show daily inspiration'),
                        value: settings.showQuotes,
                        onChanged: (value) => appState.setShowQuotes(value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // ========== Notifications Section ==========
                _buildSectionTitle(context, 'Notifications'),
                Card(
                  child: Column(
                    children: [
                      // Master Notification Toggle
                      SwitchListTile(
                        secondary: const Icon(Icons.notifications),
                        title: const Text('Daily Reminders'),
                        subtitle: const Text('Get notified to complete habits'),
                        value: settings.notificationsEnabled,
                        onChanged: (value) => appState.setNotificationsEnabled(value),
                      ),
                      // Notification Time (only visible if notifications enabled)
                      if (settings.notificationsEnabled) ...[
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.access_time),
                          title: const Text('Default Reminder Time'),
                          subtitle: Text(_formatTime(settings.notificationTimeOfDay)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showTimePicker(context, appState, settings),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // ========== Feedback Section ==========
                _buildSectionTitle(context, 'Feedback'),
                Card(
                  child: Column(
                    children: [
                      // Sound Toggle
                      SwitchListTile(
                        secondary: const Icon(Icons.volume_up),
                        title: const Text('Sound Effects'),
                        subtitle: const Text('Play sounds on completion'),
                        value: settings.soundEnabled,
                        onChanged: (value) => appState.setSoundEnabled(value),
                      ),
                      const Divider(height: 1),
                      // Haptic Toggle
                      SwitchListTile(
                        secondary: const Icon(Icons.vibration),
                        title: const Text('Haptic Feedback'),
                        subtitle: const Text('Vibrate on interactions'),
                        value: settings.hapticsEnabled,
                        onChanged: (value) => appState.setHapticsEnabled(value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // ========== Navigation Section ==========
                _buildSectionTitle(context, 'Navigation'),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.dashboard),
                        title: const Text('Dashboard'),
                        subtitle: const Text('View all habits'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.go('/dashboard'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.calendar_month),
                        title: const Text('History'),
                        subtitle: const Text('View completion calendar'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.go('/history'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // ========== Data & Storage Section ==========
                _buildSectionTitle(context, 'Data & Storage'),
                Card(
                  child: Column(
                    children: [
                      // Backup & Restore (Phase 11)
                      ListTile(
                        leading: const Icon(Icons.backup),
                        title: const Text('Backup & Restore'),
                        subtitle: const Text('Export or import your data'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/data-management'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.delete_forever, color: Colors.red.shade700),
                        title: Text(
                          'Reset All Data',
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                        subtitle: const Text('Delete all habits and settings'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showResetConfirmation(context, appState),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // ========== About Section ==========
                _buildSectionTitle(context, 'About'),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.book),
                        title: const Text('About Atomic Habits'),
                        subtitle: const Text('Framework principles'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showInfoDialog(context),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text('App Info'),
                        subtitle: const Text('Version 4.10.0 (Phase 13)'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showAboutDialog(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // App branding footer
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.self_improvement,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Atomic Habits Hook App',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Graceful Consistency > Fragile Streaks',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System default';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _showThemeSelector(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Choose Theme',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.phone_android),
              title: const Text('System default'),
              trailing: appState.themeMode == ThemeMode.system
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                appState.setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Light'),
              trailing: appState.themeMode == ThemeMode.light
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                appState.setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark'),
              trailing: appState.themeMode == ThemeMode.dark
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                appState.setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _showTimePicker(
    BuildContext context,
    AppState appState,
    AppSettings settings,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: settings.notificationTimeOfDay,
      helpText: 'Set Default Reminder Time',
    );
    
    if (picked != null) {
      final timeString = AppSettings.timeOfDayToString(picked);
      appState.setDefaultNotificationTime(timeString);
    }
  }

  void _showResetConfirmation(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red.shade700),
            const SizedBox(width: 8),
            const Text('Reset All Data?'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will permanently delete:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• All your habits'),
            Text('• Your completion history'),
            Text('• Your streaks and scores'),
            Text('• All app settings'),
            SizedBox(height: 16),
            Text(
              'This action cannot be undone.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade700,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await appState.clearAllData();
              if (context.mounted) {
                context.go('/');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data has been reset'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.menu_book, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text('Framework'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This app combines three powerful frameworks:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                "James Clear's Atomic Habits",
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.deepPurple),
              ),
              SizedBox(height: 4),
              Text('• Identity-based habits'),
              Text('• 4 Laws of Behavior Change'),
              Text('• 2-minute rule (Tiny Versions)'),
              Text('• Habit stacking'),
              Text('• Implementation intentions'),
              SizedBox(height: 12),
              Text(
                "Nir Eyal's Hook Model",
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.deepPurple),
              ),
              SizedBox(height: 4),
              Text('• Trigger → Action → Reward → Investment'),
              Text('• Variable rewards for engagement'),
              Text('• Investment for retention'),
              SizedBox(height: 12),
              Text(
                "B.J. Fogg's Behavior Model",
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.deepPurple),
              ),
              SizedBox(height: 4),
              Text('• B = MAP (Motivation × Ability × Prompt)'),
              Text('• Make it tiny to maximize ability'),
              Text('• Anchor to existing habits'),
              SizedBox(height: 16),
              Text(
                'Our Philosophy: Graceful Consistency > Fragile Streaks',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: 'Atomic Habits Hook App',
        applicationVersion: '4.10.0 (Phase 13)',
        applicationIcon: const Icon(
          Icons.self_improvement,
          size: 48,
          color: Colors.deepPurple,
        ),
        applicationLegalese: '© 2025 Atomic Habits Hook App\n\n'
            'Built with Flutter and ❤️\n\n'
            'Inspired by James Clear, Nir Eyal, and B.J. Fogg',
        children: const [
          SizedBox(height: 16),
          Text(
            'Completed Phases:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('✅ Phase 1: AI Onboarding (Magic Wand)'),
          Text('✅ Phase 2: Conversational UI'),
          Text('✅ Phase 3: Multi-Habit Engine'),
          Text('✅ Phase 4: Dashboard'),
          Text('✅ Phase 5: History & Calendar'),
          Text('✅ Phase 6: Settings & Polish'),
          Text('✅ Phase 7: Weekly Review with AI'),
          Text('✅ Phase 9: Home Screen Widgets'),
          Text('✅ Phase 10: Analytics Dashboard'),
          Text('✅ Phase 11: Backup & Restore'),
          Text('✅ Phase 12: Bad Habit Protocol'),
          Text('✅ Phase 13: Habit Stacking'),
        ],
      ),
    );
  }
}
