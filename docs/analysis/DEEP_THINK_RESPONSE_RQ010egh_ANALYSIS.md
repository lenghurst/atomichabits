# Deep Think Response Analysis: RQ-010egh (Permission Technical Architecture)

> **Response Date:** 15 January 2026
> **Prompt Version:** Draft 3
> **Status:** ✅ ACCEPTED with MODIFICATIONS
> **Implementation:** DEFERRED — Research phase only

---

## Executive Summary

The Deep Think response provides production-quality architecture for:
- **RQ-010g:** Activity Recognition (Transition API, ActivityContext class)
- **RQ-010h:** Doze Mode survival strategy
- **RQ-010e:** Geofencing + Location privacy

**Verdict:** Accept core architecture. Four implementation gaps identified → RQ-010r-u created.

---

## 1. Key Technical Decisions — ACCEPTED

### 1.1 Activity Recognition Strategy

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **API** | Transition API (`ActivityTransitionRequest`) | Push-based, ~0.5% battery vs 4% for polling |
| **Activities Tracked** | STILL, WALKING, RUNNING, ON_BICYCLE, IN_VEHICLE | TILTING excluded (noisy) |
| **PendingIntent Flag** | `FLAG_MUTABLE` | Required for GMS to attach `ActivityTransitionResult` extras |

### 1.2 Confidence Thresholds (Per Activity)

| Activity | Threshold | Rationale |
|----------|-----------|-----------|
| **STILL** | 50% | Low risk — false positive just means "user ignored" |
| **WALKING** | 65% | Transitional state, moderate confidence needed |
| **RUNNING** | 75% | High risk — false positive = annoying "Good job!" while stressed |
| **ON_BICYCLE** | 75% | Mechanically similar to vehicle motion |
| **IN_VEHICLE** | 80% | Safety critical — suppresses visual nudges |

### 1.3 V-O Opportunity Weight Adjustments

| Activity State | Modifier | Rationale |
|----------------|----------|-----------|
| `STILL` (extended >15min) | +0.10 | Prime time for intervention |
| `STILL` (brief) | +0.05 | Available but may be transitional |
| `WALKING` | +0.05 | Good for audio/transition nudges |
| `RUNNING` | +0.15 | User is engaged (for exercise habits) |
| `ON_BICYCLE` | -0.10 | Busy but interruptible |
| `IN_VEHICLE` | **-0.30** | SAFETY — suppress visual nudges |

### 1.4 Doze Mode Decision Tree

| Urgency | Trigger | Doze Behavior | Use Case |
|---------|---------|---------------|----------|
| **CRITICAL** | FCM High Priority | Wakes device immediately | Witness "Help Me" alerts |
| **HIGH** | Transition API / Geofence | Wakes app ~10s | "Arrived at Gym" nudge |
| **MEDIUM** | WorkManager (Expedited) | Runs ASAP (quota) | Daily morning JITAI calc |
| **LOW** | WorkManager (Periodic) | Deferred to maintenance | Data sync, pattern analysis |

### 1.5 Geofencing Architecture

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Fine vs Coarse** | `ACCESS_FINE_LOCATION` REQUIRED | `addGeofences()` throws SecurityException without it |
| **Background Location** | REQUIRED for always-on geofencing | Fallback: retro-active card on app open |
| **Geofence Allocation** | Fixed (5) + Active Habits (20) + Dynamic (rest) | 100 limit per app |
| **Privacy** | Store `zone_id`, not coordinates in history | Coords only in `user_zones` table |

### 1.6 WiFi Fallback — Honest Assessment

| Signal | Permission Required | What It Tells Us |
|--------|---------------------|------------------|
| WiFi SSID | `ACCESS_FINE_LOCATION` (Android 10+) | NOT a fallback for location-denied |
| WiFi Connected (no SSID) | None | "On WiFi, somewhere" (indoors) |
| WiFi Unmetered | None | Likely Home/Office (not hotspot) |

**Conclusion:** WiFi SSID is NOT a zero-permission fallback. Only "connected + unmetered" inference works.

### 1.7 Zero-Permission Signals (Verified)

These signals work with NO permissions granted:

1. **Power State:** `BatteryManager.EXTRA_PLUGGED`
   - Plugged + Night = Home/Bed
   - Plugged + Day = Work Desk
2. **Clock:** Time-of-day, day-of-week
3. **App Engagement:** User opened app = awake + looking at screen
4. **Manual Input:** "I'm Here" button
5. **Screen State:** On/off (no permission needed)

---

## 2. ActivityContext Specification (For Future Implementation)

**DO NOT IMPLEMENT YET** — This is the approved specification for when implementation begins.

### 2.1 Class Structure

