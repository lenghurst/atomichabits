# Deep Think Reconciliation: Identity Coach Architecture (RQ-005, RQ-006, RQ-007)

**Source:** DeepSeek Deep Think
**Date:** 10 January 2026
**Reconciled By:** Claude (Opus 4.5)
**Research Target:** RQ-005 (Proactive Recommendation Algorithms), RQ-006 (Content Library), RQ-007 (Identity Roadmap)

---

## Executive Summary

This Deep Think report provides comprehensive architecture for the Identity Coach system. The research quality is **HIGH** — it includes pseudocode, schema definitions, threshold specifications, and battery considerations.

**Reconciliation Results:**
- Total proposals: 21 (across 3 RQs with 7 sub-questions each)
- ✅ ACCEPT: 14
- 🟡 MODIFY: 5
- 🔴 REJECT: 1
- ⚠️ ESCALATE: 1

**Key Strengths:**
- Correctly identifies Two-Stage Hybrid Retrieval (semantic + psychometric)
- Properly separates "Architect" (async) from "Commander" (JITAI)
- Battery-conscious design (Supabase Edge Functions)
- Global Archetype mapping solves infinite facet scaling problem

**Key Concerns:**
- Some terminology inconsistencies with existing psyOS vocabulary
- "Atomic 20" content assumptions need validation
- Identity Consolidation Score formula needs integration with existing metrics

---

## Phase 1: Locked Decision Audit

### CD Conflict Analysis

| Proposal | CD Affected | Status | Resolution |
|----------|-------------|--------|------------|
| Two-Stage Hybrid Retrieval (semantic + psychometric) | CD-016 (AI Model) | ✅ COMPATIBLE | Uses gemini-embedding-001 as specified |
| 4-category energy gating | CD-015 (4-state energy) | ✅ COMPATIBLE | Matches locked 4-state model |
| "Architect" async engine | CD-016 (AI Model) | ✅ COMPATIBLE | DeepSeek V3.2 for background tasks |
| Global Archetype mapping (12 archetypes) | CD-005 (6-dimension) | 🟡 NEEDS ALIGNMENT | Should map to 6 dimensions, not separate archetype system |
| Identity Consolidation Score (ICS) | CD-008 (Identity Coach) | ✅ COMPATIBLE | Extends existing spec |
| Supabase Edge Functions | CD-016 (AI Model) | ✅ COMPATIBLE | Correct backend architecture |
| Regression Detection (Android signals) | CD-017 (Android-First) | ✅ COMPATIBLE | Uses UsageStats, unlock time |

### No CD Conflicts Found

The research respects all locked decisions. The Global Archetype proposal (12 archetypes) requires terminology alignment with existing psyOS vocabulary but doesn't conflict with CDs.

---

## Phase 2: Data Reality Audit (Android-First per CD-017)

### Data Points Assumed by Research

| Data Point | Android Status | Permission | Battery | Action |
|------------|---------------|------------|---------|--------|
| `stepsLast30Min` | ✅ Available | ACTIVITY_RECOGNITION | < 0.1% | INCLUDE |
| `screenOnDuration` | ✅ Available | PACKAGE_USAGE_STATS | < 0.1% | INCLUDE |
| `appCategory` (UsageStats) | ✅ Available | PACKAGE_USAGE_STATS | < 0.1% | INCLUDE |
| First unlock time | ✅ Available | PACKAGE_USAGE_STATS | < 0.1% | INCLUDE |
| Facet embeddings (768-dim) | ✅ Supabase | N/A (server) | 0% | INCLUDE |
| User dimension vector (6-dim) | ✅ Supabase | N/A (server) | 0% | INCLUDE |
| JITAI dismissal rate | ✅ Local DB | N/A | 0% | INCLUDE |
| Calendar data | ✅ Available | CALENDAR | < 0.1% | INCLUDE |

### Battery Impact Assessment

| Component | Battery Impact | Justification |
|-----------|---------------|---------------|
| Two-Stage Retrieval | 0% (server-side) | Supabase Edge Function |
| Nightly recommendation generation | 0% (server-side) | Async job |
| Implicit feedback tracking | < 0.1% | Local DB writes only |
| Regression detection signals | < 0.5% | Piggybacks on existing UsageStats |

