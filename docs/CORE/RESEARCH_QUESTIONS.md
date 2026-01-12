# RESEARCH_QUESTIONS.md — Active Research & Open Questions

> **Last Updated:** 06 January 2026 (Archiving strategy implemented)
> **Purpose:** Track active research informing product/architecture decisions
> **Owner:** Oliver (with AI agent research support)
> **Status:** 12 RQs COMPLETE (archived), 15 RQs NEED RESEARCH

---

## Quick Navigation

| Resource | Purpose | Location |
|----------|---------|----------|
| **Quick Reference** | All RQs at a glance (start here) | `index/RQ_INDEX.md` |
| **Completed Research** | Full findings for COMPLETE RQs | `archive/RQ_ARCHIVE_Q1_2026.md` |
| **Active Research** | Full details for items needing work | This file (below) |

**Workflow:** Check index first → Read archive for completed items → This file for active research details.

---

## How to Use This Document

1. **AI Agents:** Check this before implementing features that touch research areas
2. **Human:** Update with findings from ChatGPT/Gemini/Claude research sessions
3. **Engineers:** Reference for understanding "why" behind architectural choices

---

## Active Research: Behavioral Dimensions for JITAI

### RQ-001: Minimum Viable Archetype Taxonomy

| Field | Value |
|-------|-------|
| **Question** | What is the minimum set of behavioral dimensions that predict differential intervention response? |
| **Status** | ✅ RESEARCH COMPLETE |
| **Blocking** | PD-001 (Archetype Philosophy) |
| **Researchers** | ChatGPT, Gemini Deep Research, Gemini Deep Think |
| **Outcome** | 6-dimension continuous model with 4 UI clusters |

**Key Insight (Deep Think):**
> ChatGPT identified **what to optimize** (Identity Evidence, Engagement, Async Delta).
> Gemini identified **who the user is** (6 behavioral dimensions).
> The dimensions serve as the **Context Vector (x)** that allows the Bandit to maximize the **Reward Function (r)**.

**Research Conclusion: The 6 Dimensions**

| # | Dimension | Continuum | Predicts |
|---|-----------|-----------|----------|
| 1 | **Regulatory Focus** | Promotion ↔ Prevention | Identity Evidence framing |
| 2 | **Autonomy/Reactance** | Rebel ↔ Conformist | Anti-Identity risk |
| 3 | **Action-State Orientation** | Executor ↔ Overthinker | Async Delta (rumination) |
| 4 | **Temporal Discounting** | Future ↔ Present | Streak value perception |
| 5 | **Perfectionistic Reactivity** | Adaptive ↔ Maladaptive | Failure Archetype risk |
| 6 | **Social Rhythmicity** | Stable ↔ Chaotic | Async Delta normalization |

**Holy Trinity Defense Mapping:**

| Resistance Type | Primary Drivers | Detection Signal |
|-----------------|-----------------|------------------|
| **Anti-Identity** | High Reactance + Prevention + Maladaptive | Push-Pull ratio (notification vs manual opens) |
| **Failure Archetype** | State Orientation + Steep Discounting + Low Rhythmicity | Recovery velocity (>48h = risk) |
| **Resistance Lie** | High Reactance + State Orientation | Decision time (dwell before logging) |

**Key Sub-Questions (ANSWERED):**
- [x] Do current 6 archetypes map to distinct intervention responses? → **Partially. Merge to 4 clusters.**
- [x] What does JITAI literature use for behavioral segmentation? → **Nahum-Shani: tailoring variables; Kuhl: action control**
- [x] Should we use continuous dimensions instead of discrete buckets? → **Yes. Backend = 6-float vector; UI = 4 clusters**
- [x] How many users per bucket needed for population learning convergence? → **4-8 dimensions optimal for cold-start**

---

### RQ-002: Intervention Effectiveness Measurement

| Field | Value |
|-------|-------|
| **Question** | How should "intervention response" be defined and measured? |
| **Status** | ✅ VALIDATED (ChatGPT confirmed codebase audit) |
| **Blocking** | RQ-001 (what dimensions predict response) |

**Current Implementation (from codebase audit):**

The Pact uses a **multi-signal reward function** optimized for identity evidence, not just task completion:

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

**Code References:**
| Metric | File | Lines |
|--------|------|-------|
| Reward calculation | `jitai_decision_engine.dart` | 772-838 |
| Outcome structure | `intervention.dart` | 479-527 |
| Bandit learning | `hierarchical_bandit.dart` | 310-330 |
| UI tracking | `intervention_modal.dart` | 40-74 |

**What We Track vs What ChatGPT Asked:**

| Measurement Type | Currently Tracked? | How |
|------------------|-------------------|-----|
| **Engagement** (tap/interact) | ✅ Yes | `notificationOpened`, `interactionType`, `timeToOpenSeconds` |
| **Behaviour Change** (habit completed) | ✅ Yes | `habitCompleted24h`, `usedTinyVersion`, `streakMaintained` |
| **Emotional Shift** | ⚠️ Partial | Emotion captured pre-intervention, no post-comparison yet |
| **Retention** | ❌ Not directly | No long-term retention tracking tied to interventions |
| **Self-Report** | ❌ Not implemented | No "was this helpful?" prompt |

**Recommended Additions (ChatGPT validated):**
1. **Post-intervention emotion capture** — Quick mood check-in or sentiment analysis of post-intervention journal entry to measure emotional delta
2. **Retention cohort tracking** — Link interventions to 7-day and 30-day retention rates to identify strategies that sustain engagement
3. **Micro-feedback prompt** — Optional one-tap "Was this helpful? [👍/👎]" (occasional, not every intervention)

**ChatGPT's Literature-Grounded Evaluation:**

| Dimension | Tracked? | Literature Prevalence | Interpretability |
|-----------|----------|----------------------|------------------|
| **Engagement** (tap/interact) | ✅ Yes | High — widely used in digital intervention research | Medium — easy to measure but indirect proxy |
| **Behavior Change** (habit done) | ✅ Yes | Very High — primary outcome in habit formation studies | High — direct measure of success |
| **Emotional Shift** (mood delta) | ⚠️ Partial | Moderate — studied in wellness/therapy interventions | Medium — subjective, external factors |
| **Retention** (long-term use) | ❌ No | High — commonly reported as long-term effectiveness | Opaque — many confounding factors |
| **Self-Report** (user feedback) | ❌ No | High — frequently collected via surveys/ratings | High — direct but prone to bias |

**Thompson Sampling Mechanism (ChatGPT explanation):**

The bandit updates Beta distribution posteriors with each reward:
```
posterior_alpha += reward          // e.g., +0.8
posterior_beta  += (1.0 - reward)  // e.g., +0.2
```

This happens for both the MetaLever (strategy) and individual arm (variant). Over time, high-reward interventions get selected more frequently.

---

### RQ-003: Dimension-to-Implementation Mapping

| Field | Value |
|-------|-------|
| **Question** | For each recommended behavioral dimension, what do we already track? |
| **Status** | ✅ COMPLETE (Deep Think synthesized) |

**Unified Dimension-to-Tracking Table:**

| Dimension | Reward Driver | Passive Inference (Existing) | Cold-Start Question | Implementation |
|-----------|---------------|------------------------------|---------------------|----------------|
| **1. Social Rhythmicity** | Async Delta (normalization) | Schedule Entropy: σ of log timestamps over 14 days | "Is your daily schedule predictable?" | ⚠️ Calculate from existing time_context |
| **2. Autonomy/Reactance** | Engagement (30%) | Push-Pull Ratio: notification opens ÷ manual opens | "Prefer pushy coach or silent partner?" | ⚠️ Track open source (notification vs organic) |
| **3. Action-State Orientation** | Async Delta (15%) | Decision Time: ms between app open → log tap | None (infer from first 3 logs) | ❌ NEW: Add `decision_time_ms` tracking |
| **4. Regulatory Focus** | Identity Evidence (50%) | Gap: Hard to infer without NLP | "Motivated by achieving dreams or preventing slides?" | ✅ Onboarding question only |
| **5. Perfectionistic Reactivity** | Retention (churn) | Recovery Velocity: time to return after streak break | "If I miss a day, I feel guilty vs determined" | ⚠️ Calculate from existing streak data |
| **6. Temporal Discounting** | Streak value | Burstiness: variance in usage patterns | "Small badge now vs rare badge later?" | ⚠️ Calculate from existing engagement data |

**Implementation Status:**
- ✅ = Already available / onboarding only
- ⚠️ = Derivable from existing data (needs calculation logic)
- ❌ = Requires new tracking implementation

---

### RQ-004: Archetype Migration Strategy

| Field | Value |
|-------|-------|
| **Question** | How do we migrate from 6 hardcoded archetypes to dimensional model? |
| **Status** | ✅ RECOMMENDATION READY |
| **Recommendation** | Hybrid: 6-float backend vector + 4 UI clusters |

**Migration Map (Current → New):**

| Current Archetype | New Cluster | Dimensional Profile | Intervention Strategy |
|-------------------|-------------|---------------------|----------------------|
| REBEL | **The Defiant Rebel** | High Reactance + Prevention | Autonomy-Supportive ("You decide when") |
| PERFECTIONIST | **The Anxious Perfectionist** | Maladaptive Perfectionism + State Orientation | Self-Compassion ("A missed day is part of the process") |
| PROCRASTINATOR + OVERTHINKER | **The Paralyzed Procrastinator** | State Orientation + High Reactance | Value Affirmation ("Remember why you started") |
| PLEASURE_SEEKER | **The Chaotic Discounter** | Steep Discounting + Low Rhythmicity | Micro-Steps ("Just put on your shoes") |
| PEOPLE_PLEASER | **⚠️ DEPRECATED** | (See Open Questions) | — |

**Fallback Strategy:**
- **Old:** PERFECTIONIST (problematic — triggers shame spiral)
- **New:** Balanced Prevention (Low Reactance + Prevention Focus)
- **Rationale:** "Don't break the chain" is universal baseline (Loss Aversion)

**Reward Function Adjustments (Per Dimension):**

| Dimension | Adjustment |
|-----------|------------|
| **Regulatory Focus** | Promotion users: boost Progress %. Prevention users: boost Streak Length. |
| **Autonomy/Reactance** | High Reactance: Notification opens yield 0 reward. Manual opens yield 2x. Forces Bandit to learn "Invisible Support". |
| **Social Rhythmicity** | Chaotic users: Normalize Async Delta by schedule entropy. Don't penalize busy parents for 2h delays. |

**Implementation Roadmap:**

| Phase | Timeframe | Deliverables |
|-------|-----------|--------------|
| **MVP** | Weeks 1-4 | Add `decision_time_ms` tracking. Calculate schedule entropy. Add 3 onboarding questions. |
| **Dynamic Reward** | Weeks 5-8 | Pass 6-float vector as Context to Thompson Sampling. Modify scoring rules per dimension. |
| **Anti-Fragile** | Weeks 9+ | Holy Trinity defense: Auto-trigger "Emergency Mode" for Maladaptive + Missed Day. |

---

### RQ-005: Proactive Recommendation Algorithms

| Field | Value |
|-------|-------|
| **Question** | What algorithms should drive identity-aligned habit/ritual recommendations? |
| **Status** | ✅ COMPLETE |
| **Completed** | 10 January 2026 |
| **Blocking** | CD-008 (Identity Coach), PD-105 (AI Coaching Architecture) |
| **Priority** | **CRITICAL** — Core value proposition |
| **Assigned** | DeepSeek Deep Think |
| **Source** | IDENTITY_COACH_SPEC.md |
| **Reconciliation** | `docs/analysis/DEEP_THINK_RECONCILIATION_RQ005_RQ006_RQ007.md` |

**Sub-Questions Answered:**

| Sub-Question | Answer | Confidence |
|--------------|--------|------------|
| What algorithms recommend identity-aligned goals? | **Two-Stage Hybrid Retrieval:** Stage 1 = Semantic search (pgvector, 768-dim) for topic matching; Stage 2 = Psychometric re-ranking (6-dim) for style matching | HIGH |
| How do we avoid overwhelming users? | **Pace Car Protocol:** Max 1 recommendation/day; only if user has < 5 active habits per facet | HIGH |
| How does this integrate with JITAI? | **Architect vs Commander separation:** "The Architect" (async Edge Function) generates recommendation cards → places in JITAI's `content_queue` → "The Commander" (JITAI) decides when to show | HIGH |
| What's the feedback loop? | **Implicit-Dominant Signal Hierarchy:** Adoption (+5), Validation (+10, 3x completion in week), Dismissal (-5), Decay (-0.5 per ignore). Updates `preference_embedding` | MEDIUM |
| How do we handle user rejection? | **Snooze vs Ban Taxonomy:** "Not Now" = suppress 14 days; "Not Me" = permanent block + subtract from preference embedding | HIGH |
| How to handle cold start? | **Trinity Seed:** Use Day 1 Holy Trinity extraction — Anti-Identity → Prevention habits; Failure Archetype → Floor habits; Dimension → Framed habits | HIGH |

**Key Deliverables:**

| Deliverable | Status | Location |
|-------------|--------|----------|
| Two-Stage Hybrid Retrieval algorithm | ✅ Specified | Reconciliation doc |
| `generateRecommendations()` pseudocode | ✅ Specified | Reconciliation doc |
| Architect/Commander separation architecture | ✅ Specified | Reconciliation doc |
| Feedback signal weights | ✅ Specified | Reconciliation doc |
| Cold start strategy | ✅ Specified | Reconciliation doc |

**Implementation Tasks:** F-07, F-08, F-09, F-10, F-11, F-17, F-19

---

### RQ-006: Content Library for Recommendations

| Field | Value |
|-------|-------|
| **Question** | What content library is needed to support proactive recommendations? |
| **Status** | ✅ COMPLETE |
| **Completed** | 10 January 2026 |
| **Blocking** | CD-009 (Content Library), RQ-005 implementation |
| **Priority** | HIGH — Enables RQ-005 |
| **Assigned** | DeepSeek Deep Think |
| **Source** | IDENTITY_COACH_SPEC.md |
| **Reconciliation** | `docs/analysis/DEEP_THINK_RECONCILIATION_RQ005_RQ006_RQ007.md` |

**Sub-Questions Answered:**

| Sub-Question | Answer | Confidence |
|--------------|--------|------------|
| What habits are "universal starters"? | **50 Universal Habits** tagged with Energy State + Dimensions. Categories: Physiology (Hydrate First), Recovery (Digital Sunset), Focus (The One Thing), Movement (Floor Press) | HIGH |
| How many ritual templates needed? | **4 Transition-Based Templates:** Activation (Sleep→Wake), Shutdown (Work→Recovery), Airlock (Focus→Social), Recovery | HIGH |
| What progression milestones are meaningful? | **Identity Consolidation Stages:** The Spark (Day 1-7, "Identity Claimed"), The Dip (Day 8-21, "Resistance Detected"), The Groove (Day 66+, "Automaticity") | HIGH |
| How do we phrase warnings without shame? | **Data-Driven Normalization:** Strip emotion, cite statistics. Example: "Streak reset. Data shows Day 8 is the most common drop-off point. You are normal. Let's resume." | HIGH |
| How to handle infinite facet names? | **Archetype Template Bridge:** Map user facets to 12 Global Archetypes (Builder, Nurturer, Warrior, etc.) via vector similarity. System writes content for archetypes, user gets mapped content | HIGH |
| What dimensional framing is needed? | **6-Dimension Matrix:** Promotion ("Boost your energy") vs Prevention ("Secure your health"); Rebel ("Do it your way") vs Conformist ("Join the community") | HIGH |

**Launch Library Specification:**

| Content Type | Quantity | Status |
|--------------|----------|--------|
| Universal Habit Templates | 50 | 🔴 TODO (F-13) |
| Archetype Template Presets | 12 | 🔴 TODO (F-14) |
| Framing Templates (6 dims × 2 poles) | 12 | 🔴 TODO (F-15) |
| Ritual Templates | 4 | 🔴 TODO (F-16) |
| Regression Messaging Templates | TBD | 🔴 TODO (F-20) |

**Human Decision Required:** Content library size at launch (Option A: 50 habits / Option B: 100 habits / Option C: 200+ habits). Recommendation: Option A.

**Implementation Tasks:** F-13, F-14, F-15, F-16, F-20

---

### RQ-007: Identity Roadmap Architecture (User Aspiration → Habit Recommendation)

| Field | Value |
|-------|-------|
| **Question** | How do we architect the full flow from user aspirations to AI-guided habit recommendations? |
| **Status** | ✅ COMPLETE |
| **Completed** | 10 January 2026 |
| **Blocking** | CD-008 (Identity Coach), CD-011 (Architecture Ramifications) |
| **Priority** | HIGH — Supports Identity Coach |
| **Assigned** | DeepSeek Deep Think |
| **Depends On** | RQ-005, RQ-006 |
| **Previously** | Was RQ-006 before renumbering |
| **Reconciliation** | `docs/analysis/DEEP_THINK_RECONCILIATION_RQ005_RQ006_RQ007.md` |

**Sub-Questions Answered:**

| Sub-Question | Answer | Confidence |
|--------------|--------|------------|
| How to extract aspirations? | **Future Self Interview (Day 3):** "Fast forward 1 year. You are proud of who you've become. What is one specific thing that version of you does every day?" | HIGH |
| What data structure for Identity Roadmap? | **Two tables:** `identity_roadmaps` (user_id, facet_id, aspiration_label, status) + `roadmap_nodes` (roadmap_id, stage_order, node_type, target_id, unlock_criteria JSONB) | HIGH |
| How to map aspirations to facets? | **Vector Classification:** Embed aspiration → classify to Global Archetype → link to existing Facet or create new | MEDIUM |
| How to match habits to aspirations? | **Vector Space Mapping:** Embed aspiration label → query habit_templates → filter by Global Archetype | HIGH |
| How to track progress? | **Identity Consolidation Score (ICS):** `ICS = Σ(Votes × Consistency) / DaysActive`. Visual: Seed → Sapling → Oak | MEDIUM |
| How to detect regression? | **Leading Indicators:** (1) Escapism: screenOnDuration > 20% vs baseline, (2) Dysregulation: first unlock shifts > 30 min, (3) Avoidance: JITAI dismissal rate increases. **Note:** Unlock time alone rejected as too noisy | MEDIUM |
| How to visualize? | **Identity Tree:** Roots (Holy Trinity) → Trunk (Core Values) → Branches (Facets) → Leaves (Habits). ICS growth thickens branches; neglect desaturates color | MEDIUM |

**Schema Delivered:**

```sql
CREATE TABLE identity_roadmaps (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  facet_id UUID REFERENCES identity_facets(id),
  aspiration_label TEXT, -- "Become a Fit Dad"
  status TEXT -- 'active', 'completed', 'paused'
);

CREATE TABLE roadmap_nodes (
  id UUID PRIMARY KEY,
  roadmap_id UUID REFERENCES identity_roadmaps(id),
  stage_order INT, -- 1, 2, 3
  node_type TEXT, -- 'habit', 'milestone'
  target_id UUID, -- Link to habit_id
  unlock_criteria JSONB -- {"ics_score": 0.5}
);
```

**Implementation Tasks:** F-02, F-03, F-12, F-18

---

### RQ-008: UI Logic Separation for AI-Assisted Development

| Field | Value |
|-------|-------|
| **Question** | What are best practices for articulating UI/logic separation that enables effective "vibe coding"? |
| **Status** | ✅ COMPLETE |
| **Completed** | 10 January 2026 |
| **Blocking** | CD-013 refinement |
| **Priority** | MEDIUM — Code quality |
| **Assigned** | Deep Think + Claude |
| **Previously** | Was RQ-005 before renumbering |

**Context:**
The Pact uses Flutter with Provider for state management (migrating to Riverpod). UI files should contain ONLY presentation logic so that:
1. AI agents can safely modify UI without breaking business logic
2. Business logic can be tested without UI
3. "Vibe coding" (rapid UI iteration) is safe

**Key Findings:**

| Decision | Resolution |
|----------|------------|
| **Architecture** | Passive View + Controller (ChangeNotifier for Provider, Notifier for Riverpod) |
| **Boundary Rule** | "IF" decisions → Logic Layer; Rendering → UI Layer |
| **Animation Triggers** | Side Effect Pattern (state flags, not inline checks) |
| **Enforcement** | Linting rules + code review verification checklist |
| **Migration** | Lift & Shift — incremental per feature |

**Boundary Decision Tree:**
```
Does it decide IF something happens? → LOGIC LAYER
Does it transform data? → LOGIC LAYER (getter)
Animation TRIGGER? → LOGIC LAYER (state flag)
Animation EXECUTION? → UI LAYER
```

**Key Insight:** "Constraint Enables Creativity" — Strict UI/Logic separation creates a Safety Sandbox where AI can iterate freely on UI without risk of corrupting business logic.

**Output Delivered:**
- ✅ Code pattern examples (Celebration Animation scenario)
- ✅ Linting configuration recommendations
- ✅ Boundary Decision Tree
- ✅ Side Effect Pattern documentation
- ✅ Migration strategy (Lift & Shift)

**Reference:** `docs/analysis/DEEP_THINK_RECONCILIATION_RQ008_RQ009.md`

---

### RQ-009: Optimal LLM Coding Approach ("Make it Work → Make it Right"?)

| Field | Value |
|-------|-------|
| **Question** | Is "Make it work first, then refactor" the optimal approach for LLM-assisted coding? |
| **Status** | ✅ COMPLETE |
| **Completed** | 10 January 2026 |
| **Priority** | MEDIUM — Affects all coding work |
| **Blocking** | Protocol 2 in AI_AGENT_PROTOCOL.md |
| **Assigned** | Deep Think + Claude |
| **Trigger** | User questioned if this is really optimal for LLMs |
| **Previously** | Was RQ-007 before renumbering |

**Key Finding:** Different tasks require different approaches. One-size-fits-all is wrong.

**Task Classification System:**

| Task Type | Examples | Strategy |
|-----------|----------|----------|
| **Logic Task** | New feature, data model, algorithm | → CONTRACT-FIRST (Plan → Work) |
| **Visual Task** | Styling, animations, layout | → VIBE CODING (Work → Right) |

**Why This Works:**
- **Logic Tasks:** LLMs produce better code when given a "contract" (interface/state definition) first. Anchors output, reduces hallucination.
- **Visual Tasks:** Subjective by nature. AI needs to "see" code to iterate. Business logic safety enables rapid experimentation.

**Protocol 2 Update:**
AI_AGENT_PROTOCOL.md Protocol 2 was **REPLACED** with "Context-Adaptive Development":
1. CLASSIFY the task (Logic vs Visual)
2. LOGIC → Contract-First (define interface → implement → test → UI)
3. VISUAL → Vibe Coding (iterate rapidly, no business logic in UI)
4. VERIFY separation (checklist)

**Quality Metrics:**
- **Logic Leakage:** Count of `if` statements involving domain entities in UI files. Target: 0.
- **Vibe Velocity:** Number of UI iterations achievable without breaking the build. Target: Infinite.

**Output Delivered:**
- ✅ Task Classification System
- ✅ Context-Adaptive Protocol (replaced Protocol 2)
- ✅ Quality metrics defined
- ✅ Integration with RQ-008 boundaries

**Reference:** `docs/analysis/DEEP_THINK_RECONCILIATION_RQ008_RQ009.md`

---

### RQ-010: Permission Data Philosophy

| Field | Value |
|-------|-------|
| **Question** | How should permission-gated data (Health, Location, Usage) be captured, stored, and used to inform identity coaching? |
| **Status** | 🔴 NEEDS RESEARCH |
| **Priority** | **HIGH** — Affects architecture across all phases |
| **Blocking** | Phase 2 (Intelligence), JITAI refinement, Gap Analysis Engine |
| **Assigned** | Dedicated session required |

**Context:**
The app requests extensive permissions but hasn't formalized:
- What data we actually use from each permission
- How it flows into coaching decisions
- Privacy/storage implications
- User transparency expectations

