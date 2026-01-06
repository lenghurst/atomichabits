# Deep Think Prompt B: Identity System Architecture

> **Target Research:** RQ-013 (Identity Topology), RQ-014 (State Economics), PD-117 (ContextSnapshot), RQ-015 (Polymorphic Habits)
> **Prepared:** 06 January 2026
> **For:** Google Deep Think / External AI Research Session
> **App Name:** The Pact

---

## Your Role

You are a **Senior Systems Architect** specializing in:
- **Behavioral psychology** (habit formation, identity theory, self-determination theory)
- **Graph theory** (relationship modeling, network analysis)
- **Mobile systems design** (battery optimization, real-time data architecture)
- **UX psychology** (cognitive load, friction reduction)

You have been retained to solve four interconnected research questions for a habit app that treats users as a "Parliament of Selves" — multiple identity facets that negotiate, conflict, and collaborate.

**Your approach:** Think like a scientist AND an engineer. Ground recommendations in literature where possible, but always deliver implementable specifications. When uncertain, state your confidence level and suggest validation experiments.

---

## Critical Instruction: Processing Order

These research questions are **interdependent**. Process them in this exact sequence:

```
┌─────────────────────────────────────────────────────────────────┐
│  STEP 1: RQ-014 (State Economics)                               │
│  ↓ Defines energy states that feed into...                      │
├─────────────────────────────────────────────────────────────────┤
│  STEP 2: RQ-013 (Identity Topology)                             │
│  ↓ Uses energy states for switching costs; feeds into...        │
├─────────────────────────────────────────────────────────────────┤
│  STEP 3: PD-117 (ContextSnapshot)                               │
│  ↓ Operationalizes energy + topology into refresh strategy...   │
├─────────────────────────────────────────────────────────────────┤
│  STEP 4: RQ-015 (Polymorphic Habits)                            │
│  ↓ Consumes context + topology for facet attribution            │
└─────────────────────────────────────────────────────────────────┘
```

**Rationale:** Each step's output constrains the next. RQ-014's energy taxonomy defines the `energyState` field in PD-117. RQ-013's friction coefficients require energy states. RQ-015's facet attribution needs both topology and context.

---

## Mandatory Context: Locked Architecture

The following research is **COMPLETE and LOCKED**. Do NOT propose alternatives to these foundations — build upon them.

### RQ-011: Multiple Identity Architecture ✅
- Users have 3-5 concurrent **identity facets** (e.g., "The Founder," "The Father," "The Athlete")
- Each facet has: `label`, `status` (active/maintenance/dormant), `archetypal_template`, `energy_state`, `tension_scores`
- Facets can conflict over time AND energy resources

### RQ-012: Fractal Trinity Architecture ✅
- **Psychometric Roots:** Deep patterns (Fear of failure, Need for control) — extracted Day 1-7
- **Psychological Manifestations:** How roots appear per facet per domain
- Uses pgvector for semantic similarity (3072-dim embeddings, HNSW index)

### RQ-016 + RQ-021 + RQ-022: Council AI System ✅
- When facets conflict (tension_score > 0.7), the **Council AI** simulates a debate
- Single-Shot Playwright model (DeepSeek V3.2 generates complete script)
- Output: Proposed **Treaty** — a user-signed agreement between facets
- Treaties use `json_logic_dart` for condition evaluation

### RQ-019: pgvector Implementation ✅
- **Embedding Model:** gemini-embedding-001 (3072-dim, Matryoshka truncation to 768)
- **Index:** HNSW (m=16, ef_construction=64)
- **Similarity:** Cosine for semantic matching

### RQ-020: Treaty-JITAI Integration ✅
- JITAI pipeline: V-O State → Safety Gates → **Treaty Check (Stage 3)** → Optimization → Content
- **ContextSnapshot** class captures 30+ fields for decision context
- `TreatyEngine` evaluates logic hooks against ContextSnapshot

### CD-015: psyOS Architecture ✅
- Full implementation at launch (not phased MVP)
- All identity facet features required

### CD-016: AI Model Strategy ✅
| Task | Model |
|------|-------|
| Embeddings | gemini-embedding-001 |
| Council AI Scripts | DeepSeek V3.2 |
| Real-time TTS | Gemini 2.5 Flash TTS |
| JITAI Logic | **Hardcoded** (no LLM in hot path) |

---

## Research Question 1: RQ-014 — State Economics & Bio-Energetic Conflicts

### Core Question
How should bio-energetic state transitions and switching costs be modeled to prevent burnout and optimize performance?

### Why This Matters First
The energy state taxonomy defines a core field in ContextSnapshot (`energyState`) and the weights in identity_topology (`switching_cost_minutes`). Every downstream decision depends on this.

