import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';
import 'habit_repository.dart';

/// Hive implementation of HabitRepository.
/// All Hive-specific code is isolated here.
class HiveHabitRepository implements HabitRepository {
  Box? _dataBox;
  static const String _boxName = 'habit_data';
  static const String _habitsKey = 'habits';
  static const String _focusedHabitKey = 'focusedHabitId';
  static const String _legacyHabitKey = 'currentHabit';
  
  @override
  Future<void> init() async {
    try {
      _dataBox = await Hive.openBox(_boxName);
    } catch (e) {
      if (kDebugMode) debugPrint('HiveHabitRepository: Error opening box: $e');
    }
  }
  
  @override
  Future<List<Habit>> getAll() async {
    if (_dataBox == null) return [];
    
    final habitsJson = _dataBox!.get(_habitsKey);
    if (habitsJson != null) {
      final habitsList = habitsJson as List;
      return habitsList
          .map((h) => Habit.fromJson(Map<String, dynamic>.from(h)))
          .toList();
    }
    
    // Legacy migration: check for old single-habit format
    final legacyHabitJson = _dataBox!.get(_legacyHabitKey);
    if (legacyHabitJson != null) {
      final legacyHabit = Habit.fromJson(Map<String, dynamic>.from(legacyHabitJson));
      final migratedHabit = legacyHabit.copyWith(
        isPrimaryHabit: true,
        focusCycleStart: legacyHabit.focusCycleStart ?? legacyHabit.createdAt,
      );
      // Save migrated data
      await saveAll([migratedHabit]);
      return [migratedHabit];
    }
    
    return [];
  }
  
  @override
  Future<void> save(Habit habit) async {
    if (_dataBox == null) return;
    final habits = await getAll();
    final index = habits.indexWhere((h) => h.id == habit.id);
    if (index >= 0) {
      habits[index] = habit;
    } else {
      habits.add(habit);
    }
    await saveAll(habits);
  }
  
  @override
  Future<void> saveAll(List<Habit> habits) async {
    if (_dataBox == null) return;
    await _dataBox!.put(_habitsKey, habits.map((h) => h.toJson()).toList());
  }
  
  @override
  Future<void> delete(String habitId) async {
    if (_dataBox == null) return;
    final habits = await getAll();
    habits.removeWhere((h) => h.id == habitId);
    await saveAll(habits);
  }
  
  @override
  Future<String?> getFocusedHabitId() async {
    if (_dataBox == null) return null;
    return _dataBox!.get(_focusedHabitKey);
  }
  
  @override
  Future<void> setFocusedHabitId(String? habitId) async {
    if (_dataBox == null) return;
    if (habitId != null) {
      await _dataBox!.put(_focusedHabitKey, habitId);
    } else {
      await _dataBox!.delete(_focusedHabitKey);
    }
  }
  
  @override
  Future<void> clear() async {
    if (_dataBox == null) return;
    await _dataBox!.delete(_habitsKey);
    await _dataBox!.delete(_focusedHabitKey);
  }
}
