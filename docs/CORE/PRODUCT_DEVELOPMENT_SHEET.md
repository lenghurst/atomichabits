# Product Development Sheet — The Pact (psyOS)

> **Generated:** 11 January 2026
> **Purpose:** Consolidated view of all decisions, research, and implementation status
> **Reality Check:** Red Team audit verified against actual codebase

---

## Executive Summary

| Category | Complete | Pending | Status |
|----------|----------|---------|--------|
| **CDs** (Confirmed Decisions) | 18/18 | 0 | ✅ 100% |
| **RQs** (Research Questions) | 31/39 | 8 + 7 sub | 🟢 79% |
| **PDs** (Product Decisions) | 15/31 | 16 | 🟡 48% |
| **Tasks** (Implementation) | 4/124 | 120 | 🟡 3% |

**Critical Blocker:** Phase A schema (`identity_facets`, `identity_topology`) DOES NOT EXIST.

**Recent Update (11 Jan):** RQ-039 (Token Economy Architecture) created with 7 sub-RQs. Decision 2 (Token Earning) DEFERRED pending research.

---

## Section 1: Confirmed Decisions (CDs) — All Locked

All 18 CDs are confirmed. These CANNOT change without explicit human approval.

### Tier 1: Core Architecture (CRITICAL)

| CD | Decision | Constraint |
|----|----------|------------|
| **CD-005** | 6-Dimension Archetype Model | Must use 6 behavioral dimensions |
| **CD-015** | psyOS Architecture | Parliament of Selves, not monolithic user |
| **CD-016** | AI Model Strategy | DeepSeek V3.2 (analyst), Gemini (real-time) |
| **CD-017** | Android-First | All features must work on Android without wearables |
| **CD-018** | Engineering Threshold | ESSENTIAL/VALUABLE/NICE-TO-HAVE/OVER-ENGINEERED |

### Tier 2-5: Supporting Decisions

| CD | Decision | Impact |
|----|----------|--------|
| CD-001 | App Name = "The Pact" | LOW |
| CD-002 | AI as Default Witness | MEDIUM |
| CD-003 | Sherlock Before Payment | HIGH |
| CD-006 | GPS Permission Usage | MEDIUM |
| CD-007 | 6+1 Dimension Model (Social) | MEDIUM |
| CD-008 | Identity Development Coach | CRITICAL |
| CD-009 | Content Library | HIGH |
| CD-010 | Retention Tracking Philosophy | MEDIUM |
| CD-011 | Identity Coach Architecture | HIGH |
| CD-012-014 | Git/Code Guardrails | LOW-MEDIUM |

---

## Section 2: Research Questions (RQs) — Triage

### 2.1 COMPLETE (31 RQs) — No Action Needed

| RQ | Topic | Key Deliverable |
|----|-------|-----------------|
| RQ-001–004 | Archetype/Effectiveness | 6-dimension model, tracking |
| RQ-005–007 | Recommendations | Two-stage hybrid retrieval, ICS |
| RQ-008–009 | Engineering Process | Context-Adaptive Development, Vibe Coding |
| RQ-011–016 | psyOS Core | Fractal Trinity, Council AI, State Economics |
| RQ-017–018 | psyOS UX | Constellation, Airlock |
| RQ-019–022, RQ-024 | Infrastructure | pgvector, Treaties, Council Scripts, Treaty Modification |
| RQ-025 | Summon Token Economy | Council Seals (1/week, cap 3, crisis bypass) |
| RQ-028–032 | Identity Coach Phase 2 | 12 Archetypes, Rocchio, Pace Car |
| RQ-033 | Streak Philosophy | Resilient Streak (NMT-based 2-miss threshold) |
| RQ-037 | Holy Trinity Validation | Shadow Cabinet model (Shadow, Saboteur, Script) |

### 2.2 PENDING (8 Main + 7 Sub-RQs) — Triage Required

