import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/contract_service.dart';
import '../../data/services/witness_service.dart';
import '../../data/models/habit_contract.dart';
import '../../data/models/witness_event.dart';
import 'high_five_sheet.dart';

/// Witness Dashboard
/// 
/// Phase 22: "The Witness" - Social Accountability Loop
/// 
/// Displays all accountability relationships in one place:
/// - Contracts where user is the Builder (people watching me)
/// - Contracts where user is the Witness (people I'm watching)
/// - Recent activity feed (completions, high-fives, nudges)
/// - Quick actions (send high-five, send nudge)
class WitnessDashboard extends StatefulWidget {
  const WitnessDashboard({super.key});

  @override
  State<WitnessDashboard> createState() => _WitnessDashboardState();
}

class _WitnessDashboardState extends State<WitnessDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accountability'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Witnesses'),
            Tab(text: 'I Witness'),
            Tab(text: 'Activity'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MyWitnessesTab(),
          _IWitnessTab(),
          _ActivityTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed('/contracts/create'),
        icon: const Icon(Icons.add),
        label: const Text('New Contract'),
      ),
    );
  }
}

/// Tab showing contracts where the user is the Builder
/// (People who are watching the user)
class _MyWitnessesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ContractService>(
      builder: (context, contractService, child) {
        final contracts = contractService.builderContracts
            .where((c) => c.isActive || c.status == ContractStatus.pending)
            .toList();
        
        if (contracts.isEmpty) {
          return _EmptyState(
            icon: '🤝',
            title: 'No Accountability Partners Yet',
            subtitle: 'Create a contract and invite someone to be your witness.',
            actionLabel: 'Create Contract',
            onAction: () => Navigator.of(context).pushNamed('/contracts/create'),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: contracts.length,
          itemBuilder: (context, index) {
            final contract = contracts[index];
            return _WitnessContractCard(
              contract: contract,
              isBuilder: true,
            );
          },
        );
      },
    );
  }
}

/// Tab showing contracts where the user is the Witness
/// (People the user is watching)
class _IWitnessTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ContractService>(
      builder: (context, contractService, child) {
        final contracts = contractService.witnessContracts
            .where((c) => c.isActive)
            .toList();
        
        if (contracts.isEmpty) {
          return _EmptyState(
            icon: '👀',
            title: 'Not Witnessing Anyone',
            subtitle: 'Accept a contract invite to become someone\'s accountability partner.',
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: contracts.length,
          itemBuilder: (context, index) {
            final contract = contracts[index];
            return _WitnessContractCard(
              contract: contract,
              isBuilder: false,
            );
          },
        );
      },
    );
  }
}

/// Activity feed showing recent witness events
class _ActivityTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<WitnessService>(
      builder: (context, witnessService, child) {
        final events = witnessService.recentEvents;
        
        if (events.isEmpty) {
          return _EmptyState(
            icon: '📭',
            title: 'No Activity Yet',
            subtitle: 'Events will appear here when you or your partners complete habits.',
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return _ActivityEventCard(event: event);
          },
        );
      },
    );
  }
}

/// Card displaying a contract in the witness dashboard
class _WitnessContractCard extends StatelessWidget {
  final HabitContract contract;
  final bool isBuilder;
  
