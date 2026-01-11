# Governance Gap Analysis: Implementation Prompts, Gate Checks & Task Taxonomy

> **Date:** 11 January 2026
> **Author:** Claude (Opus 4.5)
> **Purpose:** Address three governance gaps identified during Session 22 audit
> **Outcome:** New RQ, formal definitions, and recommendations

---

## Executive Summary

Three governance gaps were identified:

1. **Implementation Prompts** — No formal definition or guardrails for task execution prompts
2. **Prerequisites Gate Check** — No protocol verifies dependencies before task execution
3. **Task Type Taxonomy** — Phases contain mixed task types without classification

This analysis provides research-backed solutions for each.

---

## Gap 1: Implementation Prompts — Formal Definition

### Current State

| Artifact Type | Exists? | Location | Guidance Document |
|---------------|---------|----------|-------------------|
| Research Prompts | ✅ Yes | `docs/prompts/DEEP_THINK_PROMPT_*.md` | `DEEP_THINK_PROMPT_GUIDANCE.md` |
| **Implementation Prompts** | ❌ No | Created ad-hoc | **NONE** |

### The Problem

An "Implementation Prompt" was created (`DEEP_THINK_PROMPT_PHASE_A_SCHEMA_FOUNDATION.md`) without:
- Formal definition of what it is
- Quality criteria for validation
- Naming convention
- Integration with existing governance

### Proposed Definition

**Implementation Prompt (IP):** A structured document that bundles related implementation tasks into an executable work package, providing:
1. Complete context from resolved research (RQs)
2. Specifications derived from confirmed decisions (CDs)
3. Constraints from product decisions (PDs)
4. Prerequisites verification checklist
5. Executable output format (code, SQL, config)
6. Verification criteria

### Relationship to Other Artifacts

```
RQ (Research Question)
    │
    ▼ answers inform
PD (Product Decision)
    │
    ▼ resolves to
CD (Confirmed Decision)
    │
    ▼ constrains
Tasks (A-01, B-01, etc.)
    │
    ▼ bundled into
Implementation Prompt (IP)
    │
    ▼ produces
Executable Output (SQL, Dart, Config)
```

### Naming Convention

```
Research Prompts:      DEEP_THINK_PROMPT_[TOPIC]_[RQ-IDS].md
Implementation Prompts: IMPLEMENTATION_PROMPT_PHASE_[X]_[TOPIC].md
```

### Quality Criteria for Implementation Prompts

| Criterion | Description | Validation |
|-----------|-------------|------------|
| **Prerequisites Listed** | All RQ/PD/CD sources explicitly stated | Checklist at top |
| **Prerequisites Verified** | Each source status confirmed (✅/❌) | Gate check table |
| **Context Complete** | Relevant research findings summarized | Section per RQ |
| **Constraints Explicit** | All CDs that constrain output listed | Locked Architecture section |
| **Output Format Clear** | Expected deliverable structure defined | Output section |
| **Verification Defined** | How to validate success | Checklist at end |
| **Anti-Patterns Listed** | Common mistakes to avoid | Anti-patterns section |

### New Research Question Required

**RQ-040: Implementation Prompt Engineering for AI Agents**

This RQ addresses: "How best to structure prompts to Gemini/Claude for implementation tasks to achieve close alignment with intent?"

See: Formal RQ definition below.

---

## Gap 2: Prerequisites Gate Check — Solution Analysis

### Research Context

Modern project management uses several patterns for dependency verification:

1. **[Stage Gate Process](https://asana.com/resources/stage-gate-process)** — Checkpoints between phases
2. **[Task Dependencies](https://asana.com/resources/project-dependencies)** — Finish-to-Start, Start-to-Start relationships
3. **[Dependency Management Tools](https://ones.com/blog/dependency-management-tools-streamline-projects/)** — Automated verification

### Solution Options

#### Option A: Manual Protocol (Lightweight)

**Description:** Add Protocol 13 requiring manual verification before implementation tasks.

```markdown
## Protocol 13: Prerequisites Gate Check

Before executing implementation tasks:
1. Extract "Source" column values
2. Check each in index files
3. Document verification in prompt
4. Proceed only if all ✅
```

**SWOT Analysis:**

| Strengths | Weaknesses |
|-----------|------------|
| Zero infrastructure | Human error risk |
| Immediate implementation | No enforcement |
| Fits existing process | Inconsistent application |
| Low cognitive overhead | Relies on discipline |

| Opportunities | Threats |
|---------------|---------|
| Can evolve to automated | Agents may skip |
| Builds verification habit | False positives (stale index) |

**Critique:**
- ✅ Pragmatic for current scale (116 tasks)
- ❌ Doesn't scale to 500+ tasks
- ⚠️ Depends on index file accuracy

---

#### Option B: Automated Dependency Graph (Heavy)

**Description:** Build a formal dependency graph with automated validation.

```yaml
# dependencies.yaml
tasks:
  A-03:
    name: Create identity_facets
    depends_on:
      - { type: RQ, id: RQ-011, status: COMPLETE }
      - { type: CD, id: CD-015, status: CONFIRMED }
    blocks:
      - B-01
      - F-02
      - H-01
```

```bash
# Validation script
./scripts/check-prerequisites.sh A-03
# Output: ✅ RQ-011 COMPLETE, ✅ CD-015 CONFIRMED → CLEAR
```

**SWOT Analysis:**

| Strengths | Weaknesses |
|-----------|------------|
| Automated enforcement | Infrastructure overhead |
| Single source of truth | Requires maintenance script |
| Scales to any size | YAML must stay in sync |
| Blocks invalid execution | Learning curve |

| Opportunities | Threats |
|---------------|---------|
| CI/CD integration | YAML drift from reality |
| Visualize dependency graph | Over-engineering for current scale |
| Auto-generate reports | Slows rapid iteration |

**Critique:**
- ✅ Robust for large projects
- ❌ Over-engineered for 116 tasks at 0% completion
- ⚠️ Adds maintenance burden

---

#### Option C: Embedded Prerequisites in Master Tracker (Hybrid)

**Description:** Enhance the Master Implementation Tracker with prerequisite status.

```markdown
| # | Task | Prerequisites | Pre-Status | Status |
|---|------|---------------|------------|--------|
| A-03 | Create identity_facets | RQ-011, CD-015 | ✅✅ | 🔴 |
| F-06 | archetype_templates | RQ-028 | ❌ | 🔴 BLOCKED |
```

**Rule:** Tasks with any ❌ in Pre-Status are automatically 🔴 BLOCKED.

**SWOT Analysis:**

| Strengths | Weaknesses |
|-----------|------------|
| Single file to maintain | Manual status updates |
| Visual at-a-glance | Can become stale |
| No new infrastructure | Duplication with index files |
| Integrates with existing | Longer table rows |

| Opportunities | Threats |
|---------------|---------|
| Protocol 8/9 auto-update | Human forgets to update |
| Color-coding in renders | Table gets unwieldy |

**Critique:**
- ✅ Best balance of visibility and overhead
- ✅ Fits current documentation patterns
- ⚠️ Requires discipline during Protocol 8/9

---

#### Option D: Stage Gate with Implementation Prompts

**Description:** Use Implementation Prompts as the gate check mechanism.

```
Phase A Tasks → Implementation Prompt A → Gate Review → Execute → Phase B unlocked
```

Implementation Prompt MUST include:

```markdown
## Prerequisites Gate Check

| Prerequisite | Type | Required Status | Actual Status | Clear? |
|--------------|------|-----------------|---------------|--------|
| RQ-011 | RQ | ✅ COMPLETE | ✅ COMPLETE | ✅ |
| RQ-012 | RQ | ✅ COMPLETE | ✅ COMPLETE | ✅ |
| CD-015 | CD | ✅ CONFIRMED | ✅ CONFIRMED | ✅ |

**Gate Status:** ✅ ALL PREREQUISITES MET — Proceed with implementation
```

**SWOT Analysis:**

| Strengths | Weaknesses |
|-----------|------------|
| Verification embedded in work | Requires IP for every phase |
| Natural checkpoint | IP overhead for small tasks |
| Human-readable | Gate check duplicated per IP |
| Auditable (in git history) | |

| Opportunities | Threats |
|---------------|---------|
| Template enforcement | Copy-paste errors |
| Links research to execution | IP becomes stale |

**Critique:**
- ✅ Most aligned with current workflow
- ✅ Prompt-first development pattern
- ⚠️ Requires IMPLEMENTATION_PROMPT_GUIDANCE.md

---

### Recommendation: Option C + D Hybrid

**Implement both:**

1. **Option C:** Add "Pre-Status" column to Master Tracker
   - Quick visual of what's blocked
   - Updated during Protocol 8/9

2. **Option D:** Require Gate Check section in all Implementation Prompts
   - Verification at execution time
   - Auditable in git

**Implementation:**
- Create Protocol 13 (Prerequisites Gate Check)
- Update Master Tracker format
- Create IMPLEMENTATION_PROMPT_GUIDANCE.md
- Add Gate Check template

---

## Gap 3: Task Type Taxonomy — Risk Analysis

### Current State

Tasks are categorized by **Phase only**:

| Phase | Contains |
|-------|----------|
| A | SQL migrations, extension enablement |
| B | Edge Functions, Dart services, DB triggers |
| C | Prompts, services, DB tables |
| D | Flutter screens, widgets |
| E | Services, content, config |
| F | DB tables, services, content templates |
| G | Services, content |
| H | Widgets, audio content, services |

### Does Ambiguity Represent a Risk?

**Analysis:**

| Risk | Severity | Mitigation |
|------|----------|------------|
| **Wrong skill assignment** | MEDIUM | Phases already imply skill (A=DBA, D=Flutter) |
| **Estimation errors** | LOW | 8/80 rule applies regardless of type |
| **Parallel work conflicts** | LOW | Tasks in same phase can often parallelize |
| **Missing dependencies** | HIGH | Different types have different toolchains |

**Key Risk:** A task marked "Database" may require both SQL AND Dart model creation. Without type clarity, the Dart model could be forgotten.

### Benefits of Increased Detail

| Benefit | Description | Impact |
|---------|-------------|--------|
| **Skill Matching** | Assign SQL tasks to DBA, Dart to Flutter dev | MEDIUM |
| **Toolchain Clarity** | Know what tools needed before starting | HIGH |
| **Parallel Identification** | Same-type tasks often parallelize | MEDIUM |
| **Estimation Precision** | SQL vs Dart have different time profiles | MEDIUM |
| **Dependency Inference** | SQL must precede Dart models | HIGH |

### Proposed Taxonomy

| Type Code | Name | Tools/Skills | Example |
|-----------|------|--------------|---------|
| `DB` | Database Schema | SQL, Supabase | A-01, A-03 |
| `EF` | Edge Function | TypeScript, Supabase | B-01, F-07 |
| `SV` | Service (Dart) | Dart, Flutter | B-04, G-04 |
| `MD` | Model (Dart) | Dart | B-10, F-17 |
| `UI` | Widget/Screen | Flutter, Dart | D-01, H-01 |
| `PR` | Prompt Engineering | LLM, English | B-07, C-05 |
| `CT` | Content Creation | Copy, Templates | F-13, F-15 |
| `CF` | Configuration | YAML, JSON | B-03 |
| `AU` | Audio/Assets | Media files | H-13 |

### Enhanced Master Tracker Format

```markdown
| # | Task | Type | Prerequisites | Pre-Status | Status |
|---|------|------|---------------|------------|--------|
| A-01 | Enable pgvector | DB | RQ-019 | ✅ | 🔴 |
| A-03 | Create identity_facets | DB | RQ-011, CD-015 | ✅✅ | 🔴 |
| B-01 | embed-manifestation Edge Function | EF | A-01, RQ-019 | ❌✅ | 🔴 BLOCKED |
| F-17 | ProactiveRecommendation model | MD | F-07 | ❌ | 🔴 BLOCKED |
```

### Is This Over-Engineering?

**Assessment:**

| Factor | Current Scale | At Scale (500+ tasks) |
|--------|---------------|----------------------|
| Type column effort | LOW (add to 116 rows) | LOW (template) |
| Maintenance | LOW (rarely changes) | LOW |
| Value | MEDIUM | HIGH |

**Verdict:** Adding a Type column is **NOT over-engineering**. It's low-effort metadata that enables:
- Better task assignment
- Dependency inference
- Parallelization planning

---

## Gap 4: Work Package Concept — Context

### Definition from Project Management

A **[Work Package](https://www.atlassian.com/work-management/project-management/work-breakdown-structure)** in project management is:

> "The lowest level of a Work Breakdown Structure (WBS) — a discrete deliverable that can be assigned to a single owner, estimated, and tracked."

### Work Package Characteristics ([PMI](https://www.pmi.org/learning/library/work-breakdown-structure-basic-principles-4883))

| Characteristic | Description |
|----------------|-------------|
| **Discrete** | Clear boundaries, no overlap with other packages |
| **Assignable** | Single owner accountable |
| **Estimable** | 8-80 hours (one day to two weeks) |
| **Measurable** | Clear completion criteria |
| **Traceable** | Links to parent deliverables |

### The 100% Rule

> "The WBS includes 100% of the work defined by the project scope and captures all deliverables — internal, external, interim — in terms of the work to be completed."

### How This Relates to Our Governance

| PM Concept | Our Equivalent | Gap? |
|------------|----------------|------|
| WBS | Phase structure (A-H) | ✅ Exists |
| Work Package | Individual task (A-01) | ✅ Exists |
| Package Owner | Not assigned | ⚠️ Gap |
| Package Estimate | Not provided | ⚠️ Gap |
| Package Prerequisites | Source column | ⚠️ Not verified |
| Package Deliverable | Implicit | ⚠️ Not explicit |

### Should We Formalize Work Packages?

**Arguments For:**
- Clear ownership (who does A-03?)
- Estimation enables planning
- Prerequisites enforced
- Deliverables explicit

**Arguments Against:**
- We have 0/116 tasks complete
- Overhead before any work done
- May slow rapid iteration
- Current tasks are simple enough

**Recommendation:**
- **Now:** Add lightweight metadata (Type, Pre-Status)
- **Later (>50% complete):** Consider formal Work Package structure with estimates and owners

---

## Deliverables from This Analysis

### 1. New RQ-040

**RQ-040: Implementation Prompt Engineering for AI Agents**

Question: How should prompts to Gemini/Claude be structured for implementation tasks to achieve maximum alignment with intent?

Sub-questions:
- What structural patterns work best (XML tags, Markdown, hybrid)?
- How should prerequisites be embedded?
- What level of specification prevents ambiguity without over-constraining?
- How should verification criteria be expressed?

### 2. New Protocol 13

**Protocol 13: Prerequisites Gate Check**

When: Before executing any implementation task or Implementation Prompt.

### 3. Documentation Updates Required

| Document | Update |
|----------|--------|
| `RQ_INDEX.md` | Add RQ-040 |
| `RESEARCH_QUESTIONS.md` | Add RQ-040 full entry |
| `AI_AGENT_PROTOCOL.md` | Add Protocol 13 |
| `RESEARCH_QUESTIONS.md` | Add Type and Pre-Status columns to Master Tracker |
| `IMPLEMENTATION_ACTIONS.md` | Reference new protocol |
| `ROADMAP.md` | Add IMPLEMENTATION_PROMPT_GUIDANCE.md to Phase 0 |

### 4. New Document Required

`IMPLEMENTATION_PROMPT_GUIDANCE.md` — Quality standards for Implementation Prompts

---

## Sources

- [Stage Gate Process - Asana](https://asana.com/resources/stage-gate-process)
- [Project Dependencies - Asana](https://asana.com/resources/project-dependencies)
- [Work Breakdown Structure - Atlassian](https://www.atlassian.com/work-management/project-management/work-breakdown-structure)
- [WBS Basic Principles - PMI](https://www.pmi.org/learning/library/work-breakdown-structure-basic-principles-4883)
- [Dependency Management Tools - ONES](https://ones.com/blog/dependency-management-tools-streamline-projects/)
- [Gemini Prompt Strategies - Google AI](https://ai.google.dev/gemini-api/docs/prompting-strategies)
- [Gemini 3 Prompting Guide - PromptBuilder](https://promptbuilder.cc/blog/gemini-3-prompting-playbook-november-2025)
- [Prompt Engineering Guide 2025 - Lakera](https://www.lakera.ai/blog/prompt-engineering-guide)

---

*Analysis complete: 11 January 2026*
