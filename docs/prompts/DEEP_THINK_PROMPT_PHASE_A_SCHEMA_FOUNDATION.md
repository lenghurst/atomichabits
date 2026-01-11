# Deep Think Prompt: Phase A — psyOS Schema Foundation

> **Target:** Phase A Tasks (A-01 through A-12) — Critical Database Schema
> **Prepared:** 11 January 2026
> **For:** Implementation Agent (Claude Code, Cursor, or Human Engineer)
> **App Name:** The Pact (psyOS — Psychological Operating System)
> **Priority:** P0 — IMMEDIATE (Unblocks 104 of 116 downstream tasks)

---

## Executive Context: Why This Is Critical

**Current State:**
- 31/39 Research Questions COMPLETE (79%)
- 116 Implementation Tasks defined
- **0 tasks can proceed** — ALL blocked by missing Phase A schema

**The Blocker:**
```
❌ Phase A Schema: 0% Complete
    │
    ├──► Phase B (Intelligence): 17 tasks BLOCKED
    ├──► Phase C (Council AI): 13 tasks BLOCKED
    ├──► Phase D (UX Frontend): 14 tasks BLOCKED
    ├──► Phase E (Polish): 10 tasks BLOCKED
    ├──► Phase F (Identity Coach): 20 tasks BLOCKED
    ├──► Phase G (Coach Intelligence): 14 tasks BLOCKED
    └──► Phase H (Constellation/Airlock): 16 tasks BLOCKED

    TOTAL: 104 tasks waiting on YOUR output
```

**This prompt produces:** Production-ready SQL migrations that unblock the entire psyOS implementation.

---

## Your Role

You are a **Senior Database Architect** specializing in:
- **PostgreSQL** (advanced features, pgvector, RLS, triggers, JSONB)
- **Supabase** (auth integration, Edge Functions, realtime)
- **Psychological data modeling** (identity systems, behavioral economics)
- **Privacy-first design** (RLS policies, data minimization)

**Your approach:**
- Produce COMPLETE, EXECUTABLE SQL migrations — not pseudocode
- Follow existing migration patterns in this codebase
- Include ALL security (RLS), performance (indexes), and maintenance (triggers) concerns
- Handle edge cases and failure modes explicitly

---

## Critical Instruction: Processing Order

Create migrations in this EXACT order (each table may depend on the previous):

```
┌────────────────────────────────────────────────────────────────────────────────┐
│  STEP 1: A-01 — Enable pgvector extension                                       │
│  ↓ Required for embedding storage in subsequent tables                          │
├────────────────────────────────────────────────────────────────────────────────┤
│  STEP 2: A-06 — Create habits table (MISSING FK target)                         │
│  ↓ conversations.habit_id references this; currently broken                     │
├────────────────────────────────────────────────────────────────────────────────┤
│  STEP 3: A-02 — Create psychometric_roots table                                 │
│  ↓ Foundation for Fractal Trinity (deep patterns)                               │
├────────────────────────────────────────────────────────────────────────────────┤
│  STEP 4: A-03 — Create identity_facets table                                    │
│  ↓ Core Parliament of Selves model — CRITICAL BLOCKER                          │
├────────────────────────────────────────────────────────────────────────────────┤
│  STEP 5: A-07 — Create psychological_manifestations table                       │
│  ↓ How roots manifest per facet per domain                                      │
├────────────────────────────────────────────────────────────────────────────────┤
│  STEP 6: A-04 — Create identity_topology table                                  │
│  ↓ Facet-to-facet relationships graph                                           │
├────────────────────────────────────────────────────────────────────────────────┤
│  STEP 7: A-08 — Create habit_facet_links table                                  │
│  ↓ Many-to-many: habits serve multiple facets                                   │
├────────────────────────────────────────────────────────────────────────────────┤
│  STEP 8: A-05 — Create treaties table                                           │
│  ↓ Council AI output — agreements between facets                                │
├────────────────────────────────────────────────────────────────────────────────┤
│  STEP 9: A-11 — Create treaty_history table                                     │
│  ↓ Amendment audit trail                                                        │
├────────────────────────────────────────────────────────────────────────────────┤
│  STEP 10: A-09 — Create archetype_templates table                               │
│  ↓ 12 global archetypes for facet mapping                                       │
├────────────────────────────────────────────────────────────────────────────────┤
│  STEP 11: A-10 — Create user_tokens table                                       │
│  ↓ Council Seal token economy                                                   │
├────────────────────────────────────────────────────────────────────────────────┤
│  STEP 12: A-12 — Create token_transactions table                                │
│  ↓ Token earn/spend ledger                                                      │
└────────────────────────────────────────────────────────────────────────────────┘
```

---

## Mandatory Context: Locked Architecture (DO NOT DEVIATE)

### CD-015: psyOS Architecture ✅ LOCKED
Users are a "Parliament of Selves" — multiple identity facets negotiating for resources.
- 3-5 concurrent facets per user
- Facets have status: `active`, `maintenance`, `dormant`
- Conflict resolution via Council AI → Treaties

### CD-016: AI Model Strategy ✅ LOCKED
| Task | Model | Implication |
|------|-------|-------------|
| Embeddings | gemini-embedding-001 | 3072-dim vectors (Matryoshka truncation to 768) |
| Council AI | DeepSeek V3.2 | Script generation |
| JITAI Logic | Hardcoded | json_logic_dart for condition evaluation |

### CD-015: 4-State Energy Model ✅ LOCKED
```sql
-- ONLY these 4 states are valid. DO NOT add a 5th.
CHECK (energy_state IN ('high_focus', 'high_physical', 'social', 'recovery'))
```

### Existing Schema Patterns (FOLLOW THESE)

From `supabase/migrations/20260102_identity_seeds.sql`:

