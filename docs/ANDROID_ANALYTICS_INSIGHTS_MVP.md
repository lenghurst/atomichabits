# Android Analytics Insights - MVP Feature Analysis

**Date:** 2026-01-03
**Purpose:** Define current analytics capabilities and potential MVP features for behavior-based insights and interventions

---

## Executive Summary

Your app already has a **sophisticated JITAI (Just-In-Time Adaptive Intervention)** system with rich behavioral tracking. This document outlines:
1. Current analytics capabilities on Android
2. Specific doomscrolling detection abilities
3. Potential MVP features for intelligent user guidance
4. Technical implementation paths

---

## Part 1: Current Analytics Capabilities

### A. App Usage Tracking (Doomscrolling Detection Foundation)

**Status:** ✅ IMPLEMENTED
**Platform:** Android only
**File:** `lib/data/sensors/digital_truth_sensor.dart`

**What We Track:**
- Daily usage minutes per distraction app:
  - TikTok, Instagram, Twitter/X, Snapchat, Facebook, YouTube, Twitch
- **Dopamine Burn** metric: Total minutes on distraction apps
- **Apex Distractor**: Most-used distraction app of the day

**How It Works:**
- Uses Android's `UsageStatsManager` API via `app_usage` package
- Requires `PACKAGE_USAGE_STATS` permission (already declared)
- Queries system-level usage data from midnight to current time
- Returns aggregate minutes per app (not real-time streams)

**Current Limitations:**
- No scroll velocity or interaction depth detection
- No real-time streaming (batch queries only)
- Cannot detect WHAT user is doing within app (scrolling vs posting)
- iOS not supported (platform limitation)

**Data Example:**
```dart
{
  'com.instagram.android': 87.5,  // minutes today
  'com.zhiliaoapp.musically': 142.3,  // TikTok
  'dopamineBurn': 229.8,  // total distraction time
  'apexDistractor': 'TikTok'
}
```

---

### B. Multi-Sensor Context Tracking

**Status:** ✅ IMPLEMENTED
**File:** `lib/data/services/jitai/context_snapshot_aggregator.dart`

Your system aggregates **8 context channels** every 30 minutes in background:

| Channel | Data Collected | Use Case |
|---------|---------------|----------|
| **Time** | Hour, day-of-week, weekend, morning/evening flags | Temporal patterns |
| **Biometric** | Sleep duration Z-score, HRV Z-score, stress flags | Energy state detection |
| **Digital** | Distraction app usage Z-score, apex distractor | Doomscrolling state |
| **Location** | Current zone (home/work/gym), distance to habit location | Environment-habit fit |
| **Calendar** | Meeting density, free window duration | Busyness/availability |
| **Historical** | Streak, days since miss, resilience score | Momentum tracking |
| **UserOverride** | Manual vulnerability setting (4-hour TTL) | User self-awareness |
| **Weather** | Conditions, temperature, wind | External blockers |

**Context Snapshot Construction:**
- Personalized Z-scores (14-day rolling baseline)
- Binary flags for quick decision logic
- Used as input for ML/bandit intervention selection

---

### C. Pattern Detection & Failure Analysis

**Status:** ✅ IMPLEMENTED
**File:** `lib/data/services/pattern_detection_service.dart`

**Detected Patterns:**
1. **Time-based failures** (evening crashes, morning struggles)
2. **Day-of-week patterns** (Monday blues, weekend variance)
3. **Energy gaps** (tired, sick, stressed misses)
4. **Location mismatches** (travel, wrong place)
5. **Forgetfulness clusters**
6. **Recovery strength** (bounce-back ability)

**Miss Reason Taxonomy (15 categories):**
- **Time:** Too busy, wrong time, no time
- **Energy:** Tired, sick, bad mood, stressed
- **Location:** Traveling, wrong place, no equipment
- **Cognitive:** Forgot, no reminder, distracted
- **External:** Unexpected disruption, social obligation, emergency

**Output:** Health scores (0-100), pattern severity, confidence scores

---

### D. Intervention Triggering System

**Status:** ✅ IMPLEMENTED
**File:** `lib/domain/services/jitai_decision_engine.dart`

**Decision Pipeline (7 steps):**

