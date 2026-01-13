# Deep Think Prompt: RQ-048c — Energy State Switching Cost Defaults

> **Parent RQ:** RQ-048 — Identity Facets Schema Field Validation
> **This Sub-RQ:** RQ-048c — Energy State Switching Cost Defaults
> **SME Domains:** Chronobiology, Cognitive Psychology, Task Switching Research, Sports Science
> **Prepared:** 13 January 2026
> **For:** Google Deep Think / Gemini / DeepSeek
> **App Name:** The Pact
> **Urgency:** HIGH — Schema field `switching_cost_minutes DEFAULT 30` is MEDIUM confidence and blocks JITAI timing logic

---

## Your Role

You are a **Senior Research Synthesizer** specializing in:
- Chronobiology and ultradian rhythms
- Cognitive psychology of task switching and attention residue
- Sports science and post-exercise cognitive recovery
- Evidence-based parameter design for behavioral applications

**Your approach:**
1. Ground ALL recommendations in peer-reviewed research
2. Cite specific studies with authors, years, and key findings
3. Distinguish between: established findings (HIGH confidence), reasonable extrapolations (MEDIUM confidence), and educated guesses (LOW confidence)
4. Acknowledge when literature is sparse — don't invent research

---

## PART 1: WHAT IS "THE PACT"? (Essential Context)

**You have no prior knowledge of this project. This section provides essential context.**

### The App in One Paragraph

The Pact is a mobile app (Flutter, Android-first) that helps users build identity-based habits through psychological insight. Unlike traditional habit trackers that count streaks, The Pact treats users as having multiple "identity facets" (e.g., "The Writer," "The Athlete," "The Present Father") that negotiate for attention. The app's intelligence layer schedules interventions based on the user's current **energy state** and the **switching costs** between states.

### Core Philosophy: "Parliament of Selves"

The Pact is built on **psyOS (Psychological Operating System)** — a framework that models human identity as:

1. **One Integrated Self** with multiple **facets** (not competing personalities)
2. **Energy States** affect which facets can be active at any time
3. **Switching Costs** represent the recovery time needed to transition between states
4. **Conflicts** between facets create friction that the app helps users navigate

### The 4-State Energy Model (LOCKED — Cannot Change)

The Pact uses a **4-state energy model** (this is a confirmed decision — CD-015):

| State | Code | Description | Example Activities |
|-------|------|-------------|-------------------|
| **Deep Focus** | `high_focus` | Sustained cognitive attention, minimal interruption tolerance | Writing, coding, strategic planning, deep reading, creative work |
| **Physical** | `high_physical` | Elevated heart rate, physical exertion | Running, gym workout, sports, yoga, manual labor |
| **Social** | `social` | Interpersonal interaction, emotional engagement | Meetings, family dinner, phone calls, networking events |
| **Recovery** | `recovery` | Rest, low cognitive/physical demand | Sleep, meditation, TV, casual browsing, napping |

**Why only 4 states?** Research shows that finer granularity (e.g., distinguishing "creative focus" from "analytical focus") adds complexity without proportional benefit. These 4 states capture the major bio-energetic modes that affect task compatibility.

### Why Switching Costs Matter

**Switching costs** are used by the app's JITAI (Just-In-Time Adaptive Intervention) system to:

1. **Avoid bad timing:** Don't suggest a high_focus task immediately after a social event
2. **Calculate schedule feasibility:** Can the user realistically do Task A, then Task B, then Task C in sequence?
3. **Compute friction:** Higher switching costs between facets = higher conflict friction
4. **Inform the Council AI:** When facets "debate," switching costs affect which facet should yield

**Current Problem:** The schema sets `switching_cost_minutes DEFAULT 30` with no citation. The rationale was "research suggests 15-90 min range; 30 is safer middle ground" — but which research? This prompt seeks evidence-based values.

---

## PART 2: The Research Question

### RQ-048c: Energy State Switching Cost Defaults

**Core Question:** What are evidence-based default values (in minutes) for the time required to transition between energy states?

**Why This Matters:**

| Impact Area | How Switching Costs Affect It |
|-------------|------------------------------|
| **JITAI Timing** | System won't suggest deep work if user just finished a social event (respects recovery time) |
| **Schedule Validation** | User wants to do Gym → Meeting → Writing. Is 30 min between each realistic? |
| **Conflict Scoring** | Facets with high switching costs between them have higher friction_coefficient |
| **User Experience** | Wrong defaults = interventions feel poorly timed = user frustration |

**Current State:**
- Database field: `switching_cost_minutes INT DEFAULT 30`
- Confidence: MEDIUM (arbitrary "middle ground")
- No citation provided
- Treats all transitions as symmetric and equal

**The Problem:**
1. Is 30 minutes the right default?
2. Should all transitions have the same default, or should we use a matrix?
3. Are transitions symmetric (focus→social = social→focus)?
4. How much individual variation exists?

---

## PART 3: Structured Sub-Questions

### Sub-Question 1: Attention Residue Literature

**Question:** What does Sophie Leroy's "attention residue" research say about task switching recovery time?

