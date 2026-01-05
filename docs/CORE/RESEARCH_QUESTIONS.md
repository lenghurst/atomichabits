# RESEARCH_QUESTIONS.md — Active Research & Open Questions

> **Last Updated:** 05 January 2026 (Full implementation confirmed; RQ-019, RQ-020 added; CD-016 AI Model Strategy)
> **Purpose:** Track active research informing product/architecture decisions
> **Owner:** Oliver (with AI agent research support)
> **Status:** psyOS CRITICAL research complete (RQ-012, RQ-016). Implementation RQs added (RQ-019, RQ-020). Full launch scope confirmed.

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
| **Status** | 🔴 NEEDS RESEARCH |
| **Blocking** | CD-008 (Identity Coach), PD-105 (AI Coaching Architecture) |
| **Priority** | **CRITICAL** — Core value proposition |
| **Assigned** | Any agent |
| **Source** | IDENTITY_COACH_SPEC.md |

**Sub-Questions:**

| Sub-Question | Notes |
|--------------|-------|
| What algorithms recommend identity-aligned goals? | Collaborative filtering? Content-based? Hybrid? |
| How do we avoid overwhelming users? | Rate limiting, importance scoring |
| How does this integrate with JITAI? | Same bandit? Separate system? (See PD-105) |
| What's the feedback loop? | How do we learn if recommendations worked? |
| How do we handle user rejection? | Snooze vs dismiss vs never show again |

**Output Expected:**
- Algorithm recommendation with rationale
- Integration pattern with existing JITAI
- Feedback loop design
- User rejection handling strategy

---

### RQ-006: Content Library for Recommendations

| Field | Value |
|-------|-------|
| **Question** | What content library is needed to support proactive recommendations? |
| **Status** | 🔴 NEEDS RESEARCH |
| **Blocking** | CD-009 (Content Library), RQ-005 implementation |
| **Priority** | HIGH — Enables RQ-005 |
| **Assigned** | Any agent |
| **Source** | IDENTITY_COACH_SPEC.md |

**Sub-Questions:**

| Sub-Question | Notes |
|--------------|-------|
| What habits are "universal starters"? | Evidence-based default recommendations |
| How many ritual templates needed? | Morning, evening, transition, recovery |
| What progression milestones are meaningful? | 7 days, 21 days, 66 days, 1 year? |
| How do we phrase warnings without shame? | Regression messaging strategy |

**Content Quantity Estimate:**
```
PROACTIVE CONTENT (Growth):
├── 50+ habit recommendation templates
├── 20+ ritual templates
├── 10+ progression path templates
├── 15+ regression warning templates
└── 30+ goal alignment prompts

TOTAL: ~125+ content pieces needed
```

**Output Expected:**
- Content taxonomy and categories
- Template structures per category
- Dimensional framing variants (per 6 dimensions)
- Minimum viable content set for launch

---

### RQ-007: Identity Roadmap Architecture (User Aspiration → Habit Recommendation)

| Field | Value |
|-------|-------|
| **Question** | How do we architect the full flow from user aspirations to AI-guided habit recommendations? |
| **Status** | 🔴 NEEDS RESEARCH |
| **Blocking** | CD-008 (Identity Coach), CD-011 (Architecture Ramifications) |
| **Priority** | HIGH — Supports Identity Coach |
| **Assigned** | Any agent |
| **Depends On** | RQ-005, RQ-006 |
| **Previously** | Was RQ-006 before renumbering |

**The Required Flow:**
```
User shares dreams/fears
    → AI constructs Identity Roadmap
    → App recommends habits/rituals
    → Tracks progress
    → JITAI intervenes when at risk
    → Identity Coach guides growth
```

**Research Questions:**
1. **Aspiration Extraction:** How should Sherlock extract aspirational identity (not just Holy Trinity blocks)?
2. **Roadmap Construction:** What data structure represents an "Identity Roadmap"?
3. **Habit Matching:** How do we map aspirations to habit recommendations?
4. **Progress Tracking:** What metrics indicate "progress toward aspirational self"?
5. **Regression Detection:** How do we detect when someone is moving AWAY from their aspiration?
6. **Coherence Check:** How do we detect when current habits don't match stated aspirations?

