# Identity Coach Deep Analysis — Exhaustive Documentation

**Date:** 10 January 2026
**Analyst:** Claude (Opus 4.5)
**Source:** DeepSeek Deep Think Research Report (RQ-005, RQ-006, RQ-007)
**Purpose:** Exhaustive documentation of concepts, emerging RQs/PDs, and system-wide impact analysis

---

## Part 1: Exhaustive Concept Documentation

### 1.1 Two-Stage Hybrid Retrieval Architecture

**The Core Innovation:**
DeepSeek proposes separating recommendation matching into two mathematically distinct operations:

```
STAGE 1: Semantic Retrieval ("The What")
├── Input: Active Facet embedding (768-dim, gemini-embedding-001)
├── Operation: pgvector cosine similarity search
├── Output: Top 50 habits conceptually related to facet
└── Example: "Father" facet → ["Read to kids", "Family dinner", "Teach skill"]

STAGE 2: Psychometric Re-ranking ("The How")
├── Input: Stage 1 candidates + User dimension vector (6-dim)
├── Operation: Cosine similarity against habit's ideal_dimension_vector
├── Output: Sorted list by personality fit
└── Example: Prevention user → Safety-framed habits ranked higher
```

**Why This Matters (Critical Insight):**
DeepSeek explicitly calls out the **"Mathematical Mismatch"** problem — you cannot meaningfully blend 6-dimensional psychometric data with 768-dimensional semantic embeddings in a single vector. This is not a preference; it's a mathematical constraint.

**Implications:**
1. Every habit in our library MUST have TWO embeddings:
   - 768-dim semantic embedding (auto-generated from description)
   - 6-dim ideal dimension vector (MANUALLY curated per habit)
2. This manual curation is a **content creation burden** — not previously accounted for
3. Stage 2 can happen client-side (Dart) since it's only 6-dim math

**Open Question:** Who curates the `ideal_dimension_vector` for each habit? Is this a one-time setup or ongoing refinement?

---

### 1.2 The Architect vs The Commander Model

**Architectural Separation:**

| Aspect | The Architect | The Commander (JITAI) |
|--------|---------------|----------------------|
| **Philosophy** | Strategic planner | Tactical executor |
| **Question Answered** | "What should user try next?" | "When should we intervene NOW?" |
| **Execution Location** | Supabase Edge Function (server) | On-device (Flutter) |
| **Frequency** | Nightly/Weekly batch | Real-time (<100ms) |
| **Battery Impact** | 0% (server-side) | <5% ceiling (CD-015) |
| **Output** | "New Habit Suggestion" cards | Intervention timing decision |
| **Learning Model** | Preference embedding updates | Thompson Sampling bandit |

**Critical Design Constraint:**
The Architect places cards into JITAI's `content_queue`. The Commander decides WHEN to show them. This means:
- Architect outputs are NOT immediately shown to user
- Commander can defer Architect suggestions based on V-O state
- This creates a potential stale-card problem (suggestion generated Tuesday, shown Saturday)

**Implication:** Cards need a `generated_at` timestamp and potentially a `stale_after` TTL.

---

### 1.3 Facet-Aware Gating (Hard Filters)

**The Problem DeepSeek Identified:**
Recommending a "High Focus" habit to a user whose active facet operates during "Recovery" hours guarantees failure.

**Two-Level Gating:**

```
FILTER 1: Energy State Gate (RQ-014)
├── Check: Does habit's required energy_state match facet's typical window?
├── Example: "Deep Work Protocol" requires high_focus
├── If facet "Father" operates 6-8pm (recovery) → EXCLUDE
└── Rationale: Energy mismatch creates friction

FILTER 2: Topology Antagonism Gate (RQ-013)
├── Check: Is active facet antagonistic to another currently active facet?
├── If yes → Suppress high-friction habits
└── Rationale: Avoid burnout during internal conflict
```

