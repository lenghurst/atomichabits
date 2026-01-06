# Research Reconciliation: RQ-014, RQ-013, PD-117, RQ-015

**Source:** Google Deep Think (Identity System Architecture Report)
**Date:** 06 January 2026
**Reconciled By:** Claude (Opus 4.5)
**Protocol Used:** Protocol 9 (External Research Reconciliation)

---

## Summary

| Metric | Count |
|--------|-------|
| **Total Proposals** | 18 |
| **✅ ACCEPT** | 11 |
| **🟡 MODIFY** | 5 |
| **🔴 REJECT** | 1 |
| **⚠️ ESCALATE** | 1 |

---

## Phase 1: Locked Decision Audit

| Proposal | Conflicts With | Resolution |
|----------|----------------|------------|
| 5-state energy model | CD-015 (4-state model) | 🔴 REJECT — Keep 4-state |
| Heart rate detection | CD-017 (Android-first, no wearables) | 🟡 MODIFY — Make optional |
| Switching cost matrix | None | ✅ Compatible |
| Directed graph topology | CD-015 (already specified) | ✅ Compatible |

---

## Phase 2: Data Reality Audit (Android-First per CD-017)

| Data Point | Android Status | Permission | Battery | Action |
|------------|----------------|------------|---------|--------|
| `stepsLast30Min` | ✅ Available | Google Fit / Health Connect | Low | **INCLUDE** |
| `heartRate` | 🟡 Conditional | Health Connect (requires Watch) | Variable | **DEFER** — Optional enhancement |
| `foregroundApp` | ✅ Available | UsageStatsManager | Low | **INCLUDE** |
| `screenOnDuration` | ✅ Available | UsageStatsManager | Low | **INCLUDE** |
| `calendarEventCategory` | ✅ Available | CalendarContract | Low | **INCLUDE** |
| `locationZone` | ✅ Available | Geofencing | Medium | **INCLUDE** |
| `appCategory` | ✅ Available | UsageStatsManager | Low | **INCLUDE** |

---

## Phase 3: ACCEPT (Integrate as-is)

| # | Proposal | Rationale |
|---|----------|-----------|
| 1 | **Switching Cost Matrix concept** | Valuable insight for JITAI; applies to 4-state model |
| 2 | **"Pirate to Parent" dangerous transition** | `high_focus → social` is highest risk; actionable |
| 3 | **Chronotype modifiers** | Already in RQ-012; confirms approach |
| 4 | **Directed graph for identity_topology** | Aligns with CD-015 |
| 5 | **Friction learning (online)** | Simple behavioral learning; uses existing data |
| 6 | **Council trigger formula** | Aligns with RQ-016/RQ-020 |
| 7 | **ContextSnapshot tiered refresh** | Smart battery optimization |
| 8 | **Waterfall attribution** | Reduces friction; good UX |
| 9 | **10% Shadow Bonus for multi-facet** | Elegant solution; doesn't inflate scores |
| 10 | **custom_metrics JSONB field** | Flexible; low complexity |
| 11 | **Facet-specific feedback templates** | Reinforces identity; already in CD-015 |

---

## Phase 4: MODIFY (Adjust for reality)

| # | Proposal | Original | Adjusted | Rationale |
|---|----------|----------|----------|-----------|
| 1 | **Energy State Model** | 5 states (deep_focus, creative_flow, high_physical, social_connect, recovery) | **4 states** (high_focus, high_physical, social, recovery) | CD-015 locked 4-state; creative vs deep distinction is NICE-TO-HAVE |
| 2 | **Passive Detection** | Uses heartRate, detailed appCategory | **Simplified:** Steps + foreground app + calendar + location | Android reality; heartRate requires Watch |
| 3 | **Burnout Algorithm** | `(Sum(DailySwitchingCosts) / TotalAwakeMinutes) > 0.3` | **Burnout Early Warning:** 3 dangerous transitions + streak fragility + cross-facet misses | Middle ground; uses existing data, leading indicators |
| 4 | **Switching Cost Matrix** | 5x5 matrix (25 pairs) | **4x4 matrix** (16 pairs) + **3 dangerous pairs highlighted** | Aligned to 4-state; focus on actionable pairs |
| 5 | **Airlock triggers** | Real-time based on context | **Schedule-aware:** Trigger based on calendar transitions + manual mode | Battery-friendly; reliable on Android |

---

## Phase 5: REJECT (Do not implement)

