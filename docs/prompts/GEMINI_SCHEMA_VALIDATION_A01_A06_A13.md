# Gemini Prompt: Schema Validation & Migration Generation

> **Task:** Validate and generate Supabase migration for identity_facets + identity_topology
> **Duration:** ~15 min
> **Output:** Ready-to-execute SQL migration file

---

## Your Role

You are a **Supabase Database Engineer**. Review the schema below and:
1. Validate for correctness (syntax, constraints, indexes)
2. Identify any issues or improvements
3. Generate a single `.sql` migration file ready to run

---

## Schema to Validate

### Part 1: Extensions & ENUMs

```sql
-- Enable pgvector for AI embeddings
CREATE EXTENSION IF NOT EXISTS vector;

-- Domain types
CREATE TYPE facet_domain_enum AS ENUM (
  'professional', 'physical', 'relational', 'temporal'
);

CREATE TYPE facet_status_enum AS ENUM (
  'active', 'maintenance', 'dormant', 'archived'
);

CREATE TYPE energy_state_enum AS ENUM (
  'high_focus', 'high_physical', 'social', 'recovery'
);

CREATE TYPE interaction_type_enum AS ENUM (
  'SYNERGISTIC', 'ANTAGONISTIC', 'COMPETITIVE', 'DEPENDENT', 'NEUTRAL'
);
```

### Part 2: identity_facets Table

```sql
CREATE TABLE identity_facets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Core Identity
  label TEXT NOT NULL CHECK (char_length(label) BETWEEN 1 AND 50),
  domain facet_domain_enum NOT NULL,
  aspiration TEXT CHECK (char_length(aspiration) < 280),

  -- Psychological Overlay
  is_shadow BOOLEAN DEFAULT FALSE,
  dimension_adjustments JSONB DEFAULT '{}'::jsonb,
  embedding vector(3072),

  -- Energy Gating (4-state model)
  typical_energy_state energy_state_enum NOT NULL DEFAULT 'high_focus',

  -- Constellation UX
  color_hex CHAR(7) DEFAULT '#FFFFFF' CHECK (color_hex ~* '^#[a-f0-9]{6}$'),
  icon_slug TEXT DEFAULT 'default',
  sort_order INT DEFAULT 0,

  -- Metrics & Lifecycle
  ics_score FLOAT DEFAULT 0.0 CHECK (ics_score BETWEEN 0.0 AND 1.0),
  status facet_status_enum NOT NULL DEFAULT 'active',
  archetype_template_id UUID,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  last_reflected_at TIMESTAMPTZ,

  -- Constraints
  CONSTRAINT uk_facets_label_user UNIQUE (user_id, label),
  CONSTRAINT uk_facets_id_user UNIQUE (id, user_id)
);

-- Indexes
CREATE INDEX idx_facets_user_status ON identity_facets(user_id, status);
CREATE INDEX idx_facets_energy ON identity_facets(user_id, typical_energy_state);
CREATE INDEX idx_facets_dimensions ON identity_facets USING GIN (dimension_adjustments);
```

### Part 3: identity_topology Table

```sql
CREATE TABLE identity_topology (
  source_facet_id UUID NOT NULL,
  target_facet_id UUID NOT NULL,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Graph Physics
  interaction_type interaction_type_enum NOT NULL DEFAULT 'NEUTRAL',
  friction_coefficient FLOAT DEFAULT 0.0 CHECK (friction_coefficient BETWEEN 0.0 AND 1.0),
  switching_cost_minutes INT DEFAULT 30 CHECK (switching_cost_minutes >= 0),

  -- AI Inference Metadata
  inferred_by TEXT DEFAULT 'SYSTEM',
  confidence FLOAT DEFAULT 1.0,
  last_validated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Constraints
  PRIMARY KEY (source_facet_id, target_facet_id),
  CONSTRAINT chk_no_self_loop CHECK (source_facet_id != target_facet_id),
  CONSTRAINT fk_source_facet FOREIGN KEY (source_facet_id, user_id)
    REFERENCES identity_facets(id, user_id) ON DELETE CASCADE,
  CONSTRAINT fk_target_facet FOREIGN KEY (target_facet_id, user_id)
    REFERENCES identity_facets(id, user_id) ON DELETE CASCADE
);

-- Indexes
CREATE INDEX idx_topology_user ON identity_topology(user_id);
CREATE INDEX idx_topology_target ON identity_topology(target_facet_id);
```

### Part 4: RLS Policies

```sql
-- identity_facets RLS
ALTER TABLE identity_facets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own facets"
  ON identity_facets FOR ALL
  USING (auth.uid() = user_id);

-- identity_topology RLS
ALTER TABLE identity_topology ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own topology"
  ON identity_topology FOR ALL
  USING (auth.uid() = user_id);
```

### Part 5: Facet Limit Trigger

```sql
CREATE OR REPLACE FUNCTION check_facet_limit()
RETURNS TRIGGER AS $$
BEGIN
  IF (SELECT count(*) FROM identity_facets
      WHERE user_id = NEW.user_id AND status = 'active') >= 10 THEN
      RAISE EXCEPTION 'Facet limit reached (10 active). Archive existing facets first.';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_check_facet_limit
BEFORE INSERT ON identity_facets
FOR EACH ROW EXECUTE FUNCTION check_facet_limit();
```

---

## Output Required

1. **Validation Report:** Any syntax errors, constraint issues, or improvements?
2. **Single Migration File:** Combine all parts into one `YYYYMMDD_create_identity_schema.sql`
3. **Rollback Script:** Provide `DROP` statements for clean rollback

---

## Constraints

- Must work with Supabase PostgreSQL
- Must use `auth.users` for user references
- Must support `auth.uid()` for RLS
- pgvector extension required for embeddings

---

*End of Prompt*
