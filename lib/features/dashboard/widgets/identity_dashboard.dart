import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/habit.dart';
import '../../../data/providers/habit_provider.dart';
import '../../../data/providers/user_provider.dart';
import '../../../domain/services/identity_growth_service.dart';
import 'the_bridge.dart';
import 'skill_tree.dart';
import 'comms_fab.dart';

/// Identity Dashboard: Binary Interface
///
/// Phase 67: Dashboard Redesign - Final Integration
///
/// Two-state interface:
/// - State A (Bridge): Doing - Action-focused, priority-sorted habits
/// - State B (Tree): Being - Identity visualization, growth over time
///
/// Toggle between states via bottom navigation or swipe.
class IdentityDashboard extends StatefulWidget {
  const IdentityDashboard({super.key});

  @override
  State<IdentityDashboard> createState() => _IdentityDashboardState();
}

class _IdentityDashboardState extends State<IdentityDashboard> {
  int _currentIndex = 0; // 0 = Bridge, 1 = Tree
  bool _commsFabExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer2<HabitProvider, UserProvider>(
      builder: (context, habitProvider, userProvider, _) {
        final habits = habitProvider.habits;
        final identity = userProvider.userProfile?.identity;
        final metrics = IdentityGrowthService.instance.getMetrics(habits);

        return Scaffold(
          body: Stack(
            children: [
              // Main content
              IndexedStack(
                index: _currentIndex,
                children: [
                  // State A: The Bridge (Doing)
                  SafeArea(
                    child: Column(
                      children: [
                        _buildHeader(context, metrics, isTree: false),
                        Expanded(
                          child: TheBridge(
                            habits: habits,
                            onHabitTap: (id) => _navigateToHabit(context, id),
                            onComplete: (id, usedTiny) => _completeHabit(
                              context,
                              habitProvider,
                              id,
                              usedTiny,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // State B: The Skill Tree (Being)
                  SafeArea(
                    child: Column(
                      children: [
                        _buildHeader(context, metrics, isTree: true),
                        Expanded(
                          child: SkillTree(
                            habits: habits,
                            coreIdentity: identity,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Comms FAB
              Positioned(
                right: 16,
                bottom: 90,
                child: CommsFab(
                  isExpanded: _commsFabExpanded,
                  onToggle: () {
                    setState(() {
                      _commsFabExpanded = !_commsFabExpanded;
                    });
                  },
                  onPersonaSelected: (personaId, prompt) {
                    _showCommsChat(context, personaId, prompt);
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomNav(context, metrics),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    IdentityGrowthMetrics metrics,
    {required bool isTree}
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Level badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  metrics.currentLevel.emoji,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 6),
                Text(
                  metrics.currentLevel.displayName,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // View title
          Text(
            isTree ? 'Identity' : 'Today',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const Spacer(),

          // Progress to next level
          SizedBox(
            width: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${metrics.totalVotes} votes',
                  style: theme.textTheme.labelSmall,
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: metrics.progressToNextLevel,
                    minHeight: 6,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, IdentityGrowthMetrics metrics) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                context,
                icon: Icons.flash_on,
                label: 'Bridge',
                isSelected: _currentIndex == 0,
                onTap: () => setState(() => _currentIndex = 0),
              ),
              _buildNavItem(
                context,
                icon: Icons.park_outlined,
                label: 'Tree',
                isSelected: _currentIndex == 1,
                onTap: () => setState(() => _currentIndex = 1),
                badge: metrics.currentLevel.emoji,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    String? badge,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                if (badge != null)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Text(badge, style: const TextStyle(fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToHabit(BuildContext context, String habitId) {
    // Navigate to habit detail or focus on it
    final habitProvider = context.read<HabitProvider>();
    habitProvider.setFocusHabit(habitId);

    // Could navigate to TodayScreen or show a modal
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Focused on habit'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _completeHabit(
    BuildContext context,
    HabitProvider habitProvider,
    String habitId,
    bool usedTiny,
  ) async {
    final result = await habitProvider.completeHabitForToday(
      habitId: habitId,
      usedTinyVersion: usedTiny,
    );

    if (result.wasNewCompletion && context.mounted) {
      // Show celebration
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('🗳️ Vote cast!'),
              const Spacer(),
              Text(
                '+1 identity vote',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showCommsChat(BuildContext context, String personaId, String prompt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommsChatSheet(
        personaId: personaId,
        systemPrompt: prompt,
      ),
    );
  }
}
