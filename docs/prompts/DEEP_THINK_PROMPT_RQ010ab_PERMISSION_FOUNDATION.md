# Deep Think Prompt: RQ-010a/b — Permission-to-Accuracy Mapping & Fallback Strategies

> **Parent RQ:** RQ-010 — Permission Data Philosophy & JITAI Graceful Degradation
> **This Prompt:** RQ-010a (Accuracy Mapping) + RQ-010b (Fallback Strategies)
> **SME Domains:** Mobile Privacy Architecture, Behavioral Intervention Systems, Context-Aware Computing
> **Prepared:** 14 January 2026
> **For:** Google Deep Think / Gemini / DeepSeek
> **App Name:** The Pact
> **Urgency:** **CRITICAL** — Outputs feed into 6 sibling sub-RQs and 30+ implementation tasks

---

## Your Role

You are a **Senior Mobile Privacy Architect & Context-Aware Systems Researcher** specializing in:
- Android permission models (runtime, manifest, special permissions)
- Just-In-Time Adaptive Intervention (JITAI) systems
- Graceful degradation patterns for sensor-dependent applications
- Privacy-preserving mobile health/wellness architecture
- Context inference from partial data

**Your approach:**
1. **Think step-by-step** through each permission's contribution to intervention accuracy
2. Model degradation **quantitatively** (specific percentages, not vague "it degrades")
3. Ground recommendations in **published research** (cite sources where available)
4. Consider the **"suspicious user"** who grants NOTHING initially — this is 15-30% of users
5. For each recommendation, present **2-3 options with tradeoffs** before recommending one

---

## Critical Instruction: Processing Order

```
RQ-010a (Permission-to-Accuracy Mapping) ← ANSWER FIRST
  ↓ Accuracy percentages enable...
RQ-010b (Fallback Strategies) ← ANSWER SECOND
  ↓ Both outputs feed into (answered in Prompt 2):
RQ-010c (Degradation Scenarios)
RQ-010g (Minimum Viable Permission Set)
```

**Process RQ-010a completely before starting RQ-010b.** The accuracy mapping directly informs which fallbacks are most critical.

---

## Sibling Sub-RQs (For Awareness — DO NOT Answer These Here)

| Sub-RQ | Title | Answered In |
|--------|-------|-------------|
| RQ-010c | Degradation Scenarios (20/40/60/80/100%) | Prompt 2 |
| RQ-010d | Progressive Permission Strategy | Prompt 3 |
| RQ-010e | JITAI Flexibility Architecture | Prompt 2 |
| RQ-010f | Privacy-Value Transparency UX | Prompt 3 |
| RQ-010g | Minimum Viable Permission Set | Prompt 2 |
| RQ-010h | Battery vs Accuracy Tradeoff | Prompt 3 |

**Your Focus:** RQ-010a and RQ-010b ONLY. Do not expand scope.

---

## PART 1: WHAT IS "THE PACT"? (Essential Context)

**You have no prior knowledge of this project. This section provides essential context.**

### The App in One Paragraph

The Pact is a mobile app (Flutter, Android-first) for **adults aged 25-45 who struggle with habit consistency** — people who've tried habit trackers but failed because willpower-based approaches don't address the psychological root causes of inconsistency. Unlike traditional habit trackers that count streaks, The Pact treats users as having multiple **"identity facets"** (e.g., "The Writer," "The Athlete," "The Present Father") that negotiate for attention. Users create "pacts" — commitments to become a certain type of person, not just to do a task.

### Core Philosophy: "Parliament of Selves" (psyOS)

The Pact is built on **psyOS (Psychological Operating System)** — a framework that models human identity as:

1. **One Integrated Self** with multiple **facets** (not competing personalities, but different aspects of who you want to be)
2. **Facets can interact:**
   - **Synergistic** — "The Athlete" supports "The Early Riser"
   - **Antagonistic** — "The Night Owl" fights "The Early Riser"
   - **Competitive** — "The Writer" and "The Parent" compete for the same time blocks
3. **Energy States** affect which facets can realistically be activated (4-state model):
   - `high_focus` — Deep cognitive work (writing, coding)
   - `high_physical` — Exercise, physical activity
   - `social` — Interpersonal interaction
   - `recovery` — Rest, passive relaxation
4. **JITAI's Job:** Recommend the right habit (facet activation) at the right moment based on user's current context

