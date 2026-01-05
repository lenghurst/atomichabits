# RESEARCH_QUESTIONS.md — Active Research & Open Questions

> **Last Updated:** 05 January 2026
> **Purpose:** Track active research informing product/architecture decisions
> **Owner:** Oliver (with AI agent research support)
> **Status:** RQ-001 RESEARCH COMPLETE — Awaiting human decision on implementation

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
| 05 Jan 2026 | Gemini Deep Think | **SYNTHESIS** | ✅ COMPLETE — Reconciled ChatGPT + Gemini into actionable architecture | Integrated into RQ-004 |
| 05 Jan 2026 | Gemini Deep Research | 6-Dimension Model | ✅ COMPLETE — Hexagonal phenotype with Holy Trinity mapping | Integrated into RQ-001 |
| 05 Jan 2026 | ChatGPT | Intervention Effectiveness | ✅ COMPLETE — Validated reward function, added literature mapping | Integrated into RQ-002 |
| 05 Jan 2026 | Claude | Research coordination | Aligned all agents' parameters for comparison | ✅ Done |
| 05 Jan 2026 | Claude | Codebase audit | Documented current intervention measurement | ✅ Done |

**Research Status: COMPLETE** — Awaiting human decision on Open Questions before implementation.

---

## Decision Dependencies

```
COMPLETED RESEARCH:
RQ-001 (Archetype Taxonomy) ✅ COMPLETE
    ├── RQ-002 (Effectiveness Measurement) ✅ COMPLETE
    ├── RQ-003 (Dimension-to-Tracking) ✅ COMPLETE
    └── RQ-004 (Migration Strategy) ✅ COMPLETE

UNBLOCKED DECISIONS:
    ├── PD-001 (Archetype Philosophy) → READY FOR DECISION
    └── PD-102 (JITAI hardcoded vs AI) → READY FOR DECISION

PENDING RESEARCH (Identity Coach - Core Value Proposition):
RQ-005 (Proactive Recommendation Algorithms) 🔴 NEEDS RESEARCH
    └── RQ-006 (Content Library) 🔴 NEEDS RESEARCH
        └── RQ-007 (Identity Roadmap Architecture) 🔴 NEEDS RESEARCH
            └── Blocks: CD-008, CD-009, CD-011, PD-105

PENDING RESEARCH (Process/Code Quality):
RQ-008 (UI Logic Separation) 🔴 NEEDS RESEARCH → Blocks CD-013
RQ-009 (LLM Coding Approach) 🔴 NEEDS RESEARCH → Blocks Protocol 2
```

**Research Priority Order:**
1. **CRITICAL:** RQ-005, RQ-006 (Identity Coach is core value prop)
2. **HIGH:** RQ-007 (Enables Identity Roadmap)
3. **MEDIUM:** RQ-008, RQ-009 (Process improvements)

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
