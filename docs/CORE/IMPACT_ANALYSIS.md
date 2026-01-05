# IMPACT_ANALYSIS.md — Research-to-Roadmap Traceability

> **Last Updated:** 05 January 2026
> **Purpose:** Track how research findings impact roadmap elements
> **Trigger:** Updated automatically when research concludes or decisions are made

---

## What This Document Is

This document ensures research findings **cascade through the entire system**. When research concludes:
1. Every roadmap item is evaluated for impact
2. New questions/research points are logged
3. Dependencies are updated
4. This document is updated

---

## Current Research: 6-Dimension Archetype Model (RQ-001)

### Research Summary
- **Source:** ChatGPT + Gemini Deep Research + Gemini Deep Think synthesis
- **Outcome:** 6-dimension continuous model with 4 UI clusters
- **Status:** COMPLETE — Awaiting implementation decisions

### The 6 Dimensions
1. Regulatory Focus (Promotion ↔ Prevention)
2. Autonomy/Reactance (Rebel ↔ Conformist)
3. Action-State Orientation (Executor ↔ Overthinker)
4. Temporal Discounting (Future ↔ Present)
5. Perfectionistic Reactivity (Adaptive ↔ Maladaptive)
6. Social Rhythmicity (Stable ↔ Chaotic)
7. **PROPOSED:** Social Sensitivity (if social features exist)

---

## Impact Analysis: Roadmap Elements

### Layer 1: The Evidence Engine (Foundation)

| Task | Impact | Action Required |
|------|--------|-----------------|
| E6: Evidence API | **HIGH** | API must log dimension-relevant signals (decision_time_ms, schedule_entropy, push-pull ratio) |
| Schema | **MEDIUM** | Add `user_dimensions` table with 6-float vector |

**New Questions:**
- Should dimensions be stored in `identity_seeds` or separate table?
- How often should dimensions be recalculated?

---

### Layer 2: The Shadow & Values Profiler (Onboarding)

| Task | Impact | Action Required |
|------|--------|-----------------|
| Sherlock Profiler | **CRITICAL** | Must extract dimension-relevant traits, not just Holy Trinity |
| Voice Wand | **MEDIUM** | 3-min recording must capture enough signal for 4 dimensions |

**New Questions:**
- Does Sherlock need to ask dimension-specific questions?
- Should we add 3 binary onboarding questions BEFORE Sherlock for cold-start?
- How do we map Holy Trinity → 6 Dimensions?

**Mapping Hypothesis:**
| Holy Trinity | Maps To |
|--------------|---------|
| Anti-Identity | Regulatory Focus (Prevention) + Perfectionistic Reactivity |
| Failure Archetype | Action-State Orientation + Temporal Discounting |
| Resistance Lie | Autonomy/Reactance + Action-State Orientation |

---

### Layer 3: The Living Garden Visualization (UI)

| Task | Impact | Action Required |
|------|--------|-----------------|
| Rive Integration | **MEDIUM** | Garden state should reflect dimensional profile |
| Dynamic Inputs | **HIGH** | Add dimension vector as Rive input |
| Atmospherics | **LOW** | Weather effects can remain emotion-based |

**New Questions:**
- Should garden show "Rebel" vs "Conformist" visually?
- Can we represent 6D space in 2D garden metaphor?

---

### Layer 4: The Conversational Command Line (Interaction)

| Task | Impact | Action Required |
|------|--------|-----------------|
| Voice Interaction | **HIGH** | AI persona should adapt to Autonomy/Reactance dimension |
| Command parsing | **LOW** | No change needed |

**New Questions:**
- Should "Rebel" users get a different AI persona entirely?
- How do we handle dimension-aware message variants?

---

### Layer 5: Philosophical Intelligence (The Brain)

| Task | Impact | Action Required |
|------|--------|-----------------|
| Gap Analysis Engine | **CRITICAL** | Must incorporate dimensions into gap detection |
| Socratic Generator | **HIGH** | Questions should be framed per Regulatory Focus |

**New Questions:**
- Promotion user: "What could you achieve if..."
- Prevention user: "What might you lose if..."
- Should Gap Analysis weight different behavioral signals per dimension?

---

### Track A-F: Weekly Build Plan