### The Problem
**"The Energy Blind Spot"** — Current habit apps track only TIME conflicts while ignoring ENERGY state conflicts. Example:

> Oliver finishes a 4-hour deep coding session at 5:00 PM. He has a family dinner at 5:30 PM. Traditional apps say: "Great, you're free!" Reality: Oliver will be irritable, distracted, and "present but absent" because switching from **high_focus** to **social** requires 45-90 minutes of neurochemical transition.

### Current Hypothesis (Validate or Refine)

| State | Neurochemistry | Typical Activities | Recovery Time |
|-------|----------------|-------------------|---------------|
| `high_focus` | Dopamine/Acetylcholine | Deep work, coding, writing | 45-90 min |
| `high_physical` | Adrenaline/Endorphin | Exercise, sports, physical labor | 30-60 min |
| `social` | Oxytocin/Serotonin | Family, meetings, collaboration | 20-40 min |
| `recovery` | Parasympathetic | Rest, meditation, passive | 15-30 min |

### Sub-Questions (Answer Each Explicitly)

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Scientific Validation:** Are these 4 states grounded in neuroscience? | Cite 2-3 papers. Propose additions/removals if warranted. |
| 2 | **Asymmetric Costs:** Is `high_focus → social` harder than `social → high_focus`? | Provide directional switching cost matrix. |
| 3 | **Chronotype Modifiers:** How does chronotype shift optimal state windows? | Provide modifiers for Lion/Bear/Wolf/Dolphin. |
| 4 | **Passive Detection:** Can we infer state from device signals without explicit user input? | Propose algorithm using: screen time patterns, app usage, movement, typing cadence. |
| 5 | **HRV Integration:** Should we use HealthKit/Google Fit HRV data? | Weigh privacy, accuracy, battery. Recommend yes/no with conditions. |
| 6 | **Airlock Rituals:** What interventions help smooth transitions? | Provide 3-5 concrete "airlock" activities per transition type. |
| 7 | **Burnout Detection:** How do we detect cumulative energy debt? | Propose algorithm with thresholds and warning triggers. |
| 8 | **Facet-State Mapping:** Which states serve which facet archetypes? | Provide default mappings (can be user-overridden). |

### Anti-Patterns to Avoid
- ❌ Requiring users to manually log energy state (too high friction)
- ❌ Binary on/off states (real energy is a spectrum)
- ❌ Ignoring individual variation (chronotype, health conditions)
- ❌ Over-reliance on hardware sensors (not all users grant permissions)

### Output Required
1. **Validated State Taxonomy** — final list of states with definitions
2. **Switching Cost Matrix** — `state × state × direction` with minute ranges
3. **Chronotype Modifier Table** — adjustments per chronotype
4. **Passive Detection Algorithm** — pseudocode or decision tree
5. **Burnout Score Algorithm** — formula with inputs and thresholds
6. **Airlock Content Spec** — activities per transition type
7. **Confidence Assessment** — rate each output HIGH/MEDIUM/LOW confidence

---

## Research Question 2: RQ-013 — Identity Topology & Graph Modeling

### Core Question
How should relationships between identity facets be modeled and utilized for conflict detection, scheduling, and coaching?

### Dependency
Uses `energyState` taxonomy from RQ-014 for the `switching_cost_minutes` edge property.

### The Problem
Facets don't exist in isolation — they form a **relationship graph**:

```
         ┌──────────────┐
         │  The Father  │
         └──────┬───────┘
                │ COMPETITIVE (time)
                │ switching_cost: 45min
         ┌──────▼───────┐
         │ The Founder  │◄────── SYNERGISTIC ────► The Athlete
         └──────────────┘        (morning energy)
```

### Existing Schema Proposal (Refine If Needed)

```sql
CREATE TABLE identity_topology (
  source_facet_id UUID,
  target_facet_id UUID,
  interaction_type TEXT,        -- 'SYNERGISTIC', 'ANTAGONISTIC', 'COMPETITIVE', 'SUPPORTIVE'
  friction_coefficient FLOAT,   -- 0.0 (Flow) to 1.0 (Gridlock)
  switching_cost_minutes INT,   -- From RQ-014 state economics
  time_overlap_risk FLOAT,      -- 0.0-1.0: likelihood of schedule conflict
  PRIMARY KEY (source_facet_id, target_facet_id)
);
```

