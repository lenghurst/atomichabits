# AI_CONTEXT.md — AI Agent Knowledge Checkpoint

> **Last Updated:** December 2024 (v1.0.0+1 — AI Onboarding Spec)
> **Purpose:** Single source of truth for AI development agents working on this codebase
> **CRITICAL:** This file MUST be kept in sync with `main` branch. Update after every significant change.

---

## ⚠️ AI HANDOFF PROTOCOL (READ FIRST!)

### The Problem This Solves
AI agents (Claude, Codex, etc.) working on this codebase have historically:
- Created documentation on feature branches that were never merged
- Left orphaned PRs with valuable work
- Recreated files that already existed on other branches
- Lost context between sessions

### Mandatory Session Start Checklist
```
□ 1. Read README.md (project overview, architecture)
□ 2. Read AI_CONTEXT.md (current state, what's implemented) ← YOU ARE HERE
□ 3. Read ROADMAP.md (what's next, priorities)
□ 4. Read AI_ONBOARDING_SPEC.md (AI feature specification)
□ 5. Check for stale branches: git branch -r | wc -l
□ 6. If stale branches > 10, consider cleanup (see Branch Hygiene below)
```

### Mandatory Session End Checklist
```
□ 1. Commit all changes to feature branch
□ 2. Create/Update PR with clear description
□ 3. Update AI_CONTEXT.md with any new features/changes
□ 4. Update ROADMAP.md if priorities changed
□ 5. Cherry-pick doc updates to main: git checkout main && git checkout <branch> -- AI_CONTEXT.md ROADMAP.md
□ 6. If PR is complete and tested: request merge or merge if authorized
□ 7. Report to user: "Session complete. PR #X created/updated. Docs synced to main."
```

### Branch Hygiene Protocol
When stale branches accumulate (> 10 unmerged):
1. List branches: `git branch -r --no-merged main`
2. For each branch, check last commit: `git log -1 <branch>`
3. If > 30 days old with no activity: recommend deletion
4. If contains unmerged valuable code: recommend cherry-pick or rebase

---

## Project Overview

**Atomic Habits Hook App** — A Flutter habit-tracking app based on:
- **James Clear's Atomic Habits** (identity-based habits, 4 Laws, 2-minute rule)
- **Nir Eyal's Hook Model** (Trigger → Action → Variable Reward → Investment)
- **B.J. Fogg's Behavior Model** (Motivation × Ability × Prompt)

**Core Philosophy:** `Graceful Consistency > Fragile Streaks`

**Tech Stack:**
| Component | Technology | Version |
|-----------|------------|---------|
| Framework | Flutter | 3.35.4 |
| Language | Dart | 3.9.2 |
| State Management | Provider | 6.1.5+1 |
| Navigation | GoRouter | ^14.0.0 |
| Persistence | Hive | ^2.2.3 |
| Notifications | flutter_local_notifications | ^19.2.1 |
| UI | Material Design 3 | - |

---

## Feature Matrix (Current State of `main`)

| Feature | Status | UI Layer | State Layer | Notes |
|---------|--------|----------|-------------|-------|
| Identity-Based Onboarding | ✅ Live | OnboardingScreen | AppState | Name, identity, habit, tiny version |
| Single Habit Tracking | ✅ Live | TodayScreen | AppState | One habit at a time |
| Graceful Consistency | ✅ Live | GracefulConsistencyCard | ConsistencyMetrics | Rolling averages, not fragile streaks |
| Never Miss Twice Engine | ✅ Live | RecoveryBanner, RecoveryPromptDialog | RecoveryEngine | Compassionate recovery system |
| AI Suggestions | ✅ Live | SuggestionDialog | AiSuggestionService | Local heuristics + async remote fallback |
| Temptation Bundling | ✅ Live | TodayScreen | Habit model | "Make it Attractive" |
| Pre-Habit Rituals | ✅ Live | PreHabitRitualDialog | Habit model | 30-second mindset timer |
| Environment Design | ✅ Live | TodayScreen | Habit model | Cues and distraction guardrails |
| Daily Notifications | ✅ Live | - | NotificationService | With snooze and mark-done actions |
| Recovery Notifications | ✅ Live | - | NotificationService | 9 AM after missed day |
| Vibecoding Architecture | ✅ Live | Controllers/Helpers/Widgets | - | Clean separation pattern |
| Settings Screen | 🚧 Stub | SettingsScreen | - | UI only, no persistence |
| **AI Onboarding (Phase 1)** | 🚧 In Progress | OnboardingScreen | OnboardingOrchestrator | See AI_ONBOARDING_SPEC.md |
| Multiple Habits | ❌ Not Started | - | - | Roadmap item |
| History/Calendar View | ❌ Not Started | - | - | Roadmap item |
| Home Screen Widget | ❌ Not Started | - | - | Exists on orphaned branch |
| Bad Habit Protocol | ❌ Not Started | - | - | Phase 2, needs Phase 1 |

