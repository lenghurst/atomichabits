import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/supabase_config.dart';
import '../models/habit_contract.dart';
import 'auth_service.dart';
import 'social_contract_exception.dart';
import '../../logic/safety/nudge_safety_validator.dart';

/// Contract Service
/// 
/// Phase 16.2: Habit Contracts
/// Phase 16.4: Deep Links
/// 
/// Manages the full lifecycle of Habit Contracts:
/// - Create draft contracts
/// - Generate and share invite links
/// - Accept invites (witness joins)
/// - Track progress
/// - Send events/nudges
class ContractService extends ChangeNotifier {
  final SupabaseClient? _supabase;
  final AuthService _authService;
  
  // Cache of contracts
  List<HabitContract> _builderContracts = [];  // Contracts where user is builder
  List<HabitContract> _witnessContracts = [];  // Contracts where user is witness
  
  bool _isLoading = false;
  String? _lastError;
  
  ContractService({
    SupabaseClient? supabaseClient,
    required AuthService authService,
  }) : _supabase = supabaseClient,
       _authService = authService;
  
  /// Contracts where current user is the builder
  List<HabitContract> get builderContracts => _builderContracts;
  
  /// Contracts where current user is the witness
  List<HabitContract> get witnessContracts => _witnessContracts;
  
  /// All contracts for current user
  List<HabitContract> get allContracts => [..._builderContracts, ..._witnessContracts];
  
  /// Whether currently loading
  bool get isLoading => _isLoading;
  
  /// Last error message
  String? get lastError => _lastError;
  
  /// Whether service is available
  bool get isAvailable => _supabase != null && 
      SupabaseConfig.isConfigured && 
      _authService.isAuthenticated;
  
  // ============================================================
  // BUILDER OPERATIONS
  // ============================================================
  
  /// Create a new draft contract
  Future<ContractResult> createContract({
    required String habitId,
    required String title,
    String? commitmentStatement,
    int durationDays = 21,
    String? builderMessage,
    NudgeFrequency nudgeFrequency = NudgeFrequency.daily,
    NudgeStyle nudgeStyle = NudgeStyle.encouraging,
    // Phase 4: Identity Privacy
    String? alternativeIdentity,
    // Phase 24: Deferred Witness
    String? witnessId,
  }) async {
    if (!isAvailable) {
      return ContractResult.failure('Contract service not available');
    }
    
    final userId = _authService.userId;
    if (userId == null) {
      return ContractResult.failure('User not authenticated');
    }
    
    try {
      _isLoading = true;
      _lastError = null;
      notifyListeners();
      
      // Generate unique ID and invite code
      final contractId = _generateUUID();
      final inviteCode = HabitContract.generateInviteCode();
      final inviteUrl = SupabaseConfig.getInviteUrl(inviteCode);
      
      final now = DateTime.now();
      
      // Determine status based on witness
      // If witness provided (Self-witness), activate immediately
      final isSelfWitness = witnessId != null && witnessId == userId;
      final initialStatus = isSelfWitness ? ContractStatus.active : ContractStatus.draft;
      
      final contract = HabitContract(
        id: contractId,
        builderId: userId,
        witnessId: witnessId,
        habitId: habitId,
        inviteCode: inviteCode,
        inviteUrl: inviteUrl,
        title: title,
        commitmentStatement: commitmentStatement,
        durationDays: durationDays,
        status: initialStatus,
        nudgeFrequency: nudgeFrequency,
        nudgeStyle: nudgeStyle,
        builderMessage: builderMessage,
        createdAt: now,
        updatedAt: now,
        alternativeIdentity: alternativeIdentity,
        // If self-witness, set start/accepted times
        startedAt: isSelfWitness ? now : null,
        acceptedAt: isSelfWitness ? now : null,
        startDate: isSelfWitness ? now : null,
        endDate: isSelfWitness ? now.add(Duration(days: durationDays)) : null,
      );
      
      // Save to Supabase
      await _supabase!
          .from(SupabaseTables.contracts)
          .insert(contract.toJson());
      
      // Log event
      await _logEvent(
        contractId: contractId,
        eventType: ContractEventType.created,
        actorId: userId,
        actorRole: 'builder',
        message: 'Contract created',
      );
      
      if (isSelfWitness) {
        await _logEvent(
          contractId: contractId,
          eventType: ContractEventType.started,
          actorId: userId,
          actorRole: 'system', // System event for self-start
          message: 'Contract started (Self-Witness)',
        );
      }
      
      // Update local cache
      _builderContracts.add(contract);
      if (isSelfWitness) {
        // Also add to witness contracts if self-witnessing? 
        // Technically yes, they are also the witness.
        _witnessContracts.add(contract);
      }
      
      _isLoading = false;
      notifyListeners();
      
      if (kDebugMode) {
        debugPrint('ContractService: Created contract $contractId (Self-Witness: $isSelfWitness)');
      }
      
      return ContractResult.success(contract);
    } catch (e) {
      _isLoading = false;
      _lastError = e.toString();
      notifyListeners();
      
      if (kDebugMode) {
        debugPrint('ContractService: Failed to create contract: $e');
      }
      
      return ContractResult.failure(e.toString());
    }
  }
  
