# IMPLEMENTATION_ACTIONS.md — Canonical Task Tracker & Agent Routing

> **Last Updated:** 11 January 2026 (Reconciled: 13 protocols, 116 tasks, RQ-040 DEFERRED)
> **Purpose:** Single source of truth for implementation tasks + agent navigation hub
> **Status:** Active — MUST be updated during Protocol 8 and Protocol 9
> **Audience:** All AI agents (Claude, DeepSeek, Gemini, ChatGPT, future agents)

---

## CRITICAL NOTICE: Implementation Reality Check

**Status:** 🔴 **BLOCKED** — Phase H tasks cannot proceed until Phase A schema exists

| Finding | Impact |
|---------|--------|
| `identity_facets` table **DOES NOT EXIST** | Constellation (Phase H) blocked |
| `identity_topology` table **DOES NOT EXIST** | Tether/conflict viz blocked |
| Audio files are **0 bytes** (placeholders) | Airlock has no audio |
| **Skill Tree is production-ready** (549 lines) | Retain as fallback |

**Correct Execution Order:**
1. Phase A (Schema Foundation) — CREATE `identity_facets`, `identity_topology`
2. Phase G (Identity Coach Intelligence) — ADD fields to schema
3. Phase H (Constellation/Airlock) — NOW unblocked

**Red Team Critique:** `docs/analysis/RED_TEAM_CRITIQUE_RQ017_RQ018.md`

---

## Table of Contents

