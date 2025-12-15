# AI_CONTEXT.md — AI Agent Knowledge Checkpoint

> **Last Updated:** December 2025 (v4.5.0 — Phase 7 Weekly Review with AI)
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
| Settings Screen | ✅ Live | SettingsScreen | AppState (AppSettings) | Theme, notifications, sound, haptics |
| **AI Onboarding (Phase 1)** | ✅ Live | OnboardingScreen + MagicWandButton | OnboardingOrchestrator | Magic Wand auto-fill |
| **AI Onboarding (Phase 2)** | ✅ Live | ConversationalOnboardingScreen | OnboardingOrchestrator | Chat UI default route |
| **Multi-Habit Engine (Phase 3)** | ✅ Live | - | AppState (List<Habit>) | CRUD + Focus Mode |
| **Dashboard (Phase 4)** | ✅ Live | HabitListScreen | AppState | Habit cards, quick-complete, swipe-delete |
| **Focus Mode Swipe (Phase 4)** | ✅ Live | TodayScreen (PageView) | AppState | Swipe between habits |
| **History/Calendar View (Phase 5)** | ✅ Live | HistoryScreen, CalendarMonthView | AppState | Stats, calendar dots, milestones |
| **Settings & Polish (Phase 6)** | ✅ Live | SettingsScreen | AppState (AppSettings) | Theme, notifications, sound, haptics |
| **Error Boundaries (Phase 6)** | ✅ Live | ErrorBoundary, ErrorScreen | - | Global error handling |
| **Weekly Review with AI (Phase 7)** | ✅ Live | WeeklyReviewDialog | WeeklyReviewService | AI-powered weekly insights |
| Home Screen Widget | ❌ Not Started | - | - | Exists on orphaned branch |
| Bad Habit Protocol | ❌ Not Started | - | - | Tier 2 Claude integration |

---

## Architecture Snapshot

