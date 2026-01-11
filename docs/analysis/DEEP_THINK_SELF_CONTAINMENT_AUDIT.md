# Deep Think Prompt Self-Containment Audit

> **Date:** 11 January 2026
> **Auditor:** Claude (Opus 4.5)
> **Purpose:** Identify and remediate prompts that assume Deep Think has project context
> **Critical Finding:** ALL existing prompts violate self-containment principle

---

## The Core Problem

**Deep Think (Gemini, DeepSeek, etc.) has:**
- ❌ NO access to our codebase
- ❌ NO memory of previous conversations
- ❌ NO knowledge of our terminology (CD, RQ, PD, psyOS, etc.)
- ❌ NO context about what "The Pact" is
- ❌ NO understanding of our internal reference systems

**Every prompt must be 100% SELF-CONTAINED.**

---

## Audit Methodology

For each prompt, scored on 5 criteria (0-2 points each, max 10):

| Criterion | 0 Points | 1 Point | 2 Points |
|-----------|----------|---------|----------|
| **App Explanation** | No explanation | Brief mention | Full context (what, why, for whom) |
| **Terminology** | Uses undefined terms | Some definitions | All terms explained inline |
| **Architecture Context** | References files/tables | Partial schemas | Full schemas inline with explanation |
| **Philosophy Explanation** | Assumes knowledge | Brief mention | Full explanation of psyOS, Parliament, etc. |
| **Standalone Readability** | Cannot understand without codebase | Partially understandable | Fully understandable by external reader |

**Passing Score:** 8/10 minimum

---

## Prompt Inventory (14 Prompts)

| # | Prompt File | RQs Covered | Self-Containment Score |
|---|-------------|-------------|------------------------|
| 1 | DEEP_THINK_PROMPT_IDENTITY_COACH_RQ005-RQ006-RQ007.md | RQ-005, 006, 007 | **4/10** ❌ |
| 2 | DEEP_THINK_PROMPT_IDENTITY_SYSTEM_RQ013-RQ014-RQ015-PD117.md | RQ-013, 014, 015, PD-117 | **3/10** ❌ |
| 3 | DEEP_THINK_PROMPT_IDENTITY_COACH_PHASE2_RQ028-RQ032.md | RQ-028 to 032 | **3/10** ❌ |
| 4 | DEEP_THINK_PROMPT_TREATY_MODIFICATION_RQ024.md | RQ-024 | **4/10** ❌ |
| 5 | DEEP_THINK_PROMPT_ENGINEERING_PROCESS_RQ008_RQ009.md | RQ-008, 009 | **5/10** ❌ |
| 6 | DEEP_THINK_PROMPT_PSYOS_UX_RQ017_RQ018.md | RQ-017, 018 | **4/10** ❌ |
| 7 | DEEP_THINK_PROMPT_SOUND_DESIGN_RQ026.md | RQ-026 | **5/10** ❌ |
| 8 | DEEP_THINK_PROMPT_HOLY_TRINITY_RQ037.md (v1) | RQ-037 | **3/10** ❌ |
| 9 | DEEP_THINK_PROMPT_HOLY_TRINITY_RQ037_v2.md | RQ-037 | **4/10** ❌ |
| 10 | DEEP_THINK_PROMPT_SUMMON_TOKEN_RQ025.md (v1) | RQ-025 | **4/10** ❌ |
| 11 | DEEP_THINK_PROMPT_SUMMON_TOKEN_RQ025_v2.md | RQ-025 | **5/10** ❌ |
| 12 | DEEP_THINK_PROMPT_STREAK_PHILOSOPHY_RQ033.md (v1) | RQ-033 | **4/10** ❌ |
| 13 | DEEP_THINK_PROMPT_STREAK_PHILOSOPHY_RQ033_v2.md | RQ-033 | **5/10** ❌ |
| 14 | DEEP_THINK_PROMPT_VIRAL_WITNESS_GROWTH_RQ040.md | RQ-040 | **5/10** ❌ |

**Result: 0/14 prompts pass. ALL need remediation.**

---

## Common Violations

### Violation 1: Undefined Terminology

