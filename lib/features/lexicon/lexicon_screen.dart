import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/lexicon_entry.dart';
import '../../data/services/lexicon_service.dart';
import '../../data/services/ai/lexicon_enricher.dart';
import 'widgets/lexicon_word_card.dart';
import 'widgets/add_word_dialog.dart';

/// The Lexicon Screen - "The Grimoire"
/// 
/// **Phase 25.9 Update:**
/// - Replaced ListView with PageView for a "book" feel.
/// - Added paper texture background (simulated with color/container).
/// - Used Serif font for titles.
class LexiconScreen extends StatefulWidget {
  const LexiconScreen({super.key});

  @override
  State<LexiconScreen> createState() => _LexiconScreenState();
}

class _LexiconScreenState extends State<LexiconScreen> {
  late Future<List<LexiconEntry>> _lexiconFuture;
  final PageController _pageController = PageController(viewportFraction: 0.9);

  @override
  void initState() {
    super.initState();
    _refreshLexicon();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _refreshLexicon() {
    setState(() {
      _lexiconFuture = context.read<LexiconService>().getLexicon();
    });
  }

  Future<void> _addNewWord(String word) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator()),
      );

      final lexiconService = context.read<LexiconService>();
      final newEntry = await lexiconService.addWord(word, identityTag: "Builder"); 

      final enricher = context.read<LexiconEnricher>();
      final enrichment = await enricher.enrichWord(word, "Builder");

      await lexiconService.updateEnrichment(
        newEntry.id,
        definition: enrichment['definition']!,
        etymology: enrichment['etymology']!,
      );

      if (mounted) {
        Navigator.pop(context); 
        _refreshLexicon(); 
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding word: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E6), // "Old Paper" color
      appBar: AppBar(
        title: const Text(
          'The Grimoire',
          style: TextStyle(
            fontFamily: 'Playfair Display', // Serif font
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
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
                  const Icon(Icons.menu_book, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Your Grimoire is empty.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontFamily: 'Playfair Display',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Add a Power Word to begin.'),
                ],
              ),
            );
          }

          return PageView.builder(
            controller: _pageController,
            itemCount: entries.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
                child: LexiconWordCard(entry: entries[index]),
              );
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
        label: const Text('Inscribe Word'),
        icon: const Icon(Icons.edit),
        backgroundColor: Colors.black87,
        foregroundColor: const Color(0xFFF5F1E6),
      ),
    );
  }
}
