# Research Questions Archive — Q1 2026

> **Created:** 06 January 2026
> **Purpose:** Archived COMPLETE research questions with full findings
> **Scope:** RQ-001 through RQ-022 (all completed items)
> **Quick Reference:** See `../index/RQ_INDEX.md`

---

## Archive Contents

| RQ# | Title | Completion Date | Key Deliverables |
|-----|-------|-----------------|------------------|
| RQ-001 | Archetype Taxonomy | 05 Jan 2026 | 6-dimension model, 4 UI clusters |
| RQ-002 | Effectiveness Measurement | 05 Jan 2026 | Reward function validation |
| RQ-003 | Dimension-to-Tracking | 05 Jan 2026 | Tracking table |
| RQ-004 | Migration Strategy | 05 Jan 2026 | Hybrid model recommendation |
| RQ-011 | Multiple Identity | 05 Jan 2026 | Identity Facets model → CD-015 |
| RQ-012 | Fractal Trinity | 05 Jan 2026 | pgvector schema, Triangulation Protocol |
| RQ-016 | Council AI | 05 Jan 2026 | Single-Shot Playwright, Treaty Protocol |
| RQ-019 | pgvector Implementation | 05 Jan 2026 | gemini-embedding-001, HNSW index |
| RQ-020 | Treaty-JITAI Integration | 05 Jan 2026 | TreatyEngine, tension score algorithm |
| RQ-021 | Treaty Lifecycle | 05 Jan 2026 | Treaty lifecycle FSM |
| RQ-022 | Council Script Prompts | 05 Jan 2026 | Playwright prompts, voice patterns |

---

## RQ-001: Minimum Viable Archetype Taxonomy ✅

**Question:** What is the minimum set of behavioral dimensions that predict differential intervention response?

**Status:** ✅ RESEARCH COMPLETE

**Outcome:** 6-dimension continuous model with 4 UI clusters

### The 6 Dimensions

| # | Dimension | Continuum | Predicts |
|---|-----------|-----------|----------|
| 1 | **Regulatory Focus** | Promotion ↔ Prevention | Identity Evidence framing |
| 2 | **Autonomy/Reactance** | Rebel ↔ Conformist | Anti-Identity risk |
| 3 | **Action-State Orientation** | Executor ↔ Overthinker | Async Delta (rumination) |
| 4 | **Temporal Discounting** | Future ↔ Present | Streak value perception |
| 5 | **Perfectionistic Reactivity** | Adaptive ↔ Maladaptive | Failure Archetype risk |
| 6 | **Social Rhythmicity** | Stable ↔ Chaotic | Async Delta normalization |

### Holy Trinity Defense Mapping

| Resistance Type | Primary Drivers | Detection Signal |
|-----------------|-----------------|------------------|
| **Anti-Identity** | High Reactance + Prevention + Maladaptive | Push-Pull ratio |
| **Failure Archetype** | State Orientation + Steep Discounting + Low Rhythmicity | Recovery velocity (>48h = risk) |
| **Resistance Lie** | High Reactance + State Orientation | Decision time (dwell before logging) |

### Key Insight
> ChatGPT identified **what to optimize** (Identity Evidence, Engagement, Async Delta).
> Gemini identified **who the user is** (6 behavioral dimensions).
> The dimensions serve as the **Context Vector (x)** that allows the Bandit to maximize the **Reward Function (r)**.

---

## RQ-002: Intervention Effectiveness Measurement ✅

**Question:** How should "intervention response" be defined and measured?

**Status:** ✅ VALIDATED

### Reward Function (Implemented)

```
REWARD CALCULATION (0.0 - 1.0 scale):

PRIMARY: Identity Evidence (50%)
├── Habit completed within 24h:     +0.35
├── Streak maintained:              +0.15
├── Used tiny version:              +0.25
└── No completion:                  -0.20

SECONDARY: Engagement Quality (30%)
├── Notification opened:            +0.20
├── Took action:                    +0.10
└── Dismissed without action:       -0.10

TERTIARY: Async Identity Delta (15%)
└── Identity score change (DeepSeek): +/- 0.15 (clamped)

PENALTIES:
├── Annoyance signal:               -0.40
└── Notification disabled:          -0.60 (catastrophic)
```

### Code References
| Metric | File | Lines |
|--------|------|-------|
| Reward calculation | `jitai_decision_engine.dart` | 772-838 |
| Outcome structure | `intervention.dart` | 479-527 |
| Bandit learning | `hierarchical_bandit.dart` | 310-330 |

---

## RQ-003: Dimension-to-Implementation Mapping ✅

**Question:** For each recommended behavioral dimension, what do we already track?

**Status:** ✅ COMPLETE