**Why Philosophy Matters for Permissions:**
- JITAI doesn't just say "do your habit" — it says "activate your Writer facet NOW because you're in high_focus energy state and your calendar shows you're free"
- Without context data, JITAI becomes a dumb timer — exactly what users already failed with
- The value proposition of The Pact depends on context awareness

### Tech Stack

| Component | Technology |
|-----------|------------|
| Frontend | Flutter 3.38.4 (Android-first, no iOS at MVP) |
| Backend | Supabase (PostgreSQL + pgvector for embeddings) |
| AI Reasoning | DeepSeek V3.2 (analyst mode), DeepSeek R1 Distilled (reasoning) |
| On-Device | WorkManager for background context sensing |

---

## PART 2: MANDATORY CONTEXT — Locked Architecture

These decisions are CONFIRMED and cannot be changed. Your recommendations must work within these constraints.

### CD-015: 4-State Energy Model (LOCKED)

The app uses exactly **4 energy states** — not 5, not 3. This is a core architectural decision.

| State | Description | Typical Activities |
|-------|-------------|-------------------|
| `high_focus` | Deep cognitive work requiring sustained attention | Writing, coding, strategic planning |
| `high_physical` | Exercise or physical activity | Running, gym, sports |
| `social` | Interpersonal interaction | Meetings, family time, social events |
| `recovery` | Rest and recharge | Sleep, meditation, passive relaxation |

**Implication for RQ-010:** JITAI needs to detect which energy state the user is in (or could transition to) to make relevant suggestions.

### CD-017: Android-First (LOCKED)

All features must work on Android without iOS or wearable integration. This means:
- No Apple HealthKit
- No Apple Watch APIs
- No iOS-specific permission models
- Target API 33+ (Android 13+), but support back to API 26 (Android 8)

### RQ-048c: Switching Cost Matrix (COMPLETED)

We have validated that transitioning between energy states takes different amounts of time:

| FROM ↓ / TO → | high_focus | high_physical | social | recovery |
|---------------|------------|---------------|--------|----------|
| high_focus | — | 15 min | 15 min | 30 min |
| high_physical | 25 min | — | 20 min | 30 min |
| social | 25 min | 15 min | — | 20 min |
| recovery | 25 min | 20 min | 15 min | — |

**Implication:** JITAI shouldn't suggest a high_focus task if user just finished social mode — they need 25 minutes to transition. Knowing current context prevents bad suggestions.

---

## PART 3: THE PROBLEM

### The Permission Paradox

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                         THE PERMISSION PARADOX                               │
│                                                                              │
│  JITAI EFFECTIVENESS requires context data:                                  │
│    • Location → Is user at gym? Home? Office?                                │
│    • Calendar → Is user in a meeting? Free?                                  │
│    • Health Connect → Did user sleep well? Current heart rate?               │
│    • Activity Recognition → Walking? Stationary? Driving?                    │
│    • Notifications → Can we even reach them?                                 │
│                                                                              │
│  BUT: Users increasingly DENY permissions:                                   │
│    • 50-70% deny at least one permission (industry data)                     │
│    • 15-30% are "paranoid" users who deny most/all                           │
│    • Permission denial rates are INCREASING year over year                   │
│                                                                              │
│  RESULT: System designed for 100% context may FAIL at 40%                   │
│                                                                              │
│  THIS RESEARCH: Quantify each permission's contribution so we can            │
│                 gracefully degrade instead of catastrophically fail          │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Current State: ContextSnapshot Class

The JITAI system consumes a `ContextSnapshot` object with these fields:

```dart
/// Context collected for JITAI decision-making
class ContextSnapshot {
  final TimeContext time;          // Always available (no permission needed)
  final BiometricContext? bio;     // Requires Health Connect (Android 14+)
  final CalendarContext? calendar; // Requires READ_CALENDAR permission
  final WeatherContext? weather;   // API call (needs INTERNET, always granted)
  final LocationContext? location; // Requires ACCESS_FINE_LOCATION or COARSE
  final DigitalContext? digital;   // Requires PACKAGE_USAGE_STATS (special)
  final HistoricalContext history; // App-internal data (no permission needed)
}

/// What TimeContext provides (always available)
class TimeContext {
  final DateTime now;              // Current time
  final String dayOfWeek;          // "Monday", "Tuesday", etc.
  final bool isWeekend;            // Saturday or Sunday
  final String timeOfDay;          // "morning", "afternoon", "evening", "night"
}

/// What BiometricContext provides (requires Health Connect)
class BiometricContext {
  final double? restingHeartRate;  // BPM
  final double? sleepHours;        // Last night's sleep duration
  final int? sleepQuality;         // 1-100 scale
  final int? steps;                // Steps today
  final double? hrv;               // Heart rate variability (stress indicator)
}

/// What CalendarContext provides (requires READ_CALENDAR)
class CalendarContext {
  final bool isBusy;               // Currently in an event
  final DateTime? nextEventStart;  // When next event begins
  final int minutesUntilNextEvent; // Free time remaining
  final String? currentEventTitle; // What they're doing (if busy)
}

/// What LocationContext provides (requires ACCESS_FINE_LOCATION)
class LocationContext {
  final String? placeType;         // "home", "work", "gym", "commuting", "other"
  final bool isAtKnownPlace;       // At a labeled location
  final double? latitude;          // GPS coordinates
  final double? longitude;
}

/// What DigitalContext provides (requires PACKAGE_USAGE_STATS)
class DigitalContext {
  final int screenTimeMinutes;     // Today's total screen time
  final String? lastAppUsed;       // Most recent app
  final bool isPhoneInUse;         // Currently using phone
  final int? socialMediaMinutes;   // Time on social media today
}

/// What HistoricalContext provides (no permission needed)
class HistoricalContext {
  final List<HabitCompletion> recentCompletions;  // Last 7 days
  final Map<String, double> facetStrengths;       // Facet → strength score
  final List<String> commonPatterns;              // "Usually writes at 6am"
}
```

**The Gap:** No documentation exists for:
- What happens when `bio` is null?
- What happens when `calendar` is null?
- What happens when 50% of context is missing?
- Which fields contribute most to JITAI accuracy?

---

## PART 4: ANDROID PERMISSION REFERENCE

### Permissions Required by ContextSnapshot

| Context Field | Android Permission(s) | Category | Estimated Deny Rate* | What's Lost if Denied |
|---------------|----------------------|----------|---------------------|----------------------|
| `time` | None | — | 0% | Nothing (always available) |
| `weather` | INTERNET | Normal | ~0% | Outdoor activity context |
| `history` | None (app-internal) | — | 0% | Nothing (always available) |
| `location` | ACCESS_FINE_LOCATION or ACCESS_COARSE_LOCATION | Dangerous | 30-50% | Gym/home/work detection, commute detection |
| `calendar` | READ_CALENDAR | Dangerous | 40-60% | Meeting awareness, free time calculation |
| `bio` | Health Connect access | Special | 50-70% | Sleep quality, HRV stress indicator, activity level |
| `digital` | PACKAGE_USAGE_STATS | Special | 70-90% | Screen time, distraction detection |
| (implied) | ACTIVITY_RECOGNITION | Dangerous | 30-40% | Walking/stationary/driving detection |
| (implied) | POST_NOTIFICATIONS (Android 13+) | Dangerous | 20-40% | Ability to proactively nudge user |

*Estimated from industry data (Google Play Console averages, not app-specific)

### Permission Category Behaviors

| Category | Android Behavior | User Experience |
|----------|------------------|-----------------|
| **Normal** | Granted at install, no prompt | User never sees |
| **Dangerous** | Runtime prompt, user can deny, can revoke later | Prompt appears when permission first requested |
| **Special** | Must redirect to Settings, manual toggle | High friction, many users abandon |

---

## PART 5: RESEARCH QUESTION RQ-010a — Permission-to-Accuracy Mapping

### Core Question

**What is the quantitative contribution of each permission to JITAI intervention timing accuracy?**

### Why This Matters

Not all permissions are equal. Some provide high-value context (location tells us you're at the gym); others provide marginal value (digital context tells us you've been on social media). Understanding the contribution of each permission allows us to:
1. Prioritize which permissions to request
2. Know when we have "enough" context to make good suggestions
3. Set user expectations ("With current permissions, JITAI is ~60% accurate")

### Current Hypothesis (Validate or Refine)

Our initial assumption (unvalidated):

| Context Source | Hypothesized Accuracy Contribution | Rationale |
|----------------|-----------------------------------|-----------|
| Time + History (baseline) | 40% | Patterns like "user writes at 6am on weekdays" |
| Location | 20% | Knowing you're at gym vs home vs work |
| Calendar | 15% | Knowing you're free vs in a meeting |
| Biometric | 10% | Sleep quality affects suggested intensity |
| Activity Recognition | 10% | Knowing you're walking vs stationary |
| Digital | 5% | Distraction level is secondary signal |

