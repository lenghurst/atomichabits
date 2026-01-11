# Deep Think Reconciliation: RQ-037, RQ-033, RQ-025

> **Source:** Gemini 2.0 Flash Thinking (Deep Think)
> **Date:** 10 January 2026
> **Reconciled By:** Claude (Opus 4.5)
> **Protocol:** 9 (External Research Reconciliation)

---

## Executive Summary

| Metric | Count |
|--------|-------|
| **Total Proposals** | 22 |
| **ACCEPT** | 14 |
| **MODIFY** | 5 |
| **REJECT** | 0 |
| **ESCALATE** | 3 |

**Overall Assessment:** HIGH QUALITY research output. All proposals compatible with locked CDs. Three items require human decision (terminology rebranding, new Weekly Review feature, IAP policy).

---

## Phase 1: Locked Decision Audit

### RQ-037 (Holy Trinity) Proposals

| Proposal | CD Check | Status |
|----------|----------|--------|
| Keep 3-trait model | ✅ Compatible with CD-015 (psyOS) | COMPATIBLE |
| Rebrand to "Shadow Cabinet" (Shadow, Saboteur, Script) | ✅ Aligns with CD-015 (Parliament of Selves) | COMPATIBLE — Escalate terminology |
| Narrative Triangulation extraction protocol | ✅ Uses DeepSeek V3.2 per CD-016 | COMPATIBLE |
| Cultural toggle for collectivist cultures | ✅ Extension of CD-005 | COMPATIBLE |
| Validation metrics (Resonance, Script Recognition, Retention Lift) | ✅ Aligns with CD-010 (user success) | COMPATIBLE |

### RQ-033 (Streak Philosophy) Proposals

| Proposal | CD Check | Status |
|----------|----------|--------|
| "Resilient Streak" with NMT (Never Miss Twice) | ✅ Aligns with CD-010 (no dark patterns) | COMPATIBLE |
| Archetype-specific UI based on Perfectionist dimension | ✅ Uses CD-005 (6-dimension model) | COMPATIBLE |
| Hide numbers for HIGH Perfectionists (>0.7) | ✅ Aligns with CD-010 (no shame) | COMPATIBLE |
| "Bank the Loss" — convert broken streaks to ICS | ✅ Compatible with existing ICS concept | COMPATIBLE |
| Freeze/Crack/Shatter visual metaphor | ✅ Android-first per CD-017 | COMPATIBLE |
| Recovery bonus (double XP for return) | ✅ Positive reinforcement per CD-010 | COMPATIBLE |

### RQ-025 (Summon Token) Proposals

| Proposal | CD Check | Status |
|----------|----------|--------|
| Rename to "Council Seals" | ✅ Aligns with CD-015 (Parliament metaphor) | COMPATIBLE |
| Balanced economy (1 token/week, cap 3) | ✅ Within $0.50/user/month budget | COMPATIBLE |
| Earn via Weekly Review (reflection) | ✅ Aligns with CD-010 (user growth) | COMPATIBLE |
| Do NOT reward streaks | ✅ Prevents grinding, per CD-010 | COMPATIBLE |
| Crisis bypass (free above 0.7 tension) | ✅ Never gate mental health per CD-010 | COMPATIBLE |
| No consumable IAP | ✅ Aligns with CD-010 (no dark patterns) | COMPATIBLE — Escalate policy |

### CD Conflict Summary

**No conflicts detected.** All proposals build on or extend confirmed decisions.

---

## Phase 2: Data Reality Audit

| Data Point | Android Status | Permission | Battery | Action |
|------------|----------------|------------|---------|--------|
| Perfectionist dimension score | ✅ Available | None (derived from Sherlock) | None | INCLUDE |
| Streak count | ✅ Available | None (app data) | None | INCLUDE |
| Graceful consistency score | ✅ Available | None (calculated) | None | INCLUDE |
| Weekly completion rate | ✅ Available | None (app data) | None | INCLUDE |
| Tension score | ✅ Available | None (calculated) | None | INCLUDE |
| Token balance | ✅ Will be stored | None (app data) | None | INCLUDE |

**All data points are Android-compatible with no new permissions required.**

---

## Phase 3: Implementation Reality Audit

### Existing Infrastructure

