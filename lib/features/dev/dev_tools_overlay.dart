import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/router/app_routes.dart';
import '../../data/app_state.dart';
import '../../config/ai_model_config.dart';
import '../../domain/services/voice_provider_selector.dart';
import 'debug_console_view.dart';

/// Developer Tools Overlay - Phase 38 (In-App Log Console)
/// 
/// Provides quick access to developer settings and testing tools.
/// Access via: Triple-tap on any screen title, or long-press version text.
/// 
/// Features:
/// - Toggle Premium (Tier 2) mode
/// - View current AI tier and status
/// - Quick navigation to any screen
/// - Skip onboarding for testing
/// - API connectivity status
class DevToolsOverlay extends StatelessWidget {
  const DevToolsOverlay({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DevToolsOverlay(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appState = context.watch<AppState>();
    final settings = appState.settings;
    
    // Get AI status
    final aiStatus = AIModelConfig.getStatusSummary();
    final currentTier = AIModelConfig.selectTier(
      isPremiumUser: settings.developerMode,
      isBreakHabit: false,
    );

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.developer_mode, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Developer Tools',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              
              const Divider(),
              
              // Current Status
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Status',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _StatusRow(
                      label: 'AI Tier',
                      value: '${currentTier.displayName} (${currentTier.emoji})',
                    ),
                    _StatusRow(
                      label: 'Premium Mode',
                      value: settings.developerMode ? 'ON' : 'OFF',
                      valueColor: settings.developerMode ? Colors.green : Colors.grey,
                    ),
                    _StatusRow(
                      label: 'DeepSeek',
                      value: aiStatus['tier1Available'] == true ? '✅ Available' : '❌ Unavailable',
                    ),
                    _StatusRow(
                      label: 'Gemini',
                      value: aiStatus['tier2Available'] == true ? '✅ Available' : '❌ Unavailable',
                    ),
                    _StatusRow(
                      label: 'Voice',
                      value: aiStatus['voiceEnabled'] == true ? '🎙️ Enabled' : '🔇 Disabled',
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Quick Actions
              Text(
                'Quick Actions',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Premium Toggle
              SwitchListTile(
                title: const Text('Premium Mode (Tier 2)'),
                subtitle: Text(
                  settings.developerMode 
                      ? 'Using Gemini Voice' 
                      : 'Using DeepSeek Text',
                ),
                value: settings.developerMode,
                onChanged: (value) {
                  appState.updateSettings(
                    settings.copyWith(developerMode: value),
                  );
                },
              ),
              
              const Divider(),
              
              // Navigation Shortcuts
              Text(
                'Quick Navigation',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _NavChip(
                    label: 'Voice Coach',
                    icon: Icons.mic,
                    onTap: () {
                      Navigator.pop(context);
                      context.go(AppRoutes.voiceOnboarding);
                    },
                  ),
                  _NavChip(
                    label: 'Text Coach',
                    icon: Icons.chat,
                    onTap: () {
                      Navigator.pop(context);
                      // Force text mode temporarily
                      appState.updateSettings(
                        settings.copyWith(developerMode: false),
                      );
                      context.go(AppRoutes.home);
                    },
                  ),
                  _NavChip(
                    label: 'Manual Form',
                    icon: Icons.edit_note,
                    onTap: () {
                      Navigator.pop(context);
                      context.go(AppRoutes.manualOnboarding);
                    },
                  ),
                  _NavChip(
                    label: 'Dashboard',
                    icon: Icons.dashboard,
                    onTap: () {
                      Navigator.pop(context);
                      context.go(AppRoutes.dashboard);
                    },
                  ),
                  _NavChip(
                    label: 'Settings',
                    icon: Icons.settings,
                    onTap: () {
                      Navigator.pop(context);
                      context.go(AppRoutes.settings);
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Skip Onboarding
              if (!appState.hasCompletedOnboarding)
                FilledButton.tonal(
                  onPressed: () async {
                    // Mark onboarding complete to skip
                    await appState.completeOnboarding();
                    if (context.mounted) {
                      Navigator.pop(context);
                      context.go(AppRoutes.dashboard);
                    }
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.skip_next),
                      SizedBox(width: 8),
                      Text('Skip Onboarding (Create Dummy Habit)'),
                    ],
                  ),
                ),
              
              const SizedBox(height: 8),
              
              // View Logs button (Phase 38: In-App Log Console)
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Close dev tools first
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const SizedBox(
                      height: 500,
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        child: DebugConsoleView(),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.terminal),
                label: const Text('View Voice Logs'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                ),
              ),
              
              const SizedBox(height: 8),

              // Voice Connection Test
              OutlinedButton.icon(
                onPressed: () async {
                   final selector = VoiceProviderSelector();
                   final rec = await selector.runDiagnostics();
                   if (context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text('Recommended: ${rec.provider}')),
                     );
                   }
                },
                icon: const Icon(Icons.speed),
                label: const Text('Test Voice Connection'),
              ),

              const SizedBox(height: 8),
              
              // Copy Debug Info button (Peter Thiel recommendation)
              OutlinedButton.icon(
                onPressed: () => _copyDebugInfo(context, aiStatus, currentTier, settings),
                icon: const Icon(Icons.copy),
                label: const Text('Copy Debug Info'),
              ),
              
              const SizedBox(height: 16),
              
              // Version info with long-press for dev tools (Ken Kocienda recommendation)
              Center(
                child: GestureDetector(
                  onLongPress: () {
                    // Already in dev tools, show a toast
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('You\'re already in Developer Tools!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Text(
                    'The Pact v0.27.6-dev',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Copy debug info to clipboard (Peter Thiel recommendation)
  static void _copyDebugInfo(
    BuildContext context,
    Map<String, dynamic> aiStatus,
    AiTier currentTier,
    dynamic settings,
  ) {
    final now = DateTime.now();
    final debugInfo = '''
=== The Pact Debug Info ===
Timestamp: ${now.toIso8601String()}
Version: 0.27.6-dev

--- AI Configuration ---
Current Tier: ${currentTier.displayName} (${currentTier.emoji})
Developer Mode: ${settings.developerMode}
DeepSeek Available: ${aiStatus['tier1Available']}
Gemini Available: ${aiStatus['tier2Available']}
Voice Enabled: ${aiStatus['voiceEnabled']}

--- Kill Switches ---
Global: ${aiStatus['globalKillSwitch']}
Gemini: ${aiStatus['geminiKillSwitch']}
DeepSeek: ${aiStatus['deepSeekKillSwitch']}
Voice: ${aiStatus['voiceKillSwitch']}

--- API Keys ---
DeepSeek Key: ${aiStatus['hasDeepSeekKey'] ? 'Configured' : 'Missing'}
Gemini Key: ${aiStatus['hasGeminiKey'] ? 'Configured' : 'Missing'}
OpenAI Key: ${aiStatus['hasOpenAiKey'] ? 'Configured' : 'Missing'}
===========================
''';
    
    Clipboard.setData(ClipboardData(text: debugInfo));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Debug info copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatusRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _NavChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }
}

/// Mixin to add dev tools gesture to any screen
/// Usage: Add DevToolsGestureDetector as a wrapper around your title
class DevToolsGestureDetector extends StatefulWidget {
  final Widget child;
  
  const DevToolsGestureDetector({
    super.key,
    required this.child,
  });

  @override
  State<DevToolsGestureDetector> createState() => _DevToolsGestureDetectorState();
}

class _DevToolsGestureDetectorState extends State<DevToolsGestureDetector> {
  int _tapCount = 0;
  DateTime? _lastTap;

  void _handleTap() {
    final now = DateTime.now();
    
    // Reset if more than 500ms since last tap
    if (_lastTap != null && now.difference(_lastTap!).inMilliseconds > 500) {
      _tapCount = 0;
    }
    
    _tapCount++;
    _lastTap = now;
    
    // Triple tap opens dev tools
    if (_tapCount >= 3) {
      _tapCount = 0;
      DevToolsOverlay.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only enable in debug mode
    if (!kDebugMode) {
      return widget.child;
    }
    
    return GestureDetector(
      onTap: _handleTap,
      child: widget.child,
    );
  }
}