### Project Structure
```
lib/
├── main.dart                           # App entry, Provider setup, GoRouter, Error handling
├── core/
│   └── error_boundary.dart             # Error handling widgets and utilities
├── config/
│   └── ai_model_config.dart            # API keys, model configuration
├── data/
│   ├── app_state.dart                  # Central state (ChangeNotifier)
│   ├── notification_service.dart       # Notifications + scheduling
│   ├── ai_suggestion_service.dart      # AI suggestions (remote + local)
│   ├── models/
│   │   ├── habit.dart                  # Habit data model
│   │   ├── user_profile.dart           # User identity model
│   │   ├── consistency_metrics.dart    # Graceful Consistency scoring
│   │   ├── app_settings.dart           # User preferences model
│   │   ├── chat_message.dart           # Chat message model
│   │   └── chat_conversation.dart      # Conversation state
│   └── services/
│       ├── recovery_engine.dart        # Never Miss Twice detection
│       ├── consistency_service.dart    # Consistency calculations
│       ├── gemini_chat_service.dart    # Chat + One-shot AI analysis
│       ├── weekly_review_service.dart  # [Phase 7] Weekly data aggregation
│       └── onboarding/
│           ├── onboarding_orchestrator.dart  # AI orchestration
│           ├── ai_response_parser.dart       # JSON extraction
│           └── conversation_guardrails.dart  # Frustration detection
├── features/
│   ├── onboarding/
│   │   ├── onboarding_screen.dart      # Form-based (Tier 3)
│   │   ├── conversational_onboarding_screen.dart  # Chat UI (default)
│   │   └── widgets/
│   │       ├── magic_wand_button.dart
│   │       └── chat_message_bubble.dart
│   ├── today/
│   │   ├── today_screen.dart           # Main screen (thin orchestrator)
│   │   ├── controllers/
│   │   │   └── today_screen_controller.dart  # Behavior logic
│   │   ├── widgets/                    # Presentational components
│   │   └── helpers/
│   │       └── recovery_ui_helpers.dart  # Pure styling functions
│   ├── dashboard/
│   │   ├── habit_list_screen.dart      # Multi-habit dashboard
│   │   └── widgets/
│   │       └── habit_summary_card.dart
│   ├── history/
│   │   ├── history_screen.dart         # Calendar view + stats
│   │   └── widgets/
│   │       └── calendar_month_view.dart
│   ├── settings/
│   │   └── settings_screen.dart        # Settings (fully functional)
│   └── review/                         # [Phase 7]
│       └── weekly_review_dialog.dart   # AI-powered weekly insights
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

### AI Architecture (Two Modes)
```
┌─────────────────────────────────────────────────────────────────┐
│                     GeminiChatService                           │
├─────────────────────────────────┬───────────────────────────────┤
│   Conversational Mode           │   One-Shot Analysis Mode      │
│   (Streaming Chat)              │   (Single Response)           │
├─────────────────────────────────┼───────────────────────────────┤
│   sendMessage()                 │   generateWeeklyAnalysis()    │
│   - Maintains chat history      │   - No history management     │
│   - Streams response chunks     │   - Returns complete string   │
│   - Used by: Onboarding         │   - Used by: Weekly Review    │
└─────────────────────────────────┴───────────────────────────────┘
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
| 1.1.0 | Dec 2025 | AI Onboarding Phase 1: Magic Wand, 7 new Habit fields |
| 1.2.0 | Dec 2025 | AI Onboarding Phase 2: Conversational UI, Chat default route |
| 1.3.0 | Dec 2025 | Phase 3: Multi-Habit Engine (List<Habit>, Focus Mode) |
| 1.4.0 | Dec 2025 | Phase 4: Dashboard (HabitListScreen, quick-complete) |
| 1.5.0 | Dec 2025 | Phase 5: History & Calendar View (HistoryScreen, CalendarMonthView) |
| 1.6.0 | Dec 2025 | Phase 6: Settings & Polish (AppSettings, Error Boundaries, Dynamic Theming) |
| 1.6.1 | Dec 2025 | Phase 6.5: Brand Polish (Custom App Icon, Splash Screen, ErrorReporter) |
| 4.5.0 | Dec 2025 | Phase 7: Weekly Review with AI (WeeklyReviewService, WeeklyReviewDialog) |

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

### New Files (Phase 1 + Phase 2)

