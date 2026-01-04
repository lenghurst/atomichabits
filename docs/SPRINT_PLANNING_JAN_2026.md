# AtomicHabits Sprint Planning: 16 Jan 2026 Launch

**Date:** 03 January 2026
**Analysis Scope:** Complete data flow mapping, gap identification, sprint prioritization
**Sources:** Claude + Gemini dual analysis (synthesized)

---

## Executive Summary: "The Missing Nervous System"

You have built a sophisticated **Brain** (JITAIDecisionEngine, HierarchicalBandit) and high-fidelity **Senses** (GeminiLiveService, VoiceSessionManager). However, the **Nervous System** connecting them is incomplete:

1. **The Brain is invisible** - Decision engine generates insights, but UI doesn't display them
2. **The Brain has amnesia** - Bandit state isn't persisted, learning resets on app restart
3. **The Brain can't feel** - Emotion from voice sessions doesn't flow to ContextSnapshot

**Launch Readiness:** 55% complete (revised down due to persistence gap)
**Blocking Issues:** 6 P0 gaps identified
**Recommended Sprint Focus:** "Close the Loop" (Wire JITAI to UI + Persistence + Emotion Flow)

---

## 1. Data Flow Analysis

### 1.1 JITAI System - COMPLETE in Engine, MISSING in UI

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          JITAI DATA FLOW                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  [SENSORS] ────────────────────────────────────────────────► [ENGINE]        │
│  ✅ TimeContext (always available)                              │            │
│  ✅ WeatherContext (OpenWeatherMap)                             │            │
│  ✅ CalendarContext (Google Calendar)                           │            │
│  ✅ BiometricContext (HealthConnect)                            │            │
│  ✅ LocationContext (Geolocator)                                │            │
│  ✅ DigitalContext (App Usage + Emotion)                        ▼            │
│                                                                              │
│  ContextSnapshotBuilder ──► ContextSnapshot ──► VulnerabilityOpportunity     │
│                                  │                Calculator                 │
│                                  │                    │                      │
│                                  ▼                    ▼                      │
│                          JITAIDecisionEngine ◄─── VOState                    │
│                                  │                                           │
│                                  ▼                                           │
│                          HierarchicalBandit (Thompson Sampling)              │
│                                  │                                           │
│                                  ▼                                           │
│                          JITAIDecision (intervene/defer/silence)             │
│                                  │                                           │
│                                  ▼                                           │
│                          JITAIProvider (State Manager)                       │
│                                  │                                           │
│ ──────────────────────────────── │ ────────────────────────────────────────  │
│                                  │                                           │
│  ❌ NOT WIRED ───────────────────┼──────────────────────────── [UI]          │
│                                  │                                           │
│       Dashboard ◄────────────────┼───── JITAIInsightsCard (EXISTS, UNUSED)   │
│       TodayScreen ◄──────────────┼───── InterventionModal (EXISTS, UNUSED)   │
│       Notifications ◄────────────┴───── JITAINotificationService (NOT CALLED)│
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Status by Component:**

| Component | File | Status | Gap |
|-----------|------|--------|-----|
| `JITAIDecisionEngine` | `lib/domain/services/jitai_decision_engine.dart:24` | ✅ Complete | None |
| `HierarchicalBandit` | `lib/domain/services/hierarchical_bandit.dart` | ✅ Complete | None |
| `VulnerabilityOpportunityCalculator` | `lib/domain/services/vulnerability_opportunity_calculator.dart` | ✅ Complete | None |
| `CascadePatternDetector` | `lib/domain/services/cascade_pattern_detector.dart` | ✅ Complete | None |
| `OptimalTimingPredictor` | `lib/domain/services/optimal_timing_predictor.dart` | ⚠️ Needs data | Cold-start problem |
| `PopulationLearningService` | `lib/domain/services/population_learning.dart` | ⚠️ Needs Edge Functions | Supabase deploy pending |
| `ContextSnapshotBuilder` | `lib/data/services/context/context_snapshot_builder.dart:24` | ✅ Complete (deprecated) | Use ContextService |
| `JITAIProvider` | `lib/data/providers/jitai_provider.dart:77` | ✅ Complete | Guardian Mode TODOs |
| `JITAINotificationService` | `lib/data/services/jitai/jitai_notification_service.dart:14` | ✅ Complete | Not triggered |
| `JITAIInsightsCard` | `lib/features/jitai/widgets/jitai_insights_card.dart:15` | ✅ Complete | Not used in UI |
| `InterventionModal` | `lib/features/jitai/widgets/intervention_modal.dart:27` | ✅ Complete | Not used in UI |

