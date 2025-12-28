import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/router/app_routes.dart';

class TierSelectionScreen extends StatelessWidget {
  const TierSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose your\nCommitment Protocol',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 32),
              
              // Tier 1 Card (Standard) - LOCKED / ALPHA
              Opacity(
                opacity: 0.5,
                child: Stack(
                  children: [
                    _buildTierCard(
                      context,
                      title: 'Observer Mode',
                      subtitle: 'Passive Tracking',
                      price: 'Free',
                      features: ['Manual Tracking', 'Basic Analytics'],
                      color: Colors.blueGrey.shade900,
                      onTap: () {
                         // Disabled
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text("Currently in Alpha testing with First Adopter Group")),
                         );
                      },
                    ),
                    // Alpha Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(
                          child: Transform.rotate(
                            angle: -0.2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white24),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "ALPHA LOCKED",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Tier 2 Card (Commitment) - PRIMARY & ONLY OPTION
              _buildTierCard(
                context,
                title: 'Commitment Protocol',
                subtitle: 'High-Stakes Behavioral Architecture',
                price: '\$9.99/mo',
                features: ['Sherlock Intelligence', 'Oracle Vision', 'Detailed Behavioral Audit'],
                color: const Color(0xFF312E81), // Indigo 900
                isRecommended: true,
                onTap: () {
                   // Tier 2 Logic -> Sherlock Screening
                   context.push(AppRoutes.onboardingSherlock);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTierCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String price,
    required List<String> features,
    required Color color,
    required VoidCallback onTap,
    bool isRecommended = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          border: isRecommended ? Border.all(color: Colors.deepPurpleAccent, width: 2) : null,
          boxShadow: isRecommended ? [
            BoxShadow(
              color: Colors.deepPurpleAccent.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            )
          ] : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             if (isRecommended) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'RECOMMENDED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: Colors.greenAccent),
                  const SizedBox(width: 8),
                  Text(
                    f,
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
