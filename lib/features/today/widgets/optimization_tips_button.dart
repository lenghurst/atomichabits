import 'package:flutter/material.dart';

/// OptimizationTipsButton - Button to get AI-powered habit suggestions
/// 
/// Purely presentational widget.
class OptimizationTipsButton extends StatelessWidget {
  final VoidCallback onPressed;
  
  const OptimizationTipsButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.tips_and_updates),
        label: const Text('Get optimization tips'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }
}
