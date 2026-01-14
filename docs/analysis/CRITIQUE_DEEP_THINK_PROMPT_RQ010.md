# Critical Audit: RQ-010 Permission Philosophy Deep Think Prompt

> **Audit Date:** 14 January 2026
> **Auditor:** Claude (Opus 4.5)
> **Subject:** `docs/prompts/DEEP_THINK_PROMPT_RQ010_PERMISSION_PHILOSOPHY.md`
> **Purpose:** Ensure prompt meets DEEP_THINK_PROMPT_GUIDANCE.md quality standards
> **Goal:** Produce best-in-class Deep Think prompt

---

## Executive Summary

| Category | Gaps Found | Severity |
|----------|------------|----------|
| **Self-Containment** | 4 gaps | 🟡 MEDIUM |
| **Prompt Quality Characteristics** | 6 gaps | 🔴 HIGH |
| **Prompt Weaknesses to Avoid** | 7 violations | 🔴 HIGH |
| **Sub-RQ Template Compliance** | 1 CRITICAL violation | 🔴 CRITICAL |

**Overall Assessment:** The prompt is GOOD but not BEST-IN-CLASS. It has strong fundamentals (good structure, examples, anti-patterns) but violates key guidance principles, most critically: **all 8 sub-RQs in one prompt defeats decomposition purpose**.

**Verdict:** ❌ REVISE before sending to Deep Think

---

## PART 1: SELF-CONTAINMENT CHECKLIST AUDIT

### ✅ PASS: APP EXPLANATION

| Requirement | Status | Evidence |
|-------------|--------|----------|
| What type of app | ✅ | "mobile app (Flutter, Android-first)" |
| Who it's for | ⚠️ Weak | No explicit target user description |
| What problem it solves | ✅ | "helps users build identity-based habits" |
| How it's different | ⚠️ Weak | Competitors mentioned but differentiation unclear |

**Gap 1: Missing target user persona**

**Current:**
> "The Pact is a mobile app (Flutter, Android-first) that helps users build identity-based habits..."

**Better:**
> "The Pact is a mobile app for **adults (25-45) who struggle with habit consistency** — people who've tried habit trackers but failed because willpower-based approaches don't address the psychological root causes of inconsistency."

---

### 🟡 PARTIAL: PHILOSOPHY EXPLANATION

| Requirement | Status | Evidence |
|-------------|--------|----------|
| What is psyOS? | ❌ MISSING | Not mentioned in Part 1 |
| What is Parliament of Selves? | ❌ MISSING | Not mentioned |
| What are identity facets? | ❌ MISSING | Not mentioned |
| Why we treat users this way? | ❌ MISSING | JITAI focus, no philosophy |

**Gap 2: Core philosophy completely absent**

The prompt focuses on JITAI (a feature) without explaining the underlying philosophy. Deep Think has no idea why permission data matters to *identity-based* habits specifically.

**Missing section:**
```markdown
### Core Philosophy: "Parliament of Selves"

The Pact is built on **psyOS (Psychological Operating System)** — a framework that models human identity as:

1. **One Integrated Self** with multiple **facets** (not competing personalities)
2. **Facets** can be synergistic, antagonistic, or competitive
3. **Energy States** affect which facets can be active (4-state model: high_focus, high_physical, social, recovery)

This philosophy matters for permissions because:
- JITAI doesn't just suggest "do your habit" — it suggests "activate your Writer facet"
- Context data tells us WHICH facet is appropriate NOW
- Without context, we're just a generic habit reminder (the thing users already failed with)
```

---

### ⚠️ PARTIAL: TERMINOLOGY DEFINED

| Term | Defined Inline? | Status |
|------|-----------------|--------|
| JITAI | ✅ | "Just-In-Time Adaptive Intervention" |
| ContextSnapshot | ✅ | Dart code provided |
| psyOS | ❌ | Not mentioned |
| Identity facets | ❌ | Not mentioned |
| Parliament of Selves | ❌ | Not mentioned |
| CD-017 | ⚠️ Partial | Referenced but not explained |
| Energy states | ❌ | Not mentioned (though relevant to JITAI) |

**Gap 3: CD-017 referenced without explanation**

**Current:** Part 4 says `CD-017 | Android-first — all features must work without iOS/wearables`

**Problem:** Deep Think doesn't know what a "CD" is. The guidance explicitly says:
> ❌ "CD-015 mandates..." → Deep Think doesn't know what a "CD" is

**Better:**
> **Android-First Constraint:** All features must work on Android without iOS or wearable device integration. This is a locked product decision that cannot be changed.

---

### ✅ PASS: SCHEMAS/CODE INLINE