### 1.2 Voice/AI Services - PARTIALLY COMPLETE

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      VOICE/AI DATA FLOW                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  User Voice ─► AudioRecordingService ─► WAV File                             │
│                                             │                                │
│                                             ▼                                │
│                                    VoiceSessionManager                       │
│                                             │                                │
│                        ┌────────────────────┼────────────────────┐           │
│                        ▼                    ▼                    ▼           │
│               GeminiVoiceNoteService  GeminiLiveService  OpenAILiveService   │
│               (Sherlock Protocol)     (Native Audio)     (Emotion Detection)│
│                        │                    │                    │           │
│                        ▼                    ▼                    ▼           │
│              Transcription + TTS     Real-time Audio      Emotion Metadata   │
│                        │                    │                    │           │
│                        │                    │                    ▼           │
│                        │                    │            Hive: emotion_metadata
│                        │                    │                    │           │
│                        │                    │                    ▼           │
│                        │                    │            DigitalContext      │
│                        │                    │            .emotionVulnerabilityBoost
│                        │                    │                    │           │
│                        ▼                    ▼                    ▼           │
│                   ChatMessage ─────────────────────────► UI (VoiceCoachScreen)
│                                                                              │
│  ❌ GAPS:                                                                    │
│  - Lazy TTS not implemented (eager generation = cost)                        │
│  - Voice Wand (3-min capture) not implemented                                │
│  - Sherlock Protocol extraction incomplete                                   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.3 State Management Architecture - SOLID

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      PROVIDER HIERARCHY (main.dart:230)                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  AppState (legacy, being strangled) ───► Dashboard, TodayScreen              │
│       │                                                                      │
│       ├── SettingsProvider ✅                                                │
│       ├── UserProvider ✅                                                    │
│       ├── HabitProvider ✅                                                   │
│       ├── PsychometricProvider ✅ (Dual-write Hive + Supabase)               │
│       └── JITAIProvider ✅ (NOT consumed by UI)                              │
│                                                                              │
│  Storage Architecture:                                                       │
│  ┌─────────────────────┬─────────────────────┐                               │
│  │ Hive (Local)        │ Supabase (Cloud)    │                               │
│  ├─────────────────────┼─────────────────────┤                               │
│  │ habits              │ habits (RLS)        │                               │
│  │ completions         │ habit_contracts     │                               │
│  │ emotion_metadata    │ identity_seeds      │                               │
│  │ bandit_params       │ psychometric_profiles│                              │
│  │ context_cache       │                     │                               │
│  └─────────────────────┴─────────────────────┘                               │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. 5-Layer Architecture Status

| Layer | Name | Status | Blocking Tasks |
|-------|------|--------|----------------|
| **1** | Evidence Engine | ⚠️ 70% | E6: Evidence API not implemented |
| **2** | Shadow Profiler | ❌ 20% | Voice Wand, Sherlock extraction |
| **3** | Living Garden | ❌ 0% | Rive integration not started |
| **4** | Command CLI | ❌ 0% | Daemon parsing not started |
| **5** | Philosophical Intelligence | ⚠️ 40% | Gap Analysis Engine not wired |

### Layer 1: Evidence Engine (Foundation)

**Completed:**
- `identity_seeds` table in Supabase ✅
- RLS policies ✅
- `SupabasePsychometricRepository` ✅
- `PsychometricProvider` dual-write ✅
- Sync-on-login ✅

**Missing:**
- **E6: Evidence API** - Log observable signals (emotion, behavior) to `identity_seeds`
  - Location: Needs new `EvidenceService` in `lib/data/services/`
  - Consumer: `VoiceSessionManager`, `JITAIProvider`, habit completions

### Layer 5: Philosophical Intelligence

**Completed:**
- `DeepSeekService` at `lib/data/services/ai/deep_seek_service.dart:29` ✅
- Basic chat pipeline ✅

**Missing:**
- Gap Analysis Engine (emotion-behavior causality)
- Integration with `PsychometricProvider` data

---

## 3. P0 Gaps Blocking Launch

### Gap 1: BANDIT AMNESIA - Learning Loop Volatile (COMPLETED ✅ Phase 66.1)