**Integration Point:** This connects directly to:
- `identity_topology.friction_coefficient` (RQ-013)
- `EnergyState` enum (RQ-014, task B-08)
- `inferEnergyState()` function (RQ-014, task B-09)

**Gap Identified:** Neither RQ-013 nor RQ-014 explicitly defined what "typical window" means for a facet. We need to add `typical_energy_state` to facets.

---

### 1.4 Implicit Feedback Signal Hierarchy

**DeepSeek's Signal Weights:**

| Signal | Weight | Trigger | Rationale |
|--------|--------|---------|-----------|
| **Validation** | +10.0 | Completes habit 3x in first week | Strongest signal — user actually doing it |
| **Adoption** | +5.0 | Adds habit to schedule | Commitment signal |
| **Explicit Dismissal** | -5.0 | "Not for me" button | Clear rejection |
| **Implicit Decay** | -0.5 | Card ignored 3x | Soft disinterest |

**Critical Design Decision:**
These weights update a `preference_embedding` (768-dim vector) that fine-tunes Stage 1 retrieval. This is a **shadow preference model** running alongside the explicit facet/dimension data.

**Concerns:**
1. **Cold Start Conflict:** Trinity Seed uses explicit data; preference embedding is implicit. How do they interact?
2. **Drift Risk:** Over time, implicit preferences may diverge from stated aspirations
3. **Transparency:** User cannot see or modify preference embedding — is this problematic for autonomy?

---

### 1.5 Snooze vs Ban Taxonomy

**User Rejection UX:**

| Action | Duration | Effect | Use Case |
|--------|----------|--------|----------|
| **"Not Now" (Snooze)** | 14 days | Suppress temporarily | Bad timing, energy mismatch |
| **"Not Me" (Ban)** | Permanent | Block habit ID + subtract from preference vector | Fundamentally wrong fit |

**Mathematical Detail (from DeepSeek):**
"Subtract a fraction of this habit's vector from the user's preference vector."

This implies: `preference_embedding = preference_embedding - α * banned_habit_embedding`

**Unspecified:**
- What is α (the fraction)? DeepSeek doesn't say.
- Does ban affect all facets or just current facet?
- Can user undo a ban?

---

### 1.6 Pace Car Protocol

**Rate Limiting Rule:**
- Maximum **1 proactive recommendation per day** per user
- Only triggered if user has **< 5 active habits per facet**

**Rationale (from DeepSeek):**
"Cognitive Load Theory. Introducing multiple behaviors triggers 'Choice Overload.'"

**Implications:**
1. Heavy users (5+ habits/facet) get NO proactive recommendations — is this correct?
2. What about users with multiple facets? 1/day total or 1/day/facet?
3. Does the limit apply to system-generated recommendations only, or also user-requested?

**My Assessment:** The 5-habit threshold seems arbitrary. Should be researched.

---

### 1.7 Trinity Seed (Cold Start Strategy)

**Leveraging Day 1 Data:**

| Holy Trinity Component | Extracted Signal | Recommendation Type |
|------------------------|------------------|---------------------|
| Anti-Identity ("Lazy") | Fear/Prevention focus | Prevention-framed habit (micro-movement) |
| Failure Archetype ("Perfectionist") | Historical pattern | Floor Habit (low bar to prove success) |
| Dimension Vector | 6-dim personality | Personality-matched framing |

**Elegance:**
This solves cold start by using data we already extract on Day 1, rather than requiring new inputs.

**Gap:**
DeepSeek assumes clean extraction of these signals. Our current Sherlock prompts (per AI_HANDOVER.md) are in conflict — two prompts exist, neither explicitly extracts dimensional signals.

**Dependency:** This requires PD-101 (Sherlock Prompt Overhaul) to be resolved first.

---

### 1.8 Global Archetype Bridge (Now: Archetype Templates)

**The Scaling Problem:**
Users create infinite facet names ("Super-Dad", "Code Ninja", "Morning Warrior"). We cannot write custom content for each.