**Total:** 100%

**Your task:** Validate, refine, or replace this model with evidence-based estimates.

### Sub-Questions (Answer Each Explicitly)

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Baseline Accuracy:** With ONLY TimeContext + HistoricalContext (no permissions), what JITAI accuracy is achievable? | Provide percentage estimate with confidence level. Cite pattern recognition literature if available. |
| 2 | **Location Contribution:** How much does knowing location (home/work/gym/commuting) improve intervention timing? | Provide percentage improvement estimate. Consider: does location enable energy state inference? |
| 3 | **Calendar Contribution:** How much does knowing calendar state (free/busy/time-until-next) improve timing? | Provide percentage estimate. Consider: calendar is proxy for interruptibility. |
| 4 | **Biometric Contribution:** How much does Health Connect data (sleep, HRV, steps) improve timing? | Provide percentage estimate. Note: Android 14+ only; pre-14 devices get 0% biometric value. |
| 5 | **Activity Contribution:** How much does ACTIVITY_RECOGNITION (walking/stationary/driving) improve timing? | Provide percentage estimate. Consider overlap with location. |
| 6 | **Digital Contribution:** How much does screen time/app usage data improve timing? | Provide percentage estimate. Note: 70-90% deny this permission. |
| 7 | **Marginal Value Ranking:** Rank permissions by marginal value (accuracy gain per privacy cost). | Output: Ordered list from highest to lowest value. |
| 8 | **Redundancy Analysis:** Which context sources overlap (e.g., location + time can infer "at work")? | Identify redundant signals that could compensate for denied permissions. |

### Anti-Patterns to Avoid

```
❌ Citing Miller's 7±2 for memory — this is about intervention timing, not recall
❌ Assuming 100% is achievable — even full context has uncertainty
❌ Treating all locations equally — "at gym" is higher value than "at restaurant"
❌ Ignoring temporal patterns — time + history may dominate for users with consistent routines
❌ Assuming biometric data is available — 50%+ will deny Health Connect
```

### Output Required for RQ-010a

1. **Permission → Accuracy Contribution Table**
   - Each context source with percentage contribution
   - Confidence level (HIGH/MEDIUM/LOW) for each estimate
   - Citation or reasoning for each number

2. **Marginal Value Ranking**
   - Ordered list: Permission → Value/Privacy ratio
   - Which permission is the "best deal" for users?

3. **Redundancy Matrix**
   - Which signals overlap?
   - If permission A is denied, can permission B partially compensate?

4. **Baseline Accuracy Model**
   - What can JITAI achieve with ZERO optional permissions?
   - Is this baseline "good enough" for a degraded experience?

5. **Confidence Assessment**
   - Rate each recommendation HIGH/MEDIUM/LOW
   - For MEDIUM/LOW, note what research would increase confidence

---

## PART 6: RESEARCH QUESTION RQ-010b — Fallback Strategies

### Core Question

**For each permission that may be denied, what fallback strategies should JITAI use to maintain functionality?**

### Why This Matters

Each denied permission creates a gap. But gaps can sometimes be filled by:
- **Direct substitutes:** Use another signal (WiFi SSID instead of GPS)
- **Inference:** Predict from available data ("usually at gym at 6pm")
- **User prompt:** Ask directly ("Where are you?" — low-tech but works)
- **Population defaults:** Use average behavior as fallback

### Current Hypothesis (Validate or Refine)

| Permission Denied | Potential Fallbacks | Expected Accuracy Recovery |
|-------------------|--------------------|-----------------------------|
| Location | WiFi SSID inference, time patterns, manual button | 50-70% of location value |
| Calendar | "Busy now" toggle, time-of-day defaults | 40-60% of calendar value |
| Biometric | Self-reported sleep, time-based energy defaults | 30-50% of biometric value |
| Digital | None (too invasive to ask) | 0% — accept the loss |
| Notifications | Widget, in-app prompts on next open | 20-40% of notification value |

