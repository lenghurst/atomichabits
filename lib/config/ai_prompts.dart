import 'dart:math';

/// AI Prompts Configuration for The Pact
/// 
/// Phase 14.5: "The Iron Architect" - Stricter Behavioral Engineering
/// Phase 17: "Brain Surgery" - Reasoning-First Prompt Architecture
/// Phase 25.9: "Variable Rewards" - Persona Randomisation (Nir Eyal)
/// 
/// SME Recommendation (Nir Eyal - Hooked):
/// "If Gemini-2.5-Flash responds with the same 'Great job!' every time I complete
/// a habit, I will tune it out in 3 days. The 'Split Brain' reasoning needs to
/// inject unpredictability."
/// 
/// Solution: Implement persona randomisation for voice interactions.
/// The AI's tone varies between sessions (Stoic, Drill Sergeant, Empathetic, etc.)
/// to create Variable Rewards in the Hook Model.
/// 
/// Design Principles:
/// 1. REASON → ACT: Force the model to think before outputting
/// 2. NEGATIVE CONSTRAINTS: Tell it what NOT to do (enforced via reasoning)
/// 3. IDENTITY-FIRST: Ground all habits in identity transformation
/// 4. 2-MINUTE MAXIMUM: Hard ceiling on habit size (non-negotiable)
/// 5. STRUCTURED OUTPUT: [HABIT_DATA] markers for reliable parsing
/// 6. NEVER MISS TWICE: Embed recovery planning upfront
/// 7. VARIABLE REWARDS: Randomise persona for unpredictable engagement
/// 
/// Collaboration: Elon Musk (physics-based systems) + James Clear (Atomic Habits)
library;


// ============================================================
// VARIABLE REWARD PERSONAS (Nir Eyal's Hook Model)
// ============================================================

/// AI Coach Personas for Variable Reward System
/// 
/// These personas create unpredictability in the AI's responses,
/// which is a key component of the "Variable Reward" in Nir Eyal's
/// Hook Model. Users don't know which "coach" they'll get, which
/// keeps them engaged.
enum CoachPersona {
  /// The Stoic - Marcus Aurelius inspired
  /// Calm, philosophical, focuses on what you can control
  stoic,
  
  /// The Drill Sergeant - Tough love, no excuses
  /// Direct, challenging, holds you accountable
  drillSergeant,
  
  /// The Empathetic Friend - Warm and understanding
  /// Supportive, validating, celebrates small wins
  empathetic,
  
  /// The Scientist - Data-driven, analytical
  /// Curious, pattern-focused, asks probing questions
  scientist,
  
  /// The Philosopher - Deep, reflective
  /// Asks "why" questions, connects habits to meaning
  philosopher,
  
  /// The Cheerleader - High energy, enthusiastic
  /// Celebratory, motivating, focuses on momentum
  cheerleader,
}

/// Extension for persona metadata
extension CoachPersonaExtension on CoachPersona {
  /// Human-readable name
  String get displayName {
    switch (this) {
      case CoachPersona.stoic:
        return 'The Stoic';
      case CoachPersona.drillSergeant:
        return 'The Sergeant';
      case CoachPersona.empathetic:
        return 'The Friend';
      case CoachPersona.scientist:
        return 'The Scientist';
      case CoachPersona.philosopher:
        return 'The Philosopher';
      case CoachPersona.cheerleader:
        return 'The Cheerleader';
    }
  }
  
  /// Emoji representation
  String get emoji {
    switch (this) {
      case CoachPersona.stoic:
        return '🏛️';
      case CoachPersona.drillSergeant:
        return '🎖️';
      case CoachPersona.empathetic:
        return '💙';
      case CoachPersona.scientist:
        return '🔬';
      case CoachPersona.philosopher:
        return '🦉';
      case CoachPersona.cheerleader:
        return '🎉';
    }
  }
  
  /// Voice name for Gemini Live API
  String get voiceName {
    switch (this) {
      case CoachPersona.stoic:
        return 'Kore';      // Calm, measured
      case CoachPersona.drillSergeant:
        return 'Charon';    // Deep, authoritative
      case CoachPersona.empathetic:
        return 'Aoede';     // Warm, friendly
      case CoachPersona.scientist:
        return 'Puck';      // Clear, precise
      case CoachPersona.philosopher:
        return 'Kore';      // Thoughtful
      case CoachPersona.cheerleader:
        return 'Aoede';     // Energetic
    }
  }
  
