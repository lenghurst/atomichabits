# Deep Think Prompt: Schema Foundation — Identity Facets, State Economics & Topology

> **Target Research:** RQ-048a, RQ-048b, RQ-014, RQ-013
> **Prepared:** 14 January 2026
> **For:** Google Deep Think / Gemini 2.0 Flash Thinking
> **App Name:** The Pact
> **Priority Score:** 8.5-9.0 (CRITICAL tier per Protocol 14)
> **Processing Order:** RQ-048a → RQ-048b → RQ-014 → RQ-013

---

## PART 1: WHAT IS "THE PACT"? (Essential Context)

**You have no prior knowledge of this project. This section provides essential context.**

### The App in One Paragraph

The Pact is a mobile app (Flutter, Android-first) that helps users build identity-based habits through psychological insight and social accountability. Unlike traditional habit trackers that count streaks, The Pact treats users as having multiple "identity facets" (e.g., "The Athlete," "The Parent," "The Entrepreneur") that negotiate for attention. Users create "pacts" — commitments to become a certain type of person.

### Core Philosophy: "Parliament of Selves"

**psyOS (Psychological Operating System)** is the app's core framework:
- **The Self** = Speaker of the House (conscious observer)
- **Facets** = MPs (each with goals, values, fears, neurochemistry)
- **Conflict** = Debate to be governed, not a bug to be squashed
- **Goal** = Governance (coalition building), not Tyranny (forcing discipline)

Key insight: Users aren't monolithic — they have multiple versions of themselves competing for time/energy. The app mediates these competing selves through:
1. **Identity Facets**: Named versions of the user ("The Writer," "The Parent")
2. **Council AI**: Simulated debate between facets when conflicts arise
3. **Treaties**: Negotiated agreements between facets with enforcement hooks

### Key Terminology

| Term | Definition |
|------|------------|
| **psyOS** | Psychological Operating System — the app's core framework |
| **Identity Facet** | A named "version" of the user they want to develop (e.g., "The Athlete") |
| **Holy Trinity** | Three core psychological traits: Anti-Identity, Failure Archetype, Resistance Lie |
| **Energy State** | One of 4 bio-energetic states: `high_focus`, `high_physical`, `social`, `recovery` |
| **Switching Cost** | Time/energy required to transition between energy states |
| **JITAI** | Just-In-Time Adaptive Intervention — context-aware habit nudges |
| **ContextSnapshot** | Real-time user state (location, time, energy, calendar, etc.) |
| **Council AI** | AI-simulated debate between user's identity facets |
| **Treaty** | Negotiated agreement between facets with enforcement rules |

### Tech Stack

- **Frontend:** Flutter 3.38.4 (Android-first, CD-017)
- **Backend:** Supabase (PostgreSQL + pgvector)
- **AI:** DeepSeek V3.2 for reasoning (CD-016), Gemini for embeddings/TTS
- **Embeddings:** gemini-embedding-001 (3072 dimensions, Matryoshka truncation)

---

## PART 2: MANDATORY CONTEXT — Locked Architecture

### CD-015: 4-State Energy Model (LOCKED — Cannot Change)

The app uses exactly 4 energy states (NOT 5, NOT 3):

| State | Neurochemistry | Typical Activities | Recovery Time |
|-------|----------------|--------------------|--------------:|
| `high_focus` | Dopamine/Acetylcholine | Deep work, coding, writing | 45-90 min |
| `high_physical` | Adrenaline/Endorphin | Exercise, sports, movement | 30-60 min |
| `social` | Oxytocin/Serotonin | Family time, meetings, social | 20-40 min |
| `recovery` | Parasympathetic | Rest, sleep, meditation | 15-30 min |

**Constraint:** Any schema or algorithm MUST use these exact 4 states. Do NOT add or remove states.

### RQ-012 (Complete): Fractal Trinity Architecture

The Holy Trinity represents root psychology manifesting differently per facet:

```sql
-- Root psychology (one per user)
CREATE TABLE psychometric_roots (
  user_id UUID PRIMARY KEY,
  chronotype TEXT CHECK (chronotype IN ('lion', 'bear', 'wolf', 'dolphin')),
  root_label TEXT,  -- "Abandoned Child", "Perfectionist"
  root_embedding VECTOR(768)
);

-- Per-facet manifestations
CREATE TABLE psychological_manifestations (
  facet_id UUID PRIMARY KEY REFERENCES identity_facets(id),
  archetype_label TEXT,  -- How root manifests here
  resistance_script TEXT,
  resistance_embedding VECTOR(768)
);
```

