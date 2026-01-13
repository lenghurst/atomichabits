# Protocol 9 Reconciliation: identity_topology Schema (Deep Think Response)

> **Source:** Deep Think (Gemini/DeepSeek)
> **Date:** 13 January 2026
> **Reconciled By:** Claude (Opus 4.5)
> **Target:** `identity_topology` table for A-13 task

---

## Input: Deep Think Proposal

```sql
-- 1. Interaction Types
CREATE TYPE interaction_type_enum AS ENUM (
  'SYNERGISTIC',   -- A makes B easier
  'ANTAGONISTIC',  -- A fights B
  'COMPETITIVE',   -- A and B compete for time
  'DEPENDENT',     -- B cannot exist without A
  'NEUTRAL'        -- Validated as non-interacting
);

-- 2. Table Definition
CREATE TABLE identity_topology (
  source_facet_id UUID NOT NULL,
  target_facet_id UUID NOT NULL,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  interaction_type interaction_type_enum NOT NULL DEFAULT 'NEUTRAL',
  friction_coefficient FLOAT DEFAULT 0.0 CHECK (friction_coefficient BETWEEN 0.0 AND 1.0),
  switching_cost_minutes INT DEFAULT 30 CHECK (switching_cost_minutes >= 0),

  inferred_by TEXT DEFAULT 'SYSTEM',
  confidence FLOAT DEFAULT 1.0,
  last_validated_at TIMESTAMPTZ DEFAULT NOW(),

  PRIMARY KEY (source_facet_id, target_facet_id),
  CONSTRAINT chk_no_self_loop CHECK (source_facet_id != target_facet_id),
  CONSTRAINT fk_source_facet FOREIGN KEY (source_facet_id, user_id)
    REFERENCES identity_facets(id, user_id) ON DELETE CASCADE,
  CONSTRAINT fk_target_facet FOREIGN KEY (target_facet_id, user_id)
    REFERENCES identity_facets(id, user_id) ON DELETE CASCADE
);

-- 3. Indexes
CREATE INDEX idx_topology_user ON identity_topology(user_id);
CREATE INDEX idx_topology_target ON identity_topology(target_facet_id);

-- 4. RLS
ALTER TABLE identity_topology ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage own topology"
  ON identity_topology FOR ALL
  USING (auth.uid() = user_id);
```

---

## Phase 1: Locked Decision Audit

| CD | Constraint | Proposal Compliance | Status |
|----|-----------|---------------------|--------|
| **CD-015** | psyOS Architecture (4-state energy model) | Schema uses `switching_cost_minutes` — compatible with energy transitions | ✅ COMPLIANT |
| **CD-016** | DeepSeek V3.2 for AI | `inferred_by` field allows AI attribution — compatible | ✅ COMPLIANT |
| **CD-017** | Android-first | No platform-specific features | ✅ COMPLIANT |
| **CD-018** | ESSENTIAL/VALUABLE/NICE-TO-HAVE threshold | See Phase 4 | AUDIT NEEDED |

**Phase 1 Result:** ✅ No CD conflicts

---

## Phase 2: Data Reality Audit

| Requirement | Proposal | PostgreSQL/Supabase Reality | Status |
|-------------|----------|----------------------------|--------|
| ENUM type | `interaction_type_enum` | ✅ Standard PostgreSQL feature | VERIFIED |
| Composite PK | `(source_facet_id, target_facet_id)` | ✅ Supported | VERIFIED |
| Composite FK | `(facet_id, user_id)` references | ✅ Requires `identity_facets(id, user_id)` UNIQUE constraint | ⚠️ DEPENDENCY |
| RLS with auth.uid() | `USING (auth.uid() = user_id)` | ✅ Supabase standard pattern | VERIFIED |
| CHECK constraints | Multiple | ✅ Standard PostgreSQL | VERIFIED |

**Phase 2 Result:** ✅ All features verified. Composite FK requires `identity_facets` to have `UNIQUE(id, user_id)` constraint (already in A-06 reconciled schema).

---

## Phase 3: Implementation Reality Audit

| Dependency | Status | Evidence |
|------------|--------|----------|
| `auth.users` table | ✅ EXISTS | Supabase built-in |
| `identity_facets` table | 🔴 PLANNED | Task A-06 — not yet implemented |
| `identity_facets(id, user_id)` UNIQUE | 🔴 PLANNED | In A-06 reconciled schema |
| Existing topology code | ❌ NONE | Clean implementation |

