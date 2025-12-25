import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/router/app_routes.dart';
import 'package:intl/intl.dart';
import '../../data/app_state.dart';
import '../../data/services/backup_service.dart';

/// Phase 11: Data Management Screen
/// 
/// Provides backup and restore functionality for user data safety.
/// 
/// **Features:**
/// - Export backup to JSON file via system share sheet
/// - Import backup from file with validation
/// - Preview backup contents before restore
/// - Warning dialogs for destructive operations
/// - Last backup/restore timestamps
/// 
/// **Architecture:**
/// - Uses BackupService for all data operations
/// - Follows existing settings UI patterns
/// - Integrates with AppState for data reload after restore
class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({super.key});

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  final BackupService _backupService = BackupService();
  
  bool _isExporting = false;
  bool _isImporting = false;
  DateTime? _lastBackupDate;
  DateTime? _lastRestoreDate;
  
  @override
  void initState() {
    super.initState();
    _loadBackupInfo();
  }
  
  Future<void> _loadBackupInfo() async {
    final lastBackup = await _backupService.getLastBackupDate();
    final lastRestore = await _backupService.getLastRestoreDate();
    
    if (mounted) {
      setState(() {
        _lastBackupDate = lastBackup;
        _lastRestoreDate = lastRestore;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Management'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ========== Info Card ==========
            Card(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 40,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Protect Your Progress',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Back up your habits, streaks, and consistency data to keep them safe.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // ========== Export Section ==========
            _buildSectionTitle(context, 'Export'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.upload_file, color: Colors.green),
                    ),
                    title: const Text('Create Backup'),
                    subtitle: const Text('Export all data to a JSON file'),
                    trailing: _isExporting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: _isExporting ? null : _handleExport,
                  ),
                  if (_lastBackupDate != null) ...[
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.history,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Last backup: ${_formatDate(_lastBackupDate!)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // ========== Import Section ==========
            _buildSectionTitle(context, 'Import'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.download, color: Colors.orange),
                    ),
                    title: const Text('Restore from Backup'),
                    subtitle: const Text('Import data from a backup file'),
                    trailing: _isImporting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: _isImporting ? null : _handleImport,
                  ),
                  if (_lastRestoreDate != null) ...[
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.restore,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Last restore: ${_formatDate(_lastRestoreDate!)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // ========== What's Included Section ==========
            _buildSectionTitle(context, "What's Included"),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIncludedItem(
                      context,
                      Icons.track_changes,
                      'All Habits',
                      'Names, identities, tiny versions, settings',
                    ),
                    const SizedBox(height: 12),
                    _buildIncludedItem(
                      context,
                      Icons.calendar_today,
                      'Completion History',
                      'Every day you showed up',
                    ),
                    const SizedBox(height: 12),
                    _buildIncludedItem(
                      context,
                      Icons.trending_up,
                      'Streaks & Scores',
                      'Current streak, longest streak, Graceful Score',
                    ),
                    const SizedBox(height: 12),
                    _buildIncludedItem(
                      context,
                      Icons.replay,
                      'Recovery History',
                      'Never Miss Twice wins and recovery events',
                    ),
                    const SizedBox(height: 12),
                    _buildIncludedItem(
                      context,
                      Icons.person,
                      'User Profile',
                      'Your name and identity statement',
                    ),
                    const SizedBox(height: 12),
                    _buildIncludedItem(
                      context,
                      Icons.settings,
                      'App Settings',
                      'Theme, notifications, sound preferences',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // ========== Tips Section ==========
            Card(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tips',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• Back up regularly to protect your progress',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• Save backups to cloud storage (Google Drive, iCloud)',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• Restoring will replace all current data',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
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
  
  Widget _buildIncludedItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.check_circle,
          size: 16,
          color: Colors.green.shade400,
        ),
      ],
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today at ${DateFormat('h:mm a').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${DateFormat('h:mm a').format(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }
  
  // ========== Export Handler ==========
  
  Future<void> _handleExport() async {
    setState(() => _isExporting = true);
    
    try {
      final result = await _backupService.exportBackup();
      
      if (!mounted) return;
      
      switch (result) {
        case BackupSuccess():
          await _backupService.recordBackupDate();
          await _loadBackupInfo();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(result.message ?? 'Backup created successfully'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          
        case BackupFailure():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(result.error)),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          
        case BackupPendingRestore():
          // This shouldn't happen for export
          break;
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }
  
  // ========== Import Handler ==========
  
  Future<void> _handleImport() async {
    setState(() => _isImporting = true);
    
    try {
      final result = await _backupService.importBackup();
      
      if (!mounted) return;
      
      switch (result) {
        case BackupPendingRestore():
          // Show preview and confirmation dialog
          final confirmed = await _showRestoreConfirmationDialog(result.backupData);
          
          if (confirmed == true && mounted) {
            await _performRestore(result.backupData);
          }
          
        case BackupFailure():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(result.error)),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          
        case BackupSuccess():
          // This shouldn't happen for import
          break;
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }
  
  Future<bool?> _showRestoreConfirmationDialog(Map<String, dynamic> backupData) async {
    final summary = _backupService.getBackupSummary(backupData);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            const Text('Restore Backup?'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Backup summary card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Backup Contents',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryRow('Habits', '${summary.habitCount}'),
                    if (summary.userName != null)
                      _buildSummaryRow('User', summary.userName!),
                    _buildSummaryRow('Completions', '${summary.totalCompletions}'),
                    _buildSummaryRow('Recoveries', '${summary.totalRecoveries}'),
                    _buildSummaryRow('Exported', summary.formattedExportDate),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Warning
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, size: 16, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Warning',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This will replace ALL current data including:',
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    const Text('• Your current habits', style: TextStyle(fontSize: 13)),
                    const Text('• Your completion history', style: TextStyle(fontSize: 13)),
                    const Text('• Your streaks and scores', style: TextStyle(fontSize: 13)),
                    const Text('• Your settings', style: TextStyle(fontSize: 13)),
                    const SizedBox(height: 8),
                    Text(
                      'This action cannot be undone.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.red.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _performRestore(Map<String, dynamic> backupData) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 24),
            Text('Restoring backup...'),
          ],
        ),
      ),
    );
    
    try {
      final result = await _backupService.restoreBackup(backupData);
      
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      
      switch (result) {
        case BackupSuccess():
          await _loadBackupInfo();
          
          // Show success and prompt for app restart
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Restore Complete'),
                ],
              ),
              content: const Text(
                'Your data has been restored successfully.\n\n'
                'The app will now reload to apply the changes.',
              ),
              actions: [
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Trigger app state reload
                    final appState = context.read<AppState>();
                    appState.reloadFromStorage().then((_) {
                      if (context.mounted) {
                        context.go(AppRoutes.dashboard);
                      }
                    });
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          
        case BackupFailure():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(result.error)),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          
        case BackupPendingRestore():
          // This shouldn't happen here
          break;
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
