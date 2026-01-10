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
  IMPACT_ANALYSIS.md    # Current tasks + cascade tracking
  AI_AGENT_PROTOCOL.md  # 9 mandatory protocols
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
3. Check `docs/CORE/IMPACT_ANALYSIS.md` — actionable tasks and cascade effects

## Before Processing External Research
1. Read `docs/CORE/DEEP_THINK_PROMPT_GUIDANCE.md` — quality standards
2. Run Protocol 9 from `docs/CORE/AI_AGENT_PROTOCOL.md` — reconciliation checklist

## Key Documentation
| File | Purpose |
|------|---------|
| `docs/CORE/AI_HANDOVER.md` | Session continuity (READ FIRST) |
| `docs/CORE/IMPACT_ANALYSIS.md` | Actionable tasks + cascade tracking |
| `docs/CORE/AI_AGENT_PROTOCOL.md` | 9 mandatory protocols |
| `docs/CORE/DEEP_THINK_PROMPT_GUIDANCE.md` | External research quality |
| `docs/CORE/PRODUCT_DECISIONS.md` | Decision rationale |
| `docs/CORE/RESEARCH_QUESTIONS.md` | Active research |
| `docs/CORE/GLOSSARY.md` | Terminology |

## After Working
Update `docs/CORE/AI_HANDOVER.md` with what you accomplished and what remains.
