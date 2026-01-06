# Deep Think Prompt B: Identity System Architecture

> **Target Research:** RQ-013 (Identity Topology), RQ-014 (State Economics), PD-117 (ContextSnapshot), RQ-015 (Polymorphic Habits)
> **Prepared:** 06 January 2026
> **For:** Google Deep Think / External AI Research Session
> **App Name:** The Pact

---

## Context Priming

You are researching for "The Pact," an identity-first habit app implementing the **psyOS (Psychological Operating System)** architecture. The app treats users as a **Parliament of Selves** — a dynamic system of negotiating identity facets rather than a monolithic person.

### Already Completed Research (Mandatory Context)

The following research has been completed and represents **locked architecture decisions**. Your research MUST build upon and integrate with these foundations:

#### RQ-011: Multiple Identity Architecture — ✅ COMPLETE
**Decision:** Identity Facets Model
- Users have 3-5 concurrent identity facets (e.g., "The Founder," "The Father," "The Athlete")
- Each facet has:
  - `label`: User-defined name
  - `status`: `active` | `maintenance` | `dormant`
  - `archetypal_template`: Hardcoded dimension adjustments
  - `energy_state`: Bio-energetic mode (see RQ-014)
  - `tension_scores`: JSONB mapping to other facets

#### RQ-012: Fractal Trinity Architecture — ✅ COMPLETE
**Decision:** Root + Manifestation Model
- **Psychometric Roots:** Deep patterns (Fear of failure, Need for control)
- **Psychological Manifestations:** How roots manifest per facet
- **Schema (with pgvector):**
```sql
CREATE TABLE psychometric_roots (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  root_type TEXT, -- 'anti_identity', 'failure_archetype', 'resistance_lie'
  content TEXT,
  root_embedding VECTOR(3072),
  extraction_date TIMESTAMPTZ
);

CREATE TABLE psychological_manifestations (
  id UUID PRIMARY KEY,
  root_id UUID REFERENCES psychometric_roots(id),
  facet_id UUID REFERENCES identity_facets(id),
  domain TEXT, -- 'health', 'relationships', 'work', 'creativity'
  resistance_script TEXT,
  resistance_embedding VECTOR(3072),
  coaching_strategy TEXT
);
```

#### RQ-019: pgvector Implementation — ✅ COMPLETE
- **Embedding Model:** gemini-embedding-001 (3072-dim, Matryoshka-compatible)
- **Index:** HNSW (m=16, ef_construction=64)
- **Truncation:** Store 3072, query at 768 for efficiency
- **Similarity:** Cosine similarity for semantic matching

#### RQ-020: Treaty-JITAI Integration — ✅ COMPLETE
**Decision:** Stage 3 Treaty Check
- Treaties are user-signed agreements between identity facets
- Evaluated after Safety Gates, before Optimization
- Uses `json_logic_dart` for condition evaluation
- **ContextSnapshot** class captures 30+ fields for decision context

#### CD-015: psyOS Architecture — ✅ CONFIRMED
The app uses full psyOS at launch (not phased MVP). All identity facet features are required.

#### CD-016: AI Model Strategy — ✅ CONFIRMED
| Task | Model |
|------|-------|
| Embeddings | gemini-embedding-001 |
| Council AI Scripts | DeepSeek V3.2 |
| Real-time TTS | Gemini 2.5 Flash TTS |
| JITAI Logic | Hardcoded (no LLM calls) |

---

## Research Questions for This Session

### RQ-013: Identity Topology & Graph Modeling

**Core Question:** How should relationships between identity facets be modeled and utilized for conflict detection, scheduling, and coaching?

**Context:**
Facets don't exist in isolation — they interact through complex relationships:
- **Synergistic:** Athlete + Morning Person (shared morning routines)
- **Antagonistic:** Night Owl + Early Riser (mutually exclusive time needs)
- **Competitive:** Founder + Present Father (compete for the same time blocks)
- **Supportive:** Health Guardian + All Facets (enables energy for others)

**Existing Schema Proposal (from RQ-011):**
```sql
CREATE TABLE identity_topology (
  source_facet_id UUID,
  target_facet_id UUID,
  interaction_type TEXT, -- 'SYNERGISTIC', 'ANTAGONISTIC', 'COMPETITIVE', 'SUPPORTIVE'
  friction_coefficient FLOAT, -- 0.0 (Flow) to 1.0 (Gridlock)
  switching_cost_minutes INT, -- Bio-energetic recovery time
  PRIMARY KEY (source_facet_id, target_facet_id)
);
```

**Sub-Questions Requiring Deep Analysis:**

