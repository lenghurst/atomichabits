import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/supabase_config.dart';
import '../models/habit.dart';
import 'auth_service.dart';

/// Sync Service
/// 
/// Phase 15: Identity Foundation
/// 
/// Provides one-way backup from local Hive storage to Supabase cloud.
/// 
/// Key Design Decisions:
/// 1. One-way sync (for now): Local → Cloud only. Prevents conflicts.
/// 2. Event-driven: Syncs on completeHabit, createHabit events
/// 3. Offline-resilient: Queues changes when offline, syncs when online
/// 4. Non-blocking: Sync happens in background, doesn't block UI
/// 
/// Future Phases:
/// - Phase 16: Two-way sync for multi-device support
/// - Phase 17: Real-time sync for Witness features
class SyncService extends ChangeNotifier {
  final SupabaseClient? _supabase;
  final AuthService _authService;
  
  SyncState _syncState = SyncState.idle;
  String? _lastError;
  DateTime? _lastSyncTime;
  int _pendingChanges = 0;
  
  // Queue for offline changes
  final List<SyncOperation> _syncQueue = [];
  
  // Connectivity check timer
  Timer? _connectivityTimer;
  
  SyncService({
    SupabaseClient? supabaseClient,
    required AuthService authService,
  }) : _supabase = supabaseClient,
       _authService = authService;
  
  /// Current sync state
  SyncState get syncState => _syncState;
  
  /// Last error message
  String? get lastError => _lastError;
  
  /// Last successful sync time
  DateTime? get lastSyncTime => _lastSyncTime;
  
  /// Number of pending changes waiting to sync
  int get pendingChanges => _pendingChanges;
  
  /// Alias for pendingChanges (used by settings UI)
  int get pendingChangesCount => _pendingChanges;
  
  /// Whether sync is currently in progress
  bool get isSyncing => _syncState == SyncState.syncing;
  
  /// Whether sync is available (user authenticated + Supabase configured)
  bool get isSyncAvailable {
    return _supabase != null && 
           SupabaseConfig.isConfigured && 
           _authService.isAuthenticated;
  }
  
