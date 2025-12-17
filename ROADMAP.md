# ROADMAP.md — Atomic Habits Hook App

> **Last Updated:** December 2025 (v5.7.0-RC1 - Phase 24 "The Red Carpet" Active)
> **Philosophy:** Graceful Consistency > Fragile Streaks
> **CRITICAL:** Keep this file in sync with `main`. Update after every sprint/session.

---

## ⚠️ AI HANDOFF PROTOCOL

### Before Starting Work
1. Read `AI_CONTEXT.md` for current architecture state
2. Check `lib/data/services/witness_service.dart` (The "Network")
3. Check `lib/data/services/pattern_detection_service.dart` (The "Brain")
4. Check `lib/data/notification_service.dart` (The "Voice")

### After Completing Work
1. Update the relevant section below (move items, add details)
2. Add to Sprint History with date and changes
3. Cherry-pick this file to main: `git checkout main && git checkout <branch> -- ROADMAP.md`
4. Create/update PR with roadmap changes noted

---

## Current Sprint: Phase 24 "The Red Carpet" (🟡 In Progress)

**Goal:** Zero-friction onboarding for Invited Witnesses. Maximize conversion of invited users.

**Status:** 🟡 In Progress (December 2025)

**Platform Focus:** Android First (Intent Handling)

**Constraint:** Low operational cost (Minimize Edge Functions)

**Philosophy:** "Revenue = f(Viral Coefficient)². Optimize virality BEFORE monetization."

### Key Strategic Pivots (Dec 2025)

#### 1. Deep Link Architecture: "The Standard Protocol"
**PIVOTED** from "Clipboard Bridge" (sketchy) to **Install Referrer API** (industry standard).

**New Architecture:**
```
1. Landing Page (atomichabits.app/join/xyz)
2. → Fingerprints click + Redirects to Play Store with referrer=invite_code=xyz
3. User installs app
4. → App reads AndroidPlayInstallReferrer
5. → Decodes invite_code
6. → Hard Bypass to WitnessAcceptScreen (skip onboarding)
```

#### 2. AI Engine: "Brain Surgery 2.0"
Refactored AI tier system for better reasoning and cost efficiency:

| Tier | Provider | Persona | Use Case |
|------|----------|---------|----------|
| 1 (Default) | **DeepSeek-V3** | The Architect | Reasoning-heavy, structured output |
| 2 (Premium) | **Claude 3.5 Sonnet** | The Coach | Empathetic, high EQ for bad habits |
| 3 (Fallback) | Gemini 2.5 Flash | AI Assistant | Fast, reliable backup |
| 4 (Manual) | None | Manual Entry | No AI available |

**Why DeepSeek:**
- Excellent at THINKING PROTOCOL and structured JSON output
- Cost-effective (10-100x cheaper than Claude/GPT-4)
- Higher temperature (1.0-1.3) for better reasoning
- OpenAI-compatible API

**Files Created:**
- `lib/data/services/ai/deep_seek_service.dart` - Tier 1 implementation
- `lib/data/services/ai/claude_service.dart` - Tier 2 implementation
- `lib/data/services/ai/ai_service_manager.dart` - Unified tier management
- `lib/data/services/ai/ai.dart` - Module exports

**Files Modified:**
- `lib/config/ai_model_config.dart` - Added DeepSeek, updated tier selection

### Technical Tasks

**AI Refactor (✅ Complete):**
- [x] Create `DeepSeekService` (Tier 1 - The Architect)
- [x] Create `ClaudeService` (Tier 2 - The Coach)
- [x] Create `AIServiceManager` for unified tier management
- [x] Update `AIModelConfig` with DeepSeek key and tier logic

**Deep Link Infrastructure (The "Standard Protocol") - ✅ Complete:**
- [x] Add `play_install_referrer` package (v0.5.0)
- [x] Implement Install Referrer detection in `DeepLinkService`
- [x] Add `checkForDeferredDeepLink()` with loading state handling
- [x] Update `OnboardingOrchestrator` for Hard Bypass routing
- [x] Add Smart Link generation in `ShareContractSheet`
- [ ] Create landing page logic for referrer injection (web deployment pending)

**UI/UX (Completed):**
- [x] "Socially Binding Pact" UI (Wax Seal animation)
- [x] Tap-and-hold to sign with haptic feedback
- [x] Guest Data Warning banner (GuestDataWarningBanner widget)

**Testing (Completed):**
- [x] DeepSeekService unit tests with mocks
- [x] ClaudeService Dependency Injection refactor
- [x] AIServiceManager tier selection tests
- [x] JSON parsing verification (Recovery Plan format)

**Web Anchor (Completed):**
- [x] InviteRedirector.tsx component (React landing page)
- [x] /join/:inviteCode route added
- [x] ShareContractSheet updated to use Web Anchor URLs
- [x] DeepLinkConfig.getWebAnchorUrl() method added

**See:** `SPRINT_24_SPEC.md` for full technical specification

---

## Previous Sprint: Phase 23 - Clean Slate (✅ Completed)

**Status:** ✅ Complete (December 2025)

**Goal:** Technical debt cleanup and foundation for growth optimizations

**Completed:**
- [x] **Branch Cleanup:** Merged `genspark_ai_developer` to `main` via PR #11
- [x] **Documentation Sync:** Updated all context files to reflect v5.7.0 state
- [x] **Release Tag:** Created `v5.7.0-RC1` tag and GitHub Release
- [x] **Stale Branches:** Cleaned up old development branches

**Key Milestone:** Repository synchronized - `main` branch now at v5.7.0 Release Candidate

---

## Previous Sprint: Phase 22 (The Witness - ✅ Completed)

**Goal:** Transform the app from Single Player (Tool) to Multiplayer (Network) with real-time social accountability

**Status:** ✅ Complete (December 2025)

**Philosophy:** "Social features are the best way to test if your Viral Engine actually works. Monetization is easier to add once you have retention; Social creates retention."

**Strategic Context:**
- Phase 21 built Deep Links (The Viral Engine) — **potential energy**
- Phase 22 activates them with social accountability — **kinetic energy**
- Together they create the viral loop that drives organic growth