| RQ | Topic | Priority | Blocked By | Category |
|----|-------|----------|------------|----------|
| **RQ-010** | Permission Data Philosophy | MEDIUM | None | Privacy/Economy |
| **RQ-023** | Population Learning Privacy | MEDIUM | RQ-019 ✅ | Privacy/Economy |
| **RQ-026** | Sound Design & Haptic | LOW | None | UX/Polish |
| **RQ-027** | Template Versioning | LOW | RQ-021 ✅ | Privacy/Economy |
| **RQ-034** | Sherlock Conversation | HIGH | RQ-037 ✅ | UX/Polish |
| **RQ-035** | Sensitivity Detection | MEDIUM | None | Privacy/Economy |
| **RQ-036** | Chamber Visual Design | MEDIUM | RQ-016 ✅ | UX/Polish |
| **RQ-038** | JITAI Component Allocation | MEDIUM | None | Engineering Process |
| **RQ-039** | Token Economy Architecture | **CRITICAL** | RQ-025 ✅ | Privacy/Economy |

**RQ-039 Sub-Questions (7):**
| Sub-RQ | Question | Priority |
|--------|----------|----------|
| RQ-039a | Earning mechanism & intrinsic motivation | CRITICAL |
| RQ-039b | Optimal reflection cadence | HIGH |
| RQ-039c | Single vs multiple earning paths | HIGH |
| RQ-039d | Token cap vs decay alternatives | HIGH |
| RQ-039e | Crisis bypass threshold validation | HIGH |
| RQ-039f | Premium token allocation | MEDIUM |
| RQ-039g | Reflection quality thresholds | MEDIUM |

### 2.3 Research Verdict

**Recently Completed (11 Jan 2026):**
- ✅ RQ-025 (Summon Token Economy) — Council Seals economy defined
- ✅ RQ-033 (Streak Philosophy) — Resilient Streak concept validated
- ✅ RQ-037 (Holy Trinity Validation) — Shadow Cabinet model confirmed

**Outstanding by Category:**

| Category | RQs | Priority Focus |
|----------|-----|----------------|
| **Token Economy** | RQ-039 + 7 sub-RQs | CRITICAL — Blocks PD-119 |
| **UX/Polish** | RQ-026, RQ-034, RQ-036 | MEDIUM — Pre-launch refinement |
| **Privacy/Economy** | RQ-010, RQ-023, RQ-027, RQ-035 | LOW-MEDIUM — Post-launch |
| **Engineering** | RQ-038 | MEDIUM — JITAI allocation |

**Net Effect:** 31/39 (79%) main RQs COMPLETE. 8 main + 7 sub-RQs remain. HIGH priority: RQ-039 (Token Economy), RQ-034 (Sherlock).

---

## Section 3: Product Decisions (PDs) — Resolution Path

### 3.1 RESOLVED (14 PDs) — No Action Needed

| PD | Decision | Resolution |
|----|----------|------------|
| PD-001 | Archetype Philosophy | → CD-005 |
| PD-106 | Multiple Identity | → CD-015 |
| PD-108–112 | Constellation/Airlock UX | All resolved via RQ-017/018 |
| PD-113–115 | Treaty Priority/Creation | All resolved via RQ-020/021 |
| PD-117 | ContextSnapshot Data | Resolved via RQ-014 |
| PD-121–125 | Identity Coach Phase 2 | All resolved via RQ-028–032 |

### 3.2 READY TO RESOLVE (12 PDs) — Decision Needed

These PDs have NO research blockers. Human decision required.

| PD | Question | Options | Recommendation |
|----|----------|---------|----------------|
| **PD-002** | Streaks vs Rolling Consistency | gracefulScore OR currentStreak | `gracefulScore` — aligns with CD-005 dimensions |
| **PD-003** | Holy Trinity Validity | Keep 3 traits OR expand | KEEP — Proven extraction pattern |
| **PD-004** | Dev Mode Purpose | Rename OR keep | DEFER — Low impact |
| **PD-101** | Sherlock Prompt Overhaul | Which of 2 prompts? | CONSOLIDATE to single prompt |
| **PD-102** | JITAI Hardcoded vs AI | Hardcoded OR AI-driven | HYBRID — Already implemented |
| **PD-103** | Sensitivity Detection | Add 7th dimension? | DEFER — Needs social features first |
| **PD-104** | LoadingInsights Personalization | What to show? | DEFER — Cosmetic |
| **PD-105** | Unified AI Coaching Architecture | How to integrate? | ✅ READY — RQ-005/006/007 complete |
| **PD-107** | Proactive Guidance System | Architecture decision | ✅ READY — RQ-005/006/007 complete |
| **PD-120** | Chamber Visual Design | Design direction | DEFER — Needs design session |
| **PD-201** | URL Scheme Migration | atomichabits → thepact | DO IT — Simple change |
| **PD-202** | Archive Documentation Handling | How to manage? | CURRENT APPROACH WORKS |

