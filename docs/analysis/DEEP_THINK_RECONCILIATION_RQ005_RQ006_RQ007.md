# Research Reconciliation: RQ-005, RQ-006, RQ-007 (Identity Coach Architecture)

**Source:** DeepSeek Deep Think (Identity Coach Architecture Report)
**Date:** 06 January 2026
**Reconciled By:** Claude (Opus 4.5)
**Protocol Used:** Protocol 9 (External Research Reconciliation)

---

## Summary

| Metric | Count |
|--------|-------|
| **Total Proposals** | 24 |
| **✅ ACCEPT** | 15 |
| **🟡 MODIFY** | 6 |
| **🔴 REJECT** | 1 |
| **⚠️ ESCALATE** | 2 |

---

## Phase 1: Locked Decision Audit

### Conflict Analysis

| Proposal | Relevant CD | Conflict? | Resolution |
|----------|-------------|-----------|------------|
| Two-Stage Hybrid Retrieval | CD-016 (AI Model Strategy) | ✅ Compatible | Uses gemini-embedding-001 for Stage 1, validates CD-016 |
| Topology & Energy Gating | CD-015 (4-state model) | ✅ Compatible | References 4-state energy model correctly |
| "Architect" vs "Commander" | CD-015, CD-008 | ✅ Compatible | Validates JITAI-Coach separation per CD-008 |
| 12 Global Archetypes | CD-005 (6-dimension model) | 🟡 Extends | Not a conflict, but extends the model — mark MODIFY |
| 6-Dimension Framing Matrix | CD-005 | ✅ Compatible | Directly implements CD-005 |
| "Identity Tree" Visualization | RQ-017 (Constellation UX) | ⚠️ **CONFLICT** | Deep Think proposes Tree; RQ-017 specifies Solar System |
| ICS (Identity Consolidation Score) | None directly | ✅ Compatible | New metric — no conflict but introduces complexity |
| Future Self Interview (Day 3) | CD-011, CD-015 | ✅ Compatible | Aligns with Keystone Onboarding (CD-015) |
| Pace Car Protocol (1 rec/day) | CD-018 (Threshold Framework) | ✅ Compatible | Appropriately scoped |
| Regression Detection signals | CD-017 (Android-first) | ✅ Compatible | Uses Android-available signals |

### Critical Conflict: Visualization Philosophy

| Deep Think Proposal | Existing Decision | Impact |
|---------------------|-------------------|--------|
| **"Identity Tree"** — Roots=Trinity, Trunk=Values, Branches=Facets, Leaves=Habits | **RQ-017: Constellation UX** — Solar System where Facets are planets orbiting the Self (sun) | **⚠️ ESCALATE** — Fundamental UX philosophy decision |

**Analysis:**
- The Deep Think output proposes returning to a **Tree metaphor** (similar to existing Skill Tree)
- RQ-017 already documents **Constellation UX (Solar System)** as the target visualization
- The Tree metaphor emphasizes **hierarchy** (roots → leaves)
- The Constellation metaphor emphasizes **gravity and balance** (orbits, mass, pull)
- Both are valid; this is a **product philosophy decision**, not a technical one

**Options for Human:**
- **Option A:** Accept Tree metaphor (simpler, familiar, aligns with Deep Think)
- **Option B:** Keep Constellation UX (more novel, better represents facet relationships/tensions)
- **Option C:** Hybrid — Tree for single-facet view, Constellation for multi-facet overview

---

## Phase 2: Data Reality Audit (Android-First per CD-017)

| Data Point | Android Status | Permission | Battery | Deep Think Usage | Action |
|------------|----------------|------------|---------|------------------|--------|
| `facet.embedding` (768-dim) | ✅ Stored in Supabase | None | None (server) | Stage 1 retrieval | **INCLUDE** |
| `user.dimensionVector` (6-dim) | ✅ Stored in Supabase | None | None (server) | Stage 2 re-ranking | **INCLUDE** |
| `habit_templates.idealDimensionVector` | ❌ **NOT EXISTS** | None | None (server) | Stage 2 matching | **CREATE** |
| `screenOnDuration` | ✅ Available | UsageStatsManager | Low | Regression detection | **INCLUDE** |
| `stepsLast30Min` | ✅ Available | Google Fit / Health Connect | Low | Energy gating | **INCLUDE** |
| `energyState` | ✅ Inferred (RQ-014) | Composite | Low | Facet-awareness filter | **INCLUDE** |
| `activeFacet` | ✅ User action | None | Low | Retrieval context | **INCLUDE** |
| `frictionCoefficient` | ✅ identity_topology (RQ-013) | None | None (DB) | Topology filter | **INCLUDE** |
| `first_unlock_time` | 🟡 Derivable | UsageStatsManager | Low | Regression signal | **INCLUDE** |
| `jitai_dismissal_rate` | ✅ Tracked | None | None | Regression signal | **INCLUDE** |

