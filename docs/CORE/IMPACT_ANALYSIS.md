# IMPACT_ANALYSIS.md — Research-to-Roadmap Traceability

> **Last Updated:** 10 January 2026
> **Purpose:** Track how research findings impact roadmap elements
> **Trigger:** Updated automatically when research concludes or decisions are made

---

## CRITICAL: Document Scope

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  ⚠️  CASCADE ANALYSIS ONLY — This document does NOT store tasks              │
│                                                                              │
│  DO:                                     │  DON'T:                           │
│  ✅ Log cascade effects                  │  ❌ Store task definitions         │
│  ✅ Reference tasks by ID (F-01, B-03)   │  ❌ Create task tables             │
│  ✅ Track dependency chains              │  ❌ Track task status              │
│  ✅ Analyze upstream/downstream impact   │  ❌ Duplicate Master Tracker       │
└──────────────────────────────────────────────────────────────────────────────┘
```

**Task Storage Locations:**
| What | Where | NOT Here |
|------|-------|----------|
| Task Definitions | RESEARCH_QUESTIONS.md → Master Implementation Tracker | ❌ |
| Task Quick Status | IMPLEMENTATION_ACTIONS.md | ❌ |
| Cascade Effects | **THIS DOCUMENT** ✅ | — |

**Workflow:**
```
Research completes
  ↓
Impact analyzed HERE (cascade effects)
  ↓
Tasks extracted to RESEARCH_QUESTIONS.md → Master Tracker
  ↓
