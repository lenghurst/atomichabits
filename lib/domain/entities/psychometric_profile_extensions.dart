import 'package:flutter/material.dart';
import 'psychometric_profile.dart';

/// Extension for formatting PsychometricProfile data into display-ready text.
/// 
/// Phase 43: The Variable Reward - Pact Identity Card
/// 
/// This extension handles the "copywriting" logic, ensuring the text on the
/// card is punchy and high-status, regardless of what the user actually said.
/// 
/// The goal is to make the user feel like they've unlocked a premium artifact.
extension ProfileFormatting on PsychometricProfile {
  
  /// The "I AM BECOMING..." statement (displayed on card back)
  /// 
  /// Uses the user's bigWhy if available, otherwise defaults to an
  /// aspirational placeholder that still feels personal.
  String get identityStatement {
    if (bigWhy.isNotEmpty) {
      return bigWhy.toUpperCase();
    }
    // Fallback: Use first anti-identity as a contrast
    if (antiIdentities.isNotEmpty) {
      return "NOT ${antiIdentities.first.toUpperCase()}";
    }
    return "THE UNSTOPPABLE";
  }
  
  /// The "I AM BURYING..." statement (displayed with strikethrough)
  /// 
  /// This is the Anti-Identity captured by the Sherlock Protocol.
  /// Examples: "THE SLEEPWALKER", "THE GHOST", "THE DRIFTER"
  String get antiIdentityDisplay {
    return antiIdentityLabel?.toUpperCase() ?? "THE DRIFTER";
  }
  
  /// The "OPERATING RULE #1" statement
  /// 
  /// Converts the resistance lie into a prohibition rule.
  /// "The Bargain" becomes "NO MORE 'THE BARGAIN'"
  String get ruleStatement {
    if (resistanceLieLabel != null && resistanceLieLabel!.isNotEmpty) {
      return "NO MORE '${resistanceLieLabel!.toUpperCase()}'";
    }
    return "NO EXCUSES";
  }
  
  /// The exact lie phrase (for context display)
  /// 
  /// This is the specific phrase the user's brain whispers.
  /// Example: "I'll do double tomorrow"
  String get liePhrase {
    return resistanceLieContext ?? "Tomorrow never comes";
  }
  
  /// Dynamic colour based on the Failure Archetype
  /// 
  /// Each archetype gets a signature colour that reflects its psychology:
  /// - PERFECTIONIST: Gold (High standards, precious)
  /// - NOVELTY_SEEKER: Purple (Magic, mystery, chaos)
  /// - REBEL: Red (Defiance, fire, passion)
  /// - OBLIGER: Blue (Duty, service, trust)
  /// - OVERCOMMITTER: Orange (Energy, ambition, burnout)
  Color get archetypeColor {
    switch (failureArchetype) {
      case 'PERFECTIONIST':
        return const Color(0xFFFFD700); // Gold
      case 'NOVELTY_SEEKER':
        return const Color(0xFF9D4EDD); // Purple
      case 'REBEL':
        return const Color(0xFFFF4D4D); // Red
      case 'OBLIGER':
        return const Color(0xFF4CC9F0); // Blue
      case 'OVERCOMMITTER':
        return const Color(0xFFFF9F1C); // Orange
      default:
        return const Color(0xFFE0E0E0); // White/Grey (Stoic default)
    }
  }

  /// A short philosophy statement for the archetype
  /// 
  /// This is displayed as a subtitle under the rule, providing
  /// a one-line mantra for the user's specific weakness.
  String get archetypeDescription {
    switch (failureArchetype) {
      case 'PERFECTIONIST':
        return "Progress > Perfection";
      case 'NOVELTY_SEEKER':
        return "Embrace The Boredom";
      case 'REBEL':
        return "Freedom Through Discipline";
      case 'OBLIGER':
        return "You Promised Us";
      case 'OVERCOMMITTER':
        return "Less But Better";
      default:
        return "Never Miss Twice";
    }
  }
  
  /// The archetype displayed as a badge
  /// 
  /// Converts the enum-style string to a display-friendly format.
  String get archetypeBadge {
    if (failureArchetype == null || failureArchetype!.isEmpty) {
      return "STOIC";
    }
    // Convert NOVELTY_SEEKER to "NOVELTY SEEKER"
    return failureArchetype!.replaceAll('_', ' ');
  }
  
  /// Check if the profile has enough data to display a meaningful card
  bool get hasDisplayableData {
    return antiIdentityLabel != null || 
           failureArchetype != null || 
           resistanceLieLabel != null;
  }
}
