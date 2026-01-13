# Deep Think Prompt: Schema Foundation — Identity Facets & Topology

> **Target Tasks:** A-01 (identity_facets table), A-02 (identity_topology table)
> **Prepared:** 13 January 2026
> **For:** Google Deep Think / Gemini / DeepSeek
> **App Name:** The Pact

---

## Your Role

You are a **Senior Database Architect** specializing in:
- PostgreSQL schema design for psychological/behavioral applications
- Graph modeling in relational databases (without graph DB)
- Supabase constraints and best practices
- Mobile-first data patterns (minimal joins, offline-friendly)

Your approach: Think step-by-step. Consider edge cases. Optimize for query patterns.

---

## PART 1: WHAT IS "THE PACT"? (Essential Context)

**You have no prior knowledge of this project. This section provides essential context.**

### The App in One Paragraph

The Pact is a mobile app (Flutter, Android-first) that helps users build identity-based habits through psychological insight and social accountability. Unlike traditional habit trackers that count streaks, The Pact treats users as having multiple "identity facets" (e.g., "The Writer," "The Athlete," "The Present Father") that negotiate for attention. Users create "pacts" — commitments to become a certain type of person. The app's AI ("Sherlock") extracts psychological patterns during onboarding and provides coaching based on who the user wants to become.

### Core Philosophy: "Parliament of Selves"

The Pact is built on **psyOS (Psychological Operating System)** — a framework that models human identity as:

1. **One Integrated Self** with multiple **facets** (not competing personalities)
2. **Facets** can be synergistic, antagonistic, or competitive
3. **Energy States** affect which facets can be active (you can't switch instantly from deep work to parenting)
4. **Conflicts** between facets are not failures — they're integration opportunities
5. **AI Council** simulates a "roundtable" where facets can negotiate

**Why this matters for schema design:** The database must model relationships BETWEEN identity facets, not just the facets themselves. This is a graph problem in a relational database.

### Key Terminology

| Term | Definition |
|------|------------|
| **psyOS** | Psychological Operating System — the app's core framework treating identity as multiple facets negotiating for attention |
| **Identity Facet** | A distinct "version" of the user they want to develop (e.g., "The Writer", "The Athlete"). Users typically have 3-5 facets |
| **Parliament of Selves** | Metaphor: facets are like members of parliament negotiating for time/energy resources |
| **Council AI** | AI feature that simulates facets "debating" to help user make decisions |
| **Shadow Cabinet** | The "dark side" of identity — who the user fears becoming. Extracted during onboarding |
| **Energy State** | Current bio-energetic mode: `high_focus`, `high_physical`, `social`, or `recovery` |
| **Switching Cost** | Time required to transition between energy states (e.g., 45-90 min from high_focus to social) |
| **Friction Coefficient** | 0.0-1.0 score indicating how much two facets conflict (0 = synergistic, 1 = gridlock) |
| **Integration Status** | Whether conflicting facets have been reconciled: `harmonized`, `in_tension`, or `unexamined` |
| **Constellation UX** | Visual dashboard showing facets as orbiting planets around a central "Self" |

### Tech Stack

- **Frontend:** Flutter 3.38.4 (Android-first, no iOS-specific APIs)
- **Backend:** Supabase (PostgreSQL + pgvector extension)
- **AI:** DeepSeek V3.2 for reasoning, Gemini for embeddings/TTS
- **Constraint:** All queries must be efficient on mobile (minimal joins, <100ms response)

### Why This Research Matters

**The entire app is blocked.** 30+ implementation tasks in Phase G and Phase H depend on these two tables existing:
- Phase G (Identity Coach Phase 2): 14 tasks blocked
- Phase H (Constellation/Airlock): 16 tasks blocked

Getting this schema RIGHT is critical — changing it later requires migrations across production users.

---

## PART 2: Research Questions

### Question 1: `identity_facets` Table Design

**Core Question:** What is the optimal schema for storing user identity facets?

**Why This Matters:**
- This table is the CORE of the application
- Every other feature depends on it
- Poor design = performance issues + migration nightmares

**Current Proposed Schema:**

```sql
CREATE TABLE identity_facets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Core Identity
  domain TEXT NOT NULL,          -- "professional", "physical", "relational", "temporal"
  label TEXT NOT NULL,           -- "Early Riser", "The Writer"
  aspiration TEXT,               -- "I wake before the world awakens"

  -- Psychological Overlay
  dimension_adjustments JSONB,   -- {"temporal_discounting": +0.2}

  -- Conflict Tracking
  conflicts_with UUID[],         -- Array of conflicting facet IDs
  integration_status TEXT,       -- "harmonized", "in_tension", "unexamined"

  -- Energy Gating (4-state model, NOT 5-state)
  typical_energy_state TEXT,     -- "high_focus", "high_physical", "social", "recovery"

  -- Identity Coach Integration
  ics_score FLOAT,               -- Identity Consolidation Score (0.0-1.0)
  archetype_template_id UUID,    -- Links to archetype_templates table

  -- Status
  status TEXT DEFAULT 'active',  -- "active", "maintenance", "dormant"

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_reflected_at TIMESTAMPTZ  -- When user last engaged with this facet
);

-- Indexes
CREATE INDEX idx_facets_user ON identity_facets(user_id);
CREATE INDEX idx_facets_status ON identity_facets(user_id, status);
```

**Sub-Questions:**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **JSONB vs Normalized:** Should `dimension_adjustments` be JSONB or a separate `facet_dimensions` table? | Analyze query patterns, pros/cons, recommend |
| 2 | **UUID Array vs Junction:** Should `conflicts_with` be UUID[] or a separate `facet_conflicts` junction table? | Consider FK constraints, cascade deletes, query patterns |
| 3 | **Domain Enum:** Should `domain` be TEXT or a proper ENUM type? What are valid domains? | Propose complete domain list |
| 4 | **Status Enum:** Should `status` be TEXT or ENUM? Are "active/maintenance/dormant" the right states? | Propose complete status list |
| 5 | **Energy State Enum:** Should `typical_energy_state` be TEXT or ENUM? | Validate against 4-state model |
| 6 | **Soft Limit Enforcement:** How do we enforce the "5 facets per user" soft limit? | Trigger vs application logic vs check constraint |
| 7 | **Missing Fields:** What fields are MISSING from this schema? | Propose additions with rationale |

**Constraints (MUST Honor):**

| Constraint | Rule |
|------------|------|
| **Energy Model** | EXACTLY 4 states: `high_focus`, `high_physical`, `social`, `recovery` — NOT 5 |
| **Database** | PostgreSQL via Supabase — no graph databases |
| **Mobile Performance** | Queries must be efficient (<100ms on mobile) |
| **Facet Limit** | Soft limit of 5 facets per user (cognitive load) |
| **Offline Support** | Schema should support local SQLite sync in future |

---

### Question 2: `identity_topology` Table Design

**Core Question:** How should relationships between facets be modeled?

**Why This Matters:**
- This enables conflict detection
- This powers the Constellation visualization
- This informs JITAI intervention timing (don't suggest focus task when in social mode)

**Current Proposed Schema:**

```sql
CREATE TABLE identity_topology (
  source_facet_id UUID REFERENCES identity_facets(id) ON DELETE CASCADE,
  target_facet_id UUID REFERENCES identity_facets(id) ON DELETE CASCADE,

  -- Relationship Type
  interaction_type TEXT NOT NULL, -- 'SYNERGISTIC', 'ANTAGONISTIC', 'COMPETITIVE'

  -- Quantitative Metrics
  friction_coefficient FLOAT,     -- 0.0 (Flow) to 1.0 (Gridlock)
  switching_cost_minutes INT,     -- Bio-energetic recovery time

  -- Metadata
  inferred_by TEXT,               -- 'AI', 'USER', 'SYSTEM'
  confidence FLOAT,               -- AI inference confidence
  last_validated_at TIMESTAMPTZ,

  PRIMARY KEY (source_facet_id, target_facet_id)
);

-- Indexes
CREATE INDEX idx_topology_source ON identity_topology(source_facet_id);
CREATE INDEX idx_topology_target ON identity_topology(target_facet_id);
```

**Sub-Questions:**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Directionality:** Should edges be bidirectional or directed? (A→B = B→A or not?) | Analyze use cases, recommend approach |
| 2 | **Self-Loops:** Can a facet have a relationship with itself? Should we allow/prevent? | Propose constraint |
| 3 | **Interaction Types:** Are SYNERGISTIC/ANTAGONISTIC/COMPETITIVE sufficient? | Propose complete type list |
| 4 | **Default Values:** What should default friction/switching cost be for new edges? | Propose defaults with rationale |
| 5 | **Graph Queries:** How do we efficiently query "all connected facets"? | Propose query patterns |
| 6 | **Visualization Data:** What additional fields does Constellation UX need? | Propose fields for orbital mechanics visualization |
| 7 | **Temporal Conflicts:** How do we detect time-based conflicts (Early Riser vs Night Owl)? | Propose mechanism |

**Constraints:**

| Constraint | Rule |
|------------|------|
| **No Graph DB** | Must use PostgreSQL relational model only |
| **Cross-User** | Edges ONLY within same user's facets |
| **Cascade** | Deleting a facet must cascade-delete all its edges |
| **Performance** | Graph traversal queries must be efficient |

---

## PART 3: Integration Requirements

### Existing Tables (For Reference)

These tables already exist or are planned — your schema must integrate:

```sql
-- Already exists
CREATE TABLE auth.users (
  id UUID PRIMARY KEY
  -- ... Supabase auth fields
);

-- Planned (do not design, just reference)
CREATE TABLE habits (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  name TEXT,
  -- ...
);

-- Junction table (do not design, just reference)
CREATE TABLE habit_facet_links (
  habit_id UUID REFERENCES habits(id),
  facet_id UUID REFERENCES identity_facets(id),
  contribution_weight FLOAT DEFAULT 1.0,
  PRIMARY KEY (habit_id, facet_id)
);

-- Archetype templates (read-only, pre-populated)
CREATE TABLE archetype_templates (
  id UUID PRIMARY KEY,
  label TEXT,
  description TEXT,
  default_dimension_profile JSONB
);
```

### Query Patterns to Optimize For

1. **Get all facets for user:** `SELECT * FROM identity_facets WHERE user_id = ?`
2. **Get facet with all relationships:** Facet + all edges where it's source OR target
3. **Detect conflicts:** All edges where friction_coefficient > 0.5
4. **Constellation data:** All facets + all edges for visualization
5. **Energy-gated facets:** Facets matching current energy state

---

## PART 4: Output Requirements

### Deliverable 1: Finalized `identity_facets` Schema

Provide:
1. Complete `CREATE TABLE` statement with all fields
2. All indexes
3. All constraints (CHECK, UNIQUE, etc.)
4. RLS policies for Supabase
5. Migration notes (what might need changing later)

### Deliverable 2: Finalized `identity_topology` Schema

Provide:
1. Complete `CREATE TABLE` statement
2. All indexes
3. Constraint to prevent cross-user edges
4. RLS policies
5. Example graph queries (3-5 common patterns)

### Deliverable 3: Sub-Questions Answered

For each sub-question:
- Direct answer
- Rationale
- Confidence level (HIGH/MEDIUM/LOW)

### Deliverable 4: Anti-Patterns to Avoid

List 5+ schema design mistakes we should NOT make, with rationale.

### Deliverable 5: Future-Proofing Notes

What changes might we need in 6 months? Design to accommodate:
- Multiple users sharing facets (social features)
- Historical facet evolution (versioning)
- AI-inferred facets vs user-declared

---

## PART 5: Example of Good Output

**For Sub-Question 1 (JSONB vs Normalized):**

```markdown
### Sub-Question 1: JSONB vs Normalized for dimension_adjustments

**Answer:** Use JSONB

**Rationale:**
1. Dimension adjustments are rarely queried individually
2. The 6 dimensions are fixed (not dynamic)
3. Updates are atomic (all dimensions together)
4. JSONB supports indexing if needed later (GIN)
5. Avoids 6-way join for simple facet retrieval

**Confidence:** HIGH

**Caveat:** If we ever need "find all facets with temporal_discounting > 0.5",
we'd need a GIN index or denormalize. Current use cases don't require this.
```

---

## Final Checklist Before Submitting

- [ ] Each sub-question has explicit answer
- [ ] All schemas include field types and constraints
- [ ] RLS policies provided for both tables
- [ ] Example queries demonstrate common patterns
- [ ] Confidence levels stated for each recommendation
- [ ] Anti-patterns section included
- [ ] Handles edge cases (empty facets, orphaned edges, etc.)
- [ ] Integration with existing tables explicit
- [ ] Mobile performance considered

---

*End of Prompt*
