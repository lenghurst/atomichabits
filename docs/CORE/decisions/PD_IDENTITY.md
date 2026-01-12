# Identity Decisions — Identity Coach & Archetypes

> **Domain:** IDENTITY
> **Token Budget:** <12k
> **Load:** When working on Identity Coach, Sherlock, archetypes, dimensions
> **Dependencies:** PD_CORE.md (always load first)
> **Related RQs:** RQ-005-007, RQ-028-032, RQ-034-037

---

## Quick Reference

| PD# | Decision | Phase | Status | Blocking RQ |
|-----|----------|-------|--------|-------------|
| PD-003 | Holy Trinity Validity | F | READY | RQ-037 ✅ |
| PD-101 | Sherlock Prompt Overhaul | F | RESHAPED | RQ-034 |
| PD-103 | Sensitivity Detection | F | PENDING | RQ-035 |
| PD-105 | Unified AI Coaching Architecture | F, G | READY | RQ-005,6,7 ✅ |
| PD-107 | Proactive Guidance System | F, G | READY | RQ-005,6,7 ✅ |
| PD-121 | Archetype Template Count | G | RESOLVED | — |
| PD-122 | Preference Embedding Visibility | G | RESOLVED | — |
| PD-123 | Facet Typical Energy State | G | RESOLVED | — |
| PD-124 | Recommendation Card Staleness | G | RESOLVED | — |
| PD-125 | Content Library Size at Launch | F | RESOLVED | — |

---

## Context: Identity Coach Architecture

**Identity Coach = WHO to become + HOW to get there**

The Identity Coach answers:
1. "Who does the user want to become?" (Aspirational Identity)
2. "What habits/rituals will get them there?" (Habit Recommendations)
3. "What's the next step in their identity journey?" (Progression Path)
4. "What patterns are pulling them backward?" (Regression Detection)
5. "Are current habits aligned with stated identity?" (Coherence)

**Full Specification:** See `IDENTITY_COACH_SPEC.md`

---

## PD-003: Holy Trinity Validity 🟢 READY

| Field | Value |
|-------|-------|
| **Phase** | F |
| **Question** | Is the Holy Trinity model (Anti-Identity, Failure Archetype, Resistance Lie) valid? |
| **Status** | READY (Research complete, awaiting decision) |
| **Research** | RQ-037 ✅ COMPLETE |

### Research Finding

RQ-037 validated the model but renamed it:
- **Holy Trinity → Shadow Cabinet**
- **Components:** Shadow, Saboteur, Script

### Recommendation

Adopt Shadow Cabinet terminology:
- **Shadow:** Who user fears becoming
- **Saboteur:** The pattern that causes failure
- **Script:** The lie that justifies inaction

---

## PD-101: Sherlock Prompt Overhaul 🟡 RESHAPED

| Field | Value |
|-------|-------|
| **Phase** | F |
| **Question** | How should Sherlock's conversational extraction be structured? |
| **Status** | RESHAPED (partially unblocked) |
| **Blocking RQ** | RQ-034 (Sherlock Conversation Architecture) |

### What's Resolved (RQ-037)

- Day 1 Sherlock extracts Shadow Cabinet
- Triangulation Protocol validates extraction
- Narrative synthesis creates "identity story"

### What's Pending (RQ-034)

- Conversation flow architecture
- Turn-taking strategy
- Error recovery patterns
- Multi-session continuity

---

## PD-103: Sensitivity Detection

| Field | Value |
|-------|-------|
| **Phase** | F |
| **Question** | How to detect and handle sensitive topics in Sherlock conversations? |
| **Status** | PENDING |
| **Blocking RQ** | RQ-035 (Sensitivity Detection Framework) |

### Sensitivity Concerns

- Mental health disclosures
- Trauma references
- Self-harm indicators
- Relationship distress

### CD-010 Constraint

User success > App engagement. Must handle sensitively:
- Appropriate referrals
- Boundary setting
- Professional handoff when needed

---

## PD-105: Unified AI Coaching Architecture 🟢 READY

| Field | Value |
|-------|-------|
| **Phase** | F, G |
| **Question** | How should Identity Coach, JITAI, and Content Library integrate? |
| **Status** | READY (Research complete) |
| **Research** | RQ-005, RQ-006, RQ-007 ✅ COMPLETE |

### Recommended Architecture

