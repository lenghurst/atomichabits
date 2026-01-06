# Documentation Governance Analysis — Root Cause Investigation

> **Date:** 06 January 2026
> **Author:** Claude (Opus 4.5)
> **Purpose:** Critical analysis of why documentation gaps occur and structural recommendations to prevent them
> **Triggered By:** Observation of duplicates, missing task extractions, and orphaned PDs

---

## Executive Summary

The CORE documentation system has strong **content** but weak **process enforcement**. Protocols exist but lack verification gates. This analysis identifies three categories of failure and proposes structural fixes.

### Observed Failures

| Category | Example | Frequency |
|----------|---------|-----------|
| **Duplicates** | Treaties table in RQ-016 AND RQ-021/RQ-022 | HIGH |
| **Missing Extractions** | RQ-019, RQ-020 marked COMPLETE but no tasks extracted | HIGH |
| **Orphaned PDs** | PD-118, PD-119, PD-120 have no implementation tasks | MEDIUM |

---

## Part 1: Root Cause Analysis

### 1.1 Why Duplicates Occur

**Observed Pattern:**
- RQ-016 (Council AI) created "Create treaties table" task
- RQ-021/RQ-022 (Treaty Lifecycle) also specified treaty table details
- Both were logged as separate tasks without cross-reference

**Root Causes:**

| Cause | Description | Evidence |
|-------|-------------|----------|
| **No Deduplication Gate** | No protocol requires checking existing tasks before creating new | AI_AGENT_PROTOCOL.md had no deduplication protocol (until now) |
| **RQ Isolation** | Each RQ treated as standalone, not as extension | RQ-021/RQ-022 didn't reference RQ-016's existing tasks |
| **Task Scattered Storage** | Tasks were embedded within individual RQ entries | No single searchable task list existed |
| **Extension vs New Ambiguity** | No criteria for when to UPDATE vs CREATE | Agents default to CREATE because it's simpler |

**Structural Gap:**
```
CURRENT FLOW:
RQ completes → Agent creates tasks → Tasks added to RQ entry
                                   ↳ No cross-reference check

SHOULD BE:
RQ completes → Agent searches Master Tracker → If similar exists: MERGE
                                              → If new: CREATE with source link
```

### 1.2 Why Task Extractions Are Missing

**Observed Pattern:**
- RQ-019 (pgvector Implementation) marked ✅ COMPLETE
- RQ-020 (Treaty-JITAI Integration) marked ✅ COMPLETE
- Neither had implementation tasks extracted to Master Tracker

**Root Causes:**

| Cause | Description | Evidence |
|-------|-------------|----------|
| **No Extraction Mandate** | Completing RQ doesn't require task extraction | Session Exit Protocol doesn't include task extraction step |
| **COMPLETE ≠ ACTIONED** | Status tracks research state, not implementation state | RQ status field only has: NEEDS RESEARCH / IN PROGRESS / COMPLETE |
| **Implicit Task Existence** | Research contains tasks but they're not explicitly extracted | RQ-019 has SQL/Dart code = implicit tasks |
| **Session Boundary Loss** | Tasks identified in one session not carried forward | AI_HANDOVER captures "what was done" not "what tasks remain" |

**Structural Gap:**
```
CURRENT RQ STATUS:
🔴 NEEDS RESEARCH → 🟡 IN PROGRESS → ✅ COMPLETE

MISSING STATE:
✅ COMPLETE (research done) → ✅ ACTIONED (tasks extracted)

Without ACTIONED status, "complete" research sits without implementation tracking.
```

### 1.3 Why PDs Have No Tasks

**Observed Pattern:**
- PD-118 (Treaty Modification UX) created 05 Jan 2026
- PD-119 (Summon Token Economy) created 05 Jan 2026
- PD-120 (Chamber Visual Design) created 05 Jan 2026
- None have implementation tasks in Master Tracker

**Root Causes:**

| Cause | Description | Evidence |
|-------|-------------|----------|
| **PD = Decision, Not Task** | PDs capture WHAT decision, not HOW to implement | PD format doesn't include implementation checklist |
| **PENDING Status Paralysis** | PENDING PDs assumed to have no tasks | But even pending decisions have preliminary tasks |
| **No PD→Task Protocol** | AI_AGENT_PROTOCOL doesn't mandate PD task extraction | Session Exit only mentions "log decisions" not "extract tasks" |
| **Research Dependency Assumed** | PD depends on RQ, so tasks will come from RQ | But RQ may never specify implementation details |

**Structural Gap:**
```
CURRENT PD STRUCTURE:
- Question
- Status (PENDING/RESOLVED)
- Options
- Decision

MISSING:
- Implementation Checklist (even if preliminary)
- Blocking Tasks
- Downstream Tasks
```

---