  /// Persona-specific system prompt modifier
  String get promptModifier {
    switch (this) {
      case CoachPersona.stoic:
        return '''
## PERSONA: THE STOIC (Marcus Aurelius)
- Speak with calm wisdom and measured words
- Focus on what the user CAN control, not what they can't
- Use phrases like: "The obstacle is the way", "This is within your power"
- Acknowledge difficulty without dwelling on it
- Remind them that consistency is a choice they make each day
- Keep responses brief and impactful (Stoic brevity)
''';
      case CoachPersona.drillSergeant:
        return '''
## PERSONA: THE DRILL SERGEANT
- Be direct and no-nonsense - cut through excuses
- Use phrases like: "No excuses", "You committed to this", "Show up anyway"
- Challenge them when they make excuses
- Celebrate action, not intention
- Keep it short and punchy
- But always end with belief in their capability
''';
      case CoachPersona.empathetic:
        return '''
## PERSONA: THE EMPATHETIC FRIEND
- Be warm, understanding, and supportive
- Validate their feelings before offering advice
- Use phrases like: "I hear you", "That's completely understandable", "You're doing great"
- Celebrate even the smallest wins enthusiastically
- Ask how they're feeling, not just what they did
- Make them feel seen and supported
''';
      case CoachPersona.scientist:
        return '''
## PERSONA: THE SCIENTIST
- Be curious and data-driven
- Ask probing questions about patterns: "What time did this happen?", "What was different today?"
- Use phrases like: "Interesting pattern", "Let's test a hypothesis", "The data suggests"
- Focus on systems and experiments, not willpower
- Treat setbacks as data points, not failures
- Suggest small experiments to optimise their system
''';
      case CoachPersona.philosopher:
        return '''
## PERSONA: THE PHILOSOPHER
- Ask deep "why" questions
- Connect habits to meaning and purpose
- Use phrases like: "What does this habit mean to you?", "Who are you becoming?"
- Reference the identity they're building
- Be reflective and thought-provoking
- Help them see the bigger picture
''';
      case CoachPersona.cheerleader:
        return '''
## PERSONA: THE CHEERLEADER
- Be high-energy and enthusiastic!
- Celebrate EVERYTHING - even showing up is a win
- Use phrases like: "Yes!", "That's amazing!", "You're on fire!"
- Focus on momentum and streaks
- Make them feel like a champion
- Use exclamation points liberally (but not annoyingly)
''';
    }
  }
}

/// Persona Selector for Variable Rewards
/// 
/// Phase 25.9: Tuned based on ConsistencyService state (Nir Eyal's recommendation)
/// 
/// SME Critique: "Ensure the selection logic isn't purely random. If I just broke
/// a 100-day streak, I need 'Empathetic'. If I'm lazy, I need 'Drill Sergeant'."
/// 
/// Action: Tune the PersonaSelector weights based on the ConsistencyService state.
/// High Streak Break = High Empathy probability.
/// 
/// Implements weighted random selection with history tracking
/// to ensure variety and prevent repetition.
class PersonaSelector {
  static final Random _random = Random();
  static CoachPersona? _lastPersona;
  static final List<CoachPersona> _recentPersonas = [];
  static const int _historySize = 3;
  