**The Core Loop:**
```
1. BUILDER completes habit
2. WITNESS gets instant notification: "[Name] just cast a vote for [Identity]!"
3. WITNESS taps notification → sends High Five emoji
4. BUILDER gets SECOND dopamine hit (social validation)
5. If BUILDER is drifting → WITNESS can send preemptive nudge
```

**Architecture:**
- WitnessService: Real-time event management with Supabase Realtime
- WitnessEvent Model: Complete event taxonomy (completion, high-five, nudge, drift)
- UI Components: Dashboard, Accept Screen, High-Five Sheet
- Notification Extensions: Witness-specific channels

**Completed:**
- [x] **WitnessEvent Model:** Event types (habitCompleted, highFiveReceived, nudgeReceived, driftWarning, streakMilestone)
- [x] **WitnessReaction Model:** Quick emoji reactions (🖐️ 🔥 💪 ⚡ 🏆 🎯)
- [x] **StreakMilestones:** Celebrations at 7, 21, 30, 60, 90, 180, 365 days
- [x] **WitnessService:** Supabase Realtime subscriptions, completion pings, high-five sending, nudge system
- [x] **WitnessDashboard:** Three tabs (My Witnesses, I Witness, Activity)
- [x] **WitnessAcceptScreen:** Deep link landing for contract invites
- [x] **HighFiveSheet:** Bottom sheet for sending emoji reactions
- [x] **HighFiveReceivedOverlay:** Celebratory animation for second dopamine hit
- [x] **NotificationService Extensions:** Witness completion, high-five, nudge, drift warning channels
- [x] **Database Migration:** witness_events table with RLS and Realtime

**Files Created:**
- `lib/data/models/witness_event.dart` (WitnessEvent, WitnessReaction, StreakMilestones)
- `lib/data/services/witness_service.dart` (WitnessService)
- `lib/features/witness/witness_dashboard.dart` (WitnessDashboard)
- `lib/features/witness/witness_accept_screen.dart` (WitnessAcceptScreen)
- `lib/features/witness/high_five_sheet.dart` (HighFiveSheet, HighFiveReceivedOverlay)
- `lib/features/witness/witness.dart` (Module exports)
- `supabase/migrations/20241216_phase22_witness_events.sql` (Database migration)
- `CHANGELOG.md` (Version history)

**Files Modified:**
- `lib/main.dart` (WitnessService provider + routes)
- `lib/config/supabase_config.dart` (witnessEvents table constant)
- `lib/data/notification_service.dart` (Witness notification channels)
- `pubspec.yaml` (Version 5.7.0)

**Routes Added:**
| Route | Screen | Purpose |
|-------|--------|---------|
| `/witness` | WitnessDashboard | Central accountability hub |
| `/witness/accept/:inviteCode` | WitnessAcceptScreen | Contract invitation acceptance |

**Notification Types:**
| Type | Recipient | Copy |
|------|-----------|------|
| Completion | Witness | "⚡ [Name] just cast a vote for [Identity]!" |
| High-Five | Builder | "🖐️ High Five from [Witness]!" |
| Nudge | Builder | "💬 Nudge from [Witness]: [message]" |
| Drift Warning | Witness | "⚠️ [Builder] is drifting. Nudge them?" |
| Milestone | Witness | "🔥 [Builder] hit [X] day streak!" |

**The "Shame Nudge" System (Pre-Failure Intervention):**
- System detects when Builder is about to miss (based on Phase 19 drift analysis)
- Witness receives warning notification before failure occurs
- Witness can send encouraging nudge to prevent the miss
- This creates proactive accountability, not reactive guilt

---

## Previous Sprint: Phase 19 (The Intelligent Nudge - ✅ Completed)

**Goal:** Transform "dumb" static reminders into dynamic, context-aware triggers.

**Status:** ✅ Complete (December 2025)

**Philosophy:** "The app should observe what you do, not just what you say you'll do."

**Key Concepts Implemented:**
1. **"The Drift":** Detect when users consistently complete habits at a different time than scheduled
   - Median completion time calculation
   - Outlier filtering (> 2 hours from mean)
   - 45-minute threshold for suggestions
   - Midnight crossing handling
   
2. **"Contextual Empathy":** Change notification copy based on detected patterns
   - Energy Gap → "Low energy? Just do the 2-minute version"
   - Morning Struggle → "Don't aim for perfect, just show up"
   - Weekend Wobble → "Weekend Warrior" mode
   - Forgetfulness → Habit stacking nudge
   
3. **Schedule Optimization:** Weekly Review proposes time updates
   - Drift analysis integrated into WeeklyReviewService
   - Weekend variance detection
   - Problematic day identification

**Architecture Implemented:**

| Component | File | Purpose |
|-----------|------|---------|
| `OptimizedTimeFinder` | `lib/data/services/smart_nudge/optimized_time_finder.dart` | Drift detection algorithm |
| `DriftAnalysis` | `lib/data/services/smart_nudge/drift_analysis.dart` | Data models + TimeOfDay |
| `NudgeCopywriter` | `lib/data/services/smart_nudge/nudge_copywriter.dart` | Context-aware notification copy |
| `NotificationService` | `lib/data/notification_service.dart` | `scheduleSmartReminder()` method |
| `TimeDriftSuggestionDialog` | `lib/widgets/time_drift_suggestion_dialog.dart` | Time update UI |
| `TodayScreenController` | `lib/features/today/controllers/today_screen_controller.dart` | `checkForDriftSuggestion()` |
| `WeeklyReviewService` | `lib/data/services/weekly_review_service.dart` | Drift analysis in reviews |

**Tiered Model (Freemium):**
| Tier | Features |
|------|----------|
| Free | Local heuristics, basic drift detection, pattern-aware copy |
| Premium (DeepSeek) | AI-personalized copy, nuanced drift analysis, life event detection |
| Premium+ (Claude) | Full conversational coaching, cross-habit correlation |

