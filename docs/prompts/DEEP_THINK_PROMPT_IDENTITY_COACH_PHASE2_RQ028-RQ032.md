# Deep Think Prompt: Identity Coach Phase 2 Research

> **Target Research:** RQ-028, RQ-029, RQ-030, RQ-031, RQ-032
> **Related Decisions:** PD-121, PD-122, PD-123, PD-124
> **Prepared:** 10 January 2026 (Enhanced per DEEP_THINK_PROMPT_GUIDANCE.md)
> **For:** Google Deep Think / Claude / External AI Tool
> **App Name:** The Pact

---

## Your Role

You are a **Senior Content Strategist & AI Systems Architect** specializing in:
- Psychometric profiling and personality typology systems
- Habit recommendation content curation and taxonomy design
- Embedding-based personalization systems (vector databases, similarity search)
- User preference learning and cold-start problem resolution
- Mobile-first AI system design with battery/performance constraints

Your approach:
1. Think step-by-step. Reason through each sub-question methodically.
2. **Present 2-3 options with explicit tradeoffs** before recommending.
3. **Cite 2-3 academic papers** where applicable (personality psychology, recommendation systems, behavior change).
4. Rate each recommendation with confidence levels (HIGH/MEDIUM/LOW).
5. Classify each proposal per CD-018: ESSENTIAL/VALUABLE/NICE-TO-HAVE/OVER-ENGINEERED.

---

## Critical Instruction: Processing Order

```
RQ-028 (Archetype Template Definitions) ← CRITICAL BLOCKER
  ↓ Defines the 12 archetypes for...
RQ-029 (Ideal Dimension Vector Curation)
  ↓ Curation process enables...
RQ-032 (ICS Integration with Existing Metrics)
  ↓ ICS calculation informs...
RQ-030 (Preference Embedding Update Mechanics)
  ↓ Preference learning fine-tunes...
RQ-031 (Pace Car Threshold Validation)
```

**Why This Order Matters:**
- RQ-028 defines archetypes → RQ-029 curates habits per archetype
- RQ-032 defines ICS → RQ-030 uses ICS for drift anchoring
- RQ-031 validates thresholds → Uses ICS to personalize limits

**Dependencies:** RQ-028 must be resolved first — it defines the archetypes that all other questions reference.

---

## MANDATORY: Android-First Data Reality Audit

**CRITICAL CONSTRAINT (CD-017):** All designs must work on Android with these available signals only:

| Data Point | Android API | Permission | Battery | Available? |
|------------|-------------|------------|---------|------------|
| `foregroundApp` | UsageStatsManager | PACKAGE_USAGE_STATS | Low | YES |
| `screenOnDuration` | UsageStatsManager | PACKAGE_USAGE_STATS | Low | YES |
| `stepsLast30Min` | Google Fit / Health Connect | Health Connect | Low | YES |
| `locationZone` | Geofencing API | ACCESS_FINE_LOCATION | Medium | YES |
| `calendarEvents` | CalendarContract | READ_CALENDAR | Low | YES |
| `heartRate` | Health Connect | Health Connect | Medium | OPTIONAL (~10% users) |
| `sleepData` | Health Connect | Health Connect | Low | OPTIONAL |

**Anti-Pattern:** Do NOT design algorithms requiring wearable-only data (HRV, stress levels, continuous biometrics).

---

## Architectural Constraints (Hard Requirements)

| Constraint | Rule | Rationale |
|------------|------|-----------|
| **Database** | PostgreSQL + pgvector on Supabase | Existing infrastructure |
| **Embeddings** | 768-dim via gemini-embedding-001 | CD-016 locked |
| **LLM** | DeepSeek V3.2 for generation | Cost-effective, CD-016 |
| **Energy Model** | 4 states only (CD-015) | NOT 5 states |
| **AI Cost** | < $0.01 per recommendation batch | Budget constraint |
| **UX Friction** | Max 2 taps to dismiss/adopt | Mobile UX best practice |
| **Onboarding** | Cannot add questions beyond Day 3 | Sherlock flow locked |
| **Content** | 50 habits at launch (PD-125) | Expandable to 100 post-launch |

---

## Mandatory Context: Locked Architecture

### CD-005: 6-Dimension Archetype Model
User profiles include a 6-float vector (each dimension -1.0 to +1.0):
1. Regulatory Focus (Promotion +1 ↔ Prevention -1)
2. Autonomy/Reactance (Rebel +1 ↔ Conformist -1)
3. Action-State Orientation (Executor +1 ↔ Overthinker -1)
4. Temporal Discounting (Future +1 ↔ Present -1)
5. Perfectionistic Reactivity (Adaptive +1 ↔ Maladaptive -1)
6. Social Rhythmicity (Stable +1 ↔ Chaotic -1)

