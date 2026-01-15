# Gemini Task: Merge Claude Branch to Main

## Task
Merge branch `claude/claude-md-instructions-RREJE` into `main`.

## Context
Claude completed Protocol 9 reconciliation on both Deep Think responses (RQ-010egh Technical + RQ-010cdf UX). Work includes:

- **7 commits ahead of main**
- Analysis files documenting accepted specifications
- New RQs: RQ-010r-w (implementation gaps), RQ-062 (implementation governance)
- Refined prompts (Drafts 2 & 3) for both Permission prompts

## Files to Merge

### New Files (Critical)
```
docs/analysis/DEEP_THINK_RESPONSE_RQ010egh_ANALYSIS.md  # Tech specs
docs/analysis/DEEP_THINK_RESPONSE_RQ010cdf_ANALYSIS.md  # UX specs
docs/analysis/BIG_THINK_CASE_BACKGROUND_LOCATION.md    # Location justification
docs/prompts/DEEP_THINK_PROMPT_RQ010egh_DRAFT2.md
docs/prompts/DEEP_THINK_PROMPT_RQ010egh_DRAFT3.md
docs/prompts/DEEP_THINK_PROMPT_RQ010cdf_DRAFT1.md
docs/prompts/DEEP_THINK_PROMPT_RQ010cdf_DRAFT2.md
docs/prompts/DEEP_THINK_PROMPT_RQ010cdf_DRAFT3.md
```

### Updated Files
```
docs/CORE/index/RQ_INDEX.md        # Now 91 sub-RQs, includes RQ-010r-w + RQ-062
docs/CORE/AI_HANDOVER.md           # Session status
```

## Commands
```bash
git fetch origin claude/claude-md-instructions-RREJE
git checkout main
git merge origin/claude/claude-md-instructions-RREJE --no-ff -m "Merge Protocol 9 analysis + RQ-010r-w + RQ-062 from Claude session"
git push origin main
```

## Verification After Merge
- [ ] RQ_INDEX.md shows 91 sub-RQs
- [ ] Both `DEEP_THINK_RESPONSE_*_ANALYSIS.md` files exist in `docs/analysis/`
- [ ] RQ-062a-f visible in RQ_INDEX.md

## Note on Prompt Locations
Your prompts are in `docs/CORE/prompts/`. Claude's drafts are in `docs/prompts/`. Both should coexist — the CORE versions are production-ready, the drafts show evolution.