**DeepSeek's Solution:**
Map user-created facets to **12 Global Archetypes** using vector similarity:

```
User facet "Super-Dad"
    ↓ Embed facet name (768-dim)
    ↓ Cosine similarity against 12 archetype embeddings
    ↓ Closest match: "The Nurturer"
    ↓ User receives content written for "The Nurturer"
```

**The 12 Archetypes (from my earlier categorization, needs validation):**

| Archetype | Core Focus | Primary Dimensions |
|-----------|------------|-------------------|
| The Builder | Achievement, creation | Promotion, Future |
| The Nurturer | Care, relationships | Prevention, Social |
| The Warrior | Discipline, challenge | Promotion, Executor |
| The Scholar | Learning, mastery | Future, Overthinker |
| The Healer | Wellness, recovery | Prevention, Recovery |
| The Creator | Expression, art | Promotion, Rebel |
| The Guardian | Protection, stability | Prevention, Conformist |
| The Explorer | Adventure, novelty | Promotion, Present |
| The Sage | Wisdom, reflection | Future, Overthinker |
| The Leader | Influence, teams | Social, Executor |
| The Devotee | Practice, faith | Conformist, Recovery |
| The Rebel | Independence, change | Rebel, Present |

**Critical Gap:**
DeepSeek provides the CONCEPT but not the CONTENT. We need:
1. Precise definition of each archetype
2. 768-dim embedding for each archetype name
3. 6-dim "ideal dimension vector" for each archetype
4. Content library written FOR each archetype

---

### 1.9 Identity Consolidation Score (ICS)

**Formula:**
```
ICS = Σ(Votes × Consistency) / DaysActive
```

**Visual Metaphor:**
| Stage | ICS Range | Visual | User State |
|-------|-----------|--------|------------|
| **Seed** | 0.0 - 0.3 | Small seed | Claimed identity, fragile |
| **Sapling** | 0.3 - 0.6 | Growing tree | Building evidence |
| **Oak** | 0.6 - 1.0 | Full tree | Automatic, stable |

**Concerns:**
1. **Overlap with hexis_score:** We already have a scoring system. How do they relate?
2. **What are "Votes"?** DeepSeek doesn't define. Likely identity evidence count.
3. **Consistency formula:** Not specified. Is it streak-based or graceful_score?
4. **Per-facet or global?** DeepSeek's schema suggests per-roadmap (per facet-aspiration pair)

---

### 1.10 Progression Stages (The Spark / The Dip / The Groove)

**Evidence-Based Milestones:**

| Stage | Days | Psychological State | Intervention Strategy |
|-------|------|---------------------|----------------------|
| **The Spark** | 1-7 | High motivation, identity claimed | Celebrate, reinforce |
| **The Dip** | 8-21 | Motivation fading, not yet automatic | Normalize struggle, prevent shame |
| **The Groove** | 66+ | Automaticity achieved | Maintenance mode, suggest leveling up |

**Critical Insight (from DeepSeek):**
"Day 8 is the most common drop-off point."

This aligns with habit formation literature (Phillippa Lally) but should be validated against our own data.

**Implementation Impact:**
- JITAI tone should adapt to stage
- Regression messaging should reference statistical norms
- Day 7 → Day 8 is a critical transition requiring special handling

---

### 1.11 Regression Detection (Android Signals)

**Leading Indicators:**

| Signal | Threshold | Source | Confidence |
|--------|-----------|--------|------------|
| **Escapism** | screenOnDuration > 20% vs baseline | UsageStats | MEDIUM |
| **Dysregulation** | First unlock shifts > 30 min later | UsageStats | MEDIUM |
| **Avoidance** | JITAI dismissal rate increases | Local DB | MEDIUM |

**My Rejection (from Protocol 9):**
I rejected "first unlock shift" as a standalone signal because:
- Natural variation (weekends, travel) creates false positives
- Only valid when combined with 2+ other signals

**DeepSeek's Classification:**
"NICE-TO-HAVE" — not essential for launch.

