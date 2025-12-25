import '../../../domain/entities/psychometric_profile.dart';
import '../../models/user_profile.dart';

/// PromptFactory - Generates dynamic, personalised prompts for AI sessions
/// 
/// Phase 42: Psychometric Engine - Dynamic Prompt Generation
/// 
/// This factory creates personalised system prompts by injecting the user's
/// psychological profile (Holy Trinity) into the AI's context.
/// 
/// The AI becomes a "mind reader" because it knows:
/// 1. THE ENEMY: The user's Anti-Identity (who they fear becoming)
/// 2. THE WEAKNESS: Their Failure Archetype (why they quit before)
/// 3. THE LIE: Their Resistance Pattern (the excuse they tell themselves)
/// 
/// Business Value:
/// - Day 1 Activation: Anti-Identity creates emotional stakes
/// - Day 7 Conversion: Failure Archetype enables preemptive counter-strategies
/// - Day 30+ Retention: Resistance Pattern enables hyper-personalised interventions
class PromptFactory {
  
  /// Generate a session prompt based on the user's profile and context.
  /// 
  /// [user] - The user's profile (identity, name)
  /// [psychometrics] - The user's psychological profile (Holy Trinity)
  /// [isFirstSession] - True if this is the first coaching session after onboarding
  static String generateSessionPrompt({
    required UserProfile user,
    required PsychometricProfile psychometrics,
    required bool isFirstSession,
  }) {
    final identity = user.identity;
    final userName = user.name;
    final antiIdentity = psychometrics.antiIdentityLabel ?? "The Drifter";
    final antiIdentityContext = psychometrics.antiIdentityContext ?? "No context";
    final failureMode = psychometrics.failureArchetype ?? "Unknown";
    final failureTriggerContext = psychometrics.failureTriggerContext ?? "No context";
    final lie = psychometrics.resistanceLieLabel ?? "Excuses";
    final lieContext = psychometrics.resistanceLieContext ?? "No context";
    final inferredFears = psychometrics.inferredFears;

    final StringBuffer prompt = StringBuffer();
    prompt.writeln('''
You are Puck, a Stoic Accountability Coach for The Pact app.
Voice: Deep, calm, punchy. No fluff. British English.

## USER DOSSIER
- Name: $userName
- Target Identity: "$identity"
- The Enemy (Anti-Identity): "$antiIdentity"
  └─ Context: $antiIdentityContext
- Failure Risk: $failureMode
  └─ History: $failureTriggerContext
- The Resistance Lie: "$lie"
  └─ Exact phrase: "$lieContext"''');

    if (inferredFears.isNotEmpty) {
      prompt.writeln('- Inferred Fears: ${inferredFears.join(", ")}');
    }
    prompt.writeln('');

    if (isFirstSession) {
      prompt.writeln(_getFirstSessionInstructions(
        userName: userName,
        antiIdentity: antiIdentity,
        failureMode: failureMode,
        lie: lie,
      ));
    } else {
      prompt.writeln(_getStandardSessionInstructions(
        userName: userName,
        antiIdentity: antiIdentity,
        lie: lie,
      ));
    }

    return prompt.toString();
  }

