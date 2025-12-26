import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../config/router/app_routes.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _isLoading = false;

  Future<void> _requestPermissions() async {
    setState(() => _isLoading = true);

    // Request permissions
    // 1. Notifications (Critical for reminders)
    await Permission.notification.request();
    
    // 2. Microphone (Critical for Voice Coach)
    // We request this early to reduce friction later
    await Permission.microphone.request();

    // 3. Contacts (Optional, for Witness) 
    // Maybe defer this to when they actually add a witness?
    // prompt says "Auth Permissions Accept", implying a bulk request or specific auth scopes.
    // For now, let's stick to system permissions.

    if (mounted) {
      setState(() => _isLoading = false);
      // Navigate to Loading/Parsing
      context.push(AppRoutes.onboardingLoading);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              
              // Eye Icon
              Icon(
                Icons.visibility,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              
              // Heading
              Text(
                'I need to see\neverything.',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Explanation
              Text(
                'To verify your word, The Pact requires access to your digital environment.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 24),
              
              _buildPermissionItem(
                icon: Icons.notifications_active,
                title: 'Notifications',
                subtitle: 'To remind you of your promises.',
              ),
              const SizedBox(height: 16),
               _buildPermissionItem(
                icon: Icons.mic,
                title: 'Microphone',
                subtitle: 'To speak with your Coach.',
              ),
              
              const Spacer(),
              
              // Button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _requestPermissions,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading 
                    ? const SizedBox(
                        height: 24, 
                        width: 24, 
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Grant Access',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                ),
              ),
              const SizedBox(height: 16),
              
              Center(
                child: TextButton(
                  onPressed: () {
                     // Skip for now, maybe? Or mandate it?
                     // Verify "I need to see everything" usually implies mandatory.
                     // But for UX, maybe allow skip.
                     context.push(AppRoutes.onboardingLoading);
                  },
                  child: Text(
                    'Not now',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