**Impact:** The Thompson Sampling bandit resets to default priors on every app restart. The AI never "learns" user preferences.
**Effort:** 0.5 days
**Root Cause:** `exportState()` and `importState()` methods exist in `HierarchicalBandit` (lines 443, 456) but are **never called**.

**Files to modify:**

| File | Changes Required |
|------|-----------------|
| `lib/data/providers/jitai_provider.dart` | Call `decisionEngine.exportState()` on dispose/pause, `importState()` on initialize |
| New: `lib/data/repositories/jitai_state_repository.dart` | Hive persistence for bandit state |

**Implementation:**
```dart
// In JITAIProvider.dispose() or AppLifecycleState.paused
Future<void> _persistBanditState() async {
  final box = await Hive.openBox('bandit_params');
  await box.put('state', _decisionEngine.exportState());
}

// In JITAIProvider.initialize()
Future<void> _hydrateBanditState() async {
  final box = await Hive.openBox('bandit_params');
  final state = box.get('state') as Map<String, dynamic>?;
  if (state != null) {
    _decisionEngine.importState(state);
  }
}
```

### Gap 2: EMOTION DISCONNECT - Voice Can't Influence JITAI (COMPLETED ✅ Phase 65)

**Impact:** `VoiceSessionManager.storeEmotionMetadata()` writes to Hive, but `ContextSnapshotBuilder` never reads it. The JITAI brain can't "feel" the user's emotional state from voice sessions.
**Effort:** 0.5 days
**Root Cause:** No read path from `emotion_metadata` Hive box to `ContextSnapshot.digital.emotionVulnerabilityBoost`.

**Files to modify:**

| File | Changes Required |
|------|-----------------|
| `lib/data/services/context/context_snapshot_builder.dart` | Inject emotion storage, read in `build()` |

**Implementation:**
```dart
// In ContextSnapshotBuilder.build()
Future<ContextSnapshot> build() async {
  // ... existing code ...

  // Fetch latest emotion from Hive
  final emotionBox = await Hive.openBox('emotion_metadata');
  final emotionData = emotionBox.get('latest_emotion') as Map<String, dynamic>?;

  double emotionBoost = 0.0;
  if (emotionData != null) {
    final capturedAt = DateTime.parse(emotionData['capturedAt']);
    final age = DateTime.now().difference(capturedAt);
    if (age < const Duration(hours: 2)) {
      emotionBoost = _calculateEmotionBoost(emotionData);
    }
  }

  // Pass to DigitalContext
  final digital = DigitalContext(
    // ... existing fields ...
    emotionVulnerabilityBoost: emotionBoost,
  );
}
```

### Gap 3: JITAI NOT WIRED TO UI (COMPLETED ✅ Phase 67)

**Impact:** Users cannot see any JITAI insights, interventions, or cascade alerts.
**Effort:** 2-3 days
**Files to modify:**

| File | Changes Required |
|------|-----------------|
| `lib/features/today/today_screen.dart` | Add `JITAIInsightsCard`, trigger `checkIntervention()` on resume |
| `lib/features/dashboard/habit_list_screen.dart` | Add `CascadeAlertBanner` for at-risk habits |
| `lib/config/router/app_router.dart` | Add intervention deep link handler |

**Implementation:**
```dart
// today_screen.dart - Add after IdentityCard
Consumer<JITAIProvider>(
  builder: (context, jitai, _) {
    if (jitai.hasCascadeRisk) {
      return CascadeAlertBanner(alerts: jitai.cascadeAlerts);
    }
    return JITAIInsightsCard(habitId: habit.id);
  },
),

// Also call on resume:
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    final jitai = context.read<JITAIProvider>();
    final profile = context.read<PsychometricProvider>().profile;
    if (profile != null) {
      jitai.runForegroundCheck(habits: habits, profile: profile);
    }
  }
}
```

### Gap 4: Notification Pipeline Incomplete (COMPLETED ✅ Phase 66.2)

**Impact:** Background interventions never reach users.
**Effort:** 1-2 days
**Files to modify:**

| File | Changes Required |
|------|-----------------|
| `lib/data/services/jitai/jitai_background_worker.dart` | Call `deliverIntervention()` from background task |
| `lib/data/providers/jitai_provider.dart` | Trigger notification on `checkIntervention()` result |

