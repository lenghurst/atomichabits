import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../config/ai_model_config.dart';
import '../auth_service.dart';

/// Embedding Service
///
/// Phase 67: RAG Vector Memory Layer
///
/// Generates embeddings for behavioral signals and conversations,
/// enabling AI personas (Sherlock, Oracle, Stoic) to recall relevant
/// past events when coaching the user.
///
/// Architecture:
/// - Model: text-embedding-004 (768 dimensions)
/// - Storage: pgvector in Supabase
/// - Fallback: Graceful degradation to keyword search
class EmbeddingService {
  static final EmbeddingService instance = EmbeddingService._();

  EmbeddingService._();

  GenerativeModel? _model;
  AuthService? _authService;
  bool _isInitialized = false;

  /// Model name for text embeddings
  /// text-embedding-004 produces 768-dimensional vectors
  static const String _embeddingModel = 'text-embedding-004';

  /// Embedding dimension (must match migration)
  static const int embeddingDimension = 768;

  /// Configure the service with dependencies
  void configure({required AuthService authService}) {
    _authService = authService;
  }

  /// Initialize the embedding model
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (!AIModelConfig.hasGeminiKey) {
      if (kDebugMode) {
        debugPrint('EmbeddingService: No Gemini API key, embeddings disabled');
      }
      return;
    }

