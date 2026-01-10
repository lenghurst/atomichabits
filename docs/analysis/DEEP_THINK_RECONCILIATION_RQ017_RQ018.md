# Research Reconciliation: RQ-017 & RQ-018 (psyOS UX Phase)

**Source:** Deep Think UX Architecture Report (Constellation & Airlock)
**Date:** 10 January 2026
**Reconciled By:** Claude (Opus 4.5)
**Protocol Used:** Protocol 9 (External Research Reconciliation)

---

## Executive Summary

| Metric | Count |
|--------|-------|
| **Total Proposals** | 28 |
| **✅ ACCEPT** | TBD |
| **🟡 MODIFY** | TBD |
| **🔴 REJECT** | TBD |
| **⚠️ ESCALATE** | TBD |

---

## Phase 1: Locked Decision Audit

### CD Congruency Check

| Proposal | CD Affected | Status | Notes |
|----------|-------------|--------|-------|
| 4-state energy colors (Blue/Green/Orange/Purple) | CD-015 (4-state) | ✅ ALIGNED | Matches high_focus, high_physical, social, recovery |
| `hexis_score` for Sun pulse | CD-015 | ⚠️ CHECK | hexis_score is DEPRECATED per RQ-032; should use ICS or different metric |
| Canvas over Rive/Lottie | CD-017 (Android-first) | ✅ ALIGNED | Battery-conscious, no external dependencies |
| Stock + User hybrid audio | CD-016 (DeepSeek) | ✅ ALIGNED | DeepSeek mentioned for generation option |
| Max 7 facets | CD-015 (psyOS) | ✅ ALIGNED | Already specified in prompt constraints |
| 5-Second Seal (v0.5) | CD-018 (ESSENTIAL) | ✅ ALIGNED | Minimum viable, avoids over-engineering |
| Big Bang migration | N/A | 🟡 REVIEW | Risk assessment needed |

### Issues Found

| Issue | Severity | Resolution |
|-------|----------|------------|
| `hexis_score` referenced for Sun visualization | MEDIUM | MODIFY — Use `user.overallICS` (aggregate of facet ICS scores) |
| "Tapping tether opens Council AI" | LOW | Verify Council AI activation rules (PD-109) allow manual summon |

---

## Phase 2: Data Reality Audit (Android-First per CD-017)

### Data Points Used in Research

| Data Point | Research Usage | Android Available? | Permission | Battery | Status |
|------------|----------------|-------------------|------------|---------|--------|
| `Facet.habitVolume` | Planet radius | ✅ YES (local DB) | None | None | ✅ ACCEPT |
| `Facet.ics_score` | Orbit distance | ✅ YES (computed) | None | None | ✅ ACCEPT |
| `Facet.energyState` | Planet color | ✅ YES (inferred) | Multiple | Low | ✅ ACCEPT |
| `Facet.lastEngaged` | Ghost mode | ✅ YES (local DB) | None | None | ✅ ACCEPT |
| `Topology.friction` | Wobble/Tether | ✅ YES (computed) | None | None | ✅ ACCEPT |
| `CalendarContract` | Airlock trigger | ✅ YES | READ_CALENDAR | Low | ✅ ACCEPT |
| `foregroundApp` | Focus exit detection | ✅ YES | PACKAGE_USAGE_STATS | Low | ✅ ACCEPT |
| `stepsLast30Min` | Physical entry | ✅ YES | Health Connect | Low | ✅ ACCEPT |
| `VibrationEffect` | Haptic patterns | ✅ YES | VIBRATE | Very Low | ✅ ACCEPT |
| Audio playback | Priming sounds | ✅ YES | None | Low | ✅ ACCEPT |

**Verdict:** All data points are Android-available. No wearable-only dependencies.

---

## Phase 3: Implementation Reality Audit

### Schema Compatibility Check

