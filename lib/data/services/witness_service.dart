import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../config/supabase_config.dart';
import '../models/habit_contract.dart';
import '../models/witness_event.dart';
import 'auth_service.dart';
import 'contract_service.dart';
import 'social_contract_exception.dart';

/// Witness Service
/// 
/// Phase 22: "The Witness" - Social Accountability Loop
/// 
/// This service manages real-time accountability notifications:
/// 
/// 1. **The Completion Ping** (Builder -> Witness)
///    When User A completes their habit, User B gets notified:
///    "User A just cast a vote for [Identity]!"
/// 
/// 2. **The High Five** (Witness -> Builder)
///    User B taps notification and sends emoji reaction.
///    User A gets a SECOND dopamine hit (social validation).
/// 
/// 3. **The Shame Nudge** (Witness -> Builder, pre-failure)
///    When User A is about to miss (drift detected):
///    "User A is drifting on [Habit]. Nudge them?"
///    User B can send a preemptive nudge before failure.
/// 
/// Architecture:
/// - Uses Supabase Realtime for instant notifications
/// - Falls back to polling if realtime unavailable
/// - Local notifications bridge the gap when app is backgrounded
class WitnessService extends ChangeNotifier {
  final SupabaseClient? _supabase;
  final AuthService _authService;
  final ContractService _contractService;
  
  // Real-time subscriptions
  RealtimeChannel? _eventsChannel;
  StreamSubscription? _authSubscription;
  
  // Event cache
  List<WitnessEvent> _pendingEvents = [];
  List<WitnessEvent> _recentEvents = [];
  
  // State
  bool _isConnected = false;
  bool _isLoading = false;
  String? _lastError;
  
  // Callbacks for notification handling
  Function(WitnessEvent)? onEventReceived;
  Function(WitnessEvent)? onHighFiveReceived;
  Function(String contractId, String builderId)? onDriftDetected;
  
  WitnessService({
    SupabaseClient? supabaseClient,
    required AuthService authService,
    required ContractService contractService,
  }) : _supabase = supabaseClient,
       _authService = authService,
       _contractService = contractService;
  
  /// Whether service is available
  bool get isAvailable => _supabase != null && 
      SupabaseConfig.isConfigured && 
      _authService.isAuthenticated;
  
  /// Whether realtime is connected
  bool get isConnected => _isConnected;
  
  /// Whether currently loading
  bool get isLoading => _isLoading;
  
  /// Last error message
  String? get lastError => _lastError;
  
  /// Pending events (unread)
  List<WitnessEvent> get pendingEvents => List.unmodifiable(_pendingEvents);
  
  /// Recent events (last 50)
  List<WitnessEvent> get recentEvents => List.unmodifiable(_recentEvents);
  
  /// Count of unread events
  int get unreadCount => _pendingEvents.where((e) => !e.isRead).length;
  
  // ============================================================
  // INITIALIZATION
  // ============================================================
  
  /// Initialize the service and connect to realtime
  Future<void> initialize() async {
    if (!isAvailable) {
      if (kDebugMode) {
        debugPrint('WitnessService: Not available (offline or not authenticated)');
      }
      return;
    }
    
    try {
      // Fire-and-forget: Load recent events in background to not block startup
      // Error handling is internal to _loadRecentEvents() - see catch block at line ~255
      unawaited(_loadRecentEvents());
      
      // Open local storage for nudge limits
      await Hive.openBox('nudge_limits');

      // Subscribe to realtime events (also non-blocking for startup)
      unawaited(_subscribeToEvents());
      
      // Listen for auth changes (reconnect on auth change)
      _authSubscription = _authService.addListener(() {
        if (_authService.isAuthenticated) {
          _subscribeToEvents();
        } else {
          _unsubscribeFromEvents();
        }
      }) as StreamSubscription?;
      
      if (kDebugMode) {
        debugPrint('WitnessService: Initialized (background loading started)');
      }
    } catch (e) {
      _lastError = e.toString();
      if (kDebugMode) {
        debugPrint('WitnessService: Initialization error: $e');
      }
    }
  }
  