### Sub-Questions (Answer Each Explicitly)

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Edge Directionality:** Bidirectional or directed graph? | Recommend with rationale. If directed, explain asymmetry. |
| 2 | **Initial Population:** How do we bootstrap for new users? | Provide algorithm using declared facets + archetypal templates. |
| 3 | **Friction Inference:** How do we learn `friction_coefficient` from behavior? | Propose signals (late nights, irritable mornings, override patterns). |
| 4 | **JITAI Integration:** How does topology inform intervention timing? | Provide specific hooks into the JITAI pipeline (Stage 3). |
| 5 | **Conflict Detection:** What threshold triggers Council AI? | Propose formula combining tension_score + topology weights. |
| 6 | **Life Event Adaptation:** How do we detect topology changes? | Propose recalibration triggers (new baby, job change, health event). |
| 7 | **Visualization:** How do we show topology to users intuitively? | Recommend pattern (solar system? relationship map? conflict calendar?). |

### Concrete User Scenario (Solve This)

> **Oliver** has declared 3 facets: The Founder, The Father, The Athlete.
> It's Tuesday 5:00 PM. He's been in `high_focus` for 4 hours (Founder work).
> Calendar shows: Family dinner at 5:30 PM (Father) and morning run at 6:00 AM tomorrow (Athlete).
>
> **Questions the system must answer:**
> 1. Should we warn Oliver about the high_focus → social switch cost?
> 2. Should we suggest an "airlock" activity before dinner?
> 3. Is there a conflict between late-night work and the morning run?
> 4. What's the current tension_score between Founder and Father?

### Anti-Patterns to Avoid
- ❌ Requiring users to manually define all edges (too complex)
- ❌ Using a separate graph database (infrastructure complexity)
- ❌ Static topology that never updates (life changes)
- ❌ Binary conflict detection (conflicts have intensity)

### Output Required
1. **Finalized Schema** — with all fields, types, constraints
2. **Bootstrap Algorithm** — pseudocode for new user topology inference
3. **Friction Learning Algorithm** — online update mechanism
4. **JITAI Hook Specification** — exact integration points with code snippets
5. **Council Trigger Formula** — when tension_score + topology = summon Council
6. **Recalibration Logic** — triggers and process for topology updates
7. **Visualization Recommendation** — with mockup description or wireframe reference

---

## Product Decision: PD-117 — ContextSnapshot Real-time Data Architecture

### Core Question
Which context fields should be gathered in real-time vs cached, and what's the optimal refresh strategy?

### Dependency
Operationalizes `energyState` (RQ-014) and `topology` (RQ-013) into a practical refresh architecture.

### The Problem
The ContextSnapshot class has 30+ fields. Refreshing everything constantly kills battery. Never refreshing makes data stale. We need a **tiered refresh strategy**.

### Current Field Inventory

| Category | Fields | Volatility |
|----------|--------|------------|
| **Temporal** | dayOfWeek, hour, minute, isWeekend, isHoliday | Every second |
| **Location** | locationZone, isHome, isWork, inTransit | Every 5-15 min |
| **Energy** | energyState, activeFacet, lastStateChange | Minutes-hours |
| **Habit** | habitId, habitName, streakDays, lastCompletionHoursAgo | Per-completion |
| **Behavioral** | vulnerabilityScore, opportunityScore, tensionScore | Per-decision |
| **Health** | sleepHoursZScore, stressLevel, hrvZScore | Daily-hourly |
| **Calendar** | calendarBusyness, nextEventMinutes, meetingLoad | Every 15 min |
| **Digital** | distractionMinutes, apexDistractor, lastUnlock | Every 5 min |
| **Emotional** | primaryEmotion, emotionIntensity | Event-driven |

### Sub-Questions (Answer Each Explicitly)

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Temporal:** Compute on-demand or cache? | Recommend strategy. |
| 2 | **Location:** Polling vs geofencing? | Recommend with battery impact estimate. |
| 3 | **Energy State:** How to track without user burden? | Integrate RQ-014 passive detection. |
| 4 | **Tension Score:** Per-decision or scheduled? | Recommend with CPU cost analysis. |
| 5 | **Health Data:** Real-time sync or batch? | Consider API limits and privacy. |
| 6 | **Calendar:** Polling frequency? | Consider rate limits and staleness. |
| 7 | **Lazy Loading:** Which fields can be null until needed? | List fields and trigger conditions. |
| 8 | **Cache Invalidation:** What events invalidate which caches? | Provide invalidation rule table. |

### Battery Budget Constraint
Target: **< 5% daily battery impact** from The Pact's background operations.

### Output Required (Structured Decision Format)

