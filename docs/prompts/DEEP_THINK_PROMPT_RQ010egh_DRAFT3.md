# Deep Think Prompt: Permission Technical Architecture (RQ-010egh) — DRAFT 3

> **Target Research:** RQ-010e, RQ-010g, RQ-010h
> **Prepared:** 15 January 2026
> **For:** Google Deep Think / External AI Research
> **App Name:** The Pact
> **Companion Prompt:** RQ-010cdf (Permission UX/Privacy Experience) — to be run separately

---

## PART 1: WHAT IS "THE PACT"? (Essential Context)

**You have no prior knowledge of this project. This section provides essential context.**

### The App in One Paragraph

The Pact is a mobile app (Flutter 3.38.4, Android-first) that helps users build identity-based habits through psychological insight and social accountability. Unlike traditional habit trackers that count streaks, The Pact treats users as having multiple "identity facets" (e.g., "The Runner," "The Writer") that negotiate for attention. Users create "pacts" — commitments to become a certain type of person — and the app uses Just-In-Time Adaptive Intervention (JITAI) to deliver context-aware nudges at psychologically optimal moments.

### Core Philosophy: "Parliament of Selves"

The Pact is built on **psyOS** (Psychological Operating System) — a framework that treats users not as monolithic selves needing discipline, but as dynamic systems of competing identity facets. Key principles:

1. **Multiple Selves**: Users have a "Parliament" of identity facets (e.g., "The Athlete" votes for the gym, "The Couch Potato" votes for Netflix)
2. **Identity Evidence**: Every habit completion is an "identity vote" — evidence that strengthens a desired facet
3. **Context-Aware Intelligence**: The app senses context (location, calendar, activity, sleep) to know WHEN to intervene
4. **JITAI Engine**: Intervenes at moments of high vulnerability AND high opportunity (not random notifications)

### Key Terminology

| Term | Definition |
|------|------------|
| **psyOS** | Psychological Operating System — the app's core behavioral framework |
| **JITAI** | Just-In-Time Adaptive Intervention — context-sensitive nudge delivery |
| **Identity Facet** | A "version" of the user they want to develop (e.g., "The Early Riser") |
| **Witness** | A trusted accountability partner who receives vulnerability alerts |
| **V-O State** | Vulnerability-Opportunity score (0.0-1.0 each) — determines when to intervene |
| **ContextSnapshot** | Frozen point-in-time capture of all sensor signals |
| **ActivityContext** | Activity Recognition data (walking, running, still, in_vehicle) — **DOES NOT EXIST YET** |
| **Geofence** | Virtual perimeter around significant locations (home, gym, work) |
| **Transition API** | Android push-based API (`ActivityTransitionRequest`) that notifies on activity changes |
| **Doze Mode** | Android battery optimization that defers background work (introduced Android 6.0) |
| **Health Connect** | Android's unified health data API (sleep, heart rate, steps) |

### Tech Stack

- **Frontend:** Flutter 3.38.4 (Android-first, iOS deferred)
- **Backend:** Supabase (PostgreSQL + pgvector)
- **AI:** DeepSeek V3.2 for reasoning, Gemini for embeddings/TTS
- **Targets:** Android 14+ (API 34+) primary, minimum Android 8 (API 26)
- **Note:** Android 15 (API 35) introduced new background restrictions — address compatibility

### Why This Research Matters

Permissions are the **lifeblood** of context intelligence. Without activity, location, and calendar data, JITAI degrades to dumb scheduled notifications. But permission requests are the #1 cause of user abandonment. This prompt focuses on the **technical architecture** for acquiring, storing, and processing permission-gated sensor data efficiently.

---

## PART 2: YOUR ROLE

You are a **Senior Android Systems Architect** specializing in:
- Android Sensor APIs (Activity Recognition, Geofencing, Health Connect)
- Battery-efficient background processing (WorkManager, Transition API, Doze Mode)
- Privacy-preserving data architecture (zone-based abstraction, on-device processing)
- Permission grant optimization strategies
- Android version compatibility (API 26 → API 35)