**Total Identity Coach Battery Budget:** < 0.6% ✅ Well within CD-015 5% ceiling

### Verdict: PASS

All data points are available on Android without wearables. No battery concerns.

---

## Phase 3: Implementation Reality Audit

### Existing Schema Comparison

| Research Proposal | Existing Implementation | Gap | Action |
|-------------------|------------------------|-----|--------|
| `preference_embedding` (Shadow Vector) | Not implemented | NEW | Create table |
| `identity_roadmaps` table | Not implemented | NEW | Create table |
| `roadmap_nodes` table | Not implemented | NEW | Create table |
| `habit_templates` with `idealDimensionVector` | Habits exist, no dimension tagging | EXTEND | Add field |
| Global Archetype mappings | `identity_facets` exists | EXTEND | Add `global_archetype_id` |

### Existing Code Comparison

| Research Proposal | Existing Code | Gap | Action |
|-------------------|--------------|-----|--------|
| `generateRecommendations()` function | None | NEW | Implement as Edge Function |
| Stage 1 semantic retrieval | `vector_search_habits` RPC exists | ✅ EXISTS | Reuse |
| Stage 2 psychometric re-ranking | None | NEW | Implement in Dart/Edge |
| "Architect" async engine | None | NEW | Implement as scheduled Edge Function |
| Implicit feedback tracking | JITAI tracks outcomes | EXTEND | Add adoption/validation signals |

### Terminology Conflicts

| Research Term | Existing psyOS Term | Resolution |
|---------------|---------------------|------------|
| "Identity Consolidation Score" | No equivalent | ADD to GLOSSARY |
| "Global Archetype" | Conflicts with CD-005 dimensions | RENAME to "Archetype Template" |
| "Shadow Vector" | Conflicts with "Shadow Presence" | RENAME to "Preference Embedding" |
| "The Dip" | No equivalent | ADD to GLOSSARY |
| "Pace Car Protocol" | No equivalent | ADD to GLOSSARY |

---

## Phase 4: Scope & Complexity Audit

### Classification by CD-018 Threshold Framework

| Proposal | Classification | Rationale |
|----------|---------------|-----------|
| **RQ-005: Two-Stage Hybrid Retrieval** | ESSENTIAL | Core recommendation engine; solves cold start |
| **RQ-005: Energy Gating** | ESSENTIAL | Prevents bad recommendations; uses existing 4-state |
| **RQ-005: Architect vs Commander separation** | ESSENTIAL | Correct architecture for battery |
| **RQ-005: Implicit feedback loop** | VALUABLE | Improves over time; not blocking |
| **RQ-005: Snooze vs Ban taxonomy** | VALUABLE | Good UX; not complex |
| **RQ-005: Pace Car Protocol (1/day limit)** | ESSENTIAL | Prevents overwhelm |
| **RQ-005: Trinity Seed (cold start)** | ESSENTIAL | Leverages existing Day 1 data |
| **RQ-006: Atomic 20 habits** | ESSENTIAL | Content is a blocker |
| **RQ-006: Transition-Based Rituals** | VALUABLE | Extends energy state model |
| **RQ-006: Progression Milestones** | VALUABLE | User motivation |
| **RQ-006: 6-Dimension Framing Matrix** | ESSENTIAL | Required for personalization |
| **RQ-006: Global Archetype Bridge (12 templates)** | ESSENTIAL | Solves infinite facet problem |
| **RQ-006: Regression Messaging** | ESSENTIAL | Prevents shame spirals |
| **RQ-006: Launch Library (50+12+12+4)** | ESSENTIAL | Content is a blocker |
| **RQ-007: Future Self Interview (Day 3)** | VALUABLE | Extends Sherlock protocol |
| **RQ-007: identity_roadmaps schema** | ESSENTIAL | Core data model |
| **RQ-007: Aspiration → Facet mapping** | VALUABLE | Automates facet creation |
| **RQ-007: Identity Consolidation Score (ICS)** | VALUABLE | Good metric; needs integration with existing |
| **RQ-007: Regression Detection (Android signals)** | NICE-TO-HAVE | Derivative of existing data |
| **RQ-007: Identity Tree visualization** | VALUABLE | Extends Skill Tree; not blocking |

