# AI_CONTEXT.md — AI Agent Knowledge Checkpoint

> **Last Updated:** December 2025 (v4.9.0 — Phase 12 Bad Habit Protocol)
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
| Home Widgets | home_widget | ^0.7.0 |
| Charts | fl_chart | ^0.69.0 |
| File Sharing | share_plus | ^10.1.4 |
| File Picking | file_picker | ^8.1.6 |
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
| **Home Screen Widgets (Phase 9)** | ✅ Live | Native (Android/iOS) | HomeWidgetService | One-tap habit completion |
| **Analytics Dashboard (Phase 10)** | ✅ Live | AnalyticsScreen | AnalyticsService | Graceful Consistency charts |
| **Backup & Restore (Phase 11)** | ✅ Live | DataManagementScreen | BackupService | JSON export/import |
| **Bad Habit Protocol (Phase 12)** | ✅ Live | Updated UI components | Habit.isBreakHabit | Break habits with purple theme |

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
│       ├── home_widget_service.dart    # [Phase 9] Home screen widget sync
│       ├── analytics_service.dart      # [Phase 10] Analytics data computation
│       ├── backup_service.dart         # [Phase 11] Backup/restore logic
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
│   │   ├── settings_screen.dart        # Settings (fully functional)
│   │   └── data_management_screen.dart # [Phase 11] Backup & Restore UI
│   ├── review/                         # [Phase 7]
│   │   └── weekly_review_dialog.dart   # AI-powered weekly insights
│   └── analytics/                      # [Phase 10]
│       └── analytics_screen.dart       # Graceful Consistency charts
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
| 4.6.0 | Dec 2025 | Phase 9: Home Screen Widgets (Android + iOS native widgets) |
| 4.7.0 | Dec 2025 | Phase 10: Analytics Dashboard (fl_chart, AnalyticsService, trend visualization) |
| 4.8.0 | Dec 2025 | Phase 11: Data Safety (BackupService, DataManagementScreen, JSON export/import) |

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

## Phase 9: Home Screen Widgets Architecture

### Overview
Home Screen Widgets enable one-tap habit completion from the device's home screen without opening the app. Supports both Android and iOS.

### New Files
```
lib/
└── data/
    └── services/
        └── home_widget_service.dart    # Widget data sync, callbacks

android/
├── app/src/main/
│   ├── kotlin/.../HabitWidgetProvider.kt  # Widget provider
│   ├── res/layout/habit_widget.xml        # Widget layout
│   ├── res/xml/habit_widget_info.xml      # Widget config
│   └── res/drawable/widget_*.xml          # Widget styles

ios/
└── HabitWidget/
    ├── HabitWidget.swift     # WidgetKit implementation
    ├── Info.plist            # Widget extension config
    └── README.md             # iOS setup guide
```

### Key Components

| Component | Platform | Purpose |
|-----------|----------|---------|
| `HomeWidgetService` | Flutter | Data sync, callback handling |
| `HabitWidgetProvider` | Android | AppWidgetProvider implementation |
| `HabitWidget` | iOS | WidgetKit StaticConfiguration |
| `HabitEntry` | iOS | TimelineEntry for widget data |

### Data Flow
```
┌─────────────────────────────────────────────────────────────┐
│                       Flutter App                            │
│  AppState → completeHabit() → _updateHomeWidget()           │
│                        ↓                                     │
│              HomeWidgetService.updateWidgetData()           │
│                        ↓                                     │
│         HomeWidget.saveWidgetData() (shared prefs)          │
└─────────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│                    Native Widget                             │
│  Android: SharedPreferences → HabitWidgetProvider           │
│  iOS: UserDefaults (App Group) → HabitTimelineProvider      │
└─────────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│                    Widget Tap                                │
│  URL: atomichabits://complete_habit?id=<habit_id>           │
│                        ↓                                     │
│  backgroundCallback() → Mark completed in shared storage     │
│                        ↓                                     │
│  App opens → _processPendingWidgetCompletion() → sync       │
└─────────────────────────────────────────────────────────────┘
```

### Widget Features
- **Habit Name + Emoji**: Shows current focused habit
- **Stats Display**: Current streak or Graceful Score
- **Complete Button**: One-tap habit completion
- **Visual State**: Different colors for completed/incomplete

### iOS Setup Requirements
The iOS widget requires Xcode configuration:
1. Add Widget Extension target
2. Configure App Groups for data sharing
3. See `ios/HabitWidget/README.md` for detailed steps

### Shared Data Keys
```dart
keyHabitId = 'habit_id'
keyHabitName = 'habit_name'
keyHabitEmoji = 'habit_emoji'
keyIdentity = 'identity'
keyIsCompleted = 'is_completed_today'
keyCurrentStreak = 'current_streak'
keyGracefulScore = 'graceful_score'
keyTinyVersion = 'tiny_version'
keyLastUpdate = 'last_update'
```

### URL Scheme
- **Scheme**: `atomichabits://`
- **Complete Action**: `atomichabits://complete_habit?id=<habit_id>`

---

## Phase 10: Analytics Dashboard Architecture