    try {
      _model = GenerativeModel(
        model: _embeddingModel,
        apiKey: AIModelConfig.geminiApiKey,
      );
      _isInitialized = true;

      if (kDebugMode) {
        debugPrint('EmbeddingService: Initialized with $_embeddingModel');
      }
    } catch (e) {
      debugPrint('EmbeddingService: Initialization failed: $e');
    }
  }

  /// Check if service is ready
  bool get isAvailable => _isInitialized && _model != null;

  /// Get current user ID
  String? get _userId => _authService?.currentUser?.id;

  // ===========================================================================
  // Core Embedding Generation
  // ===========================================================================

  /// Generate embedding vector for text
  ///
  /// Returns null if service unavailable or embedding fails
  Future<List<double>?> embed(String text) async {
    if (!isAvailable || text.isEmpty) return null;

    try {
      final response = await _model!.embedContent(Content.text(text));
      final embedding = response.embedding;

      if (embedding == null || embedding.values.isEmpty) {
        if (kDebugMode) {
          debugPrint('EmbeddingService: Empty embedding returned');
        }
        return null;
      }

      return embedding.values;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('EmbeddingService: Embed failed: $e');
      }
      return null;
    }
  }

  /// Generate embedding and format for Supabase pgvector
  ///
  /// Supabase expects embedding as a string: "[0.1, 0.2, ...]"
  Future<String?> embedForSupabase(String text) async {
    final embedding = await embed(text);
    if (embedding == null) return null;

    // Format as pgvector string
    return '[${embedding.join(',')}]';
  }

  // ===========================================================================
  // Evidence Log Embedding
  // ===========================================================================

  /// Embed and store for an evidence log entry
  ///
  /// Called after an evidence log is created (either immediately or via queue)
  Future<bool> embedEvidenceLog({
    required String logId,
    required String eventType,
    required Map<String, dynamic> payload,
  }) async {
    if (!isAvailable) return false;

    // Build searchable text from event type and payload
    final searchableText = _buildSearchableText(eventType, payload);

    final embeddingStr = await embedForSupabase(searchableText);
    if (embeddingStr == null) return false;

    try {
      await Supabase.instance.client
          .from('evidence_logs')
          .update({
            'embedding': embeddingStr,
            'searchable_text': searchableText,
          })
          .eq('id', logId);

      if (kDebugMode) {
        debugPrint('EmbeddingService: Embedded evidence log $logId');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('EmbeddingService: Failed to store evidence embedding: $e');
      }
      return false;
    }
  }

  /// Build searchable text from event type and payload
  String _buildSearchableText(String eventType, Map<String, dynamic> payload) {
    final parts = <String>[eventType];

    // Extract relevant fields based on event type
    if (payload.containsKey('habit_id')) {
      parts.add('habit: ${payload['habit_id']}');
    }
    if (payload.containsKey('emotion')) {
      parts.add('feeling: ${payload['emotion']}');
    }
    if (payload.containsKey('app_name')) {
      parts.add('app: ${payload['app_name']}');
    }
    if (payload.containsKey('completed_at')) {
      parts.add('completed at: ${payload['completed_at']}');
    }
    if (payload.containsKey('arm_id')) {
      parts.add('intervention: ${payload['arm_id']}');
    }
    if (payload.containsKey('engaged')) {
      parts.add(payload['engaged'] == true ? 'user engaged' : 'user ignored');
    }
    if (payload.containsKey('habit_completed')) {
      parts.add(payload['habit_completed'] == true ? 'habit done' : 'habit skipped');
    }

    return parts.join(' | ');
  }

  // ===========================================================================
  // Conversation Turn Embedding
  // ===========================================================================

  /// Embed and store for a conversation turn
  Future<bool> embedConversationTurn({
    required String turnId,
    required String userTranscript,
    required String aiResponse,
  }) async {
    if (!isAvailable) return false;

    // Combine user and AI text for semantic search
    final combinedText = 'User: $userTranscript | AI: $aiResponse';

    final embeddingStr = await embedForSupabase(combinedText);
    if (embeddingStr == null) return false;

    try {
      await Supabase.instance.client
          .from('conversation_turns')
          .update({'embedding': embeddingStr})
          .eq('id', turnId);

      if (kDebugMode) {
        debugPrint('EmbeddingService: Embedded conversation turn $turnId');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('EmbeddingService: Failed to store turn embedding: $e');
      }
      return false;
    }
  }

  // ===========================================================================
  // RAG: Semantic Memory Search
  // ===========================================================================

  /// Search memory using semantic similarity
  ///
  /// Returns relevant evidence and conversation snippets for AI context
  Future<List<MemoryResult>> searchMemory({
    required String query,
    double threshold = 0.65,
    int limit = 10,
  }) async {
    if (!isAvailable || _userId == null) return [];

    final queryEmbedding = await embedForSupabase(query);
    if (queryEmbedding == null) return [];

    try {
      // Call the unified search_memory RPC function
      final response = await Supabase.instance.client
          .rpc('search_memory', params: {
            'p_user_id': _userId,
            'p_query_embedding': queryEmbedding,
            'p_match_threshold': threshold,
            'p_match_count': limit,
          });

      if (response == null) return [];

      return (response as List)
          .map((row) => MemoryResult.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('EmbeddingService: Memory search failed: $e');
      }
      return [];
    }
  }

  /// Format memory results as AI context
  ///
  /// Returns a prompt-ready string for AI personas
  String formatMemoryAsContext(List<MemoryResult> memories) {
    if (memories.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.writeln('## Relevant Memory (from past interactions):');

    for (final memory in memories) {
      final date = _formatRelativeDate(memory.occurredAt);
      buffer.writeln('- [$date] ${memory.content}');
    }

    return buffer.toString();
  }

  /// Format date as relative (e.g., "2 days ago", "last week")
  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'today';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 14) return 'last week';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    return '${(diff.inDays / 30).floor()} months ago';
  }

  // ===========================================================================
  // Batch Operations (for backfill)
  // ===========================================================================

  /// Backfill embeddings for existing evidence logs
  ///
  /// Call this once after enabling vector search for existing data
  Future<int> backfillEvidenceEmbeddings({int batchSize = 50}) async {
    if (!isAvailable || _userId == null) return 0;

    int processed = 0;

    try {
      // Fetch evidence logs without embeddings
      final response = await Supabase.instance.client
          .from('evidence_logs')
          .select('id, event_type, payload')
          .eq('user_id', _userId!)
          .isFilter('embedding', null)
          .limit(batchSize);

      final logs = response as List;

      for (final log in logs) {
        final success = await embedEvidenceLog(
          logId: log['id'] as String,
          eventType: log['event_type'] as String,
          payload: log['payload'] as Map<String, dynamic>? ?? {},
        );
        if (success) processed++;

        // Small delay to avoid rate limiting
        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (kDebugMode) {
        debugPrint('EmbeddingService: Backfilled $processed evidence logs');
      }
    } catch (e) {
      debugPrint('EmbeddingService: Backfill failed: $e');
    }

    return processed;
  }
}

/// Memory search result
class MemoryResult {
  final String id;
  final String source; // 'evidence' or 'conversation'
  final String content;
  final DateTime occurredAt;
  final double similarity;

  MemoryResult({
    required this.id,
    required this.source,
    required this.content,
    required this.occurredAt,
    required this.similarity,
  });

  factory MemoryResult.fromJson(Map<String, dynamic> json) {
    return MemoryResult(
      id: json['id'] as String,
      source: json['source'] as String,
      content: json['content'] as String,
      occurredAt: DateTime.parse(json['occurred_at'] as String),
      similarity: (json['similarity'] as num).toDouble(),
    );
  }
}