---

### 1.12 Future Self Interview (Day 3 Sherlock Extension)

**Prompt:**
> "Fast forward 1 year. You are proud of who you've become. What is one specific thing that version of you does every day?"

**Why Day 3 (not Day 1):**
- Day 1: User focused on Holy Trinity (fear, pattern, excuse)
- Day 3: User has enough context to project forward
- Avoids cognitive overload on first session

**Output Extraction:**
- Identity aspiration: "I am someone who..."
- Concrete behavior: "...exercises daily"

**Integration:**
This feeds into `identity_roadmaps.aspiration_label` and can auto-create a roadmap.

---

## Part 2: Emerging Research Questions (New RQs)

Based on gaps identified in Deep Think analysis:

### RQ-028: Archetype Template Definitions & Content Strategy

| Field | Value |
|-------|-------|
| **Question** | What are the precise definitions, embeddings, and content libraries for each of the 12 Archetype Templates? |
| **Status** | 🔴 NEEDS RESEARCH |
| **Priority** | **CRITICAL** — Blocks F-06, F-13, F-14 |
| **Blocking** | Content creation pipeline, Facet-to-content mapping |
| **Sub-Questions** | |

| # | Sub-Question |
|---|--------------|
| 1 | What is the precise psychological definition of each archetype? |
| 2 | What is the 768-dim embedding for each archetype name? |
| 3 | What is the 6-dim ideal_dimension_vector for each archetype? |
| 4 | How do we validate archetype assignments (user feedback, A/B test)? |
| 5 | Should users be able to override automatic archetype mapping? |
| 6 | How do we handle facets that don't cleanly match any archetype? |

---

### RQ-029: Ideal Dimension Vector Curation Process

| Field | Value |
|-------|-------|
| **Question** | How do we systematically assign ideal_dimension_vectors to the 50+ habit templates? |
| **Status** | 🔴 NEEDS RESEARCH |
| **Priority** | HIGH — Blocks psychometric re-ranking accuracy |
| **Blocking** | Two-Stage Retrieval Stage 2, F-13 |
| **Sub-Questions** | |

| # | Sub-Question |
|---|--------------|
| 1 | Can we auto-derive dimension vectors from habit descriptions (LLM-assisted)? |
| 2 | What validation process ensures dimension vectors are accurate? |
| 3 | Should dimension vectors be adjustable based on population learning? |
| 4 | How do we handle habits that span multiple dimension poles? |

---

### RQ-030: Preference Embedding Update Mechanics

| Field | Value |
|-------|-------|
| **Question** | How exactly does the preference embedding get updated, and what are the mathematical/behavioral implications? |
| **Status** | 🔴 NEEDS RESEARCH |
| **Priority** | MEDIUM — Affects long-term personalization |
| **Blocking** | Feedback loop implementation (F-11) |
| **Sub-Questions** | |

| # | Sub-Question |
|---|--------------|
| 1 | What is α (the fraction) for "ban" vector subtraction? |
| 2 | How do we prevent preference drift from stated aspirations? |
| 3 | Should preference embedding be visible/editable by user? |
| 4 | How often should we re-compute embedding (every signal vs batched)? |
| 5 | What's the interaction between preference embedding and Trinity Seed? |

---

### RQ-031: Pace Car Threshold Validation

| Field | Value |
|-------|-------|
| **Question** | Is 1 recommendation/day and 5-habit threshold optimal, or should these be dynamic? |
| **Status** | 🔴 NEEDS RESEARCH |
| **Priority** | MEDIUM — UX quality |
| **Blocking** | F-19 (Pace Car implementation) |
| **Sub-Questions** | |

| # | Sub-Question |
|---|--------------|
| 1 | Should recommendation frequency adapt to user engagement level? |
| 2 | Is 5 habits/facet the right threshold, or should it be personalized? |
| 3 | Should multi-facet users get 1/day total or 1/day/facet? |
| 4 | What happens when user explicitly requests recommendations? |