### New Data Requirements Identified

| Data Point | Required For | Implementation Effort |
|------------|--------------|----------------------|
| `habit_templates.idealDimensionVector` | Stage 2 psychometric re-ranking | MEDIUM — Must tag ~50 habits |
| `habit_templates.globalArchetypeId` | Facet→Content mapping | MEDIUM — Must create 12 archetypes |
| `preference_embedding` (Shadow Vector) | Feedback loop fine-tuning | LOW — Computed, not stored |
| `user.aspiration_label` | Identity Roadmap | LOW — Already in CD-011 |

---

## Phase 3: Implementation Reality Audit

### Existing Components (Already Built)

| Component | Status | Deep Think Assumption | Gap |
|-----------|--------|----------------------|-----|
| pgvector in Supabase | ✅ RQ-019 COMPLETE | Assumes available | None |
| JITAI Bandit | ✅ Implemented | "Commander" intact | None |
| identity_facets table | ✅ RQ-012 schema | Facets exist | None |
| identity_topology | ✅ RQ-013 schema | Friction coefficients exist | None |
| 4-state energy model | ✅ CD-015, RQ-014 | Energy gating available | None |
| habit_templates table | ⚠️ Partial | Assumes `idealDimensionVector` | **GAP** — Field missing |
| global_archetypes table | ❌ Not exists | Assumes 12 archetypes | **GAP** — Must create |

### Schema Additions Required

```sql
-- 1. Add psychometric vector to habit templates
ALTER TABLE habit_templates
ADD COLUMN ideal_dimension_vector FLOAT[6],
ADD COLUMN global_archetype_id UUID REFERENCES global_archetypes(id);

-- 2. Create Global Archetypes lookup
CREATE TABLE global_archetypes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,           -- "The Builder", "The Nurturer"
  description TEXT,
  embedding VECTOR(768),        -- For facet→archetype matching
  dimension_profile FLOAT[6],   -- Typical dimension vector
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. Create Identity Roadmaps
CREATE TABLE identity_roadmaps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  facet_id UUID REFERENCES identity_facets(id),
  aspiration_label TEXT,        -- "Become a Fit Dad"
  aspiration_embedding VECTOR(768),
  status TEXT DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 4. Create Roadmap Nodes
CREATE TABLE roadmap_nodes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  roadmap_id UUID REFERENCES identity_roadmaps(id),
  stage_order INT,              -- 1, 2, 3...
  node_type TEXT,               -- 'habit', 'milestone', 'ritual'
  target_id UUID,               -- References habit_templates or milestones
  unlock_criteria JSONB,        -- {"ics_score": 0.5}
  status TEXT DEFAULT 'locked',
  created_at TIMESTAMPTZ DEFAULT now()
);
```

### Code Components Required

| Component | Location | Depends On |
|-----------|----------|------------|
| `IdentityCoachEngine` class | `lib/domain/services/identity_coach_engine.dart` | Schema additions |
| `HabitRecommender` service | `lib/domain/services/habit_recommender.dart` | pgvector, global_archetypes |
| `RoadmapService` | `lib/domain/services/roadmap_service.dart` | identity_roadmaps table |
| `RegressionDetector` | `lib/domain/services/regression_detector.dart` | Android signals |
| `PaceCarLimiter` | `lib/domain/services/pace_car_limiter.dart` | User preferences |

---

## Phase 4: Scope & Complexity Audit (CD-018 Framework)

### RQ-005: Proactive Recommendation Algorithms

| Proposal | Deep Think Rating | Our Rating | Rationale |
|----------|-------------------|------------|-----------|
| Two-Stage Hybrid Retrieval | ESSENTIAL | **ESSENTIAL** | Core algorithm — without this, no recommendations |
| Topology & Energy Gating | ESSENTIAL | **ESSENTIAL** | Uses existing RQ-013, RQ-014 work |
| "Architect" vs "Commander" | ESSENTIAL | **ESSENTIAL** | Proper separation prevents battery drain |
| Implicit-Dominant Feedback | VALUABLE | **VALUABLE** | Important but can launch without perfect feedback |
| Snooze vs Ban Taxonomy | VALUABLE | **VALUABLE** | Good UX, not blocking |
| Pace Car Protocol (1/day) | ESSENTIAL | **ESSENTIAL** | Critical — prevents overwhelm |
| Trinity Seed (Cold Start) | ESSENTIAL | **ESSENTIAL** | Uses existing Day 1 data |