| Requirement | Status |
|-------------|--------|
| ContextSnapshot code | ✅ Full Dart class shown |
| Permission tables | ✅ Good tabular format |
| Comments explaining fields | ✅ Each field has permission requirement |

---

## PART 2: PROMPT QUALITY CHARACTERISTICS AUDIT

### 1. Rich Context

| Requirement | Status | Gap |
|-------------|--------|-----|
| **Prior Research Summary** | ❌ MISSING | No completed RQs summarized |
| **Locked Decisions** | ⚠️ Weak | Only CD-017 mentioned; CD-015 (energy model) highly relevant but absent |
| **Schema Examples** | ✅ | ContextSnapshot provided |
| **Current State** | ✅ | "Current State" gap clearly explained |

**Gap 4: No "Mandatory Context: Locked Architecture" section**

The guidance REQUIRES:
```markdown
## Mandatory Context: Locked Architecture

[Summarize all COMPLETE RQs and CONFIRMED CDs that constrain this research]

### RQ-XXX: [Title] ✅
- Key decision or finding

### CD-XXX: [Title] ✅
- Constraint this imposes
```

The RQ-010 prompt has NO section summarizing prior research. This is critical because:
- RQ-048c (Switching Costs) findings affect JITAI timing
- CD-015 (4-state energy model) constrains what contexts matter
- RQ-012 (Fractal Trinity) affects identity facet architecture

**Missing Relevant Locked Context:**
| Decision | Why It Matters for RQ-010 |
|----------|---------------------------|
| CD-015: 4-state energy model | JITAI needs to know user's energy state — affects what permissions are most valuable |
| CD-017: Android-first | Already mentioned but not explained |
| RQ-048c: Switching costs | Validated matrix affects JITAI timing decisions |
| RQ-013: Identity topology | Facet relationships affect which habits to suggest |

---

### 2. Structured Sub-Questions

| Requirement | Status |
|-------------|--------|
| Tabular format | ✅ |
| Explicit numbering | ✅ |
| Task clarity | ✅ |
| Tradeoff framing | ⚠️ Partial (some questions, not all) |

---

### 3. Constraints Section

| Requirement | Status |
|-------------|--------|
| Technical constraints | ✅ |
| UX constraints | ⚠️ Implied but not explicit |
| Resource constraints | ✅ (< 5% battery) |
| Anti-patterns section | ✅ |

---

### 4. Output Format Specification

| Requirement | Status | Gap |
|-------------|--------|-----|
| **Markdown structure** | ⚠️ Partial | No explicit header structure |
| **Code expectations** | ❌ MISSING | No pseudocode/algorithm request |
| **Confidence levels** | ❌ MISSING | Not explicitly requested |
| **Deliverables list** | ✅ | Good summary table |

**Gap 5: Confidence levels not requested**

The guidance requires:
> "Rate confidence HIGH/MEDIUM/LOW for each recommendation"

The RQ-010 prompt does NOT request this. This is critical for permission research because some recommendations will be based on industry data (HIGH confidence) vs inference (LOW confidence).

**Gap 6: No code/algorithm expectations**

For a prompt about JITAI architecture and degradation logic, the output should include:
- Pseudocode for degradation decision tree
- Algorithm for fallback selection
- State machine for permission-aware JITAI

---

## PART 3: PROMPT WEAKNESSES TO AVOID AUDIT

| Weakness | Present? | Evidence |
|----------|----------|----------|
| **No Expert Role** | ✅ Fixed | "Senior Mobile Privacy Architect" |
| **Missing Think-Chain** | ❌ VIOLATION | No "think step-by-step" instruction |
| **No Priority Sequence** | ❌ VIOLATION | 8 sub-RQs with no processing order |
| **No Examples** | ✅ Fixed | Good example in Part 7 |
| **No Anti-Patterns** | ✅ Fixed | Strong anti-patterns section |
| **No Confidence Levels** | ❌ VIOLATION | Not requested in output criteria |
| **Single Solution** | ❌ VIOLATION | No "2-3 options with tradeoffs" |
| **Weak Interdependencies** | ❌ VIOLATION | No RQ→RQ dependency diagram |
| **No User Scenarios** | ❌ VIOLATION | Abstract scenarios, no concrete user journey |
| **No Literature Guidance** | ❌ VIOLATION | No "cite papers" instruction |
| **No Validation Checklist** | ✅ Fixed | Good checklist in Part 9 |

---

### Gap 7: Missing Think-Chain Instruction

**Problem:** The prompt doesn't tell the model HOW to think.

**Add:**
> Your approach:
> 1. **Think step-by-step** through each permission's contribution
> 2. Model degradation **mathematically** (accuracy percentages, not vague "it gets worse")
> 3. Consider the **suspicious user** who grants NOTHING initially

