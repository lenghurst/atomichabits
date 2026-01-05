# IDENTITY_COACH_SPEC.md — AI-Driven Identity Development System

> **Last Updated:** 05 January 2026
> **Status:** SPECIFICATION DRAFT — Requires research validation
> **Priority:** CRITICAL — This IS the core value proposition
> **Identified By:** Oliver (05 Jan 2026)
> **Related Decision:** CD-008 (Identity Development Coach)

---

## The Core Distinction

```
JITAI = WHEN to intervene (reactive timing)
Content Library = WHAT to say in interventions
Identity Coach = WHO to become + HOW to get there
```

**The Identity Coach is not an add-on — it's the reason the app exists.**

---

## The Gap

### Current State: REACTIVE System (JITAI)
```
User at risk → JITAI detects → Intervention triggered
```

The Pact currently has a sophisticated JITAI system that:
- Detects vulnerability/opportunity states
- Selects interventions via Thompson Sampling
- Learns which interventions work per user
- Reacts to problems

**What's Missing:** A system that answers the fundamental questions:
1. **Who does the user want to become?** (Aspirational Identity)
2. **What habits/rituals will get them there?** (Recommendations)
3. **What's the next step in their identity journey?** (Progression)
4. **What patterns are pulling them backward?** (Regression Detection)
5. **Are their current habits aligned with their stated identity?** (Coherence)

---

## The Identity Coach

### Core Concept
An AI-driven life coach that constructs and guides identity development — not just accountability, but transformation.

**Value Proposition Shift:**
- From: "We help you stick to habits" (accountability app)
- To: "We help you become who you want to be" (identity transformation coach)

### System Components

```
PROACTIVE ANALYTICS ENGINE
│
├── 1. HABIT RECOMMENDER
│   ├── "Based on your profile, you might benefit from X"
│   ├── Identity-aligned suggestions
│   ├── Gap-filling habits (values → behaviors)
│   └── Difficulty calibration per dimension
│
├── 2. RITUAL DESIGNER
│   ├── Morning/evening routine suggestions
│   ├── Stacking recommendations
│   ├── Dimension-aware sequencing
│   └── Energy-aware scheduling
│
├── 3. PROGRESSION PATHFINDER
│   ├── "Your next identity milestone"
│   ├── Skill tree navigation
│   ├── Level-up criteria
│   └── Growth trajectory visualization
│
├── 4. REGRESSION DETECTOR
│   ├── Pattern-based warning system
│   ├── "We've seen this pattern before..."
│   ├── Preemptive intervention triggers
│   └── Cascade risk forecasting
│
├── 5. GOAL ALIGNMENT ENGINE
│   ├── "This habit conflicts with your stated values"
│   ├── Coherence scoring
│   ├── Priority recommendations
│   └── Value-behavior gap surfacing
│
└── 6. ANTI-IDENTITY GUARDIAN
    ├── "This behavior reinforces your feared self"
    ├── Shadow pattern detection
    ├── Resistance Lie activation warnings
    └── Identity drift alerts
```

---

## How It Differs from JITAI

| Aspect | JITAI (Reactive) | Proactive Engine |
|--------|------------------|------------------|
| **Trigger** | User at risk | Always running |
| **Goal** | Prevent failure | Enable growth |
| **Output** | Intervention message | Recommendation + rationale |
| **Timing** | Just-in-time | Anticipatory |
| **Learning** | What interventions work | What progressions work |
| **User State** | Vulnerability/Opportunity | Trajectory/Potential |

---

## Integration with 6-Dimension Model

The Proactive Engine uses dimensions to personalize recommendations:

| Dimension | Recommendation Adaptation |
|-----------|---------------------------|
| **Regulatory Focus** | Promotion: "Try this new challenge" / Prevention: "Protect this progress" |
| **Autonomy/Reactance** | High: "Here's an option when you're ready" / Low: "Here's what to do next" |
| **Action-State** | Executor: "Add this to your stack" / Overthinker: "Just try this tiny step" |
| **Temporal Discounting** | Present: "Quick win opportunity" / Future: "Building toward your vision" |
| **Perfectionism** | Adaptive: "Optimize your routine" / Maladaptive: "Permission to be imperfect" |
| **Social Rhythmicity** | Stable: "Stack on your 7am coffee" / Chaotic: "Flexible micro-habits" |

---

## Data Requirements

### Input Signals
```
ALREADY AVAILABLE:
├── Behavioral history (completions, misses, streaks)
├── Time patterns (when they succeed/fail)
├── Dimension vector (6 floats)
├── Holy Trinity (Anti-Identity, Archetype, Resistance Lie)
├── Stated goals and values
├── JITAI intervention outcomes
└── Voice session transcripts (RAG)

NEED TO ADD:
├── User-reported satisfaction with habits
├── Energy/mood correlations
├── "Graduated" habit markers
├── Aspiration statements (dreams, fears)
└── Life context changes (job, relationship, health)
```

