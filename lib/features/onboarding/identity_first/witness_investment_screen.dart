import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../config/router/app_routes.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/app_state.dart';
import '../../../data/services/voice_session_manager.dart';
import '../../../data/services/onboarding/onboarding_orchestrator.dart';
import '../components/permission_glass_pane.dart';
import '../voice_coach_screen.dart';
import '../../../data/models/voice_session_config.dart';

/// Witness Investment Screen
/// 
/// Phase 33: The Investment (Technical Specification)
/// 
/// This screen implements the high-stakes "Investment" phase of the Hook Model:
/// - "Who will witness your failure?" - A visceral, emotionally charged question
/// - TypeAhead contact search for frictionless witness selection
/// - Pre-Permission Glass Pane for contextual permission requests
/// - Continuous voice integration (Gemini 3 British Coach)
/// - Privacy controls for emotional safety
/// 
/// The UI remains clean while the logic creates a binding social contract.
class WitnessInvestmentScreen extends StatefulWidget {
  /// Optional voice session manager for continuous audio during transition.
  final VoiceSessionManager? voiceSessionManager;
  
  const WitnessInvestmentScreen({
    super.key,
    this.voiceSessionManager,
  });

  @override
  State<WitnessInvestmentScreen> createState() => _WitnessInvestmentScreenState();
}