Your approach: **Think step-by-step through each sub-question. Reason through tradeoffs explicitly. Cite Android documentation where applicable. Prioritize battery efficiency and graceful degradation.**

---

## PART 3: CRITICAL INSTRUCTION — PROCESSING ORDER

These RQs have dependencies. Process in this exact sequence:

```
┌─────────────────────────────────────────────────────────────────────┐
│                         PROCESSING ORDER                             │
│                                                                      │
│  RQ-010g: Activity Recognition Architecture                         │
│     │                                                                │
│     │   Output: ActivityContext class, Transition API setup,        │
│     │           Sleep API integration strategy                       │
│     ▼                                                                │
│  RQ-010h: Doze Mode + Battery Optimization                          │
│     │                                                                │
│     │   Output: Background execution strategy, WorkManager config,  │
│     │           Doze maintenance window timing                       │
│     ▼                                                                │
│  RQ-010e: Geofencing + Location Strategy                            │
│     │                                                                │
│     │   Output: Zone-based architecture, geofence CRUD operations,  │
│     │           WiFi fallback analysis                               │
│     ▼                                                                │
│  [Output feeds into companion prompt RQ-010cdf for UX layer]        │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Rationale:** Activity state informs location strategy (no geofence trigger needed if user is `still`). Battery strategy (RQ-010h) must be solved before designing background location polling.

---

## PART 4: EXISTING CODE — ContextSnapshot (REAL CODE)

The following Dart class **already exists** in our codebase. Your proposed `ActivityContext` must integrate with this structure.

```dart
/// ContextSnapshot: The unified sensory input for JITAI decision-making.
/// This is the "eyes and ears" of the intervention system.
class ContextSnapshot {
  // === IDENTITY ===
  final String snapshotId;
  final DateTime capturedAt;

  // === TIME FEATURES (Always Available) ===
  final TimeContext time;

  // === BIOMETRIC FEATURES (Optional - Health Connect) ===
  final BiometricContext? biometrics;

  // === CALENDAR FEATURES (Optional - Google Calendar) ===
  final CalendarContext? calendar;

  // === WEATHER FEATURES (Optional - OpenWeatherMap) ===
  final WeatherContext? weather;

  // === LOCATION FEATURES (Optional - Geolocator) ===
  final LocationContext? location;

  // === DIGITAL BEHAVIOR (Optional - App Usage) ===
  final DigitalContext? digital;

  // === HISTORICAL FEATURES (From Habit Data) ===
  final HistoricalContext history;

  // =====================================================
  // ⚠️ MISSING: ActivityContext — YOUR DELIVERABLE
  // =====================================================
  // final ActivityContext? activity;  // <-- DOES NOT EXIST YET

  // ... sensorCount, dataRichness, toFeatureVector(), etc.
}
```

### Existing BiometricContext (REAL CODE — for Sleep Integration)

```dart
/// BiometricContext: From Health Connect / HealthKit
class BiometricContext {
  final int? sleepMinutes;       // Last night's sleep from Health Connect
  final double? hrvSdnn;         // Heart rate variability
  final DateTime capturedAt;

  // Z-scores relative to user's baseline (positive = better than average)
  final double sleepZScore;
  final double hrvZScore;

  /// Is user sleep deprived? (< 6 hours or z-score < -1)
  bool get isSleepDeprived =>
      sleepZScore < -1.0 || (sleepMinutes != null && sleepMinutes! < 360);

  /// Is user stressed? (low HRV, z-score < -1)
  bool get isStressed => hrvZScore < -1.0;
}
```

**Note:** Sleep data comes from Health Connect Sleep API. Your `ActivityContext` should consider sleep state for activity readiness inference (e.g., low sleep + morning `STILL` = likely still in bed, not opportunity).

### Existing LocationContext (REAL CODE)

```dart
class LocationContext {
  final double? latitude;
  final double? longitude;
  final LocationZone zone;  // home, work, gym, commute, travel, unknown
  final double? distanceToHabitLocation;
  final DateTime capturedAt;

