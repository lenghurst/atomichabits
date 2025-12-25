# AI_CONTEXT.md — The Pact

> **Last Updated:** 25 December 2025 (Commit: Phase 34.4 - Setup Message Fix)  
> **Last Verified:** Phase 34.4 Complete (WebSocket Setup Fix - thinkingConfig removed)  
> **Council Status:** 🟢 GREEN LIGHT FOR LAUNCH  
> **Identity:** The Pact  
> **Domain:** thepact.co  
> **Language:** UK English (Default)

---

## ⚠️ AI HANDOFF PROTOCOL (READ FIRST!)

### The Problem This Solves
AI agents (Claude, Codex, etc.) working on this codebase have historically:
- Created documentation on feature branches that were never merged
- Left orphaned PRs with valuable work
- Recreated files that already existed on other branches
- Lost context between sessions
- **FAILED TO SYNC:** Applied patches locally but failed to push to remote, causing "It Works on My Machine" errors.

### Mandatory Session Start Checklist
```
□ 1. Read README.md (project overview, architecture)
□ 2. Read AI_CONTEXT.md (current state, what's implemented) ← YOU ARE HERE
□ 3. Read ROADMAP.md (what's next, priorities)
□ 4. Read docs/ARCHITECTURE_MIGRATION.md (new provider architecture)
□ 5. Check for stale branches: git branch -r | wc -l
□ 6. If stale branches > 10, consider cleanup (see Branch Hygiene below)
```

### Mandatory Session End Checklist
```
□ 1. SAVE ALL FILES: Ensure no unsaved buffers exist.
□ 2. COMMIT ALL CHANGES: git commit -am "feat/fix: description"
□ 3. PUSH TO REMOTE: git push origin main
□ 4. Update AI_CONTEXT.md with any new features/changes
□ 5. Update ROADMAP.md if priorities changed
□ 6. Report to user: "Session complete. Changes pushed to main. Docs updated."
```

---

## Project Overview

**The Pact** — A social habit-tracking app that turns personal goals into socially binding contracts.

**Core Philosophy:** `Graceful Consistency > Fragile Streaks`

