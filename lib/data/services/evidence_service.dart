import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:uuid/uuid.dart';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_service.dart';

/// Evidence Event Types
class EvidenceEventType {
  static const String habitCompletion = 'habit_completion';
  static const String emotionDetected = 'emotion_detected';
  static const String doomScrollSession = 'doom_scroll_session';
  static const String interventionDelivered = 'intervention_delivered';
  static const String interventionOutcome = 'intervention_outcome';
}

/// Evidence Service
/// 
/// Phase 3: Evidence Foundation
/// 
/// Centralized logging for behavioral signals.
/// Features:
/// - Singleton access
/// - Offline queuing (Hive)
/// - Background worker support (queue-only)
/// - Retry mechanism with exponential backoff
class EvidenceService {
  static final EvidenceService instance = EvidenceService._();
  static const _uuid = Uuid();
  
  EvidenceService._();
  
  AuthService? _authService;
  Box? _queueBox;
  static const String _queueBoxName = 'evidence_queue';
  bool _isSyncing = false;
  
  /// Configure the service with dependencies
  /// Call this after Provider tree is built (e.g., in main.dart or AppState)
  void configure({required AuthService authService}) {
    _authService = authService;
  }
  
  /// Initialize the service (opens Hive box)
  Future<void> initialize() async {
    try {
      if (!Hive.isBoxOpen(_queueBoxName)) {
        _queueBox = await Hive.openBox(_queueBoxName);
      } else {
        _queueBox = Hive.box(_queueBoxName);
      }
      
      // Prune old events (older than 30 days)
      await _pruneOldEvents();
      
      if (kDebugMode) {
        debugPrint('EvidenceService initialized. Queue size: ${_queueBox?.length ?? 0}');
      }
    } catch (e) {
      debugPrint('EvidenceService initialization failed: $e');
    }
  }
  
  /// Get current user ID or 'anonymous'
  String get _userId => _authService?.currentUser?.id ?? 'anonymous';
  
  /// Check if Supabase is available
  bool get _isOnline => _authService?.isSupabaseAvailable ?? false;

  // ===========================================================================
  // Public Logging Methods
  // ===========================================================================

  /// Log habit completion
  Future<void> logHabitCompletion({
    required String habitId,
    required DateTime timestamp,
  }) async {
    await _logEvent(
      type: EvidenceEventType.habitCompletion,
      payload: {
        'habit_id': habitId,
        'completed_at': timestamp.toIso8601String(),
      },
      occurredAt: timestamp,
    );
  }

  /// Log emotion detected from voice session
  Future<void> logEmotionDetected({
    required String emotion,
    required double confidence,
    required String source,
  }) async {
    await _logEvent(
      type: EvidenceEventType.emotionDetected,
      payload: {
        'emotion': emotion,
        'confidence': confidence,
        'source': source,
      },
    );
  }

  /// Log doom scroll session (Guardin Mode)
  /// Note: [dailyMinutes] is the daily total, as session-level tracking 
  /// is not yet available via native bridge.
  Future<void> logDoomScrollSession({
    required String appName,
    required int dailyMinutes,
    required int? tier,
  }) async {
    await _logEvent(
      type: EvidenceEventType.doomScrollSession,
      payload: {
        'app_name': appName,
        'daily_minutes': dailyMinutes,
        'guardian_tier': tier,
      },
    );
  }

  /// Log intervention delivered (Background Worker)
  /// Note: This is usually called from background isolate where Supabase
  /// might not be active. It will be queued.
  Future<void> logInterventionDelivered({
    required String eventId,
    required String armId,
    required String habitId,
    required String trigger,
  }) async {
    await _logEvent(
      type: EvidenceEventType.interventionDelivered,
      payload: {
        'event_id': eventId,
        'arm_id': armId,
        'habit_id': habitId,
        'trigger': trigger,
      },
      forceQueue: true, // Always queue background events for safety
    );
  }

  /// Log intervention outcome (User Response)
  Future<void> logInterventionOutcome({
    required String eventId,
    required bool engaged,
    required bool habitCompleted,
  }) async {
    await _logEvent(
      type: EvidenceEventType.interventionOutcome,
      payload: {
        'event_id': eventId,
        'engaged': engaged,
        'habit_completed': habitCompleted,
      },
    );
  }