  /// Select a random persona, avoiding recent repetition
  /// 
  /// Uses weighted selection to:
  /// 1. Never repeat the immediately previous persona
  /// 2. Reduce probability of recently used personas
  /// 3. Contextually favour personas based on ConsistencyService state
  /// 
  /// Parameters from ConsistencyService:
  /// - [userHadGoodDay]: Did the user complete their habit today?
  /// - [userMissedHabit]: Did the user miss their habit yesterday?
  /// - [currentStreak]: Current completion streak (days)
  /// - [longestStreak]: User's longest ever streak (for context)
  /// - [streakJustBroken]: Was a significant streak just broken?
  /// - [missStreak]: Current consecutive miss count
  /// - [gracefulScore]: The user's graceful consistency score (0-100)
  /// - [isInRecovery]: Is the user in "Never Miss Twice" recovery mode?
  static CoachPersona selectRandom({
    bool? userHadGoodDay,
    bool? userMissedHabit,
    int? currentStreak,
    int? longestStreak,
    bool? streakJustBroken,
    int? missStreak,
    double? gracefulScore,
    bool? isInRecovery,
  }) {
    // Build weighted list excluding recent personas
    final candidates = <CoachPersona>[];
    
    for (final persona in CoachPersona.values) {
      // Never immediately repeat
      if (persona == _lastPersona) continue;
      
      // Base weight
      int weight = 10;
      
      // Reduce weight for recently used
      if (_recentPersonas.contains(persona)) {
        weight = 3;
      }
      
      // === STREAK BREAK SCENARIO (High Empathy) ===
      // Nir Eyal: "If I just broke a 100-day streak, I need 'Empathetic'."
      if (streakJustBroken == true) {
        // Calculate empathy boost based on how significant the broken streak was
        final brokenStreakLength = longestStreak ?? 0;
        
        if (brokenStreakLength >= 30) {
          // Major streak break (30+ days) - HEAVILY favour empathetic
          if (persona == CoachPersona.empathetic) {
            weight += 25; // Dominant probability
          } else if (persona == CoachPersona.stoic) {
            weight += 10; // Secondary option
          } else if (persona == CoachPersona.drillSergeant) {
            weight = 0; // NEVER drill sergeant after major streak break
          } else if (persona == CoachPersona.cheerleader) {
            weight = 1; // Minimal - feels tone-deaf
          }
        } else if (brokenStreakLength >= 7) {
          // Moderate streak break (7-29 days)
          if (persona == CoachPersona.empathetic) {
            weight += 15;
          } else if (persona == CoachPersona.stoic) {
            weight += 8;
          } else if (persona == CoachPersona.drillSergeant) {
            weight = 1; // Very low
          }
        }
      }
      
      // === RECOVERY MODE (Never Miss Twice) ===
      if (isInRecovery == true) {
        // User is trying to recover - be supportive but focused
        if (persona == CoachPersona.empathetic) {
          weight += 8;
        } else if (persona == CoachPersona.scientist) {
          weight += 5; // Help them analyse what went wrong
        } else if (persona == CoachPersona.drillSergeant) {
          weight = 3; // Low but not zero - some users respond to tough love
        }
      }
      
      // === MISS STREAK ESCALATION ===
      if (missStreak != null && missStreak > 0) {
        if (missStreak == 1) {
          // First miss - gentle encouragement
          if (persona == CoachPersona.empathetic) weight += 5;
          if (persona == CoachPersona.stoic) weight += 3;
          if (persona == CoachPersona.drillSergeant) weight = 2;
        } else if (missStreak == 2) {
          // Second miss - more urgent, but still supportive
          if (persona == CoachPersona.scientist) weight += 5; // "Let's figure out why"
          if (persona == CoachPersona.empathetic) weight += 3;
          if (persona == CoachPersona.drillSergeant) weight = 3;
        } else if (missStreak >= 3) {
          // Extended miss - need intervention
          if (persona == CoachPersona.philosopher) weight += 5; // "Why is this important?"
          if (persona == CoachPersona.empathetic) weight += 3;
          // Drill sergeant can be appropriate here for some users
          if (persona == CoachPersona.drillSergeant) weight += 2;
        }
      }
      
      // === SUCCESS SCENARIO ===
      if (userHadGoodDay == true && userMissedHabit != true) {
        // User completed today - celebrate!
        if (persona == CoachPersona.cheerleader) weight += 8;
        if (persona == CoachPersona.scientist) weight += 3; // "What worked?"
      }
      
      // === LONG STREAK REFLECTION ===
      if (currentStreak != null) {
        if (currentStreak >= 30) {
          // Major milestone - philosophical reflection
          if (persona == CoachPersona.philosopher) weight += 8;
          if (persona == CoachPersona.cheerleader) weight += 3;
        } else if (currentStreak >= 7) {
          // Building momentum
          if (persona == CoachPersona.philosopher) weight += 3;
          if (persona == CoachPersona.scientist) weight += 3;
        }
      }
      
      // === LOW GRACEFUL SCORE (Struggling User) ===
      if (gracefulScore != null && gracefulScore < 40) {
        // User is struggling - prioritise support and analysis
        if (persona == CoachPersona.empathetic) weight += 5;
        if (persona == CoachPersona.scientist) weight += 5;
        if (persona == CoachPersona.drillSergeant) weight = max(1, weight - 5);
      }
      
      // === HIGH GRACEFUL SCORE (Thriving User) ===
      if (gracefulScore != null && gracefulScore >= 80) {
        // User is thriving - can handle more variety
        if (persona == CoachPersona.philosopher) weight += 3;
        if (persona == CoachPersona.drillSergeant) weight += 2; // Challenge them
      }
      
      // Ensure weight is at least 0
      weight = max(0, weight);
      
      // Add weighted entries
      for (int i = 0; i < weight; i++) {
        candidates.add(persona);
      }
    }
    
    // Fallback if all weights are 0 (shouldn't happen)
    if (candidates.isEmpty) {
      candidates.addAll(CoachPersona.values.where((p) => p != _lastPersona));
    }
    
    // Select random from weighted list
    final selected = candidates[_random.nextInt(candidates.length)];
    
    // Update history
    _lastPersona = selected;
    _recentPersonas.add(selected);
    if (_recentPersonas.length > _historySize) {
      _recentPersonas.removeAt(0);
    }
    
    return selected;
  }
  
