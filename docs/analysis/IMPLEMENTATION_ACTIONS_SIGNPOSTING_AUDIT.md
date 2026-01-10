# IMPLEMENTATION_ACTIONS.md Signposting Audit

> **Date:** 10 January 2026
> **Purpose:** Identify gaps in core documentation that fail to reference IMPLEMENTATION_ACTIONS.md
> **Outcome:** Ensure no agent misses IA updates during session lifecycle

---

## Executive Summary

| Document | IA Referenced? | Gap Severity | Fix Required |
|----------|---------------|--------------|--------------|
| AI_AGENT_PROTOCOL.md (Entry) | ❌ NO | **HIGH** | Add to read list |
| AI_AGENT_PROTOCOL.md (Exit) | ❌ NO | **HIGH** | Add to Tier 1/1.5 |
| IMPACT_ANALYSIS.md (Header) | ❌ NO | **MEDIUM** | Add CASCADE ONLY warning |
| DEEP_THINK_PROMPT_GUIDANCE.md | ❌ NO | **MEDIUM** | Add Step 1.5 |
| CLAUDE.md | ✅ YES | — | None |
| RESEARCH_QUESTIONS.md | ✅ YES (implicit) | LOW | Optional clarification |

**Overall Assessment:** IMPLEMENTATION_ACTIONS.md is well-designed but **invisible to agents** during standard session workflows. This creates high risk of the same task-loss problem recurring.

---

## Detailed Findings

### 1. AI_AGENT_PROTOCOL.md — Session Entry Protocol

**Location:** Lines 15-45

**Current State:**
```
STEP 1: Context Acquisition (Read in order)
□ CLAUDE.md
□ AI_HANDOVER.md
□ index/CD_INDEX.md + index/PD_INDEX.md
□ index/RQ_INDEX.md
□ IMPACT_ANALYSIS.md — Actionable tasks + cascade tracking  ← INCORRECT DESCRIPTION
□ PRODUCT_DECISIONS.md
□ RESEARCH_QUESTIONS.md
□ GLOSSARY.md
□ AI_CONTEXT.md
□ ROADMAP.md
```

