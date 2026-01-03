# AtomicHabits Sprint Planning: 16 Jan 2026 Launch

**Date:** 03 January 2026
**Analysis Scope:** Complete data flow mapping, gap identification, sprint prioritization

---

## Executive Summary

The JITAI system core is **well-implemented** but **not wired to UI**. This is the single biggest gap blocking launch. The 5-layer architecture has Layer 1 (Evidence Engine) mostly complete, but Layers 2-5 are incomplete.

**Launch Readiness:** 60% complete
**Blocking Issues:** 4 P0 gaps identified
**Recommended Sprint Focus:** "Wire JITAI to UI" + "Notification Pipeline"

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

### Gap 1: JITAI NOT WIRED TO UI (Critical)

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

### Gap 2: Notification Pipeline Incomplete (Critical)

**Impact:** Background interventions never reach users.
**Effort:** 1-2 days
**Files to modify:**

| File | Changes Required |
|------|-----------------|
| `lib/data/services/jitai/jitai_background_worker.dart` | Call `deliverIntervention()` from background task |
| `lib/data/providers/jitai_provider.dart` | Trigger notification on `checkIntervention()` result |

**Current state:** `JITAINotificationService.deliverIntervention()` exists but is never called.

### Gap 3: Evidence API Missing (High)

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

### Gap 4: Lazy TTS Not Implemented (Medium)

**Impact:** Cost overrun on TTS generation (every response generates audio, even if not played).
**Effort:** 0.5 days
**Files to modify:** `lib/data/services/gemini_voice_note_service.dart`

**Current:** TTS generated eagerly on every response.
**Target:** Generate on "Play" button click only.

---

## 4. Hidden Dependencies

```
┌──────────────────────────────────────────────────────────────────────────┐
│                        DEPENDENCY GRAPH                                   │
├──────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  Evidence API (Gap 3) ◄──────────── Required by:                          │
│                                     - Gap Analysis Engine (Layer 5)       │
│                                     - Population Learning                 │
│                                     - Guardian Mode logging               │
│                                                                           │
│  Wire JITAI to UI (Gap 1) ◄──────── Required by:                          │
│                                     - User testing                        │
│                                     - Intervention outcome tracking       │
│                                     - Bandit learning                     │
│                                                                           │
│  Notification Pipeline (Gap 2) ◄─── Required by:                          │
│                                     - Background intervention delivery    │
│                                     - User engagement                     │
│                                                                           │
│  PsychometricProfile ◄───────────── Required by:                          │
│                                     - JITAI archetype-specific messaging  │
│                                     - Shadow interventions                │
│                                     - Population priors                   │
│                                                                           │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## 5. Sprint Recommendation

### Sprint 1: "Surface the Engine" (Days 1-4)

**Goal:** Make JITAI visible to users.

| Priority | Task | Effort | Owner |
|----------|------|--------|-------|
| P0 | Wire `JITAIInsightsCard` to TodayScreen | 4h | - |
| P0 | Wire `CascadeAlertBanner` to Dashboard | 2h | - |
| P0 | Trigger `runForegroundCheck()` on app open | 2h | - |
| P0 | Show `InterventionModal` when intervention triggered | 3h | - |
| P0 | Connect notification tap to intervention handler | 3h | - |
| P1 | Call `deliverIntervention()` from background worker | 4h | - |
| P1 | Persist intervention outcomes to bandit | 2h | - |

**Deliverable:** Users see timing insights, cascade warnings, and receive interventions.

### Sprint 2: "Evidence Foundation" (Days 5-7)

**Goal:** Complete Layer 1 with Evidence API.

| Priority | Task | Effort | Owner |
|----------|------|--------|-------|
| P1 | Create `EvidenceService` | 4h | - |
| P1 | Log habit completions as identity evidence | 2h | - |
| P1 | Log emotion from voice sessions | 2h | - |
| P1 | Log doom scroll sessions from Guardian Mode | 2h | - |
| P2 | Implement Lazy TTS refactor | 4h | - |

**Deliverable:** Identity evidence logged, cost savings from lazy TTS.

### Sprint 3: "Witness & Share" (Days 8-10)

**Goal:** Social accountability loop.

| Priority | Task | Effort | Owner |
|----------|------|--------|-------|
| P1 | Witness deep link (WhatsApp share) | 8h | - |
| P2 | "Ask your best witness" intervention action | 4h | - |
| P2 | Witness ranking display in settings | 4h | - |

**Deliverable:** Users can invite witnesses via WhatsApp.

---

## 6. Impact vs Effort Matrix

```
                          HIGH IMPACT
                              │
    ┌─────────────────────────┼─────────────────────────┐
    │  DO NOW                 │  PLAN CAREFULLY         │
    │                         │                         │
    │  • Wire JITAI to UI     │  • Voice Wand (Layer 2) │
    │  • Notification Pipeline│  • Gap Analysis Engine  │
    │  • Evidence API         │  • Population Learning  │
    │                         │                         │
LOW ├─────────────────────────┼─────────────────────────┤ HIGH
EFFORT                        │                         EFFORT
    │  QUICK WINS             │  DEFER                  │
    │                         │                         │
    │  • Lazy TTS             │  • Living Garden (Rive) │
    │  • Guardian Mode TODOs  │  • Command CLI          │
    │                         │  • Contextual Bandits   │
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

- [ ] **JITAI visible in UI** (Gap 1)
- [ ] **Notifications delivered from background** (Gap 2)
- [ ] **Evidence API logging** (Gap 3)
- [ ] **Lazy TTS implemented** (Gap 4)
- [ ] **Witness deep link working** (Track F)
- [ ] **Play Store build passing**
- [ ] **Privacy policy updated for emotion data**

---

## 9. Technical Debt Notes

1. **ContextSnapshotBuilder marked @deprecated** - Should migrate to `ContextService`
2. **AppState strangler pattern incomplete** - UI still reads from AppState, not new providers
3. **Guardian Mode TODOs** - Native bridge for real-time session tracking not implemented
4. **Population Learning Edge Functions** - Supabase deployment pending

---

*Generated: 03 January 2026*
