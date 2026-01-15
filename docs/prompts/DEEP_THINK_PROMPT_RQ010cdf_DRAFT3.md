# Deep Think Prompt: Permission UX & Privacy Experience (RQ-010cdf) — DRAFT 3

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
| **Rationale Dialog** | Android's `shouldShowRequestPermissionRationale()` — shown after first denial |

### Tech Stack

- **Frontend:** Flutter 3.38.4 (Android-first, iOS deferred)
- **Backend:** Supabase (PostgreSQL + pgvector)
- **AI:** DeepSeek V3.2 for reasoning
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

Your approach: **Think step-by-step through each user scenario. Consider the emotional journey, not just the functional flow. Cite UX research where applicable (e.g., Felt et al. 2012 on Android permissions, studies on permission fatigue). Prioritize user trust and long-term retention over short-term permission grants.**

---

## PART 3: EXISTING CODE — Current Permission UX (REAL CODE)

### 3.1 Current Approach: All Permissions At Once (ANTI-PATTERN)

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
      child: Column(
        children: [
          // ❌ PROBLEM: Surveillance-focused heading
          const Text('I need to see\neverything.'),

          // ❌ PROBLEM: Technical jargon in subtitles
          _buildPermissionItem(
            title: 'Health & Activity',
            subtitle: 'biometric_resilience_score',  // User doesn't understand
          ),

          // ❌ PROBLEM: "Not now" goes to failure screen (DARK PATTERN)
          TextButton(
            onPressed: () => context.go(AppRoutes.misalignment),
            child: Text('Not now'),
          ),
        ],
      ),
    );
  }
}
```

**Problems:**
1. Requests ALL permissions upfront (~40% abandonment)
2. "I need to see everything" — surveillance framing
3. Technical jargon, not user benefits
4. "Not now" = failure screen — dark pattern
5. No pre-permission context

### 3.2 Better Pattern: PermissionGlassPane (EXISTING - EXTEND)

```dart
// lib/features/onboarding/components/permission_glass_pane.dart (GOOD PATTERN)

/// Pre-Permission Glass Pane — shows context BEFORE OS dialog
class PermissionGlassPane extends StatelessWidget {
  final Permission permission;
  final String title;
  final String description;
  final String benefit;  // ✅ Shows user benefit
  final IconData icon;
  final VoidCallback onGranted;
  final VoidCallback onDenied;
  final VoidCallback? onSkip;  // ✅ Skip option for graceful degradation

  // Handles permanently denied with settings deep link
}

