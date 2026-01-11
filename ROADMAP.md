# ROADMAP.md — The Pact

> **Last Updated:** 11 January 2026 (Codebase reality audit — Phase 1 status corrected to PARTIAL)
> **Current Strategy:** psyOS Full Implementation at Launch (NOT phased per PD-114)
> **Target Launch:** TBD (Full psyOS scope requires significant build)
> **Identity:** Psychological Operating System (psyOS)

---

## 🔒 LOCKED CONFIGURATIONS (Stable)

### AI Model Strategy (CD-016)

**Multi-Model Architecture:**
| Use Case | Model | Model ID | Rationale |
|----------|-------|----------|-----------|
| **Real-time Voice (Sherlock)** | Gemini 3 Flash | `gemini-3-flash-preview` | Latency-critical |
| **Real-time Voice (TTS)** | Gemini 2.5 Flash TTS | `gemini-2.5-flash-preview-tts` | Quality, SSML |
| **Embedding Generation** | **gemini-embedding-001** | `gemini-embedding-001` | Purpose-built, Matryoshka, 3072-dim |
| **Council AI Scripts** | **DeepSeek V3.2** | `deepseek-v3.2-chat` | Complex reasoning, cost-effective |
| **Root Psychology Synthesis** | **DeepSeek V3.2** | `deepseek-v3.2-chat` | Deep analysis |
| **Gap Analysis** | **DeepSeek V3.2** | `deepseek-v3.2-chat` | Pattern detection |
| **Native Audio** | Gemini 2.5 Flash Audio | `gemini-2.5-flash-native-audio-preview-12-2025` | Voice input |

**Model Split:**
- **Gemini**: Real-time voice, TTS, embeddings (latency-critical + purpose-built)
- **DeepSeek V3.2**: Reasoning tasks (Council AI, Root Synthesis, Gap Analysis)
- **Hardcoded**: JITAI logic, Treaty enforcement (json_logic_dart)

**Legacy Configuration (Deprecated):**
- ~~**Analysis Model:** `deepseek-chat`~~ → Now `deepseek-v3.2-chat` (CD-016)
- ~~**Embedding Model:** text-embedding-004~~ → Now `gemini-embedding-001` (RQ-019)

---

## 🎯 Development Phases

Development follows a **phase-based model** where each phase enables the next. Tracks run within phases as parallel workstreams.

```
                    Phase 0      Phase 1      Phase 2      Phase 3
                    Research     Foundation   Intelligence User Exp
                    ─────────────────────────────────────────────────
Track A (Database)     ─            ████           ░           ░
Track B (Voice)        ─            ████          ███         ███
Track C (Dashboard)    ─              ─            ░          ████ ✅
Track D (Gap Analysis) ████ blocked   ░           ░░░          ░
Track G (Identity)     ████ blocked   ░            ░           ░░░
```

### Phase 0: Research & Decisions (PERPETUAL)
**What It Is:** The "thinking" work that informs building. Phase 0 never completes — new questions emerge as we build.

**Contains:**
- Research Questions (RQ-XXX) — Open investigations
- Product Decisions (PD-XXX) — Pending choices
- Confirmed Decisions (CD-XXX) — Locked choices

**Major Decision: CD-015 — psyOS Architecture**
On 05 January 2026, the decision was made to pursue **psyOS (Psychological Operating System)** architecture for launch, not the simpler MVP approach. This generates new research questions:

**psyOS Research Queue (CRITICAL):**
- RQ-012: Fractal Trinity Architecture
- RQ-013: Identity Topology & Graph Modeling
- RQ-014: State Economics & Bio-Energetic Conflicts
- RQ-015: Polymorphic Habits Implementation
- RQ-016: Council AI (Roundtable Simulation)
- RQ-017: Constellation UX (Solar System Visualization)
- RQ-018: Airlock Protocol & Identity Priming