| Component | Status | Location |
|-----------|--------|----------|
| Holy Trinity fields | ✅ EXISTS | `identity_seeds` table |
| PsychometricProfile class | ✅ EXISTS | `lib/domain/entities/psychometric_profile.dart` |
| ConsistencyService | ✅ EXISTS | `lib/data/services/consistency_service.dart` |
| Graceful score calculation | ✅ EXISTS | `consistency_service.dart:29-31` |
| Archetype dimension scoring | 🔴 NOT IMPLEMENTED | Needs RQ-028 implementation |
| Token system | 🔴 NOT IMPLEMENTED | Needs new table + service |
| Weekly Review feature | 🔴 NOT IMPLEMENTED | New feature proposal |

### Schema Gaps

| Proposal Requires | Current State | Gap |
|-------------------|---------------|-----|
| Shadow/Saboteur/Script fields | `anti_identity_label`, `failure_archetype`, `resistance_lie_label` exist | Field rename only (cosmetic) |
| Perfectionist dimension score | Not in schema | Needs Phase A or calculate on-the-fly |
| Token balance table | Does not exist | Needs `user_tokens` migration |
| Token transaction log | Does not exist | Needs `token_transactions` migration |

---

## Phase 3.5: Schema Reality Check

```
TABLE EXISTENCE CHECK:

✅ identity_seeds — EXISTS (20260102_identity_seeds.sql)
   └── Holy Trinity fields present: anti_identity_label, failure_archetype, resistance_lie_label

❌ identity_facets — DOES NOT EXIST
   └── Not required for these RQs (Phase A blocker for other work)

❌ user_tokens — DOES NOT EXIST
   └── REQUIRED for RQ-025 implementation
   └── Action: Create migration

❌ token_transactions — DOES NOT EXIST
   └── REQUIRED for RQ-025 implementation
   └── Action: Create migration
```

**Blocker Identified:** Token economy (RQ-025) requires new database tables before implementation.

---

## Phase 4: Scope & Complexity Audit

### CD-018 Threshold Assessment

| Proposal | Rating | Justification |
|----------|--------|---------------|
| 3-trait Holy Trinity model | **ESSENTIAL** | Core personalization, already implemented |
| "Shadow Cabinet" branding | **VALUABLE** | Aligns with psyOS narrative |
| Narrative Triangulation extraction | **ESSENTIAL** | Improves onboarding quality |
| Resilient Streak (NMT) | **VALUABLE** | Significant UX improvement for perfectionists |
| Archetype-specific display | **VALUABLE** | Leverages CD-005 investment |
| Hide streak for perfectionists | **VALUABLE** | Reduces anxiety per CD-010 |
| "Bank the Loss" (ICS conversion) | **NICE-TO-HAVE** | Mitigates loss but adds complexity |
| Council Seals token system | **VALUABLE** | Enables proactive Council access |
| Weekly Review earning | **VALUABLE** | Connects doing to reflecting |
| Crisis bypass | **ESSENTIAL** | Never gate mental health support |
| Freeze/Crack/Shatter visuals | **NICE-TO-HAVE** | Polish, can simplify to text states |

### Scope Expansion Detection

| New Concept | In Original Prompt? | Assessment |
|-------------|---------------------|------------|
| "Shadow Cabinet" metaphor | No | ACCEPT — Better narrative fit |
| "Weekly Review" feature | No | ESCALATE — New feature, needs definition |
| "Bank the Loss" ICS | Mentioned | ACCEPT — Aligns with existing ICS concept |
| Freeze/Crack visual states | No | ACCEPT — Reasonable UX detail |

---

## Phase 5: ACCEPT / MODIFY / REJECT / ESCALATE

### ✅ ACCEPT (Integrate as-is) — 14 items

| # | Proposal | Rationale |
|---|----------|-----------|
| 1 | Keep 3-trait Holy Trinity model | Validated by research, already implemented |
| 2 | Traits map to Possible Selves, IFS Protectors, Neutralization Techniques | Strong theoretical grounding with citations |
| 3 | 5-minute extraction target with 4-turn protocol | Within CD-017 Android constraints |
| 4 | Validation metrics (Resonance 4.2+, Script Recognition 30%+, Retention +15%) | Measurable, actionable |
| 5 | Resilient Streak (NMT-based, resets on 2+ consecutive misses) | Aligns with existing NMT philosophy |
| 6 | Hide streak integers for Perfectionist > 0.7 | Reduces anxiety per CD-010 |
| 7 | Archetype-specific recovery messaging | Uses CD-005 dimensions |
| 8 | Balanced token economy (1/week earn, cap 3) | Within $0.20-0.50/month budget |
| 9 | Earn tokens via Weekly Review (reflection) | Incentivizes growth behavior |
| 10 | Do NOT reward streaks with tokens | Prevents grinding easy habits |
| 11 | Crisis bypass — free Council above 0.7 tension | Never gate mental health |
| 12 | 90-day simulation shows stable equilibrium | Economy modeling complete |
| 13 | Anti-gaming: require 50+ char reflection | Prevents trivial farming |
| 14 | Cultural toggle for collectivist contexts | Extensible without breaking |

