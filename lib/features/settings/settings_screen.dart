import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../data/app_state.dart';
import '../../data/review_service.dart';
import '../../widgets/weekly_review_dialog.dart';

/// Settings screen - placeholder for future features
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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

            // Settings sections (placeholders)
            _buildSectionTitle(context, 'Account'),
            _buildSettingsTile(
              context,
              icon: Icons.person,
              title: 'Profile',
              subtitle: 'Edit your identity and name',
              onTap: () {
                // TODO: Navigate to profile edit screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon!')),
                );
              },
            ),
            const Divider(),
            
            _buildSectionTitle(context, 'Habits'),
            _buildSettingsTile(
              context,
              icon: Icons.edit,
              title: 'Edit Habit',
              subtitle: 'Modify your current habit',
              onTap: () {
                // TODO: Navigate to habit edit screen
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
                // TODO: Navigate to add habit screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon!')),
                );
              },
            ),
            const Divider(),

            // Phase 4 & 5: Avatar and Notification Settings
            _buildSectionTitle(context, 'Personalisation'),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.person_outline),
                    title: const Text('Identity avatar'),
                    subtitle: const Text('Show a small visual that grows with your habit'),
                    value: appState.avatarEnabled,
                    onChanged: (bool value) {
                      appState.updateAvatarEnabled(value);
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_outlined),
                    title: const Text('Habit reminders'),
                    subtitle: const Text('Send a daily nudge when it\'s time for your tiny habit'),
                    value: appState.userProfile?.notificationsEnabled ?? true,
                    onChanged: (bool value) {
                      appState.updateNotificationsEnabled(value);
                    },
                  ),
                ],
              ),
            ),
            const Divider(),

            _buildSectionTitle(context, 'Data'),
            _buildSettingsTile(
              context,
              icon: Icons.history,
              title: 'Habit History',
              subtitle: 'View your past completions',
              onTap: () {
                // TODO: Navigate to history screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon!')),
                );
              },
            ),
            _buildSettingsTile(
              context,
              icon: Icons.analytics_outlined,
              title: 'Generate Weekly Review',
              subtitle: 'Get insights on your progress',
              onTap: () => _handleGenerateWeeklyReview(context, appState),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.backup,
              title: 'Backup & Restore',
              subtitle: 'Save your data',
              onTap: () {
                // TODO: Implement backup
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon!')),
                );
              },
            ),
            const Divider(),
            
            _buildSectionTitle(context, 'About'),
            _buildSettingsTile(
              context,
              icon: Icons.book,
              title: 'Learn About Atomic Habits',
              subtitle: 'Principles and frameworks',
              onTap: () {
                // TODO: Show info dialog
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
              Text('• James Clear\'s Atomic Habits'),
              Text('  - Identity-based habits'),
              Text('  - 4 Laws of Behavior Change'),
              Text('  - 2-minute rule'),
              Text('  - Habit stacking'),
              SizedBox(height: 12),
              Text('• Nir Eyal\'s Hook Model'),
              Text('  - Trigger → Action → Reward → Investment'),
              SizedBox(height: 12),
              Text('• B.J. Fogg\'s Behavior Model'),
              Text('  - Behavior = Motivation × Ability × Prompt'),
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

  /// Generate and show weekly review (Phase 6)
  Future<void> _handleGenerateWeeklyReview(
      BuildContext context, AppState appState) async {
    if (appState.currentHabit == null || appState.userProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No habit data available for review'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating weekly review...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final habit = appState.currentHabit!;
      final profile = appState.userProfile!;

      // Build context for weekly review
      final reviewContext = WeeklyReviewContext(
        identity: profile.identity,
        habitName: habit.name,
        tinyVersion: habit.tinyVersion,
        currentStreak: habit.currentStreak,
        totalCompletions: habit.totalCompletions,
        completionHistory: habit.completionHistory,
        daysToReview: 7, // Last 7 days
      );

      // Call review service
      final service = ReviewService();
      final result = await service.generateWeeklyReview(reviewContext);

      // Close loading dialog
      if (context.mounted) Navigator.of(context).pop();

      // Show review dialog
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => WeeklyReviewDialog(review: result),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) Navigator.of(context).pop();

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to generate review. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
