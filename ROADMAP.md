# ROADMAP.md — The Pact

> **Last Updated:** 03 January 2026  
> **Current Strategy:** The Augmented Constitution (Parallel MVP)  
> **Target Launch:** 16 Jan 2026  
> **Identity:** Identity Evidence Engine

---

## 🔒 LOCKED CONFIGURATIONS (Stable)
- **Interactive Model:** `gemini-3-flash-preview` (The Actor)
- **Analysis Model:** `deepseek-chat` (The Analyst)
- **Native Audio:** `gemini-2.5-flash-native-audio-preview-12-2025`
- **TTS Model:** `gemini-2.5-flash-preview-tts` (Lazy Generation)

---

## 🎯 The Unconventional MVP: 5 Parallel Layers

We are ignoring linear versions (v1, v2). We are building 5 interconnected layers simultaneously.

### Layer 1: The Evidence Engine (Foundation)
**Goal:** Database schema with philosophical integrity + privacy guarantees.

| ID | Task | Status |
|----|------|--------|
| E1 | **Schema Definition**: Create `identity_seeds` table in Supabase. | [x] |
| E2 | **RLS Policies**: Enforce user-only access (psychometric data is sensitive). | [x] |
| E3 | **Supabase Repository**: Create `SupabasePsychometricRepository` class. | [x] |
| E4 | **Hybrid Provider**: Update `PsychometricProvider` to write Hive + Supabase. | [x] |
| E5 | **Sync-on-Login**: Pull cloud profile on authentication. | [x] |
| E6 | **Evidence API**: Log observable signals (emotion, tone) + AI-inferred constructs. | [ ] |

### Layer 2: The Shadow & Values Profiler (Onboarding)
**Goal:** Magic Wand Onboarding (Voice-First).
- [ ] **Voice Wand**: 3-minute recording capture.
- [ ] **Sherlock Profiler**: Extract Core Values + Shadow Archetype.
- [ ] **Lazy TTS Refactor**: Switch `GeminiVoiceNoteService` to generate audio ONLY on "Play" click (Cost Savings).
- [ ] **Shadow Dialogue**: Logic for "Talk to my [Perfectionist/Rebel] part".

### Layer 3: The Living Garden Visualization (UI)
**Goal:** A responsive ecosystem, not a chart.
- [ ] **Rive Integration:** `garden_ecosystem` state machine.
- [ ] **Dynamic Inputs:** Wire `hexis_score`, `shadow_presence`, `season` to Rive controller.
- [ ] **Atmospherics:** Weather effects based on user emotional state.

### Layer 4: The Conversational Command Line (Interaction)
**Goal:** Fast, text/voice hybrid command discovery.
- [ ] **Daemon CLI:** Command parsing (`log`, `check`, `gap`, `shadow`).
- [ ] **Voice Interaction**: Enhanced `VoiceCoachScreen` supporting command routing.

### Layer 5: Philosophical Intelligence (The Brain)
**Goal:** Real-time DeepSeek analysis.
- [ ] **Gap Analysis Engine:** Detect dissonance between Stated Values and Behavior.
- [ ] **Socratic Generator:** Turn "data" into "questions" (e.g., "Is this a seasonal dormancy?").

---

## 💰 Monetization & Forward Model

**Structure:** Monthly Subscription.
**Currency:** "Credits".

**Consumption Model:**
1.  **Conversation Turn** = 1 Credit (Transcription + Gemini 3 Reasoning).
2.  **Audio Playback** = +1 Credit (TTS Generation via Lazy Load).
3.  **Deep Insight** = 2 Credits (DeepSeek Gap Analysis).

---

## 🗓️ Weekly Build Plan (Parallel Tracks)

### Track A: Database & Evidence Engine
- [ ] Supabase init with `20260101_augmented_constitution.sql`.
- [ ] Evidence Repository implementation.

### Track B: Voice Interface (The Actor)
- [ ] **Lazy TTS Implementation**: Refactor `VoiceCoachScreen` Play button.
- [ ] **Shadow Persona Prompting**: Update `PromptFactory` for archetypes.

