import 'package:flutter/services.dart';
import 'dart:async';

/// Haptic Patterns Utility
/// 
/// Phase 25.9: "The Sacred Seal" - Complex Vibration Patterns
/// 
/// SME Recommendation (Don Norman - The Design of Everyday Things):
/// "The Wax Seal animation requires a complex vibration pattern (heavier impact
/// at the end), not a standard HapticFeedback.mediumImpact()."
/// 
/// "If the haptic feedback isn't perfectly timed with the visual animation
/// of the wax crushing, the illusion breaks. It becomes kitsch, not sacred."
/// 
/// This utility provides complex, multi-stage haptic patterns that synchronise
/// with visual animations to create a sense of weight and commitment.
class HapticPatterns {
  
  /// The Wax Seal Pattern - "The Sacred Stamp"
  /// 
  /// A complex pattern that simulates the physical sensation of pressing
  /// a wax seal onto paper. The pattern builds in intensity:
  /// 
  /// 1. Initial contact (light)
  /// 2. Pressing down (medium, sustained)
  /// 3. Wax spreading (light pulses)
  /// 4. Final stamp (heavy impact)
  /// 
  /// Total duration: ~600ms (synchronised with seal animation)
  static Future<void> waxSealStamp() async {
    // Phase 1: Initial contact - light touch
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    
    // Phase 2: Pressing down - medium sustained pressure
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.selectionClick();
    await Future.delayed(const Duration(milliseconds: 80));
    
    // Phase 3: Wax spreading - light pulses
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 60));
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 60));
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    
    // Phase 4: Final stamp - HEAVY impact (the "crush")
    // This is the moment the seal is complete
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.heavyImpact(); // Double tap for finality
  }
  
  /// The Signing Progress Pattern
  /// 
  /// Called during the hold-to-sign gesture at key progress points.
  /// Creates a sense of building commitment.
  /// 
  /// [progress] - Value from 0.0 to 1.0
  static Future<void> signingProgress(double progress) async {
    if (progress <= 0.0) return;
    
    // 25% - First checkpoint
    if (progress >= 0.25 && progress < 0.26) {
      await HapticFeedback.selectionClick();
    }
    // 50% - Halfway
    else if (progress >= 0.50 && progress < 0.51) {
      await HapticFeedback.lightImpact();
    }
    // 75% - Almost there
    else if (progress >= 0.75 && progress < 0.76) {
      await HapticFeedback.mediumImpact();
    }
    // 100% - Complete (handled by waxSealStamp)
  }
  
  /// The Voice Activity Detection Pattern
  /// 
  /// SME Recommendation (Don Norman):
  /// "Implement a visual 'listening' state immediately when the mic picks up
  /// sound, even before the socket sends the interrupt signal."
  /// 
  /// This provides immediate haptic feedback when voice is detected,
  /// confirming to the user that they've been heard.
  static Future<void> voiceDetected() async {
    await HapticFeedback.selectionClick();
  }
  
  /// The Voice Interrupt Pattern
  /// 
  /// Confirms that the user's voice has successfully interrupted the AI.
  /// More pronounced than voiceDetected to signal the state change.
  static Future<void> voiceInterrupt() async {
    await HapticFeedback.mediumImpact();
  }
  
  /// The AI Speaking Pattern
  /// 
  /// Subtle pulse when the AI starts speaking.
  /// Helps users know when to listen.
  static Future<void> aiSpeakingStart() async {
    await HapticFeedback.lightImpact();
  }
  
  /// The Habit Completion Pattern - "The Victory Tap"
  /// 
  /// Celebratory pattern when a habit is marked complete.
  /// Creates a sense of accomplishment.
  static Future<void> habitComplete() async {
    // Quick double-tap celebration
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }
  
  /// The Streak Milestone Pattern
  /// 
  /// Special pattern for streak milestones (7 days, 30 days, etc.)
  /// More elaborate to mark the achievement.
  static Future<void> streakMilestone() async {
    // Triple pulse celebration
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.heavyImpact();
  }
  
  /// The Recovery Pattern - "The Bounce Back"
  /// 
  /// Encouraging pattern when user recovers from a miss.
  /// Celebrates the "Never Miss Twice" philosophy.
  static Future<void> recoveryComplete() async {
    // Rising pattern - light to heavy
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }
  
  /// The Error Pattern
  /// 
  /// Subtle indication that something went wrong.
  /// Not jarring, but noticeable.
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    await HapticFeedback.heavyImpact();
  }
  
  /// The Button Press Pattern
  /// 
  /// Standard button feedback - used for important actions.
  static Future<void> buttonPress() async {
    await HapticFeedback.mediumImpact();
  }
  
  /// The Scroll Tick Pattern
  /// 
  /// Light feedback for scrolling through lists.
  static Future<void> scrollTick() async {
    await HapticFeedback.selectionClick();
  }
}

/// Voice Activity Indicator State
/// 
/// Used with GeminiLiveService to provide immediate visual and haptic
/// feedback when voice activity is detected.
enum VoiceActivityState {
  /// No voice detected
  idle,
  
  /// Voice detected, processing
  detecting,
  
  /// User is speaking (confirmed)
  speaking,
  
  /// AI is speaking
  aiSpeaking,
  
  /// User interrupted AI
  interrupted,
}

/// Extension for VoiceActivityState
extension VoiceActivityStateExtension on VoiceActivityState {
  /// Get the appropriate haptic pattern for this state
  Future<void> triggerHaptic() async {
    switch (this) {
      case VoiceActivityState.idle:
        // No haptic for idle
        break;
      case VoiceActivityState.detecting:
        await HapticPatterns.voiceDetected();
        break;
      case VoiceActivityState.speaking:
        // No additional haptic - detecting already fired
        break;
      case VoiceActivityState.aiSpeaking:
        await HapticPatterns.aiSpeakingStart();
        break;
      case VoiceActivityState.interrupted:
        await HapticPatterns.voiceInterrupt();
        break;
    }
  }
  
  /// Display name for debugging
  String get displayName {
    switch (this) {
      case VoiceActivityState.idle:
        return 'Idle';
      case VoiceActivityState.detecting:
        return 'Detecting...';
      case VoiceActivityState.speaking:
        return 'You\'re speaking';
      case VoiceActivityState.aiSpeaking:
        return 'AI is speaking';
      case VoiceActivityState.interrupted:
        return 'Interrupted';
    }
  }
  
  /// Icon for UI display
  String get icon {
    switch (this) {
      case VoiceActivityState.idle:
        return '🎤';
      case VoiceActivityState.detecting:
        return '👂';
      case VoiceActivityState.speaking:
        return '🗣️';
      case VoiceActivityState.aiSpeaking:
        return '🤖';
      case VoiceActivityState.interrupted:
        return '✋';
    }
  }
}