**Current Permissions Captured:**

| Permission | Data Available | Currently Used? | Notes |
|------------|---------------|-----------------|-------|
| **Health** | Sleep duration, HRV, stress | 🟡 Partial | Z-scored for V-O calculation |
| **Location** | GPS coordinates, zone | 🟡 Partial | Location zone for context |
| **Calendar** | Meeting count, free windows | 🟡 Partial | Busyness context |
| **Usage** | Screen time, app usage | 🟡 Partial | Doom scrolling detection |
| **Notifications** | Enabled/disabled | ✅ Yes | JITAI channel selection |

**Sub-Questions:**

| # | Question | Implications |
|---|----------|--------------|
| 1 | What signals from each permission actually predict intervention effectiveness? | Research needed |
| 2 | How do we communicate data usage to users (transparency)? | UX/Legal |
| 3 | What's the storage model? (Ephemeral vs persistent, local vs cloud) | Architecture |
| 4 | How does each signal feed into the 6-dimension model? | Intelligence |
| 5 | What happens if user revokes permission mid-use? | Graceful degradation |
| 6 | Should any permissions be optional? | Product philosophy |
| 7 | What additional permissions should we request? | Expansion |

**User Direction (05 Jan 2026):**
> "My gut tells me to make nothing optional and ask for everything because that is what I want for myself."

**Output Expected:**
- Permission-to-signal mapping
- Storage architecture for each data type
- Integration with 6-dimension model
- User transparency design
- Graceful degradation strategy

**Note:** Requires dedicated session to flesh out properly.

---

### RQ-011: Multiple Identity Architecture

| Field | Value |
|-------|-------|
| **Question** | How should the app handle users with multiple aspirational identities? |
| **Status** | ✅ RESEARCH COMPLETE — Awaiting PD-106 Decision |
| **Priority** | **CRITICAL** — Fundamental to data model, coaching logic, and philosophy |
| **Blocking** | Phase 1 (schema), Phase 2 (recommendations), Phase 3 (dashboard) |
| **Related PD** | PD-106 (Product Decision required) |
| **Research Date** | 05 January 2026 |
| **Researcher** | Claude (Opus 4.5) |

**Context:**
Users have multiple aspirational identities:
- "Worldclass SaaS Salesman"
- "Consistent Swimmer"
- "Present Father"
- "Morning Person"

These may complement or conflict with each other.

---

#### Current State Analysis

**Finding:** The app currently enforces **single identity per user** at the database level.

| Component | Current Implementation |
|-----------|----------------------|
| **Database** | `identity_seeds` with `UNIQUE (user_id)` |
| **Habit linking** | `habit.identity` is a single string |
| **Growth tracking** | Single `strongestIdentity` metric |
| **JITAI context** | Uses one `PsychometricProfile` |
| **Dashboard** | Single growth visualization (Seed → Oak) |

**Key Files:**
- `supabase/migrations/20260102_identity_seeds.sql` — One-to-one user-identity
- `lib/domain/entities/psychometric_profile.dart` — Holy Trinity + dimensions
- `lib/data/models/habit.dart` — `identity: String` (single)
- `lib/domain/services/identity_growth_service.dart` — Single identity metrics

---

#### Philosophical Analysis

**Three Frames for Understanding Multiple Identities:**

| Frame | Philosophy | App Role |
|-------|------------|----------|
| **Integration (IFS/Jung)** | All identities are "parts" of one Self | Help user **integrate** parts |
| **Context-Switching (Goffman)** | We perform different identities in contexts | Help user **switch** cleanly |
| **Hierarchy (Maslow)** | One core identity; others serve it | Help user **prioritize** |

**Key Insight:** Identity conflicts are not bugs — they're the app's **deepest value proposition**. Surfacing tension enables genuine self-reflection.

---

#### Architecture Options Evaluated

| Option | Description | Recommendation |
|--------|-------------|----------------|
| **A: Single Identity** | Force one primary (status quo) | ❌ Too limiting |
| **B: Multiple Flat** | N identities, equal weight | ⚠️ No unified self |
| **C: Hierarchical** | Primary + secondary identities | ⚠️ Feels artificial |
| **D: Identity Facets** | One Self → N Facets (IFS model) | ✅ **RECOMMENDED** |

---

#### Recommended Architecture: Identity Facets

**Philosophy:** One integrated Self with multiple **facets** (not competing identities).

**Key Principle:** Holy Trinity (anti-identity, failure archetype, resistance lie) stays **unified** because psychological patterns are consistent. But aspirational facets can diverge.

**Proposed Schema:**
```sql
-- Core psychometric profile stays (represents integrated self)
-- New: Facets table
CREATE TABLE identity_facets (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL,
  domain TEXT NOT NULL,          -- "professional", "physical", "relational", "temporal"
  label TEXT NOT NULL,           -- "Early Riser"
  aspiration TEXT,               -- "I wake before the world awakens"

  -- Per-facet behavioral adjustments (overlay on base dimensions)
  dimension_adjustments JSONB,   -- {"temporal_discounting": +0.2}

  -- Conflict tracking
  conflicts_with UUID[],         -- Array of conflicting facet IDs
  integration_status TEXT,       -- "harmonized", "in_tension", "unexamined"

  created_at TIMESTAMPTZ,
  last_reflected_at TIMESTAMPTZ  -- When user last engaged with this facet
);

-- Habits link to facets (many-to-many)
CREATE TABLE habit_facet_links (
  habit_id UUID NOT NULL,
  facet_id UUID NOT NULL,
  contribution_weight FLOAT DEFAULT 1.0,
  PRIMARY KEY (habit_id, facet_id)
);
```

---

#### Sub-Questions Answered

| # | Question | Recommendation | Rationale |
|---|----------|----------------|-----------|
| 1 | How many identities? | **5 (soft limit)** | Cognitive load, focus |
| 2 | Hierarchy? | **Flat with optional "focus"** | Avoids artificial ranking |
| 3 | Can they conflict? | **Yes — detect and surface** | Core value differentiator |
| 4 | Conflict meaning? | **Integration opportunity** | IFS philosophy |
| 5 | Habits → Identities? | **Many-to-many** | A habit can serve multiple facets |
| 6 | Dimension vector? | **One per user + per-facet adjustments** | Base personality + context tweaks |
| 7 | Dashboard UX? | **Unified tree with facet branches** | Emphasizes integrated self |

---

#### Conflict Detection Strategy

**Types of Conflicts:**
| Type | Example | Detection Method |
|------|---------|------------------|
| **Temporal** | Early Riser vs Night Owl | Time-based habit comparison |
| **Resource** | Career Focus vs Family Time | Time allocation analysis |
| **Value** | Minimalist vs Collector | AI semantic analysis |
| **Behavioral** | Social Butterfly vs Deep Worker | Context clash detection |

**Resolution Strategies:**
| Strategy | When to Use |
|----------|-------------|
| **Surface** | First detection — "I notice tension between X and Y" |
| **Socratic** | User engagement — "If you could only be one, which?" |
| **Integration** | User seeks resolution — "Could you be a 'Morning Creative'?" |
| **Acceptance** | User acknowledges — "It's okay to hold tension" |

---

#### Dashboard UX Recommendation

**Hybrid Approach:**
- **Default:** Unified Skill Tree (trunk = core self, branches = facets)
- **Drill-down:** Facet Cards for per-facet metrics
- **Tension surfacing:** Conflict Banner when detected

```
         🌳 Core Self
        /|\\
       / | \\
      ◉  ◉  ◉   ← Facet branches
     /|  |  |\\
    ○○  ○  ○○○  ← Habit leaves

⚠️ TENSION: Early Riser ↔ Night Owl
   Tap to explore this conflict
```

---

#### Migration Path

```
Phase 1 (MVP): Add facets table, optional linking
   ↓ Current habits work without facets
Phase 2: Dashboard shows facets (optional view)
   ↓ Users can organize existing habits
Phase 3: Sherlock extracts facets during onboarding
   ↓ New users get richer profile
Phase 4: Conflict detection + coaching
   ↓ Full value realized
```

---

#### Output Delivered

| Deliverable | Status |
|-------------|--------|
| Data model for multiple identities | ✅ Identity Facets schema |
| Conflict detection algorithm | ✅ Temporal + Semantic + Behavioral |
| Coaching strategy for conflicts | ✅ Surface → Socratic → Integration |
| Dashboard UX for multiple identities | ✅ Unified Tree + Facet Cards |
| Recommendation engine changes | ✅ Facet-aware JITAI |

**Next Step:** PD-106 decision required to confirm approach before implementation

---

#### External Validation: Google Deep Think Analysis (05 Jan 2026)

**Verdict:** Model validated with critical refinements required.

##### What Deep Think Validated ✅

| Element | Status | Notes |
|---------|--------|-------|
| Identity Facets model | ✅ Validated | Maps to IFS + CAPS literature |
| Unified Self philosophy | ✅ Validated | Correct frame for high-functioning adults |
| Conflicts as coaching | ✅ Validated | Core differentiator |
| Unified Tree UX | ✅ Validated | Recommended with "leaning tree" enhancement |

##### Critical Gaps Identified ⚠️

**1. The Invariance Fallacy**
> "You assume the Resistance Lie is consistent across domains. It is not."

| Root Archetype | Work Manifestation | Health Manifestation |
|----------------|-------------------|---------------------|
| Perfectionist | "I need to research more" | "I'll start Monday when it's perfect" |
| Rebel | "Don't tell me what to do" | "I work out when I feel like it" |

**Fix:** Don't split Holy Trinity table. Instruct Sherlock (AI) to **contextualize** the archetype per-facet. DB stores Root; prompt injects Manifestation.

**2. The Energy Blind Spot**
> "You are tracking Time conflicts but ignoring **Energy State** conflicts."

Current conflicts (Time, Resource, Value) miss **State Switching** costs:
- "Deep Work Coder" (High Cognitive, Low Arousal) → "Present Father" (High Emotional, High Arousal)
- Time is free, but **switching cost** is massive

**New Conflict Type: Energy State**
```
Tag habits with energy_state:
- high_focus (Dopamine/Acetylcholine)
- high_physical (Adrenaline/Endorphin)
- social (Oxytocin/Serotonin)
- recovery (Parasympathetic)

Flag adjacent mismatched states.
```

##### New Architectural Elements

**1. Maintenance Mode (Seasonality)**
> "High performers don't balance; they sequence."

Add `status` field to facets:
- `active` — Full habit load, growth expected
- `maintenance` — Low volume (1x/week), no streak anxiety
- `dormant` — Parked, no habits active

Coaching: "You can't be Level 10 Founder AND Level 10 Athlete this quarter. Which is the Driver?"

**2. Tension Score (Graded Conflicts)**
Move from binary (conflict/no-conflict) to continuous:
```
0.0-0.3: Synergy (habits reinforce each other)
0.4-0.6: Neutral (independent)
0.7-0.8: Friction (needs attention)
0.9-1.0: Incompatibility (hard choice required)
```

**3. Keystone Onboarding**
> "Extracting 5 facets on Day 1 is cognitive suicide."

| Day | Action | Extraction |
|-----|--------|------------|
| Day 1 | The Hook | ONE Keystone Identity |
| Day 3 | The Shadow | "What's being neglected?" → Facet 2 |
| Day 7+ | The Garden | Unlock full facet creation |

**4. Archetypal Templates**
> "Users cannot self-report dimension adjustments."

Hardcode templates for launch:
```json
"Entrepreneur": {"risk_tolerance": +0.2, "action_orientation": +0.3}
"Parent": {"social_rhythmicity": +0.2}
"Athlete": {"temporal_discounting": -0.2}
```

Later: AI infers from behavior.

**5. Airlock Protocol (State Transitions)**
When Energy State Conflict detected, insert **Transition Ritual**:
```
"You are switching from Hunter Mode (Work) to Gatherer Mode (Home).
Do not enter yet. 5-minute Box Breathing."
```

**6. High Leverage Habits**
If habit serves multiple facets, frame as **double vote**:
```
"This 10-minute meditation centers the Founder and grounds the Father.
Double vote."
```

**7. Conflict Silence**
If `tension_score > 0.8` (Active Conflict), **suppress nudges**. Don't nag about reading when user is pulling an all-nighter.

##### Guardrails Added

| Risk | Guardrail |
|------|-----------|
| "Ought Self" (external pressure identities) | Sherlock asks: "Do you *want* this, or *should* this?" |
| Capacity overload | Hard limit: 3 Active Facets for new users |
| Tree imbalance | Visual feedback: Tree "leans" when facets uneven |

---

#### Blue Sky Architecture (No Time Constraints)

**Philosophy Shift:** From "Habit Tracker" to **Psychological Operating System (psyOS)**.

##### 1. Parliament of Selves
User is not a monolith but a **Parliament**:
- **The Self** = Speaker of the House (conscious observer)
- **Facets** = MPs (each with goals, values, fears, neurochemistry)
- **Conflict** = Debate to be governed, not bug to be squashed
- **Goal** = Governance (coalition), not Tyranny (discipline)

##### 2. Fractal Trinity (Hierarchical Blocks)
```sql
-- THE DEEP SOURCE (Global/Biological)
CREATE TABLE psychometric_roots (
  user_id UUID PRIMARY KEY,
  root_fear TEXT,                    -- "I am unworthy of love" (Core Wound)
  base_temperament_vector JSONB,     -- Biological baseline
  chronotype TEXT                    -- "Wolf" (Night Owl)
);

-- THE CONTEXTUAL MANIFESTATION (Local)
CREATE TABLE psychological_manifestations (
  id UUID PRIMARY KEY,
  facet_id UUID REFERENCES identity_facets(id),
  root_id UUID REFERENCES psychometric_roots(user_id),
  archetype_label TEXT,              -- Root: "Abandoned Child" → Facet: "People Pleaser"
  resistance_script TEXT,            -- "If I say no, I will be fired (abandoned)"
  coaching_strategy TEXT             -- "Compassionate Inquiry" vs "Direct Challenge"
);
```

**Insight:** If you only cure the leaf (specific excuse), the root grows new weeds. AI Coach must link: "Same delay tactic in fitness as career. Perfectionist root again."

##### 3. Identity Topology (Graph Model)
```sql
CREATE TABLE identity_topology (
  source_facet_id UUID,
  target_facet_id UUID,
  interaction_type TEXT,             -- 'SYNERGISTIC', 'ANTAGONISTIC', 'COMPETITIVE'
  friction_coefficient FLOAT,        -- 0.0 (Flow) to 1.0 (Gridlock)
  switching_cost_minutes INT         -- Time to reset biology between them
);
```

##### 4. Polymorphic Habits
Same action, different encoding based on active facet:

| Action | Active Facet | Metric | Feedback |
|--------|--------------|--------|----------|
| Morning Run | Athlete | Pace, HR Zone | "+10 Physical Points" |
| Morning Run | Founder | Silence, Ideas | "+10 Clarity Points" |
| Morning Run | Father | Stress Regulation | "Cortisol burned. Safe to go home." |

**Implementation:** When checking off habit, user validates "Who did this?" reinforcing specific neural pathway.

##### 5. Council AI (Roundtable Simulation)
Instead of 1:1 chat, **simulate the parliament**:

```
User: "Should I take this promotion requiring travel?"

The Executive Agent: "Take it. Growth we promised."
The Father Agent: "You'll miss soccer practice. Violates 'Present' rule."

Sherlock (Mediator): "Proposal: Take job, negotiate 'No Travel Tuesdays'.
Executive gets growth; Father gets consistency. Treaty?"
```

##### 6. Constellation UX (Solar System)
Dashboard as **Living Solar System**:
- **Sun** = The Self (center)
- **Planets** = Facets (orbiting)
  - **Mass** = Habit volume
  - **Gravity** = Pull on time/energy
  - **Orbit Distance** = Integration with Core Self
- **Entropy**: Ignored planet doesn't shrink — it **cools** (dims), orbit becomes **erratic** (wobbles)

**Visual Insight:** Massive "Career" planet pulling "Health" planet out of orbit. User sees life's gravity distortion.

##### 7. Identity Priming (Pavlovian Anchors)
Nudges shouldn't just remind (Cognitive); they should **prime** (Sensory):

```
Trigger: 5 mins before "Deep Work"
Action: Play Sonic Trigger specific to "Architect" facet
Content: Hans Zimmer drone + Voice: "You are a builder. The world is noise.
         This is the signal. Enter the Cathedral."
Result: Immediate state shift via sensory anchoring.
```

---

#### MVP vs Blue Sky Summary

| Element | MVP (Jan 16) | Blue Sky |
|---------|--------------|----------|
| Schema | `identity_facets` + `status` field | + `psychometric_roots` + `identity_topology` |
| Onboarding | 1 Keystone Facet | Progressive extraction over 7 days |
| Dimensions | Archetypal Templates (hardcoded) | AI-inferred from behavior |
| Conflicts | Time only | + Energy State + Identity Standard |
| Detection | Binary | Tension Score (0.0-1.0) |
| Resolution | Surface → Socratic | + Airlock + Council AI |
| UX | Unified Tree | Constellation (Solar System) |
| Habits | Single encoding | Polymorphic (context-aware) |
| JITAI | Facet-aware messages | + Identity Priming (sensory) |

**Note:** CD-015 confirmed psyOS (Blue Sky) architecture for launch. See new RQ-012 through RQ-018 below.

---

## psyOS Research Questions (CD-015 Generated)

The following research questions were generated by the CD-015 decision to pursue psyOS architecture.

---

### RQ-012: Fractal Trinity Architecture

| Field | Value |
|-------|-------|
| **Question** | How should the Fractal Trinity (Root Psychology + Contextual Manifestations) be architected? |
| **Status** | ✅ RESEARCH COMPLETE |
| **Priority** | **CRITICAL** — Foundational to psyOS |
| **Blocking** | Schema design, Sherlock extraction, coaching logic |
| **Generated By** | CD-015 (psyOS Architecture) |
| **Research Date** | 05 January 2026 |
| **Researcher** | Google Deep Think |

**Context:**
Deep Think identified the "Invariance Fallacy" — the assumption that psychological patterns (Holy Trinity) are consistent across domains. In reality, the same root fear manifests differently per facet.

---

#### Finalized Schema (with pgvector)

```sql
-- Enable Vector extension for semantic pattern matching
CREATE EXTENSION IF NOT EXISTS vector;

-- THE DEEP SOURCE (Global/Biological)
CREATE TABLE psychometric_roots (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id),
  chronotype TEXT CHECK (chronotype IN ('lion', 'bear', 'wolf', 'dolphin')),
  neurotype TEXT,                    -- "high_sensitivity", "adhd_tendency", etc.
  root_label TEXT,                   -- "Abandoned Child", "Perfectionist", etc.
  root_embedding VECTOR(768),        -- Semantic embedding for pattern matching
  root_confidence FLOAT DEFAULT 0.0, -- 0.0-1.0 confidence in root extraction
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- THE CONTEXTUAL MANIFESTATION (Local per-Facet)
CREATE TABLE psychological_manifestations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  facet_id UUID NOT NULL REFERENCES identity_facets(id) ON DELETE CASCADE,
  root_id UUID REFERENCES psychometric_roots(user_id),
  archetype_label TEXT,              -- "People Pleaser" (in this context)
  resistance_script TEXT,            -- "If I say no, I will be fired (abandoned)"
  resistance_embedding VECTOR(768),  -- For cross-facet pattern similarity
  trigger_context TEXT,              -- When this manifests: "deadlines", "social pressure"
  coaching_strategy TEXT,            -- "Compassionate Inquiry" vs "Direct Challenge"
  UNIQUE(facet_id)                   -- One manifestation per facet
);
```

**Key Design Decisions:**
- `root_embedding` enables semantic similarity search across users (population learning)
- `resistance_embedding` allows detecting same root manifesting differently
- `root_confidence` increases as more facets reveal the same pattern
- One-to-many: One Root → Many Manifestations (per facet)

---

#### The Triangulation Protocol (Root Extraction Algorithm)

**Problem:** Users cannot directly articulate their root psychology. They only describe surface manifestations.

**Solution:** Extract manifestations first, then use vector math to triangulate the root.

```
TRIANGULATION PROTOCOL:

Day 1: Extract Manifestation A (Keystone Facet)
  → Sherlock asks: "When you try to [habit], what stops you?"
  → Store resistance_script + resistance_embedding

Day 3-4: Extract Manifestation B (Shadow Facet)
  → Sherlock asks: "What's being neglected? When you try that, what stops you?"
  → Store resistance_script + resistance_embedding

Day 7: Root Synthesis
  → Calculate cosine_similarity(embedding_A, embedding_B)
  → If similarity > 0.7: Same root, high confidence
  → If similarity < 0.4: Different roots, investigate further
  → Sherlock synthesizes: "I notice the same pattern..."
```

**Mathematical Basis:**
```
root_vector = average(manifestation_embeddings)
root_confidence = 1 - standard_deviation(cosine_similarities)
```

---

#### Sherlock Day 7 Synthesis Prompt

```text
SYSTEM:
You are Sherlock, a psychological detective. You have observed the user's resistance patterns across multiple identity facets. Your task is to synthesize the ROOT PSYCHOLOGY from surface manifestations.

CONTEXT:
User has the following identity facets and resistance patterns:

Facet A: "{{facet_a.label}}"
- Resistance Script: "{{facet_a.resistance_script}}"
- Trigger Context: "{{facet_a.trigger_context}}"

Facet B: "{{facet_b.label}}"
- Resistance Script: "{{facet_b.resistance_script}}"
- Trigger Context: "{{facet_b.trigger_context}}"

Embedding Similarity: {{cosine_similarity}}

TASK:
1. Identify the COMMON THREAD connecting these resistance patterns
2. Name the ROOT ARCHETYPE (e.g., "Abandoned Child", "Perfectionist", "Imposter")
3. Articulate the CORE FEAR in one sentence
4. Explain how this root manifests differently in each context
5. Suggest a COACHING STRATEGY that addresses the root, not the symptoms

OUTPUT FORMAT (JSON):
{
  "root_label": "string",
  "core_fear": "string (one sentence)",
  "manifestation_explanations": {
    "facet_a": "how root shows up here",
    "facet_b": "how root shows up here"
  },
  "coaching_strategy": "string",
  "confidence": 0.0-1.0
}
```

---

#### Chronotype-JITAI Matrix

**Key Insight:** Intervention timing must respect biological chronotype, not just user preference.

| Chronotype | Peak (Push Hard) | Trough (Compassion) | Danger Zone (No Nudge) |
|------------|------------------|---------------------|------------------------|
| **Lion** | 06:00-10:00 | 14:00-16:00 | >20:30 |
| **Bear** | 10:00-14:00 | 15:00-16:00 | >23:00 |
| **Wolf** | 17:00-23:00 | 08:00-11:00 | 06:00-09:00 |
| **Dolphin** | Variable | Mid-Day | 02:00-05:00 |

**JITAI Integration:**
```dart
// In jitai_decision_engine.dart
String getInterventionTone(String chronotype, DateTime now) {
  final hour = now.hour;
  switch (chronotype) {
    case 'lion':
      if (hour >= 6 && hour < 10) return 'push_hard';
      if (hour >= 14 && hour < 16) return 'compassion';
      if (hour >= 20) return 'no_nudge';
      break;
    case 'wolf':
      if (hour >= 17 && hour < 23) return 'push_hard';
      if (hour >= 8 && hour < 11) return 'compassion';
      if (hour >= 6 && hour < 9) return 'no_nudge';
      break;
    // ... bear, dolphin cases
  }
  return 'neutral';
}
```

**Tone Mapping:**
| Tone | Message Style | Example |
|------|---------------|---------|
| `push_hard` | Direct challenge, high energy | "Time to become the person you promised. Go." |
| `compassion` | Gentle, self-compassion | "It's okay to rest. The streak isn't everything." |
| `no_nudge` | Silence (skip intervention) | — |
| `neutral` | Standard message | "Ready for your evening routine?" |

---

#### Sub-Questions Answered