**Issues Identified:**
1. ❌ IMPLEMENTATION_ACTIONS.md is NOT in the read list
2. ❌ IMPACT_ANALYSIS.md is described as "Actionable tasks" — incorrect (it's cascade tracking only)

**Risk:** Agents entering a session will:
- Not know IMPLEMENTATION_ACTIONS.md exists
- Still think IMPACT_ANALYSIS.md is for task storage
- Repeat the task-loss pattern we just fixed

**Recommended Fix:**
```
STEP 1: Context Acquisition (Read in order)
□ CLAUDE.md — Project overview, constraints, routing
□ AI_HANDOVER.md — What did the last agent do?
□ index/CD_INDEX.md + index/PD_INDEX.md — Quick decision status lookup
□ index/RQ_INDEX.md — Quick research status lookup
□ IMPLEMENTATION_ACTIONS.md — Task quick status + navigation hub ← ADD
□ IMPACT_ANALYSIS.md — Cascade tracking ONLY (not task storage) ← FIX DESCRIPTION
□ PRODUCT_DECISIONS.md — Full details for PENDING decisions only
□ RESEARCH_QUESTIONS.md — Full details for ACTIVE research + Master Task Tracker ← ADD DETAIL
□ GLOSSARY.md — What do terms mean in this codebase?
□ AI_CONTEXT.md — What's the current architecture?
□ ROADMAP.md — What are the current priorities?
```

---

### 2. AI_AGENT_PROTOCOL.md — Session Exit Protocol

**Location:** Lines 55-91

**Current State:**
```
TIER 1: ALWAYS UPDATE (Non-negotiable)
□ AI_HANDOVER.md
□ PRODUCT_DECISIONS.md
□ RESEARCH_QUESTIONS.md
□ ROADMAP.md
□ IMPACT_ANALYSIS.md — Log cascade effects of any decisions made
□ index/*.md

TIER 1.5: IF EXTERNAL RESEARCH WAS PROCESSED
□ Protocol 9 was completed
□ Reconciliation document created
□ ACCEPT/MODIFY/REJECT/ESCALATE documented
```

**Issues Identified:**
1. ❌ IMPLEMENTATION_ACTIONS.md is NOT in any tier
2. ❌ No mention of updating IA when task status changes

**Risk:** Agents exiting a session will:
- Not update IA Quick Status when tasks move to IN_PROGRESS or COMPLETE
- Not log task additions in the Task Addition Log
- IA becomes stale, defeating its purpose

**Recommended Fix:**
Add to TIER 1.5:
```
TIER 1.5: IF TASKS WERE EXTRACTED OR STATUS CHANGED
□ IMPLEMENTATION_ACTIONS.md — Update Quick Status section
□ RESEARCH_QUESTIONS.md → Master Tracker — Update task status
```

Or add as explicit TIER 1 item:
```
TIER 1: ALWAYS UPDATE (Non-negotiable)
□ AI_HANDOVER.md — Summarize what you did, what remains
□ IMPLEMENTATION_ACTIONS.md — Update if tasks extracted or status changed ← ADD
□ PRODUCT_DECISIONS.md — Log any new decisions/questions
...
```

---

### 3. IMPACT_ANALYSIS.md — Header Section

**Location:** Lines 1-30

**Current State:**
```markdown
# IMPACT_ANALYSIS.md — Research-to-Roadmap Traceability

> **Purpose:** Track how research findings impact roadmap elements

## What This Document Is
This document ensures research findings **cascade through the entire system**. When research concludes:
1. Every roadmap item is evaluated for impact
2. New questions/research points are logged
3. Dependencies are updated
4. This document is updated

**Workflow:** Research completes → Impact analyzed here → Tasks extracted → Implementation begins
```

**Issues Identified:**
1. ❌ No explicit warning that tasks should NOT be stored here
2. ❌ Workflow line 30 says "Tasks extracted" but doesn't clarify WHERE they go
3. ❌ No cross-reference to IMPLEMENTATION_ACTIONS.md

**Risk:** The document still reads as if tasks belong here, perpetuating confusion.

**Recommended Fix:**
Add after header:
```markdown
---

## CRITICAL: Document Scope

⚠️ **CASCADE ANALYSIS ONLY** — This document tracks HOW research impacts the roadmap.

| Do | Don't |
|----|-------|
| Log cascade effects | Store task definitions |
| Reference tasks by ID (F-01, B-03) | Create task tables |
| Track dependencies | Track task status |

**Task Storage Locations:**
- **Task Definitions:** RESEARCH_QUESTIONS.md → Master Implementation Tracker
- **Task Quick Status:** IMPLEMENTATION_ACTIONS.md
- **Cascade Effects:** THIS DOCUMENT

**Workflow:** Research completes → Impact analyzed here → Tasks extracted to RESEARCH_QUESTIONS.md → Quick status updated in IMPLEMENTATION_ACTIONS.md
```

---

### 4. DEEP_THINK_PROMPT_GUIDANCE.md — Post-Response Processing

**Location:** Lines 261-300

**Current State:**
```
### Step 1: Extract Implementation Tasks (From ACCEPTED items only)
...
4. Add to Master Implementation Tracker in RESEARCH_QUESTIONS.md

### Step 2: Update Research Questions
...

### 5. Update Dependencies
...
3. Update IMPACT_ANALYSIS.md
```

**Issues Identified:**
1. ❌ No step to update IMPLEMENTATION_ACTIONS.md Quick Status section
2. ✅ Step 1 correctly points to RESEARCH_QUESTIONS.md (good)
3. ❌ Step 5 only mentions IMPACT_ANALYSIS.md, not IA

**Risk:** Agents processing external research will:
- Add tasks to Master Tracker ✅
- Update cascade effects ✅
- NOT update IA Quick Status ❌

**Recommended Fix:**
Add Step 1.5:
```
### Step 1.5: Update Implementation Actions Quick Status
```
After adding tasks to Master Tracker:
1. Update IMPLEMENTATION_ACTIONS.md → Quick Status Dashboard
2. Add entry to "Recently Added Tasks" section
3. Update "Task Addition Log" with date, source, phase, count
```
```

---

## Risk Assessment

### If Fixes Are Not Applied

| Scenario | Probability | Impact | Risk Level |
|----------|-------------|--------|------------|
| Agent doesn't know IA exists | HIGH | Task tracking fails | **CRITICAL** |
| Agent updates IMPACT_ANALYSIS.md with tasks | MEDIUM | Duplicates, confusion | **HIGH** |
| IA Quick Status becomes stale | HIGH | Dashboard useless | **MEDIUM** |
| Task Addition Log not maintained | MEDIUM | Audit trail lost | **LOW** |

### Expected Outcome After Fixes

| Scenario | Probability | Impact |
|----------|-------------|--------|
| Agent reads IA during session entry | HIGH | Awareness established |
| Agent updates IA during session exit | HIGH | Dashboard stays current |
| Tasks stored in correct location | HIGH | No more task loss |

---

## Reconciliation with Existing Architecture

### Current Architecture (Post-10 Jan Fixes)

```
                    ┌─────────────────────────────┐
                    │       CLAUDE.md             │
                    │   (Project Entry Point)     │
                    └─────────────┬───────────────┘
                                  │
                    ┌─────────────▼───────────────┐
                    │     AI_HANDOVER.md          │
                    │   (Session Context)         │
                    └─────────────┬───────────────┘
                                  │
         ┌────────────────────────┼────────────────────────┐
         │                        │                        │
┌────────▼────────┐    ┌─────────▼─────────┐    ┌────────▼────────┐
│  index/*.md     │    │ IMPLEMENTATION_   │    │ RESEARCH_       │
│ (Quick Lookup)  │    │ ACTIONS.md        │    │ QUESTIONS.md    │
└─────────────────┘    │ (Task Quick       │    │ (Master         │
                       │  Status + Nav)    │    │  Task Tracker)  │
                       └─────────┬─────────┘    └────────┬────────┘
                                 │                       │
                                 └───────────┬───────────┘
                                             │
                              ┌──────────────▼──────────────┐
                              │     IMPACT_ANALYSIS.md      │
                              │   (Cascade Effects ONLY)    │
                              └─────────────────────────────┘
```

### Gap in Current Signposting

The architecture is correct, but **AI_AGENT_PROTOCOL.md doesn't reflect it**:
- Session Entry Protocol doesn't include IA
- Session Exit Protocol doesn't include IA
- IMPACT_ANALYSIS.md header doesn't disclaim task storage

### Fix Strategy: Minimal Changes, Maximum Clarity

Rather than rewriting documents, apply surgical fixes:
1. Add 1 line to Session Entry Protocol
2. Add 1 line to Session Exit Protocol
3. Add 1 section to IMPACT_ANALYSIS.md header
4. Add 1 step to DEEP_THINK_PROMPT_GUIDANCE.md

Total changes: ~40 lines across 3 files.

---

## Recommendations

### P0 (Must Fix)

| Fix | Document | Effort |
|-----|----------|--------|
| Add IA to Session Entry Protocol | AI_AGENT_PROTOCOL.md | 2 lines |
| Add IA to Session Exit Protocol | AI_AGENT_PROTOCOL.md | 2 lines |
| Fix IMPACT_ANALYSIS.md description | AI_AGENT_PROTOCOL.md | 1 line |
| Add CASCADE ONLY warning | IMPACT_ANALYSIS.md | 15 lines |

### P1 (Should Fix)

| Fix | Document | Effort |
|-----|----------|--------|
| Add Step 1.5 to post-response | DEEP_THINK_PROMPT_GUIDANCE.md | 8 lines |

### P2 (Nice to Have)

| Fix | Document | Effort |
|-----|----------|--------|
| Add "Master Task Tracker" to RQ description | AI_AGENT_PROTOCOL.md | 3 words |

---

## Action Items

1. ✅ Apply P0 fixes to AI_AGENT_PROTOCOL.md — COMPLETE
2. ✅ Apply P0 fixes to IMPACT_ANALYSIS.md — COMPLETE
3. ✅ Apply P1 fixes to DEEP_THINK_PROMPT_GUIDANCE.md — COMPLETE (Step 1.5 added)
4. ✅ Update AI_HANDOVER.md with this audit — COMPLETE
5. ✅ Commit and push — COMPLETE

---

*This audit follows Protocol 1 (Research-to-Roadmap Cascade) principles.*
