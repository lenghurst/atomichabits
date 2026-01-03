/// JITAIStateRepository - Persistence for JITAI bandit state
///
/// Sprint 1: "Close the Loop" - Fixes Bandit Amnesia
///
/// Problem: The hierarchical bandit's learned Thompson Sampling parameters
/// (alpha/beta posteriors) were never persisted. Every app restart reset
/// the bandit to uniform priors, losing all personalization.
///
/// Solution: This repository persists bandit state to Hive on:
/// - App pause (lifecycle)
/// - App dispose
/// - After significant learning (periodic)
///
/// And hydrates on:
/// - JITAIProvider.initialize()

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Repository interface for JITAI state persistence
abstract class JITAIStateRepository {
  /// Initialize the repository
  Future<void> init();

  /// Load bandit state from storage
  Future<Map<String, dynamic>?> loadBanditState();

  /// Save bandit state to storage
  Future<void> saveBanditState(Map<String, dynamic> state);

  /// Clear all saved state
  Future<void> clear();

  /// Check if state exists
  Future<bool> hasState();
}

/// Hive implementation of JITAIStateRepository
class HiveJITAIStateRepository implements JITAIStateRepository {
  Box? _box;
  static const String _boxName = 'jitai_state';
  static const String _banditStateKey = 'bandit_state';
  static const String _lastSavedKey = 'last_saved_at';

  @override
  Future<void> init() async {
    try {
      _box = await Hive.openBox(_boxName);
      if (kDebugMode) {
        debugPrint('HiveJITAIStateRepository: Initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('HiveJITAIStateRepository: Error opening box: $e');
      }
    }
  }

  @override
  Future<Map<String, dynamic>?> loadBanditState() async {
    if (_box == null) {
      if (kDebugMode) {
        debugPrint('HiveJITAIStateRepository: Box not initialized');
      }
      return null;
    }

    try {
      final stateData = _box!.get(_banditStateKey);
      if (stateData != null) {
        // Convert Hive's dynamic map to proper typed map
        final state = _deepCastMap(stateData);

        if (kDebugMode) {
          final lastSaved = _box!.get(_lastSavedKey);
          debugPrint('HiveJITAIStateRepository: Loaded state from $lastSaved');
        }

        return state;
      }

      if (kDebugMode) {
        debugPrint('HiveJITAIStateRepository: No saved state found');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('HiveJITAIStateRepository: Error loading state: $e');
      }
      return null;
    }
  }

  @override
  Future<void> saveBanditState(Map<String, dynamic> state) async {
    if (_box == null) {
      if (kDebugMode) {
        debugPrint('HiveJITAIStateRepository: Box not initialized, cannot save');
      }
      return;
    }

    try {
      await _box!.put(_banditStateKey, state);
      await _box!.put(_lastSavedKey, DateTime.now().toIso8601String());

      if (kDebugMode) {
        debugPrint('HiveJITAIStateRepository: State saved successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('HiveJITAIStateRepository: Error saving state: $e');
      }
    }
  }

  @override
  Future<void> clear() async {
    if (_box == null) return;

    await _box!.delete(_banditStateKey);
    await _box!.delete(_lastSavedKey);

    if (kDebugMode) {
      debugPrint('HiveJITAIStateRepository: State cleared');
    }
  }

  @override
  Future<bool> hasState() async {
    if (_box == null) return false;
    return _box!.containsKey(_banditStateKey);
  }

  /// Recursively cast Hive's dynamic maps to proper typed maps
  Map<String, dynamic> _deepCastMap(dynamic data) {
    if (data is Map) {
      return data.map((key, value) {
        if (value is Map) {
          return MapEntry(key.toString(), _deepCastMap(value));
        } else if (value is List) {
          return MapEntry(key.toString(), _deepCastList(value));
        }
        return MapEntry(key.toString(), value);
      });
    }
    return {};
  }

  /// Recursively cast Hive's dynamic lists
  List<dynamic> _deepCastList(List<dynamic> data) {
    return data.map((item) {
      if (item is Map) {
        return _deepCastMap(item);
      } else if (item is List) {
        return _deepCastList(item);
      }
      return item;
    }).toList();
  }
}