Quick status updated in IMPLEMENTATION_ACTIONS.md
```

---

## What This Document Is

This document ensures research findings **cascade through the entire system**. When research concludes:
1. Every roadmap item is evaluated for impact
2. New questions/research points are logged
3. Dependencies are updated
4. This document is updated

---

## Related Documentation

| Document | Relationship |
|----------|--------------|
| **[RESEARCH_QUESTIONS.md](./RESEARCH_QUESTIONS.md)** | Source of research findings that trigger impact analysis |
| **[PRODUCT_DECISIONS.md](./PRODUCT_DECISIONS.md)** | Decisions that cascade through this impact analysis |
| **[AI_AGENT_PROTOCOL.md](./AI_AGENT_PROTOCOL.md)** | Protocol 9 references this for reconciliation workflow |
| **[GLOSSARY.md](./GLOSSARY.md)** | Terminology definitions used in this document |
| **[index/RQ_INDEX.md](./index/RQ_INDEX.md)** | Quick lookup of research question status |
| **[index/CD_INDEX.md](./index/CD_INDEX.md)** | Quick lookup of confirmed decision status |

**Workflow:** Research completes in RESEARCH_QUESTIONS.md → Impact analyzed here → Tasks extracted → Implementation begins

---

## Current Research: 6-Dimension Archetype Model (RQ-001)

### Research Summary
- **Source:** ChatGPT + Gemini Deep Research + Gemini Deep Think synthesis
- **Outcome:** 6-dimension continuous model with 4 UI clusters
- **Status:** COMPLETE — Awaiting implementation decisions

### The 6 Dimensions
1. Regulatory Focus (Promotion ↔ Prevention)
2. Autonomy/Reactance (Rebel ↔ Conformist)
3. Action-State Orientation (Executor ↔ Overthinker)
4. Temporal Discounting (Future ↔ Present)
5. Perfectionistic Reactivity (Adaptive ↔ Maladaptive)
6. Social Rhythmicity (Stable ↔ Chaotic)
7. **PROPOSED:** Social Sensitivity (if social features exist)

---

## Impact Analysis: Roadmap Elements

### Layer 1: The Evidence Engine (Foundation)

| Task | Impact | Action Required |
|------|--------|-----------------|
| E6: Evidence API | **HIGH** | API must log dimension-relevant signals (decision_time_ms, schedule_entropy, push-pull ratio) |
| Schema | **MEDIUM** | Add `user_dimensions` table with 6-float vector |

**New Questions:**
- Should dimensions be stored in `identity_seeds` or separate table?
- How often should dimensions be recalculated?

---

### Layer 2: The Shadow & Values Profiler (Onboarding)

| Task | Impact | Action Required |
|------|--------|-----------------|
| Sherlock Profiler | **CRITICAL** | Must extract dimension-relevant traits, not just Holy Trinity |
| Voice Wand | **MEDIUM** | 3-min recording must capture enough signal for 4 dimensions |

**New Questions:**
- Does Sherlock need to ask dimension-specific questions?
- Should we add 3 binary onboarding questions BEFORE Sherlock for cold-start?
- How do we map Holy Trinity → 6 Dimensions?

**Mapping Hypothesis:**
| Holy Trinity | Maps To |
|--------------|---------|
| Anti-Identity | Regulatory Focus (Prevention) + Perfectionistic Reactivity |
| Failure Archetype | Action-State Orientation + Temporal Discounting |
| Resistance Lie | Autonomy/Reactance + Action-State Orientation |

---

### Layer 3: The Living Garden Visualization (UI)

| Task | Impact | Action Required |
|------|--------|-----------------|
| Rive Integration | **MEDIUM** | Garden state should reflect dimensional profile |
| Dynamic Inputs | **HIGH** | Add dimension vector as Rive input |
| Atmospherics | **LOW** | Weather effects can remain emotion-based |

**New Questions:**
- Should garden show "Rebel" vs "Conformist" visually?
- Can we represent 6D space in 2D garden metaphor?

---

### Layer 4: The Conversational Command Line (Interaction)

| Task | Impact | Action Required |
|------|--------|-----------------|
| Voice Interaction | **HIGH** | AI persona should adapt to Autonomy/Reactance dimension |
| Command parsing | **LOW** | No change needed |

**New Questions:**
- Should "Rebel" users get a different AI persona entirely?
- How do we handle dimension-aware message variants?

---

### Layer 5: Philosophical Intelligence (The Brain)

| Task | Impact | Action Required |
|------|--------|-----------------|
| Gap Analysis Engine | **CRITICAL** | Must incorporate dimensions into gap detection |
| Socratic Generator | **HIGH** | Questions should be framed per Regulatory Focus |

**New Questions:**
- Promotion user: "What could you achieve if..."
- Prevention user: "What might you lose if..."
- Should Gap Analysis weight different behavioral signals per dimension?

---

### Track A-F: Weekly Build Plan

| Track | Impact | Action Required |
|-------|--------|-----------------|
| Track A: Database | **HIGH** | Add dimension storage to Evidence Repository |
| Track B: Voice | **CRITICAL** | Shadow Persona Prompting must be dimension-aware |
| Track C: Dashboard | **MEDIUM** | Bridge should show dimension-relevant habits first |
| Track D: Gap Analysis | **CRITICAL** | DeepSeek pipeline needs dimension context |
| Track E: Integration | **MEDIUM** | CLI commands should respect dimension preferences |
| Track F: Social | **HIGH** | Social Leaderboard now required for 7th dimension |

---

### Pending Decisions Impact

| Decision | Impact from Research | New Status |
|----------|---------------------|------------|
| PD-001: Archetype Philosophy | **RESOLVED** | 6-dimension model with 4 UI clusters |
| PD-002: Streaks vs Rolling | **IMPACTED** | Prevention users value Streak; Promotion users value Progress % |
| PD-003: Holy Trinity Validity | **IMPACTED** | Holy Trinity maps to dimensions, remains valid as extraction target |
| PD-004: Dev Mode | No impact | — |
| PD-101: Sherlock Prompt | **CRITICAL** | Must extract dimension signals, not just labels |
| PD-102: JITAI Hardcoded vs AI | **RESOLVED** | Dimensions = Context Vector for Bandit |
| PD-103: Sensitivity Detection | **IMPACTED** | Sensitivity may correlate with Perfectionistic Reactivity |
| PD-104: Loading Insights | **IMPACTED** | Insights should reflect user's dimensional profile |

---

## New Roadmap Elements Identified

### GAP IDENTIFIED: Proactive Analytics Engine

**Current State:** JITAI is REACTIVE (intervenes when things go wrong)
**Missing:** PROACTIVE recommendation system

**What's Needed:**
```
PROACTIVE ANALYTICS ENGINE
├── Habit Recommendations: "Based on your profile, try X"
├── Ritual Suggestions: "Morning routines for Overthinkers"
├── Progression Paths: "Your next identity milestone"
├── Regression Analysis: "Warning: Pattern suggests dropout risk"
├── Goal Alignment: "This habit conflicts with your stated values"
└── Anti-Identity Prevention: "This behavior reinforces your feared self"
```

**Priority:** HIGH — This elevates value proposition from "accountability app" to "AI life coach"

**Research Required:**
- What recommendation algorithms work for identity-based goals?
- How do we avoid overwhelming users with suggestions?
- How does this integrate with JITAI?

---

### GAP IDENTIFIED: Content Library

**Current State:** Generic intervention messages
**Required:** 4 message variants per trigger per dimension combination

**Content Matrix:**
| Dimension State | Message Framing |
|-----------------|-----------------|
| Promotion + Low Reactance | Eager ("Go for it!") |
| Prevention + Low Reactance | Vigilant ("Protect your progress") |
| Promotion + High Reactance | Autonomy-Supportive ("When you're ready...") |
| Prevention + High Reactance | Directive-Soft ("Your choice, but consider...") |

**Scale:** 7 intervention arms × 4 framings = 28 message templates minimum

---

### GAP IDENTIFIED: Social Leaderboard

**Status:** Not implemented
**Impact:** Enables 7th dimension (Social Sensitivity)
**Add to Roadmap:** Yes

---

## Follow-up Research Points

| ID | Question | Triggered By | Priority |
|----|----------|--------------|----------|
| FRQ-001 | How do dimensions evolve over time? | RQ-001 | HIGH |
| FRQ-002 | What's optimal content library size? | Deep Think | HIGH |
| FRQ-003 | Proactive recommendation algorithms for identity goals | Gap Analysis | CRITICAL |
| FRQ-004 | Social Sensitivity dimension validation | Decision: Add social features | MEDIUM |
| FRQ-005 | Dimension-to-Holy-Trinity mapping validation | PD-003 impact | MEDIUM |

---

---

## Impact Analysis: 06 January 2026 Session

### Decisions Made This Session

| Decision | Type | Impact Level |
|----------|------|--------------|
| **CD-017** | Android-First Development Strategy | **CRITICAL** |
| **CD-018** | Engineering Threshold Framework | **CRITICAL** |
| **Protocol 9** | External Research Reconciliation | HIGH |
| **RQ-013** | Identity Topology (COMPLETE) | HIGH |
| **RQ-014** | State Economics (COMPLETE) | **CRITICAL** |
| **RQ-015** | Polymorphic Habits (COMPLETE) | HIGH |
| **PD-117** | ContextSnapshot Real-time Data (RESOLVED) | HIGH |

---

### CD-017: Android-First Impact Analysis

**Upstream Consequences (What this decision blocks):**

| Element | Impact | Action Required |
|---------|--------|-----------------|
| Deep Think sessions | Must include "Android-First Data Reality Audit" | Protocol 9 enforces this |
| RQ-014 (State Economics) | Heart rate now nullable; step count primary | Already reconciled |
| RQ-018 (Airlock Protocol) | Must use Android sensors only | Constraint documented |
| ContextSnapshot design | Tiered refresh based on Android APIs | PD-117 resolved |
| Battery budget | 5% ceiling locked per CD-015 | All features must fit |

**Downstream Consequences (What depends on this):**

| Element | Impact | New Constraint |
|---------|--------|----------------|
| Passive detection algorithm | Must use: UsageStatsManager, Google Fit, CalendarContract, Geofencing | Heartrate optional |
| All future RQs | Must pass "Android Data Reality Audit" before integration | Via Protocol 9 Phase 2 |
| iOS development | Secondary; Android features first, iOS port second | Development priority |
| Wearable features | Tier 4 (optional); never required for core functionality | Graceful degradation |

---

### CD-018: Engineering Threshold Impact Analysis

**Classification Framework Applied:**

| Component | Classification | Rationale |
|-----------|----------------|-----------|
| 4-state energy model | ESSENTIAL | Core to psyOS; enables all identity-aware features |
| Switching cost matrix | ESSENTIAL | Enables burnout prevention, JITAI timing |
| Passive detection (Android) | ESSENTIAL | Core context awareness |
| Heart rate integration | NICE-TO-HAVE | Only 10% of Android users have smartwatches |
| 5-state energy model | OVER-ENGINEERED | Requires cognitive mode detection not feasible on Android |
| Real-time heartrate | OVER-ENGINEERED | Battery prohibitive; hourly sufficient |

**Impact on Implementation Prioritization:**

| Task ID | Task | Old Priority | New Classification | Action |
|---------|------|--------------|-------------------|--------|
| B-08 | EnergyState enum (4-state) | CRITICAL | ESSENTIAL | Proceed as planned |
| B-09 | inferEnergyState() | CRITICAL | ESSENTIAL | Use Android-only signals |
| B-10 | BurnoutDetector | HIGH | VALUABLE | 3-signal algorithm (middle ground) |
| — | 5-state energy model | — | REJECT | Conflicts with CD-015 |
| — | Real-time heartrate | — | REJECT | Battery prohibitive |

---

### Protocol 9: Impact on Future Research

**New Workflow (Enforced):**

```
External Research (Deep Think, Claude, GPT, etc.)
    ↓
