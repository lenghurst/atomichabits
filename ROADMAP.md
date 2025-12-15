# ROADMAP.md — Atomic Habits Hook App

> **Last Updated:** December 2025 (v4.11.0 - Phase 14 Pattern Detection)
> **Philosophy:** Graceful Consistency > Fragile Streaks
> **CRITICAL:** Keep this file in sync with `main`. Update after every sprint/session.

---

## ⚠️ AI HANDOFF PROTOCOL

### Before Starting Work
1. Read `AI_CONTEXT.md` for current architecture state
2. Read `AI_ONBOARDING_SPEC.md` for AI feature specification
3. Check this roadmap for priorities
4. Check orphaned branches: `git branch -r --no-merged main | wc -l`
5. If item exists on orphaned branch, consider rebasing instead of recreating

### After Completing Work
1. Update the relevant section below (move items, add details)
2. Add to Sprint History with date and changes
3. Cherry-pick this file to main: `git checkout main && git checkout <branch> -- ROADMAP.md`
4. Create/update PR with roadmap changes noted

---

## Current Sprint: Phase 14 (Pattern Detection - ✅ Completed)

**Goal:** Transform "Miss Reasons" into actionable insights - "The Safety Net"

**Status:** ✅ Complete (December 2025)

**Philosophy:** "Failure is data, not defeat. Every miss reason reveals a pattern to fix."

**Architecture:** Local-First, Cloud-Boosted
- Local Heuristics: Real-time pattern tags via `PatternDetectionService` (O(n) complexity)
- LLM Synthesis: Weekly pattern insights via `WeeklyReviewService` integration

**Completed:**
- [x] **MissReason Enum:** Enhanced with 5 categories (time, energy, location, forgetfulness, unexpected) + 17 specific reasons
- [x] **MissReasonCategory Enum:** New grouping for pattern detection
- [x] **MissEvent Class:** Structured miss tracking with date, reason, scheduled time, recovery status
- [x] **HabitPattern Model:** Pattern detection output with type, severity, confidence, suggestions
- [x] **PatternSummary Model:** Aggregated pattern insights with health score and tags
- [x] **PatternDetectionService:** Local heuristics engine with 7 pattern types
- [x] **Habit Model Update:** Added `missHistory` field for structured miss tracking
- [x] **RecoveryPromptDialog Update:** Category-based miss reason picker (2-step selection)
- [x] **AppState Update:** `recordMissReason()` now stores structured `MissEvent` in history
- [x] **AnalyticsScreen Update:** Pattern Insight Cards with friction detection and suggestions
- [x] **WeeklyReviewService Update:** Pattern tags included in LLM prompt for personalized coaching

**Pattern Types Detected:**
| Pattern | Tag | Description |
|---------|-----|-------------|
| Wrong Time | 🌙 Night Owl / 🌅 Morning Struggle | Habit scheduled at suboptimal time |
| Problematic Day | 📅 [Day] Struggle | Specific days consistently challenging |
| Energy Gap | ⚡ Low Energy Pattern | Energy-related misses dominate |
| Location Mismatch | 📍 Location Dependent | Environment disrupts habit |
| Forgetting | 🧠 Memory Gap | Forgetfulness issues |
| Weekend Variance | 🎉 Weekend Wobble | Different weekend behavior |
| Strong Recovery | 💪 Quick Recovery | Positive - good at bouncing back |

**Files Created:**
- `lib/data/models/habit_pattern.dart` (MissEvent, HabitPattern, PatternSummary)
- `lib/data/services/pattern_detection_service.dart`

**Files Modified:**
- `lib/data/models/consistency_metrics.dart` (MissReason enum enhanced with categories)
- `lib/data/models/habit.dart` (added missHistory field)
- `lib/data/app_state.dart` (recordMissReason stores MissEvent)
- `lib/widgets/recovery_prompt_dialog.dart` (category-based picker)
- `lib/features/analytics/analytics_screen.dart` (Pattern Insight Cards)
- `lib/data/services/weekly_review_service.dart` (LLM pattern integration)

**No Schema Changes:** New `missHistory` field uses existing JSON persistence with backward compatibility

---

## Previous Sprint: Phase 13 (Habit Stacking - ✅ Completed)

**Goal:** Enable "Chain Reaction" habit linking where completing one habit prompts the next

**Status:** ✅ Complete (December 2025)

**Philosophy:** "The best way to build a new habit is to identify a current habit you already do each day and then stack your new behavior on top." — James Clear

**Key Principle:** After completing a habit, the app prompts the user to start any stacked habits immediately, leveraging existing momentum.

**Completed:**
- [x] **CompletionResult Model:** New return type for `completeHabitForToday()` with stacking info
- [x] **AppState Methods:** `getStackedHabits()`, `getNextStackedHabit()`, `habitsWithStacksSorted`, `wouldCreateCircularStack()`
- [x] **StackPromptDialog:** Chain Reaction prompt with "Let's Do It" / "Not Now" actions
- [x] **TodayScreenController:** Updated to handle Chain Reaction flow after completion
- [x] **HabitListScreen:** Shows Chain Reaction prompt on quick-complete, sorts habits with stacks adjacent
- [x] **HabitSummaryCard:** Shows stacking indicator chip ("After X" / "Before X")
- [x] **Documentation:** Updated AI_CONTEXT.md and ROADMAP.md

