import 'dart:math' as math;
import '../../data/models/habit.dart';

/// Identity Growth Service
///
/// Phase 67: Level 2 Growth Mechanism
///
/// Tracks the user's identity growth progression based on:
/// - Total identity votes across all habits
/// - Streak consistency (never miss twice)
/// - Recovery patterns (bouncing back)
/// - Habit diversity (multiple identity facets)
///
/// Levels unlock new features and visualizations:
/// - Level 1 (Seedling): 0-10 votes - Basic tracking
/// - Level 2 (Sprout): 11-50 votes - Skill Tree visible
/// - Level 3 (Sapling): 51-150 votes - Witness features
/// - Level 4 (Tree): 151-365 votes - Advanced analytics
/// - Level 5 (Oak): 366+ votes - Full identity dashboard
class IdentityGrowthService {
  static final IdentityGrowthService instance = IdentityGrowthService._();

  IdentityGrowthService._();

  /// Calculate the user's identity level based on their habits
  IdentityLevel calculateLevel(List<Habit> habits) {
    if (habits.isEmpty) return IdentityLevel.seed;

    final totalVotes = _calculateTotalVotes(habits);
    final consistencyScore = _calculateConsistencyScore(habits);
    final diversityScore = _calculateDiversityScore(habits);
    final recoveryScore = _calculateRecoveryScore(habits);

    // Composite score with weighted components
    // 60% votes, 20% consistency, 10% diversity, 10% recovery
    final compositeScore = (totalVotes * 0.6) +
        (consistencyScore * 100 * 0.2) +
        (diversityScore * 50 * 0.1) +
        (recoveryScore * 50 * 0.1);

    return IdentityLevel.fromScore(compositeScore);
  }

  /// Get detailed growth metrics
  IdentityGrowthMetrics getMetrics(List<Habit> habits) {
    if (habits.isEmpty) {
      return IdentityGrowthMetrics.empty();
    }

    final totalVotes = _calculateTotalVotes(habits);
    final level = calculateLevel(habits);
    final progressToNext = _calculateProgressToNextLevel(totalVotes, level);
    final consistencyScore = _calculateConsistencyScore(habits);
    final diversityScore = _calculateDiversityScore(habits);
    final recoveryScore = _calculateRecoveryScore(habits);

    return IdentityGrowthMetrics(
      currentLevel: level,
      totalVotes: totalVotes,
      progressToNextLevel: progressToNext,
      consistencyScore: consistencyScore,
      diversityScore: diversityScore,
      recoveryScore: recoveryScore,
      strongestIdentity: _getStrongestIdentity(habits),
      votesUntilNextLevel: level.votesToNextLevel - totalVotes,
      daysActive: _calculateDaysActive(habits),
    );
  }

  /// Get unlocked features for current level
  List<IdentityFeature> getUnlockedFeatures(IdentityLevel level) {
    return IdentityFeature.values
        .where((f) => f.requiredLevel.index <= level.index)
        .toList();
  }

  /// Get next milestone message
  String getNextMilestoneMessage(IdentityGrowthMetrics metrics) {
    if (metrics.currentLevel == IdentityLevel.oak) {
      return 'You\'ve reached the highest level. Keep growing strong!';
    }

    final votesNeeded = metrics.votesUntilNextLevel;
    final nextLevel = IdentityLevel.values[metrics.currentLevel.index + 1];

    if (votesNeeded <= 5) {
      return 'Just $votesNeeded more votes to become a ${nextLevel.displayName}!';
    } else if (votesNeeded <= 20) {
      return 'You\'re close to ${nextLevel.displayName} status. Keep showing up!';
    } else {
      return '${nextLevel.displayName} awaits. ${votesNeeded} votes to go.';
    }
  }

  /// Calculate total identity votes
  int _calculateTotalVotes(List<Habit> habits) {
    return habits.fold<int>(0, (sum, h) => sum + (h.identityVotes ?? 0));
  }