**Context:** Leroy (2009) introduced the concept that switching tasks leaves "residue" from the prior task that impairs performance on the new task.

**Your Task:**
- Summarize key findings with specific time ranges
- Identify conditions that increase/decrease residue duration
- Assess applicability to energy state transitions (not just task switching)

**Output Required:**
- Citation with author, year, journal
- Specific time range findings (e.g., "15-25 minutes")
- Conditions that affect duration
- Confidence level for extrapolation to energy states

---

### Sub-Question 2: Ultradian Rhythms

**Question:** Does chronobiology research suggest natural transition periods between work modes?

**Context:** Peretz Lavie and others have documented ~90-minute ultradian cycles in human alertness and cognitive performance.

**Your Task:**
- Summarize ultradian rhythm research relevant to state transitions
- Identify if there are natural "transition windows" between cycles
- Assess whether these rhythms suggest optimal switching times

**Output Required:**
- Key researchers and findings (Lavie, Kleitman, others)
- Cycle duration and transition characteristics
- Implication for switching_cost_minutes
- Confidence level

---

### Sub-Question 3: Post-Exercise Cognitive Recovery

**Question:** How long after physical exercise does cognitive performance return to baseline?

**Context:** The `high_physical → high_focus` transition is critical. Users who exercise before deep work need to know when their cognitive capacity is restored.

**Your Task:**
- Summarize sports psychology / cognitive science research on post-exercise cognition
- Distinguish between:
  - Immediate post-exercise effects (first 0-20 min)
  - Short-term effects (20-60 min)
  - Delayed benefits (exercise improves cognition after recovery)
- Identify optimal timing for cognitive work after exercise

**Output Required:**
- Citations from sports psychology literature
- Time ranges for cognitive recovery by exercise intensity
- Specific recommendation for high_physical → high_focus
- Confidence level

---

### Sub-Question 4: Social Interaction → Deep Focus Transition

**Question:** Is there research on the transition time from social interaction to deep cognitive work?

**Context:** The `social → high_focus` transition is common (e.g., meeting ends, user wants to write). How long before full focus capacity is restored?

**Your Task:**
- Search for research on social → cognitive transitions
- If direct research is sparse, identify related findings (e.g., "social fatigue," "introvert recharge time")
- Consider emotional residue from social interactions

**Output Required:**
- Available citations (acknowledge if sparse)
- Best estimate with rationale
- Factors that might increase/decrease this transition time
- Confidence level

---

### Sub-Question 5: Recovery State Transitions

**Question:** How quickly can someone transition FROM recovery state to other states?

**Context:** Recovery (rest, sleep, meditation) is the "lowest energy" state. Intuitively, transitions FROM recovery should be easier than transitions TO recovery.

**Your Task:**
- Assess whether recovery → anything transitions are faster
- Consider sleep inertia research (waking up → full alertness)
- Consider meditation research (post-meditation alertness)

**Output Required:**
- Citations if available
- Estimated transition times: recovery → high_focus, recovery → high_physical, recovery → social
- Asymmetry analysis (is FROM recovery faster than TO recovery?)
- Confidence level

---

### Sub-Question 6: Transition Asymmetry

**Question:** Are energy state transitions symmetric (A→B = B→A) or asymmetric?

**Context:** The current schema uses a single `switching_cost_minutes` value per edge. If transitions are asymmetric, we need a matrix approach.

**Your Task:**
- Analyze whether each transition pair is symmetric
- Provide evidence for asymmetry where it exists
- Recommend: single default vs. per-transition defaults vs. full 4x4 matrix

**Output Required:**
- Analysis table for each direction pair
- Recommendation with rationale
- Schema implication (do we need separate source→target and target→source edges?)

---

### Sub-Question 7: Individual Variation

**Question:** How much do switching costs vary between individuals? Should we use fixed defaults or user-calibrated values?

**Context:** Some people switch contexts easily; others need long transition buffers. The app could:
- Option A: Use population-average defaults (simpler)
- Option B: Let users calibrate their own values (personalized but burdensome)
- Option C: Use AI to learn individual patterns over time (sophisticated)

**Your Task:**
- Assess literature on individual differences in context switching
- Consider personality factors (introversion/extraversion, ADHD, etc.)
- Recommend approach for MVP

**Output Required:**
- Evidence for individual variation magnitude
- Factors that predict switching ability
- Recommendation: fixed defaults vs. calibration vs. AI learning
- MVP pragmatism assessment

---

### Sub-Question 8: Final Switching Cost Matrix

**Question:** Given all the above research, what should the default `switching_cost_minutes` be for each state pair?

**Your Task:**
Provide a complete 4×4 matrix:

| FROM ↓ / TO → | high_focus | high_physical | social | recovery |
|---------------|------------|---------------|--------|----------|
| **high_focus** | — | ? min | ? min | ? min |
| **high_physical** | ? min | — | ? min | ? min |
| **social** | ? min | ? min | — | ? min |
| **recovery** | ? min | ? min | ? min | — |

For each cell:
- Provide recommended default value
- Cite supporting evidence
- Rate confidence (HIGH/MEDIUM/LOW)

