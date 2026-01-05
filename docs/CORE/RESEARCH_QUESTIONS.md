# RESEARCH_QUESTIONS.md — Active Research & Open Questions

> **Last Updated:** 05 January 2026
> **Purpose:** Track active research informing product/architecture decisions
> **Owner:** Oliver (with AI agent research support)

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
| **Status** | IN RESEARCH |
| **Blocking** | PD-001 (Archetype Philosophy) |
| **Researchers** | ChatGPT, Gemini, Claude |
| **Target** | Scientifically-grounded archetype buckets for JITAI population learning |

**Current State:**
- 6 hardcoded archetypes: PERFECTIONIST, REBEL, PROCRASTINATOR, OVERTHINKER, PLEASURE_SEEKER, PEOPLE_PLEASER
- Mix of Rubin's Four Tendencies + general behavioral patterns
- No empirical validation of bucket boundaries

**Research Approach:**
1. **Prioritization:** Parsimony + Interpretability first (cold-start math requires data density)
2. **Sources:** Peer-reviewed + preprints + JITAI lab grey literature
3. **Population:** Self-selecting productivity/identity app users (25-45, knowledge workers, prior self-improvement attempts)

**Key Sub-Questions:**
- [ ] Do current 6 archetypes map to distinct intervention responses?
- [ ] What does JITAI literature use for behavioral segmentation?
- [ ] Should we use continuous dimensions instead of discrete buckets?
- [ ] How many users per bucket needed for population learning convergence?

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
| **Status** | TEMPLATE READY |
| **Action** | ChatGPT to populate after research |

**Template (to be filled by ChatGPT):**

| Dimension | In Literature? | We Track? | Interpretability | Implementation Gap |
|-----------|---------------|-----------|------------------|-------------------|
| Autonomy Need | ✅ SDT | ⚠️ Inferred from REBEL | High | No direct measure |
| Shame Sensitivity | ✅ Brené Brown | ❌ | Medium | Not tracked |
| Friction Tolerance | ✅ BJ Fogg | ⚠️ Inferred from tiny version usage | High | Indirect only |
| Reward Timing Pref | ✅ Behavioral Econ | ❌ | Medium | Not tracked |
| External Validation Need | ✅ Rubin (Obliger) | ⚠️ Inferred from witness usage | High | Indirect only |
| ... | ... | ... | ... | ... |

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
| 05 Jan 2026 | ChatGPT | Intervention Effectiveness | ✅ COMPLETE — Validated reward function, added literature mapping | Integrated into RQ-002 |
| 05 Jan 2026 | Gemini | Deep Research | IN PROGRESS — 7-point plan on archetype dimensions | Awaiting results |
| 05 Jan 2026 | Gemini Deep Think | Synthesis | PENDING — Will compare ChatGPT + Gemini findings | Awaiting Gemini completion |
| 05 Jan 2026 | Claude | Research coordination | Aligned both agents' parameters for comparison | ✅ Done |
| 05 Jan 2026 | Claude | Codebase audit | Documented current intervention measurement | ✅ Done |
| 05 Jan 2026 | ChatGPT | Clarification Qs | Asked about effectiveness measurement | ✅ Answered |
| 05 Jan 2026 | Gemini | Archetype analysis | Identified 6-bucket cold-start math | Hybrid recommended |

---

## Decision Dependencies

```
RQ-001 (Archetype Taxonomy)
    ├── Depends on: RQ-002 (How do we measure success?)
    ├── Depends on: RQ-003 (What do we already track?)
    └── Blocks: PD-001 (Archetype Philosophy decision)
                PD-102 (JITAI hardcoded vs AI)
```

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