| # | Proposal | Reason |
|---|----------|--------|
| 1 | **5-State Energy Model** (deep_focus vs creative_flow split) | Conflicts with CD-015 (4-state model). The distinction requires passive detection of cognitive mode (convergent vs divergent thinking) which is not reliably detectable on Android. 4-state model is sufficient for launch. |

---

## Phase 6: ESCALATE → RESOLVED

| # | Proposal | Resolution | Date |
|---|----------|------------|------|
| 1 | **Heart Rate as optional Tier 4 signal** | **Option A SELECTED:** Include as nullable field, only use if Health Connect data available. Low effort, high value for Watch users (~10% of Android users). | 06 Jan 2026 |

**Implementation Note:**
```dart
// ContextSnapshot update
class ContextSnapshot {
  // ... other fields

  /// Nullable - only populated if Health Connect data available
  /// Tier 4: Background fetch, hourly refresh
  final int? heartRate;

  /// Whether heart rate data is available from Health Connect
  final bool hasHeartRateAccess;
}

// Usage in inferEnergyState
if (ctx.heartRate != null && ctx.heartRate! > 110) {
  return EnergyState.high_physical; // Higher confidence with HR
}
```

---

## Android-First Specifications (Reconciled)

### RQ-014: State Economics (RECONCILED)

**4-State Model (Aligned with CD-015):**

| State Key | Definition | Passive Detection (Android) |
|-----------|------------|----------------------------|
| `high_focus` | Convergent work, single-tasking | `foregroundApp` in productivity list + `screenOnDuration > 20min` |
| `high_physical` | High somatic arousal | `stepsLast30Min > 1000` |
| `social` | Interpersonal, empathetic | `calendarEventCategory == 'meeting'` OR `locationZone == 'social'` |
| `recovery` | Parasympathetic, low-input | `isPhoneLocked && hour > 21 && stepsLast30Min < 50` |

**Switching Cost Matrix (4x4, Android-First):**

| From ↓ / To → | high_focus | high_physical | social | recovery |
|---------------|------------|---------------|--------|----------|
| **high_focus** | 0 | 45 | **60** ⚠️ | 20 |
| **high_physical** | **0 (Boost)** | 0 | 15 | 5 |
| **social** | **50** ⚠️ | 15 | 0 | 10 |
| **recovery** | 15 | 10 | 10 | 0 |

**3 Dangerous Transitions (Focus tracking):**
1. `high_focus → social` (60 min) — "Pirate to Parent"
2. `social → high_focus` (50 min) — "Parent to Pirate"
3. `high_focus → high_physical` (45 min) — Cognitive to Physical without reset

**Passive Detection Algorithm (Android):**

```dart
EnergyState inferEnergyState(ContextSnapshot ctx) {
  // 1. Treaty Override
  if (ctx.activeTreaty?.imposedState != null) {
    return ctx.activeTreaty!.imposedState!;
  }

  // 2. Physical (Google Fit / Health Connect)
  if (ctx.stepsLast30Min > 1000) {
    return EnergyState.high_physical;
  }

  // 3. Focus (UsageStatsManager)
  if (ctx.screenOnDuration > 20 && _isFocusApp(ctx.foregroundApp)) {
    return EnergyState.high_focus;
  }

  // 4. Social (CalendarContract / Geofencing)
  if (ctx.calendarEventCategory == 'meeting' || ctx.locationZone == 'social') {
    return EnergyState.social;
  }

  // 5. Recovery
  if (ctx.isPhoneLocked && ctx.hour > 21 && ctx.stepsLast30Min < 50) {
    return EnergyState.recovery;
  }

  // 6. Time-based fallback
  return _inferFromChronotype(ctx.hour, ctx.chronotype);
}

bool _isFocusApp(String packageName) {
  const focusApps = [
    'com.google.android.apps.docs',
    'com.microsoft.office.word',
    'com.notion.android',
    // ... productivity apps
  ];
  return focusApps.contains(packageName);
}
```

**Burnout Early Warning (Middle Ground):**

```dart
double calculateBurnoutRisk(UserDay day) {
  double risk = 0.0;

  // Signal 1: Dangerous Transition Count (40%)
  const dangerous = {('high_focus', 'social'), ('social', 'high_focus'), ('high_focus', 'high_physical')};
  int dangerousCount = day.transitions.where((t) => dangerous.contains((t.from, t.to))).length;
  risk += (dangerousCount / 3).clamp(0.0, 1.0) * 0.4;

  // Signal 2: Streak Fragility (30%)
  int fragile = day.habits.where((h) => h.streakDaysRemaining == 1 && !h.completedToday).length;
  risk += (fragile / day.habits.length).clamp(0.0, 1.0) * 0.3;

  // Signal 3: Cross-Facet Misses (30%)
  Set<String> facetsWithMisses = day.missedHabits.map((h) => h.facetId).toSet();
  if (facetsWithMisses.length >= 2) risk += 0.3;

  return risk;
}
```

