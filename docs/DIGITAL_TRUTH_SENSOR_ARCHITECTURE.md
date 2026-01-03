# Digital Truth Sensor: Dual-Mode Architecture

**Date**: January 3, 2026
**Status**: Proposed Enhancement
**Combines**: Real-Time Intervention Plan + Researcher Agent queryEvents() Finding

---

## Executive Summary

The Digital Truth Sensor will operate in **two complementary modes**:

1. **Guardian Mode**: Real-time interruption (foreground service + polling)
2. **Analyst Mode**: Precise session tracking (WorkManager + event queries)

This hybrid approach maximizes both **marketing value** (real-time) and **user value** (insights).

---

## Mode 1: Guardian Mode (Real-Time Interruption)

### Purpose
Deliver on the marketing promise: "We stop you mid-scroll, not tomorrow"

### Implementation
```kotlin
class GuardianModeService : Service() {
    private var pollInterval = 30_000L // Adaptive: 30s → 5s

    private fun monitor() {
        val currentApp = getCurrentForegroundApp() // queryUsageStats()

        if (isDistractionApp(currentApp)) {
            pollInterval = 5_000L // High frequency when doom scrolling
            updateSessionDuration(currentApp)

            if (sessionDuration >= threshold) {
                triggerIntervention() // Overlay/notification
            }
        } else {
            pollInterval = 30_000L // Low frequency otherwise
        }

        handler.postDelayed({ monitor() }, pollInterval)
    }
}
```

### Characteristics
- **Latency**: 0-5 seconds
- **Battery**: 2,000-5,000 polls/day (2-3% drain)
- **Precision**: ±5 second accuracy
- **User Control**: Toggle on/off in settings
- **Android Compliance**: Requires `specialUse` foreground service

---

## Mode 2: Analyst Mode (Event-Based Tracking)

### Purpose
Provide precise session analytics and pattern detection

### Implementation
```kotlin
// Runs via WorkManager every 15 minutes
class AnalystWorker : Worker() {
    override fun doWork(): Result {
        val lastCheckTime = getLastCheckTimestamp()
        val now = System.currentTimeMillis()

        val events = usageStatsManager.queryEvents(lastCheckTime, now)
        val sessions = buildSessionsFromEvents(events)

        // Store sessions in local DB
        sessionRepository.insert(sessions)

        // Check for dopamine loop patterns
        val loopAlert = detectDopamineLoop(sessions)
        if (loopAlert != null) {
            notifyUser(loopAlert)
        }

        saveLastCheckTimestamp(now)
        return Result.success()
    }
}
```

### Characteristics
- **Latency**: Up to 15 minutes (not real-time)
- **Battery**: 96 checks/day (<0.5% drain)
- **Precision**: Millisecond timestamp accuracy
- **New Capabilities**:
  - Session count per app
  - Average session duration
  - Dopamine loop detection (rapid switching)
  - Historical trend analysis
- **Android Compliance**: Standard WorkManager (no special permissions)

---

## Data Flow Integration

```
┌─────────────────────────────────────────────────────────────┐
│                    DigitalTruthSensor                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Guardian Mode (Real-Time)    Analyst Mode (Retrospective)  │
│  ┌──────────────────────┐    ┌────────────────────────┐    │
│  │ Foreground Service   │    │ WorkManager Worker      │    │
│  │ - 5-30s polling      │    │ - 15min intervals       │    │
│  │ - Current state      │    │ - Event history         │    │
│  └──────────┬───────────┘    └───────────┬────────────┘    │
│             │                             │                  │
│             ▼                             ▼                  │
│  ┌──────────────────────────────────────────────────┐       │
│  │         Unified Session Database (Hive)          │       │
│  │  - Current session (from Guardian)               │       │
│  │  - Historical sessions (from Analyst)            │       │
│  │  - Dopamine loop alerts                          │       │
│  └──────────────────────────────────────────────────┘       │
│                          │                                   │
│                          ▼                                   │
│            ┌─────────────────────────────┐                  │
│            │   ContextSnapshot.digital   │                  │
│            │   - distractionMinutes      │                  │
│            │   - currentSessionMinutes   │                  │
│            │   - sessionCount            │                  │
│            │   - isDoomScrolling         │                  │
│            └─────────────────────────────┘                  │
│                          │                                   │
└──────────────────────────┼───────────────────────────────────┘
                           ▼
                 JITAI Decision Engine
```

