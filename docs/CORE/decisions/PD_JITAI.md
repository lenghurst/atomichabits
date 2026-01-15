# JITAI Decisions — Intelligence Layer

> **Domain:** JITAI
> **Token Budget:** <10k
> **Load:** When working on intelligence, interventions, timing, context sensing
> **Dependencies:** PD_CORE.md (always load first)
> **Related RQs:** RQ-010egh, RQ-014, RQ-020, RQ-023, RQ-038

---

## Quick Reference

| PD# | Decision | Phase | Status | Blocking RQ |
|-----|----------|-------|--------|-------------|
| PD-102 | JITAI Hardcoded vs AI | B | PENDING | RQ-038 |
| PD-116 | Population Learning Privacy | B | PENDING | RQ-023 |
| PD-117 | ContextSnapshot Real-time Data | B | RESOLVED | — |
| PD-140 | Activity Recognition uses Transition API | B | 🔵 OPEN | RQ-010g |
| PD-141 | Activity Confidence Thresholds | B | 🔵 OPEN | RQ-010g |
| PD-142 | V-O Opportunity Weight Modifiers | B | 🔵 OPEN | RQ-010g |
| PD-143 | Doze Mode Priority Levels | B | 🔵 OPEN | RQ-010h |
| PD-144 | Geofence Allocation Strategy | B | 🔵 OPEN | RQ-010e |
| PD-160 | JITAI Accuracy Contribution Model | B | 🔵 OPEN | RQ-010a |
| PD-161 | Digital Context Excluded from MVP | B | 🔵 OPEN | RQ-010a |
| PD-162 | Location Fallback Strategies | B | 🔵 OPEN | RQ-010b |
| PD-163 | Calendar Fallback Strategies | B | 🔵 OPEN | RQ-010b |
| PD-164 | Biometric Fallback Strategies | B | 🔵 OPEN | RQ-010b |
| PD-165 | WiFi SSID Invalid as Fallback | B | 🔵 OPEN | RQ-010a |

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

---

## PD-140: Activity Recognition uses Transition API 🔵 OPEN

| Field | Value |
|-------|-------|
| **Phase** | B (Backend) |
| **Decision** | Use Transition API (`ActivityTransitionRequest`) for activity recognition, not polling |
| **Status** | 🔵 OPEN |
| **Source RQ** | RQ-010g |

**Rationale:** Push-based approach uses ~0.5% battery vs ~4% for polling. Receives callbacks only on activity transitions (ENTER/EXIT), not continuous updates.

**Source:** `docs/analysis/DEEP_THINK_RESPONSE_RQ010egh_ANALYSIS.md` §1.1

**Alternatives Rejected:**
- `ActivityRecognitionClient.requestActivityUpdates()` — Polling-based, higher battery
- Third-party SDKs — Unnecessary abstraction

**CD-018 Tier:** ESSENTIAL

**Activities Tracked:** STILL, WALKING, RUNNING, ON_BICYCLE, IN_VEHICLE (TILTING excluded as noisy)

---

## PD-141: Activity Confidence Thresholds 🔵 OPEN

| Field | Value |
|-------|-------|
| **Phase** | B (Backend) |
| **Decision** | Activity-specific confidence thresholds for high-confidence determination |
| **Status** | 🔵 OPEN |
| **Source RQ** | RQ-010g |

**Rationale:** Different activities have different false-positive costs. IN_VEHICLE false positive could cause safety issues; STILL false positive is low-risk.

**Source:** `docs/analysis/DEEP_THINK_RESPONSE_RQ010egh_ANALYSIS.md` §1.2

**Threshold Values:**

| Activity | Threshold | Rationale |
|----------|-----------|-----------|
| STILL | 50% | Low risk — false positive = "user ignored" |
| WALKING | 65% | Transitional state, moderate confidence needed |
| RUNNING | 75% | High risk — false positive = annoying celebration |
| ON_BICYCLE | 75% | Mechanically similar to vehicle motion |
| IN_VEHICLE | 80% | Safety critical — suppresses visual nudges |

**Alternatives Rejected:** Single universal threshold (65%) — doesn't account for risk variation

**CD-018 Tier:** VALUABLE

---

## PD-142: V-O Opportunity Weight Modifiers 🔵 OPEN

| Field | Value |
|-------|-------|
| **Phase** | B (Backend) |
| **Decision** | Activity state modifies V-O opportunity score |
| **Status** | 🔵 OPEN |
| **Source RQ** | RQ-010g |

**Rationale:** User's physical activity indicates interruptibility. Still = available; In vehicle = do not disturb.

**Source:** `docs/analysis/DEEP_THINK_RESPONSE_RQ010egh_ANALYSIS.md` §1.3

**Modifier Values:**