Protocol 9 Phase 1: Locked Decision Audit
    ↓ (Reject conflicts with CDs)
Protocol 9 Phase 2: Data Reality Audit (CD-017)
    ↓ (Filter for Android availability)
Protocol 9 Phase 3-6: ACCEPT/MODIFY/REJECT/ESCALATE
    ↓
Reconciliation document → docs/analysis/
    ↓
Only THEN integrate into Core Docs
```

**Impact on Research Pipeline:**

| RQ | Status | Protocol 9 Applied |
|----|--------|-------------------|
| RQ-013, 14, 15 | COMPLETE | Yes (first application) |
| RQ-005, 6, 7 | NEEDS RESEARCH | Must apply when results arrive |
| RQ-017 | NEEDS RESEARCH | Must apply when results arrive |
| RQ-018 | NEEDS RESEARCH | Must apply when results arrive |

---

### RQ-013/14/15 Completion: Downstream Effects

**Database Schema (Confirmed):**

| Table | Status | Fields Added |
|-------|--------|--------------|
| `identity_topology` | Ready for implementation | `switching_cost_minutes`, `friction_coefficient` |
| `habit_facet_links` | Ready for implementation | `custom_metrics JSONB` |

**Service Layer (Confirmed):**

| Service | Status | Key Methods |
|---------|--------|-------------|
| EnergyState | Ready | 4-state enum |
| inferEnergyState() | Ready | Android-first detection |
| BurnoutDetector | Ready | 3-signal algorithm |
| WaterfallAttribution | Ready | Multi-facet habit credit |

**Blocked Research (Now Unblocked):**

| RQ | Was Blocked By | Now Status |
|----|----------------|------------|
| RQ-017 (Constellation UX) | RQ-012 | READY for research |
| RQ-018 (Airlock Protocol) | RQ-012 | READY for research |
| RQ-024 (Treaty Modification) | RQ-021 | READY for research |

---

### Implementation Task Impact

**Tasks Extracted from Deep Think Reconciliation:**

| ID | Task | Priority | Component | Depends On |
|----|------|----------|-----------|------------|
| A-12 | Create `identity_topology` table | CRITICAL | Database | — |
| A-13 | Add `custom_metrics JSONB` to `habit_facet_links` | HIGH | Database | — |
| B-08 | Implement `EnergyState` enum (4-state) | CRITICAL | Service | — |
| B-09 | Implement `inferEnergyState()` | CRITICAL | Service | B-08 |
| B-10 | Implement `BurnoutDetector` (3 signals) | HIGH | Service | B-08, B-09 |
| B-11 | Implement `WaterfallAttribution` | HIGH | Service | — |
| B-12 | Update `ContextSnapshot` tiered refresh | HIGH | Service | B-09 |
| B-13 | Implement Council trigger formula | HIGH | Service | RQ-013 |
| C-05 | Integrate dangerous transition tracking | MEDIUM | Council AI | B-08, B-09 |

---

### Recommendations

1. **Immediate:** Add 9 tasks from reconciliation to Master Implementation Tracker
2. **Before Next Deep Think:** Ensure prompt includes Android-First constraints explicitly
3. **Documentation:** Consider creating a "Data Availability Matrix" as permanent reference
4. **Quality Gate:** All future implementation PRs must cite their task ID (A-xx, B-xx, C-xx)

---

## Impact Analysis: 10 January 2026 Session

### Research Completed This Session

| Research | Status | Impact Level |
|----------|--------|--------------|
| **RQ-005** | ✅ COMPLETE | **CRITICAL** — Core Identity Coach algorithm |
| **RQ-006** | ✅ COMPLETE | **HIGH** — Content library specification |
| **RQ-007** | ✅ COMPLETE | **HIGH** — Identity roadmap architecture |

### Reconciliation Summary

**Source:** DeepSeek Deep Think
**Document:** `docs/analysis/DEEP_THINK_RECONCILIATION_RQ005_RQ006_RQ007.md`
**Results:** 14 ACCEPT, 5 MODIFY, 1 REJECT, 1 ESCALATE

---

### RQ-005/006/007: Cascade Effects

**Schema Impact (New Tables Required):**

| Table | Purpose | Priority | Source |
|-------|---------|----------|--------|
| `preference_embeddings` | User taste vector (768-dim) | HIGH | RQ-005 |
| `identity_roadmaps` | User aspiration tracking | CRITICAL | RQ-007 |
| `roadmap_nodes` | Roadmap stage progression | CRITICAL | RQ-007 |
| `archetype_templates` | 12 preset dimension combinations | HIGH | RQ-006 |

**Schema Impact (Field Additions):**

| Table | Field | Purpose | Source |
|-------|-------|---------|--------|
| `habit_templates` | `ideal_dimension_vector` | Psychometric matching | RQ-005 |
| `identity_facets` | `archetype_template_id` | Content mapping | RQ-006 |

**Service Layer Impact:**

| Service | Status | Key Methods |
|---------|--------|-------------|
| `ProactiveRecommendation` | NEW | Dart model for recommendation output |
| `IdentityRoadmapService` | NEW | Roadmap CRUD + ICS calculation |
| `generateRecommendations()` | NEW | Edge Function for async recommendations |

**Content Requirements:**

| Content Type | Quantity | Status | Blocking |
|--------------|----------|--------|----------|
| Universal Habit Templates | 50 | 🔴 TODO | Identity Coach launch |
| Archetype Template Presets | 12 | 🔴 TODO | Content mapping |
| Framing Templates | 12 | 🔴 TODO | Personalization |
| Ritual Templates | 4 | 🔴 TODO | Ritual recommendations |

---

### Human Decision Required

**Content Library Size at Launch:**

| Option | Habits | Templates | Effort | Ship Speed |
|--------|--------|-----------|--------|------------|
| **A** (Recommended) | 50 | 12 | Low | Fast |
| **B** | 100 | 24 | Medium | Moderate |
| **C** | 200+ | 48 | High | Slow |

**Recommendation:** Option A — ship fast, iterate based on feedback.

---

### Implementation Tasks Extracted

| ID | Task | Priority | Component | Source |
|----|------|----------|-----------|--------|
| F-01 | Create `preference_embeddings` table | HIGH | Database | RQ-005 |
| F-02 | Create `identity_roadmaps` table | CRITICAL | Database | RQ-007 |
| F-03 | Create `roadmap_nodes` table | CRITICAL | Database | RQ-007 |
| F-04 | Add `ideal_dimension_vector` to `habit_templates` | HIGH | Database | RQ-005 |
| F-05 | Add `archetype_template_id` to `identity_facets` | HIGH | Database | RQ-006 |
| F-06 | Create `archetype_templates` reference table | HIGH | Database | RQ-006 |
| F-07 | Implement `generateRecommendations()` Edge Function | CRITICAL | Backend | RQ-005 |
| F-08 | Implement Stage 1: Semantic retrieval | CRITICAL | Backend | RQ-005 |
| F-09 | Implement Stage 2: Psychometric re-ranking | CRITICAL | Backend | RQ-005 |
| F-10 | Implement "Architect" scheduler (nightly/weekly) | HIGH | Backend | RQ-005 |
| F-11 | Implement feedback signal tracking | HIGH | Service | RQ-005 |
| F-12 | Extend Sherlock Day 3: "Future Self Interview" | HIGH | Onboarding | RQ-007 |
| F-13 | Create 50 universal habit templates | CRITICAL | Content | RQ-006 |
| F-14 | Create 12 Archetype Template presets | HIGH | Content | RQ-006 |
| F-15 | Create 12 Framing Templates | HIGH | Content | RQ-006 |
| F-16 | Create 4 Ritual Templates | MEDIUM | Content | RQ-006 |
| F-17 | Implement `ProactiveRecommendation` Dart model | HIGH | Service | RQ-005 |
| F-18 | Implement `IdentityRoadmapService` | HIGH | Service | RQ-007 |
| F-19 | Implement Pace Car rate limiting | HIGH | Service | RQ-005 |
| F-20 | Create regression messaging templates | MEDIUM | Content | RQ-006 |

---

### Dependency Chain Update

```
RQ-005 (Proactive Algorithms) ✅
├── Depends on: RQ-001 (Dimensions) ✅
├── Depends on: RQ-012 (Fractal Trinity) ✅
├── Enables: F-07 through F-11 (Backend tasks)
├── Enables: F-17 (ProactiveRecommendation model)
└── Enables: F-19 (Pace Car rate limiting)