  bool get isAtHome => zone == LocationZone.home;
  bool get isAtWork => zone == LocationZone.work;
  bool get isAtGym => zone == LocationZone.gym;
  bool get isNearHabitLocation =>
      distanceToHabitLocation != null && distanceToHabitLocation! < 100;
}

enum LocationZone { home, work, gym, commute, travel, unknown }
```

---

## PART 5: EXISTING CODE — VulnerabilityOpportunityCalculator (REAL CODE)

This is the JITAI decision engine. It consumes `ContextSnapshot` and produces intervention decisions.

### Current Weight Constants (REAL VALUES)

```dart
class VOWeights {
  final double weekendRisk;          // default: 0.15
  final double eveningRisk;          // default: 0.12
  final double sleepDeprivation;     // default: 0.20
  final double stressHRV;            // default: 0.18
  final double highDistraction;      // default: 0.10
  final double recentMiss;           // default: 0.25  ← highest weight
  final double lowResilience;        // default: 0.15
  final double weakHabitStrength;    // default: 0.12
  final double activeRiskPattern;    // default: 0.08
  final double badWeather;           // default: 0.10
  // ⚠️ MISSING: activityState weights — YOUR DELIVERABLE
}
```

### Current Opportunity Calculation (REAL CODE)

```dart
static double _calculateOpportunity(
  ContextSnapshot context,
  PsychometricProfile profile,
  VOWeights weights,
) {
  double score = 0.5; // Start at neutral

  // === CALENDAR OPPORTUNITY ===
  if (context.calendar != null) {
    if (cal.isInMeeting) score -= 0.4;
    else if (cal.isGoodWindow) {
      score += 0.2;
      if (cal.freeWindowMinutes != null && cal.freeWindowMinutes! > 45) {
        score += 0.1;
      }
    }
  }

  // === TIME OPPORTUNITY ===
  if (context.time.hour >= 5 && context.time.hour < 8) score += 0.1;  // Early morning
  if (context.time.hour >= 22) score -= 0.2;  // Late night

  // === LOCATION OPPORTUNITY ===
  if (context.location != null) {
    if (context.location!.isAtHome) score += 0.05;
    if (context.location!.isNearHabitLocation) score += 0.15;
    if (context.location!.isAtGym) score += 0.2;  // ← GYM IS HIGH OPPORTUNITY
  }

  // === INTERVENTION FATIGUE ===
  if (context.history.hoursSinceLastIntervention < 2) score -= 0.2;
  if (context.history.isInterventionFatigued) score -= 0.3;

  // =====================================================
  // ⚠️ MISSING: Activity-based opportunity adjustment
  // =====================================================
  // if (context.activity != null) {
  //   if (context.activity!.isStill) score += ???;
  //   if (context.activity!.isExercising) score += ???;
  //   if (context.activity!.isInTransit) score -= ???;
  // }

  return score.clamp(0.0, 1.0);
}
```

**Your deliverable:** Propose weight adjustments for each activity state, maintaining the same scale (additive adjustments in -0.4 to +0.2 range).

---

## PART 6: EXISTING ANDROID MANIFEST (REAL CODE)

```xml
<!-- Currently declared permissions -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
<uses-permission android:name="android.permission.PACKAGE_USAGE_STATS"
    tools:ignore="ProtectedPermissions" />

