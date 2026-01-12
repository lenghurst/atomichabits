# JITAI Decisions — Intelligence Layer

> **Domain:** JITAI
> **Token Budget:** <10k
> **Load:** When working on intelligence, interventions, timing, context sensing
> **Dependencies:** PD_CORE.md (always load first)
> **Related RQs:** RQ-014, RQ-020, RQ-023, RQ-038

---

## Quick Reference

| PD# | Decision | Phase | Status | Blocking RQ |
|-----|----------|-------|--------|-------------|
| PD-102 | JITAI Hardcoded vs AI | B | PENDING | RQ-038 |
| PD-116 | Population Learning Privacy | B | PENDING | RQ-023 |
| PD-117 | ContextSnapshot Real-time Data | B | RESOLVED | — |

---

## Context: JITAI Architecture

**JITAI = Just-In-Time Adaptive Interventions**

The JITAI system decides:
- **WHEN** to intervene (timing optimization)
- **HOW** to intervene (arm selection via Thompson Sampling)
- **WHAT** context signals inform the decision

**Full Architecture:** See `lib/domain/services/jitai_decision_engine.dart`

---

## PD-102: JITAI Hardcoded vs AI

| Field | Value |
|-------|-------|
| **Phase** | B (Backend) |
| **Question** | Should JITAI decision logic be hardcoded rules or AI-driven? |
| **Status** | PENDING |
| **Blocking RQ** | RQ-038 (JITAI Component Allocation Strategy) |

### Options

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| **A: Hardcoded** | Rule-based V-O calculation | Predictable, debuggable | Rigid, can't adapt |
| **B: Hybrid** | Rules + AI for edge cases | Balance of control and flexibility | Complexity |
| **C: AI-Driven** | ML model for all decisions | Adaptive, learns patterns | Black box, debugging hard |

### Current Implementation

Hardcoded rules with Thompson Sampling for arm selection:
- V-O State calculation (rule-based)
- Safety gates (rule-based)
- Arm selection (bandit algorithm)

### CD-016 Constraint

DeepSeek V3.2 for analyst tasks, R1 Distilled for reasoning.
If AI-driven, use appropriate model.

---

## PD-116: Population Learning Privacy

| Field | Value |
|-------|-------|
| **Phase** | B (Backend) |
| **Question** | How to share learning across users while preserving privacy? |
| **Status** | PENDING |
| **Blocking RQ** | RQ-023 (Population Learning Privacy Framework) |

### The Challenge

Better JITAI requires learning from population patterns:
- "Users with archetype X respond better to intervention Y"
- "Time of day Z has higher success rate for habit type W"

But this requires:
- Aggregating user data
- Privacy-preserving techniques
- Regulatory compliance (GDPR, CCPA)

### Options Under Consideration

| Option | Privacy Level | Learning Quality |
|--------|---------------|------------------|
| **A: No population learning** | Maximum privacy | Limited learning |
| **B: Differential privacy** | High privacy | Good learning |
| **C: Federated learning** | High privacy | Best learning |
| **D: Opt-in aggregated** | User-controlled | Variable |

---

## PD-117: ContextSnapshot Real-time Data ✅ RESOLVED

| Field | Value |
|-------|-------|
| **Phase** | B (Backend) |
| **Decision** | ContextSnapshot includes real-time sensors where available |
| **Status** | RESOLVED |
| **Research** | RQ-014 (State Economics) |

### What's Included

```dart
ContextSnapshot {
  TimeContext time;          // Hour, day, weekend
  BiometricContext? bio;     // Sleep, HRV z-scores (if Health Connect)
  CalendarContext? calendar; // Busyness, meetings
  WeatherContext? weather;   // Outdoor suitability
  LocationContext? location; // Home, work, gym
  DigitalContext? digital;   // Distraction level
  HistoricalContext history; // Streak, identity score
}
```

### CD-017 Constraint

Android-first. All context sources must work on Android:
- Health Connect (Android 14+)
- Calendar provider (Android standard)
- Location services (standard)
- OpenWeatherMap API (cross-platform)

---

## JITAI Configuration Constants

From `lib/config/jitai_config.dart`:

| Constant | Value | Purpose |
|----------|-------|---------|
| `minCheckInterval` | 15 min | Battery saving |
| `periodicCheckInterval` | 30 min | Background checks |
| `maxInterventionsPerDay` | 5 | Fatigue prevention |
| `minInterventionInterval` | 2 hours | Per-habit cooldown |
| `cascadeRiskThreshold` | 0.5 | Proactive intervention trigger |
| `minTimingScore` | 0.35 | Minimum to trigger intervention |

---

## Related Research Questions

| RQ# | Title | Status | Blocks |
|-----|-------|--------|--------|
| RQ-014 | State Economics & Bio-Energetic Conflicts | COMPLETE | PD-117 |
| RQ-020 | Treaty-JITAI Integration | COMPLETE | — |
| RQ-023 | Population Learning Privacy | NEEDS RESEARCH | PD-116 |
| RQ-038 | JITAI Component Allocation Strategy | NEEDS RESEARCH | PD-102 |

---

## Cross-Domain Connections

| Related Domain | Connection |
|----------------|------------|
| **WITNESS** | Witness JITAI extends this for outward-facing notifications (PD-134) |
| **IDENTITY** | Identity Coach uses JITAI for proactive recommendations |
| **UX** | JITAI drives notification content and timing |

---

*JITAI decisions define how the app intelligently adapts to user context.*