### RQ-006: Content Library

| Proposal | Deep Think Rating | Our Rating | Rationale |
|----------|-------------------|------------|-----------|
| "Atomic 20" Universal Habits | ESSENTIAL | **ESSENTIAL** | Minimum viable content set |
| Transition-Based Ritual Taxonomy | VALUABLE | **VALUABLE** | Aligns with State Economics |
| Identity Consolidation Stages | VALUABLE | **MODIFY → ESSENTIAL** | Spark/Dip/Groove is elegant and actionable |
| 6-Dimension Framing Matrix | ESSENTIAL | **ESSENTIAL** | Direct implementation of CD-005 |
| 12 Global Archetypes | ESSENTIAL | **MODIFY** | Concept valid, but 12 may be over-engineered |
| Regression Messaging | ESSENTIAL | **ESSENTIAL** | Critical for preventing shame spirals |
| Minimum Viable Set (50+12+12+4) | N/A | **ESSENTIAL** | Defines launch content |

### RQ-007: Identity Roadmap Architecture

| Proposal | Deep Think Rating | Our Rating | Rationale |
|----------|-------------------|------------|-----------|
| "Future Self" Interview | ESSENTIAL | **ESSENTIAL** | Fills CD-011 gap for aspiration extraction |
| Roadmap Schema | ESSENTIAL | **ESSENTIAL** | Clean, minimal schema |
| Vector Classification (Aspiration→Facet) | VALUABLE | **VALUABLE** | DeepSeek V3.2 can handle |
| ICS (Identity Consolidation Score) | VALUABLE | **MODIFY** | Formula reasonable, but complexity TBD |
| Regression Detection (3 signals) | NICE-TO-HAVE | **MODIFY → VALUABLE** | Simpler than burnout detection; uses existing data |
| "Identity Tree" Visualization | VALUABLE | **⚠️ ESCALATE** | Conflicts with Constellation UX (RQ-017) |

---

## Phase 5: Categorization

### ✅ ACCEPT (Integrate as-is) — 15 Items

| # | Proposal | RQ | Rationale |
|---|----------|-----|-----------|
| 1 | **Two-Stage Hybrid Retrieval** | RQ-005 | Mathematically sound; solves cold start; uses existing pgvector |
| 2 | **Topology & Energy Gating (Hard Filters)** | RQ-005 | Leverages RQ-013 + RQ-014 work directly |
| 3 | **"Architect" vs "Commander" Architecture** | RQ-005 | Proper separation; Coach is async, JITAI is real-time |
| 4 | **Pace Car Protocol (1 rec/day, <5 habits)** | RQ-005 | Cognitive load management; aligns with CD-018 |
| 5 | **Trinity Seed (Cold Start)** | RQ-005 | Elegant use of existing Day 1 Holy Trinity data |
| 6 | **Snooze vs Ban Taxonomy** | RQ-005 | Clear UX pattern: "Not Now" (14 days) vs "Not Me" (permanent) |
| 7 | **"Atomic 20" Universal Habits** | RQ-006 | Evidence-based, low-friction starter habits |
| 8 | **Transition-Based Ritual Taxonomy** | RQ-006 | Activation/Shutdown/Airlock maps to State Economics |
| 9 | **Identity Consolidation Stages (Spark/Dip/Groove)** | RQ-006 | Elegant progression model (Day 1-7 / Day 8-21 / Day 66+) |
| 10 | **6-Dimension Framing Matrix** | RQ-006 | Direct implementation of CD-005 for content personalization |
| 11 | **Regression Messaging (Data-Driven Normalization)** | RQ-006 | "Day 8 is most common drop-off" — reduces shame |
| 12 | **"Future Self" Interview (Day 3)** | RQ-007 | Fills aspiration extraction gap per CD-011 |
| 13 | **Roadmap Schema (identity_roadmaps + roadmap_nodes)** | RQ-007 | Clean, minimal, extensible |
| 14 | **Vector Classification (Aspiration→Facet)** | RQ-007 | DeepSeek V3.2 can classify per CD-016 |
| 15 | **Habit→Aspiration Vector Matching** | RQ-007 | Uses pgvector; consistent with RQ-019 |

---

