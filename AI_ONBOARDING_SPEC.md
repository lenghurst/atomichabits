# AI_ONBOARDING_SPEC.md

> **Status:** FINAL (v4.0.0)
> **Last Updated:** December 2024
> **Architecture:** Hybrid Tiered (Gemini 2.5 Flash / Claude 4.5 Sonnet / Manual)
> **Philosophy:** "Graceful Consistency > Fragile Streaks"

---

## 1. The Strategy: "Graceful Intelligence"

We use a tiered strategy to balance **Unit Economics** (Cost/Speed) with **Coaching Quality** (EQ/Depth).

| Tier | Model | Role | Trigger Condition |
| :--- | :--- | :--- | :--- |
| **Tier 1 (Default)** | **Gemini 2.5 Flash** | **The Architect** | Free users. Fast extraction. Focus: Structure & 2-Minute Rule. |
| **Tier 2 (Premium)** | **Claude 4.5 Sonnet** | **The Coach** | Premium users OR "Bad Habit" flows. Focus: Psychology & Root Cause. |
| **Tier 3 (Fallback)** | **Manual Input** | **The Safety Net** | Offline, API failure, frustration detected, or user opt-out. |

---

## 2. Data Model & Migration (CRITICAL)

**Gap Resolution:** The `Habit` model in `main` must be updated to support these fields *before* AI integration.

### Required Updates to `lib/data/models/habit.dart`

```dart
class Habit {
  // ... existing fields ...

  // === NEW FIELDS FOR AI ONBOARDING ===
  final bool isBreakHabit;           // default: false
  final String? replacesHabit;       // e.g. "Doomscrolling"
  final String? rootCause;           // e.g. "Boredom/Anxiety"
  final String? substitutionPlan;    // e.g. "5-min stretch"
  final String? habitEmoji;          // e.g. "📚"
  final String? motivation;          // e.g. "To be healthier"
  final String? recoveryPlan;        // Maps to Failure Playbook
}
```

### Unified `OnboardingData` Interface

This DTO maps 1:1 to the updated `Habit` class.