### 3.3 BLOCKED BY RESEARCH (3 PDs)

| PD | Blocked By | Status |
|----|------------|--------|
| PD-116 | RQ-023 (Privacy) | DEFER — Post-launch |
| PD-118 | RQ-024 (Treaty Mod) | ✅ RESOLVED — Constitutional Amendment Model |
| PD-119 | RQ-025 (Summon Token) | DEFER — Post-launch |

### 3.4 Resolution Priorities

| Priority | PDs to Resolve | Action |
|----------|----------------|--------|
| **NOW** | PD-105, PD-107 | Architecture decisions — unblocked |
| **SOON** | PD-002, PD-003, PD-101 | Core UX — simple decisions |
| **LATER** | PD-102, PD-104, PD-120, PD-201, PD-202 | Non-blocking |
| **POST-MVP** | PD-103, PD-116, PD-118, PD-119, PD-004 | Gamification/privacy/low-impact |

---

## Section 4: Implementation Plan (IP) — Reality-Based

### 4.1 Current Reality (Red Team Verified)

| Component | Status | Impact |
|-----------|--------|--------|
| `identity_seeds` table | ✅ EXISTS | Sherlock Protocol works |
| `identity_facets` table | ❌ DOES NOT EXIST | **BLOCKS Phase G, H** |
| `identity_topology` table | ❌ DOES NOT EXIST | **BLOCKS Phase H** |
| `skill_tree.dart` | ✅ PRODUCTION-READY (549 lines) | Fallback visualization |
| `the_bridge.dart` | ✅ PRODUCTION-READY (478 lines) | JITAI cards work |
| Audio files | ❌ 0 BYTES (placeholders) | Needs sourcing |
| JITAI system | ✅ EXTENSIVE (41 files) | Core is working |

### 4.2 Correct Implementation Order

```
PHASE 0: DECISIONS (NOW)
├── Resolve PD-105 (Unified AI Coaching)
├── Resolve PD-107 (Proactive Guidance)
├── Resolve PD-002 (Streaks vs Consistency)
└── Resolve PD-101 (Sherlock Prompt)

PHASE A: SCHEMA FOUNDATION (CRITICAL BLOCKER)
├── A-01: Create identity_facets table ◄── UNBLOCKS EVERYTHING
├── A-02: Create identity_topology table
├── A-03: Create facet_relationships table
├── A-04: Create facet_habits linking table
├── A-05: Add habit_facet_links energy_state field
├── A-06: Create habits_content table
└── A-07-A-10: Supporting tables

PHASE B: INTELLIGENCE LAYER
├── B-01–B-05: JITAI enhancements
├── B-06–B-10: Recommendation engine
└── B-11–B-15: Content pipeline

PHASE C: COUNCIL AI SYSTEM
├── C-01–C-06: Treaty infrastructure
└── C-07–C-12: Council session flow

PHASE D: UX & FRONTEND
├── D-01–D-06: Treaty UI
└── D-07–D-10: Dashboard enhancements

PHASE E: POLISH & ADVANCED
├── E-01–E-04: Summon Tokens (POST-MVP)
├── E-05–E-06: Treaty Modification
└── E-07–E-10: Analytics

PHASE F: IDENTITY COACH SYSTEM
├── F-01–F-10: Content library
└── F-11–F-20: Recommendation logic

PHASE G: IDENTITY COACH INTELLIGENCE
├── G-01: Add ics_score to identity_facets ◄── Requires A-01
├── G-02–G-07: Archetype system
└── G-08–G-14: Preference learning

PHASE H: CONSTELLATION & AIRLOCK (🔴 BLOCKED)
├── H-01–H-09: Constellation visualization ◄── Requires A-01, A-02, G-01
├── H-10–H-14: Airlock UX
└── H-15–H-16: Navigation
```

