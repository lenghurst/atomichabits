import 'package:flutter/material.dart';
import '../../../data/models/lexicon_entry.dart';

class LexiconWordCard extends StatelessWidget {
  final LexiconEntry entry;

  const LexiconWordCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.word,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (entry.masteryLevel > 0)
                  Chip(
                    label: Text('Lvl ${entry.masteryLevel}'),
                    backgroundColor: theme.colorScheme.primaryContainer,
                    labelStyle: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            if (entry.definition != null) ...[
              const SizedBox(height: 8),
              Text(
                entry.definition!,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            if (entry.etymology != null) ...[
              const SizedBox(height: 8),
              Text(
                entry.etymology!,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