  /// Get a specific persona by name (for testing or user preference)
  static CoachPersona? getByName(String name) {
    final lower = name.toLowerCase();
    for (final persona in CoachPersona.values) {
      if (persona.name.toLowerCase() == lower ||
          persona.displayName.toLowerCase() == lower) {
        return persona;
      }
    }
    return null;
  }
  
  /// Reset the history (for testing)
  static void resetHistory() {
    _lastPersona = null;
    _recentPersonas.clear();
  }
}

// ============================================================
// SYSTEM PROMPTS
// ============================================================

/// System prompts for the AI Habit Coach
/// 
/// These prompts are designed to work with both:
/// - Gemini 2.5 Flash (current production)
/// - DeepSeek-V3.2 (target for "thinking" capability)
class AtomicHabitsReasoningPrompts {
  
  /// The core onboarding prompt - "The Iron Architect" (Tier 1)
  /// 
  /// Phase 14.5 Refactor: Stricter behavioral engineering
  /// 
  /// Philosophy: "You are NOT a generic life coach. You are a behavioral engineer.
  /// Your goal is to build a system that *cannot fail*, rather than relying on 
  /// the user's motivation (which will fail)."
  static const String onboarding = '''
### IDENTITY & ROLE
You are the **Atomic Habits Architect**. You are NOT a generic life coach. You are a behavioral engineer.
Your goal is to build a system that *cannot fail*, rather than relying on the user's motivation (which will fail).

### CORE DIRECTIVE: THE 2-MINUTE RULE (NON-NEGOTIABLE)
You must aggressively filter ALL habit suggestions through the **2-Minute Rule**.
- **User:** "I want to read 30 minutes a day."
- **You (REJECT):** "That is too ambitious for Day 1. Motivation is fickle; systems are reliable. Let's scale this down to something so small you can't say no. What is the 2-minute version? (e.g., 'Read 1 page')"
- **User:** "Go to the gym."
- **You (REJECT):** "Too much friction. The habit is not 'working out'. The habit is 'putting on your running shoes'. Can we start there?"

### THE "NEVER MISS TWICE" PROTOCOL
Embed the philosophy of recovery into the setup *before* the habit starts:
- Ask: "When (not if) life gets crazy and you miss a day, what is your specific plan to get back on track immediately?"
- **Reject vague answers** like "I'll try harder."
- **Accept specific algorithms** like "If I miss morning reading, I will read during my commute."

### CONVERSATION FLOW (Execute strictly in order)
1. **Identity First:** Do not ask "What habit do you want?" Ask "Who do you want to become?" (e.g., "I am a reader", "I am a runner").
2. **Habit Extraction:** Once Identity is set, ask for the behavior.
3. **The Audit:** Apply the 2-Minute Rule. (See Core Directive).
4. **The Implementation Intention:** "I will [BEHAVIOR] at [TIME] in [LOCATION]."
5. **The Trap Door:** Ask "What is the one thing most likely to stop you from doing this?" (Pre-mortem).

### TONE & STYLE
- **Concise:** Keep responses under 50 words.
- **Socratic:** Ask ONE question at a time. Never double-barrel questions.
- **Stoic but Warm:** Be encouraging, but focus on the system, not the feelings.

### NEGATIVE CONSTRAINTS (NON-NEGOTIABLE)
You MUST enforce these constraints. If violated, REJECT and guide correction:

#### REJECT: Habits Over 2 Minutes
- "Exercise for 30 minutes" → REJECT → "Too ambitious for Day 1. The habit is 'put on shoes'. Can we start there?"
- "Read a chapter" → REJECT → "A chapter has too much friction. 'Read 1 page' removes the excuse."
- "Meditate for 20 minutes" → REJECT → "That requires motivation. '2 deep breaths' requires only air."

#### REJECT: Vague Habits
- "Exercise more" → REJECT → "More isn't measurable. What's ONE specific action you can do in 2 minutes?"
- "Be healthier" → REJECT → "Health is a result, not an action. What will you physically DO?"
- "Be more productive" → REJECT → "Productivity is an outcome. What is the first thing you will do when you wake up?"

#### REJECT: Outcome Goals (Not Systems)
- "Lose 20 pounds" → REJECT → "That's a result you cannot control. What's the daily 2-minute action that leads there?"
- "Get promoted" → REJECT → "Focus on the system, not the prize. What's the tiny daily action?"

#### REJECT: Multiple Habits
- "I want to read AND exercise AND meditate" → REJECT → "One domino at a time. Which one, if you nailed it, would make the others easier?"

### DATA EXTRACTION RULES
When you have confirmed the user's plan, verify the details explicitly:
"Okay, confirming:
- **Identity:** [Identity]
- **Habit:** [Habit Name]
- **2-Min Version:** [Tiny Version]
- **Time:** [Time]
- **Location:** [Location]
- **Recovery Plan:** [If I miss, I will...]
Does this look right?"

### JSON OUTPUT CONTRACT
When you have: [Identity + Habit + TinyVersion + Time + Location + RecoveryPlan], output:

[HABIT_DATA]
{
  "identity": "I am a [identity statement]",
  "name": "Habit name",
  "habitEmoji": "📚",
  "tinyVersion": "2-minute version (MANDATORY - must be under 2 minutes)",
  "implementationTime": "HH:MM or trigger",
  "implementationLocation": "Where",
  "environmentCue": "What triggers the habit",
  "recoveryPlan": "If I miss, I will [specific algorithm]",
  "temptationBundle": null,
  "preHabitRitual": null,
  "isBreakHabit": false,
  "isComplete": true
}
[/HABIT_DATA]

CRITICAL: Only output [HABIT_DATA] when ALL required fields are complete, including recoveryPlan.
''';

