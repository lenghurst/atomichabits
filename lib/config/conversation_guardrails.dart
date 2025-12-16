/// Conversation Guardrails
/// 
/// Phase 21.2: FTUE Polish - Coaching-Focused Rejection Messages
/// 
/// The Problem: When users enter oversized or vague habits, the rejection
/// can feel frustrating. This creates friction at the critical FTUE moment.
/// 
/// The Solution: Frame every rejection as coaching. The user should feel
/// like they're being guided by an expert, not scolded by a validator.
/// 
/// Reference: CPO Boardroom feedback - "Error messages should be coaching"
library;

/// Coaching-focused rejection messages
/// 
/// These replace cold validation errors with warm guidance.
/// Each message explains WHY we're asking them to change,
/// frames the change as PROGRESS (not failure), and offers
/// a specific NEXT STEP.
class ConversationGuardrails {
  
  // ============================================================
  // OVERSIZED HABIT REJECTIONS (The 2-Minute Rule)
  // ============================================================
  
  /// Rejection for time-based oversized habits
  /// e.g., "30 minutes of exercise"
  static const oversizedTime = RejectionMessage(
    headline: 'Your ambition is impressive!',
    explanation: 'But on Day 1, motivation is high - and it will fade. '
        'We need a habit so small that you can do it on your worst day.',
    coaching: 'What could you do in just 2 minutes that would still '
        'feel like progress? (Hint: "Put on running shoes" counts!)',
    icon: '🎯',
  );
  
  /// Rejection for chapter/unit-based oversized habits
  /// e.g., "Read a chapter"
  static const oversizedUnit = RejectionMessage(
    headline: 'Chapters are for later.',
    explanation: 'A chapter requires 20+ minutes and willpower. '
        'The real habit is the gateway action.',
    coaching: 'What if the habit was just "Read 1 page"? '
        'Once you start, you\'ll probably read more - but 1 page is the commitment.',
    icon: '📖',
  );
  
  /// Rejection for routine-based oversized habits
  /// e.g., "Morning routine"
  static const oversizedRoutine = RejectionMessage(
    headline: 'Routines are powerful, but they\'re built brick by brick.',
    explanation: 'Trying to install a full routine is like trying to '
        'run before you can walk. One habit unlocks the next.',
    coaching: 'What\'s the first domino? The ONE action that, if you nailed it, '
        'would make the rest of your routine easier?',
    icon: '🧱',
  );
  
  // ============================================================
  // VAGUE HABIT REJECTIONS (Specificity)
  // ============================================================
  
  /// Rejection for abstract goals
  /// e.g., "Be healthier"
  static const vagueAbstract = RejectionMessage(
    headline: '"Healthier" is a direction, not a destination.',
    explanation: 'Your brain can\'t schedule something abstract. '
        'It needs a specific action at a specific time.',
    coaching: 'What\'s ONE physical action you could do tomorrow at a specific time? '
        '(e.g., "Drink water at 8am" beats "be healthier")',
    icon: '🧭',
  );
  
  /// Rejection for comparative goals
  /// e.g., "Exercise more"
  static const vagueComparative = RejectionMessage(
    headline: '"More" isn\'t measurable.',
    explanation: 'Without a specific target, you can\'t track progress, '
        'and what doesn\'t get measured doesn\'t get managed.',
    coaching: 'Let\'s make it concrete: What\'s one specific exercise '
        'you could do in 2 minutes? (e.g., "5 pushups")',
    icon: '📏',
  );
  
  /// Rejection for outcome goals (not process)
  /// e.g., "Lose 20 pounds"
  static const vagueOutcome = RejectionMessage(
    headline: 'That\'s a result - let\'s design the system that gets you there.',
    explanation: 'You can\'t control outcomes directly. '
        'But you CAN control the daily actions that lead to them.',
    coaching: 'What\'s the daily 2-minute action that would compound '
        'toward that result? (Focus on what you\'ll DO, not what will HAPPEN)',
    icon: '🔄',
  );
  
  // ============================================================
  // MULTIPLE HABIT REJECTIONS (Focus)
  // ============================================================
  
  /// Rejection for attempting multiple habits
  static const multipleHabits = RejectionMessage(
    headline: 'I love the enthusiasm! But one domino at a time.',
    explanation: 'Research shows that adding multiple habits simultaneously '
        'dramatically increases failure rates. Mastering one creates momentum for the rest.',
    coaching: 'If you could only pick ONE habit, which would have the biggest '
        'ripple effect on the others? (That\'s your keystone habit)',
    icon: '🎯',
  );
  
  // ============================================================
  // RECOVERY PLAN REJECTIONS (Never Miss Twice)
  // ============================================================
  
  /// Rejection for vague recovery plans
  /// e.g., "I'll try harder"
  static const vagueRecovery = RejectionMessage(
    headline: '"Try harder" is wishful thinking, not a plan.',
    explanation: 'When life gets chaotic, you won\'t have bandwidth '
        'for decisions. You need a pre-made algorithm.',
    coaching: 'Complete this sentence: "If I miss my habit, I will '
        '[specific action] at [specific time]." (e.g., "read during lunch break instead")',
    icon: '🛟',
  );
  