| # | Question | Answer | Rationale |
|---|----------|--------|-----------|
| 1 | How does Sherlock extract Root vs Manifestation? | **Triangulation Protocol** — extract manifestations over 7 days, synthesize root via vector similarity | Users can't self-report roots; they only see symptoms |
| 2 | Should users see Root Fear? | **No** — only show manifestation-level coaching | Showing "Abandoned Child" could be traumatic; show "When deadlines loom, you procrastinate to protect yourself" |
| 3 | How link manifestations to roots? | **pgvector cosine similarity** — embeddings reveal semantic connection | Mathematical rather than heuristic |
| 4 | Multiple Root Fears? | **Allow up to 2** — primary root + secondary (if similarity < 0.4 across facets) | Some users have genuinely different roots for different life domains |
| 5 | Chronotype → JITAI? | **Chronotype-JITAI Matrix** — timing determines tone, not just content | Pushing a Wolf at 7am creates resentment, not action |

---

#### Implementation Roadmap

**⚠️ CRITICAL: Full Implementation at Launch (Not Phased)**

Per user directive (05 Jan 2026), the full psyOS vision will be implemented for launch, not staggered. Deep Think's phased approach has been consolidated into a single launch scope:

| Component | Deliverable | AI Model | Status |
|-----------|-------------|----------|--------|
| **Schema** | `psychometric_roots` + `psychological_manifestations` with pgvector | N/A | 🔴 To Build |
| **Onboarding** | Chronotype question; integrate into Keystone extraction | Gemini 3 Flash | 🔴 To Build |
| **Triangulation** | Day 1 → Day 4 → Day 7 manifestation extraction algorithm | Gemini 3 Flash | 🔴 To Build |
| **Synthesis** | Sherlock Day 7 root synthesis prompt with JSON output | **DeepSeek V3.2** | ✅ Designed |
| **Embeddings** | pgvector integration for semantic similarity | **DeepSeek V3.2** | 🔴 To Build |
| **JITAI** | Chronotype-JITAI Matrix in decision engine | Hardcoded | 🔴 To Build |
| **Tone Selection** | push_hard/compassion/no_nudge/neutral message selection | Hardcoded | 🔴 To Build |

**AI Model Strategy (see CD-016):**
- **Real-time voice**: Gemini 3 Flash (latency-critical)
- **Background analysis**: DeepSeek V3.2 (cost-effective, high reasoning)
- **Embedding generation**: DeepSeek V3.2 (batch processing)
- **Deterministic logic**: Hardcoded (no AI variance)

---

#### Output Delivered

| Deliverable | Status |
|-------------|--------|
| Schema for `psychometric_roots` | ✅ Complete (with pgvector) |
| Schema for `psychological_manifestations` | ✅ Complete (with embeddings) |
| Root extraction algorithm | ✅ Triangulation Protocol |
| Sherlock synthesis prompt | ✅ Day 7 JSON output prompt |
| Chronotype-JITAI integration | ✅ Matrix + tone mapping |
| UX guideline | ✅ Hide root, show manifestation coaching |

---

### RQ-013: Identity Topology & Graph Modeling

| Field | Value |
|-------|-------|
| **Question** | How should relationships between identity facets be modeled and utilized? |
| **Status** | 🔴 NEEDS RESEARCH |
| **Priority** | **HIGH** — Core to conflict detection |
| **Blocking** | Conflict resolution, JITAI integration, dashboard design |
| **Generated By** | CD-015 (psyOS Architecture) |
| **Assigned** | Dedicated session required |

**Context:**
Facets don't exist in isolation — they interact. Some are synergistic (Athlete + Morning Person), some antagonistic (Night Owl + Early Riser), some competitive (Founder + Present Father).

**Proposed Schema:**
```sql
CREATE TABLE identity_topology (
  source_facet_id UUID,
  target_facet_id UUID,
  interaction_type TEXT,             -- 'SYNERGISTIC', 'ANTAGONISTIC', 'COMPETITIVE'
  friction_coefficient FLOAT,        -- 0.0 (Flow) to 1.0 (Gridlock)
  switching_cost_minutes INT,        -- Bio-energetic recovery time
  PRIMARY KEY (source_facet_id, target_facet_id)
);
```

**Sub-Questions:**

| # | Question | Implications |
|---|----------|--------------|
| 1 | How do we initially populate the topology? | AI inference vs user declaration |
| 2 | Should topology edges be bidirectional or directed? | Graph complexity |
| 3 | How does friction coefficient affect JITAI decisions? | Intervention logic |
| 4 | What visualizations make topology intuitive to users? | UX research |
| 5 | How do we detect when topology has changed (life events)? | Adaptive system |
| 6 | Should we use a graph database or relational for topology? | Infrastructure |

**Output Expected:**
- Graph model specification (nodes, edges, weights)
- Algorithm for topology inference from behavior
- Integration points with JITAI and dashboard
- Visualization recommendations

---

### RQ-014: State Economics & Bio-Energetic Conflicts

| Field | Value |
|-------|-------|
| **Question** | How should bio-energetic state transitions and switching costs be modeled? |
| **Status** | 🔴 NEEDS RESEARCH |
| **Priority** | **HIGH** — Core to psyOS value proposition |
| **Blocking** | Airlock Protocol, JITAI intelligence, conflict detection |
| **Generated By** | CD-015 (psyOS Architecture) |
| **Assigned** | Dedicated session required |

**Context:**
Deep Think identified "The Energy Blind Spot" — tracking only time conflicts while ignoring energy state conflicts. Switching from "Deep Work Coder" (high_focus) to "Present Father" (social) has a massive switching cost even if time is available.

**Proposed Energy States:**

| State | Neurochemistry | Recovery Time |
|-------|----------------|---------------|
| `high_focus` | Dopamine/Acetylcholine | 45-90 min |
| `high_physical` | Adrenaline/Endorphin | 30-60 min |
| `social` | Oxytocin/Serotonin | 20-40 min |
| `recovery` | Parasympathetic | 15-30 min |

**Sub-Questions:**

| # | Question | Implications |
|---|----------|--------------|
| 1 | How do we validate energy state categories against literature? | Scientific grounding |
| 2 | Are switching costs bidirectional or asymmetric? | `high_focus → social` vs `social → high_focus` |
| 3 | How does chronotype affect energy state transitions? | Personalization |
| 4 | Should we track actual energy (HRV, sleep) vs assumed energy? | Data requirements |
| 5 | How do we detect energy state from passive signals? | Context capture |
| 6 | What interventions help reduce switching costs? | Airlock content |

**Output Expected:**
- Validated energy state taxonomy
- Switching cost matrix (state × state)
- Integration with JITAI for conflict detection
- Airlock ritual specifications per transition type

---

### RQ-015: Polymorphic Habits Implementation

| Field | Value |
|-------|-------|
| **Question** | How should habits be encoded differently based on active facet? |
| **Status** | 🔴 NEEDS RESEARCH |
| **Priority** | **HIGH** — Core UX differentiator |
| **Blocking** | Habit completion flow, dashboard metrics, neural reinforcement |
| **Generated By** | CD-015 (psyOS Architecture) |
| **Assigned** | Dedicated session required |

**Context:**
The same action (e.g., "Morning Run") can serve different facets with different meanings:
- As Athlete: Track pace, HR zone → "+10 Physical Points"
- As Founder: Track silence, ideas → "+10 Clarity Points"
- As Father: Track stress regulation → "Cortisol burned. Safe to go home."

**Key Insight:**
When checking off a habit, user should validate "Who did this serve?" — reinforcing the specific neural pathway.

**Sub-Questions:**

| # | Question | Implications |
|---|----------|--------------|
| 1 | Should facet attribution be automatic or user-selected? | UX friction |
| 2 | Can a single completion serve multiple facets simultaneously? | Many-to-many scoring |
| 3 | How do we track metrics differently per facet? | Data model complexity |
| 4 | What feedback language is appropriate per facet? | Content library |
| 5 | How does polymorphic encoding affect JITAI messages? | Personalization |
| 6 | Should completion history show facet context? | Dashboard design |

**Output Expected:**
- UX flow for facet attribution during completion
- Metric tracking architecture per facet
- Feedback message templates per facet type
- Integration with identity_facets and habit_facet_links tables

---

### RQ-016: Council AI (Roundtable Simulation)

| Field | Value |
|-------|-------|
| **Question** | How should the AI simulate a "parliament" of the user's identity facets for conflict resolution? |
| **Status** | ✅ RESEARCH COMPLETE |
| **Priority** | **CRITICAL** — Signature feature of psyOS |
| **Blocking** | AI prompts, voice session design, conflict resolution UX |
| **Generated By** | CD-015 (psyOS Architecture) |
| **Research Date** | 05 January 2026 |
| **Researcher** | Google Deep Think |

**Context:**
Instead of 1:1 AI chat, simulate the user's internal parliament:
```
User: "Should I take this promotion requiring travel?"

The Executive Agent: "Take it. Growth we promised."
The Father Agent: "You'll miss soccer practice. Violates 'Present' rule."

Sherlock (Mediator): "Proposal: Take job, negotiate 'No Travel Tuesdays'.
Executive gets growth; Father gets consistency. Treaty?"
```

---

#### The Single-Shot Playwright Model

**Key Decision:** Do NOT use multi-agent orchestration (LangChain agent chaining). Instead, use a **Single-Shot Playwright Model** where one LLM call generates the entire dramatic script.

**Rationale:**
| Approach | Pros | Cons |
|----------|------|------|
| Multi-Agent (LangChain) | More "authentic" agent voices | Latency, cost, complexity, unpredictable turns |
| **Single-Shot Playwright** | Fast, predictable, coherent narrative | Requires careful prompt engineering |

**Architecture:**
```
Input: Conflict description + Facet profiles + User history
  ↓
Single LLM Call (Gemini 3 Flash)
  ↓
Output: Complete dramatic script + Treaty proposal (JSON)
```

---

#### Council AI System Prompt

```text
SYSTEM_ROLE:
You are "The Council Engine." You simulate a roundtable debate between the user's Internal Facets.
Sherlock (The Mediator) is the Chair.

CAST:
1. SHERLOCK (Narrator/Mediator): Objective, calm, Socratic. Describes the scene and synthesizes proposals. Speaks in third person about the agents.
2. AGENT A ("{{facet_a.label}}"):
   - Voice Style: {{facet_a.voice_style}}
   - Core Fear: {{facet_a.manifestation_archetype}}
   - Goal: Advocate for this facet's priorities
3. AGENT B ("{{facet_b.label}}"):
   - Voice Style: {{facet_b.voice_style}}
   - Core Fear: {{facet_b.manifestation_archetype}}
   - Goal: Advocate for this facet's priorities

CONFLICT:
"{{conflict_description}}"
(Example: "The user wants to accept a promotion requiring 40% travel, but this conflicts with their 'Present Father' commitment.")

RULES:
1. Each agent speaks 2-3 times maximum
2. Sherlock opens with scene-setting, then facilitates
3. Agents argue their position with emotional authenticity (not logic alone)
4. Sherlock identifies COMMON GROUND and proposes a TREATY
5. The Treaty must be SPECIFIC (not "find balance" but "No travel Tuesdays and Thursdays")
6. End with a question to the user: "Do you accept this Treaty?"

OUTPUT FORMAT:
```json
{
  "script": [
    {"speaker": "sherlock", "type": "narration", "text": "..."},
    {"speaker": "{{facet_a.label}}", "type": "dialogue", "text": "..."},
    {"speaker": "{{facet_b.label}}", "type": "dialogue", "text": "..."},
    // ... more turns
    {"speaker": "sherlock", "type": "proposal", "text": "I propose the following Treaty..."}
  ],
  "treaty_proposal": {
    "title": "The Tuesday-Thursday Shield",
    "terms": "No work travel on Tuesdays and Thursdays. These are protected family days.",
    "logic_hooks": {
      "trigger": "travel_scheduled",
      "condition": "day_of_week IN ('tuesday', 'thursday')",
      "action": "block_and_remind",
      "reminder_text": "This day is protected by your Treaty. The Father needs you home."
    }
  },
  "closing_question": "Do you accept this Treaty, knowing both parts of you had a voice?"
}
```

TONE:
- Dramatic but not theatrical
- Emotionally resonant but not manipulative
- The goal is INSIGHT, not entertainment
```

---

#### Facet Agent Templates

Each facet has a voice profile that shapes how it argues in Council:

```json
{
  "professional_achiever": {
    "voice_style": "Confident, metrics-driven, future-focused",
    "typical_arguments": ["Growth opportunity", "Career trajectory", "Financial security"],
    "fear_trigger": "Being left behind, irrelevance",
    "compromise_willing": ["Time boundaries", "Remote options"],
    "non_negotiable": ["Challenging work", "Recognition"]
  },
  "present_parent": {
    "voice_style": "Warm, guilt-aware, protective",
    "typical_arguments": ["Kids grow up fast", "Presence over presents", "Their memory of you"],
    "fear_trigger": "Missing moments, child's resentment",
    "compromise_willing": ["Quality over quantity", "Scheduled presence"],
    "non_negotiable": ["Key events", "Bedtime routines"]
  },
  "health_guardian": {
    "voice_style": "Steady, long-term thinking, body-aware",
    "typical_arguments": ["Future self needs you healthy", "Energy compounds", "No career without health"],
    "fear_trigger": "Burnout, chronic illness, early death",
    "compromise_willing": ["Timing of exercise", "Type of activity"],
    "non_negotiable": ["Sleep hours", "Recovery days"]
  },
  "creative_explorer": {
    "voice_style": "Playful, possibility-seeking, restless",
    "typical_arguments": ["Life is short", "When will you if not now?", "Soul food"],
    "fear_trigger": "Regret, unlived life, creative death",
    "compromise_willing": ["Frequency", "Scale of projects"],
    "non_negotiable": ["Some creative time", "Permission to dream"]
  }
}
```

---

#### The Treaty Protocol

Treaties are database objects that **override default JITAI logic** when specific conditions are met.

**Schema:**
```sql
CREATE TABLE treaties (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  title TEXT NOT NULL,               -- "The Tuesday-Thursday Shield"
  terms_text TEXT NOT NULL,          -- Human-readable terms
  logic_hooks JSONB NOT NULL,        -- Machine-executable rules
  facets_involved UUID[] NOT NULL,   -- Which facets negotiated this
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'expired', 'broken')),
  signed_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ,            -- Optional expiration
  breach_count INT DEFAULT 0,        -- How many times violated
  last_breach_at TIMESTAMPTZ
);
```

**Logic Hooks Structure:**
```json
{
  "trigger": "travel_scheduled",           // Event that activates the hook
  "condition": "day_of_week IN ('tue', 'thu')",  // When to fire
  "action": "block_and_remind",            // What to do
  "reminder_text": "Protected day per Treaty",  // What to say
  "severity": "hard"                       // "soft" = warn, "hard" = block
}
```

**Treaty Lifecycle:**
```
DRAFT → User reviews Council output
  ↓
SIGNED → User explicitly accepts ("I accept this Treaty")
  ↓
ACTIVE → Logic hooks fire on triggers
  ↓
BREACHED → User overrides Treaty (logged, not blocked for "soft")
  ↓
RENEGOTIATION → After 3 breaches, prompt: "This Treaty isn't working. Reconvene Council?"
```

---

#### UX Flow

```
1. SUMMON THE COUNCIL
   Trigger: User asks conflict question OR system detects high tension_score
   UI: "Your inner council wants to discuss this. Convene?" [Yes / Not Now]

2. THE SHOW
   Display: Animated script playback (text bubbles, character avatars)
   Duration: 30-60 seconds of reading
   Audio: Optional voice synthesis (Audiobook Pattern - see below)

3. THE DEAL
   Display: Treaty card with clear terms
   Action: "Sign Treaty" / "Reject" / "Modify"

4. BINDING
   On Sign: Treaty stored in DB, logic_hooks activated
   Confirmation: "Treaty signed. Your facets are now bound."

5. ENFORCEMENT
   When trigger fires: "⚠️ TREATY ALERT: This violates 'The Tuesday-Thursday Shield'.
   The Father asked you to protect this day. Override anyway?"
   Options: [Honor Treaty] [Override (logs breach)] [Renegotiate]
```

---

#### Voice Mode Adaptation: The Audiobook Pattern

**Problem:** Multi-voice synthesis (different voice per agent) is:
- Technically complex
- Expensive (multiple TTS calls)
- Often sounds jarring

**Solution: The Audiobook Pattern**
A single narrator voice (Sherlock) reads the entire script, including character dialogue with vocal inflection but not character switching.

```
Sherlock (narrating): "The Executive leans forward, intensity in his voice."
Sherlock (as Executive): "'This is the opportunity we've been building toward.'"
Sherlock (narrating): "The Father shakes his head slowly."
Sherlock (as Father): "'But at what cost? They won't be little forever.'"
```

**Implementation:**
- Use Gemini 2.5 Flash TTS with SSML tags for pacing
- Add `[pause:500ms]` markers in script
- Character dialogue gets slightly different prosody (not different voice)

**Why This Works:**
- Audiobooks have done this for centuries
- Maintains narrative coherence
- Single voice = single TTS call = faster, cheaper
- Listeners are trained to accept this convention

---

#### Therapeutic Guardrails

| Risk | Guardrail |
|------|-----------|
| **User feels "talked at"** | The Veto Rule: User is the only one with a vote. Agents propose; User decides. |
| **Facet becomes "bad guy"** | No Bad Parts: Frame agents as Protectors with fears, not villains with demands |
| **Self-harm context** | Safety Switch: If conflict involves self-harm language, exit Council immediately, route to crisis resources |
| **Treaty feels like constraint** | Framing: "Treaty" not "Rule" — Treaties can be renegotiated, rules feel imposed |
| **Endless debate** | Turn Limit: Max 6 turns per Council session. Sherlock must propose by turn 5. |

---

#### Sub-Questions Answered

| # | Question | Answer | Rationale |
|---|----------|--------|-----------|
| 1 | How construct AI agents per facet? | **Single-Shot Playwright** with Facet Agent Templates injected into prompt | Faster, cheaper, more coherent than multi-agent |
| 2 | Distinct voices? | **Yes, in text style; No in audio (Audiobook Pattern)** | Text voices defined by templates; audio uses single narrator |
| 3 | Prevent gimmicky feeling? | **Emotional authenticity + real consequences (Treaties)** | It's not theater if it changes behavior |
| 4 | What triggers Council? | **High tension_score (>0.7) OR user question with "should I" + multi-facet keywords** | Automatic detection + explicit summon |
| 5 | Treaty implementation? | **DB table with logic_hooks + JITAI override** | Treaties are executable, not just symbolic |
| 6 | Async Council? | **Phase 2: Notification-based mini-debates** | Start with sync for MVP, add async later |
| 7 | No consensus? | **Sherlock proposes "Temporary Experiment" — try for 2 weeks, reconvene** | No permanent deadlock; time-bound trials |

---

#### Implementation Roadmap

**⚠️ CRITICAL: Full Implementation at Launch (Not Phased)**

Per user directive (05 Jan 2026), the full psyOS vision will be implemented for launch, not staggered. Deep Think's phased approach has been consolidated into a single launch scope:

| Component | Deliverable | AI Model | Status |
|-----------|-------------|----------|--------|
| **System Prompt** | Single-Shot Playwright with CAST injection | **DeepSeek V3.2** | ✅ Designed |
| **UI** | Text bubbles, character avatars, animated script playback | N/A | 🔴 To Build |
| **Treaty Table** | `treaties` schema with `logic_hooks` JSONB | N/A | 🔴 To Build |
| **Logic Hooks** | Treaty enforcement in JITAI decision engine | Hardcoded | 🔴 To Build |
| **Breach Tracking** | Violation counting, renegotiation triggers | Hardcoded | 🔴 To Build |
| **Voice (Audiobook)** | Single narrator TTS with SSML markup | Gemini 2.5 Flash TTS | 🔴 To Build |
| **Auto-Detection** | tension_score > 0.7 triggers Council summon | **DeepSeek V3.2** | 🔴 To Build |

**AI Model Strategy (see CD-016):**
- **Council Script Generation**: DeepSeek V3.2 (complex reasoning, cost-effective for single-shot)
- **Voice Synthesis (Audiobook)**: Gemini 2.5 Flash TTS (quality, SSML support)
- **Conflict Detection**: DeepSeek V3.2 (pattern analysis)
- **Logic Hook Execution**: Hardcoded (deterministic, no AI variance)

**Treaty-JITAI Integration:**
Treaties override default JITAI behavior. When a logic_hook fires:
1. Check user's active treaties
2. If treaty condition matches, override JITAI's default intervention
3. Use treaty's `reminder_text` instead of standard content
4. Log enforcement for breach tracking

---

#### Output Delivered

| Deliverable | Status |
|-------------|--------|
| Architecture decision | ✅ Single-Shot Playwright (not multi-agent) |
| System prompt | ✅ Complete with JSON output format |
| Facet Agent Templates | ✅ 4 archetypes defined |
| Treaty schema | ✅ With logic_hooks JSONB |
| UX flow | ✅ Summon → Show → Deal → Binding → Enforcement |
| Voice strategy | ✅ Audiobook Pattern (single narrator) |
| Guardrails | ✅ Veto Rule, No Bad Parts, Safety Switch, Turn Limit |

---

### RQ-017: Constellation UX (Solar System Visualization)

| Field | Value |
|-------|-------|
| **Question** | How should the dashboard visualize identity facets as a living solar system? |
| **Status** | ✅ COMPLETE |
| **Completed** | 10 January 2026 |
| **Priority** | **HIGH** — Core visual identity of psyOS |
| **Generated By** | CD-015 (psyOS Architecture) |
| **Reconciliation** | `docs/analysis/DEEP_THINK_RECONCILIATION_RQ017_RQ018.md` |

**Sub-Questions Answered:**

| # | Question | Answer | Confidence |
|---|----------|--------|------------|
| 1 | Animation framework? | **Flutter CustomPainter (Canvas)** — Rive/Lottie can't handle dynamic orbital math | HIGH |
| 2 | Data binding? | **Bohr-Kepler Hybrid Model** — Stable orbits + physics velocity | HIGH |
| 3 | Interactions? | Tap planet → drill-down; Tap tether → conflict modal | HIGH |
| 4 | Scalability? | Max 7 facets; progressive disclosure Day 1→7→30 | HIGH |
| 5 | Accessibility? | Settled state (0 FPS idle); reduced motion option | MEDIUM |
| 6 | Migration? | **Big Bang with fallback** (PD-108) | HIGH |
| 7 | Physics? | Pseudo-physics for visual effect, not simulation | HIGH |

**Key Deliverables:**

| Visual Property | Data Source | Formula |
|-----------------|-------------|---------|
| **Planet Radius** | `habitVolume` | `16dp + clamp(log(votes)*4, 0, 24)` |
| **Orbit Distance** | `ics_score` | `MaxRadius - (ICS * 30dp)` |
| **Planet Color** | `energyState` | Blue/Green/Orange/Purple (4-state) |
| **Brightness** | `lastEngaged` | 100% (<3d), 30% (>7d = Ghost) |
| **Wobble** | `friction` | `offset += sin(t*20) * friction * 4px` |
| **Tether** | `friction > 0.6` | Red dashed line if both active |

**Implementation Tasks:** H-01 through H-09, H-15, H-16

---

### RQ-018: Airlock Protocol & Identity Priming

| Field | Value |
|-------|-------|
| **Question** | How should state transitions and sensory priming be implemented? |
| **Status** | ✅ COMPLETE |
| **Completed** | 10 January 2026 |
| **Priority** | **HIGH** — Differentiates psyOS from competitors |
| **Generated By** | CD-015 (psyOS Architecture) |
| **Reconciliation** | `docs/analysis/DEEP_THINK_RECONCILIATION_RQ017_RQ018.md` |

**Sub-Questions Answered:**