```dart
// lib/data/models/onboarding_data.dart

class OnboardingData {
  // === CORE IDENTITY ===
  final String identity;            // "I am a person who reads daily"
  final String name;                // "Read every day" (Maps to Habit.name)
  final String? habitEmoji;         // "📚"
  
  // === IMPLEMENTATION INTENTION ===
  final String tinyVersion;         // "Read 1 page" (2-Minute Rule)
  final String implementationTime;  // "22:00"
  final String implementationLocation; // "In bed"
  final String? environmentCue;     // "After I brush my teeth"
  
  // === ATOMIC HABITS (Law 2 & 3) ===
  final String? temptationBundle;   // "While drinking herbal tea"
  final String? preHabitRitual;     // "Take 3 deep breaths"
  final String? environmentDistraction; // "Put phone in other room"
  
  // === BREAK HABIT SPECIFIC ===
  final bool isBreakHabit;          // false = build, true = break
  final String? replacesHabit;      // "Doomscrolling"
  final String? rootCause;          // "Boredom/Anxiety"
  final String? substitutionPlan;   // "5-min stretch instead"
  
  // === METADATA ===
  final String? motivation;         // "Expand knowledge"
  final String? recoveryPlan;       // Maps to FailurePlaybook.recoveryAction
  final bool isComplete;            // Ready to save?

  const OnboardingData({
    required this.identity,
    required this.name,
    this.habitEmoji,
    required this.tinyVersion,
    required this.implementationTime,
    required this.implementationLocation,
    this.environmentCue,
    this.temptationBundle,
    this.preHabitRitual,
    this.environmentDistraction,
    this.isBreakHabit = false,
    this.replacesHabit,
    this.rootCause,
    this.substitutionPlan,
    this.motivation,
    this.recoveryPlan,
    this.isComplete = false,
  });

  factory OnboardingData.fromJson(Map<String, dynamic> json) {
    return OnboardingData(
      identity: json['identity'] as String? ?? '',
      name: json['name'] as String? ?? json['habitName'] as String? ?? '',
      habitEmoji: json['habitEmoji'] as String?,
      tinyVersion: json['tinyVersion'] as String? ?? '',
      implementationTime: json['implementationTime'] as String? ?? json['time'] as String? ?? '09:00',
      implementationLocation: json['implementationLocation'] as String? ?? json['location'] as String? ?? '',
      environmentCue: json['environmentCue'] as String? ?? json['cue'] as String?,
      temptationBundle: json['temptationBundle'] as String?,
      preHabitRitual: json['preHabitRitual'] as String?,
      environmentDistraction: json['environmentDistraction'] as String?,
      isBreakHabit: json['isBreakHabit'] as bool? ?? false,
      replacesHabit: json['replacesHabit'] as String?,
      rootCause: json['rootCause'] as String?,
      substitutionPlan: json['substitutionPlan'] as String?,
      motivation: json['motivation'] as String?,
      recoveryPlan: json['recoveryPlan'] as String?,
      isComplete: json['isComplete'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'identity': identity,
    'name': name,
    'habitEmoji': habitEmoji,
    'tinyVersion': tinyVersion,
    'implementationTime': implementationTime,
    'implementationLocation': implementationLocation,
    'environmentCue': environmentCue,
    'temptationBundle': temptationBundle,
    'preHabitRitual': preHabitRitual,
    'environmentDistraction': environmentDistraction,
    'isBreakHabit': isBreakHabit,
    'replacesHabit': replacesHabit,
    'rootCause': rootCause,
    'substitutionPlan': substitutionPlan,
    'motivation': motivation,
    'recoveryPlan': recoveryPlan,
    'isComplete': isComplete,
  };

  /// Convert to Habit model for persistence
  Habit toHabit({required String id}) {
    return Habit(
      id: id,
      name: name,
      identity: identity,
      tinyVersion: tinyVersion,
      createdAt: DateTime.now(),
      implementationTime: implementationTime,
      implementationLocation: implementationLocation,
      environmentCue: environmentCue,
      temptationBundle: temptationBundle,
      preHabitRitual: preHabitRitual,
      environmentDistraction: environmentDistraction,
      isBreakHabit: isBreakHabit,
      replacesHabit: replacesHabit,
      rootCause: rootCause,
      substitutionPlan: substitutionPlan,
      habitEmoji: habitEmoji,
      motivation: motivation,
      // recoveryPlan maps to failurePlaybook if present
    );
  }
}
```

---

## 3. Conversation State Machine

To prevent the AI from "getting lost," we enforce strict states.

```dart
// lib/data/models/onboarding_state.dart

enum OnboardingState {
  greeting,            // Welcome & intent
  identityExploration, // "Who do you want to become?"
  habitDiscovery,      // "What action proves that identity?"
  rootCauseAnalysis,   // (Bad Habit Only) "Why do you do it?"
  inversionPlanning,   // (Bad Habit Only) "Make it invisible/difficult"
  tinyVersion,         // "Make it Easy" (2-minute rule)
  implementation,      // "When and Where?"
  commitment,          // Summary & Confirmation
  complete             // Final JSON handoff
}

/// Valid state transitions
const Map<OnboardingState, List<OnboardingState>> validTransitions = {
  OnboardingState.greeting: [OnboardingState.identityExploration],
  OnboardingState.identityExploration: [OnboardingState.habitDiscovery],
  OnboardingState.habitDiscovery: [
    OnboardingState.rootCauseAnalysis,  // If bad habit
    OnboardingState.tinyVersion,        // If good habit
  ],
  OnboardingState.rootCauseAnalysis: [OnboardingState.inversionPlanning],
  OnboardingState.inversionPlanning: [OnboardingState.tinyVersion],
  OnboardingState.tinyVersion: [OnboardingState.implementation],
  OnboardingState.implementation: [OnboardingState.commitment],
  OnboardingState.commitment: [OnboardingState.complete],
  OnboardingState.complete: [], // Terminal state
};
```

---