| Track | Impact | Action Required |
|-------|--------|-----------------|
| Track A: Database | **HIGH** | Add dimension storage to Evidence Repository |
| Track B: Voice | **CRITICAL** | Shadow Persona Prompting must be dimension-aware |
| Track C: Dashboard | **MEDIUM** | Bridge should show dimension-relevant habits first |
| Track D: Gap Analysis | **CRITICAL** | DeepSeek pipeline needs dimension context |
| Track E: Integration | **MEDIUM** | CLI commands should respect dimension preferences |
| Track F: Social | **HIGH** | Social Leaderboard now required for 7th dimension |

---

### Pending Decisions Impact

| Decision | Impact from Research | New Status |
|----------|---------------------|------------|
| PD-001: Archetype Philosophy | **RESOLVED** | 6-dimension model with 4 UI clusters |
| PD-002: Streaks vs Rolling | **IMPACTED** | Prevention users value Streak; Promotion users value Progress % |
| PD-003: Holy Trinity Validity | **IMPACTED** | Holy Trinity maps to dimensions, remains valid as extraction target |
| PD-004: Dev Mode | No impact | — |
| PD-101: Sherlock Prompt | **CRITICAL** | Must extract dimension signals, not just labels |
| PD-102: JITAI Hardcoded vs AI | **RESOLVED** | Dimensions = Context Vector for Bandit |
| PD-103: Sensitivity Detection | **IMPACTED** | Sensitivity may correlate with Perfectionistic Reactivity |
| PD-104: Loading Insights | **IMPACTED** | Insights should reflect user's dimensional profile |

---

## New Roadmap Elements Identified

### GAP IDENTIFIED: Proactive Analytics Engine

**Current State:** JITAI is REACTIVE (intervenes when things go wrong)
**Missing:** PROACTIVE recommendation system

**What's Needed:**
```
PROACTIVE ANALYTICS ENGINE
├── Habit Recommendations: "Based on your profile, try X"
├── Ritual Suggestions: "Morning routines for Overthinkers"
├── Progression Paths: "Your next identity milestone"
├── Regression Analysis: "Warning: Pattern suggests dropout risk"
├── Goal Alignment: "This habit conflicts with your stated values"
└── Anti-Identity Prevention: "This behavior reinforces your feared self"
```

**Priority:** HIGH — This elevates value proposition from "accountability app" to "AI life coach"

**Research Required:**
- What recommendation algorithms work for identity-based goals?
- How do we avoid overwhelming users with suggestions?
- How does this integrate with JITAI?

---

### GAP IDENTIFIED: Content Library

**Current State:** Generic intervention messages
**Required:** 4 message variants per trigger per dimension combination

**Content Matrix:**
| Dimension State | Message Framing |
|-----------------|-----------------|
| Promotion + Low Reactance | Eager ("Go for it!") |
| Prevention + Low Reactance | Vigilant ("Protect your progress") |
| Promotion + High Reactance | Autonomy-Supportive ("When you're ready...") |
| Prevention + High Reactance | Directive-Soft ("Your choice, but consider...") |

**Scale:** 7 intervention arms × 4 framings = 28 message templates minimum

---

### GAP IDENTIFIED: Social Leaderboard

**Status:** Not implemented
**Impact:** Enables 7th dimension (Social Sensitivity)
**Add to Roadmap:** Yes

---

## Follow-up Research Points

| ID | Question | Triggered By | Priority |
|----|----------|--------------|----------|
| FRQ-001 | How do dimensions evolve over time? | RQ-001 | HIGH |
| FRQ-002 | What's optimal content library size? | Deep Think | HIGH |
| FRQ-003 | Proactive recommendation algorithms for identity goals | Gap Analysis | CRITICAL |
| FRQ-004 | Social Sensitivity dimension validation | Decision: Add social features | MEDIUM |
| FRQ-005 | Dimension-to-Holy-Trinity mapping validation | PD-003 impact | MEDIUM |

---

## Revision History

| Date | Research/Decision | Roadmap Items Impacted | Changes Made |
|------|-------------------|------------------------|--------------|
| 05 Jan 2026 | RQ-001 Complete | All Layers, PD-001, PD-102, PD-002, PD-003, PD-101, PD-104 | Initial impact analysis |

