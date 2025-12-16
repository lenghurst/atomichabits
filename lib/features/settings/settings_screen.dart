import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/app_state.dart';
import '../../data/models/app_settings.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/sync_service.dart';
import '../../data/services/feedback_service.dart';
import '../../widgets/alpha_shield_banner.dart';

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
            child: Column(
              children: [
                // Phase 20: Alpha Shield Banner
                const AlphaShieldBanner(),
                
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const SizedBox(height: 8),
                      
                      // ========== Account Section (Phase 16.1) ==========
                _buildSectionTitle(context, 'Account'),
                _buildAccountCard(context),
                const SizedBox(height: 24),
                
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
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.handshake),
                        title: const Text('Contracts'),
                        subtitle: const Text('View accountability contracts'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.go('/contracts'),
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
                
                // ========== Feedback Section (Phase 20: Destroyer Defense) ==========
                _buildSectionTitle(context, 'Feedback'),
                Card(
                  child: Column(
                    children: [
                      // Bug Report - The Bug Bounty
                      ListTile(
                        leading: Icon(Icons.bug_report, color: Colors.orange.shade700),
                        title: const Text('Report a Bug'),
                        subtitle: const Text('Get credited in CREDITS.md'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showBugReportDialog(context),
                      ),
                      const Divider(height: 1),
                      // Roast the Developer - The Escape Valve
                      ListTile(
                        leading: Icon(Icons.local_fire_department, color: Colors.red.shade700),
                        title: const Text('Roast the Developer'),
                        subtitle: const Text('Tell us why this sucks'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showRoastDialog(context),
                      ),
                      const Divider(height: 1),
                      // Feature Request
                      ListTile(
                        leading: Icon(Icons.lightbulb, color: Colors.amber.shade700),
                        title: const Text('Suggest a Feature'),
                        subtitle: const Text('What would make this better?'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showFeatureRequestDialog(context),
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
                        leading: const Icon(Icons.people),
                        title: const Text('Credits'),
                        subtitle: const Text('Founding Testers & Contributors'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showCreditsDialog(context),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text('App Info'),
                        subtitle: const Text('Version 5.4.0 (Phase 14.5)'),
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
        applicationVersion: '5.4.0 (Phase 14.5)',
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
          Text('✅ Phase 14: Pattern Detection'),
          Text('✅ Phase 15: Identity Foundation'),
          Text('✅ Phase 16.2: Habit Contracts'),
          Text('✅ Phase 17: Brain Surgery (AI)'),
          Text('✅ Phase 18: The Vibe Update'),
          Text('✅ Phase 19: Side Door Strategy'),
          Text('✅ Phase 20: Destroyer Defense'),
        ],
      ),
    );
  }

  /// Build the account management card (Phase 16.1)
  Widget _buildAccountCard(BuildContext context) {
    final authService = context.watch<AuthService>();
    final syncService = context.watch<SyncService>();
    
    return Card(
      child: Column(
        children: [
          // Account Status Header
          _buildAccountStatusTile(context, authService, syncService),
          
          // Actions based on auth state
          if (authService.isSupabaseAvailable) ...[
            const Divider(height: 1),
            if (!authService.isAuthenticated) ...[
              // Not signed in - show sign in options
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text('Sign In'),
                subtitle: const Text('Connect to enable cloud sync'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showSignInSheet(context, authService),
              ),
            ] else if (authService.isAnonymous) ...[
              // Signed in anonymously - show upgrade options
              ListTile(
                leading: Icon(Icons.upgrade, color: Colors.blue.shade700),
                title: const Text('Upgrade Account'),
                subtitle: const Text('Link email or Google for backup'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showUpgradeSheet(context, authService),
              ),
            ] else ...[
              // Fully signed in - show sign out
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign Out'),
                subtitle: Text('Signed in as ${authService.currentUser?.email ?? "Unknown"}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _confirmSignOut(context, authService),
              ),
            ],
            const Divider(height: 1),
            // Sync status
            _buildSyncStatusTile(context, syncService),
          ] else ...[
            // Supabase not configured
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.cloud_off, color: Colors.grey.shade500),
              title: const Text('Offline Mode'),
              subtitle: const Text('Cloud sync not configured'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAccountStatusTile(BuildContext context, AuthService authService, SyncService syncService) {
    IconData icon;
    Color iconColor;
    String title;
    String subtitle;
    
    if (!authService.isSupabaseAvailable) {
      icon = Icons.cloud_off;
      iconColor = Colors.grey;
      title = 'Local Only';
      subtitle = 'Data stored on device';
    } else if (!authService.isAuthenticated) {
      icon = Icons.account_circle_outlined;
      iconColor = Colors.orange;
      title = 'Not Signed In';
      subtitle = 'Sign in to enable cloud backup';
    } else if (authService.isAnonymous) {
      icon = Icons.person_outline;
      iconColor = Colors.blue;
      title = 'Anonymous Account';
      subtitle = 'Upgrade to keep your data safe';
    } else {
      icon = Icons.verified_user;
      iconColor = Colors.green;
      title = 'Verified Account';
      subtitle = authService.currentUser?.email ?? 'Cloud sync enabled';
    }
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.1),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
    );
  }

  Widget _buildSyncStatusTile(BuildContext context, SyncService syncService) {
    final lastSync = syncService.lastSyncTime;
    final isSyncing = syncService.isSyncing;
    final pendingCount = syncService.pendingChangesCount;
    
    String syncText;
    IconData syncIcon;
    Color syncColor;
    
    if (isSyncing) {
      syncText = 'Syncing...';
      syncIcon = Icons.sync;
      syncColor = Colors.blue;
    } else if (pendingCount > 0) {
      syncText = '$pendingCount changes pending';
      syncIcon = Icons.cloud_upload;
      syncColor = Colors.orange;
    } else if (lastSync != null) {
      syncText = 'Last synced ${_formatLastSync(lastSync)}';
      syncIcon = Icons.cloud_done;
      syncColor = Colors.green;
    } else {
      syncText = 'Not yet synced';
      syncIcon = Icons.cloud_queue;
      syncColor = Colors.grey;
    }
    
    return ListTile(
      leading: Icon(syncIcon, color: syncColor),
      title: const Text('Cloud Sync'),
      subtitle: Text(syncText),
      trailing: isSyncing 
          ? const SizedBox(
              width: 20, 
              height: 20, 
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => syncService.syncNow(),
            ),
    );
  }

  String _formatLastSync(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _showSignInSheet(BuildContext context, AuthService authService) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_sync,
                size: 48,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 16),
              const Text(
                'Sign In to Sync',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your habits will be backed up to the cloud and available across devices.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              
              // Google Sign In
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _handleGoogleSignIn(context, authService);
                  },
                  icon: Image.network(
                    'https://www.google.com/favicon.ico',
                    width: 20,
                    height: 20,
                    errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata),
                  ),
                  label: const Text('Continue with Google'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Email Sign In
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showEmailSignInDialog(context, authService);
                  },
                  icon: const Icon(Icons.email),
                  label: const Text('Sign in with Email'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Anonymous option
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final result = await authService.signInAnonymously();
                  if (context.mounted) {
                    if (result.success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Signed in anonymously')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${result.error}')),
                      );
                    }
                  }
                },
                child: const Text('Continue without account'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showUpgradeSheet(BuildContext context, AuthService authService) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.upgrade,
                size: 48,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              const Text(
                'Upgrade Your Account',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Link an email or Google account to keep your data safe forever.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              
              // Google Link
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _handleGoogleSignIn(context, authService);
                  },
                  icon: const Icon(Icons.g_mobiledata),
                  label: const Text('Link Google Account'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Email Link
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showEmailUpgradeDialog(context, authService);
                  },
                  icon: const Icon(Icons.email),
                  label: const Text('Link Email & Password'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Maybe later'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn(BuildContext context, AuthService authService) async {
    final result = await authService.signInWithGoogle();
    if (context.mounted) {
      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed in with Google!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: \${result.error}')),
        );
      }
    }
  }

  void _showEmailSignInDialog(BuildContext context, AuthService authService) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign In with Email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await authService.signInWithEmail(
                email: emailController.text.trim(),
                password: passwordController.text,
              );
              if (context.mounted) {
                if (result.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Signed in!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: \${result.error}')),
                  );
                }
              }
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  void _showEmailUpgradeDialog(BuildContext context, AuthService authService) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Link Email Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Create a password to secure your account:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmController,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (passwordController.text != confirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }
              Navigator.pop(context);
              final result = await authService.upgradeWithEmail(
                email: emailController.text.trim(),
                password: passwordController.text,
              );
              if (context.mounted) {
                if (result.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account upgraded!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: \${result.error}')),
                  );
                }
              }
            },
            child: const Text('Link Account'),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text(
          'Your data will remain on this device, but cloud sync will be disabled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await authService.signOut();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Signed out')),
                );
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PHASE 20: Destroyer Defense - Feedback Dialogs
  // ============================================================

  /// Show bug report dialog
  void _showBugReportDialog(BuildContext context) {
    final descriptionController = TextEditingController();
    final handleController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.bug_report, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            const Text('Report a Bug'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Found something broken? Tell us and get credited in CREDITS.md!',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: handleController,
                decoration: const InputDecoration(
                  labelText: 'Your Name/Handle (for credits)',
                  hintText: '@yourhandle or "Jane Doe"',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'What went wrong?',
                  hintText: 'Describe the bug...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              final sent = await FeedbackService.sendBugReport(
                description: descriptionController.text,
                userHandle: handleController.text,
              );
              if (context.mounted) {
                if (sent) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening email...')),
                  );
                } else {
                  // Fallback: copy to clipboard
                  await FeedbackService.copyBugReportToClipboard(
                    description: descriptionController.text,
                    userHandle: handleController.text,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bug report copied to clipboard')),
                  );
                }
              }
            },
            icon: const Icon(Icons.send),
            label: const Text('Send Report'),
          ),
        ],
      ),
    );
  }

  /// Show roast dialog - The "Escape Valve"
  void _showRoastDialog(BuildContext context) {
    final roastController = TextEditingController();
    final handleController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.local_fire_department, color: Colors.red.shade700),
            const SizedBox(width: 8),
            const Text('Roast the Developer'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tell me why this sucks. Be honest. Be brutal. Be constructive.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                'If your roast leads to a fix, you\'ll be immortalized in the Hall of Roasts.',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: handleController,
                decoration: const InputDecoration(
                  labelText: 'Your Handle (for Hall of Roasts)',
                  hintText: '@yourhandle',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: roastController,
                decoration: const InputDecoration(
                  labelText: 'Your Roast',
                  hintText: 'This app sucks because...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Nevermind'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade700,
            ),
            onPressed: () async {
              Navigator.pop(context);
              final sent = await FeedbackService.sendRoast(
                roast: roastController.text,
                userHandle: handleController.text,
              );
              if (context.mounted) {
                if (sent) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening email... Let it out!')),
                  );
                } else {
                  await FeedbackService.copyRoastToClipboard(
                    roast: roastController.text,
                    userHandle: handleController.text,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Roast copied to clipboard')),
                  );
                }
              }
            },
            icon: const Icon(Icons.local_fire_department),
            label: const Text('Send Roast'),
          ),
        ],
      ),
    );
  }

  /// Show feature request dialog
  void _showFeatureRequestDialog(BuildContext context) {
    final featureController = TextEditingController();
    final handleController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lightbulb, color: Colors.amber.shade700),
            const SizedBox(width: 8),
            const Text('Suggest a Feature'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What would make this app better for you?',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: handleController,
                decoration: const InputDecoration(
                  labelText: 'Your Name/Handle',
                  hintText: '@yourhandle',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: featureController,
                decoration: const InputDecoration(
                  labelText: 'Feature Idea',
                  hintText: 'I wish the app could...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              // Use bug report template but for features
              final subject = Uri.encodeComponent('💡 Feature Request: Atomic Habits');
              final body = Uri.encodeComponent('''
💡 FEATURE REQUEST — Atomic Habits Hook App

**From:** ${handleController.text.isNotEmpty ? handleController.text : '[Anonymous]'}
**Date:** ${DateTime.now().toIso8601String()}

---

**Feature Idea:**
${featureController.text}

---

*Thank you for your suggestion!*
''');
              final uri = Uri.parse('mailto:${FeedbackService.feedbackEmail}?subject=$subject&body=$body');
              
              try {
                await launchUrl(uri);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not open email client')),
                  );
                }
              }
            },
            icon: const Icon(Icons.send),
            label: const Text('Send Idea'),
          ),
        ],
      ),
    );
  }

  /// Show credits dialog
  void _showCreditsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.people, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text('Credits'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'The Founding Team',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('• @lenghurst — Creator & Lead Developer'),
              const Text('• Claude (Anthropic) — AI Co-Architect'),
              const Text('• Gemini (Google) — AI Onboarding'),
              const Text('• DeepSeek-V3.2 — Prompt Optimization'),
              const SizedBox(height: 16),
              const Text(
                'Founding Testers',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Be the first! Report a bug to get credited.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Hall of Roasts',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'No roasts yet. Tell us why this sucks!',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Want your name here?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text('• Report a bug → Founding Testers'),
              const Text('• Submit a roast → Hall of Roasts'),
              const Text('• Suggest a feature → Release Notes'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showBugReportDialog(context);
            },
            child: const Text('Report Bug'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