<!-- NOT YET DECLARED (evaluate if needed): -->
<!-- android.permission.READ_CALENDAR -->
<!-- android.permission.POST_NOTIFICATIONS (Android 13+) -->
<!-- android.permission.RECEIVE_BOOT_COMPLETED -->
<!-- android.permission.WAKE_LOCK -->
<!-- android.permission.SCHEDULE_EXACT_ALARM (Android 12+) -->
<!-- android.permission.health.READ_SLEEP (Health Connect) -->
```

---

## PART 7: RESEARCH QUESTIONS

### RQ-010g: Activity Recognition Architecture

**Core Question:** How do we capture and utilize Android Activity Recognition data (walking, running, still, in_vehicle) for JITAI context?

**Why This Matters:**
- Activity state is ~40% of energy-state inference (alongside sleep from Health Connect, HRV)
- "User is walking toward gym" vs "User is still on couch" requires different intervention strategies
- Activity + Location + Sleep = powerful three-way disambiguation

**The Problem (Concrete Scenario):**
> Alex has a "Run 3x/week" pact. At 6:45am on Saturday:
> - Location: Near running trail (geofence enter event)
> - Activity: `STILL` for 5 minutes
> - Sleep: 5.5 hours (below baseline, z-score: -1.2)
>
> **Interpretation:** Alex is likely sitting in car, sleep-deprived, deciding whether to run. High vulnerability, moderate opportunity. Consider supportive nudge, not demanding one.

**Android API Options:**

| API | Method | Battery | Use Case |
|-----|--------|---------|----------|
| **Transition API** | `ActivityTransitionRequest` | LOW (~0.5%) | Event-driven: ENTER/EXIT states |
| **Activity Updates** | `requestActivityUpdates()` | HIGH (continuous) | Real-time tracking (NOT recommended) |
| **Health Connect** | `SleepSessionRecord` | NONE (user-synced) | Sleep duration inference |

**Sub-Questions (Answer Each Explicitly):**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Transition API Setup:** What exact Android code registers for activity transitions? | Provide Kotlin/Java snippet using `ActivityRecognition.getClient()` and `ActivityTransition.Builder` |
| 2 | **Activity Types:** Which `DetectedActivity` types should we subscribe to? | List types with justification. Consider: STILL, WALKING, RUNNING, ON_BICYCLE, IN_VEHICLE, TILTING |
| 3 | **Confidence Thresholds:** Activity Recognition returns confidence scores (0-100). What threshold per activity type? | Propose thresholds. Note: false positives for `RUNNING` are worse than `STILL` |
| 4 | **Sleep + Activity Integration:** How does sleep deprivation modify activity interpretation? | Propose logic: low sleep + morning STILL = different from rested + evening STILL |
| 5 | **ActivityContext Class Design:** Complete Dart class matching existing patterns | Provide full implementation with `toJson()`, `fromJson()`, helper getters |
| 6 | **V-O Weight Adjustments:** How does activity state affect opportunity score? | Propose weights in same scale as existing code (-0.4 to +0.2 range) |

**Anti-Patterns to Avoid:**
- ❌ Using `requestActivityUpdates()` with interval < 30 seconds (battery drain)
- ❌ Ignoring confidence scores (leads to false positives)
- ❌ Complex state machines requiring persistent foreground service
- ❌ Treating `IN_VEHICLE` as universally "bad" (commute = captive audience for podcasts)

**Output Required for RQ-010g:**
1. Android Transition API setup code (Kotlin)
2. Complete `ActivityContext` Dart class
3. Confidence threshold table per activity type
4. Sleep + Activity integration logic
5. V-O opportunity weight adjustments
6. Confidence Assessment: HIGH/MEDIUM/LOW for each output

---

### RQ-010h: Doze Mode + Battery Optimization Strategy

**Core Question:** How do we maintain JITAI responsiveness while respecting Android Doze Mode and App Standby?

**Why This Matters:**
- Android 6.0+ Doze Mode can defer alarms, jobs, and network by hours
- Android 13+ requires `POST_NOTIFICATIONS` permission
- Android 15 (API 35) introduced stricter background restrictions
- Users who don't grant battery exemption still deserve working app

**Doze Mode Technical Details:**

```
DOZE MODE STATES (for reference):
┌─────────────────────────────────────────────────────────────────┐
│ State          │ Conditions                │ Restrictions       │
├────────────────┼───────────────────────────┼────────────────────┤
│ ACTIVE         │ Screen on OR charging     │ None               │
│ LIGHT DOZE     │ Screen off, stationary    │ Deferred jobs      │
│ DEEP DOZE      │ Extended light doze       │ No network, alarms │
│ MAINTENANCE    │ Every ~15 min in doze     │ Brief window       │
└─────────────────────────────────────────────────────────────────┘