| Proposed Element | Existing Schema | Gap? | Action |
|------------------|-----------------|------|--------|
| `Facet.habitVolume` | Can derive from `habit_facet_links` count | ✅ No gap | Compute at query time |
| `Facet.ics_score` | NEEDS field in `identity_facets` | 🟡 Gap | Already in Phase G (G-01) |
| `Facet.energyState` | Exists in `identity_facets` | ✅ No gap | — |
| `Facet.lastEngaged` | Can derive from latest `habit_logs` | ✅ No gap | Compute at query time |
| `Topology.friction` | Exists in `identity_topology.friction_coefficient` | ✅ No gap | — |
| Ghost mode threshold (7 days) | Business logic | ✅ No gap | Dart service |
| Audio assets | File storage | 🟡 Gap | Need asset pipeline |
| Haptic patterns | Service | 🟡 Gap | Need `HapticService` |

### Service Compatibility Check

| Proposed Service | Existing? | Gap? | Action |
|------------------|-----------|------|--------|
| `ConstellationPainter` | ❌ No | 🟡 Gap | NEW — CustomPainter implementation |
| `TransitionDetector` | ❌ No | 🟡 Gap | NEW — Calendar + Activity monitoring |
| `AirlockOverlay` | ❌ No | 🟡 Gap | NEW — Full-screen ritual widget |
| `HapticService` | ❌ No | 🟡 Gap | NEW — Android VibrationEffect wrapper |
| `inferEnergyState()` | ✅ Specified in RQ-014 | ✅ Exists | Task B-09 |

---

## Phase 4: Scope & Complexity Audit (CD-018)

### Constellation Features

| Feature | Research Classification | My Assessment | Rationale |
|---------|------------------------|---------------|-----------|
| Sun (center) with pulse | — | **ESSENTIAL** | Core metaphor anchor |
| Planets as facets | — | **ESSENTIAL** | Core visualization |
| Orbit distance = ICS | — | **ESSENTIAL** | Meaningful data binding |
| Planet color = energy state | — | **ESSENTIAL** | Instant context recognition |
| Planet radius = habit volume | — | **VALUABLE** | Adds weight/importance signal |
| Ghost mode (7-day cooling) | — | **VALUABLE** | Drives re-engagement |
| Wobble (friction-based) | — | **VALUABLE** | Conflict visibility |
| Tether (red line for conflicts) | — | **VALUABLE** | Explicit tension indicator |
| Settled state (0 FPS idle) | — | **ESSENTIAL** | Battery critical |
| RepaintBoundary optimization | — | **ESSENTIAL** | Performance critical |
| Progressive disclosure (Day 1→30) | — | **VALUABLE** | Prevents overwhelm |
| Tap planet → drill-down | — | **VALUABLE** | Navigation |
| Tap tether → Council summon | — | **NICE-TO-HAVE** | Could defer |

### Airlock Features

| Feature | Research Classification | My Assessment | Rationale |
|---------|------------------------|---------------|-----------|
| 5-Second Seal (v0.5) | — | **ESSENTIAL** | Minimum viable ritual |
| Predictive trigger (Calendar) | — | **ESSENTIAL** | Proactive intervention |
| Reactive trigger (App change) | — | **VALUABLE** | Real-time detection |
| Transition Pair Matrix | — | **ESSENTIAL** | Already defined in RQ-014 |
| Severity-based Airlock | Option D | **ESSENTIAL** | Balances value vs friction |
| Treaty-bound mandatory | Option E | **VALUABLE** | Opt-in discipline |
| Stock audio (4 loops) | — | **ESSENTIAL** | Launch requirement |
| User-recorded mantras | — | **NICE-TO-HAVE** | Post-launch unlock |
| Haptic patterns (2) | — | **VALUABLE** | Enhances sensory experience |
| 3-minute Breathwork (CRITICAL) | — | **OVER-ENGINEERED** | Too long for v1; reduce to 1m max |

---

## Phase 5: ACCEPT/MODIFY/REJECT/ESCALATE

### ✅ ACCEPT (Integrate as-is) — 20 proposals

