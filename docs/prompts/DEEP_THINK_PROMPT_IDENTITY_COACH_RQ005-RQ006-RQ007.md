# Deep Think Prompt: Identity Coach Research

> **Target Research:** RQ-005, RQ-006, RQ-007
> **Prepared:** 06 January 2026
> **For:** Google Deep Think / Claude / External AI Tool
> **App Name:** The Pact

---

## Your Role

You are a **Senior AI Systems Architect** specializing in:
- Behavioral recommendation systems (habit formation, identity development)
- Multi-armed bandit algorithms and contextual reinforcement learning
- Content personalization for behavior change interventions
- Mobile-first AI system design with battery/performance constraints

Your approach: Think step-by-step. For each sub-question, reason through alternatives, cite relevant literature where applicable, and recommend with explicit confidence levels.

---

## Critical Instruction: Processing Order

```
RQ-005 (Proactive Recommendation Algorithms)
  ↓ Output feeds into...
RQ-006 (Content Library Requirements)
  ↓ Output feeds into...
RQ-007 (Identity Roadmap Architecture)
```

**Dependencies:** RQ-006 cannot be fully answered without RQ-005. RQ-007 synthesizes both.

---

## MANDATORY: Android-First Data Reality Audit

**CRITICAL CONSTRAINT (CD-017):** All designs must work on Android with these available signals only:

| Data Point | Android API | Permission | Battery | Available? |
|------------|-------------|------------|---------|------------|
| `foregroundApp` | UsageStatsManager | PACKAGE_USAGE_STATS | Low | ✅ YES |
| `screenOnDuration` | UsageStatsManager | PACKAGE_USAGE_STATS | Low | ✅ YES |
| `stepsLast30Min` | Google Fit / Health Connect | Health Connect | Low | ✅ YES |
| `locationZone` | Geofencing API | ACCESS_FINE_LOCATION | Medium | ✅ YES |
| `calendarEvents` | CalendarContract | READ_CALENDAR | Low | ✅ YES |
| `heartRate` | Health Connect | Health Connect | Medium | 🟡 OPTIONAL (~10% users) |
| `sleepData` | Health Connect | Health Connect | Low | 🟡 OPTIONAL |

**Anti-Pattern:** Do NOT design algorithms requiring wearable-only data (HRV, stress levels, continuous biometrics).

---

## Mandatory Context: Locked Architecture

### CD-005: 6-Dimension Archetype Model ✅
User profiles include a 6-float vector:
1. Regulatory Focus (Promotion ↔ Prevention)
2. Autonomy/Reactance (Rebel ↔ Conformist)
3. Action-State Orientation (Executor ↔ Overthinker)
4. Temporal Discounting (Future ↔ Present)
5. Perfectionistic Reactivity (Adaptive ↔ Maladaptive)
6. Social Rhythmicity (Stable ↔ Chaotic)

### CD-015: psyOS Architecture ✅
The Pact is a Psychological Operating System treating users as "Parliament of Selves":
- Users have multiple identity facets (e.g., "Devoted Father", "Ambitious Programmer")
- Habits can belong to multiple facets (polymorphic)
- Facets have energy states: `high_focus`, `high_physical`, `social`, `recovery`
- Facet-facet relationships modeled in `identity_topology` graph
- Council AI mediates facet conflicts

### CD-016: AI Model Strategy ✅
- **DeepSeek V3.2** for analyst/generator roles (cost-effective)
- **DeepSeek R1 Distilled** for Council AI reasoning (higher quality, 5x cost)
- JITAI bandit: Hardcoded Thompson Sampling (no LLM)

### CD-017: Android-First Development ✅
Primary platform is Android. All features must work without:
- Apple HealthKit
- Wearable-only sensors
- iOS-specific APIs

### CD-018: Engineering Threshold Framework ✅
Categorize each proposal as:
- **ESSENTIAL:** Must have for launch
- **VALUABLE:** Should have, adds significant value
- **NICE-TO-HAVE:** Could have, marginal benefit
- **OVER-ENGINEERED:** Skip, complexity exceeds value

