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
    await Permission.microphone.request();

    // 3. Health & Activity (Biometric Layer)
    // Used to calculate resilience score
    await Permission.activityRecognition.request();
    await Permission.sensors.request();

    // 4. Calendar (Environmental Layer)
    // Used to find free slots for habits
    await Permission.calendarFullAccess.request();

    // 5. App Usage (Digital Truth Layer)
    // Used to detect dopamine loops (doomscrolling)
    // Note: Android requires special intent, basic permission might not suffice but we request what we can
    // permission_handler doesn't wrap AppUsage strictly, but we can try requestInstallPackages or ignore for MVP UI
    // For now, we mainly inform the user.
    
    // 6. Demographics (Age/Context) are handled via Google Sign-In scopes

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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.visibility_outlined,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              
              // Heading
              const Text(
                'I need to see\neverything.',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.1,
                  fontFamily: 'Roboto', // Ensure premium font feels
                  letterSpacing: -1.0,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Explanation
              const Text(
                'To verify your word, The Pact requires access to your digital environment.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Scrollable list if small screen, but likely fits
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildPermissionItem(
                        icon: Icons.notifications_active_outlined,
                        title: 'Notifications',
                        subtitle: 'To remind you of your promises.',
                      ),
                      const SizedBox(height: 16),
                      _buildPermissionItem(
                        icon: Icons.mic_none_outlined,
                        title: 'Microphone',
                        subtitle: 'To speak with your Coach.',
                      ),
                      const SizedBox(height: 16),
                      _buildPermissionItem(
                        icon: Icons.monitor_heart_outlined,
                        title: 'Health & Activity',
                        subtitle: 'biometric_resilience_score',
                      ),
                      const SizedBox(height: 16),
                      _buildPermissionItem(
                        icon: Icons.calendar_today_outlined,
                        title: 'Calendar',
                        subtitle: 'temporal_context_awareness',
                      ),
                      const SizedBox(height: 16),
                      _buildPermissionItem(
                        icon: Icons.history_outlined,
                        title: 'Digital Truth',
                        subtitle: 'app_usage_dopamine_loops',
                      ),
                      const SizedBox(height: 16),
                      _buildPermissionItem(
                        icon: Icons.cake_outlined,
                        title: 'Demographics',
                        subtitle: 'age_context_profiling',
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
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
                    : const Text(
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
                     // Strict Commitment: Declining permissions leads to Misalignment (Fail State)
                     context.go(AppRoutes.misalignment);
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