class _WitnessInvestmentScreenState extends State<WitnessInvestmentScreen>
    with SingleTickerProviderStateMixin {
  // Controllers
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  
  // State
  bool _hasContactsPermission = false;
  bool _isLoadingContacts = false;
  List<Contact> _allContacts = [];
  Contact? _selectedContact;
  String? _selectedContactMethod;
  bool _hideProgressFromWitness = false;
  bool _showManualEntry = false;
  
  // Animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _checkContactsPermission();
    
    // Trigger voice prompt after a short delay
    Future.delayed(const Duration(milliseconds: 500), _triggerVoicePrompt);
  }
  
  void _initializeAnimation() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  /// Check if we already have contacts permission.
  Future<void> _checkContactsPermission() async {
    final status = await Permission.contacts.status;
    setState(() {
      _hasContactsPermission = status.isGranted;
    });
    
    if (_hasContactsPermission) {
      _loadContacts();
    }
  }
  
  /// Load all contacts for TypeAhead suggestions.
  Future<void> _loadContacts() async {
    if (_isLoadingContacts) return;
    
    setState(() => _isLoadingContacts = true);
    
    try {
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );
      
      setState(() {
        _allContacts = contacts;
        _isLoadingContacts = false;
      });
    } catch (e) {
      setState(() => _isLoadingContacts = false);
      debugPrint('WitnessInvestmentScreen: Failed to load contacts: $e');
    }
  }
  
  /// Trigger the voice prompt: "A Pact requires a witness..."
  void _triggerVoicePrompt() {
    widget.voiceSessionManager?.sendText(
      'A Pact requires a witness. Who do you fear disappointing the most?',
    );
  }
  
  /// Request contacts permission with the Glass Pane.
  Future<void> _requestContactsPermission() async {
    await PermissionGlassPane.show(
      context: context,
      permission: Permission.contacts,
      title: 'Find Your Witness',
      description: 'Search your contacts to find someone who will hold you accountable. '
          'They\'ll receive updates on your progress.',
      benefit: 'People with a witness are 3x more likely to achieve their goals.',
      icon: Icons.contacts,
      onGranted: () {
        setState(() => _hasContactsPermission = true);
        _loadContacts();
      },
      onDenied: () {
        setState(() => _showManualEntry = true);
      },
      onSkip: () {
        setState(() => _showManualEntry = true);
      },
    );
  }
  
  /// Search contacts by name, email, or phone.
  List<Contact> _searchContacts(String query) {
    if (query.isEmpty) return [];
    
    final lowerQuery = query.toLowerCase();
    return _allContacts.where((contact) {
      // Search by name
      if (contact.displayName.toLowerCase().contains(lowerQuery)) {
        return true;
      }
      // Search by email
      for (final email in contact.emails) {
        if (email.address.toLowerCase().contains(lowerQuery)) {
          return true;
        }
      }
      // Search by phone
      for (final phone in contact.phones) {
        if (phone.number.contains(query)) {
          return true;
        }
      }
      return false;
    }).take(10).toList();
  }
  
  /// Handle contact selection from TypeAhead.
  void _handleContactSelected(Contact contact) {
    HapticFeedback.mediumImpact();
    
    final emails = contact.emails;
    final phones = contact.phones;
    
    // If multiple contact methods, show picker
    if (emails.length + phones.length > 1) {
      _showContactMethodPicker(contact);
    } else if (emails.isNotEmpty) {
      _setWitness(contact, emails.first.address);
    } else if (phones.isNotEmpty) {
      _setWitness(contact, phones.first.number);
    } else {
      // No email or phone, use name only
      _setWitness(contact, contact.displayName);
    }
  }
  
  /// Show picker for multiple contact methods.
  void _showContactMethodPicker(Contact contact) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ContactMethodPicker(
        contact: contact,
        onSelected: (method) => _setWitness(contact, method),
      ),
    );
  }
  
  /// Set the selected witness.
  void _setWitness(Contact contact, String contactMethod) {
    setState(() {
      _selectedContact = contact;
      _selectedContactMethod = contactMethod;
      _searchController.text = contact.displayName;
    });
  }
  
  /// Continue with the selected witness.
  void _handleContinueWithWitness() {
    if (_selectedContact == null && _searchController.text.isEmpty) return;
    
    HapticFeedback.heavyImpact();
    
    // Save witness to app state
    final appState = context.read<AppState>();
    final witnessName = _selectedContact?.displayName ?? _searchController.text;
    final witnessContact = _selectedContactMethod ?? '';
    
    if (appState.userProfile != null) {
      final updatedProfile = appState.userProfile!.copyWith(
        witnessName: witnessName,
        witnessContact: witnessContact,
      );
      appState.setUserProfile(updatedProfile);
    }

    // --- NEW: INVITE THE WITNESS (Brain Surgery 2.5) ---
    if (witnessContact.isNotEmpty) {
      _inviteWitness(witnessName, witnessContact);
    } else {
      // Navigate to Goal Screening (Step 8)
      context.go(AppRoutes.screening);
    }
  }

  Future<void> _inviteWitness(String name, String contact) async {
    final appState = context.read<AppState>();
    final myName = appState.userProfile?.name ?? "I";
    final habitName = context.read<OnboardingOrchestrator>().extractedData?.name ?? "a new habit";
    
    // Polished Copy (Brain Surgery 2.5)
    final message = "Hey $name, $myName here. I just bet money that I'll build a habit of $habitName. "
        "I named you as my witness. If I slack off, I lose the cash. Keep me honest? https://atomichabits.app/witness";
    
    try {
      // Use system share sheet (works for WhatsApp, SMS, Signal, etc.)
      await Share.share(message, subject: "Witness my Pact");
    } catch (e) {
      debugPrint("Error sharing invite: $e");
    }
    
    // Navigate regardless of success (don't block user)
    if (mounted) context.go(AppRoutes.screening);
  }
  
  /// Continue without a witness.
  void _handleStartSolo() {
    HapticFeedback.lightImpact();
    
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Go Solo?'),
        content: const Text(
          'Research shows that people with a witness are 3x more likely to achieve their goals. '
          'Are you sure you want to continue alone?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Add a Witness'),
          ),
          TextButton(
             onPressed: () {
               Navigator.pop(context);
               // Navigate to Tough Truths AI Coach
               Navigator.of(context).push(
                 MaterialPageRoute(
                   builder: (context) => VoiceCoachScreen(
                     config: VoiceSessionConfig.toughTruths,
                   ),
                 ),
               );
             },
             child: const Text('Use AI Coach', style: TextStyle(color: Color(0xFF64748B))),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRoutes.screening);
            },
            child: const Text('Continue Solo'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final userName = appState.userProfile?.name.isNotEmpty == true
        ? appState.userProfile!.name
        : 'You';
    final identity = appState.userProfile?.identity.isNotEmpty == true
        ? appState.userProfile!.identity
        : 'A Better Version of Yourself';
    final currentDate = DateFormat('MMMM d, y').format(DateTime.now());
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Background gradient accents
          _buildBackgroundAccents(),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),
                
                // Contract card (scrollable)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // The Pact Contract
                        _buildContractCard(userName, identity, currentDate),
                        
                        const SizedBox(height: 32),
                        
                        // The Investment Section
                        _buildInvestmentSection(),
                      ],
                    ),
                  ),
                ),
                
                // Bottom actions
                _buildBottomActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBackgroundAccents() {
    return Stack(
      children: [
        Positioned(
          top: 80,
          right: 0,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) => Opacity(
              opacity: _pulseAnimation.value * 0.1,
              child: Container(
                width: 256,
                height: 256,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444), // Red for stakes
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                      blurRadius: 100,
                      spreadRadius: 50,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
            width: 384,
            height: 384,
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: Color(0xFFF8FAFC)),
          ),
          const Spacer(),
          // Progress indicator
          _buildProgressIndicator(),
          const Spacer(),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }
  
  Widget _buildProgressIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildProgressDot(isActive: true, isComplete: true),
        _buildProgressLine(isComplete: true),
        _buildProgressDot(isActive: true, isComplete: false),
        _buildProgressLine(isComplete: false),
        _buildProgressDot(isActive: false, isComplete: false),
      ],
    );
  }
  
  Widget _buildProgressDot({required bool isActive, required bool isComplete}) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isComplete
            ? const Color(0xFF22C55E)
            : isActive
                ? const Color(0xFFEF4444)
                : const Color(0xFF334155),
        border: isActive && !isComplete
            ? Border.all(color: const Color(0xFFEF4444), width: 2)
            : null,
      ),
    );
  }
  
  Widget _buildProgressLine({required bool isComplete}) {
    return Container(
      width: 32,
      height: 2,
      color: isComplete ? const Color(0xFF22C55E) : const Color(0xFF334155),
    );
  }
  
  Widget _buildContractCard(String userName, String identity, String currentDate) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Center(
            child: Text(
              'THE PACT',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 4,
                color: Color(0xFF22C55E),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Contract text
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Color(0xFFF8FAFC),
              ),
              children: [
                const TextSpan(text: 'I, '),
                TextSpan(
                  text: userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF22C55E),
                  ),
                ),
                const TextSpan(text: ', hereby declare my commitment to become '),
                TextSpan(
                  text: identity,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFFF59E0B),
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Date
          Text(
            'Signed on $currentDate',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInvestmentSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _selectedContact != null
              ? const Color(0xFF22C55E)
              : const Color(0xFFEF4444).withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The visceral question
          const Text(
            'Who will witness your failure?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFEF4444),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose someone whose disappointment you fear. '
            'They\'ll hold you accountable.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 24),
          
          // Contact search or permission request
          if (!_hasContactsPermission && !_showManualEntry)
            _buildPermissionRequest()
          else
            _buildContactSearch(),
          
          // Privacy controls
          if (_selectedContact != null) ...[
            const SizedBox(height: 24),
            _buildPrivacyControls(),
          ],
        ],
      ),
    );
  }
  
  Widget _buildPermissionRequest() {
    return Column(
      children: [
        FilledButton.icon(
          onPressed: _requestContactsPermission,
          icon: const Icon(Icons.contacts),
          label: const Text('Search Contacts'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            minimumSize: const Size(double.infinity, 56),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() => _showManualEntry = true),
          child: const Text('Enter manually instead'),
        ),
      ],
    );
  }
  
  Widget _buildContactSearch() {
    return Column(
      children: [
        // TypeAhead search field
        TypeAheadField<Contact>(
          controller: _searchController,
          focusNode: _searchFocusNode,
          suggestionsCallback: (pattern) async {
            if (!_hasContactsPermission) return [];
            return _searchContacts(pattern);
          },
          itemBuilder: (context, contact) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF334155),
                backgroundImage: contact.photo != null
                    ? MemoryImage(contact.photo!)
                    : null,
                child: contact.photo == null
                    ? Text(
                        contact.displayName.isNotEmpty
                            ? contact.displayName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(color: Color(0xFFF8FAFC)),
                      )
                    : null,
              ),
              title: Text(
                contact.displayName,
                style: const TextStyle(color: Color(0xFFF8FAFC)),
              ),
              subtitle: Text(
                contact.emails.isNotEmpty
                    ? contact.emails.first.address
                    : contact.phones.isNotEmpty
                        ? contact.phones.first.number
                        : '',
                style: const TextStyle(color: Color(0xFF94A3B8)),
              ),
            );
          },
          onSelected: _handleContactSelected,
          builder: (context, controller, focusNode) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              style: const TextStyle(color: Color(0xFFF8FAFC)),
              decoration: InputDecoration(
                hintText: _hasContactsPermission
                    ? 'Search by name, email, or phone...'
                    : 'Enter name or email...',
                hintStyle: const TextStyle(color: Color(0xFF64748B)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                suffixIcon: _selectedContact != null
                    ? const Icon(Icons.check_circle, color: Color(0xFF22C55E))
                    : null,
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFEF4444)),
                ),
              ),
            );
          },
          decorationBuilder: (context, child) {
            return Material(
              type: MaterialType.card,
              elevation: 4,
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              child: child,
            );
          },
          emptyBuilder: (context) => const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'No contacts found',
              style: TextStyle(color: Color(0xFF94A3B8)),
            ),
          ),
        ),
        
        // Selected contact display
        if (_selectedContact != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF22C55E),
                  backgroundImage: _selectedContact!.photo != null
                      ? MemoryImage(_selectedContact!.photo!)
                      : null,
                  child: _selectedContact!.photo == null
                      ? Text(
                          _selectedContact!.displayName.isNotEmpty
                              ? _selectedContact!.displayName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(color: Colors.white),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedContact!.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF8FAFC),
                        ),
                      ),
                      if (_selectedContactMethod != null)
                        Text(
                          _selectedContactMethod!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedContact = null;
                      _selectedContactMethod = null;
                      _searchController.clear();
                    });
                  },
                  icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildPrivacyControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Privacy Controls',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFF8FAFC),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: _hideProgressFromWitness,
            onChanged: (value) {
              setState(() => _hideProgressFromWitness = value);
              HapticFeedback.selectionClick();
            },
            title: const Text(
              'Share only milestones',
              style: TextStyle(color: Color(0xFFF8FAFC)),
            ),
            subtitle: const Text(
              'Your witness will only see weekly progress, not daily check-ins',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
            contentPadding: EdgeInsets.zero,
            activeTrackColor: const Color(0xFF22C55E),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBottomActions() {
    final hasWitness = _selectedContact != null || _searchController.text.isNotEmpty;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        border: Border(
          top: BorderSide(color: Color(0xFF334155)),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Primary action
            FilledButton(
              onPressed: hasWitness ? _handleContinueWithWitness : null,
              style: FilledButton.styleFrom(
                backgroundColor: hasWitness
                    ? const Color(0xFF22C55E)
                    : const Color(0xFF334155),
                minimumSize: const Size(double.infinity, 56),
              ),
              child: Text(
                hasWitness ? 'Seal the Pact' : 'Choose a Witness',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Secondary action
            TextButton(
              onPressed: _handleStartSolo,
              child: const Text(
                'I\'ll go alone',
                style: TextStyle(color: Color(0xFF94A3B8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Contact method picker for contacts with multiple emails/phones.
class _ContactMethodPicker extends StatelessWidget {
  final Contact contact;
  final void Function(String method) onSelected;
  
  const _ContactMethodPicker({
    required this.contact,
    required this.onSelected,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF64748B),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                'How should we reach ${contact.displayName}?',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF8FAFC),
                ),
              ),
              const SizedBox(height: 16),
              
              // Email options
              ...contact.emails.map((email) => ListTile(
                leading: const Icon(Icons.email, color: Color(0xFF22C55E)),
                title: Text(
                  email.address,
                  style: const TextStyle(color: Color(0xFFF8FAFC)),
                ),
                subtitle: Text(
                  email.label.name,
                  style: const TextStyle(color: Color(0xFF94A3B8)),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onSelected(email.address);
                },
              )),
              
              // Phone options
              ...contact.phones.map((phone) => ListTile(
                leading: const Icon(Icons.phone, color: Color(0xFF22C55E)),
                title: Text(
                  phone.number,
                  style: const TextStyle(color: Color(0xFFF8FAFC)),
                ),
                subtitle: Text(
                  phone.label.name,
                  style: const TextStyle(color: Color(0xFF94A3B8)),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onSelected(phone.number);
                },
              )),
            ],
          ),
        ),
      ),
    );
  }
}