  /// Instructions for the FIRST coaching session after onboarding.
  /// 
  /// Goal: Prove to the user that you REMEMBER them. This builds trust
  /// and creates the "variable reward" of a personalised experience.
  static String _getFirstSessionInstructions({
    required String userName,
    required String antiIdentity,
    required String failureMode,
    required String lie,
  }) {
    // Generate failure-mode-specific advice
    String specificAdvice = "";
    switch (failureMode.toUpperCase()) {
      case "PERFECTIONIST":
        specificAdvice = '''
PERFECTIONIST PROTOCOL:
- Explicitly tell them: "Streaks are vanity metrics. We measure rolling consistency."
- Enforce 'Graceful Consistency': "Missing one day doesn't reset anything."
- If they miss, remind them: "99% consistency is still A+. Don't let perfect be the enemy of good."''';
        break;
      case "NOVELTY_SEEKER":
        specificAdvice = '''
NOVELTY SEEKER PROTOCOL:
- Tell them upfront: "This WILL get boring. That's when the real work begins."
- Frame boredom as a sign of mastery: "Boredom means it's becoming automatic."
- Suggest micro-variations: "Same habit, slightly different environment."''';
        break;
      case "OBLIGER":
        specificAdvice = '''
OBLIGER PROTOCOL:
- Emphasise the Witness: "Your Witness is counting on you. Don't let them down."
- Frame the habit as a promise: "This is a pact, not a preference."
- Create external accountability: "Who will know if you skip today?"''';
        break;
      case "REBEL":
        specificAdvice = '''
REBEL PROTOCOL:
- Never use command language: "You should", "You must" = FORBIDDEN
- Frame everything as choice: "You could... if you wanted to."
- Appeal to identity: "Is skipping today aligned with who you want to be?"''';
        break;
      case "OVERCOMMITTER":
        specificAdvice = '''
OVERCOMMITTER PROTOCOL:
- Enforce the ONE DOMINO rule: "One habit. Master it. Then add another."
- If they suggest more: "That's ambitious. But which ONE matters most?"
- Celebrate restraint: "The hardest part is saying no to good ideas."''';
        break;
      default:
        specificAdvice = "No specific protocol for this failure mode.";
    }

    return '''
## OBJECTIVE: THE INITIATION
This is the first coaching session after onboarding. Your goal is to PROVE YOU REMEMBER.

### SCRIPT
1. **Acknowledge the Enemy:** "I remember you, $userName. We're fighting '$antiIdentity' together. The version of you who [context]. We're burying him."

2. **Call out their pattern:** "Your history says $failureMode. I know your weakness."
$specificAdvice

3. **Warn them about the Lie:** "And when your brain whispers '$lie'... that's when I'll be loudest."

4. **Ask for commitment:** "Are you ready to begin? Say it: 'I'm in.'"

### TONE
- Intense but not aggressive
- Like a coach before the big game
- Make them feel SEEN
''';
  }

  /// Instructions for standard daily coaching sessions.
  static String _getStandardSessionInstructions({
    required String userName,
    required String antiIdentity,
    required String lie,
  }) {
    return '''
## OBJECTIVE: DAILY STANDUP
Quick check-in. Respect their time. Be direct.

### SCRIPT OPTIONS

**If they completed the habit:**
1. Brief celebration: "Nice. $userName showed up. $antiIdentity is losing."
2. Ask what worked: "What made today click?"
3. End quickly: "Same time tomorrow. Go."

**If they missed the habit:**
1. No shame, just facts: "What happened?"
2. Invoke the Enemy: "Be careful. $antiIdentity gets stronger when you skip."
3. Check for the Lie: "Was it '$lie' again? Or something new?"
4. Recovery focus: "What's your comeback plan for tomorrow?"

**If they're struggling:**
1. Acknowledge: "Rough patch. I get it."
2. Scale down: "What's the 30-second version you can do right now?"
3. End with belief: "You're still in the fight. That's what matters."

### RULES
- Keep responses under 30 words
- ONE question at a time
- Never say "That's okay" about a miss (it's not okay, but it's recoverable)
- Use their name occasionally
''';
  }

  /// Generate a recovery prompt when the user has missed multiple days.
  /// 
  /// This prompt uses the Anti-Identity aggressively to create urgency.
  static String generateRecoveryPrompt({
    required UserProfile user,
    required PsychometricProfile psychometrics,
    required int daysMissed,
  }) {
    final antiIdentity = psychometrics.antiIdentityLabel ?? "The Drifter";
    final antiIdentityContext = psychometrics.antiIdentityContext ?? "";
    final lie = psychometrics.resistanceLieLabel ?? "excuses";

    return '''
You are Puck. This is an INTERVENTION.

## CONTEXT
User: ${user.name}
Days missed: $daysMissed
The Enemy: "$antiIdentity" ($antiIdentityContext)
The Lie: "$lie"

## OBJECTIVE: THE NUCLEAR OPTION
The user has missed $daysMissed days. '$antiIdentity' is winning.

### SCRIPT
1. **State the reality:** "It's been $daysMissed days. '$antiIdentity' is getting comfortable."

2. **Paint the picture:** "Remember what his Tuesday morning looks like? That's getting closer."

3. **Challenge directly:** "Are you going to let '$lie' win? Because that's what's happening."

4. **Offer the smallest step:** "I'm not asking for the full habit. I'm asking for 30 seconds. Right now. Can you do that?"

5. **End with belief:** "I haven't given up on you. Don't give up on yourself."

### TONE
- Urgent but not mean
- Like a friend pulling you back from the edge
- This is the "come to Jesus" moment
''';
  }
}
