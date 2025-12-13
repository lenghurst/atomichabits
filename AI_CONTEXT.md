# AI_CONTEXT: Atomic Achievements Knowledge Checkpoint

> **Last Updated:** December 2024 (v1.2.3 — Home Screen Widget Implementation)
> **Purpose:** Save state for AI development agents working on this codebase

---

## Feature Matrix

| Feature | UI Layer | State Layer | Persistence Layer | Status | Code Citations |
|---------|----------|-------------|-------------------|--------|----------------|
| Multi-Habit Core | HabitSelectionSheet | `_habits`, `setFocusHabit` | Hive box (List) | ✅ Live | app_state.dart (Lines 200, 290) |
| Habit Contracts | HabitContractScreen | `updateHabitContract` | Habit.contract (JSON) | ✅ Live | habit_contract_screen.dart, app_state.dart (Line 301) |
| Android Home Widget | atomic_widget.xml | AtomicWidgetService | HomeWidget + Hive | ✅ Live | atomic_widget_service.dart (Line 41) |
| **Widget/App Sync** | TodayScreen lifecycle | `_reconcileWithHive()` | Hive reconciliation | ✅ Live | app_state.dart (Lines 181-308) |
| Actionable Notifications | Native Actions | `_handleNotificationAction` | flutter_local_notifications | ✅ Live | notification_service.dart (Line 182), app_state.dart (Line 572) |
| History / Calendar | HistoryScreen | `isDateCompleted` | Habit.completionHistory | ✅ Live | history_screen.dart, app_state.dart (Line 522) |
| Onboarding Flow | OnboardingScreen | `completeOnboarding` | hasCompletedOnboarding | ✅ Live | onboarding_screen.dart, app_state.dart (Line 183) |
| Never Miss Twice | RecoveryBanner, RecoveryPromptDialog | `RecoveryEngine`, `_checkRecoveryNeeds` | recoveryHistory (JSON) | ✅ Live | recovery_engine.dart, app_state.dart |
| Graceful Consistency | GracefulConsistencyCard | `ConsistencyMetrics` | completionHistory (JSON) | ✅ Live | consistency_metrics.dart, graceful_consistency_card.dart |
| Settings / Data | SettingsScreen (Stub) | ❌ None | ❌ None | 🚧 Partial | settings_screen.dart (UI only) |
| AI Suggestions | SuggestionDialog | AiSuggestionService | ❌ Local Heuristic Only | ⚠️ Partial | ai_suggestion_service.dart (No Remote LLM) |

---

## 1) Philosophy: Four Laws → Product Features

### Make it Obvious (Law #1)
- **Android home widget** shows focus habit name/streak and allows one-tap completion from the launcher
- Empty-state prompts users to set a focus habit
- **Notifications** provide time-based cues (with snooze) tied to implementation intentions
- **Environment cues** modeled in `Habit` for visual trigger placement

### Make it Attractive (Law #2)
- **Identity framing** on Today and contract copy reinforces "who you are"
- **Temptation bundles** and **pre-habit rituals** modeled in `Habit` for pairing habits with enjoyable cues
- AI suggestions offer personalized bundling ideas

### Make it Easy (Law #3)
- **Tiny version field** — 2-minute rule implementation
- **One-tap completion** (widget + notification action) reduces friction
- **Quick-add HabitSelectionSheet** for fast habit switching
- CreateHabitScreen defaults to immediate focus and optional reminder setup

### Make it Satisfying (Law #4)
- **Graceful Consistency metrics** replace fragile streaks
- **Identity vote counts** — every completion is a vote for your identity
- **Recovery wins** celebrated, not hidden
- **History calendar** provides visual proof of progress
- **Reward flow** with confetti and investment prompts

---

## 2) Architecture Snapshot

### Platform/Stack
- **Flutter** (Dart 3) — Cross-platform UI framework
- **Provider/ChangeNotifier** (`AppState`) — State management
- **GoRouter** (ShellRoute bottom nav) — Navigation
- **Hive** — Local persistence (NoSQL)
- **flutter_local_notifications** — Daily reminders
- **home_widget** — Android launcher widget
- **table_calendar** — History view
- **share_plus** — Contract sharing
- **timezone** — Notification scheduling

### State Management
```
AppState (ChangeNotifier + WidgetsBindingObserver)
├── User profile, habits list, focus habit ID
├── Graceful Consistency logic
├── Recovery detection (Never Miss Twice)
├── Resume Sync Strategy (widget split-brain reconciliation)
└── Notification scheduling
```

Single `AppState` ChangeNotifier created in `MyApp` and injected via Provider; controllers (e.g., `TodayScreenController`) orchestrate UI actions while widgets stay presentational (Vibecoding pattern).

### Navigation
- GoRouter with redirect to onboarding
- `StatefulShellRoute` surfaces Today, History, and Settings via `ScaffoldWithNavBar`
- Additional routes for habit creation and contract signing

### Persistence
- One Hive box `habit_data` storing:
  - `hasCompletedOnboarding` (bool)
  - `userProfile` (JSON)
  - `habits` list (JSON) — or legacy `currentHabit`
  - `focusHabitId` (String)
- AppState loads/migrates legacy `currentHabit`, saves on mutations, and updates widget after persistence

### Notifications
- `NotificationService` initializes flutter_local_notifications with action IDs `mark_done`/`snooze`
- Delegates responses to AppState's `_handleNotificationAction`
- Recovery notifications scheduled for 9 AM after missed days
- `cancelDailyReminder()` for widget sync (v1.2.2)