```markdown
## PD-117: ContextSnapshot Real-time Data Architecture

### Decision
[One-sentence summary of chosen approach]

### Options Considered
| Option | Description | Battery | Accuracy | Complexity |
|--------|-------------|---------|----------|------------|

### Chosen Approach
[Detailed explanation]

### Field Refresh Strategy Table
| Field | Tier | Refresh Trigger | Max Staleness | Nullable? |
|-------|------|-----------------|---------------|-----------|

### ContextService Dart Architecture
[Class structure with key methods]

### Cache Invalidation Rules
| Event | Invalidates |
|-------|-------------|

### Battery Impact Projection
[Estimated breakdown by component]
```

---

## Research Question 4: RQ-015 — Polymorphic Habits Implementation

### Core Question
How should habits be encoded, completed, and measured differently based on the active identity facet?

### Dependency
Consumes `ContextSnapshot.activeFacet` (PD-117) and `identity_topology` (RQ-013) for intelligent attribution.

### The Problem
The same action serves different facets with different meanings:

| Action | As Athlete | As Founder | As Father |
|--------|------------|------------|-----------|
| **Morning Run** | Training (+pace, HR) | Mental clarity (+ideas) | Stress regulation (+cortisol burned) |
| **Reading** | Recovery (+variety) | Learning (+applicable) | Modeling (+quality time) |
| **Cooking** | Nutrition (+macros) | Creative outlet (+experimentation) | Bonding (+family participation) |

**Key Insight:** The *meaning* changes the neural pathway being reinforced. "I ran as an Athlete" builds athletic identity. "I ran to be a present Father" builds paternal identity.

### Current Schema (Refine If Needed)

```sql
CREATE TABLE habit_facet_links (
  habit_id UUID,
  facet_id UUID,
  contribution_weight FLOAT,      -- 0.0 to 1.0
  energy_state TEXT,              -- Required energy state for this link
  custom_metrics JSONB,           -- Facet-specific metric definitions
  feedback_template TEXT,         -- Personalized completion message
  PRIMARY KEY (habit_id, facet_id)
);

CREATE TABLE habit_completions (
  id UUID PRIMARY KEY,
  habit_id UUID,
  user_id UUID,
  completed_at TIMESTAMPTZ,
  facet_id UUID,                  -- Which facet was this attributed to?
  metrics JSONB,                  -- Actual metrics captured
  energy_state_before TEXT,
  energy_state_after TEXT
);
```

### Sub-Questions (Answer Each Explicitly)

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Attribution UX:** AI-inferred, user-selected, or hybrid? | Design the completion flow. Consider friction vs accuracy. |
| 2 | **Multi-Facet:** Can one completion serve multiple facets? | If yes, how to split credit? If no, why? |
| 3 | **Metric Divergence:** Different metrics per facet for same habit? | Propose schema changes if needed. |
| 4 | **Feedback Messages:** How should completion messages vary? | Provide template system with variables. |
| 5 | **Identity Evidence:** How does attribution affect `identity_evidence_score`? | Propose scoring formula changes. |
| 6 | **JITAI Messages:** How do nudges reference the relevant facet? | Provide message template examples. |
| 7 | **History UX:** Show facet context in completion history? | Mockup or wireframe description. |

### Concrete User Scenario (Solve This)

> **Oliver** completes "Morning Run" at 6:30 AM.
> His active facets: Founder (active), Father (active), Athlete (maintenance).
> ContextSnapshot shows: `energyState: high_physical`, `activeFacet: null` (morning ambiguity).
>
> **The app must:**
> 1. Determine which facet(s) to attribute this completion to
> 2. Show appropriate feedback message
> 3. Update identity_evidence_score correctly
> 4. Log the completion with proper metadata

### Anti-Patterns to Avoid
- ❌ Asking "which facet?" on EVERY completion (fatigue)
- ❌ Always defaulting to most recently active facet (loses nuance)
- ❌ Ignoring multi-facet completions (loses evidence)
- ❌ Same generic feedback regardless of facet (misses reinforcement opportunity)

### Output Required
1. **Attribution Flow** — decision tree or algorithm
2. **Completion UX Spec** — screens, interactions, timing
3. **Multi-Facet Handling** — if allowed, credit allocation formula
4. **Feedback Template System** — with variable substitution
5. **Scoring Integration** — changes to identity_evidence_score
6. **JITAI Template Examples** — 3-5 example messages per facet type

---

## Architectural Constraints (Hard Requirements)

| Constraint | Rule |
|------------|------|
| **Database** | Supabase (PostgreSQL + pgvector). No graph databases. |
| **AI Models** | Per CD-016. JITAI logic is **hardcoded** (no LLM in hot path). |
| **Client** | Flutter/Dart. All client-side services in Dart. |
| **Embeddings** | gemini-embedding-001 only. |
| **JSON Logic** | `json_logic_dart` for all condition evaluation. |
| **User Burden** | Cannot require explicit graph edge definition or complex configuration. |
| **Battery** | < 5% daily impact from background operations. |