**Phase 3 Result:** ⚠️ Depends on A-06 (`identity_facets`) completing first

---

## Phase 3.5: Schema Reality Check

```bash
# Verification command (conceptual)
grep -r "identity_facets" supabase/migrations/
# Expected: No results (table doesn't exist yet)
```

| Table | Exists? | Blocker |
|-------|---------|---------|
| `identity_facets` | 🔴 NO | A-06 must complete first |
| `identity_topology` | 🔴 NO | This is what we're creating |

**Phase 3.5 Result:** ⚠️ A-13 is BLOCKED by A-06

---

## Phase 4: Scope & Complexity Audit (CD-018)

| Element | Rating | Rationale |
|---------|--------|-----------|
| `interaction_type_enum` (5 types) | **ESSENTIAL** | Core graph semantics — cannot model relationships without |
| Composite PK | **ESSENTIAL** | Standard graph edge pattern |
| `friction_coefficient` | **VALUABLE** | Enables conflict severity quantification |
| `switching_cost_minutes` | **VALUABLE** | Enables schedule feasibility calculation |
| Self-loop prevention | **ESSENTIAL** | Domain correctness (internal conflict ≠ self-edge) |
| Composite FK (tenant isolation) | **ESSENTIAL** | Security requirement — prevents cross-user data |
| `inferred_by` field | **VALUABLE** | Enables AI vs user attribution |
| `confidence` field | **VALUABLE** | Enables AI uncertainty tracking |
| `last_validated_at` | **VALUABLE** | Enables stale inference detection |
| RLS policy | **ESSENTIAL** | Security requirement |
| `idx_topology_user` | **VALUABLE** | Query performance |
| `idx_topology_target` | **VALUABLE** | Query performance |

**Phase 4 Result:**
- ESSENTIAL: 5
- VALUABLE: 7
- NICE-TO-HAVE: 0
- OVER-ENGINEERED: 0

---

## Phase 5: Categorization

### ✅ ACCEPT (10 proposals)

| # | Proposal | Rationale |
|---|----------|-----------|
| 1 | `interaction_type_enum` (5 types) | SYNERGISTIC/ANTAGONISTIC/COMPETITIVE/DEPENDENT/NEUTRAL covers all relationship semantics |
| 2 | Composite PK `(source, target)` | Standard directed graph edge pattern |
| 3 | Self-loop prevention constraint | Correct — internal facet conflict = split facet, not self-edge |
| 4 | Composite FK pattern | Industry-standard tenant isolation — prevents cross-user edges |
| 5 | `friction_coefficient` with CHECK | Bounded 0.0-1.0 for normalized scoring |
| 6 | `inferred_by TEXT` | Flexible attribution (AI/USER/SYSTEM) |
| 7 | `confidence FLOAT` | Allows probabilistic AI inference |
| 8 | `last_validated_at TIMESTAMPTZ` | Enables staleness detection |
| 9 | RLS policy | Standard Supabase security pattern |
| 10 | Both indexes | `idx_topology_user` for RLS, `idx_topology_target` for reverse lookups |

### 🟡 MODIFY (1 proposal)

| # | Proposal | Original | Adjusted | Rationale |
|---|----------|----------|----------|-----------|
| 1 | `switching_cost_minutes` default | 30 | **KEEP 30** but flag as **MEDIUM confidence** | RQ-048c pending — Deep Think response for switching costs not yet reconciled. 30 is defensible middle-ground but not evidence-based. |

### 🔴 REJECT (0 proposals)

None — all proposals are sound.

### ⚠️ ESCALATE (0 proposals)

None — no human decisions required for this table.

---

## Phase 6: Final Reconciled Schema

