import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/router/app_routes.dart';

class ValuePropScreen extends StatelessWidget {
  const ValuePropScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepPurple.shade900.withOpacity(0.4),
                    Colors.black,
                    Colors.blue.shade900.withOpacity(0.2),
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  
                  // Icon
                  Icon(
                    Icons.self_improvement,
                    size: 64,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(height: 32),
                  
                  // Main Heading
                  Text(
                    'Graceful Consistency\n>\nFragile Streaks',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Subheading
                  Text(
                    'Most habit apps punish you for being human.\nThe Pact helps you recover.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        // Navigate to Sign In (or next step)
                        // Assuming Sign In is handled or we go to permissions
                        // For now, let's assume we go to a SignIn screen or Permissions
                         context.push(AppRoutes.onboardingPermissions); 
                         // Note: We need to register this route
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        "I'm ready to commit",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