/// Pre-built configs (EXISTING - NEEDS EXTENSION)
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

  // ⚠️ MISSING: location, backgroundLocation, activityRecognition, calendar
  // ⚠️ MISSING: privacyNote field for privacy reassurance
}
```

**Your deliverable:** Extend `PermissionConfigs` with location, activity, calendar — including privacy notes.

---

## PART 4: TECHNICAL CONTEXT (From RQ-010egh)

### 4.1 Permission Requirements

| Permission | Required For | Fallback |
|------------|--------------|----------|
| `ACTIVITY_RECOGNITION` | Activity state (still, walking, running) | Time-based inference |
| `ACCESS_FINE_LOCATION` | Geofencing | Manual "I'm here" button |
| `ACCESS_BACKGROUND_LOCATION` | Always-on geofencing | Retro-active "Did you go?" card |
| `READ_CALENDAR` | Schedule context | Manual busy/free toggle |
| `POST_NOTIFICATIONS` | Nudges | In-app only |

### 4.2 Critical UX Implications from Technical Research

| Finding | UX Implication |
|---------|----------------|
| WiFi SSID requires location on Android 10+ | Cannot claim WiFi as privacy alternative |
| Geofencing requires FINE location | "Approximate" location choice = no geofencing |
| Zone storage (not coordinates) | Can message: "We see zones, not coordinates" |
| Background location requires separate request | Must ask after foreground is granted |

### 4.3 Zero-Permission Signals

| Signal | Permission Needed |
|--------|-------------------|
| Time / Day of week | None |
| Charging state | None |
| Screen on/off | None |
| App open events | None |

---

## PART 5: ANDROID VERSION UX DIFFERENCES

| Version | Permission UX Change |
|---------|---------------------|
| **Android 10** | "Allow only while using" option for location |
| **Android 11** | "Only this time" option added |
| **Android 12** | "Approximate" vs "Precise" location choice |
| **Android 13+** | `POST_NOTIFICATIONS` requires explicit request |
| **Android 14+** | Partial photo access option |

### 5.1 shouldShowRequestPermissionRationale()

After a user denies a permission ONCE, Android provides `shouldShowRequestPermissionRationale()` which returns `true`. This is the signal to show additional context BEFORE re-requesting.

**UX Implication:** If user denied once, show enhanced rationale screen before second request.

---

## PART 6: COMPETITOR ANALYSIS (Context)

How similar apps handle permissions:

| App | Strategy | Result |
|-----|----------|--------|
| **Strava** | Asks for location at first run create | ~70% grant |
| **Nike Run Club** | Progressive — asks location when starting a run | ~75% grant |
| **Headspace** | Notifications after first session completed | ~80% grant |
| **Noom** | All permissions upfront in onboarding | ~50% grant |

**Lesson:** Progressive, contextual requests (Nike, Headspace) outperform upfront bundles (Noom).

---

## PART 7: RESEARCH QUESTIONS

### RQ-010d: Progressive Permission Strategy

**Core Question:** When should we request each permission, and in what order?

**Sub-Questions:**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Zero-Permission First 5 Minutes:** What value can we deliver with NO permissions? | Design zero-permission onboarding |
| 2 | **First Permission:** Which permission should be FIRST, and what triggers it? | Recommend with psychology justification. Cite research if available. |
| 3 | **Location Sequence:** How do we sequence Fine → Background location requests? | Cite Android guidelines. Propose timing gap. |
| 4 | **Trust Signals:** What user behaviors indicate permission readiness? | List triggers (days active, habits created, etc.) |
| 5 | **Re-Request Strategy:** After denial, when do we ask again? | Propose cooldowns. Consider `shouldShowRequestPermissionRationale()`. |
| 6 | **Android 13+ Notifications:** When do we request POST_NOTIFICATIONS? | Recommend timing |
| 7 | **Rationale Screen Trigger:** When should we show enhanced rationale (after first denial)? | Design rationale flow |

**Anti-Patterns:**
- ❌ All permissions upfront
- ❌ Requesting before value demonstrated
- ❌ Background location without established trust
- ❌ Re-requesting immediately after denial
- ❌ Dark patterns (denial = failure)

**Output Required:**
1. Permission timeline by user journey stage
2. Trigger conditions per permission
3. Re-request cooldown strategy
4. Trust signal framework
5. Rationale screen design (for post-first-denial)
6. Confidence: HIGH/MEDIUM/LOW

---

### RQ-010f: Privacy-Value Transparency

**Core Question:** How do we message each permission to maximize trust AND grant rate?

**Zone-Based Mental Model:**
> "We see ZONES, not coordinates. We know you arrived at 'Gym' — not where the gym is."

**Sub-Questions:**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **PermissionConfigs:** Design configs for location, backgroundLocation, activityRecognition, calendar | Match existing code pattern. Include `privacyNote` field. |
| 2 | **Value-First Copy:** Frame each permission as USER benefit | Write 2-3 variants per permission for A/B testing |
| 3 | **Zone Messaging:** Explain "zones not coordinates" simply | Propose messaging variants |
| 4 | **Denial Response:** What appears immediately after denial? | Design non-punitive denial UX |
| 5 | **Android 12 "Approximate" Response:** User chose approximate location — what do we show? | Design response (geofencing won't work) |
| 6 | **Privacy Dashboard:** Should users see collected data? | Design concept |
| 7 | **Data Retention Messaging:** How long do we keep zone history? What do we tell users? | Propose retention policy + messaging |
| 8 | **Play Store Background Location Justification:** How do we explain background location to Play Store reviewers? | Draft compliance messaging |

**Anti-Patterns:**
- ❌ Fear-based messaging
- ❌ Vague explanations
- ❌ Technical jargon
- ❌ Lying about data collection
- ❌ Hiding privacy implications

**Output Required:**
1. PermissionConfigs (location, backgroundLocation, activityRecognition, calendar)
2. Copy variants for A/B testing (2-3 per permission)
3. Zone mental model explanation copy
4. Denial response flow
5. "Approximate location" response UX
6. Privacy dashboard wireframe
7. Data retention messaging
8. Play Store background location justification
9. Confidence: HIGH/MEDIUM/LOW

---

### RQ-010c: Degradation Scenarios

**Core Question:** What UX do we provide at each permission level?

**Degradation Matrix:**

| Mode | Permissions | Capability |
|------|-------------|------------|
| **Full Mode** (100%) | All | Full context intelligence |
| **Location Mode** (80%) | Location + Activity + Notifications | Zone + movement |
| **Activity Mode** (60%) | Activity + Notifications | Movement + time |
| **Basic Mode** (40%) | Notifications only | Time-based nudges |
| **Manual Mode** (20%) | None | Manual input only |

**Sub-Questions:**

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Manual Mode (0%):** App with ZERO permissions | Design full experience |
| 2 | **Basic Mode (40%):** Time-based nudges feel smart | Design scheduling UX |
| 3 | **Feature Visibility:** Hide disabled features or show with "Enable" prompt? | Recommend with justification |
| 4 | **Upgrade Prompts:** Show what users are missing without nagging | Design non-intrusive prompts. Propose frequency limits. |
| 5 | **Manual Fallbacks:** UI that replaces each denied permission | Design fallback UIs |
| 6 | **Upgrade Celebration:** User grants previously denied permission — how do we celebrate? | Design celebration moment |
| 7 | **Mode Indicator:** Should users see what "mode" they're in? | Recommend with justification |

**Manual Fallback Mapping:**

| Denied Permission | Manual Fallback |
|-------------------|-----------------|
| Location | "I'm here" zone chips: [Home] [Work] [Gym] [Other] |
| Activity | "What are you doing?" [Resting] [Moving] [Exercising] |
| Calendar | "Are you free?" toggle |
| Notifications | In-app reminders only |

**Output Required:**
1. UX flow for each mode (Manual → Full)
2. Manual fallback UI designs
3. Upgrade prompt design (with frequency limits)
4. Feature visibility strategy
5. Upgrade celebration design
6. Mode indicator recommendation
7. Confidence: HIGH/MEDIUM/LOW

---

## PART 8: USER SCENARIOS

### Scenario A: Privacy-Conscious User (Denies Everything)

> Alex denies ALL permissions.
>
> 1. What does Alex see on home screen?
> 2. How does Alex log habit completion?
> 3. What nudges (if any) does Alex receive?
> 4. After 2 weeks of success, how do we invite permissions?

### Scenario B: Gradual Trust Builder

> Sarah grants notifications. Denies location. Creates "Gym 4x/week" habit.
>
> 1. When do we ask for location?
> 2. What message?
> 3. If denied again, gym habit UX?
> 4. After 2 successful manual gym logs, ask again?

### Scenario C: Permission Regret

> Marcus grants all permissions. After 3 weeks, revokes location in Android settings.
>
> 1. How does app detect revocation?
> 2. What does Marcus see?
> 3. How do we degrade gracefully?

### Scenario D: Android 12 "Approximate Location"

> Lisa (Android 12) chooses "Approximate" instead of "Precise."
>
> 1. Can we geofence? (No — requires precise)
> 2. What do we tell Lisa?
> 3. Should we ask her to upgrade later?

### Scenario E: Second Request After Denial

> Tom denied location permission once. Android shows `shouldShowRequestPermissionRationale() = true`.
>
> 1. When do we show enhanced rationale?
> 2. What does enhanced rationale screen look like?
> 3. If Tom denies again (now permanently denied), what UX?

---

## PART 9: EXAMPLES OF GOOD OUTPUT

### Example: PermissionConfigs for Location

```dart
static const location = (
  permission: Permission.location,
  title: 'Cheer You On When You Arrive',
  description: 'When you get to the gym, we\'ll send a quick boost to help you '
      'crush your workout.',
  benefit: 'Users with location enabled are 2x more likely to show up.',
  privacyNote: '🔒 We see "Gym" — not the address. Your location history '
      'stays on your phone.',
  icon: Icons.location_on,
);