### Track C: Binary Interface (Dashboard Redesign)
- [x] **The Bridge**: Action deck with JITAI sorting.
- [x] **Skill Tree**: Identity growth visualization.
- [x] **Comms Fab**: AI Persona integration (Sherlock/Oracle).

### Track D: Gap Analysis (The Analyst)
- [ ] `PsychometricProvider` → `DeepSeekService` pipeline update.
- [ ] Implementation of `GapAnalysisEngine` logic.

### Track E: Integration
- [ ] Connect CLI commands to Evidence Engine.
- [ ] "Dogfooding" build distribution.

### Track F: Social & Protocol Refinements (User Priority)
- [x] **Witness Investment**: WhatsApp Deep Link Integration (WitnessDeepLinkService).
- [x] **Deferred Witness**: "Start Solo" option for immediate activation.
- [x] **Safety Limits**: Global Nudge Limit (6/day) enforced via Hive.
- [ ] **Betting Logic**: Inverse confidence slider + "Tough Truths AI" fallback.
- [ ] **The Oracle**: Separate `VoiceSessionManager` state + Context Injection from Sherlock.

### Track G-0: Terminology Alignment (URGENT — Prerequisite)

**Status:** 🔴 NOT STARTED — Blocks clear communication

| Task | Status | Priority | Notes |
|------|--------|----------|-------|
| Systematic GLOSSARY review | 🔴 NOT STARTED | **URGENT** | Terms undefined → miscommunication |
| Habit vs Ritual decision | 🔴 NOT STARTED | HIGH | Are they separate concepts? (See GLOSSARY.md) |
| Layer 3 "Living Garden" clarification | 🔴 NOT STARTED | MEDIUM | Does not exist in codebase — aspirational only |
| Align terms across all Core docs | 🔴 NOT STARTED | HIGH | Ensure consistency |

**Why Urgent:**
- Agents and human must share vocabulary
- Undefined terms lead to conflicting implementations
- GLOSSARY should be source of truth

---

### Track G: Identity Coach Implementation (Core Value Proposition)

**Dependency Chain (Must Execute In Order):**

```
RESEARCH PHASE (RQ-006)
├── 1. Aspiration Extraction Research ← FIRST
│   └── Output: Sherlock prompt changes
│
├── 2. Identity Roadmap Data Model ← Depends on #1
│   └── Output: Schema design
│
├── 3. Habit Matching Algorithm ← Depends on #2
│   └── Output: Recommendation logic
│
├── 4. Progress/Regression Metrics ← Depends on #3
│   └── Output: Metric definitions
│
└── 5. Coherence Engine ← Depends on #4
    └── Output: Gap detection logic

IMPLEMENTATION PHASE (After Research)
├── 6. Update Sherlock Prompt ← Depends on research #1
├── 7. Schema Migration ← Depends on research #2
├── 8. Build Recommendation Engine ← Depends on research #3
├── 9. Dashboard Redesign ← Depends on #8
└── 10. Widget Implementation ← Depends on #9
```

| Task | Status | Depends On | Blocking |
|------|--------|------------|----------|
| **RQ-006 Research** | 🔴 NOT STARTED | — | All below |
| Aspiration Extraction (research) | 🔴 NOT STARTED | — | Data Model |
| Identity Roadmap Data Model | 🔴 NOT STARTED | Extraction | Matching |
| Habit Matching Algorithm | 🔴 NOT STARTED | Data Model | Metrics |
| Progress/Regression Metrics | 🔴 NOT STARTED | Matching | Coherence |
| Coherence Engine | 🔴 NOT STARTED | Metrics | Implementation |
| Sherlock Prompt Update | 🔴 NOT STARTED | RQ-006 complete | — |
| Schema Migration | 🔴 NOT STARTED | Data Model | — |
| Recommendation Engine | 🔴 NOT STARTED | Matching | Dashboard |
| Dashboard Redesign | 🔴 NOT STARTED | Engine | Widgets |
| Widget Implementation | 🔴 NOT STARTED | Dashboard | — |