**Current state:** `JITAINotificationService.deliverIntervention()` exists but is never called.

### Gap 5: Evidence API Missing (High)

**Impact:** Layer 1 foundation incomplete, no identity evidence logging.
**Effort:** 1 day
**New file:** `lib/data/services/evidence_service.dart`

**Required methods:**
```dart
class EvidenceService {
  Future<void> logHabitCompletion(String habitId, DateTime timestamp);
  Future<void> logEmotionDetected(String emotion, double confidence);
  Future<void> logDoomScrollSession(String app, Duration duration);
  Future<void> logInterventionOutcome(String eventId, bool successful);
}
```

### Gap 6: Lazy TTS Not Implemented (Medium)

**Impact:** Cost overrun on TTS generation (every response generates audio, even if not played).
**Effort:** 0.5 days
**Files to modify:** `lib/data/services/gemini_voice_note_service.dart`

**Current:** TTS generated eagerly on every response.
**Target:** Generate on "Play" button click only.

---

## 4. Hidden Dependencies & Risks

```
┌──────────────────────────────────────────────────────────────────────────┐
│                        DEPENDENCY GRAPH                                   │
├──────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  Bandit Persistence (Gap 1) ◄──────── Required by:                        │
│                                        - All adaptive behavior            │
│                                        - Personalization                  │
│                                        - Without it, AI never learns      │
│                                                                           │
│  Emotion Flow (Gap 2) ◄────────────── Required by:                        │
│                                        - Vulnerability calculation        │
│                                        - Voice-aware interventions        │
│                                                                           │
│  Evidence API (Gap 5) ◄────────────── Required by:                        │
│                                        - Gap Analysis Engine (Layer 5)    │
│                                        - Population Learning              │
│                                        - Guardian Mode logging            │
│                                                                           │
│  Wire JITAI to UI (Gap 3) ◄────────── Required by:                        │
│                                        - User testing                     │
│                                        - Intervention outcome tracking    │
│                                        - Bandit learning                  │
│                                                                           │
│  Notification Pipeline (Gap 4) ◄───── Required by:                        │
│                                        - Background intervention delivery │
│                                        - User engagement                  │
│                                                                           │
│  PsychometricProfile ◄─────────────── Required by:                        │
│                                        - JITAI archetype-specific messaging│
│                                        - Shadow interventions             │
│                                        - Population priors                │
│                                                                           │
└──────────────────────────────────────────────────────────────────────────┘
```

### Production Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| **Native Bridge Crash** | `DigitalTruthSensor` (Guardian Mode) requires Android `UsageStats`, iOS `ScreenTime`. If not robust, app crashes. | Wrap in try-catch, default to `false` (no distraction detected) |
| **Supabase Edge Function** | `get-gemini-ephemeral-token` referenced in `GeminiLiveService`. If not deployed, Voice Mode fails in production. | Deploy to Supabase, verify `GEMINI_API_KEY` env var |
| **Cold Start Problem** | `OptimalTimingPredictor` needs historical data. New users get poor predictions. | Use population priors from `PopulationLearningService` |

---

## 5. Sprint Recommendation

### Sprint 1: "Close the Loop" (COMPLETED ✅ Jan 4)

**Goal:** Complete the Nervous System - Context → Decision → UI → Learning → Persistence.

| Priority | Task | Effort | Gap |
|----------|------|--------|-----|
| **P0** | Implement `_persistBanditState()` and `_hydrateBanditState()` in JITAIProvider | 3h | Gap 1 |
| **P0** | Read `emotion_metadata` in ContextSnapshotBuilder | 3h | Gap 2 |
| **P0** | Wire `JITAIInsightsCard` to TodayScreen | 4h | Gap 3 |
| **P0** | Show `InterventionModal` when intervention triggered | 3h | Gap 3 |
| **P0** | Trigger `runForegroundCheck()` on app open | 2h | Gap 3 |
| P1 | Wire `CascadeAlertBanner` to Dashboard | 2h | Gap 3 |
| P1 | Connect notification tap to intervention handler | 3h | Gap 4 |

**Deliverable:** AI remembers, feels, and speaks. Complete closed loop.

### Sprint 2: "Notification Pipeline" (Days 4-5)

**Goal:** Background interventions reach users.