### 🟡 MODIFY (Adjust for reality) — 5 items

| # | Proposal | Original | Adjusted | Rationale |
|---|----------|----------|----------|-----------|
| 1 | "Shadow Cabinet" naming | Rename DB fields | Keep existing field names, use display alias | DB migration is risky; use display layer translation |
| 2 | Extraction protocol pseudocode | DeepSeek context | Adapt for actual Sherlock implementation | Needs Dart translation |
| 3 | "Bank the Loss" | Full ICS integration | Simplify: Show "X days earned" message | Avoid over-engineering per CD-018 |
| 4 | Freeze/Crack/Shatter visuals | Complex animation | Start with text states: "Protected" / "At Risk" / "Reset" | Can add visuals later |
| 5 | Token transaction log | Full audit table | Start with balance + last_earned_at | Simpler schema first |

### 🔴 REJECT (Do not implement) — 0 items

No proposals rejected. All are compatible with locked decisions.

### ⚠️ ESCALATE (Human decision required) — 3 items

| # | Proposal | Conflicts With | Options | Recommendation |
|---|----------|----------------|---------|----------------|
| 1 | Adopt "Shadow Cabinet" terminology (Shadow, Saboteur, Script) | Terminology change affects docs, prompts, UI | A) Adopt fully B) Keep internal names, use display aliases C) Defer | **B — Display aliases.** Minimal risk, preserves consistency. |
| 2 | "Weekly Review" as primary token earning mechanism | New feature not in original scope | A) Implement as designed B) Use simpler "7-day consistency" earning C) Defer tokens entirely | **A or B — Human choice.** Weekly Review adds reflection value but requires new screen. |
| 3 | No consumable IAP policy | Business model decision | A) Free-only (recommended) B) Optional purchase C) Premium subscription bonus | **A — Free-only for MVP.** Revisit post-launch. |

---

## Phase 6: Integration & Task Extraction

### Tasks Extracted (via Protocol 8)

#### Phase A: Schema Foundation (Token System)

| ID | Task | Priority | Status | Source | Component |
|----|------|----------|--------|--------|-----------|
| A-11 | Create `user_tokens` table (balance, lifetime_earned, lifetime_spent) | HIGH | 🔴 NOT STARTED | RQ-025 | Database |
| A-12 | Create `token_transactions` table (amount, type, source, timestamp) | MEDIUM | 🔴 NOT STARTED | RQ-025 | Database |

#### Phase D: UX & Frontend (Streak Display)

| ID | Task | Priority | Status | Source | Component |
|----|------|----------|--------|--------|-----------|
| D-11 | Implement archetype-aware streak display (hide for Perfectionist > 0.7) | HIGH | 🔴 NOT STARTED | RQ-033 | Widget |
| D-12 | Implement Resilient Streak logic (reset only on 2+ consecutive misses) | HIGH | 🔴 NOT STARTED | RQ-033 | Service |
| D-13 | Create streak recovery messaging (Perfectionist vs Standard variants) | MEDIUM | 🔴 NOT STARTED | RQ-033 | Content |
| D-14 | Add "Protected" / "At Risk" / "Reset" streak state indicators | MEDIUM | 🔴 NOT STARTED | RQ-033 | Widget |

#### Phase E: Polish & Advanced (Token Economy)

| ID | Task | Priority | Status | Source | Component |
|----|------|----------|--------|--------|-----------|
| E-11 | Implement TokenService (earn, spend, balance check) | HIGH | 🔴 NOT STARTED | RQ-025 | Service |
| E-12 | Implement token earning for Weekly Review / 7-day consistency | HIGH | 🔴 NOT STARTED | RQ-025 | Service |
| E-13 | Create token balance UI widget (Council Seal icon + count) | MEDIUM | 🔴 NOT STARTED | RQ-025 | Widget |
| E-14 | Implement crisis bypass logic (free Council above 0.7 tension) | HIGH | 🔴 NOT STARTED | RQ-025 | Service |
| E-15 | Create token earning explanation tutorial (onboarding) | MEDIUM | 🔴 NOT STARTED | RQ-025 | Screen |