1. **Vulnerability-Opportunity Calculation**
   - Vulnerability: Risk of failure (0.0-1.0)
   - Opportunity: Receptivity to intervention (0.0-1.0)
   - 4 quadrants: Silence / Wait / Light Touch / Intervene Now

2. **Optimal Timing Prediction**
   - ML-based timing analysis
   - Defers poorly-timed interventions

3. **Safety Gates**
   - Gottman Ratio check (positive:negative interaction balance)
   - Battery/connection checks
   - Rate limiting (max 8 interventions/day)

4. **Cascade Detection**
   - Weather blocking, travel disruption, weekend patterns
   - Triggers proactive intervention if cascade risk > 60%

5. **Shadow Trigger** (Rebel archetype only)
   - Autonomy-preserving crisis interventions

6. **Hierarchical Bandit Selection** (Thompson Sampling)
   - **Tier 1:** Select MetaLever (Activate/Support/Trust)
   - **Tier 2:** Select specific Intervention Arm (12 total)
   - Exploration decay over time

7. **Event Logging**
   - Logs context features, bandit values, arm exposure

**Intervention Taxonomy (12 Arms):**

| MetaLever | Philosophy | Arms |
|-----------|-----------|------|
| **ACTIVATE** | Identity reinforcement | Identity Mirror, Anti-Identity Warning, Vote Casting, Social Witness |
| **SUPPORT** | Reduce friction/barriers | Friction Reduction (Tiny Version, Environment Design), Emotional Regulation (Urge Surfing, Compassion), Cognitive Reframe |
| **TRUST** | Autonomy preservation | Strategic Silence, Shadow Intervention (rebels) |

---

### E. Notification & Delivery Infrastructure

**Status:** ✅ IMPLEMENTED
**Files:** `lib/data/notification_service.dart`, `lib/data/services/jitai/jitai_notification_service.dart`

**Notification Capabilities:**
- **Action buttons:** "Mark Done", "Snooze 30min", "Do 2-min version", "Send Nudge"
- **Privacy controls:** Lock screen visibility toggle
- **Smart copy generation:** Context-aware messaging via `NudgeCopywriter`
- **Channel segmentation:** Green (Activate), Blue (Support), Gray (Trust)

**Intervention Delivery:**
- Triggered by background worker (every 30 mins) or foreground checks
- Respects battery optimization and Doze mode
- Adaptive importance levels by MetaLever

---

### F. Background Monitoring

**Status:** ✅ IMPLEMENTED
**File:** `lib/data/services/jitai/jitai_background_worker.dart`

**Schedule:**
- Periodic: Every 30 minutes when app backgrounded
- Foreground: Immediate check on app resume
- One-off: Scheduled for optimal timing windows

**Per-Check Process:**
1. Load active habits and user profile
2. Build context snapshot (sensor aggregation)
3. Run JITAI decision for each habit
4. Deliver intervention notifications if triggered
5. Log intervention events

---

## Part 2: Doomscrolling Detection - What's Possible Now

### Current Capability: Macro-Level Detection

You can detect doomscrolling at the **app-level**, not interaction-level:

**Detectable Signals:**
- ✅ Total minutes on distraction apps (daily aggregate)
- ✅ Which app is being overused (apex distractor)
- ✅ Time of day when usage occurs (via context snapshots)
- ✅ Correlation with sleep deprivation (HRV/sleep Z-scores)
- ✅ Correlation with calendar busyness (procrastination)
- ✅ Correlation with location (home vs work doomscrolling)

**NOT Detectable (without AccessibilityService):**
- ❌ Scroll velocity or swipe frequency
- ❌ Active vs passive consumption (posting vs scrolling)
- ❌ Specific content types being consumed
- ❌ Real-time session duration (only batch totals)

### Example Doomscrolling Scenario Detection

**Scenario:** User is stress-doomscrolling on Instagram before bed

**Context Snapshot Would Show:**
```dart
{
  timeContext: { hour: 23, isEvening: true },
  biometricContext: {
    sleepZScore: -1.2,  // sleep deprived
    hrvZScore: -0.8,    // stressed
    isStressed: true
  },
  digitalContext: {
    distractionMinutesZScore: 2.1,  // way above baseline
    apexDistractor: 'Instagram',
    isHighDistraction: true
  },
  locationContext: { currentZone: 'home' },
  historicalContext: { daysSinceLastMiss: 0 }  // vulnerable
}
```