### CD-015: psyOS Architecture
- Users have multiple identity facets (e.g., "Super-Dad", "Code Ninja")
- Habits can belong to multiple facets (polymorphic)
- Facets have energy states: `high_focus`, `high_physical`, `social`, `recovery`
- Council AI mediates facet conflicts

### CD-016: AI Model Strategy
- **DeepSeek V3.2** for analyst/generator roles
- **gemini-embedding-001** for 768-dim embeddings
- JITAI bandit: Hardcoded Thompson Sampling (no LLM)

### CD-018: Engineering Threshold Framework
- **ESSENTIAL:** Must have for launch
- **VALUABLE:** Should have, adds significant value
- **NICE-TO-HAVE:** Could have, marginal benefit
- **OVER-ENGINEERED:** Skip, complexity exceeds value

### PD-125: Content Library Size (RESOLVED)
- **Decision:** Launch with 50 universal habit templates
- **Caveat:** Expand to 100 post-launch based on user feedback
- Each habit requires BOTH 768-dim semantic embedding AND 6-dim ideal_dimension_vector

---

## Current Schema Reference (Relevant Tables)

### identity_facets (existing)
```sql
CREATE TABLE identity_facets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,                    -- e.g., "Super-Dad", "Code Ninja"
  description TEXT,
  energy_state TEXT DEFAULT 'recovery',  -- high_focus | high_physical | social | recovery
  created_at TIMESTAMPTZ DEFAULT NOW(),
  -- NEEDS: archetype_template_id UUID REFERENCES archetype_templates(id)
);
```

### habit_templates (existing)
```sql
CREATE TABLE habit_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,                   -- e.g., "Morning meditation"
  description TEXT,
  category TEXT,                         -- wellness | productivity | social | etc.
  embedding VECTOR(768),                 -- Auto-generated via gemini-embedding-001
  created_at TIMESTAMPTZ DEFAULT NOW(),
  -- NEEDS: ideal_dimension_vector FLOAT[6]
);
```

### archetype_templates (NEEDED - RQ-028)
```sql
-- Proposed schema - validate or refine
CREATE TABLE archetype_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,             -- e.g., "The Builder"
  description TEXT NOT NULL,             -- 1-2 paragraph definition
  dimension_vector FLOAT[6] NOT NULL,    -- Ideal dimension profile
  embedding VECTOR(768),                 -- For facet→archetype matching
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### preference_embeddings (NEEDED - RQ-030)
```sql
-- Proposed schema - validate or refine
CREATE TABLE preference_embeddings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  embedding VECTOR(768),                 -- User taste vector
  trinity_seed VECTOR(768),              -- Anchored from Day 1 onboarding
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Prior Research: Two-Stage Hybrid Retrieval (RQ-005)

The Identity Coach uses Two-Stage Hybrid Retrieval:

**Stage 1 (Semantic):**
- 768-dim embedding similarity via pgvector
- Query: User's active facet name (e.g., "Devoted Father") + Holy Trinity context
- Returns: Top 10-20 candidate habits

**Stage 2 (Psychometric Re-ranking):**
- 6-dim cosine similarity between user's dimension vector and habit's ideal_dimension_vector
- Filters: Energy state compatibility, Pace Car constraints
- Returns: Top 1-3 recommendations

**The Problem:**
- Stage 1 embeddings are auto-generated (gemini-embedding-001)
- Stage 2 vectors require MANUAL curation (6 floats per habit)
- 12 Archetype Templates are PROPOSED but UNDEFINED

---

## Prior Research: Identity Consolidation Score (RQ-007)

**ICS Formula (proposed):**
```
ICS = Σ(Votes × Consistency) / DaysActive
```

**Visualization:**
- Seed (ICS < 0.3): New identity, fragile
- Sapling (0.3 ≤ ICS < 0.7): Growing, gaining momentum
- Oak (ICS ≥ 0.7): Established, resilient

**The Problem:**
- "Votes" is undefined (what counts as a vote?)
- Relationship to existing hexis_score and graceful_score unclear
- Scope unclear (per-facet? per-habit? per-roadmap?)

---

## Concrete Scenario: Solve This

**User:** Sarah, 34, creates a facet called "Devoted Mother" on Day 1.