---

### Gap 8: No Processing Order for 8 Sub-RQs

**Critical Problem:** The guidance requires:
> "## Critical Instruction: Processing Order"
> [If multiple RQs, show dependency chain with ASCII diagram]

The prompt has 8 sub-RQs (RQ-010a through RQ-010h) with NO processing order. This is problematic because:

- RQ-010a (Permission-to-Accuracy Mapping) must complete BEFORE RQ-010c (Degradation Scenarios)
- RQ-010g (Minimum Viable) depends on RQ-010c outputs
- RQ-010d (Progressive Permission) depends on RQ-010a rankings

**Required Dependency Chain:**
```
RQ-010a (Accuracy Mapping)
  ↓ Provides accuracy contribution percentages for...
RQ-010b (Fallback Strategies)
  ↓ Both feed into...
RQ-010c (Degradation Scenarios 20/40/60/80/100%)
  ↓ Enables determination of...
RQ-010g (Minimum Viable Permission Set)
  ↓ Determines which permissions to prioritize in...
RQ-010d (Progressive Permission Strategy)
  ↓ Implementation affects...
RQ-010f (Privacy-Value Transparency)

PARALLEL TRACK:
RQ-010e (JITAI Flexibility Architecture) ← Architectural decision
RQ-010h (Battery vs Accuracy) ← Cross-cutting concern
```

---

### Gap 9: No "2-3 Options with Tradeoffs" Instruction

**Problem:** The prompt asks for single recommendations, not options.

**Current (RQ-010e):**
> "**Recommendation:** Which architecture for The Pact's MVP?"

**Better:**
> "**Recommendation:** Present 2-3 architectural options (rigid/flexible/adaptive) with tradeoffs, then recommend one for MVP with rationale."

---

### Gap 10: No User Scenario Journey

**Problem:** The prompt has abstract percentage-based scenarios (20%, 40%, 60%) but no concrete user story.

**Missing:**
```markdown
### Concrete User Scenario: "Sarah the Skeptic"

Sarah is a 32-year-old who:
1. Downloaded The Pact because a friend recommended it
2. Denied Location and Health Connect during onboarding ("I don't trust apps with that")
3. Granted only Notifications and Calendar

**Walk through Sarah's first week:**
- Day 1: What does JITAI show her? What fails silently?
- Day 3: Sarah completes a habit at the gym. JITAI didn't know she was there. What happens?
- Day 7: Sarah opens the app. What does she see? Is she satisfied or frustrated?

**Use Sarah's journey to validate your degradation model.**
```

---

### Gap 11: No Literature Guidance

**Problem:** The guidance requires:
> "Cite 2-3 papers where applicable"

Permission-based degradation research exists:
- Google's permission grant rate studies
- iOS/Android permission psychology research
- JITAI effectiveness literature

**Add:**
> For each recommendation, cite relevant research where available:
> - Permission grant rate studies (Google, Apple research)
> - JITAI timing effectiveness literature
> - Privacy-utility tradeoff research

---

## PART 4: SUB-RQ TEMPLATE COMPLIANCE AUDIT

### 🔴 CRITICAL VIOLATION: All 8 Sub-RQs in One Prompt

The guidance explicitly states:
> ❌ Including all sub-RQs in one prompt (defeats decomposition purpose)

**Current Prompt:** Includes RQ-010a through RQ-010h ALL in one document.

**Problem:**
1. Output will be shallow (spreading attention across 8 topics)
2. No ability to iterate on individual sub-RQs
3. Defeats the purpose of Protocol 11 decomposition
4. Deep Think will produce 2-3 paragraphs per sub-RQ instead of 2-3 pages

**Recommendation Options:**

| Option | Pros | Cons |
|--------|------|------|
| **A: Split into 8 prompts** | Deepest research per topic | 8× round-trips, higher cost |
| **B: Group into 3 prompts** | Balance of depth and efficiency | Requires grouping logic |
| **C: Keep as 1 with explicit depth instruction** | Single round-trip | Risk of shallow outputs |

**Recommended:** **Option B** — Group into 3 prompts:

1. **Prompt 1: Foundation** (RQ-010a, RQ-010b)
   - Accuracy mapping + Fallback strategies
   - These are foundational — everything else depends on them

2. **Prompt 2: Scenarios & Minimum Viable** (RQ-010c, RQ-010g, RQ-010e)
   - Degradation modeling + Minimum viable + Architecture
   - These form the core decision framework

3. **Prompt 3: Strategy & UX** (RQ-010d, RQ-010f, RQ-010h)
   - Progressive permission + Privacy transparency + Battery
   - These are implementation/UX details