**Dependencies (Must Be Researched In Order):**
```
1. Aspiration Extraction (Sherlock changes)
   └── Needs: New onboarding questions, prompt updates

2. Identity Roadmap Data Model
   └── Needs: Schema design, storage strategy
   └── Depends on: #1 (what data to store)

3. Habit Matching Algorithm
   └── Needs: Recommendation logic
   └── Depends on: #2 (what to match against)

4. Progress/Regression Detection
   └── Needs: Metric definitions
   └── Depends on: #3 (what to measure against)

5. Coherence Engine
   └── Needs: Gap analysis logic
   └── Depends on: #4 (what signals to use)
```

**Output Expected:**
- Data model for Identity Roadmap
- Algorithm for habit-to-aspiration matching
- Metrics for progress/regression
- Integration points with existing JITAI

---

### RQ-008: UI Logic Separation for AI-Assisted Development

| Field | Value |
|-------|-------|
| **Question** | What are best practices for articulating UI/logic separation that enables effective "vibe coding"? |
| **Status** | 🔴 NEEDS RESEARCH |
| **Blocking** | CD-013 refinement |
| **Priority** | MEDIUM — Code quality |
| **Assigned** | Any agent |
| **Previously** | Was RQ-005 before renumbering |

**Context:**
The Pact uses Flutter with Riverpod for state management. We want UI files to contain ONLY presentation logic so that:
1. AI agents can safely modify UI without breaking business logic
2. Business logic can be tested without UI
3. "Vibe coding" (rapid UI iteration) is safe

**Research Questions:**
1. What patterns do production Flutter apps use for strict UI/logic separation?
2. How do other AI-assisted development teams articulate this principle?
3. What linting rules or code review checks can enforce this?
4. How does this apply to animation logic (UI or business)?
5. Where does navigation routing logic belong?

**Output Expected:**
- Code pattern examples (✅ correct vs ❌ wrong)
- Linting configuration recommendations
- Boundary definitions (what counts as "UI" vs "logic")

---

### RQ-009: Optimal LLM Coding Approach ("Make it Work → Make it Right"?)

| Field | Value |
|-------|-------|
| **Question** | Is "Make it work first, then refactor" the optimal approach for LLM-assisted coding? |
| **Status** | 🔴 NEEDS RESEARCH |
| **Priority** | MEDIUM — Affects all coding work |
| **Blocking** | Protocol 2 in AI_AGENT_PROTOCOL.md |
| **Assigned** | Any agent |
| **Trigger** | User questioned if this is really optimal for LLMs |
| **Previously** | Was RQ-007 before renumbering |

**Context:**
Current AI_AGENT_PROTOCOL.md Protocol 2 states:
```
1. Execute functionality completely (make it work)
2. THEN refactor for cleanliness (make it right)
3. NEVER sacrifice functionality for clean code principles
```

**Questions to Research:**
1. Do LLMs produce better code when refactoring is separate from initial implementation?
2. Or does explicit structure/planning BEFORE coding produce better results?
3. What do AI-assisted development teams recommend?
4. Are there studies comparing approaches?
5. Does it depend on task complexity?

**Alternative Approaches to Compare:**
| Approach | Description | Potential Pros | Potential Cons |
|----------|-------------|----------------|----------------|
| **A: Work → Right** | Implement first, refactor second | Unblocks functionality | May create more tech debt |
| **B: Plan → Work** | Plan structure, then implement | Cleaner initial code | May over-engineer |
| **C: TDD** | Tests first, then implementation | Verified correctness | Slower initial progress |
| **D: Iterative** | Small chunks: plan → code → test → refine | Balanced | More context switches |

**Output Expected:**
- Recommendation for which approach to use
- Conditions when each approach is appropriate
- Update AI_AGENT_PROTOCOL.md with findings

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
| **Status** | 🔴 NEEDS RESEARCH |
| **Priority** | **HIGH** — Core visual identity of psyOS |
| **Blocking** | Dashboard redesign, animation implementation, data binding |
| **Generated By** | CD-015 (psyOS Architecture) |
| **Assigned** | Dedicated session required |