| # | Proposal | Rationale |
|---|----------|-----------|
| 1 | **Bohr-Kepler Hybrid Model** (stable orbits + physics velocity) | Elegant solution for mobile readability |
| 2 | **Planet radius = log(votes)** formula | Logarithmic prevents runaway; matches ICS approach |
| 3 | **Orbit distance = ICS-based** | Direct integration with RQ-032 |
| 4 | **4-color energy palette** (Blue/Green/Orange/Purple) | Matches CD-015 4-state model |
| 5 | **Ghost Mode at 7 days** | Reasonable threshold; drives re-engagement |
| 6 | **Wobble = friction-based offset** | Simple, effective conflict indicator |
| 7 | **Tether for conflicts > 0.6** | Aligns with RQ-013 friction thresholds |
| 8 | **Canvas (CustomPainter) over Rive** | Correct for dynamic data binding |
| 9 | **RepaintBoundary for starfield** | Standard Flutter optimization |
| 10 | **Settled state (0 FPS idle)** | Critical for battery |
| 11 | **Max 7 facets** | Already in constraints |
| 12 | **Progressive disclosure** (Day 1→7→30) | Good UX practice |
| 13 | **5-Second Seal v0.5** | Perfect ESSENTIAL scope |
| 14 | **Predictive Calendar trigger** | Uses available Android signals |
| 15 | **Reactive App-change trigger** | Uses UsageStatsManager |
| 16 | **Severity-based Airlock (PD-110 Option D)** | Balances value vs friction |
| 17 | **Treaty-bound mandatory option** | Opt-in discipline preserves agency |
| 18 | **Stock audio (4 loops, <500KB)** | Within asset budget |
| 19 | **Haptic patterns (2 defined)** | Android VibrationEffect compatible |
| 20 | **Hybrid audio strategy (PD-112 Option D)** | Stock default + user unlock |

### 🟡 MODIFY (Adjust for reality) — 6 proposals

| # | Original | Modified | Rationale |
|---|----------|----------|-----------|
| 1 | **Sun pulse tied to `hexis_score`** | Sun pulse tied to **aggregate ICS** (`AVG(facet.ics_score)`) | hexis_score is DEPRECATED per RQ-032 |
| 2 | **3-minute Breathwork for CRITICAL transitions** | **1-minute max** for v1; expandable post-launch | OVER-ENGINEERED for launch; user will abandon |
| 3 | **Tap tether → Council summon** | Tap tether → **"Conflict detected" modal with Council option** | Don't auto-summon; respect PD-109 rate limits |
| 4 | **"Legacy List View" for accessibility** | **Remove from scope** — focus on Constellation accessibility instead | Maintaining two views splits engineering |
| 5 | **Big Bang migration (PD-108 Option A)** | **Option A with fallback** — if user struggles, offer simplified view | Risk mitigation without full parallel system |
| 6 | **User Mantras unlock at Level 10** | Unlock at **Sapling tier (ICS ≥ 1.2)** | Aligns with ICS visual tiers from RQ-032 |

### 🔴 REJECT (Do not implement) — 2 proposals

| # | Proposal | Reason |
|---|----------|--------|
| 1 | **60bpm pulse for Sun** | Over-specified; let designers determine animation timing |
| 2 | **"Screen shatters" completion effect** | OVER-ENGINEERED visual effect; simple fade transition is sufficient |

### ⚠️ ESCALATE (Human decision needed) — 0

All items resolved via ACCEPT/MODIFY/REJECT.

---

## Phase 6: Documentation Updates

### RQ-017 Status Update
- **Status:** ✅ COMPLETE
- **Key Deliverables:** Constellation visual spec, data binding formulas, Canvas implementation approach

### RQ-018 Status Update
- **Status:** ✅ COMPLETE
- **Key Deliverables:** Airlock trigger detection, 5-Second Seal UX, Transition Pair Matrix integration

### PD Resolutions