| # | Question | Answer | Confidence |
|---|----------|--------|------------|
| 1 | Trigger detection? | **Predictive (Calendar) + Reactive (App change)** | HIGH |
| 2 | Transition rituals? | **5-Second Seal (v0.5)** — press-and-hold fingerprint | HIGH |
| 3 | Audio assets? | **Stock library (4 loops, <500KB)** + user mantras post-launch | HIGH |
| 4 | Customization? | **Hybrid (PD-112)** — Stock default, user unlock at Sapling tier | HIGH |
| 5 | Effectiveness? | Transition quality metrics, treaty compliance | MEDIUM |
| 6 | User control? | **Severity + Treaty (PD-110)** — suggested default, Treaty makes mandatory | HIGH |
| 7 | Anti-annoyance? | Severity-based intensity; max 1m ritual for v1 | HIGH |

**Key Deliverables:**

**The Seal (v0.5):**
- Full-screen overlay: "Leaving [Facet A]. Entering [Facet B]."
- Press-and-hold fingerprint icon for 5 seconds
- Circle fills with light (0% → 100%)
- Haptic ramp: `createWaveform([0,1000,1000,1000,1000,1000], [0,50,0,100,0,200], -1)`

**Transition Intensity Matrix (from RQ-014):**

| From ↓ / To → | Focus | Physical | Social | Recovery |
|---------------|-------|----------|--------|----------|
| **Focus** | — | Low | **CRITICAL** | Med |
| **Physical** | Med | — | Low | Low |
| **Social** | **HIGH** | Low | — | Low |
| **Recovery** | Med | High | Low | — |

**Audio Assets (Stock):**
- `drone_focus.ogg` (40Hz Gamma binaural)
- `drone_social.ogg` (Warm acoustic)
- `drone_physical.ogg` (130bpm percussion)
- `sfx_airlock_seal.ogg` (Pneumatic hiss)

**Implementation Tasks:** H-10 through H-14

---

### RQ-019: pgvector Implementation Strategy

| Field | Value |
|-------|-------|
| **Question** | How should vector embeddings be implemented for semantic similarity in psyOS? |
| **Status** | ✅ RESEARCH COMPLETE |
| **Priority** | **HIGH** — Foundational to Triangulation Protocol |
| **Blocking** | Root synthesis, cross-facet pattern detection, population learning |
| **Generated By** | RQ-012 (Fractal Trinity) Deep Think research |
| **Research Date** | 05 January 2026 |
| **Researcher** | Google Deep Think |

**Context:**
Deep Think's Triangulation Protocol requires semantic embeddings to:
1. Store `root_embedding` and `resistance_embedding` vectors
2. Calculate cosine similarity between manifestations
3. Enable population-level pattern detection

---

#### Embedding Model Selection

**Decision:** Use **gemini-embedding-001** (not text-embedding-004)

| Criterion | gemini-embedding-001 | text-embedding-004 |
|-----------|---------------------|-------------------|
| **Status** | ✅ Current | ⚠️ Deprecated Jan 14, 2026 |
| **Dimensions** | 3072 default (Matryoshka: 768/1536/3072) | 768 fixed |
| **F1 Score** | +1.9% improvement | Baseline |
| **Languages** | Unified multilingual + code | Separate models |
| **Matryoshka** | ✅ Flexible truncation | ❌ Fixed |

**Matryoshka Representation Learning (MRL):**
The embedding can be truncated to smaller dimensions without re-embedding:
- Full precision: 3072 dimensions
- Medium: 1536 dimensions
- Compact: 768 dimensions (for cost optimization)

**Recommendation:** Store 3072-dim embeddings, use 768 for similarity queries (cheaper, still effective).

---

#### Finalized Schema (with pgvector)

```sql
-- 1. Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- 2. Vector fields in core tables
-- psychometric_roots: Root embedding for pattern matching
ALTER TABLE psychometric_roots
ADD COLUMN root_embedding VECTOR(3072);

-- psychological_manifestations: Resistance embedding for cross-facet similarity
ALTER TABLE psychological_manifestations
ADD COLUMN resistance_embedding VECTOR(3072);

-- 3. Create HNSW Index for fast similarity search
-- HNSW = Hierarchical Navigable Small World (superior to IVFFlat for our scale)
CREATE INDEX ON psychological_manifestations
USING hnsw (resistance_embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);

CREATE INDEX ON psychometric_roots
USING hnsw (root_embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);

-- 4. Row Level Security (RLS) - Users can only query their own embeddings
ALTER TABLE psychological_manifestations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own manifestations" ON psychological_manifestations
FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own manifestations" ON psychological_manifestations
FOR UPDATE USING (auth.uid() = user_id);
```

**HNSW Index Parameters:**
| Parameter | Value | Rationale |
|-----------|-------|-----------|
| `m` | 16 | Balanced recall/speed for <1M vectors |
| `ef_construction` | 64 | Higher build quality, one-time cost |
| `vector_cosine_ops` | — | Cosine similarity for semantic matching |

---

#### Embedding Invalidation Trigger (Null-on-Update)

When `resistance_script` is edited, the embedding becomes stale. Use a trigger to invalidate:

```sql
-- Invalidation trigger: Set embedding to NULL when text changes
CREATE OR REPLACE FUNCTION invalidate_embedding() RETURNS TRIGGER AS $$
BEGIN
  NEW.resistance_embedding = NULL;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_script_update
BEFORE UPDATE OF resistance_script ON psychological_manifestations
FOR EACH ROW EXECUTE FUNCTION invalidate_embedding();
```

**Why Null-on-Update:**
- Cheaper than re-embedding on every edit (user may edit multiple times)
- Background worker re-embeds NULL vectors in batch
- Avoids blocking the user's write operation

---

#### Edge Function for Embedding Generation

```typescript
// supabase/functions/embed-manifestation/index.ts
import { GoogleGenerativeAI } from '@google/generative-ai';

Deno.serve(async (req) => {
  const payload = await req.json();
  const { id, resistance_script } = payload.record;

  // Skip if no text to embed
  if (!resistance_script) return new Response('No text', { status: 200 });

  const genAI = new GoogleGenerativeAI(Deno.env.get('GEMINI_API_KEY')!);

  // CRITICAL: Use gemini-embedding-001 (not deprecated text-embedding-004)
  const model = genAI.getGenerativeModel({ model: "gemini-embedding-001" });

  const result = await model.embedContent(resistance_script);
  const embedding = result.embedding.values; // 3072-dim vector

  // Write back to DB
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  );

  await supabase
    .from('psychological_manifestations')
    .update({ resistance_embedding: embedding })
    .eq('id', id);

  return new Response('Embedded', { status: 200 });
});
```

**Trigger Configuration:**
```sql
-- Database webhook to call Edge Function on NULL embeddings
-- Configure in Supabase Dashboard → Database → Webhooks
-- Trigger: INSERT or UPDATE on psychological_manifestations
-- Condition: resistance_embedding IS NULL AND resistance_script IS NOT NULL
```

---

#### Timing Strategy: Async Database Webhooks

| Approach | Pros | Cons | Decision |
|----------|------|------|----------|
| Sync (in-request) | Immediate | Blocks user, timeout risk | ❌ |
| Background worker | Batched, efficient | Delay, infrastructure | ⚠️ Later |
| **Async Webhook** | Near-realtime, serverless | Per-call cost | ✅ **MVP** |

**Flow:**
```
User edits resistance_script
  → Trigger sets resistance_embedding = NULL
  → Supabase Webhook fires on NULL condition
  → Edge Function generates embedding
  → Edge Function writes back to DB
  → (async, ~500ms latency)
```

---

#### Cost Projection

| Users | Vectors/User | Total Vectors | Embedding Cost | Storage Cost | Monthly Total |
|-------|--------------|---------------|----------------|--------------|---------------|
| 10K | 10 | 100K | $5/mo | $2/mo | **$7/mo** |
| 100K | 10 | 1M | $50/mo | $20/mo | **$70/mo** |
| 1M | 10 | 10M | $500/mo | $200/mo | **$700/mo** |

**Assumptions:**
- 10 manifestations per user (average)
- gemini-embedding-001: ~$0.00005 per embedding
- pgvector storage: ~$0.02 per 1K vectors/month
- 20% re-embedding rate (edits)

---

#### Sub-Questions Answered

| # | Question | Answer | Rationale |
|---|----------|--------|-----------|
| 1 | pgvector on Supabase free tier? | ✅ Yes | Extension available on all tiers |
| 2 | Which embedding model? | **gemini-embedding-001** | Better performance, not deprecated, Matryoshka support |
| 3 | Batch embedding strategy? | Async webhooks (MVP), background worker (scale) | Balance latency vs cost |
| 4 | Query pattern? | HNSW index with cosine similarity | Fast ANN search at scale |
| 5 | Embedding updates? | Null-on-Update trigger + async re-embed | Decouple write from embed |
| 6 | Storage cost at scale? | ~$200/mo at 1M users | Acceptable for value delivered |

---

#### AI Model Clarification

**Updated CD-016 Embedding Assignment:**

| Task | Model | Rationale |
|------|-------|-----------|
| **Embedding Generation** | **gemini-embedding-001** | Purpose-built for embeddings, Matryoshka support |
| Council AI Scripts | DeepSeek V3.2 | Complex reasoning |
| Root Synthesis | DeepSeek V3.2 | Deep analysis |
| Gap Analysis | DeepSeek V3.2 | Pattern detection |

**Note:** DeepSeek V3.2 is for **reasoning** tasks, not embeddings. Gemini's dedicated embedding model is more efficient and cost-effective for vector generation.

---

#### Similarity Search Query Patterns

**Use Case 1: Find Similar Manifestations Within User**
```sql
-- Find manifestations similar to a specific one (same user)
SELECT m2.id, m2.resistance_script,
       1 - (m1.resistance_embedding <=> m2.resistance_embedding) AS similarity
FROM psychological_manifestations m1
JOIN psychological_manifestations m2 ON m1.user_id = m2.user_id
WHERE m1.id = $manifestation_id
  AND m2.id != m1.id
  AND m1.resistance_embedding IS NOT NULL
  AND m2.resistance_embedding IS NOT NULL
ORDER BY m1.resistance_embedding <=> m2.resistance_embedding
LIMIT 5;
```

**Use Case 2: Cross-Facet Pattern Detection**
```sql
-- Find if same resistance pattern appears across different facets
SELECT
  f1.label AS facet_1,
  f2.label AS facet_2,
  m1.resistance_script AS pattern_1,
  m2.resistance_script AS pattern_2,
  1 - (m1.resistance_embedding <=> m2.resistance_embedding) AS similarity
FROM psychological_manifestations m1
JOIN psychological_manifestations m2
  ON m1.user_id = m2.user_id
  AND m1.facet_id != m2.facet_id
JOIN identity_facets f1 ON m1.facet_id = f1.id
JOIN identity_facets f2 ON m2.facet_id = f2.id
WHERE m1.user_id = $user_id
  AND 1 - (m1.resistance_embedding <=> m2.resistance_embedding) > 0.85
ORDER BY similarity DESC;
```

**Dart Query Wrapper:**
```dart
// lib/data/repositories/embedding_repository.dart
class EmbeddingRepository {
  final SupabaseClient _supabase;

  /// Find manifestations similar to the given one
  Future<List<SimilarManifestation>> findSimilar(
    String manifestationId, {
    double threshold = 0.7,
    int limit = 5,
  }) async {
    final response = await _supabase.rpc(
      'find_similar_manifestations',
      params: {
        'target_id': manifestationId,
        'similarity_threshold': threshold,
        'result_limit': limit,
      },
    );
    return (response as List)
        .map((e) => SimilarManifestation.fromJson(e))
        .toList();
  }

  /// Detect cross-facet patterns for a user
  Future<List<CrossFacetPattern>> detectCrossFacetPatterns(
    String userId, {
    double threshold = 0.85,
  }) async {
    final response = await _supabase.rpc(
      'detect_cross_facet_patterns',
      params: {
        'target_user_id': userId,
        'similarity_threshold': threshold,
      },
    );
    return (response as List)
        .map((e) => CrossFacetPattern.fromJson(e))
        .toList();
  }
}
```

---

#### Population Learning Pipeline

**Purpose:** Aggregate anonymized patterns across users for:
1. Identify common resistance archetypes (cluster analysis)
2. Discover effective coaching strategies per archetype
3. Cold-start recommendations for new users

**Privacy-First Design:**
```sql
-- Population embeddings are ANONYMIZED (no user_id, no text)
CREATE TABLE population_resistance_clusters (
  cluster_id UUID PRIMARY KEY,
  centroid_embedding VECTOR(768),  -- Truncated from 3072 for privacy
  cluster_label TEXT,              -- "Perfectionist Resistance", "Procrastination Pattern"
  member_count INT,
  coaching_strategy TEXT,          -- What works for this cluster
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
);

-- Users opt-in to population learning
ALTER TABLE users ADD COLUMN population_learning_enabled BOOLEAN DEFAULT false;
```

**Cluster Update Job (Nightly):**
```typescript
// supabase/functions/update-population-clusters/index.ts
// 1. Fetch all embeddings from opted-in users
// 2. Truncate to 768 dimensions (Matryoshka)
// 3. Run K-means clustering (k=20)
// 4. Update centroid embeddings
// 5. Label clusters via DeepSeek V3.2 analysis
```

**Cold-Start Matching:**
```dart
// For new users, match their first manifestation to population cluster
Future<String?> suggestCoachingStrategy(String manifestationId) async {
  final embedding = await getEmbedding(manifestationId);
  final truncated = embedding.sublist(0, 768);  // Matryoshka truncation

  final cluster = await findNearestCluster(truncated);
  return cluster?.coachingStrategy;
}
```

**Privacy Constraints (see PD-116):**
| Data | Shared? | How |
|------|---------|-----|
| Raw text (resistance_script) | ❌ Never | — |
| Full embedding (3072-dim) | ❌ Never | — |
| Truncated embedding (768-dim) | ✅ If opted-in | Anonymized, no user_id |
| Cluster membership | ✅ If opted-in | Aggregate only |

---

#### Output Delivered

| Deliverable | Status |
|-------------|--------|
| Supabase pgvector setup | ✅ SQL schema provided |
| Embedding model selection | ✅ gemini-embedding-001 (with rationale) |
| Index strategy | ✅ HNSW with tuned parameters |
| Invalidation logic | ✅ Null-on-Update trigger |
| Edge Function code | ✅ TypeScript implementation |
| Cost projection | ✅ 10K → 1M users |
| Similarity search queries | ✅ SQL + Dart wrappers |
| Population learning pipeline | ✅ Privacy-first cluster design |

---

### RQ-020: Treaty-JITAI Integration Architecture

| Field | Value |
|-------|-------|
| **Question** | How should Treaties override and interact with default JITAI logic? |
| **Status** | ✅ RESEARCH COMPLETE |
| **Priority** | **HIGH** — Core to Council AI value |
| **Blocking** | Treaty enforcement, JITAI modifications, logic hook execution |
| **Generated By** | RQ-016 (Council AI) Deep Think research |
| **Research Date** | 05 January 2026 |
| **Researcher** | Google Deep Think |

**Context:**
Deep Think specified that Treaties are "database objects that override default JITAI logic when specific conditions are met." This requires:
1. A priority hierarchy (Treaty vs default JITAI)
2. Logic hook execution engine
3. Breach tracking and renegotiation triggers

---

#### JITAI Pipeline Position: Stage 3 (Post-Safety, Pre-Optimization)

```
JITAI Decision Pipeline (Finalized)
├── 1. Calculate V-O State
├── 2. Safety Gates (Gottman, fatigue) ← NEVER OVERRIDDEN
├── 3. ★ TREATY CHECK ★ (NEW)
│   ├── Load active treaties for user
│   ├── Evaluate logic_hooks against ContextSnapshot
│   ├── If Hard Treaty matches → BLOCK (override pipeline)
│   └── If Soft Treaty matches → WARN (continue with reminder)
├── 4. Optimal Timing Analysis
├── 5. Quadrant-based Strategy
├── 6. Hierarchical Bandit Selection
└── 7. Content Generation (may inject Treaty reminder_text)
```

**Why Stage 3 (Post-Safety):**
- Safety Gates are **absolute** — Treaties cannot override Gottman ratio limits
- Treaties represent **user values**, not psychological safety
- Placing after safety prevents self-harm via Treaty ("I will work 20 hours/day")

---

#### Logic Hook Parser: json_logic_dart

**Decision:** Use `json_logic_dart` package (NOT custom expression parser)

**Rationale:**
| Approach | Pros | Cons | Decision |
|----------|------|------|----------|
| Custom eval() | Flexible | Security risk, maintenance | ❌ |
| **JSON Logic** | Standard, safe, expressive | Learning curve | ✅ |
| SQL-like DSL | Familiar | Parse complexity | ❌ |

**JSON Logic Grammar:**
```json
{
  "and": [
    { "==": [{ "var": "day_of_week" }, "tuesday"] },
    { ">=": [{ "var": "hour" }, 18] }
  ]
}
```

**Supported Operators:**
| Category | Operators |
|----------|-----------|
| Logic | `and`, `or`, `!`, `if` |
| Comparison | `==`, `!=`, `>`, `>=`, `<`, `<=` |
| Numeric | `+`, `-`, `*`, `/`, `%` |
| Array | `in`, `all`, `some`, `none` |
| String | `substr`, `cat` |
| Data | `var`, `missing`, `missing_some` |

**Context Variables Available:**
```dart
// ContextSnapshot fields available to logic hooks
{
  "day_of_week": "tuesday",
  "hour": 18,
  "minute": 30,
  "is_weekend": false,
  "location_zone": "home",
  "active_facet": "the_father",
  "habit_id": "uuid",
  "habit_name": "evening_run",
  "streak_days": 7,
  "last_completion_hours_ago": 24,
  "energy_state": "high_focus",
  "vulnerability_score": 0.6,
  "opportunity_score": 0.8
}
```

---

#### TreatyEngine Dart Implementation

```dart
// lib/domain/services/treaty_engine.dart
import 'package:json_logic_dart/json_logic_dart.dart';

class TreatyEngine {
  final JsonLogic _logic = JsonLogic();

  /// Check all active treaties against current context
  /// Returns the highest-priority matching treaty, or null
  Treaty? checkTreaties(ContextSnapshot context, List<Treaty> activeTreaties) {
    final contextMap = context.toJson();

    List<Treaty> matches = activeTreaties.where((t) {
      try {
        return _logic.apply(t.logicHooks['condition'], contextMap) == true;
      } catch (e) {
        // Invalid logic hook — log and skip
        return false;
      }
    }).toList();

    if (matches.isEmpty) return null;

    // Conflict Resolution: Hard > Soft, then Newest > Oldest
    matches.sort((a, b) {
      // 1. Severity: hard beats soft
      int severityA = a.logicHooks['action']['severity'] == 'hard' ? 2 : 1;
      int severityB = b.logicHooks['action']['severity'] == 'hard' ? 2 : 1;
      int score = severityB.compareTo(severityA);
      if (score != 0) return score;

      // 2. Recency: newer beats older
      return b.signedAt.compareTo(a.signedAt);
    });

    return matches.first;
  }

  /// Execute the treaty's action
  TreatyAction executeAction(Treaty treaty, ContextSnapshot context) {
    final action = treaty.logicHooks['action'];
    final actionType = action['type'] as String;

    switch (actionType) {
      case 'block_and_remind':
        return TreatyAction(
          type: TreatyActionType.block,
          reminderText: action['reminder_text'] ?? treaty.termsText,
          treatyId: treaty.id,
        );
      case 'warn':
        return TreatyAction(
          type: TreatyActionType.warn,
          reminderText: action['reminder_text'] ?? treaty.termsText,
          treatyId: treaty.id,
        );
      case 'log_only':
        return TreatyAction(
          type: TreatyActionType.log,
          reminderText: null,
          treatyId: treaty.id,
        );
      default:
        return TreatyAction(
          type: TreatyActionType.none,
          reminderText: null,
          treatyId: treaty.id,
        );
    }
  }
}

enum TreatyActionType { block, warn, log, none }

class TreatyAction {
  final TreatyActionType type;
  final String? reminderText;
  final String treatyId;

  TreatyAction({
    required this.type,
    required this.reminderText,
    required this.treatyId,
  });
}
```

---

#### Treaty Priority Hierarchy (5-Level Stack)

| Rank | Component | Behavior | Example |
|------|-----------|----------|---------|
| 1 | **Safety Gates** | ABSOLUTE (Never Overridden) | Gottman ratio, fatigue limits |
| 2 | **Hard Treaties** | BLOCKING — stops action | "No work travel on Tuesdays" |
| 3 | **Soft Treaties** | WARNING — reminds but allows | "Try to avoid screens after 9pm" |
| 4 | **JITAI Algorithm** | DEFAULT — learned interventions | Thompson Sampling selection |
| 5 | **User Preferences** | PASSIVE — lowest priority | Notification timing preferences |

**Key Insight:** Safety Gates > User Values > AI Optimization > User Preferences

---

#### Breach Logic: Probationary Status

**Breach Definition:** User explicitly overrides a Treaty (clicks "Override Anyway" on hard block).

**Breach Escalation:**
| Breach Count (7 days) | Status | Action |
|----------------------|--------|--------|
| 0 | Active | Normal enforcement |
| 1 | Active | Log only, show gentle reminder |
| 2 | Active | "You've broken this Treaty twice this week" |
| **3** | **Probationary** | "This Treaty isn't working. Reconvene Council?" |
| 4 | Probationary | Continue prompting for renegotiation |
| 5+ | **Auto-Suspended** | Treaty suspended, user notified |

**Auto-Suspension on Dismiss:**
If user dismisses renegotiation prompt 3 times:
```
Treaty enters "suspended" status
Notification: "Your [Treaty Name] has been paused. Tap to reactivate or delete."
```

---

#### Council AI Activation Keywords (PD-109 Finalized)

**Tension Threshold:** `0.7`
**Turn Limit:** `6` per session
**Rate Limit:** `1 auto-summon per 24h per conflict topic`

**Keyword Detection Patterns:**
```regex
/(part of me|torn|conflict|versus|vs|sacrificing)/i
/(guilty|ashamed) about (work|family|rest)/i
/should i (choose|pick)/i
```

**Auto-Summon Logic:**
```dart
bool shouldSummonCouncil(String userInput, double tensionScore) {
  // 1. Tension score exceeds threshold
  if (tensionScore > 0.7) return true;

  // 2. User language indicates internal conflict
  final conflictPatterns = [
    RegExp(r'(part of me|torn|conflict|versus|vs|sacrificing)', caseSensitive: false),
    RegExp(r'(guilty|ashamed) about (work|family|rest)', caseSensitive: false),
    RegExp(r'should i (choose|pick)', caseSensitive: false),
  ];

  for (final pattern in conflictPatterns) {
    if (pattern.hasMatch(userInput)) return true;
  }

  return false;
}
```

---

#### Sub-Questions Answered

| # | Question | Answer | Rationale |
|---|----------|--------|-----------|
| 1 | Pipeline position? | **Stage 3 (Post-Safety)** | Safety Gates must remain absolute |
| 2 | Condition parser? | **json_logic_dart** | Standard grammar, safe, expressive |
| 3 | Available triggers? | ContextSnapshot fields (20+ variables) | Full context access |
| 4 | Hard vs Soft? | Hard = BLOCK, Soft = WARN | Matches treaty severity to action |
| 5 | Breach threshold? | **3 breaches in 7 days → Probationary** | Balanced between enforcement and flexibility |
| 6 | Treaty conflicts? | **Hard > Soft, then Newest > Oldest** | Clear priority rules |
| 7 | Expired treaties? | Status = 'expired', no enforcement, retain for history | Clean lifecycle |

---

#### Logic Hooks Grammar (Full Specification)

**Complete Logic Hook Structure:**
```json
{
  "condition": {
    "and": [
      { "==": [{ "var": "day_of_week" }, "tuesday"] },
      { ">=": [{ "var": "hour" }, 18] }
    ]
  },
  "action": {
    "type": "block_and_remind",
    "reminder_text": "This day is protected by your Treaty. The Father needs you home.",
    "severity": "hard"
  }
}
```