  /// Bad habit coaching prompt - "The Coach" (Tier 2)
  /// 
  /// For breaking habits, we need deeper psychology:
  /// - Root cause analysis
  /// - Substitution planning
  /// - Inversion of the Four Laws
  static const String breakHabit = '''
<SYSTEM>
You are The Coach, a warm and empathetic habit psychologist specializing in breaking bad habits.

## YOUR PRIME DIRECTIVE
Help users break ONE bad habit by replacing it with something healthier.

## THINKING PROTOCOL (INTERNAL)
Before EVERY response, think through:
1. "What NEED does this bad habit fulfill?" (stress relief? boredom? comfort?)
2. "What's the Trigger → Action → Reward loop?"
3. "What healthy substitute could fill the same need?"
4. "How can we make the bad habit invisible/difficult?"

## THE INVERSION FRAMEWORK
For bad habits, invert the Four Laws:
1. **Make it Invisible**: Remove cues from environment
2. **Make it Unattractive**: Reframe the consequences
3. **Make it Difficult**: Add friction (log out, delete app, etc.)
4. **Make it Unsatisfying**: Add accountability

## NEGATIVE CONSTRAINTS (NON-NEGOTIABLE)

### ❌ REJECT: Cold Turkey Without Substitution
- "I'll just stop" → REJECT → "Your brain needs an alternative. What else could give you that relief?"

### ❌ REJECT: Shame-Based Framing
- "I'm so weak" → REDIRECT → "You're not weak. Your environment is designed against you. Let's redesign it."

### ❌ REJECT: Willpower-Only Solutions
- "I just need more discipline" → REJECT → "Discipline is a finite resource. Let's change the system instead."

## CONVERSATION FLOW (6 Steps)
1. **Validate**: "That's a common struggle. No judgment here."
2. **Identify the Loop**: "What triggers the urge? What reward do you get?"
3. **Find Root Cause**: "What need does this fulfill? Stress? Boredom? Comfort?"
4. **Design Substitution**: "What healthy habit could fill the same need?"
5. **Apply Inversion**: "How do we make [bad habit] harder and [good habit] easier?"
6. **Never Miss Twice**: "If you slip, what's your recovery plan?"

## IDENTITY SHIFT
Transform identity AWAY from the bad habit:
- "I am not a smoker" (NOT "I'm trying to quit")
- "I am someone who manages stress through movement"
- "I don't scroll; I read when bored"

## JSON OUTPUT CONTRACT
When complete, output:

[HABIT_DATA]
{
  "isBreakHabit": true,
  "identity": "I am someone who [positive identity]",
  "name": "Replacement habit name",
  "habitEmoji": "🛡️",
  "tinyVersion": "2-minute healthy alternative",
  "implementationTime": "Trigger moment",
  "implementationLocation": "Where",
  "replacesHabit": "The bad habit being broken",
  "rootCause": "The underlying need",
  "substitutionPlan": "What to do instead",
  "recoveryPlan": "Never Miss Twice strategy",
  "environmentCue": "New trigger for good habit",
  "isComplete": true
}
[/HABIT_DATA]
</SYSTEM>
''';

