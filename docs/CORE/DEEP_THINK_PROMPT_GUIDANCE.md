# Deep Think Prompt Guidance — Quality Assurance Framework

> **Last Updated:** 11 January 2026
> **Purpose:** Ensure all prompts sent to external AI research tools (Google Deep Think, Claude, etc.) meet quality standards for maximum output value
> **Scope:** Mandatory for ANY agent preparing research prompts

---

## Why This Document Exists

External AI research tools (Deep Think, Claude Projects, ChatGPT Canvas) produce output quality proportional to input quality. Poorly structured prompts yield vague, unimplementable responses. This document codifies **prompt engineering best practices** specifically for The Pact's research workflow.

**This is a MANDATORY checklist.** Do not send external research prompts without verifying compliance.

---

## Prompt Quality Characteristics (Required)

Every Deep Think prompt MUST exhibit these characteristics:

### 1. Rich Context
| Requirement | Description | Example |
|-------------|-------------|---------|
| **Prior Research Summary** | Summarize all completed RQs that inform this research | "RQ-012 established Fractal Trinity architecture with pgvector..." |
| **Locked Decisions** | List CDs that constrain the solution space | "CD-016 mandates DeepSeek V3.2 for Council AI, hardcoded JITAI" |
| **Schema Examples** | Include SQL/Dart snippets from existing research | Actual `CREATE TABLE` statements |
| **Current State** | Describe what exists vs what's being researched | "ContextSnapshot class exists but `energyState` field is unspecified" |

### 2. Structured Sub-Questions
| Requirement | Description | Example |
|-------------|-------------|---------|
| **Tabular Format** | Use tables to organize question space | `| # | Question | Your Task |` |
| **Explicit Numbering** | Number sub-questions for reference | "1. Edge Directionality: Bidirectional or directed?" |
| **Task Clarity** | Tell the model what action to take | "Cite 2-3 papers. Propose additions/removals." |
| **Tradeoff Framing** | Frame questions as tradeoffs when applicable | "Battery vs accuracy — recommend with justification" |

### 3. Constraints Section
| Requirement | Description | Example |
|-------------|-------------|---------|
| **Technical Constraints** | Database, AI models, frameworks | "Supabase (PostgreSQL + pgvector). No graph databases." |
| **UX Constraints** | Friction limits, user burden | "Cannot require explicit graph edge definition" |
| **Resource Constraints** | Battery, API limits, cost | "< 5% daily battery impact" |
| **Anti-Patterns** | What NOT to do | "❌ Requiring users to manually log energy state" |

### 4. Output Format Specification
| Requirement | Description | Example |
|-------------|-------------|---------|
| **Markdown Structure** | Specify exact headers and format | "Use `### Sub-Questions Answered` with table format" |
| **Code Expectations** | Specify pseudocode, Dart, SQL | "Provide decision tree or algorithm in Dart" |
| **Confidence Levels** | Request certainty assessment | "Rate each output HIGH/MEDIUM/LOW confidence" |
| **Deliverables List** | Numbered list of expected outputs | "1. Validated taxonomy 2. Switching matrix 3. Algorithm" |

---

## Prompt Weaknesses to Avoid (Anti-Patterns)

These common weaknesses degrade output quality. **Actively check for and eliminate these:**

| Weakness | Problem | Fix |
|----------|---------|-----|
| **No Expert Role** | Model lacks domain authority | Add: "You are a Senior Systems Architect specializing in..." |
| **Missing Think-Chain** | Less rigorous analysis | Add: "Think step-by-step. Reason through each sub-question." |
| **No Priority Sequence** | Interdependent RQs solved in wrong order | Add: "Process in this exact sequence: RQ-014 → RQ-013 → ..." |
| **No Examples** | Ambiguous quality bar | Add: "Example of good output:" section with concrete sample |
| **No Anti-Patterns** | Model may repeat known mistakes | Add: "Anti-Patterns to Avoid:" section per RQ |
| **No Confidence Levels** | Can't triage follow-up research | Add: "Rate confidence HIGH/MEDIUM/LOW for each recommendation" |
| **Single Solution** | Loses decision flexibility | Add: "Present 2-3 options with tradeoffs, then recommend" |
| **Weak Interdependencies** | Inconsistent specs across RQs | Add: ASCII diagram showing RQ → RQ dependencies |
| **No User Scenarios** | May miss UX implications | Add: "Solve this concrete scenario:" with specific example |
| **No Literature Guidance** | Inconsistent rigor | Add: "Cite 2-3 papers where applicable" |
| **No Validation Checklist** | Self-validation skipped | Add: "Final Checklist Before Submitting" section |

