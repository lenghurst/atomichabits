# Deep Think Prompt Critique: RQ-028 through RQ-032

> **Prompt Analyzed:** `docs/prompts/DEEP_THINK_PROMPT_IDENTITY_COACH_PHASE2_RQ028-RQ032.md`
> **Framework Applied:** `docs/CORE/DEEP_THINK_PROMPT_GUIDANCE.md`
> **Date:** 10 January 2026
> **Analyst:** Claude (Opus 4.5)

---

## Executive Summary

| Category | Score | Verdict |
|----------|-------|---------|
| **Rich Context** | 7/10 | Good — missing schema examples, current state code |
| **Structured Sub-Questions** | 6/10 | Adequate — needs tabular format with explicit tasks |
| **Constraints** | 6/10 | Partial — missing UX, cost, per-RQ anti-patterns |
| **Output Format** | 8/10 | Strong — missing code expectations, quality criteria |
| **Anti-Pattern Avoidance** | 6/10 | Moderate — missing user scenario, example output |
| **Overall** | **6.6/10** | **NEEDS IMPROVEMENT** before sending to external AI |

---

## Detailed Critique: Required Characteristics

### 1. Rich Context (7/10)

| Requirement | Present? | Quality | Gap Identified |
|-------------|----------|---------|----------------|
| Prior Research Summary | ✅ | Good | Summarizes RQ-005, RQ-007 but not RQ-012/013/014/015/016 |
| Locked Decisions | ✅ | Good | CD-005, CD-015, CD-016, CD-017 present |
| Schema Examples | ❌ | **Missing** | No SQL/Dart showing `identity_facets`, `habit_templates`, existing tables |
| Current State | ⚠️ | Partial | Describes gap conceptually but no code showing current implementation |

**Recommendation:** Add "Current Schema" section with actual SQL for relevant tables.

### 2. Structured Sub-Questions (6/10)

| Requirement | Present? | Quality | Gap Identified |
|-------------|----------|---------|----------------|
| Tabular Format | ⚠️ | Partial | Sub-questions are numbered lists, not tables |
| Explicit Numbering | ✅ | Good | — |
| Task Clarity | ⚠️ | Partial | Many questions lack explicit "Your Task:" directive |
| Tradeoff Framing | ✅ | Good | Options presented for most questions |

**Recommendation:** Convert sub-questions to table format:
```markdown
| # | Question | Your Task |
|---|----------|-----------|
| 1 | Are these 12 archetypes psychologically grounded? | Cite 2-3 papers. Validate or propose alternatives. |
```

### 3. Constraints Section (6/10)

| Requirement | Present? | Quality | Gap Identified |
|-------------|----------|---------|----------------|
| Technical Constraints | ✅ | Good | Android data availability table |
| UX Constraints | ❌ | **Missing** | No friction limits, user burden limits |
| Resource Constraints | ⚠️ | Partial | Battery mentioned, no API costs or limits |
| Anti-Patterns | ⚠️ | Partial | Only one general anti-pattern |

**Recommendation:** Add explicit constraints table:
```markdown
| Constraint | Rule |
|------------|------|
| **Database** | PostgreSQL + pgvector on Supabase |
| **AI Cost** | < $0.01 per recommendation generation |
| **UX Friction** | Max 2 taps to dismiss recommendation |
| **Onboarding** | Cannot add questions beyond Day 3 Sherlock |
```

### 4. Output Format Specification (8/10)

| Requirement | Present? | Quality | Gap Identified |
|-------------|----------|---------|----------------|
| Markdown Structure | ✅ | Good | Clear structure specified |
| Code Expectations | ❌ | **Missing** | No mention of SQL, Dart, or pseudocode expected |
| Confidence Levels | ✅ | Good | Requested |
| Deliverables List | ✅ | Good | "Expected Output" per RQ |

**Recommendation:** Add explicit code expectations:
```markdown
### Code Expectations
- Provide SQL `CREATE TABLE` statements for new tables
- Provide Dart pseudocode for algorithms
- Provide JSON examples for archetype template structure
```

---

## Anti-Pattern Checklist