| Activity State | Modifier | Rationale |
|----------------|----------|-----------|
| STILL (extended >15min) | +0.10 | Prime time for intervention |
| STILL (brief) | +0.05 | Available but may be transitional |
| WALKING | +0.05 | Good for audio/transition nudges |
| RUNNING | +0.15 | User engaged (for exercise habits) |
| ON_BICYCLE | -0.10 | Busy but interruptible |
| IN_VEHICLE | **-0.30** | SAFETY — suppress visual nudges |

**Alternatives Rejected:** Binary interruptible/not model — loses nuance

**CD-018 Tier:** VALUABLE

---

## PD-143: Doze Mode Priority Levels 🔵 OPEN

| Field | Value |
|-------|-------|
| **Phase** | B (Backend) |
| **Decision** | Four-tier priority system for Doze Mode survival |
| **Status** | 🔵 OPEN |
| **Source RQ** | RQ-010h |

**Rationale:** Different JITAI events have different urgency. Emergency alerts must wake device; pattern analysis can wait for maintenance window.

**Source:** `docs/analysis/DEEP_THINK_RESPONSE_RQ010egh_ANALYSIS.md` §1.4

**Priority Levels:**

| Urgency | Trigger | Doze Behavior | Use Case |
|---------|---------|---------------|----------|
| CRITICAL | FCM High Priority | Wakes device immediately | Witness "Help Me" alerts |
| HIGH | Transition API / Geofence | Wakes app ~10s | "Arrived at Gym" nudge |
| MEDIUM | WorkManager (Expedited) | Runs ASAP (quota) | Daily morning JITAI calc |
| LOW | WorkManager (Periodic) | Deferred to maintenance | Data sync, pattern analysis |

**Alternatives Rejected:** Single priority level — would drain battery or miss critical alerts

**CD-018 Tier:** ESSENTIAL

---

## PD-144: Geofence Allocation Strategy 🔵 OPEN

| Field | Value |
|-------|-------|
| **Phase** | B (Backend) |
| **Decision** | 100 geofence limit allocated as Fixed (5) + Active Habits (20) + Dynamic (75) |
| **Status** | 🔵 OPEN |
| **Source RQ** | RQ-010e |

**Rationale:** Android enforces 100 geofence limit per app. Must prioritize user-defined zones over dynamic recommendations.

**Source:** `docs/analysis/DEEP_THINK_RESPONSE_RQ010egh_ANALYSIS.md` §1.5

**Allocation:**

| Category | Count | Purpose |
|----------|-------|---------|
| Fixed | 5 | Core locations (Home, Work) |
| Active Habits | 20 | User-defined habit zones (Gym, Library) |
| Dynamic | 75 | AI-recommended or temporary zones |

**Privacy Note:** Store `zone_id` in history, not coordinates. Coordinates only in `user_zones` table.

**Alternatives Rejected:**
- First-come-first-served — could exhaust limit on low-value zones
- No dynamic zones — loses optimization opportunity

**CD-018 Tier:** VALUABLE

---

## PD-160: JITAI Accuracy Contribution Model 🔵 OPEN

| Field | Value |
|-------|-------|
| **Phase** | B (Backend) |
| **Decision** | JITAI accuracy model: 40% baseline (Time+History) + permission contributions |
| **Status** | 🔵 OPEN |
| **Source RQ** | RQ-010a |

**Rationale:** Time + History alone achieves ~40% accuracy based on Wood & Neal (2007) habit research. Additional permissions provide marginal improvements.

**Source:** `docs/analysis/DEEP_THINK_RECONCILIATION_RQ010ab_PERMISSION_ACCURACY.md`

**Contribution Model:**

| Permission | Contribution | Rationale |
|------------|--------------|-----------|
| Time + History (baseline) | 40% | Always available, context-stable behavior |
| Location | +20% | Enables energy state inference |
| Calendar | +15% | "Don't get uninstalled" — interrupt avoidance |
| Biometric (Health Connect) | +15% | Solves burnout detection; Android 14+ only |
| Activity Recognition | +10% | Low battery, high safety value (IN_VEHICLE) |
| Digital Context | 0% | DROPPED — high privacy cost, ambiguous signal |

**Alternatives Rejected:** Equal weighting — doesn't reflect marginal value differences

**CD-018 Tier:** ESSENTIAL

---

## PD-161: Digital Context Excluded from MVP 🔵 OPEN

| Field | Value |
|-------|-------|
| **Phase** | B (Backend) |
| **Decision** | Digital Context (app usage tracking) excluded from MVP JITAI |
| **Status** | 🔵 OPEN |
| **Source RQ** | RQ-010a |

**Rationale:** High privacy cost (PACKAGE_USAGE_STATS has 70-90% deny rate), high battery drain, ambiguous signal value (Instagram = recovery OR procrastination).

**Source:** `docs/analysis/DEEP_THINK_RECONCILIATION_RQ010ab_PERMISSION_ACCURACY.md`

**Decision:** Deprioritize `DigitalContext` from MVP JITAI calculations. May revisit post-launch if user research indicates value.

**Alternatives Rejected:** Include Digital Context with consent flow — over-engineered per CD-018

**CD-018 Tier:** ESSENTIAL (to exclude)

