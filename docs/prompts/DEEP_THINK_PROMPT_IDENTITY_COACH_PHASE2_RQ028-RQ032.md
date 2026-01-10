# Deep Think Prompt: Identity Coach Phase 2 Research

> **Target Research:** RQ-028, RQ-029, RQ-030, RQ-031, RQ-032
> **Related Decisions:** PD-121, PD-122, PD-123, PD-124
> **Prepared:** 10 January 2026
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

### PD-125: Content Library Size (RESOLVED)
- **Decision:** Launch with 50 universal habit templates
- **Caveat:** Expand to 100 post-launch based on user feedback
- Each habit requires BOTH 768-dim semantic embedding AND 6-dim ideal_dimension_vector

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

### Sub-Questions to Address

1. **Validation:** Are these 12 archetypes psychologically grounded? Should any be merged, split, or replaced?

2. **Dimension Vectors:** What is the precise 6-dim ideal_dimension_vector for each archetype?
   - Format: `[reg_focus, autonomy, action_state, temporal, perfectionism, social_rhythmicity]`
   - Each value: -1.0 to +1.0

3. **Semantic Embeddings:** What text description should we embed for each archetype to enable facet→archetype matching?

4. **Content Mapping:** For each archetype, what are 5-8 representative habits that strongly align?

5. **Edge Cases:** How do we handle facet names that don't cleanly match any archetype?
   - Option A: Nearest neighbor (always assign)
   - Option B: Multi-archetype blend (weighted average)
   - Option C: "General" fallback archetype

6. **User Override:** Should users be able to manually change their facet's archetype assignment?

### Expected Output
- Precise archetype definitions (1-2 paragraphs each with psychological grounding)
- 6-dim ideal_dimension_vector for each archetype (with rationale)
- Embedding source text for each archetype
- 5-8 representative habits per archetype
- Edge case handling recommendation

### Related Decision: PD-121
**Question:** Should we use 12, 6, or 24 archetypes?
- Option A (12): Good coverage, moderate content burden
- Option B (6): Less content, coarser matching (one per dimension pole)
- Option C (24): Better matching, heavy content burden (dimension × 4 quadrants)

---

## RQ-029: Ideal Dimension Vector Curation Process

### Question
How do we systematically assign ideal_dimension_vectors to the 50 habit templates?

### Context
Two-Stage Retrieval requires every habit to have BOTH:
1. 768-dim semantic embedding (auto-generated by gemini-embedding-001)
2. 6-dim ideal_dimension_vector (manually curated)

The manual curation is a content creation burden.

### Sub-Questions to Address

1. **LLM-Assisted Derivation:**
   - Can DeepSeek V3.2 generate dimension vectors from habit descriptions?
   - What prompt engineering ensures accurate output?
   - What validation process catches errors?

2. **Curation Workflow:**
   - Who curates (Oliver? AI-assisted? Expert panel)?
   - What input format is ergonomic (sliders? dropdowns? free numbers)?
   - How long does it take per habit?

3. **Multi-Polar Habits:**
   - How do we handle habits that span multiple dimension poles?
   - Example: "Morning meditation" could be Future+Overthinker OR Present+Executor
   - Should we allow multiple dimension vectors per habit?

4. **Population Learning:**
   - Should dimension vectors be adjustable based on aggregated user feedback?
   - If users with Rebel profiles consistently adopt a habit, should we shift its vector?

### Expected Output
- LLM-assisted derivation prompt (if viable)
- Curation workflow specification
- Multi-polar habit handling strategy
- Population learning recommendation (yes/no with rationale)

---

## RQ-030: Preference Embedding Update Mechanics

### Question
How exactly does the preference embedding get updated, and what are the behavioral implications?

### Context
DeepSeek proposes a "preference embedding" (768-dim vector) that fine-tunes Stage 1 retrieval:
- When user BANS a habit → "subtract a fraction (α) of this habit's vector from the user's preference vector"
- When user ADOPTS a habit → "add a fraction (β) of this habit's vector"

But the specifics are undefined.

### Sub-Questions to Address

1. **Update Algorithm:**
   - What is α (ban subtraction fraction)? Suggested: 0.1 to 0.3
   - What is β (adoption addition fraction)? Suggested: 0.05 to 0.15
   - Should we use exponential decay for older signals?

2. **Drift Prevention:**
   - How do we prevent preference embedding from drifting away from stated aspirations?
   - Should Trinity Seed (from Day 1 onboarding) anchor the embedding?
   - What's the interaction formula?