---

### Existing JITAI System ✅
Thompson Sampling bandit with 7 intervention arms:
1. Motivational quotes
2. Micro-commitment prompts
3. Streak reminders
4. Social accountability nudges
5. Friction reduction suggestions
6. Identity reinforcement
7. Schedule optimization

Bandit context includes: time_of_day, day_of_week, streak_length, miss_count_week, dimension_vector.

---

### RQ-012: Fractal Trinity Architecture ✅ (Completed)
- Identity facets stored with embeddings
- Facets have energy states affecting habit suitability
- "Active facet" tracked in ContextSnapshot
- Polymorphic habits link to multiple facets

### RQ-014: State Economics ✅ (Completed)
4-state energy model with switching costs:
| State | Detection |
|-------|-----------|
| `high_focus` | Productivity app + 20min screen time |
| `high_physical` | Steps > 1000/30min |
| `social` | Calendar meeting OR social location zone |
| `recovery` | Phone locked + evening + low steps |

Dangerous transitions: `high_focus → social` (60min), `social → high_focus` (50min)

---

## Research Question 1: RQ-005 — Proactive Recommendation Algorithms

### Core Question
What algorithms should drive identity-aligned habit/ritual recommendations in a psyOS context with multiple identity facets?

### Why This Matters
The Identity Coach transforms The Pact from "habit tracker with identity features" to "AI life coach that guides identity development." This is the core value proposition (CD-008).

### The Problem
**Scenario:** User "Alex" has facets: "Devoted Father" (high energy mornings), "Ambitious Programmer" (high focus afternoons), "Health Enthusiast" (evenings). Currently:
- No system suggests habits aligned to facets
- No system detects when habits drift from stated identity
- No system recommends progression paths

**Current State:** JITAI intervenes reactively. No proactive guidance exists.

### Current Hypothesis (Validate or Refine)

| Component | Hypothesis | Confidence |
|-----------|------------|------------|
| Algorithm type | Hybrid: Content-based for cold start, Collaborative filtering for refinement | MEDIUM |
| Integration with JITAI | Separate system, shared context | LOW |
| Feedback loop | Implicit (habit completion) + Explicit (thumbs up/down) | MEDIUM |
| Rate limiting | Max 1 recommendation/day, suppress after 2 dismissals | LOW |

### Sub-Questions (Answer Each Explicitly)

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Algorithm Selection:** Content-based, Collaborative Filtering, or Hybrid? | Compare tradeoffs for identity-aligned recommendations. Consider cold-start problem with new users. |
| 2 | **Facet-Awareness:** How should recommendations incorporate active facet + facet topology? | Propose algorithm that respects energy states and facet switching costs. |
| 3 | **JITAI Integration:** Should proactive recommendations use same bandit or separate system? | Recommend architecture with rationale. Consider: (a) Same bandit with new arms, (b) Separate proactive bandit, (c) Rule-based layer on top of JITAI. |
| 4 | **Feedback Loop:** How do we learn if recommendations worked? | Design feedback signals: implicit (completion rate, streak length) vs explicit (user ratings). |
| 5 | **Rejection Handling:** How should we handle dismissed recommendations? | Propose snooze/dismiss/never-show-again taxonomy with algorithmic consequences. |
| 6 | **Rate Limiting:** How often should recommendations appear? | Propose frequency and suppression rules to avoid overwhelm. |
| 7 | **Cold Start:** How do we recommend before we have user history? | Propose onboarding-based seeding strategy using dimension vector + facets. |

### Anti-Patterns to Avoid
- ❌ Requiring explicit user ratings for every recommendation (high friction)
- ❌ Overwhelming users with multiple daily suggestions
- ❌ Recommending habits that conflict with active facet's energy state
- ❌ Ignoring switching costs when recommending facet transitions
- ❌ Treating all users the same regardless of dimension profile