| # | Question | Context | Implications |
|---|----------|---------|--------------|
| 1 | **Edge Directionality:** Should topology edges be bidirectional or directed? | "Founder → Father" transition may have different cost than "Father → Founder" | Graph model complexity, algorithm requirements |
| 2 | **Initial Population:** How do we bootstrap topology for new users? | Can't expect users to define all edges manually | AI inference from declared facets, progressive refinement |
| 3 | **Friction Inference:** How do we calculate `friction_coefficient` from behavioral data? | Late night work sessions followed by irritable mornings = high friction | Signal detection, learning algorithm |
| 4 | **JITAI Integration:** How does topology inform intervention timing? | If user is in "high_focus" (Founder), don't suggest "family dinner" (Father) | Decision engine hooks, treaty interaction |
| 5 | **Conflict Detection:** What threshold triggers Council AI summon? | Two facets competing for overlapping time blocks | tension_score calculation (existing), topology input |
| 6 | **Life Event Adaptation:** How do we detect topology changes (new baby, job change)? | User's facet relationships evolve over months/years | Change detection, recalibration prompts |
| 7 | **Graph Visualization:** What UX pattern makes topology intuitive to non-technical users? | "Solar System" (RQ-017) may not show edges well | Alternative: relationship mapping, conflict calendars |

**Constraints:**
- Must integrate with existing `tension_score` calculation (RQ-020)
- Must inform Council AI context (RQ-016, RQ-022)
- Cannot require explicit user edge definition (too high friction)
- Prefer relational (Supabase) over graph DB (infrastructure simplicity)

**Output Expected:**
1. Finalized graph model specification (nodes, edges, properties)
2. Algorithm for topology inference from behavioral signals
3. Edge weight update mechanism (online learning vs batch)
4. JITAI integration points with specific code hooks
5. Conflict detection threshold recommendations
6. Visualization approach recommendation

---

### RQ-014: State Economics & Bio-Energetic Conflicts

**Core Question:** How should bio-energetic state transitions and switching costs be modeled to prevent burnout and optimize performance?

**Context:**
Deep Think's prior analysis identified "The Energy Blind Spot" — current systems track only TIME conflicts while ignoring ENERGY state conflicts. Switching from "Deep Work Coder" (high_focus) to "Present Father" (social) has massive switching costs even when time is available.

**Current Energy State Hypothesis (from RQ-011):**

| State | Neurochemistry | Typical Activities | Recovery Time |
|-------|----------------|-------------------|---------------|
| `high_focus` | Dopamine/Acetylcholine | Deep work, coding, writing | 45-90 min |
| `high_physical` | Adrenaline/Endorphin | Exercise, sports, physical labor | 30-60 min |
| `social` | Oxytocin/Serotonin | Family time, meetings, collaboration | 20-40 min |
| `recovery` | Parasympathetic activation | Rest, meditation, light activities | 15-30 min |

**Sub-Questions Requiring Deep Analysis:**

| # | Question | Context | Research Direction |
|---|----------|---------|-------------------|
| 1 | **Scientific Validation:** Are these 4 states grounded in neuroscience literature? | Need citations and potential refinements | Literature review, expert validation |
| 2 | **Switching Cost Matrix:** Are transitions symmetric or asymmetric? | `high_focus → social` may be harder than `social → high_focus` | Empirical studies, user research |
| 3 | **Chronotype Interaction:** How does chronotype modify energy states? | Night owls have different `high_focus` windows | RQ-012 Chronotype-JITAI Matrix integration |
| 4 | **Passive Detection:** Can we infer energy state from device signals? | Screen time patterns, movement, typing speed | Privacy vs utility tradeoff |
| 5 | **HRV Integration:** Should we use Apple/Google Health data for energy? | HRV indicates parasympathetic activation | Permission requirements, accuracy |
| 6 | **Airlock Design:** What interventions facilitate smooth transitions? | "Transition Airlock" treaty template (RQ-021) needs content | Breathwork, micro-rituals, buffer activities |
| 7 | **Burnout Prevention:** How do we detect cumulative energy debt? | Multiple forced switches per day = burnout risk | Long-term tracking, warning thresholds |
| 8 | **Facet-State Mapping:** Which energy states serve which facets? | "The Father" may need `social` but "The Athlete" needs `high_physical` | Facet archetype templates |

**Integration Requirements:**
- Must feed into ContextSnapshot (PD-117)
- Must influence JITAI timing decisions
- Must inform Council AI conflict detection (tension_score)
- Should integrate with Airlock Protocol (RQ-018) when researched