| Term Used | Times | Explained? | Fix Required |
|-----------|-------|------------|--------------|
| "CD-XXX" | 50+ | Never | Explain what CDs are + full text of each |
| "RQ-XXX" | 100+ | Never | Explain what RQs are + summarize findings |
| "PD-XXX" | 20+ | Never | Explain what PDs are |
| "psyOS" | 30+ | Rarely | Full explanation of Psychological Operating System |
| "Parliament of Selves" | 20+ | Rarely | Full explanation of the philosophy |
| "Holy Trinity" | 15+ | Partially | Full explanation of Anti-Identity, Failure Archetype, Resistance Lie |
| "Sherlock Protocol" | 10+ | Never | Full explanation of onboarding conversation |
| "Council AI" | 10+ | Partially | Full explanation of facet conflict resolution |
| "JITAI" | 5+ | Never | Explain Just-In-Time Adaptive Intervention |
| "identity_topology" | 5+ | Never | Full schema with explanation |
| "Fractal Trinity" | 5+ | Never | Full explanation |
| "4-state energy model" | 10+ | Partially | Full explanation with transitions |

### Violation 2: Reference-Style Context

**Bad Pattern (Current):**
```markdown
### CD-015: psyOS Architecture ✅ CONFIRMED
- Users are treated as "Parliament of Selves"
- Facets have energy states
```

**Good Pattern (Required):**
```markdown
## What is psyOS? (ESSENTIAL CONTEXT)

"psyOS" stands for Psychological Operating System. Unlike traditional habit trackers
that treat users as a single person needing discipline, The Pact treats each user as
having multiple "identity facets" — different versions of themselves that compete
for time and attention.

**Example:** A user might have these facets:
- "The Writer" — wants to write every morning
- "The Parent" — wants to be present for kids
- "The Athlete" — wants to stay fit

These facets often CONFLICT (e.g., morning writing vs morning workout). The app
helps users recognize these conflicts and create "treaties" — agreements between
facets about when each gets priority.

**Why this matters for your research:** [Specific relevance to this prompt]
```

### Violation 3: Missing App Explanation

**None of the prompts explain:**
1. What "The Pact" is (habit/identity app)
2. Who the target users are
3. What problem it solves
4. How it's different from competitors
5. Current tech stack (Flutter, Supabase, etc.)

### Violation 4: Schema References Without Context

**Bad Pattern (Current):**
```markdown
### Existing Schema
- `identity_facets` table
- `psychometric_profile.dart`
```

**Good Pattern (Required):**
```sql
-- FULL SCHEMA (Deep Think cannot see our codebase)
CREATE TABLE identity_facets (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES profiles(id),
  name TEXT NOT NULL,              -- e.g., "The Writer", "The Parent"
  description TEXT,                -- User's description of this facet
  energy_state TEXT,               -- 'high_focus', 'high_physical', 'social', 'recovery'
  is_active BOOLEAN DEFAULT true,  -- Can be archived
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- WHY THIS EXISTS:
-- Users create facets during onboarding. Each facet represents a "version"
-- of themselves they want to develop. Habits are then assigned to facets.
```

---

## Detailed Audit: Sample Prompts

### Prompt 1: DEEP_THINK_PROMPT_IDENTITY_COACH_RQ005-RQ006-RQ007.md

| Criterion | Score | Evidence |
|-----------|-------|----------|
| App Explanation | 0/2 | No explanation of what The Pact is |
| Terminology | 1/2 | CD-015, CD-016, CD-017, CD-018 mentioned but only briefly explained |
| Architecture Context | 1/2 | Mentions tables but doesn't include full schemas |
| Philosophy Explanation | 1/2 | "Parliament of Selves" mentioned but not fully explained |
| Standalone Readability | 1/2 | Partially understandable but missing crucial context |
| **TOTAL** | **4/10** | ❌ FAIL |

**Specific Issues:**
- Line 62: "CD-005: 6-Dimension Archetype Model" — What is a CD? Why 6 dimensions?
- Line 72: "CD-015: psyOS Architecture" — What is psyOS? Brief mention but no real explanation
- Line 98: "Existing JITAI System" — What is JITAI? Never explained
- No explanation of why this research matters to the app

### Prompt 9: DEEP_THINK_PROMPT_HOLY_TRINITY_RQ037_v2.md

| Criterion | Score | Evidence |
|-----------|-------|----------|
| App Explanation | 0/2 | No explanation of what The Pact is |
| Terminology | 1/2 | "Holy Trinity" partially explained but many terms undefined |
| Architecture Context | 1/2 | References RQ-012, RQ-013 without explaining what they found |
| Philosophy Explanation | 1/2 | "Parliament of Selves" mentioned once |
| Standalone Readability | 1/2 | Better structure but still assumes context |
| **TOTAL** | **4/10** | ❌ FAIL |

**Specific Issues:**
- Line 43: "RQ-012: Fractal Trinity ✅ COMPLETE" — Summarizes findings but doesn't explain what Fractal Trinity IS
- Line 74: "CD-015: psyOS Architecture ✅ CONFIRMED" — Lists as fact, doesn't explain
- Line 99: "## Current Implementation: Code & Schema" — References files Deep Think cannot see