| Weakness | Present in Prompt? | Impact | Fix Required |
|----------|-------------------|--------|--------------|
| No Expert Role | ✅ Present (Senior Content Strategist) | — | None |
| Missing Think-Chain | ✅ Present ("Think step-by-step") | — | None |
| No Priority Sequence | ✅ Present (processing order diagram) | — | None |
| **No Examples** | ❌ **MISSING** | Model lacks quality bar | Add "Example of Good Output" section |
| **No Anti-Patterns per RQ** | ❌ **MISSING** | May repeat known mistakes | Add anti-patterns for each RQ |
| No Confidence Levels | ✅ Present | — | None |
| Single Solution | ✅ Present (asks for 2-3 options) | — | None |
| **Weak Interdependencies** | ⚠️ Partial | May solve out of order | Strengthen dependency explanations |
| **No User Scenarios** | ❌ **MISSING** | May miss UX implications | Add concrete user walkthrough |
| No Literature Guidance | ✅ Present ("Cite 2-3 papers") | — | None |
| No Validation Checklist | ✅ Present (Final Checklist) | — | None |

---

## Critical Missing Sections

### Missing 1: Example of Good Output

The prompt lacks a concrete example showing the expected quality bar.

**Add this section:**
```markdown
## Example of Good Output

For RQ-028 (Archetype Definitions), a HIGH-QUALITY answer includes:

### The Builder Archetype
**Definition:** The Builder identity archetype represents individuals driven by tangible creation and achievement. Psychologically grounded in Deci & Ryan's Self-Determination Theory (competence need) and Dweck's growth mindset research, Builders derive meaning from visible progress and completed work. They are most engaged when...

**6-Dim Vector:** `[0.8, 0.2, 0.7, 0.9, 0.5, 0.3]`
- Regulatory Focus: +0.8 (strong Promotion orientation)
- Autonomy: +0.2 (mild preference for structure)
- Action-State: +0.7 (strong Executor)
- Temporal: +0.9 (future-focused)
- Perfectionism: +0.5 (balanced)
- Rhythmicity: +0.3 (mild preference for stability)

**Embedding Source Text:** "Achievement-oriented identity focused on creating, building, and completing tangible projects. Values productivity, progress metrics, and visible results."

**Representative Habits:**
1. Complete one meaningful task before checking email
2. Maintain a "done list" alongside to-do list
3. Break large projects into visible milestones
...

**Confidence:** HIGH
**Classification:** ESSENTIAL
```

### Missing 2: User Scenario Walkthrough

**Add this section:**
```markdown
## Concrete Scenario: Solve This

**User:** Sarah, 34, creates a facet called "Devoted Mother" on Day 1.

**Question 1 (RQ-028):** Which archetype should "Devoted Mother" map to?
- Walk through the matching process
- What happens if similarity scores are close (0.82 for Nurturer, 0.79 for Guardian)?

**Question 2 (RQ-030):** Sarah dismisses 3 habit recommendations in a row.
- Show the exact preference embedding update calculation
- Provide the α values used

**Question 3 (RQ-031):** Sarah has 4 active habits under "Devoted Mother". Should she receive a recommendation?
- Apply the Pace Car rule
- Show the decision tree
```

### Missing 3: Anti-Patterns per RQ

**Add to each RQ:**
```markdown
### Anti-Patterns to Avoid (RQ-028)
- ❌ Defining archetypes without psychological grounding (no citations)
- ❌ Dimension vectors without rationale (just numbers)
- ❌ Generic habits that apply to any archetype
- ❌ Ignoring edge cases (blended archetypes)
```

### Missing 4: Current Schema Reference

**Add this section:**
```markdown
## Current Schema (Relevant Tables)

### identity_facets
```sql
CREATE TABLE identity_facets (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  name TEXT NOT NULL,           -- e.g., "Super-Dad"
  created_at TIMESTAMPTZ,
  -- archetype_template_id FK needed (RQ-028)
);
```

### habit_templates
```sql
CREATE TABLE habit_templates (
  id UUID PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  embedding VECTOR(768),        -- Auto-generated
  -- ideal_dimension_vector FLOAT[6] needed (RQ-029)
);
```
```

