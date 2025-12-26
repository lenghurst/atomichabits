import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/router/app_routes.dart';

class LoadingInsightsScreen extends StatefulWidget {
  const LoadingInsightsScreen({super.key});

  @override
  State<LoadingInsightsScreen> createState() => _LoadingInsightsScreenState();
}

class _LoadingInsightsScreenState extends State<LoadingInsightsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _statusText = 'Parsing behavioral data...';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Sequence of loading messages
    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _statusText = 'Identifying resistance patterns...');
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _statusText = 'Generating insights...');
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      context.replace(AppRoutes.onboardingTierSelection);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Custom Spinner
            RotationTransition(
              turns: _controller,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.deepPurpleAccent.withOpacity(0.5),
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  gradient: SweepGradient(
                    colors: [
                      Colors.transparent,
                      Colors.deepPurpleAccent,
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              _statusText,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
