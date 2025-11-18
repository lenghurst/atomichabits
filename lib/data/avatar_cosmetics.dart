/// Avatar cosmetic items that unlock as users show up consistently
/// Based on cumulative completions (identity votes), not fragile streaks
/// Theme: Calm, identity-aligned progression (not casino/gacha)

class CosmeticItem {
  final String id; // Unique identifier
  final String category; // "environment", "aura", "prop"
  final int requiredVotes; // Total completions needed to unlock
  final String label; // User-facing name (British English)
  final String description; // Flavour text

  const CosmeticItem({
    required this.id,
    required this.category,
    required this.requiredVotes,
    required this.label,
    required this.description,
  });
}

/// Hard-coded starter set of cosmetics
/// Designed to be:
/// - Thematically linked to identity and habit formation
/// - Predictable unlocks (no randomness)
/// - Never removed once unlocked (no punitive mechanics)
const List<CosmeticItem> kAllCosmeticItems = [
  // === ENVIRONMENT ITEMS (physical space) ===

  // Unlock at day 1 - everyone gets something immediately
  CosmeticItem(
    id: 'env_clean_desk',
    category: 'environment',
    requiredVotes: 1,
    label: 'Clean desk',
    description: 'A tidy space to begin your journey.',
  ),

  // Unlock at day 3
  CosmeticItem(
    id: 'env_small_plant',
    category: 'environment',
    requiredVotes: 3,
    label: 'Small plant',
    description: 'Growing steadily, just like you.',
  ),

  // Unlock at day 7
  CosmeticItem(
    id: 'env_warm_lamp',
    category: 'environment',
    requiredVotes: 7,
    label: 'Warm lamp',
    description: 'Soft light for focused work.',
  ),

  // Unlock at day 14
  CosmeticItem(
    id: 'env_bookshelf',
    category: 'environment',
    requiredVotes: 14,
    label: 'Bookshelf',
    description: 'Knowledge gathered over time.',
  ),

  // Unlock at day 30
  CosmeticItem(
    id: 'env_cosy_chair',
    category: 'environment',
    requiredVotes: 30,
    label: 'Cosy chair',
    description: 'A comfortable space you\'ve earned.',
  ),

  // === AURA ITEMS (identity visual effects) ===

  // Unlock at day 2
  CosmeticItem(
    id: 'aura_faint_glow',
    category: 'aura',
    requiredVotes: 2,
    label: 'Faint glow',
    description: 'Your identity beginning to shine.',
  ),

  // Unlock at day 5
  CosmeticItem(
    id: 'aura_steady_light',
    category: 'aura',
    requiredVotes: 5,
    label: 'Steady light',
    description: 'Consistency building strength.',
  ),

  // Unlock at day 10
  CosmeticItem(
    id: 'aura_confident_shine',
    category: 'aura',
    requiredVotes: 10,
    label: 'Confident shine',
    description: 'You\'ve shown up. It shows.',
  ),

  // Unlock at day 21
  CosmeticItem(
    id: 'aura_radiant_presence',
    category: 'aura',
    requiredVotes: 21,
    label: 'Radiant presence',
    description: 'Three weeks of evidence.',
  ),

  // === PROP ITEMS (symbolic objects) ===

  // Unlock at day 4
  CosmeticItem(
    id: 'prop_journal',
    category: 'prop',
    requiredVotes: 4,
    label: 'Small journal',
    description: 'Tracking your journey.',
  ),

  // Unlock at day 12
  CosmeticItem(
    id: 'prop_identity_card',
    category: 'prop',
    requiredVotes: 12,
    label: 'Identity card',
    description: 'Framed reminder of who you are.',
  ),

  // Unlock at day 20
  CosmeticItem(
    id: 'prop_achievement_token',
    category: 'prop',
    requiredVotes: 20,
    label: 'Achievement token',
    description: 'A small symbol of commitment.',
  ),
];

/// Get all cosmetics for a specific category
List<CosmeticItem> getCosmeticsByCategory(String category) {
  return kAllCosmeticItems.where((item) => item.category == category).toList();
}

/// Get all unlocked cosmetics for a user based on total votes
List<CosmeticItem> getUnlockedCosmetics(int totalVotes) {
  return kAllCosmeticItems
      .where((item) => item.requiredVotes <= totalVotes)
      .toList();
}

/// Get the next cosmetic to unlock (null if all unlocked)
CosmeticItem? getNextCosmeticToUnlock(int totalVotes) {
  final locked = kAllCosmeticItems
      .where((item) => item.requiredVotes > totalVotes)
      .toList();

  if (locked.isEmpty) return null;

  // Return the cosmetic with the lowest required votes
  locked.sort((a, b) => a.requiredVotes.compareTo(b.requiredVotes));
  return locked.first;
}