**Action Types:**
| Type | Behavior | UI |
|------|----------|-----|
| `block_and_remind` | Stop action, show reminder | Modal with "Honor Treaty" / "Override" |
| `warn` | Allow action, show reminder | Toast with Treaty terms |
| `log_only` | Silent tracking | No UI, logged for analytics |

---

#### Treaties Table Schema

```sql
-- treaties: Core treaty storage
CREATE TABLE treaties (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

  -- Treaty metadata
  title TEXT NOT NULL,                          -- "Tuesday Family Night"
  terms_text TEXT NOT NULL,                     -- Human-readable terms
  facets_involved UUID[] NOT NULL,              -- Array of facet IDs
  status TEXT NOT NULL DEFAULT 'active',        -- 'active', 'probationary', 'suspended', 'expired'

  -- Logic hooks (JSON Logic format)
  logic_hooks JSONB NOT NULL,
  /*
    {
      "condition": { "and": [...] },
      "action": {
        "type": "block_and_remind" | "warn" | "log_only",
        "reminder_text": "...",
        "severity": "hard" | "soft"
      }
    }
  */

  -- Council session reference (optional - treaties can be created ad-hoc)
  council_session_id UUID REFERENCES council_sessions(id),

  -- Breach tracking
  breach_count INT DEFAULT 0,
  last_breach_at TIMESTAMPTZ,
  breach_window_start TIMESTAMPTZ,              -- Rolling 7-day window

  -- Lifecycle
  signed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), -- When treaty was agreed
  expires_at TIMESTAMPTZ,                       -- NULL = never expires
  suspended_at TIMESTAMPTZ,                     -- When suspended (if applicable)

  -- Audit
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for treaty lookup
CREATE INDEX idx_treaties_user_status ON treaties(user_id, status);
CREATE INDEX idx_treaties_facets ON treaties USING GIN(facets_involved);

-- RLS: Users can only see their own treaties
ALTER TABLE treaties ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own treaties" ON treaties
FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own treaties" ON treaties
FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own treaties" ON treaties
FOR UPDATE USING (auth.uid() = user_id);

-- Breach tracking trigger
CREATE OR REPLACE FUNCTION record_treaty_breach() RETURNS TRIGGER AS $$
BEGIN
  -- Reset window if outside 7-day period
  IF NEW.breach_window_start IS NULL OR
     NEW.breach_window_start < NOW() - INTERVAL '7 days' THEN
    NEW.breach_window_start = NOW();
    NEW.breach_count = 1;
  ELSE
    NEW.breach_count = OLD.breach_count + 1;
  END IF;

  NEW.last_breach_at = NOW();

  -- Auto-transition to probationary at 3 breaches
  IF NEW.breach_count >= 3 AND OLD.status = 'active' THEN
    NEW.status = 'probationary';
  END IF;

  -- Auto-suspend at 5 breaches
  IF NEW.breach_count >= 5 THEN
    NEW.status = 'suspended';
    NEW.suspended_at = NOW();
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

**Treaty Dart Model:**
```dart
// lib/domain/models/treaty.dart
@freezed
class Treaty with _$Treaty {
  const factory Treaty({
    required String id,
    required String userId,
    required String title,
    required String termsText,
    required List<String> facetsInvolved,
    required TreatyStatus status,
    required Map<String, dynamic> logicHooks,
    String? councilSessionId,
    required int breachCount,
    DateTime? lastBreachAt,
    required DateTime signedAt,
    DateTime? expiresAt,
    DateTime? suspendedAt,
  }) = _Treaty;

  factory Treaty.fromJson(Map<String, dynamic> json) => _$TreatyFromJson(json);
}

enum TreatyStatus { active, probationary, suspended, expired }
```

---

#### ContextSnapshot Class Definition

```dart
// lib/domain/models/context_snapshot.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'context_snapshot.freezed.dart';
part 'context_snapshot.g.dart';

/// Complete context available to Treaty logic hooks and JITAI decisions.
/// This is the single source of truth for "current state" when making decisions.
@freezed
class ContextSnapshot with _$ContextSnapshot {
  const factory ContextSnapshot({
    // ═══════════════════════════════════════════════════════════
    // TEMPORAL CONTEXT
    // ═══════════════════════════════════════════════════════════
    required String dayOfWeek,        // 'monday', 'tuesday', etc.
    required int hour,                // 0-23
    required int minute,              // 0-59
    required bool isWeekend,          // true if Saturday/Sunday
    required String timeOfDay,        // 'morning', 'afternoon', 'evening', 'night'

    // ═══════════════════════════════════════════════════════════
    // LOCATION CONTEXT
    // ═══════════════════════════════════════════════════════════
    String? locationZone,             // 'home', 'work', 'gym', 'commute', 'other'
    double? distanceFromHomeKm,       // Approximate distance
    bool? isStationary,               // Has user been still for >5min?

    // ═══════════════════════════════════════════════════════════
    // IDENTITY CONTEXT
    // ═══════════════════════════════════════════════════════════
    String? activeFacetId,            // Currently active facet (if any)
    String? activeFacetLabel,         // Human-readable label
    String? previousFacetId,          // Last active facet (for transitions)

    // ═══════════════════════════════════════════════════════════
    // HABIT CONTEXT (when evaluating a specific habit)
    // ═══════════════════════════════════════════════════════════
    String? habitId,                  // Current habit being evaluated
    String? habitName,                // Human-readable name
    String? habitFacetId,             // Facet this habit belongs to
    int? streakDays,                  // Current streak
    double? lastCompletionHoursAgo,   // Hours since last completion

    // ═══════════════════════════════════════════════════════════
    // ENERGY STATE (from RQ-014)
    // ═══════════════════════════════════════════════════════════
    String? energyState,              // 'high_focus', 'low_energy', 'social', 'recovery'
    String? chronotype,               // 'lion', 'bear', 'wolf', 'dolphin'
    bool? isOptimalWindow,            // Is this chronotype's optimal time?

    // ═══════════════════════════════════════════════════════════
    // V-O STATE (Vulnerability-Opportunity)
    // ═══════════════════════════════════════════════════════════
    required double vulnerabilityScore, // 0.0-1.0, higher = more vulnerable
    required double opportunityScore,   // 0.0-1.0, higher = better moment

    // ═══════════════════════════════════════════════════════════
    // CONFLICT DETECTION (for Council AI)
    // ═══════════════════════════════════════════════════════════
    double? tensionScore,             // 0.0-1.0, calculated from conflict signals
    List<String>? conflictingFacetIds, // Facets currently in tension

    // ═══════════════════════════════════════════════════════════
    // CALENDAR CONTEXT (if calendar integration enabled)
    // ═══════════════════════════════════════════════════════════
    bool? hasUpcomingEvent,           // Event in next 30 minutes?
    String? nextEventType,            // 'meeting', 'personal', 'travel', etc.
    int? minutesToNextEvent,          // Minutes until next event
  }) = _ContextSnapshot;

  factory ContextSnapshot.fromJson(Map<String, dynamic> json) =>
      _$ContextSnapshotFromJson(json);
}

extension ContextSnapshotJson on ContextSnapshot {
  /// Convert to Map for JSON Logic evaluation
  Map<String, dynamic> toLogicContext() {
    return {
      'day_of_week': dayOfWeek,
      'hour': hour,
      'minute': minute,
      'is_weekend': isWeekend,
      'time_of_day': timeOfDay,
      'location_zone': locationZone,
      'distance_from_home_km': distanceFromHomeKm,
      'is_stationary': isStationary,
      'active_facet': activeFacetLabel,
      'active_facet_id': activeFacetId,
      'previous_facet_id': previousFacetId,
      'habit_id': habitId,
      'habit_name': habitName,
      'habit_facet_id': habitFacetId,
      'streak_days': streakDays,
      'last_completion_hours_ago': lastCompletionHoursAgo,
      'energy_state': energyState,
      'chronotype': chronotype,
      'is_optimal_window': isOptimalWindow,
      'vulnerability_score': vulnerabilityScore,
      'opportunity_score': opportunityScore,
      'tension_score': tensionScore,
      'conflicting_facet_ids': conflictingFacetIds,
      'has_upcoming_event': hasUpcomingEvent,
      'next_event_type': nextEventType,
      'minutes_to_next_event': minutesToNextEvent,
    };
  }
}
```

**Context Gathering Service:**
```dart
// lib/domain/services/context_service.dart
class ContextService {
  final LocationService _location;
  final CalendarService _calendar;
  final EnergyStateService _energy;
  final FacetService _facets;

  /// Build complete context snapshot for current moment
  Future<ContextSnapshot> captureContext({
    String? habitId,
    String? habitName,
  }) async {
    final now = DateTime.now();
    final location = await _location.getCurrentZone();
    final calendar = await _calendar.getUpcoming();
    final energy = await _energy.getCurrentState();
    final activeFacet = await _facets.getActiveFacet();
    final vo = await _calculateVOState();
    final tension = await _calculateTensionScore();

    return ContextSnapshot(
      dayOfWeek: _dayOfWeek(now),
      hour: now.hour,
      minute: now.minute,
      isWeekend: now.weekday >= 6,
      timeOfDay: _timeOfDay(now.hour),
      locationZone: location?.zone,
      activeFacetId: activeFacet?.id,
      activeFacetLabel: activeFacet?.label,
      habitId: habitId,
      habitName: habitName,
      energyState: energy?.state,
      chronotype: energy?.chronotype,
      vulnerabilityScore: vo.vulnerability,
      opportunityScore: vo.opportunity,
      tensionScore: tension,
      // ... etc
    );
  }
}
```

---

#### Tension Score Calculation (for PD-109)

**Question Answered:** How is `tension_score` calculated for Council AI activation?

**Tension Score Algorithm:**
```dart
/// Calculate tension score from conflict signals
/// Returns 0.0-1.0 where > 0.7 triggers Council AI auto-summon
Future<double> calculateTensionScore(String userId) async {
  double score = 0.0;

  // 1. Facet time imbalance (0-0.3)
  final imbalance = await _calculateFacetImbalance(userId);
  score += imbalance * 0.3;

  // 2. Recent treaty breaches (0-0.2)
  final breaches = await _getRecentBreaches(userId, days: 7);
  score += min(breaches.length / 5, 1.0) * 0.2;

  // 3. Conflicting habit schedules (0-0.2)
  final conflicts = await _detectScheduleConflicts(userId);
  score += min(conflicts.length / 3, 1.0) * 0.2;

  // 4. User-reported stress signals (0-0.3)
  final stressSignals = await _getRecentStressSignals(userId);
  score += stressSignals * 0.3;

  return min(score, 1.0);
}

/// Detect facet time imbalance
/// Returns 0.0 (balanced) to 1.0 (severely imbalanced)
Future<double> _calculateFacetImbalance(String userId) async {
  final facetTimes = await _getFacetTimeAllocation(userId, days: 7);

  if (facetTimes.isEmpty) return 0.0;

  // Calculate coefficient of variation
  final mean = facetTimes.values.reduce((a, b) => a + b) / facetTimes.length;
  final variance = facetTimes.values
      .map((t) => pow(t - mean, 2))
      .reduce((a, b) => a + b) / facetTimes.length;
  final stdDev = sqrt(variance);
  final cv = stdDev / mean;

  // CV > 1.0 indicates severe imbalance
  return min(cv, 1.0);
}
```

**Tension Score Components:**
| Signal | Weight | Source |
|--------|--------|--------|
| Facet time imbalance | 30% | Activity tracking |
| Recent treaty breaches | 20% | Treaty breach_count |
| Conflicting schedules | 20% | Habit scheduling |
| User stress signals | 30% | Check-ins, language analysis |

**Threshold:** `tension_score > 0.7` → Auto-summon Council AI (PD-109)

---

#### Output Delivered

| Deliverable | Status |
|-------------|--------|
| Pipeline position | ✅ Stage 3 (Post-Safety) |
| Logic hook parser | ✅ json_logic_dart |
| TreatyEngine Dart class | ✅ Complete implementation |
| Priority hierarchy | ✅ 5-level stack |
| Breach escalation | ✅ Probationary → Auto-Suspend |
| Council activation rules | ✅ PD-109 finalized (0.7 threshold, 6 turns, keywords) |
| Conflict resolution | ✅ Hard > Soft, Newest > Oldest |
| **Treaties table schema** | ✅ Complete SQL + Dart model |
| **ContextSnapshot class** | ✅ Full Dart implementation |
| **Tension score algorithm** | ✅ Multi-signal calculation |

---

### RQ-021: Treaty Lifecycle & UX

| Field | Value |
|-------|-------|
| **Question** | How should users create, view, modify, and manage Treaties throughout their lifecycle? |
| **Status** | ✅ RESEARCH COMPLETE |
| **Research Date** | 05 January 2026 |
| **Researcher** | Google Deep Think |
| **Priority** | **HIGH** — Core to Council AI value proposition |
| **Blocking** | Treaty creation UI, treaty management screens, template system |
| **Generated By** | RQ-020 (Treaty-JITAI Integration) gap analysis |
| **Decision** | PD-115 ✅ RESOLVED → Templates + Council AI |

---

#### The "Common Law" Principle

80% of habit conflicts are universal (e.g., "Doomscrolling", "Work/Life Balance"). Forcing users to engage a complex AI simulation for simple needs creates "Prompt Fatigue."

**Psychological Hierarchy:**
- **Templates** = "Protocols" (Maintenance)
- **Council** = "Arbitration" (Crisis)

This preserves Council as high-value, novel experience reserved for genuine friction (`tension > 0.7`).

---

#### Treaty Management Screen: "The Constitution"

A dedicated tab in the Profile section (not Settings).

**Visual Metaphor:** A solemn, legalistic dashboard. Dark mode default.

**Sections:**
| Section | Contents |
|---------|----------|
| **Active Laws** | Enforcing Treaties with "Wax Seal" badge |
| **Probation** | Treaties breached 3+ times in 7 days (Pulsing Red Border) |
| **The Archives** | Repealed or Suspended treaties |

**Action:** FAB "Draft New Law" → Opens Wizard

---

#### Treaty Creation Wizard (3 Steps)

**Step 1: The Source**
- *Option A: Standard Protocols (Templates)* – Card grid (Rest, Focus, Health)
- *Option B: Summon Council (AI)* – Only available if `tension > 0.7` OR via "Summon Token"

**Step 2: The Drafting**
- *If Template:* User fills variables (e.g., `Start Time: 21:00`)
- *If Council:* Session UI plays script (Avatars pulse, Audio streams). Sherlock proposes Draft Treaty.

**Step 3: The Ratification (Core Interaction)**
- **The Artifact:** Detailed "Treaty Card" (Terms, Logic Summary, Signatories)
- **The Ritual:** User must **Long-Press (3s)** Fingerprint/Seal icon:
  - *0-1s:* Haptic ticking (Clockwork feel)
  - *1-2s:* Wax melting animation. Haptics intensify.
  - *3s:* Heavy "Thud" sound. Screen flashes gold. "RATIFIED."

---

#### Confirmed Treaty Template Library (Launch Set)

| Template | Logic Hook (JSON Logic) | UX Description |
|----------|-------------------------|----------------|
| **The Sunset Clause** | `{"and": [{"==": [{"var": "category"}, "work"]}, {">=": [{"var": "hour"}, {{time}}]}]}` | **Hard Block** work apps after {{time}} |
| **Deep Work Decree** | `{"and": [{"==": [{"var": "context"}, "deep_work"]}, {"==": [{"var": "type"}, "notification"]}]}` | **Mute** notifications during Deep Work |
| **The Sabbath** | `{"and": [{"==": [{"var": "day"}, "Sun"]}, {"==": [{"var": "metric"}, "streak"]}]}` | **Suppress** streak penalties on Sundays |
| **Transition Airlock** | `{"and": [{"==": [{"var": "prev_ctx"}, "work"]}, {"==": [{"var": "next_ctx"}, "home"]}]}` | **Prompt** a "Decompression Ritual" (5m breathing) |
| **Presence Pact** | `{"and": [{"==": [{"var": "loc"}, "dining"]}, {"==": [{"var": "device"}, "phone"]}]}` | **Nudge** (High Severity) if phone unlocked at dinner |

---

#### Sub-Questions Answered

| # | Question | Answer |
|---|----------|--------|
| 1 | Require Council AI to create? | **No** — Templates for simple, Council for complex |
| 2 | Treaty creation wizard flow? | **3-step:** Source → Drafting → Ratification |
| 3 | Pre-built templates? | **Yes** — 5 templates for launch |
| 4 | View/manage treaties? | **"The Constitution"** tab in Profile |
| 5 | Modify/delete treaties? | Archive to "The Archives" section |
| 6 | Review cadence? | Probation state triggers renegotiation prompt |
| 7 | Share templates? | **Deferred** — Post-launch community feature |

---

#### Output Delivered

| Deliverable | Status |
|-------------|--------|
| Treaty creation flow | ✅ 3-step wizard (Source → Drafting → Ratification) |
| Treaty management screen | ✅ "The Constitution" with Active/Probation/Archives |
| Treaty template library | ✅ 5 templates with JSON Logic |
| Ratification ritual | ✅ 3-second haptic "wax seal" interaction |
| First-time user experience | ✅ Low-stakes "Digital Sunset" on Day 1 |

---

### RQ-022: Council Script Generation Prompts

| Field | Value |
|-------|-------|
| **Question** | What prompt templates should DeepSeek V3.2 use to generate Council AI scripts? |
| **Status** | ✅ RESEARCH COMPLETE |
| **Research Date** | 05 January 2026 |
| **Researcher** | Google Deep Think |
| **Priority** | **HIGH** — Core to Council AI quality |
| **Blocking** | Council AI implementation, facet voice differentiation |
| **Generated By** | RQ-016 (Council AI) + CD-016 (AI Model Strategy) |

---

#### Architecture Summary

| Component | Value |
|-----------|-------|
| **Model** | DeepSeek V3.2 (`deepseek-v3.2-chat`) |
| **Strategy** | "The Audiobook Pattern" — single narrator (Sherlock) |
| **TTS** | Gemini 2.5 Flash TTS (Single Voice) |
| **SSML** | Client-side mapping from `voice_archetype` to prosody tags |

---

#### Confirmed System Prompt Template

```text
### SYSTEM ROLE
You are "The Council Engine," a psychological dramatist simulating a roundtable debate between a user's internal Identity Facets.
Your Narrator is SHERLOCK: Wise, objective, compassionate.

### INPUT CONTEXT
User: {{user_name}}
Conflict: {{conflict_description}}
Facet A: {{facet_a_json}} (Name, Values, Voice Desc, Root Fear)
Facet B: {{facet_b_json}} (Name, Values, Voice Desc, Root Fear)
Resistance (Shadow): {{resistance_root}}
Context Snapshot: {{context_snapshot}}

### GUIDELINES
1. **The Format:** Write a script for a SINGLE narrator (Sherlock).
   - Sherlock narrates body language/tone ("The Builder paces...").
   - Sherlock speaks the dialogue ("'We cannot stop now!'").
2. **The Arc (6 Turns):**
   - Turns 1-2: Thesis (Facet A states urgent need).
   - Turns 3-4: Antithesis (Facet B rebuts with their fear).
   - Turns 5-6: Synthesis (Sherlock proposes the Treaty).
3. **Voice Archetypes:** Assign a `voice_archetype` to each line:
   - `neutral` (Sherlock/Narration)
   - `urgent` (High energy/anxiety)
   - `warm` (Low energy/protective)
   - `shadow` (The Resistance/Fear)
4. **The Treaty:** The final output must include a `proposed_treaty` object.

### EDGE CASES
- **Single Facet:** If only one Facet is active, the antagonist is "The Shadow" (The Resistance Pattern).
- **No Conflict:** Sherlock performs a "State of the Union" reflection instead.

### OUTPUT SCHEMA (Strict JSON)
{
  "script": [
    {
      "speaker_label": "Sherlock",
      "text": "The Builder slams the table, vibrating with anxiety.",
      "voice_archetype": "neutral"
    },
    {
      "speaker_label": "The Builder",
      "text": "'If we sleep now, we lose everything we built!'",
      "voice_archetype": "urgent"
    }
  ],
  "proposed_treaty": {
    "title": "Short Title",
    "terms_text": "One sentence summary.",
    "logic_hooks": {
       "trigger": "context_change",
       "condition": { ...valid_json_logic... },
       "action": "block_category",
       "severity": "hard"
    }
  }
}
```

---

#### Voice Archetype to SSML Mapping

Do NOT ask the LLM to write raw SSML (error-prone). Map `voice_archetype` to prosody tags client-side.

| Archetype | SSML Prosody | Use Case |
|-----------|--------------|----------|
| `neutral` | `<prosody rate="1.0" pitch="0st">` | Sherlock narration |
| `urgent` | `<prosody rate="1.15" pitch="+1st">` | Builder, Athlete (high energy) |
| `warm` | `<prosody rate="0.85" pitch="-2st">` | Father, Partner (protective) |
| `shadow` | `<prosody rate="1.1" pitch="+3st" volume="-1dB">` | Anxiety, Fear voices |

**Dart Implementation:**
```dart
String buildSSML(List<ScriptLine> script) {
  final buffer = StringBuffer('<speak>');
  for (final line in script) {
    final tags = _getTagsForArchetype(line.voiceArchetype);
    buffer.write('$tags${line.text}</prosody><break time="400ms"/>');
  }
  buffer.write('</speak>');
  return buffer.toString();
}
```

---

#### User Context Injection Format

```json
{
  "facet_a": {
    "label": "The Builder",
    "voice_desc": "Clipped, pragmatic, focused on ROI",
    "root_fear": "Irrelevance"
  },
  "facet_b": {
    "label": "The Father",
    "voice_desc": "Slow, warm, protective of time",
    "root_fear": "Regret"
  }
}
```

**Resistance Pattern Injection:**
```json
{
  "root": "Fear of inadequacy",
  "manifestations": [
    {
      "facet": "the_father",
      "script": "If I'm not there for every moment, I'm failing as a father"
    },
    {
      "facet": "the_builder",
      "script": "If I don't seize every opportunity, someone else will"
    }
  ]
}
```

---

#### Sub-Questions Answered

| # | Question | Answer |
|---|----------|--------|
| 1 | Optimal prompt length? | ~1500 tokens input, ~800 tokens output |
| 2 | Inject facet definitions? | JSON objects with label, voice_desc, root_fear |
| 3 | Inject resistance patterns? | JSON with root + per-facet manifestations |
| 4 | Output JSON schema? | `script[]` + `proposed_treaty` object |
| 5 | Voice differentiation? | `voice_archetype` field per line |
| 6 | SSML generation? | Client-side mapping, NOT LLM-generated |
| 7 | Multi-turn handling? | Fixed 6-turn arc structure |
| 8 | Edge case: single facet? | Shadow becomes the antagonist |
| 9 | Edge case: no conflict? | "State of the Union" reflection |

---

#### Output Delivered

| Deliverable | Status |
|-------------|--------|
| System prompt template | ✅ Complete with role, guidelines, edge cases |
| User context injection | ✅ JSON format for facets + resistance |
| JSON output schema | ✅ `script[]` + `proposed_treaty` |
| Voice archetype guidelines | ✅ 4 archetypes (neutral, urgent, warm, shadow) |
| SSML strategy | ✅ Client-side mapping via `SSMLBuilder` |
| Edge case handling | ✅ Single facet, no conflict scenarios |

---

### RQ-023: Population Learning Privacy Framework

| Field | Value |
|-------|-------|
| **Question** | What data can be shared across users for population-level insights, and how do we ensure privacy? |
| **Status** | 🔴 NEEDS RESEARCH |
| **Priority** | **MEDIUM** — Enables cold-start and coaching optimization |
| **Blocking** | Population cluster implementation, cold-start recommendations |
| **Generated By** | RQ-019 (pgvector) population learning pipeline |
| **Assigned** | Legal + technical review required |

**Context:**
RQ-019 specified the population learning infrastructure (cluster embeddings, anonymized patterns), but the **privacy framework** needs formal definition.

**Privacy Hierarchy (Proposed):**
| Data Type | Shareable? | Condition |
|-----------|------------|-----------|
| Raw text (resistance_script, facet labels) | ❌ Never | — |
| Full embeddings (3072-dim) | ❌ Never | — |
| Truncated embeddings (768-dim) | ✅ If opted-in | Anonymized, aggregated only |
| Cluster membership | ✅ If opted-in | No individual identification |
| Aggregate coaching effectiveness | ✅ Always | Statistical only |

**Sub-Questions:**

| # | Question | Implications |
|---|----------|--------------|
| 1 | What's the minimum anonymity set size (k-anonymity)? | Privacy vs utility |
| 2 | Should population learning be opt-in or opt-out? | User control |
| 3 | How do we explain population learning to users? | Transparency |
| 4 | Can truncated embeddings be reverse-engineered? | Security review |
| 5 | What's the data retention policy for population clusters? | GDPR compliance |
| 6 | How do we handle user deletion requests? | Right to be forgotten |

**Output Expected:**
- Privacy policy language for population learning
- Technical safeguards specification
- Opt-in/opt-out UI design
- k-anonymity implementation
- Data deletion procedures

**Depends On:** PD-116 (Population Learning Privacy)

---

### RQ-024: Treaty Modification & Renegotiation Flow

| Field | Value |
|-------|-------|
| **Question** | How should users modify, renegotiate, or terminate active Treaties? |
| **Status** | ✅ COMPLETE |
| **Completed** | 10 January 2026 |
| **Priority** | **HIGH** — Core to treaty lifecycle |
| **Generated By** | RQ-021 gap analysis (sub-question #5 incomplete) |
| **Assigned** | Deep Think session |

**Research Output:** Constitutional Amendment Model with Minor/Major distinction.

**Sub-Questions Answered:**

| # | Question | Answer |
|---|----------|--------|
| 1 | Can users edit active treaties directly? | YES — Minor amendments only (parameters) |
| 2 | Does editing require Council reconvention? | NO for minor; YES for major |
| 3 | What's the Probation → Renegotiation flow? | T+0 → T+96h escalation with Fix/Pause/Repeal options |
| 4 | Can users "pause" a treaty without deleting? | YES — 14-day max, probation timer frozen |
| 5 | What happens to breach history on modification? | PRESERVED on minor; RESET (Amnesty) on major |
| 6 | Can users duplicate/fork existing treaties? | NO — Not in MVP; use templates instead |

**Key Decisions:**

| Decision | Specification |
|----------|---------------|
| **Amendment Classification** | Minor (params) vs Major (logic/parties) |
| **Minor Amendment** | 3s Re-Ratification ceremony, breach history preserved |
| **Major Amendment** | Council reconvene, Amnesty (breach reset), new lineage |
| **Probation Trigger** | 5 breaches in 7 days OR 3 dismissed warnings |
| **Probation Journey** | T+0 notification → T+24h nudge → T+72h warning → T+96h auto-suspend |
| **Pause** | User-initiated, 14-day max, probation frozen |
| **Suspend** | System-initiated (auto at T+96h), requires renegotiation to reactivate |
| **Repeal** | Type "REPEAL" to confirm, treaty archived permanently |

**Schema Additions:**

```sql
-- New table: treaty_history (audit log)
CREATE TABLE treaty_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  treaty_id UUID NOT NULL REFERENCES treaties(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id),
  version INT NOT NULL,
  title TEXT NOT NULL,
  terms_text TEXT NOT NULL,
  logic_hooks JSONB NOT NULL,
  change_type TEXT CHECK (change_type IN ('minor', 'major', 'pause', 'suspend', 'repeal')),
  breach_count_at_log INT,
  change_reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Additions to treaties table