### Scope Expansion Check

| Original RQ Scope | Research Output | Verdict |
|-------------------|-----------------|---------|
| RQ-005: Algorithms | Provided complete algorithm + pseudocode | ✅ On scope |
| RQ-006: Content Library | Provided taxonomy + quantities | ✅ On scope |
| RQ-007: Roadmap Architecture | Provided schema + ICS formula | ✅ On scope |

**No scope creep detected.** Research stays within original RQ boundaries.

---

## Phase 5: ACCEPT / MODIFY / REJECT / ESCALATE

### ✅ ACCEPT (Integrate as-is) — 14 items

| # | Proposal | RQ | Rationale |
|---|----------|------|-----------|
| 1 | Two-Stage Hybrid Retrieval (semantic + psychometric) | RQ-005 | Mathematically sound; uses existing pgvector |
| 2 | Energy Gating hard filter | RQ-005 | Uses locked 4-state model (CD-015) |
| 3 | Architect vs Commander separation | RQ-005 | Correct architecture; battery-conscious |
| 4 | Pace Car Protocol (1 recommendation/day) | RQ-005 | Prevents cognitive overload |
| 5 | Trinity Seed for cold start | RQ-005 | Leverages existing Day 1 extraction |
| 6 | Implicit feedback signals (+5 adoption, +10 validation, -5 dismiss, -0.5 decay) | RQ-005 | Reasonable weights; can tune later |
| 7 | Snooze (14d) vs Ban taxonomy | RQ-005 | Good UX pattern |
| 8 | Transition-Based Ritual taxonomy (Activation, Shutdown, Airlock) | RQ-006 | Aligns with RQ-018 Airlock research |
| 9 | Progression Milestones (Spark→Dip→Groove) | RQ-006 | Backed by habit formation literature |
| 10 | 6-Dimension Framing Matrix | RQ-006 | Required for CD-005 compliance |
| 11 | Regression Messaging (data-driven normalization) | RQ-006 | Prevents maladaptive perfectionism trigger |
| 12 | identity_roadmaps + roadmap_nodes schema | RQ-007 | Clean relational design |
| 13 | Future Self Interview (Day 3 Sherlock extension) | RQ-007 | Extracts aspiration with behavior |
| 14 | Habit → Aspiration matching (vector space) | RQ-007 | Uses existing pgvector infra |

### 🟡 MODIFY (Adjust for reality) — 5 items

| # | Proposal | Original | Adjusted | Rationale |
|---|----------|----------|----------|-----------|
| 1 | Global Archetype Bridge (12 archetypes) | 12 named archetypes (Builder, Nurturer, etc.) | **Rename to "Archetype Templates"** and map to 6-dimension vectors, not a separate classification | CD-005 locks 6-dimension model; these should be preset dimension combinations, not a parallel system |
| 2 | "Shadow Vector" terminology | Shadow Vector for preference embedding | **Rename to "Preference Embedding"** | "Shadow" conflicts with existing "Shadow Presence" term in GLOSSARY |
| 3 | Atomic 20 habit collection | 20 universal habits | **Expand to 50 habits** tagged with Energy State + Dimensions; validate list against behavior science literature | 20 may be insufficient for diversity; research suggests 50 per content library spec |
| 4 | Identity Consolidation Score formula | `ICS = Σ(Votes × Consistency) / DaysActive` | **Integrate with existing Identity Evidence** scoring; consider using `hexis_score` evolution instead | Multiple score systems create confusion; consolidate |
| 5 | Aspiration → Facet mapping via DeepSeek V3.2 | Use DeepSeek for classification | **Use gemini-embedding-001 for embedding, classify by vector similarity** | More consistent with CD-016 model allocation (embeddings = Gemini) |

### 🔴 REJECT (Do not implement) — 1 item