## 4. Tier 1: Gemini 2.5 Flash (The Architect)

**Goal:** Extract structured data for a *Good Habit* in < 4 turns.

### System Prompt

```markdown
You are an expert Habit Architect based on James Clear's Atomic Habits. Your goal is to extract structured data efficiently.

# RULES
1. **Efficiency:** Ask 1 question at a time. Keep replies under 3 sentences.
2. **Identity First:** Ground habits in identity ("Who do you want to become?").
3. **2-Minute Rule:** ALWAYS negotiate the habit down to a 2-minute version.
4. **Warmth:** Be encouraging but concise.

# CONVERSATION FLOW
1. Start with: "Who do you want to become?" (Identity)
2. Then: "What's ONE small action that proves that identity?" (Habit)
3. Then: "What's the 2-minute version you could do on your worst day?" (Tiny Version)
4. Then: "When and where will you do this?" (Implementation)
5. Finally: Output the JSON and a brief encouragement.

# JSON OUTPUT CONTRACT
When you have gathered [Identity, Habit, TinyVersion, Time, Location], output this JSON block:

[HABIT_DATA]
{
  "isBreakHabit": false,
  "identity": "I am a person who...",
  "name": "Read before bed",
  "habitEmoji": "📚",
  "tinyVersion": "Read one page",
  "implementationTime": "22:00",
  "implementationLocation": "In bed",
  "environmentCue": "After brushing teeth",
  "temptationBundle": null,
  "preHabitRitual": null,
  "motivation": null,
  "isComplete": true
}
[/HABIT_DATA]

Remember: Output the JSON block ONLY when you have all required fields. Do not output partial data.
```

---

## 5. Tier 2: Claude 4.5 Sonnet (The Coach)

**Goal:** Deep discovery for *Bad Habits* or *Premium Coaching*.

### System Prompt

```markdown
You are a warm, empathetic Habit Psychologist based on James Clear's Atomic Habits and Motivational Interviewing principles. You prioritize *why* over *what*.

# PRINCIPLES
- Active listening: Reflect back what you hear
- One question at a time: Never overwhelm
- Identity-first: "I am not a smoker" > "I'm trying to quit"
- 2-Minute Rule: Make the new habit impossibly small
- Compassion: No judgment, only curiosity

# BAD HABIT PROTOCOL (6 Steps)
When user wants to BREAK a habit, follow these steps:

1. **Identify the Loop:** What's the Trigger → Action → Reward?
2. **Find Root Cause:** Is it boredom? Anxiety? Loneliness? Stress?
3. **Design Substitution:** Find a healthy habit that fills the SAME need.
4. **Apply Inversion (Four Laws):**
   - Make it Invisible (remove cues)
   - Make it Unattractive (reframe consequences)
   - Make it Difficult (add friction)
   - Make it Unsatisfying (add accountability)
5. **Identity Shift:** Help them adopt a new identity statement.
6. **Failure Plan:** "Never Miss Twice" - what's the recovery plan?

# CONVERSATION GUIDELINES
- Keep responses under 4 sentences
- Ask probing questions: "What need does this habit fulfill?"
- Validate feelings: "That makes sense. Many people feel that way."
- Offer concrete alternatives: "Instead of X, could you try Y?"

# JSON OUTPUT CONTRACT
When you have gathered sufficient information, output:

[HABIT_DATA]
{
  "isBreakHabit": true,
  "identity": "I am a person who manages stress through movement",
  "name": "Walk when stressed",
  "habitEmoji": "🚶",
  "tinyVersion": "Stand up and stretch for 30 seconds",
  "implementationTime": "When feeling stressed",
  "implementationLocation": "At my desk",
  "replacesHabit": "Stress eating",
  "rootCause": "Anxiety/stress relief",
  "substitutionPlan": "5-minute walk around the block",
  "environmentCue": "Notice tension in shoulders",
  "motivation": "Feel calm without food",
  "recoveryPlan": "If I slip, I'll do one deep breath and try again",
  "isComplete": true
}
[/HABIT_DATA]
```

---

