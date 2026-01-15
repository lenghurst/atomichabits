# Deep Think Prompt: Permission UX & Privacy Experience (RQ-010cdf) — DRAFT 1

> **Target Research:** RQ-010c, RQ-010d, RQ-010f
> **Prepared:** 15 January 2026
> **For:** Google Deep Think / External AI Research
> **App Name:** The Pact
> **Companion Prompt:** RQ-010egh (Permission Technical Architecture) — COMPLETED

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
| **Zone** | A semantic location label (home, work, gym) — NOT GPS coordinates |
| **Guardian Mode** | Protective mode that suppresses distracting apps when user is at gym/study location |
| **Progressive Disclosure** | Revealing features/requests gradually as user trust builds |

### Tech Stack

- **Frontend:** Flutter 3.38.4 (Android-first, iOS deferred)
- **Backend:** Supabase (PostgreSQL + pgvector)
- **AI:** DeepSeek V3.2 for reasoning, Gemini for embeddings/TTS
- **Targets:** Android 14+ (API 34+) primary, minimum Android 8 (API 26)

### Why This Research Matters

Permissions are a **trust transaction**. Users grant access to sensitive data (location, activity, calendar) in exchange for perceived value. Permission requests are also the #1 cause of user abandonment — 40% of users uninstall apps that request "too many" permissions upfront.

This prompt focuses on the **UX and privacy experience** — how we ASK for permissions, WHEN we ask, HOW we message the value exchange, and what happens when users say NO.

---

## PART 2: YOUR ROLE

You are a **Senior UX Architect** specializing in:
- Privacy-first user experience design
- Permission request optimization and timing
- Trust-building progressive disclosure
- Mobile app onboarding flows
- Graceful degradation UX patterns
- User mental model design

Your approach: **Think step-by-step through each user scenario. Consider the emotional journey, not just the functional flow. Cite UX research where applicable. Prioritize user trust and long-term retention over short-term permission grants.**

---

## PART 3: TECHNICAL CONTEXT (From Companion Prompt RQ-010egh)

The technical architecture prompt has been completed. Here are the key findings that inform UX decisions:

### 3.1 Permission Requirements (Technical Reality)

| Permission | Technical Requirement | Fallback Available? |
|------------|----------------------|---------------------|
| `ACTIVITY_RECOGNITION` | Required for activity state (still, walking, running) | Yes — time-based inference only |
| `ACCESS_FINE_LOCATION` | Required for geofencing | Yes — manual check-in button |
| `ACCESS_BACKGROUND_LOCATION` | Required for always-on geofencing | Yes — retro-active "Did you go?" card |
| `READ_CALENDAR` | Required for schedule context | Yes — manual busy/free indication |
| `POST_NOTIFICATIONS` (Android 13+) | Required for nudges | No — app becomes passive |

### 3.2 WiFi Fallback Reality (CRITICAL UX IMPLICATION)

**Technical finding:** On Android 10+, reading WiFi SSID requires `ACCESS_FINE_LOCATION`.

**UX Implication:** We CANNOT use "WiFi-based location" as a privacy-friendly alternative to GPS. If we mention WiFi detection, users may think we're tracking less than we are. **Messaging must be honest.**

### 3.3 Zero-Permission Signals (What Works Without Asking)

These signals work with NO permissions:
1. **Time of day / Day of week** — Always available
2. **Charging state** — `BatteryManager.EXTRA_PLUGGED` (no permission)
3. **Screen on/off** — No permission needed
4. **App engagement** — User opened app = awake + available
5. **Historical patterns** — User's own habit data

### 3.4 Zone-Based Mental Model (Privacy Messaging)

**Technical decision:** We store **zone membership** (home, work, gym), NOT GPS coordinates in user history.

**UX Messaging:** Users should understand: "We see ZONES, not coordinates. We know you arrived at 'Gym' — we don't know the address."

---

## PART 4: CRITICAL INSTRUCTION — PROCESSING ORDER

These RQs have dependencies. Process in this exact sequence:

```
┌─────────────────────────────────────────────────────────────────────┐
│                         PROCESSING ORDER                             │
│                                                                      │
│  RQ-010d: Progressive Permission Strategy                           │
│     │                                                                │
│     │   Output: When to ask for each permission (timing)            │
│     ▼                                                                │
│  RQ-010f: Privacy-Value Transparency                                │
│     │                                                                │
│     │   Output: How to message each permission request              │
│     ▼                                                                │
│  RQ-010c: Degradation Scenarios                                     │
│     │                                                                │
│     │   Output: UX for each denial combination                      │
│     ▼                                                                │
│  [Outputs feed into implementation]                                 │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Rationale:** We must decide WHEN to ask (RQ-010d) before we design the ASK itself (RQ-010f). Degradation UX (RQ-010c) depends on both.

---

## PART 5: RESEARCH QUESTIONS

### RQ-010d: Progressive Permission Strategy

**Core Question:** When should we request each permission, and in what order?

**Why This Matters:**
- Asking all permissions upfront causes 40% abandonment
- Asking too late means missing JITAI opportunities
- Context matters — asking for gym location AFTER user creates gym habit = higher grant rate

**The Problem (Concrete Scenario):**
> New user Sarah downloads The Pact. Within 60 seconds, she sees:
> - Location permission dialog
> - Activity recognition dialog
> - Notification permission dialog
> - Calendar permission dialog
>
> **Result:** Sarah uninstalls. She hasn't even experienced the app's value yet.

**Current Hypothesis:**

| Stage | Trigger | Permission to Request |
|-------|---------|----------------------|
| **Onboarding** | App install | None (zero permissions initially) |
| **First Value** | After first habit created | `POST_NOTIFICATIONS` (to enable nudges) |
| **Location Habits** | User creates gym/location-based habit | `ACCESS_FINE_LOCATION` |
| **Background** | User has used location features for 7+ days | `ACCESS_BACKGROUND_LOCATION` |
| **Activity** | User creates exercise/movement habit | `ACTIVITY_RECOGNITION` |
| **Calendar** | User enables "respect my meetings" feature | `READ_CALENDAR` |

**Sub-Questions (Answer Each Explicitly):**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Zero-Permission Onboarding:** What is the maximum value we can deliver with ZERO permissions? | Design the first 5 minutes with no permissions |
| 2 | **First Permission Timing:** Which permission should be FIRST, and what triggers it? | Recommend with user psychology justification |
| 3 | **Location Permission Sequence:** Should we ask for Fine Location and Background Location together or separately? | Cite Android best practices |
| 4 | **Permission Bundling:** Are there permissions that should ALWAYS be requested together? | Identify bundles vs isolated requests |
| 5 | **Re-Request Strategy:** If user denies a permission, when (if ever) should we ask again? | Propose re-request timing with cooldown periods |
| 6 | **Trust Signals:** What user behaviors indicate readiness for more permissions? | List behavioral triggers (e.g., 3+ habits, 7+ days active) |

**Anti-Patterns to Avoid:**
- ❌ Requesting all permissions at install
- ❌ Requesting permissions before demonstrating value
- ❌ Requesting background location immediately (Play Store flags this)
- ❌ Re-requesting denied permissions immediately
- ❌ Using "scary" system dialogs without context

**Output Required for RQ-010d:**
1. Permission request timeline (visual or table)
2. Trigger conditions for each permission request
3. Re-request strategy with cooldown periods
4. Trust signal identification framework
5. Confidence Assessment: HIGH/MEDIUM/LOW for each recommendation

---

### RQ-010f: Privacy-Value Transparency

**Core Question:** How do we message each permission request to maximize trust AND grant rate?

**Why This Matters:**
- Generic system dialogs ("Allow The Pact to access your location?") have low grant rates
- Users grant permissions when they understand the VALUE EXCHANGE
- Privacy-conscious users need to understand what we DON'T collect

**The Problem (Concrete Scenario):**
> User sees Android's generic: "Allow The Pact to access your location?"
>
> User thinks: "Why do they need my location? Are they selling my data?"
>
> **Result:** User denies. They never learn that location enables "arrive at gym → encouragement" feature.

**Zone-Based Mental Model:**
> We want users to think: "The app knows I'm at THE GYM, not WHERE the gym is."
>
> **Messaging principle:** "We see zones, not coordinates."

**Current Hypothesis:**

| Permission | Value Message | Privacy Reassurance |
|------------|---------------|---------------------|
| Location | "Know when you arrive at the gym to cheer you on" | "We remember 'gym' — not the address" |
| Activity | "Detect when you start running to track your workout" | "We see 'walking' or 'running' — not a path" |
| Notifications | "Remind you at the perfect moment, not random times" | "You control exactly when we can nudge" |
| Calendar | "Respect your meetings — never interrupt focus time" | "We see 'busy' — not meeting details" |

**Sub-Questions (Answer Each Explicitly):**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Pre-Permission Screen:** Should we show an explanatory screen BEFORE the system dialog? | Design pre-permission screen structure |
| 2 | **Value-First Messaging:** How do we frame each permission as a USER benefit, not app requirement? | Write copy for each permission |
| 3 | **Zone Messaging:** How do we explain "zones not coordinates" in simple terms? | Propose 2-3 messaging variants for A/B test |
| 4 | **Denial Response:** What do we show IMMEDIATELY after a user denies a permission? | Design denial response flow |
| 5 | **Settings Deep Link:** How do we guide users to re-enable permissions later? | Propose settings recovery UX |
| 6 | **Privacy Dashboard:** Should we show users what data we've collected? | Design privacy transparency feature |

**Anti-Patterns to Avoid:**
- ❌ Using fear-based messaging ("Without location, the app won't work")
- ❌ Vague explanations ("To improve your experience")
- ❌ Technical jargon ("ACCESS_FINE_LOCATION")
- ❌ Lying about data collection practices
- ❌ Making promises we can't keep ("We NEVER track you")

**Output Required for RQ-010f:**
1. Pre-permission screen templates (one per permission)
2. Copy variants for A/B testing (2-3 per permission)
3. Zone-based mental model explanation (user-facing copy)
4. Denial response flow design
5. Privacy dashboard wireframe concept
6. Confidence Assessment: HIGH/MEDIUM/LOW for each recommendation

---

### RQ-010c: Degradation Scenarios

**Core Question:** What UX do we provide when users deny some or all permissions?

**Why This Matters:**
- 30-50% of users deny at least one permission
- App must provide value even with partial permissions
- Graceful degradation retains users who may grant permissions later

**The Problem (Concrete Scenario):**
> User Marcus denies location permission but grants notifications and activity.
>
> **Current state:** App crashes or shows blank screens where location features would be.
>
> **Desired state:** App works beautifully with what Marcus granted, gently shows what he's missing.

**Degradation Matrix (From Technical Research):**

| Permissions Granted | JITAI Capability | Degradation Level |
|--------------------|------------------|-------------------|
| ALL (Location + Activity + Calendar + Notifications) | Full context intelligence | 100% |
| Location + Activity + Notifications | Zone + movement context | 80% |
| Activity + Notifications only | Movement + time context | 60% |
| Notifications only | Time-based nudges | 40% |
| NONE | Manual-only mode | 20% |

**Sub-Questions (Answer Each Explicitly):**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **20% Mode UX:** What does the app look like with ZERO permissions? | Design "Manual Mode" experience |
| 2 | **40% Mode UX:** Notifications only — how do we make time-based nudges feel intelligent? | Propose smart scheduling UX |
| 3 | **Feature Gating:** Should location-dependent features be HIDDEN or shown with "Enable" prompt? | Recommend with pros/cons |
| 4 | **Upgrade Prompts:** How do we show users what they're missing without being annoying? | Design non-intrusive upgrade prompts |
| 5 | **Manual Fallbacks:** For each denied permission, what manual input replaces it? | Map fallbacks to denied permissions |
| 6 | **Success Stories:** How do we show users that granting permissions improved others' experience? | Propose social proof UX |

**Manual Fallback Mapping:**

| Denied Permission | Manual Fallback |
|-------------------|-----------------|
| Location | "I'm here" button with zone chips (Home / Work / Gym / Other) |
| Activity | "What are you doing?" prompt (Resting / Moving / Exercising) |
| Calendar | "Are you free right now?" yes/no toggle |
| Notifications | In-app reminders only (user must open app) |

**Anti-Patterns to Avoid:**
- ❌ Breaking the app when permissions denied
- ❌ Constantly nagging about denied permissions
- ❌ Making manual fallbacks feel like punishment
- ❌ Hiding ALL features behind permissions
- ❌ Showing empty states without explanation

**Output Required for RQ-010c:**
1. UX flow for each degradation level (20%, 40%, 60%, 80%, 100%)
2. Manual fallback UI designs
3. Upgrade prompt timing and placement
4. Feature visibility strategy (hidden vs disabled vs enabled)
5. "What you're missing" messaging that isn't annoying
6. Confidence Assessment: HIGH/MEDIUM/LOW for each recommendation

---

## PART 6: USER SCENARIOS (SOLVE STEP-BY-STEP)

### Scenario A: Privacy-Conscious User (Denies Everything)

> **Context:** Alex is privacy-conscious. Downloads The Pact. Denies ALL permission requests.
>
> **Questions to answer:**
> 1. What does Alex see on the home screen?
> 2. How does Alex log a habit completion?
> 3. What nudges (if any) does Alex receive?
> 4. After 2 weeks of successful use, how do we invite Alex to grant permissions?

### Scenario B: Gradual Trust Builder

> **Context:** Sarah grants notifications at onboarding, but denies location. After 1 week of using the app, she creates a "Gym 4x/week" habit.
>
> **Questions to answer:**
> 1. When should we ask Sarah for location permission?
> 2. What message do we show Sarah?
> 3. If Sarah denies again, what's her UX for the gym habit?
> 4. After 2 successful gym visits (manually logged), should we ask again?

### Scenario C: Permission Regret

> **Context:** Marcus granted all permissions initially. After 3 weeks, he goes to Android settings and revokes location permission.
>
> **Questions to answer:**
> 1. How does the app detect the revocation?
> 2. What does Marcus see next time he opens the app?
> 3. Do we ask Marcus why he revoked?
> 4. How do we gracefully degrade his experience?

### Scenario D: Dense Urban False Positives

> **Context:** Lisa's gym is above a Starbucks. The app sometimes thinks she's at the gym when she's getting coffee.
>
> **Questions to answer:**
> 1. How do we handle false-positive zone detection?
> 2. Should we ask Lisa to confirm arrival?
> 3. How do we prevent notification fatigue from false positives?
> 4. Should Lisa be able to "correct" the app's zone detection?

---

## PART 7: ARCHITECTURAL CONSTRAINTS (HARD REQUIREMENTS)

| Constraint | Rule | Rationale |
|------------|------|-----------|
| **Platform** | Android 14+ (API 34+) target | Permission UI varies by Android version |
| **No Dark Patterns** | Never use deceptive UX to gain permissions | Locked decision CD-010 |
| **Privacy-First** | Store zone labels, not coordinates | User trust requirement |
| **Graceful Degradation** | App MUST work with zero permissions | Core UX principle |
| **No Fear Messaging** | Never threaten reduced functionality | Trust-building approach |
| **Honest Messaging** | Never claim we collect less than we do | Legal/ethical requirement |

---

## PART 8: EXAMPLE OF GOOD OUTPUT (Quality Bar)

For RQ-010f Sub-Question 1 (Pre-Permission Screen), here is the quality expected:

### Pre-Permission Screen: Location

```
┌─────────────────────────────────────────┐
│                                         │
│  [Illustration: Map pin transforming    │
│   into a heart/encouragement icon]      │
│                                         │
│  "Cheer you on when you arrive"        │
│                                         │
│  When you get to the gym, we'll send   │
│  a quick boost to help you crush it.   │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  🔒 Privacy promise:                    │
│  We see "Gym" — not the address.       │
│  Your location history stays on your   │
│  phone, never our servers.              │
│                                         │
│  [Learn more about our privacy]         │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  [ Enable Location ]  [ Not Now ]       │
│                                         │
└─────────────────────────────────────────┘
```

**Design Notes:**
- Illustration shows VALUE, not surveillance
- Copy leads with benefit ("Cheer you on"), not request ("We need your location")
- Privacy promise is prominent but not primary
- "Not Now" is equal visual weight to "Enable" (no dark patterns)
- "Learn more" link for privacy-conscious users

**This is the quality bar.** Your outputs should match this level of:
- Visual wireframe (ASCII or description)
- Copy that leads with user value
- Privacy reassurance integrated
- No dark patterns
- Clear user choice

---

## PART 9: OUTPUT QUALITY CRITERIA

| Criterion | Question to Ask |
|-----------|-----------------|
| **User-Centered** | Does this prioritize user trust over permission grants? |
| **Honest** | Is all messaging truthful about what we collect? |
| **Graceful** | Does denied permission = degraded experience, not broken app? |
| **Non-Intrusive** | Will users feel nagged or respected? |
| **Actionable** | Can a designer implement this without clarifying questions? |
| **Testable** | Are there clear variants for A/B testing? |
| **Confidence-Rated** | Is each recommendation tagged HIGH/MEDIUM/LOW? |

---

## PART 10: FINAL CHECKLIST BEFORE SUBMITTING

Before submitting your response, verify:

- [ ] RQ-010d permission timeline covers ALL permissions
- [ ] RQ-010d includes re-request strategy with cooldowns
- [ ] RQ-010f includes pre-permission screen for each permission
- [ ] RQ-010f includes zone messaging copy variants
- [ ] RQ-010c includes UX for each degradation level (20-100%)
- [ ] RQ-010c includes manual fallback UI for each denied permission
- [ ] All user scenarios (A, B, C, D) solved step-by-step
- [ ] No dark patterns in any recommendation
- [ ] Privacy promises are truthful
- [ ] Confidence levels stated for each recommendation

---

## PART 11: RELATIONSHIP TO COMPANION PROMPT (RQ-010egh)

The technical prompt (RQ-010egh) established:
- Which permissions are REQUIRED vs ENHANCING
- What fallbacks exist for each denied permission
- Technical constraints (WiFi SSID requires location, etc.)

**Your outputs here must respect those technical realities.** For example:
- If technical says "geofencing requires FINE_LOCATION" → UX cannot promise geofencing without it
- If technical says "WiFi SSID needs location" → UX cannot claim WiFi is a privacy-friendly alternative

Your outputs will be used to:
1. Design the actual permission request screens
2. Write the user-facing copy
3. Implement the degradation UX
4. Train the AI to explain privacy in user conversations

---

*End of Prompt — DRAFT 1*