### Scenario 1: Archetype Assignment (RQ-028)
Sarah's facet "Devoted Mother" needs an archetype.
- Walk through the matching process
- What happens if similarity scores are close? (e.g., 0.82 for Nurturer, 0.79 for Guardian)
- Should Sarah be notified of her archetype? Can she override it?

### Scenario 2: Habit Recommendation (RQ-029)
The Architect generates recommendations for Sarah.
- Which habits from the 50-habit library fit "Devoted Mother" + Nurturer archetype?
- Show how ideal_dimension_vector matching works
- What if Sarah has a Rebel-leaning dimension vector but Nurturer archetype?

### Scenario 3: Preference Learning (RQ-030)
Sarah dismisses 3 habit recommendations in a row:
1. "Schedule weekly family movie night" (dismissed)
2. "Read bedtime stories daily" (dismissed)
3. "Plan healthy lunches for kids" (dismissed)

- Show the exact preference embedding update calculation
- What are the α (subtraction) values?
- How do we prevent drift from her stated "Devoted Mother" aspiration?

### Scenario 4: Pace Car Decision (RQ-031)
Sarah has 4 active habits under "Devoted Mother".
- Should she receive a 5th recommendation?
- She also has 2 habits under "Ambitious Career Woman" facet
- Total habit count vs per-facet count: which applies?

### Scenario 5: ICS Calculation (RQ-032)
Sarah has been using the app for 14 days with this pattern:
- 10 habit completions across "Devoted Mother" facet
- 80% consistency (graceful_score = 0.8)
- 2 missed days

Calculate her ICS. Is she Seed, Sapling, or Oak?

---

## RQ-028: Archetype Template Definitions (CRITICAL)

### Question
What are the precise definitions, embeddings, and content libraries for each of the 12 Archetype Templates?

### Context
DeepSeek proposed 12 Global Archetypes to solve the "infinite facet names" problem. Users create custom facets ("Super-Dad", "Code Ninja") that map to curated content via vector similarity. But the archetypes themselves are undefined.

### Proposed 12 Archetypes (Validate or Revise)

| Archetype | Core Focus | Proposed Dimension Emphasis |
|-----------|------------|----------------------------|
| The Builder | Achievement, creation | Promotion, Future |
| The Nurturer | Care, relationships | Prevention, Social |
| The Warrior | Discipline, challenge | Promotion, Executor |
| The Scholar | Learning, mastery | Future, Overthinker |
| The Healer | Wellness, recovery | Prevention, Recovery |
| The Creator | Expression, art | Promotion, Rebel |
| The Guardian | Protection, stability | Prevention, Conformist |
| The Explorer | Adventure, novelty | Promotion, Present |
| The Sage | Wisdom, reflection | Future, Overthinker |
| The Leader | Influence, teams | Social, Executor |
| The Devotee | Practice, faith | Conformist, Recovery |
| The Rebel | Independence, change | Rebel, Present |

### Sub-Questions (Answer Each Explicitly)

| # | Question | Your Task |
|---|----------|-----------|
| 1 | Are these 12 archetypes psychologically grounded? | Cite 2-3 papers. Validate or propose alternatives. Justify mergers/splits. |
| 2 | What is the precise 6-dim vector for each archetype? | Provide exact `[reg, auto, action, temp, perf, social]` values with rationale. |
| 3 | What text should we embed for facet→archetype matching? | Provide embedding source text (50-100 words per archetype). |
| 4 | What 5-8 habits strongly align with each archetype? | List specific habits from a wellness/productivity domain. |
| 5 | How do we handle facet names that don't cleanly match? | Choose: nearest neighbor / weighted blend / fallback archetype. Justify. |
| 6 | Should users override automatic archetype assignment? | Recommend yes/no with UX implications. |

### Anti-Patterns to Avoid (RQ-028)
- ❌ Defining archetypes without psychological grounding (no citations)
- ❌ Dimension vectors as arbitrary numbers without rationale
- ❌ Generic habits that apply to any archetype equally
- ❌ Ignoring overlap between archetypes (Scholar vs Sage)
- ❌ Not addressing the 6-dim to 12-archetype mapping gap

### Expected Output
1. Precise archetype definitions (1-2 paragraphs each with psychological grounding)
2. 6-dim ideal_dimension_vector for each archetype (with rationale)
3. Embedding source text for each archetype (50-100 words)
4. 5-8 representative habits per archetype
5. Edge case handling recommendation with confidence level

