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
  decisions/            # Domain-specific Product Decisions
    MANIFEST.md         # LOADING RULES — which files to load when
    PD_CORE.md          # CDs + foundational decisions (always load)
    PD_WITNESS.md       # Witness Intelligence Layer decisions
    PD_JITAI.md         # JITAI + Intelligence decisions
    PD_IDENTITY.md      # Identity Coach, Archetypes decisions
    PD_UX.md            # Screens, Flows, Onboarding decisions
  IMPLEMENTATION_ACTIONS.md  # Task tracker (quick status + audit trail)
  RESEARCH_QUESTIONS.md      # Master Implementation Tracker (detailed tasks)
  AI_AGENT_PROTOCOL.md  # 12 mandatory protocols (1-9 operational, 10-12 meta-cognitive)
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

### Step 0: Git State Check (MANDATORY — Prevents Duplicate Work)
```bash
git status                    # Uncommitted changes from stuck session?
git log --oneline -3          # Task already in recent commits?
git log origin/HEAD..HEAD     # Unpushed commits needing push?
```

### Steps 1-7: Context Acquisition
1. Read `docs/CORE/AI_HANDOVER.md` — session context (~120 lines, always fits)
2. Read `docs/CORE/decisions/MANIFEST.md` — **LOADING RULES** for domain-specific context
3. Load `docs/CORE/decisions/PD_CORE.md` — always load CDs first
4. Load domain-specific file based on task (see MANIFEST.md for mapping)
5. Check `docs/CORE/index/` — current status of decisions (CD/PD) and research (RQ)
6. Check `docs/CORE/IMPLEMENTATION_ACTIONS.md` (lines 1-50) — **BLOCKED tasks warning**
7. **REALITY CHECK:** Verify schema tables exist before implementing (Phase H is BLOCKED)

### Large File Handling
If a file exceeds token limit, read in chunks:
- **Header first:** `offset=0, limit=100` (status, blockers)
- **Footer if needed:** `offset=(total-100), limit=100` (checklists, summaries)

## Before Processing External Research
1. Read `docs/CORE/DEEP_THINK_PROMPT_GUIDANCE.md` — quality standards
2. Run Protocol 9 from `docs/CORE/AI_AGENT_PROTOCOL.md` — reconciliation checklist

## Key Documentation
| File | Purpose |
|------|---------|
| `docs/CORE/PRODUCT_DEVELOPMENT_SHEET.md` | **START HERE** — Consolidated CD/RQ/PD/Task status |
| `docs/CORE/AI_HANDOVER.md` | Session continuity |
| `docs/CORE/decisions/MANIFEST.md` | **CONTEXT LOADING RULES** — which PD files to load |
| `docs/CORE/decisions/PD_CORE.md` | Core Decisions (CDs) — always load first |
| `docs/CORE/decisions/PD_*.md` | Domain-specific decisions (see MANIFEST.md) |
| `docs/CORE/IMPLEMENTATION_ACTIONS.md` | Task quick status + audit trail |
| `docs/CORE/RESEARCH_QUESTIONS.md` | Master Implementation Tracker (107 tasks) |
| `docs/CORE/AI_AGENT_PROTOCOL.md` | 12 mandatory protocols |
| `docs/CORE/DEEP_THINK_PROMPT_GUIDANCE.md` | External research quality |
| `docs/CORE/GLOSSARY.md` | Terminology |

## After Working
Update `docs/CORE/AI_HANDOVER.md` with what you accomplished and what remains.