ALTER TABLE treaties
ADD COLUMN version INT DEFAULT 1,
ADD COLUMN parent_treaty_id UUID REFERENCES treaties(id),
ADD COLUMN last_amended_at TIMESTAMPTZ;
```

**Reconciliation:** See `docs/analysis/DEEP_THINK_RECONCILIATION_RQ024.md`

**Tasks Extracted:** A-11, A-12, B-16, B-17, C-13, D-11, D-12, D-13, D-14 (9 tasks)

**Depends On:** RQ-021 ✅ COMPLETE, PD-115 ✅ RESOLVED

---

### RQ-025: Summon Token Economy

| Field | Value |
|-------|-------|
| **Question** | How should the Summon Token gamification mechanic work? |
| **Status** | 🔴 NEEDS RESEARCH |
| **Priority** | **MEDIUM** — Enhancement to Council access |
| **Blocking** | Gamification system, Council access UX |
| **Generated By** | RQ-021 ("Summon Token" mentioned but not specified) |
| **Assigned** | Gamification design session |

**Context:**
RQ-021 mentions "Summon Token" as a mechanism to access Council AI when tension_score < 0.7, but doesn't specify the economy:
- How are tokens earned?
- What's the cost to summon?
- Is there a cap?

**Sub-Questions:**

| # | Question | Implications |
|---|----------|--------------|
| 1 | How are Summon Tokens earned? | Behavior incentives |
| 2 | What's the "cost" to summon Council? | Token depletion rate |
| 3 | Is there a token cap? | Inflation control |
| 4 | Can tokens be purchased? | Monetization |
| 5 | Do tokens expire? | Urgency vs hoarding |
| 6 | Are tokens visible in UI? | Gamification salience |

**Proposed Earning Mechanisms:**

| Action | Tokens Earned | Rationale |
|--------|---------------|-----------|
| Complete habit streak (7 days) | +1 | Reward consistency |
| Successfully resolve Council treaty | +1 | Reward engagement |
| Refer a friend | +2 | Growth mechanic |
| Watch educational content | +1 | Engagement depth |
| Premium subscription | +3/month | Monetization |

**Output Expected:**
- Token economy specification
- Earning/spending rules
- UI placement for token display
- Anti-gaming safeguards

**Depends On:** RQ-021 ✅ COMPLETE

---

### RQ-026: Sound Design & Haptic Specification

| Field | Value |
|-------|-------|
| **Question** | What are the exact sound and haptic requirements for Ratification Ritual and Council sessions? |
| **Status** | 🔴 NEEDS RESEARCH |
| **Priority** | **MEDIUM** — Polish layer |
| **Blocking** | Audio asset pipeline, haptic implementation |
| **Generated By** | RQ-021 (Ratification mentions "heavy thud", "clockwork ticking") |
| **Assigned** | Sound design + UX session |

**Context:**
RQ-021 mentions specific audio/haptic cues for the Ratification Ritual:
- "Haptic ticking (Clockwork feel)"
- "Wax melting animation" (visual)
- "Heavy thud sound"
- "Screen flashes gold"

These need formal specification for implementation.

**Sub-Questions:**

| # | Question | Implications |
|---|----------|--------------|
| 1 | What's the exact haptic pattern for 0-3s timeline? | iOS/Android compatibility |
| 2 | What audio file format and duration? | Asset pipeline |
| 3 | Should sounds be customizable? | User preference |
| 4 | What's the audio for Council sessions? | Background ambiance |
| 5 | How do we handle silent mode? | Fallback to visuals only |
| 6 | Licensing for "wax seal" sound? | Legal |

**Ratification Sound Timeline (Proposed):**

| Time | Haptic | Sound | Visual |
|------|--------|-------|--------|
| 0-1s | Light taps (10Hz) | Soft ticking (clockwork) | Fingerprint icon glows |
| 1-2s | Medium vibration | Ticking intensifies | Wax begins melting |
| 2-3s | Strong pulse | Wax sizzle | Wax drips onto seal |
| 3s | Heavy thud (100ms) | Deep "stamp" sound | Flash gold → "RATIFIED" |

**Output Expected:**
- Haptic pattern specifications (iOS + Android)
- Audio asset list with durations
- Fallback behavior for silent mode
- Asset sourcing recommendations

**Depends On:** RQ-021 ✅ COMPLETE

---

### RQ-027: Treaty Template Versioning Strategy

| Field | Value |
|-------|-------|
| **Question** | How should we handle updates to treaty templates after launch? |
| **Status** | 🔴 NEEDS RESEARCH |
| **Priority** | **LOW** — Post-launch concern |
| **Blocking** | Template update pipeline |
| **Generated By** | RQ-021 (5 templates at launch, will evolve) |
| **Assigned** | Engineering session |

**Context:**
We launch with 5 treaty templates. Over time we'll want to:
- Add new templates
- Fix bugs in existing template logic
- Improve template UX

What happens to users who already activated old templates?

**Sub-Questions:**

| # | Question | Implications |
|---|----------|--------------|
| 1 | Do active treaties auto-update with template fixes? | Breaking changes risk |
| 2 | How do we notify users of template updates? | Communication |
| 3 | Can users "upgrade" to new template version? | Migration UX |
| 4 | Should templates be immutable once activated? | Simplicity vs flexibility |
| 5 | How do we deprecate templates? | Sunset strategy |

**Proposed Strategy:**

| Approach | Description | When to Use |
|----------|-------------|-------------|
| **Immutable** | Active treaties never change | Default behavior |
| **Soft Update** | UI/messaging changes, logic unchanged | Cosmetic fixes |
| **Migration Prompt** | User notified, can choose to upgrade | Logic fixes |
| **Force Migration** | All treaties updated automatically | Security patches |

**Output Expected:**
- Versioning strategy recommendation
- Migration UX (if needed)
- Template deprecation policy
- Schema changes for version tracking

**Depends On:** RQ-021 ✅ COMPLETE, Treaty implementation

---

### RQ-028: Archetype Template Definitions & Content Strategy

| Field | Value |
|-------|-------|
| **Question** | What are the precise definitions, embeddings, and content libraries for each of the 12 Archetype Templates? |
| **Status** | ✅ COMPLETE |
| **Priority** | **CRITICAL** — Blocks F-06, F-13, F-14, content creation pipeline |
| **Completed** | 10 January 2026 (Deep Think Reconciliation) |
| **Reconciliation** | `docs/analysis/DEEP_THINK_RECONCILIATION_RQ028_RQ029_RQ030_RQ031_RQ032.md` |

**Key Findings:**

1. **12 Global Archetypes Confirmed** — Psychologically grounded in Self-Determination Theory and Big Five/Pearson models
2. **6-Dim Vectors Defined** — Each archetype has a complete `[Reg, Auto, Action, Temp, Perf, Rhythm]` vector
3. **Cosine Similarity Matching** — Facet names matched via nearest neighbor
4. **Fallback Strategy** — If similarity < 0.65, default to Builder (configurable) with "flagForReview"
5. **User Override** — Users can manually change archetype in Settings

**The 12 Archetypes:**

| Archetype | Core Drive | Dimension Vector |
|-----------|------------|------------------|
| The Builder | Achievement | `[0.9, 0.2, 0.8, 0.9, 0.4, 0.3]` |
| The Nurturer | Connection | `[-0.6, -0.4, 0.2, 0.4, 0.3, 0.7]` |
| The Warrior | Discipline | `[0.8, 0.5, 0.9, 0.6, 0.7, 0.5]` |
| The Scholar | Mastery | `[0.3, 0.4, -0.5, 0.9, 0.7, 0.2]` |
| The Healer | Balance | `[-0.5, -0.2, 0.1, 0.6, 0.2, 0.8]` |
| The Creator | Expression | `[0.7, 0.9, 0.4, 0.3, 0.5, -0.4]` |
| The Guardian | Stability | `[-0.9, -0.7, 0.5, 0.7, 0.4, 0.9]` |
| The Explorer | Novelty | `[0.9, 0.8, 0.6, -0.3, -0.2, -0.5]` |
| The Sage | Wisdom | `[0.1, 0.3, -0.8, 0.8, 0.5, 0.4]` |
| The Leader | Influence | `[0.6, 0.1, 0.7, 0.6, 0.5, 0.8]` |
| The Devotee | Faith | `[-0.3, -0.6, 0.2, 0.5, 0.3, 1.0]` |
| The Rebel | Liberation | `[0.5, 1.0, 0.8, -0.6, -0.4, -0.7]` |

**Schema Delivered:**
```sql
CREATE TABLE archetype_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  description TEXT NOT NULL,
  dimension_vector FLOAT[] NOT NULL CHECK (array_length(dimension_vector, 1) = 6),
  embedding VECTOR(768),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Sub-Questions Answered:**

| # | Question | Answer |
|---|----------|--------|
| 1 | Psychological definitions? | ✅ Based on SDT + Big Five |
| 2 | 768-dim embeddings? | ✅ Auto-generated from descriptions |
| 3 | 6-dim vectors? | ✅ Provided for all 12 |
| 4 | Validation strategy? | ✅ Configurable threshold + flagForReview |
| 5 | User override? | ✅ Yes, in Settings |
| 6 | Edge cases? | ✅ Default to Builder, flag for review |

**Depends On:** RQ-005 ✅ COMPLETE, RQ-006 ✅ COMPLETE

---

### RQ-029: Ideal Dimension Vector Curation Process

| Field | Value |
|-------|-------|
| **Question** | How do we systematically assign ideal_dimension_vectors to the 50+ habit templates? |
| **Status** | ✅ COMPLETE |
| **Priority** | HIGH — Blocks psychometric re-ranking accuracy |
| **Completed** | 10 January 2026 (Deep Think Reconciliation) |
| **Reconciliation** | `docs/analysis/DEEP_THINK_RECONCILIATION_RQ028_RQ029_RQ030_RQ031_RQ032.md` |

**Key Findings:**

1. **Hybrid Workflow** — DeepSeek V3.2 generates draft vectors; humans audit
2. **Batch Process** — Generate → CSV → Expert Audit → Ingest
3. **Multi-Polar Handling** — Neutralize (score = 0.0) if habit is both poles

**DeepSeek Prompt (System):**
```text
Role: Psychometrician.
Task: Map habit to 6 dimensions (-1.0 to 1.0).
Input: "[Habit Title]" ([Description]).
Dimensions: [Regulatory, Autonomy, Action, Temporal, Perfectionism, Rhythmicity]

OUTPUT JSON: {
  "vector": [0.2, 0.8, -0.4, -0.2, 0.0, -0.3],
  "rationale": "High Rebel (Autonomy) due to free-form nature."
}
```

**Sub-Questions Answered:**

| # | Question | Answer |
|---|----------|--------|
| 1 | LLM-assisted derivation? | ✅ DeepSeek V3.2 with audit |
| 2 | Validation process? | ✅ Human expert review |
| 3 | Population learning? | Deferred (future RQ) |
| 4 | Multi-polar habits? | ✅ Neutralize to 0.0 |
| 5 | Curator format? | ✅ JSON with rationale |

**Depends On:** RQ-005 ✅ COMPLETE, CD-005 (6-dimension model)

---

### RQ-030: Preference Embedding Update Mechanics

| Field | Value |
|-------|-------|
| **Question** | How exactly does the preference embedding get updated, and what are the behavioral implications? |
| **Status** | ✅ COMPLETE |
| **Priority** | MEDIUM — Affects long-term personalization quality |
| **Completed** | 10 January 2026 (Deep Think Reconciliation) |
| **Reconciliation** | `docs/analysis/DEEP_THINK_RECONCILIATION_RQ028_RQ029_RQ030_RQ031_RQ032.md` |

**Key Findings:**

1. **Rocchio Algorithm with Trinity Anchor** — Industry-standard approach with drift prevention
2. **Alpha Values:** Ban = 0.15 (strong negative), Adopt = 0.05 (weak positive)
3. **Anchor Weight:** 30% pull towards Day 1 Trinity Seed
4. **User Visibility:** NO — 768-dim vectors are noise to users (PD-122 RESOLVED)

**Algorithm (Dart):**
```dart
List<double> updatePreference(List<double> current, List<double> habitVec, Action action) {
  // 1. Learning Step (Rocchio)
  double weight = (action == Action.ban) ? -0.15 : 0.05;
  List<double> learnt = vectorAdd(current, vectorScale(habitVec, weight));

  // 2. Anchoring Step (Drift Prevention)
  List<double> anchored = vectorAdd(
      vectorScale(learnt, 0.7),
      vectorScale(trinitySeed, 0.3)
  );
  return vectorNormalize(anchored);
}
```