  /// Calculate consistency score (0-1)
  /// Based on never-miss-twice rate and streak patterns
  double _calculateConsistencyScore(List<Habit> habits) {
    if (habits.isEmpty) return 0.0;

    double totalScore = 0.0;

    for (final habit in habits) {
      // Streak factor (longer = better)
      final streakFactor = math.min(habit.currentStreak / 30.0, 1.0);

      // Never-miss-twice factor
      final recoveryHistory = habit.recoveryHistory;
      final singleMissRecoveries = habit.singleMissRecoveries;
      final totalMisses = recoveryHistory.length;

      final neverMissTwiceFactor = totalMisses > 0
          ? singleMissRecoveries / totalMisses
          : 1.0;

      totalScore += (streakFactor * 0.6 + neverMissTwiceFactor * 0.4);
    }

    return (totalScore / habits.length).clamp(0.0, 1.0);
  }

  /// Calculate diversity score (0-1)
  /// More habits with distinct identities = higher score
  double _calculateDiversityScore(List<Habit> habits) {
    if (habits.isEmpty) return 0.0;

    // Count unique identities
    final identities = habits
        .map((h) => h.identity?.toLowerCase().trim())
        .where((i) => i != null && i.isNotEmpty)
        .toSet();

    final uniqueCount = identities.length;

    // Optimal is 3-5 distinct identities
    if (uniqueCount >= 3 && uniqueCount <= 5) {
      return 1.0;
    } else if (uniqueCount >= 2) {
      return 0.7;
    } else if (uniqueCount >= 1) {
      return 0.4;
    }

    return 0.0;
  }

  /// Calculate recovery score (0-1)
  /// Based on how well user bounces back from misses
  double _calculateRecoveryScore(List<Habit> habits) {
    if (habits.isEmpty) return 0.5; // Neutral default

    int totalRecoveries = 0;
    int successfulRecoveries = 0;

    for (final habit in habits) {
      for (final recovery in habit.recoveryHistory) {
        totalRecoveries++;
        // Single-day miss recovery is successful
        if (recovery.daysMissed <= 1) {
          successfulRecoveries++;
        }
        // Using tiny version shows commitment
        if (recovery.usedTinyVersion) {
          successfulRecoveries++; // Bonus point
          totalRecoveries++;
        }
      }
    }

    if (totalRecoveries == 0) return 0.5;

    return (successfulRecoveries / totalRecoveries).clamp(0.0, 1.0);
  }

  /// Get the strongest identity (most votes)
  String? _getStrongestIdentity(List<Habit> habits) {
    if (habits.isEmpty) return null;

    final sorted = List<Habit>.from(habits)
      ..sort((a, b) => (b.identityVotes ?? 0).compareTo(a.identityVotes ?? 0));

    return sorted.first.identity;
  }

  /// Calculate progress to next level (0-1)
  double _calculateProgressToNextLevel(int totalVotes, IdentityLevel level) {
    if (level == IdentityLevel.oak) return 1.0;

    final nextLevel = IdentityLevel.values[level.index + 1];
    final currentThreshold = level.voteThreshold;
    final nextThreshold = nextLevel.voteThreshold;

    final progress = (totalVotes - currentThreshold) /
        (nextThreshold - currentThreshold);

    return progress.clamp(0.0, 1.0);
  }

  /// Calculate total days user has been active
  int _calculateDaysActive(List<Habit> habits) {
    if (habits.isEmpty) return 0;

    DateTime? earliest;
    DateTime? latest;

    for (final habit in habits) {
      for (final completion in habit.completionHistory) {
        if (earliest == null || completion.isBefore(earliest)) {
          earliest = completion;
        }
        if (latest == null || completion.isAfter(latest)) {
          latest = completion;
        }
      }
    }

    if (earliest == null || latest == null) return 0;

    return latest.difference(earliest).inDays + 1;
  }
}

