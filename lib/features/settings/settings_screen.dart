import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../data/app_state.dart';

/// Settings screen - Notification settings and app configuration
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isRequestingPermission = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/today'),
            ),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 16),

                // App info section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.self_improvement,
                          size: 64,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Atomic Habits Hook App',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Version 1.0.0',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Notifications section
                _buildSectionTitle(context, 'Notifications'),
                _buildNotificationSettings(context, appState),
                const Divider(),

                // Account section
                _buildSectionTitle(context, 'Account'),
                _buildSettingsTile(
                  context,
                  icon: Icons.person,
                  title: 'Profile',
                  subtitle: 'Edit your identity and name',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon!')),
                    );
                  },
                ),
                const Divider(),

                // Habits section
                _buildSectionTitle(context, 'Habits'),
                _buildSettingsTile(
                  context,
                  icon: Icons.edit,
                  title: 'Edit Habit',
                  subtitle: 'Modify your current habit',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon!')),
                    );
                  },
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.add_circle,
                  title: 'Add New Habit',
                  subtitle: 'Create additional habits',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon!')),
                    );
                  },
                ),
                const Divider(),

                // Data section
                _buildSectionTitle(context, 'Data'),
                _buildSettingsTile(
                  context,
                  icon: Icons.history,
                  title: 'Habit History',
                  subtitle: 'View your past completions',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon!')),
                    );
                  },
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.backup,
                  title: 'Backup & Restore',
                  subtitle: 'Save your data',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon!')),
                    );
                  },
                ),
                const Divider(),

                // About section
                _buildSectionTitle(context, 'About'),
                _buildSettingsTile(
                  context,
                  icon: Icons.book,
                  title: 'Learn About Atomic Habits',
                  subtitle: 'Principles and frameworks',
                  onTap: () {
                    _showInfoDialog(context);
                  },
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.info,
                  title: 'App Information',
                  subtitle: 'Version, credits, and licenses',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Atomic Habits Hook App',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(Icons.self_improvement),
                      children: [
                        const Text(
                          'An app to help you build better habits using principles from '
                          'James Clear\'s Atomic Habits and Nir Eyal\'s Hook Model.',
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildNotificationSettings(BuildContext context, AppState appState) {
    final hasPermission = appState.hasNotificationPermission;
    final notificationsEnabled = appState.notificationsEnabled;
    final currentTime = appState.currentReminderTime ?? '09:00';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main notification toggle
            Row(
              children: [
                Icon(
                  notificationsEnabled
                      ? Icons.notifications_active
                      : Icons.notifications_off,
                  color: notificationsEnabled ? Colors.deepPurple : Colors.grey,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Daily Reminders',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        notificationsEnabled
                            ? 'Get reminded to complete your habit'
                            : 'Reminders are turned off',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: notificationsEnabled,
                  onChanged: (value) async {
                    if (value && !hasPermission) {
                      // Request permission first
                      await _requestPermission(context, appState);
                    } else {
                      await appState.setNotificationsEnabled(value);
                    }
                  },
                ),
              ],
            ),

            // Permission warning
            if (notificationsEnabled && !hasPermission) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Notification permission required',
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _isRequestingPermission
                          ? null
                          : () => _requestPermission(context, appState),
                      child: _isRequestingPermission
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Grant'),
                    ),
                  ],
                ),
              ),
            ],

            // Reminder time picker
            if (notificationsEnabled) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _showTimePicker(context, appState, currentTime),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Reminder Time',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _formatTime(currentTime),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ],

            // Test notification button
            if (notificationsEnabled && hasPermission) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await appState.showTestNotification();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Test notification sent!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.send, size: 18),
                  label: const Text('Send Test Notification'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _requestPermission(BuildContext context, AppState appState) async {
    setState(() {
      _isRequestingPermission = true;
    });

    try {
      final granted = await appState.requestNotificationPermission();

      if (context.mounted) {
        if (granted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification permission granted!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission denied. Please enable in device settings.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRequestingPermission = false;
        });
      }
    }
  }

  Future<void> _showTimePicker(
    BuildContext context,
    AppState appState,
    String currentTime,
  ) async {
    // Parse current time
    final parts = currentTime.split(':');
    final hour = int.tryParse(parts[0]) ?? 9;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final newTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      await appState.updateReminderTime(newTime);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reminder time updated to ${_formatTime(newTime)}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return time;
    }
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About This App'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This app combines:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('James Clear\'s Atomic Habits'),
              Text('  - Identity-based habits'),
              Text('  - 4 Laws of Behavior Change'),
              Text('  - 2-minute rule'),
              Text('  - Habit stacking'),
              SizedBox(height: 12),
              Text('Nir Eyal\'s Hook Model'),
              Text('  - Trigger -> Action -> Reward -> Investment'),
              SizedBox(height: 12),
              Text('B.J. Fogg\'s Behavior Model'),
              Text('  - Behavior = Motivation x Ability x Prompt'),
              SizedBox(height: 16),
              Text(
                'Push Notifications = Make it Obvious',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Daily reminders serve as external triggers that cue the habit loop. '
                'Without these prompts, you must rely on memory alone.',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}
