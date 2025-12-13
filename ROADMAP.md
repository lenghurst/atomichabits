# Roadmap — Atomic Achievements

> **Last Updated:** December 2024 (v1.2.3)
> **Philosophy:** Graceful Consistency > Fragile Streaks

---

## Immediate (Stabilize Core Loop)

### ✅ Completed
- [x] **Widget/App Parity (v1.2.2)** — Resume Sync Strategy ensures widget completions sync into in-memory `AppState` when the app resumes
  - `WidgetsBindingObserver` mixin in AppState
  - `_reconcileWithHive()` detects external completions
  - `cancelDailyReminder()` prevents duplicate notifications
  - Reward flow triggers for widget completions

- [x] **Home Screen Widget Implementation (v1.2.3)** — Complete Android widget using `home_widget` package
  - Widget layout (`atomic_widget.xml`) with habit name, streak, status
  - `AtomicWidgetService` with background callbacks for completion
  - Widget info XML with 2x2 cell dimensions
  - AndroidManifest updated with widget receiver and service
  - AppState integration: `_updateHomeWidget()` called on init, completion, sync
  - Empty state support for users without habits

### 🚧 In Progress

### 📋 To Do
- [ ] **Timezone Correctness** — Detect local timezone for notifications and reschedule on TZ change; add iOS permission handling
- [ ] **History Polish** — Support multi-habit filtering in the history view and provide delete/edit affordances for habits
- [ ] **Contract Deep Links** — Generate real invite links (or app links) for witnesses; track contract state per habit
- [ ] **Reminder UX** — Confirm permission status before scheduling and surface "Permission Denied" errors in UI if needed
- [ ] **Settings Implementation** — Connect SettingsScreen to actual preferences (notifications, theme, data export)

---

## Next (Growth & OS Integration)

### Features
- [ ] **Invite Lifecycle** — Add witness acceptance flow and verification; persist witness contact with messaging template
- [ ] **Home Widget v2** — Add multiple widget styles (stack vs. one-tap) and AOD toggle reflected from `AndroidConfig`
- [ ] **Notifications v2** — Add recovery nudges ("never miss twice"), contextual copy from RecoveryEngine, and snooze limit rules
- [ ] **Sync/Backups** — Introduce account system with cloud sync; guard migrations and conflicts
- [ ] **LLM Suggestions** — Replace heuristic `AiSuggestionService` with backend-powered prompts; add guardrails and caching

### Technical
- [ ] **Hive Adapters** — Generate type-safe adapters with `build_runner` for model growth
- [ ] **iOS Notifications** — Complete permission handling and notification styling
- [ ] **Error Boundaries** — Add proper error handling and crash reporting

---

## Later (Polish & Differentiation)

### User Experience
- [ ] **Accessibility** — Dynamic type, contrast check, and larger tap targets across Today/History
- [ ] **Delight** — Haptics + micro-animations on completion/recovery; celebratory states on milestones
- [ ] **Dark Mode & Theming** — User-toggle plus adaptive palette for AMOLED
- [ ] **Localization** — i18n strings and RTL layout validation

### Features
- [ ] **Insights** — Weekly/monthly systems review, trend charts, and environment-cue recommendations
- [ ] **Habit Stacking** — Link habits together with sequential triggers
- [ ] **Failure Playbooks** — Pre-planned recovery strategies with scenario matching
- [ ] **Social Accountability** — Optional sharing and accountability partner features
- [ ] **iOS Widget Support** — WidgetKit implementation

---

## Technical Debt Tracker

| Item | Priority | Status | Notes |
|------|----------|--------|-------|
| Widget concurrency guard | High | ✅ Done | `_isReconciling` lock in v1.2.2 |
| Hive type adapters | Medium | 🔴 Open | Manual JSON maps work but fragile |
| iOS notification permissions | Medium | 🔴 Open | Android-only code paths |
| History multi-habit filter | Medium | 🔴 Open | Focus habit only currently |
| Settings persistence | Low | 🔴 Open | UI stub exists |
| Timezone change handling | Low | 🔴 Open | Fixed to UTC/Local |

---

## Sprint History

### Sprint: Home Screen Widget (December 2024)
**Goal:** Complete Android home screen widget implementation

**Completed:**
- ✅ Added `home_widget: ^0.7.0` to pubspec.yaml
- ✅ Created `atomic_widget.xml` layout (habit name, streak, status)
- ✅ Created `atomic_widget_info.xml` (2x2 cell, resizable)
- ✅ Created `strings.xml` for widget description
- ✅ Updated AndroidManifest.xml (widget receiver, background service)
- ✅ Created `AtomicWidgetService` with background completion callback
- ✅ Integrated with AppState (`_updateHomeWidget()` helper)
- ✅ Widget updates on: init, completion, sync

**Files Created:**
- `android/app/src/main/res/layout/atomic_widget.xml`
- `android/app/src/main/res/xml/atomic_widget_info.xml`
- `android/app/src/main/res/values/strings.xml`
- `lib/data/services/atomic_widget_service.dart`

**Files Modified:**
- `pubspec.yaml` (+1 dependency)
- `android/app/src/main/AndroidManifest.xml` (+26 lines)
- `lib/data/app_state.dart` (+25 lines)

### Sprint: Resume Sync Strategy (December 2024)
**Goal:** Fix widget split-brain data issue

**Completed:**
- ✅ `WidgetsBindingObserver` mixin in AppState
- ✅ `didChangeAppLifecycleState()` lifecycle handler
- ✅ `_reconcileWithHive()` state comparison and sync
- ✅ `cancelDailyReminder()` in NotificationService
- ✅ Concurrency guard with `_isReconciling` lock
- ✅ Reward flow trigger for external completions
- ✅ Documentation updates (README, IMPLEMENTATION_SUMMARY_SYNC.md)

**Files Modified:**
- `lib/data/app_state.dart` (+170 lines)
- `lib/data/notification_service.dart` (+20 lines)
- `lib/features/today/controllers/today_screen_controller.dart` (+20 lines)
- `lib/features/today/today_screen.dart` (+2 lines)

### Sprint: Never Miss Twice Engine (December 2024)
**Goal:** Complete Framework Feature 31

**Completed:**
- ✅ `consecutiveMissedDays` tracking
- ✅ `neverMissTwiceScore` calculation
- ✅ Recovery urgency levels (gentle/important/compassionate)
- ✅ Flexible tracking metrics (never reset)
- ✅ Comprehensive test suite

### Sprint: Vibecoding Refactor (December 2024)
**Goal:** Clean architecture separation

**Completed:**
- ✅ Controllers for behavior logic
- ✅ Helpers for pure styling functions
- ✅ Dumb widgets pattern
- ✅ Thin orchestrator screens

---

## How to Use This Roadmap

1. **Pick an item** from "Immediate" section
2. **Check AI_CONTEXT.md** for architecture context
3. **Read relevant code citations** in feature matrix
4. **Update this file** after completing work
5. **Update AI_CONTEXT.md** if architecture changes

---

*"You do not rise to the level of your goals. You fall to the level of your systems."* — James Clear
