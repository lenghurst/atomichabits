/// InterventionModal - Active Intervention Display
///
/// Shows the current JITAI intervention to the user.
/// Displays the intervention message and tracks engagement.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/jitai_provider.dart';
import '../../../domain/services/jitai_decision_engine.dart';

/// Shows an intervention modal
Future<bool?> showInterventionModal(BuildContext context) {
  final jitai = context.read<JITAIProvider>();
  final intervention = jitai.activeIntervention;

  if (intervention == null) return Future.value(null);

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => InterventionModal(intervention: intervention),
  );
}

class InterventionModal extends StatefulWidget {
  final ActiveIntervention intervention;

  const InterventionModal({
    super.key,
    required this.intervention,
  });

  @override
  State<InterventionModal> createState() => _InterventionModalState();
}

class _InterventionModalState extends State<InterventionModal> {
  final Stopwatch _engagementTimer = Stopwatch();

  @override
  void initState() {
    super.initState();
    _engagementTimer.start();
  }

  @override
  void dispose() {
    _engagementTimer.stop();
    super.dispose();
  }

  void _handleEngage(BuildContext context, bool willComplete) {
    final jitai = context.read<JITAIProvider>();
    final eventId = widget.intervention.decision.event?.eventId ?? '';

    jitai.recordInterventionOutcome(
      eventId: eventId,
      engaged: true,
      habitCompleted: willComplete,
      engagementSeconds: _engagementTimer.elapsed.inSeconds,
    );

    Navigator.of(context).pop(willComplete);
  }

  void _handleDismiss(BuildContext context) {
    final jitai = context.read<JITAIProvider>();
    jitai.dismissIntervention(reason: 'user_dismissed');
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.intervention.decision.event;
    if (event == null) return const SizedBox.shrink();

    final arm = event.arm;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Lever icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _colorForLever(arm.lever).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _iconForLever(arm.lever),
                  size: 32,
                  color: _colorForLever(arm.lever),
                ),
              ),
              const SizedBox(height: 16),

              // Habit name
              Text(
                widget.intervention.habitName,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),

              // Message
              Text(
                arm.message,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _handleDismiss(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Not now'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: () => _handleEngage(context, true),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Let\'s do it'),
                    ),
                  ),
                ],
              ),

              // Secondary action
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => _handleEngage(context, false),
                child: Text(
                  'I\'ll try the tiny version',
                  style: TextStyle(
                    color: theme.colorScheme.primary.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForLever(MetaLever lever) {
    switch (lever) {
      case MetaLever.activate:
        return Icons.flash_on;
      case MetaLever.support:
        return Icons.favorite;
      case MetaLever.trust:
        return Icons.self_improvement;
    }
  }

  Color _colorForLever(MetaLever lever) {
    switch (lever) {
      case MetaLever.activate:
        return Colors.orange;
      case MetaLever.support:
        return Colors.pink;
      case MetaLever.trust:
        return Colors.purple;
    }
  }
}

/// Inline intervention banner for less intrusive display
class InterventionBanner extends StatelessWidget {
  final ActiveIntervention intervention;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const InterventionBanner({
    super.key,
    required this.intervention,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final event = intervention.decision.event;
    if (event == null) return const SizedBox.shrink();

    final arm = event.arm;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _colorForLever(arm.lever).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _iconForLever(arm.lever),
                  size: 20,
                  color: _colorForLever(arm.lever),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      intervention.habitName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      arm.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onDismiss,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForLever(MetaLever lever) {
    switch (lever) {
      case MetaLever.activate:
        return Icons.flash_on;
      case MetaLever.support:
        return Icons.favorite;
      case MetaLever.trust:
        return Icons.self_improvement;
    }
  }

  Color _colorForLever(MetaLever lever) {
    switch (lever) {
      case MetaLever.activate:
        return Colors.orange;
      case MetaLever.support:
        return Colors.pink;
      case MetaLever.trust:
        return Colors.purple;
    }
  }
}