### Output Required
1. **Recommended algorithm** with pseudocode or decision tree
2. **Integration architecture** showing relationship to JITAI
3. **Feedback loop design** with signal priorities
4. **Rate limiting rules** with rationale
5. **Cold start strategy** using existing onboarding data
6. **Confidence Assessment** — rate each recommendation HIGH/MEDIUM/LOW

---

## Research Question 2: RQ-006 — Content Library for Recommendations

### Core Question
What content library structure and minimum content set is needed to support identity-aligned proactive recommendations?

### Why This Matters
Algorithms cannot optimize without content variants. The content library is the "vocabulary" of the Identity Coach.

### The Problem
**Current State:** JITAI has 7 intervention arms × 4 dimensional framings = 28 messages. No proactive recommendation content exists.

**Required:** Content taxonomy for:
- Habit recommendations (new habit suggestions)
- Ritual templates (routine suggestions)
- Progression milestones (identity development stages)
- Regression warnings (pattern-based alerts)

### Current Hypothesis (Validate or Refine)

| Category | Estimated Quantity | Confidence |
|----------|-------------------|------------|
| Habit templates | 50+ | MEDIUM |
| Ritual templates | 20+ | LOW |
| Progression milestones | 10+ | LOW |
| Regression warnings | 15+ | MEDIUM |
| Goal alignment prompts | 30+ | LOW |

