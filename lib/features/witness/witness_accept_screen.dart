import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/contract_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/habit_contract.dart';

/// Witness Accept Screen
/// 
/// Phase 22: "The Witness" - Social Accountability Loop
/// 
/// Shown when a user clicks a contract invite deep link:
/// 1. Displays the contract details (habit, builder, duration)
/// 2. Asks: "Do you accept to witness [Habit]?"
/// 3. On accept: Creates the witness relationship in Supabase
/// 4. Both parties now receive real-time notifications
/// 
/// Route: /contracts/join/:inviteCode
class WitnessAcceptScreen extends StatefulWidget {
  final String inviteCode;
  
  const WitnessAcceptScreen({
    super.key,
    required this.inviteCode,
  });

  @override
  State<WitnessAcceptScreen> createState() => _WitnessAcceptScreenState();
}

class _WitnessAcceptScreenState extends State<WitnessAcceptScreen> {
  bool _isLoading = true;
  bool _isAccepting = false;
  HabitContract? _contract;
  String? _error;
  final TextEditingController _messageController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadContract();
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
  
  Future<void> _loadContract() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    final contractService = context.read<ContractService>();
    final result = await contractService.lookupByInviteCode(widget.inviteCode);
    
    setState(() {
      _isLoading = false;
      if (result.success && result.contract != null) {
        _contract = result.contract;
      } else {
        _error = result.error ?? 'Contract not found';
      }
    });
  }
  
  Future<void> _acceptContract() async {
    if (_contract == null) return;
    
    final authService = context.read<AuthService>();
    
    // Check if user is authenticated
    if (!authService.isAuthenticated) {
      _showAuthRequiredDialog();
      return;
    }
    
    // Check if trying to witness own contract
    if (_contract!.builderId == authService.userId) {
      setState(() {
        _error = 'You cannot be a witness for your own contract';
      });
      return;
    }
    
    setState(() => _isAccepting = true);
    
    final contractService = context.read<ContractService>();
    final result = await contractService.acceptInvite(
      _contract!,
      witnessMessage: _messageController.text.isNotEmpty 
          ? _messageController.text 
          : null,
    );
    
    setState(() => _isAccepting = false);
    
    if (result.success) {
      _showSuccessDialog();
    } else {
      setState(() {
        _error = result.error ?? 'Failed to accept contract';
      });
    }
  }
  
  void _showAuthRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign In Required'),
        content: const Text(
          'To become an accountability witness, you need to create an account. '
          'This lets us notify you when your partner completes their habit.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to auth screen
              Navigator.of(context).pushNamed('/settings/account');
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }
  
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Text('🤝', style: TextStyle(fontSize: 48)),
        title: const Text('You\'re In!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You\'re now the accountability witness for "${_contract!.title}".',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'What happens now:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1. You\'ll get notified when they complete their habit\n'
                    '2. Send high-fives to celebrate their wins\n'
                    '3. Nudge them if they\'re about to miss',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/contracts');
            },
            child: const Text('View Contract'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a Witness'),
        centerTitle: true,
      ),
      body: _buildBody(theme),
    );
  }
  
  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading contract...'),
          ],
        ),
      );
    }
    
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('😕', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(
                'Oops!',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: _loadContract,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_contract == null) {
      return const Center(child: Text('No contract found'));
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          const Text(
            '🤝',
            style: TextStyle(fontSize: 64),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'You\'ve Been Invited',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Someone wants you to be their accountability partner',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // Contract Details Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contract title
                  Row(
                    children: [
                      Text(
                        _contract!.status.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _contract!.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const Divider(height: 32),
                  
                  // Commitment statement
                  if (_contract!.commitmentStatement != null) ...[
                    Text(
                      'Commitment',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '"${_contract!.commitmentStatement}"',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Duration
                  _buildDetailRow(
                    theme,
                    icon: Icons.calendar_today,
                    label: 'Duration',
                    value: '${_contract!.durationDays} days',
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Nudge frequency
                  _buildDetailRow(
                    theme,
                    icon: Icons.notifications_active,
                    label: 'Check-ins',
                    value: _contract!.nudgeFrequency.displayName,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Nudge style
                  _buildDetailRow(
                    theme,
                    icon: Icons.chat_bubble_outline,
                    label: 'Nudge Style',
                    value: _contract!.nudgeStyle.displayName,
                  ),
                  
                  // Builder message
                  if (_contract!.builderMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Message from Builder',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _contract!.builderMessage!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // What being a witness means
          Card(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'As a Witness, you will:',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildWitnessRole(
                    theme,
                    emoji: '📱',
                    text: 'Get notified when they complete their habit',
                  ),
                  const SizedBox(height: 8),
                  _buildWitnessRole(
                    theme,
                    emoji: '🖐️',
                    text: 'Send high-fives to celebrate their wins',
                  ),
                  const SizedBox(height: 8),
                  _buildWitnessRole(
                    theme,
                    emoji: '💬',
                    text: 'Optionally nudge them when they\'re drifting',
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Message input
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(
              labelText: 'Message (optional)',
              hintText: 'Send an encouraging message...',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          
          const SizedBox(height: 32),
          
          // Accept button
          FilledButton.icon(
            onPressed: _isAccepting ? null : _acceptContract,
            icon: _isAccepting 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.handshake),
            label: Text(_isAccepting ? 'Accepting...' : 'Accept & Become Witness'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Decline button
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Not Now'),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  Widget _buildWitnessRole(
    ThemeData theme, {
    required String emoji,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