**Context:**
Replace the Skill Tree with a **Constellation UX**:
- **Sun** = The Self (center of gravity)
- **Planets** = Facets (orbiting)
  - **Mass** = Habit volume / importance
  - **Gravity** = Pull on time/energy
  - **Orbit Distance** = Integration with Core Self
- **Neglected planets** don't shrink — they **cool** (dim), orbit becomes **erratic** (wobbles)

**Visual Feedback:**
- Massive "Career" planet pulling "Health" planet out of orbit
- User sees their life's gravity distortion in real-time

**Sub-Questions:**

| # | Question | Implications |
|---|----------|--------------|
| 1 | What animation framework? Rive, Lottie, or custom Flutter? | Technical choice |
| 2 | How do we map facet metrics to visual properties? | Data binding |
| 3 | What interactions should the visualization support? | Tap, drag, zoom? |
| 4 | How do we handle 1-2 facets vs 5+ facets? | Scalability |
| 5 | What accessibility considerations for motion-sensitive users? | Accessibility |
| 6 | How does Constellation relate to existing Binary Interface? | Migration path |
| 7 | Should orbit mechanics have actual physics or just look like it? | Realism vs performance |

**Output Expected:**
- Technical specification for Constellation animation
- Data model → visual property mapping
- Interaction design specification
- Accessibility guidelines
- Migration plan from Skill Tree

---

### RQ-018: Airlock Protocol & Identity Priming

| Field | Value |
|-------|-------|
| **Question** | How should state transitions and sensory priming be implemented? |
| **Status** | 🔴 NEEDS RESEARCH |
| **Priority** | **HIGH** — Differentiates psyOS from competitors |
| **Blocking** | JITAI integration, notification content, audio assets |
| **Generated By** | CD-015 (psyOS Architecture) |
| **Assigned** | Dedicated session required |

**Context:**
Two related concepts:

**Airlock Protocol:** When energy state conflict detected, insert mandatory transition ritual:
```
"You are switching from Hunter Mode (Work) to Gatherer Mode (Home).
Do not enter yet. 5-minute Box Breathing."
```

**Identity Priming:** Nudges should **prime** (sensory), not just remind (cognitive):
```
Trigger: 5 mins before "Deep Work"
Action: Play Sonic Trigger specific to "Architect" facet
Content: Hans Zimmer drone + Voice: "You are a builder. The world is noise.
         This is the signal. Enter the Cathedral."
Result: Immediate state shift via sensory anchoring.
```

**Sub-Questions:**

| # | Question | Implications |
|---|----------|--------------|
| 1 | How do we detect when Airlock is needed? | JITAI integration |
| 2 | What are effective transition rituals per energy state pair? | Content library |
| 3 | How do we create/source audio assets for Identity Priming? | Asset pipeline |
| 4 | Should priming be user-customizable or AI-selected? | Personalization |
| 5 | How do we measure effectiveness of priming? | Analytics |
| 6 | What's the user opt-out mechanism for Airlock? | User control |
| 7 | How do we prevent Airlock from becoming annoying? | UX quality |

**Output Expected:**
- Airlock trigger conditions and rules
- Transition ritual content library
- Audio asset requirements and sources
- Identity Priming notification system design
- Effectiveness measurement framework

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

#### Output Delivered

| Deliverable | Status |
|-------------|--------|
| Supabase pgvector setup | ✅ SQL schema provided |
| Embedding model selection | ✅ gemini-embedding-001 (with rationale) |
| Index strategy | ✅ HNSW with tuned parameters |
| Invalidation logic | ✅ Null-on-Update trigger |
| Edge Function code | ✅ TypeScript implementation |
| Cost projection | ✅ 10K → 1M users |

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

---

## Implementation Tasks from Research

**Purpose:** Track actionable items generated by completed research.

**Process:**
1. When research generates actionable items → Log here
2. **All tasks go to ROADMAP.md:**
   - HIGH/CRITICAL priority → Add to relevant Track in current Roadmap
   - LOW/MEDIUM priority → Add to Future Features section