---

## PD-162: Location Fallback Strategies 🔵 OPEN

| Field | Value |
|-------|-------|
| **Phase** | B (Backend) |
| **Decision** | Three-tier fallback strategy when location permission denied |
| **Status** | 🔵 OPEN |
| **Source RQ** | RQ-010b |

**Rationale:** Graceful degradation maintains JITAI value even without GPS permission.

**Source:** `docs/analysis/DEEP_THINK_RECONCILIATION_RQ010ab_PERMISSION_ACCURACY.md`

**Fallback Strategies:**

| Strategy | Recovery | Friction | Implementation |
|----------|----------|----------|----------------|
| Semantic Time Blocks | 30-40% | LOW | User defines schedule: "I work 9-5 M-F" in onboarding |
| Manual Context Latch | 95% | HIGH | "I'm Here" button sets location context |
| Pattern Mining | 30% | NONE | Learn from time-based patterns after 2 weeks |

**Alternatives Rejected:** WiFi SSID inference — requires ACCESS_FINE_LOCATION on Android 8.1+

**CD-018 Tier:** VALUABLE

---

## PD-163: Calendar Fallback Strategies 🔵 OPEN

| Field | Value |
|-------|-------|
| **Phase** | B (Backend) |
| **Decision** | Three-tier fallback strategy when calendar permission denied |
| **Status** | 🔵 OPEN |
| **Source RQ** | RQ-010b |

**Rationale:** Calendar is the "don't get uninstalled" permission — interrupting meetings causes app deletion.

**Source:** `docs/analysis/DEEP_THINK_RECONCILIATION_RQ010ab_PERMISSION_ACCURACY.md`

**Fallback Strategies:**

| Strategy | Recovery | Friction | Implementation |
|----------|----------|----------|----------------|
| Focus Mode Timer | 60% | MEDIUM | User sets DND manually |
| Work-Hours Heuristic | 30% | NONE | Assume busy 9am-12pm, 2pm-5pm weekdays |
| Conservative Mode | SAFETY | NONE | Silent notifications during inferred busy times |

**CD-018 Tier:** ESSENTIAL (Conservative Mode prevents uninstalls)

---

## PD-164: Biometric Fallback Strategies 🔵 OPEN

| Field | Value |
|-------|-------|
| **Phase** | B (Backend) |
| **Decision** | Two-tier fallback strategy when Health Connect unavailable |
| **Status** | 🔵 OPEN |
| **Source RQ** | RQ-010b |

**Rationale:** Biometric data (sleep, HRV) is Android 14+ only. Must support older devices.

**Source:** `docs/analysis/DEEP_THINK_RECONCILIATION_RQ010ab_PERMISSION_ACCURACY.md`

**Fallback Strategies:**

| Strategy | Recovery | Friction | Implementation |
|----------|----------|----------|----------------|
| Energy Check Prompt | 80% | LOW (daily) | "How's your energy?" — 4-option picker matching CD-015 states |
| Circadian Default | 20% | NONE | Time-based energy inference (morning=high_focus, evening=recovery) |

**Energy Check Options:** `high_focus`, `high_physical`, `social`, `recovery` (per CD-015)

**CD-018 Tier:** VALUABLE

---

## PD-165: WiFi SSID Invalid as Fallback 🔵 OPEN

| Field | Value |
|-------|-------|
| **Phase** | B (Backend) |
| **Decision** | WiFi SSID cannot be used as location fallback — requires ACCESS_FINE_LOCATION |
| **Status** | 🔵 OPEN |
| **Source RQ** | RQ-010a |

**Rationale:** Since Android 8.1 (API 27), `WifiManager.getConnectionInfo()` requires `ACCESS_FINE_LOCATION`. If user denied location, they implicitly denied WiFi SSID access.

**Source:** `docs/analysis/DEEP_THINK_RECONCILIATION_RQ010ab_PERMISSION_ACCURACY.md`

**Technical Facts:**
- Android 8.0 (API 26): WiFi SSID requires `ACCESS_COARSE_LOCATION`
- Android 8.1 (API 27): WiFi SSID requires `ACCESS_FINE_LOCATION`
- Android 10 (API 29): Returns `<unknown ssid>` without location permission

**Decision:** REJECT WiFi SSID as location fallback. Use Semantic Time Blocks or Pattern Mining instead.

**Alternatives Rejected:** WiFi-based location inference — invalid on target API range (26+)

**CD-018 Tier:** ESSENTIAL (prevents invalid implementation)

---

## Cross-Domain Connections

| Related Domain | Connection |
|----------------|------------|
| **WITNESS** | Witness JITAI extends this for outward-facing notifications (PD-134) |
| **IDENTITY** | Identity Coach uses JITAI for proactive recommendations |
| **UX** | JITAI drives notification content and timing |
| **UX (NEW)** | Permission UX decisions (PD-150–155) gate when JITAI features are available |

---

*JITAI decisions define how the app intelligently adapts to user context.*