---

## Output Quality Criteria

For each research question, your output will be evaluated on:

| Criterion | Question to Ask |
|-----------|-----------------|
| **Implementable** | Can an engineer build this without asking clarifying questions? |
| **Grounded** | Are recommendations supported by cited literature or clear reasoning? |
| **Consistent** | Does this integrate with existing RQ-012, RQ-016, RQ-019, RQ-020, RQ-021, RQ-022? |
| **Actionable** | Are there concrete next steps, not just principles? |
| **Bounded** | Are edge cases handled? Are failure modes addressed? |

---

## Example of Good Output (RQ-014 Partial)

This is the QUALITY BAR for your responses:

```markdown
## RQ-014: State Economics — Energy State Taxonomy

### Validated State Taxonomy

**Confidence: HIGH** (grounded in literature)

After reviewing Csikszentmihalyi (1990) on flow states, Kahneman (2011) on cognitive load,
and Sapolsky (2017) on stress neurochemistry, I recommend **5 states** (not 4):

| State | Definition | Neurochemical Signature | Recovery Needed |
|-------|------------|------------------------|-----------------|
| `deep_focus` | Single-task cognitive immersion | High dopamine, acetylcholine | 45-90 min |
| `creative` | Divergent thinking, idea generation | Moderate dopamine, alpha waves | 30-60 min |
| `physical` | Exercise, manual activity | Adrenaline, endorphins | 20-40 min |
| `social` | Interpersonal engagement | Oxytocin, serotonin | 15-30 min |
| `recovery` | Parasympathetic restoration | Low cortisol, high HRV | 10-20 min |

**Change from hypothesis:** Added `creative` state because deep_focus (convergent) and
creative (divergent) have different neurochemistry and different recovery patterns.
Merging them loses coaching precision.

### Switching Cost Matrix (Asymmetric)

**Confidence: MEDIUM** (some empirical support, needs user validation)

| From ↓ / To → | deep_focus | creative | physical | social | recovery |
|---------------|------------|----------|----------|--------|----------|
| **deep_focus** | 0 | 20 min | 45 min | **60 min** | 15 min |
| **creative** | 15 min | 0 | 30 min | 25 min | 10 min |
| **physical** | 30 min | 20 min | 0 | 15 min | 5 min |
| **social** | **45 min** | 20 min | 20 min | 0 | 10 min |
| **recovery** | 10 min | 5 min | 10 min | 5 min | 0 |

**Key asymmetry:** `deep_focus → social` (60 min) is much harder than `social → deep_focus` (45 min)
because deep focus requires residual working memory clearance that social engagement can corrupt.

### Passive Detection Algorithm

**Confidence: MEDIUM** (needs real-world validation)

```dart
EnergyState inferEnergyState(DeviceSignals signals) {
  // Rule 1: Recent exercise detected
  if (signals.stepCountLast30Min > 500 && signals.heartRateAvg > 100) {
    return EnergyState.physical;
  }

  // Rule 2: Deep focus indicators
  if (signals.singleAppFocusMinutes > 25 &&
      signals.notificationsDismissedRatio > 0.8 &&
      signals.typingBurstsPerMinute > 3) {
    return EnergyState.deepFocus;
  }

  // Rule 3: Social signals
  if (signals.messagingAppActiveMinutes > 10 ||
      signals.callDurationMinutes > 5 ||
      signals.locationZone == 'social_venue') {
    return EnergyState.social;
  }

  // Rule 4: Low activity = recovery
  if (signals.screenOffMinutes > 15 && signals.movementScore < 0.2) {
    return EnergyState.recovery;
  }

  // Default: creative (transitional state)
  return EnergyState.creative;
}
```
```

---

## Final Checklist Before Submitting

Before finalizing your response, verify:

- [ ] RQ-014 is answered FIRST (others depend on it)
- [ ] Each sub-question has an explicit answer
- [ ] All schemas include field types and constraints
- [ ] All algorithms include pseudocode or decision trees
- [ ] Confidence levels (HIGH/MEDIUM/LOW) stated for each major recommendation
- [ ] Anti-patterns section concerns are addressed
- [ ] User scenarios are solved with step-by-step reasoning
- [ ] Integration points with existing research (RQ-012, RQ-016, etc.) are explicit
- [ ] Battery budget (< 5%) is respected in PD-117
- [ ] Output follows the specified markdown structure

---

*End of Prompt B — Identity System Architecture*