Maintenance window: ~30 seconds every 15 minutes (light) → 2+ hours (deep)
```

**The Problem (Concrete Scenario):**
> Sarah has a "Meditate at 7am" pact. Phone on nightstand overnight:
> - 11pm: Phone enters Doze (screen off, stationary)
> - 6:45am: Scheduled WorkManager job should trigger "15 min to habit" nudge
> - **Reality:** Job may be deferred until 7:30am maintenance window
>
> Sarah wakes at 7:30am, sees no notification. App seems broken.

**Sub-Questions (Answer Each Explicitly):**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Battery Exemption Request:** Should we request `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`? | Evaluate Play Store policy. Note: Google discourages this for most apps. |
| 2 | **Exact Alarms (Android 12+):** When is `SCHEDULE_EXACT_ALARM` appropriate for a habit app? | Define criteria. Note: Users can revoke in Settings. |
| 3 | **FCM High-Priority:** What qualifies as high-priority that can wake device? | Define criteria. Google monitors abuse — what's the line? |
| 4 | **Maintenance Window Strategy:** How do we maximize the ~30s maintenance window? | Propose: what work to batch, what to defer |
| 5 | **Battery Budget:** What's acceptable daily battery drain for a habit app? | Propose target with justification. Reference: typical is 1-3% for background apps. |
| 6 | **Android 15 Compatibility:** What new restrictions in API 35 affect our approach? | Identify and propose mitigations |
| 7 | **Graceful Degradation:** If ALL background execution fails, what UX do we provide? | Propose fallback (e.g., "catch-up" check-in when app opens) |

**Anti-Patterns to Avoid:**
- ❌ Foreground Service with persistent notification (user hostile, 10% uninstall rate)
- ❌ Frequent wake locks (battery drain, Play Store rejection)
- ❌ Testing only with charger connected (Doze never activates)
- ❌ Assuming FCM always wakes device (delivery not guaranteed)

**Output Required for RQ-010h:**
1. Doze survival strategy decision tree (by intervention urgency level)
2. WorkManager configuration (constraints, backoff, expedited work)
3. FCM priority criteria matrix
4. Maintenance window batching strategy
5. Battery budget target with benchmarks
6. Android 15 compatibility notes
7. Confidence Assessment: HIGH/MEDIUM/LOW for each output

---

### RQ-010e: Geofencing + Location Strategy

**Core Question:** How do we implement zone-based location intelligence that respects privacy while enabling JITAI?

**Why This Matters:**
- Location is ~40% of JITAI context weight
- Geofences enable "arrive at gym → nudge" flows
- `ACCESS_BACKGROUND_LOCATION` is HIGH RISK for Play Store rejection
- Users increasingly deny location (iOS 15+ saw 35% denial rate)

**The Problem (Concrete Scenario):**
> Marcus has a "Gym 4x/week" pact. He sets "Fitness First Downtown" as gym.
>
> **Desired:** Enter 100m radius → trigger "Guardian mode" (suppress social media, offer encouragement)
>
> **Privacy concern:** Marcus doesn't want breadcrumb trails of his movements.

**Android Location Permission Reality:**

| Permission | Accuracy | Use Case | Play Store Risk |
|------------|----------|----------|-----------------|
| `ACCESS_COARSE_LOCATION` | ~3km | City-level | LOW |
| `ACCESS_FINE_LOCATION` | ~10m | Geofencing | MEDIUM |
| `ACCESS_BACKGROUND_LOCATION` | Same + background | Always-on geofence | HIGH |

**⚠️ WiFi SSID Fallback Caveat:**
> On Android 10+, reading WiFi SSID requires `ACCESS_FINE_LOCATION`. This is NOT a zero-permission fallback.
> WiFi "connected" status (without SSID) IS zero-permission but only tells you "on WiFi, somewhere."

**Sub-Questions (Answer Each Explicitly):**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Fine vs Coarse for Geofencing:** Can Android Geofencing API work with COARSE only? | Test assumption. Cite Android docs on minimum accuracy for `addGeofences()`. |
| 2 | **Background Location Necessity:** Define exact use cases requiring `ACCESS_BACKGROUND_LOCATION` | Matrix: which features require it, which can degrade gracefully |
| 3 | **Geofence Limit Strategy:** Android allows ~100 geofences per app (device-dependent). How do we allocate? | Propose: user-defined vs auto-detected vs habit-linked |
| 4 | **Dense Urban Accuracy:** GPS drifts 50-100m in cities. Gym is above coffee shop. How to disambiguate? | Propose strategy (hint: dwell time, activity state, floor detection?) |
| 5 | **WiFi SSID Reality:** Given Android 10+ restrictions, is WiFi SSID a viable fallback for location-denied users? | Evaluate honestly. What CAN we do without location permission? |
| 6 | **Zero-Permission Fallback:** What location-adjacent intelligence works with NO permissions? | List: charging pattern, time-of-day inference, user-reported location |
| 7 | **Zone-Based Storage Schema:** How do we store "user is at gym" without storing coordinates? | Propose privacy-first database schema |

**Anti-Patterns to Avoid:**
- ❌ Storing GPS coordinate breadcrumbs
- ❌ Polling location (use geofence transitions instead)
- ❌ Requiring background location for ALL features
- ❌ Geofence radius < 50m (GPS accuracy issues)
- ❌ Relying on WiFi SSID without disclosing location requirement

**Output Required for RQ-010e:**
1. Fine vs Coarse decision with Android API documentation citation
2. Background location use case matrix (REQUIRED vs OPTIONAL vs NOT NEEDED)
3. Geofence allocation strategy (100 limit)
4. Dense urban disambiguation approach
5. Honest WiFi fallback analysis
6. Zero-permission intelligence list
7. Privacy-first zone storage schema (SQL or Dart model)
8. Confidence Assessment: HIGH/MEDIUM/LOW for each output

---

## PART 8: ARCHITECTURAL CONSTRAINTS (HARD REQUIREMENTS)

| Constraint | Rule | Rationale |
|------------|------|-----------|
| **Platform** | Android 8+ (API 26) minimum, Android 14+ (API 34+) target | Market coverage |
| **Database** | Supabase (PostgreSQL + pgvector). No Firebase Realtime DB. | Already chosen |
| **AI Models** | DeepSeek V3.2 for reasoning. Cannot change. | Locked CD-016 |
| **Battery Target** | < 3% daily battery drain from app | User retention |
| **No Foreground Service** | For MVP, avoid persistent notification | High abandonment rate |
| **Privacy-First** | Store zone membership, not coordinates | GDPR/trust |
| **Graceful Degradation** | App must provide value with ZERO permissions | Cannot gate core features |
| **4-State Energy Model** | high_focus, high_physical, social, recovery | Locked CD-015 |

---

## PART 9: USER SCENARIOS (SOLVE STEP-BY-STEP)

### Scenario A: Gym Arrival Detection
> **Context:** Tuesday 6:30pm. Alex drives to the gym after work.
>
> **Events:**
> 1. 6:15pm: Activity = `IN_VEHICLE`, Location = `work` zone
> 2. 6:28pm: Geofence ENTER (gym, 100m radius), Activity = `IN_VEHICLE`
> 3. 6:30pm: Activity transition: `IN_VEHICLE` → `STILL` (parked)
> 4. 6:32pm: Activity transition: `STILL` → `WALKING`
> 5. 6:35pm: Activity = `STILL` (inside gym, changing)
>
> **Questions to answer step-by-step:**
> 1. At which event should the app first respond?
> 2. What is the intervention at each stage?
> 3. How does battery optimization affect timing?

### Scenario B: Permission Denial (Worst Case — Zero Sensor Data)
> **Context:** New user denies ALL permissions (location, activity, calendar, notifications).
>
> **Signals still available (truly zero-permission on Android):**
> - Time of day, day of week (always available)
> - Whether phone is charging (`BatteryManager.EXTRA_PLUGGED`)
> - Screen on/off state
> - App open/close events (user is in app)
> - Historical habit completion patterns (user's own data)
> - User-reported location (manual "I'm at the gym" button)
>
> **Questions to answer:**
> 1. What JITAI intelligence can we derive from these signals alone?
> 2. How does charging pattern reveal routine? (e.g., charges at same desk = "at work")
> 3. What's the UX for a "Manual Mode" where user opts out of sensing?

### Scenario C: Dense Urban Environment
> **Context:** Marcus lives in Manhattan. His gym is on 3rd floor. Coffee shop on ground floor.
>
> **Problem:** GPS shows 80m horizontal drift. Geofence triggers when Marcus is at coffee shop.
>
> **Questions to answer:**
> 1. How do we avoid false-positive gym entry detection?
> 2. Can we use dwell time + activity state to confirm?
> 3. Should we ask user to confirm arrival ("Looks like you're at the gym — confirm?")

---

## PART 10: EXAMPLE OF GOOD OUTPUT (Quality Bar)

For RQ-010g Sub-Question 5 (ActivityContext class), here is the quality expected:

```dart
/// ActivityContext: Current physical activity state from Activity Recognition API.
///
/// Design notes:
/// - Uses Transition API (`ActivityTransitionRequest`) not polling
/// - Confidence threshold: 75% minimum to avoid false positives (except STILL: 50%)
/// - Integrates with ContextSnapshot as optional field
/// - Consider sleep state for interpretation (low sleep + morning STILL = in bed)
class ActivityContext {
  /// Current detected activity
  final ActivityType currentActivity;