## 6. Guardrails & Parsing (Technical Implementation)

### A. Conversation Guardrails

```dart
// lib/data/config/conversation_guardrails.dart

class ConversationGuardrails {
  // === CONVERSATION LIMITS ===
  static const int maxConversationTurns = 15;
  static const int maxMessagesPerMinute = 10;
  static const int minSecondsBetweenRequests = 2;
  
  // === TIMEOUTS ===
  static const Duration apiTimeout = Duration(seconds: 10);
  static const Duration streamTimeout = Duration(seconds: 30);
  static const int maxRetries = 1;
  static const Duration retryDelay = Duration(seconds: 2);

  // === FRUSTRATION DETECTION ===
  // Triggers immediate fallback to Manual Mode (Tier 3)
  static const List<String> frustrationPatterns = [
    r'just let me',
    r'skip',
    r'too long',
    r'stupid',
    r'this is taking',
    r'can I just',
    r'never mind',
    r'forget it',
    r'stop asking',
    r'i give up',
  ];
  
  /// Check if user message indicates frustration
  static bool detectFrustration(String message) {
    final lowerMessage = message.toLowerCase();
    return frustrationPatterns.any((pattern) => 
      RegExp(pattern, caseSensitive: false).hasMatch(lowerMessage)
    );
  }
  
  /// Message shown when switching to manual mode
  static const String escapeHatchMessage = 
    "I sense I'm slowing you down. Let's switch to the quick form instead — "
    "you can fill in the details directly. No problem at all!";
}
```

### B. Response Parser

```dart
// lib/features/onboarding/helpers/ai_response_parser.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../data/models/onboarding_data.dart';

class AiResponseParser {
  static const String _habitDataStartMarker = '[HABIT_DATA]';
  static const String _habitDataEndMarker = '[/HABIT_DATA]';
  static final RegExp _habitDataPattern = RegExp(
    r'\[HABIT_DATA\](.*?)\[\/HABIT_DATA\]',
    dotAll: true,
  );

  /// Extracts OnboardingData from AI response
  /// Returns null if no valid JSON found
  static OnboardingData? extractHabitData(String response) {
    final match = _habitDataPattern.firstMatch(response);
    if (match == null) return null;

    try {
      final jsonStr = match.group(1)!.trim();
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return OnboardingData.fromJson(json);
    } catch (e) {
      debugPrint('AiResponseParser: Failed to parse habit data: $e');
      return null;
    }
  }

  /// Extracts conversational text (everything before [HABIT_DATA])
  static String extractConversationalText(String response) {
    final idx = response.indexOf(_habitDataStartMarker);
    if (idx == -1) return response.trim();
    return response.substring(0, idx).trim();
  }

  /// Check if response contains complete habit data
  static bool hasCompleteHabitData(String response) {
    final data = extractHabitData(response);
    return data != null && data.isComplete;
  }

  /// Validate that extracted data has minimum required fields
  static bool isValidHabitData(OnboardingData? data) {
    if (data == null) return false;
    return data.identity.isNotEmpty &&
           data.name.isNotEmpty &&
           data.tinyVersion.isNotEmpty &&
           data.implementationTime.isNotEmpty &&
           data.implementationLocation.isNotEmpty;
  }
}
```

### C. API Model Configuration

```dart
// lib/data/config/ai_model_config.dart

class AIModelConfig {
  // === API KEYS (from environment) ===
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );
  
  static const String claudeApiKey = String.fromEnvironment(
    'CLAUDE_API_KEY', 
    defaultValue: '',
  );
  
  // === MODEL NAMES ===
  static const String tier1Model = 'gemini-2.5-flash-latest';
  static const String tier2Model = 'claude-3-5-sonnet-latest'; // Or claude-4.5-sonnet when available
  
  // === FEATURE FLAGS ===
  static bool get hasGeminiAccess => geminiApiKey.isNotEmpty;
  static bool get hasClaudeAccess => claudeApiKey.isNotEmpty;
  static bool get isConfigured => hasGeminiAccess || hasClaudeAccess;
  
  // === TIER SELECTION ===
  static AiTier selectTier({required bool isPremium, required bool isBreakHabit}) {
    // Bad habits always use Claude (if available)
    if (isBreakHabit && hasClaudeAccess) return AiTier.tier2;
    
    // Premium users get Claude
    if (isPremium && hasClaudeAccess) return AiTier.tier2;
    
    // Default to Gemini
    if (hasGeminiAccess) return AiTier.tier1;
    
    // Fallback to manual
    return AiTier.tier3;
  }
}

enum AiTier { tier1, tier2, tier3 }
```