1. [What This Document Is](#what-this-document-is)
2. [Agent Entry Point Routing](#agent-entry-point-routing)
3. [Complete Documentation Hierarchy](#complete-documentation-hierarchy)
4. [Task Management Governance](#task-management-governance)
5. [Quick Status Dashboard](#quick-status-dashboard)
6. [Critical Paths](#critical-paths)
7. [Recently Added Tasks](#recently-added-tasks)
8. [Blocked Tasks (Awaiting Research)](#blocked-tasks-awaiting-research)
9. [Task Addition Log](#task-addition-log)
10. [Audit Trail](#audit-trail)

---

## What This Document Is

This document serves **three critical functions**:

| Function | Description | Who Uses It |
|----------|-------------|-------------|
| **Task Registry** | Canonical list of all implementation tasks across 6 phases (A-F) | Implementation agents |
| **Navigation Hub** | Cross-reference layer connecting all governance docs | All agents |
| **Audit Trail** | Historical record of task additions and workflow issues | Human oversight |

**Cardinal Rule:** Implementation tasks are defined in **ONE place only**:
- **Master Implementation Tracker** → `RESEARCH_QUESTIONS.md` (detailed tables)
- **This document** → Quick status + cross-references + audit trail

**Anti-Pattern:** Never store task definitions in IMPACT_ANALYSIS.md — that document is for CASCADE ANALYSIS only.

---

## Agent Entry Point Routing

> **AUTHORITATIVE SOURCE:** See `CLAUDE.md` for the official reading order (v2.0).
> This document is at **Level 2** in the reading hierarchy.

### For All Agents

Follow `CLAUDE.md` Reading Order v2.0:
- **Level 0:** CLAUDE.md + AI_HANDOVER.md (always)
- **Level 1:** Index files (most tasks)
- **Level 2:** This document + PRODUCT_DEVELOPMENT_SHEET.md (complex tasks)
- **Level 3:** Full documents (research/audit only)

**When to update this document:**
- After extracting tasks via Protocol 8
- After reconciling external research via Protocol 9
- When task status changes (NOT STARTED → IN PROGRESS → COMPLETE)

### For External Research Agents (DeepSeek, Gemini, ChatGPT)

```
PROMPT PREPARATION (by orchestrating agent):
1. Read DEEP_THINK_PROMPT_GUIDANCE.md ← Quality standards
   ↓
2. Read index/CD_INDEX.md ← Locked decisions to include
   ↓
3. Read index/RQ_INDEX.md ← Completed research to summarize
   ↓
4. Generate prompt from docs/prompts/ templates
   ↓
5. Send to external AI

RESPONSE PROCESSING (by receiving agent):
1. MANDATORY: Run Protocol 9 (External Research Reconciliation)
   ↓
2. Create reconciliation doc in docs/analysis/
   ↓
3. Run Protocol 8 (Task Extraction) on ACCEPT/MODIFY items
   ↓
4. Update Master Implementation Tracker (RESEARCH_QUESTIONS.md)
   ↓
5. Update THIS DOCUMENT (Quick Status section)
```

### For Human (Product Owner)

```
QUICK CHECK:
→ index/PD_INDEX.md: What decisions are pending MY input?
→ index/RQ_INDEX.md: What research is blocked/complete?
→ THIS DOCUMENT: What's the implementation status?

DEEP DIVE:
→ PRODUCT_DECISIONS.md: Full decision rationale
→ RESEARCH_QUESTIONS.md: Master Implementation Tracker (116 tasks)
→ IMPACT_ANALYSIS.md: Cascade effects of recent decisions
```

---

## Complete Documentation Hierarchy

### Visual Map

```
docs/
├── CORE/                              ← GOVERNANCE LAYER
│   │
│   ├── [ENTRY POINT] CLAUDE.md ───────────────────────────────┐
│   │   (For Claude Code - project overview)                   │
│   │                                                          │
│   ├── AI_HANDOVER.md ← Session continuity                    │
│   │   Updates: EVERY session                                 │
│   │                                                          │
│   ├── index/                    ← QUICK LOOKUP               │
│   │   ├── CD_INDEX.md (17 decisions)                         │
│   │   ├── PD_INDEX.md (31 decisions, 7 resolved)             │
│   │   └── RQ_INDEX.md (32 questions, 18 complete)            │
│   │                                                          │
│   ├── IMPLEMENTATION_ACTIONS.md ← YOU ARE HERE ◀─────────────┤
│   │   (Task quick status + cross-references)                 │
│   │                                                          │
│   ├── RESEARCH_QUESTIONS.md ← MASTER TASK TRACKER            │
│   │   (116 tasks across 8 phases A-H)                        │
│   │   Updates: Protocol 8, Protocol 9                        │
│   │                                                          │
│   ├── PRODUCT_DECISIONS.md ← Decision rationale              │
│   │   Updates: When decisions made/pending                   │
│   │                                                          │
│   ├── IMPACT_ANALYSIS.md ← Cascade tracking ONLY             │
│   │   (Does NOT store tasks - references them)               │
│   │                                                          │
│   ├── AI_AGENT_PROTOCOL.md ← 13 mandatory protocols          │
│   │   Protocols 1-9: Operational                             │
│   │   Protocols 10-12: Meta-cognitive (Bias, Sub-RQ, Defer)  │
│   │   Protocol 13: Gate Check (Prerequisites verification)   │
│   │                                                          │
│   ├── DEEP_THINK_PROMPT_GUIDANCE.md ← Prompt quality         │
│   │   (For external research agent prompts)                  │
│   │                                                          │
│   ├── GLOSSARY.md ← Terminology (50+ terms)                  │
│   │                                                          │
│   ├── IDENTITY_COACH_SPEC.md ← Feature specification         │
│   │                                                          │
│   └── archive/                  ← RESOLVED ITEMS             │
│       ├── CD_PD_ARCHIVE_Q1_2026.md                           │
│       └── RQ_ARCHIVE_Q1_2026.md                              │
│                                                              │
├── analysis/                     ← RECONCILIATION OUTPUTS     │
│   ├── DEEP_THINK_RECONCILIATION_RQ005_RQ006_RQ007.md         │
│   ├── DEEP_THINK_RECONCILIATION_RQ014_RQ013_PD117_RQ015.md   │
│   ├── IDENTITY_COACH_DEEP_ANALYSIS.md                        │
│   └── DOCUMENTATION_GOVERNANCE_ANALYSIS.md                   │
│                                                              │
└── prompts/                      ← EXTERNAL RESEARCH PROMPTS  │
    ├── DEEP_THINK_PROMPT_IDENTITY_COACH_RQ005-RQ006-RQ007.md  │
    ├── DEEP_THINK_PROMPT_IDENTITY_COACH_PHASE2_RQ028-RQ032.md │
    ├── DEEP_THINK_PROMPT_IDENTITY_SYSTEM_RQ013-RQ014-RQ015-PD117.md
    └── CLAUDE_SESSION_PRIMER.md                               │
                                                               │
PROJECT ROOT:                                                  │
├── CLAUDE.md ─────────────────────────────────────────────────┘
│   (Symlink/copy for Claude Code entry)
│
├── lib/                          ← FLUTTER APP CODE
│   └── [Dart implementation]
│
└── supabase/                     ← DATABASE LAYER
    └── migrations/
```

### Document Purpose Matrix

| Document | Purpose | Updates When | Who Updates |
|----------|---------|--------------|-------------|
| **CLAUDE.md** | Project entry point for Claude Code | Project structure changes | Human/Claude |
| **AI_HANDOVER.md** | Session continuity | Every session end | Current agent |
| **index/CD_INDEX.md** | Quick CD lookup | CD status changes | Any agent |
| **index/PD_INDEX.md** | Quick PD lookup | PD status changes | Any agent |
| **index/RQ_INDEX.md** | Quick RQ lookup | RQ status changes | Any agent |
| **IMPLEMENTATION_ACTIONS.md** | Task quick status + routing | Protocol 8/9 execution | Any agent |
| **RESEARCH_QUESTIONS.md** | Master Implementation Tracker | Task extraction | Any agent |
| **PRODUCT_DECISIONS.md** | Decision rationale | New decisions | Human/agent |
| **IMPACT_ANALYSIS.md** | Cascade effects | Research completes | Any agent |
| **AI_AGENT_PROTOCOL.md** | Behavioral rules | Rare (process changes) | Human |
| **DEEP_THINK_PROMPT_GUIDANCE.md** | Prompt quality | Rare (standards change) | Human/agent |
| **GLOSSARY.md** | Terminology | New terms introduced | Any agent |
| **docs/analysis/*.md** | Reconciliation outputs | Protocol 9 execution | Any agent |
| **docs/prompts/*.md** | External research prompts | New research queued | Any agent |

---

## Task Management Governance

### Governing Protocols

| Protocol | Location | When to Execute | Output |
|----------|----------|-----------------|--------|
| **Protocol 8** | AI_AGENT_PROTOCOL.md:504 | After RQ completes OR PD resolves | Tasks added to Master Tracker |
| **Protocol 9** | AI_AGENT_PROTOCOL.md:555 | After receiving external research | ACCEPT/MODIFY/REJECT/ESCALATE + Reconciliation doc |

### Task Extraction Decision Tree

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                     TASK EXTRACTION DECISION TREE                             │
│                                                                              │
│  INPUT: Research output OR Decision resolution                               │
│                                                                              │
│  1. Is this from EXTERNAL research (DeepSeek, Gemini, etc.)?                 │
│     ├── YES → Run Protocol 9 FIRST                                           │
│     │         ├── Create docs/analysis/DEEP_THINK_RECONCILIATION_*.md        │
│     │         ├── Categorize: ACCEPT / MODIFY / REJECT / ESCALATE            │
│     │         └── ONLY extract tasks from ACCEPT and MODIFY items            │
│     │                                                                        │
│     └── NO → Proceed directly to Step 2                                      │
│                                                                              │
│  2. For each actionable item:                                                │
│     ├── Search Master Tracker (RESEARCH_QUESTIONS.md) for duplicates        │
│     │   ├── EXACT MATCH → Skip (already tracked)                             │
│     │   ├── SIMILAR → MERGE (update existing task)                           │
│     │   └── NOVEL → CREATE new task                                          │
│                                                                              │
│  3. Assign Task ID:                                                          │
│     ├── Phase A (A-01, A-02...) → Schema/Database                            │
│     ├── Phase B (B-01, B-02...) → Intelligence/Backend                       │
│     ├── Phase C (C-01, C-02...) → Council AI                                 │
│     ├── Phase D (D-01, D-02...) → UX/Frontend                                │
│     ├── Phase E (E-01, E-02...) → Polish/Advanced                            │
│     └── Phase F (F-01, F-02...) → Identity Coach                             │
│                                                                              │
│  4. Required Fields:                                                         │
│     ├── ID: [Phase]-[Number]                                                 │
│     ├── Task: Clear action description                                       │
│     ├── Priority: CRITICAL / HIGH / MEDIUM / LOW                             │
│     ├── Status: 🔴 NOT STARTED / 🟡 IN PROGRESS / ✅ COMPLETE                │
│     ├── Source: RQ-XXX or PD-XXX                                             │
│     ├── Component: Database / Service / Screen / Content / etc.             │
│     └── AI Model: (optional) If task requires specific model                 │
│                                                                              │
│  5. Update Documents:                                                        │
│     ├── RESEARCH_QUESTIONS.md → Add to Master Implementation Tracker        │
│     ├── IMPLEMENTATION_ACTIONS.md → Update Quick Status + Recently Added    │
│     └── IMPACT_ANALYSIS.md → Add cascade effects (NOT task definitions)     │
│                                                                              │
│  OUTPUT: Task tracked in Master Tracker with full traceability               │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Canonical Locations (Memorize This)

| What | Where | NOT Here |
|------|-------|----------|
| **Task Definitions** | RESEARCH_QUESTIONS.md → Master Implementation Tracker | ~~IMPACT_ANALYSIS.md~~ |
| **Task Quick Status** | IMPLEMENTATION_ACTIONS.md (this document) | — |
| **Cascade Effects** | IMPACT_ANALYSIS.md | ~~RESEARCH_QUESTIONS.md~~ |
| **Decision Rationale** | PRODUCT_DECISIONS.md | ~~IMPACT_ANALYSIS.md~~ |
| **Reconciliation Output** | docs/analysis/DEEP_THINK_RECONCILIATION_*.md | ~~Inline in RQs~~ |
| **External Prompts** | docs/prompts/DEEP_THINK_PROMPT_*.md | ~~Ad-hoc generation~~ |

---

## Quick Status Dashboard

### Phase Summary (116 Total Tasks)

| Phase | Description | Total | CRITICAL | HIGH | MEDIUM | LOW | Progress |
|-------|-------------|-------|----------|------|--------|-----|----------|
| **A: Schema** | Database foundation | 12 | 6 | 4 | 2 | 0 | 0% |
| **B: Intelligence** | Backend services | 17 | 5 | 8 | 3 | 1 | 0% |
| **C: Council AI** | Council system | 13 | 5 | 7 | 1 | 0 | 0% |
| **D: UX** | Frontend screens | 14 | 2 | 7 | 4 | 1 | 0% |
| **E: Polish** | Advanced features | 10 | 0 | 2 | 5 | 3 | 0% |
| **F: Identity Coach** | Recommendation engine (Phase 1) | 20 | 5 | 12 | 3 | 0 | 0% |
| **G: Identity Coach** | Intelligence layer (Phase 2) | 14 | 3 | 7 | 2 | 2 | 0% |
| **H: Constellation/Airlock** | psyOS UX layer | 16 | 5 | 6 | 4 | 1 | 0% |
| **TOTAL** | | **116** | **31** | **52** | **25** | **8** | **0%** |

**Full Task List:** RESEARCH_QUESTIONS.md → "Master Implementation Tracker" (line ~3487)

### Status Distribution

```
┌─────────────────────────────────────────────────────────────┐
│ 🔴 NOT STARTED: 116 (100%)                                  │
│ 🟡 IN PROGRESS: 0 (0%)                                      │
│ ✅ COMPLETE:    0 (0%)                                      │
└─────────────────────────────────────────────────────────────┘
```

### Phase H: Constellation & Airlock (🔴 BLOCKED — 10 Jan 2026)

**Source:** RQ-017 ✅, RQ-018 ✅ (Deep Think psyOS UX Phase — COMPLETE)
**Decisions:** PD-108 ✅, PD-110 ✅, PD-112 ✅ (All RESOLVED)

**⚠️ BLOCKED:** Requires Phase A schema (`identity_facets`, `identity_topology` tables)

| Task | Description | Priority | Status |
|------|-------------|----------|--------|
| H-01 | `ConstellationPainter` (CustomPainter) | CRITICAL | 🔴 BLOCKED |
| H-02 | Orbit distance formula (ICS-based) | CRITICAL | 🔴 BLOCKED |
| H-07 | Settled state (0 FPS idle) | CRITICAL | 🔴 BLOCKED |
| H-10 | `TransitionDetector` service | CRITICAL | 🔴 BLOCKED |
| H-11 | `AirlockOverlay` widget (5-Second Seal) | CRITICAL | 🔴 BLOCKED |
| H-13 | Stock audio files (>0 bytes) | HIGH | 🔴 NOT STARTED |

**Unblocking Path:** Complete A-01, A-02 → G-01, G-02 → H-* tasks become actionable

---

### Phase G: Identity Coach Intelligence (10 Jan 2026)

**Source:** RQ-028, RQ-029, RQ-030, RQ-031, RQ-032 (Deep Think Phase 2)
**Decisions:** PD-121 (12 Archetypes), PD-122 (Hidden embedding), PD-123 (Energy state), PD-124 (7-day TTL)

| # | Task | Priority | Status |
|---|------|----------|--------|
| G-01 | Add `ics_score` field to identity_facets | HIGH | 🔴 |
| G-02 | Add `typical_energy_state` field to identity_facets | HIGH | 🔴 |
| G-03 | Add `trinity_seed` field to preference_embeddings | HIGH | 🔴 |
| G-04 | Implement `RocchioUpdater` service | **CRITICAL** | 🔴 |
| G-05 | Implement `ICSCalculator` service | HIGH | 🔴 |
| G-06 | Implement `ArchetypeMatcher` service | **CRITICAL** | 🔴 |
| G-07 | Update `PaceCar` to Building vs Maintenance model | HIGH | 🔴 |
| G-08 | Populate archetype_templates (12 definitions) | **CRITICAL** | 🔴 |
| G-09 | Run DeepSeek dimension curation on 50 habits | HIGH | 🔴 |
| G-10 | Audit and validate dimension vectors | HIGH | 🔴 |
| G-11 | Add 7-day TTL logic to recommendation cards | MEDIUM | 🔴 |
| G-12 | Implement ICS visual tier mapping (Seed/Sapling/Oak) | MEDIUM | 🔴 |
| G-13 | Deprecate hexis_score in GLOSSARY.md | LOW | 🔴 |
| G-14 | Create archetype override UI in Settings | LOW | 🔴 |

---

## Critical Paths

### Path 1: Council AI Foundation (Primary)

```
A-01 (pgvector extension)
  ↓
A-02 (psychometric_roots table) ─┬─→ A-03 (psychological_manifestations)
                                 └─→ A-05 (treaties table)
  ↓
B-01 (embed-manifestation Edge Function)
  ↓
B-06 (Triangulation Protocol) ─→ B-07 (Sherlock Day 7 synthesis)
  ↓
C-01 (Treaty Dart model) ─→ C-03 (TreatyEngine)
  ↓
C-04 (generate_council_session Edge Function) ─→ C-05 (Council Engine prompt)
  ↓
D-01 (Constitution dashboard) ─→ D-02 (The Chamber overlay)
```

### Path 2: Identity Coach (Parallel Track)

```
F-02 (identity_roadmaps table) ─→ F-03 (roadmap_nodes table)
  ↓
F-06 (archetype_templates table) ← BLOCKED BY RQ-028 (Archetype Definitions)
  ↓
F-07 (generateRecommendations Edge Function)
  ↓
F-08 (Stage 1: Semantic retrieval) ─→ F-09 (Stage 2: Psychometric re-ranking)
  ↓
F-13 (50 universal habit templates) ← BLOCKED BY RQ-028, RQ-029
  ↓
F-10 (Architect scheduler)
```

### Blocking Research (Must Complete Before Implementation)

| Research | Blocks | Priority | Status |
|----------|--------|----------|--------|
| **RQ-039** (Token Economy) | E-12, E-14, PD-119 | **CRITICAL** | 🔴 NEW — 7 sub-RQs |
| RQ-034 (Sherlock Architecture) | PD-101 (partial) | HIGH | 🔴 NEEDS RESEARCH |
| RQ-035 (Sensitivity Detection) | PD-103 | HIGH | 🔴 NEEDS RESEARCH |
| RQ-036 (Chamber Visual Design) | PD-120 | MEDIUM | 🔴 NEEDS RESEARCH |
| RQ-010 (Permission Data) | JITAI refinement | MEDIUM | 🔴 NEEDS RESEARCH |

**Recently Completed (11 Jan 2026):**
- ✅ RQ-017 (Constellation UX) — Phase H tasks now defined
- ✅ RQ-018 (Airlock Protocol) — Phase H tasks now defined
- ✅ RQ-028-032 (Identity Coach Phase 2) — Phase G tasks defined
- ✅ RQ-037/033/025 (Gamification) — Concepts defined, Decision 2 DEFERRED

---

## Recently Added Tasks

### 11 January 2026 — RQ-039: Token Economy Architecture (Research)

**Source:** Protocol 9 reconciliation exposed bias in original recommendation; decision DEFERRED
**Status:** 🔴 NEEDS RESEARCH — 7 sub-RQs created

| Sub-RQ | Question | Priority | Blocking |
|--------|----------|----------|----------|
| **RQ-039a** | Earning mechanism & intrinsic motivation | CRITICAL | E-12 |
| **RQ-039b** | Optimal reflection cadence | HIGH | E-12 |
| **RQ-039c** | Single vs multiple earning paths | HIGH | E-12 |
| **RQ-039d** | Token cap vs decay alternatives | HIGH | E-12 |
| **RQ-039e** | Crisis bypass threshold validation | HIGH | E-14 |
| **RQ-039f** | Premium token allocation | MEDIUM | Subscription |
| **RQ-039g** | Reflection quality thresholds | MEDIUM | E-12 |

**Impact:** Decision 2 (Token Earning Mechanism) from escalated items DEFERRED pending research.
**PD-119 Status:** Changed to DEFER (was PENDING)
**Analysis:** `docs/analysis/RQ039_TOKEN_ECONOMY_DEEP_ANALYSIS.md`

---

### 10 January 2026 — RQ-008/009: Engineering Process (8 Tasks)

**Source:** RQ-008 (UI Logic Separation), RQ-009 (LLM Coding Approach) reconciliation via Protocol 9
**Decisions:** Protocol 2 REPLACED with Context-Adaptive Development
**Reconciliation Doc:** `docs/analysis/DEEP_THINK_RECONCILIATION_RQ008_RQ009.md`

| Task ID | Description | Priority | Status | Source |
|---------|-------------|----------|--------|--------|
| P-01 | Update AI_AGENT_PROTOCOL.md with Protocol 2 (Context-Adaptive) | **CRITICAL** | ✅ DONE | RQ-008,009 |
| P-02 | Create Boundary Decision Tree documentation | HIGH | ✅ DONE | RQ-008 |
| P-03 | Add linting rules to analysis_options.yaml | HIGH | 🔴 | RQ-008 |
| P-04 | Create ChangeNotifier Controller template | HIGH | 🔴 | RQ-008 |
| P-05 | Document Side Effect pattern with code example | HIGH | ✅ DONE | RQ-008 |
| P-06 | Add Riverpod to pubspec.yaml for new features | MEDIUM | 🔴 | RQ-008 |
| P-07 | Create "Logic vs Visual" task classification guide | HIGH | ✅ DONE | RQ-009 |
| P-08 | Define "Logic Leakage" metric tracking | MEDIUM | 🔴 | RQ-008 |

**Key Insight:** "Constraint Enables Creativity" — Strict UI/Logic separation creates a Safety Sandbox where AI can iterate freely on UI.

---

### 10 January 2026 — RQ-024: Treaty Modification (9 Tasks)

**Source:** RQ-024 (Treaty Modification & Renegotiation) reconciliation via Protocol 9
**Decisions:** PD-118 RESOLVED (Constitutional Amendment Model)
**Reconciliation Doc:** `docs/analysis/DEEP_THINK_RECONCILIATION_RQ024.md`

| Task ID | Description | Priority | Status | Source |
|---------|-------------|----------|--------|--------|
| A-11 | Create `treaty_history` table (audit log) | HIGH | 🔴 | RQ-024 |
| A-12 | Add `version`, `parent_treaty_id`, `last_amended_at` to treaties | HIGH | 🔴 | RQ-024 |
| D-11 | Implement Treaty Amendment Editor (minor amendments) | HIGH | 🔴 | RQ-024 |
| D-12 | Implement Re-Ratification ceremony (3s hold + haptic) | HIGH | 🔴 | RQ-024 |
| D-13 | Implement Pause Treaty flow (modal + date picker) | MEDIUM | 🔴 | RQ-024 |
| D-14 | Implement Repeal Treaty flow (type-to-confirm) | MEDIUM | 🔴 | RQ-024 |
| C-13 | Wire Council reconvene for major amendments (pass treaty context) | HIGH | 🔴 | RQ-024 |
| B-16 | Implement Probation notification journey (T+0 to T+96h) | HIGH | 🔴 | RQ-024 |
| B-17 | Implement Auto-suspend logic (5+ breaches OR 3 dismissed) | HIGH | 🔴 | RQ-024 |

---

### 10 January 2026 — Phase G: Identity Coach Intelligence (14 Tasks)

**Source:** RQ-028, RQ-029, RQ-030, RQ-031, RQ-032 reconciliation via Protocol 9
**Decisions:** PD-121, PD-122, PD-123, PD-124 RESOLVED
**Reconciliation Doc:** `docs/analysis/DEEP_THINK_RECONCILIATION_RQ028_RQ029_RQ030_RQ031_RQ032.md`

| Task ID | Description | Priority | Status | Source |
|---------|-------------|----------|--------|--------|
| G-01 | Add `ics_score` field to identity_facets | HIGH | 🔴 | RQ-032 |
| G-02 | Add `typical_energy_state` field to identity_facets | HIGH | 🔴 | RQ-031, PD-123 |
| G-03 | Add `trinity_seed` field to preference_embeddings | HIGH | 🔴 | RQ-030 |
| G-04 | `RocchioUpdater` service | **CRITICAL** | 🔴 | RQ-030 |
| G-05 | `ICSCalculator` service | HIGH | 🔴 | RQ-032 |
| G-06 | `ArchetypeMatcher` service | **CRITICAL** | 🔴 | RQ-028 |
| G-07 | Update `PaceCar` Building vs Maintenance model | HIGH | 🔴 | RQ-031 |
| G-08 | Populate archetype_templates (12 definitions) | **CRITICAL** | 🔴 | RQ-028, PD-121 |
| G-09 | DeepSeek dimension curation on 50 habits | HIGH | 🔴 | RQ-029 |
| G-10 | Audit and validate dimension vectors | HIGH | 🔴 | RQ-029 |
| G-11 | 7-day TTL logic for recommendation cards | MEDIUM | 🔴 | RQ-031, PD-124 |
| G-12 | ICS visual tier mapping (Seed/Sapling/Oak) | MEDIUM | 🔴 | RQ-032 |
| G-13 | Deprecate hexis_score in GLOSSARY | LOW | 🔴 | RQ-032 |
| G-14 | Archetype override UI in Settings | LOW | 🔴 | RQ-028 |

---

### 10 January 2026 — Phase F: Identity Coach (20 Tasks)

**Source:** RQ-005, RQ-006, RQ-007 reconciliation via Protocol 9
**Decision:** PD-125 RESOLVED (50 habits at launch with caveat)
**Reconciliation Doc:** `docs/analysis/DEEP_THINK_RECONCILIATION_RQ005_RQ006_RQ007.md`

| Task ID | Description | Priority | Status | Source |
|---------|-------------|----------|--------|--------|
| F-01 | `preference_embeddings` table (768-dim vector) | HIGH | 🔴 | RQ-005 |
| F-02 | `identity_roadmaps` table | **CRITICAL** | 🔴 | RQ-007 |
| F-03 | `roadmap_nodes` table | **CRITICAL** | 🔴 | RQ-007 |
| F-04 | `ideal_dimension_vector` field on habit_templates | HIGH | 🔴 | RQ-005 |
| F-05 | `archetype_template_id` FK on identity_facets | HIGH | 🔴 | RQ-006 |
| F-06 | `archetype_templates` reference table (12 presets) | HIGH | 🔴 | RQ-006 |
| F-07 | `generateRecommendations()` Edge Function | **CRITICAL** | 🔴 | RQ-005 |
| F-08 | Stage 1: Semantic retrieval (pgvector) | **CRITICAL** | 🔴 | RQ-005 |
| F-09 | Stage 2: Psychometric re-ranking (6-dim) | **CRITICAL** | 🔴 | RQ-005 |
| F-10 | Architect scheduler (nightly/weekly) | HIGH | 🔴 | RQ-005 |
| F-11 | Feedback signal tracking (adopt/dismiss/snooze) | HIGH | 🔴 | RQ-005 |
| F-12 | Sherlock Day 3: Future Self Interview | HIGH | 🔴 | RQ-007 |
| F-13 | 50 universal habit templates (dual embeddings) | **CRITICAL** | 🔴 | RQ-006, PD-125 |
| F-14 | 12 Archetype Template presets | HIGH | 🔴 | RQ-006 |
| F-15 | 12 Framing Templates (dimension × poles) | HIGH | 🔴 | RQ-006 |
| F-16 | 4 Ritual Templates | MEDIUM | 🔴 | RQ-006 |
| F-17 | `ProactiveRecommendation` Dart model | HIGH | 🔴 | RQ-005 |
| F-18 | `IdentityRoadmapService` (CRUD + ICS) | HIGH | 🔴 | RQ-007 |
| F-19 | Pace Car rate limiting | HIGH | 🔴 | RQ-005 |
| F-20 | Regression messaging templates | MEDIUM | 🔴 | RQ-006 |

### 06 January 2026 — Phases A-E: Identity System (57 Tasks)

**Source:** RQ-012, RQ-013, RQ-014, RQ-015, RQ-016 reconciliation
**Reconciliation Doc:** `docs/analysis/DEEP_THINK_RECONCILIATION_RQ014_RQ013_PD117_RQ015.md`

**Full Task List:** See RESEARCH_QUESTIONS.md → Master Implementation Tracker → Phases A through E

---

## Blocked Tasks (Awaiting Research)

### Research Dependency Matrix

| Task Range | Blocking Research | Research Status | Deep Think Prompt |
|------------|-------------------|-----------------|-------------------|
| F-06, F-13, F-14 | **RQ-028** (Archetype Definitions) | 🔴 NEEDS RESEARCH | `DEEP_THINK_PROMPT_IDENTITY_COACH_PHASE2_RQ028-RQ032.md` |
| F-13 | **RQ-029** (Dimension Curation) | 🔴 NEEDS RESEARCH | Same as above |
| F-11 | **RQ-030** (Preference Embedding) | 🔴 NEEDS RESEARCH | Same as above |
| F-19 | **RQ-031** (Pace Car Validation) | 🔴 NEEDS RESEARCH | Same as above |
| F-18 | **RQ-032** (ICS Integration) | 🔴 NEEDS RESEARCH | Same as above |
| E-05, E-06 | RQ-024 (Treaty Modification) | ✅ COMPLETE | `DEEP_THINK_RECONCILIATION_RQ024.md` |
| E-01, E-02 | RQ-025 (Summon Token Economy) | 🔴 NEEDS RESEARCH | Not yet created |
| E-03, E-04 | RQ-026 (Sound Design) | 🔴 NEEDS RESEARCH | Not yet created |
| E-07 | RQ-027 (Template Versioning) | 🔴 NEEDS RESEARCH | Not yet created |
| Phase H (ALL) | **Phase A Schema** | 🔴 NOT STARTED | `identity_facets`, `identity_topology` tables |
| H-13 | **Audio Assets** | 🔴 NOT STARTED | 0-byte placeholder files need replacement |
| *Future Privacy* | RQ-023 (Population Privacy) | 🔴 NEEDS RESEARCH | Not yet created |

### Next Implementation to Queue

**CRITICAL PATH:** Phase A Schema → Phase G Fields → Phase H Widgets

1. **A-01, A-02** (CRITICAL) — Create `identity_facets` and `identity_topology` tables
   - **WHY FIRST:** All Phase G and Phase H tasks depend on these tables
   - **Unblocks:** G-01, G-02, G-05, H-01 through H-16

2. **H-13** (HIGH) — Source actual audio files
   - Current files are 0 bytes (placeholders)
   - Needed for Airlock (RQ-018)

**Research Complete (Ready for Implementation):**
- RQ-017 ✅ (Constellation UX) — Reconciled in `DEEP_THINK_RECONCILIATION_RQ017_RQ018.md`
- RQ-018 ✅ (Airlock Protocol) — Reconciled in `DEEP_THINK_RECONCILIATION_RQ017_RQ018.md`
- RQ-028-032 ✅ (Identity Coach Phase 2) — Reconciled

**Research Still Needed:**
- RQ-023 (Population Privacy) — Blocks future privacy features
- RQ-025 (Summon Token Economy) — Blocks E-01, E-02
- RQ-026 (Sound Design) — Blocks E-03, E-04

**Recently Completed Research:**
- RQ-024 ✅ (Treaty Modification) — Reconciled 10 Jan 2026, 9 tasks extracted

---

## Task Addition Log

| Date | Source | Phase | Tasks Added | Added By | Reconciliation Doc |
|------|--------|-------|-------------|----------|-------------------|
| 10 Jan 2026 | RQ-024 | A,B,C,D | A-11,A-12,B-16,B-17,C-13,D-11-D-14 (9 tasks) | Claude (Opus 4.5) | `DEEP_THINK_RECONCILIATION_RQ024.md` |
| 10 Jan 2026 | RQ-028/029/030/031/032 | G | G-01 through G-14 (14 tasks) | Claude (Opus 4.5) | `DEEP_THINK_RECONCILIATION_RQ028_RQ029_RQ030_RQ031_RQ032.md` |
| 10 Jan 2026 | RQ-005/006/007 | F | F-01 through F-20 (20 tasks) | Claude (Opus 4.5) | `DEEP_THINK_RECONCILIATION_RQ005_RQ006_RQ007.md` |
| 06 Jan 2026 | RQ-012/013/014/015/016 | A-E | A-01 through E-10 (57 tasks) | Claude (Opus 4.5) | `DEEP_THINK_RECONCILIATION_RQ014_RQ013_PD117_RQ015.md` |

---

## Audit Trail

### Issue Identified: 10 January 2026 — Task Loss

**Problem:** F-01 through F-20 tasks from RQ-005/006/007 were added to IMPACT_ANALYSIS.md but NOT to the Master Implementation Tracker in RESEARCH_QUESTIONS.md.

**Root Cause:** Ambiguity between:
- "Implementation Tasks Extracted" section in IMPACT_ANALYSIS.md
- "Master Implementation Tracker" in RESEARCH_QUESTIONS.md

**Resolution Applied:**
1. Added Phase F (20 tasks) to Master Implementation Tracker
2. Created this document (IMPLEMENTATION_ACTIONS.md) as navigation hub
3. Updated Protocol 8 in AI_AGENT_PROTOCOL.md with explicit canonical locations
4. Added Phase F to task ID convention (A-F, not just A-E)

**Prevention Measures:**
- Protocol 8 now explicitly states: "Tasks MUST be added to RESEARCH_QUESTIONS.md Master Tracker"
- This document serves as cross-reference layer between reconciliation and Master Tracker
- IMPACT_ANALYSIS.md header now states "CASCADE ANALYSIS ONLY — does NOT store tasks"

---

## External Agent Instructions

### For DeepSeek / Gemini / ChatGPT (When Processing Prompts)

If you are an external AI agent receiving a Deep Think prompt from The Pact project:

1. **Respect Locked Decisions:** The prompt includes CDs (Confirmed Decisions). Do NOT propose changes that conflict with them.

2. **Android-First Reality:** CD-017 mandates Android-first development. Do NOT propose features requiring:
   - Apple HealthKit
   - Wearable-only sensors
   - iOS-specific APIs

3. **4-State Energy Model:** CD-015 locks the energy model at 4 states (high_focus, high_physical, social, recovery). Do NOT propose 5-state models.

4. **Output Format:** Follow the structure specified in the prompt. Include:
   - Confidence levels (HIGH/MEDIUM/LOW) for each recommendation
   - CD-018 classification (ESSENTIAL/VALUABLE/NICE-TO-HAVE/OVER-ENGINEERED)
   - Tradeoffs for each option before recommending

5. **Your output will be reconciled** via Protocol 9 by a receiving agent. Proposals that conflict with locked decisions will be REJECTED.

---

## Cross-Reference Quick Links

| Need | Go To |
|------|-------|
| What did the last agent do? | `AI_HANDOVER.md` |
| What decisions are locked? | `index/CD_INDEX.md` |
| What decisions are pending? | `index/PD_INDEX.md` |
| What research is complete? | `index/RQ_INDEX.md` |
| Full task details? | `RESEARCH_QUESTIONS.md` → Master Implementation Tracker |
| Cascade effects? | `IMPACT_ANALYSIS.md` |
| Term definitions? | `GLOSSARY.md` |
| Agent behavioral rules? | `AI_AGENT_PROTOCOL.md` |
| Prompt quality standards? | `DEEP_THINK_PROMPT_GUIDANCE.md` |
| Identity Coach spec? | `IDENTITY_COACH_SPEC.md` |
| Reconciliation outputs? | `docs/analysis/DEEP_THINK_RECONCILIATION_*.md` |
| External research prompts? | `docs/prompts/DEEP_THINK_PROMPT_*.md` |

---

*This document is maintained during Protocol 8 (Task Extraction) and Protocol 9 (External Research Reconciliation). Last updated: 10 January 2026.*