**Schema Delivered:**
```sql
CREATE TABLE preference_embeddings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  embedding VECTOR(768),
  trinity_seed VECTOR(768), -- Fixed anchor from Onboarding
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Sub-Questions Answered:**

| # | Question | Answer |
|---|----------|--------|
| 1 | α for ban? | ✅ 0.15 (configurable) |
| 2 | Drift prevention? | ✅ 30% Trinity Seed anchor |
| 3 | User visibility? | ✅ NO (PD-122 resolved) |
| 4 | Recompute frequency? | ✅ Every feedback signal |
| 5 | Trinity Seed interaction? | ✅ 30% anchor weight |
| 6 | Reset mechanism? | Future feature (not blocking) |

**Depends On:** RQ-005 ✅ COMPLETE

---

### RQ-031: Pace Car Threshold Validation

| Field | Value |
|-------|-------|
| **Question** | Is 1 recommendation/day and 5-habit threshold optimal, or should these be dynamic? |
| **Status** | ✅ COMPLETE |
| **Priority** | MEDIUM — UX quality, cognitive load |
| **Completed** | 10 January 2026 (Deep Think Reconciliation) |
| **Reconciliation** | `docs/analysis/DEEP_THINK_RECONCILIATION_RQ028_RQ029_RQ030_RQ031_RQ032.md` |

**Key Findings:**

1. **Dynamic Capacity Model** — Based on Cognitive Load, not fixed habit count
2. **Building vs Maintenance** — `graceful_score < 0.8` = Building (effortful)
3. **Thresholds:**
   - Seed users (ICS < 1.2): Max **3** Building habits
   - Sapling/Oak users: Max **5** Building habits
   - Maintenance habits: **Unlimited**

**Logic:**
```dart
bool shouldShowRecommendation(User user) {
  int buildingCount = user.habits.where((h) => h.gracefulScore < 0.8).length;
  int cap = (user.icsScore < 1.2) ? 3 : 5;
  return buildingCount < cap;
}
```

**Sub-Questions Answered:**

| # | Question | Answer |
|---|----------|--------|
| 1 | Adapt to engagement? | ✅ Yes, via ICS tiers |
| 2 | 5 habits threshold? | ✅ Refined: Building vs Maintenance |
| 3 | Multi-facet users? | Applies per-facet |
| 4 | On-demand requests? | ✅ User can browse explicitly |
| 5 | New user velocity? | ✅ Conservative (cap 3 Building) |

**Depends On:** RQ-005 ✅ COMPLETE

---

### RQ-032: ICS Integration with Existing Metrics

| Field | Value |
|-------|-------|
| **Question** | How does Identity Consolidation Score (ICS) integrate with existing hexis_score and graceful_score? |
| **Status** | ✅ COMPLETE |
| **Priority** | HIGH — Prevents metric fragmentation |
| **Completed** | 10 January 2026 (Deep Think Reconciliation) |
| **Reconciliation** | `docs/analysis/DEEP_THINK_RECONCILIATION_RQ028_RQ029_RQ030_RQ031_RQ032.md` |

**Key Findings:**

1. **hexis_score Audit:** Not implemented in code — documentation-only term. Safe to deprecate.
2. **graceful_score:** Keep — active in JITAI and Pace Car
3. **ICS is the Master Metric:** Logarithmic scale rewards longevity

**ICS Formula:**
```
ICS_facet = AvgConsistency_facet × log10(TotalVotes_facet + 1)
```

- **AvgConsistency:** Average `graceful_score` of active habits for facet
- **TotalVotes:** Cumulative habit completions for facet
- **log10:** Prevents runaway scores; rewards longevity over volume

**Visual Tiers:**

| Tier | ICS Range | Approx Votes | UI Representation |
|------|-----------|--------------|-------------------|
| Seed | < 1.2 | ~15 | Sprout icon |
| Sapling | 1.2 – 3.0 | 15-100 | Small tree |
| Oak | ≥ 3.0 | 100+ | Full tree |

**Metric Consolidation:**

| Metric | Status | Role |
|--------|--------|------|
| hexis_score | ❌ DEPRECATED | Never implemented |
| graceful_score | ✅ KEEP | Component of ICS |
| ICS | ✅ NEW | Master facet metric |

**Sub-Questions Answered:**

| # | Question | Answer |
|---|----------|--------|
| 1 | hexis_score? | ✅ Audit: Not in code. Deprecate. |
| 2 | Replace or coexist? | ✅ ICS replaces hexis_score |
| 3 | Votes definition? | ✅ Cumulative habit completions |
| 4 | Consistency calc? | ✅ Avg graceful_score |
| 5 | ICS scope? | ✅ Per-facet |
| 6 | Display? | ✅ Seed/Sapling/Oak tiers |

**Depends On:** RQ-007 ✅ COMPLETE

---

### RQ-033: Streak Philosophy & Gamification

| Field | Value |
|-------|-------|
| **Question** | Should The Pact use streak counts or rolling consistency metrics? How should gamification align with habit psychology? |
| **Status** | 🔴 NEEDS RESEARCH |
| **Priority** | HIGH — Philosophical tension between code and messaging |
| **Blocking** | PD-002 (Streaks vs Rolling Consistency) |

**Context:**
- Codebase uses streaks heavily (`currentStreak`, `longestStreak` properties)
- Messaging says "streaks are vanity metrics"
- This tension needs resolution before gamification features

**Sub-Questions:**
1. What does habit psychology research say about streak vs consistency metrics?
2. Do streaks help or harm long-term habit formation?
3. How can we gamify without creating streak anxiety?
4. Should we track both but display one?
5. What does "Graceful Consistency" philosophy mean for gamification?

**Code References:**
- `lib/data/services/consistency_service.dart` — Implements "Graceful Consistency"
- `lib/data/models/habit.dart` — `currentStreak`, `longestStreak` properties

---

### RQ-034: Sherlock Conversation Architecture

| Field | Value |
|-------|-------|
| **Question** | What is the optimal structure for the Sherlock onboarding conversation? |
| **Status** | 🔴 NEEDS RESEARCH |
| **Priority** | HIGH — Core onboarding experience |
| **Blocking** | PD-101 (Sherlock Prompt Overhaul) |
| **Depends On** | RQ-037 (Holy Trinity Validation) |

**Context:**
- Current Sherlock prompt is simplistic with no turn limit or success criteria
- Quality of extracted Holy Trinity (Anti-Identity, Archetype, Resistance Lie) is uncertain
- Need structured conversation design for better extraction

**Sub-Questions:**
1. How many conversation turns are optimal for personality extraction?
2. What success criteria should trigger conversation completion?
3. How to balance natural conversation with data extraction?
4. What fallback strategies if extraction quality is low?
5. How to handle users who give minimal responses?

**Code References:**
- `lib/config/ai_prompts.dart:717-745` — Main Sherlock prompt
- `lib/data/services/ai/prompt_factory.dart:47-67` — `_sherlockPrompt` constant

---

### RQ-035: Sensitivity Detection Framework

| Field | Value |
|-------|-------|
| **Question** | How should The Pact detect and handle sensitive goals (addiction, trauma, private issues)? |
| **Status** | 🔴 NEEDS RESEARCH |
| **Priority** | HIGH — User safety and privacy |
| **Blocking** | PD-103 (Sensitivity Detection) |

**Context:**
- No sensitivity detection logic exists in current codebase
- All habits treated equally regardless of sensitivity
- Witness invites shown to all users (potential privacy issue)

**Sub-Questions:**
1. What categories of goals should be flagged as sensitive?
2. How to detect sensitivity without invasive keyword lists?
3. What privacy protections should apply to sensitive habits?
4. Should sensitive habits have different witness rules?
5. How to handle AI coaching for addiction/trauma goals safely?
6. What demographic/contextual signals inform sensitivity?

**Privacy Considerations:**
- Must be privacy-preserving (no external data sharing)
- User should be able to override sensitivity classification
- Sensitive data should have stricter RLS policies

---

### RQ-036: Chamber Visual Design Patterns

| Field | Value |
|-------|-------|
| **Question** | What visual design and interaction patterns should "The Chamber" (Council session UI) use? |
| **Status** | 🔴 NEEDS RESEARCH |
| **Priority** | MEDIUM — Core to Council AI experience |
| **Blocking** | PD-120 (The Chamber Visual Design) |
| **Depends On** | RQ-016 ✅ COMPLETE (Council AI) |

**Context:**
- Deep Think specified "The Chamber" as dark mode overlay with pulsing avatars
- No detailed visual specifications provided
- Key UX moment — where identities negotiate treaties

**Sub-Questions:**
1. How should facet avatars appear? (Generated? User-uploaded? Archetypal icons?)
2. How does "pulsing" indicate speaking? (Glow? Scale? Border animation?)
3. What visual hierarchy shows which facet is speaking?
4. How to represent AI-generated dialogue vs user-written content?
5. What dark UI patterns work best for psychological depth?
6. How to make negotiations feel dramatic without being stressful?

**Design References:**
- Dark UI patterns from meditation apps (Headspace, Calm)
- Character dialogue systems in games (Persona, Disco Elysium)
- Council/voting UIs in strategy games

---

### RQ-037: Holy Trinity Model Validation

| Field | Value |
|-------|-------|
| **Question** | Is the 3-trait model (Anti-Identity, Archetype, Resistance Lie) sufficient for personality capture? |
| **Status** | 🔴 NEEDS RESEARCH |
| **Priority** | HIGH — Core to personalization strategy |
| **Blocking** | PD-003 (Holy Trinity Validity) |

**Context:**
- Holy Trinity implemented but extraction quality is uncertain
- Model guides Sherlock prompts and coaching personalization
- Need validation before building more on this foundation

**Sub-Questions:**
1. Does research support a 3-trait model for habit psychology?
2. Are Anti-Identity, Archetype, Resistance Lie the right 3 traits?
3. How do we measure extraction quality?
4. What validation metrics prove the model is working?
5. Should traits be revised based on empirical usage data?
6. How does this relate to Big Five, SDT, or other validated models?

**Code References:**
- `lib/domain/entities/psychometric_profile.dart:17-29` — Holy Trinity fields
- `lib/data/services/ai/prompt_factory.dart:119-170` — Usage in prompts

---

### RQ-038: JITAI Component Allocation Strategy

| Field | Value |
|-------|-------|
| **Question** | Which JITAI components should be hardcoded vs AI-learned? |
| **Status** | 🔴 NEEDS RESEARCH |
| **Priority** | MEDIUM — Affects intervention effectiveness |
| **Blocking** | PD-102 (JITAI Hardcoded vs AI) |

**Context:**
- Current JITAI is hybrid — hardcoded weights with Thompson Sampling
- Question is optimal balance between determinism and adaptability
- CD-016 (DeepSeek V3.2) provides AI capability but doesn't specify usage

**Sub-Questions:**
1. What does JITAI research say about hardcoded vs learned components?
2. Which decisions need consistency (hardcoded)?
3. Which decisions benefit from personalization (learned)?
4. How much training data is needed before learned components are reliable?
5. What's the cold-start strategy for new users?
6. How do Thompson Sampling and population learning interact?

**Code References:**
- `lib/domain/services/jitai_decision_engine.dart` — Main orchestrator
- `lib/domain/services/hierarchical_bandit.dart` — Thompson Sampling
- `lib/domain/services/population_learning.dart` — Cross-user learning

---

### RQ-040: AI Orchestration Architecture Strategy

| Field | Value |
|-------|-------|
| **Question** | Should we formalize current AI orchestration with MCP/A2A standards, and what's the optimal timing? |
| **Status** | 🔴 NEEDS RESEARCH |
| **Priority** | MEDIUM — Strategic positioning for 2026+ ecosystem |
| **Blocking** | Future Council AI implementation, Protocol 9 automation |
| **Created** | 12 January 2026 |
| **Trigger** | Codebase audit revealed sophisticated orchestration that could be formalized |

**Context:**
- Current implementation: 3-tier routing (DeepSeek/Gemini Flash/Gemini Pro) with failover chain
- AIServiceManager already follows "Host-to-Server" pattern that MCP standardizes
- MCP focuses on agent-to-tool communication (your current architecture)
- A2A focuses on agent-to-agent communication (your Council AI vision)
- Official Dart/Flutter MCP support exists but is "experimental"

**Current Architecture Assessment:**
| Component | Status | Notes |
|-----------|--------|-------|
| Multi-model routing | ✅ Complete | `AIServiceManager.selectProvider()` |
| Failover chain | ✅ Complete | Tier 3 → 2 → 1 → Manual |
| Kill switches | ✅ Complete | 4 switches via `AIModelConfig` |
| Voice integration | ✅ Complete | WebSocket + native audio |
| Protocol 9 automation | ❌ Manual | 6-phase checklist exists, no code |
| Council AI | ❌ Not built | Documented but unimplemented |

**Protocol 10 Bias Analysis (12 Jan 2026):**

| # | Assumption | Validity | Basis |
|---|------------|----------|-------|
| 1 | Current architecture is functional | **HIGH** | Codebase audit confirmed 85% complete |
| 2 | MCP Dart SDK is experimental | **HIGH** | Official Flutter docs state SDK requirements |
| 3 | A2A has no Dart SDK | **HIGH** | Only Python SDK available on GitHub |
| 4 | Pre-launch speed > architecture purity | **MEDIUM** | Industry consensus, not product-validated |
| 5 | Council AI can wait for post-launch | **MEDIUM** | CD-008 says Identity Coach is critical |
| 6 | MCP ecosystem stable by Q2 2026 | **LOW** | Trajectory prediction, no guarantee |
| 7 | A2A Dart SDK will emerge | **LOW** | Speculation based on Google Flutter investment |
| 8 | Enterprise sales require MCP | **LOW** | Gartner estimate, not validated data |

**Confidence:** MEDIUM (3 LOW-validity assumptions)
**Decision:** PROCEED with research (Protocol 12 not triggered)

**Pre-Launch vs Post-Launch Analysis:**

| Aspect | Pre-Launch Relevance | Post-Launch Relevance |
|--------|---------------------|----------------------|
| MCP Migration | 🔴 Delays launch 2-4 weeks | 🟢 Enables ecosystem integrations |
| A2A/Council AI | 🔴 No Dart SDK available | 🟢 Core differentiator |
| Kill Switch Enhancement | 🟢 **DO NOW** — low effort | 🟢 Continued value |
| Protocol 9 Automation | 🟢 **DO NOW** — agent efficiency | 🟢 Continued value |

**Ramifications:**
- Pre-launch MCP: Would delay launch 2-4 weeks for uncertain benefit
- Post-launch MCP: Enables Claude Desktop, VS Code, Cursor integrations
- Pre-launch A2A: Impossible (no Dart SDK)
- Post-launch A2A: Enables Parliament of Selves vision
- Risk if delayed too long: Miss ecosystem integrations, enterprise sales friction

**Sub-Questions:**

#### RQ-040a: MCP Formalization Requirements
| Field | Value |
|-------|-------|
| **Question** | What would it take to convert AIServiceManager to MCP standard? |
| **Status** | 🔴 NEEDS RESEARCH |
| **Priority** | MEDIUM |
| **Pre-Launch Relevance** | 🟡 LOW — delays launch |
| **Post-Launch Relevance** | 🟢 HIGH — enables ecosystem |
| **Scope** | Technical requirements, dart_mcp compatibility, breaking changes |
| **Timeline** | Research Q2 2026 |

Research Areas:
- Dart SDK 3.9+ / Flutter 3.35+ requirements
- dart_mcp package maturity assessment
- WebSocket transport for GeminiLiveService
- Breaking changes to existing integrations
- Effort vs benefit analysis (estimated 2-3 weeks)

#### RQ-040b: A2A Protocol for Council AI
| Field | Value |
|-------|-------|
| **Question** | How should A2A (Agent2Agent) inform Council AI architecture? |
| **Status** | 🔴 NEEDS RESEARCH |
| **Priority** | HIGH — Core to psyOS vision |
| **Pre-Launch Relevance** | 🔴 NONE — no Dart SDK |
| **Post-Launch Relevance** | 🟢 **CRITICAL** — core differentiator |
| **Scope** | Multi-agent collaboration patterns for Parliament of Selves |
| **Timeline** | Research when Dart SDK available (or via Edge Functions bridge) |

Research Areas:
- A2A Agent Card specification for facet agents
- How facets would "negotiate" via A2A protocol
- Integration with MCP tool access
- No Dart SDK yet — timing implications
- Supabase Edge Functions as A2A bridge option

#### RQ-040c: Kill Switch & Failover Enhancement
| Field | Value |
|-------|-------|
| **Question** | Should current kill switch/failover be documented as part of CD-016? |
| **Status** | 🔴 NEEDS RESEARCH |
| **Priority** | MEDIUM |
| **Pre-Launch Relevance** | 🟢 **HIGH** — low effort, high resilience |
| **Post-Launch Relevance** | 🟢 HIGH — continued value |
| **Scope** | Documentation, remote config patterns, monitoring |
| **Timeline** | **DO NOW** (0.5 days effort) |

Research Areas:
- Current implementation audit (4 switches exist, verified)
- Remote config integration patterns
- Monitoring/alerting requirements
- Should this become a CD or remain implementation detail?

#### RQ-040d: Protocol 9 Automation Feasibility
| Field | Value |
|-------|-------|
| **Question** | Can Protocol 9 (External Research Reconciliation) be automated? |
| **Status** | 🔴 NEEDS RESEARCH |
| **Priority** | HIGH — Agent session efficiency |
| **Pre-Launch Relevance** | 🟢 **HIGH** — affects every Claude session |
| **Post-Launch Relevance** | 🟢 HIGH — continued value |
| **Scope** | Automation feasibility, tool design, integration with docs |
| **Timeline** | **DO NOW** (0.5-2 days effort) |

Research Areas:
- Parse external AI research outputs
- Check against locked CDs automatically
- Generate ACCEPT/MODIFY/REJECT/ESCALATE classifications
- Create reconciliation documents programmatically
- Implementation options:
  1. Pre-commit hook (0.5 days) — **RECOMMENDED START**
  2. Claude Skill `/reconcile` (1-2 days)
  3. MCP tool (3-5 days) — only if MCP adopted

#### RQ-040e: Migration Timing & Risk Assessment
| Field | Value |
|-------|-------|
| **Question** | What's the optimal timing for any orchestration changes? |
| **Status** | 🔴 NEEDS RESEARCH |
| **Priority** | MEDIUM |
| **Pre-Launch Relevance** | 🟡 MEDIUM — decision point |
| **Post-Launch Relevance** | 🟢 HIGH — quarterly re-evaluation |
| **Scope** | Ecosystem maturity, risk analysis, phasing |
| **Timeline** | Monitor quarterly |

Research Areas:
- MCP ecosystem maturity timeline (experimental → stable)
- A2A Dart SDK availability timeline
- Risk of early adoption vs late adoption
- Phased migration approach if warranted
- Industry predictions (Gartner: 75% API gateway MCP by 2026)

**Recommendation Based on Deep Analysis (MEDIUM Confidence):**

| Phase | Timeframe | Action | Effort |
|-------|-----------|--------|--------|
| **0** | NOW | Document current as "MCP-ready" | 1 day |
| **1** | Pre-Launch | Keep current, ship product | 0 |
| **2** | Launch+3mo | Re-evaluate MCP Dart SDK stability | 1 day |
| **3** | Launch+6mo | Implement MCP IF triggers met | 2-3 weeks |
| **4** | Launch+12mo | Implement A2A/Council AI | 3-4 weeks |

**Decision Triggers for MCP Adoption:**
- User/Customer requests Claude/Cursor integration
- B2B partner requires MCP compliance
- Dart MCP SDK marked "stable" (not experimental)
- MCP Registry reaches GA
- Competitor launches MCP-enabled features

**Immediate Actions (Pre-Launch):**
1. ✅ RQ-040c: Document kill switches in CD-016 (0.5 days)
2. ✅ RQ-040d: Implement Protocol 9 pre-commit hook (0.5 days)

**References:**
- [MCP Specification 2025-11-25](https://modelcontextprotocol.io/specification/2025-11-25)
- [One Year of MCP - Anniversary Blog](https://blog.modelcontextprotocol.io/posts/2025-11-25-first-mcp-anniversary/)
- [Dart MCP Server Docs](https://docs.flutter.dev/ai/mcp-server)
- [A2A Protocol Specification](https://a2a-protocol.org/latest/specification/)
- [Google A2A Announcement](https://developers.googleblog.com/en/a2a-a-new-era-of-agent-interoperability/)
- [MCP vs A2A Guide](https://auth0.com/blog/mcp-vs-a2a/)
- [Agentic MCP and A2A Architecture](https://medium.com/@anil.jain.baba/agentic-mcp-and-a2a-architecture-a-comprehensive-guide-0ddf4359e152)
- [Technical Debt in AI MVP Development](https://medium.com/@adnanmasood/rewriting-the-technical-debt-curve-how-generative-ai-vibe-coding-and-ai-driven-sdlc-transform-03129e81a25e)

---

## Implementation Tasks from Research

**Purpose:** Track actionable items generated by completed research.

**Process:**
1. When research generates actionable items → Log here
2. Tasks organized by psyOS Implementation Phase
3. If needs decision first → Create PD in PRODUCT_DECISIONS.md

**Rule:** Nothing gets lost. Every actionable item ends up here with clear source traceability.

---

### Master Implementation Tracker

**Legend:**
- 🔴 NOT STARTED | 🟡 IN PROGRESS | ✅ COMPLETE
- Priority: **CRITICAL** → HIGH → MEDIUM → LOW
- Source: RQ/PD/CD that generated this task

---

### Phase A: Schema Foundation

| # | Task | Priority | Status | Source | Component | AI Model |
|---|------|----------|--------|--------|-----------|----------|
| A-01 | Enable pgvector extension (Supabase) | **CRITICAL** | 🔴 NOT STARTED | RQ-019 | Database | N/A |
| A-02 | Create `psychometric_roots` table with `root_embedding VECTOR(3072)` | **CRITICAL** | 🔴 NOT STARTED | RQ-012, RQ-019 | Database | N/A |
| A-03 | Create `psychological_manifestations` table with `resistance_embedding VECTOR(3072)` | **CRITICAL** | 🔴 NOT STARTED | RQ-012, RQ-019 | Database | N/A |
| A-04 | Create HNSW indexes for both embedding tables (m=16, ef_construction=64) | **CRITICAL** | 🔴 NOT STARTED | RQ-019 | Database | N/A |
| A-05 | Create `treaties` table with `logic_hooks` JSONB, `origin`, `status`, `breach_count` | **CRITICAL** | 🔴 NOT STARTED | RQ-016, RQ-020, RQ-021 | Database | N/A |
| A-06 | Create `identity_facets` table (if not exists) | **CRITICAL** | 🔴 NOT STARTED | RQ-011, CD-015 | Database | N/A |
| A-07 | Add `population_learning_enabled` boolean to `users` table | MEDIUM | 🔴 NOT STARTED | RQ-019, RQ-023 | Database | N/A |
| A-08 | Create `population_resistance_clusters` table (768-dim centroids) | MEDIUM | 🔴 NOT STARTED | RQ-019 | Database | N/A |
| A-09 | Implement RLS policies for all new tables | HIGH | 🔴 NOT STARTED | RQ-019 | Database | N/A |
| A-10 | Add chronotype question to onboarding flow | HIGH | 🔴 NOT STARTED | RQ-012 | Database | N/A |
| A-11 | Create `treaty_history` table (amendment audit log) | HIGH | 🔴 NOT STARTED | RQ-024 | Database | N/A |
| A-12 | Add `version`, `parent_treaty_id`, `last_amended_at` to treaties | HIGH | 🔴 NOT STARTED | RQ-024 | Database | N/A |

---

### Phase B: Intelligence Layer

| # | Task | Priority | Status | Source | Component | AI Model |
|---|------|----------|--------|--------|-----------|----------|
| B-01 | Create Edge Function `embed-manifestation` (gemini-embedding-001) | **CRITICAL** | 🔴 NOT STARTED | RQ-019 | Supabase Edge | gemini-embedding-001 |
| B-02 | Implement Null-on-Update trigger for embedding invalidation | **CRITICAL** | 🔴 NOT STARTED | RQ-019 | Database Trigger | N/A |
| B-03 | Configure Supabase Webhook for async embedding generation | HIGH | 🔴 NOT STARTED | RQ-019 | Supabase Config | N/A |
| B-04 | Implement `EmbeddingRepository` Dart class with similarity queries | HIGH | 🔴 NOT STARTED | RQ-019 | Repository | N/A |
| B-05 | Create SQL functions: `find_similar_manifestations`, `detect_cross_facet_patterns` | HIGH | 🔴 NOT STARTED | RQ-019 | Database Function | N/A |
| B-06 | Implement Triangulation Protocol (Day 1→4→7 manifestation extraction) | **CRITICAL** | 🔴 NOT STARTED | RQ-012 | Service | Gemini 3 Flash |
| B-07 | Implement Sherlock Day 7 root synthesis prompt | **CRITICAL** | 🔴 NOT STARTED | RQ-012 | Prompt | DeepSeek V3.2 |
| B-08 | Add Chronotype-JITAI Matrix to decision engine | HIGH | 🔴 NOT STARTED | RQ-012 | Service | Hardcoded |
| B-09 | Implement tone-based message selection (push_hard/compassion/neutral) | HIGH | 🔴 NOT STARTED | RQ-012 | Service | Hardcoded |
| B-10 | Implement `ContextSnapshot` Dart class (30+ fields) | **CRITICAL** | 🔴 NOT STARTED | RQ-020 | Model | N/A |
| B-11 | Implement `calculateTensionScore()` algorithm | **CRITICAL** | 🔴 NOT STARTED | RQ-020 | Service | Hardcoded |
| B-12 | Add `decision_time_ms` tracking to JITAI | HIGH | 🔴 NOT STARTED | RQ-003 | Analytics | N/A |
| B-13 | Pass 6-float dimension vector to Thompson Sampling | HIGH | 🔴 NOT STARTED | RQ-004 | Service | N/A |
| B-14 | Implement Holy Trinity "Emergency Mode" | MEDIUM | 🔴 NOT STARTED | RQ-004 | Service | N/A |
| B-15 | Create population cluster update job (nightly) | LOW | 🔴 NOT STARTED | RQ-019 | Edge Function | DeepSeek V3.2 |
| B-16 | Implement Probation notification journey (T+0 to T+96h) | HIGH | 🔴 NOT STARTED | RQ-024 | Service | N/A |
| B-17 | Implement Auto-suspend logic (5+ breaches OR 3 dismissed) | HIGH | 🔴 NOT STARTED | RQ-024 | Service | N/A |

---

### Phase C: Council AI System

| # | Task | Priority | Status | Source | Component | AI Model |
|---|------|----------|--------|--------|-----------|----------|
| C-01 | Implement `Treaty` Dart model class | **CRITICAL** | 🔴 NOT STARTED | RQ-016, RQ-021 | Model | N/A |
| C-02 | Implement `TreatyTemplate` repository (5 hardcoded templates) | **CRITICAL** | 🔴 NOT STARTED | RQ-021 | Repository | N/A |
| C-03 | Implement `TreatyEngine` using `json_logic_dart` | **CRITICAL** | 🔴 NOT STARTED | RQ-020 | Service | N/A |
| C-04 | Create Edge Function `generate_council_session` | **CRITICAL** | 🔴 NOT STARTED | RQ-016, RQ-022 | Supabase Edge | DeepSeek V3.2 |
| C-05 | Implement DeepSeek V3.2 "Council Engine" system prompt (with JSON validation) | **CRITICAL** | 🔴 NOT STARTED | RQ-022 | Prompt | DeepSeek V3.2 |
| C-06 | Implement `SSMLBuilder` service (voice archetype → SSML prosody) | HIGH | 🔴 NOT STARTED | RQ-022 | Service | N/A |
| C-07 | Hook `TreatyEngine` into JITAI Stage 3 (Post-Safety, Pre-Optimization) | **CRITICAL** | 🔴 NOT STARTED | RQ-020 | Integration | Hardcoded |
| C-08 | Implement breach counter + Probation trigger (3 breaches in 7 days) | HIGH | 🔴 NOT STARTED | RQ-020, RQ-021 | Logic | N/A |
| C-09 | Implement tension_score auto-detection (threshold > 0.7) | HIGH | 🔴 NOT STARTED | RQ-020 | Service | DeepSeek V3.2 |
| C-10 | Build Facet Agent Templates (4 voice archetypes) | HIGH | 🔴 NOT STARTED | RQ-022 | Content | N/A |
| C-11 | Implement Audiobook Pattern TTS (single narrator, SSML prosody) | HIGH | 🔴 NOT STARTED | RQ-016, RQ-022 | Service | Gemini 2.5 Flash TTS |
| C-12 | Implement Council activation keyword regex detection | MEDIUM | 🔴 NOT STARTED | RQ-020 | Service | N/A |
| C-13 | Wire Council reconvene for major amendments (pass treaty context) | HIGH | 🔴 NOT STARTED | RQ-024 | Service | N/A |

---

### Phase D: UX & Frontend

| # | Task | Priority | Status | Source | Component | AI Model |
|---|------|----------|--------|--------|-----------|----------|
| D-01 | Build "The Constitution" dashboard screen (Active Laws / Probation / Archives) | **CRITICAL** | 🔴 NOT STARTED | RQ-021 | Screen | N/A |
| D-02 | Build "The Chamber" Council session overlay (dark mode, pulsing avatars) | **CRITICAL** | 🔴 NOT STARTED | RQ-021, RQ-022 | Screen | N/A |
| D-03 | Implement Treaty Card widget component | HIGH | 🔴 NOT STARTED | RQ-021 | Widget | N/A |
| D-04 | Implement Ratification Ritual (3-second haptic seal) | HIGH | 🔴 NOT STARTED | RQ-021, RQ-026 | Widget | N/A |
| D-05 | Build Treaty Creation Wizard (3-step flow) | HIGH | 🔴 NOT STARTED | RQ-021 | Screen | N/A |
| D-06 | Implement "Digital Sunset" first-time treaty onboarding | HIGH | 🔴 NOT STARTED | RQ-021 | Onboarding | N/A |
| D-07 | Add 3 onboarding questions for cold-start dimension estimation | HIGH | 🔴 NOT STARTED | RQ-004 | Onboarding | N/A |
| D-08 | Post-intervention emotion capture UI | MEDIUM | 🔴 NOT STARTED | RQ-002 | Widget | N/A |
| D-09 | Micro-feedback prompt (👍/👎) on interventions | LOW | 🔴 NOT STARTED | RQ-002 | Widget | N/A |
| D-10 | Track notification open source (push vs organic) | MEDIUM | 🔴 NOT STARTED | RQ-003 | Analytics | N/A |
| D-11 | Implement Treaty Amendment Editor (minor amendments) | HIGH | 🔴 NOT STARTED | RQ-024 | Widget | N/A |
| D-12 | Implement Re-Ratification ceremony (3s hold + haptic) | HIGH | 🔴 NOT STARTED | RQ-024 | Widget | N/A |
| D-13 | Implement Pause Treaty flow (modal + date picker) | MEDIUM | 🔴 NOT STARTED | RQ-024 | Widget | N/A |
| D-14 | Implement Repeal Treaty flow (type-to-confirm) | MEDIUM | 🔴 NOT STARTED | RQ-024 | Widget | N/A |

---

### Phase E: Polish & Advanced

| # | Task | Priority | Status | Source | Component | AI Model |
|---|------|----------|--------|--------|-----------|----------|
| E-01 | Design Summon Token UI display | MEDIUM | 🔴 NOT STARTED | RQ-025, PD-119 | Widget | N/A |
| E-02 | Implement Summon Token earning/spending logic | MEDIUM | 🔴 NOT STARTED | RQ-025, PD-119 | Service | N/A |
| E-03 | Specify Ratification Ritual haptic patterns (iOS + Android) | MEDIUM | 🔴 NOT STARTED | RQ-026 | Asset | N/A |
| E-04 | Source/create Ratification audio assets (clockwork, wax seal, thud) | MEDIUM | 🔴 NOT STARTED | RQ-026 | Asset | N/A |
| E-05 | Implement Treaty modification/amendment flow | HIGH | 🔴 NOT STARTED | RQ-024, PD-118 | Screen | N/A |
| E-06 | Implement Probation → Renegotiation journey | HIGH | 🔴 NOT STARTED | RQ-024, PD-118 | Flow | N/A |
| E-07 | Implement treaty template versioning schema | LOW | 🔴 NOT STARTED | RQ-027 | Database | N/A |
| E-08 | The Chamber visual design implementation | MEDIUM | 🔴 NOT STARTED | PD-120 | Screen | N/A |
| E-09 | Retention cohort tracking | LOW | 🔴 NOT STARTED | RQ-002 | Analytics | N/A |
| E-10 | Calculate schedule entropy from time_context | MEDIUM | 🔴 NOT STARTED | RQ-003 | Analytics | N/A |

---

### Phase F: Identity Coach System

*Added: 10 January 2026 | Source: RQ-005, RQ-006, RQ-007 | Decision: PD-125 (50 habits at launch)*

| # | Task | Priority | Status | Source | Component | AI Model |
|---|------|----------|--------|--------|-----------|----------|
| F-01 | Create `preference_embeddings` table (768-dim vector per user) | HIGH | 🔴 NOT STARTED | RQ-005 | Database | N/A |
| F-02 | Create `identity_roadmaps` table (user aspiration tracking) | **CRITICAL** | 🔴 NOT STARTED | RQ-007 | Database | N/A |
| F-03 | Create `roadmap_nodes` table (progression stages) | **CRITICAL** | 🔴 NOT STARTED | RQ-007 | Database | N/A |
| F-04 | Add `ideal_dimension_vector` (6-dim) to `habit_templates` | HIGH | 🔴 NOT STARTED | RQ-005 | Database | N/A |
| F-05 | Add `archetype_template_id` FK to `identity_facets` | HIGH | 🔴 NOT STARTED | RQ-006 | Database | N/A |
| F-06 | Create `archetype_templates` reference table (12 presets) | HIGH | 🔴 NOT STARTED | RQ-006 | Database | N/A |
| F-07 | Implement `generateRecommendations()` Edge Function (The Architect) | **CRITICAL** | 🔴 NOT STARTED | RQ-005 | Supabase Edge | DeepSeek V3.2 |
| F-08 | Implement Stage 1: Semantic retrieval (768-dim, pgvector) | **CRITICAL** | 🔴 NOT STARTED | RQ-005 | Backend | gemini-embedding-001 |
| F-09 | Implement Stage 2: Psychometric re-ranking (6-dim scoring) | **CRITICAL** | 🔴 NOT STARTED | RQ-005 | Backend | Hardcoded |
| F-10 | Implement Architect scheduler (nightly/weekly batch) | HIGH | 🔴 NOT STARTED | RQ-005 | Backend | N/A |
| F-11 | Implement feedback signal tracking (adopt/dismiss/snooze) | HIGH | 🔴 NOT STARTED | RQ-005 | Service | N/A |
| F-12 | Extend Sherlock Day 3: "Future Self Interview" for roadmap seeding | HIGH | 🔴 NOT STARTED | RQ-007 | Onboarding | DeepSeek V3.2 |
| F-13 | Create 50 universal habit templates (with dual embeddings) | **CRITICAL** | 🔴 NOT STARTED | RQ-006, PD-125 | Content | gemini-embedding-001 |
| F-14 | Create 12 Archetype Template presets (dimension vectors) | HIGH | 🔴 NOT STARTED | RQ-006 | Content | N/A |
| F-15 | Create 12 Framing Templates (dimension × poles) | HIGH | 🔴 NOT STARTED | RQ-006 | Content | N/A |
| F-16 | Create 4 Ritual Templates (Morning/Evening/Transition/Weekend) | MEDIUM | 🔴 NOT STARTED | RQ-006 | Content | N/A |
| F-17 | Implement `ProactiveRecommendation` Dart model class | HIGH | 🔴 NOT STARTED | RQ-005 | Model | N/A |
| F-18 | Implement `IdentityRoadmapService` (CRUD + ICS calculation) | HIGH | 🔴 NOT STARTED | RQ-007 | Service | N/A |
| F-19 | Implement Pace Car rate limiting (max 1/day, <5 active habits) | HIGH | 🔴 NOT STARTED | RQ-005 | Service | N/A |
| F-20 | Create regression messaging templates (The Dip responses) | MEDIUM | 🔴 NOT STARTED | RQ-006 | Content | N/A |

---

### Phase G: Identity Coach Intelligence (Phase 2)

*Added: 10 January 2026 | Source: RQ-028, RQ-029, RQ-030, RQ-031, RQ-032 | Decisions: PD-121, PD-122, PD-123, PD-124*

| # | Task | Priority | Status | Source | Component | AI Model |
|---|------|----------|--------|--------|-----------|----------|
| G-01 | Add `ics_score` FLOAT field to `identity_facets` table | HIGH | 🔴 NOT STARTED | RQ-032 | Database | N/A |
| G-02 | Add `typical_energy_state` TEXT field to `identity_facets` (CD-015 4-state enum) | HIGH | 🔴 NOT STARTED | RQ-031, PD-123 | Database | N/A |
| G-03 | Add `trinity_seed` VECTOR(768) field to `preference_embeddings` | HIGH | 🔴 NOT STARTED | RQ-030 | Database | N/A |
| G-04 | Implement `RocchioUpdater` service (α=0.15 ban, α=0.05 adopt, 30% anchor) | **CRITICAL** | 🔴 NOT STARTED | RQ-030 | Service | N/A |
| G-05 | Implement `ICSCalculator` service (AvgConsistency × log10(Votes+1)) | HIGH | 🔴 NOT STARTED | RQ-032 | Service | N/A |
| G-06 | Implement `ArchetypeMatcher` service (cosine similarity, threshold 0.65) | **CRITICAL** | 🔴 NOT STARTED | RQ-028 | Service | gemini-embedding-001 |
| G-07 | Update F-19 `PaceCar` to use Building vs Maintenance model (graceful_score < 0.8) | HIGH | 🔴 NOT STARTED | RQ-031 | Service | N/A |
| G-08 | Populate `archetype_templates` with 12 validated archetype definitions | **CRITICAL** | 🔴 NOT STARTED | RQ-028, PD-121 | Content | N/A |
| G-09 | Run DeepSeek dimension curation prompt on 50 habit templates | HIGH | 🔴 NOT STARTED | RQ-029 | Content | DeepSeek V3.2 |
| G-10 | Audit and validate dimension vectors for all habits | HIGH | 🔴 NOT STARTED | RQ-029 | Content | N/A |
| G-11 | Add `created_at` timestamp + 7-day TTL logic to recommendation cards | MEDIUM | 🔴 NOT STARTED | RQ-031, PD-124 | Service | N/A |
| G-12 | Implement ICS visual tier mapping (Seed/Sapling/Oak) | MEDIUM | 🔴 NOT STARTED | RQ-032 | UI | N/A |
| G-13 | Deprecate `hexis_score` in GLOSSARY.md (mark as replaced by ICS) | LOW | 🔴 NOT STARTED | RQ-032 | Documentation | N/A |
| G-14 | Create archetype override UI in Settings (user can change assignment) | LOW | 🔴 NOT STARTED | RQ-028 | UI | N/A |

---

### Phase H: Constellation & Airlock (psyOS UX) — 🔴 BLOCKED

*Added: 10 January 2026 | Source: RQ-017 ✅, RQ-018 ✅ | Decisions: PD-108 ✅, PD-110 ✅, PD-112 ✅*

**⚠️ BLOCKED BY PHASE A:** These tasks require `identity_facets` and `identity_topology` tables which **DO NOT EXIST**.

| Reality Check | Status |
|---------------|--------|
| `identity_facets` table | ❌ DOES NOT EXIST |
| `identity_topology` table | ❌ DOES NOT EXIST |
| Audio files (assets/sounds/) | ❌ 0 BYTES (placeholders) |
| Skill Tree fallback | ✅ Production-ready (549 lines) |

**Unblocking Path:** A-01 → A-02 → G-01 → G-02 → Phase H tasks become actionable
**Red Team Critique:** `docs/analysis/RED_TEAM_CRITIQUE_RQ017_RQ018.md`

| # | Task | Priority | Status | Source | Component | AI Model |
|---|------|----------|--------|--------|-----------|----------|
| H-01 | Implement `ConstellationPainter` (CustomPainter, Canvas) | **CRITICAL** | 🔴 BLOCKED | RQ-017 | Widget | N/A |
| H-02 | Implement orbit distance formula (ICS-based: `MaxRadius - ICS*30dp`) | **CRITICAL** | 🔴 BLOCKED | RQ-017 | Widget | N/A |
| H-03 | Implement planet radius formula (`16dp + clamp(log(votes)*4, 0, 24)`) | HIGH | 🔴 BLOCKED | RQ-017 | Widget | N/A |
| H-04 | Implement Ghost Mode (7-day threshold, desaturation shader) | HIGH | 🔴 BLOCKED | RQ-017 | Widget | N/A |
| H-05 | Implement Wobble animation (friction-based: `sin(t*20) * friction * 4px`) | MEDIUM | 🔴 BLOCKED | RQ-017 | Widget | N/A |
| H-06 | Implement Tether visualization (red line for `friction > 0.6`) | MEDIUM | 🔴 BLOCKED | RQ-017 | Widget | N/A |
| H-07 | Implement Settled State (0 FPS when idle 3s) | **CRITICAL** | 🔴 BLOCKED | RQ-017 | Widget | N/A |
| H-08 | Add RepaintBoundary optimization for starfield | HIGH | 🔴 BLOCKED | RQ-017 | Widget | N/A |
| H-09 | Implement progressive disclosure logic (Day 1→7→30) | HIGH | 🔴 BLOCKED | RQ-017 | Service | N/A |
| H-10 | Implement `TransitionDetector` service (Calendar + Activity) | **CRITICAL** | 🔴 NOT STARTED | RQ-018 | Service | N/A |
| H-11 | Implement `AirlockOverlay` widget (5-Second Seal UX) | **CRITICAL** | 🔴 BLOCKED | RQ-018 | Widget | N/A |
| H-12 | Implement `HapticService` (Android VibrationEffect wrapper) | HIGH | 🔴 NOT STARTED | RQ-018 | Service | N/A |
| H-13 | Bundle stock audio assets (4 loops, <500KB) — **CURRENT: 0 bytes** | HIGH | 🔴 NOT STARTED | RQ-018 | Asset | N/A |
| H-14 | Integrate Airlock with Treaty system (mandatory if treaty exists) | HIGH | 🔴 BLOCKED | RQ-018 | Service | N/A |
| H-15 | Implement conflict modal (tether tap → Council option) | MEDIUM | 🔴 BLOCKED | RQ-017 | Widget | N/A |
| H-16 | Implement tap-planet drill-down navigation | MEDIUM | 🔴 BLOCKED | RQ-017 | Widget | N/A |

---

### Phase P: Process & Engineering (RQ-008 + RQ-009)

*Added: 10 January 2026 | Source: RQ-008 (UI Logic Separation), RQ-009 (LLM Coding Approach)*

| # | Task | Priority | Status | Source | Component | AI Model |
|---|------|----------|--------|--------|-----------|----------|
| P-01 | Update AI_AGENT_PROTOCOL.md with Protocol 2 (Context-Adaptive) | **CRITICAL** | ✅ DONE | RQ-008,009 | Documentation | N/A |
| P-02 | Create Boundary Decision Tree documentation | HIGH | ✅ DONE | RQ-008 | Documentation | N/A |
| P-03 | Add linting rules to analysis_options.yaml | HIGH | 🔴 NOT STARTED | RQ-008 | Config | N/A |
| P-04 | Create ChangeNotifier Controller template | HIGH | 🔴 NOT STARTED | RQ-008 | Template | N/A |
| P-05 | Document Side Effect pattern with code example | HIGH | ✅ DONE | RQ-008 | Documentation | N/A |
| P-06 | Add Riverpod to pubspec.yaml for new features | MEDIUM | 🔴 NOT STARTED | RQ-008 | Config | N/A |
| P-07 | Create "Logic vs Visual" task classification guide | HIGH | ✅ DONE | RQ-009 | Documentation | N/A |
| P-08 | Define "Logic Leakage" metric tracking | MEDIUM | 🔴 NOT STARTED | RQ-008 | Analytics | N/A |

**Note:** P-01, P-02, P-05, P-07 were completed as part of Protocol 9 reconciliation. Remaining tasks (P-03, P-04, P-06, P-08) are implementation work.

---

### Pending Research Tasks

These tasks cannot be fully specified until research completes:

| Source | Status | Blocks Tasks |
|--------|--------|--------------|
| RQ-008 (UI Logic Separation) | ✅ COMPLETE | P-01 to P-08 extracted |
| RQ-009 (LLM Coding Approach) | ✅ COMPLETE | Protocol 2 updated |
| RQ-023 (Population Privacy) | 🔴 NEEDS RESEARCH | Privacy policy, opt-in UI, PD-116 |
| RQ-024 (Treaty Modification) | ✅ COMPLETE | A-11, A-12, B-16, B-17, C-13, D-11-D-14 extracted |
| RQ-025 (Summon Token Economy) | 🔴 NEEDS RESEARCH | E-01, E-02 (token system) |
| RQ-026 (Sound Design) | 🔴 NEEDS RESEARCH | E-03, E-04 (audio assets), H-13 enhancement |
| RQ-027 (Template Versioning) | 🔴 NEEDS RESEARCH | E-07 (versioning schema) |

---

### Implementation Summary

| Phase | Total Tasks | CRITICAL | HIGH | MEDIUM | LOW | Done |
|-------|-------------|----------|------|--------|-----|------|
| **A: Schema** | 12 | 6 | 4 | 2 | 0 | 0 |
| **B: Intelligence** | 17 | 5 | 8 | 3 | 1 | 0 |
| **C: Council AI** | 13 | 5 | 7 | 1 | 0 | 0 |
| **D: UX** | 14 | 2 | 7 | 4 | 1 | 0 |
| **E: Polish** | 10 | 0 | 2 | 5 | 3 | 0 |
| **F: Identity Coach** | 20 | 5 | 12 | 3 | 0 | 0 |
| **G: Identity Coach 2** | 14 | 3 | 7 | 2 | 2 | 0 |
| **H: Constellation/Airlock** | 16 | 5 | 6 | 4 | 1 | 0 |
| **P: Process & Engineering** | 8 | 1 | 5 | 2 | 0 | 4 |
| **TOTAL** | **124** | **32** | **58** | **26** | **8** | **4** |

**Critical Path:** A-01 → A-02/A-03/A-05 → B-01 → B-06/B-07 → C-01/C-03 → C-04/C-05 → D-01/D-02

**Identity Coach Path:** F-02/F-03 → F-06 → F-07/F-08/F-09 → F-13 → F-10

**Constellation Path:** G-01 (ICS field) → H-02 (orbit formula) → H-01 (painter) → H-07 (settled state)

**Process Path (Completed):** P-01 ✅ → P-02 ✅ → P-05 ✅ → P-07 ✅ (remaining: P-03, P-04, P-06, P-08)

---

## Open Questions for Human Decision

These require Oliver's input before implementation:

| # | Question | Options | Deep Think Recommendation |
|---|----------|---------|---------------------------|
| 1 | **People Pleaser void** | (A) Add "Social Sensitivity" as 7th dimension, (B) Delete archetype | Delete unless social leaderboard exists |
| 2 | **Privacy vs Battery** | (A) Time-of-day variance only (low privacy), (B) Full GPS for entropy | Time-of-day for MVP |
| 3 | **Content Library debt** | Need 4 message variants per trigger (Eager, Vigilant, Autonomy-Supportive, Directive) | Bandit can't optimize with only 1 generic message |
| 4 | **Retention as metric** | (A) Add cohort tracking, (B) Skip (too confounded) | Skip for MVP, add later |

---

## Signals Currently Available for Research

### What The Pact Captures (for dimension research):

**Always Available:**
- Time context (hour, day, weekend, morning/evening)
- Historical behavior (streak, days since miss, resilience score, habit strength)
- Intervention fatigue (count in 24h)

**If Permissions Granted:**
- Physiological: Sleep duration (z-score), HRV/stress (z-score)
- Environmental: Location zone, weather, calendar busyness
- Digital: Distraction minutes, apex distractor app
- Emotional: Primary emotion from voice sessions (anxiety/stress/joy/etc.)

**User Self-Report:**
- Manual vulnerability override (weighted 70% when set)

**Not Yet Implemented:**
- Activity recognition (walking, sitting, driving)
- Real-time doom-scrolling detection
- Post-intervention emotion delta

---

## Research Session Log

| Date | Agent | Focus | Findings | Action Items |
|------|-------|-------|----------|--------------|
| 05 Jan 2026 | Google Deep Think | **RQ-012 + RQ-016** | ✅ COMPLETE — Fractal Trinity schema (pgvector), Triangulation Protocol, Council AI (Single-Shot Playwright), Treaty Protocol, Chronotype-JITAI Matrix | Integrated into RQ-012, RQ-016 |
| 05 Jan 2026 | Gemini Deep Think | **SYNTHESIS** | ✅ COMPLETE — Reconciled ChatGPT + Gemini into actionable architecture | Integrated into RQ-004 |
| 05 Jan 2026 | Gemini Deep Research | 6-Dimension Model | ✅ COMPLETE — Hexagonal phenotype with Holy Trinity mapping | Integrated into RQ-001 |
| 05 Jan 2026 | ChatGPT | Intervention Effectiveness | ✅ COMPLETE — Validated reward function, added literature mapping | Integrated into RQ-002 |
| 05 Jan 2026 | Claude | Research coordination | Aligned all agents' parameters for comparison | ✅ Done |
| 05 Jan 2026 | Claude | Codebase audit | Documented current intervention measurement | ✅ Done |

**Research Status:** RQ-012 and RQ-016 COMPLETE. Remaining psyOS research: RQ-013 through RQ-018 (excluding RQ-016).

---

## Decision Dependencies

```
CONFIRMED DECISIONS:
CD-015 (psyOS Architecture) ✅ CONFIRMED (05 Jan 2026)
    └── Generated: RQ-012 through RQ-018
    └── Resolved: PD-106 (Identity Facets model)