---

### RQ-032: ICS Integration with Existing Metrics

| Field | Value |
|-------|-------|
| **Question** | How does Identity Consolidation Score (ICS) integrate with existing hexis_score and graceful_score? |
| **Status** | 🔴 NEEDS RESEARCH |
| **Priority** | HIGH — Prevents metric fragmentation |
| **Blocking** | F-18 (IdentityRoadmapService) |
| **Sub-Questions** | |

| # | Sub-Question |
|---|--------------|
| 1 | Should ICS replace hexis_score or coexist? |
| 2 | How is "Votes" defined in the ICS formula? |
| 3 | How is "Consistency" calculated (streak vs graceful)? |
| 4 | Is ICS per-facet, per-roadmap, or per-habit? |

---

## Part 3: Emerging Product Decisions (New PDs)

### PD-121: Archetype Template Count & Definitions

| Field | Value |
|-------|-------|
| **Decision** | Should we use 12 archetypes (DeepSeek proposal) or a different number? |
| **Status** | 🔴 PENDING |
| **Requires** | RQ-028 |
| **Options** | |

| Option | Description | Trade-off |
|--------|-------------|-----------|
| **A: 12 Archetypes** | DeepSeek's proposal | Good coverage, moderate content burden |
| **B: 6 Archetypes** | One per dimension pole | Less content, coarser matching |
| **C: 24 Archetypes** | Dimension × 4 quadrants | Better matching, heavy content burden |

**Recommendation:** Option A (12) — validated by Jungian archetype literature.

---

### PD-122: User Visibility of Preference Embedding

| Field | Value |
|-------|-------|
| **Decision** | Should users be able to see and/or modify their learned preference embedding? |
| **Status** | 🔴 PENDING |
| **Requires** | RQ-030 |
| **Options** | |

| Option | Description | Trade-off |
|--------|-------------|-----------|
| **A: Hidden** | User never sees preference embedding | Simpler UX, less transparency |
| **B: Visible (read-only)** | User can see but not modify | Transparency without complexity |
| **C: Editable** | User can adjust preferences | Full control, but complex UX |

**Recommendation:** Option B — transparency supports autonomy (psyOS philosophy).

---

### PD-123: Facet Typical Energy State Field

| Field | Value |
|-------|-------|
| **Decision** | Should we add `typical_energy_state` to facets to enable energy gating? |
| **Status** | 🔴 PENDING |
| **Requires** | None — architectural |
| **Options** | |

| Option | Description | Trade-off |
|--------|-------------|-----------|
| **A: Add field** | Explicit user configuration | Accurate, but adds onboarding friction |
| **B: Infer from behavior** | Learn from habit completion times | No friction, but takes time to learn |
| **C: Use time-of-day proxy** | Derive from facet activation patterns | Middle ground |

**Recommendation:** Option C — least friction, reasonable accuracy.

---

### PD-124: Recommendation Card Staleness Handling

| Field | Value |
|-------|-------|
| **Decision** | How do we handle Architect-generated cards that haven't been shown for days? |
| **Status** | 🔴 PENDING |
| **Requires** | None — architectural |
| **Options** | |

| Option | Description | Trade-off |
|--------|-------------|-----------|
| **A: No expiry** | Cards stay in queue indefinitely | Simple, but may show outdated suggestions |
| **B: 7-day TTL** | Cards expire if not shown within 7 days | Fresh recommendations, may waste compute |
| **C: Context-sensitive** | Expire based on changing user context | Accurate but complex |

**Recommendation:** Option B — simple and reasonable.

---

## Part 4: Upstream/Downstream Impact Analysis

### 4.1 Impact on Confirmed Decisions (CDs)

