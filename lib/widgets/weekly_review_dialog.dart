import 'package:flutter/material.dart';
import '../data/review_service.dart';

/// Dialog for displaying weekly habit review
///
/// Shows AI-generated (or local fallback) weekly summary with:
/// - Overall progress summary
/// - Key highlights (what's working)
/// - Opportunities for improvement
class WeeklyReviewDialog extends StatelessWidget {
  final WeeklyReviewResult review;

  const WeeklyReviewDialog({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.analytics_outlined,
                      color: Colors.blue.shade700,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Weekly Review',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Summary section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.shade100,
                  ),
                ),
                child: Text(
                  review.summary,
                  style: const TextStyle(
                    height: 1.6,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Highlights section
              if (review.highlights.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Icons.star_outline,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Key highlights',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...review.highlights.map((highlight) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.orange.shade700,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              highlight,
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),
              ],

              // Opportunities section
              if (review.opportunities.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.green.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Opportunities',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...review.opportunities.map((opportunity) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.green.shade700,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              opportunity,
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),
              ],

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Got it'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
