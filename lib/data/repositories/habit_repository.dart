import '../models/habit.dart';

/// Abstract interface for habit data persistence.
/// Decouples the Provider layer from the Infrastructure layer (Hive).
abstract class HabitRepository {
  /// Initialize the repository
  Future<void> init();
  
  /// Get all habits from storage
  Future<List<Habit>> getAll();
  
  /// Save a single habit
  Future<void> save(Habit habit);
  
  /// Save all habits (batch)
  Future<void> saveAll(List<Habit> habits);
  
  /// Delete a habit by ID
  Future<void> delete(String habitId);
  
  /// Get the focused habit ID
  Future<String?> getFocusedHabitId();
  
  /// Set the focused habit ID
  Future<void> setFocusedHabitId(String? habitId);
  
  /// Clear all habit data
  Future<void> clear();
}