### Related Decision: PD-121
**Question:** Should we use 12, 6, or 24 archetypes?

| Option | Archetypes | Content Burden | Matching Precision | Recommendation |
|--------|------------|----------------|-------------------|----------------|
| **A** | 12 | Moderate (12 × 50 = 600 pairings) | Good | — |
| **B** | 6 | Low (6 × 50 = 300 pairings) | Coarse | — |
| **C** | 24 | High (24 × 50 = 1200 pairings) | Excellent | — |

**Your recommendation:** Which option, with rationale and confidence level?

---

## RQ-029: Ideal Dimension Vector Curation Process

### Question
How do we systematically assign ideal_dimension_vectors to the 50 habit templates?

### Context
Two-Stage Retrieval requires every habit to have BOTH:
1. 768-dim semantic embedding (auto-generated by gemini-embedding-001)
2. 6-dim ideal_dimension_vector (manually curated)

The manual curation is a content creation burden.

### Sub-Questions (Answer Each Explicitly)

| # | Question | Your Task |
|---|----------|-----------|
| 1 | Can DeepSeek V3.2 generate dimension vectors from habit descriptions? | Design and provide the exact prompt. Show validation process. |
| 2 | What curation workflow should we use? | Specify: who, input format (sliders/dropdowns/numbers), time per habit. |
| 3 | How do we handle habits that span multiple dimension poles? | Example: "Morning meditation" — Executor or Overthinker? Propose solution. |
| 4 | Should dimension vectors update based on population learning? | Recommend yes/no with privacy/accuracy tradeoffs. |
| 5 | How do we validate vector accuracy before launch? | Propose validation methodology (A/B test? Expert review? User feedback?). |

### Anti-Patterns to Avoid (RQ-029)
- ❌ LLM-generated vectors without validation step
- ❌ Treating all 6 dimensions as equally important for every habit
- ❌ Binary (0 or 1) dimension values instead of continuous (-1 to +1)
- ❌ No process for updating vectors based on feedback

### Expected Output
1. LLM-assisted derivation prompt (if viable) — exact prompt text
2. Curation workflow specification — who, how, how long
3. Multi-polar habit handling strategy — decision tree or algorithm
4. Population learning recommendation — yes/no with rationale

---

## RQ-030: Preference Embedding Update Mechanics

### Question
How exactly does the preference embedding get updated, and what are the behavioral implications?

### Context
DeepSeek proposes a "preference embedding" (768-dim vector) that fine-tunes Stage 1 retrieval:
- When user BANS a habit → "subtract a fraction (α) of this habit's vector from the user's preference vector"
- When user ADOPTS a habit → "add a fraction (β) of this habit's vector"

But the specifics are undefined.

### Sub-Questions (Answer Each Explicitly)

| # | Question | Your Task |
|---|----------|-----------|
| 1 | What are optimal α (ban) and β (adopt) values? | Provide specific values (e.g., α=0.15, β=0.08) with rationale. |
| 2 | How do we prevent drift from stated aspirations? | Design anchoring mechanism using Trinity Seed. Provide formula. |
| 3 | Should users see their preference profile? (PD-122) | Recommend yes/no. If yes, how to visualize 768-dim? |
| 4 | Real-time updates or batched? | Recommend with performance implications on mobile. |
| 5 | How does Trinity Seed interact with learned preferences? | Provide blending formula (e.g., 0.7×Trinity + 0.3×Learned). |
| 6 | Can users reset their preference embedding? | Recommend yes/no with UX implications. |

### Anti-Patterns to Avoid (RQ-030)
- ❌ High α values causing preference whiplash (e.g., α > 0.3)
- ❌ No drift prevention mechanism (embedding drifts from aspirations)
- ❌ Real-time updates blocking UI (performance issue)
- ❌ Exposing raw 768-dim vector to users (confusing UX)

### Expected Output
1. Update algorithm specification with exact α, β values
2. Drift prevention mechanism — formula showing Trinity Seed anchoring
3. User visibility recommendation (PD-122 input)
4. Update frequency recommendation with performance analysis
5. Dart pseudocode for the update algorithm

---

## RQ-031: Pace Car Threshold Validation

### Question
Is 1 recommendation/day and 5-habit threshold optimal, or should these be dynamic?

### Context
DeepSeek's "Pace Car Protocol" specifies:
- Max 1 recommendation per day
- Only if user has < 5 active habits per facet

These thresholds lack supporting research.

### Sub-Questions (Answer Each Explicitly)

