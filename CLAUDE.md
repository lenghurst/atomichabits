# CLAUDE.md — The Pact

> **Reading Order Owner:** This file is the SOLE AUTHORITATIVE SOURCE for agent reading order.
> **Version:** 2.0 | **Last Updated:** 11 January 2026

## What
- **psyOS** (Psychological Operating System) — NOT a habit tracker
- **Stack:** Flutter 3.38.4 (Android-first), Supabase (PostgreSQL + pgvector), DeepSeek AI
- **Core concept:** Parliament of Selves, Identity Evidence, Council AI

## Why
Users are treated as multiple identity facets negotiating for attention, not a monolithic self requiring discipline. The atomic unit is Identity Evidence.

---

## Agent Reading Order v2.0 (AUTHORITATIVE)

### Level 0: Orientation (Always — 5 min)
| # | File | Purpose | Preview |
|---|------|---------|---------|
| 1 | **This file (CLAUDE.md)** | Project identity, constraints | You're reading it |
| 2 | `docs/CORE/AI_HANDOVER.md` (top section) | Last session wisdom | What did previous agent accomplish? |

**STOP if:** Quick question or clarification only
**CONTINUE if:** Any implementation, research, or audit task

### Level 1: Status Snapshot (Most tasks — 10 min)
| # | File | Purpose | Current State |
|---|------|---------|---------------|
| 3 | `docs/CORE/index/CD_INDEX.md` | LOCKED decisions | 18 CDs — ALL CONFIRMED |
| 4 | `docs/CORE/index/PD_INDEX.md` | Pending decisions | 32 PDs — 15 resolved, 10 pending |
| 5 | `docs/CORE/index/RQ_INDEX.md` | Research status | 40 RQs — 31 complete, 8+7 pending |

**VERIFICATION:** Can you state which CDs constrain your task?
**STOP if:** Task is unblocked and straightforward
**CONTINUE if:** Task involves blocked items or dependencies

### Level 2: Task Context (Complex tasks — 15 min)
| # | File | Purpose |
|---|------|---------|
| 6 | `docs/CORE/IMPLEMENTATION_ACTIONS.md` | Task navigation, phase overview |
| 7 | `docs/CORE/PRODUCT_DEVELOPMENT_SHEET.md` | Executive summary, dependencies |

**VERIFICATION:** Can you identify your task's phase and blockers?
**STOP if:** Implementation task with clear path
**CONTINUE if:** Research, governance, or audit task

### Level 3: Deep Context (Research/Audit only — 30+ min)
| # | File | Purpose |
|---|------|---------|
| 8 | `docs/CORE/RESEARCH_QUESTIONS.md` | Full task specifications |
| 9 | `docs/CORE/PRODUCT_DECISIONS.md` | Decision rationale |
| 10 | `docs/CORE/AI_AGENT_PROTOCOL.md` | 13 mandatory protocols |
| 11 | `docs/CORE/IMPACT_ANALYSIS.md` | Cascade effects |

**Reference (as needed):**
- `GLOSSARY.md` — Unknown terms
- `AI_CONTEXT.md` — Architecture questions
- `ROADMAP.md` — Priority questions

---

## Session Start Verification (Required in first response)

```
□ Last session summary: _______________________
□ Task classification: [Quick/Implementation/Research/Audit]
□ Reading level reached: [0/1/2/3]
□ Blocking CDs: _____________ (or "none")
□ Task dependencies: _________ (or "none")
□ Phase: [A/B/C/D/E/F/G/H/N/A]
```

---

## Critical Constraints (CD-015 through CD-018)
- **CD-015:** 4-state energy model (high_focus, high_physical, social, recovery)
- **CD-016:** DeepSeek V3.2 (analyst), R1 Distilled (reasoning)
- **CD-017:** Android-first — all features must work without iOS/wearables
- **CD-018:** ESSENTIAL/VALUABLE/NICE-TO-HAVE/OVER-ENGINEERED threshold

Full list: `docs/CORE/index/CD_INDEX.md`

## Current Blocker (11 Jan 2026)
**Phase A Schema is BLOCKED** — `identity_facets`, `identity_topology` tables don't exist.
104 of 116 tasks depend on Phase A. Verify schema before implementing.

## Project Structure
```
lib/                    # Flutter app code
docs/CORE/              # Governance documentation
  AI_HANDOVER.md        # Session context
  index/                # Quick status lookup (CD/PD/RQ)
  IMPLEMENTATION_ACTIONS.md  # Task tracker
  RESEARCH_QUESTIONS.md      # Master Implementation Tracker (116 tasks)
  AI_AGENT_PROTOCOL.md  # 13 mandatory protocols
```

## Commands
```bash
flutter test                    # Run tests
flutter build apk               # Build Android
cd supabase && supabase db push # Push schema
```

## After Working
Update `docs/CORE/AI_HANDOVER.md` with what you accomplished and what remains.