---

### RQ-013: Identity Topology (RECONCILED)

**Schema (No changes needed — already compatible):**

```sql
CREATE TABLE identity_topology (
  source_facet_id UUID REFERENCES identity_facets(id),
  target_facet_id UUID REFERENCES identity_facets(id),
  interaction_type TEXT CHECK (interaction_type IN ('synergistic', 'antagonistic', 'competitive', 'neutral')),
  friction_coefficient FLOAT DEFAULT 0.5,
  switching_cost_minutes INT,  -- From 4x4 matrix
  last_conflict_at TIMESTAMPTZ,
  PRIMARY KEY (source_facet_id, target_facet_id),
  CONSTRAINT distinct_facets CHECK (source_facet_id <> target_facet_id)
);
```

**Council Trigger Formula (No changes):**

```dart
bool shouldSummonCouncil(ContextSnapshot ctx, IdentityTopology topology) {
  double trigger = (ctx.tensionScore * 0.6) + (topology.frictionCoefficient * 0.4);
  return trigger > 0.75;
}
```

---

### PD-117: ContextSnapshot (RECONCILED)

**Field Refresh Strategy (Android-optimized):**

| Field | Tier | Refresh Trigger | Android Source | Battery |
|-------|------|-----------------|----------------|---------|
| `activeFacet` | 0 | Manual / Schedule | User action | Low |
| `energyState` | 1 | App Foreground / 15m | Inferred | Low |
| `foregroundApp` | 1 | App Foreground | UsageStatsManager | Low |
| `screenOnDuration` | 1 | App Foreground | UsageStatsManager | Low |
| `stepsLast30Min` | 2 | 15m Timer | Google Fit | Low |
| `locationZone` | 2 | Geofence Entry/Exit | Geofencing API | Med |
| `calendarEvents` | 2 | 15m Timer | CalendarContract | Low |
| `tensionScore` | 3 | Lazy (On JITAI) | Computed | High |
| `heartRate` | 4 | Background (Hourly) | Health Connect | Med |

**Total Battery Impact: ~4.0%** (Within 5% budget per CD-015)

---

### RQ-015: Polymorphic Habits (RECONCILED — No changes needed)

All Deep Think proposals for RQ-015 were ACCEPTED:
- Waterfall Attribution
- 10% Shadow Bonus
- custom_metrics JSONB
- Facet-specific feedback templates

---

## Tasks Extracted (via Protocol 8)

| ID | Task | Priority | Component | Source |
|----|------|----------|-----------|--------|
| A-12 | Create `identity_topology` table with 4x4 switching cost support | CRITICAL | Database | RQ-013 |
| A-13 | Add `custom_metrics JSONB` to `habit_facet_links` | HIGH | Database | RQ-015 |
| B-08 | Implement `EnergyState` enum (4-state) | CRITICAL | Service | RQ-014 |
| B-09 | Implement `inferEnergyState()` with Android signals | CRITICAL | Service | RQ-014 |
| B-10 | Implement `BurnoutDetector` (3 signals) | HIGH | Service | RQ-014 |
| B-11 | Implement `WaterfallAttribution` logic | HIGH | Service | RQ-015 |
| B-12 | Update `ContextSnapshot` with tiered refresh | HIGH | Service | PD-117 |
| B-13 | Implement Council trigger formula | HIGH | Service | RQ-013 |
| C-05 | Integrate dangerous transition tracking | MEDIUM | Council AI | RQ-014 |

---

## Appendix: Android Permission Requirements

| Permission | Purpose | User Prompt Text |
|------------|---------|------------------|
| `PACKAGE_USAGE_STATS` | App usage detection for focus state | "Allow The Pact to see which apps you use to detect your focus mode" |
| `ACCESS_FINE_LOCATION` | Geofencing for location zones | "Allow The Pact to know your location to suggest context-aware habits" |
| `READ_CALENDAR` | Calendar event detection | "Allow The Pact to see your calendar to avoid interrupting meetings" |
| Health Connect | Step count, optional heart rate | "Allow The Pact to access your fitness data to track activity" |

---

*This reconciliation was performed per Protocol 9 (AI_AGENT_PROTOCOL.md). All ACCEPT and MODIFY items are ready for implementation. ESCALATE item requires human decision.*
