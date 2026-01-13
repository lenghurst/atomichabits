# Deep Think Prompt: RQ-048 — Identity Facets Schema Field Validation

> **Target Research:** RQ-048 (parent), RQ-048a, RQ-048b, RQ-048c
> **Prepared:** 13 January 2026
> **For:** Google Deep Think / Gemini / DeepSeek
> **App Name:** The Pact
> **Origin:** Weak reasoning identified in reconciliation audit (`docs/analysis/AUDIT_DEEP_THINK_RECONCILIATION_A01_A02.md`)

---

## Your Role

You are a **Senior Research Synthesizer** specializing in:
- Identity psychology and self-concept theory
- Cognitive load theory and working memory limits
- Chronobiology and task switching research
- Evidence-based UX parameter design

Your approach: Ground ALL recommendations in peer-reviewed research. Distinguish between established findings (HIGH confidence), reasonable extrapolations (MEDIUM confidence), and educated guesses (LOW confidence). Cite sources.

---

## PART 1: WHAT IS "THE PACT"? (Essential Context)

**You have no prior knowledge of this project. This section provides essential context.**

### The App in One Paragraph

The Pact is a mobile app (Flutter, Android-first) that helps users build identity-based habits through psychological insight and social accountability. Unlike traditional habit trackers that count streaks, The Pact treats users as having multiple "identity facets" (e.g., "The Writer," "The Athlete," "The Present Father") that negotiate for attention. Users create "pacts" — commitments to become a certain type of person.

### Core Philosophy: "Parliament of Selves"

The Pact is built on **psyOS (Psychological Operating System)** — a framework that models human identity as:

1. **One Integrated Self** with multiple **facets** (not competing personalities)
2. **Facets** can be synergistic, antagonistic, or competitive
3. **Energy States** affect which facets can be active (4-state model: high_focus, high_physical, social, recovery)
4. **Switching Costs** represent time needed to transition between energy states
5. **Conflicts** between facets are integration opportunities, not failures

### Why This Research Matters

During schema reconciliation for the `identity_facets` table, **four decisions were made with weak reasoning**:

| Decision | Stated Rationale | Problem |
|----------|------------------|---------|
| **4 domains** (professional, physical, relational, temporal) | "7 may be over-specified for MVP" | No user research or literature cited |
| **10 active facet cap** | "15 seems excessive" | Gut feeling, no cognitive load research |
| **30 min switching cost default** | "Research suggests 15-90 min range" | Which research? No citation |
| **ai_voice_prompt rejected** | "NICE-TO-HAVE" | Already resolved (will include) |

**This research validates or revises the first three decisions.**

---

## PART 2: Critical Instruction — Processing Order

```
RQ-048a (Domain Taxonomy)
  ↓ Informs available categories for...
RQ-048b (Facet Capacity)
  ↓ Informs cognitive budget for...
RQ-048c (Switching Costs)
  ↓ All three produce...
VALIDATED SCHEMA PARAMETERS
```

**Process in this exact order.** Each sub-RQ builds on the previous.

---

## PART 3: Research Questions

### RQ-048a: Facet Domain Taxonomy

**Core Question:** What categorical taxonomy best captures the breadth of human identity facets while remaining cognitively manageable?

**Current State:**
- Deep Think proposed 7 domains: professional, physical, relational, temporal, intellectual, creative, spiritual
- Reconciliation cut to 4 domains: professional, physical, relational, temporal
- Audit suggested 5 domains: add "growth" (merge intellectual + creative)

**The Problem:**
The cut from 7→4 was arbitrary. But 7 may genuinely be too many. We need evidence-based guidance on:
1. What domain categories appear in identity psychology literature?
2. What level of granularity is cognitively optimal?
3. Are there domains that users commonly express that don't fit into the current 4?