| # | Question | Your Task |
|---|----------|-----------|
| 1 | What does literature say about optimal habit acquisition rate? | Cite 2-3 papers. Validate or refine "1/day" threshold. |
| 2 | Should frequency adapt to user engagement level? | Propose personalization algorithm if recommended. |
| 3 | Is limit per-facet or total across all facets? | Recommend with multi-facet user example. |
| 4 | What happens when user explicitly requests recommendations? | Design on-demand policy (bypass limits? separate quota?). |
| 5 | Should new users get different thresholds (week 1-2)? | Propose onboarding-specific rules if applicable. |

### Anti-Patterns to Avoid (RQ-031)
- ❌ One-size-fits-all thresholds (no personalization)
- ❌ Per-facet limits causing facet favoritism
- ❌ Blocking on-demand requests (user frustration)
- ❌ Arbitrary thresholds without literature backing

### Expected Output
1. Literature-backed threshold validation (with citations)
2. Personalization strategy — algorithm or decision tree
3. Multi-facet handling specification — clear policy
4. On-demand request policy — when to bypass limits

---

## RQ-032: ICS Integration with Existing Metrics

### Question
How does Identity Consolidation Score (ICS) integrate with existing hexis_score and graceful_score?

### Context
DeepSeek proposes:
```
ICS = Σ(Votes × Consistency) / DaysActive
```

But we already have:
- `hexis_score` — undefined in current docs (needs audit)
- `graceful_score` — rolling consistency metric

Creating parallel metrics causes confusion.

### Sub-Questions (Answer Each Explicitly)

| # | Question | Your Task |
|---|----------|-----------|
| 1 | What does hexis_score currently calculate? | Audit codebase references. Define or propose deprecation. |
| 2 | Is ICS per-facet, per-habit, or per-roadmap? | Recommend scope with aggregation strategy. |
| 3 | What counts as a "Vote" in the ICS formula? | Define precisely: completion? journal? app open? |
| 4 | Should we use graceful_score as the Consistency component? | Recommend integration or separation. |
| 5 | Are Seed/Sapling/Oak thresholds (0.3, 0.7) correct? | Validate or propose alternatives with rationale. |
| 6 | What should users see? (numeric ICS? tier only? progress?) | Propose visualization spec. |

### Anti-Patterns to Avoid (RQ-032)
- ❌ Creating yet another metric without consolidating existing ones
- ❌ Undefined "Votes" term leading to implementation confusion
- ❌ ICS competing with graceful_score for user attention
- ❌ Threshold values without behavioral rationale

### Related Decision: PD-123
**Question:** Should each facet have a `typical_energy_state` field?
- This would inform ICS calculation (facet active in "wrong" energy state = lower consistency)

**Your recommendation:** Yes/no with rationale.

### Expected Output
1. hexis_score audit results — what it is, keep or deprecate
2. Metric consolidation recommendation — ICS replaces? coexists?
3. Refined ICS formula with ALL terms precisely defined
4. Visualization specification — what users see

---

## Related Decisions (Provide Input)

### PD-121: Archetype Template Count
**Your recommendation:** 12, 6, or 24 archetypes?
- Provide: Option choice, rationale (2-3 sentences), confidence (HIGH/MEDIUM/LOW)

### PD-122: User Visibility of Preference Embedding
**Your recommendation:** Should users see/edit their preference profile?
- Provide: Yes/no, how to display if yes, confidence level

### PD-123: Facet Typical Energy State Field
**Your recommendation:** Should each facet have a `typical_energy_state` field?
- Provide: Yes/no, rationale, confidence level

### PD-124: Recommendation Card Staleness Handling
**Context:** The Architect generates recommendation cards, Commander decides when to show. Cards may sit in queue for days.
**Options:** (A) No expiry, (B) 7-day TTL, (C) Context-sensitive expiry
**Your recommendation:** Which option, rationale, confidence level

---

## Output Format

### For Each RQ, Provide:

1. **Summary Answer** (2-3 sentences)
2. **Detailed Analysis** (structured by sub-questions in table format)
3. **Options Evaluated** (2-3 options with tradeoffs)
4. **Recommendation** (with confidence level and CD-018 classification)
5. **Implementation Specification:**
   - SQL `CREATE TABLE` or `ALTER TABLE` statements
   - Dart pseudocode for algorithms
   - JSON examples for data structures

### For Each PD, Provide:
1. **Recommendation** (which option)
2. **Rationale** (2-3 sentences)
3. **Confidence** (HIGH/MEDIUM/LOW)