| Priority | Task | Effort | Gap |
|----------|------|--------|-----|
| **P0** | Call `deliverIntervention()` from background worker | 4h | Gap 4 |
| **P0** | Persist intervention outcomes to bandit | 2h | Gap 1 |
| P1 | Wrap `DigitalTruthSensor` in try-catch (crash protection) | 2h | Risk |
| P1 | Verify Supabase Edge Function `get-gemini-ephemeral-token` | 2h | Risk |

**Deliverable:** Users receive background interventions, learning loop complete.

### Sprint 3: "Evidence Foundation" (Days 6-8)

**Goal:** Complete Layer 1 with Evidence API.

| Priority | Task | Effort | Gap |
|----------|------|--------|-----|
| P1 | Create `EvidenceService` | 4h | Gap 5 |
| P1 | Log habit completions as identity evidence | 2h | Gap 5 |
| P1 | Log emotion from voice sessions | 2h | Gap 5 |
| P1 | Log doom scroll sessions from Guardian Mode | 2h | Gap 5 |
| P2 | Implement Lazy TTS refactor | 4h | Gap 6 |

**Deliverable:** Identity evidence logged, cost savings from lazy TTS.

### Sprint 4: "Witness & Share" (Days 9-10)

**Goal:** Social accountability loop.

| Priority | Task | Effort |
|----------|------|--------|
| P1 | Witness deep link (WhatsApp share) | 8h |
| P2 | "Ask your best witness" intervention action | 4h |
| P2 | Witness ranking display in settings | 4h |

**Deliverable:** Users can invite witnesses via WhatsApp.

---

## 6. Impact vs Effort Matrix

```
                          HIGH IMPACT
                              │
    ┌─────────────────────────┼─────────────────────────┐
    │  DO NOW (Sprint 1-2)    │  PLAN CAREFULLY         │
    │                         │                         │
    │  • Bandit Persistence   │  • Voice Wand (Layer 2) │
    │  • Emotion Flow         │  • Gap Analysis Engine  │
    │  • Wire JITAI to UI     │  • Population Learning  │
    │  • Notification Pipeline│                         │
    │                         │                         │
LOW ├─────────────────────────┼─────────────────────────┤ HIGH
EFFORT                        │                         EFFORT
    │  QUICK WINS             │  DEFER                  │
    │                         │                         │
    │  • Lazy TTS             │  • Living Garden (Rive) │
    │  • Crash protection     │  • Command CLI          │
    │  • Edge Function verify │  • Contextual Bandits   │
    │                         │                         │
    └─────────────────────────┼─────────────────────────┘
                              │
                          LOW IMPACT
```

---

## 7. Files Modified Summary

### Must Touch for Launch

```
lib/features/today/today_screen.dart          # Add JITAI widgets
lib/features/dashboard/habit_list_screen.dart  # Add cascade alerts
lib/data/providers/jitai_provider.dart         # Trigger notifications
lib/data/services/jitai/jitai_background_worker.dart  # Deliver interventions
lib/data/services/evidence_service.dart        # NEW FILE
```

### Nice to Have

```
lib/data/services/gemini_voice_note_service.dart  # Lazy TTS
lib/data/services/witness_service.dart            # Deep link share
```

---

## 8. Launch Checklist (16 Jan 2026)

### Critical (Must Have)
- [ ] **Bandit state persists across restarts** (Gap 1) - AI remembers
- [ ] **Emotion metadata flows to JITAI** (Gap 2) - AI feels
- [ ] **JITAI visible in UI** (Gap 3) - AI speaks
- [ ] **Notifications delivered from background** (Gap 4) - AI reaches users

### High Priority
- [ ] **Evidence API logging** (Gap 5)
- [ ] **Lazy TTS implemented** (Gap 6)
- [ ] **Witness deep link working** (Track F)
- [ ] **DigitalTruthSensor crash-protected**
- [ ] **Supabase Edge Function deployed**

### Production
- [ ] **Play Store build passing**
- [ ] **Privacy policy updated for emotion data**
- [ ] **Crash reporting enabled (Sentry/Crashlytics)**

---

## 9. Technical Debt Notes

1. **ContextSnapshotBuilder marked @deprecated** - Should migrate to `ContextService`
2. **AppState strangler pattern incomplete** - UI still reads from AppState, not new providers
3. **Guardian Mode TODOs** - Native bridge for real-time session tracking not implemented
4. **Population Learning Edge Functions** - Supabase deployment pending

---

*Generated: 03 January 2026*