### RQ-010a/b (Complete): Permission Accuracy Model

Just-completed research established:
- **Baseline accuracy (Time + History):** 40%
- **Location contribution:** 20%
- **Calendar contribution:** 15%
- **Biometric contribution:** 15%
- **Activity Recognition:** 10%
- **Digital Context:** 0% (DROP from MVP — OVER-ENGINEERED)

### Existing Schema (Proposed but Not Validated)

```sql
-- Identity facets table (needs field validation)
CREATE TABLE identity_facets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  domain TEXT,                    -- "professional", "physical", "relational", "temporal"
  label TEXT NOT NULL,            -- User-defined name: "The Early Riser"
  aspiration TEXT,                -- "I wake before the world awakens"
  typical_energy_state TEXT,      -- Which of the 4 states this facet operates in
  keystone_habit_id UUID,         -- Primary habit for this facet
  status TEXT DEFAULT 'active',   -- 'active', 'maintenance', 'dormant'
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_engaged_at TIMESTAMPTZ
);

-- Identity topology (relationship between facets)
CREATE TABLE identity_topology (
  source_facet_id UUID REFERENCES identity_facets(id),
  target_facet_id UUID REFERENCES identity_facets(id),
  interaction_type TEXT,          -- 'SYNERGISTIC', 'ANTAGONISTIC', 'COMPETITIVE'
  friction_coefficient FLOAT,     -- 0.0 (Flow) to 1.0 (Gridlock)
  switching_cost_minutes INT,     -- Bio-energetic recovery time
  PRIMARY KEY (source_facet_id, target_facet_id)
);
```

---

## PART 3: YOUR ROLE