| # | Proposal | Reason |
|---|----------|--------|
| 1 | Regression Detection: "First unlock time shifts later > 30 mins" as leading indicator | **Too noisy as standalone signal.** Natural variation in wake times (weekends, schedule changes) would trigger false positives. ONLY use when combined with 2+ other signals (escapism + avoidance). |

### ⚠️ ESCALATE (Human decision required) — 1 item

| # | Proposal | Options | Recommendation |
|---|----------|---------|----------------|
| 1 | **Content Library Size at Launch** | (A) 50 habits + 12 templates = "Atomic Launch" (fast), (B) 100 habits + 24 templates = "Rich Launch" (thorough), (C) 200+ habits = "Full Library" (comprehensive) | **Option A** — ship fast, iterate based on feedback. Content creation is expensive; start with validated core. |

---

## Phase 6: Integration

### Tasks Extracted (Protocol 8)

| ID | Task | Priority | Component | Source | Status |
|----|------|----------|-----------|--------|--------|
| **F-01** | Create `preference_embeddings` table | HIGH | Database | RQ-005 | 🔴 TODO |
| **F-02** | Create `identity_roadmaps` table | CRITICAL | Database | RQ-007 | 🔴 TODO |
| **F-03** | Create `roadmap_nodes` table | CRITICAL | Database | RQ-007 | 🔴 TODO |
| **F-04** | Add `ideal_dimension_vector` to `habit_templates` | HIGH | Database | RQ-005 | 🔴 TODO |
| **F-05** | Add `archetype_template_id` to `identity_facets` | HIGH | Database | RQ-006 | 🔴 TODO |
| **F-06** | Create `archetype_templates` reference table (12 presets) | HIGH | Database | RQ-006 | 🔴 TODO |
| **F-07** | Implement `generateRecommendations()` Edge Function | CRITICAL | Backend | RQ-005 | 🔴 TODO |
| **F-08** | Implement Stage 1: Semantic retrieval | CRITICAL | Backend | RQ-005 | 🔴 TODO |
| **F-09** | Implement Stage 2: Psychometric re-ranking | CRITICAL | Backend | RQ-005 | 🔴 TODO |
| **F-10** | Implement "Architect" scheduler (nightly/weekly) | HIGH | Backend | RQ-005 | 🔴 TODO |
| **F-11** | Implement feedback signal tracking (adoption, validation, dismissal) | HIGH | Service | RQ-005 | 🔴 TODO |
| **F-12** | Extend Sherlock Day 3: "Future Self Interview" prompt | HIGH | Onboarding | RQ-007 | 🔴 TODO |
| **F-13** | Create 50 universal habit templates with dimension tagging | CRITICAL | Content | RQ-006 | 🔴 TODO |
| **F-14** | Create 12 Archetype Template presets with dimension vectors | HIGH | Content | RQ-006 | 🔴 TODO |
| **F-15** | Create 12 Framing Templates (6 dims × 2 poles) | HIGH | Content | RQ-006 | 🔴 TODO |
| **F-16** | Create 4 Ritual Templates (Activation, Shutdown, Airlock, Recovery) | MEDIUM | Content | RQ-006 | 🔴 TODO |
| **F-17** | Implement `ProactiveRecommendation` Dart model | HIGH | Service | RQ-005 | 🔴 TODO |
| **F-18** | Implement `IdentityRoadmapService` | HIGH | Service | RQ-007 | 🔴 TODO |
| **F-19** | Implement Pace Car rate limiting (1/day) | HIGH | Service | RQ-005 | 🔴 TODO |
| **F-20** | Create regression messaging templates | MEDIUM | Content | RQ-006 | 🔴 TODO |

### GLOSSARY Terms to Add

