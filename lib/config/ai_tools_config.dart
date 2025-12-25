/// AI Tools Configuration for The Pact
/// 
/// Phase 42: Psychometric Engine - Real-time Tool Use
/// 
/// This file defines the function declarations (tools) that the Gemini Live API
/// can call during a voice session. Tools enable the AI to "save" data in real-time
/// without breaking the conversation flow.
/// 
/// Architecture:
/// 1. AI speaks and listens via WebSocket
/// 2. When AI decides to save data, it emits a `tool_call` event
/// 3. VoiceSessionManager intercepts the event and routes to PsychometricProvider
/// 4. Provider saves to Hive immediately (crash recovery per Margaret Hamilton)
/// 5. VoiceSessionManager sends `tool_response` back to AI
/// 6. AI continues the conversation
/// 
/// Reference: https://ai.google.dev/gemini-api/docs/function-calling
class AiToolsConfig {
  /// The function name used by the psychometric tool
  static const String psychometricToolName = 'update_user_psychometrics';
  
  /// The tool definition for the "Soul Capture" onboarding session.
  /// 
  /// This tool allows the AI to save psychological traits as they are
  /// confirmed during the Sherlock Protocol conversation.
  /// 
  /// IMPORTANT: Call this tool IMMEDIATELY when a trait is confirmed.
  /// Do not batch saves. Each trait should be saved independently for
  /// crash recovery (per Margaret Hamilton's recommendation).
  static const Map<String, dynamic> psychometricTool = {
    "functionDeclarations": [
      {
        "name": "update_user_psychometrics",
        "description": """Call this tool IMMEDIATELY after confirming a specific psychological trait with the user. 
You can call this multiple times during the conversation as you discover new traits.
Each call should include only the fields you are saving (partial updates are supported).

WHEN TO CALL:
- After user confirms their Anti-Identity name (e.g., "The Sleepwalker")
- After diagnosing their Failure Archetype (e.g., "PERFECTIONIST")
- After identifying their Resistance Lie (e.g., "The Bargain")

DO NOT WAIT until the end of the conversation. Save each trait as soon as it is confirmed.""",
        "parameters": {
          "type": "object",
          "properties": {
            // === TRAIT 1: ANTI-IDENTITY (Fear) ===
            "anti_identity_label": {
              "type": "string",
              "description": "The specific archetype name agreed upon for their failed self. Examples: 'The Sleepwalker', 'The Ghost', 'The Zombie', 'The Drifter'. Must be a vivid, memorable nickname."
            },
            "anti_identity_context": {
              "type": "string",
              "description": "A brief summary of the user's description of their 'hell' - what their failed self's life looks like. Example: 'Hits snooze 5 times, hates the mirror, always tired'."
            },
            
            // === TRAIT 2: FAILURE ARCHETYPE (History) ===
            "failure_archetype": {
              "type": "string",
              "enum": ["PERFECTIONIST", "NOVELTY_SEEKER", "OBLIGER", "REBEL", "OVERCOMMITTER"],
              "description": """The diagnosed reason for their past failures:
- PERFECTIONIST: Quits after a single miss because 99% feels like failure
- NOVELTY_SEEKER: Gets bored once the habit loses its novelty
- OBLIGER: Only keeps habits when others are counting on them
- REBEL: Resists anything that feels like an obligation
- OVERCOMMITTER: Takes on too many habits and burns out"""
            },
            "failure_trigger_context": {
              "type": "string",
              "description": "The specific story of their last failure - what happened on the day the habit died. Example: 'Missed 3 days on vacation, felt too guilty to start again'."
            },
            
            // === TRAIT 3: RESISTANCE PATTERN (The Lie) ===
            "resistance_lie_label": {
              "type": "string",
              "description": "The name of the excuse they use to procrastinate. Examples: 'The Bargain' (I'll do double tomorrow), 'The Tomorrow Trap' (I'll start fresh Monday), 'The Fatigue Excuse' (I'm too tired)."
            },
            "resistance_lie_context": {
              "type": "string",
              "description": "The EXACT phrase their brain whispers when they want to skip. Example: 'I'll just do double tomorrow to make up for it'."
            },
            
            // === INFERRED DATA ===
            "inferred_fears": {
              "type": "array",
              "items": {"type": "string"},
              "description": "Psychological fears you detected from their descriptions. Examples: ['Physical Shame', 'Career Regret', 'Relationship Loss', 'Financial Ruin']. Maximum 3 fears."
            }
          },
          "required": []  // All fields optional for partial updates
        }
      }
    ]
  };
  
  /// Tool definitions for coaching sessions (post-onboarding)
  /// 
  /// These tools allow the AI to record user feedback and adjust
  /// the coaching approach in real-time.
  static const Map<String, dynamic> coachingTools = {
    "functionDeclarations": [
      {
        "name": "record_session_feedback",
        "description": "Record the user's response to coaching. Call when you detect strong positive or negative reactions to your approach.",
        "parameters": {
          "type": "object",
          "properties": {
            "coaching_effective": {
              "type": "boolean",
              "description": "True if the user responded positively to the coaching style"
            },
            "user_sentiment": {
              "type": "string",
              "enum": ["motivated", "resistant", "neutral", "frustrated", "inspired"],
              "description": "The user's emotional state during the session"
            },
            "adjust_style": {
              "type": "string",
              "enum": ["more_direct", "more_supportive", "more_analytical", "keep_same"],
              "description": "Recommended adjustment for future sessions"
            }
          },
          "required": ["coaching_effective"]
        }
      }
    ]
  };
}