---

## PART 5: COMPLETE GAP SUMMARY

| # | Gap | Category | Severity | Fix |
|---|-----|----------|----------|-----|
| 1 | Missing target user persona | Self-Containment | 🟡 MEDIUM | Add "25-45 adults who struggle with consistency" |
| 2 | Core philosophy absent (psyOS, Parliament) | Self-Containment | 🔴 HIGH | Add full philosophy section |
| 3 | CD-017 not explained inline | Self-Containment | 🟡 MEDIUM | Replace "CD-017" with full explanation |
| 4 | No "Mandatory Context: Locked Architecture" | Rich Context | 🔴 HIGH | Add section with CD-015, RQ-048c |
| 5 | Confidence levels not requested | Output Format | 🔴 HIGH | Add "Rate HIGH/MEDIUM/LOW" |
| 6 | No code/algorithm expectations | Output Format | 🟡 MEDIUM | Add pseudocode request |
| 7 | Missing think-chain instruction | Think Quality | 🟡 MEDIUM | Add "think step-by-step" |
| 8 | No processing order for 8 sub-RQs | Structure | 🔴 HIGH | Add dependency diagram |
| 9 | No "2-3 options" instruction | Decision Quality | 🟡 MEDIUM | Add options requirement |
| 10 | No concrete user scenario journey | User-Centricity | 🔴 HIGH | Add "Sarah the Skeptic" |
| 11 | No literature citation guidance | Rigor | 🟡 MEDIUM | Add "cite research" |
| 12 | **All 8 sub-RQs in one prompt** | Structure | 🔴 CRITICAL | Split into 3 prompts |

---

## PART 6: STRUCTURAL ISSUES

### Current Structure vs Required Structure

**Current:**
```
PART 1: What is The Pact
PART 2: Android Permission Landscape
PART 3: Research Questions (ALL 8 in one)
PART 4: Constraints
PART 5: Anti-Patterns
PART 6: Output Quality
PART 7: Example
PART 8: Deliverables
PART 9: Checklist
PART 10: Integration Points
```

**Required (per guidance):**
```
## Your Role ← Has
## Critical Instruction: Processing Order ← MISSING
## Mandatory Context: Locked Architecture ← MISSING
## PART 1: What is The Pact ← Has (needs philosophy)
## PART 2: Background (Permission Landscape) ← Has
## Research Question [split per sub-RQ] ← VIOLATION (all in one)
  - Core Question
  - Why This Matters
  - The Problem
  - Current Hypothesis ← MISSING per sub-RQ
  - Sub-Questions
  - Anti-Patterns ← Has global, not per-RQ
  - Output Required
## Architectural Constraints ← Has
## Output Quality Criteria ← Has
## Example of Good Output ← Has
## Final Checklist ← Has
```

---

## PART 7: RECOMMENDED REVISIONS

### Immediate Fixes (Apply to Current Prompt)

1. **Add Processing Order section** with ASCII dependency diagram
2. **Add Mandatory Context section** with CD-015, RQ-048c summaries
3. **Add psyOS/Parliament of Selves explanation** to Part 1
4. **Add "Current Hypothesis" for each sub-RQ** — what do we currently believe?
5. **Add confidence level request** to each sub-RQ output
6. **Add concrete user scenario** ("Sarah the Skeptic")
7. **Add literature citation instruction**
8. **Add "2-3 options with tradeoffs" instruction** for architectural questions
9. **Remove CD-017 reference** — explain constraint inline
10. **Add code/algorithm expectations** — request decision tree pseudocode

### Structural Fix (Split into 3 Prompts)

**Prompt 1:** `DEEP_THINK_PROMPT_RQ010ab_PERMISSION_FOUNDATION.md`
- RQ-010a (Accuracy Mapping)
- RQ-010b (Fallback Strategies)
- 5-8 pages expected output

**Prompt 2:** `DEEP_THINK_PROMPT_RQ010ceg_DEGRADATION_ARCHITECTURE.md`
- RQ-010c (Degradation Scenarios)
- RQ-010e (JITAI Architecture)
- RQ-010g (Minimum Viable)
- 8-12 pages expected output

**Prompt 3:** `DEEP_THINK_PROMPT_RQ010dfh_STRATEGY_UX.md`
- RQ-010d (Progressive Permission)
- RQ-010f (Privacy-Value Transparency)
- RQ-010h (Battery vs Accuracy)
- 5-8 pages expected output

---

## Revision History

| Date | Author | Changes |
|------|--------|---------|
| 14 Jan 2026 | Claude (Opus 4.5) | Initial critical audit |

---

*This critique follows DEEP_THINK_PROMPT_GUIDANCE.md quality standards.*