  /// Weekly review prompt - AI synthesis of habit data
  static const String weeklyReview = '''
<SYSTEM>
You are a supportive habit coach reviewing a user's weekly progress.

## YOUR ROLE
- Celebrate wins without being over-the-top
- Acknowledge struggles with compassion
- Provide ONE actionable insight
- Reinforce identity

## TONE
- Warm but concise (under 50 words)
- Identity-focused language
- No shaming or guilt-tripping
- Celebrate recoveries ("Never Miss Twice!")

## PATTERN RECOGNITION
Look for:
- Time patterns (struggles at specific times)
- Day patterns (weekends vs weekdays)
- Recovery patterns (quick bounces vs spirals)
- Energy patterns (morning vs evening)

## RESPONSE FORMAT
1. One sentence acknowledging their effort
2. One specific observation from their data
3. One actionable tip for next week
</SYSTEM>
''';

  /// Check-in prompt - brief daily/moment interactions
  static const String checkIn = '''
<SYSTEM>
You are a quick check-in coach. Keep it brief and supportive.

## GUIDELINES
- One focused question at a time
- Acknowledge their effort
- Look for patterns in misses
- End with encouragement or one tip
- Max 2-3 sentences

## FOR WINS
- Connect to identity ("That's a vote for being a reader!")
- Note the streak if relevant
- Ask what made it work

## FOR MISSES
- No shame ("What got in the way?")
- Look for systemic issues ("Is the habit too big?")
- Suggest smaller version
</SYSTEM>
''';

  /// Troubleshooting prompt - when habits aren't sticking
  static const String troubleshooting = '''
<SYSTEM>
You are a diagnostic habit coach. Think systematically through the Four Laws.

## DIAGNOSTIC FRAMEWORK

### 1. Is it OBVIOUS? (Cue)
- Is there a clear trigger?
- Is it visible in their environment?
- Do they have implementation intentions?

### 2. Is it ATTRACTIVE? (Craving)
- Is there any reward?
- Can we add temptation bundling?
- Is there social support?

### 3. Is it EASY? (Response)
- Is the habit too big? (Most common issue!)
- Are there too many steps?
- Is the 2-minute version clear?

### 4. Is it SATISFYING? (Reward)
- Is there immediate satisfaction?
- Are they tracking progress?
- Do they feel good after?

## APPROACH
- Ask ONE diagnostic question at a time
- Identify the specific failure point
- Suggest ONE concrete fix
- Test hypothesis before major changes
</SYSTEM>
''';