### 🟡 MODIFY (Adjust for reality) — 6 Items

| # | Proposal | Original | Adjusted | Rationale |
|---|----------|----------|----------|-----------|
| 1 | **12 Global Archetypes** | 12 hardcoded archetypes (Builder, Nurturer, Warrior, etc.) | **8 Core Archetypes** for launch; expand if needed | 12 may be over-engineered; 8 covers common facets without overwhelming content creation |
| 2 | **Implicit-Dominant Signal Hierarchy** | +5.0 Adoption, +10.0 Validation, -5.0 Dismiss, -0.5 Decay | **Weights to be tuned** — treat as initial values, not locked | Exact weights require A/B testing; accept as starting point |
| 3 | **ICS Formula** | `ICS = Σ(Votes × Consistency) / DaysActive` | **ICS = Σ(Completions × GracefulScore) / max(DaysActive, 7)** | Replace "Votes" with existing terminology; floor `DaysActive` to prevent divide-by-small-number |
| 4 | **Regression Detection (3 signals)** | screenOnDuration, first_unlock_time shift, JITAI dismissal | **Add: Cross-facet misses (from BurnoutDetector)** | Aligns with RQ-014 reconciliation; reuses existing signal |
| 5 | **Minimum Viable Content Set** | 50 habits + 12 archetypes + 12 framings + 4 rituals | **50 habits + 8 archetypes + 12 framings + 6 rituals** | Reduce archetypes to 8; add 2 rituals for better coverage (Morning, Evening, Transition, Recovery, Focus, Social) |
| 6 | **"preference_embedding" (Shadow Vector)** | Update after each rejection | **Update weekly via batch job** | Real-time updates are battery-expensive; weekly batch is sufficient |

---

### 🔴 REJECT (Do not implement) — 1 Item

| # | Proposal | Reason |
|---|----------|--------|
| 1 | **Collaborative Filtering ("Users like you")** | Deep Think correctly rejected this (Option A); we confirm rejection. **Fatal cold start problem** at launch with zero users. Revisit post-launch when population data exists. |

---

### ⚠️ ESCALATE (Human decision required) — 2 Items

#### ESCALATE-1: Visualization Philosophy (Tree vs Constellation)

| Aspect | Deep Think (Tree) | Existing (Constellation) |
|--------|-------------------|--------------------------|
| **Metaphor** | Identity Tree — Roots, Trunk, Branches, Leaves | Solar System — Sun (Self), Planets (Facets), Orbits |
| **Hierarchy** | Emphasizes vertical growth (root→leaf) | Emphasizes balance/gravity (pull between facets) |
| **Conflict representation** | Not natural in tree metaphor | Planets pulling each other out of orbit |
| **Implementation** | Could reuse/enhance existing Skill Tree | Requires new visualization (RQ-017) |
| **Psychological fit** | IFS-like parts hierarchy | Parliament of Selves (CD-015) — negotiating equals |

**Options for Human:**

| Option | Description | Recommendation |
|--------|-------------|----------------|
| **A: Tree** | Accept Deep Think's Identity Tree; deprecate Constellation UX | NOT RECOMMENDED — Tree doesn't represent facet tensions well |
| **B: Constellation** | Keep RQ-017's Solar System; reject Deep Think's Tree | RECOMMENDED — Better fit for psyOS Parliament metaphor |
| **C: Hybrid** | Tree for single-facet detail view; Constellation for multi-facet overview | POSSIBLE — More complex but covers both needs |

**Recommended:** **Option B** — Constellation UX aligns better with CD-015's "Parliament of Selves" philosophy where facets are equals negotiating, not hierarchical branches.

---

#### ESCALATE-2: Number of Global Archetypes

| Option | Count | Pros | Cons |
|--------|-------|------|------|
| **A: Deep Think's 12** | 12 | Comprehensive coverage | Heavy content creation burden (12 × content variants) |
| **B: Reduced to 8** | 8 | Manageable for launch | May miss edge cases |
| **C: Start with 6, expand** | 6→8→12 | Lean launch | Risk of incomplete mapping |

**Recommendation:** **Option B (8 Archetypes)** for launch:
1. The Builder (achievement, creation)
2. The Nurturer (care, relationships)
3. The Warrior (fitness, discipline)
4. The Scholar (learning, growth)
5. The Artist (creativity, expression)
6. The Leader (influence, career)
7. The Healer (wellness, recovery)
8. The Explorer (adventure, freedom)

---

## Phase 6: Tasks Extracted (via Protocol 8)