```sql
-- ============================================================
-- IDENTITY_TOPOLOGY TABLE (Task A-13)
-- Reconciled: 13 January 2026
-- Depends on: A-06 (identity_facets)
-- ============================================================

-- 1. Interaction Types ENUM
CREATE TYPE interaction_type_enum AS ENUM (
  'SYNERGISTIC',   -- A makes B easier (e.g., Athlete → Early Riser)
  'ANTAGONISTIC',  -- A fights B (e.g., Night Owl ↔ Early Riser)
  'COMPETITIVE',   -- A and B compete for time (e.g., Writer vs Parent)
  'DEPENDENT',     -- B cannot exist without A (e.g., Marathoner requires Athlete)
  'NEUTRAL'        -- Validated as non-interacting (explicit, not default)
);

-- 2. Table Definition
CREATE TABLE identity_topology (
  -- Composite Primary Key (edge ID = source + target)
  source_facet_id UUID NOT NULL,
  target_facet_id UUID NOT NULL,

  -- Denormalized user_id for RLS Performance + Tenant Isolation
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Graph Physics
  interaction_type interaction_type_enum NOT NULL DEFAULT 'NEUTRAL',
  friction_coefficient FLOAT DEFAULT 0.0
    CHECK (friction_coefficient BETWEEN 0.0 AND 1.0),
  switching_cost_minutes INT DEFAULT 30  -- MEDIUM confidence (pending RQ-048c)
    CHECK (switching_cost_minutes >= 0),

  -- AI Inference Metadata
  inferred_by TEXT DEFAULT 'SYSTEM',  -- Values: 'AI', 'USER', 'SYSTEM'
  confidence FLOAT DEFAULT 1.0
    CHECK (confidence BETWEEN 0.0 AND 1.0),
  last_validated_at TIMESTAMPTZ DEFAULT NOW(),

  -- CONSTRAINTS
  PRIMARY KEY (source_facet_id, target_facet_id),

  CONSTRAINT chk_no_self_loop
    CHECK (source_facet_id != target_facet_id),

  -- Tenant Isolation: Both facets must belong to same user as this row
  CONSTRAINT fk_source_facet
    FOREIGN KEY (source_facet_id, user_id)
    REFERENCES identity_facets(id, user_id) ON DELETE CASCADE,

  CONSTRAINT fk_target_facet
    FOREIGN KEY (target_facet_id, user_id)
    REFERENCES identity_facets(id, user_id) ON DELETE CASCADE
);

-- 3. Indexes
CREATE INDEX idx_topology_user ON identity_topology(user_id);
CREATE INDEX idx_topology_target ON identity_topology(target_facet_id);

-- 4. Row Level Security
ALTER TABLE identity_topology ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own topology"
  ON identity_topology FOR ALL
  USING (auth.uid() = user_id);
```

---

## SME Domains Identified

- [x] **Database Architecture** — Composite PK, FK patterns, indexing
- [x] **Graph Theory** — Directed edges, self-loop semantics
- [x] **Security Engineering** — Tenant isolation, RLS
- [ ] **Chronobiology** — Switching costs (delegated to RQ-048c)

---

## Dependency Chain

```
A-01 (pgvector extension)
  ↓
A-06 (identity_facets table) ← BLOCKS A-13
  ↓
A-13 (identity_topology table) ← THIS TASK
  ↓
A-14, A-15 (RLS policies) — can run in parallel after A-13
```

---

## Test Queries (Schema-Only Reconciliation)

| # | Query | Purpose |
|---|-------|---------|
| 1 | `SELECT * FROM identity_topology WHERE user_id = $1` | Get all edges for user |
| 2 | `SELECT * FROM identity_topology WHERE source_facet_id = $1 OR target_facet_id = $1` | Get all edges for a facet |
| 3 | `SELECT * FROM identity_topology WHERE friction_coefficient > 0.5` | Find high-conflict edges |
| 4 | `SELECT source_facet_id, target_facet_id, interaction_type FROM identity_topology WHERE user_id = $1` | Constellation visualization data |
| 5 | `INSERT INTO identity_topology (source_facet_id, target_facet_id, user_id, interaction_type) VALUES ($1, $2, $3, 'ANTAGONISTIC')` | Create edge |

---

## Summary

| Metric | Count |
|--------|-------|
| **Total Proposals** | 11 |
| **ACCEPT** | 10 |
| **MODIFY** | 1 (switching_cost default confidence) |
| **REJECT** | 0 |
| **ESCALATE** | 0 |

**Decision:** ✅ PROCEED with schema as proposed. One parameter (`switching_cost_minutes = 30`) marked as MEDIUM confidence pending RQ-048c research.

---

## Revision History

| Date | Author | Changes |
|------|--------|---------|
| 13 Jan 2026 | Claude (Opus 4.5) | Initial reconciliation via Protocol 9 |

---

*This reconciliation follows AI_AGENT_PROTOCOL.md Protocol 9 (External Research Reconciliation).*