### Sub-Questions (Answer Each Explicitly)

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Universal Starter Habits:** What habits have evidence-based broad appeal? | Cite research (e.g., BJ Fogg's Tiny Habits, James Clear) for universally effective starter habits. |
| 2 | **Ritual Templates:** What ritual types are needed? | Propose taxonomy: morning, evening, transition, recovery. Define structure for each. |
| 3 | **Progression Milestones:** What identity development stages are meaningful? | Validate or refine: 7 days, 21 days, 66 days, 6 months, 1 year. Cite habit formation research. |
| 4 | **Dimensional Framing:** How should content vary by dimension? | Provide example framings for each of 6 dimensions. |
| 5 | **Facet-Specific Content:** Should content vary by facet type? | Propose whether "Devoted Father" gets different content than "Ambitious Programmer". |
| 6 | **Regression Messaging:** How do we warn without shame? | Propose messaging principles for regression alerts that don't trigger Maladaptive Perfectionism. |
| 7 | **Minimum Viable Set:** What's the smallest content set for launch? | Apply CD-018 threshold: ESSENTIAL content only. |

### Anti-Patterns to Avoid
- ❌ Generic content that doesn't reflect dimension profile
- ❌ Shame-based regression warnings (triggers Maladaptive Perfectionism)
- ❌ Too many content pieces (maintenance burden)
- ❌ Content requiring manual curation per user

### Output Required
1. **Content taxonomy** with categories and subcategories
2. **Template structure** for each content type (fields, variables)
3. **Dimensional framing matrix** (6 dimensions × 2 poles × key content types)
4. **Minimum viable content set** for launch (ESSENTIAL only)
5. **Regression messaging guidelines** that avoid shame
6. **Confidence Assessment** — rate each recommendation HIGH/MEDIUM/LOW

---

## Research Question 3: RQ-007 — Identity Roadmap Architecture

### Core Question
How do we architect the full flow from user aspirations to AI-guided habit recommendations in a psyOS context?

### Why This Matters
This is the "how it all fits together" question. RQ-005 defines algorithms, RQ-006 defines content, RQ-007 defines the complete data flow.

### The Problem
**The Required Flow:**
```
User shares dreams/fears (Sherlock onboarding)
    → AI extracts aspirational identity
    → AI constructs "Identity Roadmap"
    → App recommends habits/rituals per facet
    → Tracks progress toward aspiration
    → JITAI intervenes when at risk
    → Identity Coach guides growth
```

**Missing Pieces:**
1. What IS an "Identity Roadmap"?
2. How do aspirations become facets?
3. How do we track progress toward identity (not just habits)?

### Current Hypothesis (Validate or Refine)

| Component | Hypothesis | Confidence |
|-----------|------------|------------|
| Identity Roadmap data structure | Directed graph: aspiration → facets → habits | MEDIUM |
| Aspiration extraction | Sherlock already extracts Holy Trinity; extend for aspirations | LOW |
| Progress metric | Weighted habit completion per facet over time | LOW |

### Sub-Questions (Answer Each Explicitly)

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Aspiration Extraction:** How should Sherlock extract aspirational identity? | Propose questions or prompts to add to onboarding. |
| 2 | **Roadmap Data Structure:** What schema represents an Identity Roadmap? | Propose SQL/Dart model. Must integrate with existing `identity_facets` table. |
| 3 | **Aspiration → Facet Mapping:** How do user aspirations become facets? | Propose algorithm or LLM prompt strategy. |
| 4 | **Habit → Aspiration Matching:** How do we recommend habits that serve aspirations? | Propose matching algorithm. |
| 5 | **Progress Metrics:** How do we measure progress toward identity (not just habit completion)? | Propose "Identity Consolidation Score" or equivalent. |
| 6 | **Regression Detection:** How do we detect identity drift before habits break? | Propose leading indicators. |
| 7 | **Visualization:** How should the Identity Roadmap be presented to users? | Propose UX concept (text-based OK, no Figma needed). |

### Anti-Patterns to Avoid
- ❌ Requiring users to explicitly define roadmap (too much friction)
- ❌ Static roadmaps that don't adapt to behavior
- ❌ Progress metrics that punish missed days (triggers Maladaptive Perfectionism)
- ❌ Overly complex data structures that require graph databases (we use PostgreSQL only)

### Output Required
1. **Aspiration extraction prompts** for Sherlock onboarding
2. **Identity Roadmap schema** (SQL, integrates with existing tables)
3. **Aspiration → Facet mapping algorithm**
4. **Habit recommendation algorithm** (integrates with RQ-005)
5. **Identity Consolidation Score** formula
6. **Regression leading indicators** list
7. **UX concept** for roadmap visualization
8. **Confidence Assessment** — rate each recommendation HIGH/MEDIUM/LOW

---

## Architectural Constraints (Hard Requirements)

| Constraint | Rule |
|------------|------|
| **Database** | Supabase (PostgreSQL + pgvector). No graph databases. |
| **AI Models** | DeepSeek V3.2 (analyst), DeepSeek R1 Distilled (reasoning). |
| **Client** | Flutter (Android-first per CD-017). |
| **Battery** | < 5% daily impact budget. Passive detection limited. |
| **JITAI** | Thompson Sampling bandit is LOCKED. Cannot change core algorithm. |
| **Facets** | Already exist in `identity_facets` table with embeddings. |
| **Energy States** | 4-state model LOCKED (high_focus, high_physical, social, recovery). |

---

## Existing Schema Context

```sql
-- Already exists: identity_facets
CREATE TABLE identity_facets (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  name TEXT NOT NULL,
  facet_type TEXT, -- 'role', 'value', 'aspiration'
  description TEXT,
  embedding vector(768),
  created_at TIMESTAMPTZ,
  energy_signature JSONB -- {high_focus: 0.8, social: 0.2, ...}
);

-- Already exists: identity_topology
CREATE TABLE identity_topology (
  source_facet_id UUID REFERENCES identity_facets(id),
  target_facet_id UUID REFERENCES identity_facets(id),
  interaction_type TEXT, -- 'synergistic', 'antagonistic', 'competitive', 'neutral'
  friction_coefficient FLOAT,
  switching_cost_minutes INT,
  PRIMARY KEY (source_facet_id, target_facet_id)
);

-- Already exists: habits
CREATE TABLE habits (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  name TEXT NOT NULL,
  description TEXT,
  frequency TEXT,
  created_at TIMESTAMPTZ
);

-- Already exists: habit_facet_links (polymorphic habits)
CREATE TABLE habit_facet_links (
  habit_id UUID REFERENCES habits(id),
  facet_id UUID REFERENCES identity_facets(id),
  weight FLOAT DEFAULT 1.0, -- Contribution weight
  custom_metrics JSONB,
  PRIMARY KEY (habit_id, facet_id)
);
```

---

## Output Quality Criteria

| Criterion | Question to Ask |
|-----------|-----------------|
| **Implementable** | Can an engineer build this without clarifying questions? |
| **Grounded** | Are recommendations supported by cited literature? |
| **Consistent** | Does this integrate with existing schema and JITAI? |
| **Actionable** | Are there concrete next steps? |
| **Bounded** | Are edge cases handled? |
| **Android-First** | Does this work with Android-available signals only? |
| **Threshold-Aware** | Is each component classified ESSENTIAL/VALUABLE/NICE-TO-HAVE? |

---

## Example of Good Output (Quality Bar)

**Example for RQ-005, Sub-Question 1:**

> **Algorithm Selection:** HYBRID (Content-based + Collaborative)
>
> **Reasoning:**
> 1. Cold-start users have no history → content-based uses dimension vector + facets
> 2. After 14 days of behavior → blend in collaborative signals
>
> **Algorithm:**
> ```python
> def recommend_habit(user, available_habits):
>     # Phase 1: Content-based score (always available)
>     content_scores = []
>     for habit in available_habits:
>         score = cosine_similarity(user.dimension_vector, habit.ideal_dimension_vector)
>         score *= facet_alignment(user.active_facet, habit.linked_facets)
>         score *= energy_state_match(user.current_energy, habit.optimal_energy)
>         content_scores.append((habit, score))
>
>     # Phase 2: Collaborative boost (after 14 days)
>     if user.days_active >= 14:
>         similar_users = find_similar_users(user, k=50)
>         collab_scores = aggregate_similar_user_completions(similar_users, available_habits)
>         # Blend: 60% content, 40% collaborative
>         final_scores = [(h, 0.6*c + 0.4*collab_scores.get(h, 0)) for h, c in content_scores]
>     else:
>         final_scores = content_scores
>
>     return sorted(final_scores, key=lambda x: -x[1])[:3]
> ```
>
> **Confidence:** HIGH — Hybrid approaches are well-validated in recommendation literature (Koren et al., 2009; Burke, 2002).
>
> **Threshold Classification:** ESSENTIAL — Cannot have Identity Coach without recommendation algorithm.

---

## Final Checklist Before Submitting

- [ ] Each sub-question has explicit answer
- [ ] All schemas include field types and constraints
- [ ] All algorithms include pseudocode
- [ ] Confidence levels stated for each recommendation
- [ ] Anti-patterns addressed
- [ ] User scenarios solved step-by-step
- [ ] Integration points with existing schema explicit
- [ ] Android-First signals used (no wearable-only data)
- [ ] Each proposal classified per CD-018 threshold

---

## Post-Processing Reminder (For Receiving Agent)

**MANDATORY:** Before integrating ANY output from this Deep Think session:

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  STOP. Run Protocol 9 (External Research Reconciliation)                     │
│                                                                              │
│  □ Phase 1: Locked Decision Audit (check against CDs 005, 015, 016, 017, 018)│
│  □ Phase 2: Data Reality Audit (Android-first verification)                  │
│  □ Phase 3: Implementation Reality Audit (existing code check)               │
│  □ Phase 4: Scope & Complexity Audit (ESSENTIAL → OVER-ENGINEERED)           │
│  □ Phase 5: Categorize each proposal (ACCEPT/MODIFY/REJECT/ESCALATE)         │
│  □ Phase 6: Create reconciliation document in docs/analysis/                 │
│                                                                              │
│  Only THEN integrate into Core Docs.                                         │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

*End of Prompt*
