import 'package:flutter/material.dart';
import '../data/daily_coach_service.dart';

/// Dialog for daily coaching reflection after habit completion
///
/// This dialog allows users to optionally reflect with their coach
/// after completing (or missing) their daily habit.
class DailyCoachDialog extends StatefulWidget {
  final DailyReflectionContext context;

  const DailyCoachDialog({
    super.key,
    required this.context,
  });

  @override
  State<DailyCoachDialog> createState() => _DailyCoachDialogState();
}

class _DailyCoachDialogState extends State<DailyCoachDialog> {
  final TextEditingController _noteController = TextEditingController();
  bool _isLoading = false;
  DailyCoachResult? _result;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  /// Get coach reflection feedback
  Future<void> _getCoachReflection() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create context with user's note
      final contextWithNote = DailyReflectionContext(
        identity: widget.context.identity,
        habitName: widget.context.habitName,
        tinyVersion: widget.context.tinyVersion,
        date: widget.context.date,
        status: widget.context.status,
        currentStreak: widget.context.currentStreak,
        totalCompletions: widget.context.totalCompletions,
        userNote: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      // Call coach service
      final service = DailyCoachService();
      final result = await service.getDailyReflection(contextWithNote);

      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to get coach feedback. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

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
                  Icon(
                    Icons.auto_awesome,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Reflect with Coach',
                      style: TextStyle(
                        fontSize: 20,
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

              // Show input form or coach response
              if (_result == null) ...[
                // Input form
                const Text(
                  'How did it go today? (optional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    hintText: 'e.g., "Felt easy today" or "Had to push through"',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  maxLines: 3,
                  maxLength: 200,
                ),
                const SizedBox(height: 16),

                // Get reflection button
                if (_isLoading)
                  const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text(
                          'Getting your coach\'s thoughts...',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _getCoachReflection,
                      icon: const Icon(Icons.psychology_outlined, size: 20),
                      label: const Text('Get Reflection'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
              ] else ...[
                // Coach response
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.deepPurple.shade100,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _result!.message,
                        style: const TextStyle(
                          height: 1.6,
                          fontSize: 15,
                        ),
                      ),
                      if (_result!.insights.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Key insights:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._result!.insights.map((insight) => Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ', style: TextStyle(fontSize: 16)),
                                  Expanded(
                                    child: Text(
                                      insight,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Close button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Got it'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
