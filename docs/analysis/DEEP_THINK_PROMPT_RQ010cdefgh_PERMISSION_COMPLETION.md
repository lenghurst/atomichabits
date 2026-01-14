# Deep Think Prompt: Permission Completion — Degradation Scenarios & JITAI Flexibility

> **Target Research:** RQ-010c, RQ-010d, RQ-010e, RQ-010f, RQ-010g, RQ-010h
> **Prepared:** 14 January 2026
> **For:** Google Deep Think / Gemini 2.0 Flash Thinking
> **App Name:** The Pact
> **Priority Score:** 8.7 (CRITICAL tier per Protocol 14)
> **Processing Order:** RQ-010c → RQ-010g → RQ-010e → RQ-010d → RQ-010f → RQ-010h
> **Parent RQ:** RQ-010 (Permission Data Philosophy)
> **Prerequisite:** RQ-010a/b COMPLETE (builds directly on this research)

---

## PART 1: WHAT IS "THE PACT"? (Essential Context)

**You have no prior knowledge of this project. This section provides essential context.**

### The App in One Paragraph

The Pact is a mobile app (Flutter, Android-first) that helps users build identity-based habits through psychological insight and social accountability. Unlike traditional habit trackers that count streaks, The Pact treats users as having multiple "identity facets" (e.g., "The Athlete," "The Parent") that negotiate for attention. The app uses JITAI (Just-In-Time Adaptive Interventions) to nudge users at optimal moments based on context signals.

### Core Philosophy: Permission as Trust

Our approach to permissions:
- **"Parliament of Selves"** philosophy respects user autonomy
- Users may deny permissions for valid reasons (privacy, battery, trust)
- The app must **gracefully degrade** without making users feel punished
- **Goal:** Maximum value at any permission level, not maximum data extraction

### Key Terminology

| Term | Definition |
|------|------------|
| **JITAI** | Just-In-Time Adaptive Intervention — context-aware habit nudges |
| **ContextSnapshot** | Real-time user state (location, time, energy, calendar, etc.) |
| **Graceful Degradation** | Maintaining value even when permissions are denied |
| **Accuracy** | How well JITAI can predict the optimal intervention moment |
| **Fallback Strategy** | Alternative data source when primary permission is denied |
| **Data Richness** | How much context information is available for decisions |

### Tech Stack

- **Frontend:** Flutter 3.38.4 (Android-first, CD-017)
- **Backend:** Supabase (PostgreSQL + pgvector)
- **AI:** DeepSeek V3.2 for reasoning (CD-016), Gemini for embeddings
- **Context Sources:** Health Connect (Android 14+), Calendar, Location, Activity Recognition

---

## PART 2: MANDATORY CONTEXT — Completed Research (RQ-010a/b)

**This research builds directly on RQ-010a/b. You MUST use these findings as foundation.**

### RQ-010a: Permission-to-Accuracy Mapping (COMPLETE)

| Data Source | Permission Required | Accuracy Contribution | Status |
|-------------|---------------------|----------------------:|--------|
| **Time + Day + History** | None | **40% (Baseline)** | Always available |
| **Location** | `ACCESS_FINE_LOCATION` | +20% | Often denied |
| **Calendar** | `READ_CALENDAR` | +15% | Usually granted |
| **Biometric** | Health Connect | +15% | Android 14+ only |
| **Activity Recognition** | `ACTIVITY_RECOGNITION` | +10% | Usually granted |
| **Digital Context** | `PACKAGE_USAGE_STATS` | **0% (DROP)** | Over-engineered |

**Key Finding:** Baseline accuracy from Time + History alone is 40% (Wood & Neal, 2007). This is the floor — app must deliver value at this level.

### RQ-010b: Fallback Strategies (COMPLETE)