  /// Share contract invite link
  Future<ContractResult> shareInvite(HabitContract contract) async {
    if (!contract.canShare) {
      return ContractResult.failure('Contract cannot be shared in current status');
    }
    
    try {
      // Update status to pending if draft
      HabitContract updatedContract = contract;
      if (contract.status == ContractStatus.draft) {
        updatedContract = await _updateContractStatus(
          contract,
          ContractStatus.pending,
          inviteSentAt: DateTime.now(),
        );
      }
      
      // Generate share text
      final shareText = _generateShareText(updatedContract);
      
      // Use system share sheet
      await Share.share(
        shareText,
        subject: '${updatedContract.title} - Join my habit contract!',
      );
      
      // Log event
      await _logEvent(
        contractId: contract.id,
        eventType: ContractEventType.inviteSent,
        actorId: _authService.userId,
        actorRole: 'builder',
        message: 'Invite link shared',
      );
      
      return ContractResult.success(updatedContract);
    } catch (e) {
      return ContractResult.failure(e.toString());
    }
  }
  
  /// Get invite link without sharing
  String getInviteLink(HabitContract contract) {
    return contract.inviteUrl ?? SupabaseConfig.getInviteUrl(contract.inviteCode);
  }
  
  /// Update contract settings
  Future<ContractResult> updateContract(HabitContract contract, {
    String? title,
    String? commitmentStatement,
    int? durationDays,
    String? builderMessage,
    NudgeFrequency? nudgeFrequency,
    NudgeStyle? nudgeStyle,
  }) async {
    if (!contract.isEditable) {
      return ContractResult.failure('Contract cannot be edited in current status');
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      final updated = contract.copyWith(
        title: title,
        commitmentStatement: commitmentStatement,
        durationDays: durationDays,
        builderMessage: builderMessage,
        nudgeFrequency: nudgeFrequency,
        nudgeStyle: nudgeStyle,
        updatedAt: DateTime.now(),
      );
      
      await _supabase!
          .from(SupabaseTables.contracts)
          .update(updated.toJson())
          .eq('id', contract.id);
      
      // Update cache
      final index = _builderContracts.indexWhere((c) => c.id == contract.id);
      if (index >= 0) {
        _builderContracts[index] = updated;
      }
      
      _isLoading = false;
      notifyListeners();
      
      return ContractResult.success(updated);
    } catch (e) {
      _isLoading = false;
      _lastError = e.toString();
      notifyListeners();
      return ContractResult.failure(e.toString());
    }
  }
  
  /// Cancel a contract (builder only)
  Future<ContractResult> cancelContract(HabitContract contract) async {
    if (contract.status == ContractStatus.completed || 
        contract.status == ContractStatus.cancelled) {
      return ContractResult.failure('Contract already finished');
    }
    
    try {
      final updated = await _updateContractStatus(
        contract,
        ContractStatus.cancelled,
        completedAt: DateTime.now(),
      );
      
      await _logEvent(
        contractId: contract.id,
        eventType: ContractEventType.cancelled,
        actorId: _authService.userId,
        actorRole: 'builder',
        message: 'Contract cancelled by builder',
      );
      
      return ContractResult.success(updated);
    } catch (e) {
      return ContractResult.failure(e.toString());
    }
  }
  
  // ============================================================
  // WITNESS OPERATIONS
  // ============================================================
  
