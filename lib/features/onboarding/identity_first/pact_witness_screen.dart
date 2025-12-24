import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/app_state.dart';

/// Pact Witness Screen
/// 
/// Screen 2 of the Identity First onboarding flow.
/// Allows users to:
/// - View their commitment contract
/// - Add a supporter (reframed from "witness" per Brown B2)
/// - Start solo without a supporter
/// 
/// Design: Contract-style visual with decorative corners
class PactWitnessScreen extends StatefulWidget {
  const PactWitnessScreen({super.key});

  @override
  State<PactWitnessScreen> createState() => _PactWitnessScreenState();
}

class _PactWitnessScreenState extends State<PactWitnessScreen> {
  final _witnessController = TextEditingController();
  bool _showWitnessInput = false;
  bool _showManualEntry = false; // Phase 28.4: Fallback for privacy-conscious users
  String? _selectedContactName; // Phase 28.4: Store selected contact name
  bool _hideProgressFromWitness = false; // Phase 30 (Brown B3): Privacy controls

  @override
  void dispose() {
    _witnessController.dispose();
    super.dispose();
  }

  /// Phase 28.4 (Fogg): Open native contact picker
  Future<void> _handlePickContact() async {
    // Request permission
    final status = await Permission.contacts.request();
    
    if (status.isGranted) {
      try {
        // Open native contact picker
        final contact = await FlutterContacts.openExternalPick();
        
        if (contact != null) {
          // Get full contact with properties
          final fullContact = await FlutterContacts.getContact(
            contact.id,
            withProperties: true,
          );
          
          if (fullContact != null) {
            _handleContactSelected(fullContact);
          }
        }
      } catch (e) {
        // Fallback to manual entry on error
        setState(() {
          _showManualEntry = true;
          _showWitnessInput = true;
        });
      }
    } else if (status.isPermanentlyDenied) {
      // Show dialog to open settings
      _showPermissionDeniedDialog();
    } else {
      // Permission denied, show manual entry
      setState(() {
        _showManualEntry = true;
        _showWitnessInput = true;
      });
    }
  }
  
  /// Phase 28.4: Handle contact selection
  void _handleContactSelected(Contact contact) {
    final emails = contact.emails;
    final phones = contact.phones;
    
    // If multiple contact methods, show picker
    if (emails.length + phones.length > 1) {
      _showContactMethodPicker(contact);
    } else if (emails.isNotEmpty) {
      _setWitnessFromContact(contact.displayName, emails.first.address);
    } else if (phones.isNotEmpty) {
      _setWitnessFromContact(contact.displayName, phones.first.number);
    } else {
      // No email or phone, use name only
      _setWitnessFromContact(contact.displayName, contact.displayName);
    }
  }
  