```sql
-- Pattern 1: Standard table structure
CREATE TABLE public.table_name (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  -- fields...
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Pattern 2: Indexes
CREATE INDEX idx_table_user ON public.table_name(user_id);

-- Pattern 3: RLS (CRITICAL for sensitive data)
ALTER TABLE public.table_name ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own data"
  ON public.table_name FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own data"
  ON public.table_name FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own data"
  ON public.table_name FOR UPDATE
  USING (auth.uid() = user_id);

-- Pattern 4: Auto-update timestamp trigger
CREATE TRIGGER update_table_updated_at
  BEFORE UPDATE ON public.table_name
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

### Existing Tables (REFERENCE ONLY — DO NOT RECREATE)

| Table | Status | Reference |
|-------|--------|-----------|
| `auth.users` | ✅ Exists | Supabase Auth (FK target) |
| `public.profiles` | ✅ Exists | User profile data |
| `public.identity_seeds` | ✅ Exists | Holy Trinity extraction |
| `public.habit_contracts` | ✅ Exists | Builder-Witness partnerships |
| `public.witness_events` | ✅ Exists | Accountability notifications |
| `public.evidence_logs` | ✅ Exists | Behavioral signal logging |
| `public.conversations` | ✅ Exists | Voice coaching sessions |
| `public.archetype_priors` | ✅ Exists | Thompson Sampling priors |

---

## Research Context: Completed Specifications

### From RQ-011 + RQ-012: Fractal Trinity Architecture ✅

**Psychometric Roots:** Deep patterns extracted Day 1-7
- Root fears (e.g., "Fear of irrelevance")
- Root needs (e.g., "Need for control")
- Temperament baseline

**Psychological Manifestations:** How roots appear per facet × domain
- Same fear manifests differently as Founder vs Father
- Uses pgvector for semantic pattern matching

### From RQ-013: Identity Topology ✅

```sql
-- Recommended schema from research
CREATE TABLE identity_topology (
  source_facet_id UUID REFERENCES identity_facets(id),
  target_facet_id UUID REFERENCES identity_facets(id),
  interaction_type TEXT CHECK (interaction_type IN (
    'SYNERGISTIC',    -- Facets reinforce each other
    'ANTAGONISTIC',   -- Facets oppose each other
    'COMPETITIVE',    -- Facets compete for same resource (time/energy)
    'SUPPORTIVE'      -- One facet enables the other
  )),
  friction_coefficient FLOAT CHECK (friction_coefficient BETWEEN 0.0 AND 1.0),
  switching_cost_minutes INT CHECK (switching_cost_minutes >= 0),
  time_overlap_risk FLOAT CHECK (time_overlap_risk BETWEEN 0.0 AND 1.0),
  last_conflict_at TIMESTAMPTZ,
  conflict_count INT DEFAULT 0,
  PRIMARY KEY (source_facet_id, target_facet_id)
);
```

### From RQ-014: State Economics ✅

**Energy State Switching Costs (locked to 4 states per CD-015):**

| From ↓ / To → | high_focus | high_physical | social | recovery |
|---------------|------------|---------------|--------|----------|
| **high_focus** | 0 | 45 min | 60 min | 15 min |
| **high_physical** | 30 min | 0 | 15 min | 5 min |
| **social** | 45 min | 20 min | 0 | 10 min |
| **recovery** | 10 min | 10 min | 5 min | 0 |

### From RQ-015: Polymorphic Habits ✅

```sql
-- Habits can serve multiple facets with different meanings
CREATE TABLE habit_facet_links (
  habit_id UUID REFERENCES habits(id) ON DELETE CASCADE,
  facet_id UUID REFERENCES identity_facets(id) ON DELETE CASCADE,
  contribution_weight FLOAT CHECK (contribution_weight BETWEEN 0.0 AND 1.0),
  energy_state TEXT CHECK (energy_state IN ('high_focus', 'high_physical', 'social', 'recovery')),
  custom_metrics JSONB DEFAULT '{}',
  feedback_template TEXT,
  PRIMARY KEY (habit_id, facet_id)
);
```

### From RQ-020 + RQ-024: Treaties ✅

```sql
-- Council AI output — agreement between facets
CREATE TABLE treaties (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Treaty metadata
  title TEXT NOT NULL,
  description TEXT,
  treaty_type TEXT CHECK (treaty_type IN ('HARD', 'SOFT')),
  status TEXT CHECK (status IN ('ACTIVE', 'PAUSED', 'SUSPENDED', 'REPEALED', 'PROBATION')),

  -- Involved facets
  primary_facet_id UUID REFERENCES identity_facets(id),
  secondary_facet_id UUID REFERENCES identity_facets(id),

  -- Logic hooks for JITAI
  logic_hooks JSONB NOT NULL DEFAULT '{}',  -- json_logic_dart conditions

  -- Lifecycle
  ratified_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  paused_until TIMESTAMPTZ,

  -- Amendment tracking (RQ-024)
  version INT DEFAULT 1,
  parent_treaty_id UUID REFERENCES treaties(id),
  last_amended_at TIMESTAMPTZ,

  -- Breach tracking
  breach_count INT DEFAULT 0,
  last_breach_at TIMESTAMPTZ,
  probation_started_at TIMESTAMPTZ,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### From RQ-025 + RQ-039: Token Economy ✅

**Note:** Token earning mechanism is DEFERRED pending RQ-039 sub-research. Schema should support multiple earning paths.

```sql
-- Council Seal tokens
CREATE TABLE user_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  balance INT DEFAULT 0 CHECK (balance >= 0),
  lifetime_earned INT DEFAULT 0,
  lifetime_spent INT DEFAULT 0,
  last_earned_at TIMESTAMPTZ,
  last_spent_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT one_wallet_per_user UNIQUE (user_id)
);

CREATE TABLE token_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  amount INT NOT NULL,  -- Positive = earn, Negative = spend
  transaction_type TEXT CHECK (transaction_type IN (
    'WEEKLY_REVIEW',      -- Earn: completed weekly review
    'CONSISTENCY_STREAK', -- Earn: 7-day streak
    'COUNCIL_SUMMON',     -- Spend: manual council access
    'PREMIUM_GRANT',      -- Earn: subscription bonus
    'CRISIS_BYPASS',      -- Spend: auto-used during crisis (logged only)
    'ADMIN_ADJUSTMENT'    -- Manual correction
  )),
  reference_id UUID,       -- FK to source (review_id, streak_id, council_session_id)
  reference_type TEXT,     -- 'review', 'streak', 'council_session'
  balance_before INT NOT NULL,
  balance_after INT NOT NULL,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### From RQ-028: Archetype Templates ✅

```sql
-- 12 Global Archetypes for facet mapping
CREATE TABLE archetype_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,  -- 'Builder', 'Nurturer', 'Warrior', etc.
  display_name TEXT NOT NULL,
  description TEXT,

  -- 6-dimension vector (CD-005)
  dimension_vector FLOAT[6] NOT NULL,  -- [regulatory, autonomy, action_state, temporal, perfectionism, social]

  -- Typical energy state (CD-015)
  typical_energy_state TEXT CHECK (typical_energy_state IN ('high_focus', 'high_physical', 'social', 'recovery')),

  -- Content generation
  coaching_tone TEXT,        -- 'challenging', 'nurturing', 'analytical', 'playful'
  motivation_drivers TEXT[], -- ['achievement', 'connection', 'mastery']
  warning_signs TEXT[],      -- ['overwork', 'isolation', 'perfectionism']

  -- Embedding for similarity matching
  embedding VECTOR(768),     -- gemini-embedding-001

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Task Specifications (Produce These Outputs)

### A-01: Enable pgvector Extension

```sql
-- Enable pgvector for embedding storage
-- Must run BEFORE any VECTOR columns are created
CREATE EXTENSION IF NOT EXISTS vector;
```

**Verification:** After execution, `SELECT * FROM pg_extension WHERE extname = 'vector';` returns 1 row.

---

### A-06: Create habits Table (MISSING FK TARGET)

**Problem:** `public.conversations.habit_id` references `habits(id)` but `habits` table was never created.

**Requirement:** Create minimal habits table that:
1. Satisfies the FK constraint
2. Supports polymorphic habit links (RQ-015)
3. Stores habit templates with dual embeddings (RQ-005)

```sql
CREATE TABLE public.habits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,  -- NULL for template habits

  -- Core habit data
  name TEXT NOT NULL,
  description TEXT,
  icon TEXT,
  color TEXT,

  -- Template vs user habit
  is_template BOOLEAN DEFAULT FALSE,
  template_id UUID REFERENCES habits(id),  -- If user habit, link to template

  -- Scheduling
  frequency TEXT CHECK (frequency IN ('daily', 'weekly', 'custom')),
  target_days INT[] DEFAULT '{1,2,3,4,5,6,7}',  -- 1=Mon, 7=Sun
  target_time TIME,

  -- Dimensions (CD-005)
  ideal_dimension_vector FLOAT[6],  -- For template matching

  -- Energy context (CD-015)
  preferred_energy_state TEXT CHECK (preferred_energy_state IN ('high_focus', 'high_physical', 'social', 'recovery', NULL)),

  -- Embeddings for recommendation (RQ-005)
  content_embedding VECTOR(768),      -- What the habit IS (semantic)
  psychometric_embedding VECTOR(768), -- Who it's FOR (style)

  -- Status
  is_active BOOLEAN DEFAULT TRUE,
  archived_at TIMESTAMPTZ,

  -- Streaks (RQ-033: Resilient Streak)
  current_streak INT DEFAULT 0,
  best_streak INT DEFAULT 0,
  last_completed_at TIMESTAMPTZ,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_habits_user ON public.habits(user_id);
CREATE INDEX idx_habits_template ON public.habits(template_id);
CREATE INDEX idx_habits_active ON public.habits(is_active) WHERE is_active = TRUE;

-- Embedding similarity search
CREATE INDEX idx_habits_content_embedding ON public.habits
  USING hnsw (content_embedding vector_cosine_ops);
CREATE INDEX idx_habits_psychometric_embedding ON public.habits
  USING hnsw (psychometric_embedding vector_cosine_ops);

-- RLS
ALTER TABLE public.habits ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own habits and templates"
  ON public.habits FOR SELECT
  USING (user_id = auth.uid() OR is_template = TRUE);

CREATE POLICY "Users can insert own habits"
  ON public.habits FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own habits"
  ON public.habits FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own habits"
  ON public.habits FOR DELETE
  USING (auth.uid() = user_id);

-- Trigger
CREATE TRIGGER update_habits_updated_at
  BEFORE UPDATE ON public.habits
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

---

### A-02: Create psychometric_roots Table

**Purpose:** Deep psychological patterns extracted during Days 1-7 (Sherlock Protocol).

```sql
CREATE TABLE public.psychometric_roots (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- === ROOT PATTERNS (Extracted Day 1-7) ===
  root_fears TEXT[] DEFAULT '{}',           -- ['irrelevance', 'abandonment', 'failure']
  root_needs TEXT[] DEFAULT '{}',           -- ['control', 'recognition', 'security']
  root_values TEXT[] DEFAULT '{}',          -- ['authenticity', 'growth', 'connection']
  temperament_baseline JSONB DEFAULT '{}',  -- Big 5 approximation

  -- === EXTRACTION METADATA ===
  extraction_day INT CHECK (extraction_day BETWEEN 1 AND 7),
  extraction_quality_score FLOAT CHECK (extraction_quality_score BETWEEN 0.0 AND 1.0),
  sherlock_session_id UUID,                 -- Link to conversation that extracted

  -- === EMBEDDINGS ===
  root_embedding VECTOR(768),               -- Semantic representation of root patterns

  -- === SYNC ===
  hive_last_updated TIMESTAMPTZ,
  sync_status TEXT DEFAULT 'synced' CHECK (sync_status IN ('pending', 'synced', 'conflict')),

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  CONSTRAINT one_root_per_user UNIQUE (user_id)
);

-- Indexes
CREATE INDEX idx_psychometric_roots_user ON public.psychometric_roots(user_id);
CREATE INDEX idx_psychometric_roots_embedding ON public.psychometric_roots
  USING hnsw (root_embedding vector_cosine_ops);

-- RLS (CRITICAL - highly sensitive data)
ALTER TABLE public.psychometric_roots ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own roots"
  ON public.psychometric_roots FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own roots"
  ON public.psychometric_roots FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own roots"
  ON public.psychometric_roots FOR UPDATE
  USING (auth.uid() = user_id);

-- Trigger
CREATE TRIGGER update_psychometric_roots_updated_at
  BEFORE UPDATE ON public.psychometric_roots
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

---

### A-03: Create identity_facets Table ⭐ CRITICAL

**Purpose:** Core Parliament of Selves model. Each facet is an aspirational identity the user is developing.

```sql
CREATE TABLE public.identity_facets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- === FACET IDENTITY ===
  label TEXT NOT NULL,                      -- User-defined: "The Founder", "The Father"
  description TEXT,
  icon TEXT,
  color TEXT,

  -- === ARCHETYPE MAPPING (RQ-028) ===
  archetype_template_id UUID REFERENCES archetype_templates(id),
  archetype_confidence FLOAT CHECK (archetype_confidence BETWEEN 0.0 AND 1.0),

  -- === LIFECYCLE STATUS ===
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'maintenance', 'dormant')),
  activated_at TIMESTAMPTZ DEFAULT NOW(),
  last_active_at TIMESTAMPTZ DEFAULT NOW(),
  dormant_since TIMESTAMPTZ,

  -- === ENERGY CONTEXT (CD-015) ===
  typical_energy_state TEXT CHECK (typical_energy_state IN ('high_focus', 'high_physical', 'social', 'recovery')),
  preferred_time_blocks JSONB DEFAULT '[]',  -- [{"start": "06:00", "end": "09:00"}, ...]

  -- === SCORING (RQ-032) ===
  ics_score FLOAT DEFAULT 0.0 CHECK (ics_score BETWEEN 0.0 AND 1.0),  -- Identity Consolidation Score
  identity_evidence_count INT DEFAULT 0,
  last_evidence_at TIMESTAMPTZ,

  -- === DIMENSIONS (CD-005) ===
  dimension_vector FLOAT[6],                -- [regulatory, autonomy, action_state, temporal, perfectionism, social]

  -- === EMBEDDINGS ===
  facet_embedding VECTOR(768),              -- Semantic representation for matching

  -- === PREFERENCE LEARNING (RQ-030) ===
  preference_embedding VECTOR(768),         -- Rocchio-updated from interactions
  trinity_seed VECTOR(768),                 -- Anchor from Day 1 Holy Trinity

  -- === DISPLAY ORDER ===
  display_order INT DEFAULT 0,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_identity_facets_user ON public.identity_facets(user_id);
CREATE INDEX idx_identity_facets_status ON public.identity_facets(status);
CREATE INDEX idx_identity_facets_archetype ON public.identity_facets(archetype_template_id);
CREATE INDEX idx_identity_facets_embedding ON public.identity_facets
  USING hnsw (facet_embedding vector_cosine_ops);
CREATE INDEX idx_identity_facets_preference ON public.identity_facets
  USING hnsw (preference_embedding vector_cosine_ops);

-- RLS
ALTER TABLE public.identity_facets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own facets"
  ON public.identity_facets FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own facets"
  ON public.identity_facets FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own facets"
  ON public.identity_facets FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own facets"
  ON public.identity_facets FOR DELETE
  USING (auth.uid() = user_id);

-- Trigger
CREATE TRIGGER update_identity_facets_updated_at
  BEFORE UPDATE ON public.identity_facets
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Constraint: Max 5 active facets per user
CREATE OR REPLACE FUNCTION check_active_facet_limit()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'active' THEN
    IF (SELECT COUNT(*) FROM identity_facets
        WHERE user_id = NEW.user_id AND status = 'active' AND id != NEW.id) >= 5 THEN
      RAISE EXCEPTION 'Maximum 5 active facets per user';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enforce_active_facet_limit
  BEFORE INSERT OR UPDATE ON public.identity_facets
  FOR EACH ROW
  EXECUTE FUNCTION check_active_facet_limit();
```

---

### A-04: Create identity_topology Table

**Purpose:** Graph edges between facets representing relationships (synergy, competition, antagonism).

```sql
CREATE TABLE public.identity_topology (
  source_facet_id UUID NOT NULL REFERENCES identity_facets(id) ON DELETE CASCADE,
  target_facet_id UUID NOT NULL REFERENCES identity_facets(id) ON DELETE CASCADE,

  -- === RELATIONSHIP TYPE ===
  interaction_type TEXT NOT NULL CHECK (interaction_type IN (
    'SYNERGISTIC',    -- Facets reinforce each other (morning run helps both Athlete and Founder)
    'ANTAGONISTIC',   -- Facets oppose each other (rebel vs conformist)
    'COMPETITIVE',    -- Facets compete for same resource (Father vs Founder for evening time)
    'SUPPORTIVE'      -- One facet enables the other (recovery enables focus)
  )),

  -- === FRICTION & COST (RQ-013, RQ-014) ===
  friction_coefficient FLOAT DEFAULT 0.5 CHECK (friction_coefficient BETWEEN 0.0 AND 1.0),
  switching_cost_minutes INT DEFAULT 30 CHECK (switching_cost_minutes >= 0),
  time_overlap_risk FLOAT DEFAULT 0.0 CHECK (time_overlap_risk BETWEEN 0.0 AND 1.0),

  -- === CONFLICT TRACKING ===
  tension_score FLOAT DEFAULT 0.0 CHECK (tension_score BETWEEN 0.0 AND 1.0),
  conflict_count INT DEFAULT 0,
  last_conflict_at TIMESTAMPTZ,

  -- === INFERENCE METADATA ===
  inferred_by TEXT CHECK (inferred_by IN ('bootstrap', 'behavior', 'user', 'council')),
  confidence FLOAT DEFAULT 0.5 CHECK (confidence BETWEEN 0.0 AND 1.0),

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  PRIMARY KEY (source_facet_id, target_facet_id),
  CONSTRAINT no_self_loops CHECK (source_facet_id != target_facet_id)
);

-- Indexes
CREATE INDEX idx_topology_source ON public.identity_topology(source_facet_id);
CREATE INDEX idx_topology_target ON public.identity_topology(target_facet_id);
CREATE INDEX idx_topology_tension ON public.identity_topology(tension_score) WHERE tension_score > 0.5;
CREATE INDEX idx_topology_type ON public.identity_topology(interaction_type);

-- RLS (inherit from facet ownership)
ALTER TABLE public.identity_topology ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own topology"
  ON public.identity_topology FOR SELECT
  USING (
    EXISTS (SELECT 1 FROM identity_facets WHERE id = source_facet_id AND user_id = auth.uid())
  );

CREATE POLICY "Users can insert own topology"
  ON public.identity_topology FOR INSERT
  WITH CHECK (
    EXISTS (SELECT 1 FROM identity_facets WHERE id = source_facet_id AND user_id = auth.uid()) AND
    EXISTS (SELECT 1 FROM identity_facets WHERE id = target_facet_id AND user_id = auth.uid())
  );

CREATE POLICY "Users can update own topology"
  ON public.identity_topology FOR UPDATE
  USING (
    EXISTS (SELECT 1 FROM identity_facets WHERE id = source_facet_id AND user_id = auth.uid())
  );

CREATE POLICY "Users can delete own topology"
  ON public.identity_topology FOR DELETE
  USING (
    EXISTS (SELECT 1 FROM identity_facets WHERE id = source_facet_id AND user_id = auth.uid())
  );

-- Trigger
CREATE TRIGGER update_identity_topology_updated_at
  BEFORE UPDATE ON public.identity_topology
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

---

### A-05: Create treaties Table

**Purpose:** Council AI output — binding agreements between facets.

```sql
CREATE TABLE public.treaties (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- === TREATY IDENTITY ===
  title TEXT NOT NULL,
  description TEXT,
  treaty_type TEXT NOT NULL CHECK (treaty_type IN ('HARD', 'SOFT')),

  -- === LIFECYCLE ===
  status TEXT DEFAULT 'ACTIVE' CHECK (status IN (
    'DRAFT',       -- Council proposed, not yet ratified
    'ACTIVE',      -- User ratified, in effect
    'PAUSED',      -- User-initiated temporary suspension
    'SUSPENDED',   -- System-initiated (breach escalation)
    'PROBATION',   -- Warning period before suspension
    'REPEALED',    -- User permanently ended
    'EXPIRED'      -- Sunset clause reached
  )),

  -- === INVOLVED FACETS ===
  primary_facet_id UUID REFERENCES identity_facets(id) ON DELETE SET NULL,
  secondary_facet_id UUID REFERENCES identity_facets(id) ON DELETE SET NULL,

  -- === LOGIC HOOKS (RQ-020) ===
  logic_hooks JSONB NOT NULL DEFAULT '{}',  -- json_logic_dart conditions
  /*
    Example:
    {
      "if": [
        {"and": [
          {"==": [{"var": "energyState"}, "high_focus"]},
          {">": [{"var": "minutesSinceStateChange"}, 240]}
        ]},
        {"action": "suggest_airlock", "params": {"minutes": 15}}
      ]
    }
  */

  -- === SCHEDULING ===
  ratified_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,                   -- Sunset clause
  paused_until TIMESTAMPTZ,

  -- === VERSIONING (RQ-024) ===
  version INT DEFAULT 1,
  parent_treaty_id UUID REFERENCES treaties(id),
  last_amended_at TIMESTAMPTZ,
  amendment_type TEXT CHECK (amendment_type IN ('MINOR', 'MAJOR', NULL)),

  -- === BREACH TRACKING ===
  breach_count INT DEFAULT 0,
  breach_count_7d INT DEFAULT 0,            -- Breaches in last 7 days
  last_breach_at TIMESTAMPTZ,
  dismissed_warning_count INT DEFAULT 0,

  -- === PROBATION (RQ-024) ===
  probation_started_at TIMESTAMPTZ,
  probation_stage TEXT CHECK (probation_stage IN ('T0', 'T24', 'T72', 'T96', NULL)),

  -- === COUNCIL SOURCE ===
  council_session_id UUID,                  -- FK to council_sessions when created

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_treaties_user ON public.treaties(user_id);
CREATE INDEX idx_treaties_status ON public.treaties(status);
CREATE INDEX idx_treaties_active ON public.treaties(status) WHERE status = 'ACTIVE';
CREATE INDEX idx_treaties_primary_facet ON public.treaties(primary_facet_id);
CREATE INDEX idx_treaties_secondary_facet ON public.treaties(secondary_facet_id);
CREATE INDEX idx_treaties_parent ON public.treaties(parent_treaty_id);

-- RLS
ALTER TABLE public.treaties ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own treaties"
  ON public.treaties FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own treaties"
  ON public.treaties FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own treaties"
  ON public.treaties FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own treaties"
  ON public.treaties FOR DELETE
  USING (auth.uid() = user_id);

-- Trigger
CREATE TRIGGER update_treaties_updated_at
  BEFORE UPDATE ON public.treaties
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

---

### A-07: Create psychological_manifestations Table

**Purpose:** How psychometric roots manifest per facet × domain (Fractal Trinity).

```sql
CREATE TABLE public.psychological_manifestations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  root_id UUID NOT NULL REFERENCES psychometric_roots(id) ON DELETE CASCADE,
  facet_id UUID NOT NULL REFERENCES identity_facets(id) ON DELETE CASCADE,

  -- === MANIFESTATION CONTEXT ===
  domain TEXT NOT NULL,                     -- 'work', 'family', 'health', 'social'
  root_type TEXT NOT NULL,                  -- 'fear', 'need', 'value'
  root_label TEXT NOT NULL,                 -- 'fear_of_irrelevance', 'need_for_control'

  -- === HOW IT MANIFESTS ===
  manifestation_pattern TEXT NOT NULL,      -- "Overworks to prove worth"
  trigger_contexts TEXT[] DEFAULT '{}',     -- ["deadlines", "comparison", "feedback"]
  behavioral_signatures TEXT[] DEFAULT '{}', -- ["late nights", "skipping meals"]

  -- === NARRATIVE TRIANGULATION (RQ-012) ===
  hope_statement TEXT,                      -- "I want to be seen as invaluable"
  fear_statement TEXT,                      -- "I'm afraid of being replaced"
  mechanism_statement TEXT,                 -- "So I overwork to stay indispensable"
  trigger_statement TEXT,                   -- "Especially when I see others succeeding"

  -- === SCORING ===
  intensity FLOAT DEFAULT 0.5 CHECK (intensity BETWEEN 0.0 AND 1.0),
  last_observed_at TIMESTAMPTZ,
  observation_count INT DEFAULT 0,

  -- === EMBEDDING ===
  manifestation_embedding VECTOR(768),

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  CONSTRAINT unique_manifestation UNIQUE (facet_id, domain, root_type, root_label)
);

-- Indexes
CREATE INDEX idx_manifestations_user ON public.psychological_manifestations(user_id);
CREATE INDEX idx_manifestations_facet ON public.psychological_manifestations(facet_id);
CREATE INDEX idx_manifestations_root ON public.psychological_manifestations(root_id);
CREATE INDEX idx_manifestations_domain ON public.psychological_manifestations(domain);
CREATE INDEX idx_manifestations_embedding ON public.psychological_manifestations
  USING hnsw (manifestation_embedding vector_cosine_ops);

-- RLS
ALTER TABLE public.psychological_manifestations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own manifestations"
  ON public.psychological_manifestations FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own manifestations"
  ON public.psychological_manifestations FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own manifestations"
  ON public.psychological_manifestations FOR UPDATE
  USING (auth.uid() = user_id);

-- Trigger
CREATE TRIGGER update_manifestations_updated_at
  BEFORE UPDATE ON public.psychological_manifestations
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

---

### A-08: Create habit_facet_links Table

**Purpose:** Many-to-many relationship between habits and facets (polymorphic habits).

```sql
CREATE TABLE public.habit_facet_links (
  habit_id UUID NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
  facet_id UUID NOT NULL REFERENCES identity_facets(id) ON DELETE CASCADE,

  -- === CONTRIBUTION ===
  contribution_weight FLOAT DEFAULT 1.0 CHECK (contribution_weight BETWEEN 0.0 AND 1.0),

  -- === ENERGY CONTEXT (CD-015) ===
  energy_state TEXT CHECK (energy_state IN ('high_focus', 'high_physical', 'social', 'recovery', NULL)),

  -- === FACET-SPECIFIC CUSTOMIZATION ===
  custom_metrics JSONB DEFAULT '{}',        -- {"pace": "min/km", "ideas_captured": "count"}
  feedback_template TEXT,                   -- "Great run, {facet_label}! {streak} days strong."
  custom_name TEXT,                         -- Facet-specific habit name override

  -- === MEANING ===
  purpose TEXT,                             -- Why this habit serves this facet
  success_definition TEXT,                  -- What "done" means for this facet

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  PRIMARY KEY (habit_id, facet_id)
);

-- Indexes
CREATE INDEX idx_habit_facet_links_habit ON public.habit_facet_links(habit_id);
CREATE INDEX idx_habit_facet_links_facet ON public.habit_facet_links(facet_id);
CREATE INDEX idx_habit_facet_links_energy ON public.habit_facet_links(energy_state);

-- RLS (inherit from facet ownership)
ALTER TABLE public.habit_facet_links ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own habit links"
  ON public.habit_facet_links FOR SELECT
  USING (
    EXISTS (SELECT 1 FROM identity_facets WHERE id = facet_id AND user_id = auth.uid())
  );

CREATE POLICY "Users can insert own habit links"
  ON public.habit_facet_links FOR INSERT
  WITH CHECK (
    EXISTS (SELECT 1 FROM identity_facets WHERE id = facet_id AND user_id = auth.uid())
  );

CREATE POLICY "Users can update own habit links"
  ON public.habit_facet_links FOR UPDATE
  USING (
    EXISTS (SELECT 1 FROM identity_facets WHERE id = facet_id AND user_id = auth.uid())
  );

CREATE POLICY "Users can delete own habit links"
  ON public.habit_facet_links FOR DELETE
  USING (
    EXISTS (SELECT 1 FROM identity_facets WHERE id = facet_id AND user_id = auth.uid())
  );

-- Trigger
CREATE TRIGGER update_habit_facet_links_updated_at
  BEFORE UPDATE ON public.habit_facet_links
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

---

### A-09: Create archetype_templates Table

**Purpose:** 12 global archetypes for facet mapping and content personalization.

```sql
CREATE TABLE public.archetype_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- === IDENTITY ===
  name TEXT NOT NULL UNIQUE,                -- 'builder', 'nurturer', 'warrior', etc.
  display_name TEXT NOT NULL,               -- 'The Builder', 'The Nurturer'
  description TEXT,
  icon TEXT,
  color TEXT,

  -- === DIMENSIONS (CD-005) ===
  dimension_vector FLOAT[6] NOT NULL,       -- [regulatory, autonomy, action_state, temporal, perfectionism, social]

  -- === ENERGY (CD-015) ===
  typical_energy_state TEXT CHECK (typical_energy_state IN ('high_focus', 'high_physical', 'social', 'recovery')),
  preferred_time_blocks JSONB DEFAULT '[]',

  -- === COACHING PERSONALITY ===
  coaching_tone TEXT,                       -- 'challenging', 'nurturing', 'analytical', 'playful'
  communication_style TEXT,                 -- 'direct', 'supportive', 'questioning'
  motivation_drivers TEXT[] DEFAULT '{}',   -- ['achievement', 'connection', 'mastery', 'autonomy']
  warning_signs TEXT[] DEFAULT '{}',        -- ['overwork', 'isolation', 'perfectionism', 'avoidance']

  -- === SHADOW CABINET (RQ-037) ===
  shadow_name TEXT,                         -- 'The Burnout', 'The Martyr'
  shadow_triggers TEXT[] DEFAULT '{}',

  -- === EMBEDDING ===
  embedding VECTOR(768),                    -- For similarity matching

  -- === METADATA ===
  is_active BOOLEAN DEFAULT TRUE,
  display_order INT DEFAULT 0,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_archetype_templates_name ON public.archetype_templates(name);
CREATE INDEX idx_archetype_templates_active ON public.archetype_templates(is_active);
CREATE INDEX idx_archetype_templates_embedding ON public.archetype_templates
  USING hnsw (embedding vector_cosine_ops);

-- RLS: Templates are read-only for users
ALTER TABLE public.archetype_templates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view active templates"
  ON public.archetype_templates FOR SELECT
  USING (is_active = TRUE);

-- Trigger
CREATE TRIGGER update_archetype_templates_updated_at
  BEFORE UPDATE ON public.archetype_templates
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Seed the 12 archetypes (RQ-028)
INSERT INTO public.archetype_templates (name, display_name, dimension_vector, typical_energy_state, coaching_tone, motivation_drivers) VALUES
  ('builder', 'The Builder', ARRAY[0.7, 0.6, 0.8, 0.6, 0.5, 0.4], 'high_focus', 'challenging', ARRAY['achievement', 'mastery']),
  ('nurturer', 'The Nurturer', ARRAY[0.4, 0.3, 0.5, 0.4, 0.3, 0.9], 'social', 'nurturing', ARRAY['connection', 'service']),
  ('warrior', 'The Warrior', ARRAY[0.8, 0.7, 0.9, 0.7, 0.6, 0.3], 'high_physical', 'challenging', ARRAY['achievement', 'strength']),
  ('scholar', 'The Scholar', ARRAY[0.5, 0.5, 0.4, 0.3, 0.6, 0.4], 'high_focus', 'analytical', ARRAY['mastery', 'understanding']),
  ('artist', 'The Artist', ARRAY[0.6, 0.8, 0.5, 0.5, 0.7, 0.5], 'high_focus', 'playful', ARRAY['expression', 'authenticity']),
  ('leader', 'The Leader', ARRAY[0.7, 0.6, 0.7, 0.6, 0.5, 0.7], 'social', 'direct', ARRAY['influence', 'achievement']),
  ('healer', 'The Healer', ARRAY[0.4, 0.4, 0.5, 0.4, 0.4, 0.8], 'recovery', 'nurturing', ARRAY['service', 'restoration']),
  ('explorer', 'The Explorer', ARRAY[0.7, 0.9, 0.6, 0.7, 0.4, 0.5], 'high_physical', 'playful', ARRAY['novelty', 'freedom']),
  ('sage', 'The Sage', ARRAY[0.4, 0.5, 0.3, 0.3, 0.5, 0.6], 'recovery', 'analytical', ARRAY['wisdom', 'understanding']),
  ('guardian', 'The Guardian', ARRAY[0.3, 0.3, 0.6, 0.4, 0.6, 0.7], 'social', 'supportive', ARRAY['protection', 'stability']),
  ('creator', 'The Creator', ARRAY[0.7, 0.7, 0.7, 0.6, 0.6, 0.4], 'high_focus', 'playful', ARRAY['innovation', 'expression']),
  ('connector', 'The Connector', ARRAY[0.5, 0.5, 0.6, 0.5, 0.4, 0.9], 'social', 'supportive', ARRAY['connection', 'harmony']);
```

---

### A-10: Create user_tokens Table

**Purpose:** Council Seal token wallet.

```sql
CREATE TABLE public.user_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- === BALANCE ===
  balance INT DEFAULT 0 CHECK (balance >= 0),
  cap INT DEFAULT 3,                        -- Max tokens (RQ-025)

  -- === LIFETIME STATS ===
  lifetime_earned INT DEFAULT 0,
  lifetime_spent INT DEFAULT 0,

  -- === TIMESTAMPS ===
  last_earned_at TIMESTAMPTZ,
  last_spent_at TIMESTAMPTZ,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  CONSTRAINT one_wallet_per_user UNIQUE (user_id)
);

-- Indexes
CREATE INDEX idx_user_tokens_user ON public.user_tokens(user_id);

-- RLS
ALTER TABLE public.user_tokens ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own tokens"
  ON public.user_tokens FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own tokens"
  ON public.user_tokens FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own tokens"
  ON public.user_tokens FOR UPDATE
  USING (auth.uid() = user_id);

-- Trigger
CREATE TRIGGER update_user_tokens_updated_at
  BEFORE UPDATE ON public.user_tokens
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

---

### A-11: Create treaty_history Table

**Purpose:** Amendment audit trail (RQ-024).

```sql
CREATE TABLE public.treaty_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  treaty_id UUID NOT NULL REFERENCES treaties(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- === VERSION ===
  version INT NOT NULL,
  previous_version INT,

  -- === CHANGE RECORD ===
  change_type TEXT NOT NULL CHECK (change_type IN (
    'CREATED',
    'MINOR_AMENDMENT',
    'MAJOR_AMENDMENT',
    'RATIFIED',
    'PAUSED',
    'RESUMED',
    'SUSPENDED',
    'PROBATION_STARTED',
    'PROBATION_ESCALATED',
    'REPEALED',
    'EXPIRED',
    'BREACH_RECORDED'
  )),

  -- === SNAPSHOT ===
  snapshot JSONB NOT NULL,                  -- Full treaty state at this version

  -- === METADATA ===
  reason TEXT,
  changed_by TEXT DEFAULT 'user' CHECK (changed_by IN ('user', 'system', 'council')),

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_treaty_history_treaty ON public.treaty_history(treaty_id);
CREATE INDEX idx_treaty_history_user ON public.treaty_history(user_id);
CREATE INDEX idx_treaty_history_version ON public.treaty_history(treaty_id, version);
CREATE INDEX idx_treaty_history_type ON public.treaty_history(change_type);

-- RLS
ALTER TABLE public.treaty_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own treaty history"
  ON public.treaty_history FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own treaty history"
  ON public.treaty_history FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- No update/delete - history is append-only
```

---

### A-12: Create token_transactions Table

**Purpose:** Token earn/spend ledger.

```sql
CREATE TABLE public.token_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- === TRANSACTION ===
  amount INT NOT NULL,                      -- Positive = earn, Negative = spend
  transaction_type TEXT NOT NULL CHECK (transaction_type IN (
    'WEEKLY_REVIEW',                        -- Earn: completed weekly reflection
    'CONSISTENCY_STREAK',                   -- Earn: 7-day streak bonus
    'COUNCIL_SUMMON',                       -- Spend: manual council access
    'CRISIS_BYPASS',                        -- Log: auto-used during crisis (amount = 0)
    'PREMIUM_GRANT',                        -- Earn: subscription bonus
    'ADMIN_ADJUSTMENT',                     -- Manual correction
    'DECAY',                                -- Potential future: token expiry
    'MILESTONE_BONUS'                       -- Earn: achievement bonus
  )),

  -- === REFERENCE ===
  reference_id UUID,                        -- FK to source entity
  reference_type TEXT,                      -- 'review', 'streak', 'council_session', 'subscription'

  -- === BALANCE TRACKING ===
  balance_before INT NOT NULL,
  balance_after INT NOT NULL,

  -- === METADATA ===
  metadata JSONB DEFAULT '{}',
  description TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_token_transactions_user ON public.token_transactions(user_id);
CREATE INDEX idx_token_transactions_type ON public.token_transactions(transaction_type);
CREATE INDEX idx_token_transactions_created ON public.token_transactions(created_at DESC);

-- RLS
ALTER TABLE public.token_transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own transactions"
  ON public.token_transactions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own transactions"
  ON public.token_transactions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- No update/delete - ledger is append-only
```

---

## Consolidated Migration File

**Output:** Create a single migration file at:
```
supabase/migrations/20260111_phase_a_psyos_foundation.sql
```

**Structure:**
```sql
-- Phase A: psyOS Schema Foundation
-- Created: 11 January 2026
-- Unblocks: 104 downstream tasks (Phases B-H)

-- ============================================================================
-- STEP 1: Enable pgvector
-- ============================================================================
[A-01 content]

-- ============================================================================
-- STEP 2: Create habits table
-- ============================================================================
[A-06 content]

-- ... continue for all tasks ...
```

---

## Verification Checklist (Execute After Migration)

After running the migration, verify:

```sql
-- Check all tables exist
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN (
  'habits', 'psychometric_roots', 'identity_facets', 'identity_topology',
  'treaties', 'treaty_history', 'psychological_manifestations',
  'habit_facet_links', 'archetype_templates', 'user_tokens', 'token_transactions'
);
-- Expected: 11 rows

-- Check pgvector extension
SELECT * FROM pg_extension WHERE extname = 'vector';
-- Expected: 1 row

-- Check archetype templates seeded
SELECT COUNT(*) FROM archetype_templates;
-- Expected: 12

-- Check RLS enabled
SELECT tablename, rowsecurity FROM pg_tables
WHERE schemaname = 'public' AND tablename IN (
  'habits', 'identity_facets', 'identity_topology', 'treaties'
);
-- Expected: All TRUE

-- Check HNSW indexes exist
SELECT indexname FROM pg_indexes WHERE indexname LIKE '%embedding%';
-- Expected: Multiple embedding indexes
```

---

## Anti-Patterns to Avoid

```
❌ Creating tables WITHOUT RLS (security vulnerability)
❌ Creating tables WITHOUT updated_at triggers (sync issues)
❌ Using 5-state energy model (CD-015 locks 4 states)
❌ Storing embeddings as TEXT or JSONB (use VECTOR type)
❌ Missing HNSW indexes on embedding columns (slow similarity search)
❌ Circular FK references without ON DELETE handling
❌ Missing unique constraints on user_id for single-row tables
❌ Allowing negative token balances
❌ Creating tables without indexes on user_id
❌ Skipping archetype_templates seed data
```

---

## Output Format

Produce a SINGLE migration file with:
1. Header comments explaining purpose
2. All 12 task implementations in order
3. Proper transaction handling
4. Verification queries as comments

**File:** `supabase/migrations/20260111_phase_a_psyos_foundation.sql`

---

## Confidence Assessment

| Task | Confidence | Notes |
|------|------------|-------|
| A-01 (pgvector) | HIGH | Standard extension |
| A-06 (habits) | HIGH | FK fix + research spec |
| A-02 (roots) | HIGH | Mirrors identity_seeds pattern |
| A-03 (facets) | HIGH | Core model from RQ-011/012 |
| A-04 (topology) | MEDIUM | Graph modeling — may need refinement |
| A-05 (treaties) | HIGH | RQ-020/024 well-specified |
| A-07 (manifestations) | MEDIUM | Complex FK chain |
| A-08 (habit_links) | HIGH | Simple junction table |
| A-09 (archetypes) | HIGH | Seed data from RQ-028 |
| A-10 (tokens) | MEDIUM | Earning mechanism deferred (RQ-039) |
| A-11 (treaty_history) | HIGH | Audit trail pattern |
| A-12 (transactions) | HIGH | Ledger pattern |

---

*End of Phase A Schema Foundation Prompt*
