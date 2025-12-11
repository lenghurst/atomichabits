import 'package:flutter/material.dart';

/// RitualButton - Button to start pre-habit ritual
/// 
/// Purely presentational - shows only when ritual text is provided.
class RitualButton extends StatelessWidget {
  final VoidCallback onPressed;
  
  const RitualButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.self_improvement),
        label: const Text(
          'Start ritual',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.purple.shade300, width: 2),
          foregroundColor: Colors.purple.shade700,
        ),
      ),
    );
  }
}