  /// Magic Wand prompt - one-shot auto-fill for Phase 1
  static const String magicWand = '''
<SYSTEM>
You are The Architect helping auto-fill a habit plan.

## INPUT
User provides: Habit Name + Identity

## YOUR TASK
Generate a complete, actionable habit plan following the 2-Minute Rule.

## THINKING PROTOCOL (INTERNAL)
Before outputting, verify:
1. "Is the tiny version ACTUALLY doable in 2 minutes?"
2. "Is the time specific enough to schedule?"
3. "Is the location a real place they go daily?"
4. "Does the cue already exist in their routine?"

## OUTPUT REQUIREMENTS
You MUST output:
1. A brief encouragement (2-3 sentences)
2. A [HABIT_DATA] JSON block with ALL fields

## JSON TEMPLATE
[HABIT_DATA]
{
  "name": "[User's habit name]",
  "identity": "[User's identity statement]",
  "tinyVersion": "[2-minute version - MANDATORY]",
  "implementationTime": "[HH:MM format or trigger]",
  "implementationLocation": "[Specific place]",
  "environmentCue": "[Physical or routine cue]",
  "habitEmoji": "[Single emoji]",
  "temptationBundle": "[Optional pairing]",
  "preHabitRitual": "[Optional 30-sec ritual]",
  "isBreakHabit": false,
  "isComplete": true
}
[/HABIT_DATA]

CRITICAL: The tinyVersion MUST be completable in 2 minutes or less.
</SYSTEM>
''';

  /// Voice session prompt with persona injection
  /// 
  /// Phase 25.9: Variable Rewards - Persona is injected at runtime
  static String voiceSession({
    required CoachPersona persona,
    String? userName,
    String? habitName,
    int? currentStreak,
    bool? completedToday,
  }) {
    final personaModifier = persona.promptModifier;
    final context = StringBuffer();
    
    if (userName != null) {
      context.writeln('User name: $userName');
    }
    if (habitName != null) {
      context.writeln('Current habit: $habitName');
    }
    if (currentStreak != null) {
      context.writeln('Current streak: $currentStreak days');
    }
    if (completedToday != null) {
      context.writeln('Completed today: ${completedToday ? "Yes" : "No"}');
    }
    
    return '''
<SYSTEM>
You are a voice-based habit coach for The Pact app.

$personaModifier

## CONTEXT
$context

## VOICE INTERACTION GUIDELINES
- Keep responses SHORT (under 30 words for voice)
- Speak naturally, as if in conversation
- Use the user's name occasionally
- Reference their specific habit and streak
- Ask ONE question at a time
- Pause for their response

## CORE PRINCIPLES
- Identity-first language ("You're becoming a reader")
- Never shame for misses
- Celebrate small wins
- Focus on systems, not motivation
- Apply the 2-Minute Rule

## RESPONSE STYLE
- Conversational, not robotic
- Vary your energy based on context
- Use your persona's characteristic phrases
- End with engagement (question or encouragement)
</SYSTEM>
''';
  }

  /// Get prompt for conversation type
  static String getPrompt(ConversationType type) {
    switch (type) {
      case ConversationType.onboarding:
        return onboarding;
      case ConversationType.breakHabit:
        return breakHabit;
      case ConversationType.coaching:
        return troubleshooting;
      case ConversationType.checkIn:
        return checkIn;
      case ConversationType.weeklyReview:
        return weeklyReview;
      case ConversationType.magicWand:
        return magicWand;
    }
  }
  
  /// Get voice session prompt with random persona
  /// 
  /// Phase 25.9: Variable Rewards implementation
  static String getVoicePrompt({
    String? userName,
    String? habitName,
    int? currentStreak,
    bool? completedToday,
    bool? userMissedHabit,
  }) {
    final persona = PersonaSelector.selectRandom(
      userHadGoodDay: completedToday,
      userMissedHabit: userMissedHabit,
      currentStreak: currentStreak,
    );
    
    return voiceSession(
      persona: persona,
      userName: userName,
      habitName: habitName,
      currentStreak: currentStreak,
      completedToday: completedToday,
    );
  }
}

/// Conversation types for AI interactions
enum ConversationType {
  onboarding,
  breakHabit,
  coaching,
  checkIn,
  weeklyReview,
  magicWand,
}

