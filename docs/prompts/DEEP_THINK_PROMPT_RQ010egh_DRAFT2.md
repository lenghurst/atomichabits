# Deep Think Prompt: Permission Technical Architecture (RQ-010egh) — DRAFT 2

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
| **Identity Vote** | Each habit completion is "evidence" strengthening a facet |
| **Witness** | A trusted accountability partner who receives vulnerability alerts |
| **V-O State** | Vulnerability-Opportunity score — determines when to intervene |
| **ContextSnapshot** | Frozen point-in-time capture of all sensor signals |
| **ActivityContext** | Activity Recognition data (walking, running, still, in_vehicle) — **DOES NOT EXIST YET** |
| **Geofence** | Virtual perimeter around significant locations (home, gym, work) |
| **Transition API** | Android push-based system that notifies on activity changes |
| **Doze Mode** | Android battery optimization that restricts background work |

### Tech Stack

- **Frontend:** Flutter 3.38.4 (Android-first, iOS deferred)
- **Backend:** Supabase (PostgreSQL + pgvector)
- **AI:** DeepSeek V3.2 for reasoning, Gemini for embeddings/TTS
- **Permissions Target:** Android 14+ (API 34+)

### Why This Research Matters

Permissions are the **lifeblood** of context intelligence. Without activity, location, and calendar data, JITAI degrades to dumb scheduled notifications. But permission requests are also the #1 cause of user abandonment. This prompt focuses on the **technical architecture** for acquiring, storing, and processing permission-gated sensor data efficiently.

---

## PART 2: YOUR ROLE

You are a **Senior Android Systems Architect** specializing in:
- Android Sensor APIs (Activity Recognition, Geofencing, Location)
- Battery-efficient background processing (WorkManager, Transition API, Doze Mode)
- Privacy-preserving data architecture (zone-based abstraction, on-device processing)
- Permission grant optimization strategies

Your approach: **Think step-by-step through each sub-question. Reason through tradeoffs explicitly. Cite Android documentation or research papers where applicable. Prioritize battery efficiency and graceful degradation.**

---

## PART 3: CRITICAL INSTRUCTION — PROCESSING ORDER

These RQs have dependencies. Process in this exact sequence:

```
┌─────────────────────────────────────────────────────────────────────┐
│                         PROCESSING ORDER                             │
│                                                                      │
│  RQ-010g: Activity Recognition Architecture                         │
│     │                                                                │
│     │   Output: ActivityContext class, Transition API setup         │
│     ▼                                                                │
│  RQ-010h: Doze Mode + Battery Optimization                          │
│     │                                                                │
│     │   Output: Background execution strategy, WorkManager config   │
│     ▼                                                                │
│  RQ-010e: Geofencing + Location Strategy                            │
│     │                                                                │
│     │   Output: Zone-based architecture, geofence CRUD operations   │
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

  // === USER OVERRIDE (The Thermostat) ===
  final double? userVulnerabilityOverride;
  final List<String> activePatterns;

  // ... constructor, factory methods, toFeatureVector() ...
}
```

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

This is the JITAI decision engine. It consumes `ContextSnapshot` and produces intervention decisions. Your outputs must integrate here.

```dart
class VulnerabilityOpportunityCalculator {
  static VOState calculate({
    required ContextSnapshot context,
    required PsychometricProfile profile,
    VOWeights weights = _defaultWeights,
  }) {
    final vulnerability = _calculateVulnerability(context, profile, weights);
    final opportunity = _calculateOpportunity(context, profile, weights);
    // ...
    return VOState(
      vulnerability: adjustedVulnerability.clamp(0.0, 1.0),
      opportunity: opportunity.clamp(0.0, 1.0),
      // ...
    );
  }

  static double _calculateOpportunity(
    ContextSnapshot context,
    PsychometricProfile profile,
    VOWeights weights,
  ) {
    double score = 0.5; // Start at neutral

    // === LOCATION OPPORTUNITY ===
    if (context.location != null) {
      if (context.location!.isAtHome) score += 0.05;
      if (context.location!.isNearHabitLocation) score += 0.15;
      if (context.location!.isAtGym) score += 0.2;  // <-- Gym = high opportunity
    }

    // =====================================================
    // ⚠️ MISSING: Activity-based opportunity adjustment
    // =====================================================
    // if (context.activity != null) {
    //   if (context.activity!.isStill) score += ???;
    //   if (context.activity!.isWalking) score += ???;
    //   // etc.
    // }

    return score.clamp(0.0, 1.0);
  }
}
```

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