| Dimension | Passive Inference | Cold-Start Question | Implementation |
|-----------|-------------------|---------------------|----------------|
| **Social Rhythmicity** | Schedule Entropy | "Is your schedule predictable?" | ⚠️ Calculate |
| **Autonomy/Reactance** | Push-Pull Ratio | "Pushy coach or silent partner?" | ⚠️ Track source |
| **Action-State Orientation** | Decision Time | None (infer from logs) | ❌ NEW tracking |
| **Regulatory Focus** | Hard to infer | "Achieving dreams or preventing slides?" | ✅ Onboarding |
| **Perfectionistic Reactivity** | Recovery Velocity | "If I miss, guilty vs determined" | ⚠️ Calculate |
| **Temporal Discounting** | Burstiness | "Small badge now vs rare badge later?" | ⚠️ Calculate |

---

## RQ-004: Archetype Migration Strategy ✅

**Question:** How do we migrate from 6 hardcoded archetypes to dimensional model?

**Status:** ✅ RECOMMENDATION READY

**Recommendation:** Hybrid — 6-float backend vector + 4 UI clusters

| Current Archetype | New Cluster | Intervention Strategy |
|-------------------|-------------|----------------------|
| REBEL | **The Defiant Rebel** | Autonomy-Supportive |
| PERFECTIONIST | **The Anxious Perfectionist** | Self-Compassion |
| PROCRASTINATOR + OVERTHINKER | **The Paralyzed Procrastinator** | Value Affirmation |
| PLEASURE_SEEKER | **The Chaotic Discounter** | Micro-Steps |

---

## RQ-011: Multiple Identity Architecture ✅

**Question:** How should the app handle users with multiple aspirational identities?

**Status:** ✅ RESEARCH COMPLETE → CD-015 (psyOS)

### Research Outcome
The "Parliament of Selves" model was adopted:
- Users have multiple **Identity Facets** (not a single identity)
- Facets can be synergistic, antagonistic, or competitive
- **Council AI** mediates conflicts between facets
- **Treaties** codify agreements between facets