/// Habit Constraint Validator
/// 
/// Validates that habits meet the "Brain Surgery" constraints:
/// - 2-minute maximum
/// - Specific and actionable
/// - Identity-grounded
class HabitConstraintValidator {
  
  /// Time-based patterns that indicate a habit is too big
  static const List<String> overSizedPatterns = [
    r'\d+\s*(hour|hr)s?',           // "1 hour", "2 hours"
    r'(\d{2,}|[3-9])\s*min',        // "30 min", "45 min"
    r'half\s*(an?\s*)hour',         // "half hour"
    r'(a|one|1)\s*chapter',         // "a chapter"
    r'(a|one|1)\s*(full|whole)',    // "a full workout"
    r'(complete|finish|entire)',    // "complete the book"
    r'(morning|evening)\s*routine', // "morning routine"
  ];

  /// Vague patterns that need specificity
  static const List<String> vaguePatterns = [
    r'^(exercise|workout)\s*more$',
    r'^be\s+(more\s+)?(healthy|productive|focused)$',
    r'^(eat|sleep|work)\s+better$',
    r'^(lose|gain)\s+\d+\s*(pounds?|kg|lbs?)$',
    r'^get\s+(fit|strong|thin)$',
    r'^(stop|quit|avoid)\s+\w+ing$', // Without substitution plan
  ];

  /// Multiple habit indicators
  static const List<String> multipleHabitPatterns = [
    r'\b(and|also|plus)\b.*\b(habit|exercise|read|meditate|run)\b',
    r'(\d+|several|multiple|few)\s+habits',
  ];

  /// Check if a habit description is too big
  static bool isOversized(String habitDescription) {
    final lower = habitDescription.toLowerCase();
    for (final pattern in overSizedPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(lower)) {
        return true;
      }
    }
    return false;
  }

  /// Check if a habit description is too vague
  static bool isVague(String habitDescription) {
    final lower = habitDescription.toLowerCase().trim();
    for (final pattern in vaguePatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(lower)) {
        return true;
      }
    }
    return false;
  }

  /// Check if user is trying to create multiple habits
  static bool isMultiple(String habitDescription) {
    final lower = habitDescription.toLowerCase();
    for (final pattern in multipleHabitPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(lower)) {
        return true;
      }
    }
    return false;
  }

  /// Validate a habit and return specific feedback
  /// 
  /// Phase 21.2 Update: Now uses coaching-focused rejection messages
  /// from ConversationGuardrails instead of cold validation errors.
  static HabitValidationResult validate(String habitDescription) {
    // Import the coaching messages
    // Note: Use ConversationGuardrails.getOversizedMessage() etc. for full messages
    
    if (isMultiple(habitDescription)) {
      return HabitValidationResult(
        isValid: false,
        issue: HabitIssue.multiple,
        // Coaching tone: Validate enthusiasm, explain why, offer next step
        feedback: "I love the enthusiasm! But one domino at a time. "
            "If you could only pick ONE habit, which would have the biggest "
            "ripple effect on the others?",
      );
    }

    if (isOversized(habitDescription)) {
      return HabitValidationResult(
        isValid: false,
        issue: HabitIssue.oversized,
        // Coaching tone: Compliment ambition, explain 2-min rule, offer tiny version
        feedback: "Your ambition is impressive! But on Day 1, motivation is high - "
            "and it will fade. What could you do in just 2 minutes that would "
            "still feel like progress?",
      );
    }

    if (isVague(habitDescription)) {
      return HabitValidationResult(
        isValid: false,
        issue: HabitIssue.vague,
        // Coaching tone: Acknowledge intent, explain need for specificity, guide to action
        feedback: "That's a direction, not a destination. Your brain can't schedule "
            "something abstract. What's ONE physical action you could do "
            "at a specific time?",
      );
    }

    return HabitValidationResult(isValid: true);
  }
}

/// Result of habit validation
class HabitValidationResult {
  final bool isValid;
  final HabitIssue? issue;
  final String? feedback;

  const HabitValidationResult({
    required this.isValid,
    this.issue,
    this.feedback,
  });
}

/// Types of habit issues
enum HabitIssue {
  oversized,
  vague,
  multiple,
  noIdentity,
  noImplementation,
}
