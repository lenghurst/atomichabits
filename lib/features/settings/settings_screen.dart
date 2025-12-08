import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../data/app_state.dart';
import '../../widgets/new_habit_warning_dialog.dart';
import '../../widgets/habit_list_sheet.dart';

/// Settings screen - manage habits, profile, and app settings
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

                // Settings sections
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

                // Habit count indicator
                if (appState.activeHabitCount > 0) ...[
                  _buildHabitSummaryCard(context, appState),
                  const SizedBox(height: 8),
                ],

                _buildSettingsTile(
                  context,
                  icon: Icons.list,
                  title: 'Manage Habits',
                  subtitle: '${appState.activeHabitCount} active habit${appState.activeHabitCount == 1 ? '' : 's'}',
                  onTap: () {
                    HabitListSheet.show(
                      context,
                      onAddHabit: () {
                        Navigator.pop(context);
                        _handleAddNewHabit(context, appState);
                      },
                    );
                  },
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.add_circle,
                  title: 'Add New Habit',
                  subtitle: 'Create additional habits',
                  onTap: () => _handleAddNewHabit(context, appState),
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.edit,
                  title: 'Edit Current Habit',
                  subtitle: appState.currentHabit?.name ?? 'No habit selected',
                  onTap: () {
                    // TODO: Navigate to habit edit screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon!')),
                    );
                  },
                ),

                // Archived habits (if any)
                if (appState.archivedHabits.isNotEmpty)
                  _buildSettingsTile(
                    context,
                    icon: Icons.archive,
                    title: 'Archived Habits',
                    subtitle: '${appState.archivedHabits.length} archived',
                    onTap: () => _showArchivedHabits(context, appState),
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
                  subtitle: 'Start fresh (cannot be undone)',
                  onTap: () => _confirmReset(context, appState),
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

  Widget _buildHabitSummaryCard(BuildContext context, AppState appState) {
    final theme = Theme.of(context);
    final focusScore = appState.focusScore;
    final completed = appState.habitsCompletedTodayCount;
    final total = appState.activeHabitCount;

    return Card(
      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Today's progress
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completed / $total done',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Focus score
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _getFocusScoreColor(focusScore).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Focus',
                    style: theme.textTheme.labelSmall,
                  ),
                  Text(
                    '${(focusScore * 100).round()}%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getFocusScoreColor(focusScore),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getFocusScoreColor(double score) {
    if (score >= 0.7) return Colors.green;
    if (score >= 0.4) return Colors.orange;
    return Colors.red;
  }

  Future<void> _handleAddNewHabit(BuildContext context, AppState appState) async {
    // Get warning message (if any)
    final warning = appState.getNewHabitWarning();

    // Show warning dialog
    final shouldProceed = await NewHabitWarningDialog.show(context, warning);

    if (shouldProceed && context.mounted) {
      // Navigate to onboarding to create new habit
      // The onboarding will add a new habit instead of replacing
      context.go('/');
    }
  }

  void _showArchivedHabits(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Archived Habits',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(height: 1),
            ...appState.archivedHabits.map(
              (habit) => ListTile(
                leading: const Icon(Icons.archive),
                title: Text(habit.name),
                subtitle: Text('${habit.totalCompletions} completions'),
                trailing: TextButton(
                  onPressed: () {
                    appState.restoreHabit(habit.id);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${habit.name} restored')),
                    );
                  },
                  child: const Text('Restore'),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text(
          'This will delete all your habits, streaks, and history. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              appState.clearAllData();
              Navigator.pop(context);
              context.go('/');
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Reset Everything'),
          ),
        ],
      ),
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
              SizedBox(height: 16),
              Text(
                'Philosophy: One Habit at a Time',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'We recommend focusing on one habit until it\'s established '
                '(21+ day streak) before adding more. This approach leads to '
                'better long-term success.',
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