### Output Format
```dart
class ProactiveRecommendation {
  final RecommendationType type;        // HABIT, RITUAL, PROGRESSION, WARNING
  final String title;                   // "Try a 5-minute meditation"
  final String rationale;               // "Your Overthinker pattern suggests..."
  final double confidence;              // 0.0-1.0
  final String dimensionalFraming;      // Adapted to user's profile
  final List<String> supportingEvidence; // What data supports this
  final bool isUrgent;                  // Regression warning vs growth opportunity
}
```

---

## Research Required

> **Note:** These research questions are now canonical in `RESEARCH_QUESTIONS.md`.
> RQ-005 and RQ-006 below match the canonical definitions.

### RQ-005: Proactive Recommendation Algorithms

| Sub-Question | Notes |
|--------------|-------|
| What algorithms recommend identity-aligned goals? | Collaborative filtering? Content-based? Hybrid? |
| How do we avoid overwhelming users? | Rate limiting, importance scoring |
| How does this integrate with JITAI? | Same bandit? Separate system? (See PD-105) |
| What's the feedback loop? | How do we learn if recommendations worked? |
| How do we handle user rejection? | Snooze vs dismiss vs never show again |

**Status:** 🔴 NEEDS RESEARCH — See `RESEARCH_QUESTIONS.md` RQ-005

### RQ-006: Content Library for Recommendations

| Sub-Question | Notes |
|--------------|-------|
| What habits are "universal starters"? | Evidence-based default recommendations |
| How many ritual templates needed? | Morning, evening, transition, recovery |
| What progression milestones are meaningful? | 7 days, 21 days, 66 days, 1 year? |
| How do we phrase warnings without shame? | Regression messaging strategy |

**Status:** 🔴 NEEDS RESEARCH — See `RESEARCH_QUESTIONS.md` RQ-006

---

## Implementation Phases

**Note:** Per AI_AGENT_PROTOCOL.md, we default to final version. Phases listed only where genuine blockers exist.

### Phase A: Foundation (No Blockers)
- [ ] Define `ProactiveRecommendation` data model
- [ ] Create `ProactiveEngine` service class
- [ ] Wire to existing dimension vector
- [ ] Add basic rule-based recommendations

### Phase B: Intelligence (Depends on Content)
- [ ] Habit recommendation templates (content blocker)
- [ ] Ritual templates (content blocker)
- [ ] Progression milestone definitions (content blocker)
- [ ] Regression pattern library (content blocker)

### Phase C: Learning (Depends on Data)
- [ ] Recommendation outcome tracking
- [ ] A/B testing framework
- [ ] Personalization model training
- [ ] Population learning for recommendations

---

## Content Library Requirements

This ties directly to the Content Library gap identified by Deep Think:

```
JITAI CONTENT (Reactive):
└── 7 arms × 4 framings = 28 messages

PROACTIVE CONTENT (Growth):
├── 50+ habit recommendation templates
├── 20+ ritual templates
├── 10+ progression path templates
├── 15+ regression warning templates
└── 30+ goal alignment prompts

TOTAL: ~125+ content pieces needed
```

**Blocker:** The algorithm cannot optimize without content variants.

---

## Success Metrics

### App Perspective
- Recommendation acceptance rate
- User engagement after recommendation
- Reduction in reactive interventions needed
- Retention correlation

### User Perspective
- Habit completion rate for recommended habits
- Progress toward stated goals
- Self-reported value alignment
- Identity consolidation score improvement

---

## Open Questions for Human Decision

| # | Question | Options | Recommendation |
|---|----------|---------|----------------|
| 1 | Priority vs JITAI | (A) Build in parallel, (B) After JITAI stable | A — Different value prop |
| 2 | AI model | (A) DeepSeek, (B) Gemini, (C) New model | DeepSeek (already analyst role) |
| 3 | UI placement | (A) Dashboard section, (B) Separate screen, (C) In-feed | Dashboard section |
| 4 | Frequency | (A) Daily recommendation, (B) Weekly, (C) On-demand | Daily with dismiss option |

---

## Relationship to Other Roadmap Items

```
PROACTIVE ENGINE
├── Depends on: Dimension Model (RQ-001) ✅ COMPLETE
├── Depends on: Content Library (GAP IDENTIFIED)
├── Enables: True AI life coaching value prop
├── Complements: JITAI (reactive + proactive = complete system)
└── Blocks: Nothing (additive feature)
```

