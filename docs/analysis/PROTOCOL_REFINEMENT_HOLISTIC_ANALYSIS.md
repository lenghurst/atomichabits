# Protocol Refinement — Holistic Analysis & Recommendations

> **Date:** 11 January 2026
> **Trigger:** Audit identified 5 challenges + 3 gaps + cognitive load concern
> **Method:** Protocol 10 (Bias Analysis) applied to own recommendations

---

## Part 1: Protocol 10 Self-Application — Cognitive Load Finding

### 1.1 The Finding Under Analysis

> "Cognitive Science: ⚠️ 12 protocols approaching working memory limits"

### 1.2 Bias Analysis of This Finding

| # | Assumption | Validity | Basis |
|---|------------|----------|-------|
| 1 | Working memory limit is 7±2 items | HIGH | Miller (1956) well-established cognitive psychology |
| 2 | AI agents are subject to same limits as humans | LOW | AI agents can re-read protocols; no true "working memory" |
| 3 | Protocol count = cognitive items | MEDIUM | Protocols are chunked hierarchically (Tiers reduce load) |
| 4 | 12 is "approaching" the limit | MEDIUM | Depends on how agents process (sequential vs parallel) |
| 5 | More protocols = worse outcomes | LOW | Quality > quantity; unused protocols have zero load |