---

## Code Expectations

Your output should include:

1. **SQL Statements** — For new tables (`archetype_templates`, `preference_embeddings`) and field additions
2. **Dart Pseudocode** — For algorithms (preference update, ICS calculation, Pace Car decision)
3. **JSON Examples** — For archetype template structure, dimension vectors

Example format:
```dart
// Preference embedding update pseudocode
void updatePreferenceEmbedding(User user, Habit habit, Action action) {
  const alpha = 0.15;  // ban subtraction
  const beta = 0.08;   // adopt addition

  if (action == Action.ban) {
    user.preferenceEmbedding -= alpha * habit.embedding;
  } else if (action == Action.adopt) {
    user.preferenceEmbedding += beta * habit.embedding;
  }

  // Anchor to Trinity Seed (drift prevention)
  user.preferenceEmbedding = 0.7 * user.trinitySeed + 0.3 * user.preferenceEmbedding;

  // Normalize to unit vector
  user.preferenceEmbedding = normalize(user.preferenceEmbedding);
}
```

---

## Output Quality Criteria

| Criterion | Question to Ask | Fail Example |
|-----------|-----------------|--------------|
| **Implementable** | Can an engineer build this without clarifying questions? | "Use a suitable algorithm" (vague) |
| **Grounded** | Are recommendations supported by cited literature? | "12 archetypes feels right" (no citations) |
| **Consistent** | Does this integrate with existing research (RQ-012, RQ-016)? | Proposing 5-state energy model (conflicts CD-015) |
| **Actionable** | Are there concrete next steps? | "Further research needed" (too vague) |
| **Bounded** | Are edge cases handled? | Only addressing happy path |
| **Quantified** | Are thresholds and values specific? | "Use a small α value" (what is small?) |

---

## Example of Good Output

For RQ-028 (Archetype Definitions), a HIGH-QUALITY answer includes:

### The Builder Archetype

**Definition:** The Builder identity archetype represents individuals driven by tangible creation and measurable achievement. Psychologically grounded in Deci & Ryan's Self-Determination Theory (1985) — specifically the competence need — and Dweck's growth mindset research (2006), Builders derive meaning from visible progress and completed work. They respond best to milestone-based feedback and struggle with abstract or unmeasurable goals. The Builder differs from the Creator in emphasis: Builders focus on completion and utility, while Creators focus on expression and novelty.

**6-Dim Vector:** `[0.8, 0.2, 0.7, 0.9, 0.5, 0.3]`
| Dimension | Value | Rationale |
|-----------|-------|-----------|
| Regulatory Focus | +0.8 | Strong Promotion orientation (achievement-driven) |
| Autonomy | +0.2 | Mild preference for structure (follows proven methods) |
| Action-State | +0.7 | Strong Executor (bias toward action over planning) |
| Temporal | +0.9 | Future-focused (works toward long-term goals) |
| Perfectionism | +0.5 | Balanced (wants quality but ships) |
| Rhythmicity | +0.3 | Mild preference for stability (sustainable habits) |

**Embedding Source Text:** "Achievement-oriented identity focused on creating, building, and completing tangible projects. Values productivity metrics, visible progress, and measurable results. Motivated by milestones and completion. Works systematically toward long-term goals while maintaining sustainable daily habits."

**Representative Habits:**
1. Complete one meaningful task before checking email
2. Maintain a "done list" alongside to-do list
3. Break large projects into visible milestones
4. Weekly review of completed work
5. Daily shipping commitment (one small completion)
6. Track productive hours with time-blocking

**Edge Case:** If facet name similarity is < 0.6 for all archetypes, assign to "The Builder" as default (most common aspiration pattern).

**Confidence:** HIGH
**Classification:** ESSENTIAL

---

## Final Checklist

Before submitting, verify:
- [ ] All sub-questions answered for each RQ (check the tables)
- [ ] All PDs have recommendations with confidence levels
- [ ] CD-018 classification applied to each proposal
- [ ] Android-first constraints respected (no wearable-only data)
- [ ] Locked decisions (CD-005, CD-015, CD-016) not contradicted
- [ ] Implementation specifications are concrete:
  - [ ] SQL statements provided
  - [ ] Dart pseudocode provided
  - [ ] JSON examples provided
- [ ] All concrete scenarios from "Solve This" section addressed
- [ ] At least 2-3 academic citations per applicable RQ
- [ ] Edge cases handled for each recommendation

---

*End of Prompt*