| CD | Impact | Details | Action Required |
|----|--------|---------|-----------------|
| **CD-005** (6-Dimension) | ✅ ENHANCED | Archetype Templates are dimension-vector presets | None — compatible |
| **CD-008** (Identity Coach) | ✅ FULFILLED | RQ-005/006/007 deliver the Coach architecture | Update spec |
| **CD-009** (Content Library) | ⚠️ SCOPE EXPANDED | Now need 50+ habits × 2 embeddings each | Update content requirements |
| **CD-015** (psyOS) | ✅ ENHANCED | Two-Stage Retrieval respects Parliament metaphor | None — compatible |
| **CD-016** (AI Models) | ✅ VALIDATED | Confirms gemini-embedding-001 for embeddings, DeepSeek for reasoning | None |
| **CD-017** (Android-First) | ✅ VALIDATED | All signals available, battery compliant | None |
| **CD-018** (Threshold) | ✅ APPLIED | Classifications used throughout | None |

**No CD conflicts.** Identity Coach architecture builds on existing decisions without modification.

---

### 4.2 Impact on Pending Decisions (PDs)

| PD | Current Status | New Status | Impact Details |
|----|----------------|------------|----------------|
| **PD-105** (Unified AI Coaching) | PENDING on RQ-005/6/7 | **READY FOR DECISION** | Research complete; can now decide architecture |
| **PD-107** (Proactive Guidance System) | RESHAPED | **READY FOR DECISION** | Two-Stage Retrieval + Architect model defined |
| **PD-101** (Sherlock Prompt) | PENDING | **DEPENDENCY ADDED** | Trinity Seed requires clean dimension extraction |
| **PD-102** (JITAI Hardcoded vs AI) | PENDING | **CLARIFIED** | Commander (JITAI) remains hardcoded; Architect is AI |

---

### 4.3 Impact on Existing RQs

| RQ | Status | Impact | Details |
|----|--------|--------|---------|
| **RQ-013** (Identity Topology) | ✅ COMPLETE | EXTENDED | Need to consider `typical_energy_state` for facets |
| **RQ-014** (State Economics) | ✅ COMPLETE | CONNECTED | Energy gating uses 4-state model directly |
| **RQ-017** (Constellation UX) | NEEDS RESEARCH | **NEW INPUT** | ICS + Spark/Dip/Groove provide visualization data |
| **RQ-018** (Airlock Protocol) | NEEDS RESEARCH | **CONNECTED** | Ritual Templates (Activation, Shutdown, Airlock) align |
| **RQ-023** (Population Learning) | NEEDS RESEARCH | **CONNECTED** | Preference embeddings can feed population clusters |

---

### 4.4 Downstream Cascade

```
RQ-005/006/007 (COMPLETE)
│
├── UNBLOCKS: PD-105, PD-107 (ready for decision)
│
├── GENERATES: RQ-028, RQ-029, RQ-030, RQ-031, RQ-032 (new research)
│
├── GENERATES: PD-121, PD-122, PD-123, PD-124 (new decisions)
│
├── ENABLES: F-01 through F-20 (implementation tasks)
│   └── BLOCKS: F-13 needs RQ-028 (archetype definitions)
│
├── FEEDS INTO: RQ-017 (Constellation UX)
│   └── ICS + progression stages → visualization inputs
│
├── FEEDS INTO: RQ-018 (Airlock Protocol)
│   └── Ritual Templates → concrete airlock examples
│
└── FEEDS INTO: RQ-023 (Population Learning)
    └── Preference embeddings → population cluster inputs
```

---

## Part 5: Roadmap Impact Assessment

### 5.1 Current Phase Structure (from ROADMAP.md)

```
Phase A: Schema Foundation
Phase B: Intelligence Layer
Phase C: Council AI System
Phase D: UX & Frontend
Phase E: Polish & Advanced
```

### 5.2 New Phase F: Identity Coach (Proposed)

Given the scope of F-01 through F-20, I propose adding a dedicated phase:

