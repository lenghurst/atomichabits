import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/services/contract_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/sound_service.dart';
import '../../data/models/habit_contract.dart';

/// Witness Accept Screen
/// 
/// Phase 22: "The Witness" - Social Accountability Loop
/// Phase 24: "The Socially Binding Pact" - Enhanced UI
/// 
/// Shown when a user clicks a contract invite deep link:
/// 1. Displays the contract details (habit, builder, duration)
/// 2. Shows as an official "Socially Binding Pact" document
/// 3. Requires tap-and-hold to "sign" the pact
/// 4. Wax seal animation + haptic feedback on acceptance
/// 5. Creates the witness relationship in Supabase
/// 
/// Route: /witness/accept/:inviteCode
/// 
/// Phase 24 Strategic Ruling:
/// - Use "Socially Binding Pact" (NOT "Legally Binding") to avoid liability
/// - Heavy visual weight: wax seal, signature gesture, official document layout
/// - Heavy haptic feedback: builds commitment psychology
class WitnessAcceptScreen extends StatefulWidget {
  final String inviteCode;
  
  const WitnessAcceptScreen({
    super.key,
    required this.inviteCode,
  });

  @override
  State<WitnessAcceptScreen> createState() => _WitnessAcceptScreenState();
}

class _WitnessAcceptScreenState extends State<WitnessAcceptScreen> 
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _isAccepting = false;
  bool _isSigning = false;
  HabitContract? _contract;
  String? _error;
  final TextEditingController _messageController = TextEditingController();
  
  // Phase 24: Sign animation controller
  late AnimationController _sealController;
  late Animation<double> _sealScale;
  late Animation<double> _sealOpacity;
  
  // Phase 24: Sign progress (0.0 to 1.0)
  double _signProgress = 0.0;
  static const _signDuration = Duration(milliseconds: 1500);
  
  // Track if seal animation has completed
  bool _sealCompleted = false;
  
  @override
  void initState() {
    super.initState();
    
    // Phase 24: Initialize seal animation
    _sealController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _sealScale = Tween<double>(begin: 2.0, end: 1.0).animate(
      CurvedAnimation(parent: _sealController, curve: Curves.elasticOut),
    );
    
    _sealOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sealController, curve: Curves.easeIn),
    );
    
    _loadContract();
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _sealController.dispose();
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
  
  /// Phase 24: Handle sign button press
  void _onSignStart() {
    if (_isAccepting || _sealCompleted) return;
    
    setState(() => _isSigning = true);
    
    // Start progress animation
    _animateSignProgress();
    
    // Haptic feedback for start
    HapticFeedback.selectionClick();
  }
  
  /// Phase 24: Handle sign button release
  void _onSignEnd() {
    if (!_isSigning) return;
    
    // If not complete, reset
    if (_signProgress < 1.0) {
      setState(() {
        _isSigning = false;
        _signProgress = 0.0;
      });
    }
  }
  
  /// Phase 24: Animate the sign progress
  Future<void> _animateSignProgress() async {
    const tickDuration = Duration(milliseconds: 50);
    final tickCount = _signDuration.inMilliseconds ~/ tickDuration.inMilliseconds;
    
    for (int i = 0; i < tickCount && _isSigning; i++) {
      await Future.delayed(tickDuration);
      
      if (!_isSigning) break;
      
      setState(() {
        _signProgress = (i + 1) / tickCount;
      });
      
      // Tick haptics at 33%, 66%, and 100%
      if (_signProgress >= 0.33 && _signProgress < 0.34) {
        HapticFeedback.selectionClick();
      } else if (_signProgress >= 0.66 && _signProgress < 0.67) {
        HapticFeedback.selectionClick();
      }
    }
    
    // Complete!
    if (_isSigning && _signProgress >= 1.0) {
      _completeSigning();
    }
  }
  
  /// Phase 24: Complete the signing ceremony
  Future<void> _completeSigning() async {
    // Heavy impact for the "stamp"
    HapticFeedback.heavyImpact();
    
    // Play seal sound
    try {
      final soundService = context.read<SoundService>();
      await soundService.playSign();
    } catch (_) {
      // Sound service may not be available
    }
    
    setState(() {
      _isSigning = false;
      _sealCompleted = true;
    });
    
    // Animate seal dropping
    _sealController.forward();
    
    // Wait for animation, then accept
    await Future.delayed(const Duration(milliseconds: 800));
    
    _acceptContract();
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
        _sealCompleted = false;
        _signProgress = 0.0;
      });
      _sealController.reset();
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
        _sealCompleted = false;
        _signProgress = 0.0;
      });
      _sealController.reset();
    }
  }
  
  void _showAuthRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign In Required'),
        content: const Text(
          'To seal this pact, you need to create an account. '
          'This lets us notify you when your partner completes their habit.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _sealCompleted = false;
                _signProgress = 0.0;
              });
              _sealController.reset();
            },
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
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF22C55E), Color(0xFF06B6D4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(
            Icons.handshake,
            size: 32,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Pact Sealed!',
          style: TextStyle(
            color: Color(0xFFF8FAFC),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You\'re now the accountability witness for "${_contract!.title}".',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF22C55E).withOpacity(0.3),
                ),
              ),
              child: const Column(
                children: [
                  Text(
                    'Your Role:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF8FAFC),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Get notified on their completions\n'
                    '• Send high-fives to celebrate wins\n'
                    '• Nudge them if they\'re drifting',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Phase 28.4 (Eyal): Reciprocity Loop
            // "Now it's your turn" - creates obligation to reciprocate
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF3B82F6).withOpacity(0.2),
                    const Color(0xFFEC4899).withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF3B82F6).withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.swap_horiz,
                        color: Color(0xFF3B82F6),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Now it\'s your turn',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF8FAFC),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'What habit will you ask ${_contract!.builderName ?? 'them'} to witness for you?',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/witness');
            },
            child: const Text(
              'Maybe Later',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          // Phase 28.4: Primary CTA is now the reciprocity action
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to onboarding to create their own pact
              Navigator.of(context).pushReplacementNamed('/');
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Create My Pact'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF22C55E),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3), // Old paper color
      appBar: AppBar(
        title: const Text('Socially Binding Pact'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
            Text('Loading pact...'),
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
              const Text('📜', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(
                'Pact Not Found',
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
      return const Center(child: Text('No pact found'));
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Phase 24: The "Official Document" Card
          _buildPactDocument(theme),
          
          const SizedBox(height: 24),
          
          // Phase 24: Sign Area
          _buildSignArea(theme),
          
          const SizedBox(height: 16),
          
          // Decline button
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Not Now',
              style: TextStyle(color: Colors.brown.shade400),
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  /// Phase 24: Build the official pact document
  Widget _buildPactDocument(ThemeData theme) {
    return Stack(
      children: [
        // Document background
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFEF5), // Aged paper
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.brown.shade300, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(4, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Text(
                '📜 SOCIALLY BINDING PACT 📜',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade800,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'An Agreement of Accountability',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.brown.shade600,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Divider
              Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.brown.shade400,
                      Colors.brown.shade400,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Builder info
              Text(
                'THE BUILDER',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade600,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _contract!.builderDisplayName ?? 'Anonymous',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade800,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Commitment
              Text(
                'hereby commits to',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.brown.shade600,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Habit box
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.brown.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    Text(
                      _contract!.habitEmoji ?? '🎯',
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _contract!.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_contract!.commitmentStatement != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '"${_contract!.commitmentStatement}"',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.brown.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Duration
              Text(
                'for a period of',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.brown.shade600,
                ),
              ),
              Text(
                '${_contract!.durationDays} DAYS',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade800,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Divider
              Container(
                height: 1,
                color: Colors.brown.shade300,
              ),
              
              const SizedBox(height: 24),
              
              // Witness role
              Text(
                'THE WITNESS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade600,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '(That\'s You)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade700,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Text(
                'agrees to bear witness and provide\naccountability through:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.brown.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Witness duties
              _buildDutyItem('📱', 'Receiving completion notifications'),
              const SizedBox(height: 8),
              _buildDutyItem('🖐️', 'Sending high-fives of encouragement'),
              const SizedBox(height: 8),
              _buildDutyItem('💬', 'Providing nudges when needed'),
              
              const SizedBox(height: 24),
              
              // Optional message
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.brown.shade50,
                  border: Border.all(color: Colors.brown.shade200),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Add a message (optional)',
                    hintStyle: TextStyle(
                      color: Colors.brown.shade400,
                      fontStyle: FontStyle.italic,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: TextStyle(color: Colors.brown.shade700),
                  maxLines: 2,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Disclaimer
              Text(
                'This is a socially binding agreement.\n'
                'Not a legal contract. Built on trust and mutual respect.',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.brown.shade400,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        // Phase 24: Wax seal (appears after signing)
        if (_sealCompleted)
          Positioned(
            bottom: 20,
            right: 20,
            child: AnimatedBuilder(
              animation: _sealController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _sealScale.value,
                  child: Opacity(
                    opacity: _sealOpacity.value,
                    child: _buildWaxSeal(),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
  
  Widget _buildDutyItem(String emoji, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.brown.shade700,
          ),
        ),
      ],
    );
  }
  
  /// Phase 24: Build the wax seal widget
  Widget _buildWaxSeal() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.red.shade700,
            Colors.red.shade900,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('✓', style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            )),
            Text(
              'SEALED',
              style: TextStyle(
                color: Colors.red.shade100,
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Phase 24: Build the sign area with progress indicator
  Widget _buildSignArea(ThemeData theme) {
    final bool canSign = !_isAccepting && !_sealCompleted;
    
    return Column(
      children: [
        // Instructions
        Text(
          _sealCompleted 
              ? 'Pact Sealed!' 
              : _isSigning 
                  ? 'Hold to seal...'
                  : 'Press and hold to seal this pact',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _sealCompleted 
                ? Colors.green.shade700 
                : Colors.brown.shade600,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Sign button with progress
        GestureDetector(
          onTapDown: canSign ? (_) => _onSignStart() : null,
          onTapUp: canSign ? (_) => _onSignEnd() : null,
          onTapCancel: canSign ? _onSignEnd : null,
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _sealCompleted 
                    ? Colors.green.shade400 
                    : Colors.brown.shade400,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                children: [
                  // Progress fill
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 50),
                    width: MediaQuery.of(context).size.width * _signProgress,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _sealCompleted
                            ? [Colors.green.shade400, Colors.green.shade600]
                            : [Colors.red.shade400, Colors.red.shade600],
                      ),
                    ),
                  ),
                  
                  // Label
                  Center(
                    child: _isAccepting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _sealCompleted 
                                    ? Icons.check_circle 
                                    : Icons.touch_app,
                                color: _signProgress > 0.5 || _sealCompleted
                                    ? Colors.white
                                    : Colors.brown.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _sealCompleted 
                                    ? 'Sealed!' 
                                    : _isSigning 
                                        ? '${(_signProgress * 100).toInt()}%'
                                        : 'HOLD TO SEAL',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                  color: _signProgress > 0.5 || _sealCompleted
                                      ? Colors.white
                                      : Colors.brown.shade700,
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
        
        const SizedBox(height: 8),
        
        // Helper text
        Text(
          _sealCompleted 
              ? 'Welcome to the pact!' 
              : 'This commitment is built on trust',
          style: TextStyle(
            fontSize: 11,
            color: Colors.brown.shade500,
          ),
        ),
      ],
    );
  }
}