**LOW-Validity Count:** 2 (Assumptions #2 and #5)
**Decision:** PROCEED with MEDIUM confidence — finding is useful but not critical

### 1.3 Revised Assessment

The cognitive load concern is **VALID for human readers** but **LESS VALID for AI agents** because:
1. AI agents can re-read AI_AGENT_PROTOCOL.md during session
2. Session Exit Protocol uses Tiers (chunking reduces cognitive load)
3. Protocols 10-12 are situational (not always triggered)

**However:** The concern has merit for **protocol maintainability** — as protocols grow, inconsistencies become harder to detect.

### 1.4 PD/RQ Determination

| Criterion | Assessment |
|-----------|------------|
| Immediate blocker? | NO — 12 protocols is workable |
| Affects product direction? | NO — internal process, not user-facing |
| Requires research? | PARTIAL — could benefit from tracking |
| Has implementation impact? | YES — future protocol additions should consolidate |

**Recommendation:** Create **PD-125** (Protocol Governance) as a PENDING decision, not an RQ.

**Rationale:** This is a governance/process question, not a research question. No external SME input needed — it's an internal design choice about when to consolidate.

---

## Part 2: Holistic Analysis of 5 Challenges

### Challenge Matrix

| Challenge | Root Cause | Impact if Unaddressed | Reversibility |
|-----------|------------|----------------------|---------------|
| 1. "4+ LOW" threshold | Absolute vs relative counting | Low-assumption recommendations escape scrutiny | EASY |
| 2. Sub-RQ independence | Idealistic requirement | Agents confused when dependencies exist | EASY |
| 3. Tier 3 no enforcement | Manual-only process | Verification skipped under time pressure | MEDIUM |
| 4. Protocol 10 broad trigger | Conservative scoping | Over-triggering → analysis fatigue | EASY |
| 5. DEFERRED vs PENDING subtle | Semantic overlap | Status misuse → tracking errors | EASY |

### 2.1 Challenge 1: "4+ LOW" Threshold Analysis

**Current Rule:** If 4+ LOW-validity assumptions → DEFER

**Problem Scenario:**
```
Recommendation A: 2 assumptions, both LOW (100% unvalidated)
Current Rule: 2 < 4 → Proceed with MEDIUM confidence ❌

Recommendation B: 10 assumptions, 4 LOW (40% unvalidated)
Current Rule: 4 ≥ 4 → DEFER ✅
```

**This is backwards.** Recommendation A (100% LOW) should be MORE concerning than B (40% LOW).

**Root Cause:** Absolute count ignores proportion.

**Solution Options:**

| Option | Rule | Pros | Cons |
|--------|------|------|------|
| A | Add ">50% LOW" clause | Simple percentage | Requires assumption count |
| B | Add minimum assumption requirement | Forces thorough analysis | Arbitrary threshold |
| C | Hybrid: MAX(4+ LOW, >50% LOW) | Catches both scenarios | More complex rule |
| D | Sliding scale by assumption count | Most accurate | Hardest to remember |

**Recommendation: Option C (Hybrid)**

New rule:
```
DEFER if ANY of:
- 4+ LOW-validity assumptions, OR
- >50% of assumptions rate LOW (minimum 3 assumptions required)
```

**Why:** Catches both high-count and high-proportion scenarios. Minimum of 3 assumptions ensures agents don't game with "1 assumption, 0 LOW."

### 2.2 Challenge 2: Sub-RQ Independence

**Current Rule:** "Independence from sibling sub-RQs (can be researched in any order)"

**Reality Check (RQ-039):**
```
RQ-039a: Earning mechanism & intrinsic motivation
    ↓ feeds into
RQ-039f: Premium token allocation (needs to know base earning first)

RQ-039e: Crisis bypass threshold validation
    ↓ depends on
RQ-039a: Understanding earning creates context for "bypassing"
```

**Root Cause:** Sub-RQs often have **soft dependencies** (not blockers, but better together).

**Solution:**

Change Protocol 11 Step 2 from:
> "Independence from sibling sub-RQs (can be researched in any order)"

To:
> "Independence from sibling sub-RQs where possible. If dependencies exist, document them with ↓ notation and note which sub-RQs benefit from sequencing."

**Add Dependency Documentation Section:**
```markdown
### Sub-RQ Dependencies (if any)

| Sub-RQ | Depends On | Nature |
|--------|------------|--------|
| 039f | 039a | Soft — premium builds on base earning |
| 039e | 039a | Soft — crisis bypass context |

**Research Order Recommendation:** 039a → (039b, 039c, 039d, 039e parallel) → 039f → 039g
```

### 2.3 Challenge 3: Tier 3 No Enforcement

**Current State:** Cross-File Consistency Checklist is documentation-enforced only.

**Risk:** Under time pressure, agents skip verification and commit inconsistent docs.

**Solution Options:**

| Option | Implementation | Effectiveness | Effort |
|--------|----------------|---------------|--------|
| A | Pre-commit git hook | HIGH — blocks commit | HIGH — requires scripting |
| B | AI Handover mandatory field | MEDIUM — creates audit trail | LOW — doc change only |
| C | Protocol 10-style documentation | MEDIUM — requires output | LOW — doc change only |
| D | Post-commit audit by next agent | LOW — reactive not proactive | ZERO — already possible |

**Recommendation: Option B (Immediate) + Option A (Future)**

**Immediate (This Session):**
Add to AI_HANDOVER.md Session Summary template:
```markdown
| **Tier 3 Verification** | ✅ Complete / ⚠️ Partial / ❌ Skipped |
| **Mismatches Found** | [List or "None"] |
```

This creates an audit trail without blocking commits.

**Future (Medium-Term):**
Create pre-commit verification script. Track as **Task G-07** in IMPLEMENTATION_ACTIONS.md.

### 2.4 Challenge 4: Protocol 10 Broad Trigger

**Current Trigger:** "Before finalizing any recommendation that affects product direction, monetization, core UX, or multi-stakeholder architecture."

**Problem:** Almost every meaningful recommendation affects one of these → over-triggering.

**Over-Triggering Consequences:**
1. **Analysis fatigue** — agents treat it as checkbox exercise
2. **Time overhead** — bias analysis takes 10-15 minutes per recommendation
3. **Diminishing returns** — minor recommendations get same scrutiny as major

**Solution:**

Add scoping criteria to Protocol 10 trigger:

```
TRIGGER: Before finalizing any recommendation that affects product direction,
monetization, core UX, or multi-stakeholder architecture AND meets ONE of:
- Affects 3+ stakeholder groups (users, business, engineering, etc.)
- Reversibility cost is HIGH (schema changes, API contracts, user-facing terminology)
- Implementation effort is >5 tasks
- Recommendation was contested or had multiple options
```

**Quick Filter:**
```
┌─────────────────────────────────────────────────────────────────────┐
│  PROTOCOL 10 TRIGGER QUICK FILTER                                   │
│                                                                     │
│  Does this recommendation:                                          │
│  □ Affect 3+ stakeholder groups?                                    │
│  □ Have HIGH reversibility cost?                                    │
│  □ Require >5 implementation tasks?                                 │
│  □ Have contested alternatives?                                     │
│                                                                     │
│  If YES to ANY → Run Protocol 10                                    │
│  If NO to ALL → Skip Protocol 10, proceed with standard confidence  │
└─────────────────────────────────────────────────────────────────────┘
```

### 2.5 Challenge 5: DEFERRED vs PENDING Distinction

**Current Definitions:**
- **PENDING:** Awaiting research or decision (research not yet done)
- **DEFERRED:** Deliberately delayed pending new research (chose not to decide)

**Confusion Scenario:**
> PD-119 was PENDING (waiting for RQ-025). RQ-025 completed. Now PD-119 could be decided, but we CHOSE to defer due to bias analysis. Is it PENDING (waiting for RQ-039) or DEFERRED (chose not to)?

**Answer:** DEFERRED — because we actively chose to wait after having enough info to decide.

**Root Cause:** The distinction is about **agency**, not **state**:
- PENDING = passive waiting (can't decide yet)
- DEFERRED = active choice (could decide, chose not to)

**Solution:**

Add Decision Tree to Protocol 12:

```
┌─────────────────────────────────────────────────────────────────────┐
│  PENDING vs DEFERRED DECISION TREE                                  │
│                                                                     │
│  Do you have enough information to make a decision?                 │
│                                                                     │
│  NO ──────────────────────────────────────────────────→ PENDING     │
│  │   (Research not complete, dependencies unresolved)               │
│  │                                                                  │
│  YES → Did you actively CHOOSE not to decide?                       │
│        │                                                            │
│        NO ────────────────────────────────────────────→ READY       │
│        │   (Decision can be made; waiting for human input)          │
│        │                                                            │
│        YES → Is there new research created to unblock?              │
│              │                                                      │
│              NO ──────────────────────────────────────→ ERROR       │
│              │   (Cannot defer without unblocking path)             │
│              │                                                      │
│              YES ─────────────────────────────────────→ DEFERRED    │
│                   (Deliberately delayed; RQ created)                │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Part 3: Addressing Remaining Gaps

### Gap G-02: Sub-RQ Prompt Template (MEDIUM)

**Current State:** DEEP_THINK_PROMPT_GUIDANCE.md has template for top-level RQs but not sub-RQs.

**Why Sub-RQs Need Different Template:**
1. **Narrower scope** — single SME domain focus
2. **Parent context** — must reference parent RQ decisions
3. **Sibling awareness** — should note what other sub-RQs cover
4. **Deliverable specificity** — concrete output expected

**Solution:** Add Sub-RQ Template section to DEEP_THINK_PROMPT_GUIDANCE.md

### Gap G-03: IMPACT_ANALYSIS Cascade (LOW)

**Current State:** Protocols 10-12 addition has no cascade entry in IMPACT_ANALYSIS.md.

**Why It Matters:** Future agents won't know what downstream effects the protocol changes had.

**Solution:** Add cascade entry to IMPACT_ANALYSIS.md

### Gap G-07: Automated Cross-File Verification (MEDIUM)

**Current State:** Manual checklist only.

**Future Solution:** Create bash script that:
1. Extracts RQ count from RQ_INDEX.md
2. Compares to PRODUCT_DEV_SHEET, AI_CONTEXT, ROADMAP
3. Reports mismatches
4. Could be integrated as pre-commit hook

**Track as Task:** Add to IMPLEMENTATION_ACTIONS.md as future engineering task.

---

## Part 4: Holistic Recommendation Summary

### Immediate Actions (This Session)

| Action | File | Priority |
|--------|------|----------|
| 1. Refine Protocol 10 threshold | AI_AGENT_PROTOCOL.md | HIGH |
| 2. Refine Protocol 10 trigger scope | AI_AGENT_PROTOCOL.md | HIGH |
| 3. Soften Protocol 11 independence requirement | AI_AGENT_PROTOCOL.md | MEDIUM |
| 4. Add PENDING vs DEFERRED decision tree to Protocol 12 | AI_AGENT_PROTOCOL.md | MEDIUM |
| 5. Add Tier 3 verification field to AI_HANDOVER template | AI_HANDOVER.md | MEDIUM |
| 6. Add Sub-RQ prompt template | DEEP_THINK_PROMPT_GUIDANCE.md | MEDIUM |
| 7. Create PD-125 (Protocol Governance) | PD_INDEX.md, PRODUCT_DECISIONS.md | LOW |

### Future Actions (Track for Later)

| Action | Where to Track | Priority |
|--------|----------------|----------|
| Create cross-file verification script | IMPLEMENTATION_ACTIONS.md | MEDIUM |
| Add Protocol 10-12 cascade to IMPACT_ANALYSIS | This session or next | LOW |
| Protocol consolidation review at 15 protocols | PD-125 trigger | LOW |

---

## Part 5: Protocol 10 Self-Check on These Recommendations

### Assumptions in This Analysis

| # | Assumption | Validity | Basis |
|---|------------|----------|-------|
| 1 | Hybrid threshold (4+ OR >50%) is better | MEDIUM | Addresses both scenarios; untested |
| 2 | "Where possible" softening is sufficient | HIGH | Common documentation pattern |
| 3 | AI_HANDOVER field creates accountability | MEDIUM | Audit trail helps but doesn't prevent |
| 4 | Quick Filter reduces over-triggering | MEDIUM | Adds criteria but still subjective |
| 5 | Decision tree clarifies DEFERRED vs PENDING | HIGH | Visual decision trees proven effective |
| 6 | PD-125 is better than RQ | HIGH | Process question, not research question |

**LOW-Validity Count:** 0
**MEDIUM-Validity Count:** 4
**HIGH-Validity Count:** 2

**Decision:** PROCEED with MEDIUM confidence — refinements are low-risk improvements

---

## Part 6: Final Recommendation

**DO implement all 7 immediate actions** because:
1. All are documentation changes (low risk, easy to revert)
2. Address real issues identified in audit
3. Follow the principle of "fix it when you see it"
4. Create better foundation for future protocol additions

**DO create PD-125** because:
1. Cognitive load concern is valid for maintainability
2. Creates governance checkpoint for future
3. Doesn't require immediate action (PENDING status)

**DO NOT create RQ** because:
1. This is internal process, not product research
2. No external SME input needed
3. PD-125 is sufficient tracking mechanism

---

*Analysis complete. Ready for implementation.*