```
Phase F: Identity Coach System
├── F-01 through F-06: Database (Tables + Fields)
├── F-07 through F-11: Backend (Edge Functions + Scheduler)
├── F-12: Onboarding (Sherlock Day 3)
├── F-13 through F-16, F-20: Content (Templates)
├── F-17 through F-19: Service (Dart models + rate limiting)
└── BLOCKED: F-13 requires RQ-028 (Archetype Definitions)
```

### 5.3 Execution Order

**Critical Path (Schema → Backend → Content):**
```
1. F-02 (identity_roadmaps) → F-03 (roadmap_nodes)
2. F-06 (archetype_templates) → Needs RQ-028 first
3. F-07, F-08, F-09 (generateRecommendations Edge Function)
4. F-13 through F-16 (Content creation) → In parallel with #3
5. F-17, F-18, F-19 (Dart services)
6. F-12 (Sherlock Day 3 extension)
```

**Blocker Analysis:**
- **F-06, F-13, F-14** are blocked by RQ-028 (Archetype Template Definitions)
- **RQ-028** is new research — must be completed before content creation

### 5.4 Timeline-Free Implementation Order

Per Protocol 3 (no timelines), here's the dependency-ordered task sequence:

```
WAVE 1 (No dependencies):
├── F-01: preference_embeddings table
├── F-02: identity_roadmaps table
├── F-03: roadmap_nodes table
├── F-04: Add ideal_dimension_vector to habit_templates
├── F-05: Add archetype_template_id to identity_facets
└── RQ-028: Research archetype definitions (PARALLEL)

WAVE 2 (After Wave 1):
├── F-06: archetype_templates table (after RQ-028)
├── F-07: generateRecommendations() Edge Function
├── F-08: Stage 1 Semantic retrieval
├── F-09: Stage 2 Psychometric re-ranking
└── F-17: ProactiveRecommendation Dart model

WAVE 3 (After Wave 2):
├── F-10: Architect scheduler
├── F-11: Feedback signal tracking
├── F-18: IdentityRoadmapService
├── F-19: Pace Car rate limiting
└── F-13: 50 universal habit templates (content)

WAVE 4 (After Wave 3):
├── F-14: 12 Archetype Template content
├── F-15: 12 Framing Templates
├── F-16: 4 Ritual Templates
└── F-20: Regression messaging templates

WAVE 5 (Final Integration):
└── F-12: Sherlock Day 3 extension (Future Self Interview)
```

---

## Part 6: Reevaluation of Recommendations

### 6.1 Content Library Size (Escalated Decision)

**Original Recommendation:** Option A (50 habits)

**Deeper Analysis:**

| Factor | Option A (50) | Option B (100) | Option C (200+) |
|--------|---------------|----------------|-----------------|
| **Coverage** | Sparse per archetype (~4/archetype) | Moderate (~8/archetype) | Rich (~17/archetype) |
| **Curation burden** | 100 dimension vectors (50 habits × 2 embeddings) | 200 vectors | 400+ vectors |
| **Cold start quality** | May miss niche facets | Better coverage | Comprehensive |
| **Iteration speed** | Fast launch, iterate | Moderate | Slow launch |
| **Content-capability parity** | May limit algorithm learning | Balanced | Algorithm fully enabled |

**Revised Recommendation:**
Still Option A, but with a **QUALIFIER**: Launch with 50, but commit to reaching 100 within first post-launch month based on user facet clustering.

**Rationale:**
- 50 habits × 12 archetypes = ~4 habits per archetype initially
- This is thin but sufficient for MVP
- Population learning (RQ-023) will reveal which archetypes need more content
- Content creation should be a continuous pipeline, not a one-time effort

---

### 6.2 Archetype Count (PD-121)

**Original Recommendation:** 12 archetypes (DeepSeek proposal)

**Deeper Analysis:**

| Factor | 6 Archetypes | 12 Archetypes | 24 Archetypes |
|--------|--------------|---------------|---------------|
| **Granularity** | Very coarse (1 per dimension) | Good balance | Very fine |
| **Content burden** | 6 content sets | 12 content sets | 24 content sets |
| **Matching accuracy** | Low | High | Highest |
| **User comprehension** | Easy | Moderate | Confusing |
| **Jungian alignment** | None | Full (classic 12) | Over-engineered |