---

## PART 4: Anti-Patterns to Avoid

```
❌ Assuming all transitions are equal (they're not)
❌ Assuming transitions are symmetric without evidence
❌ Citing Miller's 7±2 (working memory, not relevant here)
❌ Using round numbers (15, 30, 45, 60) without justification
❌ Inventing research that doesn't exist (acknowledge sparse literature)
❌ Ignoring that "recovery" includes both sleep and light rest
❌ Treating exercise as monolithic (intensity matters)
❌ Assuming social interactions are all equivalent (meeting vs. party)
```

---

## PART 5: Architectural Constraints

| Constraint | Rule |
|------------|------|
| **Energy Model** | EXACTLY 4 states: high_focus, high_physical, social, recovery — NOT 5 |
| **Database** | `switching_cost_minutes INT` — single integer per edge |
| **Asymmetry Handling** | If asymmetric, we create TWO edges (A→B and B→A) with different values |
| **User Burden** | Users should NOT manually configure these — defaults must be reasonable |
| **Wearable Data** | NOT available for MVP (Android-first, no watch) |
| **AI Calibration** | Possible future enhancement, but not required for defaults |

---

## PART 6: Output Quality Criteria

| Criterion | Question to Ask |
|-----------|-----------------|
| **Evidence-Based** | Is every number grounded in cited research? |
| **Specific** | Are time ranges given (not vague "some time")? |
| **Asymmetry-Aware** | Are directional differences addressed? |
| **Confidence-Rated** | Is each cell rated HIGH/MEDIUM/LOW? |
| **Actionable** | Can an engineer implement the matrix without clarification? |
| **Honest** | Are gaps in literature acknowledged? |

---

## PART 7: Example of Good Output

**For Sub-Question 3 (Post-Exercise Cognitive Recovery):**

```markdown
### Sub-Question 3: Post-Exercise Cognitive Recovery

**Literature Summary:**

Chang et al. (2012) meta-analysis of 79 studies found:
- **Immediate post-exercise (0-15 min):** Cognitive performance is IMPAIRED
  - Executive function ↓ during this window
  - Heart rate and arousal still elevated
- **Short-term (15-60 min):** Performance returns to baseline, then IMPROVES
  - Peak cognitive benefit at ~20-30 min post moderate exercise
  - BDNF release enhances neuroplasticity
- **Exercise intensity matters:**
  - Light exercise (walking): Minimal impairment, 5-10 min recovery
  - Moderate exercise (jogging): 15-20 min to baseline
  - High-intensity (HIIT, sprints): 30-45 min to baseline

**Recommendation for high_physical → high_focus:**
- Default: **25 minutes**
- Rationale: Assumes moderate exercise; allows heart rate to normalize and executive function to recover
- If user did HIIT: 40 minutes would be more appropriate (but we use population average)

**Confidence:** MEDIUM
- Chang et al. meta-analysis is robust for exercise → cognition
- BUT: "high_focus" in our app is broader than lab cognitive tasks
- Individual variation is significant (fitness level affects recovery)

**Citation:** Chang, Y. K., Labban, J. D., Gapin, J. I., & Etnier, J. L. (2012).
The effects of acute exercise on cognitive performance: A meta-analysis.
Brain Research, 1453, 87-101.
```

---

## PART 8: Deliverables Summary

| Deliverable | Description |
|-------------|-------------|
| **Switching Cost Matrix** | 4×4 table with default minutes for each transition |
| **Confidence Ratings** | HIGH/MEDIUM/LOW for each cell |
| **Citations** | At least 5 peer-reviewed sources |
| **Asymmetry Analysis** | Which transitions are directionally different? |
| **Implementation Recommendation** | Single default vs. matrix approach |
| **Individual Variation Guidance** | Fixed defaults vs. calibration for MVP |

---

## PART 9: Final Checklist Before Submitting

- [ ] Each sub-question has explicit answer
- [ ] All 12 matrix cells have values (excluding diagonal)
- [ ] Each value has confidence rating
- [ ] At least 5 citations provided
- [ ] Asymmetry explicitly addressed for each pair
- [ ] Gaps in literature honestly acknowledged
- [ ] Recommendations are implementable in PostgreSQL INT field
- [ ] Individual variation magnitude estimated
- [ ] MVP pragmatism considered (not over-engineered)

---

## PART 10: Schema Context (For Reference)

The switching cost appears in this table:

```sql
CREATE TABLE identity_topology (
  source_facet_id UUID NOT NULL,
  target_facet_id UUID NOT NULL,
  user_id UUID NOT NULL,

  interaction_type interaction_type_enum NOT NULL,
  friction_coefficient FLOAT DEFAULT 0.0,
  switching_cost_minutes INT DEFAULT 30,  -- ← THIS IS WHAT WE'RE VALIDATING

  PRIMARY KEY (source_facet_id, target_facet_id)
);
```

**Current default:** 30 minutes
**Current confidence:** MEDIUM (no citation)
**Your task:** Validate, modify, or provide evidence-based alternative

---

*End of Prompt*