**Files Created:**
- `lib/data/services/smart_nudge/optimized_time_finder.dart` ✅
- `lib/data/services/smart_nudge/nudge_copywriter.dart` ✅
- `lib/data/services/smart_nudge/drift_analysis.dart` ✅
- `lib/widgets/time_drift_suggestion_dialog.dart` ✅
- `test/unit/optimized_time_finder_test.dart` ✅
- `PHASE_19_SPEC.md` ✅

**Files Modified:**
- `lib/data/notification_service.dart` ✅
- `lib/features/today/controllers/today_screen_controller.dart` ✅
- `lib/data/services/weekly_review_service.dart` ✅

**Unit Tests:**
- Significant drift detection (9:00 AM → 9:45 AM)
- Outlier handling (ignores one-off 4:00 PM completions)
- Midnight crossing (11 PM scheduled, 1 AM actual)
- Insufficient data handling (< 7 completions)
- Weekend variance detection
- Confidence calculation
- Time rounding to nearest 15 minutes

---

## Previous Sprint: Phase 15 (Identity Foundation - ✅ Completed)

**Goal:** Build the Cloud Sync & Auth infrastructure to enable "Multiplayer" features

**Status:** ✅ Complete (December 2025)

**Philosophy:** "You can't build social features without identity. Build the bridge before crossing it."

**Architecture:** Local-First with Optional Cloud Backup
- Local Hive storage remains primary (offline-capable)
- Supabase provides cloud backup and identity
- Anonymous-first: Users can start immediately, upgrade later

**Completed:**
- [x] **Supabase Integration:** Added `supabase_flutter` and `google_sign_in` dependencies
- [x] **SupabaseConfig:** Environment-based configuration with runtime checks
- [x] **AuthService:** Anonymous login (default), Email/Password upgrade, Google Sign-In
- [x] **SyncService:** One-way backup (Hive → Supabase) with offline queue
- [x] **Database Schema:** `users`, `habits`, `habit_completions` tables with RLS
- [x] **Provider Integration:** AuthService and SyncService in MultiProvider
- [x] **Reference Files:** Extracted social_screen.dart and elevenlabs_service.dart from orphaned branches

**Key Design Decisions:**
| Decision | Rationale |
|----------|-----------|
| Anonymous-first | Zero friction onboarding, upgrade later |
| One-way sync (for now) | Prevents conflicts, simpler implementation |
| Environment variables | Secure credential management |
| Offline queue | Changes sync when online, never lost |
| RLS policies | Data isolation enforced at database level |

**Files Created:**
- `lib/config/supabase_config.dart` (Configuration with env vars)
- `lib/data/services/auth_service.dart` (Authentication service)
- `lib/data/services/sync_service.dart` (Cloud sync service)
- `SUPABASE_SCHEMA.md` (Database schema documentation)
- `lib/features/social/reference/reference_ui.dart` (Phase 16.3 reference)
- `lib/data/services/reference/elevenlabs_reference.dart` (Phase 17 reference)

**Files Modified:**
- `pubspec.yaml` (Supabase + Google Sign-In dependencies, version 4.12.0)
- `lib/main.dart` (Supabase initialization, service providers)

---

## Previous Sprint: Phase 14 (Pattern Detection - ✅ Completed)

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

## Previous Sprint: Phase 14.5 (The Iron Architect - ✅ Completed)

**Goal:** Refactor AI prompts from "Supportive Coach" to "Behavioral Architect" - stricter, physics-based enforcement of the 2-Minute Rule

**Status:** ✅ Complete (December 2025)

**Philosophy:** "You are NOT a generic life coach. You are a behavioral engineer. Your goal is to build a system that *cannot fail*, rather than relying on the user's motivation (which will fail)."

**Collaboration:** Elon Musk (physics-based systems thinking) + James Clear (Atomic Habits)