3. **User Visibility (Related: PD-122):**
   - Should users see their preference profile?
   - If yes, how do we translate 768-dim to understandable concepts?
   - Should users be able to reset their preference embedding?

4. **Update Frequency:**
   - Real-time (every signal) vs. batched (daily)?
   - Performance implications on mobile?

5. **Cold Start Interaction:**
   - How does preference embedding interact with Trinity Seed during first week?
   - Should Trinity Seed dominate initially, then fade?

### Expected Output
- Update algorithm specification (with α, β values)
- Drift prevention mechanism
- User visibility recommendation
- Update frequency recommendation

---

## RQ-031: Pace Car Threshold Validation

### Question
Is 1 recommendation/day and 5-habit threshold optimal, or should these be dynamic?

### Context
DeepSeek's "Pace Car Protocol" specifies:
- Max 1 recommendation per day
- Only if user has < 5 active habits per facet

These thresholds lack supporting research.

### Sub-Questions to Address

1. **Literature Review:**
   - What does behavior change literature say about optimal habit acquisition rate?
   - Is there evidence for cognitive load limits on simultaneous habits?

2. **Personalization:**
   - Should recommendation frequency adapt to user engagement level?
   - Should the 5-habit threshold be personalized based on user history?

3. **Multi-Facet Users:**
   - If user has 3 facets, is the limit 1/day total or 1/day/facet?
   - How do we prevent facet favoritism?

4. **On-Demand Requests:**
   - What happens when user explicitly asks for recommendations?
   - Should on-demand bypass Pace Car limits?

5. **Onboarding Velocity:**
   - Should new users (week 1-2) get more recommendations to build momentum?
   - Or should we be MORE conservative to prevent overwhelm?

### Expected Output
- Literature-backed threshold validation
- Personalization strategy (if recommended)
- Multi-facet handling specification
- On-demand request policy

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

### Sub-Questions to Address

1. **hexis_score Audit:**
   - What does hexis_score currently calculate?
   - Where is it used in the codebase?
   - Should it be deprecated or merged with ICS?

2. **Scope Clarity:**
   - Is ICS per-facet, per-habit, or per-roadmap?
   - If per-facet, how do we aggregate to user-level?

3. **"Votes" Definition:**
   - What counts as a vote? (habit completion? journal entry? app open?)
   - Should votes be weighted by difficulty?

4. **Consistency Calculation:**
   - Should we use graceful_score as the Consistency component?
   - Or calculate separately (streak-based vs. rolling)?

5. **Visualization:**
   - Seed/Sapling/Oak thresholds (0.3, 0.7) — are these right?
   - Should we show numeric ICS or only tier?
   - Should users see progress toward next tier?

### Related Decision: PD-123
**Question:** Should each facet have a `typical_energy_state` field?
- This would inform ICS calculation (facet active in "wrong" energy state = lower consistency)

### Expected Output
- hexis_score audit results
- Metric consolidation recommendation (ICS replaces? coexists?)
- Refined ICS formula with all terms defined
- Visualization specification

---

## Related Decisions (Provide Input)

### PD-121: Archetype Template Count
**Your recommendation:** 12, 6, or 24 archetypes? (with rationale)

### PD-122: User Visibility of Preference Embedding
**Your recommendation:** Should users see/edit their preference profile?

### PD-123: Facet Typical Energy State Field
**Your recommendation:** Should each facet have a `typical_energy_state` field?

### PD-124: Recommendation Card Staleness Handling
**Context:** The Architect generates recommendation cards, Commander decides when to show. Cards may sit in queue for days.
**Your recommendation:** No expiry, 7-day TTL, or context-sensitive expiry?

---

## Output Format

For each RQ, provide:

1. **Summary Answer** (2-3 sentences)
2. **Detailed Analysis** (structured by sub-questions)
3. **Options Evaluated** (2-3 options with tradeoffs)
4. **Recommendation** (with confidence level and CD-018 classification)
5. **Implementation Specification** (schema changes, algorithm pseudocode, content requirements)

For each PD, provide:
1. **Recommendation** (which option)
2. **Rationale** (2-3 sentences)
3. **Confidence** (HIGH/MEDIUM/LOW)

---

## Final Checklist

Before submitting, verify:
- [ ] All sub-questions addressed for each RQ
- [ ] All PDs have recommendations
- [ ] CD-018 classification applied to each proposal
- [ ] Android-first constraints respected (no wearable-only data)
- [ ] Locked decisions (CD-005, CD-015, CD-016) not contradicted
- [ ] Implementation specifications are concrete (not vague)