| PD | Decision | Rationale |
|----|----------|-----------|
| **PD-108** | **Option A (Big Bang) with fallback** | Clean cut to new paradigm; simplified fallback for struggling users |
| **PD-110** | **Option D (Severity) + Option E (Treaty)** | Default suggested, Treaty makes mandatory; preserves agency |
| **PD-112** | **Option D (Hybrid)** | Stock at launch, user mantras unlocked at Sapling tier |

### New GLOSSARY Terms

| Term | Definition |
|------|------------|
| **The Constellation** | psyOS dashboard visualization showing identity facets as planets orbiting the Self (sun) |
| **Ghost Mode** | Visual state for neglected facets (>7 days inactive); desaturated, dashed stroke |
| **The Seal** | 5-second Airlock completion ritual; press-and-hold interaction |
| **Tether** | Red pulsing line connecting conflicting facets in Constellation |

### Implementation Tasks Extracted

| ID | Task | Priority | Component | Source |
|----|------|----------|-----------|--------|
| H-01 | Implement `ConstellationPainter` (CustomPainter) | **CRITICAL** | Widget | RQ-017 |
| H-02 | Implement orbit distance formula (ICS-based) | **CRITICAL** | Widget | RQ-017 |
| H-03 | Implement planet radius formula (log votes) | HIGH | Widget | RQ-017 |
| H-04 | Implement Ghost Mode (7-day threshold, desaturation) | HIGH | Widget | RQ-017 |
| H-05 | Implement Wobble (friction-based offset) | MEDIUM | Widget | RQ-017 |
| H-06 | Implement Tether visualization (conflict > 0.6) | MEDIUM | Widget | RQ-017 |
| H-07 | Implement Settled State (0 FPS idle) | **CRITICAL** | Widget | RQ-017 |
| H-08 | Add RepaintBoundary for starfield | HIGH | Widget | RQ-017 |
| H-09 | Implement progressive disclosure logic | HIGH | Service | RQ-017 |
| H-10 | Implement `TransitionDetector` service | **CRITICAL** | Service | RQ-018 |
| H-11 | Implement `AirlockOverlay` widget (5-Second Seal) | **CRITICAL** | Widget | RQ-018 |
| H-12 | Implement `HapticService` (VibrationEffect wrapper) | HIGH | Service | RQ-018 |
| H-13 | Bundle stock audio assets (4 loops, <500KB) | HIGH | Asset | RQ-018 |
| H-14 | Integrate Airlock with Treaty system | HIGH | Service | RQ-018 |
| H-15 | Implement conflict modal (tether tap) | MEDIUM | Widget | RQ-017 |
| H-16 | Implement tap-planet drill-down navigation | MEDIUM | Widget | RQ-017 |

---

## Summary

| Category | Count |
|----------|-------|
| **✅ ACCEPT** | 20 |
| **🟡 MODIFY** | 6 |
| **🔴 REJECT** | 2 |
| **⚠️ ESCALATE** | 0 |
| **Total** | 28 |

### CD Congruency Verification

| CD | Requirement | Research Alignment |
|----|-------------|-------------------|
| CD-005 | 6-Dimension Model | ✅ Not directly used but compatible |
| CD-015 | 4-State Energy Model | ✅ Colors map to 4 states exactly |
| CD-016 | DeepSeek V3.2 | ✅ Mentioned for audio generation option |
| CD-017 | Android-First | ✅ All signals available, Canvas approach |
| CD-018 | ESSENTIAL Threshold | ✅ Applied to all features |

### Key Modifications Summary

1. **hexis_score → aggregate ICS** for Sun visualization
2. **3-min → 1-min max** Breathwork for CRITICAL transitions
3. **Auto-summon → Modal with option** for tether tap
4. **Level 10 → Sapling tier** for mantra unlock
5. **Big Bang → Big Bang with fallback** for migration

---

*This reconciliation was performed per Protocol 9 (AI_AGENT_PROTOCOL.md). All items are ready for implementation.*