  /// Lookup a contract by invite code (for joining)
  Future<ContractResult> lookupByInviteCode(String inviteCode) async {
    if (!isAvailable) {
      return ContractResult.failure('Contract service not available');
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      final response = await _supabase!
          .from(SupabaseTables.contracts)
          .select()
          .eq('invite_code', inviteCode.toUpperCase())
          .eq('status', 'pending')
          .maybeSingle();
      
      _isLoading = false;
      notifyListeners();
      
      if (response == null) {
        return ContractResult.failure('Contract not found or already accepted');
      }
      
      final contract = HabitContract.fromJson(response);
      return ContractResult.success(contract);
    } catch (e) {
      _isLoading = false;
      _lastError = e.toString();
      notifyListeners();
      return ContractResult.failure(e.toString());
    }
  }
  
  /// Accept a contract invite (become witness)
  Future<ContractResult> acceptInvite(HabitContract contract, {
    String? witnessMessage,
  }) async {
    if (!isAvailable) {
      return ContractResult.failure('Contract service not available');
    }
    
    final userId = _authService.userId;
    if (userId == null) {
      return ContractResult.failure('User not authenticated');
    }
    
    // Can't witness your own contract
    if (contract.builderId == userId) {
      return ContractResult.failure('You cannot witness your own contract');
    }
    
    // Must be pending
    if (contract.status != ContractStatus.pending) {
      return ContractResult.failure('Contract is not available for joining');
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      final now = DateTime.now();
      final startDate = now;
      final endDate = now.add(Duration(days: contract.durationDays));
      
      final updated = contract.copyWith(
        witnessId: userId,
        status: ContractStatus.active,
        witnessMessage: witnessMessage,
        startDate: startDate,
        endDate: endDate,
        acceptedAt: now,
        startedAt: now,
        updatedAt: now,
      );
      
      await _supabase!
          .from(SupabaseTables.contracts)
          .update(updated.toJson())
          .eq('id', contract.id);
      
      // Log events
      await _logEvent(
        contractId: contract.id,
        eventType: ContractEventType.witnessJoined,
        actorId: userId,
        actorRole: 'witness',
        message: witnessMessage ?? 'Witness joined the contract',
      );
      
      await _logEvent(
        contractId: contract.id,
        eventType: ContractEventType.started,
        actorId: userId,
        actorRole: 'system',
        message: 'Contract started',
        metadata: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );
      
      // Add to witness contracts
      _witnessContracts.add(updated);
      
      _isLoading = false;
      notifyListeners();
      
      if (kDebugMode) {
        debugPrint('ContractService: Witness joined contract ${contract.id}');
      }
      
      return ContractResult.success(updated);
    } catch (e) {
      _isLoading = false;
      _lastError = e.toString();
      notifyListeners();
      return ContractResult.failure(e.toString());
    }
  }
  