  /// Confidence score from Activity Recognition (0.0-1.0, normalized from 0-100)
  final double confidence;

  /// Previous activity (for transition detection)
  final ActivityType? previousActivity;

  /// When transition to current activity was detected
  final DateTime transitionDetectedAt;

  /// Calculated duration in current state
  Duration get durationInState =>
      DateTime.now().difference(transitionDetectedAt);

  /// When this context was captured
  final DateTime capturedAt;

  ActivityContext({
    required this.currentActivity,
    required this.confidence,
    this.previousActivity,
    required this.transitionDetectedAt,
    required this.capturedAt,
  });

  /// Has user been still for extended period? (potential opportunity)
  bool get isExtendedStill =>
      currentActivity == ActivityType.still &&
      durationInState.inMinutes > 15;

  /// Is user in transit? (defer intervention — captive audience)
  bool get isInTransit =>
      currentActivity == ActivityType.inVehicle ||
      currentActivity == ActivityType.onBicycle;

  /// Is user actively exercising? (high opportunity if matches habit)
  bool get isExercising =>
      currentActivity == ActivityType.running ||
      currentActivity == ActivityType.onBicycle;

  /// Just transitioned from vehicle? (likely arriving somewhere)
  bool get justArrivedSomewhere =>
      previousActivity == ActivityType.inVehicle &&
      currentActivity == ActivityType.walking &&
      durationInState.inMinutes < 5;