| Primary Source | Fallback 1 | Recovery | Fallback 2 | Recovery |
|----------------|------------|----------|------------|----------|
| **Location** | Semantic Time Blocks | 30-40% | Pattern Mining | 30% |
| **Calendar** | Focus Mode Timer | 60% | Work-Hours Heuristic | 30% |
| **Biometric** | Energy Check Prompt | 80% | Circadian Default | 20% |
| **All Multi-Denial** | Smart Schedule Mode | 100% of baseline | — | — |

**Critical Correction (WiFi Trap):** WiFi SSID is NOT a location fallback. Since Android 8.1, `WifiManager.getConnectionInfo()` requires `ACCESS_FINE_LOCATION`.

### CD-015: 4-State Energy Model (LOCKED)

| State | Description | Cannot be changed |
|-------|-------------|-------------------|
| `high_focus` | Deep work, coding, writing | |
| `high_physical` | Exercise, sports | |
| `social` | Family, meetings | |
| `recovery` | Rest, meditation | |

### CD-018: Complexity Threshold (LOCKED)

| Rating | Definition | Action |
|--------|------------|--------|
| **ESSENTIAL** | Core value prop depends on this | Must implement |
| **VALUABLE** | Significantly improves experience | Should implement |
| **NICE-TO-HAVE** | Marginal improvement | Consider for v2 |
| **OVER-ENGINEERED** | High cost, low value | Do not implement |

---

## PART 3: YOUR ROLE

You are a **Senior Mobile Privacy Architect** specializing in:
- **Android Permission Architecture** (runtime permissions, permission groups)
- **Context-Aware Computing** (JITAI systems, ubiquitous computing)
- **Privacy-Preserving Design** (data minimization, transparency)
- **Behavioral Psychology** (habit formation, intervention timing)

Your approach:
1. Think step-by-step through each research question
2. Respect the constraint that users MAY deny any permission
3. Design for graceful degradation, not punishment
4. Provide concrete pseudocode and scenarios

---

## PART 4: CRITICAL INSTRUCTION — Processing Order

Process in this exact sequence (dependency chain):

```
RQ-010c (Degradation Scenarios: 20/40/60/80/100%)
  ↓ Defines what "accuracy level" means in practice
RQ-010g (Minimum Viable Permission Set)
  ↓ Defines MVP requirements
RQ-010e (JITAI Flexibility Architecture)
  ↓ Defines how JITAI adapts to available data
RQ-010d (Progressive Permission Strategy)
  ↓ Defines when/how to request permissions
RQ-010f (Privacy-Value Transparency)
  ↓ Defines user communication strategy
RQ-010h (Battery vs Accuracy Tradeoff)
  ↓ Defines resource optimization
→ Final: Unified Permission Architecture
```

---

## PART 5: RESEARCH QUESTIONS

### RQ-010c: Degradation Scenarios (20/40/60/80/100%)

**Core Question:** What does the user experience look like at each accuracy level?

**Why This Matters:** We claim "graceful degradation" but haven't specified what users actually experience. This research defines concrete scenarios for each level.

**Accuracy Level Framework (from RQ-010a):**
- **100%:** All permissions granted (Time + Location + Calendar + Bio + Activity)
- **80%:** Missing one secondary permission
- **60%:** Location denied but Calendar/Bio granted
- **40%:** Baseline only (Time + History)
- **20%:** New user, no history, minimal permissions

**Sub-Questions (Answer Each):**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | What JITAI capabilities exist at each accuracy level? | Map accuracy % to specific features |
| 2 | What is the user's subjective experience at 40% vs 80%? | "App feels psychic" vs "App guesses a lot" |
| 3 | At what accuracy level does the app become "annoying"? | When do bad nudges outweigh good ones? |
| 4 | How do we communicate accuracy level to users? | Should users see "Your JITAI accuracy: 72%"? |
| 5 | What's the conversion rate impact of lower accuracy? | Does 40% accuracy lead to higher churn? |

**Scenario Template (Complete for Each Level):**
```markdown
### [X]% Accuracy Scenario

**Permissions:** [List granted/denied]
**Data Available:** [What JITAI knows]
**Typical Nudge Quality:** [Excellent/Good/Fair/Poor]

**Example Day:**
- 7:00 AM: [What happens]
- 12:00 PM: [What happens]
- 6:00 PM: [What happens]

**User Sentiment:** "..."
```