---

## Researcher Agent Finding: Precise Integration Point

### Where queryEvents() Fits

**Original Researcher Claim**: "More efficient than queryUsageStats()"
**Corrected Understanding**: "More precise, not more efficient"

**Actual Benefit**: queryEvents() provides **event-level granularity** that enables:

1. **Dopamine Loop Detection** (NEW)
   - Detect when user switches between TikTok → Instagram → YouTube in <5 minutes
   - Original Plan: Cannot detect this pattern (only sees "current app")
   - Researcher Finding: Can reconstruct entire switching sequence

2. **Session-Level Analytics** (ENHANCED)
   - Original Plan: "47 minutes on TikTok today"
   - Researcher Finding: "8 sessions, avg 5.9 min, longest 12 min"

3. **Precise Timestamps** (ACCURACY)
   - Original Plan: ±5 second accuracy (due to polling)
   - Researcher Finding: Millisecond accuracy (from event log)

### Implementation Strategy

**Phase 1 (Week 1-2)**: Guardian Mode Only
- Implement real-time interruption using Original Plan (polling)
- Marketing launch: "Real-time doom scroll detection"
- Validate Play Store approval with `specialUse` foreground service

**Phase 2 (Week 3-4)**: Add Analyst Mode
- Integrate queryEvents() for session tracking
- Add "Session Statistics" card to dashboard
- Marketing update: "Precise session analytics"

**Phase 3 (Week 5+)**: Dopamine Loop Detection
- Implement pattern detection algorithm
- Add "Loop Alert" intervention type
- Marketing update: "Detects compulsive switching behavior"

---

## Battery Impact Comparison

| Configuration | Polls/Day | Battery Est. | Capabilities |
|--------------|-----------|--------------|-------------|
| **Guardian Only** | 2,000-5,000 | 2-3% | Real-time interruption |
| **Analyst Only** | 96 | <0.5% | Session stats, loop detection |
| **Hybrid (Both)** | 2,096-5,096 | 2.5-3.5% | All features |
| **Smart Hybrid*** | 1,000-3,000 | 1.5-2% | All features (optimized) |

*Smart Hybrid: Guardian Mode auto-disables after 2 hours of no distraction app usage

---

## Android 15 Compliance Strategy

### Guardian Mode (Requires Approval)
- **Service Type**: `specialUse`
- **Justification**: "Real-time addiction intervention for behavioral health"
- **Precedent**: Similar to "I Am Sober", "Nomo" (approved)
- **Risk**: Medium (requires clear Play Console explanation)

### Analyst Mode (Standard API)
- **Service Type**: N/A (uses WorkManager)
- **Justification**: "Periodic health data analysis"
- **Precedent**: Standard usage for fitness/wellbeing apps
- **Risk**: Low (standard API usage)

---

## User Settings: Granular Control

```dart
class DigitalTruthSettings {
  // Guardian Mode
  bool guardianModeEnabled;
  InterventionStyle interventionStyle; // gentle, moderate, aggressive
  Duration interventionThreshold; // 5-30 minutes

  // Analyst Mode
  bool sessionTrackingEnabled; // Always on if Guardian enabled
  bool loopDetectionEnabled;

  // Battery Saver
  bool autoDisableGuardian; // Turn off after 2h of no distraction usage
}
```

**Marketing Copy**:
- Guardian Mode: "Real-time protection"
- Analyst Mode: "Insights without interruption"
- Hybrid: "Full protection + detailed insights"

---

## Conclusion: Researcher Finding Value

**Original Assessment**: "High value discovery - recommended implementation"
**Revised Assessment**: "Complementary enhancement - integrate as Analyst Mode"

The Researcher Agent's queryEvents() finding does NOT replace the Real-Time Plan, but rather **adds a second dimension** to the Digital Truth Sensor:

- **Guardian Mode** (Original Plan) = Marketing differentiator
- **Analyst Mode** (Researcher Finding) = User engagement driver

Together, they create a "best of both worlds" architecture that maximizes both sales appeal and user value.