  /// Initialize the sync service
  Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) {
      _syncState = SyncState.disabled;
      if (kDebugMode) {
        debugPrint('SyncService: Disabled (Supabase not configured)');
      }
      notifyListeners();
      return;
    }
    
    // Start connectivity check timer
    _connectivityTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _processSyncQueue(),
    );
    
    _syncState = SyncState.idle;
    notifyListeners();
  }
  
  /// Sync a habit to the cloud (called on createHabit)
  Future<SyncResult> syncHabit(Habit habit) async {
    if (!isSyncAvailable) {
      // Queue for later sync
      _queueOperation(SyncOperation(
        type: SyncOperationType.createHabit,
        habitId: habit.id,
        data: habit.toJson(),
        timestamp: DateTime.now(),
      ));
      return SyncResult.queued();
    }
    
    try {
      _syncState = SyncState.syncing;
      notifyListeners();
      
      final userId = _authService.userId;
      if (userId == null) {
        return SyncResult.failure('User not authenticated');
      }
      
      // Upsert habit to cloud
      await _supabase!.from(SupabaseTables.habits).upsert({
        'id': habit.id,
        'user_id': userId,
        'name': habit.name,
        'identity': habit.identity,
        'tiny_version': habit.tinyVersion,
        'implementation_intention': habit.implementationIntention,
        'scheduled_time': habit.scheduledTime,
        'is_break_habit': habit.isBreakHabit,
        'habit_emoji': habit.habitEmoji,
        'motivation': habit.motivation,
        'anchor_habit_id': habit.anchorHabitId,
        'stack_position': habit.stackPosition,
        'created_at': habit.createdAt.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'is_active': !habit.isPaused,
      });
      
      _syncState = SyncState.idle;
      _lastSyncTime = DateTime.now();
      _lastError = null;
      notifyListeners();
      
      return SyncResult.success();
    } catch (e) {
      _syncState = SyncState.error;
      _lastError = e.toString();
      notifyListeners();
      
      // Queue for retry
      _queueOperation(SyncOperation(
        type: SyncOperationType.createHabit,
        habitId: habit.id,
        data: habit.toJson(),
        timestamp: DateTime.now(),
      ));
      
      if (kDebugMode) {
        debugPrint('SyncService: Failed to sync habit: $e');
      }
      
      return SyncResult.failure(e.toString());
    }
  }
  
  /// Sync a habit completion to the cloud (called on completeHabit)
  Future<SyncResult> syncCompletion({
    required String habitId,
    required DateTime completionDate,
    bool isRecovery = false,
    bool usedTinyVersion = false,
  }) async {
    if (!isSyncAvailable) {
      // Queue for later sync
      _queueOperation(SyncOperation(
        type: SyncOperationType.completeHabit,
        habitId: habitId,
        data: {
          'completion_date': completionDate.toIso8601String(),
          'is_recovery': isRecovery,
          'used_tiny_version': usedTinyVersion,
        },
        timestamp: DateTime.now(),
      ));
      return SyncResult.queued();
    }
    
    try {
      _syncState = SyncState.syncing;
      notifyListeners();
      
      final userId = _authService.userId;
      if (userId == null) {
        return SyncResult.failure('User not authenticated');
      }
      
      // Insert completion record
      await _supabase!.from(SupabaseTables.completions).insert({
        'habit_id': habitId,
        'user_id': userId,
        'completion_date': completionDate.toIso8601String(),
        'is_recovery': isRecovery,
        'used_tiny_version': usedTinyVersion,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      _syncState = SyncState.idle;
      _lastSyncTime = DateTime.now();
      _lastError = null;
      notifyListeners();
      
      return SyncResult.success();
    } catch (e) {
      _syncState = SyncState.error;
      _lastError = e.toString();
      notifyListeners();
      
      // Queue for retry
      _queueOperation(SyncOperation(
        type: SyncOperationType.completeHabit,
        habitId: habitId,
        data: {
          'completion_date': completionDate.toIso8601String(),
          'is_recovery': isRecovery,
          'used_tiny_version': usedTinyVersion,
        },
        timestamp: DateTime.now(),
      ));
      
      if (kDebugMode) {
        debugPrint('SyncService: Failed to sync completion: $e');
      }
      
      return SyncResult.failure(e.toString());
    }
  }
  
  /// Sync habit update to the cloud
  Future<SyncResult> syncHabitUpdate(Habit habit) async {
    if (!isSyncAvailable) {
      _queueOperation(SyncOperation(
        type: SyncOperationType.updateHabit,
        habitId: habit.id,
        data: habit.toJson(),
        timestamp: DateTime.now(),
      ));
      return SyncResult.queued();
    }
    
    try {
      _syncState = SyncState.syncing;
      notifyListeners();
      
      await _supabase!.from(SupabaseTables.habits).update({
        'name': habit.name,
        'identity': habit.identity,
        'tiny_version': habit.tinyVersion,
        'implementation_intention': habit.implementationIntention,
        'scheduled_time': habit.scheduledTime,
        'is_break_habit': habit.isBreakHabit,
        'habit_emoji': habit.habitEmoji,
        'motivation': habit.motivation,
        'anchor_habit_id': habit.anchorHabitId,
        'stack_position': habit.stackPosition,
        'updated_at': DateTime.now().toIso8601String(),
        'is_active': !habit.isPaused,
      }).eq('id', habit.id);
      
      _syncState = SyncState.idle;
      _lastSyncTime = DateTime.now();
      _lastError = null;
      notifyListeners();
      
      return SyncResult.success();
    } catch (e) {
      _syncState = SyncState.error;
      _lastError = e.toString();
      notifyListeners();
      
      _queueOperation(SyncOperation(
        type: SyncOperationType.updateHabit,
        habitId: habit.id,
        data: habit.toJson(),
        timestamp: DateTime.now(),
      ));
      
      return SyncResult.failure(e.toString());
    }
  }
  
  /// Sync habit deletion to the cloud
  Future<SyncResult> syncHabitDeletion(String habitId) async {
    if (!isSyncAvailable) {
      _queueOperation(SyncOperation(
        type: SyncOperationType.deleteHabit,
        habitId: habitId,
        data: {},
        timestamp: DateTime.now(),
      ));
      return SyncResult.queued();
    }
    
    try {
      _syncState = SyncState.syncing;
      notifyListeners();
      
      // Soft delete - mark as inactive
      await _supabase!.from(SupabaseTables.habits).update({
        'is_active': false,
        'deleted_at': DateTime.now().toIso8601String(),
      }).eq('id', habitId);
      
      _syncState = SyncState.idle;
      _lastSyncTime = DateTime.now();
      _lastError = null;
      notifyListeners();
      
      return SyncResult.success();
    } catch (e) {
      _syncState = SyncState.error;
      _lastError = e.toString();
      notifyListeners();
      
      _queueOperation(SyncOperation(
        type: SyncOperationType.deleteHabit,
        habitId: habitId,
        data: {},
        timestamp: DateTime.now(),
      ));
      
      return SyncResult.failure(e.toString());
    }
  }
  
  /// Full backup of all habits to cloud
  Future<SyncResult> backupAllHabits(List<Habit> habits) async {
    if (!isSyncAvailable) {
      return SyncResult.failure('Sync not available');
    }
    
    try {
      _syncState = SyncState.syncing;
      notifyListeners();
      
      final userId = _authService.userId;
      if (userId == null) {
        return SyncResult.failure('User not authenticated');
      }
      
      // Batch upsert all habits
      final habitData = habits.map((h) => {
        'id': h.id,
        'user_id': userId,
        'name': h.name,
        'identity': h.identity,
        'tiny_version': h.tinyVersion,
        'implementation_intention': h.implementationIntention,
        'scheduled_time': h.scheduledTime,
        'is_break_habit': h.isBreakHabit,
        'habit_emoji': h.habitEmoji,
        'motivation': h.motivation,
        'anchor_habit_id': h.anchorHabitId,
        'stack_position': h.stackPosition,
        'created_at': h.createdAt.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'is_active': !h.isPaused,
        // Store completion history as JSON for backup
        'completion_history': h.completionHistory
            .map((d) => d.toIso8601String())
            .toList(),
      }).toList();
      
      await _supabase!.from(SupabaseTables.habits).upsert(habitData);
      
      _syncState = SyncState.idle;
      _lastSyncTime = DateTime.now();
      _lastError = null;
      notifyListeners();
      
      if (kDebugMode) {
        debugPrint('SyncService: Backed up ${habits.length} habits');
      }
      
      return SyncResult.success();
    } catch (e) {
      _syncState = SyncState.error;
      _lastError = e.toString();
      notifyListeners();
      
      if (kDebugMode) {
        debugPrint('SyncService: Full backup failed: $e');
      }
      
      return SyncResult.failure(e.toString());
    }
  }
  
  /// Queue an operation for later sync
  void _queueOperation(SyncOperation operation) {
    _syncQueue.add(operation);
    _pendingChanges = _syncQueue.length;
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('SyncService: Queued operation, pending: $_pendingChanges');
    }
  }
  
  /// Process queued sync operations
  Future<void> _processSyncQueue() async {
    if (!isSyncAvailable || _syncQueue.isEmpty) {
      return;
    }
    
    if (kDebugMode) {
      debugPrint('SyncService: Processing ${_syncQueue.length} queued operations');
    }
    
    final operations = List<SyncOperation>.from(_syncQueue);
    _syncQueue.clear();
    
    for (final op in operations) {
      try {
        switch (op.type) {
          case SyncOperationType.createHabit:
          case SyncOperationType.updateHabit:
            await _supabase!.from(SupabaseTables.habits).upsert(op.data);
            break;
          case SyncOperationType.completeHabit:
            await _supabase!.from(SupabaseTables.completions).insert({
              ...op.data,
              'habit_id': op.habitId,
              'user_id': _authService.userId,
              'created_at': DateTime.now().toIso8601String(),
            });
            break;
          case SyncOperationType.deleteHabit:
            await _supabase!.from(SupabaseTables.habits).update({
              'is_active': false,
              'deleted_at': DateTime.now().toIso8601String(),
            }).eq('id', op.habitId);
            break;
        }
      } catch (e) {
        // Re-queue failed operation
        _syncQueue.add(op);
        if (kDebugMode) {
          debugPrint('SyncService: Failed to process operation: $e');
        }
      }
    }
    
    _pendingChanges = _syncQueue.length;
    _lastSyncTime = DateTime.now();
    notifyListeners();
  }
  
  /// Force process sync queue now
  Future<void> forceSyncNow() async {
    await _processSyncQueue();
  }
  
  /// Alias for forceSyncNow (used by settings UI)
  Future<void> syncNow() async {
    await forceSyncNow();
  }
  
  /// Clear sync queue (use with caution)
  void clearSyncQueue() {
    _syncQueue.clear();
    _pendingChanges = 0;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _connectivityTimer?.cancel();
    super.dispose();
  }
}

/// Sync state
enum SyncState {
  idle,
  syncing,
  error,
  disabled,
}

/// Sync operation types
enum SyncOperationType {
  createHabit,
  updateHabit,
  deleteHabit,
  completeHabit,
}

/// Queued sync operation
class SyncOperation {
  final SyncOperationType type;
  final String habitId;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  
  SyncOperation({
    required this.type,
    required this.habitId,
    required this.data,
    required this.timestamp,
  });
}

/// Result of a sync operation
class SyncResult {
  final bool success;
  final bool queued;
  final String? error;
  
  SyncResult._({
    required this.success,
    this.queued = false,
    this.error,
  });
  
  factory SyncResult.success() {
    return SyncResult._(success: true);
  }
  
  factory SyncResult.queued() {
    return SyncResult._(success: true, queued: true);
  }
  
  factory SyncResult.failure(String error) {
    return SyncResult._(success: false, error: error);
  }
}