### 4.3 Task Summary by Phase

| Phase | Tasks | Status | Blocker |
|-------|-------|--------|---------|
| **A: Schema** | 10 | 🔴 NOT STARTED | None — START HERE |
| **B: Intelligence** | 15 | 🔴 NOT STARTED | Phase A |
| **C: Council AI** | 12 | 🔴 NOT STARTED | Phase A, B |
| **D: UX** | 10 | 🔴 NOT STARTED | Phase A |
| **E: Polish** | 10 | 🔴 NOT STARTED | Phases A-D |
| **F: Identity Coach** | 20 | 🔴 NOT STARTED | Phases A-D |
| **G: Coach Intelligence** | 14 | 🔴 NOT STARTED | Phase A, F |
| **H: Constellation** | 16 | 🔴 BLOCKED | Phases A, G |

---

## Section 5: Recommended Action Plan

### Immediate Actions (This Week)

| # | Action | Owner | Outcome |
|---|--------|-------|---------|
| 1 | **Resolve PD-105** | Human | Unified AI Coaching architecture confirmed |
| 2 | **Resolve PD-107** | Human | Proactive Guidance architecture confirmed |
| 3 | **Resolve PD-002** | Human | Streaks vs Consistency decided |
| 4 | **Implement A-01** | Developer | `identity_facets` table exists |
| 5 | **Implement A-02** | Developer | `identity_topology` table exists |

### Short-Term Actions (This Sprint)

| # | Action | Owner | Outcome |
|---|--------|-------|---------|
| 6 | Complete Phase A (A-03 through A-10) | Developer | Schema foundation complete |
| 7 | Resolve PD-101 (Sherlock Prompt) | Human | Single canonical prompt |
| 8 | ✅ RQ-024 COMPLETE | — | Treaty flow spec ready |
| 9 | Begin Phase B (Intelligence Layer) | Developer | JITAI enhanced |

### What NOT to Do

| ❌ Don't | Why |
|----------|-----|
| Research RQ-026 (Sound Design) | Phase H blocked anyway |
| Implement Phase H tasks | No schema to work with |
| Research RQ-008, RQ-009, RQ-027 | Low priority, not blocking |
| Worry about audio files | Can source later |

---

## Section 6: Decision Required

### Human Decisions Needed

| PD | Question | Default Recommendation |
|----|----------|------------------------|
| **PD-105** | How should Unified AI Coaching integrate with JITAI? | Two-Stage Hybrid per RQ-005 |
| **PD-107** | What is the Proactive Guidance System architecture? | The Architect + The Commander per RQ-005 |
| **PD-002** | Streaks or Rolling Consistency? | `gracefulScore` (rolling) |
| **PD-101** | Which Sherlock prompt is canonical? | Consolidate to single prompt in prompt_factory.dart |

**Once these 4 PDs are resolved, implementation can begin.**

---

## Appendix: Dependency Graph

```
CD-005 (6-Dimension) ────────────────────────────────────────────────────────►
    │
CD-015 (psyOS) ──────────────────────────────────────────────────────────────►
    │
    ├── RQ-012 (Fractal Trinity) ✅
    │       ├── RQ-013–015 ✅
    │       ├── RQ-016 (Council) ✅
    │       │       ├── RQ-021–022 ✅
    │       │       └── RQ-024 ✅ ← COMPLETE
    │       ├── RQ-017–018 ✅
    │       └── RQ-019–020 ✅
    │
    ├── Phase A (Schema) ◄──────────────────────── START HERE
    │       ├── Phase B (Intelligence)
    │       ├── Phase C (Council)
    │       ├── Phase D (UX)
    │       └── Phase E-H
    │
    └── PD-105, PD-107 ◄────────────────────────── RESOLVE THESE
```

---

*This Product Development Sheet consolidates all governance documents into a single actionable view.*