  /// Send a nudge to the builder (witness only)
  /// 
  /// Phase 21.3: Now tracks nudge timing for effectiveness measurement
  /// Send a nudge to the builder (witness only)
  /// 
  /// Phase 61: Enhanced Fairness Algorithm
  /// - Max 3 nudges per witness per day
  /// - Max 6 nudges total per day
  /// - 30-minute cooldown
  /// - Quiet hours protection
  Future<ContractResult> sendNudge(HabitContract contract, String message) async {
    if (!isAvailable) {
      return ContractResult.failure('Contract service not available');
    }
    
    final userId = _authService.userId;
    if (userId == null) {
      return ContractResult.failure('User not authenticated');
    }
    
    if (userId != contract.witnessId) {
      return ContractResult.failure('Only witness can send nudges');
    }
    
    if (!contract.isActive) {
      return ContractResult.failure('Contract is not active');
    }

    try {
      // Validation (Fairness Algorithm)
      // Throws SocialContractException if violated
      NudgeSafetyValidator.validateNudge(
        contract: contract, 
        witnessId: userId,
      );

      final now = DateTime.now();
      
      // Get witness specific history to update it
      final witnessHistory = contract.nudgeHistory[userId] ?? [];
      final witnessTodayCount = witnessHistory.where((dt) => 
          dt.isAfter(DateTime(now.year, now.month, now.day))).length;
      
      final allTodayNudges = contract.nudgeHistory.values
          .expand((dates) => dates)
          .where((dt) => dt.isAfter(DateTime(now.year, now.month, now.day)))
          .length;
           
      // Update history
      final updatedWitnessHistory = [...witnessHistory, now];
      final Map<String, List<DateTime>> updatedNudgeHistory = Map.from(contract.nudgeHistory);
      updatedNudgeHistory[userId!] = updatedWitnessHistory;
      
      // Update Contract
      final updated = contract.copyWith(
        lastNudgeSentAt: now,
        nudgesReceivedCount: contract.nudgesReceivedCount + 1,
        nudgeHistory: updatedNudgeHistory,
        updatedAt: now,
      );
      
      await _supabase!
          .from(SupabaseTables.contracts)
          .update(updated.toJson())
          .eq('id', contract.id);
      
      await _logEvent(
        contractId: contract.id,
        eventType: ContractEventType.nudgeSent,
        actorId: userId,
        actorRole: 'witness',
        message: message,
        metadata: {
          'nudge_sent_at': now.toIso8601String(),
          'total_nudges': updated.nudgesReceivedCount,
          'witness_daily_count': witnessTodayCount + 1,
          'global_daily_count': allTodayNudges + 1,
        },
      );
      
      // Update cache
      final index = _witnessContracts.indexWhere((c) => c.id == contract.id);
      if (index >= 0) {
        _witnessContracts[index] = updated;
      }
      
      notifyListeners();
      
      // TODO: Send push notification to builder
      
      return ContractResult.success(updated);
    } on SocialContractException catch (e) {
      return ContractResult.failure(e.message);
    } catch (e) {
      return ContractResult.failure(e.toString());
    }
  }

  bool _isWithinQuietHours(HabitContract contract) {
    if (contract.nudgeQuietStart == null || contract.nudgeQuietEnd == null) {
      return false;
    }
    final now = TimeOfDay.now();
    final start = contract.nudgeQuietStart!;
    final end = contract.nudgeQuietEnd!;
    
    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
     
    if (startMinutes < endMinutes) {
      // e.g. 9am to 5pm
      return nowMinutes >= startMinutes && nowMinutes < endMinutes;
    } else {
      // e.g. 10pm to 8am (overnight)
      return nowMinutes >= startMinutes || nowMinutes < endMinutes;
    }
  }
  
  // ============================================================
  // PROGRESS TRACKING
  // ============================================================
  
  /// Record a day completed (called from AppState on habit completion)
  /// 
  /// Phase 21.3: Now tracks nudge response timing for effectiveness measurement
  Future<void> recordDayCompleted(String habitId) async {
    // Find active contracts for this habit
    final contracts = _builderContracts
        .where((c) => c.habitId == habitId && c.isActive)
        .toList();
    
    for (final contract in contracts) {
      try {
        final now = DateTime.now();
        final newStreak = contract.currentStreak + 1;
        
        // Phase 21.3: Check if this completion is a response to a nudge
        // A nudge response is recorded if:
        // 1. There was a recent nudge (within 24 hours)
        // 2. The builder hadn't already responded to it
        bool isNudgeResponse = false;
        int nudgesResponded = contract.nudgesRespondedCount;
        
        if (contract.hasOpenNudge && contract.lastNudgeSentAt != null) {
          final timeSinceNudge = now.difference(contract.lastNudgeSentAt!);
          if (timeSinceNudge.inHours <= 24) {
            isNudgeResponse = true;
            nudgesResponded++;
          }
        }
        
        final updated = contract.copyWith(
          daysCompleted: contract.daysCompleted + 1,
          currentStreak: newStreak,
          longestStreak: newStreak > contract.longestStreak 
              ? newStreak 
              : contract.longestStreak,
          updatedAt: now,
          // Phase 21.3: Update nudge response tracking
          lastNudgeResponseAt: isNudgeResponse ? now : contract.lastNudgeResponseAt,
          nudgesRespondedCount: nudgesResponded,
        );
        
        final updateData = {
          'days_completed': updated.daysCompleted,
          'current_streak': updated.currentStreak,
          'longest_streak': updated.longestStreak,
          'updated_at': updated.updatedAt.toIso8601String(),
          // Phase 21.3: Nudge effectiveness tracking
          'nudges_responded_count': updated.nudgesRespondedCount,
        };
        
        // Only update response timestamp if this was a nudge response
        if (isNudgeResponse) {
          updateData['last_nudge_response_at'] = now.toIso8601String();
        }
        
        await _supabase!
            .from(SupabaseTables.contracts)
            .update(updateData)
            .eq('id', contract.id);
        
        await _logEvent(
          contractId: contract.id,
          eventType: ContractEventType.dayCompleted,
          actorId: _authService.userId,
          actorRole: 'builder',
          // Phase 21.3: Log whether this was a nudge response
          metadata: isNudgeResponse ? {
            'nudge_response': true,
            'response_time_hours': contract.lastNudgeSentAt != null 
                ? now.difference(contract.lastNudgeSentAt!).inHours 
                : null,
            'nudge_effectiveness_rate': updated.nudgeEffectivenessRate,
          } : null,
        );
        
        // Update cache
        final index = _builderContracts.indexWhere((c) => c.id == contract.id);
        if (index >= 0) {
          _builderContracts[index] = updated;
        }
        
        // Check if contract completed
        if (updated.daysCompleted >= contract.durationDays) {
          await _completeContract(updated);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('ContractService: Failed to record completion: $e');
        }
      }
    }
    
    notifyListeners();
  }
  
