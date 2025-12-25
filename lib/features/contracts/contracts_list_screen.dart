import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/router/app_routes.dart';
import '../../data/models/habit_contract.dart';
import '../../data/services/contract_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/sound_service.dart';
import '../../data/app_state.dart';
import '../../widgets/animated_nudge_button.dart';

/// Contracts List Screen
/// 
/// Phase 16.2: Habit Contracts
/// 
/// Shows all contracts for the current user:
/// - Contracts they created (as Builder)
/// - Contracts they joined (as Witness)
/// 
/// This is a minimal "witness dashboard" - expanded in Phase 16.3
class ContractsListScreen extends StatefulWidget {
  const ContractsListScreen({super.key});

  @override
  State<ContractsListScreen> createState() => _ContractsListScreenState();
}

class _ContractsListScreenState extends State<ContractsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load contracts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContractService>().loadContracts();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final contractService = context.watch<ContractService>();
    
    if (!authService.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Contracts')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.handshake_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Sign in to view contracts',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.go(AppRoutes.settings),
                  child: const Text('Go to Settings'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contracts'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.person),
              text: 'My Habits (${contractService.builderContracts.length})',
            ),
            Tab(
              icon: const Icon(Icons.visibility),
              text: 'Witnessing (${contractService.witnessContracts.length})',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => contractService.loadContracts(),
          ),
        ],
      ),
      body: contractService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBuilderTab(contractService),
                _buildWitnessTab(contractService),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.contractCreate),
        icon: const Icon(Icons.add),
        label: const Text('New Contract'),
      ),
    );
  }
  
  Widget _buildBuilderTab(ContractService contractService) {
    final contracts = contractService.builderContracts;
    
    if (contracts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.handshake_outlined,
        title: 'No Contracts Yet',
        subtitle: 'Create a contract and invite someone to hold you accountable.',
        actionLabel: 'Create Contract',
        onAction: () => context.go(AppRoutes.contractCreate),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => contractService.loadContracts(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: contracts.length,
        itemBuilder: (context, index) {
          return _buildContractCard(contracts[index], isBuilder: true);
        },
      ),
    );
  }
  
  Widget _buildWitnessTab(ContractService contractService) {
    final contracts = contractService.witnessContracts;
    
    if (contracts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.visibility_outlined,
        title: 'Not Witnessing Anyone',
        subtitle: 'When someone invites you to witness their habit contract, it will appear here.',
        actionLabel: 'Enter Invite Code',
        onAction: _showEnterCodeDialog,
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => contractService.loadContracts(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: contracts.length,
        itemBuilder: (context, index) {
          return _buildContractCard(contracts[index], isBuilder: false);
        },
      ),
    );
  }
  
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildContractCard(HabitContract contract, {required bool isBuilder}) {
    final statusColor = _getStatusColor(contract.status);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showContractDetails(contract, isBuilder),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(contract.status.emoji),
                        const SizedBox(width: 4),
                        Text(
                          contract.status.displayName,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (contract.isActive)
                    Text(
                      '${contract.daysRemaining} days left',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Title
              Text(
                contract.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Progress (if active)
              if (contract.isActive) ...[
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: contract.progressPercentage / 100,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          contract.isOnTrack ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${contract.completionRate.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: contract.isOnTrack ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatChip('🔥', '${contract.currentStreak}', 'Streak'),
                    const SizedBox(width: 8),
                    _buildStatChip('✅', '${contract.daysCompleted}', 'Done'),
                    const SizedBox(width: 8),
                    _buildStatChip('❌', '${contract.daysMissed}', 'Missed'),
                  ],
                ),
              ],
              
              // Pending state
              if (contract.status == ContractStatus.pending) ...[
                Row(
                  children: [
                    const Icon(Icons.hourglass_empty, size: 16, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      isBuilder 
                          ? 'Waiting for witness to join'
                          : 'Waiting for you to accept',
                      style: TextStyle(color: Colors.orange.shade700),
                    ),
                  ],
                ),
              ],
              
              // Actions
              if (isBuilder && contract.canShare) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _shareContract(contract),
                      icon: const Icon(Icons.share, size: 16),
                      label: const Text('Share Invite'),
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
  
  Widget _buildStatChip(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
  
  Color _getStatusColor(ContractStatus status) {
    switch (status) {
      case ContractStatus.draft:
        return Colors.grey;
      case ContractStatus.pending:
        return Colors.orange;
      case ContractStatus.active:
        return Colors.green;
      case ContractStatus.completed:
        return Colors.blue;
      case ContractStatus.broken:
        return Colors.red;
      case ContractStatus.cancelled:
        return Colors.grey;
    }
  }
  
  void _showContractDetails(HabitContract contract, bool isBuilder) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return _buildContractDetailsSheet(contract, isBuilder, scrollController);
        },
      ),
    );
  }
  
  Widget _buildContractDetailsSheet(
    HabitContract contract, 
    bool isBuilder,
    ScrollController scrollController,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ListView(
        controller: scrollController,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Header
          Row(
            children: [
              Text(contract.status.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contract.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      contract.status.displayName,
                      style: TextStyle(color: _getStatusColor(contract.status)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Commitment
          if (contract.commitmentStatement != null) ...[
            const Text('Commitment', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  '"${contract.commitmentStatement}"',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Progress
          if (contract.isActive) ...[
            const Text('Progress', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildProgressStat('Days Completed', '${contract.daysCompleted}'),
                        _buildProgressStat('Days Missed', '${contract.daysMissed}'),
                        _buildProgressStat('Current Streak', '${contract.currentStreak}'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: contract.progressPercentage / 100,
                      backgroundColor: Colors.grey.shade200,
                      minHeight: 8,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${contract.completionRate.toStringAsFixed(0)}% completion rate',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Details
          const Text('Details', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailRow('Duration', '${contract.durationDays} days'),
                  _buildDetailRow('Days Remaining', '${contract.daysRemaining}'),
                  _buildDetailRow('Nudge Frequency', contract.nudgeFrequency.displayName),
                  _buildDetailRow('Nudge Style', contract.nudgeStyle.displayName),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Actions
          if (!isBuilder && contract.isActive) ...[
            Center(
              child: AnimatedNudgeButton(
                onPressed: () => _sendNudge(contract),
                label: 'Send Nudge',
                style: NudgeButtonStyle.rocket,
              ),
            ),
          ],
          
          if (isBuilder && contract.canShare) ...[
            FilledButton.icon(
              onPressed: () => _shareContract(contract),
              icon: const Icon(Icons.share),
              label: const Text('Share Invite Link'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildProgressStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
  
  void _showEnterCodeDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Invite Code'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'e.g., ABC12345',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.characters,
          maxLength: 8,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              final code = controller.text.trim().toUpperCase();
              if (code.isNotEmpty) {
                context.go(AppRoutes.contractJoin(code));
              }
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _shareContract(HabitContract contract) async {
    final contractService = context.read<ContractService>();
    await contractService.shareInvite(contract);
  }
  
  void _sendNudge(HabitContract contract) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Nudge'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Send an encouraging message to help them stay on track.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: _getNudgeHint(contract.nudgeStyle),
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final message = controller.text.trim();
              if (message.isNotEmpty) {
                final contractService = context.read<ContractService>();
                await contractService.sendNudge(contract, message);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nudge sent!')),
                  );
                }
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
  
  String _getNudgeHint(NudgeStyle style) {
    switch (style) {
      case NudgeStyle.encouraging:
        return 'You got this! Keep going!';
      case NudgeStyle.firm:
        return 'Remember your commitment.';
      case NudgeStyle.playful:
        return 'Time to crush it! 💪';
      case NudgeStyle.dataOnly:
        return 'Day 5: 0 completions this week.';
    }
  }
}