### Schema Foundation (Phase A)

| ID | Task | Priority | Component | Source |
|----|------|----------|-----------|--------|
| A-14 | Add `ideal_dimension_vector FLOAT[6]` to `habit_templates` | CRITICAL | Database | RQ-005 |
| A-15 | Add `global_archetype_id UUID` to `habit_templates` | CRITICAL | Database | RQ-006 |
| A-16 | Create `global_archetypes` table (8 archetypes) | CRITICAL | Database | RQ-006 |
| A-17 | Create `identity_roadmaps` table | HIGH | Database | RQ-007 |
| A-18 | Create `roadmap_nodes` table | HIGH | Database | RQ-007 |

### Intelligence Layer (Phase B)

| ID | Task | Priority | Component | Source |
|----|------|----------|-----------|--------|
| B-14 | Implement `HabitRecommender` with Two-Stage Hybrid Retrieval | CRITICAL | Service | RQ-005 |
| B-15 | Implement Energy/Topology Gating in `HabitRecommender` | CRITICAL | Service | RQ-005 |
| B-16 | Implement `IdentityCoachEngine` (Architect pattern) | CRITICAL | Service | RQ-005 |
| B-17 | Implement `PaceCarLimiter` (1 rec/day, <5 habits rule) | HIGH | Service | RQ-005 |
| B-18 | Implement `RegressionDetector` (4 signals) | HIGH | Service | RQ-007 |
| B-19 | Implement `RoadmapService` | HIGH | Service | RQ-007 |
| B-20 | Implement `ICS Calculator` (modified formula) | MEDIUM | Service | RQ-007 |
| B-21 | Add "Future Self" question to Sherlock Day 3 | HIGH | Onboarding | RQ-007 |

### Content Creation (Phase C)

| ID | Task | Priority | Component | Source |
|----|------|----------|-----------|--------|
| C-06 | Create 8 Global Archetype definitions with embeddings | CRITICAL | Content | RQ-006 |
| C-07 | Create 50 Universal Habit templates with dimension vectors | CRITICAL | Content | RQ-006 |
| C-08 | Create 6 Ritual templates (Morning, Evening, Transition, Recovery, Focus, Social) | HIGH | Content | RQ-006 |
| C-09 | Create 12 Framing templates (6 dims × 2 poles) | HIGH | Content | RQ-006 |
| C-10 | Create Identity Consolidation Stage messaging (Spark, Dip, Groove) | MEDIUM | Content | RQ-006 |
| C-11 | Create Regression Messaging templates (data-driven) | MEDIUM | Content | RQ-006 |

### UX & Frontend (Phase D)

| ID | Task | Priority | Component | Source |
|----|------|----------|-----------|--------|
| D-01 | Create "Recommended Habits" card for Dashboard | HIGH | Screen | RQ-005 |
| D-02 | Create Snooze/Ban UI for habit rejection | MEDIUM | Widget | RQ-005 |
| D-03 | Create Identity Roadmap view (if Option B/C) | HIGH | Screen | RQ-007 |
| D-04 | Visualization: Constellation UX OR Tree (PENDING ESCALATE-1) | HIGH | Screen | RQ-007/RQ-017 |

---

## Appendix A: Algorithm Specifications

### Two-Stage Hybrid Retrieval (RQ-005)

```typescript
// Supabase Edge Function: recommend-habits
async function generateRecommendations(userId: string, activeFacetId: string) {
  // Fetch context
  const user = await supabase.from('users').select('dimension_vector').eq('id', userId).single();
  const facet = await supabase.from('identity_facets').select('embedding, energy_state').eq('id', activeFacetId).single();
  const topology = await supabase.from('identity_topology').select('*').eq('source_facet_id', activeFacetId);

  // STAGE 1: Semantic Retrieval (The "What")
  const { data: candidates } = await supabase.rpc('vector_search_habits', {
    query_embedding: facet.embedding,
    match_threshold: 0.7,
    limit: 50
  });

  // STAGE 1.5: Hard Filters (Gating)
  const filtered = candidates.filter(habit => {
    // Energy Gate: Remove habits requiring incompatible energy
    if (habit.required_energy_state && habit.required_energy_state !== facet.energy_state) {
      return false;
    }
    // Topology Gate: Remove high-friction habits during antagonistic state
    const antagonistic = topology.find(t => t.interaction_type === 'antagonistic');
    if (antagonistic && antagonistic.friction_coefficient > 0.7 && habit.difficulty > 0.6) {
      return false;
    }
    return true;
  });

  // STAGE 2: Psychometric Re-ranking (The "How")
  return filtered
    .map(habit => ({
      ...habit,
      matchScore: cosineSimilarity(user.dimension_vector, habit.ideal_dimension_vector)
    }))
    .sort((a, b) => b.matchScore - a.matchScore)
    .slice(0, 5);
}
```