**Architecture:** Strict Behavioral Engineering
- Aggressive 2-Minute Rule filtering
- "Never Miss Twice" Protocol embedded in onboarding
- Pre-mortem failure analysis ("The Trap Door")
- DeepSeek-V3.2 optimized structure (### HEADERS, CAPITALIZED DIRECTIVES)

**Completed:**
- [x] **Iron Architect Prompt:** Complete rewrite of onboarding system prompt
- [x] **2-Minute Rule Enforcement:** Stricter rejection of oversized habits with physics-based framing
- [x] **Never Miss Twice Protocol:** Recovery plan embedded before habit starts
- [x] **Pre-mortem Analysis:** "What is the one thing most likely to stop you?" step
- [x] **DeepSeek Optimization:** ### headers and structured constraints for better reasoning
- [x] **Recovery Plan Field:** Added `recoveryPlan` to JSON output contract

**Key Changes:**

| Before (Supportive Coach) | After (Iron Architect) |
|---------------------------|------------------------|
| "Let's make this smaller" | "Too ambitious for Day 1. Motivation is fickle; systems are reliable." |
| "What's a 2-minute version?" | "The habit is not 'working out'. The habit is 'putting on your running shoes'." |
| Optional recovery planning | **Mandatory:** "When (not if) life gets crazy, what's your specific plan?" |
| No pre-mortem | **The Trap Door:** "What is the one thing most likely to stop you?" |

**Conversation Flow (Strict Order):**
1. **Identity First:** "Who do you want to become?" (not "What habit?")
2. **Habit Extraction:** Ask for the behavior
3. **The Audit:** Apply 2-Minute Rule (aggressive filtering)
4. **Implementation Intention:** "I will [BEHAVIOR] at [TIME] in [LOCATION]"
5. **The Trap Door:** Pre-mortem failure analysis
6. **Recovery Plan:** "If I miss, I will [specific algorithm]"

**Upstream/Downstream Effects:**

| Effect | Description |
|--------|-------------|
| 🟢 Higher Conversion | Smaller habits = higher stick rate |
| 🟢 Better Pattern Data | Fewer "Energy Gap" failures (Phase 14) because habits are 2-minute versions |
| 🟡 Potential Friction | "Arnault Types" may feel habits are "too small" |
| 🟢 Mitigation | "Too ambitious for Day 1" frames rejection as compliment to ambition |
| 🟢 DeepSeek Ready | Prompt structure (### HEADERS, DIRECTIVES) optimized for V3.2 reasoning |

**Files Modified:**
- `lib/data/services/gemini_chat_service.dart` (AtomicHabitsPrompts.onboarding)
- `lib/config/ai_prompts.dart` (AtomicHabitsReasoningPrompts.onboarding)

**No Schema Changes:** Recovery plan stored in existing `recoveryPlan` field

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

## Current Sprint: Phase 16.2 + 16.4 (Vertical Slice - ✅ Completed)

**Goal:** "The Atomic Contract" - End-to-end accountability flow

**Status:** ✅ Complete (December 2025)

**Philosophy:** "Vertical Slice Sprint" - Build one complete user journey before expanding

**Architecture:** Builder creates contract → Generates invite link → Witness joins via deep link

**Completed:**
- [x] **Database Schema:** `habit_contracts` table with RLS policies
- [x] **HabitContract Model:** Full Dart model with enums (ContractStatus, NudgeFrequency, NudgeStyle)
- [x] **ContractService:** CRUD operations + invite code generation + witnessing logic
- [x] **CreateContractScreen:** Draft contract UI with habit picker, duration, nudge settings
- [x] **JoinContractScreen:** Deep link handler for witness acceptance
- [x] **ContractsListScreen:** Tabbed view (My Habits / Witnessing) - minimal witness dashboard
- [x] **Routes:** `/contracts`, `/contracts/create`, `/contracts/join/:inviteCode`
- [x] **Deep Links:** Invite code generation and lookup

**Key Design Decisions:**
| Decision | Rationale |
|----------|-----------|
| Invite codes (not IDs) | Privacy + shorter URLs |
| Local-first witness list | Works offline, syncs when online |
| Tabbed contracts view | Simple before complex Phase 16.3 |
| Builder-initiated only | Witnesses can't create contracts |

**Files Created:**
- `lib/data/models/habit_contract.dart` (Contract model + enums)
- `lib/data/services/contract_service.dart` (CRUD + invite logic)
- `lib/features/contracts/create_contract_screen.dart`
- `lib/features/contracts/join_contract_screen.dart`
- `lib/features/contracts/contracts_list_screen.dart`

**Files Modified:**
- `lib/main.dart` (ContractService provider + routes)
- `lib/config/supabase_config.dart` (habit_contracts table name)
- `SUPABASE_SCHEMA.md` (habit_contracts schema + RLS)

---

## Current Sprint: Phase 18 (The Vibe Update - ✅ Completed)

**Goal:** Transform the app from "Utility" to "Toy" — "Juice it or lose it" for increased Time in App

**Status:** ✅ Complete (December 2025)

**Philosophy:** "If it doesn't feel good, they won't come back. Every interaction should be visceral."

**Architecture:** Sensory Integration + Kinetic UI
- Sound feedback via `audioplayers` package
- Haptic patterns via `HapticFeedback` service
- Spring animations with `ScaleTransition` and `ConfettiWidget`

**Completed:**
- [x] **SoundService:** Audio playback with completion, recovery, sign, nudge sounds
- [x] **FeedbackPatterns:** Combined haptic + sound patterns (completion, recovery, contractSign, etc.)
- [x] **StackPromptDialog Refactor:** Pop animation with ScaleTransition, ConfettiWidget, bouncing chain link
- [x] **AnimatedNudgeButton:** Recoil animation with rocket launch effect
- [x] **InlineNudgeButton:** Shake animation for compact contexts
- [x] **Provider Integration:** SoundService added to MultiProvider
- [x] **Screenshot Test Framework:** `app_store_screenshots_test.dart` for automated screenshots

**Key Features:**
| Feature | Implementation | Description |
|---------|---------------|-------------|
| Completion Sound | `SoundService.playComplete()` | Satisfying "clunk" on habit done |
| Recovery Sound | `SoundService.playRecover()` | Triumphant rise on Never Miss Twice |
| Contract Sign | `FeedbackPatterns.contractSign()` | Tick-tick-thud buildup |
| Chain Reaction Pop | `StackPromptDialog` | Spring scale + confetti |
| Nudge Recoil | `AnimatedNudgeButton` | Recoil + rocket launch |
| Haptic Patterns | `HapticFeedbackType` | Heavy, medium, light, selection |

**Files Created:**
- `lib/data/services/sound_service.dart` (Audio + FeedbackPatterns)
- `lib/widgets/animated_nudge_button.dart` (AnimatedNudgeButton, InlineNudgeButton, FloatingNudgeButton)
- `test/integration/app_store_screenshots_test.dart` (Automated App Store screenshots)
- `assets/sounds/complete.mp3`, `recover.mp3`, `sign.mp3` (Placeholder audio)

**Files Modified:**
- `lib/widgets/stack_prompt_dialog.dart` (Animation refactor + sound/haptic integration)
- `lib/features/contracts/contracts_list_screen.dart` (AnimatedNudgeButton integration)
- `lib/features/contracts/create_contract_screen.dart` (Contract signing feedback - "The Commitment")
- `lib/features/today/controllers/today_screen_controller.dart` (Completion + Recovery feedback)
- `lib/main.dart` (SoundService provider)
- `pubspec.yaml` (audioplayers dependency, assets/sounds/)

**Screenshot Scenes:**
1. "Never Miss Twice" - Recovery prompt
2. "The Watchtower" - Witness dashboard
3. "AI Architect" - Chat coach
4. "Chain Reaction" - Habit stacking
5. "Today View" - Focus mode
6. "Analytics Dashboard" - Trend charts

---

## Previous Sprint: Phase 19 (The Side Door Strategy - ✅ Completed)

**Goal:** "One App, Multiple Front Doors" - Persona-based marketing without code fragmentation

**Status:** ✅ Complete (December 2025)

**Philosophy:** "If we are building one 'Everything Store', we cannot have just one front door. We will build Side Doors." — Jeff Bezos

**Architecture:** Chameleon Prompts + Niche Landing Pages
- Same codebase serves all niches
- AI adapts language/examples based on detected persona
- Landing pages set context before onboarding

**Target Niches (Ranked by 4-Point Matrix):**

| Niche | Boss Vacuum | Maker's Guilt | Streak Victim | Digital Desk | Score |
|-------|-------------|---------------|---------------|--------------|-------|
| 🥇 Indie Developer | ✅ | ✅ | ✅ (GitHub) | ✅ | 4/4 |
| 🥈 Writer/Creator | ✅ | ✅ | ✅ (Algorithm) | ✅ | 4/4 |
| 🥉 PhD Student | ✅ | ✅ | ✅ (Thesis fear) | ✅ | 4/4 |
| 🌍 Language Learner | ✅ | ⚠️ | ✅ (Duolingo) | ✅ | 3.5/4 |
| 🚀 Indie Maker | ✅ | ✅ | ✅ | ✅ | 4/4 |

**Matrix Criteria:**
1. **Boss Vacuum**: No external enforcer (❌ Employees, Sales Teams)
2. **Maker's Guilt**: Identity tied to output (feel crisis when not shipping)
3. **Streak Victim**: Already burned by streak apps (Duolingo, GitHub)
4. **Digital Desk**: At device when doing habit (❌ Swimming, Woodworking)

**Completed:**
- [x] **NicheConfig System:** `lib/config/niche_config.dart`
  - UserNiche enum (developer, writer, academic, languageLearner, indieMaker)
  - NicheConfig with display names, taglines, examples, detection keywords
  - NicheConfigs map with all persona configurations
- [x] **NicheDetectionService:** Detect persona from user input
  - Keyword-based scoring with confidence levels
  - Streak refugee detection ("lost my streak", "quit Duolingo")
  - URL-based detection from landing pages
- [x] **NichePromptAdapter:** Persona-specific prompt injection
  - `getWelcomeMessage()` with streak refugee handling
  - `getIdentityPrompt()` with niche-specific examples
  - `getHabitPrompt()` and `getTinyVersionPrompt()` with relevant examples
  - `injectNicheContext()` for AI prompt enhancement
- [x] **OnboardingOrchestrator Update:** Niche-aware conversation
  - `setNicheFromUrl()` for landing page detection
  - `detectNicheFromInput()` for conversation-based detection
  - `_buildNicheContextSection()` for AI prompt injection
  - Streak refugee context injection
- [x] **OnboardingData Update:** Niche tracking fields
  - `userNiche` field
  - `entrySource` field
  - `isStreakRefugee` boolean
- [x] **Landing Page Routes:** Side door URLs in `main.dart`
  - `/devs` → Developer niche
  - `/writers` → Writer/Creator niche
  - `/scholars` → PhD/Academic niche
  - `/languages` → Language Learner niche
  - `/makers` → Indie Maker niche

**Niche-Specific Hooks:**

| Niche | Hook Message | Streak Antidote |
|-------|--------------|-----------------|
| Developer | "Stop worshipping the Green Squares. Start shipping consistently." | "GitHub green squares are vanity metrics. Shipping is the real score." |
| Writer | "The Algorithm wants perfection. You are human." | "The algorithm rewards consistency, not perfection." |
| Academic | "Your thesis is too big. Write one sentence today." | "Your thesis won't be written in one sitting. One sentence is progress." |
| Language | "The owl doesn't own you." | "Lost your Duolingo streak? Your progress isn't lost." |
| Maker | "Ship daily, not perfectly." | "Building in public isn't about daily posts. It's about consistent progress." |

**Files Created:**
- `lib/config/niche_config.dart` (Full niche configuration system)

**Files Modified:**
- `lib/data/models/onboarding_data.dart` (Niche tracking fields)
- `lib/data/services/onboarding/onboarding_orchestrator.dart` (Niche detection & prompt injection)
- `lib/main.dart` (Side door landing routes)

**Marketing Campaign Strategy:**
1. **Developer Door**: Post on r/programming, HackerNews, dev Twitter
2. **Writer Door**: Post on r/writing, Medium, creator communities
3. **Scholar Door**: Post on r/GradSchool, academic Twitter
4. **Language Door**: Post on r/languagelearning, Duolingo subreddits
5. **Maker Door**: Post on IndieHackers, r/SideProject

**Convergence Point:** All doors lead to same AI onboarding that asks "Who do you want to become?" and adapts based on detected/set niche.

---

## Current Sprint: Phase 20 (Destroyer Defense - ✅ Completed)

**Goal:** Risk mitigation for "High Performers" - The users with highest standards who will roast you publicly if things break

**Status:** ✅ Complete (December 2025)

**Philosophy:** "If you ask for the roast, they feel heard, and the anger dissipates before it hits public channels."

**Architecture:** Co-Creator Frame + Escape Valves
- Frame bugs as "discoveries" to involve users in development
- Provide private channels for venting before public destruction
- Manage expectations with prominent alpha/beta labels

**The Risk:** High Performers have high standards. If the app crashes, they won't just delete it; they will roast you on Hacker News.

**The Solution:** "The Co-Creator Frame" — You're not selling a finished product; you're inviting them into the lab.

**Tactics Implemented:**

| Tactic | Implementation | Description |
|--------|---------------|-------------|
| Bug Bounty | `CREDITS.md` + Bug Report Dialog | Find a crash → Get name in CREDITS.md |
| Escape Valve | "Roast the Developer" button | Private channel prevents public destruction |
| Alpha Shield | `AlphaShieldBanner` widget | Manages expectations: "UI is temporary, data is safe" |
| Credits Dialog | Settings → Credits | Shows Founding Testers & Hall of Roasts |
| Feature Request | Settings → Suggest Feature | Converts critics to co-creators |

**Completed:**
- [x] **CREDITS.md:** Founding Testers section, Hall of Roasts section
- [x] **FeedbackService:** Bug report templates, roast templates, device info collection
- [x] **AlphaShieldBanner:** Compact banner (settings) + expanded banner (splash) + splash overlay
- [x] **AlphaShieldConfig:** Build status enum, banner messages, disclaimer text
- [x] **Bug Report Dialog:** Name/handle collection, auto-includes device + version info
- [x] **Roast Dialog:** "Tell us why this sucks" with severity scale and suggestions
- [x] **Feature Request Dialog:** Converts frustration into constructive feedback
- [x] **Credits Dialog:** Shows Founding Team, Founding Testers, Hall of Roasts
- [x] **Settings Integration:** Feedback section with bug report, roast, and feature request buttons
- [x] **Email Fallback:** Copy to clipboard when email client unavailable
- [x] **GitHub Issues Link:** Direct link to repo issues for technical bugs

**Files Created:**
- `CREDITS.md` (Founding Testers + Hall of Roasts)
- `lib/data/services/feedback_service.dart` (FeedbackService + AlphaShieldConfig)
- `lib/widgets/alpha_shield_banner.dart` (AlphaShieldBanner + AlphaShieldSplashOverlay + AlphaShieldFAB)

**Files Modified:**
- `lib/features/settings/settings_screen.dart` (Feedback section + Credits dialog)
- `pubspec.yaml` (url_launcher, device_info_plus, package_info_plus dependencies)

**Key Design Decisions:**
| Decision | Rationale |
|----------|----------|
| Email-first feedback | Works everywhere, no accounts needed |
| Copy-to-clipboard fallback | Works even without email client |
| Name/handle collection | Enables CREDITS.md recognition |
| Device + version auto-include | Better bug reports without user effort |
| "Hall of Roasts" gamification | Turns critics into celebrated contributors |
| Alpha Shield in Settings | Persistent reminder without annoying popup |

**Psychological Framework:**
1. **The Bug Bounty:** Non-monetary recognition (name in credits) is often more motivating than cash for this demographic
2. **The Escape Valve:** A private "roast" channel prevents public Twitter/HN destruction
3. **The Alpha Shield:** Managing expectations upfront prevents disappointment
4. **The Co-Creator Frame:** "You found a bug" → "You discovered something" reframes the experience

---

## Current Sprint: Phase 21 (The Viral Engine - ✅ Completed)

**Goal:** Deep Links Infrastructure + FTUE Polish + Data Schema Enhancement — The "money maker" from Head of Sales

**Status:** ✅ Complete (December 2025)

**Philosophy:** "Create a contract to read 1 page a day, post the link on Twitter." — Head of Sales

**Boardroom Review Context:**
- **CTO:** Validated architecture (supabase + app_links + google_sign_in)
- **CPO:** Raised FTUE complexity concerns; requested coaching-focused error messages
- **Head of Sales:** Flagged Deep Links as viral growth driver
- **Head of Strategy:** Emphasized data collection for 2026 "Behavior Model"

**Architecture:**
- Phase 21.1: iOS Universal Links + Android App Links + Share Flow
- Phase 21.2: FTUE Polish with coaching-focused rejection messages
- Phase 21.3: Nudge effectiveness tracking for Behavior Model

### Phase 21.1: Deep Links Infrastructure

**Completed:**
- [x] **DeepLinkConfig:** URL builders, parsers, and validation
- [x] **DeepLinkService:** Initial/incoming link handling, router integration
- [x] **iOS Universal Links:** Runner.entitlements with applinks:atomichabits.app
- [x] **Android App Links:** AndroidManifest with autoVerify intent-filters
- [x] **Web Assets:** apple-app-site-association + assetlinks.json in .well-known
- [x] **ShareContractSheet:** Beautiful modal for sharing contract invite links
- [x] **ContractInvitePreview:** Preview card for recipients joining a contract
- [x] **main.dart Integration:** DeepLinkService in MultiProvider + router wiring

**Deep Link Patterns:**
| Pattern | Example | Destination |
|---------|---------|-------------|
| Contract Invite (short) | /c/ABCD1234 | Join Contract Screen |
| Contract Invite (query) | /invite?c=ABCD1234 | Join Contract Screen |
| Niche Landing | /devs, /writers | Conversational Onboarding |
| App Routes | /dashboard, /settings | Direct Navigation |
| Custom Scheme | atomichabits://invite?c=X | Deep Link Fallback |

**Files Created:**
- `lib/config/deep_link_config.dart` (DeepLinkConfig, DeepLinkType, DeepLinkData)
- `lib/data/services/deep_link_service.dart` (DeepLinkService)
- `lib/widgets/share_contract_sheet.dart` (ShareContractSheet, ContractInvitePreview)
- `ios/Runner/Runner.entitlements` (Universal Links)
- `web/.well-known/apple-app-site-association` (iOS web config)
- `web/.well-known/assetlinks.json` (Android web config)

**Files Modified:**
- `android/app/src/main/AndroidManifest.xml` (App Links intent-filters)
- `lib/main.dart` (DeepLinkService provider + router integration)

### Phase 21.2: FTUE Polish

**Goal:** Turn rejection messages into coaching moments per CPO feedback

**Completed:**
- [x] **ConversationGuardrails:** Coaching-focused rejection messages
- [x] **RejectionMessage class:** Headline + Explanation + Coaching + Icon
- [x] **Oversized rejections:** "Your ambition is impressive!" framing
- [x] **Vague rejections:** "That's a direction, not a destination" framing
- [x] **Recovery plan rejections:** "'Try harder' is wishful thinking, not a plan"
- [x] **ProgressiveDisclosure:** Feature gating based on user progress
- [x] **HabitConstraintValidator:** Updated with coaching-focused feedback

**Rejection Message Philosophy:**
1. **Validate:** "Your ambition is impressive!"
2. **Explain:** "But on Day 1, motivation is high and will fade."
3. **Guide:** "What could you do in just 2 minutes?"

**Files Created:**
- `lib/config/conversation_guardrails.dart` (ConversationGuardrails, RejectionMessage, ProgressiveDisclosure)

**Files Modified:**
- `lib/config/ai_prompts.dart` (HabitConstraintValidator with coaching messages)

### Phase 21.3: Data Schema Enhancement

**Goal:** Track nudge effectiveness for Head of Strategy's "Behavior Model"

**Completed:**
- [x] **HabitContract Model:** Added nudge tracking fields
- [x] **ContractService.sendNudge():** Tracks nudge sent timestamp
- [x] **ContractService.recordDayCompleted():** Tracks nudge response + effectiveness
- [x] **nudgeEffectivenessRate getter:** % of nudges that led to completion
- [x] **Event metadata:** Logs nudge response timing and effectiveness

**New Data Fields:**
| Field | Type | Purpose |
|-------|------|---------|
| lastNudgeSentAt | DateTime? | When witness last sent nudge |
| lastNudgeResponseAt | DateTime? | When builder completed after nudge |
| nudgesReceivedCount | int | Total nudges received |
| nudgesRespondedCount | int | Nudges that led to completion |

**Computed Metrics:**
- `nudgeEffectivenessRate`: nudgesResponded / nudgesReceived × 100
- `hasOpenNudge`: lastNudgeSentAt > lastNudgeResponseAt

**Files Modified:**
- `lib/data/models/habit_contract.dart` (Nudge tracking fields + computed properties)
- `lib/data/services/contract_service.dart` (Nudge effectiveness tracking in sendNudge/recordDayCompleted)

---

**Upstream Effects (2026 Behavior Model):**
| Data Point | Use Case |
|------------|----------|
| Nudge Effectiveness Rate | Optimize nudge frequency per user |
| Response Time Distribution | Best time to send nudges |
| Nudge Style Effectiveness | Which tone works best |
| Pattern + Nudge Correlation | Do nudges help on "hard" days? |

---

## Previous Sprint: Phase 17 (Brain Surgery - ✅ Completed)

**Goal:** Optimize AI prompts for DeepSeek-V3.2's "Thinking in Tool-Use" capability

**Status:** ✅ Complete (December 2025)

**Philosophy:** "REASON before ACTING" — Leverage DeepSeek's breakthrough for stronger constraint enforcement

**Architecture:** Reasoning-First Prompts with Dual-Layer Guardrails
- Prompt-level: THINKING PROTOCOL, NEGATIVE CONSTRAINTS
- Client-side: ConversationGuardrails validation

**Completed:**
- [x] **AtomicHabitsReasoningPrompts:** New prompt library with THINKING PROTOCOL
- [x] **HabitConstraintValidator:** Client-side validation for 2-minute rule
- [x] **ConversationGuardrails Update:** Added oversized/vague/multiple habit patterns
- [x] **GeminiChatService Update:** Enhanced coaching prompts with reasoning markers
- [x] **OnboardingOrchestrator Update:** Guardrail injection in prompts
- [x] **AI_ONBOARDING_SPEC.md Update:** v5.0.0 with Reasoning-First design

**Key Design Principles:**
| Principle | Implementation | Example |
|-----------|---------------|---------|
| REASON → ACT | THINKING PROTOCOL | "Is this habit under 2 minutes?" |
| NEGATIVE CONSTRAINTS | Explicit rejection rules | "Do NOT allow 30-minute habits" |
| 2-MINUTE CEILING | Strict enforcement | "Exercise" → "Put on workout clothes" |
| IDENTITY-FIRST | Identity before behavior | "I am someone who..." |
| DUAL-LAYER | Prompt + Client validation | Both AI and code enforce rules |

**Files Created:**
- `lib/config/ai_prompts.dart` (AtomicHabitsReasoningPrompts, HabitConstraintValidator)

**Files Modified:**
- `lib/data/services/onboarding/conversation_guardrails.dart`
- `lib/data/services/gemini_chat_service.dart`
- `lib/data/services/onboarding/onboarding_orchestrator.dart`
- `AI_ONBOARDING_SPEC.md`

---

---

## Future Sprint: Phase 25 - The Cash Register

**Status:** 📋 Planned (Post Viral Loop Validation)

**Goal:** Implement Freemium Monetization

**Features:**
- [ ] **RevenueCat Integration:** Subscription management
- [ ] **Tier Logic:** Free (local heuristics, basic), Pro (cloud sync, AI nudges, unlimited contracts)
- [ ] **Paywall UI:** Premium feature gating

**Rationale:** "Monetize the network after proving the viral loop works."

---

## Completed: Phase 16 Expansion

**Status:** ✅ Complete

**Sub-phases:**
- [x] **Phase 16.1: Auth UI** — ✅ Settings integration for account management (December 2025)
- [x] **Phase 16.3: Witness Dashboard (Full)** — ✅ Implemented in Phase 22 with WitnessDashboard

### Phase 16.1: Auth UI in Settings (✅ Completed)

**Goal:** Provide user-facing authentication management in Settings screen

**Status:** ✅ Complete (December 2025)

**Completed:**
- [x] **Account Section:** Added "Account" section to Settings screen with status display
- [x] **Auth Status Display:** Shows authentication state (Not Signed In / Anonymous / Verified)
- [x] **Sign In Flow:** Modal bottom sheet with Google Sign-In, Email/Password, and Anonymous options
- [x] **Account Upgrade:** Upgrade anonymous accounts to email/password or Google
- [x] **Sign Out:** Confirmation dialog for signing out
- [x] **Cloud Sync Status:** Shows sync state, pending changes count, last sync time
- [x] **Manual Sync:** Refresh button to trigger sync manually
- [x] **Offline Mode:** Graceful display when Supabase is not configured
- [x] **SyncService Getters:** Added `isSyncing`, `pendingChangesCount`, `syncNow()` for UI

**Files Modified:**
- `lib/features/settings/settings_screen.dart` (Auth UI section with full flows)
- `lib/data/services/sync_service.dart` (Added UI helper getters)

**Key Design Decisions:**
| Decision | Rationale |
|----------|----------|
| Modal bottom sheets | Clean, focused sign-in experience |
| Status-based UI | Different options for anonymous vs verified |
| Graceful offline | Works without Supabase configured |
| Sync visibility | Users understand cloud backup state |

**Release Candidate Checklist:**
- [x] Phase 9: Home Screen Widgets
- [x] Phase 10: Analytics Dashboard  
- [x] Phase 11: Backup & Restore
- [x] Phase 12: Bad Habit Protocol
- [x] Phase 13: Habit Stacking
- [x] Phase 14: Pattern Detection
- [x] Phase 15: Identity Foundation
- [x] Phase 16.2: Habit Contracts
- [x] Phase 17: Brain Surgery (AI Prompts)
- [x] Phase 18: The Vibe Update
- [ ] Phase 16: Full Habit Contracts & Witnesses
- [ ] Final polish and testing
- [ ] App Store / Play Store preparation

---

## Priority Tasks for Phase 17

> **Strategic Context:** These tasks support the GTM "Cost MVP" strategy (Viral Growth / $0 Spend)

### 🎙️ Smart Voice Entry (High Priority)
**Goal:** AI-powered speech-to-text for frictionless habit logging

**Implementation:**
- Leverage `elevenlabs_reference.dart` (extracted from `claude/merge-missing-code-*`)
- Speech-to-text for habit completion notes
- Voice-based habit creation ("Hey, I want to start meditating")
- Context-aware transcription with habit vocabulary

**Files to Reference:**
- `lib/data/services/reference/elevenlabs_reference.dart`

### 📜 Legal Data Review (Medium Priority)
**Goal:** GDPR/CCPA compliance for cloud sync

**Implementation:**
- Data collection policy documentation
- "Download My Data" feature (export all cloud data)
- Account deletion with data purge
- Privacy settings UI in Settings screen

**Blocked By:** Phase 15 (now complete) - needed to know what data is collected

### 🔔 Context-Aware Notifications (Medium Priority)
**Goal:** Replace generic nudges with "Pattern-Matched" motivation

**Implementation:**
- Integrate PatternDetectionService with NotificationService
- AI-generated notification copy based on:
  - User's detected patterns (e.g., "Night Owl" → evening motivation)
  - Recovery history (e.g., "You bounced back 3 times this month!")
  - Identity statements (e.g., "As someone who values health...")
- Style variants: Guilt, Encouragement, Celebration, Compassion

**Dependencies:**
- Phase 14: Pattern Detection ✅
- Phase 7: Weekly Review AI ✅

### 🔗 Deep Links for Viral Invites (High Priority - GTM Critical)
**Goal:** Enable `atomichabits.app/invite?c=123` for Trojan Horse strategy

**Implementation:**
- Universal/App Links setup (iOS + Android)
- Invite code generation tied to User ID
- Contract preview screen for invitees
- Attribution tracking for viral loops

**Blocked By:** Phase 16.2 (Habit Contracts)

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
| Stale branches cleanup | High | ✅ Done | 19 stale branches deleted (December 2025) |
| Settings persistence | Medium | ✅ Done | Full persistence via Hive |
| Hive type adapters | Medium | 🔴 Open | Manual JSON maps work but fragile |
| iOS notification permissions | Medium | 🔴 Open | Android-only code paths |
| Timezone change handling | Low | 🔴 Open | Fixed to UTC/Local |
| Remove unnecessary imports | Low | 🔴 Open | flutter analyze warnings |
| Supabase env vars setup | High | 🟡 Docs | See SUPABASE_SCHEMA.md for setup |

---

## Branch Cleanup Status (Phase 15)

| Branch Pattern | Content | Action | Status |
|----------------|---------|--------|--------|
| `claude/ai-conversational-first-page-*` | Social UI | ✅ Extracted to reference | Keep for now |
| `claude/merge-missing-code-*` | ElevenLabs Voice | ✅ Extracted to reference | Keep for now |
| `claude/habit-substitution-guardrails-*` | Bad Habit Logic | 🗑️ DELETE | Superseded by Phase 12 |
| `codex/create-node.js-backend-*` | Node.js Backend | 🗑️ DELETE | Replaced by Supabase |
| `claude/setup-atomic-achievements-*` | Home Widgets | 🗑️ DELETE | Superseded by Phase 9 |
| `claude/phase-4-identity-avatar-*` | Gamification | 📦 Archive | Keep for Phase 18 |

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
| Orphaned branches | 18+ | < 5 | Key assets extracted, cleanup pending |
| Test coverage | ~70% | 80%+ | Good foundation |
| Doc sync to main | ✅ Now | Always | New protocol |
| Time to onboard new AI | ~30 min | < 10 min | With Big Four docs |
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
| Phase 15 Identity Foundation | ✅ | ✅ | Complete! Cloud sync ready |
| Phase 16.2 Habit Contracts | ✅ | ✅ | Complete! Vertical slice done |
| Phase 17 Brain Surgery | ✅ | ✅ | Complete! DeepSeek-V3.2 optimized |
| Phase 18 The Vibe Update | ✅ | ✅ | Complete! Sound + Haptics + Animations + UI Wiring |
| Phase 16.1 Auth UI in Settings | ✅ | ✅ | Complete! Full auth management |
| Phase 19 Side Door Strategy | ✅ | ✅ | Complete! Niche-based onboarding |
| Phase 19 Intelligent Nudge | ✅ | ✅ | Complete! Drift detection + Smart copy |
| Phase 20 Destroyer Defense | ✅ | ✅ | Complete! Bug bounty + Alpha Shield |
| Phase 14.5 Iron Architect | ✅ | ✅ | Complete! Stricter 2-Minute Rule prompts |
| Phase 16.3 Witness Dashboard | ✅ | ✅ | Complete! Integrated in Phase 22 |
| Phase 22 The Witness | ✅ | ✅ | Complete! Social Accountability Loop |
| Release Candidate Ready | ✅ | ✅ | v5.7.0 - Social Features Complete |
| Phase 23 Clean Slate | ✅ | ✅ | Complete! PR #11 merged, v5.7.0-RC1 tagged |
| Phase 24 The Red Carpet | 🟡 | ✅ | Current: Viral Engine optimization |
| Phase 25 The Cash Register | 📋 | ✅ | Planned: Monetization (post-viral) |

---

*"You do not rise to the level of your goals. You fall to the level of your systems."* — James Clear

*Last synced to main: December 2025 (v5.7.0-RC1 - Phase 24 "The Red Carpet" Active)*