**UI Adaptations:**
| Component | Normal Flow | Chain Reaction Flow |
|-----------|------------|---------------------|
| After Completion | Show Reward Dialog | Show Stack Prompt Dialog |
| Dashboard | Unsorted habits | Stacks sorted adjacent |
| Summary Card | Basic info | Shows stacking indicator |

**Files Created:**
- `lib/data/models/completion_result.dart`
- `lib/widgets/stack_prompt_dialog.dart`

**Files Modified:**
- `lib/data/app_state.dart` (stacking methods, CompletionResult return type)
- `lib/features/today/controllers/today_screen_controller.dart`
- `lib/features/dashboard/habit_list_screen.dart`
- `lib/features/dashboard/widgets/habit_summary_card.dart`
- `lib/features/today/today_screen_old.dart`
- `pubspec.yaml` (version 4.10.0+1)

**No Schema Changes:** Uses existing `anchorHabitId`, `anchorEvent`, `stackPosition` fields

---

## Previous Sprint: Phase 12 (Bad Habit Protocol - ✅ Completed)

**Goal:** Enable users to break bad habits alongside building good ones

**Status:** ✅ Complete (December 2025)

**Philosophy:** "Make it invisible, unattractive, difficult, and unsatisfying." For break habits, avoidance equals completion — tracked via the same `completionHistory` mechanism but with inverted UI logic.

**Completed:**
- [x] **OnboardingScreen:** Added Build vs Break toggle with habit type selection
- [x] **OnboardingScreen:** Break habit fields (trigger, root cause, substitution plan)
- [x] **CompletionButton:** "I Stayed Strong Today" action text for break habits
- [x] **CompletionButton:** Purple theme + shield icon for break habits
- [x] **HabitCard:** Break habit styling with "BREAKING" label and substitution display
- [x] **HabitSummaryCard:** Different colors, icons, and labels for break habits
- [x] **RecoveryPromptDialog:** "Slipped up?" messaging for break habits
- [x] **RecoveryEngine:** New break habit recovery messages and action text
- [x] **AnalyticsScreen:** "Abstinence Rate" labels and purple theme for break habits
- [x] **HomeWidgetService:** Break habit data keys (action text, streak label)
- [x] **Documentation:** Updated AI_CONTEXT.md and ROADMAP.md

**UI Adaptations:**
| Component | Build Habit | Break Habit |
|-----------|------------|-------------|
| Action Button | "Mark as Complete ✓" | "I Stayed Strong Today 🛡️" |
| Streak Label | "🔥 Streak" | "🛡️ Days Free" |
| Progress Label | "Consistency" | "Abstinence Rate" |
| Color Theme | Green | Purple |

**Files Modified:**
- `lib/features/onboarding/onboarding_screen.dart`
- `lib/features/today/widgets/completion_button.dart`
- `lib/features/today/widgets/habit_card.dart`
- `lib/features/today/today_screen.dart`
- `lib/features/dashboard/widgets/habit_summary_card.dart`
- `lib/features/analytics/analytics_screen.dart`
- `lib/widgets/recovery_prompt_dialog.dart`
- `lib/data/services/recovery_engine.dart`
- `lib/data/services/home_widget_service.dart`
- `pubspec.yaml` (version 4.9.0+1)

**No Schema Changes:** Uses existing `isBreakHabit`, `replacesHabit`, `rootCause`, `substitutionPlan` fields

---

## Previous Sprint: Phase 11 (Data Safety - ✅ Completed)

**Goal:** Protect user investment with comprehensive backup and restore functionality

**Status:** ✅ Complete (December 2025)

**Completed:**
- [x] **Dependencies:** Added `path_provider`, `share_plus`, `file_picker`, `intl`
- [x] **Service:** Created `BackupService` with export/import/validation logic
- [x] **UI:** Created `DataManagementScreen` with backup/restore UI
- [x] **Export Flow:** Generate JSON → Open System Share Sheet → Record timestamp
- [x] **Import Flow:** File picker → Validate JSON → Preview → Confirm warning → Restore

**Files Created:**
- `lib/data/services/backup_service.dart`
- `lib/features/settings/data_management_screen.dart`

---

## Previous Sprint: Phase 10 (Analytics Dashboard - ✅ Completed)

**Goal:** Build a "Zoom Out" view showing resilience where missed days appear as small dips, not cliffs

**Status:** ✅ Complete (December 2025)

**Completed:**
- [x] **Package:** Added `fl_chart: ^0.69.0` dependency
- [x] **Service:** Created `AnalyticsService` with rolling score calculation
- [x] **UI:** Created `AnalyticsScreen` with interactive trend visualizations
- [x] **Charts:** Line chart for Graceful Consistency Score (7/14/30/90 days)
- [x] **Charts:** Bar chart for weekly completion breakdown
- [x] **Resilience Visual:** Missed days as small dips, recoveries highlighted in orange
- [x] **Period Selector:** 7 Days, 14 Days, 30 Days, 90 Days, All Time
- [x] **Summary Stats:** Completed days, completion rate, recoveries, best streak
- [x] **Insights:** Context-aware insight cards based on performance
- [x] **Navigation:** `/analytics` route + Analytics button on Dashboard
- [x] **Multi-habit:** Habit picker for users with multiple habits

**Files Created:**
- `lib/features/analytics/analytics_screen.dart`
- `lib/data/services/analytics_service.dart`

**Files Modified:**
- `lib/main.dart` (added `/analytics` route + import)
- `lib/features/dashboard/habit_list_screen.dart` (Analytics button in app bar)
- `pubspec.yaml` (fl_chart dependency, version 4.7.0+1)

