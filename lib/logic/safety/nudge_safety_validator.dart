import 'package:flutter/material.dart';
import '../../data/models/habit_contract.dart';
import '../../data/services/social_contract_exception.dart';

/// Validates social safety rules for nudges
/// Implements the "Fairness Algorithm"
class NudgeSafetyValidator {
  
  /// Rate limiting configuration
  static const int MAX_NUDGES_PER_WITNESS_PER_DAY = 3;
  static const int MAX_NUDGES_TOTAL_PER_DAY = 6;
  static const int COOLDOWN_MINUTES = 30;

  /// Validates if a nudge can be sent
  /// Throws [SocialContractException] if any rule is violated
  static void validateNudge({
    required HabitContract contract,
    required String witnessId,
    DateTime? nowOverride, // For testing
    TimeOfDay? timeOfDayOverride, // For testing
  }) {
    // 0. Use overrides if provided (Dependency Injection for Time)
    final now = nowOverride ?? DateTime.now();
    final timeOfDay = timeOfDayOverride ?? TimeOfDay.fromDateTime(now);
    
    // 1. Block check
    if (contract.blockedWitnessIds.contains(witnessId)) {
      throw SocialContractException('You have been blocked from sending nudges.');
    }
    
    // 2. Global toggle check
    if (!contract.allowNudges) {
      throw SocialContractException('Nudges are disabled for this contract.');
    }
    
    // 3. Quiet hours check
    if (_isWithinQuietHours(contract, timeOfDay)) {
      throw SocialContractException('Nudges are not allowed during quiet hours.');
    }
    
    final today = DateTime(now.year, now.month, now.day);
    
    // 4. Rate Limiting Logic (Fairness Algorithm)
    
    // Get witness specific history
    final witnessHistory = contract.nudgeHistory[witnessId] ?? [];
    final witnessTodayCount = witnessHistory.where((dt) => dt.isAfter(today)).length;
    
    // 4a. Per-witness daily limit
    if (witnessTodayCount >= MAX_NUDGES_PER_WITNESS_PER_DAY) {
      throw SocialContractException(
        'You have reached your daily nudge limit ($MAX_NUDGES_PER_WITNESS_PER_DAY/day). '
        'Supportive reminders work best when spaced out.'
      );
    }
    
    // 4b. Cooldown check
    if (witnessHistory.isNotEmpty) {
      final lastNudge = witnessHistory.last;
      final difference = now.difference(lastNudge);
      if (difference.inMinutes < COOLDOWN_MINUTES) {
         final minutesLeft = COOLDOWN_MINUTES - difference.inMinutes;
         throw SocialContractException(
           'Please wait $minutesLeft minute(s) before nudging again.'
         );
      }
    }
    
    // 4c. Global daily limit (all witnesses)
    final allTodayNudges = contract.nudgeHistory.values
        .expand((dates) => dates)
        .where((dt) => dt.isAfter(today))
        .length;
        
    if (allTodayNudges >= MAX_NUDGES_TOTAL_PER_DAY) {
      throw SocialContractException(
        'This contract has reached its daily nudge limit ($MAX_NUDGES_TOTAL_PER_DAY/day). '
        'Let them focus without overwhelm.'
      );
    }
  }

  static bool _isWithinQuietHours(HabitContract contract, TimeOfDay now) {
    if (contract.nudgeQuietStart == null || contract.nudgeQuietEnd == null) {
      return false;
    }
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
}
