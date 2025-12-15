/// Completion Result - Phase 13: Habit Stacking
/// 
/// Represents the result of completing a habit, including information
/// about stacked habits that should be triggered next.
/// 
/// Part of the "Chain Reaction" feature where completing one habit
/// can prompt the user to do the next stacked habit.

class CompletionResult {
  /// Whether this was a new completion (not already completed today)
  final bool wasNewCompletion;
  
  /// The ID of the habit that was completed
  final String completedHabitId;
  
  /// The name of the habit that was completed
  final String completedHabitName;
  
  /// If this habit has a stacked habit, this is the ID of the next habit to prompt
  final String? nextStackedHabitId;
  
  /// The name of the next stacked habit (for display in prompt)
  final String? nextStackedHabitName;
  
  /// The emoji of the next stacked habit (for visual prompt)
  final String? nextStackedHabitEmoji;
  
  /// The tiny version of the next stacked habit (for context)
  final String? nextStackedHabitTinyVersion;
  
  /// Whether the stacked habit is a "break" habit
  final bool? isNextStackedBreakHabit;
  
  /// Whether this completion was a recovery (bounced back from miss)
  final bool wasRecovery;
  
  /// Number of days missed before this recovery (0 if not recovery)
  final int daysMissedBeforeRecovery;
  
  /// Whether the user used the tiny/minimum version
  final bool usedTinyVersion;
  
  CompletionResult({
    required this.wasNewCompletion,
    required this.completedHabitId,
    required this.completedHabitName,
    this.nextStackedHabitId,
    this.nextStackedHabitName,
    this.nextStackedHabitEmoji,
    this.nextStackedHabitTinyVersion,
    this.isNextStackedBreakHabit,
    this.wasRecovery = false,
    this.daysMissedBeforeRecovery = 0,
    this.usedTinyVersion = false,
  });
  
  /// Whether there's a stacked habit to prompt next
  bool get hasStackedHabit => nextStackedHabitId != null;
  
  /// Get the chain reaction message for the stacked habit
  String get chainReactionMessage {
    if (!hasStackedHabit) return '';
    
    final action = isNextStackedBreakHabit == true ? 'avoid' : 'do';
    return 'Chain Reaction! Ready to $action "$nextStackedHabitName" next?';
  }
  
  /// Get the stacking phrase for display
  String get stackingPhrase {
    if (!hasStackedHabit) return '';
    return 'After completing "$completedHabitName", stack with "$nextStackedHabitName"';
  }
  
  /// Factory for a simple "already completed" result
  factory CompletionResult.alreadyCompleted(String habitId, String habitName) {
    return CompletionResult(
      wasNewCompletion: false,
      completedHabitId: habitId,
      completedHabitName: habitName,
    );
  }
  
  /// Factory for when no habit exists
  factory CompletionResult.noHabit() {
    return CompletionResult(
      wasNewCompletion: false,
      completedHabitId: '',
      completedHabitName: '',
    );
  }
  
  @override
  String toString() {
    return 'CompletionResult('
        'completed: $wasNewCompletion, '
        'habit: $completedHabitName, '
        'hasStack: $hasStackedHabit'
        '${hasStackedHabit ? ", next: $nextStackedHabitName" : ""}'
        ')';
  }
}