```
lib/
├── data/
│   ├── models/
│   │   ├── onboarding_data.dart       # Maps to Habit.dart
│   │   ├── chat_message.dart          # ChatMessage model
│   │   └── chat_conversation.dart     # Conversation state
│   ├── config/
│   │   ├── ai_model_config.dart       # API keys, model names
│   │   └── conversation_guardrails.dart  # Limits, frustration detection
│   └── services/
│       ├── gemini_chat_service.dart   # Gemini API integration
│       └── onboarding/
│           ├── onboarding_orchestrator.dart  # Tier selection, flow
│           ├── ai_response_parser.dart       # JSON extraction
│           └── conversation_guardrails.dart  # Frustration detection
├── features/
│   └── onboarding/
│       ├── onboarding_screen.dart           # Form UI (Tier 3 fallback)
│       ├── conversational_onboarding_screen.dart  # Chat UI (default)
│       └── widgets/
│           ├── magic_wand_button.dart       # ✨ AI assist button
│           └── chat_message_bubble.dart     # Chat bubbles + typing indicator
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

---

## Phase 2: Conversational UI Architecture

### Route Configuration
```dart
// main.dart - GoRouter configuration
'/'                → ConversationalOnboardingScreen (Chat AI Coach)
'/onboarding/manual' → OnboardingScreen (Form-based fallback)
'/dashboard'       → HabitListScreen (Multi-habit dashboard)
'/today'           → TodayScreen (Focus mode with PageView)
'/history'         → HistoryScreen (Calendar view)
'/settings'        → SettingsScreen (Full settings persistence)
```

### Conversation Flow
```
1. User opens app (first time)
2. ConversationalOnboardingScreen loads
3. AI greeting: "Hi! What's your name?"
4. User provides name
5. AI guides through: Identity → Habit → 2-Min Rule → Implementation
6. When AI has complete data, shows confirmation dialog
7. User confirms → saves Habit + UserProfile → navigates to /today
```

### Escape Hatch Triggers
```dart
// ConversationGuardrails.frustrationPatterns
- "just let me type", "skip", "too long"
- "stupid", "this is taking", "never mind"
- "stop asking", "manual", "forget it"
```

### Key Classes (Phase 2)
| Class | Purpose |
|-------|---------|
| `ConversationalOnboardingScreen` | Chat UI, message list, input field |
| `ChatMessageBubble` | Message styling, avatars, typing indicator |
| `ConversationResult` | Response from orchestrator (data + display text) |
| `OnboardingOrchestrator.sendConversationalMessage()` | Main chat method |

---

---

## Phase 6: Settings & Polish Architecture

### AppSettings Model
```dart
// lib/data/models/app_settings.dart
class AppSettings {
  final ThemeMode themeMode;           // system, light, dark
  final bool soundEnabled;              // Play sounds on completion
  final bool hapticsEnabled;            // Vibrate on interactions
  final bool notificationsEnabled;      // Global notification toggle
  final String defaultNotificationTime; // HH:MM format
  final bool showQuotes;                // Motivational quotes
}
```

### Error Handling Architecture
```dart
// lib/core/error_boundary.dart
- ErrorBoundary widget: Catches errors in widget subtree
- ErrorScreen: User-friendly error display with retry
- setupGlobalErrorHandling(): Flutter + async error handling
- BuildContext extensions: showErrorSnackBar, showSuccessSnackBar
```

### Dynamic Theming
```dart
// main.dart
MaterialApp.router(
  themeMode: appState.themeMode,  // From AppState settings
  theme: ThemeData(...),           // Light theme
  darkTheme: ThemeData(...),       // Dark theme
)
```

---

---

## Phase 7: Weekly Review with AI Architecture

### Overview
The Weekly Review feature provides AI-powered personalized insights based on habit performance data. It closes the "Hook Model" loop by turning user effort into personalized investment.

### New Files
```
lib/
├── data/
│   └── services/
│       └── weekly_review_service.dart    # Data aggregation & prompt building
└── features/
    └── review/
        └── weekly_review_dialog.dart     # Review UI with stats & AI insights
```

### Key Classes

| Class | Purpose |
|-------|---------|
| `WeeklyReviewService` | Aggregates 7-day habit data, builds AI prompts, provides local fallback |
| `WeeklyReviewResult` | Result model with review text, stats, AI/fallback flag |
| `WeeklyStats` | Summary stats: days completed, week history, score, recoveries |
| `WeeklyReviewDialog` | Modal dialog showing 7-day progress, stats, AI review |

### AI Prompt Design
The service builds a context-aware prompt including:
- Habit name, identity, motivation
- 7-day completion history (emoji format)
- Graceful Consistency Score and change
- Recovery count and identity votes
- Rules for tone (compassionate, identity-focused, no shaming)

### Fallback Logic
If AI is unavailable (offline, API error), local heuristics generate appropriate responses:
- Perfect week → Celebrate identity commitment
- Recoveries → Praise resilience
- Struggling → Suggest 2-minute rule
- No completions → Compassionate fresh start

### Integration Points
- **History Screen**: Weekly Review card in insights section + app bar button
- **Dashboard**: Weekly Review button (✨) in app bar for quick access
- **Provider**: `WeeklyReviewService` registered via `ProxyProvider`

### GeminiChatService Extension
Added `generateWeeklyAnalysis(String prompt)` method for single-turn, non-conversational AI requests.

---

*Last synced to main: December 2025*