  /// Confidence meets action threshold?
  /// STILL has lower threshold (50%) because false positives are less costly
  /// RUNNING has higher threshold (75%) because false positives are annoying
  bool get isHighConfidence {
    if (currentActivity == ActivityType.still) return confidence >= 0.50;
    if (currentActivity == ActivityType.running) return confidence >= 0.75;
    return confidence >= 0.65; // Default for WALKING, IN_VEHICLE, etc.
  }

  /// V-O opportunity modifier based on activity state
  /// Range: -0.3 to +0.15 (matches existing weight scale)
  double get opportunityModifier {
    if (!isHighConfidence) return 0.0; // No adjustment if uncertain

    switch (currentActivity) {
      case ActivityType.still:
        return isExtendedStill ? 0.10 : 0.05; // Stillness = availability
      case ActivityType.walking:
        return 0.08; // Walking = transitional, slight opportunity
      case ActivityType.running:
        return 0.15; // Running = high engagement (if running habit)
      case ActivityType.inVehicle:
        return -0.15; // Driving = bad time for visual nudge
      case ActivityType.onBicycle:
        return -0.10; // Cycling = engaged but interruptible
      default:
        return 0.0;
    }
  }

  Map<String, dynamic> toJson() => {
    'currentActivity': currentActivity.name,
    'confidence': confidence,
    'previousActivity': previousActivity?.name,
    'transitionDetectedAt': transitionDetectedAt.toIso8601String(),
    'capturedAt': capturedAt.toIso8601String(),
  };