### Overview
The Analytics Dashboard provides a "Zoom Out" view of habit progress, visualizing Graceful Consistency over time. The key design principle: **missed days appear as small dips, not cliffs**, reinforcing the app's resilience-focused philosophy.

### New Files
```
lib/
├── features/
│   └── analytics/
│       └── analytics_screen.dart    # Interactive charts and insights
└── data/
    └── services/
        └── analytics_service.dart   # Historical data computation
```

### Key Components

| Component | Purpose |
|-----------|---------|
| `AnalyticsScreen` | Main UI with charts, period selector, insights |
| `AnalyticsService` | Data aggregation, rolling score calculation |
| `AnalyticsDataPoint` | Single data point for charts (date, score, status) |
| `PeriodSummary` | Summary statistics for a time period |
| `WeeklyBreakdown` | Bar chart data for weekly view |
| `AnalyticsPeriod` | Enum for time periods (7/14/30/90 days, All) |

### Chart Types

1. **Line Chart (Main)**
   - Graceful Consistency Score over time
   - Curved line with gradient fill
   - Dot colors: Green (completed), Orange (recovery), Gray (missed)
   - Touch tooltips showing date, score, status

2. **Bar Chart (Weekly)**
   - Weekly completion breakdown (days per week)
   - Color coding: Green (≥70%), Orange (≥40%), Gray (<40%)

### Data Flow
```
┌─────────────────────────────────────────────────────────────┐
│                      Habit Data                              │
│   - completionHistory (List<DateTime>)                       │
│   - recoveryHistory (List<RecoveryEvent>)                   │
│   - createdAt (DateTime)                                     │
└─────────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│                  AnalyticsService                            │
│   generateScoreHistory() → List<AnalyticsDataPoint>         │
│   generatePeriodSummary() → PeriodSummary                   │
│   generateWeeklyBreakdown() → List<WeeklyBreakdown>         │
└─────────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│                   AnalyticsScreen                            │
│   - Period selector chips                                    │
│   - Habit header with identity                               │
│   - Line chart with trend indicator                          │
│   - Summary card (stats grid)                                │
│   - Weekly breakdown bar chart                               │
│   - Contextual insight card                                  │
└─────────────────────────────────────────────────────────────┘
```