3. If needs decision first → Create PD in PRODUCT_DECISIONS.md

**Rule:** Nothing gets lost. Every actionable item ends up in either the active Roadmap or Future Features.

### From RQ-002 (Intervention Effectiveness)

| Task | Priority | Status | Track |
|------|----------|--------|-------|
| Post-intervention emotion capture | MEDIUM | 🔴 NOT STARTED | Track D |
| Retention cohort tracking | LOW | 🔴 NOT STARTED | Track D |
| Micro-feedback prompt (👍/👎) | LOW | 🔴 NOT STARTED | Track D |

### From RQ-003 (Dimension Tracking)

| Task | Priority | Status | Track |
|------|----------|--------|-------|
| Add `decision_time_ms` tracking | HIGH | 🔴 NOT STARTED | Track A |
| Calculate schedule entropy from time_context | MEDIUM | 🔴 NOT STARTED | Track D |
| Track notification open source (push vs organic) | MEDIUM | 🔴 NOT STARTED | Track D |

### From RQ-004 (Migration Strategy)

| Task | Priority | Status | Track |
|------|----------|--------|-------|
| Add 3 onboarding questions for cold-start | HIGH | 🔴 NOT STARTED | Track B |
| Pass 6-float vector to Thompson Sampling | HIGH | 🔴 NOT STARTED | Track D |
| Implement Holy Trinity "Emergency Mode" | MEDIUM | 🔴 NOT STARTED | Track D |

### From RQ-012 (Fractal Trinity) — ✅ RESEARCH COMPLETE

| Task | Priority | Status | Track | AI Model |
|------|----------|--------|-------|----------|
| Create `psychometric_roots` table with pgvector | **CRITICAL** | 🔴 NOT STARTED | Phase A | N/A |
| Create `psychological_manifestations` table | **CRITICAL** | 🔴 NOT STARTED | Phase A | N/A |
| Add chronotype question to onboarding | HIGH | 🔴 NOT STARTED | Phase A | N/A |
| Implement Triangulation Protocol (Day 1→4→7) | **CRITICAL** | 🔴 NOT STARTED | Phase B | Gemini 3 Flash |
| Implement Sherlock Day 7 root synthesis | **CRITICAL** | 🔴 NOT STARTED | Phase B | DeepSeek V3.2 |
| Integrate pgvector for embedding storage | HIGH | 🔴 NOT STARTED | Phase B | DeepSeek V3.2 |
| Add Chronotype-JITAI Matrix to decision engine | HIGH | 🔴 NOT STARTED | Phase B | Hardcoded |
| Implement tone-based message selection | HIGH | 🔴 NOT STARTED | Phase B | Hardcoded |

### From RQ-016 (Council AI) — ✅ RESEARCH COMPLETE

| Task | Priority | Status | Track | AI Model |
|------|----------|--------|-------|----------|
| Create `treaties` table with logic_hooks JSONB | **CRITICAL** | 🔴 NOT STARTED | Phase C | N/A |
| Implement Single-Shot Playwright system prompt | **CRITICAL** | 🔴 NOT STARTED | Phase C | DeepSeek V3.2 |
| Build Council UI (text bubbles, avatars) | **CRITICAL** | 🔴 NOT STARTED | Phase C | N/A |
| Implement Treaty signing flow | HIGH | 🔴 NOT STARTED | Phase C | N/A |
| Implement Treaty enforcement in JITAI | HIGH | 🔴 NOT STARTED | Phase C | Hardcoded |
| Add breach tracking and renegotiation prompts | HIGH | 🔴 NOT STARTED | Phase C | N/A |
| Implement Audiobook Pattern TTS | HIGH | 🔴 NOT STARTED | Phase C | Gemini 2.5 Flash TTS |
| Add tension_score auto-detection | MEDIUM | 🔴 NOT STARTED | Phase C | DeepSeek V3.2 |
| Build Facet Agent Templates (4 archetypes) | HIGH | 🔴 NOT STARTED | Phase C | N/A |

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