**Sub-Questions:**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Literature Review:** What identity domain taxonomies exist in psychology literature (e.g., Markus & Nurius "Possible Selves", Oyserman's identity-based motivation)? | Cite 3-5 frameworks with their domain categories |
| 2 | **Overlap Analysis:** Which domains from literature map to our current 4 (professional, physical, relational, temporal)? What's missing? | Create mapping table |
| 3 | **User Expression Analysis:** When people describe "who they want to become," what categories do they naturally use? | Cite user research or qualitative studies |
| 4 | **Cognitive Constraints:** Is there a literature-supported optimal number of identity categories? (Related to RQ-048b) | Cite chunking/categorization research |
| 5 | **Recommendation:** Given the above, what is the optimal domain list for The Pact? | Provide final list with rationale |

**Anti-Patterns to Avoid:**
- ❌ Proposing domains based on what "feels comprehensive"
- ❌ Using philosophical categories (mind/body/spirit) without user evidence
- ❌ Ignoring cultural variation in identity salience

**Output Required:**
1. Literature synthesis table (framework → domains → coverage)
2. Gap analysis (what's missing from current 4 domains)
3. Recommended domain list with confidence level
4. Rationale for each domain (include/exclude)

---

### RQ-048b: Cognitive Load Facet Limits

**Core Question:** What is the evidence-based optimal limit for active identity facets before cognitive overload occurs?

**Current State:**
- UI displays 5 facets (soft limit)
- Database allows 10 active facets (hard cap)
- Deep Think proposed 15 (rejected as "excessive")
- No citation provided for any of these numbers

**The Problem:**
The 5/10 split was arbitrary. We need research-grounded limits considering:
1. Working memory constraints (Miller's 7±2, Cowan's 4)
2. Identity integration complexity (more facets = more conflict pairs)
3. Cognitive load from facet management (switching, tracking, scheduling)

**Sub-Questions:**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Working Memory:** What does cognitive load theory say about managing multiple identity goals simultaneously? | Cite Sweller, Cowan, or relevant researchers |
| 2 | **Identity Fragmentation:** Does self-concept research identify a threshold where multiple selves become overwhelming? | Cite Markus, McConnell, or identity integration research |
| 3 | **Goal Management:** What does goal-setting research (e.g., Locke & Latham) say about optimal number of active goals? | Cite specific findings |
| 4 | **Complexity Analysis:** With N facets, there are N(N-1)/2 potential conflict pairs. At what N does this become unmanageable? | Provide mathematical + cognitive analysis |
| 5 | **UI Precedent:** Do any identity/habit apps have published research on their limits? (Streaks, Fabulous, etc.) | Cite if available |
| 6 | **Recommendation:** What should the soft limit (UI) and hard cap (database) be? | Provide specific numbers with rationale |

**Anti-Patterns to Avoid:**
- ❌ Citing Miller's 7±2 without considering that this applies to short-term memory, not identity management
- ❌ Ignoring the difference between "number of facets" and "cognitive load of managing facets"
- ❌ Using round numbers (5, 10, 15) without justification

**Output Required:**
1. Research synthesis on cognitive limits for identity/goal management
2. Conflict complexity analysis (N facets → N(N-1)/2 pairs)
3. Recommended soft limit + hard cap with confidence levels
4. Edge case handling (what happens when user has 20 genuine facets?)

---

### RQ-048c: Energy State Switching Cost Defaults

**Core Question:** What are evidence-based default values for switching costs between energy states?

**Current State:**
- Reconciliation set default to 30 minutes
- Stated rationale: "Research suggests 15-90 min range; 30 is safer middle ground"
- No specific research was cited

**The Problem:**
Switching costs directly affect:
1. JITAI intervention timing (don't suggest high_focus task if user just finished social mode)
2. Schedule feasibility calculation (can user really do these 3 things in sequence?)
3. Conflict friction coefficients

We need actual research on context switching, attention residue, and bio-energetic recovery.

**Key Definitions:**

| Energy State | Description | Example Activities |
|--------------|-------------|-------------------|
| **high_focus** | Deep cognitive work requiring sustained attention | Writing, coding, strategic planning |
| **high_physical** | Exercise or physical activity | Running, gym, sports |
| **social** | Interpersonal interaction | Meetings, family time, social events |
| **recovery** | Rest and recharge | Sleep, meditation, passive relaxation |

**Sub-Questions:**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Attention Residue:** What does Sophie Leroy's research say about task switching recovery time? | Cite specific findings with time ranges |
| 2 | **Ultradian Rhythms:** Does chronobiology research suggest natural transition periods between work modes? | Cite Peretz Lavie or similar |
| 3 | **Exercise Recovery:** How long before cognitive performance returns to baseline after physical exercise? | Cite sports psychology / cognitive research |
| 4 | **Social→Focus:** Is there research on transition time from social interaction to deep work? | Cite if available |
| 5 | **Individual Variation:** How much do switching costs vary between individuals? Should we use fixed defaults or user-calibrated values? | Cite relevant research |
| 6 | **Recommendation:** What should the default switching_cost_minutes be for each state pair? | Provide matrix with confidence levels |

**Anti-Patterns to Avoid:**
- ❌ Assuming symmetric switching costs (focus→social ≠ social→focus)
- ❌ Using single default for all transitions
- ❌ Ignoring that some transitions are easier than others (e.g., recovery→anything is usually quick)

**Output Required:**
1. Research synthesis on context switching / attention residue
2. Switching cost matrix (source state × target state)
3. Confidence levels for each estimate
4. Recommendation: fixed defaults vs user-calibrated

---

## PART 4: Architectural Constraints

| Constraint | Rule |
|------------|------|
| **Database** | PostgreSQL via Supabase — ENUM types for domains |
| **Energy Model** | EXACTLY 4 states: high_focus, high_physical, social, recovery — NOT 5 |
| **Mobile-First** | Parameters must work on Android without wearable data |
| **User Burden** | Users should NOT have to manually configure switching costs |
| **MVP Scope** | Prefer simpler solutions; complexity can be added later |

---

## PART 5: Output Quality Criteria

| Criterion | Question to Ask |
|-----------|-----------------|
| **Evidence-Based** | Is every number grounded in cited research? |
| **Actionable** | Can an engineer implement this without clarification? |
| **Bounded** | Are edge cases addressed? |
| **Confidence-Rated** | Is each recommendation rated HIGH/MEDIUM/LOW? |

---

## PART 6: Example of Good Output

**For RQ-048c Sub-Question 1 (Attention Residue):**

```markdown
### Sub-Question 1: Attention Residue Research

**Finding:** Sophie Leroy (2009) found that switching tasks while the prior task is
incomplete creates "attention residue" lasting **15-25 minutes** on average.

**Key Insight:** The residue is LONGER when:
- Prior task was engaging (high cognitive demand)
- Prior task was incomplete (Zeigarnik effect)
- New task requires different cognitive mode

**Implication for The Pact:**
- high_focus → social: ~25 min (high residue due to deep work interruption)
- social → high_focus: ~15 min (social tasks rarely incomplete)
- recovery → anything: ~5 min (low cognitive load to release)

**Confidence:** MEDIUM — Leroy's research was on task switching, not specifically
energy state transitions. Extrapolation is reasonable but unvalidated.

**Citation:** Leroy, S. (2009). Why is it so hard to do my work? The challenge of
attention residue when switching between work tasks. Organizational Behavior and
Human Decision Processes, 109(2), 168-181.
```

---

## PART 7: Final Checklist Before Submitting

- [ ] Each sub-question has explicit answer with citation
- [ ] All recommendations include confidence level (HIGH/MEDIUM/LOW)
- [ ] Research synthesis tables provided for each RQ
- [ ] Gaps in literature acknowledged (don't invent research)
- [ ] Practical recommendations implementable in PostgreSQL/Flutter
- [ ] Edge cases addressed (what if user has unusual profile?)
- [ ] Cultural variation considered for domain taxonomy

---

## PART 8: Deliverables Summary

| RQ | Deliverable |
|----|-------------|
| **RQ-048a** | Recommended domain ENUM list with literature rationale |
| **RQ-048b** | Soft limit (UI) + hard cap (DB) numbers with cognitive research support |
| **RQ-048c** | Switching cost matrix (4×4 energy states) with time values |
| **All** | Confidence ratings and citations for every recommendation |

---

*End of Prompt*