### Home Widget
- `AtomicWidgetService` synchronizes focus habit snapshot to Android home_widget data keys
- Processes background tap callbacks to mark completion directly in Hive
- **Resume Sync Strategy** (v1.2.2): App reconciles with Hive on resume to detect widget completions

---

## 3) Gotchas & Non-Obvious Decisions

### Widget Background Sync (RESOLVED in v1.2.2)
- ~~Widget background completion updates Hive directly and does **not** run AppState logic~~
- **Now Fixed:** `AppState` implements `WidgetsBindingObserver` and calls `_reconcileWithHive()` on `AppLifecycleState.resumed`
- Detects external completions, cancels notifications, triggers reward flow
- Concurrency guard (`_isReconciling`) prevents race conditions

### Timezone Handling
- Fixed to UTC/Local in `NotificationService`
- Robust local timezone detection/change handling is **not yet implemented**

### Migration Logic
- `migrateSingleToMulti` only runs when no habits exist in the new list
- Legacy `currentHabit` is converted and focus set automatically

### Nav Gating
- Navigation shell assumes onboarding completion
- Deep links into `/today` or `/history` redirect to onboarding until `hasCompletedOnboarding` is true

### Invite Links
- Share/invite relies on `share_plus`
- If unavailable, ContractScreen prints to console
- **No deep links (Firebase/UniLinks)** are generated yet

---

## 4) Technical Debt / Missing Pieces

### Resolved (v1.2.2)
- ✅ **Widget/App Parity** — Resume Sync Strategy implemented
- ✅ **Concurrency Guard** — `_isReconciling` lock prevents race conditions
- ✅ **Notification Cancellation** — `cancelDailyReminder()` for external completions

### Outstanding
- **Hive Adapters:** Not generated (manual JSON maps only); model growth may benefit from `build_runner` adapters for type safety
- **Platform Specifics:** Notification permissions are Android-only code paths; iOS/web fallbacks are minimal
- **History limitations:** View is read-only for the *focus* habit only. No filtering across multiple habits and no deletion/edit affordances
- **AI Service:** `AiSuggestionService` is a local-heuristic stub; there is no backend/LLM endpoint or auth layer connected
- **Settings Screen:** UI-only stub, no actual settings persistence
- **Timezone Robustness:** No TZ change detection or rescheduling

---

## 5) Key Files Reference

### Core State
| File | Purpose |
|------|---------|
| `lib/data/app_state.dart` | Central state management, lifecycle observer, reconciliation |
| `lib/data/notification_service.dart` | Notifications, daily reminders, recovery alerts |
| `lib/data/ai_suggestion_service.dart` | Local heuristic suggestions |

### Models
| File | Purpose |
|------|---------|
| `lib/data/models/habit.dart` | Habit data model with consistency tracking |
| `lib/data/models/user_profile.dart` | User identity and preferences |
| `lib/data/models/consistency_metrics.dart` | Graceful Consistency scoring system |

### Services
| File | Purpose |
|------|---------|
| `lib/data/services/recovery_engine.dart` | Never Miss Twice detection & messaging |

### Features
| File | Purpose |
|------|---------|
| `lib/features/today/today_screen.dart` | Main habit view (thin orchestrator) |
| `lib/features/today/controllers/today_screen_controller.dart` | Behavior logic, dialog management |
| `lib/features/onboarding/onboarding_screen.dart` | Initial setup flow |
| `lib/features/settings/settings_screen.dart` | Settings (stub) |

### Widgets
| File | Purpose |
|------|---------|
| `lib/widgets/graceful_consistency_card.dart` | Consistency metrics display |
| `lib/widgets/recovery_prompt_dialog.dart` | Compassionate recovery UI |
| `lib/widgets/reward_investment_dialog.dart` | Hook Model reward flow |

---

## 6) Version History

| Version | Feature | Key Changes |
|---------|---------|-------------|
| 1.0.0 | Initial Release | Onboarding, single habit, streaks |
| 1.1.0 | Graceful Consistency | Rolling averages, recovery tracking, identity votes |
| 1.2.0 | Vibecoding Refactor | Controllers, helpers, dumb widgets pattern |
| 1.2.1 | Never Miss Twice Engine | Complete recovery detection and messaging |
| 1.2.2 | Resume Sync Strategy | Widget split-brain fix, lifecycle reconciliation |
| **1.2.3** | **Home Screen Widget** | Android widget XML, AtomicWidgetService, background completion |

---

## 7) Home Screen Widget Architecture

### Components
- **Android Layout:** `android/app/src/main/res/layout/atomic_widget.xml`
- **Widget Info:** `android/app/src/main/res/xml/atomic_widget_info.xml`
- **Dart Service:** `lib/data/services/atomic_widget_service.dart`
- **AndroidManifest:** Updated with widget receiver, background receiver, and service

### Data Keys (shared between Dart and Android)
- `habit_name` — Display name of focus habit
- `habit_streak` — Current streak count
- `habit_completed` — Whether completed today
- `habit_tiny_version` — 2-minute version reminder
- `habit_id` — Unique ID for verification

### Flow
1. **Widget tap** → Background callback → Direct Hive update
2. **App resume** → `_reconcileWithHive()` → Detect external completion
3. **App completion** → `_updateHomeWidget()` → Sync widget display

---

*This file serves as a knowledge checkpoint for AI agents. Update after significant changes.*