**Reference:** See `docs/CORE/IDENTITY_COACH_SPEC.md` for full specification.

---

## ✅ Completed Legacy Phases (Reference)

### Phase 68.5: Onboarding Polish & Tech Debt (05 Jan 2026)
**Goal:** Harden reliability, add observability, and standardizing error handling.
- [x] **Testing Suite:** 3 Integration Suites (Identity/Conversational/Offline) + Unit Tests. 
- [x] **Analytics:** `AnalyticsService` singleton implementation.
- [x] **Resilience:** `RetryPolicy` for Auth & Psychometric sync.
- [x] **Critical Fix:** `hasHolyTrinity` (OR -> AND) logic correction.
- [x] **Documentation:** `ADR 002` (Dual Flows) & Loading State polish.

### Phase 67: Dashboard Redesign & JITAI Integration (04 Jan 2026)
**Goal:** Integrated interface for Doing (habits) + Being (identity).
- [x] **Binary Interface:** Split Dashboard into "Bridge" (Action) and "Tree" (Growth).
- [x] **RAG Vector Memory:** Semantic search for AI context.
- [x] **JITAI Wiring:** Real-time reordering of habits based on context.

### Phase 68: Onboarding Calibration & Auth Repair (04 Jan 2026)
**Goal:** Stabilize Identity-First flow and ensure schema compliance.
- [x] **V4 Navigation:** `LoadingInsightsScreen` -> `PactTierSelectorScreen` (V4) correction.
- [x] **Schema Integrity:** Removed `email` writes from `AuthService` (PGRST204 Fix).
- [x] **Sherlock Routing:** `SherlockPermissionScreen` -> `VoiceCoachScreen` (Misalignment Fix).

### Phase 66: Witness & Share (04 Jan 2026)
**Goal:** Enable viral social loops and safe accountability.
- [x] **WhatsApp Deep Links**: `WitnessDeepLinkService` with clean URL encoding and fallback.
- [x] **Deferred Witness**: Immediate contract activation with self-witnessing pattern.
- [x] **Nudge Safety**: Local 6-nudge daily limit to prevent harassment.

### Phase 65: Digital Truth & Emotion Integration (03 Jan 2026)
**Goal:** Real-time protection against digital dopamine loops & emotional vulnerability.
- [x] **Digital Truth Sensor**: Guardian Mode polling loop (30s) in `JITAIProvider`.
- [x] **Emotion Context**: `DigitalContext` extensions for affective computing keys.
- [x] **Vulnerability Logic**: `emotionVulnerabilityBoost` modifier in Decision Engine.
- [x] **Privacy Architecture**: Local-only, 2-hour ephemeral storage for emotion data.

### Phase 64: Cloud Hydration & UserProvider (02 Jan 2026)
**Goal:** Fix P0 data loss and modernize state management.
- [x] **Cloud Hydration:** Restore habits from Supabase on fresh install.
- [x] **UserProvider Migration:** Migrate Dashboard & Onboarding to strict Provider pattern.
- [x] **Perf Optimization:** Unblock startup (Witness svc) and first frame (Drift analysis).

### Phase 63: Psychometric Cloud Sync (02 Jan 2026)
**Goal:** Hybrid storage model for Identity Evidence.
- [x] **Schema Alignment**: `habit_contracts` UUID -> TEXT migration.
- [x] **Identity Seeds**: `identity_seeds` table with RLS.
- [x] **Dual Write**: Hive (Local) + Supabase (Cloud) sync in `PsychometricProvider`.

### Phase 62: Sherlock Protocol Refinement (30 Dec 2025)
**Goal:** Align Sherlock with IFS therapy principles and fix privacy leaks.
- [x] IFS Protocol (Protector Parts)
- [x] Autonomy Gate (User Declaration)

### Phase 60: Voice Reliability (Hybrid Stack) (29 Dec 2025)
**Goal:** Fix TTS 400 error and ensure robust audio generation.
- [x] Hybrid Architecture (Reasoning/Mouth split)
- [x] WAV Header Fix (Manual PCM wrapping)