COMPLETED RESEARCH:
RQ-001 (Archetype Taxonomy) ✅ COMPLETE
    ├── RQ-002 (Effectiveness Measurement) ✅ COMPLETE
    ├── RQ-003 (Dimension-to-Tracking) ✅ COMPLETE
    └── RQ-004 (Migration Strategy) ✅ COMPLETE

RQ-011 (Multiple Identity Architecture) ✅ COMPLETE (05 Jan 2026)
    └── Recommendation: Identity Facets model → ✅ CONFIRMED via CD-015

RESOLVED DECISIONS:
    ├── PD-001 (Archetype Philosophy) → ✅ RESOLVED via CD-005
    ├── PD-106 (Multiple Identities) → ✅ RESOLVED via CD-015 (psyOS)
    └── PD-102 (JITAI hardcoded vs AI) → 🟡 RESHAPED by CD-015

COMPLETED RESEARCH (psyOS - CRITICAL):
RQ-012 (Fractal Trinity Architecture) ✅ COMPLETE (05 Jan 2026 - Deep Think)
    └── Delivered: Schema (pgvector), Triangulation Protocol, Sherlock prompts, Chronotype-JITAI Matrix
RQ-016 (Council AI) ✅ COMPLETE (05 Jan 2026 - Deep Think)
    └── Delivered: Single-Shot Playwright, System prompt, Treaty Protocol, Audiobook Pattern

PENDING RESEARCH (psyOS - HIGH):
RQ-013 (Identity Topology & Graph) 🔴 NEEDS RESEARCH
    └── Blocks: Conflict resolution, JITAI, dashboard
RQ-014 (State Economics) 🔴 NEEDS RESEARCH
    └── Blocks: Airlock Protocol, energy conflict detection
RQ-015 (Polymorphic Habits) 🔴 NEEDS RESEARCH
    └── Blocks: Habit completion flow, metrics
RQ-017 (Constellation UX) 🔴 NEEDS RESEARCH
    └── Blocks: Dashboard redesign
RQ-018 (Airlock & Priming) 🔴 NEEDS RESEARCH
    └── Blocks: JITAI integration, audio assets

IMPLEMENTATION RESEARCH (Generated by RQ-012/RQ-016):
RQ-019 (pgvector Implementation) 🔴 NEEDS RESEARCH
    └── Blocks: Embedding storage, Triangulation Protocol, population learning
RQ-020 (Treaty-JITAI Integration) 🔴 NEEDS RESEARCH
    └── Blocks: Treaty enforcement, JITAI modifications, Council AI value

PENDING RESEARCH (Core Architecture - BLOCKING):
RQ-010 (Permission Data Philosophy) 🔴 NEEDS RESEARCH
    └── Blocks: Phase 2 Intelligence, JITAI refinement, Gap Analysis

PENDING RESEARCH (Identity Coach - Core Value Proposition):
RQ-005 (Proactive Recommendation Algorithms) 🔴 NEEDS RESEARCH
    └── RQ-006 (Content Library → Guidance Content) 🔴 NEEDS RESEARCH
        └── RQ-007 (Identity Roadmap Architecture) 🔴 NEEDS RESEARCH
            └── Blocks: CD-008, CD-009, CD-011, PD-105, PD-107

PENDING RESEARCH (Process/Code Quality):
RQ-008 (UI Logic Separation) 🔴 NEEDS RESEARCH → Blocks CD-013
RQ-009 (LLM Coding Approach) 🔴 NEEDS RESEARCH → Blocks Protocol 2
```

**RQ/PD Hierarchy:**
- Not all PDs require RQs (some are straightforward product choices)
- All RQs should generate PDs if implementation decisions are needed

**Terminology:**
- **RQ** = Research Question (investigation)
- **PD** = Product Decision (pending choice)
- **CD** = Confirmed Decision (locked choice)

**Research Priority Order (Updated for psyOS):**
1. ~~**CRITICAL:** RQ-012, RQ-016 (Fractal Trinity, Council AI — signature features)~~ ✅ COMPLETE
2. **HIGH:** RQ-019, RQ-020 (Implementation research generated by RQ-012/RQ-016)
3. **HIGH:** RQ-013, RQ-014, RQ-015, RQ-017, RQ-018 (psyOS supporting systems)
4. **HIGH:** RQ-005, RQ-006 (Proactive Guidance System — core value prop)
5. **HIGH:** RQ-010 (Permission Data — affects all phases)
6. **HIGH:** RQ-007 (Identity Roadmap Architecture)
7. **MEDIUM:** RQ-008, RQ-009 (Process improvements)

---

## Notes for Researchers

### For ChatGPT:
When populating RQ-003 table, consider:
1. **Parsimony:** Fewer dimensions = faster population learning convergence
2. **Interpretability:** Can we explain this to users? ("You're high in autonomy need")
3. **Actionability:** Does knowing this dimension change our intervention strategy?

### For Gemini:
Focus on:
1. JITAI-specific literature (Nahum-Shani, Klasnja)
2. Mapping dimensions to intervention arm selection
3. Cold-start prior seeding strategies

### For Claude:
Focus on:
1. Codebase integration feasibility
2. Technical debt if dimensions require new tracking
3. Architecture implications of dimension changes
