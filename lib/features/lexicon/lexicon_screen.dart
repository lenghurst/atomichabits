import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/lexicon_entry.dart';
import '../../data/services/lexicon_service.dart';
import '../../data/services/ai/lexicon_enricher.dart';
import 'widgets/lexicon_word_card.dart';
import 'widgets/add_word_dialog.dart';

class LexiconScreen extends StatefulWidget {
  const LexiconScreen({super.key});

  @override
  State<LexiconScreen> createState() => _LexiconScreenState();
}

class _LexiconScreenState extends State<LexiconScreen> {
  late Future<List<LexiconEntry>> _lexiconFuture;

  @override
  void initState() {
    super.initState();
    _refreshLexicon();
  }

  void _refreshLexicon() {
    setState(() {
      _lexiconFuture = context.read<LexiconService>().getLexicon();
    });
  }

  Future<void> _addNewWord(String word) async {
    try {
      // 1. Optimistic UI update (optional, but let's just show loading)
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator()),
      );

      // 2. Add word to DB
      final lexiconService = context.read<LexiconService>();
      final newEntry = await lexiconService.addWord(word, identityTag: "Builder"); // TODO: Get actual tag

      // 3. Enrich in background (or await if we want immediate gratification)
      final enricher = context.read<LexiconEnricher>();
      final enrichment = await enricher.enrichWord(word, "Builder"); // TODO: Get actual tag

      await lexiconService.updateEnrichment(
        newEntry.id,
        definition: enrichment['definition']!,
        etymology: enrichment['etymology']!,
      );

      if (mounted) {
        Navigator.pop(context); // Close loader
        _refreshLexicon(); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loader
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding word: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Lexicon'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<LexiconEntry>>(
        future: _lexiconFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final entries = snapshot.data ?? [];

          if (entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Your Grimoire is empty.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text('Add a Power Word to begin.'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              return LexiconWordCard(entry: entries[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final word = await showDialog<String>(
            context: context,
            builder: (context) => const AddWordDialog(),
          );
          if (word != null && word.isNotEmpty) {
            _addNewWord(word);
          }
        },
        label: const Text('Add Word'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
