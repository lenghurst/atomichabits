# Confirmed Decisions & Resolved Product Decisions Archive — Q1 2026

> **Created:** 06 January 2026
> **Purpose:** Archived CONFIRMED CDs and RESOLVED PDs with full rationale
> **Quick Reference:** See `../index/CD_INDEX.md` and `../index/PD_INDEX.md`

---

## Archive Contents

### Confirmed Decisions (CDs)

| CD# | Title | Date | Impact |
|-----|-------|------|--------|
| CD-001 | App Name = "The Pact" | Jan 2026 | LOW |
| CD-002 | AI as Default Witness | Jan 2026 | MEDIUM |
| CD-003 | Sherlock Before Payment | Jan 2026 | HIGH |
| CD-004 | No Conversational CLI | Jan 2026 | NONE |
| CD-005 | 6-Dimension Archetype Model | Jan 2026 | **CRITICAL** |
| CD-006 | GPS Permission Usage | Jan 2026 | MEDIUM |
| CD-007 | 6+1 Dimension Model | Jan 2026 | MEDIUM |
| CD-008 | Identity Development Coach | Jan 2026 | **CRITICAL** |
| CD-009 | Content Library | Jan 2026 | HIGH |
| CD-010 | Retention Tracking Philosophy | Jan 2026 | MEDIUM |
| CD-011 | Identity Coach Architecture | Jan 2026 | HIGH |
| CD-012 | Git Workflow Protocol | Jan 2026 | LOW |
| CD-013 | UI Logic Separation | Jan 2026 | MEDIUM |
| CD-014 | Core File Guardrails | Jan 2026 | **CRITICAL** |
| CD-015 | psyOS Architecture | 05 Jan 2026 | **CRITICAL** |
| CD-016 | AI Model Strategy (DeepSeek V3.2) | 05 Jan 2026 | **CRITICAL** |

### Resolved Product Decisions (PDs)

| PD# | Title | Resolved Via | Date |
|-----|-------|--------------|------|
| PD-001 | Archetype Philosophy | CD-005 | Jan 2026 |
| PD-106 | Multiple Identity Architecture | CD-015 | 05 Jan 2026 |
| PD-109 | Council AI Activation Rules | RQ-016 | 05 Jan 2026 |
| PD-113 | Treaty Priority Hierarchy | RQ-020 | 05 Jan 2026 |
| PD-114 | Full Implementation Commitment | — | 05 Jan 2026 |
| PD-115 | Treaty Creation UX | RQ-021 | 05 Jan 2026 |

---

## CRITICAL Confirmed Decisions

### CD-005: 6-Dimension Archetype Model

**Decision:** Use 6-dimension continuous model with 4 UI clusters

**The 6 Dimensions:**
1. **Regulatory Focus** — Promotion ↔ Prevention
2. **Autonomy/Reactance** — Rebel ↔ Conformist
3. **Action-State Orientation** — Executor ↔ Overthinker
4. **Temporal Discounting** — Future ↔ Present
5. **Perfectionistic Reactivity** — Adaptive ↔ Maladaptive
6. **Social Rhythmicity** — Stable ↔ Chaotic

**Implementation:** Backend = 6-float vector; UI = 4 clusters

---

### CD-015: psyOS (Psychological Operating System) Architecture

**Decision:** The Pact will be built as a psyOS — not a habit tracker

**Core Philosophy:**
| Old Frame | New Frame (psyOS) |
|-----------|-------------------|
| Habit Tracker | Psychological Operating System |
| Monolithic Self | Parliament of Selves |
| Discipline | Governance (Coalition) |
| Conflict = Bug | Conflict = Core Value |

**7 Core Architectural Elements:**
1. **Parliament of Selves** — User as dynamic system of parts
2. **Fractal Trinity** — Root psychology + contextual manifestations
3. **Identity Topology** — Graph model of facet relationships
4. **State Economics** — Bio-energetic conflict detection
5. **Polymorphic Habits** — Same action, different meaning per facet
6. **Council AI** — Parliament mediator for conflicts
7. **Constellation UX** — Solar system dashboard