---

## Architecture Snapshot

### Project Structure
```
lib/
├── main.dart                           # App entry, Provider setup, GoRouter
├── data/
│   ├── app_state.dart                  # Central state (ChangeNotifier)
│   ├── notification_service.dart       # Notifications + scheduling
│   ├── ai_suggestion_service.dart      # AI suggestions (remote + local)
│   ├── models/
│   │   ├── habit.dart                  # Habit data model
│   │   ├── user_profile.dart           # User identity model
│   │   └── consistency_metrics.dart    # Graceful Consistency scoring
│   └── services/
│       ├── recovery_engine.dart        # Never Miss Twice detection
│       ├── consistency_service.dart    # Consistency calculations
│       ├── keystone_analyzer.dart      # Habit analysis
│       └── review_service.dart         # Review functionality
├── features/
│   ├── onboarding/
│   │   └── onboarding_screen.dart      # First-time setup
│   ├── today/
│   │   ├── today_screen.dart           # Main screen (thin orchestrator)
│   │   ├── controllers/
│   │   │   └── today_screen_controller.dart  # Behavior logic
│   │   ├── widgets/                    # Presentational components
│   │   └── helpers/
│   │       └── recovery_ui_helpers.dart  # Pure styling functions
│   └── settings/
│       └── settings_screen.dart        # Settings (stub)
├── widgets/                            # Shared widgets
│   ├── graceful_consistency_card.dart
│   ├── recovery_prompt_dialog.dart
│   ├── reward_investment_dialog.dart
│   ├── pre_habit_ritual_dialog.dart
│   └── suggestion_dialog.dart
└── utils/
    └── date_utils.dart                 # Date utilities
```

### State Management Pattern
```
AppState (ChangeNotifier)
├── UserProfile? _userProfile
├── Habit? _currentHabit
├── bool _hasCompletedOnboarding
├── bool _shouldShowRewardFlow
└── Methods: completeHabitForToday(), getZoomOutPerspective(), etc.
```