---

## Mandatory Prompt Structure

Use this template for ALL Deep Think prompts:

```markdown
# Deep Think Prompt: [Topic Title]

> **Target Research:** [RQ-XXX, PD-XXX list]
> **Prepared:** [Date]
> **For:** Google Deep Think / [External AI Tool]
> **App Name:** The Pact

---

## Your Role

You are a **[Domain Expert Title]** specializing in:
- [Domain 1]
- [Domain 2]
- [Domain 3]

Your approach: [Thinking methodology instruction]

---

## Critical Instruction: Processing Order

[If multiple RQs, show dependency chain with ASCII diagram]

```
RQ-XXX (First)
  ↓ Output feeds into...
RQ-YYY (Second)
  ↓ Output feeds into...
PD-ZZZ (Third)
```

---

## Mandatory Context: Locked Architecture

[Summarize all COMPLETE RQs and CONFIRMED CDs that constrain this research]

### RQ-XXX: [Title] ✅
- Key decision or finding
- Schema snippet if relevant

### CD-XXX: [Title] ✅
- Constraint this imposes

---

## Research Question 1: RQ-XXX — [Title]

### Core Question
[One-sentence question]

### Why This Matters
[Context for prioritization]

### The Problem
[Concrete example or scenario illustrating the gap]

### Current Hypothesis (Validate or Refine)
[Table or description of current thinking]

### Sub-Questions (Answer Each Explicitly)
| # | Question | Your Task |
|---|----------|-----------|
| 1 | ... | ... |

### Anti-Patterns to Avoid
- ❌ [What NOT to do]

### Output Required
1. [Specific deliverable]
2. [Specific deliverable]
3. Confidence Assessment — rate each output HIGH/MEDIUM/LOW

---

## Architectural Constraints (Hard Requirements)

| Constraint | Rule |
|------------|------|
| **Database** | ... |
| **AI Models** | ... |
| **Client** | ... |

---

## Output Quality Criteria

| Criterion | Question to Ask |
|-----------|-----------------|
| **Implementable** | Can an engineer build this without clarifying questions? |
| **Grounded** | Are recommendations supported by cited literature? |
| **Consistent** | Does this integrate with existing research? |
| **Actionable** | Are there concrete next steps? |
| **Bounded** | Are edge cases handled? |

---

## Example of Good Output

[Include one partial example showing the QUALITY BAR expected]

---

## Final Checklist Before Submitting

- [ ] Each sub-question has explicit answer
- [ ] All schemas include field types and constraints
- [ ] All algorithms include pseudocode
- [ ] Confidence levels stated for each recommendation
- [ ] Anti-patterns addressed
- [ ] User scenarios solved step-by-step
- [ ] Integration points with existing research explicit

---

*End of Prompt*
```

---

## Sub-RQ Prompt Template (Protocol 11)

When creating prompts for **sub-RQs** (e.g., RQ-039a, RQ-039b), use this modified template. Sub-RQs have narrower scope and require parent context.

### Key Differences from Top-Level RQ Prompts

| Aspect | Top-Level RQ | Sub-RQ |
|--------|--------------|--------|
| **Scope** | Multi-domain | Single SME domain |
| **Context** | All relevant CDs/RQs | Parent RQ + sibling awareness |
| **Deliverable** | Broad research output | Specific, bounded answer |
| **Length** | 10+ page output expected | 2-5 page output expected |

### Sub-RQ Prompt Template