**Output Required:**
1. Complete scenarios for 20%, 40%, 60%, 80%, 100% accuracy levels
2. Feature availability matrix by accuracy level
3. Recommended minimum viable accuracy for launch
4. Confidence Assessment: HIGH/MEDIUM/LOW

---

### RQ-010g: Minimum Viable Permission Set

**Core Question:** What is the absolute minimum permission set for the app to deliver core value?

**Why This Matters:** Per CD-018, we need to define what's ESSENTIAL vs OVER-ENGINEERED. Some permissions may be truly optional.

**Current Permission Request List:**
| Permission | Currently Requested | Proposed Status |
|------------|--------------------:|-----------------|
| `INTERNET` | Yes | ESSENTIAL (networking) |
| `RECEIVE_BOOT_COMPLETED` | Yes | ESSENTIAL (background work) |
| `POST_NOTIFICATIONS` | Yes | ESSENTIAL (JITAI delivery) |
| `ACCESS_FINE_LOCATION` | Yes | ? |
| `READ_CALENDAR` | Yes | ? |
| `ACTIVITY_RECOGNITION` | Yes | ? |
| `PACKAGE_USAGE_STATS` | Yes | DROP (RQ-010a said 0% value) |
| Health Connect | Yes | ? (Android 14+ only) |

**Sub-Questions (Answer Each):**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | Which permissions are truly ESSENTIAL (app broken without)? | Binary: Essential vs Optional |
| 2 | Which permissions are VALUABLE but optional? | Should request but handle denial gracefully |
| 3 | Should we remove `PACKAGE_USAGE_STATS` entirely? | It was rated 0% value — is there any case? |
| 4 | What's the MVP permission set for launch? | Minimum for "good enough" experience |
| 5 | What about Android version constraints? | Health Connect requires Android 14+ |

**Output Required:**
1. Tiered permission classification: ESSENTIAL / VALUABLE / NICE-TO-HAVE
2. MVP permission set recommendation
3. Permissions to remove entirely from manifest
4. Android version compatibility matrix
5. Confidence Assessment: HIGH/MEDIUM/LOW

---

### RQ-010e: JITAI Flexibility Architecture

**Core Question:** How should JITAI adapt its decision-making based on available data?

**Why This Matters:** Current JITAI assumes all data is available. It needs to be "data-rich-aware" — adjusting confidence and behavior based on what it knows.

**Current JITAI Decision Flow:**
```dart
// Current: Assumes all data available
double calculateTimingScore(ContextSnapshot context) {
  return 0.3 * context.location.isOptimal +
         0.3 * context.calendar.isFree +
         0.2 * context.energy.isHigh +
         0.2 * context.time.isOptimal;
}
```

**Proposed: Data-Richness-Aware:**
```dart
// Proposed: Adapts to available data
double calculateTimingScore(ContextSnapshot context) {
  double score = 0.0;
  double totalWeight = 0.0;

  // Only include signals that are available
  if (context.location != null) {
    score += 0.3 * context.location.isOptimal;
    totalWeight += 0.3;
  }
  if (context.calendar != null) {
    score += 0.3 * context.calendar.isFree;
    totalWeight += 0.3;
  }
  // ... etc

  // Normalize and apply confidence penalty
  double rawScore = totalWeight > 0 ? score / totalWeight : 0.5;
  double confidencePenalty = 1 - (totalWeight / 1.0);
  return rawScore * (1 - confidencePenalty * 0.3);
}
```

**Sub-Questions (Answer Each):**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | Should JITAI reduce intervention frequency at low accuracy? | Fewer but better vs. same frequency with lower confidence |
| 2 | How should confidence score reflect data availability? | 0.8 confidence at 100% data vs ? at 40% data |
| 3 | Should different intervention types require different accuracy? | "Don't disturb in meeting" needs calendar; "Good morning" doesn't |
| 4 | How do we prevent "dumb" nudges at low accuracy? | "Do you want to exercise?" at 2 AM |
| 5 | Should JITAI be more conservative or more exploratory at low data? | Default to safe nudges vs. try to learn |