/// Identity growth levels
enum IdentityLevel {
  seed(
    displayName: 'Seed',
    emoji: '🌱',
    voteThreshold: 0,
    description: 'Just planted. Every vote counts.',
  ),
  seedling(
    displayName: 'Seedling',
    emoji: '🌿',
    voteThreshold: 10,
    description: 'Taking root. Keep nurturing.',
  ),
  sprout(
    displayName: 'Sprout',
    emoji: '🌾',
    voteThreshold: 50,
    description: 'Growing strong. Identity forming.',
  ),
  sapling(
    displayName: 'Sapling',
    emoji: '🌳',
    voteThreshold: 150,
    description: 'Standing tall. Resilient.',
  ),
  tree(
    displayName: 'Tree',
    emoji: '🌲',
    voteThreshold: 365,
    description: 'Deep roots. Steady growth.',
  ),
  oak(
    displayName: 'Oak',
    emoji: '🏔️',
    voteThreshold: 1000,
    description: 'Unshakeable. Legendary.',
  );

  const IdentityLevel({
    required this.displayName,
    required this.emoji,
    required this.voteThreshold,
    required this.description,
  });

  final String displayName;
  final String emoji;
  final int voteThreshold;
  final String description;

  /// Votes needed to reach next level
  int get votesToNextLevel {
    if (this == IdentityLevel.oak) return 0;
    return IdentityLevel.values[index + 1].voteThreshold;
  }

  /// Create level from composite score
  static IdentityLevel fromScore(double score) {
    if (score >= 1000) return IdentityLevel.oak;
    if (score >= 365) return IdentityLevel.tree;
    if (score >= 150) return IdentityLevel.sapling;
    if (score >= 50) return IdentityLevel.sprout;
    if (score >= 10) return IdentityLevel.seedling;
    return IdentityLevel.seed;
  }
}

/// Features unlocked by identity level
enum IdentityFeature {
  basicTracking(
    id: 'basic_tracking',
    name: 'Basic Tracking',
    description: 'Track habits and streaks',
    requiredLevel: IdentityLevel.seed,
  ),
  skillTree(
    id: 'skill_tree',
    name: 'Skill Tree',
    description: 'Visualize your identity growth',
    requiredLevel: IdentityLevel.sprout,
  ),
  witnessFeatures(
    id: 'witness',
    name: 'The Witness',
    description: 'Social accountability',
    requiredLevel: IdentityLevel.sapling,
  ),
  advancedAnalytics(
    id: 'analytics',
    name: 'Advanced Analytics',
    description: 'Deep pattern insights',
    requiredLevel: IdentityLevel.tree,
  ),
  aiPersonas(
    id: 'personas',
    name: 'AI Personas',
    description: 'Sherlock, Oracle, Stoic',
    requiredLevel: IdentityLevel.sprout,
  ),
  ragMemory(
    id: 'memory',
    name: 'Memory Layer',
    description: 'AI remembers your journey',
    requiredLevel: IdentityLevel.sapling,
  );

  const IdentityFeature({
    required this.id,
    required this.name,
    required this.description,
    required this.requiredLevel,
  });

  final String id;
  final String name;
  final String description;
  final IdentityLevel requiredLevel;
}

/// Identity growth metrics
class IdentityGrowthMetrics {
  final IdentityLevel currentLevel;
  final int totalVotes;
  final double progressToNextLevel;
  final double consistencyScore;
  final double diversityScore;
  final double recoveryScore;
  final String? strongestIdentity;
  final int votesUntilNextLevel;
  final int daysActive;

  const IdentityGrowthMetrics({
    required this.currentLevel,
    required this.totalVotes,
    required this.progressToNextLevel,
    required this.consistencyScore,
    required this.diversityScore,
    required this.recoveryScore,
    this.strongestIdentity,
    required this.votesUntilNextLevel,
    required this.daysActive,
  });

  factory IdentityGrowthMetrics.empty() {
    return const IdentityGrowthMetrics(
      currentLevel: IdentityLevel.seed,
      totalVotes: 0,
      progressToNextLevel: 0,
      consistencyScore: 0,
      diversityScore: 0,
      recoveryScore: 0.5,
      votesUntilNextLevel: 10,
      daysActive: 0,
    );
  }

  /// Overall health score (0-1)
  double get overallHealth {
    return (consistencyScore * 0.4 +
            diversityScore * 0.3 +
            recoveryScore * 0.3)
        .clamp(0.0, 1.0);
  }
}