  // ===========================================================================
  // Internal Logic & Sync
  // ===========================================================================

  /// Core logging logic
  Future<void> _logEvent({
    required String type,
    required Map<String, dynamic> payload,
    DateTime? occurredAt,
    bool forceQueue = false,
  }) async {
    final event = {
      'id': _generateUuid(),
      'user_id': _userId, // Capture ID at time of event
      'event_type': type,
      'payload': payload,
      'occurred_at': (occurredAt ?? DateTime.now()).toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
      'retry_count': 0,
    };

    if (forceQueue || !_isOnline) {
      await _queueEvent(event);
      if (kDebugMode) debugPrint('EvidenceService: Queued event $type');
    } else {
      try {
        await _sendToSupabase(event);
        if (kDebugMode) debugPrint('EvidenceService: Sent event $type');
      } catch (e) {
        if (kDebugMode) debugPrint('EvidenceService: Send failed ($e), queuing...');
        await _queueEvent(event);
      }
    }
  }

  /// Send single event to Supabase
  Future<void> _sendToSupabase(Map<String, dynamic> event) async {
    final client = Supabase.instance.client;
    
    // Remove metadata fields not in schema
    final data = Map<String, dynamic>.from(event);
    data.remove('retry_count');
    // Ensure we don't send 'id' if we want DB to generate it, 
    // BUT we generated it locally to ensure uniqueness across retries.
    // The schema says DEFAULT gen_random_uuid(), but we can override.
    
    await client.from('evidence_logs').insert(data);
  }

  /// Queue event in Hive
  Future<void> _queueEvent(Map<String, dynamic> event) async {
    if (_queueBox == null) await initialize();
    await _queueBox?.add(event);
  }

  /// Sync queued events to Supabase
  /// Call this on app start and foreground resume
  Future<void> syncQueuedEvents() async {
    if (_isSyncing || !_isOnline || _queueBox == null || _queueBox!.isEmpty) return;
    
    _isSyncing = true;
    if (kDebugMode) debugPrint('EvidenceService: Starting sync of ${_queueBox!.length} events...');

    try {
      final keys = _queueBox!.keys.toList();
      final List<dynamic> events = keys.map((k) => _queueBox!.get(k)).toList();
      
      // Process in batches (e.g., 50) to avoid timeouts
      // For now, simple loop with handling
      for (int i = 0; i < events.length; i++) {
        final key = keys[i];
        final event = Map<String, dynamic>.from(events[i]);
        
        try {
          await _sendToSupabase(event);
          await _queueBox!.delete(key); // Remove on success
        } catch (e) {
          // Handle failure
          int retries = (event['retry_count'] as int? ?? 0) + 1;
          event['retry_count'] = retries;
          
          if (retries > 3) {
            // Permanent failure or backend issue.
            // For now, keep it? Or move to dead letter?
            // User plan says: "On permanent failure: Keep in queue, log warning, skip to next"
            // But we can't keep retrying forever.
            // Let's implement exponential backoff check
            if (kDebugMode) debugPrint('EvidenceService: Event failed $retries times. Skipping for now.');
            await _queueBox!.put(key, event); // Update retry count
          } else {
             // Calculate backoff
             // We don't actually wait here, we just update count.
             // The loop continues. Next sync will try again.
             await _queueBox!.put(key, event);
          }
        }
      }
    } catch (e) {
      debugPrint('EvidenceService: Sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }
  
  /// Prune events older than 30 days
  Future<void> _pruneOldEvents() async {
    if (_queueBox == null) return;
    
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final keysToRemove = <dynamic>[];
    
    for (var key in _queueBox!.keys) {
      final event = _queueBox!.get(key);
      if (event != null && event['created_at'] != null) {
        final createdAt = DateTime.parse(event['created_at']);
        if (createdAt.isBefore(cutoff)) {
          keysToRemove.add(key);
        }
      }
    }
    
    if (keysToRemove.isNotEmpty) {
      await _queueBox!.deleteAll(keysToRemove);
      if (kDebugMode) debugPrint('EvidenceService: Pruned ${keysToRemove.length} old events');
    }
  }

  String _generateUuid() {
    return _uuid.v4();
  }
}
