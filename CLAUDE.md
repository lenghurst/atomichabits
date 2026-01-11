# CLAUDE.md — The Pact

## What
- **psyOS** (Psychological Operating System) — NOT a habit tracker
- **Stack:** Flutter 3.38.4 (Android-first), Supabase (PostgreSQL + pgvector), DeepSeek AI
- **Core concept:** Parliament of Selves, Identity Evidence, Council AI

## Why
Users are treated as multiple identity facets negotiating for attention, not a monolithic self requiring discipline. The atomic unit is Identity Evidence.

## Project Structure
```
lib/                    # Flutter app code
docs/CORE/              # Governance documentation
  AI_HANDOVER.md        # READ FIRST — session context
  index/                # Quick status lookup (CD/PD/RQ)
  IMPLEMENTATION_ACTIONS.md  # Task tracker (quick status + audit trail)
  RESEARCH_QUESTIONS.md      # Master Implementation Tracker (detailed tasks)
  AI_AGENT_PROTOCOL.md  # 13 mandatory protocols (1-9 operational, 10-12 meta-cognitive)
  DEEP_THINK_PROMPT_GUIDANCE.md  # External research quality standards
```

## Commands
```bash
flutter test                    # Run tests
flutter build apk               # Build Android
cd supabase && supabase db push # Push schema
```

## Critical Constraints (Locked — Cannot Change Without Human Approval)
- **CD-015:** 4-state energy model (high_focus, high_physical, social, recovery) — NOT 5-state
- **CD-016:** DeepSeek V3.2 (analyst), R1 Distilled (reasoning)
- **CD-017:** Android-first — all features must work without iOS/wearables
- **CD-018:** ESSENTIAL/VALUABLE/NICE-TO-HAVE/OVER-ENGINEERED threshold framework

Full list: `docs/CORE/index/CD_INDEX.md`

## Before Working
1. Read `docs/CORE/AI_HANDOVER.md` — session context from last agent
2. Check `docs/CORE/index/` — current status of decisions (CD/PD) and research (RQ)
3. Check `docs/CORE/IMPLEMENTATION_ACTIONS.md` — **includes BLOCKED tasks warning**
4. **REALITY CHECK:** Verify schema tables exist before implementing (Phase H is BLOCKED)

## Before Processing External Research
1. Read `docs/CORE/DEEP_THINK_PROMPT_GUIDANCE.md` — quality standards
2. Run Protocol 9 from `docs/CORE/AI_AGENT_PROTOCOL.md` — reconciliation checklist

## Key Documentation
| File | Purpose |
|------|---------|
| `docs/CORE/PRODUCT_DEVELOPMENT_SHEET.md` | **START HERE** — Consolidated CD/RQ/PD/Task status |
| `docs/CORE/AI_HANDOVER.md` | Session continuity |
| `docs/CORE/IMPLEMENTATION_ACTIONS.md` | Task quick status + audit trail |
| `docs/CORE/RESEARCH_QUESTIONS.md` | Master Implementation Tracker (107 tasks) |
| `docs/CORE/AI_AGENT_PROTOCOL.md` | 13 mandatory protocols |
| `docs/CORE/DEEP_THINK_PROMPT_GUIDANCE.md` | External research quality |
| `docs/CORE/PRODUCT_DECISIONS.md` | Decision rationale |
| `docs/CORE/GLOSSARY.md` | Terminology |

## After Working
Update `docs/CORE/AI_HANDOVER.md` with what you accomplished and what remains.
