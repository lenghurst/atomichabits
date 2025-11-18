import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/app_state.dart';
import '../../data/avatar_cosmetics.dart';

/// Avatar screen - Shows identity avatar and cosmetic progression
/// Phase 4: Optional, calm, identity-aligned visual representation
class AvatarScreen extends StatelessWidget {
  const AvatarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final profile = appState.userProfile;
        final avatarEnabled = appState.avatarEnabled;
        final totalVotes = appState.currentHabit?.totalCompletions ?? 0;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Identity avatar'),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/today'),
            ),
          ),
          body: SafeArea(
            child: avatarEnabled
                ? _buildAvatarView(context, appState, profile, totalVotes)
                : _buildDisabledView(context),
          ),
        );
      },
    );
  }

  /// View when avatar is disabled
  Widget _buildDisabledView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.visibility_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              'The identity avatar is turned off in Settings.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/settings'),
              icon: const Icon(Icons.settings),
              label: const Text('Go to Settings'),
            ),
          ],
        ),
      ),
    );
  }

  /// View when avatar is enabled
  Widget _buildAvatarView(
    BuildContext context,
    AppState appState,
    dynamic profile,
    int totalVotes,
  ) {
    if (profile == null) {
      return const Center(child: Text('No profile found'));
    }

    final unlockedIds = profile.unlockedCosmeticsIds as List<String>;
    final equippedCosmetics = profile.equippedCosmetics as Map<String, String>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section: Avatar representation
          Center(
            child: Column(
              children: [
                Text(
                  'This is how your identity looks right now.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildAvatarRepresentation(context, equippedCosmetics),
                const SizedBox(height: 16),
                Text(
                  '${unlockedIds.length} items unlocked',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Middle section: Unlocked items by category
          Text(
            'Unlocked items',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          _buildCosmeticCategory(
            context,
            appState,
            'Environment',
            'environment',
            Icons.home,
            unlockedIds,
            equippedCosmetics,
          ),
          const SizedBox(height: 16),

          _buildCosmeticCategory(
            context,
            appState,
            'Aura',
            'aura',
            Icons.auto_awesome,
            unlockedIds,
            equippedCosmetics,
          ),
          const SizedBox(height: 16),

          _buildCosmeticCategory(
            context,
            appState,
            'Props',
            'prop',
            Icons.emoji_objects,
            unlockedIds,
            equippedCosmetics,
          ),
          const SizedBox(height: 32),

          // Bottom: Explanatory text
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Each completed day unlocks another small detail in your environment.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Next unlock preview
          _buildNextUnlockPreview(totalVotes),
        ],
      ),
    );
  }

  /// Simple abstract avatar representation
  /// Shows equipped cosmetics as stacked icons
  Widget _buildAvatarRepresentation(
    BuildContext context,
    Map<String, String> equippedCosmetics,
  ) {
    // Get cosmetic details for equipped items
    final equippedItems = <CosmeticItem>[];
    for (final entry in equippedCosmetics.entries) {
      final cosmetic = kAllCosmeticItems.firstWhere(
        (c) => c.id == entry.value,
        orElse: () => kAllCosmeticItems.first,
      );
      equippedItems.add(cosmetic);
    }

    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple.shade100,
            Colors.blue.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepPurple.shade200, width: 2),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Base avatar icon
            Icon(
              Icons.person,
              size: 64,
              color: Colors.deepPurple.shade700,
            ),
            const SizedBox(height: 8),
            // Show equipped items as small badges
            if (equippedItems.isNotEmpty)
              Wrap(
                spacing: 4,
                children: equippedItems.take(3).map((item) {
                  return Chip(
                    label: Text(
                      _getCosmeticIcon(item.category),
                      style: const TextStyle(fontSize: 16),
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  /// Get icon emoji for cosmetic category
  String _getCosmeticIcon(String category) {
    switch (category) {
      case 'environment':
        return '🏠';
      case 'aura':
        return '✨';
      case 'prop':
        return '📝';
      default:
        return '⭐';
    }
  }

  /// Build a cosmetic category section
  Widget _buildCosmeticCategory(
    BuildContext context,
    AppState appState,
    String title,
    String category,
    IconData icon,
    List<String> unlockedIds,
    Map<String, String> equippedCosmetics,
  ) {
    // Get cosmetics for this category
    final categoryCosmetics = getCosmeticsByCategory(category);
    final unlockedInCategory = categoryCosmetics
        .where((c) => unlockedIds.contains(c.id))
        .toList();

    if (unlockedInCategory.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'No items unlocked yet',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
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

    final equippedId = equippedCosmetics[category];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: unlockedInCategory.map((cosmetic) {
                final isEquipped = cosmetic.id == equippedId;
                return InkWell(
                  onTap: () {
                    // Update equipped cosmetic
                    final newEquipped = Map<String, String>.from(equippedCosmetics);
                    newEquipped[category] = cosmetic.id;
                    appState.updateEquippedCosmetics(newEquipped);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isEquipped
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isEquipped
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade300,
                        width: isEquipped ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isEquipped)
                          const Icon(Icons.check_circle, size: 16),
                        if (isEquipped) const SizedBox(width: 4),
                        Text(
                          cosmetic.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isEquipped ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Show next cosmetic to unlock
  Widget _buildNextUnlockPreview(int totalVotes) {
    final nextCosmetic = getNextCosmeticToUnlock(totalVotes);

    if (nextCosmetic == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.celebration, color: Colors.green.shade700),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'You\'ve unlocked everything! Keep showing up.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final votesNeeded = nextCosmetic.requiredVotes - totalVotes;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_outline, color: Colors.orange.shade700),
              const SizedBox(width: 12),
              const Text(
                'Next unlock',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            nextCosmetic.label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            nextCosmetic.description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$votesNeeded more ${votesNeeded == 1 ? 'day' : 'days'} to unlock',
            style: TextStyle(
              fontSize: 14,
              color: Colors.orange.shade900,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
