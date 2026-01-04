import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/habit.dart';
import '../../../data/providers/jitai_provider.dart';
import '../../../data/providers/user_provider.dart';
import '../../../domain/entities/psychometric_profile.dart';
import '../../../domain/services/vulnerability_opportunity_calculator.dart';
import '../../../domain/services/cascade_pattern_detector.dart';

/// The Bridge: Context-Aware Action Deck
///
/// Phase 67: Dashboard Redesign
///
/// The "Doing" state of the binary interface. Displays habits sorted by
/// JITAI priority (V-O scoring, cascade risk, timing) with glass card styling.
///
/// Features:
/// - Priority-sorted habit cards
/// - Cascade risk indicators
/// - Quick completion actions
/// - V-O state visualization
class TheBridge extends StatefulWidget {
  final List<Habit> habits;
  final Function(String habitId)? onHabitTap;
  final Function(String habitId, bool usedTiny)? onComplete;

  const TheBridge({
    super.key,
    required this.habits,
    this.onHabitTap,
    this.onComplete,
  });

  @override
  State<TheBridge> createState() => _TheBridgeState();
}

class _TheBridgeState extends State<TheBridge> {
  List<ScoredHabit>? _scoredHabits;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScoredHabits();
  }

  @override
  void didUpdateWidget(TheBridge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.habits != widget.habits) {
      _loadScoredHabits();
    }
  }

  Future<void> _loadScoredHabits() async {
    if (!mounted) return;

    final jitaiProvider = context.read<JITAIProvider>();
    final userProvider = context.read<UserProvider>();

    if (!jitaiProvider.isInitialized) {
      setState(() {
        _isLoading = false;
        _scoredHabits = null;
      });
      return;
    }

    // Build profile from UserProvider
    final profile = _buildProfile(userProvider);

    try {
      final scored = await jitaiProvider.getOptimalHabits(
        habits: widget.habits,
        profile: profile,
      );

      if (mounted) {
        setState(() {
          _scoredHabits = scored;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _scoredHabits = null;
        });
      }
    }
  }

  PsychometricProfile _buildProfile(UserProvider userProvider) {
    final userProfile = userProvider.userProfile;
    return PsychometricProfile(
      antiIdentityLabel: userProfile?.antiIdentityLabel,
      failureArchetype: userProfile?.failureArchetypeEnum,
      resistanceLieLabel: userProfile?.resistanceLieLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Fallback to unsorted list if JITAI not available
    final items = _scoredHabits ?? widget.habits.map((h) => _createFallbackScored(h)).toList();

    if (items.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: _loadScoredHabits,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _BridgeCard(
            scoredHabit: item,
            isFirst: index == 0,
            onTap: () => widget.onHabitTap?.call(item.habit.id),
            onComplete: (usedTiny) => widget.onComplete?.call(item.habit.id, usedTiny),
          );
        },
      ),
    );
  }

  ScoredHabit _createFallbackScored(Habit habit) {
    // Fallback when JITAI is not available
    return ScoredHabit(
      habit: habit,
      priorityScore: 0.5,
      voState: _neutralVOState(),
      cascadeRisk: _noCascadeRisk(),
      timingScore: 0.5,
      reason: 'Ready for you',
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'All done for today!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Every vote counts towards who you\'re becoming.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual Bridge Card with glass morphism
class _BridgeCard extends StatelessWidget {
  final ScoredHabit scoredHabit;
  final bool isFirst;
  final VoidCallback? onTap;
  final Function(bool usedTiny)? onComplete;

  const _BridgeCard({
    required this.scoredHabit,
    required this.isFirst,
    this.onTap,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final habit = scoredHabit.habit;
    final theme = Theme.of(context);
    final isCompleted = habit.isCompletedToday;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getCardColor(context).withValues(alpha: isFirst ? 0.25 : 0.15),
                  _getCardColor(context).withValues(alpha: isFirst ? 0.15 : 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getBorderColor(context),
                width: isFirst ? 2 : 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isCompleted ? null : onTap,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          // Priority indicator
                          if (isFirst) _buildPriorityBadge(context),
                          if (isFirst) const SizedBox(width: 8),

                          // Emoji
                          Text(
                            habit.habitEmoji ?? '🎯',
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),

                          // Title & Identity
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  habit.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    decoration: isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                if (habit.identity != null)
                                  Text(
                                    habit.identity!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // Streak badge
                          if (habit.currentStreak > 0)
                            _buildStreakBadge(context, habit.currentStreak),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Reason / Status Row
                      Row(
                        children: [
                          _buildStatusChip(context),
                          const Spacer(),
                          // Identity votes
                          Text(
                            '${habit.identityVotes ?? 0} votes',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),

                      // Action buttons (if not completed)
                      if (!isCompleted) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            // Tiny version button
                            if (habit.tinyVersion != null)
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => onComplete?.call(true),
                                  icon: const Icon(Icons.flash_on, size: 16),
                                  label: Text(
                                    habit.tinyVersion!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: theme.colorScheme.secondary,
                                    side: BorderSide(
                                      color: theme.colorScheme.secondary.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                              ),
                            if (habit.tinyVersion != null) const SizedBox(width: 8),

                            // Full completion button
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () => onComplete?.call(false),
                                icon: const Icon(Icons.check, size: 16),
                                label: const Text('Complete'),
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Completed state
                      if (isCompleted)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Identity vote cast',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getCardColor(BuildContext context) {
    final theme = Theme.of(context);

    // High cascade risk = warm warning color
    if (scoredHabit.cascadeRisk.probability > 0.6) {
      return Colors.orange;
    }

    // High priority = primary color
    if (scoredHabit.isHighPriority) {
      return theme.colorScheme.primary;
    }

    // Default surface
    return theme.colorScheme.surfaceContainerHighest;
  }

  Color _getBorderColor(BuildContext context) {
    final theme = Theme.of(context);

    if (scoredHabit.cascadeRisk.probability > 0.6) {
      return Colors.orange.withValues(alpha: 0.6);
    }

    if (isFirst) {
      return theme.colorScheme.primary.withValues(alpha: 0.6);
    }

    return theme.colorScheme.outline.withValues(alpha: 0.2);
  }

  Widget _buildPriorityBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'NOW',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStreakBadge(BuildContext context, int streak) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final theme = Theme.of(context);
    final reason = scoredHabit.reason;

    IconData icon;
    Color color;

    if (scoredHabit.cascadeRisk.probability > 0.6) {
      icon = Icons.warning_amber;
      color = Colors.orange;
    } else if (scoredHabit.isInterventionReady) {
      icon = Icons.bolt;
      color = theme.colorScheme.primary;
    } else {
      icon = Icons.schedule;
      color = theme.colorScheme.onSurfaceVariant;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          reason,
          style: theme.textTheme.bodySmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

/// Helper to create neutral VOState for fallback
VOState _neutralVOState() => VOState(
  vulnerability: 0.5,
  opportunity: 0.5,
  predictiveFailureProbability: 0.0,
  dominantRiskFactors: [],
  dominantOpportunityFactors: [],
  calculatedAt: DateTime.now(),
);

/// Helper to create no-risk CascadeRisk for fallback
CascadeRisk _noCascadeRisk() => CascadeRisk(
  probability: 0.0,
  reason: CascadeRiskReason.baseline,
  explanation: '',
  isHighRisk: false,
);