## Part 2: Structural Analysis of CORE Documentation

### 2.1 Current Document Relationships

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        CURRENT DOCUMENT HIERARCHY                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  README.md ─────────────────────────────────────────────────────────────┐   │
│       │                                                                  │   │
│       ▼                                                                  │   │
│  AI_HANDOVER.md ───── What last agent did ───────────────────────────────┼───│
│       │                                                                  │   │
│       ▼                                                                  │   │
│  PRODUCT_DECISIONS.md ───── Philosophy (CDs/PDs) ────────────────────────┼───│
│       │                         │                                        │   │
│       │                         ▼                                        │   │
│       │           RESEARCH_QUESTIONS.md ───── Research (RQs) ────────────┼───│
│       │                         │                                        │   │
│       │                         │ ❌ WEAK LINK                           │   │
│       │                         │    Tasks scattered within RQs          │   │
│       │                         │    No Master Tracker (was)             │   │
│       │                         ▼                                        │   │
│       │           ROADMAP.md ───── Priorities ───────────────────────────┼───│
│       │                                                                  │   │
│       ▼                                                                  │   │
│  AI_CONTEXT.md ───── Technical Truth ────────────────────────────────────┘   │
│                                                                             │
│  ❌ MISSING: Clear task extraction flow from RQ/PD to Master Tracker        │
│  ❌ MISSING: Deduplication gate                                             │
│  ❌ MISSING: ACTIONED status for completed research                         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Protocol Gaps

| Protocol | What It Covers | What It Misses |
|----------|---------------|----------------|
| **Session Entry** | Read docs for context | No verification of task extraction state |
| **Session Exit** | Update handover, log decisions | No mandatory task extraction step |
| **Research Trigger** | When to propose RQ | No requirement to specify expected tasks |
| **Decision Flow** | Classification, dependency, impact | No task generation requirement |
| **Research-to-Roadmap** | Impact tracing | No explicit task creation mandate |
| **Clean Code** | Refactoring after implementation | Not relevant to documentation |

**Key Missing Protocol:**
```
MISSING: Task Lifecycle Protocol

Trigger: RQ marked COMPLETE or PD marked RESOLVED
Action:
1. EXTRACT all implementation tasks from research output
2. SEARCH Master Tracker for existing similar tasks
3. For each task:
   - IF exists → MERGE (update existing)
   - IF new → CREATE with source linkage
4. UPDATE RQ/PD status to ACTIONED
5. VERIFY task count matches expected deliverables
```

### 2.3 Status Field Gaps

**Current RQ Status Options:**
- 🔴 NEEDS RESEARCH
- 🟡 IN PROGRESS
- ✅ COMPLETE

**Missing:**
- ✅ ACTIONED (tasks extracted and tracked)

**Current PD Status Options:**
- 🔴 PENDING
- 🟡 RESHAPED (partially resolved)
- ✅ RESOLVED

**Missing:**
- ✅ IMPLEMENTED (all tasks completed)

**Why This Matters:**
Without ACTIONED/IMPLEMENTED status, there's no way to verify that completed research has been converted to tracked work. An RQ can be ✅ COMPLETE but have zero tasks in the tracker.

---

## Part 3: Verification Failures

### 3.1 No Automated Checks

The documentation system relies entirely on AI agent discipline. There are no automated checks for:

| Check | Current State | Risk |
|-------|--------------|------|
| Duplicate task detection | Manual only | Duplicates created silently |
| Task count verification | None | Research completes with zero tasks |
| Cross-reference validation | None | Tasks may reference non-existent RQs |
| Status consistency | None | RQ COMPLETE but tasks NOT STARTED = confusion |
| Orphan detection | None | PDs created without task linkage |

### 3.2 Agent Memory Limitations

AI agents work within context windows. Without explicit protocols:

| Limitation | Impact |
|------------|--------|
| Can't see previous sessions' full output | May recreate tasks that exist |
| Can't search across all docs simultaneously | Miss duplicates |
| Don't remember task IDs from earlier in session | Use inconsistent IDs |
| No persistent task database | Rely on markdown parsing |

---

## Part 4: Recommendations

### 4.1 Immediate Fixes (This Session)

| Fix | Location | Status |
|-----|----------|--------|
| Add Protocol 7 (Deep Think Quality) | AI_AGENT_PROTOCOL.md | ✅ DONE |
| Add Protocol 8 (Task Extraction & Deduplication) | AI_AGENT_PROTOCOL.md | ✅ DONE |
| Create Master Implementation Tracker | RESEARCH_QUESTIONS.md | ✅ DONE |
| Create DEEP_THINK_PROMPT_GUIDANCE.md | docs/CORE/ | ✅ DONE |

### 4.2 Structural Fixes (Future Session)

