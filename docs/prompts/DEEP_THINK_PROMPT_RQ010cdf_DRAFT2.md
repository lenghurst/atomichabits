# Deep Think Prompt: Permission UX & Privacy Experience (RQ-010cdf) — DRAFT 2

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
| **Zone** | A semantic location label (home, work, gym) — NOT GPS coordinates |
| **Guardian Mode** | Protective mode that suppresses distracting apps when user is at gym/study location |
| **Pre-Permission Screen** | Contextual UI shown BEFORE OS permission dialog to explain value |
| **Glass Pane** | Our term for the pre-permission bottom sheet component |

### Tech Stack

- **Frontend:** Flutter 3.38.4 (Android-first, iOS deferred)
- **Backend:** Supabase (PostgreSQL + pgvector)
- **AI:** DeepSeek V3.2 for reasoning, Gemini for embeddings/TTS
- **Targets:** Android 14+ (API 34+) primary, minimum Android 8 (API 26)

---

## PART 2: YOUR ROLE

You are a **Senior UX Architect** specializing in:
- Privacy-first user experience design
- Permission request optimization and timing
- Trust-building progressive disclosure
- Mobile app onboarding flows
- Graceful degradation UX patterns
- Android permission UX best practices

Your approach: **Think step-by-step through each user scenario. Consider the emotional journey, not just the functional flow. Cite UX research where applicable. Prioritize user trust and long-term retention over short-term permission grants.**

---

## PART 3: EXISTING CODE — Current Permission UX (REAL CODE)

### 3.1 Current Approach: All Permissions At Once (ANTI-PATTERN)

This is our current onboarding permissions screen. **It requests ALL permissions at once — we want to fix this.**

```dart
// lib/features/onboarding/screens/permissions_screen.dart (CURRENT - PROBLEMATIC)

class _PermissionsScreenState extends State<PermissionsScreen> {
  Future<void> _requestPermissions() async {
    // ❌ PROBLEM: Requests ALL permissions at once
    await Permission.notification.request();
    await Permission.microphone.request();
    await Permission.activityRecognition.request();
    await Permission.sensors.request();
    await Permission.calendarFullAccess.request();
    // Location permissions are in manifest but NOT requested in onboarding yet

    context.push(AppRoutes.onboardingLoading);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ...
      child: Column(
        children: [
          // ❌ PROBLEM: Heading is surveillance-focused
          const Text(
            'I need to see\neverything.',  // <-- Creepy!
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),

          // ❌ PROBLEM: Subtitles use technical jargon
          _buildPermissionItem(
            title: 'Health & Activity',
            subtitle: 'biometric_resilience_score',  // <-- User doesn't understand
          ),
          _buildPermissionItem(
            title: 'Calendar',
            subtitle: 'temporal_context_awareness',  // <-- Technical jargon
          ),

          // ❌ PROBLEM: "Not now" goes to failure screen
          TextButton(
            onPressed: () => context.go(AppRoutes.misalignment),  // <-- Dark pattern!
            child: Text('Not now'),
          ),
        ],
      ),
    );
  }
}
```

**Problems with current approach:**
1. Requests ALL permissions upfront (40% abandonment rate)
2. "I need to see everything" — surveillance framing
3. Subtitles use internal technical terms, not user benefits
4. "Not now" sends user to failure screen — dark pattern
5. No pre-permission context shown

### 3.2 Better Pattern: PermissionGlassPane (EXISTING - EXTEND THIS)

We have a better component that shows context BEFORE the OS dialog:

```dart
// lib/features/onboarding/components/permission_glass_pane.dart (GOOD PATTERN)

/// Pre-Permission Glass Pane
///
/// A contextual wrapper that explains WHY a permission is needed BEFORE
/// triggering the OS permission dialog. This dramatically increases
/// permission grant rates by:
///
/// 1. Providing context (users understand the value)
/// 2. Reducing surprise (users expect the dialog)
/// 3. Creating commitment (users have already mentally agreed)

class PermissionGlassPane extends StatelessWidget {
  final Permission permission;
  final String title;
  final String description;
  final String benefit;  // ✅ Shows user benefit
  final IconData icon;
  final VoidCallback onGranted;
  final VoidCallback onDenied;
  final VoidCallback? onSkip;  // ✅ Skip option for graceful degradation

  // ... handles permanently denied with settings deep link ...

  @override
  Widget build(BuildContext context) {
    return Container(
      // Bottom sheet with:
      // - Icon with gradient background
      // - Title (e.g., "Find Your Witness")
      // - Description (explains why needed)
      // - Benefit highlight box (e.g., "3x more likely to achieve goals")
      // - "Allow Access" primary button
      // - "Skip for now" secondary button
    );
  }
}

/// Pre-built permission configurations (EXISTING - NEEDS EXTENSION)
class PermissionConfigs {
  static const contacts = (
    title: 'Find Your Witness',
    description: 'Search your contacts to find someone who will hold you accountable.',
    benefit: 'People with a witness are 3x more likely to achieve their goals.',
    icon: Icons.contacts,
  );

  static const notifications = (
    title: 'Stay on Track',
    description: 'Receive gentle reminders to complete your habits.',
    benefit: 'Users with notifications enabled complete 40% more habits.',
    icon: Icons.notifications_active,
  );

  // ⚠️ MISSING: location, activityRecognition, calendar configs
  // ⚠️ MISSING: Privacy reassurance section
}
```

**What's good:**
- Shows context before OS dialog
- Has benefit highlight
- Has skip option
- Handles permanently denied state

**What's missing (YOUR DELIVERABLE):**
- Location permission config with privacy messaging
- Activity recognition permission config
- Calendar permission config with privacy messaging
- Privacy reassurance section ("We see zones, not coordinates")
- Progressive timing strategy

---

## PART 4: TECHNICAL CONTEXT (From Companion Prompt RQ-010egh)

### 4.1 Permission Requirements (Technical Reality)

| Permission | Technical Requirement | Fallback Available? |
|------------|----------------------|---------------------|
| `ACTIVITY_RECOGNITION` | Required for activity state (still, walking, running) | Yes — time-based inference only |
| `ACCESS_FINE_LOCATION` | Required for geofencing | Yes — manual "I'm here" button |
| `ACCESS_BACKGROUND_LOCATION` | Required for always-on geofencing | Yes — retro-active "Did you go?" card |
| `READ_CALENDAR` | Required for schedule context | Yes — manual busy/free toggle |
| `POST_NOTIFICATIONS` (Android 13+) | Required for nudges | No — app becomes passive |

### 4.2 WiFi Fallback Reality (CRITICAL UX IMPLICATION)

**Technical finding:** On Android 10+, reading WiFi SSID requires `ACCESS_FINE_LOCATION`.

**UX Implication:** We CANNOT claim "WiFi-based detection" as a privacy alternative to GPS. If we mention WiFi, users may think we're tracking less than we actually are. **Messaging must be honest.**

### 4.3 Zero-Permission Signals (What Works Without Asking)

| Signal | How It Works | No Permission Needed |
|--------|--------------|---------------------|
| Time of day | System clock | ✅ |
| Day of week | System calendar | ✅ |
| Charging state | `BatteryManager.EXTRA_PLUGGED` | ✅ |
| Screen on/off | System event | ✅ |
| App engagement | User opened app | ✅ |

### 4.4 Zone-Based Mental Model (Privacy Messaging)

**Technical decision:** We store **zone membership** (home, work, gym), NOT GPS coordinates.

**UX Messaging:** Users should understand: "We see ZONES, not coordinates. We know you arrived at 'Gym' — we don't know the address."

---

## PART 5: ANDROID VERSION DIFFERENCES (Critical for UX)

| Android Version | Permission UX Difference |
|-----------------|--------------------------|
| **Android 6-9** | "Allow" / "Deny" only |
| **Android 10** | "Allow" / "Allow only while using" / "Deny" for location |
| **Android 11** | "Only this time" option added |
| **Android 12** | "Approximate" vs "Precise" location choice |
| **Android 13+** | `POST_NOTIFICATIONS` requires explicit permission |
| **Android 14+** | "Limited photos" option |

