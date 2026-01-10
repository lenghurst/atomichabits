# IMPLEMENTATION_ACTIONS.md — Canonical Task Tracker

> **Last Updated:** 10 January 2026
> **Purpose:** Single source of truth for all implementation tasks
> **Status:** Active — This document MUST be updated when tasks are extracted

---

## What This Document Is

This document ensures **no implementation task is lost**. When research concludes or reconciliation happens:

1. Tasks are extracted and added HERE
2. This document links to the Master Implementation Tracker in RESEARCH_QUESTIONS.md
3. Status updates happen here (or in the Master Tracker)

**Rule:** If a task exists, it MUST be in this document OR the Master Implementation Tracker. Never both in separate locations without cross-reference.

---

## Related Documentation

| Document | Relationship |
|----------|--------------|
| **[RESEARCH_QUESTIONS.md](./RESEARCH_QUESTIONS.md)** | Contains Master Implementation Tracker (canonical task list) |
| **[IMPACT_ANALYSIS.md](./IMPACT_ANALYSIS.md)** | Contains cascade analysis (references tasks, does NOT define them) |
| **[AI_AGENT_PROTOCOL.md](./AI_AGENT_PROTOCOL.md)** | Protocol 8 (Task Extraction) — specifies when to add tasks |
| **[AI_HANDOVER.md](./AI_HANDOVER.md)** | Session context — references active tasks |

---

## Workflow: Task Extraction

When extracting tasks from research or reconciliation:

```
1. EXTRACT tasks from ACCEPT/MODIFY items
   ↓
2. CHECK if task already exists in Master Tracker (RESEARCH_QUESTIONS.md)
   ↓
3. If NEW → Add to Master Tracker under appropriate Phase (A-F)
   ↓
4. If DUPLICATE → Update existing task, don't create new
   ↓
5. UPDATE this document's Quick Status section
   ↓
6. CROSS-REFERENCE in IMPACT_ANALYSIS.md (for cascade tracking)
```

**CRITICAL:** IMPACT_ANALYSIS.md is for CASCADE ANALYSIS, not task storage. Tasks go in the Master Tracker.

---

## Quick Status

### Current Phase Summary

| Phase | Description | Total | CRITICAL | NOT STARTED | IN PROGRESS | COMPLETE |
|-------|-------------|-------|----------|-------------|-------------|----------|
| **A: Schema** | Database foundation | 10 | 6 | 10 | 0 | 0 |
| **B: Intelligence** | Backend services | 15 | 5 | 15 | 0 | 0 |
| **C: Council AI** | Council system | 12 | 5 | 12 | 0 | 0 |
| **D: UX** | Frontend screens | 10 | 2 | 10 | 0 | 0 |
| **E: Polish** | Advanced features | 10 | 0 | 10 | 0 | 0 |
| **F: Identity Coach** | Recommendation engine | 20 | 5 | 20 | 0 | 0 |
| **TOTAL** | | **77** | **23** | **77** | **0** | **0** |

*For detailed task list, see: RESEARCH_QUESTIONS.md → "Master Implementation Tracker"*

---

## Critical Path

### Primary Path (Council AI Foundation)
```
A-01 (pgvector) → A-02/A-03/A-05 (tables) → B-01 (embedding) → B-06/B-07 (Sherlock) → C-01/C-03 (Treaty) → C-04/C-05 (Council) → D-01/D-02 (screens)
```

### Identity Coach Path (Parallel Track)
```
F-02/F-03 (roadmap tables) → F-06 (archetypes) → F-07/F-08/F-09 (retrieval) → F-13 (content) → F-10 (scheduler)
```

---

## Recently Added Tasks

### 10 January 2026 — Identity Coach (Phase F)

**Source:** RQ-005, RQ-006, RQ-007 reconciliation
**Decision:** PD-125 (50 habits at launch with caveat)