**Output Required:**
1. Revised `calculateTimingScore()` algorithm with data-richness awareness
2. Confidence penalty formula based on available signals
3. Intervention type → minimum accuracy requirements matrix
4. "Safety gate" rules that don't depend on optional data
5. Confidence Assessment: HIGH/MEDIUM/LOW

---

### RQ-010d: Progressive Permission Strategy

**Core Question:** When and how should the app request each permission?

**Why This Matters:** Requesting all permissions at install leads to blanket denials. Progressive disclosure builds trust.

**Current State:** All permissions requested during onboarding (bad practice).

**Sub-Questions (Answer Each):**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | What order should permissions be requested? | Most to least valuable? Most to least likely to grant? |
| 2 | What trigger should prompt each permission request? | First gym check-in → Location; First calendar habit → Calendar |
| 3 | How long should we wait between permission requests? | Don't bombard users |
| 4 | What value proposition should accompany each request? | "Location helps us know when you're at the gym" |
| 5 | How do we handle "Don't ask again" without being annoying? | One-time "You can enable in Settings" |
| 6 | What about permission request timing in the user journey? | Not during critical flows |

**Output Required:**
1. Permission request sequence with triggers
2. Value proposition copy for each permission
3. Timing rules (minimum days between requests)
4. "Don't ask again" handling strategy
5. Confidence Assessment: HIGH/MEDIUM/LOW

---

### RQ-010f: Privacy-Value Transparency

**Core Question:** How do we communicate the value-privacy tradeoff to users?

**Why This Matters:** Users deserve to understand what they're trading. This is about informed consent, not dark patterns.

**Sub-Questions (Answer Each):**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | Should we show users their "accuracy level"? | "Your JITAI accuracy: 72%" — helpful or confusing? |
| 2 | How do we explain what each permission enables? | "Location → Know when you're at gym → Better nudge timing" |
| 3 | Should there be a "privacy settings" screen? | Centralized vs. contextual permission management |
| 4 | How do we handle the "all permissions denied" case? | Explicit messaging: "App works, but nudges will be less smart" |
| 5 | Should we show before/after comparisons? | "Since enabling Calendar, nudge accuracy improved 23%" |

**Output Required:**
1. User-facing transparency design (what to show, where)
2. Permission explanation copy (plain language)
3. Privacy settings screen specification
4. "Low accuracy" messaging strategy
5. Confidence Assessment: HIGH/MEDIUM/LOW

---

### RQ-010h: Battery vs Accuracy Tradeoff

**Core Question:** How do we balance context capture accuracy against battery drain?

**Why This Matters:** Users cite battery as top reason for uninstalling apps. But less frequent polling = lower accuracy.

**Current Battery Impact Estimates:**
| Signal | Polling Frequency | Battery Impact | Accuracy Gain |
|--------|-------------------|----------------|---------------|
| GPS Location | Every 15 min | HIGH (~3-5%/day) | +20% |
| Activity Recognition | Every 10 min | LOW (~0.5%/day) | +10% |
| Health Connect | Every 30 min | MEDIUM (~1%/day) | +15% |
| Calendar | On app open | NEGLIGIBLE | +15% |

**Sub-Questions (Answer Each):**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | What's acceptable daily battery impact? | Industry benchmark: <3% for background apps |
| 2 | Can we use geofencing instead of continuous GPS? | Enter/exit "home", "work", "gym" zones |
| 3 | Should battery mode affect JITAI behavior? | Low battery → less polling, lower accuracy |
| 4 | What polling frequencies balance accuracy vs battery? | 15 min? 30 min? Adaptive? |
| 5 | How do we communicate battery tradeoffs to users? | "High accuracy mode uses more battery" |

