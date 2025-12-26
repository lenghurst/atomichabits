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
              
              // Tier 1 Card
              _buildTierCard(
                context,
                title: 'Standard Protocol',
                subtitle: 'Daily text Check-ins',
                price: 'Free',
                features: ['Text-based AI Coach', 'Basic Analytics', 'Manual Tracking'],
                color: Colors.blueGrey.shade800,
                onTap: () {
                  // Tier 1 Logic
                   context.push(AppRoutes.manualOnboarding);
                },
              ),
              const SizedBox(height: 16),
              
              // Tier 2 Card (Voice)
              _buildTierCard(
                context,
                title: 'High-Stakes Protocol',
                subtitle: 'Voice Coaching & Sherlock',
                price: '\$9.99/mo',
                features: ['Real-time Voice Calls', 'Sherlock Behavioral Analysis', 'Deep Insights'],
                color: Colors.deepPurple.shade900,
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