static const backgroundLocation = (
  permission: Permission.locationAlways,
  title: 'Know When You Arrive (Even When Closed)',
  description: 'Get encouragement the moment you arrive — no need to open the app.',
  benefit: 'Never miss a gym arrival boost.',
  privacyNote: '🔒 We see zone transitions, not a breadcrumb trail.',
  playStoreJustification: 'Background location enables arrival-triggered motivational '
      'messages for fitness habits. Core app functionality requires knowing when '
      'user arrives at self-defined habit locations (gym, home office) to deliver '
      'timely encouragement.',
  icon: Icons.my_location,
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
│  │ Home  │ │ Work  │ │  Gym  │        │
│  └───────┘ └───────┘ └───────┘        │
│  ┌─────────────────┐                   │
│  │ Somewhere else  │                   │
│  └─────────────────┘                   │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  TODAY'S PACTS                          │
│  ☐ Run 30 minutes                       │
│  ☐ Read 20 pages                        │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  💡 Want smarter reminders?             │
│  Enable location to get cheered on      │
│  when you arrive at the gym.            │
│                                         │
│  [Maybe Later]       [Enable]           │
│                                         │
└─────────────────────────────────────────┘
```

### Example: Upgrade Celebration

```
┌─────────────────────────────────────────┐
│                                         │
│            🎉                           │
│                                         │
│    Location Enabled!                    │
│                                         │
│    Now I can cheer you on the moment   │
│    you arrive at the gym.               │
│                                         │
│    Your first arrival boost is ready.   │
│                                         │
│           [ Got it! ]                   │
│                                         │
└─────────────────────────────────────────┘
```

---

## PART 10: CONSTRAINTS

| Constraint | Rule |
|------------|------|
| **No Dark Patterns** | Denial = degraded, NOT failure |
| **Privacy-First** | Store zones, not coordinates |
| **Graceful Degradation** | App MUST work with zero permissions |
| **Honest Messaging** | Never claim less collection than reality |
| **Android Version Aware** | UX adapts to Android 10-14+ |
| **Play Store Compliant** | Background location justification required |

---

## PART 11: OUTPUT QUALITY CRITERIA

| Criterion | Question |
|-----------|----------|
| **User-Centered** | Prioritizes trust over grants? |
| **Honest** | Truthful about data collection? |
| **Graceful** | Denied = degraded, not broken? |
| **Non-Intrusive** | Users feel respected? |
| **Implementable** | Flutter dev can build directly? |
| **Testable** | Clear A/B variants? |
| **Play Store Ready** | Background location justification included? |
| **Research-Backed** | Cites relevant studies where applicable? |
| **Confidence-Rated** | Each recommendation rated? |

---

## PART 12: FINAL CHECKLIST

- [ ] RQ-010d: Permission timeline covers all permissions
- [ ] RQ-010d: Re-request cooldowns with rationale screen design
- [ ] RQ-010d: Trust signal framework
- [ ] RQ-010f: PermissionConfigs for all 4 permissions (with privacyNote)
- [ ] RQ-010f: Zone messaging copy variants
- [ ] RQ-010f: Denial response flow
- [ ] RQ-010f: "Approximate location" response
- [ ] RQ-010f: Data retention policy + messaging
- [ ] RQ-010f: Play Store background location justification
- [ ] RQ-010c: All degradation modes designed
- [ ] RQ-010c: Manual fallback UIs
- [ ] RQ-010c: Upgrade celebration design
- [ ] Scenarios A-E solved step-by-step
- [ ] No dark patterns
- [ ] Privacy promises truthful
- [ ] Research citations where applicable
- [ ] Confidence levels stated

---

*End of Prompt — DRAFT 3*
