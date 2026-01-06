# Gemini Merge Prompt — Branch to Main

> **Date:** 06 January 2026
> **Branch to Merge:** `claude/session-priming-docs-r6fCh`
> **Target:** `main`
> **Repository:** lenghurst/atomichabits

---

## Task

Merge the feature branch `claude/session-priming-docs-r6fCh` into `main` after verification.

---

## Pre-Merge Verification Checklist

Before merging, verify the following:

### 1. Documentation Integrity
- [ ] All files in `docs/CORE/` are valid markdown
- [ ] No broken internal links
- [ ] All index files (`docs/CORE/index/*.md`) reference existing items
- [ ] Archive files contain moved content (not duplicated)

### 2. File Organization (CD-014 Compliance)
- [ ] No new files added directly to `docs/CORE/` (only 11 governance files allowed)
- [ ] Deep Think prompts are in `docs/prompts/`
- [ ] Reconciliation documents are in `docs/analysis/`
- [ ] Index files are in `docs/CORE/index/`
- [ ] Archive files are in `docs/CORE/archive/`

### 3. Decision Consistency
- [ ] No contradictions between CDs (check PRODUCT_DECISIONS.md)
- [ ] Protocol 9 is properly referenced in AI_AGENT_PROTOCOL.md
- [ ] CD-017 (Android-First) and CD-018 (Engineering Threshold) are documented

### 4. Prompt Quality
- [ ] Deep Think prompts follow DEEP_THINK_PROMPT_GUIDANCE.md template
- [ ] All prompts include: Expert Role, Sub-Questions, Anti-Patterns, Output Format
- [ ] Protocol 9 reminder included for post-processing

---

## Changes in This Branch

### New Files Created
```
docs/prompts/
├── CLAUDE_SESSION_PRIMER.md                           ← Session priming for new agents
├── DEEP_THINK_PROMPT_IDENTITY_COACH_RQ005-RQ006-RQ007.md  ← Research prompt
└── DEEP_THINK_PROMPT_IDENTITY_SYSTEM_RQ013-RQ014-RQ015-PD117.md  ← (moved from docs/CORE/)

docs/analysis/
└── DEEP_THINK_RECONCILIATION_RQ014_RQ013_PD117_RQ015.md  ← Protocol 9 output
```

### Files Modified
```
docs/CORE/
├── AI_AGENT_PROTOCOL.md        ← Added Protocol 9, Tier 1.5 to Session Exit
├── PRODUCT_DECISIONS.md        ← Added CD-017, CD-018, updated CD-014
├── IMPACT_ANALYSIS.md          ← Added 06 Jan session impact analysis
├── README.md                   ← Added entry points for Protocol 9
├── DEEP_THINK_PROMPT_GUIDANCE.md  ← Added Step 0 (Protocol 9 trigger)
├── index/RQ_INDEX.md           ← Updated status for RQ-013,14,15
├── index/CD_INDEX.md           ← Added CD-017, CD-018
└── index/PD_INDEX.md           ← Updated PD-117 status
```

---

## Merge Commands

```bash
# 1. Fetch latest
git fetch origin main
git fetch origin claude/session-priming-docs-r6fCh

# 2. Checkout main and pull
git checkout main
git pull origin main

# 3. Merge feature branch (no fast-forward to preserve history)
git merge --no-ff claude/session-priming-docs-r6fCh -m "$(cat <<'EOF'
Merge branch 'claude/session-priming-docs-r6fCh' into main

## Summary
- Add Protocol 9 (External Research Reconciliation)
- Add CD-017 (Android-First Development Strategy)
- Add CD-018 (Engineering Threshold Framework)
- Implement documentation archiving strategy
- Create Deep Think prompt for RQ-005/006/007 (Identity Coach)
- Create Claude session priming prompt
- Complete impact analysis for session decisions

## Key Decisions Locked
- 4-state energy model (NOT 5-state)
- Android-first development (iOS secondary)
- ESSENTIAL/VALUABLE/NICE-TO-HAVE/OVER-ENGINEERED framework

## Files Changed
- 8 modified, 5 created
- New directories: docs/prompts/, docs/analysis/

## Next Steps
- Send Identity Coach prompt to Deep Think
- Implement database tasks (A-12, A-13)
- Implement service tasks (B-08 through B-13)
EOF
)"

# 4. Push to main
git push origin main

# 5. (Optional) Delete feature branch
git branch -d claude/session-priming-docs-r6fCh
git push origin --delete claude/session-priming-docs-r6fCh
```

---

## Post-Merge Verification

After merge, verify:

1. **Main branch has all changes:**
   ```bash
   git log main --oneline -10
   ```

2. **No file conflicts:**
   ```bash
   git status
   ```

3. **Documentation renders correctly:**
   - Check `docs/CORE/README.md` links work
   - Check index files reference correct items

---

## Rollback (If Needed)

If issues are found after merge:

```bash
# Find the merge commit
git log --oneline -5

# Revert the merge commit (replace MERGE_COMMIT_HASH)
git revert -m 1 MERGE_COMMIT_HASH
git push origin main
```

---

## Notes

- This branch contains **documentation only** — no code changes
- All changes are additive (no breaking changes)
- The branch follows the established governance framework
- Protocol 9 was applied to external research before integration

---

*Prompt generated: 06 January 2026*
