# Claude Session Primer — The Pact (psyOS)

> **Last Updated:** 06 January 2026
> **Purpose:** Prime new Claude sessions with project context
> **Usage:** Copy this prompt into a new Claude session to continue development

---

## Project Overview

**App Name:** The Pact
**Type:** psyOS (Psychological Operating System) — NOT a habit tracker
**Platform:** Flutter (Android-first per CD-017)
**Database:** Supabase (PostgreSQL + pgvector)
**AI:** DeepSeek V3.2 (analyst), DeepSeek R1 Distilled (reasoning)

---

## Core Philosophy

The Pact treats users as a **"Parliament of Selves"** — multiple identity facets negotiating for attention, not a monolithic self requiring discipline.

| Old Frame | New Frame (psyOS) |
|-----------|-------------------|
| Habit Tracker | Psychological Operating System |
| Monolithic Self | Parliament of Selves |
| Discipline | Governance (Coalition) |
| Streaks | Identity Consolidation |
| Failure | Facet Conflict |

---

## Critical Context Files (Read These First)

```
docs/CORE/
├── README.md                      ← Start here
├── AI_AGENT_PROTOCOL.md           ← Your behavioral rules (MANDATORY)
├── PRODUCT_DECISIONS.md           ← Locked decisions (CDs) you MUST NOT contradict
├── RESEARCH_QUESTIONS.md          ← Research status and task tracker
├── IMPACT_ANALYSIS.md             ← Decision consequences
├── index/                         ← Quick reference indexes
│   ├── RQ_INDEX.md               ← Research question status at a glance
│   ├── CD_INDEX.md               ← Confirmed decisions at a glance
│   └── PD_INDEX.md               ← Pending decisions at a glance
└── archive/                       ← Completed/resolved items
```

---

## Locked Decisions (Cannot Be Changed Without Human Approval)

| CD# | Decision | Impact |
|-----|----------|--------|
| **CD-005** | 6-Dimension Archetype Model | User profiles are 6-float vectors |
| **CD-015** | psyOS Architecture | Parliament of Selves, 4-state energy, Council AI |
| **CD-016** | AI Model Strategy | DeepSeek V3.2 (analyst), R1 Distilled (reasoning) |
| **CD-017** | Android-First Development | All features must work without iOS/wearables |
| **CD-018** | Engineering Threshold Framework | ESSENTIAL/VALUABLE/NICE-TO-HAVE/OVER-ENGINEERED |

**4-State Energy Model (LOCKED — NOT 5-state):**
- `high_focus` — Productivity work
- `high_physical` — Exercise, movement
- `social` — Meetings, social activities
- `recovery` — Rest, low activity

---

## Current Architecture

```
Identity System:
├── identity_facets (with 768-dim embeddings)
├── identity_topology (facet-facet relationships)
├── habit_facet_links (polymorphic habits)
└── Council AI (mediates facet conflicts)

Intelligence System:
├── JITAI (reactive, Thompson Sampling bandit)
├── Identity Coach (proactive, NEEDS RESEARCH)
├── Burnout Detector (3-signal algorithm)
└── ContextSnapshot (tiered refresh rates)

Passive Detection (Android-Only):
├── UsageStatsManager (foreground app, screen time)
├── Google Fit / Health Connect (steps)
├── Geofencing API (location zones)
├── CalendarContract (calendar events)
└── Health Connect (heartRate OPTIONAL, ~10% users)
```

---

## Research Status

**COMPLETE:**
- RQ-012: Fractal Trinity Architecture ✅
- RQ-013: Identity Topology ✅
- RQ-014: State Economics ✅
- RQ-015: Polymorphic Habits ✅
- RQ-016: Council AI Architecture ✅