**JITAI Decision:**
- Vulnerability: HIGH (stress + sleep deprivation + recent miss)
- Opportunity: MEDIUM (at home, not in meeting)
- → **Quadrant: Intervene Now**

**Potential Intervention:** Urge Surfing notification
- "You've been on Instagram for 47 minutes. Your stressed self is craving escape, but your [Identity] self knows this won't actually help you feel better. Want to try a 90-second urge surfing session instead?"
- Action buttons: "Start Session" | "Not now"

---

## Part 3: Potential MVP Features for Accelerated Launch

### Feature 1: Doomscroll Detector + Urge Surfing Intervention

**Concept:** Real-time detection of excessive distraction app usage → trigger urge surfing intervention

**Implementation:**

**Data Sources:**
- `DigitalTruthSensor.getDopamineBurnMinutes()` - total distraction time
- `DigitalTruthSensor.getApexDistractor()` - which app
- User baseline (14-day rolling average)
- Current context (stress, sleep, time of day)

**Trigger Logic:**
```dart
// In JITAIBackgroundWorker or foreground check
if (digitalContext.distractionMinutesZScore > 1.5 &&  // 1.5 SD above baseline
    biometricContext.isStressed &&
    timeContext.isEvening &&
    vulnerabilityScore > 0.7) {

  // Select Urge Surfing intervention
  selectedArm = InterventionArm.urgeSurfing;

  // Deliver notification
  notificationService.showUrgeSurfingIntervention(
    apexDistractor: digitalContext.apexDistractor,
    minutesSpent: actualMinutes,
    identity: user.currentIdentity,
  );
}
```

**Notification Copy Example:**
> "You've been on TikTok for 87 minutes today—way more than your usual 25. Your stressed brain is seeking dopamine hits, but your [Athlete] self knows this is a procrastination spiral. Ready to surf the urge instead? 90 seconds."
>
> [Start Urge Surfing] [Not Now]

**Outcome Tracking:**
- Notification opened (yes/no)
- Session completed (yes/no)
- App usage next hour (reduction metric)
- Habit completion within 24h (did intervention help?)

**File Modifications:**
- `lib/domain/services/jitai_decision_engine.dart` - Add doomscroll detection logic
- `lib/data/services/jitai/jitai_notification_service.dart` - Add urge surfing notification template
- `lib/domain/entities/intervention.dart` - Track new outcome metrics

---

### Feature 2: Dopamine Burn Budget Dashboard

**Concept:** Visual dashboard showing daily distraction app usage vs personal baseline + progress over time

**UI Components:**
1. **Daily Burn Gauge:** Circular progress indicator
   - Green zone: < 30 min (baseline)
   - Yellow zone: 30-60 min
   - Red zone: > 60 min
   - Apex distractor badge

2. **Weekly Trend:** Line chart of dopamine burn over 7 days

3. **Pattern Insights:**
   - "You tend to doomscroll on TikTok on Sunday evenings when you're stressed."
   - "Your distraction time is 3x higher on days you miss your [Habit]."

4. **Cue-Trigger Insight:**
   - "Noticed: You open Instagram within 5 minutes of missing your meditation habit. This might be a stress-avoidance pattern."

**Data Requirements:**
- Historical `dopamineBurn` data (daily aggregates)
- Correlation analysis with miss events
- Pattern detection service integration

**File Locations:**
- New screen: `lib/presentation/screens/insights/dopamine_burn_dashboard.dart`
- Data service: Extend `lib/data/services/analytics_service.dart`
- Pattern correlation: `lib/data/services/pattern_detection_service.dart`

---

### Feature 3: Proactive Cue-Trigger Insight Notifications

**Concept:** Automatically detect behavioral patterns linking habit failures to distraction app usage → send educational insights

**Example Scenarios:**

**Scenario A: Procrastination Substitution**
- **Pattern Detected:** User opens TikTok within 10 minutes of scheduled habit time on 5/7 days
- **Insight Notification:**
  > "Pattern Alert: You've opened TikTok within 10 minutes of your 7 PM workout time for 5 days this week. This looks like procrastination substitution—your brain is dodging the hard thing by offering you an easier dopamine hit. Want to try a 2-minute version instead tonight?"
  > [Do 2-Min Workout] [Tell Me More]