| Task ID | Description | Priority | Status |
|---------|-------------|----------|--------|
| F-01 | `preference_embeddings` table | HIGH | 🔴 NOT STARTED |
| F-02 | `identity_roadmaps` table | **CRITICAL** | 🔴 NOT STARTED |
| F-03 | `roadmap_nodes` table | **CRITICAL** | 🔴 NOT STARTED |
| F-04 | `ideal_dimension_vector` field | HIGH | 🔴 NOT STARTED |
| F-05 | `archetype_template_id` FK | HIGH | 🔴 NOT STARTED |
| F-06 | `archetype_templates` reference table | HIGH | 🔴 NOT STARTED |
| F-07 | `generateRecommendations()` Edge Function | **CRITICAL** | 🔴 NOT STARTED |
| F-08 | Stage 1: Semantic retrieval | **CRITICAL** | 🔴 NOT STARTED |
| F-09 | Stage 2: Psychometric re-ranking | **CRITICAL** | 🔴 NOT STARTED |
| F-10 | Architect scheduler | HIGH | 🔴 NOT STARTED |
| F-11 | Feedback signal tracking | HIGH | 🔴 NOT STARTED |
| F-12 | Sherlock Day 3: Future Self Interview | HIGH | 🔴 NOT STARTED |
| F-13 | 50 universal habit templates | **CRITICAL** | 🔴 NOT STARTED |
| F-14 | 12 Archetype Template presets | HIGH | 🔴 NOT STARTED |
| F-15 | 12 Framing Templates | HIGH | 🔴 NOT STARTED |
| F-16 | 4 Ritual Templates | MEDIUM | 🔴 NOT STARTED |
| F-17 | `ProactiveRecommendation` Dart model | HIGH | 🔴 NOT STARTED |
| F-18 | `IdentityRoadmapService` | HIGH | 🔴 NOT STARTED |
| F-19 | Pace Car rate limiting | HIGH | 🔴 NOT STARTED |
| F-20 | Regression messaging templates | MEDIUM | 🔴 NOT STARTED |

---

### 06 January 2026 — Identity System (Phases A-E)

**Source:** RQ-012, RQ-013, RQ-014, RQ-015, RQ-016 reconciliation

57 tasks added across Phases A-E. See RESEARCH_QUESTIONS.md → Master Implementation Tracker for full list.

---

## Blocked Tasks (Awaiting Research)

These tasks cannot be fully specified until research completes:

| Task Range | Blocking Research | Status |
|------------|-------------------|--------|
| E-05, E-06 | RQ-024 (Treaty Modification) | 🔴 NEEDS RESEARCH |
| E-01, E-02 | RQ-025 (Summon Token Economy) | 🔴 NEEDS RESEARCH |
| E-03, E-04 | RQ-026 (Sound Design) | 🔴 NEEDS RESEARCH |
| E-07 | RQ-027 (Template Versioning) | 🔴 NEEDS RESEARCH |
| *Future* | RQ-017 (Constellation UX) | 🔴 NEEDS RESEARCH |
| *Future* | RQ-018 (Airlock Protocol) | 🔴 NEEDS RESEARCH |
| *Future* | RQ-023 (Population Privacy) | 🔴 NEEDS RESEARCH |
| *Future* | RQ-028 (Archetype Definitions) | 🔴 NEEDS RESEARCH |
| *Future* | RQ-029 (Dimension Curation) | 🔴 NEEDS RESEARCH |
| *Future* | RQ-030 (Preference Embedding) | 🔴 NEEDS RESEARCH |
| *Future* | RQ-031 (Pace Car Validation) | 🔴 NEEDS RESEARCH |
| *Future* | RQ-032 (ICS Integration) | 🔴 NEEDS RESEARCH |

---

## Task Addition Log

| Date | Source | Phase | Tasks Added | Added By |
|------|--------|-------|-------------|----------|
| 10 Jan 2026 | RQ-005/006/007 | F | F-01 through F-20 (20 tasks) | Claude (Opus 4.5) |
| 06 Jan 2026 | RQ-012/013/014/015/016 | A-E | A-01 through E-10 (57 tasks) | Claude (Opus 4.5) |

---

## Audit Trail

### Issue Identified: 10 January 2026

**Problem:** F-01 through F-20 tasks from RQ-005/006/007 were added to IMPACT_ANALYSIS.md but NOT to the Master Implementation Tracker in RESEARCH_QUESTIONS.md.

**Root Cause:** Ambiguity between "Implementation Tasks Extracted" in IMPACT_ANALYSIS.md vs "Master Implementation Tracker" in RESEARCH_QUESTIONS.md.

**Resolution:**
1. Added Phase F to Master Implementation Tracker (RESEARCH_QUESTIONS.md)
2. Created this document (IMPLEMENTATION_ACTIONS.md) as single source of truth
3. Clarified workflow: IMPACT_ANALYSIS.md is for CASCADE analysis, not task storage

**Prevention:** This document now serves as the cross-reference layer between reconciliation output and the Master Tracker.

---

*This document is maintained automatically during Protocol 8 (Task Extraction) and Protocol 9 (External Research Reconciliation).*