**Generated RQs:** RQ-012 through RQ-018

---

### CD-016: AI Model Strategy (Multi-Model)

**Decision:** Use multi-model architecture

| Task | Model |
|------|-------|
| Real-time Voice | Gemini 3 Flash |
| Embedding Generation | gemini-embedding-001 |
| Council AI Scripts | DeepSeek V3.2 |
| Root Synthesis | DeepSeek V3.2 |
| JITAI Logic | Hardcoded |

---

## Resolved Product Decisions

### PD-001: Archetype Philosophy ✅

**Question:** Should archetypes be hardcoded buckets or dynamically AI-generated?

**Resolution:** → CD-005 — 6-dimension continuous model with 4 UI clusters

---

### PD-106: Multiple Identity Architecture ✅

**Question:** How should the app handle users with multiple aspirational identities?

**Resolution:** → CD-015 — Identity Facets model via psyOS

---

### PD-109: Council AI Activation Rules ✅

**Question:** When should Council AI sessions be triggered?

**Resolution (from RQ-016):**
- **User Initiated:** Explicit "Ask the Council" action
- **JITAI Triggered:** Tension score > 0.7 between facets
- **Treaty Breach:** When active treaty is violated
- **Renegotiation:** When treaty approaches expiry

---

### PD-113: Treaty Priority Hierarchy ✅

**Question:** How should treaties interact with JITAI?

**Resolution (from RQ-020):**
```
Stage 1: Safety Check (time-of-day, DND)
Stage 2: Annoyance Filter (recent nudges)
Stage 3: TREATY CHECK ← Treaties apply here
Stage 4: Thompson Sampling
Stage 5: Content Generation
```

Treaties override default JITAI when conditions match.

---

### PD-114: Full Implementation Commitment ✅

**Question:** Should psyOS be phased or full at launch?

**Resolution:** Full Implementation — All psyOS features at launch
> "psyOS architecture is what I want to pursue for launch. Not the MVP Version."

---

### PD-115: Treaty Creation UX ✅

**Question:** How should users create treaties between facets?

**Resolution (from RQ-021):**
1. **Council AI Proposed** — After conflict resolution
2. **Template Selection** — Pre-built treaty templates
3. **System Suggested** — Based on detected friction

**Treaty Lifecycle:**
```
PROPOSED → ACTIVE → STRAINED → BROKEN → RENEGOTIATING → ACTIVE
                 ↓
              RETIRED
```

---

## Supporting Confirmed Decisions

### CD-001: App Name & Branding
- **Decision:** App is "The Pact", not "AtomicHabits"
- **Action:** Deprecate `atomichabits://` URL scheme

### CD-002: AI as Default Witness
- **Decision:** AI is ALWAYS the witness; human witness is ADDITIVE
- **Action:** Remove "Go Solo" terminology

### CD-003: Sherlock Before Payment
- **Decision:** Keep Sherlock voice session BEFORE payment gate
- **Risk:** Higher CAC (AI cost before commitment)

### CD-004: No Conversational CLI
- **Decision:** Do NOT implement command-line interface
- **Rationale:** Incongruent with consumer wellness app

### CD-008: Identity Development Coach
- **Decision:** Coach becomes Parliament Mediator in psyOS
- **Priority:** Elevated to CRITICAL

### CD-012: Git Workflow Protocol
- **Decision:** Standardized git workflow
- **Impact:** Process/LOW

### CD-013: UI Logic Separation
- **Decision:** Strict separation for AI-assisted development
- **Impact:** Code quality/MEDIUM

### CD-014: Core File Creation Guardrails
- **Decision:** Strict rules for creating new Core files
- **Impact:** Agent context/CRITICAL

---

*This archive contains complete decision rationale. For pending decisions, see PRODUCT_DECISIONS.md.*