<!-- NOT YET DECLARED (may be needed): -->
<!-- android.permission.READ_CALENDAR -->
<!-- android.permission.POST_NOTIFICATIONS -->
<!-- android.permission.RECEIVE_BOOT_COMPLETED -->
<!-- android.permission.WAKE_LOCK -->
<!-- android.permission.SCHEDULE_EXACT_ALARM -->
```

---

## PART 7: RESEARCH QUESTIONS

### RQ-010g: Activity Recognition Architecture

**Core Question:** How do we capture and utilize Android Activity Recognition data (walking, running, still, in_vehicle) for JITAI context?

**Why This Matters:**
- Activity state is 40% of energy-state inference (alongside sleep, HRV)
- "User is walking toward gym" vs "User is still on couch" requires completely different intervention strategies
- Activity + Location = powerful disambiguation (walking + gym zone = arriving for workout)

**The Problem (Concrete Scenario):**
> Alex has a "Run 3x/week" pact. At 6:45am on Saturday, the app detects:
> - Location: Near running trail (geofence enter event)
> - Activity: `STILL` for 5 minutes
>
> What does this mean? Is Alex stretching before a run? Sitting in car deciding whether to run? About to bail?
>
> **The app needs activity state to disambiguate** — if activity transitions to `RUNNING`, confirm the run started. If `IN_VEHICLE`, Alex bailed. If `STILL` persists + time passes, consider a gentle nudge.

**Current Hypothesis:**

| Component | Proposed Approach |
|-----------|-------------------|
| Detection Method | Google Activity Recognition Transition API (push-based, not polling) |
| Primary Activities | `STILL`, `WALKING`, `RUNNING`, `ON_BICYCLE`, `IN_VEHICLE` |
| Battery Strategy | Subscribe to transitions, not continuous polling |
| Integration Point | New `ActivityContext` class in ContextSnapshot |

**Sub-Questions (Answer Each Explicitly):**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Transition API vs Polling:** Google offers both continuous recognition (battery-heavy) and Transition API (event-driven). Which is appropriate for our use case? | Recommend with justification. Cite battery impact numbers from Android docs. |
| 2 | **Confidence Thresholds:** Activity Recognition returns confidence scores. What threshold should we use for each activity type? | Propose thresholds per activity. Consider: "90% confidence RUNNING" vs "60% confidence WALKING" |
| 3 | **Transition Combinations:** We need to detect specific transitions (e.g., `STILL → WALKING → gym_zone`). How do we compose these? | Propose state machine or event sequence pattern |
| 4 | **ActivityContext Class Design:** What fields should `ActivityContext` contain? | Provide complete Dart class matching existing patterns |
| 5 | **Integration with VulnerabilityOpportunityCalculator:** How does activity state affect V-O scores? | Propose weight adjustments for each activity type |

**Anti-Patterns to Avoid:**
- ❌ Continuous polling (drains battery)
- ❌ Ignoring confidence scores (leads to false positives)
- ❌ Complex state machines that require persistent service
- ❌ Depending on `IN_VEHICLE` for habit tracking (too coarse)

**Output Required for RQ-010g:**
1. Transition API vs Polling recommendation with battery justification
2. Complete `ActivityContext` Dart class (matching existing code patterns)
3. Confidence threshold table per activity type
4. V-O integration weights proposal
5. Confidence Assessment: HIGH/MEDIUM/LOW for each output

---

### RQ-010h: Doze Mode + Battery Optimization Strategy

**Core Question:** How do we maintain JITAI responsiveness while respecting Android Doze Mode and App Standby?

**Why This Matters:**
- Android 6.0+ aggressively throttles background work to save battery
- Doze Mode can delay alarms, jobs, and network access by hours
- Users who deny battery optimization exemption still deserve working app
- Play Store reviews suffer when notifications seem "broken"

**The Problem (Concrete Scenario):**
> Sarah has a "Meditate at 7am" pact. Phone sits on nightstand overnight (Doze Mode active). At 6:45am:
> - Doze Mode: ACTIVE (phone is stationary, screen off)
> - Scheduled nudge: 7:00am gentle reminder
>
> **Problem:** Standard JobScheduler/AlarmManager may be deferred up to 2+ hours in deep Doze. Sarah wakes at 7:30am to zero notifications. App seems broken.

**Current Hypothesis:**

| Strategy | Description | When to Use |
|----------|-------------|-------------|
| High-Priority FCM | Firebase Cloud Messaging wakes device | CRITICAL interventions only |
| Exact Alarms | `SCHEDULE_EXACT_ALARM` permission (Android 12+) | Time-sensitive habits with user permission |
| Maintenance Windows | Use Doze maintenance windows | Non-urgent syncs |
| Foreground Service | Last resort for continuous tracking | NOT RECOMMENDED for MVP |

**Sub-Questions (Answer Each Explicitly):**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Doze Exemption Request:** Should we request `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`? What's the UX impact? | Recommend with justification. Note Play Store policy implications. |
| 2 | **Exact Alarms (Android 12+):** `SCHEDULE_EXACT_ALARM` requires permission and can be revoked. When is it appropriate? | Define exact alarm use cases for habit apps |
| 3 | **FCM Priority Strategy:** High-priority FCM can wake device but Google monitors abuse. What qualifies as "high priority"? | Define criteria for high-priority FCM |
| 4 | **Graceful Degradation:** If all background execution is blocked, how do we deliver value? | Propose fallback UX for worst-case scenario |
| 5 | **Battery Budget:** What daily battery impact is acceptable for a habit app? | Propose target (e.g., "<2% daily drain") with rationale |

**Anti-Patterns to Avoid:**
- ❌ Foreground Service with persistent notification (user hostile)
- ❌ Frequent wake locks (battery drain, Play Store rejection)
- ❌ Ignoring Doze Mode in testing (works on desk, fails in real use)
- ❌ Assuming FCM high-priority is always available

**Output Required for RQ-010h:**
1. Doze Mode survival strategy (decision tree for each intervention type)
2. WorkManager configuration recommendations
3. FCM priority criteria matrix
4. Battery budget target with justification
5. Confidence Assessment: HIGH/MEDIUM/LOW for each output

---

### RQ-010e: Geofencing + Location Strategy

**Core Question:** How do we implement zone-based location intelligence that respects privacy while enabling JITAI?

**Why This Matters:**
- Location context is 40% of JITAI's context weight (tied with activity)
- Geofences enable "arrive at gym → nudge" flows
- Background location is HIGH RISK for Play Store rejection
- Users increasingly deny location (iOS 15+ saw 35% denial rate)

**The Problem (Concrete Scenario):**
> Marcus has a "Gym 4x/week" pact. He sets "Fitness First Downtown" as his gym location.
>
> **Desired behavior:** When Marcus enters a 100m radius of the gym, trigger a "Guardian mode" that suppresses social media notifications and offers encouragement.
>
> **Privacy concern:** Marcus doesn't want the app tracking his movements continuously. He's okay with zone transitions but not breadcrumb trails.

**Current Hypothesis:**

| Component | Proposed Approach |
|-----------|-------------------|
| API | Android Geofencing API (push-based, battery-efficient) |
| Zones | User-defined (home, work, gym) + auto-detected (frequent locations) |
| Radius | 100m default, user-adjustable 50m-500m |
| Data Storage | Zone membership only, not coordinates (privacy-first) |
| Fallback | WiFi SSID detection if location denied |

**Sub-Questions (Answer Each Explicitly):**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Fine vs Coarse Location:** Geofencing API requires `ACCESS_FINE_LOCATION`. Can we achieve useful zones with `ACCESS_COARSE_LOCATION` only? | Test assumption. Cite Android docs on coarse location accuracy. |
| 2 | **Background Location (Critical):** `ACCESS_BACKGROUND_LOCATION` requires separate permission request + Play Store justification. When is it necessary? | Define exact use cases requiring background location |
| 3 | **Geofence Limits:** Android limits to 100 geofences per app. How do we prioritize? | Propose allocation strategy (habits vs auto-detected vs user-defined) |
| 4 | **Dense Urban Accuracy:** In cities, GPS can drift 50-100m. How do we handle gym-next-to-coffee-shop scenarios? | Propose disambiguation strategy |
| 5 | **WiFi Fallback:** If user denies location, can we use WiFi SSID as zone proxy? | Evaluate feasibility and limitations |
| 6 | **Zone-Based Storage:** How do we store "user is at gym" without storing coordinates? | Propose privacy-first schema |

**Anti-Patterns to Avoid:**
- ❌ Storing GPS breadcrumb trails
- ❌ Polling location (battery drain)
- ❌ Requiring background location for all features
- ❌ Geofences smaller than GPS accuracy (~50m)
- ❌ Assuming WiFi = reliable zone detection (SSID spoofing, range issues)

**Output Required for RQ-010e:**
1. Fine vs Coarse location decision with justification
2. Background location use case matrix (when required, when optional)
3. Geofence allocation strategy (100 limit)
4. WiFi fallback architecture
5. Privacy-first zone storage schema
6. Confidence Assessment: HIGH/MEDIUM/LOW for each output

---

## PART 8: ARCHITECTURAL CONSTRAINTS (HARD REQUIREMENTS)

| Constraint | Rule | Rationale |
|------------|------|-----------|
| **Platform** | Android 14+ (API 34+) target, Android 8+ (API 26) minimum | Market coverage vs API availability |
| **Database** | Supabase (PostgreSQL + pgvector). No Firebase Realtime DB. | Backend already chosen |
| **AI Models** | DeepSeek V3.2 for reasoning. Cannot change. | Locked decision CD-016 |
| **Battery Target** | < 5% daily battery drain from app | User retention requirement |
| **No Foreground Service** | For MVP, avoid persistent notification requirement | UX research shows high abandonment |
| **Privacy-First** | Store zone membership, not coordinates | GDPR/trust requirement |
| **Graceful Degradation** | App must provide value with ZERO permissions | Cannot require permissions |
| **4-State Energy Model** | high_focus, high_physical, social, recovery | Locked decision CD-015 |

---

## PART 9: USER SCENARIOS (SOLVE STEP-BY-STEP)

### Scenario A: Gym Arrival Detection
> **Context:** Tuesday 6:30pm. Alex drives to the gym after work.
>
> **Events:**
> 1. 6:15pm: Activity = `IN_VEHICLE`
> 2. 6:28pm: Geofence ENTER (gym, 100m radius)
> 3. 6:30pm: Activity = `STILL` (parked)
> 4. 6:32pm: Activity = `WALKING`
> 5. 6:35pm: Activity = `STILL` (inside gym, changing)
>
> **Question:** At what point should the app intervene? What intervention?

### Scenario B: Permission Denial (Worst Case)
> **Context:** New user denies ALL permissions (location, activity, calendar).
>
> **Question:** How does the app provide JITAI value with zero sensor data?
>
> **Available signals (zero-permission):**
> - Time of day (always available)
> - Day of week (always available)
> - Whether phone is charging (BatteryManager, no permission needed)
> - WiFi connected status (though not SSID without permission)
> - Screen on/off (no permission needed)
> - Historical habit completion patterns (user's own data)

### Scenario C: Dense Urban Environment
> **Context:** Marcus lives in Manhattan. His gym is on the 3rd floor of a building. Coffee shop is on ground floor.
>
> **Problem:** GPS shows 80m drift. Geofence triggers when Marcus is at coffee shop, not gym.
>
> **Question:** How do we disambiguate without tracking floor/altitude?

---

## PART 10: EXAMPLE OF GOOD OUTPUT (Quality Bar)

For RQ-010g Sub-Question 4 (ActivityContext class), here is an example of the quality expected:

```dart
/// ActivityContext: Current physical activity state from Activity Recognition API.
///
/// Design notes:
/// - Uses Transition API (push-based) not polling
/// - Confidence threshold: 75% minimum to avoid false positives
/// - Integrates with ContextSnapshot as optional field
/// - Z-scores not applicable (discrete states, not continuous values)
class ActivityContext {
  /// Current detected activity
  final ActivityType currentActivity;