  /// Record a day missed
  Future<void> recordDayMissed(String habitId) async {
    final contracts = _builderContracts
        .where((c) => c.habitId == habitId && c.isActive)
        .toList();
    
    for (final contract in contracts) {
      try {
        final updated = contract.copyWith(
          daysMissed: contract.daysMissed + 1,
          currentStreak: 0,  // Reset streak
          updatedAt: DateTime.now(),
        );
        
        await _supabase!
            .from(SupabaseTables.contracts)
            .update({
              'days_missed': updated.daysMissed,
              'current_streak': 0,
              'updated_at': updated.updatedAt.toIso8601String(),
            })
            .eq('id', contract.id);
        
        await _logEvent(
          contractId: contract.id,
          eventType: ContractEventType.dayMissed,
          actorId: _authService.userId,
          actorRole: 'builder',
        );
        
        // Update cache
        final index = _builderContracts.indexWhere((c) => c.id == contract.id);
        if (index >= 0) {
          _builderContracts[index] = updated;
        }
        
        // Check if contract broken
        if (!updated.isOnTrack && updated.daysMissed >= contract.gracePeriodDays) {
          // Only break if significantly off track
          final totalDays = updated.daysCompleted + updated.daysMissed;
          if (totalDays >= 7 && updated.completionRate < 50) {
            await _breakContract(updated);
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('ContractService: Failed to record miss: $e');
        }
      }
    }
    
    notifyListeners();
  }
  
  // ============================================================
  // DATA LOADING
  // ============================================================
  
  /// Load all contracts for current user
  Future<void> loadContracts() async {
    if (!isAvailable) return;
    
    final userId = _authService.userId;
    if (userId == null) return;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // Load builder contracts
      final builderResponse = await _supabase!
          .from(SupabaseTables.contracts)
          .select()
          .eq('builder_id', userId)
          .order('created_at', ascending: false);
      
      _builderContracts = (builderResponse as List)
          .map((json) => HabitContract.fromJson(json))
          .toList();
      
      // Load witness contracts
      final witnessResponse = await _supabase
          .from(SupabaseTables.contracts)
          .select()
          .eq('witness_id', userId)
          .order('created_at', ascending: false);
      
      _witnessContracts = (witnessResponse as List)
          .map((json) => HabitContract.fromJson(json))
          .toList();
      
      _isLoading = false;
      notifyListeners();
      
      if (kDebugMode) {
        debugPrint('ContractService: Loaded ${_builderContracts.length} builder contracts');
        debugPrint('ContractService: Loaded ${_witnessContracts.length} witness contracts');
      }
    } catch (e) {
      _isLoading = false;
      _lastError = e.toString();
      notifyListeners();
      
      if (kDebugMode) {
        debugPrint('ContractService: Failed to load contracts: $e');
      }
    }
  }
  
  /// Get contract by ID
  HabitContract? getContractById(String id) {
    return allContracts.firstWhere(
      (c) => c.id == id,
      orElse: () => throw StateError('Contract not found'),
    );
  }
  
  /// Get contracts for a specific habit
  List<HabitContract> getContractsForHabit(String habitId) {
    return allContracts.where((c) => c.habitId == habitId).toList();
  }
  