### Missing 5: Output Quality Criteria Table

**Add this section:**
```markdown
## Output Quality Criteria

| Criterion | Question to Ask | Fail Example |
|-----------|-----------------|--------------|
| **Implementable** | Can an engineer build this without clarifying questions? | "Use a suitable algorithm" (vague) |
| **Grounded** | Are recommendations supported by cited literature? | "12 archetypes feels right" (no citations) |
| **Consistent** | Does this integrate with existing research (RQ-012, RQ-016)? | Proposing 5-state energy model (conflicts CD-015) |
| **Actionable** | Are there concrete next steps? | "Further research needed" (too vague) |
| **Bounded** | Are edge cases handled? | Only addressing happy path |
```

---

## Priority Fixes

### P0 (Must Fix Before Sending)

1. **Add "Example of Good Output" section** — Critical for setting quality bar
2. **Add User Scenario Walkthrough** — Prevents UX oversights
3. **Convert sub-questions to tables with "Your Task" column** — Ensures explicit deliverables

### P1 (Should Fix)

4. **Add anti-patterns per RQ** — Prevents common mistakes
5. **Add Current Schema section** — Grounds proposals in reality
6. **Add Code Expectations** — Clarifies expected output format

### P2 (Nice to Have)

7. **Add Output Quality Criteria table** — Self-validation checklist
8. **Strengthen dependency explanations** — Clarify why order matters
9. **Add UX/cost constraints** — Complete constraints picture

---

## Revised Prompt Structure (Recommended)

```
1. Header (existing ✅)
2. Your Role (existing ✅)
3. Processing Order (existing ✅)
4. Android-First Audit (existing ✅)
5. Locked Architecture (existing ✅)
6. **[ADD] Current Schema Reference**
7. Prior Research (existing ✅)
8. **[ADD] Concrete User Scenario**
9. RQ-028 (convert to table sub-questions, add anti-patterns)
10. RQ-029 (convert to table, add anti-patterns)
11. RQ-030 (convert to table, add anti-patterns)
12. RQ-031 (convert to table, add anti-patterns)
13. RQ-032 (convert to table, add anti-patterns)
14. Related Decisions (existing ✅)
15. **[ADD] Architectural Constraints Table (complete)**
16. Output Format (existing ✅)
17. **[ADD] Code Expectations**
18. **[ADD] Output Quality Criteria**
19. **[ADD] Example of Good Output**
20. Final Checklist (existing ✅)
```

---

## Verdict

**Original State:** 6.6/10 — Good foundation but missing critical elements for world-class prompt engineering.

**After P0 Fixes:** Expected 8.5/10 — Ready for external AI.

---

## Post-Critique Status: FIXES APPLIED

**Date:** 10 January 2026

All P0 and P1 fixes have been applied to `DEEP_THINK_PROMPT_IDENTITY_COACH_PHASE2_RQ028-RQ032.md`:

| Fix | Status |
|-----|--------|
| Add "Example of Good Output" section | ✅ Applied — Full Builder archetype example |
| Add User Scenario Walkthrough | ✅ Applied — 5 concrete scenarios |
| Convert sub-questions to tables | ✅ Applied — All RQs use "# / Question / Your Task" format |
| Add anti-patterns per RQ | ✅ Applied — Each RQ has dedicated anti-patterns |
| Add Current Schema section | ✅ Applied — SQL for existing + proposed tables |
| Add Code Expectations | ✅ Applied — SQL, Dart, JSON expectations specified |
| Add Output Quality Criteria | ✅ Applied — 6-criterion table |
| Strengthen dependency explanations | ✅ Applied — "Why This Order Matters" section |
| Add UX/cost constraints | ✅ Applied — Architectural Constraints table |

**Revised Score:** 8.5/10 — Ready for external AI.

**Action:** Prompt is now ready to send to DeepSeek/Gemini Deep Think.

---

*This critique follows the framework established in `docs/CORE/DEEP_THINK_PROMPT_GUIDANCE.md`. All gaps are mapped to specific sections of the guidance document.*