#### Phase B: Intelligence Layer (Extraction Improvement)

| ID | Task | Priority | Status | Source | Component |
|----|------|----------|--------|--------|-----------|
| B-16 | Implement Narrative Triangulation extraction protocol | HIGH | 🔴 NOT STARTED | RQ-037 | Onboarding |
| B-17 | Add extraction_quality_score to identity_seeds | MEDIUM | 🔴 NOT STARTED | RQ-037 | Database |
| B-18 | Create Day 3 Resonance Score check (profile accuracy rating) | MEDIUM | 🔴 NOT STARTED | RQ-037 | Service |

#### Phase G: Identity Coach Intelligence (Archetype Integration)

| ID | Task | Priority | Status | Source | Component |
|----|------|----------|--------|--------|-----------|
| G-15 | Calculate Perfectionist dimension from Saboteur archetype | HIGH | 🔴 NOT STARTED | RQ-033, RQ-037 | Service |
| G-16 | Store dimension scores for UI adaptation | MEDIUM | 🔴 NOT STARTED | RQ-033 | Database |

### Cross-RQ Integration Verified

| Integration | Source → Target | Status |
|-------------|-----------------|--------|
| Saboteur → Streak UI | RQ-037 → RQ-033 | ✅ Documented |
| Weekly Review → Token Earning | RQ-033 → RQ-025 | ✅ Documented |
| Shadow/Saboteur/Script → Council AI | RQ-037 → Council | ✅ Documented |

---

## Glossary Updates Required

| Term | Definition | Source |
|------|------------|--------|
| **Shadow Cabinet** | The psyOS term for the Holy Trinity traits — The Shadow (feared self), The Saboteur (maladaptive protector), The Script (habituated trigger) | RQ-037 |
| **The Shadow** | Display name for Anti-Identity — the feared possible self | RQ-037 |
| **The Saboteur** | Display name for Failure Archetype — the maladaptive protector pattern | RQ-037 |
| **The Script** | Display name for Resistance Lie — the habituated trigger phrase | RQ-037 |
| **Resilient Streak** | A streak that survives single-day misses but resets on 2+ consecutive misses (NMT-based) | RQ-033 |
| **Council Seal** | The token currency for manually summoning Council AI | RQ-025 |
| **Weekly Review** | A reflection activity that earns Council Seals | RQ-025 |
| **Crisis Bypass** | Automatic free Council access when tension_score > 0.7 | RQ-025 |
| **Narrative Triangulation** | The 4-turn extraction protocol: Hope → Fear → Mechanism → Trigger | RQ-037 |

---

## Confidence Assessment Summary

| Research Area | Confidence | Rationale |
|---------------|------------|-----------|
| Holy Trinity validation | **HIGH** | Strong citations (Markus, Oyserman, Schwartz, Sykes & Matza) |
| Extraction protocol (4 turns) | **HIGH** | Within time constraint, structured approach |
| Resilient Streak concept | **HIGH** | Aligns with Lally et al. (2010), existing NMT philosophy |
| Archetype-specific display | **HIGH** | Direct application of CD-005 |
| Token economy balance | **MEDIUM** | Simulation provided but needs production validation |
| Weekly Review as earning mechanism | **MEDIUM** | Good concept but new feature requiring design |
| Cultural toggle | **MEDIUM** | Research cited (Markus & Kitayama) but implementation unclear |

---

## Next Steps

1. **Human Decision Required:**
   - [ ] Approve "Shadow Cabinet" display terminology
   - [ ] Choose token earning mechanism (Weekly Review vs 7-day consistency)
   - [ ] Confirm no consumable IAP policy

2. **Implementation Order:**
   1. A-11, A-12: Token schema (unblocks E-* tasks)
   2. D-11, D-12: Resilient Streak logic
   3. B-16: Narrative Triangulation extraction
   4. E-11 through E-15: Token economy

3. **Governance Updates:**
   - [ ] Mark RQ-037, RQ-033, RQ-025 as ✅ COMPLETE
   - [ ] Update GLOSSARY.md with new terms
   - [ ] Add tasks to Master Implementation Tracker

---

*Reconciliation complete. Protocol 9 all phases executed.*