### Sub-Questions (Answer Each Explicitly)

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Location Fallbacks:** If ACCESS_FINE_LOCATION denied, what are the top 3 fallback strategies? | For each: (a) How it works, (b) Accuracy recovery %, (c) User friction, (d) Implementation complexity |
| 2 | **Calendar Fallbacks:** If READ_CALENDAR denied, what are the top 3 fallback strategies? | Same structure as above |
| 3 | **Biometric Fallbacks:** If Health Connect denied, what are the top 3 fallback strategies? | Same structure. Note Android 14+ constraint. |
| 4 | **Digital Fallbacks:** If PACKAGE_USAGE_STATS denied, is fallback possible or should we accept the loss? | Recommend: fallback or graceful exclusion? |
| 5 | **Notification Fallbacks:** If POST_NOTIFICATIONS denied, how can JITAI still deliver value? | This may be the "gatekeeper" permission — analyze critically. |
| 6 | **Cascading Fallbacks:** If BOTH location AND calendar denied, do fallbacks compound or conflict? | Consider multi-denial scenarios. |

### Concrete User Scenario: "Sarah the Skeptic"

Use this scenario to validate your fallback strategies:

**Sarah** is a 32-year-old who:
1. Downloaded The Pact because a friend recommended it
2. Denied Location and Health Connect during onboarding ("I don't trust apps with my data")
3. Granted only Notifications and Calendar

**Walk through Sarah's first week:**

