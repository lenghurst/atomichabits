import 'package:flutter/material.dart';

/// ImprovementSuggestionsDialog - Shows AI-powered habit improvement suggestions
/// 
/// Purely presentational widget - receives all suggestions via props.
class ImprovementSuggestionsDialog extends StatelessWidget {
  final Map<String, List<String>> suggestions;
  final VoidCallback onClose;
  
  const ImprovementSuggestionsDialog({
    super.key,
    required this.suggestions,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.tips_and_updates, color: Colors.deepPurple),
          SizedBox(width: 12),
          Text('Strengthen Your Habit'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Here are some ideas to make your habit stronger:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            _SuggestionSection(
              title: '💗 Temptation Bundling',
              suggestions: suggestions['temptationBundle'] ?? [],
            ),
            _SuggestionSection(
              title: '🧘 Pre-Habit Ritual',
              suggestions: suggestions['preHabitRitual'] ?? [],
            ),
            _SuggestionSection(
              title: '💡 Environment Cue',
              suggestions: suggestions['environmentCue'] ?? [],
            ),
            _SuggestionSection(
              title: '🚫 Remove Distractions',
              suggestions: suggestions['environmentDistraction'] ?? [],
            ),
            const SizedBox(height: 16),
            Text(
              'Tip: You can adjust your habit setup in Settings.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onClose,
          child: const Text('Close'),
        ),
      ],
    );
  }
}

/// Individual suggestion section
class _SuggestionSection extends StatelessWidget {
  final String title;
  final List<String> suggestions;
  
  const _SuggestionSection({
    required this.title,
    required this.suggestions,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 8),
        ...suggestions.take(2).map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text('• $s', style: const TextStyle(fontSize: 14)),
        )),
        const SizedBox(height: 12),
      ],
    );
  }
}