**Resolved:**
- ~~RQ-011 (Multiple Identities)~~ → ✅ Resolved via CD-015
- ~~RQ-005/006/007 (Proactive Guidance)~~ → ✅ Complete (PD-105, PD-107 now READY)
- ~~RQ-012→022 (psyOS Core)~~ → ✅ Complete (Council AI, Treaties, Airlock)
- ~~RQ-025/033/037 (Gamification)~~ → ✅ Complete (Council Seals, Resilient Streak, Shadow Cabinet)

**Still Blocking:**
- RQ-010 (Permission Data) → Blocks Phase 2 JITAI refinement
- RQ-023 (Population Privacy) → Blocks PD-116
- RQ-034 (Sherlock Architecture) → Blocks PD-101 (partially unblocked by RQ-037)
- RQ-035/036/038 (Sensitivity, Chamber, JITAI Allocation) → Block various PDs

**See:** `docs/CORE/RESEARCH_QUESTIONS.md` for full list

---

### Phase 1: Foundation
**What It Is:** Infrastructure — data, auth, core services.

| Component | Status | Notes |
|-----------|--------|-------|
| Database schemas (Supabase) | 🟡 **Partial** | `identity_seeds`, `habit_contracts` exist; **`identity_facets`, `identity_topology`, `treaties` NOT CREATED** — Blocks Phase B-H |
| Auth flow | ✅ Done | Supabase Auth |
| Core repositories | ✅ Done | `PsychometricRepository` |
| Permission capture | 🟡 Partial | Captured but underutilized |
| Evidence logging (E6) | 🔴 Not done | Log observable signals |
| **Missing `habits` table** | 🔴 Not done | FK reference in `conversations` but table never created |

> ⚠️ **AUDIT NOTE (11 Jan 2026):** Phase A schema is 0% complete. 104 of 116 tasks are BLOCKED until `identity_facets`, `identity_topology`, and `treaties` tables are created. See `docs/analysis/SESSION_22_CODEBASE_REALITY_AUDIT.md`.

---

### Phase 2: Intelligence
**What It Is:** The "brain" — systems that analyze, decide, recommend.

| Component | Status | Notes |
|-----------|--------|-------|
| JITAI Decision Engine | ✅ Done | — |
| Thompson Sampling | ✅ Done | — |
| V-O Calculator | ✅ Done | — |
| Gap Analysis Engine | 🟡 Ready to build | RQ-005/006/007 ✅ complete |
| Recommendation Engine | 🟡 Ready to build | RQ-005/006/007 ✅ complete |
| Dimension Inference | ✅ Done | RQ-003 complete |

---

### Phase 3: User Experience
**What It Is:** User-facing journeys that consume intelligence.

| Journey | Status | Notes |
|---------|--------|-------|
| Onboarding (Sherlock) | 🟡 Partial | Works but prompt needs overhaul |
| Daily Loop (Dashboard) | 🟡 Partial | Bridge + Skill Tree done |
| Growth Path (Coaching) | 🔴 Not done | Blocked by Phase 2 |
| Interventions | ✅ Done | JITAI-powered |

---

### Future Features (Not in Current Roadmap)
These are parked until blocking decisions are made.

| Feature | Blocking Decision |
|---------|-------------------|
| Living Garden | SUPERSEDED by Constellation UX (CD-015) |
| Conversational CLI | CD-004 rejected this |
| Power Words / Lexicon | Content strategy TBD |
| Shadow Dialogue | Now part of Council AI (CD-015) |

---

## 🧠 psyOS Implementation Roadmap (CD-015)

The psyOS architecture represents a fundamental shift from "habit tracker" to "Psychological Operating System." This section outlines the implementation phases.

### psyOS Philosophy
```
OLD: Habit Tracker with Identity Features
NEW: Psychological Operating System

Key Shifts:
- Monolithic Self → Parliament of Selves
- Discipline → Governance (Coalition)
- Conflict = Bug → Conflict = Core Value
- Linear Progress → Identity Topology (Graph)
- Time Scheduling → State Economics (Bio-energetic)
- Generic Habits → Polymorphic Habits
- AI Assistant → Council AI (Parliament Mediator)
- Tree Visualization → Constellation UX (Solar System)
```