---

## Previous Sprint: Phase 9 (Home Screen Widgets - ✅ Completed)

**Goal:** One-tap habit completion from home screen without opening the app

**Status:** ✅ Complete (December 2025)

**Completed:**
- [x] **Service:** Created `HomeWidgetService` for widget data synchronization
- [x] **Android Widget:** Native `HabitWidgetProvider` with habit name + complete button
- [x] **iOS Widget:** WidgetKit implementation with `HabitWidget` and `HabitEntry`
- [x] **Data Sync:** Automatic widget updates on habit completion, creation, deletion
- [x] **Interactivity:** Widget tap callbacks for habit completion
- [x] **Deep Links:** URL scheme `atomichabits://` for widget actions
- [x] **Stats Display:** Shows current streak or Graceful Score on widget

**Files Created:**
- `lib/data/services/home_widget_service.dart`
- `android/app/src/main/kotlin/.../HabitWidgetProvider.kt`
- `android/app/src/main/res/layout/habit_widget.xml`
- `android/app/src/main/res/xml/habit_widget_info.xml`
- `android/app/src/main/res/drawable/widget_*.xml`
- `ios/HabitWidget/HabitWidget.swift`
- `ios/HabitWidget/Info.plist`
- `ios/HabitWidget/README.md`

**Files Modified:**
- `lib/data/app_state.dart` (HomeWidgetService integration)
- `lib/main.dart` (widget click listener setup)
- `android/app/src/main/AndroidManifest.xml` (widget receiver + deep links)
- `android/app/src/main/res/values/colors.xml` (widget colors)
- `android/app/src/main/res/values/strings.xml` (new file, widget strings)
- `ios/Runner/Info.plist` (URL scheme for deep links)
- `pubspec.yaml` (home_widget dependency, version 4.6.0+1)

---

## Previous Sprint: Phase 7 (Weekly Review - ✅ Completed)

**Goal:** AI-powered Weekly Review feature to close the Hook Model loop

**Status:** ✅ Complete (December 2025)

**Completed:**
- [x] **Service:** Created `WeeklyReviewService` for data aggregation and prompt building
- [x] **AI Integration:** Added `generateWeeklyAnalysis()` to `GeminiChatService`
- [x] **UI:** Created `WeeklyReviewDialog` with 7-day progress, stats, AI insights
- [x] **Fallback:** Local heuristic generation when AI unavailable
- [x] **History Integration:** Weekly Review card + app bar button
- [x] **Dashboard Integration:** Quick access button with habit picker

**Files Created:**
- `lib/data/services/weekly_review_service.dart`
- `lib/features/review/weekly_review_dialog.dart`

**Files Modified:**
- `lib/data/services/gemini_chat_service.dart` (generateWeeklyAnalysis method)
- `lib/main.dart` (WeeklyReviewService provider)
- `lib/features/history/history_screen.dart` (review card + button)
- `lib/features/dashboard/habit_list_screen.dart` (review button)
- `pubspec.yaml` (version bump to 4.5.0+1)

---

## Next Sprint: Phase 15 (TBD)

**Status:** 🔵 Planning

**Options for Next Phase:**
- [ ] **Smart Notifications** — AI-powered timing based on completion patterns and detected friction
- [ ] **Social Accountability** — Optional sharing features
- [ ] **Accessibility** — Dynamic type, contrast, larger tap targets
- [ ] **Cloud Sync** — Sync data across devices (Firebase/Supabase)
- [ ] **Habit Templates** — Pre-built common habits with AI suggestions
- [ ] **Advanced Stacking UI** — Visual habit chain builder

**Release Candidate Checklist:**
- [x] Phase 9: Home Screen Widgets
- [x] Phase 10: Analytics Dashboard  
- [x] Phase 11: Backup & Restore
- [x] Phase 12: Bad Habit Protocol
- [x] Phase 13: Habit Stacking
- [x] Phase 14: Pattern Detection
- [ ] Final polish and testing
- [ ] App Store / Play Store preparation

---

## Previous Sprint: Brand Polish (Phase 6.5 - ✅ Completed)

**Goal:** Custom app icon, splash screen, and enhanced error reporting

**Status:** ✅ Complete (December 2025)