  /// Subscribe to realtime events for current user
  Future<void> _subscribeToEvents() async {
    if (!isAvailable) return;
    
    final userId = _authService.userId;
    if (userId == null) return;
    
    // Unsubscribe from existing channel
    await _unsubscribeFromEvents();
    
    try {
      // Subscribe to witness_events table where target_id = current user
      _eventsChannel = _supabase!.channel('witness_events_$userId');
      
      _eventsChannel!
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: SupabaseTables.witnessEvents,
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'target_id',
              value: userId,
            ),
            callback: (payload) {
              _handleRealtimeEvent(payload.newRecord);
            },
          )
          .subscribe((status, [error]) {
            _isConnected = status == RealtimeSubscribeStatus.subscribed;
            notifyListeners();
            
            if (kDebugMode) {
              debugPrint('WitnessService: Realtime status: $status');
              if (error != null) {
                debugPrint('WitnessService: Realtime error: $error');
              }
            }
          });
      
      if (kDebugMode) {
        debugPrint('WitnessService: Subscribed to realtime events');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WitnessService: Failed to subscribe: $e');
      }
    }
  }
  
  /// Unsubscribe from realtime events
  Future<void> _unsubscribeFromEvents() async {
    if (_eventsChannel != null) {
      await _supabase?.removeChannel(_eventsChannel!);
      _eventsChannel = null;
      _isConnected = false;
    }
  }
  
  /// Handle incoming realtime event
  void _handleRealtimeEvent(Map<String, dynamic> payload) {
    try {
      final event = WitnessEvent.fromJson(payload);
      
      // Add to pending events
      _pendingEvents.insert(0, event);
      
      // Add to recent events
      _recentEvents.insert(0, event);
      if (_recentEvents.length > 50) {
        _recentEvents = _recentEvents.sublist(0, 50);
      }
      
      // Notify listeners
      notifyListeners();
      
      // Trigger callback for notification handling
      onEventReceived?.call(event);
      
      // Special handling for high-fives (extra dopamine!)
      if (event.type == WitnessEventType.highFiveReceived) {
        onHighFiveReceived?.call(event);
      }
      
      if (kDebugMode) {
        debugPrint('WitnessService: Received event: ${event.type}');
        debugPrint('  Title: ${event.notificationTitle}');
        debugPrint('  Body: ${event.notificationBody}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WitnessService: Error parsing event: $e');
      }
    }
  }
  
  /// Load recent events from database
  Future<void> _loadRecentEvents() async {
    if (!isAvailable) return;
    
    final userId = _authService.userId;
    if (userId == null) return;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      final response = await _supabase!
          .from(SupabaseTables.witnessEvents)
          .select()
          .eq('target_id', userId)
          .order('created_at', ascending: false)
          .limit(50);
      
      _recentEvents = (response as List)
          .map((json) => WitnessEvent.fromJson(json))
          .toList();
      
      // Filter pending (unread) events
      _pendingEvents = _recentEvents.where((e) => !e.isRead).toList();
      
      _isLoading = false;
      notifyListeners();
      
      if (kDebugMode) {
        debugPrint('WitnessService: Loaded ${_recentEvents.length} recent events');
        debugPrint('WitnessService: ${_pendingEvents.length} unread');
      }
    } catch (e) {
      _isLoading = false;
      _lastError = e.toString();
      notifyListeners();
      
      if (kDebugMode) {
        debugPrint('WitnessService: Failed to load events: $e');
      }
    }
  }
  
  // ============================================================
  // BUILDER ACTIONS (Send events to Witness)
  // ============================================================
  
  /// Send completion ping to all witnesses
  /// Called when builder completes a habit
  /// 
  /// Notification copy: "[Name] just cast a vote for [Identity]!"
  Future<void> sendCompletionPing({
    required String habitId,
    required String habitName,
    required String identity,
    required int currentStreak,
  }) async {
    if (!isAvailable) return;
    
    final userId = _authService.userId;
    if (userId == null) return;
    
    // Find all active contracts where user is builder
    final activeContracts = _contractService.builderContracts
        .where((c) => c.habitId == habitId && c.isActive && c.witnessId != null)
        .toList();
    
    if (activeContracts.isEmpty) {
      if (kDebugMode) {
        debugPrint('WitnessService: No active contracts for habit $habitId');
      }
      return;
    }
    
    for (final contract in activeContracts) {
      try {
        final eventId = _generateEventId();
        
        // Check for streak milestone
        final isMilestone = StreakMilestones.isMilestone(currentStreak);
        final eventType = isMilestone 
            ? WitnessEventType.streakMilestone 
            : WitnessEventType.habitCompleted;
            
        // ✅ PRIVACY: Use contract-specific identity if set (e.g. "Sober Person" vs "Productive Employee")
        // otherwise fall back to the one passed in (which is likely the builder's default)
        final effectiveIdentity = contract.alternativeIdentity ?? identity;
        
        final event = WitnessEvent(
          id: eventId,
          contractId: contract.id,
          type: eventType,
          actorId: userId,
          targetId: contract.witnessId!,
          habitId: habitId,
          habitName: habitName,
          identity: effectiveIdentity,
          metadata: isMilestone ? {
            'streak': currentStreak,
            'milestone_emoji': StreakMilestones.getMilestoneEmoji(currentStreak),
            'milestone_message': StreakMilestones.getMilestoneMessage(currentStreak),
          } : {
            'streak': currentStreak,
          },
          createdAt: DateTime.now(),
        );
        
        await _supabase!
            .from(SupabaseTables.witnessEvents)
            .insert(event.toJson());
        
        if (kDebugMode) {
          debugPrint('WitnessService: Sent completion ping to witness ${contract.witnessId}');
          debugPrint('  Identity: $effectiveIdentity');
          if (isMilestone) {
            debugPrint('  Milestone: $currentStreak days!');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('WitnessService: Failed to send completion ping: $e');
        }
      }
    }
  }
  
  /// Notify witness that builder's streak was broken
  Future<void> sendStreakBrokenNotification({
    required String habitId,
    required String habitName,
    required int previousStreak,
  }) async {
    if (!isAvailable) return;
    
    final userId = _authService.userId;
    if (userId == null) return;
    
    final activeContracts = _contractService.builderContracts
        .where((c) => c.habitId == habitId && c.isActive && c.witnessId != null)
        .toList();
    
    for (final contract in activeContracts) {
      try {
        final event = WitnessEvent(
          id: _generateEventId(),
          contractId: contract.id,
          type: WitnessEventType.streakBroken,
          actorId: userId,
          targetId: contract.witnessId!,
          habitId: habitId,
          habitName: habitName,
          metadata: {'previous_streak': previousStreak},
          createdAt: DateTime.now(),
        );
        
        await _supabase!
            .from(SupabaseTables.witnessEvents)
            .insert(event.toJson());
      } catch (e) {
        if (kDebugMode) {
          debugPrint('WitnessService: Failed to send streak broken notification: $e');
        }
      }
    }
  }
  
  // ============================================================
  // WITNESS ACTIONS (Send events to Builder)
  // ============================================================
  
  /// Send a high-five reaction to the builder
  /// This triggers the SECOND dopamine hit for social validation
  Future<bool> sendHighFive({
    required String contractId,
    required String builderId,
    required String emoji,
    String? message,
  }) async {
    if (!isAvailable) return false;
    
    final userId = _authService.userId;
    if (userId == null) return false;
    
    try {
      final reaction = WitnessReaction(
        emoji: emoji,
        message: message,
        sentAt: DateTime.now(),
      );
      
      final event = WitnessEvent(
        id: _generateEventId(),
        contractId: contractId,
        type: WitnessEventType.highFiveReceived,
        actorId: userId,
        targetId: builderId,
        reaction: reaction,
        message: message ?? WitnessReaction.quick(emoji).message,
        createdAt: DateTime.now(),
      );
      
      await _supabase!
          .from(SupabaseTables.witnessEvents)
          .insert(event.toJson());
      
      if (kDebugMode) {
        debugPrint('WitnessService: Sent high-five $emoji to builder $builderId');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WitnessService: Failed to send high-five: $e');
      }
      return false;
    }
  }
  
  /// Send a nudge to the builder (witness initiated)
  Future<bool> sendNudge({
    required String contractId,
    required String builderId,
    required String message,
  }) async {
    if (!isAvailable) return false;
    
    final userId = _authService.userId;
    if (userId == null) return false;
    
    try {
      // 1. Check Global Nudge Limit (Spam Protection)
      if (!await _checkGlobalNudgeLimit(contractId)) {
        if (kDebugMode) {
          debugPrint('WitnessService: Daily nudge limit reached for contract $contractId');
        }
        // Throwing allows UI to show specific toast
        throw const SocialContractException('Daily nudge limit reached (6 max)');
      }
      
      final event = WitnessEvent(
        id: _generateEventId(),
        contractId: contractId,
        type: WitnessEventType.nudgeReceived,
        actorId: userId,
        targetId: builderId,
        message: message,
        createdAt: DateTime.now(),
      );
      
      await _supabase!
          .from(SupabaseTables.witnessEvents)
          .insert(event.toJson());
      
      // Also update contract nudge tracking
      final contract = _contractService.getContractById(contractId);
      if (contract != null) {
        await _contractService.sendNudge(contract, message);
      }
      
      if (kDebugMode) {
        debugPrint('WitnessService: Sent nudge to builder $builderId');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WitnessService: Sent nudge to builder $builderId');
      }
      
      return true;
    } on SocialContractException {
      rethrow; // Re-throw intentionally for UI handling
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WitnessService: Failed to send nudge: $e');
      }
      return false;
    }
  }
  
  // ============================================================
  // DRIFT DETECTION (The "Shame" Nudge System)
  // ============================================================
  
  /// Check if any builders are drifting and notify witnesses
  /// Called periodically or when drift is detected by the app
  Future<void> checkForDriftingBuilders() async {
    if (!isAvailable) return;
    
    final userId = _authService.userId;
    if (userId == null) return;
    
    // Get contracts where user is witness
    final witnessContracts = _contractService.witnessContracts
        .where((c) => c.isActive)
        .toList();
    
    for (final contract in witnessContracts) {
      // Check if builder is drifting (based on Phase 19 logic)
      // This would integrate with the DriftAnalysisService
      final isDrifting = await _checkBuilderDrift(contract);
      
      if (isDrifting) {
        // Notify the witness (current user) that their builder is drifting
        onDriftDetected?.call(contract.id, contract.builderId);
        
        if (kDebugMode) {
          debugPrint('WitnessService: Builder ${contract.builderId} is drifting');
        }
      }
    }
  }
  
  /// Check if a specific builder is drifting
  /// Returns true if builder hasn't completed and is past their usual time
  Future<bool> _checkBuilderDrift(HabitContract contract) async {
    // This would query the builder's completion status
    // For now, use simple logic based on contract data
    
    final now = DateTime.now();
    final hour = now.hour;
    
    // If it's evening (after 6 PM) and builder hasn't completed today
    // This is a simplified check - real implementation would use Phase 19 drift analysis
    if (hour >= 18) {
      // Check if there was a completion today
      // This would require querying the habit_completions table
      // For MVP, return false (don't trigger drift warnings yet)
      return false;
    }
    
    return false;
  }
  
  /// Send drift warning to witness
  /// Called when system detects builder is about to miss
  Future<void> sendDriftWarning({
    required String contractId,
    required String witnessId,
    required String builderId,
    required String habitName,
  }) async {
    if (!isAvailable) return;
    
    try {
      final event = WitnessEvent(
        id: _generateEventId(),
        contractId: contractId,
        type: WitnessEventType.driftWarning,
        actorId: builderId,  // System acting on behalf of builder
        targetId: witnessId,
        habitName: habitName,
        message: '$habitName might miss today. Send a nudge?',
        createdAt: DateTime.now(),
      );
      
      await _supabase!
          .from(SupabaseTables.witnessEvents)
          .insert(event.toJson());
      
      if (kDebugMode) {
        debugPrint('WitnessService: Sent drift warning to witness $witnessId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WitnessService: Failed to send drift warning: $e');
      }
    }
  }
  
  // ============================================================
  // EVENT MANAGEMENT
  // ============================================================
  
  /// Mark an event as read
  Future<void> markEventAsRead(String eventId) async {
    if (!isAvailable) return;
    
    try {
      await _supabase!
          .from(SupabaseTables.witnessEvents)
          .update({'is_read': true})
          .eq('id', eventId);
      
      // Update local cache
      final index = _pendingEvents.indexWhere((e) => e.id == eventId);
      if (index >= 0) {
        _pendingEvents[index] = _pendingEvents[index].copyWith(isRead: true);
        _pendingEvents.removeAt(index);
      }
      
      final recentIndex = _recentEvents.indexWhere((e) => e.id == eventId);
      if (recentIndex >= 0) {
        _recentEvents[recentIndex] = _recentEvents[recentIndex].copyWith(isRead: true);
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WitnessService: Failed to mark event as read: $e');
      }
    }
  }
  
  /// Mark all events as read
  Future<void> markAllEventsAsRead() async {
    if (!isAvailable) return;
    
    final userId = _authService.userId;
    if (userId == null) return;
    
    try {
      await _supabase!
          .from(SupabaseTables.witnessEvents)
          .update({'is_read': true})
          .eq('target_id', userId)
          .eq('is_read', false);
      
      // Update local cache
      _pendingEvents = [];
      _recentEvents = _recentEvents.map((e) => e.copyWith(isRead: true)).toList();
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WitnessService: Failed to mark all events as read: $e');
      }
    }
  }
  
  /// Get events for a specific contract
  Future<List<WitnessEvent>> getEventsForContract(String contractId) async {
    if (!isAvailable) return [];
    
    try {
      final response = await _supabase!
          .from(SupabaseTables.witnessEvents)
          .select()
          .eq('contract_id', contractId)
          .order('created_at', ascending: false)
          .limit(100);
      
      return (response as List)
          .map((json) => WitnessEvent.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WitnessService: Failed to get events for contract: $e');
      }
      return [];
    }
  }
  
  // ============================================================
  // HELPERS
  // ============================================================
  
  /// Generate unique event ID
  String _generateEventId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.hashCode.abs().toRadixString(16);
    return 'we_${timestamp}_$random';
  }
  
  /// Refresh events from server
  Future<void> refresh() async {
    await _loadRecentEvents();
  }
  
  @override
  void dispose() {
    _unsubscribeFromEvents();
    _authSubscription?.cancel();
    super.dispose();
  }
  
  /// Check if we're within the global daily nudge limit (6 per contract per day)
  Future<bool> _checkGlobalNudgeLimit(String contractId) async {
    try {
      final box = Hive.box('nudge_limits');
      final today = DateTime.now().toString().split(' ')[0]; // yyyy-MM-dd
      final key = 'nudges_${contractId}_$today';
      
      final currentCount = box.get(key, defaultValue: 0) as int;
      if (currentCount >= 6) {
        return false;
      }
      
      // Increment count (optimistic)
      await box.put(key, currentCount + 1);
      return true;
    } catch (e) {
      // Fail open if Hive errors (don't block user)
      if (kDebugMode) debugPrint('WitnessService: Error checking nudge limit: $e');
      return true;
    }
  }
}

/// Extension to Supabase tables for witness events
extension SupabaseTablesWitness on SupabaseTables {
  static const String witnessEvents = 'witness_events';
}