You are a **Senior Systems Architect** specializing in:
- **Behavioral Psychology Systems** (IFS, ACT, SDT theories)
- **PostgreSQL Schema Design** (normalized schemas, JSONB optimization, pgvector)
- **State Machine Architecture** (FSM for energy states, facet lifecycles)
- **Cognitive Load Theory** (Miller's Law, information architecture)

Your approach:
1. Think step-by-step through each research question
2. Cite academic literature where applicable (APA format)
3. Validate assumptions against empirical research
4. Provide concrete deliverables (SQL, algorithms, matrices)

---

## PART 4: CRITICAL INSTRUCTION — Processing Order

These RQs are interdependent. Process in this exact sequence:

```
RQ-048a (Facet Domain Taxonomy)
  ↓ Output informs facet field validation
RQ-048b (Cognitive Load Facet Limits)
  ↓ Output informs database constraints
RQ-014 (State Economics)
  ↓ Output informs switching cost matrix
RQ-013 (Identity Topology)
  ↓ Output informs graph modeling
→ Final: Unified Schema Recommendation
```

---

## PART 5: RESEARCH QUESTIONS

### RQ-048a: Facet Domain Taxonomy

**Core Question:** What domain categories should identity facets be organized into?

**Why This Matters:** The `domain` field in `identity_facets` table needs validated taxonomy. Current proposal uses 4 categories but lacks empirical grounding.

**Current Hypothesis:**
| Domain | Examples | Energy State Affinity |
|--------|----------|----------------------|
| professional | Entrepreneur, Writer, Manager | high_focus |
| physical | Athlete, Runner, Yogi | high_physical |
| relational | Parent, Partner, Friend | social |
| temporal | Early Riser, Night Owl | varies |

**Sub-Questions (Answer Each):**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | Is a 4-domain taxonomy sufficient, or should it be 5-8? | Cite role theory literature (Biddle, 1979; Stryker, 2002) |
| 2 | Should "temporal" be a domain or a cross-cutting attribute? | Evaluate if chronotype belongs in domain or as separate field |
| 3 | What happens when a facet spans multiple domains? | Propose: Primary domain only vs. multi-domain tagging |
| 4 | Is there empirical support for domain-energy-state correlation? | Validate assumption that "professional" → high_focus |
| 5 | Should domains be hardcoded or user-definable? | UX friction vs. data consistency tradeoff |

**Anti-Patterns to Avoid:**
- ❌ Creating overlapping domains that confuse users
- ❌ Hardcoding too many domains (cognitive load)
- ❌ Using generic labels ("personal", "other") that don't guide behavior

**Output Required:**
1. Validated domain taxonomy (3-6 categories) with definitions
2. Recommendation: Hardcoded vs. user-definable
3. Domain → Energy State mapping matrix
4. Confidence Assessment: HIGH/MEDIUM/LOW

---

### RQ-048b: Cognitive Load Facet Limits

**Core Question:** How many identity facets can users effectively manage?

**Why This Matters:** We need to set database constraints (`CHECK` clauses) to prevent cognitive overload while not artificially limiting power users.

**Current Hypothesis:**
- **Soft limit:** 5 facets (based on working memory research)
- **Hard cap:** 10 facets (based on Miller's Law 7±2)

**Sub-Questions (Answer Each):**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | What does cognitive load research say about identity management? | Cite Miller (1956), Cowan (2001), Sweller (1988) |
| 2 | Is 5 the right soft limit for active facets? | Distinguish "active" vs "maintenance" vs "dormant" |
| 3 | Should limits vary by user experience level? | New users vs. 90-day veterans |
| 4 | How do other identity-based apps handle limits? | Competitive analysis (if available) |
| 5 | What's the UX for hitting the limit? | "You have 5 active facets. Archive one to add another?" |

**Anti-Patterns to Avoid:**
- ❌ No limits (leads to facet sprawl, abandoned facets)
- ❌ Arbitrary limits without rationale (frustrates users)
- ❌ Hard blocking without graceful degradation

**Output Required:**
1. Recommended limits: `active_limit`, `maintenance_limit`, `total_limit`
2. SQL constraint implementation
3. UX copy for limit warnings
4. Confidence Assessment: HIGH/MEDIUM/LOW

---

### RQ-014: State Economics & Bio-Energetic Conflicts

**Core Question:** How should bio-energetic state transitions and switching costs be modeled?

**Why This Matters:**
- Deep Think identified "The Energy Blind Spot" — tracking time conflicts while ignoring energy costs
- Switching from `high_focus` (Deep Work) to `social` (Family) has massive bio-energetic cost even if time is available
- This research validates the CD-015 4-state model and produces the switching cost matrix

**Current Hypothesis (from earlier research):**

| From ↓ / To → | high_focus | high_physical | social | recovery |
|---------------|:----------:|:-------------:|:------:|:--------:|
| **high_focus** | 0 | 15 min | **45 min** | 20 min |
| **high_physical** | 20 min | 0 | 15 min | 15 min |
| **social** | **30 min** | 15 min | 0 | 10 min |
| **recovery** | 25 min | 30 min | 15 min | 0 |

**Sub-Questions (Answer Each):**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | Does neuroscience support these 4 states? | Cite dopamine/cortisol/oxytocin research |
| 2 | Are switching costs symmetric or asymmetric? | Is focus→social same as social→focus? |
| 3 | How does chronotype affect switching? | Lions (morning) vs Wolves (evening) |
| 4 | Should costs be absolute or relative to user fitness? | Population defaults vs personalization |
| 5 | What interventions reduce switching costs? | "Airlock" rituals, breathing exercises |
| 6 | How do we detect current energy state passively? | Signals from Health Connect, app usage, calendar |

**Anti-Patterns to Avoid:**
- ❌ Requiring explicit energy state logging (too much friction)
- ❌ Ignoring switching costs in JITAI timing
- ❌ Over-complicating with 6+ states

**Output Required:**
1. Validated 4-state taxonomy (or propose revision with evidence)
2. Complete 4×4 asymmetric switching cost matrix with citations
3. Chronotype modifier table (per chronotype)
4. Passive detection algorithm pseudocode
5. Airlock ritual specifications per transition type
6. Confidence Assessment: HIGH/MEDIUM/LOW

---

### RQ-013: Identity Topology & Graph Modeling

**Core Question:** How should relationships between identity facets be modeled and utilized?

**Why This Matters:**
- Facets don't exist in isolation — "Athlete" and "Early Riser" are synergistic
- "Night Owl" and "Early Riser" are antagonistic
- "Entrepreneur" and "Present Parent" compete for time
- JITAI needs to understand these relationships for conflict detection

**Current Hypothesis:**

```sql
CREATE TABLE identity_topology (
  source_facet_id UUID,
  target_facet_id UUID,
  interaction_type TEXT,  -- 'SYNERGISTIC', 'ANTAGONISTIC', 'COMPETITIVE'
  friction_coefficient FLOAT,  -- 0.0-1.0
  switching_cost_minutes INT,
  PRIMARY KEY (source_facet_id, target_facet_id)
);
```

**Sub-Questions (Answer Each):**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | How do we initially populate the topology? | AI inference vs user declaration |
| 2 | Should edges be bidirectional or directed? | Is Athlete→Parent same as Parent→Athlete? |
| 3 | What are the exact definitions of each interaction type? | SYNERGISTIC, ANTAGONISTIC, COMPETITIVE semantics |
| 4 | How does friction_coefficient affect JITAI? | Thresholds for conflict detection |
| 5 | Should we use graph database or relational? | pgvector + adjacency list vs Neo4j |
| 6 | How do we detect when topology has changed? | Life events, new jobs, births |

**Anti-Patterns to Avoid:**
- ❌ Requiring users to manually define all edges (too complex)
- ❌ Static topology that never adapts
- ❌ Separate graph database (infrastructure complexity)

**Output Required:**
1. Finalized schema with all fields typed
2. Interaction type definitions with examples
3. Auto-inference algorithm for initial topology
4. Friction coefficient thresholds (when to trigger Council AI)
5. Integration with JITAI decision pipeline
6. Confidence Assessment: HIGH/MEDIUM/LOW

---

## PART 6: ARCHITECTURAL CONSTRAINTS (Hard Requirements)

| Constraint | Rule |
|------------|------|
| **Database** | Supabase (PostgreSQL + pgvector). No Neo4j or external graph DB. |
| **Energy States** | Exactly 4 states per CD-015. Cannot add/remove states. |
| **AI Models** | DeepSeek V3.2 for analysis, Gemini for embeddings (CD-016) |
| **Client** | Android-first (CD-017). Must work without iOS/wearables. |
| **Complexity** | ESSENTIAL/VALUABLE/NICE-TO-HAVE threshold (CD-018) |

---

## PART 7: OUTPUT QUALITY CRITERIA

| Criterion | Question to Ask |
|-----------|-----------------|
| **Implementable** | Can an engineer build this without clarifying questions? |
| **Grounded** | Are recommendations supported by cited literature? |
| **Consistent** | Does this integrate with existing research (RQ-012, RQ-010a/b)? |
| **Actionable** | Are there concrete next steps? |
| **Bounded** | Are edge cases handled (empty topology, 0 facets, etc.)? |

---

## PART 8: EXAMPLE OF GOOD OUTPUT

**For RQ-014 Sub-Question 2 (Switching Cost Asymmetry):**

> **Finding:** Switching costs ARE asymmetric. Focus→Social requires more recovery than Social→Focus due to attentional inertia (Monsell, 2003).
>
> **Evidence:** Ophir et al. (2009) demonstrated that interruptions to focused work require 23 minutes average recovery, while initiating focus after social interaction averages 12 minutes.
>
> **Revised Matrix:**
> | From ↓ / To → | focus | physical | social | recovery |
> |---------------|-------|----------|--------|----------|
> | focus | 0 | 15 | **45** | 20 |
> | social | **25** | 15 | 0 | 10 |
>
> **Confidence:** HIGH (multiple replicated studies)

---

## PART 9: DELIVERABLES CHECKLIST

By the end of your response, provide:

- [ ] **RQ-048a:** Validated domain taxonomy (3-6 categories) with SQL ENUM
- [ ] **RQ-048b:** Facet limit recommendations with SQL CHECK constraints
- [ ] **RQ-014:** Complete 4×4 switching cost matrix with citations
- [ ] **RQ-014:** Chronotype modifier table
- [ ] **RQ-014:** Passive energy state detection pseudocode
- [ ] **RQ-013:** Finalized `identity_topology` schema
- [ ] **RQ-013:** Interaction type definitions
- [ ] **RQ-013:** Auto-inference algorithm
- [ ] **UNIFIED:** Combined schema recommendation for Phase A
- [ ] **CONFIDENCE:** Rating for each section (HIGH/MEDIUM/LOW)

---

## PART 10: FINAL CHECKLIST BEFORE SUBMITTING

- [ ] Each sub-question has explicit answer
- [ ] All schemas include field types and constraints
- [ ] All algorithms include pseudocode
- [ ] Confidence levels stated for each recommendation
- [ ] Anti-patterns addressed
- [ ] User scenarios solved step-by-step
- [ ] Integration points with existing research explicit

---

*End of Prompt*