### Rolling Score Calculation
The `_calculateRollingScore()` method computes a smoothed Graceful Score for each day:
- Uses 7-day rolling window
- Considers days since habit creation (doesn't penalize new habits)
- Formula: `completionRate × 100` (simplified for visualization)

### Insight Generation
Insights are generated based on period data:
- **Recovery + Stable Score**: "Your recoveries kept your score stable"
- **High Completion (≥80%)**: "Excellent consistency! Building evidence..."
- **Missed Days + Small Dip**: "Notice how the score dips gently, not crashes"
- **Declining Score**: "Let's focus on the 2-minute version"
- **Default**: "Every completion is a vote for your identity"

### Navigation
- **Route**: `/analytics`
- **Access**: Analytics button (📊) in Dashboard app bar
- **Condition**: Only shown when habits exist

---

## Phase 11: Data Safety (Backup & Restore) Architecture

### Overview
The Data Safety feature protects user investment by enabling comprehensive backup and restore functionality. After building analytics, users have significant data worth protecting. This is a prerequisite for Release Candidate status.

### Philosophy
"Protecting user investment is as important as enabling it."
- Users invest time and effort tracking habits
- Completion history, recovery wins, and consistency data are valuable
- Essential for device migration, data safety, and peace of mind

### New Files
```
lib/
├── features/
│   └── settings/
│       └── data_management_screen.dart  # Backup/Restore UI
└── data/
    └── services/
        └── backup_service.dart          # Export/Import logic
```

### Key Components

| Component | Purpose |
|-----------|---------|
| `BackupService` | JSON serialization, file I/O, validation |
| `DataManagementScreen` | UI for backup/restore operations |
| `BackupResult` | Sealed class for operation results |
| `BackupSummary` | Preview of backup contents |

### Backup File Format
```json
{
  "version": 1,
  "appName": "Atomic Habits Hook App",
  "exportedAt": "2025-12-15T10:30:00.000Z",
  "habits": [...],
  "userProfile": {...},
  "appSettings": {...},
  "focusedHabitId": "uuid",
  "hasCompletedOnboarding": true
}
```

### Data Flow
```
┌─────────────────────────────────────────────────────────────┐
│                       Export Flow                            │
│                                                             │
│   Hive Box → BackupService.exportBackup()                   │
│            → Generate JSON with all data                     │
│            → Write to temp file                              │
│            → Open System Share Sheet                         │
│            → Record backup timestamp                         │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                       Import Flow                            │
│                                                             │
│   File Picker → BackupService.importBackup()                │
│              → Read and parse JSON                          │
│              → Validate structure and required keys          │
│              → Show preview (BackupSummary)                  │
│              → User confirms overwrite warning               │
│              → BackupService.restoreBackup()                │
│              → Clear and restore Hive box                   │
│              → AppState.reloadFromStorage()                 │
│              → Navigate to Dashboard                         │
└─────────────────────────────────────────────────────────────┘
```

### Validation Rules
- Required keys: `version`, `exportedAt`, `habits`, `userProfile`
- `habits` must be a valid JSON array
- Each habit must have `id` and `name` fields
- Version must be a positive integer

### What's Included in Backup
- ✅ All habits (names, identities, tiny versions, settings)
- ✅ Completion history (every day showed up)
- ✅ Streaks and scores (current, longest, Graceful Score)
- ✅ Recovery history (Never Miss Twice wins)
- ✅ User profile (name, identity statement)
- ✅ App settings (theme, notifications, sound)
- ✅ Focused habit ID
- ✅ Onboarding completion status

### Navigation
- **Route**: `/data-management`
- **Access**: Settings → Data & Storage → Backup & Restore
- **Dependencies**: `path_provider`, `share_plus`, `file_picker`, `intl`

---

## Phase 12: Bad Habit Protocol Architecture

### Overview
The Bad Habit Protocol enables users to break bad habits alongside building good ones, fully aligning with James Clear's methodology. For bad habits, **avoidance equals completion** — tracked via the same `completionHistory` mechanism but with inverted UI logic.

### Philosophy
"To break a bad habit: Make it invisible, unattractive, difficult, and unsatisfying." — James Clear

The app leverages the existing (but previously unused) `isBreakHabit` field to invert UI messaging while keeping the underlying consistency engine intact.

### Key Principle: Avoidance = Completion
For break habits:
- Marking "complete" means "I successfully avoided today"
- Streak represents "Days Habit-Free" 
- Completion rate becomes "Abstinence Rate"
- Recovery messages change to "Slipped up?" language

### UI Adaptations

| Component | Build Habit | Break Habit |
|-----------|------------|-------------|
| Action Button | "Mark as Complete ✓" | "I Stayed Strong Today 🛡️" |
| Completed Status | "Completed for today! 🎉" | "Avoided today! 💪" |
| Streak Label | "🔥 Streak" | "🛡️ Days Free" |
| Progress Label | "Consistency" | "Abstinence Rate" |
| Color Theme | Green/Orange | Purple |
| Card Icon | Check circle | Shield |
| Tiny Version | "Start tiny: {action}" | "Instead, I will: {substitution}" |

### OnboardingScreen Changes
```dart
// Build vs Break toggle
_buildHabitTypeToggle() // Segmented control

// Break habit specific fields (when _isBreakHabit = true)
- Trigger input: "What triggers this habit?"
- Root cause input: "Why do you want to break this habit?"
- Substitution plan: "What will you do instead?"
```

### RecoveryPromptDialog Changes
```dart
// Phase 12: Break habit recovery messages
getBreakHabitRecoveryTitle()    // "Slipped Up?" vs "Never Miss Twice"
getBreakHabitRecoverySubtitle() // "One slip doesn't define you"
getBreakHabitRecoveryMessage()  // Substitution-focused messaging
getBreakHabitRecoveryActionText() // "I'm staying strong today"
```

### Analytics Dashboard Changes
```dart
// Labels adapt based on habit.isBreakHabit
- "Abstinence Rate" instead of "Graceful Consistency"
- "Days Avoided" instead of "Days Completed"  
- "Avoidance Rate" instead of "Completion Rate"
- "Longest Abstinence" instead of "Best Streak"
- "Fresh Starts" instead of "Recoveries"
- Shield icon (🛡️) instead of flame (🔥)
```

### HomeWidgetService Changes
```dart
// New shared data keys for native widgets
keyIsBreakHabit = 'is_break_habit'
keyActionText = 'action_text'     // "Avoid" or "Complete"
keyStreakLabel = 'streak_label'   // "Days Free" or "Streak"
```

### Files Modified
```
lib/features/onboarding/onboarding_screen.dart     # Build/Break toggle + fields
lib/features/today/widgets/completion_button.dart  # Action text + colors
lib/features/today/widgets/habit_card.dart         # Break habit styling
lib/features/today/today_screen.dart               # Pass isBreakHabit flag
lib/features/dashboard/widgets/habit_summary_card.dart  # Card adaptations
lib/features/analytics/analytics_screen.dart       # Label changes
lib/widgets/recovery_prompt_dialog.dart            # Break habit messages
lib/data/services/recovery_engine.dart             # New message methods
lib/data/services/home_widget_service.dart         # Widget data keys
```

### Habit Model Fields (Already Existed)
```dart
// lib/data/models/habit.dart - Phase 12 leverages these existing fields:
final bool isBreakHabit;        // Toggle for break vs build
final String? replacesHabit;    // What bad habit this targets
final String? rootCause;        // Why/trigger for the habit
final String? substitutionPlan; // Healthy alternative behavior
```

### Data Handling
- **No schema changes** — `isBreakHabit` already exists in Habit model
- **Backward compatible** — defaults to `false` for existing habits
- **Same persistence** — completionHistory tracks avoidance same as completion
- **Same analytics** — AnalyticsService treats both habit types identically

---

*Last synced to main: December 2025*