### psyOS Implementation Phases

```
PHASE A: Schema & Foundation
├── psychometric_roots table (Root fears, temperament)
├── identity_facets table (with status, energy_state)
├── psychological_manifestations table (Fractal Trinity)
├── identity_topology table (Graph relationships)
└── habit_facet_links table (Many-to-many)

PHASE B: Core Intelligence
├── Fractal Trinity extraction (Sherlock updates)
├── Identity Topology inference
├── Energy State detection
├── Tension Score calculation (0.0-1.0)
└── JITAI integration with facets

PHASE C: Council AI
├── Multi-agent prompt architecture
├── Facet agent character design
├── Treaty proposal mechanics
├── Async Council notifications
└── Voice + text integration

PHASE D: Constellation UX
├── Solar System visualization
├── Planet metrics mapping
├── Orbital mechanics (decay, wobble)
├── Interaction design
└── Migration from Skill Tree

PHASE E: Airlock & Priming
├── Energy state conflict detection
├── Transition ritual content
├── Audio asset pipeline
├── Identity Priming notifications
└── Effectiveness measurement
```

### psyOS Task Breakdown (Full Implementation at Launch)

> **CRITICAL:** Per PD-114, ALL psyOS features will be implemented at launch, not phased.

| Phase | Component | RQ | PD | Status | AI Model |
|-------|-----------|----|----|--------|----------|
| **A** | `psychometric_roots` schema (pgvector) | RQ-012 ✅ | — | 🟢 Ready to build | N/A |
| **A** | `psychological_manifestations` schema | RQ-012 ✅ | — | 🟢 Ready to build | N/A |
| **A** | `treaties` schema (logic_hooks JSONB) | RQ-016 ✅ | PD-113 ✅ | 🟢 Ready to build | N/A |
| **A** | `identity_facets` with status | RQ-011 ✅ | — | 🟢 Ready to build | N/A |
| **A** | `identity_topology` schema | RQ-013 ✅ | — | 🟢 Ready to build | N/A |
| **A** | `habit_facet_links` schema | RQ-015 ✅ | PD-111 ✅ | 🟢 Ready to build | N/A |
| **B** | Triangulation Protocol (Day 1→4→7) | RQ-012 ✅ | — | 🟢 Ready to build | Gemini 3 Flash |
| **B** | Sherlock Day 7 root synthesis | RQ-012 ✅ | — | 🟢 Ready to build | **DeepSeek V3.2** |
| **B** | Chronotype-JITAI Matrix | RQ-012 ✅ | — | 🟢 Ready to build | Hardcoded |
| **B** | Topology inference | RQ-013 ✅ | — | 🟢 Ready to build | N/A |
| **B** | Energy State detection | RQ-014 ✅ | — | 🟢 Ready to build | N/A |
| **B** | Tension Score calculation | — | — | 🟢 Ready to build | N/A |
| **C** | Single-Shot Playwright prompt | RQ-016 ✅ | — | 🟢 Ready to build | **DeepSeek V3.2** |
| **C** | Council UI (text bubbles, avatars) | RQ-016 ✅ | — | 🟢 Ready to build | N/A |
| **C** | Treaty signing flow | RQ-016 ✅ | PD-109 ✅ | 🟢 Ready to build | N/A |
| **C** | Treaty enforcement in JITAI | RQ-016 ✅ | PD-113 ✅ | 🟢 Ready to build | Hardcoded |
| **C** | Audiobook Pattern TTS | RQ-016 ✅ | — | 🟢 Ready to build | Gemini 2.5 TTS |
| **D** | Constellation visualization | RQ-017 ✅ | PD-108 ✅ | 🟢 Ready to build | N/A |
| **D** | Skill Tree migration | — | PD-108 ✅ | 🟢 Ready to build | N/A |
| **E** | Airlock triggers | RQ-018 ✅ | PD-110 ✅ | 🟢 Ready to build | N/A |
| **E** | Identity Priming audio | RQ-018 ✅ | PD-112 ✅ | 🟢 Ready to build | Gemini 2.5 TTS |