```markdown
# Deep Think Prompt: [Sub-RQ ID] — [Title]

> **Parent RQ:** RQ-XXX — [Parent Title]
> **This Sub-RQ:** RQ-XXXy — [Sub-RQ Title]
> **SME Domain:** [Single domain focus]
> **Prepared:** [Date]
> **For:** Google Deep Think / [External AI Tool]

---

## Your Role

You are a **[Domain Expert Title]** specializing in [single SME domain].

Focus ONLY on the specific question below. Do not expand scope to cover sibling sub-RQs.

---

## Parent Context

### Parent RQ: RQ-XXX — [Title]
[Brief summary of the parent question and why it was decomposed]

### Sibling Sub-RQs (For Awareness Only — DO NOT Answer These)
| Sub-RQ | Title | Status |
|--------|-------|--------|
| RQ-XXXa | [Title] | [Complete/Pending] |
| RQ-XXXb | [Title] | [Complete/Pending] |
| ... | ... | ... |

**Your Focus:** RQ-XXXy ONLY

---

## The Question

### RQ-XXXy: [Title]

**Core Question:** [Single, focused question]

**Why This Matters:** [Context for prioritization]

**Constraints:**
- [Domain-specific constraints]
- [Integration constraints with parent/siblings]

### Sub-Questions (Answer Each)
| # | Question | Your Task |
|---|----------|-----------|
| 1 | ... | ... |
| 2 | ... | ... |

---

## Output Required

1. [Specific deliverable for this sub-RQ]
2. Integration notes: How does this answer feed into the parent RQ?
3. Confidence Assessment: HIGH/MEDIUM/LOW

---

## Architectural Constraints

[Same as parent prompt — inherited]

---

*End of Sub-RQ Prompt*
```

### When to Use Sub-RQ Template

Use this template when:
- Protocol 11 (Sub-RQ Creation) was applied to a parent RQ
- Sub-RQs have been defined with IDs (e.g., RQ-039a through RQ-039g)
- Each sub-RQ needs independent research

### Anti-Patterns for Sub-RQ Prompts

```
❌ Including all sub-RQs in one prompt (defeats decomposition purpose)
❌ Omitting parent context (loses integration awareness)
❌ Using multi-domain expert role (sub-RQs are single-domain)
❌ Expecting 10+ page output (sub-RQs are bounded)
```

---

## Prompt Quality Checklist (Use Before Sending)

Before sending ANY prompt to Deep Think or external AI:

### Context Verification
- [ ] All relevant completed RQs summarized
- [ ] All constraining CDs listed
- [ ] Existing schemas/code included
- [ ] Current state vs desired state clear

### Structure Verification
- [ ] Expert role defined
- [ ] Processing order specified (if multiple RQs)
- [ ] Sub-questions in tabular format
- [ ] Each sub-question has explicit task

### Constraints Verification
- [ ] Technical constraints listed
- [ ] UX constraints listed
- [ ] Resource constraints quantified
- [ ] Anti-patterns section included

### Output Verification
- [ ] Markdown structure specified
- [ ] Deliverables numbered
- [ ] Confidence levels requested
- [ ] Example of good output included

### Validation Verification
- [ ] Final checklist included
- [ ] Quality criteria table included
- [ ] Integration points explicit

---

## Post-Response Processing (MANDATORY)

After receiving Deep Think output, the receiving agent MUST follow this exact sequence:

### Step 0: RUN PROTOCOL 9 FIRST (Non-Negotiable)

