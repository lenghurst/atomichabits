import 'package:flutter/material.dart';

class ManifestoCard extends StatelessWidget {
  final String oldIdentity;
  final String newIdentity;
  final String date;

  const ManifestoCard({
    super.key,
    required this.oldIdentity,
    required this.newIdentity,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 500,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.white, width: 4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "THE PACT",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              letterSpacing: 4,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier', // Monospace for "official" feel
            ),
          ),
          const SizedBox(height: 40),
          Text(
            "I AM NO LONGER",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            oldIdentity.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.lineThrough,
              decorationColor: Colors.red,
              decorationThickness: 3,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            "I AM",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            newIdentity.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          Container(
            height: 2,
            width: 100,
            color: Colors.red,
          ),
          const SizedBox(height: 8),
          Text(
            "SEALED ON $date",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