### psyOS Schema Summary

```sql
-- CORE TABLES (New for psyOS)
psychometric_roots           -- Global psychology (root fears, temperament)
identity_facets              -- User's identity parts (with status, energy)
psychological_manifestations -- How roots manifest per facet
identity_topology            -- Relationships between facets (graph)
habit_facet_links            -- Many-to-many: habits serve facets

-- KEY FIELDS
identity_facets.status       -- 'active', 'maintenance', 'dormant'
identity_facets.energy_state -- 'high_focus', 'high_physical', 'social', 'recovery'
identity_topology.friction_coefficient  -- 0.0-1.0 tension score
identity_topology.switching_cost_minutes -- Bio-energetic recovery
```

### Critical Path for psyOS

```
✅ ALL RESEARCH COMPLETE — READY TO BUILD

RQ-012 (Fractal Trinity) ✅ ───┐
RQ-016 (Council AI) ✅ ────────┼──→ Phase A + C = Core psyOS Value ✅
RQ-013 (Topology) ✅ ──────────┘

RQ-017 (Constellation) ✅ ─────┐
RQ-015 (Polymorphic) ✅ ───────┼──→ Phase D + Habits = UX Differentiator ✅
                               │
RQ-014 (State Economics) ✅ ───┤
RQ-018 (Airlock/Priming) ✅ ───┴──→ Phase E = Full psyOS Experience ✅
```

**Research Status (Updated 11 Jan 2026):**

**Overall Progress:** 31/40 RQs Complete (78%) + 7 sub-RQs pending + 1 DEFERRED

| Category | RQs | Status | Key Deliverables |
|----------|-----|--------|------------------|
| **Foundation** | RQ-001→009 | ✅ COMPLETE | Archetypes, Recommendations, Roadmap |
| **psyOS Core** | RQ-012→022 | ✅ COMPLETE | Fractal Trinity, Council AI, Treaties, Airlock |
| **Gamification** | RQ-025, 033, 037 | ✅ COMPLETE | Council Seals, Resilient Streak, Shadow Cabinet |
| **Remaining** | 8 main + 7 sub | 🔴 NEEDS RESEARCH | See below (includes RQ-039 Token Economy) |
| **Deferred** | RQ-040 | 🟡 DEFERRED | Implementation Prompt Engineering (deferred per red team) |

**Remaining Research Queue:**
| RQ | Topic | Blocking | Priority |
|----|-------|----------|----------|
| RQ-010 | Permission Data Philosophy | JITAI refinement | Medium |
| RQ-023 | Population Learning Privacy | PD-116 | Medium |
| RQ-026 | Sound Design & Haptics | UX polish | Low |
| RQ-027 | Treaty Template Versioning | Treaty maintenance | Low |
| RQ-034 | Sherlock Conversation Architecture | PD-101 (partial) | High |
| RQ-035 | Sensitivity Detection Framework | PD-103 | Medium |
| RQ-036 | Chamber Visual Design Patterns | PD-120 | Medium |
| RQ-038 | JITAI Component Allocation | PD-102 | Medium |

**Decisions Now READY (Unblocked by Research):**
- 🟢 **PD-002** (Streaks vs Rolling Consistency) — RQ-033 complete: Resilient Streak recommended
- 🟢 **PD-003** (Holy Trinity Validity) — RQ-037 complete: Shadow Cabinet display layer validated
- 🟡 **PD-119** (Summon Token Economy) — DEFERRED pending RQ-039 research (7 sub-RQs)
- 🟢 **PD-105** (Unified AI Coaching) — RQ-005/006/007 complete
- 🟢 **PD-107** (Proactive Guidance System) — RQ-005/006/007 complete

**Decisions Still Pending (Blocked by Research):**
- 🔴 **PD-101** (Sherlock Prompt Overhaul) — Partially unblocked, needs RQ-034
- 🔴 **PD-102** (JITAI Hardcoded vs AI) — Needs RQ-038
- 🔴 **PD-103** (Sensitivity Detection) — Needs RQ-035
- 🔴 **PD-116** (Population Learning Privacy) — Needs RQ-023
- 🔴 **PD-120** (Chamber Visual Design) — Needs RQ-036