**Completed:**
- [x] **Branding:** Generated custom app icon (atom + arrow design, deep purple)
- [x] **Android:** All mipmap icon sizes (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- [x] **iOS:** All AppIcon sizes (20px to 1024px, alpha removed)
- [x] **Android Splash:** Custom launch_background.xml with branded colors
- [x] **iOS Splash:** LaunchScreen.storyboard with deep purple background
- [x] **Error Reporting:** Enhanced `ErrorReporter` class with structured logging
- [x] **Config:** flutter_launcher_icons.yaml for future regeneration
- [x] **Assets:** Brand assets directory structure

**Files Created:**
- `assets/branding/app_icon.png` (1024x1024 source icon)
- `flutter_launcher_icons.yaml` (icon generation config)
- `android/app/src/main/res/values/colors.xml` (brand colors)
- `android/app/src/main/res/drawable/splash_icon.png`

**Files Modified:**
- All Android mipmap icons (ic_launcher.png)
- All iOS AppIcon images
- `android/app/src/main/res/drawable/launch_background.xml`
- `android/app/src/main/res/drawable-v21/launch_background.xml`
- `ios/Runner/Base.lproj/LaunchScreen.storyboard`
- `ios/Runner/Assets.xcassets/LaunchImage.imageset/*`
- `lib/core/error_boundary.dart` (ErrorReporter class)
- `pubspec.yaml` (version bump, assets, dev dependencies)

---

## Previous Sprint: Settings & Polish (Phase 6 - ✅ Completed)

**Goal:** Complete settings persistence and app polish

**Status:** ✅ Complete (December 2025)

**Completed:**
- [x] **Model:** Created `AppSettings` data model with persistence
- [x] **State:** Integrated settings into `AppState` with Hive storage
- [x] **Theming:** Dynamic theme switching (System/Light/Dark)
- [x] **UI:** Full `SettingsScreen` refactor with all functional settings
- [x] **Features:** Notification time picker
- [x] **Features:** Sound and haptic feedback toggles
- [x] **Features:** Motivational quotes toggle
- [x] **Features:** Reset all data with confirmation
- [x] **Polish:** Global error handling with `setupGlobalErrorHandling()`
- [x] **Polish:** Error boundary widget for graceful error recovery
- [x] **Polish:** Error/success snackbar extensions

**Files Created:**
- `lib/data/models/app_settings.dart`
- `lib/core/error_boundary.dart`

**Files Modified:**
- `lib/data/app_state.dart` (settings integration + methods)
- `lib/main.dart` (dynamic theming + error handling)
- `lib/features/settings/settings_screen.dart` (full refactor)

---

---

## Previous Sprint: History & Calendar View (Phase 5 - ✅ Completed)

**Goal:** Visual calendar showing completion history across all habits

**Status:** ✅ Complete (December 2025)

**Completed:**
- [x] **UI:** Created `HistoryScreen` with stats overview
- [x] **UI:** Created `CalendarMonthView` widget with completion dots
- [x] **UI:** Show recovery days with special blue styling
- [x] **UI:** Month navigation with previous/next buttons
- [x] **Features:** Stats: Current streak, longest streak, total days, consistency, identity votes, recoveries
- [x] **Features:** Milestones system (First Week, Three Weeks, One Month, Habit Formed, Century Club, One Year)
- [x] **Features:** Contextual insights based on habit data
- [x] **Features:** Habit switcher for multi-habit users
- [x] **Integration:** History button on TodayScreen app bar
- [x] **Integration:** History button on Dashboard app bar
- [x] **Routing:** `/history` route added

**Files Created:**
- `lib/features/history/history_screen.dart`
- `lib/features/history/widgets/calendar_month_view.dart`

**Files Modified:**
- `lib/features/today/today_screen.dart` (History button)
- `lib/features/dashboard/habit_list_screen.dart` (History button)
- `lib/main.dart` (routing)

---

## Previous Sprint: Dashboard (Phase 4 - ✅ Completed)

**Goal:** Multi-Habit Dashboard with Focus Mode Navigation

**Status:** ✅ Complete (December 2025)

**Completed:**
- [x] **UI:** Created `HabitListScreen` (Dashboard)
- [x] **UI:** Created `HabitSummaryCard` widget with quick-complete
- [x] **UI:** Updated `TodayScreen` with PageView swipe navigation
- [x] **Routing:** Dashboard is now default for returning users (`/dashboard`)
- [x] **Features:** Stats header (habits count, completed today, avg score)
- [x] **Features:** Swipe-to-delete with confirmation dialog
- [x] **Features:** Add habit options (AI Coach / Manual)

**Files Created:**
- `lib/features/dashboard/habit_list_screen.dart`
- `lib/features/dashboard/widgets/habit_summary_card.dart`

**Files Modified:**
- `lib/features/today/today_screen.dart` (PageView support)
- `lib/main.dart` (routing)

---

## Previous Sprint: Multi-Habit Engine (Phase 3 - ✅ Completed)

**Goal:** Support tracking multiple habits with Focus Mode selection

**Status:** ✅ Complete (December 2025)

**Completed:**
- [x] **State:** Refactored `AppState` from `_currentHabit` to `List<Habit> _habits`
- [x] **State:** Added `_focusedHabitId` for Focus Mode
- [x] **State:** Added CRUD methods: `createHabit()`, `updateHabit()`, `deleteHabit()`
- [x] **State:** Added focus methods: `setFocusHabit()`, `setPrimaryHabit()`, `graduateHabit()`
- [x] **Migration:** Legacy single-habit data auto-migrated on upgrade
- [x] **Backward Compat:** `currentHabit` getter works identically

---

## Previous Sprint: AI Onboarding Phase 2 (✅ Completed)

**Goal:** Implement the "Conversational First" Experience (Tier 1)

**Status:** ✅ Complete (December 2025)

**Completed:**
- [x] **UI:** Created `ConversationalOnboardingScreen` (Chat UI)
- [x] **UI:** Created `ChatMessageBubble` (User vs AI bubbles with typing indicator)
- [x] **Logic:** Implemented `OnboardingOrchestrator.sendConversationalMessage()` with response parsing
- [x] **Logic:** Wired up `GeminiChatService` for Tier 1 chat
- [x] **Logic:** Integrated `ConversationGuardrails` for frustration detection
- [x] **Migration:** Chat is now default route (`/`); Form at `/onboarding/manual`
- [x] **Testing:** Escape hatch dialog triggers on frustration patterns

**Deferred to Phase 3+:**
- [ ] Create `ClaudeChatService` (Tier 2) for "Bad Habit" premium coaching
- [ ] Test timeout/retry logic in real network conditions

---

## Previous Sprint: AI Onboarding Phase 1 (✅ Completed)

**Goal:** Infrastructure & "Magic Wand" MVP

**Status:** ✅ Complete (December 2025)

See Sprint History below for details.

---

---

## Immediate Priority (Next 1-2 Sprints)

### 🔴 High Priority

| Item | Description | Complexity | Blocked By |
|------|-------------|------------|------------|
| **AI Onboarding Phase 2** | Full conversational onboarding with Gemini/Claude | High | ✅ Complete |
| **Multiple Habits (Phase 3)** | Support tracking multiple habits with focus mode | High | ✅ Complete |
| **Dashboard (Phase 4)** | Multi-habit list view with quick actions | High | ✅ Complete |
| **History/Calendar View** | Visual calendar showing completion history | Medium | ✅ Complete |
| **Settings Implementation** | Connect SettingsScreen to actual preferences | Low | ✅ Complete |

### 🟡 Medium Priority

| Item | Description | Complexity | Notes |
|------|-------------|------------|-------|
| **Failure Playbooks** | Pre-planned recovery strategies | Medium | UX design needed |
| **Stacking UI** | UI for setting up habit stacks | Low | Enhancement to Phase 13 |

---

## Next Phase (Growth & Polish)

### Features
- [x] **Weekly Review with AI** — ✅ AI synthesis of weekly progress (Phase 7)
- [x] **Analytics Dashboard** — ✅ Trend charts, insights (Phase 10)
- [x] **Backup and Restore** — ✅ Export/import habit data (Phase 11)
- [x] **Pattern Detection from Miss Reasons** — ✅ Friction patterns with actionable insights (Phase 14)
- [ ] **Habit Pause/Vacation Mode** — Planned breaks without penalty
- [ ] **Social Accountability** — Optional sharing features

### Technical
- [ ] **Hive Type Adapters** — Generate with `build_runner` for type safety
- [ ] **iOS Notifications** — Complete permission handling
- [ ] **Error Boundaries** — Proper error handling and crash reporting
- [ ] **Timezone Robustness** — Detect TZ changes and reschedule notifications

### Platform Expansion
- [x] **Android Home Screen Widget** — ✅ One-tap completion from launcher (Phase 9)
- [x] **iOS Widget Support** — ✅ WidgetKit implementation (Phase 9)

---

## Later (Differentiation)

### User Experience
- [ ] **Accessibility** — Dynamic type, contrast check, larger tap targets
- [ ] **Delight** — Haptics + micro-animations on completion/recovery
- [ ] **Dark Mode & Theming** — User-toggle plus adaptive palette
- [ ] **Localization** — i18n strings and RTL layout validation

### Advanced Features
- [ ] **Insights Engine** — AI-powered recommendations based on patterns
- [ ] **Habit Contracts** — Accountability agreements with witnesses
- [ ] **Deep Links** — Share habits, invite accountability partners

---

## Technical Debt Tracker

| Item | Priority | Status | Notes |
|------|----------|--------|-------|
| Stale branches cleanup | High | 🔴 Open | 18+ unmerged branches |
| Settings persistence | Medium | ✅ Done | Full persistence via Hive |
| Hive type adapters | Medium | 🔴 Open | Manual JSON maps work but fragile |
| iOS notification permissions | Medium | 🔴 Open | Android-only code paths |
| Timezone change handling | Low | 🔴 Open | Fixed to UTC/Local |
| Remove unnecessary imports | Low | 🔴 Open | flutter analyze warnings |

---

## Sprint History

### Sprint: Data Safety (Phase 11) - December 2025 ✅

**Goal:** Protect user investment with comprehensive backup and restore functionality

**Context:**
- Users have invested significant time building habits and tracking progress
- After Analytics (Phase 10), data protection becomes essential
- Prerequisite for Release Candidate status
- Philosophy: "Protecting user investment is as important as enabling it"

**Completed:**
- ✅ Added `path_provider`, `share_plus`, `file_picker`, `intl` dependencies
- ✅ Created `BackupService` with export/import/validation logic
- ✅ Created `DataManagementScreen` with full backup/restore UI
- ✅ Export flow: JSON generation → System Share Sheet → Timestamp recording
- ✅ Import flow: File picker → Validation → Preview → Confirm → Restore
- ✅ Backup validation with required keys and structure checks
- ✅ Added `reloadFromStorage()` to AppState for seamless restore
- ✅ Added `/data-management` route
- ✅ Updated Settings with "Data & Storage" section

**Files Created:**
- `lib/data/services/backup_service.dart`
- `lib/features/settings/data_management_screen.dart`

**Files Modified:**
- `lib/main.dart` (added `/data-management` route + import)
- `lib/data/app_state.dart` (added `reloadFromStorage()` method)
- `lib/features/settings/settings_screen.dart` (Data & Storage section)
- `pubspec.yaml` (dependencies, version 4.8.0+1)
- `AI_CONTEXT.md`, `ROADMAP.md` (documentation)

**Key Design Decisions:**
- JSON format with versioning for future compatibility
- Filename: `atomic_habits_backup_YYYY-MM-DD.json`
- System share sheet for maximum platform compatibility
- Destructive restore requires explicit confirmation
- Backup includes ALL user data (habits, history, settings, profile)

---

### Sprint: Analytics Dashboard (Phase 10) - December 2025 ✅

**Goal:** Build a "Zoom Out" view showing resilience, where missed days appear as small dips

**Context:**
- Provides visual gratification for collected data (Hook Model: Variable Reward)
- Reinforces "Graceful Consistency > Fragile Streaks" philosophy
- Missed days appear as gentle dips, not catastrophic cliffs
- Leverages `fl_chart` package for interactive visualizations

**Completed:**
- ✅ Added `fl_chart: ^0.69.0` dependency
- ✅ Created `AnalyticsService` with rolling score calculation
- ✅ Created `AnalyticsScreen` with interactive trend charts
- ✅ Line chart: Graceful Consistency over time (7/14/30/90 days, All Time)
- ✅ Bar chart: Weekly completion breakdown
- ✅ Resilience visual: Different dot colors for completed/recovery/missed
- ✅ Period summary: Stats card with completion rate, recoveries, best streak
- ✅ Contextual insights based on habit performance
- ✅ Habit picker for multi-habit users
- ✅ Added `/analytics` route to GoRouter
- ✅ Added Analytics button (📊) to Dashboard app bar

**Files Created:**
- `lib/features/analytics/analytics_screen.dart`
- `lib/data/services/analytics_service.dart`

**Files Modified:**
- `lib/main.dart` (added `/analytics` route + import)
- `lib/features/dashboard/habit_list_screen.dart` (Analytics button in app bar)
- `pubspec.yaml` (fl_chart dependency, version 4.7.0+1)
- `AI_CONTEXT.md`, `ROADMAP.md` (documentation)

**Key Design Decisions:**
- Rolling 7-day window for score smoothing (missed days = dips, not cliffs)
- Recovery days highlighted in orange (celebrating resilience)
- Touch tooltips show date, score, and status
- Insight card adapts to user's performance patterns

---

### Sprint: Home Screen Widgets (Phase 9) - December 2025 ✅

**Goal:** One-tap habit completion from home screen without opening the app

**Context:**
- Reduces friction for habit completion (Fogg's Behavior Model: Ability)
- High visibility on home screen acts as environmental cue (Atomic Habits: Make it Obvious)
- Supports both Android and iOS platforms via `home_widget` package

**Completed:**
- ✅ Added `home_widget: ^0.7.0` dependency
- ✅ Created `HomeWidgetService` for data sync and callback handling
- ✅ Created Android `HabitWidgetProvider` with native widget layout
- ✅ Created iOS `HabitWidget` using WidgetKit
- ✅ Integrated widget updates into `AppState` (create, complete, delete, focus)
- ✅ Implemented background callback for widget tap completion
- ✅ Added URL scheme `atomichabits://` for deep linking

**Files Created:**
- `lib/data/services/home_widget_service.dart`
- `android/app/src/main/kotlin/.../HabitWidgetProvider.kt`
- `android/app/src/main/res/layout/habit_widget.xml`
- `android/app/src/main/res/xml/habit_widget_info.xml`
- `android/app/src/main/res/drawable/widget_*.xml`
- `android/app/src/main/res/values/strings.xml`
- `ios/HabitWidget/HabitWidget.swift`
- `ios/HabitWidget/Info.plist`
- `ios/HabitWidget/README.md`

**Files Modified:**
- `lib/data/app_state.dart` (HomeWidgetService integration)
- `lib/main.dart` (widget click listener)
- `android/app/src/main/AndroidManifest.xml` (widget receiver)
- `android/app/src/main/res/values/colors.xml` (widget colors)
- `ios/Runner/Info.plist` (URL scheme)
- `pubspec.yaml` (version 4.6.0+1)
- `AI_CONTEXT.md`, `ROADMAP.md` (documentation)

**Widget Features:**
- Shows habit name with emoji
- Shows current streak or Graceful Score
- One-tap complete button
- Visual state (purple = incomplete, green = completed)
- Opens app when tapped elsewhere

**Note:** iOS widget requires manual Xcode setup (App Groups, Widget Extension target). See `ios/HabitWidget/README.md`.

---

### Sprint: Weekly Review with AI (Phase 7) - December 2025 ✅

**Goal:** Implement "Investment" phase of Hook Model - AI-powered weekly insights

**Context:**
- Closes the Hook Model loop: Trigger → Action → Variable Reward → **Investment**
- Users invest time reviewing progress, which increases commitment to next cycle
- Leverages existing `GeminiChatService` infrastructure

**Completed:**
- ✅ Added `generateWeeklyAnalysis()` to `GeminiChatService` for single-turn AI
- ✅ Created `WeeklyReviewService` with data aggregation and prompt building
- ✅ Created `WeeklyReviewDialog` with 7-day progress dots and stats
- ✅ Implemented local fallback heuristics when AI unavailable
- ✅ Integrated Weekly Review button (✨) into History screen
- ✅ Integrated Weekly Review button into Dashboard with habit picker
- ✅ Registered `WeeklyReviewService` via `ProxyProvider`

**Files Created:**
- `lib/data/services/weekly_review_service.dart`
- `lib/features/review/weekly_review_dialog.dart`

**Files Modified:**
- `lib/data/services/gemini_chat_service.dart` (new method)
- `lib/main.dart` (provider registration)
- `lib/features/history/history_screen.dart` (review card + button)
- `lib/features/dashboard/habit_list_screen.dart` (review button + picker)
- `pubspec.yaml` (version 4.5.0+1)
- `AI_CONTEXT.md`, `ROADMAP.md` (documentation)

**Key Commits:**
- `8966769` - feat(review): Implement Phase 7 Weekly Review with AI (v4.5.0)

**AI Prompt Design Principles:**
- Graceful Consistency philosophy (no shaming)
- Identity-focused language ("becoming the person...")
- Celebrates recovery ("Never Miss Twice")
- Actionable tips (2-minute rule suggestions)
- Under 50 words, warm but professional

---

### Sprint: AI Onboarding Phase 2 - Conversational UI (December 2025) ✅

**Goal:** Implement "Conversational First" Experience

**Context:**
- Chat UI as default onboarding route
- Form-based onboarding preserved as manual fallback (Tier 3)
- Frustration detection for seamless escape hatch

**Completed:**
- ✅ Created `ConversationalOnboardingScreen` (Chat UI)
  - Name collection → Identity → Habit creation flow
  - Escape hatch dialog (frustration detection)
  - Habit confirmation dialog with data preview
  - Auto-scroll, typing indicator, error handling
- ✅ Created `ChatMessageBubble` widget
  - User/AI message styling with avatars
  - Animated typing indicator (staggered dots)
  - Error state display, streaming support
- ✅ Updated `OnboardingOrchestrator`
  - Added `ConversationResult` class
  - Added `sendConversationalMessage()` for Phase 2 chat
  - Added `startConversation()` method
  - Integrated `ConversationGuardrails` frustration detection
  - Habit data extraction ([HABIT_DATA] parsing)
- ✅ Updated `main.dart` routing
  - `/` → ConversationalOnboardingScreen (chat default)
  - `/onboarding/manual` → OnboardingScreen (form fallback)
  - ChangeNotifierProxyProvider for OnboardingOrchestrator

**Files Created:**
- `lib/features/onboarding/conversational_onboarding_screen.dart`
- `lib/features/onboarding/widgets/chat_message_bubble.dart`

**Files Modified:**
- `lib/data/services/onboarding/onboarding_orchestrator.dart`
- `lib/main.dart`

**Key Commits:**
- `2cb2972` - feat(onboarding): Implement Phase 2 Conversational UI

---

### Sprint: AI Onboarding Phase 1 - Magic Wand (December 2025) ✅

**Goal:** Infrastructure & "Magic Wand" MVP

**Context:**
- Solved "Empty State Problem" without full chat UI complexity
- Fixed critical "Data Amnesia" bug (AI metadata was being lost on save)
- Collaborative spec development between Claude, Gemini, and user
- Three-tier AI architecture: Gemini (fast) → Claude (deep) → Manual (fallback)

**Completed:**
- ✅ Created `AI_ONBOARDING_SPEC.md` v4.0.0 (comprehensive spec)
- ✅ Updated `Habit` model with 7 new AI fields
- ✅ Cherry-picked `GeminiChatService`, `ChatConversation`, `ChatMessage` from orphaned branches
- ✅ Created `OnboardingData` model (DTO for AI ↔ Habit mapping)
- ✅ Created `AiResponseParser` helper (`[HABIT_DATA]` JSON extraction)
- ✅ Created `ConversationGuardrails` config (frustration detection patterns)
- ✅ Created `AIModelConfig` config (API keys, timeouts, tier selection)
- ✅ Created `OnboardingOrchestrator` service (The "Brain")
- ✅ Created `MagicWandButton` widget (The "Body")
- ✅ Integrated Magic Wand button into `OnboardingScreen`
- ✅ **Fixed "Data Amnesia"** - AI metadata fields now preserved on save
- ✅ Updated `main.dart` with MultiProvider for AI services
- ✅ Updated `AI_CONTEXT.md` with new architecture

**Files Created:**
- `AI_ONBOARDING_SPEC.md`
- `lib/data/models/onboarding_data.dart`
- `lib/data/models/chat_conversation.dart` (cherry-picked)
- `lib/data/models/chat_message.dart` (cherry-picked)
- `lib/data/services/gemini_chat_service.dart` (cherry-picked)
- `lib/data/services/onboarding/onboarding_orchestrator.dart`
- `lib/data/services/onboarding/ai_response_parser.dart`
- `lib/data/services/onboarding/conversation_guardrails.dart`
- `lib/config/ai_model_config.dart`
- `lib/features/onboarding/widgets/magic_wand_button.dart`

**Files Modified:**
- `lib/data/models/habit.dart` (7 new AI fields)
- `lib/features/onboarding/onboarding_screen.dart` (Magic Wand integration + Data Amnesia fix)
- `lib/main.dart` (MultiProvider setup)

**Key Commits:**
- `d54a6c9` - fix(onboarding): Prevent Data Amnesia - preserve AI metadata fields
- `0614614` - feat(onboarding): Implement Phase 1 Magic Wand AI feature
- `5a17228` - feat(onboarding): Add Phase 1 backend/logic infrastructure
- `fcbe9d5` - feat(ai-onboarding): Add AI Onboarding spec and Phase 1 infrastructure

---

### Sprint: Documentation Sync (December 2024)
**Goal:** Establish AI Handoff Protocol and sync docs to main

**Context:** 
- Discovered AI_CONTEXT.md and ROADMAP.md existed on orphaned branches
- 18+ unmerged branches with potentially valuable work
- New AI sessions couldn't find documentation, recreated it

**Completed:**
- ✅ Cherry-picked AI_CONTEXT.md from `claude/setup-atomic-achievements-architecture-*`
- ✅ Cherry-picked ROADMAP.md from same branch
- ✅ Updated both files to reflect actual main branch state (v1.0.0+1)
- ✅ Added AI Handoff Protocol sections to both files
- ✅ Documented orphaned branch inventory

**Files Modified:**
- `AI_CONTEXT.md` (rewritten to match main)
- `ROADMAP.md` (rewritten to match main)

---

### Previous Sprints (from git history)

#### Never Miss Twice Engine (December 2024)
- ✅ `consecutiveMissedDays` tracking
- ✅ `neverMissTwiceScore` calculation  
- ✅ Recovery urgency levels (gentle/important/compassionate)
- ✅ Flexible tracking metrics (never reset)
- ✅ Comprehensive test suite

#### Vibecoding Refactor (December 2024)
- ✅ Controllers for behavior logic
- ✅ Helpers for pure styling functions
- ✅ Dumb widgets pattern
- ✅ Thin orchestrator screens

#### Async Suggestions Upgrade (December 2024)
- ✅ Remote LLM endpoint support with 5s timeout
- ✅ Local heuristic fallback
- ✅ Loading states in UI
- ✅ Parallel fetching for combined suggestions

#### AI Suggestion System (December 2024)
- ✅ Local heuristic engine for all 4 suggestion types
- ✅ "Get Ideas" buttons in onboarding
- ✅ "Get optimization tips" on Today screen
- ✅ SuggestionDialog widget

#### "Make it Attractive" Features (December 2024)
- ✅ Temptation bundling field
- ✅ Pre-habit ritual with 30s timer
- ✅ Environment cues and distraction guardrails
- ✅ Notification copy includes temptation bundle

#### Initial Release (December 2024)
- ✅ Identity-based onboarding
- ✅ Single habit tracking
- ✅ Graceful Consistency system
- ✅ Daily notifications
- ✅ Reward flow with confetti

---

## Orphaned Branches with Valuable Work

> **Action Required:** Review these branches before starting related work

| Branch Pattern | Contains | Recommendation | Status |
|----------------|----------|----------------|--------|
| `claude/ai-conversational-first-page-*` | `GeminiChatService`, `ChatConversation` | ✅ **Cherry-picked for Phase 1** | ✅ Done |
| `claude/habit-substitution-guardrails-*` | `BadHabitScreen`, substitution logic | **Cherry-pick for Phase 2** | 🟡 Next |
| `claude/setup-atomic-achievements-*` | Home Widget, Multi-habit setup | Cherry-pick widget code | 🟡 Later |
| `claude/merge-missing-code-*` | `PremiumAiOnboardingService` | Review prompts for Claude tier | 🟡 Reference |
| `claude/phase-4-identity-avatar-*` | Avatar cosmetics system | Review scope for gamification | 🔵 Later |
| `codex/create-node.js-backend-*` | Backend API | Review for LLM backend | 🔵 Later |
| `claude/claude-md-*` | CLAUDE.md | Consider merging | 🔵 Optional |
| `claude/atomic-habits-android-app-*` | FEATURE_ROADMAP.md | Close (superseded) | ⚪ Delete |

**Cleanup Command:**
```bash
# List all unmerged branches with last commit date
for branch in $(git branch -r --no-merged main); do
  echo "$branch: $(git log -1 --format='%ai %s' $branch)"
done | sort
```

---

## How to Use This Roadmap

### For AI Agents
1. **Session Start:** Read this file to understand priorities
2. **Pick Work:** Choose from "Current Sprint" or "Immediate Priority"
3. **Check Branches:** See if work already exists on orphaned branch
4. **Do Work:** Follow AI_CONTEXT.md for architecture
5. **Session End:** Update this file, cherry-pick to main

### For Humans
1. **Review Priorities:** Reorder items based on product needs
2. **Review Branches:** Approve/close orphaned PRs
3. **Review Sprints:** Check sprint history for context

---

## Success Metrics

| Metric | Current | Target | Notes |
|--------|---------|--------|-------|
| Orphaned branches | 18+ | < 5 | Need cleanup |
| Test coverage | ~70% | 80%+ | Good foundation |
| Doc sync to main | ✅ Now | Always | New protocol |
| Time to onboard new AI | ~30 min | < 10 min | With Big Three docs |
| Phase 1 Magic Wand | ✅ | ✅ | Complete! |
| Phase 2 Conversational UI | ✅ | ✅ | Complete! |
| Phase 3 Multi-Habit Engine | ✅ | ✅ | Complete! |
| Phase 4 Dashboard | ✅ | ✅ | Complete! |
| Phase 5 History & Calendar | ✅ | ✅ | Complete! |
| Phase 6 Settings & Polish | ✅ | ✅ | Complete! |
| Phase 7 Weekly Review with AI | ✅ | ✅ | Complete! |
| Phase 9 Home Screen Widgets | ✅ | ✅ | Complete! |
| Phase 10 Analytics Dashboard | ✅ | ✅ | Complete! |
| Phase 11 Backup & Restore | ✅ | ✅ | Complete! |
| Phase 12 Bad Habit Protocol | ✅ | ✅ | Complete! |
| Phase 13 Habit Stacking | ✅ | ✅ | Complete! |
| Phase 14 Pattern Detection | ✅ | ✅ | Complete! |
| Release Candidate Ready | 🟡 | ✅ | Pending final polish |

---

*"You do not rise to the level of your goals. You fall to the level of your systems."* — James Clear

*Last synced to main: December 2025*