| Fix | Description | Priority |
|-----|-------------|----------|
| **Add ACTIONED Status** | New RQ status after task extraction | HIGH |
| **Add IMPLEMENTED Status** | New PD status after tasks complete | HIGH |
| **Mandate PD Implementation Checklist** | Even PENDING PDs must list expected tasks | HIGH |
| **Task Extraction Verification** | Protocol requires task count check | MEDIUM |
| **Weekly Governance Audit** | Human reviews task-to-RQ alignment | MEDIUM |

### 4.3 Process Fixes

**New Mandatory Flow:**
```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    PROPOSED: TASK LIFECYCLE PROTOCOL                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. RQ/PD CREATED                                                           │
│     └── Must include: "Expected Deliverables" count                         │
│                                                                             │
│  2. RESEARCH COMPLETES (RQ) or DECISION RESOLVED (PD)                       │
│     └── Agent MUST extract tasks:                                           │
│         a. List all actionable items from output                            │
│         b. Search Master Tracker for duplicates                             │
│         c. For each item:                                                   │
│            - EXISTS → Update existing task with new details                 │
│            - NEW → Create task with ID, source, priority                    │
│                                                                             │
│  3. EXTRACTION VERIFICATION                                                 │
│     └── Task count >= Expected Deliverables?                                │
│         - YES → Mark RQ/PD as ACTIONED                                      │
│         - NO → Flag as "Missing Tasks" for human review                     │
│                                                                             │
│  4. IMPLEMENTATION TRACKING                                                 │
│     └── As tasks complete → Update status in Master Tracker                 │
│     └── When ALL tasks ✅ → Mark RQ/PD as IMPLEMENTED                        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.4 Template Updates

**Proposed RQ Template Addition:**
```markdown
| Field | Value |
|-------|-------|
| **Expected Deliverables** | [Number] — e.g., "5 tasks expected" |
| **Task Extraction Status** | 🔴 NOT EXTRACTED / ✅ EXTRACTED ([N] tasks) |
```

**Proposed PD Template Addition:**
```markdown
### Implementation Checklist (Preliminary)
| Task | Priority | Depends On | Status |
|------|----------|------------|--------|
| [Task 1] | HIGH | RQ-XXX | 🔴 NOT STARTED |
| [Task 2] | MEDIUM | [None] | 🔴 NOT STARTED |
```

---

## Part 5: Why This Matters

### 5.1 Current Risk

Without governance fixes:
- **Duplicates accumulate** → Wasted effort, conflicting implementations
- **Tasks go missing** → Research value lost, features not built
- **PDs have no path to implementation** → Decisions made but not actioned

### 5.2 Compounding Effect

```
Session 1: RQ-016 creates "treaties table" task
Session 2: RQ-021 creates "treaties table" task (duplicate)
Session 3: Agent sees 2 tasks, assumes both needed, builds twice
Session 4: Conflict discovered, time wasted reconciling

OR

Session 1: RQ-019 marked COMPLETE with rich specifications
Session 2: No tasks extracted (missing protocol)
Session 3: Agent starts fresh, re-researches pgvector
Session 4: Research value lost, time wasted
```

### 5.3 Success Criteria

The governance system is successful when:

| Metric | Current | Target |
|--------|---------|--------|
| Duplicate tasks | > 0 observed | 0 |
| RQ COMPLETE without tasks | > 0 observed | 0 |
| PD RESOLVED without tasks | > 0 observed | 0 |
| Task-to-source traceability | Partial | 100% |
| Weekly audit findings | N/A | < 3 issues |

---

## Part 6: Implementation Roadmap

| Phase | Action | Owner | ETA |
|-------|--------|-------|-----|
| **Phase 1** | Protocol 7, 8, Master Tracker | This session | ✅ DONE |
| **Phase 2** | Add ACTIONED status to RQ template | Next session | 🔴 TODO |
| **Phase 3** | Add Implementation Checklist to PD template | Next session | 🔴 TODO |
| **Phase 4** | Backfill missing tasks from RQ-019, RQ-020 | Next session | 🔴 TODO |
| **Phase 5** | Create tasks for PD-118, PD-119, PD-120 | After research | 🔴 BLOCKED |
| **Phase 6** | Establish weekly governance audit | Human | 🔴 TODO |

---

## Conclusion

The CORE documentation system's failures stem from **implicit processes** that should be **explicit protocols**. The addition of Protocol 7 (Deep Think Quality) and Protocol 8 (Task Extraction & Deduplication) addresses the immediate gaps. However, structural changes to RQ/PD templates (adding ACTIONED status and Implementation Checklists) are needed for long-term governance.

**Key Insight:** Documentation systems degrade unless they include verification gates. Protocols without verification are suggestions. Protocols with verification are governance.

---

*This analysis should be reviewed and acted upon in the next human-AI session.*