---

## 7. Vibecoding Architecture (File Structure)

Following the project's Vibecoding pattern (Controller/Helper/Widget separation):

```
lib/
├── data/
│   ├── services/
│   │   ├── onboarding_orchestrator.dart     # Service: Manages AI conversation flow
│   │   ├── gemini_service.dart              # Service: Tier 1 API calls
│   │   └── claude_service.dart              # Service: Tier 2 API calls
│   ├── models/
│   │   ├── onboarding_data.dart             # Model: Maps to Habit.dart
│   │   └── onboarding_state.dart            # Model: State machine enum
│   └── config/
│       ├── ai_model_config.dart             # Config: API keys, model names
│       └── conversation_guardrails.dart     # Config: Limits, patterns
├── features/
│   └── onboarding/
│       ├── onboarding_screen.dart           # Existing form (becomes Tier 3)
│       ├── conversational_onboarding.dart   # NEW: Chat UI (Phase 2)
│       ├── controllers/
│       │   └── onboarding_controller.dart   # Controller: Conversation state
│       ├── widgets/
│       │   ├── magic_wand_button.dart       # NEW: The "✨" button
│       │   ├── chat_message.dart            # NEW: Chat bubble widget
│       │   └── quick_form_fallback.dart     # Widget: Tier 3 form
│       └── helpers/
│           └── ai_response_parser.dart      # Helper: JSON extraction
```

---

## 8. Phased Implementation Plan

### Phase 1: "The Magic Wand" (Current Sprint)

**Goal:** Add AI-assisted field completion to existing form UI.

**Implementation:**
1. Add `MagicWandButton` (✨) to `OnboardingScreen`
2. User enters: Name + Identity + Habit Name
3. Clicks ✨ → Gemini auto-fills: Tiny Version, Time, Location, Cue
4. Existing "Ideas" buttons remain as manual fallback
5. If offline or API fails → button disabled with tooltip

**UI Change:**
```dart
// Add to onboarding_screen.dart, after habit name field
Row(
  children: [
    Expanded(child: _habitNameField()),
    const SizedBox(width: 8),
    MagicWandButton(
      onPressed: _autoFillWithAI,
      isLoading: _isLoadingAI,
      isEnabled: _canUseAI,
    ),
  ],
)
```

### Phase 2: "Conversational First" (Next Sprint)

**Goal:** Make chat the default onboarding experience.

**Implementation:**
1. Create `ConversationalOnboardingScreen` with chat UI
2. `OnboardingOrchestrator` manages Tier 1/2/3 switching
3. Add "Switch to Form" button for users who prefer manual
4. Existing form becomes the "Tier 3 Fallback" UI
5. A/B test: 50% chat, 50% form

---

## 9. Assets to Cherry-Pick (Orphaned Branches)

**Do NOT recreate these. Retrieve them:**

### 1. GeminiChatService
- **Branch:** `origin/claude/ai-conversational-first-page-01AMbHQvbDgWCxixHcNftXVn`
- **File:** `lib/data/services/gemini_chat_service.dart`
- **Contains:** System prompts for Atomic Habits coaching
- **Command:**
  ```bash
  git checkout origin/claude/ai-conversational-first-page-01AMbHQvbDgWCxixHcNftXVn -- lib/data/services/gemini_chat_service.dart
  ```