**UX Implication:** Our permission screens must adapt to what the user will see in the OS dialog.

---

## PART 6: CRITICAL INSTRUCTION — PROCESSING ORDER

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

---

## PART 7: RESEARCH QUESTIONS

### RQ-010d: Progressive Permission Strategy

**Core Question:** When should we request each permission, and in what order?

**Why This Matters:**
- Asking all permissions upfront causes 40% abandonment
- Context matters — asking for gym location AFTER user creates gym habit = higher grant rate
- Android 13+ requires POST_NOTIFICATIONS at runtime (can't assume granted)

**Current State vs Desired State:**

| Current State | Desired State |
|---------------|---------------|
| All permissions requested during onboarding | Permissions requested at point of relevance |
| "I need to see everything" messaging | Value-first messaging |
| Denial = failure screen | Denial = degraded but functional experience |

**Sub-Questions (Answer Each Explicitly):**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Zero-Permission Onboarding:** What value can we deliver in first 5 minutes with NO permissions? | Design the first session with zero permissions |
| 2 | **First Permission:** Which permission should be FIRST, and what triggers it? | Recommend with psychology justification |
| 3 | **Location Sequence:** Fine Location → Background Location: together or separate? How much time between? | Cite Android best practices |
| 4 | **Trust Signals:** What user behaviors indicate readiness for more permissions? | List behavioral triggers |
| 5 | **Re-Request Strategy:** If user denies, when should we ask again? | Propose cooldown periods |
| 6 | **Android 13+ Notifications:** When do we request POST_NOTIFICATIONS? | Recommend timing for Android 13+ |

**Anti-Patterns to Avoid:**
- ❌ Requesting all permissions at install
- ❌ Requesting permissions before demonstrating value
- ❌ Requesting background location immediately (Play Store scrutiny)
- ❌ Re-requesting denied permissions immediately
- ❌ Dark patterns (denial = failure screen)

**Output Required for RQ-010d:**
1. Permission request timeline (by user journey stage)
2. Trigger conditions for each permission
3. Re-request strategy with cooldown periods
4. Trust signal framework
5. Confidence Assessment: HIGH/MEDIUM/LOW

---

### RQ-010f: Privacy-Value Transparency

**Core Question:** How do we message each permission request to maximize trust AND grant rate?

**Why This Matters:**
- Generic OS dialogs have ~50% grant rate
- Pre-permission context increases grant rate to ~70%
- Privacy reassurance is critical for location permissions

**Zone-Based Mental Model:**

We want users to think: "The app knows I'm at THE GYM, not WHERE the gym is."

**Messaging principle:** "We see zones, not coordinates."

**Sub-Questions (Answer Each Explicitly):**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Pre-Permission Screens:** Design the Glass Pane config for: Location, Activity, Calendar | Provide title, description, benefit, privacy note |
| 2 | **Value-First Copy:** How do we frame each permission as USER benefit? | Write copy variants (A/B testable) |
| 3 | **Zone Messaging:** How do we explain "zones not coordinates" simply? | Propose 2-3 messaging variants |
| 4 | **Denial Response:** What appears IMMEDIATELY after denial? | Design denial flow |
| 5 | **Privacy Dashboard:** Should users see what data we've collected? | Design concept |
| 6 | **Android 12+ Location Choice:** When user chooses "Approximate" over "Precise", what do we show? | Design response UX |

**Anti-Patterns to Avoid:**
- ❌ Fear-based messaging ("App won't work without this")
- ❌ Vague explanations ("To improve your experience")
- ❌ Technical jargon ("ACCESS_FINE_LOCATION")
- ❌ Lying about data collection
- ❌ Hiding privacy implications

**Output Required for RQ-010f:**
1. PermissionConfigs for location, activity, calendar (matching existing code pattern)
2. Copy variants for A/B testing
3. Zone mental model explanation copy
4. Denial response flow
5. Privacy dashboard wireframe
6. Confidence Assessment: HIGH/MEDIUM/LOW

---

### RQ-010c: Degradation Scenarios

**Core Question:** What UX do we provide when users deny some or all permissions?

**Degradation Matrix:**

| Permissions Granted | Capability | Mode Name |
|--------------------|------------|-----------|
| ALL | Full context intelligence | **Full Mode** |
| Location + Activity + Notifications | Zone + movement | **Location Mode** (80%) |
| Activity + Notifications | Movement + time | **Activity Mode** (60%) |
| Notifications only | Time-based nudges | **Basic Mode** (40%) |
| NONE | Manual-only | **Manual Mode** (20%) |

**Sub-Questions (Answer Each Explicitly):**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Manual Mode (0%):** What does the app look like with ZERO permissions? | Design the experience |
| 2 | **Basic Mode (40%):** How do we make time-based nudges feel intelligent? | Design smart scheduling UX |
| 3 | **Feature Visibility:** Should location features be HIDDEN or shown with "Enable" prompt? | Recommend with justification |
| 4 | **Upgrade Prompts:** How do we show what users are missing without nagging? | Design non-intrusive prompts |
| 5 | **Manual Fallbacks:** For each denied permission, what replaces it? | Map fallbacks |
| 6 | **Mode Switching:** If user grants permission later, how do we celebrate? | Design upgrade celebration |

**Manual Fallback Mapping:**

| Denied Permission | Manual Fallback UI |
|-------------------|-------------------|
| Location | "I'm here" zone chips: [Home] [Work] [Gym] [Other] |
| Activity | "What are you doing?" [Resting] [Moving] [Exercising] |
| Calendar | "Are you free?" yes/no toggle |
| Notifications | In-app reminders only |

**Output Required for RQ-010c:**
1. UX flow for each mode (Manual, Basic, Activity, Location, Full)
2. Manual fallback UI designs
3. Upgrade prompt design (non-intrusive)
4. Feature visibility strategy
5. Mode upgrade celebration
6. Confidence Assessment: HIGH/MEDIUM/LOW

---

## PART 8: USER SCENARIOS (SOLVE STEP-BY-STEP)

### Scenario A: Privacy-Conscious User (Denies Everything)

> Alex is privacy-conscious. Denies ALL permissions.
>
> 1. What does Alex see on home screen?
> 2. How does Alex log a habit completion?
> 3. What nudges (if any) does Alex receive?
> 4. After 2 weeks of success, how do we invite Alex to grant permissions?

### Scenario B: Gradual Trust Builder

> Sarah grants notifications at onboarding. Denies location. After 1 week, she creates a "Gym 4x/week" habit.
>
> 1. When should we ask Sarah for location?
> 2. What message do we show?
> 3. If denied again, what's her gym habit UX?
> 4. After 2 successful manual gym logs, should we ask again?

### Scenario C: Permission Regret

> Marcus granted all permissions initially. After 3 weeks, revokes location in Android settings.
>
> 1. How does app detect revocation?
> 2. What does Marcus see next time he opens app?
> 3. How do we gracefully degrade his experience?

### Scenario D: Android 12 "Approximate Location" Choice

> Lisa is on Android 12. When location dialog appears, she chooses "Approximate" instead of "Precise."
>
> 1. Can we still do geofencing? (Technical: No, geofencing requires precise)
> 2. What do we tell Lisa?
> 3. Should we ask her to upgrade to precise later?

---

## PART 9: EXAMPLE OF GOOD OUTPUT (Quality Bar)

### Example: PermissionConfig for Location

```dart
/// Configuration for location permission - to be added to PermissionConfigs
static const location = (
  permission: Permission.location,
  title: 'Cheer You On When You Arrive',
  description: 'When you get to the gym, we\'ll send a quick boost to help you '
      'crush your workout. We only check zones (gym, home, work) — '
      'never your exact path.',
  benefit: 'Users with location enabled are 2x more likely to show up.',
  privacyNote: '🔒 We see "Gym" — not the address. Your location history '
      'stays on your phone.',
  icon: Icons.location_on,
);

static const backgroundLocation = (
  permission: Permission.locationAlways,
  title: 'Know When You Arrive (Even When Closed)',
  description: 'Get encouragement the moment you arrive — no need to open the app. '
      'We check zones only, not your journey.',
  benefit: 'Background location means never missing a gym arrival boost.',
  privacyNote: '🔒 We see zone transitions, not a breadcrumb trail.',
  icon: Icons.my_location,
);

static const activityRecognition = (
  permission: Permission.activityRecognition,
  title: 'Detect When You\'re Moving',
  description: 'We can tell when you start running or walking — perfect for '
      'fitness habits. We see "running" vs "still", not your route.',
  benefit: 'Activity detection means smarter, better-timed nudges.',
  privacyNote: '🔒 We see movement type, not location or path.',
  icon: Icons.directions_run,
);

static const calendar = (
  permission: Permission.calendarFullAccess,
  title: 'Respect Your Schedule',
  description: 'We\'ll check for free time before nudging you. '
      'We see "busy" or "free" — never meeting details.',
  benefit: 'Calendar-aware nudges hit at the right moment.',
  privacyNote: '🔒 We see time blocks, not meeting names or attendees.',
  icon: Icons.calendar_today,
);
```

### Example: Manual Mode Home Screen

```
┌─────────────────────────────────────────┐
│  THE PACT                    [Settings] │
├─────────────────────────────────────────┤
│                                         │
│  Good morning, Alex                     │
│                                         │
│  📍 Where are you right now?           │
│  ┌───────┐ ┌───────┐ ┌───────┐        │
│  │ Home  │ │ Work  │ │ Gym   │        │
│  └───────┘ └───────┘ └───────┘        │
│  ┌─────────────────┐                   │
│  │ Somewhere else  │                   │
│  └─────────────────┘                   │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  TODAY'S PACTS                          │
│                                         │
│  ☐ Run 30 minutes                       │
│  ☐ Read 20 pages                        │
│  ☐ Meditate 10 minutes                  │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  💡 Want smarter reminders?             │
│  Enable location to get encouraged      │
│  when you arrive at the gym.            │
│  [Maybe Later]  [Enable]                │
│                                         │
└─────────────────────────────────────────┘
```

---

## PART 10: ARCHITECTURAL CONSTRAINTS

| Constraint | Rule |
|------------|------|
| **No Dark Patterns** | Denial = degraded experience, NOT failure screen |
| **Privacy-First** | Store zone labels, not coordinates |
| **Graceful Degradation** | App MUST work with zero permissions |
| **Honest Messaging** | Never claim less data collection than reality |
| **Android Version Aware** | UX must adapt to Android 10-14 differences |

---

## PART 11: OUTPUT QUALITY CRITERIA

| Criterion | Question |
|-----------|----------|
| **User-Centered** | Does this prioritize user trust over permission grants? |
| **Honest** | Is messaging truthful about what we collect? |
| **Graceful** | Does denied permission = degraded, not broken? |
| **Non-Intrusive** | Will users feel respected, not nagged? |
| **Implementable** | Can a Flutter developer build this directly? |
| **Testable** | Are there clear A/B variants? |
| **Confidence-Rated** | Is each recommendation HIGH/MEDIUM/LOW? |

---

## PART 12: FINAL CHECKLIST

- [ ] RQ-010d: Permission timeline covers all permissions
- [ ] RQ-010d: Re-request cooldowns specified
- [ ] RQ-010f: PermissionConfigs for location, activity, calendar provided
- [ ] RQ-010f: Zone messaging copy variants provided
- [ ] RQ-010f: Denial response flow designed
- [ ] RQ-010c: All degradation modes (20-100%) designed
- [ ] RQ-010c: Manual fallback UIs designed
- [ ] User scenarios A-D solved step-by-step
- [ ] No dark patterns in any recommendation
- [ ] Privacy promises are truthful
- [ ] Confidence levels stated

---

*End of Prompt — DRAFT 2*