**Scenario B: Stress Escape**
- **Pattern Detected:** High Instagram usage (2+ SD above baseline) on days with HRV < -1.0 (stressed)
- **Insight Notification:**
  > "Sherlock noticed: On stressed days (like today), you spend 3x more time on Instagram. Your [Identity] self knows scrolling won't actually reduce stress—it just postpones it. Want to try a grounding exercise instead?"
  > [Start Grounding] [Not Now]

**Scenario C: Evening Energy Crash**
- **Pattern Detected:** YouTube usage spikes after 9 PM on days with sleep < 6.5 hours
- **Insight Notification:**
  > "You're sleep-deprived (6.2 hours last night) and it's 9:47 PM. Your pattern: on tired evenings, you lose 90+ minutes to YouTube, then sleep even less. Break the cycle? Set a wind-down alarm for 10 PM?"
  > [Set Alarm] [Dismiss]

**Implementation:**

**Detection Service:**
```dart
class CueTriggerPatternDetector {
  // Analyze temporal correlation between:
  // 1. Habit scheduled time → distraction app usage
  // 2. Stress/sleep states → distraction app usage
  // 3. Misses → distraction app usage

  Future<List<CueTriggerInsight>> detectPatterns({
    required List<Habit> habits,
    required List<DigitalSnapshot> usageHistory,
    required List<BiometricSnapshot> biometricHistory,
  }) async {
    // Pattern A: Temporal proximity to habit time
    // Pattern B: Biometric state correlation
    // Pattern C: Miss event correlation

    return detectedInsights;
  }
}
```

**Notification Timing:**
- Delivered weekly (e.g., Sunday evening reflection)
- Or just-in-time when pattern is actively occurring
- Max 1 insight notification per day (avoid overwhelm)

**File Locations:**
- New service: `lib/domain/services/cue_trigger_pattern_detector.dart`
- Extend: `lib/data/services/pattern_detection_service.dart`
- Notifications: `lib/data/services/jitai/jitai_notification_service.dart`

---

### Feature 4: Identity-Based Dopamine Replacement

**Concept:** When doomscrolling detected, suggest identity-aligned alternative activities (temptation bundling in reverse)

**How It Works:**
1. Detect high distraction app usage (> 1.5 SD above baseline)
2. User's psychometric profile contains:
   - Current identity (e.g., "Athlete")
   - Core values (e.g., "Health", "Discipline")
   - Peak energy window (e.g., mornings)
3. Generate identity-aligned alternative suggestion

**Example Intervention:**
> "You've been scrolling Instagram for 62 minutes. Your [Athlete] self would rather spend this energy on something that actually moves you forward. How about:
> - 10-minute neighborhood walk (dopamine + aligned with identity)
> - Watch 1 motivational YouTube video from your saved list
> - Text your witness [Name] for a quick check-in
>
> Pick one, or keep scrolling—your choice."

**Data Requirements:**
- `PsychometricProfile.currentIdentity`
- `PsychometricProfile.coreValues`
- `Habit.temptationBundle` (could store identity-aligned alternatives)
- Pre-defined activity library per identity archetype

**File Locations:**
- New service: `lib/domain/services/dopamine_replacement_suggester.dart`
- Extend: `lib/domain/entities/psychometric_profile.dart` (add `identityAlignedActivities`)
- Notifications: `lib/data/services/jitai/jitai_notification_service.dart`

---

### Feature 5: Doomscroll → Habit Redirect

**Concept:** When user opens distraction app during habit time window, trigger immediate redirect notification

**Technical Approach:**

**Challenge:** No real-time app launch detection without AccessibilityService

**Workaround:** Periodic foreground checks when app resumes

**Implementation:**
1. User opens your app (foreground)
2. `JITAILifecycleObserver` triggers immediate context check
3. Check if current time is within habit time window (± 15 minutes)
4. Query `DigitalTruthSensor` for recent usage (last hour)
5. If high distraction app usage + within habit window → trigger redirect

**Example Notification:**
> "It's 7:12 PM—your meditation time. But you've been on TikTok for the last 22 minutes. Your [Mindful] self knows that scrolling is just delaying the thing that actually matters. Do the 2-minute version right now?"
> [Do 2-Min Version] [Snooze 15 Min]

**Limitation:** Only detects when user returns to your app, not when they initially open distraction app