  /// Phase 28.4: Show picker for multiple contact methods
  void _showContactMethodPicker(Contact contact) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How should we reach ${contact.displayName}?',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF8FAFC),
                ),
              ),
              const SizedBox(height: 16),
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
                  _setWitnessFromContact(contact.displayName, email.address);
                },
              )),
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
                  _setWitnessFromContact(contact.displayName, phone.number);
                },
              )),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Phase 28.4: Set witness from contact selection
  void _setWitnessFromContact(String name, String contactInfo) {
    setState(() {
      _witnessController.text = contactInfo;
      _selectedContactName = name;
      _showWitnessInput = true;
    });
  }
  
  /// Phase 28.4: Show permission denied dialog
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Contacts Access',
          style: TextStyle(color: Color(0xFFF8FAFC)),
        ),
        content: const Text(
          'To quickly add a witness, please enable contacts access in Settings.',
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _showManualEntry = true;
                _showWitnessInput = true;
              });
            },
            child: const Text('Enter Manually'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _handleAddWitness() {
    // Phase 28.4: Open contact picker instead of showing text field
    _handlePickContact();
  }

  void _handleContinueWithWitness() {
    if (_witnessController.text.isEmpty) return;

    // Save witness to app state
    final appState = context.read<AppState>();
    // TODO: Add witness field to UserProfile model
    
    // Navigate to tier selection
    context.go('/onboarding/tier');
  }

  void _handleStartSolo() {
    // Navigate to tier selection without witness
    context.go('/onboarding/tier');
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
      backgroundColor: const Color(0xFF0F172A), // slate-900
      body: Stack(
        children: [
          // Background gradient accents
          Positioned(
            top: 80,
            right: 0,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withOpacity(0.05),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF22C55E).withOpacity(0.05),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
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
                color: const Color(0xFFF59E0B).withOpacity(0.05),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withOpacity(0.05),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Brand mark and Share button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Brand mark
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ],
                      ),
                      
                      // Share Button (Manual Invite)
                      IconButton(
                        icon: const Icon(Icons.share, color: Color(0xFF94A3B8)),
                        tooltip: 'Share Invite Link',
                        onPressed: () {
                          Share.share(
                            'I’m starting a new habit pact. Will you be my witness? Download The Pact here: https://atomichabits.app',
                            subject: 'Be my witness on The Pact',
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Header Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          border: Border.all(color: const Color(0xFF334155)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.description_outlined,
                              size: 16,
                              color: Color(0xFF22C55E),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'STEP 2 OF 3',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF22C55E),
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Headline
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            letterSpacing: -0.02,
                            color: Color(0xFFF8FAFC),
                          ),
                          children: [
                            TextSpan(text: 'Your First '),
                            TextSpan(
                              text: 'Pact',
                              style: TextStyle(color: Color(0xFF22C55E)),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'Pacts are stronger with backup. Invite one person to hold you accountable, or start building solo.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF94A3B8),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Contract Card
                  Expanded(
                    child: SingleChildScrollView(
                      child: Stack(
                        children: [
                          // Decorative corner marks
                          Positioned(
                            top: -8,
                            left: -8,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: Color(0xFF22C55E),
                                    width: 2,
                                  ),
                                  top: BorderSide(
                                    color: Color(0xFF22C55E),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: -8,
                            right: -8,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                    color: Color(0xFF22C55E),
                                    width: 2,
                                  ),
                                  top: BorderSide(
                                    color: Color(0xFF22C55E),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Contract content
                          Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFF8FAFC),
                                  Color(0xFFE2E8F0),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.16),
                                  blurRadius: 32,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Contract Header
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'COMMITMENT CONTRACT',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0F172A),
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Executed on $currentDate',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF475569),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF22C55E),
                                            Color(0xFF4ADE80),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Color(0xFF0F172A),
                                        size: 24,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // Main Declaration
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF0F172A),
                                      height: 1.6,
                                    ),
                                    children: [
                                      const TextSpan(text: 'I, '),
                                      TextSpan(
                                        text: userName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                          decorationThickness: 2,
                                        ),
                                      ),
                                      const TextSpan(text: ', commit to becoming'),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                Container(
                                  padding: const EdgeInsets.only(left: 16),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      left: BorderSide(
                                        color: Color(0xFF22C55E),
                                        width: 4,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    identity,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                      letterSpacing: -0.01,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Witness Section
                                Container(
                                  padding: const EdgeInsets.only(top: 16),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: const Color(0xFF94A3B8).withOpacity(0.3),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Supported by:',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF334155),
                                            ),
                                          ),
                                          if (_witnessController.text.isNotEmpty)
                                            Row(
                                              children: const [
                                                Icon(
                                                  Icons.check_circle,
                                                  size: 16,
                                                  color: Color(0xFF16A34A),
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  'Sealed',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF16A34A),
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),

                                      const SizedBox(height: 12),

                                      // Phase 28.4 (Fogg): Witness input with contact picker
                                      if (_showWitnessInput)
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Show selected contact name if available
                                            if (_selectedContactName != null) ...[
                                              Text(
                                                _selectedContactName!,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF0F172A),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                            ],
                                            // Read-only field with contact info
                                            TextField(
                                              controller: _witnessController,
                                              readOnly: !_showManualEntry,
                                              autofocus: _showManualEntry,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF0F172A),
                                              ),
                                              decoration: InputDecoration(
                                                hintText: _showManualEntry 
                                                    ? 'Enter email or phone' 
                                                    : 'Tap to select contact',
                                                filled: true,
                                                fillColor: Colors.white,
                                                // Phase 28.4: Contact picker icon button
                                                suffixIcon: IconButton(
                                                  icon: const Icon(
                                                    Icons.contacts,
                                                    color: Color(0xFF22C55E),
                                                  ),
                                                  onPressed: _handlePickContact,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                  borderSide: const BorderSide(
                                                    color: Color(0xFF94A3B8),
                                                    width: 2,
                                                  ),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                  borderSide: const BorderSide(
                                                    color: Color(0xFF94A3B8),
                                                    width: 2,
                                                  ),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                  borderSide: const BorderSide(
                                                    color: Color(0xFF22C55E),
                                                    width: 2,
                                                  ),
                                                ),
                                                contentPadding: const EdgeInsets.all(12),
                                              ),
                                              onTap: _showManualEntry ? null : _handlePickContact,
                                            ),
                                            // Phase 28.4: Manual entry fallback link
                                            if (!_showManualEntry)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 8),
                                                child: GestureDetector(
                                                  onTap: () => setState(() => _showManualEntry = true),
                                                  child: const Text(
                                                    'Enter manually instead',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFF64748B),
                                                      decoration: TextDecoration.underline,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        )
                                      else
                                        Stack(
                                          children: [
                                            Container(
                                              height: 40,
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  bottom: BorderSide(
                                                    color: const Color(0xFF94A3B8).withOpacity(0.4),
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              right: 0,
                                              top: 0,
                                              // Phase 28.4: Primary button opens contact picker
                                              child: ElevatedButton.icon(
                                                onPressed: _handleAddWitness,
                                                icon: const Icon(Icons.contacts, size: 16),
                                                label: const Text(
                                                  'Add Supporter',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFF1E293B),
                                                  foregroundColor: const Color(0xFFF8FAFC),
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  elevation: 0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Signature line decoration
                                const Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'Your commitment, sealed.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: Color(0xFF64748B),
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

                  const SizedBox(height: 24),

                  // Action Buttons
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_showWitnessInput && _witnessController.text.isNotEmpty)
                        ElevatedButton(
                          onPressed: _handleContinueWithWitness,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF22C55E),
                            foregroundColor: const Color(0xFF0F172A),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.auto_awesome, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Seal the Pact',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        ElevatedButton(
                          onPressed: _handleAddWitness,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF22C55E),
                            foregroundColor: const Color(0xFF0F172A),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Choose a Supporter',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextButton(
                          onPressed: _handleStartSolo,
                          child: const Text(
                            'Start Solo (Add Supporter Later)',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Phase 30 (Brown B3): Privacy Controls
                      // Gives users control over what witnesses can see
                      _buildPrivacyControls(),

                      const SizedBox(height: 16),

                      const Text(
                        'Having a supporter increases your success rate by 65%. They\'re here to cheer you on, not judge you.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Phase 30 (Brown B3): Privacy Controls Widget
  /// Gives users control over what their witness can see
  Widget _buildPrivacyControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF334155),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shield_outlined,
                size: 18,
                color: Colors.white.withOpacity(0.7),
              ),
              const SizedBox(width: 8),
              const Text(
                'Privacy Controls',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF8FAFC),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Toggle for hiding daily progress
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Share only milestones',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFCBD5E1),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Your witness will only see weekly summaries, not daily check-ins.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Switch(
                value: _hideProgressFromWitness,
                onChanged: (value) {
                  setState(() => _hideProgressFromWitness = value);
                },
                activeColor: const Color(0xFF22C55E),
                activeTrackColor: const Color(0xFF22C55E).withOpacity(0.3),
                inactiveThumbColor: const Color(0xFF64748B),
                inactiveTrackColor: const Color(0xFF334155),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Reassurance message
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: const Color(0xFF3B82F6).withOpacity(0.8),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You can change these settings anytime. Your journey, your rules.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.6),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