  /// Confidence score from Activity Recognition (0.0-1.0)
  final double confidence;

  /// Previous activity (for transition detection)
  final ActivityType? previousActivity;

  /// When this activity started (for duration tracking)
  final DateTime activityStarted;

  /// When this detection was captured
  final DateTime capturedAt;

  ActivityContext({
    required this.currentActivity,
    required this.confidence,
    this.previousActivity,
    required this.activityStarted,
    required this.capturedAt,
  });

  /// Has user been still for extended period? (opportunity for intervention)
  bool get isExtendedStill =>
      currentActivity == ActivityType.still &&
      DateTime.now().difference(activityStarted).inMinutes > 15;

  /// Is user in transit? (defer intervention)
  bool get isInTransit =>
      currentActivity == ActivityType.inVehicle ||
      (currentActivity == ActivityType.walking && previousActivity == ActivityType.inVehicle);

  /// Is user exercising? (high opportunity if matches habit)
  bool get isExercising =>
      currentActivity == ActivityType.running ||
      currentActivity == ActivityType.onBicycle;

  /// Confidence meets threshold for action?
  bool get isHighConfidence => confidence >= 0.75;

  Map<String, dynamic> toJson() => {
    'currentActivity': currentActivity.name,
    'confidence': confidence,
    'previousActivity': previousActivity?.name,
    'activityStarted': activityStarted.toIso8601String(),
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
      activityStarted: DateTime.parse(json['activityStarted'] as String),
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
- JSON serialization for persistence
- Integration with existing patterns

---

## PART 11: OUTPUT QUALITY CRITERIA

| Criterion | Question to Ask |
|-----------|-----------------|
| **Implementable** | Can an Android developer build this without clarifying questions? |
| **Integrated** | Does this work with existing ContextSnapshot and V-O Calculator? |
| **Battery-Conscious** | Is power consumption explicitly addressed? |
| **Privacy-First** | Does this store minimum necessary data? |
| **Degradation-Aware** | Does this work when permissions are denied? |
| **Bounded** | Are edge cases (dense urban, GPS drift, Doze Mode) handled? |
| **Confidence-Rated** | Is each recommendation tagged HIGH/MEDIUM/LOW? |

---

## PART 12: FINAL CHECKLIST BEFORE SUBMITTING

Before submitting your response, verify:

- [ ] RQ-010g ActivityContext class is complete Dart code (not pseudocode)
- [ ] RQ-010h Doze Mode strategy includes decision tree
- [ ] RQ-010e geofence allocation accounts for 100 limit
- [ ] All sub-questions have explicit answers
- [ ] Battery impact is quantified where possible
- [ ] Privacy-first principles are maintained
- [ ] Graceful degradation is addressed
- [ ] User scenarios (A, B, C) are solved step-by-step
- [ ] Confidence levels stated for each recommendation
- [ ] Integration points with existing code are explicit

---

## PART 13: RELATIONSHIP TO COMPANION PROMPT (RQ-010cdf)

This prompt focuses on **technical architecture**. A separate prompt (RQ-010cdf) covers:
- Permission request UX flows
- User-facing messaging (zone-based mental model)
- Permission denial recovery strategies
- Progressive disclosure timing

**Your outputs here feed into RQ-010cdf.** The UX prompt needs to know:
1. Which permissions are REQUIRED vs ENHANCING
2. What fallbacks exist for each denied permission
3. What the battery/privacy tradeoffs are

Ensure your outputs are explicit enough that the UX prompt can build user-facing flows.

---

*End of Prompt — DRAFT 2*