**Revised Recommendation:**
12 archetypes remains correct, but with **hierarchical fallback**:
- Primary: Match to closest of 12
- Fallback: If confidence < threshold, fall back to dimension-pole content

---

### 6.3 The Rejected Signal (Unlock Time Shift)

**Original Decision:** REJECT standalone unlock time as regression signal

**Deeper Analysis:**
I maintain this rejection, but with nuance:

**Why I rejected it:**
- Weekend/travel variation creates false positives
- Cultural differences in sleep patterns
- Single-signal detection is fragile

**How to use it correctly:**
- Only as ONE of THREE required signals for regression detection
- Require: (unlock shift) + (escapism) + (JITAI avoidance)
- This multi-signal approach reduces false positives significantly

---

### 6.4 ICS vs Hexis Score (RQ-032)

**The Problem:**
We now have TWO scoring systems:
- `hexis_score` (existing, undefined in docs)
- `ICS` (new, from DeepSeek)

**Recommendation:**
Do NOT maintain parallel systems. Instead:
1. Research what hexis_score actually measures (it's in codebase)
2. Either evolve hexis_score to incorporate ICS formula, OR
3. Deprecate hexis_score in favor of ICS

**Rationale:**
Multiple scores create user confusion and developer cognitive load. One unified metric is cleaner.

---

## Part 7: Consolidated Action Items

### Immediate (Before Next Session)

| Priority | Action | Owner |
|----------|--------|-------|
| **CRITICAL** | Create RQ-028 (Archetype Definitions) | Next agent |
| **CRITICAL** | Update PD-105, PD-107 status to READY | This session |
| HIGH | Create RQ-029, RQ-030, RQ-031, RQ-032 | This session |
| HIGH | Create PD-121, PD-122, PD-123, PD-124 | This session |

### Human Decisions Required

| Decision | Options | Recommendation | Urgency |
|----------|---------|----------------|---------|
| Content Library Size | 50 / 100 / 200+ habits | 50, expand to 100 post-launch | Before F-13 |
| Archetype Count | 6 / 12 / 24 | 12 with fallback | Before RQ-028 |
| ICS vs Hexis | Merge / Parallel / Replace | Merge into one metric | Before F-18 |
| Preference Visibility | Hidden / Visible / Editable | Visible (read-only) | Before F-11 |

---

## Appendix: Complete Dependency Graph

```
CD-005 (6-Dimension) ────┐
                         │
CD-015 (psyOS) ─────────┼──→ RQ-005 (Algorithms) ✅
                         │       │
CD-016 (AI Models) ─────┤       ├──→ RQ-028 (Archetypes) 🔴 NEW
                         │       │       │
CD-017 (Android-First) ─┤       │       └──→ F-06, F-13, F-14
                         │       │
CD-018 (Thresholds) ────┘       ├──→ RQ-029 (Dimension Curation) 🔴 NEW
                                 │
                                 ├──→ RQ-030 (Preference Update) 🔴 NEW
                                 │
                                 └──→ RQ-031 (Pace Car Validation) 🔴 NEW

RQ-012 (Fractal Trinity) ✅ ──→ Trinity Seed (cold start)

RQ-013 (Identity Topology) ✅ ──→ Antagonism Gating

RQ-014 (State Economics) ✅ ──→ Energy Gating
                                   │
                                   └──→ PD-123 (Typical Energy State) 🔴 NEW

RQ-006 (Content Library) ✅ ──→ RQ-028 (Archetypes) 🔴
                                   │
                                   └──→ PD-121 (Archetype Count) 🔴 NEW

RQ-007 (Identity Roadmap) ✅ ──→ RQ-032 (ICS Integration) 🔴 NEW
```

---

*End of Deep Analysis — 10 January 2026*