**Live URL:** [thepact.co](https://thepact.co)

**Tech Stack:**
| Component | Technology | Version |
|-----------|------------|---------|
| **Mobile** | Flutter | 3.38.4 |
| **Web** | React + Vite + Tailwind | Latest |
| **Backend** | Supabase | ^2.8.4 |
| **AI (Tier 1)** | DeepSeek-V3 | Text Chat |
| **AI (Tier 2)** | Gemini 3 Flash (2.5 Live) | Voice + Text |
| **Voice** | Gemini Live API | WebSocket Streaming |
| **Hosting** | Netlify | Auto-deploy |

---

## 🟢 Council of Five: Final Verdict

The Council has reviewed the Phase 34 implementation and issued their final verdict:

| Expert | Status | Key Finding |
|--------|--------|-------------|
| **Martin Fowler** | ✅ APPROVED | Rich domain model achieved. PsychometricProfile has logic, Engine has calculations. |
| **Robert C. Martin** | ✅ APPROVED | Zero Flutter imports in domain. DIP satisfied via abstract repositories. |
| **Eric Evans** | ✅ APPROVED | Ubiquitous Language implemented. CoachingStyle, ResilienceScore are first-class. |
| **Casey Muratori** | ✅ APPROVED | Bitmask O(1) checks. `recalibrateRisksAsync` now runs in Isolate. |
| **Remi Rousselet** | 🔄 PENDING | Structure solid. Phase 35 (ProxyProvider wiring) needed post-launch. |

**Launch Status:** **GO** 🟢  
**Target:** NYE 2025

---

## Phase 34: Architecture Refactoring (The "Council of Five")

A comprehensive architectural overhaul based on expert review from five software engineering titans:

| Expert | Focus | Key Contribution |
|--------|-------|------------------|
| **Martin Fowler** | Enterprise Patterns | Rich Domain Model (logic in entities) |
| **Eric Evans** | Domain-Driven Design | Ubiquitous Language, Anti-Corruption Layer |
| **Robert C. Martin** | Clean Architecture | Repository Pattern, Dependency Inversion |
| **Casey Muratori** | Performance | Bitmask flags, Incremental updates |
| **Remi Rousselet** | State Management | Domain-specific Providers, ProxyProvider |

### Key Changes Implemented

| Component | File(s) Created | Details |
|---|---|---|
| **Repository Layer** | `lib/data/repositories/*.dart` | Abstract interfaces + Hive implementations |
| **Domain Providers** | `lib/data/providers/*.dart` | Settings, User, Habit, Psychometric |
| **PsychometricProfile** | `lib/domain/entities/psychometric_profile.dart` | Rich domain entity for LLM context |
| **PsychometricEngine** | `lib/domain/services/psychometric_engine.dart` | Behavioural pattern analyser |
| **Migration Guide** | `docs/ARCHITECTURE_MIGRATION.md` | Step-by-step migration instructions |

### New Files Created (Phase 34)

**Repository Layer:**
- `lib/data/repositories/settings_repository.dart` (Interface)
- `lib/data/repositories/hive_settings_repository.dart` (Implementation)
- `lib/data/repositories/user_repository.dart` (Interface)
- `lib/data/repositories/hive_user_repository.dart` (Implementation)
- `lib/data/repositories/habit_repository.dart` (Interface)
- `lib/data/repositories/hive_habit_repository.dart` (Implementation)
- `lib/data/repositories/psychometric_repository.dart` (Interface)
- `lib/data/repositories/hive_psychometric_repository.dart` (Implementation)

**Domain Providers:**
- `lib/data/providers/settings_provider.dart`
- `lib/data/providers/user_provider.dart`
- `lib/data/providers/habit_provider.dart`
- `lib/data/providers/psychometric_provider.dart`

**Domain Layer:**
- `lib/domain/entities/psychometric_profile.dart`
- `lib/domain/services/psychometric_engine.dart`

**Documentation:**
- `docs/ARCHITECTURE_MIGRATION.md`

### Phase 34.2: Shadow Wiring (Dark Launch)

The new providers are now "shadow wired" into `main.dart` - initialised and available but not yet consumed by UI screens. This enables gradual migration using the "Strangler Fig" pattern.

**Changes to main.dart:**
- Added imports for all new repositories and providers
- Initialised repositories with Hive box references
- Created provider instances with repository injection
- Added providers to MultiProvider list
- Debug output confirms shadow wiring on app start

**Architecture Status:**
```
main.dart
├── AppState (Legacy)          → UI screens consume this
└── Shadow Providers (New)     → Initialised, available, unused
    ├── SettingsProvider
    ├── UserProvider
    ├── HabitProvider
    └── PsychometricProvider
```

### Phase 34.3: Oliver Backdoor (Tier 2 Verification)

⚠️ **TODO: REMOVE BEFORE PRODUCTION DEPLOYMENT**

A temporary backdoor to allow `oliver.longhurst@gmail.com` to access Tier 2 (Voice Coach) features without going through the payment flow.

**Implementation:**
```dart
// In lib/data/app_state.dart (isPremium getter)
bool get isPremium {
  try {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser?.email == 'oliver.longhurst@gmail.com') {
      return true;
    }
  } catch (_) {}
  return _isPremium;
}
```

**Why This Approach:**
1. More reliable than Dev Tools toggle (persists across app restarts)
2. Doesn't require knowing the 'secret handshake' (7 taps)
3. Uses AppState.isPremium which is consumed by UI (not UserProvider which isn't wired yet)

**Cleanup Command:**
```bash
grep -rn 'oliver.longhurst' lib/
```

### Phase 34.4: Debug Diagnostics + Voice Coach UI

Added in-app debug diagnostics to help diagnose API key loading issues on device.

**Changes:**

1. **Voice Coach Button Added to Dashboard:**
   - File: `lib/features/dashboard/habit_list_screen.dart`
   - Added "Voice Coach" option to the Add Habit bottom sheet
   - Purple mic icon, navigates to `/onboarding/voice`
   - Only visible for Premium users (Oliver Backdoor)

2. **In-App API Key Debug Info:**
   - File: `lib/config/ai_model_config.dart`
   - Added `debugKeyStatus` getter that returns human-readable key status
   - Shows which keys are loaded/missing with first 5 chars preview

3. **Error Messages Include Debug Info:**
   - File: `lib/features/onboarding/conversational_onboarding_screen.dart`
   - When AI connection fails, error message now includes:
     ```
     --- DEBUG INFO ---
     API Key Status:
     • DeepSeek: ✗ NOT LOADED
     • Gemini: ✗ NOT LOADED
     ```

4. **Console Logging:**
   - File: `lib/data/services/ai/ai_service_manager.dart`
   - Added debug logging on service initialisation
   - Shows key presence and first 5 chars in logcat

**Known Issue:** `--dart-define-from-file=secrets.json` may not be loading keys correctly. Alternative is to pass keys directly via `--dart-define`.

### Phase 34.4b: Gemini Model Fix + Parser Improvements

Critical fix for Voice Coach - the model name was incorrect.

**Root Cause:** Model name `gemini-live-2.5-flash-native-audio` does not exist in Google's API.

**Fix Applied:**

| Component | Old Value | New Value |
|-----------|-----------|----------|
| Flutter Config | `gemini-live-2.5-flash-native-audio` | `gemini-2.5-flash-native-audio-preview-12-2025` |
| Backend Edge Function | Same | Same |

**Source:** https://ai.google.dev/gemini-api/docs/live (December 25, 2025)

**Files Changed:**
1. `lib/config/ai_model_config.dart` - Corrected `tier2Model`
2. `supabase/functions/get-gemini-ephemeral-token/index.ts` - Matching model
3. `lib/data/services/onboarding/ai_response_parser.dart` - Added Markdown sanitizer

**Parser Improvements:**
- Added `sanitizeAndExtractJson()` to handle Markdown code blocks
- Strips \`\`\`json ... \`\`\` wrappers from Gemini responses
- Extracts JSON from conversational preamble/trailing text

**IMPORTANT:** After pulling, redeploy the Edge Function:
```bash
supabase functions deploy get-gemini-ephemeral-token
```

### Phase 34.4c: WebSocket Setup Message Fix (thinkingConfig)

Critical fix for Voice Coach WebSocket connection - invalid field in setup message.

**Error Message:**
```
SOCKET_CLOSED
Code: 1007 | Reason: Invalid JSON payload received.
Unknown name "thinkingConfig" at 'setup': Cannot find field.
```

**Root Cause:** The `thinkingConfig` field is NOT valid for raw WebSocket setup messages. Only the Python/JS SDK abstracts this internally.

**Fix Applied:**

| Before (Broken) | After (Fixed) |
|-----------------|---------------|
| `'thinkingConfig': { 'thinkingLevel': 'MINIMAL' }` | Removed entirely |
| N/A | `'thinkingBudget': 0` inside `generationConfig` |

**File Changed:** `lib/data/services/gemini_live_service.dart`

**Reference:** https://ai.google.dev/gemini-api/docs/live-guide

**Analysis Document:** `docs/GEMINI_LIVE_API_FINDINGS.md`

---

## PsychometricProfile: The "Brain" of AI Personalisation

The `PsychometricProfile` is the key innovation for personalised AI coaching. It transforms raw habit data into structured LLM context.

### Profile Structure

```dart
class PsychometricProfile {
  // === CORE DRIVERS (The "Why") ===
  final List<String> coreValues;       // e.g., ["Freedom", "Mastery", "Health"]
  final String bigWhy;                 // The singular life goal driving them
  final List<String> antiIdentities;   // Who they fear becoming
  final List<String> desireFingerprint; // Specific desires

  // === COMMUNICATION MATRIX (The "How") ===
  final CoachingStyle coachingStyle;   // TOUGH_LOVE, SOCRATIC, SUPPORTIVE, etc.
  final int verbosityPreference;       // 1 (Bullet points) to 5 (Long prose)
  final List<String> resonanceWords;   // Words that trigger action
  final List<String> avoidWords;       // Words that cause resistance

  // === BEHAVIOURAL INTELLIGENCE (The "When") ===
  final List<String> dropOffZones;     // e.g., "Weekends", "Travel"
  final String peakEnergyWindow;       // e.g., "08:00 - 11:00"
  final double resilienceScore;        // 0.0-1.0 (Likelihood to quit after a miss)
  
  // === PERFORMANCE OPTIMISATION (Muratori) ===
  final int riskBitmask;               // O(1) risk checks via bitmask
}
```

### LLM System Prompt Generation

```dart
String toSystemPrompt() {
  return '''
  [[USER PSYCHOMETRICS]]
  
  CORE DRIVERS:
  - Values: ${coreValues.join(", ")}
  - Primary Drive: $bigWhy
  - FEARS (Anti-Identity): ${antiIdentities.join(", ")}
  
  COMMUNICATION PROTOCOL:
  - Adopt Persona: ${coachingStyle.displayName}
  - Verbosity Level: $verbosityPreference/5
  - USE these words: ${resonanceWords.join(", ")}
  - AVOID these words: ${avoidWords.join(", ")}
  
  BEHAVIOURAL RISKS:
  - High-Risk Drop-off Zones: ${dropOffZones.join(", ")}
  - Best Energy Window: $peakEnergyWindow
  - Current Resilience: ${(resilienceScore * 100).toStringAsFixed(0)}%
  ''';
}
```

### Coaching Styles

| Style | Description | Example Response |
|-------|-------------|------------------|
| **TOUGH_LOVE** | Direct and demanding | "Get up. No excuses." |
| **SOCRATIC** | Questions to discover answers | "Why do you think you missed today?" |
| **SUPPORTIVE** | Encouraging and understanding | "You're doing great! One miss is okay!" |
| **ANALYTICAL** | Data-driven insights | "Data shows you miss on Tuesdays. Let's optimise." |
| **STOIC** | Philosophical wisdom | "The obstacle is the way." |

---

## Phase 33: Brain Surgery 2.5 (The "Pact" Polish)

A critical architectural overhaul to close the loop on social accountability and trust.

**Key Changes Implemented:**

| Component | File(s) Changed | Details |
|---|---|---|
| **The Pledge** | `pact_tier_selector_screen.dart` | Added a "Contract Card" listing the specific habit, witness, and stakes before payment. |
| **Witness Invite** | `witness_investment_screen.dart` | Implemented native Share Sheet (`share_plus`) to send invite links via WhatsApp/SMS. |
| **Explicit Auth** | `auth_service.dart` | Verified Google Sign-In requests `email` and `profile` scopes explicitly. |
| **Voice Polish** | `pact_tier_selector_screen.dart` | Added sound effects (`audioplayers`) to the AI Coach placeholder button. |

---

## Phase 33: The Investment (Supporter Screen Redesign)

Redesigned the Supporter Screen as a high-stakes "Investment" phase.

**Key Changes Implemented:**

| Component | File(s) Changed | Details |
|---|---|---|
| **TypeAhead Dependency** | `pubspec.yaml` | Added `flutter_typeahead` for contact searching. |
| **Permission Glass Pane** | `permission_glass_pane.dart` | Context before requesting OS permissions. |
| **Investment Screen** | `witness_investment_screen.dart` | Replaces the old `PactWitnessScreen`. |
| **Routing** | `main.dart` | Updated GoRouter configuration. |

---

## Phase 32: FEAT-01 - Audio Recording Integration

Implemented audio recording and session management for voice conversations.

**Key Changes Implemented:**

| Component | File(s) Changed | Details |
|---|---|---|
| **Audio Dependencies** | `pubspec.yaml` | Added `flutter_sound` and `permission_handler`. |
| **Audio Recording Service** | `audio_recording_service.dart` | Microphone initialisation and VAD. |
| **Voice Session Manager** | `voice_session_manager.dart` | Orchestration layer for voice sessions. |
| **Voice Coach Screen** | `voice_coach_screen.dart` | Refactored to use `VoiceSessionManager`. |
| **Security Patch** | `voice_coach_screen.dart` | `WidgetsBindingObserver` to pause when backgrounded. |

---

## Architecture Overview

### Directory Structure

```
lib/
├── config/                 # Configuration files
│   ├── ai_model_config.dart    # AI model endpoints and settings
│   ├── supabase_config.dart    # Supabase configuration
│   └── deep_link_config.dart   # Deep link configuration
│
├── data/
│   ├── app_state.dart          # LEGACY: Monolithic state (being strangled)
│   ├── models/                 # Data models
│   │   └── habit.dart
│   ├── repositories/           # NEW: Repository pattern
│   │   ├── *_repository.dart       (Interfaces)
│   │   └── hive_*_repository.dart  (Implementations)
│   ├── providers/              # NEW: Domain-specific providers
│   │   ├── settings_provider.dart
│   │   ├── user_provider.dart
│   │   ├── habit_provider.dart
│   │   └── psychometric_provider.dart
│   └── services/
│       ├── ai/                 # AI services
│       │   ├── ai_service_manager.dart
│       │   ├── deep_seek_service.dart
│       │   └── gemini_live_service.dart
│       └── ...
│
├── domain/                 # NEW: Pure domain layer
│   ├── entities/
│   │   └── psychometric_profile.dart
│   └── services/
│       └── psychometric_engine.dart
│
├── features/
│   ├── onboarding/
│   │   ├── identity_first/     # The "Pact" Flow
│   │   │   ├── value_proposition_screen.dart
│   │   │   ├── identity_access_gate_screen.dart
│   │   │   ├── witness_investment_screen.dart
│   │   │   └── pact_tier_selector_screen.dart
│   │   ├── voice_coach_screen.dart
│   │   └── conversational_onboarding_screen.dart
│   └── ...
│
└── main.dart               # App entry point
```

### Migration Strategy: Strangler Fig Pattern

The new architecture coexists with the legacy `AppState` using the "Strangler Fig" pattern:

1. **Phase 34** (Current): Create new providers alongside AppState ✅
2. **Phase 35**: Wire new providers into main.dart with ProxyProvider
3. **Phase 36**: Gradually migrate screens to use new providers
4. **Phase 37**: Deprecate and remove AppState

---

## AI Model Configuration

### Current Endpoints (December 2025)

| Tier | Model | Use Case |
|------|-------|----------|
| **Tier 1** | `deepseek-chat` | Text reasoning, logic |
| **Tier 2** | `gemini-live-2.5-flash-native-audio` | Real-time voice |
| **Tier 2 Fallback** | `gemini-2.5-flash` | Text when voice unavailable |
| **Tier 3** | `gemini-2.5-pro` | Complex reasoning |

### Kill Switch System

```dart
class AIModelConfig {
  static const bool enableGeminiLive = true;
  static const bool enableDeepSeek = true;
  static const bool enableOpenAI = false; // Disabled
}
```

---

## Dependencies Added (Phase 33-34)

| Package | Version | Purpose |
|---------|---------|---------|
| `share_plus` | ^10.1.4 | Native share sheet |
| `audioplayers` | ^6.1.0 | Sound effects |
| `flutter_typeahead` | ^5.2.0 | Contact search |
| `flutter_sound` | ^9.16.3 | Audio recording |
| `permission_handler` | ^11.3.1 | OS permissions |

---

## Testing Checklist

### Smoke Test (Pre-Launch)

```
□ 1. Google Sign-In works (oliver.longhurst@gmail.com)
□ 2. Oliver Backdoor grants Tier 2 access
□ 3. Voice Coach latency < 500ms
□ 4. Context memory persists across sessions
□ 5. Background security (session pauses when backgrounded)
□ 6. Contract Card displays correctly
□ 7. Share Sheet opens with correct invite link
```

### Google Sign-In Configuration

| Location | Field | Value |
|----------|-------|-------|
| **secrets.json** | GOOGLE_WEB_CLIENT_ID | Web Client ID from Google Cloud |
| **Google Cloud** | Web Client redirect URI | `https://lwzvvaqgvcmsxblcglxo.supabase.co/auth/v1/callback` |
| **Google Cloud** | Android Client SHA-1 | Debug keystore SHA-1 |
| **Supabase** | Client ID | Web Client ID |
| **Supabase** | Client Secret | Web Client Secret |
| **Supabase** | Authorised Client IDs | Android Client ID |

### Architecture Test (Post-Launch)

```
□ 1. Repository pattern enables mock testing
□ 2. PsychometricProfile generates valid LLM prompts
□ 3. Incremental resilience updates work correctly
□ 4. Bitmask risk checks are O(1)
```

---

## Known Issues & Technical Debt

| Issue | Priority | Status |
|-------|----------|--------|
| AppState is still monolithic | Medium | Strangler pattern in progress |
| Habit.dart has toJson (violates Clean Architecture) | Low | Phase 36 |
| No DTO separation for persistence | Low | Phase 36 |
| HabitEngine not extracted | Medium | Phase 35 |

---

## Branch Hygiene

If `git branch -r | wc -l` returns > 10:

```bash
# List remote branches
git branch -r

# Delete merged branches
git branch -r --merged main | grep -v main | xargs -I {} git push origin --delete {}

# Prune local references
git fetch --prune
```
