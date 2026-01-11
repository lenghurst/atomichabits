# Implementation Prompt Guidance — Executable Task Bundles

> **Last Updated:** 11 January 2026
> **Purpose:** Quality standards for Implementation Prompts (IPs) — prompts that produce executable code
> **Scope:** Mandatory for ANY agent preparing prompts for implementation tasks
> **Relationship:** Companion to `DEEP_THINK_PROMPT_GUIDANCE.md` (research prompts)

---

## What Is an Implementation Prompt?

An **Implementation Prompt (IP)** is a structured document that bundles related implementation tasks into an executable work package. Unlike Deep Think prompts (which produce research findings), IPs produce **working code**.

| Artifact Type | Purpose | Output | Example |
|---------------|---------|--------|---------|
| **Deep Think Prompt** | Research questions, architecture | Findings, recommendations | "How should identity topology be modeled?" |
| **Implementation Prompt** | Execute tasks, build features | SQL, Dart, Edge Functions | "Create identity_facets table with RLS" |

---

## When to Create an Implementation Prompt

Create an IP when:
- **Bundling 3+ related tasks** into a coherent work package
- **Tasks require significant context** from completed research
- **Output must be production-ready** (not prototype/exploration)
- **Phase work** — typically one IP per major phase (A, B, C, etc.)

Do NOT create an IP when:
- Single, isolated task (just do it)
- Task requires more research first (create Deep Think Prompt instead)
- Output is exploratory/prototype quality

---

## Implementation Prompt vs Tasks

| Concept | Definition | Example |
|---------|------------|---------|
| **Task** | Single unit of work (A-03) | "Create identity_facets table" |
| **Implementation Prompt** | Bundle of related tasks with context | "Phase A Schema Foundation (A-01 through A-12)" |

**Relationship:**
```
RQ (Research) → PD (Decision) → CD (Confirmed) → Tasks → IP (Bundle) → Code
```

---

## Mandatory IP Structure

Every Implementation Prompt MUST contain these sections:

### 1. Header Block

```markdown
# [Implementation Prompt Title]: [Phase/Topic]

> **Target:** [Task IDs] (e.g., A-01 through A-12)
> **Prepared:** [Date]
> **For:** Implementation Agent (Claude Code, Cursor, Human)
> **App Name:** The Pact (psyOS)
> **Priority:** [P0-P3] — [Impact summary]
```

### 2. Prerequisites Gate Check (MANDATORY — Protocol 13)

```markdown
## Prerequisites Gate Check

| Prerequisite | Type | Required Status | Actual Status | Clear? |
|--------------|------|-----------------|---------------|--------|
| RQ-011 | RQ | ✅ COMPLETE | ✅ COMPLETE | ✅ |
| CD-015 | CD | ✅ CONFIRMED | ✅ CONFIRMED | ✅ |

**Gate Status:** ✅ ALL PREREQUISITES MET — Proceed with implementation
```

⚠️ **CRITICAL:** If ANY prerequisite shows ❌, do NOT proceed. Fix the blocker first.

### 3. Executive Context

Explain **why** this work matters and what it unblocks:

```markdown
## Executive Context: Why This Is Critical

**Current State:**
- [What exists]
- [What's blocked]

**After This IP Completes:**
- [What becomes possible]
- [Tasks/phases unblocked]
```

### 4. Role Definition

```markdown
## Your Role

You are a **[Technical Role]** specializing in:
- [Skill 1]
- [Skill 2]
- [Domain expertise]

**Your approach:**
- [Quality expectations]
- [Output format expectations]
```

### 5. Processing Order

If tasks have dependencies, specify the exact execution order:

```markdown
## Critical Instruction: Processing Order

```
┌────────────────────────────────────────┐
│  STEP 1: [Task ID] — [Description]      │
│  ↓ Required for [next step reason]      │
├────────────────────────────────────────┤
│  STEP 2: [Task ID] — [Description]      │
│  ↓ Required for [next step reason]      │
└────────────────────────────────────────┘
```
```

### 6. Locked Architecture Context

Summarize relevant completed research and confirmed decisions:

```markdown
## Mandatory Context: Locked Architecture (DO NOT DEVIATE)

### From RQ-XXX: [Title] ✅
- [Key finding]
- [Constraint it imposes]

### From CD-XXX: [Title] ✅ LOCKED
- [Confirmed decision]
- [What this means for implementation]
```

### 7. Task Specifications

For each task, provide complete specifications:

```markdown
## Task A-XX: [Title]

### Requirements
- [Requirement 1]
- [Requirement 2]

### Technical Specification
[SQL, Dart, or other code specification]

### Constraints
- [Constraint 1]
- [Constraint 2]

### Expected Output
[What the completed task should produce]
```

### 8. Anti-Patterns

List common mistakes to avoid:

```markdown
## Anti-Patterns (DO NOT)

❌ [Mistake 1] — Why this is wrong
❌ [Mistake 2] — Why this is wrong
❌ [Mistake 3] — Why this is wrong
```

### 9. Verification Checklist