### Vibecoding Pattern (UI vs Logic Separation)
```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   UI Widgets    │────▶│   Controllers   │────▶│    Helpers      │
│  (Presentational)│     │   (Behavior)    │     │ (Pure Functions)│
│  Props in/out   │     │  Side effects   │     │  No state       │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

---

## Key Files Reference

### Must-Read Before Making Changes
| File | Purpose | Read When |
|------|---------|-----------|
| `lib/data/app_state.dart` | Central state management | Any state changes |
| `lib/data/models/habit.dart` | Habit data model | Adding habit fields |
| `lib/data/models/consistency_metrics.dart` | Scoring algorithm | Changing metrics |
| `lib/data/services/recovery_engine.dart` | Recovery detection | Recovery logic changes |

### Testing
| File | Coverage |
|------|----------|
| `test/helpers/` | Date utils, recovery UI helpers |
| `test/models/` | Consistency metrics (40+ tests) |
| `test/services/` | Recovery engine (35+ tests) |
| `test/widgets/` | Identity card, completion button, recovery banner |
| `test/integration/` | Core flows |

---

## Gotchas & Non-Obvious Decisions

### 1. Single Habit Assumption
- App currently supports **one habit only**
- `AppState._currentHabit` is the source of truth
- Multi-habit requires significant refactor (see ROADMAP.md)

### 2. Graceful Consistency Formula
```
Score = (Base × 0.4) + (Recovery × 0.2) + (Stability × 0.2) + (NMT × 0.2)
- Base = 7-day completion rate × 100
- Recovery = 5 points per quick recovery (max 20)
- Stability = Lower variance = higher bonus
- NMT = Never Miss Twice success rate × 20
```

### 3. AI Suggestions Architecture
- Local heuristics first (instant)
- Remote LLM call with 5s timeout
- Fallback to local if remote fails
- Endpoint configurable in `ai_suggestion_service.dart`

### 4. Async BuildContext Handling
- All async UI methods check `if (mounted)` before using context
- Pattern: `if (mounted) Navigator.of(context).pop()`

---

## Version History

| Version | Date | Key Changes |
|---------|------|-------------|
| 1.0.0+1 | Dec 2024 | Current main: Full Graceful Consistency, Never Miss Twice, Vibecoding |
| 1.1.0 | Dec 2024 | (In Progress) AI Onboarding Phase 1: Magic Wand, 7 new Habit fields |

---

## Orphaned Branch Inventory

> **WARNING:** These branches contain work that was never merged to main.
> Review before starting new work to avoid duplication.

| Branch | Contains | Status |
|--------|----------|--------|
| `claude/setup-atomic-achievements-architecture-*` | AI_CONTEXT.md, ROADMAP.md, Home Widget | Partially merged (docs only) |
| `claude/claude-md-*` | CLAUDE.md | Not merged |
| `claude/atomic-habits-android-app-*` | FEATURE_ROADMAP.md | Not merged |
| `codex/create-node.js-backend-*` | Backend for suggestions | Not merged |

Run `git branch -r --no-merged main` for full list.

---

## Documentation Files (The "Big Four")

| File | Purpose | Update Frequency |
|------|---------|------------------|
| `README.md` | User-facing docs, architecture, testing guide | On major features |
| `AI_CONTEXT.md` | AI agent state checkpoint | Every session end |
| `ROADMAP.md` | Priorities, sprint tracking | Every session end |
| `AI_ONBOARDING_SPEC.md` | AI onboarding feature specification | On AI feature changes |

**Rule:** These files MUST always be in sync with `main` branch.

---

## AI Onboarding Architecture (NEW - December 2024)

### Three-Tier Strategy

| Tier | Model | Role | When Used |
|------|-------|------|-----------|
| Tier 1 | Gemini 2.5 Flash | The Architect | Default, fast extraction |
| Tier 2 | Claude 4.5 Sonnet | The Coach | Premium users, bad habits |
| Tier 3 | Manual Input | Safety Net | Offline, API failure, user opt-out |

### New Files (Phase 1)

```
lib/
├── data/
│   ├── models/
│   │   ├── onboarding_data.dart       # Maps to Habit.dart
│   │   └── onboarding_state.dart      # State machine enum
│   ├── config/
│   │   ├── ai_model_config.dart       # API keys, model names
│   │   └── conversation_guardrails.dart  # Limits, frustration detection
│   └── services/
│       └── onboarding_orchestrator.dart  # Tier selection, flow
├── features/
│   └── onboarding/
│       ├── widgets/
│       │   └── magic_wand_button.dart # ✨ AI assist button
│       └── helpers/
│           └── ai_response_parser.dart # JSON extraction
```

### New Habit Model Fields (v4.0.0)

```dart
// Added to lib/data/models/habit.dart
final bool isBreakHabit;        // true = break habit, false = build
final String? replacesHabit;    // What bad habit this replaces
final String? rootCause;        // Why the bad habit exists
final String? substitutionPlan; // Healthy alternative
final String? habitEmoji;       // Visual identity
final String? motivation;       // User's why
final String? recoveryPlan;     // Never Miss Twice plan
```

### Key Design Decisions

1. **JSON Output Contract:** AI outputs `[HABIT_DATA]...[/HABIT_DATA]` markers
2. **Frustration Detection:** Regex patterns trigger escape to manual mode
3. **State Machine:** Enforces conversation flow to prevent AI "getting lost"
4. **Backward Compatibility:** All new fields default to safe values

---

*"You do not rise to the level of your goals. You fall to the level of your systems."* — James Clear

*Last synced to main: December 2024*