**File Locations:**
- Extend: `lib/data/services/jitai/jitai_lifecycle_observer.dart`
- Add logic: `lib/domain/services/jitai_decision_engine.dart`

---

### Feature 6: Weekly Sherlock Insights Report

**Concept:** Automated weekly email/notification summarizing detected patterns, progress, and recommendations

**Content Sections:**
1. **Dopamine Burn This Week:** Total minutes, trend vs last week, apex distractor
2. **Detected Patterns:**
   - "You doomscroll on TikTok for 90+ minutes on Sunday nights when stressed."
   - "On days you complete your morning routine, distraction app usage drops 47%."
3. **Cue-Trigger Insights:**
   - "Noticed: You open Instagram within 5 minutes of skipping your workout 4/5 times this week."
4. **Identity Alignment Score:** How well behavior matched stated identity
5. **Recommendations:**
   - "Try scheduling your workout 30 minutes earlier to avoid the 7 PM procrastination window."
   - "Your peak dopamine burn is 9-11 PM. Consider a phone lockdown ritual at 9 PM."

**Data Sources:**
- `AnalyticsService.getWeeklyMetrics()`
- `PatternDetectionService.detectPatterns()`
- `DigitalTruthSensor` historical data
- `BiometricSensor` historical data
- `CueTriggerPatternDetector` (new service)

**Delivery:**
- In-app notification (Sunday 8 PM)
- Optional email digest
- Swipeable carousel UI in app

**File Locations:**
- New service: `lib/domain/services/sherlock_weekly_report_generator.dart`
- New screen: `lib/presentation/screens/insights/weekly_sherlock_report.dart`
- Notification: `lib/data/notification_service.dart`

---

## Part 4: Technical Feasibility Assessment

### What Requires No New Infrastructure

**Immediate (<1 week):**
- ✅ Feature 1: Doomscroll Detector (uses existing sensors + JITAI)
- ✅ Feature 2: Dopamine Burn Dashboard (frontend only, existing data)
- ✅ Feature 4: Identity-Based Dopamine Replacement (uses existing psychometric profile)

### What Requires New Services

**Medium Effort (1-2 weeks):**
- 🟡 Feature 3: Cue-Trigger Insight Notifications (new `CueTriggerPatternDetector` service)
- 🟡 Feature 6: Weekly Sherlock Report (new aggregation service + UI)

### What Requires New Permissions/Infrastructure

**Not Needed for MVP:**
- ❌ Feature 5: Real-time doomscroll redirect (requires AccessibilityService - invasive)

---

## Part 5: Recommended MVP Scope

### Phase 1: Core Analytics (1 week)
1. **Dopamine Burn Dashboard** (Feature 2)
   - Visual daily/weekly usage tracking
   - Apex distractor highlighting
   - Basic pattern insights

2. **Doomscroll Detector** (Feature 1)
   - Trigger urge surfing when usage > 1.5 SD above baseline
   - Integrate with existing JITAI pipeline
   - Track intervention outcomes

### Phase 2: Intelligent Insights (1-2 weeks)
3. **Cue-Trigger Pattern Detection** (Feature 3)
   - Temporal correlation analysis
   - Biometric state correlation
   - Proactive educational notifications

4. **Identity-Based Dopamine Replacement** (Feature 4)
   - Suggest identity-aligned alternatives
   - Track replacement activity completion

### Phase 3: Longitudinal Reporting (1 week)
5. **Weekly Sherlock Insights Report** (Feature 6)
   - Automated pattern summarization
   - Progress tracking
   - Personalized recommendations

### NOT for MVP:
- Real-time app launch detection (Feature 5) - too invasive
- Accessibility service integration - privacy concerns
- Scroll velocity tracking - requires AccessibilityService

---

## Part 6: Data Privacy Considerations

### Current Privacy Safeguards

**Local Processing:**
- All usage data processed locally on device
- Only aggregate metrics stored (not detailed logs)
- No raw usage events sent to backend

**User Control:**
- Optional sensitive notification mode (lock screen privacy)
- User can disable background worker
- User can revoke `PACKAGE_USAGE_STATS` permission

**Transparency:**
- Clear permission explanations in onboarding
- Settings screen showing what data is tracked
- Opt-in for biometric/location sensors

### Recommendations for New Features