```markdown
## Output Verification Checklist

After completing all tasks, verify:

□ [Verification 1]
□ [Verification 2]
□ [Verification 3]
□ All SQL migrations compile without errors
□ RLS policies tested with both authenticated and anon roles
□ Foreign key constraints validate correctly
```

---

## Quality Criteria for IPs

| Criterion | Description | Validation |
|-----------|-------------|------------|
| **Prerequisites Listed** | All RQ/PD/CD sources explicitly stated | Gate Check section |
| **Prerequisites Verified** | Each source status confirmed (✅/❌) | Gate Check table |
| **Context Complete** | Relevant research findings summarized | Locked Architecture section |
| **Constraints Explicit** | All CDs that constrain output listed | Constraints per task |
| **Output Format Clear** | Expected deliverable structure defined | Task specifications |
| **Verification Defined** | How to validate success | Verification Checklist |
| **Anti-Patterns Listed** | Common mistakes to avoid | Anti-Patterns section |
| **Processing Order Clear** | Task dependencies explicit | Processing Order section |

---

## Naming Convention

```
Research Prompts:       DEEP_THINK_PROMPT_[TOPIC]_[RQ-IDS].md
Implementation Prompts: IMPLEMENTATION_PROMPT_PHASE_[X]_[TOPIC].md

Deprecated (rename):    DEEP_THINK_PROMPT_PHASE_A_SCHEMA_FOUNDATION.md
                        → IMPLEMENTATION_PROMPT_PHASE_A_SCHEMA_FOUNDATION.md
```

**Note:** The existing Phase A prompt uses DEEP_THINK naming. Future IPs should use IMPLEMENTATION_PROMPT prefix.

---

## Differences from Deep Think Prompts

| Aspect | Deep Think Prompt | Implementation Prompt |
|--------|-------------------|----------------------|
| **Purpose** | Research, explore options | Execute, produce code |
| **Output** | Findings, recommendations | SQL, Dart, config files |
| **Confidence** | Requests HIGH/MEDIUM/LOW ratings | Expects production-ready output |
| **Exploration** | "Present 2-3 options" | "Execute this specification" |
| **Format** | Prose explanations | Code blocks, tables |
| **Verification** | Literature citations | Compilation, tests |

---

## Example: Good IP Section

**Task A-03: Create identity_facets Table**

```markdown
### Requirements
- Store user identity facets (Parliament of Selves model)
- Support 768-dimension embeddings for semantic search
- Link facets to archetypes and energy states
- Include ICS (Identity Coherence Score) tracking

### Technical Specification
```sql
CREATE TABLE public.identity_facets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  label TEXT NOT NULL,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'maintenance', 'dormant')),
  typical_energy_state TEXT CHECK (typical_energy_state IN ('high_focus', 'high_physical', 'social', 'recovery')),
  ics_score FLOAT DEFAULT 0.0 CHECK (ics_score BETWEEN 0.0 AND 1.0),
  facet_embedding VECTOR(768),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- RLS Policy
ALTER TABLE public.identity_facets ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage own facets" ON public.identity_facets
  FOR ALL USING (auth.uid() = user_id);

-- Index for vector similarity search
CREATE INDEX idx_identity_facets_embedding ON public.identity_facets
  USING ivfflat (facet_embedding vector_cosine_ops);
```

### Constraints
- Must use 4-state energy model (CD-015): high_focus, high_physical, social, recovery
- Vector dimension must match DeepSeek embedding output (768)
- RLS required for multi-tenant security

### Expected Output
- Migration file: `supabase/migrations/YYYYMMDD_create_identity_facets.sql`
- Table created with all columns, constraints, RLS, and indexes
```

---

## Common IP Anti-Patterns

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| **No Gate Check** | May proceed on incomplete prerequisites | Always include Prerequisites Gate Check |
| **Pseudocode output** | Not executable | Request "production-ready" code |
| **Missing RLS** | Security vulnerability | Include RLS in every table spec |
| **Vague constraints** | Ambiguous implementation | Link to specific CDs |
| **No processing order** | Tasks executed wrong sequence | Include dependency diagram |
| **Copy-paste context** | Stale or irrelevant | Verify context is current |

---

## Post-IP Processing (Protocol 8)

After an IP produces output:

1. **VERIFY** all tasks marked complete in Master Tracker
2. **UPDATE** IMPLEMENTATION_ACTIONS.md with status changes
3. **RUN** migrations and verify success
4. **COMMIT** with clear message referencing task IDs
5. **UPDATE** AI_HANDOVER.md with completion summary

---

## Reference

- **Deep Think Prompt Guidance:** `docs/CORE/DEEP_THINK_PROMPT_GUIDANCE.md`
- **Protocol 13 (Gate Check):** `docs/CORE/AI_AGENT_PROTOCOL.md`
- **Protocol 8 (Task Extraction):** `docs/CORE/AI_AGENT_PROTOCOL.md`
- **Exemplar IP:** `docs/prompts/DEEP_THINK_PROMPT_PHASE_A_SCHEMA_FOUNDATION.md`

---

*This document enables immediate IP creation without waiting for RQ-040 research.*
*Based on patterns from existing DEEP_THINK_PROMPT_GUIDANCE.md and Phase A IP exemplar.*