**Current ContextSnapshot Fields (from RQ-020):**
```dart
class ContextSnapshot {
  // Time
  final String dayOfWeek;
  final int hour;
  final int minute;
  final bool isWeekend;

  // Location
  final String locationZone; // 'home', 'work', 'gym', 'transit', 'other'

  // Energy (THIS IS WHAT RQ-014 MUST SPECIFY)
  final String? energyState; // 'high_focus', 'high_physical', 'social', 'recovery'
  final String? activeFacet;

  // Scores
  final double vulnerabilityScore;
  final double opportunityScore;
  final double tensionScore;

  // 30+ more fields...
}
```

**Output Expected:**
1. Validated energy state taxonomy (add/remove/rename states?)
2. Complete switching cost matrix (state × state × direction)
3. Chronotype modifiers per state
4. Passive detection algorithm specification
5. Airlock intervention content recommendations
6. Burnout detection algorithm
7. Facet-to-energy-state mapping guidelines

---

### PD-117: ContextSnapshot Real-time Data Architecture

**Core Question:** Which context fields should be gathered in real-time vs cached, and what's the optimal refresh strategy for battery life vs accuracy?

**Context:**
The ContextSnapshot class (RQ-020) captures 30+ fields to inform JITAI decisions. Some fields change constantly (time), some rarely (chronotype), and some are expensive to compute (tension_score). We need a formal refresh architecture.

**Current Field Inventory (from RQ-020):**

| Category | Fields | Count |
|----------|--------|-------|
| Temporal | dayOfWeek, hour, minute, isWeekend, isHoliday | 5 |
| Location | locationZone, isHome, isWork, inTransit | 4 |
| Energy | energyState, activeFacet, lastStateChange | 3 |
| Habit | habitId, habitName, streakDays, lastCompletionHoursAgo | 4 |
| Behavioral | vulnerabilityScore, opportunityScore, tensionScore | 3 |
| Health | sleepHoursZScore, stressLevel, hrvZScore | 3 |
| Calendar | calendarBusyness, nextEventMinutes, meetingLoad | 3 |
| Digital | distractionMinutes, apexDistractor, lastUnlock | 3 |
| Emotional | primaryEmotion, emotionIntensity | 2 |
| **Total** | | **~30** |

**Sub-Questions Requiring Deep Analysis:**

| # | Question | Tradeoffs |
|---|----------|-----------|
| 1 | **Temporal fields:** Compute on every decision or cache? | CPU vs accuracy (always use computed) |
| 2 | **Location tracking:** Every 5 min, 15 min, or geofence only? | Battery vs precision (geofence preferred) |
| 3 | **Energy state:** User-declared, inferred, or hybrid? | Friction vs accuracy |
| 4 | **Tension score:** Per-decision or hourly batch? | CPU cost vs responsiveness |
| 5 | **Health integration:** Real-time sync or morning batch? | API limits, user privacy |
| 6 | **Calendar sync:** How often to poll calendar API? | Rate limits, staleness |
| 7 | **Emotional state:** Voice session only or passive detection? | Privacy, accuracy |
| 8 | **Lazy loading:** Which expensive fields can be null until needed? | Complexity vs performance |

**Battery Impact Analysis Required:**

| Tier | Target Refresh | Max Battery | Example Fields |
|------|----------------|-------------|----------------|
| **Static** | Once / Never | 0% | chronotype, facet definitions, user prefs |
| **Slow** | 60 min | ~1%/day | calendar context, tension_score |
| **Medium** | 15 min | ~3%/day | location_zone |
| **Fast** | Per-decision | Varies | temporal, vulnerability, opportunity |
| **Event-driven** | On trigger | Varies | emotion (post-voice), sleep (on wake) |

**Output Expected:**
1. Complete field refresh strategy table
2. Lazy loading specification (which fields can be null)
3. Battery impact projections
4. Event-driven refresh triggers
5. ContextService Dart class architecture
6. Cache invalidation rules

---

### RQ-015: Polymorphic Habits Implementation

**Core Question:** How should habits be encoded, completed, and measured differently based on the active identity facet?

**Context:**
The same physical action (e.g., "Morning Run") serves different identity facets with different meanings and metrics:

| Facet | Same Action | Meaning | Metrics | Feedback |
|-------|-------------|---------|---------|----------|
| **Athlete** | Morning Run | Training | Pace, HR zone, distance | "+10 Physical Points" |
| **Founder** | Morning Run | Mental clarity | Ideas generated, silence | "+10 Clarity Points" |
| **Father** | Morning Run | Stress regulation | Cortisol burned | "Safe to go home" |

**Key Insight:** When checking off a habit, the user should validate "Who did this serve?" — reinforcing the specific neural pathway and identity.