  const _WitnessContractCard({
    required this.contract,
    required this.isBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showContractDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(theme).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(contract.status.emoji),
                        const SizedBox(width: 4),
                        Text(
                          contract.status.displayName,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _getStatusColor(theme),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Role indicator
                  Text(
                    isBuilder ? 'Builder' : 'Witness',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Contract title
              Text(
                contract.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Progress bar
              if (contract.isActive) ...[
                LinearProgressIndicator(
                  value: contract.completionRate / 100,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  color: contract.isOnTrack 
                      ? Colors.green 
                      : Colors.orange,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${contract.daysCompleted}/${contract.durationDays} days',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      '${contract.completionRate.toStringAsFixed(0)}% completion',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: contract.isOnTrack ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
              
              // Streak info
              if (contract.currentStreak > 0) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text(
                      '${contract.currentStreak} day streak',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
              
              // Quick actions for Witness
              if (!isBuilder && contract.isActive) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _sendHighFive(context),
                      icon: const Text('🖐️'),
                      label: const Text('High Five'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _sendNudge(context),
                      icon: const Text('💬'),
                      label: const Text('Nudge'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getStatusColor(ThemeData theme) {
    switch (contract.status) {
      case ContractStatus.active:
        return Colors.green;
      case ContractStatus.pending:
        return Colors.orange;
      case ContractStatus.completed:
        return theme.colorScheme.primary;
      case ContractStatus.broken:
        return Colors.red;
      case ContractStatus.cancelled:
        return Colors.grey;
      default:
        return theme.colorScheme.onSurface;
    }
  }
  
  void _showContractDetails(BuildContext context) {
    Navigator.of(context).pushNamed('/contracts/${contract.id}');
  }
  
  void _sendHighFive(BuildContext context) {
    HighFiveSheet.show(
      context,
      contractId: contract.id,
      builderId: contract.builderId,
      builderName: null, // Would need to fetch from user profile
      habitName: contract.title,
      onSend: (emoji, message) async {
        final witnessService = context.read<WitnessService>();
        await witnessService.sendHighFive(
          contractId: contract.id,
          builderId: contract.builderId,
          emoji: emoji,
          message: message,
        );
      },
    );
  }
  
  void _sendNudge(BuildContext context) {
    _showNudgeDialog(context);
  }
  
  void _showNudgeDialog(BuildContext context) {
    final messageController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send a Nudge'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Write an encouraging message to help them stay on track.'),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                hintText: 'Hey! Time for your habit?',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final witnessService = context.read<WitnessService>();
              await witnessService.sendNudge(
                contractId: contract.id,
                builderId: contract.builderId,
                message: messageController.text.isNotEmpty
                    ? messageController.text
                    : 'Your witness is checking in! Time for your habit?',
              );
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nudge sent!')),
                );
              }
            },
            child: const Text('Send Nudge'),
          ),
        ],
      ),
    );
  }
}

/// Card displaying an activity event
class _ActivityEventCard extends StatelessWidget {
  final WitnessEvent event;
  
  const _ActivityEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getEventColor(theme).withOpacity(0.1),
          child: Text(
            _getEventEmoji(),
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(event.notificationTitle),
        subtitle: Text(
          event.notificationBody,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTime(event.createdAt),
              style: theme.textTheme.bodySmall,
            ),
            if (!event.isRead)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        onTap: () {
          // Mark as read and handle action
          final witnessService = context.read<WitnessService>();
          witnessService.markEventAsRead(event.id);
        },
      ),
    );
  }
  
  String _getEventEmoji() {
    switch (event.type) {
      case WitnessEventType.habitCompleted:
        return '⚡';
      case WitnessEventType.streakMilestone:
        return '🔥';
      case WitnessEventType.highFiveReceived:
        return event.reaction?.emoji ?? '🖐️';
      case WitnessEventType.nudgeReceived:
        return '💬';
      case WitnessEventType.driftWarning:
        return '⚠️';
      case WitnessEventType.witnessJoined:
        return '🤝';
      case WitnessEventType.contractAccepted:
        return '✅';
      case WitnessEventType.streakBroken:
        return '😢';
      case WitnessEventType.contractCompleted:
        return '🏆';
      default:
        return '📣';
    }
  }
  
  Color _getEventColor(ThemeData theme) {
    switch (event.type) {
      case WitnessEventType.habitCompleted:
      case WitnessEventType.streakMilestone:
        return Colors.green;
      case WitnessEventType.highFiveReceived:
        return Colors.amber;
      case WitnessEventType.nudgeReceived:
        return Colors.blue;
      case WitnessEventType.driftWarning:
        return Colors.orange;
      case WitnessEventType.witnessJoined:
      case WitnessEventType.contractAccepted:
        return theme.colorScheme.primary;
      case WitnessEventType.streakBroken:
        return Colors.red;
      case WitnessEventType.contractCompleted:
        return Colors.purple;
      default:
        return theme.colorScheme.onSurface;
    }
  }
  
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${time.month}/${time.day}';
    }
  }
}

/// Empty state widget
class _EmptyState extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