RQ-006 (Content Library) ✅
├── Depends on: RQ-005 (algorithms need content)
├── Enables: F-13 through F-16 (Content tasks)
├── Enables: F-06 (Archetype Templates table)
└── BLOCKS: Full Identity Coach launch (content is a blocker)

RQ-007 (Identity Roadmap) ✅
├── Depends on: RQ-005 (recommendations feed roadmap)
├── Enables: F-02, F-03, F-12, F-18
└── Enables: Progression UI in Constellation
```

---

### GLOSSARY Terms Added

10 new terms added from RQ-005/006/007:
- The Architect, The Commander, Pace Car Protocol, Trinity Seed
- Preference Embedding, Archetype Template, Identity Consolidation Score (ICS)
- The Spark, The Dip, The Groove
- Two-Stage Hybrid Retrieval, Future Self Interview

---

### Recommendations

1. **Immediate:** Human approval on content library size (Option A recommended)
2. **Implementation Order:** F-02 → F-03 → F-07 → F-08 → F-09 (critical path)
3. **Content Parallel Track:** F-13 → F-14 → F-15 can proceed in parallel with DB work
4. **Integration:** Sherlock extension (F-12) should be added to Day 3 flow

---

## Revision History

| Date | Research/Decision | Roadmap Items Impacted | Changes Made |
|------|-------------------|------------------------|--------------|
| 10 Jan 2026 | RQ-005, RQ-006, RQ-007 (Identity Coach) | Identity Coach tasks F-01 through F-20, Content Library | Protocol 9 reconciliation, 20 new implementation tasks |
| 06 Jan 2026 | CD-017, CD-018, RQ-013/14/15, PD-117 | All implementation, Protocol 9, Task extraction | Full impact analysis added |
| 05 Jan 2026 | RQ-001 Complete | All Layers, PD-001, PD-102, PD-002, PD-003, PD-101, PD-104 | Initial impact analysis |