**Sub-Questions Requiring Deep Analysis:**

| # | Question | UX Impact | Data Model Impact |
|---|----------|-----------|-------------------|
| 1 | **Attribution UX:** Automatic (AI-inferred) or user-selected? | Friction vs accuracy | ML model vs explicit field |
| 2 | **Multi-facet completion:** Can one action serve multiple facets? | Cognitive load | Many-to-many join table |
| 3 | **Metric divergence:** How do we track different metrics per facet? | Dashboard complexity | Polymorphic metrics schema |
| 4 | **Feedback variation:** Should completion messages vary by facet? | Content library growth | Template system |
| 5 | **JITAI messaging:** How do intervention messages reference active facet? | Personalization depth | Message template variables |
| 6 | **History display:** Show facet context in completion history? | Dashboard information density | UI component complexity |
| 7 | **Identity evidence:** How does facet attribution affect identity_evidence_score? | Core metric validity | Scoring algorithm changes |

**Current Schema (from RQ-011):**
```sql
CREATE TABLE habit_facet_links (
  habit_id UUID,
  facet_id UUID,
  contribution_weight FLOAT, -- 0.0 to 1.0
  energy_state TEXT, -- Required energy state for this link
  custom_metrics JSONB, -- Facet-specific metric definitions
  feedback_template TEXT,
  PRIMARY KEY (habit_id, facet_id)
);

CREATE TABLE habit_completions (
  id UUID PRIMARY KEY,
  habit_id UUID,
  user_id UUID,
  completed_at TIMESTAMPTZ,
  facet_id UUID, -- Which facet was this completion attributed to?
  metrics JSONB, -- Actual metrics captured
  energy_state_before TEXT,
  energy_state_after TEXT
);
```

**Output Expected:**
1. Facet attribution UX flow specification
2. Multi-facet completion handling
3. Polymorphic metrics schema
4. Feedback template system
5. Identity evidence scoring integration
6. JITAI message personalization guidelines

---

## Architectural Constraints

Your research MUST adhere to these locked decisions:

1. **Database:** Supabase (PostgreSQL + pgvector). No graph databases.
2. **AI Models:** As per CD-016. JITAI logic is hardcoded (no LLM in hot path).
3. **Client:** Flutter/Dart. All client-side services in Dart.
4. **Embeddings:** gemini-embedding-001 for all semantic matching.
5. **JSON Logic:** `json_logic_dart` for Treaty condition evaluation.
6. **No User Burden:** Cannot require users to explicitly define graph edges, switching costs, or complex configurations. Must be inferred or simplified.

---

## Output Format

Please provide your research in the following structure:

### For Each Research Question:

```markdown
## RQ-0XX: [Title]

### Summary
[2-3 sentence summary of findings]

### Sub-Questions Answered
| # | Question | Answer | Rationale |
|---|----------|--------|-----------|

### Specification
[Detailed technical specification with schemas, algorithms, code samples]

### Integration Points
[How this integrates with existing architecture]

### Implementation Checklist
| Task | Priority | Component |
|------|----------|-----------|

### Open Questions (if any)
[Questions that couldn't be fully resolved]
```

### For Product Decision:

```markdown
## PD-117: [Title]

### Decision
[Clear statement of the chosen approach]

### Options Considered
| Option | Description | Pros | Cons |

### Rationale
[Why this option was selected]

### Specification
[Detailed implementation spec]
```

---

## Success Criteria

This research session is successful if:

1. **RQ-013:** Complete graph model with inference algorithm and JITAI integration hooks
2. **RQ-014:** Validated energy taxonomy with switching cost matrix and detection algorithm
3. **PD-117:** Complete refresh strategy with battery projections and Dart architecture
4. **RQ-015:** Polymorphic habit UX flow with schema and scoring integration

All outputs must be:
- Implementable by engineers without further clarification
- Consistent with existing RQ-012, RQ-016, RQ-019, RQ-020, RQ-021, RQ-022 research
- Traceable to the psyOS vision (Parliament of Selves)

---

## Appendix: Related Files (For Reference)

| File | Content |
|------|---------|
| `docs/CORE/PRODUCT_DECISIONS.md` | All confirmed and pending decisions |
| `docs/CORE/RESEARCH_QUESTIONS.md` | All research questions with findings |
| `docs/CORE/GLOSSARY.md` | psyOS terminology definitions |
| `lib/domain/services/jitai_decision_engine.dart` | Current JITAI implementation |
| `lib/data/models/context_snapshot.dart` | (To be created) |
| `lib/domain/services/treaty_engine.dart` | (To be created) |

---

*End of Prompt B*