**NEEDS RESEARCH (Priority Order):**
1. **RQ-005, 006, 007:** Identity Coach (Proactive Recommendations) — **Deep Think prompt ready**
2. **RQ-017:** Constellation UX (Dashboard visualization)
3. **RQ-018:** Airlock & Priming Protocol (JITAI integration)
4. **RQ-019:** pgvector Implementation
5. **RQ-020:** Treaty-JITAI Integration

---

## Protocol 9: External Research Reconciliation

**MANDATORY before integrating ANY external AI output (Deep Think, Claude, GPT):**

```
Phase 1: Locked Decision Audit → Check against all CDs
Phase 2: Data Reality Audit → Verify Android-first compatibility
Phase 3: Implementation Reality Audit → Check existing code
Phase 4: Scope & Complexity Audit → ESSENTIAL → OVER-ENGINEERED
Phase 5: Categorize → ACCEPT / MODIFY / REJECT / ESCALATE
Phase 6: Document → Create reconciliation file in docs/analysis/
```

---

## File Organization Rules (CD-014)

| File Type | Location |
|-----------|----------|
| Deep Think prompts | `docs/prompts/` |
| Reconciliation documents | `docs/analysis/` |
| Quick reference indexes | `docs/CORE/index/` |
| Archived items | `docs/CORE/archive/` |
| Governance files | `docs/CORE/` (LOCKED — no new files) |

---

## Current Tasks Pending

**Implementation Tasks (from Deep Think Reconciliation):**

| ID | Task | Priority |
|----|------|----------|
| A-12 | Create `identity_topology` table | CRITICAL |
| A-13 | Add `custom_metrics JSONB` to `habit_facet_links` | HIGH |
| B-08 | Implement `EnergyState` enum (4-state) | CRITICAL |
| B-09 | Implement `inferEnergyState()` | CRITICAL |
| B-10 | Implement `BurnoutDetector` (3 signals) | HIGH |
| B-11 | Implement `WaterfallAttribution` | HIGH |
| B-12 | Update `ContextSnapshot` tiered refresh | HIGH |
| B-13 | Implement Council trigger formula | HIGH |
| C-05 | Integrate dangerous transition tracking | MEDIUM |

---

## Next Steps (Suggested)

1. **If implementing:** Start with A-12 → B-08 → B-09 chain (database → service)
2. **If researching:** Send `docs/prompts/DEEP_THINK_PROMPT_IDENTITY_COACH_RQ005-RQ006-RQ007.md` to Deep Think
3. **If reviewing:** Run Protocol 9 on any existing Deep Think outputs in `docs/analysis/`

---

## Key Terms (Glossary)

| Term | Meaning |
|------|---------|
| **Facet** | An identity role (e.g., "Devoted Father", "Ambitious Programmer") |
| **Holy Trinity** | Anti-Identity + Failure Archetype + Resistance Lie (extracted by Sherlock) |
| **Sherlock** | Voice-based onboarding AI that extracts psychological profile |
| **Council AI** | DeepSeek R1 that mediates facet conflicts |
| **JITAI** | Just-In-Time Adaptive Intervention (reactive nudges) |
| **Identity Coach** | Proactive recommendation system (NEEDS RESEARCH) |
| **Treaty** | User-imposed rule between facets (e.g., "No work after 6pm") |
| **Switching Cost** | Minutes needed to recover from facet transition |

---

## How to Use This Primer

1. **Read AI_AGENT_PROTOCOL.md** — Contains your behavioral rules
2. **Check index files** — Quick status of all RQs, CDs, PDs
3. **Read PRODUCT_DECISIONS.md** — Full details of locked decisions
4. **Check RESEARCH_QUESTIONS.md** — Master Implementation Tracker at bottom

**IMPORTANT:** If you receive external research output, run Protocol 9 BEFORE integrating.

---

## Contact for Human Decisions

If you encounter:
- Conflicts with locked CDs → ESCALATE to human
- Ambiguous requirements → Ask human via AskUserQuestion
- Architecture changes → Requires human approval

---

*This primer was auto-generated on 06 January 2026. For latest status, check the index files.*