```
┌─────────────────────────────────────────────┐
│           IDENTITY COACH (Brain)            │
│  • Aspirational identity tracking           │
│  • Progression path planning                │
│  • Regression detection                     │
│  • Orchestrates WHEN and WHAT               │
└───────────────────┬─────────────────────────┘
                    │
        ┌───────────┴───────────┐
        ↓                       ↓
┌───────────────┐     ┌───────────────┐
│ JITAI (When)  │     │ Content (What)│
│ Timing engine │     │ Message lib   │
└───────────────┘     └───────────────┘
```

---

## PD-107: Proactive Guidance System 🟢 READY

| Field | Value |
|-------|-------|
| **Phase** | F, G |
| **Question** | How should the proactive recommendation system work? |
| **Status** | READY (Research complete) |
| **Research** | RQ-005, RQ-006, RQ-007 ✅ COMPLETE |

### Recommendation Pipeline

1. **Semantic Retrieval:** pgvector similarity on preference_embeddings
2. **Psychometric Re-ranking:** 6-dimension alignment scoring
3. **ICS Calculation:** Identity Coherence Score
4. **Pace Car Filtering:** Rate limiting based on user capacity

---

## PD-121: Archetype Template Count ✅ RESOLVED

| Field | Value |
|-------|-------|
| **Phase** | G |
| **Decision** | 12 archetype templates at launch |
| **Status** | RESOLVED |
| **Research** | RQ-028 |

### The 12 Archetypes

1. The Achiever
2. The Caregiver
3. The Creator
4. The Explorer
5. The Rebel
6. The Sage
7. The Magician
8. The Hero
9. The Lover
10. The Jester
11. The Ruler
12. The Innocent

---

## PD-122: Preference Embedding Visibility ✅ RESOLVED

| Field | Value |
|-------|-------|
| **Phase** | G |
| **Decision** | Preference embedding is HIDDEN from users |
| **Status** | RESOLVED |
| **Research** | RQ-030 |
| **Rationale** | Technical implementation detail, not user-facing |

---

## PD-123: Facet Typical Energy State ✅ RESOLVED

| Field | Value |
|-------|-------|
| **Phase** | G |
| **Decision** | Add `typical_energy_state` field to identity_facets |
| **Status** | RESOLVED |
| **Values** | high_focus, high_physical, social, recovery (CD-015 constraint) |

---

## PD-124: Recommendation Card Staleness ✅ RESOLVED

| Field | Value |
|-------|-------|
| **Phase** | G |
| **Decision** | 7-day TTL for recommendation cards |
| **Status** | RESOLVED |
| **Rationale** | Cards that aren't acted on become stale |

---

## PD-125: Content Library Size at Launch ✅ RESOLVED

| Field | Value |
|-------|-------|
| **Phase** | F |
| **Decision** | 50 universal habit templates at launch |
| **Status** | RESOLVED |
| **Caveat** | Must cover all 12 archetypes meaningfully |

---

## PD-119: Summon Token Economy 🟡 DEFERRED

| Field | Value |
|-------|-------|
| **Phase** | G |
| **Question** | How should Council Seals be earned and spent? |
| **Status** | DEFERRED |
| **Research** | RQ-039 (7 sub-RQs) |

### Council Seals Defined

Council Seals are earned tokens that allow users to:
- Summon emergency Council sessions
- Unlock advanced Council features
- Demonstrate commitment to treaties

### Deferred Reason

Bias analysis revealed 8 unvalidated assumptions about:
- Earning mechanics fairness
- Spending economy balance
- Gamification psychology impact

RQ-039 created with 7 sub-RQs to investigate.

---

## Related Research Questions

| RQ# | Title | Status | Blocks |
|-----|-------|--------|--------|
| RQ-005 | Proactive Recommendation Algorithms | COMPLETE | — |
| RQ-006 | Content Library for Recommendations | COMPLETE | — |
| RQ-007 | Identity Roadmap Architecture | COMPLETE | — |
| RQ-028 | Archetype Template Definitions | COMPLETE | — |
| RQ-029 | Ideal Dimension Vector Curation | COMPLETE | — |
| RQ-030 | Preference Embedding Update Mechanics | COMPLETE | — |
| RQ-031 | Pace Car Threshold Validation | COMPLETE | — |
| RQ-032 | ICS Integration with Existing Metrics | COMPLETE | — |
| RQ-034 | Sherlock Conversation Architecture | NEEDS RESEARCH | PD-101 |
| RQ-035 | Sensitivity Detection Framework | NEEDS RESEARCH | PD-103 |
| RQ-037 | Holy Trinity Model Validation | COMPLETE | PD-003 |

---

*Identity decisions define how The Pact guides users toward their aspirational selves.*
