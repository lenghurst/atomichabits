import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/habit_contract.dart';
import '../../data/services/contract_service.dart';
import '../../data/services/auth_service.dart';

/// Join Contract Screen
/// 
/// Phase 16.2 + 16.4: Habit Contracts & Deep Links
/// 
/// Displayed when User B opens an invite link.
/// Flow:
/// 1. Parse invite code from deep link
/// 2. Lookup contract details
/// 3. Show contract preview
/// 4. User accepts → becomes witness
/// 5. Navigate to witness view
class JoinContractScreen extends StatefulWidget {
  final String inviteCode;
  
  const JoinContractScreen({super.key, required this.inviteCode});

  @override
  State<JoinContractScreen> createState() => _JoinContractScreenState();
}

class _JoinContractScreenState extends State<JoinContractScreen> {
  final _messageController = TextEditingController();
  
  bool _isLoading = true;
  bool _isJoining = false;
  HabitContract? _contract;
  String? _error;
  bool _joined = false;
  
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

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    
    // Loading state
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Join Contract')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading contract...'),
            ],
          ),
        ),
      );
    }
    
    // Error state
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Join Contract')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Contract Not Found',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () => context.go('/dashboard'),
                  child: const Text('Go to Dashboard'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // Success - joined
    if (_joined && _contract != null) {
      return _buildJoinedScreen();
    }
    
    // Check auth
    if (!authService.isAuthenticated) {
      return _buildAuthRequiredScreen();
    }
    
    // Check if trying to join own contract
    if (_contract!.builderId == authService.userId) {
      return _buildOwnContractScreen();
    }
    
    // Show contract preview
    return _buildPreviewScreen();
  }
  
  Widget _buildAuthRequiredScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Contract')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle_outlined, size: 64, color: Colors.deepPurple),
            const SizedBox(height: 16),
            Text(
              'Sign In to Join',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a free account to become a witness and help your friend stay accountable.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Contract preview card
            if (_contract != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.handshake, color: Colors.deepPurple),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _contract!.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('${_contract!.durationDays} day commitment'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            FilledButton(
              onPressed: () {
                // Sign in anonymously first, then they can upgrade later
                context.read<AuthService>().signInAnonymously().then((_) {
                  setState(() {}); // Rebuild with authenticated state
                });
              },
              child: const Text('Continue as Guest'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/settings'),
              child: const Text('Sign in with Email'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOwnContractScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Contract')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              Text(
                'This is Your Contract',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'You created this contract! Share the link with someone else to have them become your witness.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPreviewScreen() {
    final contract = _contract!;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Contract'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Card(
            color: Colors.deepPurple.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.handshake, size: 48, color: Colors.deepPurple),
                  const SizedBox(height: 16),
                  Text(
                    'You\'re invited to witness',
                    style: TextStyle(
                      color: Colors.deepPurple.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    contract.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Contract Details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contract Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  
                  // Commitment
                  if (contract.commitmentStatement != null) ...[
                    const Text('Commitment:', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(
                      '"${contract.commitmentStatement}"',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // Duration
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text('${contract.durationDays} days'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Nudge preferences
                  Row(
                    children: [
                      const Icon(Icons.notifications, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text('Check-ins: ${contract.nudgeFrequency.displayName}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      const Icon(Icons.style, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text('Style: ${contract.nudgeStyle.displayName}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Personal message from builder
          if (contract.builderMessage != null) ...[
            const SizedBox(height: 16),
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.message, size: 20, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Message from Builder',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(contract.builderMessage!),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          
          // Your role section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.visibility, size: 20, color: Colors.deepPurple),
                      SizedBox(width: 8),
                      Text(
                        'Your Role as Witness',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildRoleItem(Icons.remove_red_eye, 'See their daily progress'),
                  _buildRoleItem(Icons.notifications_active, 'Send encouraging nudges'),
                  _buildRoleItem(Icons.emoji_events, 'Celebrate their wins'),
                  _buildRoleItem(Icons.favorite, 'Hold them accountable with care'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Your message (optional)
          TextFormField(
            controller: _messageController,
            decoration: const InputDecoration(
              labelText: 'Your Message (Optional)',
              hintText: 'Say something encouraging...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.edit),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          
          // Join Button
          FilledButton.icon(
            onPressed: _isJoining ? null : _joinContract,
            icon: _isJoining 
                ? const SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.check),
            label: Text(_isJoining ? 'Joining...' : 'Accept & Become Witness'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              backgroundColor: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 12),
          
          // Decline
          TextButton(
            onPressed: () => context.go('/dashboard'),
            child: const Text('Not right now'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  
  Widget _buildRoleItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }
  
  Widget _buildJoinedScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome, Witness!'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.celebration, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 24),
            Text(
              'You\'re Now a Witness!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'The contract "${_contract!.title}" has started.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ll see their progress and can send encouraging nudges.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            
            // Contract summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Duration'),
                        Text('${_contract!.durationDays} days'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Started'),
                        Text(_formatDate(_contract!.startDate ?? DateTime.now())),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Ends'),
                        Text(_formatDate(_contract!.endDate ?? DateTime.now())),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            
            FilledButton(
              onPressed: () => context.go('/contracts'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              child: const Text('View My Contracts'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
  
  Future<void> _joinContract() async {
    if (_contract == null) return;
    
    setState(() => _isJoining = true);
    
    final contractService = context.read<ContractService>();
    
    final result = await contractService.acceptInvite(
      _contract!,
      witnessMessage: _messageController.text.trim().isNotEmpty 
          ? _messageController.text.trim() 
          : null,
    );
    
    setState(() => _isJoining = false);
    
    if (result.success && result.contract != null) {
      setState(() {
        _contract = result.contract;
        _joined = true;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Failed to join contract'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