**For Dopamine Burn Dashboard:**
- Show data retention policy (e.g., "7 days of detailed data, 90 days of aggregates")
- Allow user to clear usage history
- Export data option (user data ownership)

**For Cue-Trigger Insights:**
- User opt-in required ("Enable Sherlock pattern detection?")
- Clear explanations of what patterns are detected
- One-tap disable in settings

---

## Part 7: Success Metrics

### Feature Performance KPIs

**Dopamine Burn Dashboard:**
- % users who view dashboard weekly
- Average weekly dopamine burn (trend over time)
- Correlation between dashboard views and usage reduction

**Doomscroll Detector:**
- Intervention trigger rate (per user per week)
- Notification open rate
- Urge surfing session completion rate
- App usage reduction in next hour after intervention

**Cue-Trigger Insights:**
- Pattern detection accuracy (validated by user feedback)
- Insight notification open rate
- User rating of insight helpfulness (1-5 scale)
- Behavior change within 7 days of insight

**Weekly Sherlock Report:**
- Report open rate
- Time spent viewing report
- Recommendation acceptance rate
- Identity alignment score improvement week-over-week

---

## Part 8: Implementation Roadmap

### Week 1: Foundation
- [ ] Add dopamine burn data persistence (daily aggregates)
- [ ] Build `CueTriggerPatternDetector` service (correlation analysis)
- [ ] Create Dopamine Burn Dashboard UI
- [ ] Add doomscroll detection logic to `JITAIDecisionEngine`

### Week 2: Interventions
- [ ] Implement urge surfing notification template
- [ ] Create identity-based dopamine replacement suggester
- [ ] Add outcome tracking for new intervention types
- [ ] Test intervention triggering in background worker

### Week 3: Insights
- [ ] Build cue-trigger insight notification system
- [ ] Create weekly Sherlock report generator
- [ ] Design report UI (swipeable carousel)
- [ ] Schedule Sunday 8 PM report delivery

### Week 4: Polish
- [ ] Add privacy controls for new features
- [ ] User testing and feedback
- [ ] Performance optimization (battery impact)
- [ ] Documentation and help screens

---

## Part 9: Next Steps

### Immediate Actions

1. **Validate Assumptions:**
   - Test `DigitalTruthSensor` data quality on real devices
   - Verify background worker can query usage data reliably
   - Check battery impact of 30-minute periodic checks

2. **User Research:**
   - Survey target users: Do they want doomscroll detection?
   - Privacy concerns: How invasive feels acceptable?
   - Feature prioritization: Which insights most valuable?

3. **Technical Spikes:**
   - Prototype correlation analysis for cue-trigger patterns
   - Design database schema for historical usage data
   - Build sample dopamine burn dashboard UI

### Questions to Resolve

1. **Scope:** Which 2-3 features for absolute minimum MVP?
2. **Privacy:** How much usage data do we store? (retention policy)
3. **Permissions:** Do we need new permissions beyond current set?
4. **Intervention Fatigue:** How many doomscroll notifications per day is too many?
5. **Platform:** Android-only for MVP, or need iOS alternatives?

---

## Conclusion

You have an **exceptional foundation** for building intelligent, behavior-based interventions:

**Strengths:**
- ✅ Macro-level doomscrolling detection via UsageStatsManager
- ✅ Multi-sensor context aggregation (8 channels)
- ✅ Sophisticated JITAI intervention system
- ✅ Background monitoring infrastructure
- ✅ Hierarchical bandit for adaptive intervention selection

**Opportunities:**
- 🎯 Surface dopamine burn insights to users (dashboard)
- 🎯 Detect cue-trigger patterns (procrastination substitution)
- 🎯 Just-in-time urge surfing interventions
- 🎯 Identity-aligned dopamine replacement suggestions
- 🎯 Weekly longitudinal insights (Sherlock reports)

**Limitations:**
- ⚠️ No real-time app launch detection (requires AccessibilityService)
- ⚠️ No scroll velocity or interaction depth (macro-level only)
- ⚠️ Android-only (iOS lacks UsageStatsManager equivalent)

**Recommended MVP Scope:**
1. Dopamine Burn Dashboard (Feature 2)
2. Doomscroll Detector + Urge Surfing (Feature 1)
3. Cue-Trigger Insight Notifications (Feature 3)

This gives users visibility, just-in-time intervention, and educational insights—all with existing infrastructure and minimal new development.