### ICS Formula (Modified)

```dart
double calculateICS(User user, Facet facet) {
  final completions = facet.habits.fold<int>(0, (sum, h) => sum + h.completionCount);
  final gracefulSum = facet.habits.fold<double>(0, (sum, h) => sum + (h.completionCount * h.gracefulScore));
  final daysActive = max(facet.daysActive, 7); // Floor to prevent early inflation

  return gracefulSum / daysActive;
}
```

### Regression Detection (4 Signals)

```dart
bool detectRegression(ContextSnapshot ctx, UserHistory history) {
  int signals = 0;

  // Signal 1: Screen time increase >20%
  if (ctx.screenOnDuration > history.avgScreenTime * 1.2) signals++;

  // Signal 2: First unlock time shift >30 min later
  if (ctx.firstUnlockTime.difference(history.avgFirstUnlock).inMinutes > 30) signals++;

  // Signal 3: JITAI dismissal rate increase
  if (ctx.recentDismissalRate > history.avgDismissalRate * 1.3) signals++;

  // Signal 4: Cross-facet misses (from BurnoutDetector)
  final facetsWithMisses = ctx.missedHabits.map((h) => h.facetId).toSet();
  if (facetsWithMisses.length >= 2) signals++;

  return signals >= 2; // Threshold: 2 of 4 signals
}
```

---

## Appendix B: Content Requirements Summary

| Category | Count | Status |
|----------|-------|--------|
| **Global Archetypes** | 8 | ❌ To create |
| **Universal Habits** | 50 | ❌ To create |
| **Ritual Templates** | 6 | ❌ To create |
| **Framing Templates** | 12 | ❌ To create |
| **Stage Messaging** | 3 | ❌ To create |
| **Regression Messages** | 5 | ❌ To create |
| **TOTAL** | 84 pieces | |

---

## Appendix C: Android Permission Impact

All Identity Coach features operate within existing permission set:

| Feature | Android API | Permission | Already Granted? |
|---------|-------------|------------|------------------|
| Habit recommendations | Supabase (server) | None | ✅ N/A |
| Energy gating | Google Fit | Fitness | ✅ Yes |
| Regression: screenOnDuration | UsageStatsManager | PACKAGE_USAGE_STATS | ✅ Yes |
| Regression: firstUnlockTime | UsageStatsManager | PACKAGE_USAGE_STATS | ✅ Yes |
| Roadmap storage | Supabase (server) | None | ✅ N/A |

**No new permissions required.**

---

## Summary of Reconciled Positions

### RQ-005: Proactive Recommendation Algorithms — ✅ COMPLETE

**Algorithm:** Two-Stage Hybrid Retrieval with Energy/Topology Gating
**Architecture:** "Architect" (async Coach) feeds "Commander" (real-time JITAI)
**Rate Limiting:** 1 recommendation/day, only if <5 habits per facet
**Cold Start:** Trinity Seed from Day 1 Holy Trinity data
**Feedback:** Implicit-dominant with weekly batch updates

### RQ-006: Content Library — ✅ COMPLETE (Spec ready, content to create)

**Universal Habits:** 50 "Atomic" habits with dimension vectors
**Archetypes:** 8 Global Archetypes (reduced from 12)
**Rituals:** 6 templates (Morning, Evening, Transition, Recovery, Focus, Social)
**Framing:** 12 templates (6 dimensions × 2 poles)
**Stages:** Spark (Day 1-7), Dip (Day 8-21), Groove (Day 66+)

### RQ-007: Identity Roadmap Architecture — ✅ COMPLETE (pending ESCALATE-1)

**Extraction:** "Future Self" interview added to Day 3 Sherlock
**Schema:** identity_roadmaps + roadmap_nodes tables
**Matching:** Vector classification via DeepSeek V3.2
**Metrics:** ICS (Identity Consolidation Score) with modified formula
**Regression:** 4-signal detection system
**Visualization:** ⚠️ PENDING ESCALATE-1 (Tree vs Constellation)

---

*This reconciliation was performed per Protocol 9 (AI_AGENT_PROTOCOL.md). All ACCEPT and MODIFY items are ready for implementation pending ESCALATE decisions.*