**Upstream/Downstream Impact Analysis:**
| Existing Decision | Impact | Action |
|-------------------|--------|--------|
| **CD-015** (psyOS) | ✅ Validated | Implementation path now clear |
| **CD-016** (AI Model) | ✅ Updated | gemini-embedding-001 for embeddings |
| **PD-106** (Identity Architecture) | ✅ RESOLVED → CD-015 | Archived to Q1-2026 |
| **RQ-013** (Identity Topology) | ✅ COMPLETE | Graph modeling defined |
| **RQ-014** (State Economics) | ✅ COMPLETE | Energy state detection ready |
| **PD-002** (Streaks) | 🟢 READY | Resilient Streak via RQ-033 |
| **PD-003** (Holy Trinity) | 🟢 READY | Shadow Cabinet via RQ-037 |
| **PD-119** (Summon Tokens) | 🟢 READY | Council Seals via RQ-025 |

---

## 📦 Legacy Layers (DEPRECATED)

> **Note:** The "5 Parallel Layers" concept is deprecated. Use Phases + Tracks instead.
> Retained below for historical reference only.

<details>
<summary>Click to expand deprecated layers</summary>

### Layer 1: The Evidence Engine (Foundation)
**Status:** ✅ Mostly complete (5/6 tasks)
- [x] Schema Definition
- [x] RLS Policies
- [x] Supabase Repository
- [x] Hybrid Provider
- [x] Sync-on-Login
- [ ] Evidence API (E6)

### Layer 2: The Shadow & Values Profiler (Onboarding)
**Status:** 🟡 Partial — This is really onboarding, not a "layer"

### Layer 3: The Living Garden Visualization (UI)
**Status:** ❌ NOT IMPLEMENTED — Moved to Future Features

### Layer 4: The Conversational Command Line (Interaction)
**Status:** ❌ REJECTED — See CD-004

### Layer 5: Philosophical Intelligence (The Brain)
**Status:** 🟡 Partial — DeepSeek exists, Gap Analysis Engine doesn't

</details>

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

### Track G-0: Terminology Alignment (Prerequisite)

**Status:** ✅ COMPLETE (05 January 2026)

| Task | Status | Notes |
|------|--------|-------|
| Systematic GLOSSARY review | ✅ Done | Ghost terms identified, PGS hierarchy added |
| Habit vs Ritual decision | 🟡 Deferred | Part of broader dashboard/recommendation architecture (RQ-005/006/007) |
| Layer 3 "Living Garden" clarification | ✅ Done | Moved to Future Features, not a "layer" |
| Align terms across all Core docs | ✅ Done | Behavioral dimensions, PGS, policies added |
| Ghost Term Policy | ✅ Done | Added to GLOSSARY.md |
| Signposting Guidance | ✅ Done | Added to GLOSSARY.md |

**Outcome:**
- GLOSSARY now includes: Proactive Guidance System, Behavioral Dimensions, Ghost Term Policy
- Deprecated terms marked: Hexis Score, Puck
- Phase structure replaces Layer concept

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
| **RQ-005/006/007 Research** | ✅ COMPLETE | — | None |
| Aspiration Extraction (research) | ✅ COMPLETE | — | — |
| Identity Roadmap Data Model | ✅ COMPLETE | Extraction | — |
| Habit Matching Algorithm | ✅ COMPLETE | Data Model | — |
| Progress/Regression Metrics | ✅ COMPLETE | Matching | — |
| Coherence Engine | ✅ COMPLETE | Metrics | — |
| Sherlock Prompt Update | 🟡 Ready to build | RQ-006 ✅ | — |
| Schema Migration | 🟡 Ready to build | Data Model ✅ | — |
| Recommendation Engine | 🟡 Ready to build | Matching ✅ | Dashboard |
| Dashboard Redesign | 🟡 Ready to build | Engine | Widgets |
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
