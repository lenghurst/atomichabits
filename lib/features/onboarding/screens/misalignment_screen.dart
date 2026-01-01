import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:go_router/go_router.dart';
import '../../../../config/router/app_routes.dart';
import '../../../../data/services/sound_service.dart';

class MisalignmentScreen extends StatefulWidget {
  const MisalignmentScreen({super.key});

  @override
  State<MisalignmentScreen> createState() => _MisalignmentScreenState();
}

class _MisalignmentScreenState extends State<MisalignmentScreen> {
  bool _isRed = true;
  Timer? _flashTimer;


  @override
  void initState() {
    super.initState();
    // Start flashing (Alarm effect)
    _flashTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _isRed = !_isRed;
        });
        // Phase 18: Sound Design - Haptic alarm
        if (_isRed) HapticFeedback.heavyImpact();
      }
    });

    // Play initial sound
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Use existing FeedbackPatterns for error
      FeedbackPatterns.error();
    });
  }

  @override
  void dispose() {
    _flashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      color: _isRed ? const Color(0xFF7F1D1D) : const Color(0xFF0F172A), // Dark Red vs Dark Slate
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_amber_rounded, 
                  size: 80, 
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(height: 24),
                const Text(
                  'USER COMMITMENT MISALIGNMENT DETECTED',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Your actions do not match your stated identity.\n\nWe cannot proceed.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                OutlinedButton(
                  onPressed: () {
                    // Phase 18: Sound Design - Click
                    HapticFeedback.lightImpact();
                    if (context.canPop()) {
                       context.pop();
                    } else {
                       // Fallback if there is no history (e.g. deep link)
                       // In this case, we might want to restart onboarding or go home
                       context.go(AppRoutes.bootstrap); 
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54, width: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    "RE-ALIGN (GO BACK)",
                    style: TextStyle(
                      fontSize: 14, 
                      fontWeight: FontWeight.bold, 
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