**Before ANY integration, run the External Research Reconciliation Checklist:**

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  STOP. Before proceeding, complete AI_AGENT_PROTOCOL.md → Protocol 9         │
│                                                                              │
│  □ Phase 1: Locked Decision Audit (check against CDs)                        │
│  □ Phase 2: Data Reality Audit (Android-first verification)                  │
│  □ Phase 3: Implementation Reality Audit (existing code check)               │
│  □ Phase 4: Scope & Complexity Audit (ESSENTIAL → OVER-ENGINEERED)           │
│  □ Phase 5: Categorize each proposal (ACCEPT/MODIFY/REJECT/ESCALATE)         │
│  □ Phase 6: Document the reconciliation output                               │
│                                                                              │
│  Only proceed to Step 1 after Protocol 9 is complete.                        │
└──────────────────────────────────────────────────────────────────────────────┘
```

**Why Step 0 exists:** External AI tools don't have access to locked CDs, platform constraints, or existing code. Their proposals often conflict with reality. Reconciliation BEFORE integration prevents drift.

### Step 0.5: Run Protocol 10 If Recommendations Made (MANDATORY)

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  AFTER Protocol 9, BEFORE Task Extraction:                                   │
│                                                                              │
│  IF any recommendations affect product direction, monetization,              │
│  core UX, or multi-stakeholder architecture:                                 │
│                                                                              │
│  □ Run Protocol 10 (Bias Analysis) from AI_AGENT_PROTOCOL.md                │
│    - List all assumptions                                                    │
│    - Rate validity (HIGH/MEDIUM/LOW)                                         │
│    - If 4+ LOW → Consider Protocol 12 (Decision Deferral)                   │
│                                                                              │
│  WHY: External research may contain biases from the source AI.               │
│  Protocol 10 surfaces these BEFORE they become implementation tasks.         │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Step 1: Extract Implementation Tasks (From ACCEPTED items only)
```
For EACH ACCEPT or MODIFY recommendation:
1. Create implementation task with ID (A-XX, B-XX, etc.)
2. Assign priority (CRITICAL/HIGH/MEDIUM/LOW)
3. Identify component (Database/Service/Screen/etc.)
4. Add to Master Implementation Tracker in RESEARCH_QUESTIONS.md

DO NOT extract tasks from REJECTED proposals.
```

### Step 1.5: Update Implementation Actions Quick Status
```
After adding tasks to Master Tracker (Step 1), update the navigation hub:

1. IMPLEMENTATION_ACTIONS.md → Quick Status Dashboard
   - Update phase totals (e.g., Phase A: 12 tasks)
   - Update overall totals

2. Add entry to "Recently Added Tasks" section
   - Task ID, Title, Phase, Status, Source RQ

3. Add row to "Task Addition Log"
   - Date, Source (RQ-XXX reconciliation), Phase, Count, Added By

4. Check "Blocked Tasks" section
   - If new research creates blockers, document them
   - If blockers resolved, remove them

WHY: IMPLEMENTATION_ACTIONS.md is the navigation hub. If it's not updated,
agents will miss new tasks. Master Tracker is the source of truth for details;
IA is the quick status dashboard.
```

### Step 2: Update Research Questions
```
1. Mark RQ as ✅ COMPLETE
2. Copy key findings into RQ entry
3. Add "Sub-Questions Answered" table
4. Add "Output Delivered" table
```

### 3. Check for Duplicates
```
Before adding tasks:
1. Search existing tasks for similar work
2. If duplicate found → MERGE, don't create new
3. If extension of existing → UPDATE existing task
```

### 4. Create Follow-Up RQs
```
For each "MEDIUM" or "LOW" confidence recommendation:
1. Create follow-up RQ for validation
2. Link to original RQ
```

### 5. Update Dependencies
```
For each new task:
1. Identify upstream dependencies (what must complete first)
2. Identify downstream impacts (what this enables)
3. Update IMPACT_ANALYSIS.md
```

---

## Integration with CORE Documentation

### Where This Document Fits

```
docs/CORE/
├── README.md                    ← References this guidance
├── AI_AGENT_PROTOCOL.md         ← Protocol 7 references this
├── RESEARCH_QUESTIONS.md        ← Prompts generated for RQs
├── PRODUCT_DECISIONS.md         ← Prompts generated for PDs
├── DEEP_THINK_PROMPT_GUIDANCE.md ← YOU ARE HERE
└── [Prompt files]               ← Actual prompts stored here
```

### Naming Convention for Prompt Files

```
DEEP_THINK_PROMPT_[TOPIC]_[RQ-IDS].md

Examples:
- DEEP_THINK_PROMPT_IDENTITY_SYSTEM_RQ013-RQ014-RQ015-PD117.md
- DEEP_THINK_PROMPT_COUNCIL_AI_RQ016-RQ021-RQ022.md
```

---

## Revision History

| Date | Author | Changes |
|------|--------|---------|
| 06 Jan 2026 | Claude (Opus 4.5) | Initial creation from Prompt B learnings |

---

*This document is MANDATORY. Non-compliant prompts will produce suboptimal research output.*