  /// Get active contracts for a habit (builder perspective)
  HabitContract? getActiveContractForHabit(String habitId) {
    return _builderContracts.firstWhere(
      (c) => c.habitId == habitId && c.isActive,
      orElse: () => throw StateError('No active contract'),
    );
  }
  
  // ============================================================
  // PRIVATE HELPERS
  // ============================================================
  
  Future<HabitContract> _updateContractStatus(
    HabitContract contract,
    ContractStatus newStatus, {
    DateTime? inviteSentAt,
    DateTime? acceptedAt,
    DateTime? startedAt,
    DateTime? completedAt,
  }) async {
    final updated = contract.copyWith(
      status: newStatus,
      inviteSentAt: inviteSentAt,
      acceptedAt: acceptedAt,
      startedAt: startedAt,
      completedAt: completedAt,
      updatedAt: DateTime.now(),
    );
    
    await _supabase!
        .from(SupabaseTables.contracts)
        .update(updated.toJson())
        .eq('id', contract.id);
    
    // Update cache
    final index = _builderContracts.indexWhere((c) => c.id == contract.id);
    if (index >= 0) {
      _builderContracts[index] = updated;
    }
    
    notifyListeners();
    return updated;
  }
  
  Future<void> _completeContract(HabitContract contract) async {
    final updated = await _updateContractStatus(
      contract,
      ContractStatus.completed,
      completedAt: DateTime.now(),
    );
    
    await _logEvent(
      contractId: contract.id,
      eventType: ContractEventType.completed,
      actorId: _authService.userId,
      actorRole: 'system',
      message: 'Contract completed successfully!',
      metadata: {
        'days_completed': updated.daysCompleted,
        'completion_rate': updated.completionRate,
      },
    );
  }
  
  Future<void> _breakContract(HabitContract contract) async {
    final updated = await _updateContractStatus(
      contract,
      ContractStatus.broken,
      completedAt: DateTime.now(),
    );
    
    await _logEvent(
      contractId: contract.id,
      eventType: ContractEventType.broken,
      actorId: _authService.userId,
      actorRole: 'system',
      message: 'Contract broken - too many missed days',
      metadata: {
        'days_missed': updated.daysMissed,
        'completion_rate': updated.completionRate,
      },
    );
  }
  
  // ============================================================
  // SOCIAL SAFETY OPERATIONS (Phase 2)
  // ============================================================
  
  /// Block witnesses from the contract
  /// 
  /// Implementing "Witness Collusion" safeguard.
  /// Allows builder to remove abusive witnesses and prevent their re-entry.
  Future<ContractResult> blockWitnesses(HabitContract contract, List<String> witnessIdsToBlock) async {
    if (!isAvailable) return ContractResult.failure('Service unavailable');
    
    // Only builder can block
    if (contract.builderId != _authService.userId) {
      return ContractResult.failure('Only the builder can manage witnesses');
    }
    
    try {
      final currentBlocked = List<String>.from(contract.blockedWitnessIds);
      // Removed unused currentWitnesses 
      // Note: The current model supports single 'witnessId'. Phase 2 implies multi-witness support?
      // The user request shows: witnessIds: ['w1', 'w2', 'w3'].
      // CHECK: Does HabitContract have witnessIds (List) or just witnessId (String)?
      // Looking at model: `final String? witnessId;` (Single witness currently).
      // If we are strictly following the model, we can only block the CURRENT witness.
      // However, the test case requested implies multiple.
      // For now, I will implement for single witness model but designed for list capability.
      
      // Update blocked list
      for (final id in witnessIdsToBlock) {
        if (!currentBlocked.contains(id)) {
          currentBlocked.add(id);
        }
      }
      
      // If the current witness is being blocked, remove them
      bool shouldClearWitness = false;
      if (contract.witnessId != null && witnessIdsToBlock.contains(contract.witnessId)) {
        shouldClearWitness = true;
      }
      
      final updated = contract.copyWith(
        blockedWitnessIds: currentBlocked,
        clearWitness: shouldClearWitness,
        status: shouldClearWitness ? ContractStatus.pending : contract.status, // Revert to pending if witness removed
        updatedAt: DateTime.now(),
      );
      
      await _supabase!
          .from(SupabaseTables.contracts)
          .update(updated.toJson())
          .eq('id', contract.id);
          
      await _logEvent(
        contractId: contract.id,
        eventType: ContractEventType.updated, // Generic update or add specific event?
        actorId: _authService.userId,
        actorRole: 'builder',
        message: 'Blocked witnesses: ${witnessIdsToBlock.join(", ")}',
      );
      
      // Update cache
      final index = _builderContracts.indexWhere((c) => c.id == contract.id);
      if (index >= 0) {
        _builderContracts[index] = updated;
      }
      notifyListeners();
      
      return ContractResult.success(updated);

    } catch (e) {
      return ContractResult.failure(e.toString());
    }
  }