### Key Schema Impact
```sql
CREATE TABLE identity_facets (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL,
  label TEXT NOT NULL,                -- "The Athlete", "The Father"
  keystone_habit_id UUID,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## RQ-012: Fractal Trinity Architecture ✅

**Question:** How should the Fractal Trinity (Root Psychology + Contextual Manifestations) be architected?

**Status:** ✅ RESEARCH COMPLETE

**Researcher:** Google Deep Think (05 Jan 2026)

### Key Insight: Invariance Fallacy
The same root fear manifests differently per facet. Users cannot directly articulate root psychology — only surface manifestations.

### Finalized Schema

```sql
-- THE DEEP SOURCE (Global/Biological)
CREATE TABLE psychometric_roots (
  user_id UUID PRIMARY KEY,
  chronotype TEXT CHECK (chronotype IN ('lion', 'bear', 'wolf', 'dolphin')),
  neurotype TEXT,
  root_label TEXT,
  root_embedding VECTOR(768),
  root_confidence FLOAT DEFAULT 0.0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- THE CONTEXTUAL MANIFESTATION (Local per-Facet)
CREATE TABLE psychological_manifestations (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL,
  facet_id UUID NOT NULL REFERENCES identity_facets(id),
  root_id UUID REFERENCES psychometric_roots(user_id),
  archetype_label TEXT,
  resistance_script TEXT,
  resistance_embedding VECTOR(768),
  trigger_context TEXT,
  coaching_strategy TEXT,
  UNIQUE(facet_id)
);
```

### Triangulation Protocol

```
Day 1: Extract Manifestation A (Keystone Facet)
Day 3-4: Extract Manifestation B (Shadow Facet)
Day 7: Root Synthesis via vector similarity
  → If similarity > 0.7: Same root, high confidence
  → If similarity < 0.4: Different roots
```

### Chronotype-JITAI Matrix

| Chronotype | Peak (Push Hard) | Trough (Compassion) | Danger Zone |
|------------|------------------|---------------------|-------------|
| **Lion** | 06:00-10:00 | 14:00-16:00 | >20:30 |
| **Bear** | 10:00-14:00 | 15:00-16:00 | >23:00 |
| **Wolf** | 17:00-23:00 | 08:00-11:00 | 06:00-09:00 |
| **Dolphin** | Variable | Mid-Day | 02:00-05:00 |

---

## RQ-016: Council AI (Roundtable Simulation) ✅

**Question:** How should the AI simulate a "parliament" of the user's identity facets?

**Status:** ✅ RESEARCH COMPLETE

**Researcher:** Google Deep Think (05 Jan 2026)

### Single-Shot Playwright Model

**Decision:** Use Single-Shot Playwright (not multi-agent orchestration)

| Approach | Pros | Cons |
|----------|------|------|
| Multi-Agent | More authentic | Latency, cost, unpredictable |
| **Single-Shot** | Fast, predictable, coherent | Requires careful prompting |

### Treaty Protocol

Treaties are database objects that override default JITAI logic:
```sql
CREATE TABLE treaties (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL,
  facet_a_id UUID NOT NULL,
  facet_b_id UUID NOT NULL,
  terms JSONB NOT NULL,
  logic_hook TEXT,
  status TEXT DEFAULT 'ACTIVE',
  breach_count INT DEFAULT 0,
  valid_until TIMESTAMPTZ
);
```

### Audiobook Pattern
Council sessions are delivered as "dramatic audiobook" with distinct voice personas per facet.

---

## RQ-019: pgvector Implementation Strategy ✅

**Question:** How should vector embeddings be implemented?

**Status:** ✅ RESEARCH COMPLETE

### Embedding Model Selection
**Decision:** Use **gemini-embedding-001** (not text-embedding-004)

| Criterion | gemini-embedding-001 | text-embedding-004 |
|-----------|---------------------|-------------------|
| Status | ✅ Current | ⚠️ Deprecated Jan 14, 2026 |
| Dimensions | 3072 (Matryoshka) | 768 fixed |

### Index Strategy
```sql
CREATE INDEX ON psychological_manifestations
USING hnsw (resistance_embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);
```

### Cost Projection
| Users | Vectors | Monthly Cost |
|-------|---------|--------------|
| 10K | 100K | $7/mo |
| 100K | 1M | $70/mo |
| 1M | 10M | $700/mo |

---

## RQ-020: Treaty-JITAI Integration ✅

**Question:** How should Treaties override default JITAI logic?

**Status:** ✅ RESEARCH COMPLETE

### JITAI Pipeline Position
Treaties apply at Stage 3 (Post-Safety, Pre-Optimization):
```
Stage 1: Safety Check (time-of-day, DND)
Stage 2: Annoyance Filter (recent nudges)
Stage 3: TREATY CHECK ← Here
Stage 4: Thompson Sampling
Stage 5: Content Generation
```

### Tension Score Algorithm
```dart
double calculateTensionScore(Treaty treaty, ContextSnapshot context) {
  double score = 0.0;
  if (treaty.triggerCondition.evaluate(context)) {
    score += 0.4;  // Condition met
  }
  if (context.energyState != treaty.expectedEnergyState) {
    score += 0.3;  // Energy conflict
  }
  if (treaty.breachCount > 2) {
    score += 0.3;  // History of breach
  }
  return score.clamp(0.0, 1.0);
}
```

---

## RQ-021: Treaty Lifecycle & UX ✅

**Question:** How should treaties be created, modified, and retired?

**Status:** ✅ RESEARCH COMPLETE

### Treaty Lifecycle FSM

```
PROPOSED → (user accepts) → ACTIVE
ACTIVE → (breach) → STRAINED
STRAINED → (3 breaches) → BROKEN
BROKEN → (renegotiation) → RENEGOTIATING
RENEGOTIATING → (new terms) → ACTIVE
ACTIVE → (facet retired) → RETIRED
```

### Creation Methods
1. **Council AI Proposed** — After conflict resolution
2. **User Initiated** — Via template selection
3. **System Suggested** — Based on detected friction

---

## RQ-022: Council Script Generation Prompts ✅

**Question:** How should Council AI scripts be generated?

**Status:** ✅ RESEARCH COMPLETE

### Playwright System Prompt (Summary)
The Council AI generates a complete dramatic script in one LLM call:
- Input: Conflict + Facet profiles + User history
- Output: JSON with voices[], treaty_proposal, resolution

### Voice Persona Guidelines
Each facet has distinct voice characteristics:
- **The Executive**: Direct, strategic, growth-focused
- **The Parent**: Nurturing, priority-focused, guilt-aware
- **The Creative**: Expansive, unconventional, pattern-breaking

---

## Appendix: Research Session Log

| Date | Agent | Focus | Status |
|------|-------|-------|--------|
| 05 Jan 2026 | Google Deep Think | RQ-012 + RQ-016 | ✅ COMPLETE |
| 05 Jan 2026 | Gemini Deep Think | SYNTHESIS | ✅ COMPLETE |
| 05 Jan 2026 | Gemini Deep Research | 6-Dimension Model | ✅ COMPLETE |
| 05 Jan 2026 | ChatGPT | Intervention Effectiveness | ✅ COMPLETE |

---

*This archive contains complete research findings. For implementation tasks, see the Master Implementation Tracker in RESEARCH_QUESTIONS.md.*
