import 'package:flutter/material.dart';

/// Weekly Review Dialog
///
/// Shown on Sundays to help users reflect on their week.
/// Based on Atomic Habits: "Reflection and review is a process that
/// allows you to remain conscious of your performance over time."
///
/// Features:
/// - Weekly stats summary
/// - Reflection prompts
/// - Optional notes
/// - Celebrates wins and normalizes setbacks
class WeeklyReviewDialog extends StatefulWidget {
  final int daysCompletedThisWeek;
  final int daysInWeek; // Usually 7, but could be less if habit is new
  final int totalDaysShowedUp;
  final int currentStreak;
  final int neverMissTwiceWins;
  final String habitName;
  final String identity;
  final VoidCallback onComplete;
  final VoidCallback onDismiss;

  const WeeklyReviewDialog({
    super.key,
    required this.daysCompletedThisWeek,
    required this.daysInWeek,
    required this.totalDaysShowedUp,
    required this.currentStreak,
    required this.neverMissTwiceWins,
    required this.habitName,
    required this.identity,
    required this.onComplete,
    required this.onDismiss,
  });

  @override
  State<WeeklyReviewDialog> createState() => _WeeklyReviewDialogState();
}

class _WeeklyReviewDialogState extends State<WeeklyReviewDialog> {
  int _currentStep = 0;
  String? _selectedWin;
  String? _selectedChallenge;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double get _weeklyPercent {
    if (widget.daysInWeek == 0) return 0;
    return widget.daysCompletedThisWeek / widget.daysInWeek * 100;
  }

  String get _weeklyMessage {
    final percent = _weeklyPercent;
    if (percent >= 100) {
      return "Perfect week! You showed up every single day.";
    } else if (percent >= 85) {
      return "Excellent consistency! Almost a perfect week.";
    } else if (percent >= 70) {
      return "Great week! You're building real momentum.";
    } else if (percent >= 50) {
      return "Good effort! Remember, showing up is what matters most.";
    } else if (percent > 0) {
      return "Every day you showed up counts. Let's build on that.";
    } else {
      return "This week was tough, but you're here now. That matters.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_view_week,
                  size: 40,
                  color: Colors.indigo.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Weekly Review',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Take a moment to reflect on your week',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Step indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index <= _currentStep
                        ? Colors.indigo
                        : Colors.grey.shade300,
                  ),
                )),
              ),
              const SizedBox(height: 24),

              // Content based on step
              if (_currentStep == 0) _buildStatsStep(),
              if (_currentStep == 1) _buildReflectionStep(),
              if (_currentStep == 2) _buildCommitmentStep(),

              const SizedBox(height: 24),

              // Navigation buttons
              Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _currentStep--;
                          });
                        },
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentStep < 2) {
                          setState(() {
                            _currentStep++;
                          });
                        } else {
                          widget.onComplete();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(_currentStep < 2 ? 'Continue' : 'Complete Review'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: widget.onDismiss,
                child: Text(
                  'Skip for now',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsStep() {
    return Column(
      children: [
        // Weekly completion card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade400, Colors.purple.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                '${widget.daysCompletedThisWeek}/${widget.daysInWeek}',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'days this week',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 12),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _weeklyPercent / 100,
                  minHeight: 8,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Message
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.emoji_emotions, color: Colors.green.shade600),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _weeklyMessage,
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Additional stats
        Row(
          children: [
            Expanded(
              child: _buildMiniStat(
                Icons.check_circle,
                Colors.teal,
                '${widget.totalDaysShowedUp}',
                'total days',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMiniStat(
                Icons.local_fire_department,
                Colors.orange,
                '${widget.currentStreak}',
                'streak',
              ),
            ),
            if (widget.neverMissTwiceWins > 0) ...[
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniStat(
                  Icons.replay,
                  Colors.blue,
                  '${widget.neverMissTwiceWins}',
                  'recoveries',
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildMiniStat(IconData icon, Color color, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionStep() {
    final wins = [
      'I showed up even when tired',
      'I used the 2-minute version',
      'I bounced back after missing a day',
      'I did my habit at the same time each day',
      'My environment cue helped me remember',
    ];

    final challenges = [
      'I felt too tired some days',
      'I forgot a few times',
      'My schedule was unpredictable',
      'I lost motivation mid-week',
      'Distractions got in the way',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Wins section
        Text(
          'What went well this week?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: wins.map((win) => ChoiceChip(
            label: Text(
              win,
              style: TextStyle(
                fontSize: 12,
                color: _selectedWin == win ? Colors.white : Colors.green.shade700,
              ),
            ),
            selected: _selectedWin == win,
            selectedColor: Colors.green,
            backgroundColor: Colors.green.shade50,
            onSelected: (selected) {
              setState(() {
                _selectedWin = selected ? win : null;
              });
            },
          )).toList(),
        ),
        const SizedBox(height: 24),

        // Challenges section
        Text(
          'What was challenging?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: challenges.map((challenge) => ChoiceChip(
            label: Text(
              challenge,
              style: TextStyle(
                fontSize: 12,
                color: _selectedChallenge == challenge ? Colors.white : Colors.orange.shade700,
              ),
            ),
            selected: _selectedChallenge == challenge,
            selectedColor: Colors.orange,
            backgroundColor: Colors.orange.shade50,
            onSelected: (selected) {
              setState(() {
                _selectedChallenge = selected ? challenge : null;
              });
            },
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildCommitmentStep() {
    return Column(
      children: [
        // Identity reminder
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple.shade200),
          ),
          child: Column(
            children: [
              Icon(Icons.star, color: Colors.purple.shade400, size: 32),
              const SizedBox(height: 8),
              Text(
                'Remember who you\'re becoming:',
                style: TextStyle(
                  color: Colors.purple.shade600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.identity,
                style: TextStyle(
                  color: Colors.purple.shade800,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Weekly intention
        Text(
          'Set your intention for next week:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),

        // Suggestions based on selected challenge
        if (_selectedChallenge != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getSuggestionForChallenge(_selectedChallenge!),
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Optional notes
        TextField(
          controller: _notesController,
          decoration: InputDecoration(
            hintText: 'Any notes for next week? (optional)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),

        // Motivational quote
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '"Every action you take is a vote for the type of person you wish to become."\n— James Clear',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  String _getSuggestionForChallenge(String challenge) {
    final suggestions = {
      'I felt too tired some days': 'Try doing just the 2-minute version when tired. Showing up matters more than perfection.',
      'I forgot a few times': 'Consider adding a stronger environment cue or linking to an existing habit.',
      'My schedule was unpredictable': 'Have a backup time slot ready. "If not at X, then at Y."',
      'I lost motivation mid-week': 'Remember: motivation follows action. Start tiny and momentum builds.',
      'Distractions got in the way': 'Review your environment design. What distraction can you remove?',
    };
    return suggestions[challenge] ?? 'Focus on showing up, even in a small way.';
  }
}