```dart
class ActivityContext {
  final ActivityType currentActivity;
  final double confidence;  // 0.0 - 1.0
  final ActivityType? previousActivity;
  final DateTime transitionDetectedAt;
  final DateTime capturedAt;

  // Computed properties
  Duration get durationInState => capturedAt.difference(transitionDetectedAt);
  bool get isExtendedStill => currentActivity == ActivityType.still && durationInState.inMinutes > 15;
  bool get isInTransit => currentActivity == ActivityType.inVehicle || currentActivity == ActivityType.onBicycle;
  bool get isExercising => currentActivity == ActivityType.running || currentActivity == ActivityType.onBicycle;
  bool get justArrivedSomewhere => previousActivity == ActivityType.inVehicle &&
                                   currentActivity == ActivityType.walking &&
                                   durationInState.inMinutes < 5;

  // Confidence check (varies by activity)
  bool get isHighConfidence {
    if (currentActivity == ActivityType.still) return confidence >= 0.50;
    if (currentActivity == ActivityType.running) return confidence >= 0.75;
    if (currentActivity == ActivityType.inVehicle) return confidence >= 0.80;
    return confidence >= 0.65;
  }

  // V-O opportunity modifier
  double get opportunityModifier {
    if (!isHighConfidence) return 0.0;
    switch (currentActivity) {
      case ActivityType.still: return isExtendedStill ? 0.10 : 0.05;
      case ActivityType.walking: return 0.05;
      case ActivityType.running: return 0.15;
      case ActivityType.onBicycle: return -0.10;
      case ActivityType.inVehicle: return -0.30;
      default: return 0.0;
    }
  }
}

enum ActivityType { still, walking, running, onBicycle, inVehicle, tilting, unknown }
```

### 2.2 Integration Points

- **ContextSnapshot:** Add `final ActivityContext? activity;` field
- **VulnerabilityOpportunityCalculator:** Use `context.activity?.opportunityModifier ?? 0.0`

---

## 3. Zone Storage Schema (For Future Implementation)

```sql
-- Coordinates stored ONLY here (for geofence registration)
CREATE TABLE user_zones (
  id UUID PRIMARY KEY,
  user_id UUID,
  name TEXT,  -- "Gym", "Home"
  radius_meters INT DEFAULT 100,
  center_lat DOUBLE PRECISION,
  center_lng DOUBLE PRECISION
);

-- NO coordinates in history — privacy-first
CREATE TABLE context_history (
  id UUID PRIMARY KEY,
  user_id UUID,
  timestamp TIMESTAMP,
  zone_id UUID REFERENCES user_zones(id),  -- Reference only
  activity_type TEXT,
  opportunity_score DOUBLE PRECISION
);
```

---

## 4. User Scenario Solutions

### Scenario A: Gym Arrival

| Time | Event | Activity | Action |
|------|-------|----------|--------|
| 6:28pm | Geofence ENTER | IN_VEHICLE | **Suppress** (safety). Log "Pending Arrival". |
| 6:30pm | IN_VEHICLE → STILL | STILL | Wait for exit (parked). |
| 6:32pm | STILL → WALKING | WALKING | **TRIGGER** "You've arrived. Leave work in the car." |
| 6:35pm | Inside gym | STILL | Confirm gym session started. |

### Scenario B: Zero Permissions

| Signal | Inference | Action |
|--------|-----------|--------|
| Phone plugged in at 10am | Stationary / Desk | Nudge: "Phone charging. Good time for 30m Deep Work?" |
| Manual "I'm Here" chips | User-reported location | Set `ContextSnapshot.location` manually |

### Scenario C: Dense Urban (Gym vs Coffee Shop)

| Check | Result | Interpretation |
|-------|--------|----------------|
| Activity | STILL | Could be either |
| Time | 8:00am | Morning = coffee time |
| Habit schedule | Gym usually 6pm | Not typical gym time |
| **Strategy** | Send soft check-in | "Are you at **Fitness First** or **Starbucks**?" |

---

## 5. Implementation Gaps → New RQs

| Gap | New RQ | Blocking |
|-----|--------|----------|
| No Health Connect Sleep API Kotlin code | RQ-010r | RQ-010g |
| No `ActivityTransitionReceiver` BroadcastReceiver | RQ-010s | RQ-010g |
| No `GeofencingClient` registration Kotlin code | RQ-010t | RQ-010e |
| No WorkManager configuration (Expedited vs Periodic) | RQ-010u | RQ-010h |

---

## 6. Android Version Compatibility Notes

| Android Version | Consideration |
|-----------------|---------------|
| **Android 10 (API 29)** | WiFi SSID requires `ACCESS_FINE_LOCATION` |
| **Android 12 (API 31)** | `SCHEDULE_EXACT_ALARM` permission needed for exact alarms |
| **Android 13 (API 33)** | `POST_NOTIFICATIONS` permission required |
| **Android 14 (API 34)** | Geofence/Activity events exempt from FGS restrictions |
| **Android 15 (API 35)** | Stricter FGS from background — but sensor events still exempt |

---

## 7. Confidence Assessment (From Response)

| Component | Confidence | Notes |
|-----------|------------|-------|
| Activity API Setup | **HIGH** | Kotlin code provided |
| ActivityContext Class | **HIGH** | Complete Dart implementation |
| Doze Strategy | **MEDIUM** | OEM variability acknowledged |
| Geofencing | **HIGH** | Fine/Background requirements clarified |
| Zero-Permission Fallbacks | **HIGH** | Honest assessment provided |

---

## 8. Next Steps (Research Phase Only)

1. ✅ Document findings (this file)
2. ✅ Create RQ-010r-u for implementation gaps
3. ⬜ Run companion prompt RQ-010cdf (Permission UX)
4. ⬜ Reconcile UX + Technical outputs
5. ⬜ Create PDs from combined research
6. ⬜ THEN begin implementation

---

*This document is the authoritative reference for RQ-010egh findings. Implementation should not begin until all RQ-010 research is complete and PDs are created.*