### 2. ChatConversation Model
- **Branch:** `origin/claude/ai-conversational-first-page-01AMbHQvbDgWCxixHcNftXVn`
- **File:** `lib/data/models/chat_conversation.dart`
- **Contains:** Conversation types, message history, Hive persistence
- **Command:**
  ```bash
  git checkout origin/claude/ai-conversational-first-page-01AMbHQvbDgWCxixHcNftXVn -- lib/data/models/chat_conversation.dart
  ```

### 3. BadHabitScreen Logic
- **Branch:** `origin/claude/habit-substitution-guardrails-01Tk3RnabL9H4chsKp4RjwCP`
- **File:** `lib/features/bad_habit/bad_habit_screen.dart`
- **Contains:** Substitution logic for Claude prompts
- **Command:**
  ```bash
  git checkout origin/claude/habit-substitution-guardrails-01Tk3RnabL9H4chsKp4RjwCP -- lib/features/bad_habit/bad_habit_screen.dart
  ```

---

## 10. Example Conversations

### Good Habit Flow (Tier 1 - Gemini)

```
AI: Hi! I'm here to help you build a tiny habit. 
    Who do you want to become? What kind of person do you see yourself as?

User: Someone who reads more

AI: "I am a reader" — love that! What's ONE small action that proves you're a reader?

User: Reading before bed

AI: Great! Now let's make it tiny — what's the 2-minute version? 
    Something so small you could do it even on your worst day.

User: Read one page

AI: Perfect! One page is exactly right. 
    When and where will you do this? Give me a specific time and place.

User: 10pm in bed

AI: You're all set! Here's your habit:

    "I am a reader. Every day at 10pm in bed, I will read one page."

    Every page is a vote for your reading identity. You've got this! 📚

[HABIT_DATA]
{
  "isBreakHabit": false,
  "identity": "I am a reader",
  "name": "Read before bed",
  "habitEmoji": "📚",
  "tinyVersion": "Read one page",
  "implementationTime": "22:00",
  "implementationLocation": "In bed",
  "environmentCue": null,
  "isComplete": true
}
[/HABIT_DATA]
```

### Bad Habit Flow (Tier 2 - Claude)

```
User: I want to stop scrolling social media so much

AI: I hear you — that's a common struggle and nothing to be ashamed of. 
    When do you usually find yourself scrolling? Is there a particular time or feeling that triggers it?

User: When I'm stressed after work

AI: That makes a lot of sense. Scrolling is your brain's way of seeking relief from stress.
    The reward isn't really the content — it's the escape, right?

User: Yeah, exactly

AI: So we need to find something else that gives you that same relief.
    What's a healthy activity that helps you decompress? Even something small?

User: Maybe going for a walk?

AI: Walking is perfect — it actually reduces cortisol (the stress hormone).
    Let's make it tiny: when you feel that urge to scroll after work, 
    could you put on your shoes and step outside for just 2 minutes?

User: I could do that

AI: Great. Now let's make scrolling harder: what if you delete the app from your phone,
    or log out after each use? The extra friction can break the automatic loop.

User: I could log out each time

AI: Perfect. Here's your new identity and plan:

    "I am a person who manages stress through movement."
    
    When you feel stressed after work, put on your shoes and step outside for 2 minutes.
    You've logged out of social media, so the friction is there to protect you.
    
    If you slip? That's okay — never miss twice. Just take one deep breath and try again.

[HABIT_DATA]
{
  "isBreakHabit": true,
  "identity": "I am a person who manages stress through movement",
  "name": "Walk when stressed",
  "habitEmoji": "🚶",
  "tinyVersion": "Put on shoes and step outside for 2 minutes",
  "implementationTime": "After work when feeling stressed",
  "implementationLocation": "Front door",
  "replacesHabit": "Scrolling social media",
  "rootCause": "Stress relief after work",
  "substitutionPlan": "Short walk outside",
  "environmentCue": "Notice stress/urge to scroll",
  "motivation": "Feel calm without numbing out",
  "recoveryPlan": "If I slip, take one deep breath and try again tomorrow",
  "isComplete": true
}
[/HABIT_DATA]
```

---

## 11. Testing Strategy

### Unit Tests

