# AI_CONTEXT.md — The Pact

> **Last Updated:** 24 December 2025 (Commit: Phase 34 - Architecture Refactoring)  
> **Last Verified:** Phase 34 Complete (Repository Pattern + Domain Providers + PsychometricProfile)  
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
| **Mobile** | Flutter | 3.35.4 |
| **Web** | React + Vite + Tailwind | Latest |
| **Backend** | Supabase | ^2.8.4 |
| **AI (Tier 1)** | DeepSeek-V3 | Text Chat |
| **AI (Tier 2)** | Gemini 3 Flash (2.5 Live) | Voice + Text |
| **Voice** | Gemini Live API | WebSocket Streaming |
| **Hosting** | Netlify | Auto-deploy |

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
□ 1. Voice Coach latency < 500ms
□ 2. Context memory persists across sessions
□ 3. Background security (session pauses when backgrounded)
□ 4. Contract Card displays correctly
□ 5. Share Sheet opens with correct invite link
□ 6. Google Auth requests email/profile scopes
```

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