  factory ActivityContext.fromJson(Map<String, dynamic> json) {
    return ActivityContext(
      currentActivity: ActivityType.values.firstWhere(
        (e) => e.name == json['currentActivity'],
        orElse: () => ActivityType.unknown,
      ),
      confidence: (json['confidence'] as num).toDouble(),
      previousActivity: json['previousActivity'] != null
          ? ActivityType.values.firstWhere(
              (e) => e.name == json['previousActivity'],
              orElse: () => ActivityType.unknown,
            )
          : null,
      transitionDetectedAt: DateTime.parse(json['transitionDetectedAt'] as String),
      capturedAt: DateTime.parse(json['capturedAt'] as String),
    );
  }
}

enum ActivityType {
  still,
  walking,
  running,
  onBicycle,
  inVehicle,
  tilting,
  unknown,
}
```

**This is the quality bar.** Your outputs should match this level of:
- Complete implementation (not pseudocode sketches)
- Documented design decisions
- Helper methods for common queries
- V-O integration via `opportunityModifier` getter
- Confidence-aware behavior
- JSON serialization for persistence

---

## PART 11: OUTPUT QUALITY CRITERIA

| Criterion | Question to Ask |
|-----------|-----------------|
| **Implementable** | Can an Android developer build this without clarifying questions? |
| **Integrated** | Does this work with existing ContextSnapshot and V-O Calculator? |
| **Battery-Conscious** | Is power consumption explicitly quantified? |
| **Privacy-First** | Does this store minimum necessary data? |
| **Degradation-Aware** | Does this work when permissions are denied? |
| **Version-Aware** | Does this address Android 10, 12, 13, 14, 15 differences? |
| **Confidence-Rated** | Is each recommendation tagged HIGH/MEDIUM/LOW? |

---

## PART 12: FINAL CHECKLIST BEFORE SUBMITTING

Before submitting your response, verify:

- [ ] RQ-010g ActivityContext class is complete Dart code (not pseudocode)
- [ ] RQ-010g includes Android Transition API setup code (Kotlin)
- [ ] RQ-010g includes confidence thresholds per activity type
- [ ] RQ-010g includes V-O weight adjustments in existing scale
- [ ] RQ-010h Doze Mode strategy includes decision tree by urgency level
- [ ] RQ-010h includes Android 15 compatibility notes
- [ ] RQ-010h includes battery budget with benchmarks
- [ ] RQ-010e addresses WiFi SSID Android 10+ restriction honestly
- [ ] RQ-010e includes zero-permission fallback list
- [ ] RQ-010e geofence allocation accounts for ~100 limit
- [ ] All three user scenarios (A, B, C) solved step-by-step
- [ ] All sub-questions have explicit answers
- [ ] Confidence levels stated for each recommendation

---

## PART 13: RELATIONSHIP TO COMPANION PROMPT (RQ-010cdf)

This prompt focuses on **technical architecture**. A companion prompt (RQ-010cdf) covers:
- Permission request UX flows (timing, messaging)
- User-facing zone messaging ("We see zones, not coordinates")
- Permission denial recovery strategies
- Progressive disclosure UX

**Your outputs feed into RQ-010cdf.** Ensure your outputs clarify:
1. Which permissions are REQUIRED vs ENHANCING
2. What fallback exists for each denied permission
3. Battery/privacy tradeoffs in user-understandable terms

---

*End of Prompt — DRAFT 3*