  /// Emergency Override: Dissolve Toxic Pact
  /// 
  /// Allows immediate termination of a contract for safety reasons.
  /// Can be triggered by Builder or Admin (if we had admin auth).
  /// For now, typically used by Builder to escape.
  Future<ContractResult> emergencyDissolveContract(HabitContract contract, String reason) async {
    if (!isAvailable) return ContractResult.failure('Service unavailable');
    
    try {
      final updated = contract.copyWith(
        status: ContractStatus.cancelled, // Or 'terminated' if we have that status
        builderMessage: 'Dissolved: $reason', // Append reason? Or metadata?
        allowNudges: false, // Hard disable
        sharePsychometrics: false, // Hard privacy reset
        updatedAt: DateTime.now(),
        completedAt: DateTime.now(),
      );
      
      await _supabase!
          .from(SupabaseTables.contracts)
          .update(updated.toJson())
          .eq('id', contract.id);
          
      await _logEvent(
        contractId: contract.id,
        eventType: ContractEventType.cancelled,
        actorId: _authService.userId,
        actorRole: 'builder', // or 'system'
        message: 'EMERGENCY DISSOLUTION: $reason',
        metadata: {'emergency': true, 'reason': reason},
      );
      
      // Update cache
      final index = _builderContracts.indexWhere((c) => c.id == contract.id);
      if (index >= 0) {
        _builderContracts[index] = updated;
      }
      // Also check witness cache just in case
      final wIndex = _witnessContracts.indexWhere((c) => c.id == contract.id);
      if (wIndex >= 0) {
         _witnessContracts[wIndex] = updated;
      }
      
      notifyListeners();
      return ContractResult.success(updated);
      
    } catch (e) {
      return ContractResult.failure(e.toString());
    }
  }
  
  Future<void> _logEvent({
    required String contractId,
    required ContractEventType eventType,
    String? actorId,
    String? actorRole,
    String? message,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _supabase!.from(SupabaseTables.contractEvents).insert({
        'id': _generateUUID(),
        'contract_id': contractId,
        'event_type': eventType.name,
        'actor_id': actorId,
        'actor_role': actorRole,
        'message': message,
        'metadata': metadata,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ContractService: Failed to log event: $e');
      }
    }
  }
  
  String _generateShareText(HabitContract contract) {
    final buffer = StringBuffer();
    
    buffer.writeln('🤝 ${contract.title}');
    buffer.writeln();
    
    if (contract.commitmentStatement != null) {
      buffer.writeln('"${contract.commitmentStatement}"');
      buffer.writeln();
    }
    
    if (contract.builderMessage != null) {
      buffer.writeln('Message: ${contract.builderMessage}');
      buffer.writeln();
    }
    
    buffer.writeln('📅 ${contract.durationDays} days');
    buffer.writeln();
    buffer.writeln('Help me stay accountable! Tap to join:');
    buffer.writeln(contract.inviteUrl ?? SupabaseConfig.getInviteUrl(contract.inviteCode));
    
    return buffer.toString();
  }
  
  String _generateUUID() {
    // Simple UUID v4 generation
    final random = DateTime.now().millisecondsSinceEpoch.toString() +
        DateTime.now().microsecond.toString();
    return 'contract_${random.hashCode.abs().toRadixString(16)}';
  }
}

/// Result of a contract operation
class ContractResult {
  final bool success;
  final HabitContract? contract;
  final String? error;
  
  ContractResult._({
    required this.success,
    this.contract,
    this.error,
  });
  
  factory ContractResult.success(HabitContract contract) {
    return ContractResult._(success: true, contract: contract);
  }
  
  factory ContractResult.failure(String error) {
    return ContractResult._(success: false, error: error);
  }
}
