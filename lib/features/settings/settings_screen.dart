import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../data/app_state.dart';
import '../../data/models/habit.dart';

/// Settings screen - Manage habits and app settings
///
/// MULTIPLE HABITS SUPPORT:
/// - Shows list of all habits with quick actions
/// - Add new habits
/// - Delete habits
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final habits = appState.habits;

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
                          'Version 1.1.0',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tracking ${habits.length} habit${habits.length == 1 ? '' : 's'}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Settings sections
                _buildSectionTitle(context, 'Account'),
                _buildSettingsTile(
                  context,
                  icon: Icons.person,
                  title: 'Profile',
                  subtitle: appState.userProfile != null
                      ? appState.userProfile!.identity
                      : 'Edit your identity and name',
                  onTap: () {
                    // TODO: Navigate to profile edit screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon!')),
                    );
                  },
                ),
                const Divider(),

                _buildSectionTitle(context, 'Habits'),

                // Add New Habit tile - NOW FUNCTIONAL
                _buildSettingsTile(
                  context,
                  icon: Icons.add_circle,
                  title: 'Add New Habit',
                  subtitle: 'Create additional habits to track',
                  onTap: () => context.go('/add-habit'),
                ),

                // Habits list
                if (habits.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...habits.map((habit) => _buildHabitTile(context, habit, appState)),
                ],

                const Divider(),

                _buildSectionTitle(context, 'Data'),
                _buildSettingsTile(
                  context,
                  icon: Icons.history,
                  title: 'Habit History',
                  subtitle: 'View your past completions',
                  onTap: () {
                    // Navigate to history for the selected/first habit
                    final appState = context.read<AppState>();
                    final habitId = appState.selectedHabitId ??
                        (appState.habits.isNotEmpty ? appState.habits.first.id : null);
                    if (habitId != null) {
                      context.go('/history/$habitId');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No habits to view history for')),
                      );
                    }
                  },
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
                _buildSettingsTile(
                  context,
                  icon: Icons.delete_forever,
                  title: 'Reset All Data',
                  subtitle: 'Clear all habits and start fresh',
                  isDestructive: true,
                  onTap: () => _confirmResetData(context, appState),
                ),
                const Divider(),

                _buildSectionTitle(context, 'About'),
                _buildSettingsTile(
                  context,
                  icon: Icons.book,
                  title: 'Learn About Atomic Habits',
                  subtitle: 'Principles and frameworks',
                  onTap: () => _showInfoDialog(context),
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
                      applicationVersion: '1.1.0',
                      applicationIcon: const Icon(Icons.self_improvement),
                      children: [
                        const Text(
                          'An app to help you build better habits using principles from '
                          'James Clear\'s Atomic Habits and Nir Eyal\'s Hook Model.',
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Now with multiple habits support!',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    );
                  },
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
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : null,
      ),
      title: Text(
        title,
        style: TextStyle(color: isDestructive ? Colors.red : null),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: isDestructive ? Colors.red.shade300 : null),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildHabitTile(BuildContext context, Habit habit, AppState appState) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${habit.currentStreak}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        title: Text(
          habit.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${habit.implementationTime} • ${habit.tinyVersion}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.go('/edit-habit/${habit.id}'),
              tooltip: 'Edit habit',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDeleteHabit(context, habit, appState),
              tooltip: 'Delete habit',
            ),
          ],
        ),
        onTap: () => context.go('/edit-habit/${habit.id}'),
      ),
    );
  }

  void _confirmDeleteHabit(BuildContext context, Habit habit, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text(
          'Are you sure you want to delete "${habit.name}"?\n\n'
          'Current streak: ${habit.currentStreak} days\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              appState.deleteHabit(habit.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Habit "${habit.name}" deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmResetData(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Data'),
        content: const Text(
          'This will delete ALL your habits, profile, and progress. '
          'You will need to complete onboarding again.\n\n'
          'This action cannot be undone!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              appState.clearAllData();
              Navigator.of(context).pop();
              context.go('/');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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
              SizedBox(height: 16),
              Text(
                'Multiple Habits Support',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Track as many habits as you want!'),
              Text('Each habit has its own:'),
              Text('  - Streak tracking'),
              Text('  - Implementation intention'),
              Text('  - Temptation bundling'),
              Text('  - Pre-habit ritual'),
              Text('  - Environment design'),
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