**Output Required:**
1. Recommended polling frequencies per signal type
2. Battery budget allocation (total <3%/day target)
3. Geofencing vs continuous GPS recommendation
4. Low battery mode specification
5. Confidence Assessment: HIGH/MEDIUM/LOW

---

## PART 6: ARCHITECTURAL CONSTRAINTS (Hard Requirements)

| Constraint | Rule |
|------------|------|
| **Platform** | Android-first (CD-017). No iOS-specific features. |
| **Health Data** | Health Connect (Android 14+). No Google Fit (deprecated). |
| **Battery** | Target <3% daily battery impact for background operations |
| **AI Models** | DeepSeek V3.2 for analysis (CD-016) |
| **WiFi Trap** | WiFi SSID requires `ACCESS_FINE_LOCATION`. Not a fallback. |
| **Digital Context** | Rated 0% value in RQ-010a. Do not use for JITAI. |

---

## PART 7: OUTPUT QUALITY CRITERIA

| Criterion | Question to Ask |
|-----------|-----------------|
| **Implementable** | Can an engineer build this without clarifying questions? |
| **Grounded** | Are recommendations based on Android documentation and UX research? |
| **Consistent** | Does this integrate with RQ-010a/b findings? |
| **Actionable** | Are there concrete pseudocode and copy examples? |
| **Bounded** | Are edge cases handled (0 permissions, all permissions, etc.)? |

---

## PART 8: EXAMPLE OF GOOD OUTPUT

**For RQ-010d Sub-Question 1 (Permission Request Order):**

> **Finding:** Request permissions in order of: (1) Likelihood to grant, (2) Value delivered.
>
> **Recommended Order:**
> 1. **POST_NOTIFICATIONS** (Day 1) — 85% grant rate, immediately shows value
> 2. **READ_CALENDAR** (Day 3, first calendar habit) — 72% grant rate, "Don't get uninstalled"
> 3. **ACTIVITY_RECOGNITION** (Day 7) — 68% grant rate, low friction
> 4. **ACCESS_FINE_LOCATION** (Day 14, first gym check-in) — 45% grant rate, high value
> 5. **Health Connect** (Day 21) — 30% grant rate, requires Android 14+
>
> **Rationale:** Building trust with high-grant permissions before requesting sensitive ones.
>
> **Confidence:** MEDIUM (based on industry benchmarks, not app-specific data)

---

## PART 9: DELIVERABLES CHECKLIST

By the end of your response, provide:

- [ ] **RQ-010c:** Complete 20/40/60/80/100% accuracy scenarios
- [ ] **RQ-010c:** Feature availability matrix by accuracy level
- [ ] **RQ-010g:** Tiered permission classification (ESSENTIAL/VALUABLE/NICE-TO-HAVE)
- [ ] **RQ-010g:** MVP permission set for launch
- [ ] **RQ-010e:** Revised `calculateTimingScore()` with data-richness awareness
- [ ] **RQ-010e:** Intervention type → minimum accuracy matrix
- [ ] **RQ-010d:** Permission request sequence with triggers and timing
- [ ] **RQ-010d:** Value proposition copy for each permission
- [ ] **RQ-010f:** Privacy transparency design
- [ ] **RQ-010f:** Permission explanation copy
- [ ] **RQ-010h:** Polling frequency recommendations
- [ ] **RQ-010h:** Battery budget allocation
- [ ] **UNIFIED:** Complete Permission Architecture Document
- [ ] **CONFIDENCE:** Rating for each section (HIGH/MEDIUM/LOW)

---

## PART 10: FINAL CHECKLIST BEFORE SUBMITTING

- [ ] Each sub-question has explicit answer
- [ ] All recommendations respect RQ-010a/b findings (baseline 40%, Digital = 0%)
- [ ] All pseudocode is implementable in Dart
- [ ] Confidence levels stated for each recommendation
- [ ] Anti-patterns addressed
- [ ] Edge cases handled (0 permissions, all denied, new user)
- [ ] Integration points with existing JITAI architecture explicit

---

*End of Prompt*