---

## Root Cause: Guidance File Gap

The `DEEP_THINK_PROMPT_GUIDANCE.md` file has a **critical omission**:

**Current Guidance Says:**
> "Summarize all completed RQs that inform this research"
> "List CDs that constrain the solution space"

**Guidance Should Say:**
> "Deep Think has NO CONTEXT about this project. Every prompt must be 100% self-contained."
> "Do NOT reference CDs/RQs by number — EXPLAIN them in full."
> "Do NOT reference code files — INCLUDE the relevant code inline."
> "Do NOT use internal terminology — DEFINE every term."

---

## Remediation Plan

### Phase 1: Update Guidance (IMMEDIATE)

Add new section to `DEEP_THINK_PROMPT_GUIDANCE.md`:

```markdown
## CRITICAL: Self-Containment Requirement

### The Reality of External AI Tools

External AI tools (Deep Think, Gemini, DeepSeek, etc.) have:
- ❌ NO access to our codebase
- ❌ NO memory of previous conversations
- ❌ NO knowledge of our terminology
- ❌ NO context about The Pact

**Every prompt must be 100% SELF-CONTAINED.**

### Self-Containment Checklist (MANDATORY)

Before sending ANY prompt:

- [ ] **App Explanation:** Does the prompt explain what The Pact is, who it's for, and what problem it solves?
- [ ] **Philosophy Explanation:** Is "psyOS" and "Parliament of Selves" fully explained (not just mentioned)?
- [ ] **Terminology Defined:** Are ALL internal terms (CD, RQ, PD, Holy Trinity, etc.) defined inline?
- [ ] **Schemas Inline:** Are all referenced tables included as full CREATE TABLE statements with comments?
- [ ] **Code Inline:** Is all referenced code included (not just file names)?
- [ ] **No Assumptions:** Could a developer with NO prior knowledge understand this prompt completely?

### Anti-Patterns

```
❌ "CD-015 mandates 4-state energy model"
   → Deep Think doesn't know what a CD is

❌ "Per RQ-012 findings on Fractal Trinity..."
   → Deep Think doesn't know what RQ-012 found

❌ "See identity_topology table"
   → Deep Think cannot see our database

❌ "As established in previous research..."
   → Deep Think has no memory

✅ CORRECT: Explain everything inline as if the reader knows nothing
```

### Template Addition: Foundation Context Section

Every prompt MUST begin with:

```markdown
## PART 1: WHAT IS "THE PACT"? (Essential Context for External AI)

**You have no prior knowledge of this project. This section provides essential context.**

### The App in One Paragraph
[Full explanation]

### Core Philosophy
[Explain Parliament of Selves, psyOS, etc.]

### Key Terminology
[Define every internal term that will be used]

### Tech Stack
[Flutter, Supabase, AI models, etc.]

### Why This Research Matters
[Connect to the specific research question]
```
```

### Phase 2: Prioritize Remediation

| Priority | Prompt | Reason | Effort |
|----------|--------|--------|--------|
| **P0** | Any prompt about to be sent | Prevent bad output | HIGH |
| **P1** | RQ-040 (Viral Growth) | Strategic, just created | HIGH |
| **P2** | Prompts for incomplete RQs | May still be sent | MEDIUM |
| **P3** | Prompts for complete RQs | Historical record | LOW |

### Phase 3: Create Self-Contained Template

Create `/docs/prompts/TEMPLATE_SELF_CONTAINED_DEEP_THINK.md` with:
- Full app context section
- Full terminology glossary
- Full architecture context
- Placeholder for specific research questions

---

## Recommended Immediate Actions

1. **UPDATE** `DEEP_THINK_PROMPT_GUIDANCE.md` with self-containment section
2. **CREATE** self-contained template
3. **REWRITE** RQ-040 prompt (most recent, strategic importance)
4. **FLAG** all other prompts as "DEPRECATED — needs self-containment update"

---

## Impact Assessment

| If Not Fixed | Consequence |
|--------------|-------------|
| Prompts sent to Deep Think | Confused output, missing context, irrelevant recommendations |
| Research quality | LOW — Deep Think makes assumptions that conflict with our architecture |
| Implementation | Tasks extracted from research may not fit our codebase |
| Time wasted | Reconciliation (Protocol 9) catches conflicts, but damage already done |

---

*This audit reveals a systematic gap in our prompt engineering process. Self-containment is not optional — it's the foundation of useful external research.*
