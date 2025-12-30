import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/router/app_routes.dart';
import '../../data/app_state.dart';
import '../../data/models/habit_contract.dart';
import '../../data/services/contract_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/sound_service.dart';
import '../../config/supabase_config.dart';

/// Create Contract Screen
/// 
/// Phase 16.2: Habit Contracts
/// 
/// Allows a Builder to create a new accountability contract for a habit.
/// After creation, generates an invite link to share with a Witness.
class CreateContractScreen extends StatefulWidget {
  final String? habitId;  // Pre-selected habit (optional)
  
  const CreateContractScreen({super.key, this.habitId});

  @override
  State<CreateContractScreen> createState() => _CreateContractScreenState();
}

class _CreateContractScreenState extends State<CreateContractScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form fields
  String? _selectedHabitId;
  final _titleController = TextEditingController();
  final _commitmentController = TextEditingController();
  final _messageController = TextEditingController();
  int _durationDays = 21;
  NudgeFrequency _nudgeFrequency = NudgeFrequency.daily;
  NudgeStyle _nudgeStyle = NudgeStyle.encouraging;
  
  // Phase 4: Identity Privacy
  String? _alternativeIdentity;
  
  bool _isCreating = false;
  HabitContract? _createdContract;
  
  @override
  void initState() {
    super.initState();
    _selectedHabitId = widget.habitId;
    
    // Pre-fill title if habit is selected
    if (_selectedHabitId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _prefillFromHabit();
      });
    }
  }
  
  void _prefillFromHabit() {
    final appState = context.read<AppState>();
    final habit = appState.habits.firstWhere(
      (h) => h.id == _selectedHabitId,
      orElse: () => throw StateError('Habit not found'),
    );
    
    setState(() {
      _titleController.text = '$_durationDays-Day ${habit.name} Challenge';
      _commitmentController.text = 
          'I commit to ${habit.tinyVersion} daily, becoming ${habit.identity}.';
        });
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _commitmentController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    
    // Check if user is authenticated
    if (!authService.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Create Contract')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.handshake_outlined, 
                    size: 64, 
                    color: Colors.deepPurple.shade400,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Sign In to Create Contracts',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'Contracts let you invite a friend to hold you accountable. '
                  'Sign in to create shareable invite links.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Primary action: Google Sign In (most common)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _handleQuickSignIn(context, authService),
                    icon: const Icon(Icons.login),
                    label: const Text('Sign In with Google'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Secondary: More options in Settings
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(AppRoutes.settings),
                    icon: const Icon(Icons.settings),
                    label: const Text('More Sign In Options'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber.shade700, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your habits stay local. Signing in only enables contracts & cloud backup.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // Show created contract with share options
    if (_createdContract != null) {
      return _buildSuccessScreen();
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Contract'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 24),
            
            // Habit Selection
            _buildHabitSelector(),
            const SizedBox(height: 16),
            
            // Contract Title
            _buildTitleField(),
            const SizedBox(height: 16),
            
            // Commitment Statement
            _buildCommitmentField(),
            const SizedBox(height: 16),
            
            // Duration
            _buildDurationSelector(),
            const SizedBox(height: 24),
            
            // Witness Preferences
            _buildWitnessPreferences(),
            const SizedBox(height: 16),
            
            // Personal Message
            _buildMessageField(),
            const SizedBox(height: 32),
            
            // Personal Message
            _buildMessageField(),
            const SizedBox(height: 24),

            // Phase 4: Identity Disclosure Warning
            _buildIdentityDisclosureWarning(),
            const SizedBox(height: 32),
            
            // Create Button
            _buildCreateButton(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Card(
      color: Colors.deepPurple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.handshake, color: Colors.deepPurple, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Habit Contract',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Invite someone to hold you accountable',
                    style: TextStyle(color: Colors.deepPurple.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHabitSelector() {
    final appState = context.watch<AppState>();
    final habits = appState.habits.where((h) => !h.isPaused).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Habit',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          key: ValueKey(_selectedHabitId),
          initialValue: _selectedHabitId,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Choose a habit to commit to',
            prefixIcon: Icon(Icons.check_circle_outline),
          ),
          items: habits.map((habit) {
            return DropdownMenuItem(
              value: habit.id,
              child: Row(
                children: [
                  Text(habit.habitEmoji ?? '🎯'),
                  const SizedBox(width: 8),
                  Expanded(child: Text(habit.name, overflow: TextOverflow.ellipsis)),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedHabitId = value;
            });
            if (value != null) {
              _prefillFromHabit();
            }
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a habit';
            }
            return null;
          },
        ),
      ],
    );
  }
  
  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contract Title',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'e.g., "21-Day Meditation Challenge"',
            prefixIcon: Icon(Icons.title),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a title';
            }
            return null;
          },
        ),
      ],
    );
  }
  
  Widget _buildCommitmentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Commitment Statement',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'What exactly are you committing to?',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _commitmentController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'e.g., "I commit to meditating for 5 minutes every morning"',
            prefixIcon: Icon(Icons.flag),
          ),
          maxLines: 2,
        ),
      ],
    );
  }
  
  Widget _buildDurationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Duration',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [7, 14, 21, 30, 66, 90].map((days) {
            final isSelected = _durationDays == days;
            final label = days == 21 
                ? '21 days (Habit Formation)' 
                : days == 66 
                    ? '66 days (Deep Habit)' 
                    : '$days days';
            
            return ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _durationDays = days;
                  // Update title if it contains duration
                  if (_titleController.text.contains('Day')) {
                    _prefillFromHabit();
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildWitnessPreferences() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.notifications_active, size: 20),
                SizedBox(width: 8),
                Text(
                  'Witness Preferences',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'How should your witness hold you accountable?',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            
            // Nudge Frequency
            const Text('Nudge Frequency', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: NudgeFrequency.values.map((freq) {
                return ChoiceChip(
                  label: Text(freq.displayName),
                  selected: _nudgeFrequency == freq,
                  onSelected: (selected) {
                    setState(() => _nudgeFrequency = freq);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            
            // Nudge Style
            const Text('Nudge Style', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            ...NudgeStyle.values.map((style) {
              return RadioListTile<NudgeStyle>(
                title: Text(style.displayName),
                subtitle: Text(style.description, style: const TextStyle(fontSize: 12)),
                value: style,
                groupValue: _nudgeStyle,
                onChanged: (value) {
                  setState(() => _nudgeStyle = value!);
                },
                dense: true,
                contentPadding: EdgeInsets.zero,
              );
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMessageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personal Message (Optional)',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Say something to your future witness',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _messageController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'e.g., "Hey! I really need your help staying accountable..."',
            prefixIcon: Icon(Icons.message),
          ),
          maxLines: 3,
        ),
      ],
    );
  }
  
  Widget _buildCreateButton() {
    return FilledButton.icon(
      onPressed: _isCreating ? null : _createContract,
      icon: _isCreating 
          ? const SizedBox(
              width: 20, 
              height: 20, 
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.add),
      label: Text(_isCreating ? 'Creating...' : 'Create Contract'),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
      ),
    );
  }
  
  Widget _buildIdentityDisclosureWarning() {
    final appState = context.watch<AppState>();
    final profile = appState.userProfile;
    
    // If no identity set, nothing to warn about
    if (profile == null || profile.identity.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final identityToShow = _alternativeIdentity ?? profile.identity;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade300, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.visibility, color: Colors.orange.shade700, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Identity Sharing',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Text(
            'When you complete this habit, your witnesses will receive:',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              '"${profile.name} just cast a vote for $identityToShow"',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade900,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'This powerfully reinforces your identity.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Option to use alternative identity
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showAlternativeIdentityDialog(profile.identity),
              icon: const Icon(Icons.edit_outlined),
              label: Text(_alternativeIdentity == null 
                  ? 'Use different identity for this pact'
                  : 'Revert to default identity'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange.shade700,
                side: BorderSide(color: Colors.orange.shade300),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAlternativeIdentityDialog(String defaultIdentity) async {
    final controller = TextEditingController(text: _alternativeIdentity);
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alternative Identity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose how you want to be identified in this specific contract.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'I am a person who...',
                hintText: 'e.g., values health',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (_alternativeIdentity != null)
            TextButton(
              onPressed: () => Navigator.pop(context, 'REVERT'),
              child: const Text('Revert to Default'),
            ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Set Identity'),
          ),
        ],
      ),
    );
    
    if (result != null) {
      setState(() {
        if (result == 'REVERT' || result.isEmpty) {
          _alternativeIdentity = null;
        } else {
          _alternativeIdentity = result;
        }
      });
    }
  }
  
  Future<void> _createContract() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedHabitId == null) return;
    
    setState(() => _isCreating = true);
    
    final contractService = context.read<ContractService>();
    
    final result = await contractService.createContract(
      habitId: _selectedHabitId!,
      title: _titleController.text.trim(),
      commitmentStatement: _commitmentController.text.trim().isNotEmpty 
          ? _commitmentController.text.trim() 
          : null,
      durationDays: _durationDays,
      builderMessage: _messageController.text.trim().isNotEmpty 
          ? _messageController.text.trim() 
          : null,
      nudgeFrequency: _nudgeFrequency,
      nudgeStyle: _nudgeStyle,
      alternativeIdentity: _alternativeIdentity, // Phase 4 Privacy
    );
    
    setState(() => _isCreating = false);
    
    if (result.success && result.contract != null) {
      // Phase 18: Contract signing feedback - "The Commitment" 🔊
      // Tick-tick-thud buildup to make contract feel official
      try {
        final soundService = context.read<SoundService>();
        final appState = context.read<AppState>();
        await FeedbackPatterns.contractSign(
          soundService,
          hapticsEnabled: appState.hapticsEnabled,
        );
        debugPrint('🔊 Contract signing feedback triggered');
      } catch (e) {
        debugPrint('🔊 SoundService not available: $e');
      }
      
      setState(() => _createdContract = result.contract);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Failed to create contract'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Widget _buildSuccessScreen() {
    final contract = _createdContract!;
    final inviteUrl = SupabaseConfig.getInviteUrl(contract.inviteCode);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contract Created!'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go(AppRoutes.dashboard),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Success Header
          const Center(
            child: Column(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 64),
                SizedBox(height: 16),
                Text(
                  'Contract Created!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Now share the invite link with your witness',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Contract Summary Card
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
                          contract.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (contract.commitmentStatement != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      '"${contract.commitmentStatement}"',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text('${contract.durationDays} days'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Invite Link Section
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.link, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Invite Link',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            inviteUrl,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: inviteUrl));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Link copied!')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Invite Code: ${contract.inviteCode}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Share Button
          FilledButton.icon(
            onPressed: () => _shareInvite(contract),
            icon: const Icon(Icons.share),
            label: const Text('Share Invite'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
          ),
          const SizedBox(height: 12),
          
          // Done Button
          OutlinedButton(
            onPressed: () => context.go(AppRoutes.dashboard),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Done'),
          ),
          const SizedBox(height: 24),
          
          // Info
          Card(
            color: Colors.amber.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'The contract will start once your witness accepts the invite.',
                      style: TextStyle(color: Colors.amber.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _shareInvite(HabitContract contract) async {
    final contractService = context.read<ContractService>();
    await contractService.shareInvite(contract);
  }
  
  /// Quick sign-in flow directly from the contract screen
  Future<void> _handleQuickSignIn(BuildContext context, AuthService authService) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Signing in...'),
              ],
            ),
          ),
        ),
      ),
    );
    
    try {
      final result = await authService.signInWithGoogle();
      
      // Dismiss loading dialog
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      if (result.success) {
        // Successfully signed in - the screen will rebuild automatically
        // via the authService.isAuthenticated check
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Signed in! You can now create contracts.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Show error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Sign in failed. Try again or use Settings for more options.'),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Settings',
                textColor: Colors.white,
                onPressed: () => context.push(AppRoutes.settings),
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Dismiss loading dialog
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