**File:** `test/helpers/ai_response_parser_test.dart`
```dart
group('AiResponseParser', () {
  test('extracts valid JSON from response', () {
    final response = '''
      Great job! Here's your habit:
      [HABIT_DATA]{"identity": "I am a reader", "name": "Read", "isComplete": true}[/HABIT_DATA]
    ''';
    final data = AiResponseParser.extractHabitData(response);
    expect(data?.identity, equals('I am a reader'));
  });

  test('returns null for missing markers', () {
    final response = 'No JSON here';
    expect(AiResponseParser.extractHabitData(response), isNull);
  });

  test('extracts conversational text before JSON', () {
    final response = 'Hello! [HABIT_DATA]{}[/HABIT_DATA]';
    expect(AiResponseParser.extractConversationalText(response), equals('Hello!'));
  });

  test('handles malformed JSON gracefully', () {
    final response = '[HABIT_DATA]{invalid json}[/HABIT_DATA]';
    expect(AiResponseParser.extractHabitData(response), isNull);
  });
});
```

**File:** `test/config/conversation_guardrails_test.dart`
```dart
group('ConversationGuardrails', () {
  test('detects frustration in "just let me type"', () {
    expect(ConversationGuardrails.detectFrustration('just let me type it'), isTrue);
  });

  test('does not flag normal messages', () {
    expect(ConversationGuardrails.detectFrustration('I want to read more'), isFalse);
  });

  test('is case insensitive', () {
    expect(ConversationGuardrails.detectFrustration('SKIP THIS'), isTrue);
  });
});
```

### Integration Tests

**File:** `test/integration/onboarding_flow_test.dart`
```dart
group('Onboarding Flow', () {
  test('completes good habit flow end-to-end', () async {
    // Setup mock AI service
    // Simulate conversation
    // Verify OnboardingData is created
    // Verify Habit is persisted to Hive
  });

  test('escape hatch triggers on frustration', () async {
    // Send frustrated message
    // Verify switch to manual mode
    // Verify existing form is shown
  });

  test('handles API timeout gracefully', () async {
    // Mock timeout
    // Verify fallback to Tier 3
    // Verify error message shown
  });
});
```

---

## 12. Implementation Checklist

### Phase 1 Tasks (Magic Wand)

- [ ] **Model Updates**
  - [ ] Add 7 new fields to `lib/data/models/habit.dart`
  - [ ] Update `Habit.fromJson()` and `toJson()` for backward compatibility
  - [ ] Create `lib/data/models/onboarding_data.dart`
  - [ ] Create `lib/data/models/onboarding_state.dart`

- [ ] **Config & Helpers**
  - [ ] Create `lib/data/config/ai_model_config.dart`
  - [ ] Create `lib/data/config/conversation_guardrails.dart`
  - [ ] Create `lib/features/onboarding/helpers/ai_response_parser.dart`

- [ ] **Services**
  - [ ] Cherry-pick `GeminiChatService` from orphaned branch
  - [ ] Create `lib/data/services/onboarding_orchestrator.dart`

- [ ] **UI Components**
  - [ ] Create `lib/features/onboarding/widgets/magic_wand_button.dart`
  - [ ] Add Magic Wand button to existing `onboarding_screen.dart`

- [ ] **Testing**
  - [ ] Add `ai_response_parser_test.dart`
  - [ ] Add `conversation_guardrails_test.dart`

- [ ] **Documentation**
  - [ ] Update `AI_CONTEXT.md` with new features
  - [ ] Update `ROADMAP.md` with sprint status

---

## 13. Success Metrics

| Metric | Current (Form Only) | Target (Phase 1) | Target (Phase 2) |
|--------|--------------------:|----------------:|----------------:|
| Onboarding completion rate | Baseline | +10% | +20% |
| Time to first habit | Baseline | -30% | -50% |
| "Tiny version" quality | Manual | AI-assisted | AI-native |
| User satisfaction (NPS) | Baseline | +5 | +10 |

---

*"You do not rise to the level of your goals. You fall to the level of your systems."* — James Clear

*Last Updated: December 2024*