  /// Rejection for missing recovery plan
  static const missingRecovery = RejectionMessage(
    headline: 'Almost there! But we need a safety net.',
    explanation: 'The difference between successful habit builders and quitters? '
        'The builders plan for failure BEFORE it happens.',
    coaching: 'Life will disrupt your habit. When (not if) you miss a day, '
        'what\'s your specific backup plan to get back immediately?',
    icon: '🪢',
  );
  
  // ============================================================
  // IDENTITY REJECTIONS
  // ============================================================
  
  /// Prompt for missing identity
  static const missingIdentity = RejectionMessage(
    headline: 'Before we pick the habit, let\'s get clear on who you\'re becoming.',
    explanation: 'Habits are votes for your identity. '
        'Each completion is evidence that you ARE the person who does this.',
    coaching: 'Complete this sentence: "I am the type of person who..." '
        '(e.g., "I am a reader", "I am someone who moves their body daily")',
    icon: '🪞',
  );
  
  // ============================================================
  // HELPER METHODS
  // ============================================================
  
  /// Get appropriate rejection message for an oversized habit
  static RejectionMessage getOversizedMessage(String habitDescription) {
    final lower = habitDescription.toLowerCase();
    
    if (lower.contains('routine') || lower.contains('morning') || lower.contains('evening')) {
      return oversizedRoutine;
    }
    
    if (lower.contains('chapter') || lower.contains('book') || lower.contains('lesson')) {
      return oversizedUnit;
    }
    
    return oversizedTime;
  }
  
  /// Get appropriate rejection message for a vague habit
  static RejectionMessage getVagueMessage(String habitDescription) {
    final lower = habitDescription.toLowerCase();
    
    if (lower.contains('more') || lower.contains('less') || lower.contains('better')) {
      return vagueComparative;
    }
    
    if (_isOutcomeGoal(lower)) {
      return vagueOutcome;
    }
    
    return vagueAbstract;
  }
  
  /// Check if the habit description is an outcome goal
  static bool _isOutcomeGoal(String lower) {
    final outcomePatterns = [
      'lose', 'gain', 'get promoted', 'earn', 'achieve',
      'become', 'reach', 'hit', 'make', 'get to',
    ];
    return outcomePatterns.any((p) => lower.contains(p));
  }
  
  /// Get rejection message for a recovery plan issue
  static RejectionMessage getRecoveryMessage(String? recoveryPlan) {
    if (recoveryPlan == null || recoveryPlan.trim().isEmpty) {
      return missingRecovery;
    }
    
    // Check for vague recovery plans
    final vagueIndicators = [
      'try', 'harder', 'more', 'better', 'just', 'simply',
    ];
    final lower = recoveryPlan.toLowerCase();
    if (vagueIndicators.any((v) => lower.contains(v)) && 
        !lower.contains('at') && !lower.contains('when')) {
      return vagueRecovery;
    }
    
    return missingRecovery; // Default fallback
  }
}

/// A coaching-focused rejection message
/// 
/// Structure:
/// - headline: Validates their ambition (positive)
/// - explanation: Explains the reasoning (educational)
/// - coaching: Guides them to the solution (actionable)
/// - icon: Visual reinforcement
class RejectionMessage {
  final String headline;
  final String explanation;
  final String coaching;
  final String icon;
  
  const RejectionMessage({
    required this.headline,
    required this.explanation,
    required this.coaching,
    required this.icon,
  });
  
  /// Format for display in chat bubble
  String get formattedForChat {
    return '''$icon **$headline**

$explanation

$coaching''';
  }
  
  /// Format for display in error card
  String get formattedForCard {
    return '$headline\n\n$explanation\n\n$coaching';
  }
  
  @override
  String toString() => formattedForChat;
}

/// Progressive Disclosure Helper
/// 
/// Phase 21.2: Reduces cognitive load during FTUE by showing
/// features incrementally based on user progress.
class ProgressiveDisclosure {
  
  /// Features that should be hidden until user has completed onboarding
  static const Set<String> postOnboardingFeatures = {
    'contracts',
    'analytics',
    'habitStacking',
    'weeklyReview',
    'export',
  };
  
  /// Features that should be hidden until user has 7+ days of data
  static const Set<String> postActivationFeatures = {
    'patternDetection',
    'advancedAnalytics',
    'habitEdit',
  };
  
  /// Features that should always be visible
  static const Set<String> coreFeatures = {
    'today',
    'dashboard',
    'settings',
    'history',
  };
  
  /// Check if a feature should be visible
  static bool shouldShow({
    required String feature,
    required bool hasCompletedOnboarding,
    required int daysWithData,
  }) {
    // Core features always visible
    if (coreFeatures.contains(feature)) return true;
    
    // Post-onboarding features require completed onboarding
    if (postOnboardingFeatures.contains(feature)) {
      return hasCompletedOnboarding;
    }
    
    // Post-activation features require 7+ days of data
    if (postActivationFeatures.contains(feature)) {
      return hasCompletedOnboarding && daysWithData >= 7;
    }
    
    // Unknown features - show after onboarding
    return hasCompletedOnboarding;
  }
  
  /// Get tooltip for why a feature is hidden
  static String? getHiddenReason(String feature) {
    if (postOnboardingFeatures.contains(feature)) {
      return 'Complete your first habit setup to unlock this feature.';
    }
    if (postActivationFeatures.contains(feature)) {
      return 'Build a few days of habit data to unlock this feature.';
    }
    return null;
  }
}
