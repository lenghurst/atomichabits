import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../config/router/app_routes.dart';
import '../../../data/providers/psychometric_provider.dart';
import '../../../data/services/auth_service.dart';

/// SherlockPermissionScreen: The "Data Handshake".
/// 
/// This screen implements the Progressive Disclosure pattern for Sherlock Sensors.
/// It explains *why* we need access to sensitive data (Calendar, YouTube, etc.)
/// before requesting the permissions.
/// 
/// If the user refuses, we employ "The Refusal Protocol" to profile them based
/// on what they are hiding.
class SherlockPermissionScreen extends StatefulWidget {
  const SherlockPermissionScreen({super.key});

  @override
  State<SherlockPermissionScreen> createState() => _SherlockPermissionScreenState();
}

class _SherlockPermissionScreenState extends State<SherlockPermissionScreen> {
  bool _isAnalyzing = false;

  void _handleUnlockAnalysis() async {
    setState(() {
      _isAnalyzing = true;
    });

    final authService = context.read<AuthService>();
    
    // Request the scopes
    final grantedScopes = await authService.requestSherlockScopes();
    
    if (grantedScopes.isNotEmpty) {
      // Success! They opened the kimono.
      if (mounted) {
        _navigateToNextStep();
      }
    } else {
      // They cancelled or failed. Treat as partial refusal.
      // We don't block them, but we log it.
      // Ideally we'd know *what* they refused, but Google Sign In often fails all-or-nothing
      // or returns null on cancel.
      // For now, we assume "Guard Consumer" behavior.
      
      // Note: We don't actively penalize "cancel" as much as explicit "I have secrets"
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  void _handleRefusal() async {
    // "I Have Secrets" path
    final psychOptions = context.read<PsychometricProvider>();
    
    // Profile the refusal
    // We assume they are hiding everything
    await psychOptions.logPermissionRefusal('calendar'); // The Overwhelmed
    await psychOptions.logPermissionRefusal('youtube');  // The Consumer
    
    // Proceed anyway
    if (mounted) {
      _navigateToNextStep();
    }
  }
  
  void _navigateToNextStep() {
    // Proceed to Witness Investment (or next step in manual flow)
    context.go(AppRoutes.witnessOnboarding);
  }

  @override
  Widget build(BuildContext context) {
    // Using a dark, mysterious aesthetic fitting "Sherlock"
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // 1. Iconography
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 1),
                  color: Colors.white.withOpacity(0.05),
                ),
                child: const Icon(
                  Icons.fingerprint,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 2. The Hook
              const Text(
                'TO KNOW YOU,\nI MUST SEE YOU.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  height: 1.2,
                ),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                'I can analyze your digital footprint to find hidden patterns of failure.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // 3. The Value Props (Sensors)
              _buildSensorRow(
                icon: Icons.calendar_today,
                title: 'CALENDAR',
                benefit: 'I find your time leaks.',
              ),
              const SizedBox(height: 24),
              _buildSensorRow(
                icon: Icons.play_circle_outline,
                title: 'YOUTUBE',
                benefit: 'I identify distraction triggers.',
              ),
              const SizedBox(height: 24),
              _buildSensorRow(
                icon: Icons.check_circle_outline,
                title: 'TASKS',
                benefit: 'I reveal your open loops.',
              ),
              
              const Spacer(),
              
              // 4. The Choice
              if (_isAnalyzing)
                const CircularProgressIndicator(color: Colors.white)
              else
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _handleUnlockAnalysis,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(0)), // Sharp edges
                          ),
                        ),
                        child: const Text(
                          'UNLOCK ANALYSIS',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _handleRefusal,
                      child: const Text(
                        'I HAVE SECRETS',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSensorRow({
    required IconData icon,
    required String title,
    required String benefit,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 24),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              benefit,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
