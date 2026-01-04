import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../data/models/habit.dart';

/// Skill Tree: Identity Growth Visualization
///
/// Phase 67: Dashboard Redesign - Level 2 MVP
///
/// The "Being" state of the binary interface. Visualizes habit growth
/// as a living tree where:
/// - Root = Core identity
/// - Trunk = Primary habit (most votes)
/// - Branches = Related habits
/// - Leaves = Completion density (greener = more consistent)
/// - Fruits = Milestone achievements
class SkillTree extends StatefulWidget {
  final List<Habit> habits;
  final String? coreIdentity;
  final VoidCallback? onHabitTap;

  const SkillTree({
    super.key,
    required this.habits,
    this.coreIdentity,
    this.onHabitTap,
  });

  @override
  State<SkillTree> createState() => _SkillTreeState();
}

class _SkillTreeState extends State<SkillTree> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _growthAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _growthAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _growthAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: _SkillTreePainter(
            habits: widget.habits,
            coreIdentity: widget.coreIdentity ?? 'Someone who shows up',
            growthProgress: _growthAnimation.value,
            theme: Theme.of(context),
          ),
          child: child,
        );
      },
      child: _buildOverlays(context),
    );
  }

  Widget _buildOverlays(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        // Core identity label at bottom
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                widget.coreIdentity ?? 'Someone who shows up',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        ),

        // Stats overlay
        Positioned(
          top: 16,
          right: 16,
          child: _buildStatsCard(context),
        ),

        // Legend
        Positioned(
          top: 16,
          left: 16,
          child: _buildLegend(context),
        ),
      ],
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    final theme = Theme.of(context);
    final totalVotes = widget.habits.fold<int>(0, (sum, h) => sum + (h.identityVotes ?? 0));
    final totalStreak = widget.habits.fold<int>(0, (sum, h) => sum + h.currentStreak);
    final completedToday = widget.habits.where((h) => h.isCompletedToday).length;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              _statRow(context, '🗳️', '$totalVotes votes'),
              const SizedBox(height: 4),
              _statRow(context, '🔥', '$totalStreak day streak'),
              const SizedBox(height: 4),
              _statRow(context, '✅', '$completedToday/${widget.habits.length} today'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statRow(BuildContext context, String emoji, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your Identity Tree',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _legendItem(context, Colors.green.shade800, 'Strong habit'),
              _legendItem(context, Colors.green.shade400, 'Growing'),
              _legendItem(context, Colors.yellow.shade600, 'Needs attention'),
              _legendItem(context, Colors.orange, 'At risk'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendItem(BuildContext context, Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the skill tree
class _SkillTreePainter extends CustomPainter {
  final List<Habit> habits;
  final String coreIdentity;
  final double growthProgress;
  final ThemeData theme;

  _SkillTreePainter({
    required this.habits,
    required this.coreIdentity,
    required this.growthProgress,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (habits.isEmpty) {
      _drawEmptyState(canvas, size);
      return;
    }

    final center = Offset(size.width / 2, size.height);
    final maxHeight = size.height * 0.85;

    // Sort habits by identity votes (trunk = most votes)
    final sortedHabits = List<Habit>.from(habits)
      ..sort((a, b) => (b.identityVotes ?? 0).compareTo(a.identityVotes ?? 0));

    // Draw tree components
    _drawRoots(canvas, center, size);
    _drawTrunk(canvas, center, maxHeight);
    _drawBranches(canvas, center, maxHeight, sortedHabits);
    _drawLeaves(canvas, center, maxHeight, sortedHabits);
  }

  void _drawEmptyState(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.colorScheme.outline.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw a simple sapling outline
    final center = Offset(size.width / 2, size.height * 0.9);

    // Stem
    canvas.drawLine(
      center,
      Offset(center.dx, size.height * 0.5),
      paint,
    );

    // Small leaves
    final leafPath = Path();
    leafPath.moveTo(center.dx, size.height * 0.5);
    leafPath.quadraticBezierTo(
      center.dx - 30,
      size.height * 0.4,
      center.dx - 20,
      size.height * 0.45,
    );
    leafPath.quadraticBezierTo(
      center.dx + 30,
      size.height * 0.4,
      center.dx + 20,
      size.height * 0.45,
    );

    canvas.drawPath(leafPath, paint);
  }

  void _drawRoots(Canvas canvas, Offset base, Size size) {
    final paint = Paint()
      ..color = _adjustBrightness(Colors.brown.shade700, 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * growthProgress
      ..strokeCap = StrokeCap.round;

    final rootCount = 3;
    final rootSpread = size.width * 0.15;

    for (int i = 0; i < rootCount; i++) {
      final angle = (i - 1) * 0.3;
      final rootEnd = Offset(
        base.dx + math.sin(angle) * rootSpread * growthProgress,
        base.dy + 20 * growthProgress,
      );

      final path = Path();
      path.moveTo(base.dx, base.dy);
      path.quadraticBezierTo(
        base.dx + math.sin(angle) * rootSpread * 0.5,
        base.dy + 10,
        rootEnd.dx,
        rootEnd.dy,
      );

      canvas.drawPath(path, paint);
    }
  }

  void _drawTrunk(Canvas canvas, Offset base, double maxHeight) {
    final trunkHeight = maxHeight * 0.4 * growthProgress;
    final trunkWidth = 12.0;

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Colors.brown.shade800,
          Colors.brown.shade600,
        ],
      ).createShader(Rect.fromLTWH(
        base.dx - trunkWidth / 2,
        base.dy - trunkHeight,
        trunkWidth,
        trunkHeight,
      ));

    final path = Path();
    path.moveTo(base.dx - trunkWidth / 2, base.dy);
    path.lineTo(base.dx - trunkWidth / 3, base.dy - trunkHeight);
    path.lineTo(base.dx + trunkWidth / 3, base.dy - trunkHeight);
    path.lineTo(base.dx + trunkWidth / 2, base.dy);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawBranches(Canvas canvas, Offset base, double maxHeight, List<Habit> sortedHabits) {
    if (sortedHabits.isEmpty) return;

    final trunkTop = Offset(base.dx, base.dy - maxHeight * 0.4 * growthProgress);
    final branchCount = sortedHabits.length.clamp(1, 5);

    for (int i = 0; i < branchCount; i++) {
      final habit = sortedHabits[i];
      final healthScore = _calculateHealthScore(habit);

      // Branch angle and length based on position
      final angle = (i - (branchCount - 1) / 2) * 0.4;
      final branchLength = (maxHeight * 0.25 + i * 10) * growthProgress;

      // Branch starting point (along trunk)
      final branchStart = Offset(
        trunkTop.dx,
        trunkTop.dy + (i * maxHeight * 0.08),
      );

      final branchEnd = Offset(
        branchStart.dx + math.sin(angle) * branchLength,
        branchStart.dy - math.cos(angle) * branchLength * 0.6,
      );

      final paint = Paint()
        ..color = _adjustBrightness(
          _getHealthColor(healthScore),
          0.7,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4 - i * 0.5
        ..strokeCap = StrokeCap.round;

      final path = Path();
      path.moveTo(branchStart.dx, branchStart.dy);
      path.quadraticBezierTo(
        (branchStart.dx + branchEnd.dx) / 2,
        branchStart.dy - 20,
        branchEnd.dx,
        branchEnd.dy,
      );

      canvas.drawPath(path, paint);

      // Draw habit node
      _drawHabitNode(canvas, branchEnd, habit, healthScore);
    }
  }

  void _drawHabitNode(Canvas canvas, Offset position, Habit habit, double healthScore) {
    final radius = 16.0 + (habit.identityVotes ?? 0) * 0.5;

    // Glow effect
    final glowPaint = Paint()
      ..color = _getHealthColor(healthScore).withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(position, radius + 4, glowPaint);

    // Main circle
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          _getHealthColor(healthScore),
          _adjustBrightness(_getHealthColor(healthScore), 0.7),
        ],
      ).createShader(Rect.fromCircle(center: position, radius: radius));

    canvas.drawCircle(position, radius, paint);

    // Border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(position, radius, borderPaint);

    // Emoji
    final textPainter = TextPainter(
      text: TextSpan(
        text: habit.habitEmoji ?? '🎯',
        style: TextStyle(fontSize: radius * 0.9),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawLeaves(Canvas canvas, Offset base, double maxHeight, List<Habit> habits) {
    // Decorative leaves around the canopy
    final random = math.Random(42); // Deterministic for consistency

    for (int i = 0; i < 20; i++) {
      final angle = random.nextDouble() * math.pi * 2;
      final distance = 80 + random.nextDouble() * 60;

      final canopyCenter = Offset(
        base.dx,
        base.dy - maxHeight * 0.5,
      );

      final leafPos = Offset(
        canopyCenter.dx + math.cos(angle) * distance * growthProgress,
        canopyCenter.dy + math.sin(angle) * distance * 0.6 * growthProgress,
      );

      final leafSize = 6 + random.nextDouble() * 8;

      // Calculate overall health for leaf color
      final avgHealth = habits.isEmpty
          ? 0.5
          : habits.fold<double>(0, (sum, h) => sum + _calculateHealthScore(h)) / habits.length;

      final leafPaint = Paint()
        ..color = _getHealthColor(avgHealth).withValues(alpha: 0.6 + random.nextDouble() * 0.3);

      canvas.drawCircle(leafPos, leafSize, leafPaint);
    }
  }

  double _calculateHealthScore(Habit habit) {
    // Health based on streak and consistency
    final votes = habit.identityVotes ?? 0;
    final streak = habit.currentStreak;
    final isCompletedToday = habit.isCompletedToday;

    double score = 0.3; // Base

    // Streak bonus
    if (streak >= 30) {
      score += 0.4;
    } else if (streak >= 7) {
      score += 0.3;
    } else if (streak >= 1) {
      score += 0.1;
    }

    // Today's completion
    if (isCompletedToday) {
      score += 0.2;
    }

    // Identity investment
    if (votes >= 50) {
      score += 0.1;
    }

    return score.clamp(0.0, 1.0);
  }

  Color _getHealthColor(double score) {
    if (score >= 0.8) return Colors.green.shade700;
    if (score >= 0.6) return Colors.green.shade400;
    if (score >= 0.4) return Colors.yellow.shade600;
    if (score >= 0.2) return Colors.orange;
    return Colors.red.shade400;
  }

  Color _adjustBrightness(Color color, double factor) {
    return Color.fromARGB(
      color.alpha,
      (color.red * factor).round().clamp(0, 255),
      (color.green * factor).round().clamp(0, 255),
      (color.blue * factor).round().clamp(0, 255),
    );
  }

  @override
  bool shouldRepaint(covariant _SkillTreePainter oldDelegate) {
    return oldDelegate.growthProgress != growthProgress ||
        oldDelegate.habits != habits;
  }
}