| Day | Event | Question to Answer |
|-----|-------|-------------------|
| Day 1 | Sarah sets up "The Writer" facet with 6am writing goal | What does JITAI show her at 6am? Does it know she's at home? |
| Day 3 | Sarah goes to gym at 6pm (JITAI doesn't know — no location) | She opens app at gym. Can JITAI infer she's there? What fallback fires? |
| Day 5 | Sarah's calendar shows "blocked" for a meeting that got cancelled | JITAI thinks she's busy. How does she correct this? |
| Day 7 | Sarah has used the app for a week | What patterns has JITAI learned? Is it getting better without location? |

**Use Sarah's journey to validate that fallbacks actually work.**

### Anti-Patterns to Avoid

```
❌ Fallbacks that require MORE permissions (e.g., WiFi SSID needs ACCESS_WIFI_STATE)
❌ Fallbacks with high user friction that users won't actually use
❌ Assuming users will self-report accurately and consistently
❌ Battery-draining workarounds (polling location frequently)
❌ Suggesting "just ask again later" as primary strategy
```

### Output Required for RQ-010b

1. **Fallback Strategy Table**

   For EACH permission:
   | Permission | Primary Fallback | Accuracy Recovery | User Friction | Implementation |
   |------------|------------------|-------------------|---------------|----------------|
   | Location | ... | X% | Low/Med/High | Easy/Med/Hard |
   | ... | ... | ... | ... | ... |

2. **Multi-Denial Scenario Analysis**
   - What if 2+ permissions denied simultaneously?
   - Do fallbacks compose or conflict?

3. **Sarah's Week Resolution**
   - Specific answers to each day's question
   - Demonstrates fallbacks work in practice

4. **"Accept the Loss" Recommendations**
   - Which permissions have no viable fallback?
   - Recommendation: invest in fallback or accept degraded experience?

5. **Pseudocode: Fallback Decision Tree**
   ```
   // Provide pseudocode or flowchart showing:
   // IF location == null THEN
   //   IF wifiSSID in knownLocations THEN ...
   //   ELSE IF timePattern suggests gym THEN ...
   //   ELSE useDefault(...)
   ```

6. **Confidence Assessment**
   - Rate each fallback strategy HIGH/MEDIUM/LOW confidence
   - Note which need user testing to validate

---

## PART 7: ARCHITECTURAL CONSTRAINTS (Hard Requirements)

| Constraint | Rule | Why |
|------------|------|-----|
| **Platform** | Android-first (Flutter). No iOS-specific APIs. | Locked decision (CD-017) |
| **Android Version** | Target API 33+, support back to API 26 | Health Connect = Android 14+ only |
| **Health Connect** | Must gracefully handle devices without it | Pre-Android 14 = no biometric context |
| **Battery** | < 5% daily battery impact | Users will uninstall battery hogs |
| **Background** | WorkManager for periodic checks | No persistent foreground service |
| **No Internet Polling** | Weather API has rate limits | Cache weather, don't poll constantly |

---

## PART 8: OUTPUT QUALITY CRITERIA

| Criterion | Question to Ask |
|-----------|-----------------|
| **Quantitative** | Are accuracy percentages specific numbers (not "good" or "reduced")? |
| **Evidence-Based** | Are estimates grounded in research or clearly marked as inference? |
| **Actionable** | Can an engineer implement the fallback without clarification? |
| **User-Validated** | Does Sarah's scenario actually work with proposed fallbacks? |
| **Robust** | Do fallbacks work when MULTIPLE permissions are denied? |
| **Battery-Aware** | Do fallbacks avoid battery-draining patterns? |

---

## PART 9: EXAMPLE OF GOOD OUTPUT

**For RQ-010b Sub-Question 1 (Location Fallbacks):**

```markdown
### Location Permission Denied: Fallback Strategies

**Permission:** ACCESS_FINE_LOCATION / ACCESS_COARSE_LOCATION
**Contribution if Granted:** ~20% of JITAI accuracy (from RQ-010a)
**Deny Rate:** 30-50%

**Fallback Strategy 1: WiFi SSID Inference**
- **How it works:** User labels home/work WiFi during setup ("This is my home network"). When connected to known SSID, infer location without GPS.
- **Requires:** ACCESS_WIFI_STATE (normal permission, auto-granted)
- **Accuracy Recovery:** ~75% of location value (15% of total JITAI accuracy)
- **User Friction:** LOW (one-time setup during onboarding)
- **Implementation Complexity:** MEDIUM (need SSID → location mapping table)
- **Limitations:** Doesn't work outside WiFi range (commuting, gym without WiFi)

**Fallback Strategy 2: Time-Pattern Inference**
- **How it works:** After 2 weeks of usage, infer: "User usually at gym 6-7pm on weekdays"
- **Requires:** No additional permissions (uses HistoricalContext)
- **Accuracy Recovery:** ~50% of location value (10% of total)
- **User Friction:** NONE (passive learning)
- **Implementation Complexity:** MEDIUM (pattern mining algorithm)
- **Limitations:** Fails for users with inconsistent routines; 2-week cold start

**Fallback Strategy 3: Manual "I'm Here" Button**
- **How it works:** Quick-access button: "I'm at: [Home] [Work] [Gym] [Other]"
- **Requires:** No permissions
- **Accuracy Recovery:** ~95% of location value when used (19% of total)
- **User Friction:** HIGH (requires active user input every time)
- **Implementation Complexity:** LOW
- **Limitations:** Users forget; not viable as primary strategy

**Recommended Approach for Location-Denied Users:**
1. **Primary:** WiFi SSID inference (automatic, decent accuracy)
2. **Secondary:** Time-pattern inference (improves over 2 weeks)
3. **Tertiary:** Manual button for power users who want precision

**Confidence:** MEDIUM
- WiFi SSID inference is proven technique (used by Google, Apple for indoor positioning)
- Time-pattern accuracy varies significantly by user (consistent routines = high accuracy)
- Manual button adoption rates unknown (need user testing)

**Citation:** Google's "Indoor Positioning Using WiFi Fingerprinting" (2018) shows 70-85% room-level accuracy with SSID-only approach.
```

---

## PART 10: FINAL CHECKLIST BEFORE SUBMITTING

- [ ] RQ-010a: Each sub-question (1-8) has explicit answer with percentage
- [ ] RQ-010a: Accuracy contribution table includes confidence levels
- [ ] RQ-010a: Marginal value ranking provided
- [ ] RQ-010a: Redundancy matrix identifies overlapping signals
- [ ] RQ-010b: Each sub-question (1-6) has explicit answer
- [ ] RQ-010b: Fallback table with accuracy recovery percentages
- [ ] RQ-010b: Sarah's scenario resolved day-by-day
- [ ] RQ-010b: Pseudocode/flowchart for fallback decision tree
- [ ] All estimates include confidence level (HIGH/MEDIUM/LOW)
- [ ] Research citations provided where available
- [ ] Battery constraints respected in fallback designs
- [ ] Multi-denial scenarios addressed

---

## PART 11: INTEGRATION POINTS

This research feeds directly into:

| Downstream RQ/Task | How It Uses This Output |
|--------------------|------------------------|
| RQ-010c (Degradation Scenarios) | Uses accuracy percentages to model 20/40/60/80% scenarios |
| RQ-010g (Minimum Viable) | Uses baseline accuracy to determine if JITAI is worth having |
| B-10 (ContextSnapshot implementation) | Uses fallback strategies for null-handling |
| B-11 (calculateTensionScore) | Uses accuracy weights in scoring algorithm |

---

*End of Prompt*