| Term | Definition | Source |
|------|------------|--------|
| **Identity Consolidation Score (ICS)** | Metric tracking identity evidence strength: `ICS = Σ(Votes × Consistency) / DaysActive`. Visual: Seed → Sapling → Oak. | RQ-007 |
| **Archetype Template** | One of 12 preset dimension-vector combinations (e.g., "The Builder", "The Nurturer") used to map infinite user-created facet names to curated content. | RQ-006 |
| **Preference Embedding** | A 768-dim vector representing user's learned taste in habits, updated via implicit feedback signals. | RQ-005 |
| **The Architect** | Async recommendation engine (Supabase Edge Function) that generates "New Habit Suggestion" cards. Runs nightly/weekly. | RQ-005 |
| **The Commander** | Real-time JITAI decision engine. Locked per CD-016. | RQ-005 |
| **Pace Car Protocol** | Rate limiting rule: maximum 1 proactive recommendation per day per user. | RQ-005 |
| **Trinity Seed** | Cold-start recommendation strategy using Holy Trinity (Anti-Identity, Failure Archetype, Resistance Lie) from Day 1. | RQ-005 |
| **The Spark** | Progression stage: Days 1-7, "Identity Claimed". | RQ-006 |
| **The Dip** | Progression stage: Days 8-21, "Resistance Detected". Key dropout risk period. | RQ-006 |
| **The Groove** | Progression stage: Day 66+, "Automaticity Achieved". | RQ-006 |

### RQ Status Updates

| RQ | Old Status | New Status | Key Deliverables |
|----|------------|------------|------------------|
| RQ-005 | 🔴 NEEDS RESEARCH | ✅ COMPLETE | Two-Stage Hybrid Retrieval, Architect separation, feedback loop, cold start strategy |
| RQ-006 | 🔴 NEEDS RESEARCH | ✅ COMPLETE | Launch library spec (50+12+12+4), dimension framing matrix, archetype bridge |
| RQ-007 | 🔴 NEEDS RESEARCH | ✅ COMPLETE | Roadmap schema, ICS formula, Future Self Interview, aspiration mapping |

### Dependency Updates

```
RQ-005 (Proactive Algorithms) ✅
├── Depends on: RQ-001 (Dimensions) ✅
├── Depends on: RQ-012 (Fractal Trinity) ✅
├── Enables: F-07 through F-11 (Backend tasks)
└── Enables: F-17 (ProactiveRecommendation model)

RQ-006 (Content Library) ✅
├── Depends on: RQ-005 (algorithms need content)
├── Enables: F-13 through F-16 (Content tasks)
└── BLOCKS: Full Identity Coach launch (content is a blocker)

RQ-007 (Identity Roadmap) ✅
├── Depends on: RQ-005 (recommendations feed roadmap)
├── Enables: F-02, F-03, F-12, F-18
└── Enables: Progression UI in Constellation
```

---

## Reconciliation Summary

### What We Gained

1. **Complete recommendation algorithm** — Two-Stage Hybrid Retrieval is implementable
2. **JITAI separation clarified** — "Architect" (async) vs "Commander" (realtime) is correct
3. **Cold start solved** — Trinity Seed uses existing Day 1 data
4. **Scaling solved** — Archetype Templates handle infinite facet names
5. **Content spec** — Clear launch library requirements (50+12+12+4)
6. **Schema additions** — 3 new tables, 2 field additions

### What We Changed

1. **Renamed "Shadow Vector"** → "Preference Embedding" (avoid GLOSSARY conflict)
2. **Renamed "Global Archetype"** → "Archetype Template" (align with CD-005)
3. **Rejected standalone unlock-time regression** (too noisy; requires multi-signal)
4. **Modified Aspiration mapping** — Use Gemini embeddings, not DeepSeek (per CD-016)
5. **Modified ICS** — Integrate with existing scoring, don't duplicate

### Human Decision Required

**Content Library Size at Launch:**
- Option A: 50 habits (fast launch)
- Option B: 100 habits (thorough)
- Option C: 200+ habits (comprehensive)

**Recommendation:** Option A — ship fast, iterate based on feedback.

---

## Next Steps

1. **Immediate:** Update RESEARCH_QUESTIONS.md with RQ-005/006/007 completion
2. **Immediate:** Add 10 GLOSSARY terms
3. **Immediate:** Add 20 implementation tasks to Master Tracker
4. **Human Required:** Confirm content library size before F-13 starts
5. **Blocked:** F-13–F-16 require content creation (human or external resource)

---

*Reconciliation complete. Protocol 9 applied successfully.*
