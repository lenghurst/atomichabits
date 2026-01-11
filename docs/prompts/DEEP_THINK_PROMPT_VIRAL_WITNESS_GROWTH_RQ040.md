# Deep Think Prompt: Viral Witness Invitation Growth Strategy

> **Target Research:** RQ-040, RQ-040a through RQ-040g
> **Prepared:** 11 January 2026
> **For:** Google Gemini Deep Think / DeepSeek R1 Distilled
> **App Name:** The Pact
> **Priority:** **STRATEGIC** — Foundational growth architecture decision
> **Requires:** Multi-domain expertise (Growth, Product, Behavioral Economics, Social Psychology)

---

## Your Role

You are a **Senior Growth Architect & Viral Loop Designer** with deep expertise in:
- Product-led growth (PLG) mechanics for consumer apps
- Viral coefficient optimization (K-factor engineering)
- Social psychology of referral and invitation systems
- Two-sided marketplace dynamics (creator vs witness value)
- Behavioral economics of accountability and social commitment
- Mobile app growth analytics and cohort modeling
- Ethical growth design (avoiding dark patterns in social mechanics)

**Your approach:** Think through this as a systems design problem. The goal is not just "get more users" but "build a self-reinforcing growth engine where each user creates value that attracts more users." Analyze the flywheel dynamics. Present multiple models with explicit tradeoffs. Include quantitative projections where possible. Consider second-order effects (what happens at scale?).

---

## Critical Instruction: Processing Order

This research has dependencies. Process in this exact sequence:

```
RQ-040a (Witness Value Proposition) — FIRST
    ↓ Defines what witnesses want/get
RQ-040b (Invitation Channels) — SECOND
    ↓ How invitation reaches witness
RQ-040c (Conversion Triggers) — THIRD
    ↓ What makes witness become creator
RQ-040d (Multi-Witness Effects) — FOURTH
    ↓ Network effects amplification
RQ-040e (Viral Coefficient Model) — FIFTH
    ↓ Quantitative targets and projections
RQ-040f (Witness Retention) — SIXTH
    ↓ Engagement without conversion
RQ-040g (High-Value Validation) — SEVENTH
    ↓ Proves the hypothesis
```

**Output each sub-RQ sequentially, referencing earlier outputs.**

---

## Strategic Context: Why This Research Matters

### The Pact's Original Vision

"THE PACT" was named for a witness-based accountability system. The core mechanic:

1. **User A** creates a "pact" (identity-based commitment to habits)
2. **User A** invites 1+ "witnesses" to hold them accountable
3. **Witnesses** receive updates on User A's progress
4. **Witnesses** experience the app's value through User A's journey
5. **Witnesses** convert to creators (make their own pacts, invite their own witnesses)
6. **Compound growth** — each generation invites the next

### The Strategic Hypothesis

> Witness invitation creates a **self-generating pipeline of high-value users** that leads to **exponential growth** if the mechanics are designed correctly.

**Why "high-value":**
- Pre-qualified through social relationship
- Understand value prop from witnessing
- Come with built-in social accountability partner
- Higher trust (friend's endorsement)
- More likely to engage deeply (social commitment)

### Current State

| Metric | Current Value | Source |
|--------|---------------|--------|
| Witness invitation rate | ~42% of users add supporter | User Journey Map |
| Witness-to-creator conversion | ~22% | User Journey Map |
| Average witnesses per pact | 1.1 (estimated) | Not measured |
| Viral coefficient (K) | ~0.24 (i=1.1 × c=0.22) | Calculated |

**Problem:** K = 0.24 is far below viral threshold (K > 1). Growth is linear, not exponential.

### The Prize

If we can achieve K = 1.0:
- Each user generates 1 new user on average
- Growth becomes self-sustaining
- CAC approaches zero for organic users
- Network effects create defensibility

If we can achieve K = 1.5:
- Exponential growth unlocked
- 100 users → 150 → 225 → 338 → 506 (4 cycles)
- Market capture potential

---

## Mandatory Context: Locked Architecture

### CD-002: AI as Default Witness ✅ CONFIRMED
- If user chooses not to invite human witness, AI serves as witness
- **Implication:** Human witnesses are optional but incentivized
- **Constraint:** Cannot REQUIRE human witness (blocks solo users)

### CD-010: Retention Philosophy ✅ CONFIRMED
- No dark patterns
- User success > app engagement
- "Graduated" users are success, not churn
- **Constraint:** Cannot use manipulative invitation tactics (guilt, shame, FOMO)

### CD-015: psyOS Architecture ✅ CONFIRMED
- Parliament of Selves: Identity facets negotiating
- Witnesses observe the user's identity journey
- **Implication:** Witness sees user's growth story, not just habit completion

### CD-017: Android-First Development ✅ CONFIRMED
- All features must work on Android without iOS-specific APIs
- **Constraint:** No iMessage-style deep integration; use cross-platform channels

### CD-018: Engineering Threshold Framework ✅ CONFIRMED
- ESSENTIAL / VALUABLE / NICE-TO-HAVE / OVER-ENGINEERED
- **Constraint:** Complex referral/MLM mechanics = OVER-ENGINEERED

---

## Prior Research Summary

### User Journey Map (24 Dec 2025)
**Key Findings:**
- `supporter_added`: 42% of users add human supporter (witness)
- `witness_to_creator`: 22% of witnesses convert to creators
- Supporter terminology shifted from "witness" to reduce judgment fear
- "Pick a supporter who'll..." framing (from Brené Brown guidance)

### RQ-021: Treaty Lifecycle ✅ COMPLETE
**Key Findings:**
- Treaties are agreements between identity facets
- Witnesses could observe treaty negotiations (future feature)
- Social accountability increases treaty adherence (hypothesis)

### RQ-037: Holy Trinity Model ✅ COMPLETE
**Key Findings:**
- Shadow Cabinet (Shadow, Saboteur, Script) extraction
- Day 1 Sherlock creates compelling identity narrative
- **Implication:** Witness invitation should happen AFTER identity extraction (user has story to share)

---

## Current Schema: Witness-Related Tables

```sql
-- Current: profiles table (simplified)
CREATE TABLE profiles (
  id UUID PRIMARY KEY,
  display_name TEXT,
  -- No witness relationship tracking
);

-- Current: habits table (simplified)
CREATE TABLE habits (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES profiles(id),
  supporter_name TEXT,  -- Basic supporter info
  supporter_contact TEXT,  -- Phone/email for notifications
  -- No structured witness user linking
);

-- PROPOSED: witness_relationships table
CREATE TABLE witness_relationships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  creator_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  witness_id UUID REFERENCES profiles(id) ON DELETE SET NULL,  -- NULL = invited but not registered
  witness_contact TEXT,  -- Phone/email if not registered
  invitation_sent_at TIMESTAMPTZ,
  invitation_channel TEXT,  -- 'sms', 'whatsapp', 'email', 'link', 'in_app'
  invitation_opened_at TIMESTAMPTZ,
  witness_registered_at TIMESTAMPTZ,
  witness_converted_at TIMESTAMPTZ,  -- When witness created their own pact
  relationship_status TEXT CHECK (status IN ('invited', 'active', 'declined', 'dormant')),
  notification_preferences JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- PROPOSED: witness_events table (for analytics)
CREATE TABLE witness_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  witness_relationship_id UUID REFERENCES witness_relationships(id),
  event_type TEXT,  -- 'invitation_sent', 'invitation_opened', 'progress_viewed', 'encouragement_sent'
  event_data JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Research Question: RQ-040 — Viral Witness Invitation Growth Strategy

### Core Question

How should the witness invitation mechanic be designed to maximize viral coefficient (K > 1) while maintaining product quality, ethical standards, and user value on both sides of the creator-witness relationship?

### Why This Matters

| Scenario | Impact |
|----------|--------|
| **K remains at 0.24** | Linear growth; dependent on marketing spend; no network effects |
| **K reaches 0.5** | Significant organic amplification; 50% CAC reduction potential |
| **K reaches 1.0** | Self-sustaining growth; minimal CAC; defensible |
| **K exceeds 1.5** | Exponential growth; market capture potential |

### The Fundamental Challenge

```
CREATOR VALUE: Clear (accountability, support, social commitment)
WITNESS VALUE: Unclear (what do they get?)

If witness value is unclear or weak:
  → Low witness engagement
  → Low conversion to creator
  → Low K-factor
  → Linear growth only
```

---

## Sub-Question RQ-040a: Witness Value Proposition & Experience

### Core Question
What tangible value does a witness receive, and how do we design their experience to maximize engagement and eventual conversion?

### Why This Matters
The witness-to-creator conversion rate (currently 22%) is the key lever for K-factor. If witnesses don't see value, they won't engage, and they won't convert.

### Current Hypothesis

| Potential Witness Value | Strength | Evidence |
|-------------------------|----------|----------|
| **Voyeuristic interest** | WEAK | Watching friend's habit completions isn't compelling |
| **Altruistic support** | MEDIUM | Works for close relationships only |
| **Reciprocity expectation** | MEDIUM | "I'll watch yours if you watch mine" |
| **Inspiration/motivation** | STRONG | Seeing friend transform is compelling |
| **Relationship deepening** | STRONG | Shared accountability creates intimacy |
| **Own behavior reflection** | STRONG | "If they can do it, maybe I should too" |

### Sub-Questions (Answer Each)

| # | Question | Your Task |
|---|----------|-----------|
| **a1** | What do witnesses ACTUALLY want from this experience? | Research analogous systems (Strava follows, Beeminder referees, StickK referees). Identify top 3-5 witness motivations. |
| **a2** ⚖️ | Should witnesses have an "app experience" or just notifications? | Present options: (A) Notifications only, (B) Limited app access, (C) Full app access (preview). Analyze tradeoffs. |
| **a3** | What should witnesses SEE about the creator's journey? | Design the witness dashboard/notification stream. What data points create engagement without violating privacy? |
| **a4** | What ACTIONS can witnesses take? | Define witness interaction model. Options: (A) Passive (view only), (B) Reactive (send encouragement), (C) Active (set challenges). |
| **a5** ⚖️ | Should witnesses have their own "score" or progress? | Analyze whether gamifying the witness role increases engagement or feels manipulative. |
| **a6** | How do we avoid witness fatigue? | Design notification cadence and opt-out mechanisms that don't kill engagement. |
| **a7** | What's the "aha moment" for a witness? | Identify the specific experience that makes a witness think "I should do this too." |

### Anti-Patterns to Avoid
- ❌ Witness as pure "notification sink" (no value = no engagement)
- ❌ Witness as "accountability police" (shame-based = relationship damage)
- ❌ Witness with no agency (passive = disengagement)
- ❌ Witness information overload (every completion notification = fatigue)
- ❌ Witness without path to creator (engagement without conversion funnel)

### Output Required: Witness Experience Specification

```dart
/// Witness experience model
class WitnessExperience {
  // What witnesses see
  final List<WitnessDataPoint> visibleData;

  // What actions witnesses can take
  final List<WitnessAction> availableActions;

  // Notification strategy
  final NotificationCadence notificationStrategy;

  // Conversion triggers (what prompts "I should try this")
  final List<ConversionTrigger> conversionTriggers;
}

enum WitnessDataPoint {
  habitCompletions,     // Daily/weekly completions
  streakProgress,       // Current streak status
  identityJourney,      // Facet evolution
  milestonesAchieved,   // Major wins
  strugglesShared,      // Creator-approved vulnerability
  // ... define which are visible
}

enum WitnessAction {
  sendEncouragement,    // Emoji/message
  setMiniChallenge,     // "Try X this week"
  shareOwnGoal,         // "I'm working on Y"
  requestAccountability, // "Can you watch me too?"
  // ... define interaction model
}
```

**Include:** User journey map for witness from invitation → conversion (or non-conversion).

---

## Sub-Question RQ-040b: Invitation Channel Optimization

### Core Question
Through which channels should witness invitations be sent, and how do we maximize invitation open rates and registration?

### Why This Matters
If invitations aren't opened, the funnel dies at step 1. Channel choice dramatically affects open rates.

### Channel Analysis Framework

| Channel | Reach | Open Rate | Trust Level | Friction | Implementation |
|---------|-------|-----------|-------------|----------|----------------|
| **SMS** | Universal | 90%+ | High | Low | Android: Can send directly with permission |
| **WhatsApp** | 2B+ users | 70%+ | High | Medium | Deep link + share sheet |
| **Email** | Universal | 20-30% | Medium | Low | Standard API |
| **In-App Share** | App users only | N/A | High | Low | System share sheet |
| **Link Copy** | Universal | Unknown | Low | Medium | User manually shares |
| **QR Code** | In-person only | N/A | High | High | Generate + display |

### Sub-Questions (Answer Each)

| # | Question | Your Task |
|---|----------|-----------|
| **b1** | What's the optimal primary invitation channel by geography/demographic? | SMS dominant in US, WhatsApp in EU/LATAM/Asia. Provide channel priority matrix. |
| **b2** | What should the invitation message SAY? | Draft 3 invitation message variants optimized for open rate and trust. A/B test framework. |
| **b3** ⚖️ | Should invitation be sent immediately or delayed? | Timing options: (A) During onboarding, (B) After first pact creation, (C) After first streak. Analyze conversion impact. |
| **b4** | How do we handle contact picker friction? | Design flow for selecting contact. Options: Suggested contacts (ML) vs manual selection. |
| **b5** | What's the landing page experience for invited witness? | Design the first 30 seconds after clicking invitation link. Web vs app deep link. |
| **b6** | How do we track invitation attribution end-to-end? | Technical spec for tracking: invitation_sent → link_clicked → app_installed → registered → converted. |
| **b7** | What's the re-invitation strategy for unopened invites? | Cadence and channel for follow-up invitations without being spammy. |

### Anti-Patterns to Avoid
- ❌ Sending invitations without user consent (spam perception)
- ❌ Generic "Join The Pact" message (no personalization = low trust)
- ❌ Requiring app install before seeing value (friction wall)
- ❌ No tracking/attribution (can't optimize what we don't measure)
- ❌ Over-aggressive re-invitation (relationship damage)

### Output Required: Invitation Flow Specification

```dart
/// Invitation flow
class InvitationService {
  /// Select optimal channel for recipient
  InvitationChannel selectChannel({
    required ContactInfo recipient,
    required String region,
  }) {
    // Channel selection logic
  }

  /// Generate personalized invitation message
  String generateInvitation({
    required Profile creator,
    required ContactInfo witness,
    required Habit? primaryHabit,  // Optional: include habit context
  }) {
    // Message generation
  }

  /// Track invitation journey
  Future<void> trackInvitationEvent(InvitationEvent event) {
    // Analytics tracking
  }
}

/// Invitation message templates (A/B test)
const invitationTemplates = {
  'personal_accountability': '''
    Hey {witness_name}, I'm using The Pact to become {identity_goal}.
    I picked you as my supporter because {reason}.
    Can you hold me accountable? {link}
  ''',
  'social_proof': '''
    {witness_name}, I started something and I need your help.
    I'm {X} days into becoming {identity_goal}.
    Will you be my witness? {link}
  ''',
  'reciprocal': '''
    {witness_name}, I'm building a new habit and I want you to see my journey.
    Maybe it'll inspire you too. Here's the invite: {link}
  ''',
};
```

**Include:** Complete invitation funnel diagram with conversion rate benchmarks at each step.

---

## Sub-Question RQ-040c: Witness-to-Creator Conversion Triggers

### Core Question
What specific experiences, moments, or prompts cause a witness to decide "I should create my own pact"?

### Why This Matters
This is the KEY lever for K-factor. Increasing conversion from 22% to 40% would nearly double the viral coefficient.

### Conversion Trigger Hypothesis

| Trigger Category | Example | Timing | Conversion Impact |
|------------------|---------|--------|-------------------|
| **Social Proof** | "Your friend just hit 30 days!" | Milestone moment | HIGH |
| **Inspiration** | "Sarah said you inspired her to start" | After creator success | HIGH |
| **Reciprocity** | "Sarah is watching you. Want to start your own pact?" | After engagement | MEDIUM |
| **FOMO** | "3 of your friends are building habits" | After threshold | MEDIUM |
| **Identity Resonance** | "Sarah is becoming a morning person. What about you?" | Contextual | HIGH |
| **Friction Removal** | "Start in 30 seconds with Sarah as your witness" | Any time | HIGH |
| **Explicit Ask** | Creator asks witness to join | After trust built | HIGH |

### Sub-Questions (Answer Each)

| # | Question | Your Task |
|---|----------|-----------|
| **c1** | What are the top 5 conversion triggers by effectiveness? | Research and rank. Include evidence from analogous products. |
| **c2** ⚖️ | When is the optimal moment to prompt conversion? | Options: (A) Immediately after invitation acceptance, (B) After witnessing first success, (C) After 7 days of engagement. Analyze timing impact. |
| **c3** | How should the conversion prompt be framed? | Draft 3-5 conversion prompt variants. Analyze psychological framing. |
| **c4** | Should the creator be involved in witness conversion? | Analyze: Creator prompts witness vs app prompts witness. Trust and effectiveness tradeoff. |
| **c5** | What's the conversion onboarding flow for witnesses? | Design expedited onboarding that leverages existing witness context. Should be faster than cold user. |
| **c6** ⚖️ | Should witnesses start with the inviting user as THEIR witness? | Automatic reciprocity vs choice. Analyze network topology implications. |
| **c7** | How do we handle "interested but not ready" witnesses? | Design nurture flow for witnesses who don't convert immediately but might later. |

### Anti-Patterns to Avoid
- ❌ Aggressive conversion prompts (feels like sales pitch)
- ❌ Conversion prompt before witness has seen value (premature)
- ❌ No conversion path (relying on organic discovery)
- ❌ Shame-based conversion ("Everyone else is doing it")
- ❌ Complex conversion flow (friction kills conversion)

### Output Required: Conversion Funnel Specification

```dart
/// Conversion trigger system
class WitnessConversionService {
  /// Evaluate conversion readiness
  ConversionReadiness assessReadiness(WitnessProfile witness) {
    return ConversionReadiness(
      engagementScore: _calculateEngagement(witness),
      exposedToValue: _hasSeenCreatorSuccess(witness),
      optimalTrigger: _selectTrigger(witness),
      conversionProbability: _predictConversion(witness),
    );
  }

  /// Select best conversion trigger for this witness
  ConversionTrigger selectTrigger(WitnessProfile witness) {
    // Logic based on witness behavior
  }

  /// Generate conversion prompt
  ConversionPrompt generatePrompt({
    required WitnessProfile witness,
    required ConversionTrigger trigger,
    required Profile creator,  // The person they're witnessing
  }) {
    // Personalized prompt generation
  }
}

/// Conversion prompt templates
const conversionPrompts = {
  'social_proof': '''
    {creator_name} just hit {milestone}!
    You've been part of their journey for {days} days.
    Ready to start your own? {creator_name} can be your first witness.
    [Start My Pact] [Not Yet]
  ''',
  'reciprocal': '''
    {creator_name} is cheering you on as their witness.
    Want them to cheer for your goals too?
    [Start Together] [Just Watching for Now]
  ''',
  // ... more templates
};
```

**Include:** Decision tree for when and how to prompt conversion.

---

## Sub-Question RQ-040d: Multi-Witness Network Effects

### Core Question
How do dynamics change when users have multiple witnesses, and how can we design for network effects at scale?

### Why This Matters
Multi-witness scenarios create network topology that can amplify or dampen growth. Understanding these dynamics is critical for K > 1.

### Network Topology Analysis

```
TOPOLOGY A: Linear Chains (Current)
User1 → Witness1 → Witness2 → ...
K limited by single-path conversion

TOPOLOGY B: Branching Trees
User1 → Witness1
      → Witness2
      → Witness3
K amplified by multiple paths

TOPOLOGY C: Interconnected Web
User1 ↔ User2 ↔ User3
      ↖      ↗
        User4
Network effects: clusters create retention
```

### Sub-Questions (Answer Each)

| # | Question | Your Task |
|---|----------|-----------|
| **d1** | What's the optimal number of witnesses per pact? | Analyze: 1 vs 2 vs 3+ witnesses. Accountability effectiveness vs invitation fatigue. |
| **d2** ⚖️ | Should we incentivize multiple witnesses? | Options: (A) No incentive (organic), (B) Soft nudge ("add another witness for better accountability"), (C) Gamified (achievements for witness count). |
| **d3** | How do multiple witnesses interact with each other? | Design multi-witness experience. Can witnesses see each other? Coordinate? Compete? |
| **d4** | What's the "magic number" for network activation? | Research threshold: How many connections before user is "locked in" to the network? |
| **d5** | How do we prevent witness overlap/saturation? | Scenario: User A and User B both invite User C. How do we handle? |
| **d6** ⚖️ | Should we build "accountability groups"? | Analyze: Individual pacts with witnesses vs group pacts (e.g., "Our family's fitness pact"). |
| **d7** | How do network effects impact retention? | Model: Retention correlation with witness count and network density. |

### Anti-Patterns to Avoid
- ❌ Requiring multiple witnesses (blocks low-social users)
- ❌ Witness spam (user invites 20 people, none engage)
- ❌ Isolated networks (clusters that don't interconnect)
- ❌ Asymmetric value (witnesses give more than they get)
- ❌ Complex group dynamics that confuse the product

### Output Required: Network Effects Model

```dart
/// Network topology analysis
class NetworkEffectsService {
  /// Calculate network strength for user
  NetworkStrength calculateStrength(String userId) {
    return NetworkStrength(
      directConnections: _countDirectWitnesses(userId),
      secondDegree: _countSecondDegreeConnections(userId),
      clusterDensity: _calculateClusterDensity(userId),
      retentionCorrelation: _correlateWithRetention(userId),
    );
  }

  /// Predict viral spread from user
  ViralPrediction predictSpread(String userId) {
    // K-factor prediction for this user's network
  }
}

/// Network health metrics
class NetworkMetrics {
  final double averageWitnessesPerUser;
  final double witnessOverlapRate;  // % of witnesses shared between users
  final double clusterCoefficient;  // Network density
  final double giantComponentSize;  // % of users in largest connected group
  final double pathLength;          // Average distance between any two users
}
```

**Include:** Visual network topology diagrams for ideal vs problematic states.

---

## Sub-Question RQ-040e: Viral Coefficient Modeling & Targets

### Core Question
What viral coefficient (K) can we realistically achieve, and what interventions have the highest impact on K?

### Why This Matters
This is the quantitative model that determines whether The Pact can achieve self-sustaining growth.

### K-Factor Formula

```
K = i × c × a

Where:
  i = invitations per user (average witnesses invited)
  c = conversion rate (% of invitees who become users)
  a = activation rate (% of new users who invite their own witnesses)

Current State:
  i = 1.1 (estimated - 42% add supporter, most add 1)
  c = 0.22 (from User Journey Map)
  a = 0.42 (same as i for now, assuming similar behavior)

  K = 1.1 × 0.22 × 0.42 = 0.10 (very sub-viral)

  Wait, recalculating with simpler model:
  K = i × c = 1.1 × 0.22 = 0.24 (still sub-viral)
```

### Sub-Questions (Answer Each)

| # | Question | Your Task |
|---|----------|-----------|
| **e1** | What's the realistic ceiling for each K-factor component? | Benchmark against best-in-class: Clubhouse (K~2 at peak), Robinhood (K~1.5), Duolingo (K~0.8). |
| **e2** | Which lever has highest ROI for K improvement? | Sensitivity analysis: 10% improvement in i vs c vs a. Where should we invest? |
| **e3** ⚖️ | What K target should we set? | Options: (A) K=0.5 (realistic), (B) K=1.0 (ambitious), (C) K=1.5 (aggressive). Resource implications. |
| **e4** | What's the time-to-conversion for viral loops? | Model: How long from invitation → registration → first pact → first witness invitation? Velocity matters for K effectiveness. |
| **e5** | How does K vary by user segment? | Segment analysis: K for high-engagement vs low-engagement, premium vs free, by demographic. |
| **e6** | What interventions move K most efficiently? | Rank interventions by K impact per engineering effort. |
| **e7** | How do we measure and monitor K in production? | Dashboard spec: Real-time K calculation, cohort analysis, intervention impact tracking. |

### Anti-Patterns to Avoid
- ❌ Optimizing for K without quality (spam invitations = high K, bad retention)
- ❌ Ignoring activation rate (users who don't invite = K death)
- ❌ Single K number (segment-specific K is more actionable)
- ❌ Short-term K boost (incentivized invitations that don't sustain)

### Output Required: K-Factor Model and Dashboard

```dart
/// K-factor calculation service
class ViralCoefficientService {
  /// Calculate current K-factor
  KFactor calculateCurrentK({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final invitationRate = _calculateInvitationRate(startDate, endDate);
    final conversionRate = _calculateConversionRate(startDate, endDate);
    final activationRate = _calculateActivationRate(startDate, endDate);

    return KFactor(
      overall: invitationRate * conversionRate * activationRate,
      components: KComponents(
        invitationRate: invitationRate,
        conversionRate: conversionRate,
        activationRate: activationRate,
      ),
      bySegment: _calculateBySegment(startDate, endDate),
    );
  }

  /// Project growth based on current K
  GrowthProjection projectGrowth({
    required int currentUsers,
    required KFactor k,
    required int months,
  }) {
    // Compound growth calculation
  }
}

/// K-factor dashboard metrics
class KFactorDashboard {
  final KFactor currentK;
  final KFactor k7Day;  // Trailing 7 days
  final KFactor k30Day; // Trailing 30 days
  final List<KByIntervention> interventionImpact;
  final GrowthProjection projection;
}
```

**Include:**
- Sensitivity analysis table (K impact per lever)
- Growth projection charts for K=0.5, K=1.0, K=1.5
- Intervention priority matrix

---

## Sub-Question RQ-040f: Witness Retention Without Conversion

### Core Question
How do we keep witnesses engaged even if they don't convert to creators, and what value do engaged-but-not-converted witnesses provide?

### Why This Matters
Not all witnesses will convert. But engaged witnesses still provide value (accountability, future conversion potential, brand ambassadors). We should optimize for their experience too.

### Witness Lifecycle States

```
INVITED → VIEWED → ENGAGED → CONVERTED
              ↓          ↓
           DORMANT → CHURNED

Goal: Maximize time in ENGAGED, minimize DORMANT/CHURNED
Even if not CONVERTED, ENGAGED witnesses provide value
```

### Sub-Questions (Answer Each)

| # | Question | Your Task |
|---|----------|-----------|
| **f1** | What's the value of an engaged-but-not-converted witness? | Quantify: Accountability value to creator, future conversion probability, word-of-mouth value. |
| **f2** | What engagement patterns predict eventual conversion? | Identify leading indicators: Notification open rate, message sent, time in app, etc. |
| **f3** ⚖️ | Should we have a "witness-only" mode? | Options: (A) No (push to convert), (B) Yes (legitimate use case), (C) Time-limited (witness for 30 days, then prompted). |
| **f4** | How do we re-engage dormant witnesses? | Design re-engagement flow for witnesses who stopped opening notifications. |
| **f5** | What's the "witness success metric"? | Define: What makes a witness "successful" even without converting? |
| **f6** | How long do witnesses stay engaged without converting? | Model: Engagement decay curve. When is conversion probability effectively zero? |

### Anti-Patterns to Avoid
- ❌ Abandoning non-converting witnesses (they still provide value)
- ❌ Pestering dormant witnesses (relationship damage)
- ❌ No win-back strategy (missed second chances)
- ❌ Treating all non-conversions as failures (some are successful witnesses)

### Output Required: Witness Lifecycle Management

```dart
/// Witness lifecycle management
class WitnessLifecycleService {
  /// Classify witness state
  WitnessState classifyWitness(WitnessProfile witness) {
    if (witness.hasCreatedPact) return WitnessState.converted;
    if (witness.lastEngagement.isAfter(DateTime.now().subtract(Duration(days: 7)))) {
      return WitnessState.engaged;
    }
    if (witness.lastEngagement.isAfter(DateTime.now().subtract(Duration(days: 30)))) {
      return WitnessState.dormant;
    }
    return WitnessState.churned;
  }

  /// Get re-engagement strategy
  ReengagementStrategy? getReengagementStrategy(WitnessProfile witness) {
    // Logic for re-engagement
  }
}

enum WitnessState {
  invited,   // Invitation sent, not yet engaged
  viewed,    // Opened invitation/app
  engaged,   // Active in last 7 days
  dormant,   // Inactive 7-30 days
  churned,   // Inactive 30+ days
  converted, // Created own pact
}
```

---

## Sub-Question RQ-040g: High-Value User Quality Validation

### Core Question
How do we validate the hypothesis that witness-converted users are higher quality than organically acquired users?

### Why This Matters
If the "high-value hypothesis" is false, the entire strategy may be misguided. We need to validate with data.

### High-Value Hypothesis Predictions

| Metric | Prediction | How to Measure |
|--------|------------|----------------|
| **D7 Retention** | Witness-converted > Organic | Cohort comparison |
| **D30 Retention** | Witness-converted > Organic | Cohort comparison |
| **Pact Completion Rate** | Witness-converted > Organic | Success rate comparison |
| **Witness Invitation Rate** | Witness-converted > Organic | Behavior comparison |
| **Premium Conversion** | Witness-converted > Organic | Revenue attribution |
| **NPS** | Witness-converted > Organic | Survey comparison |

### Sub-Questions (Answer Each)

| # | Question | Your Task |
|---|----------|-----------|
| **g1** | What metrics define "high-value user"? | Create composite quality score. Weight retention, engagement, virality, LTV. |
| **g2** | How do we attribute user source accurately? | Technical spec for first-touch attribution. Handle edge cases (saw ad then got invitation). |
| **g3** | What's the minimum sample size for statistical significance? | Power analysis for cohort comparison. |
| **g4** | How long should we wait before comparing cohorts? | Define comparison window (30 days? 90 days?). |
| **g5** ⚖️ | Should high-value validation change our strategy? | Scenarios: (A) Hypothesis validated → double down on viral, (B) Hypothesis invalidated → rebalance to paid acquisition. |
| **g6** | What confounding factors might bias the comparison? | Identify: Selection bias (who gets invited), relationship quality, demographic differences. |

### Anti-Patterns to Avoid
- ❌ Assuming hypothesis is true without validation
- ❌ Cherry-picking metrics that support hypothesis
- ❌ Insufficient sample size for conclusions
- ❌ Ignoring confounding factors

### Output Required: Validation Framework

```dart
/// User quality validation
class UserQualityValidation {
  /// Calculate quality score
  UserQualityScore calculateQuality(String userId) {
    return UserQualityScore(
      retentionScore: _calculateRetention(userId),
      engagementScore: _calculateEngagement(userId),
      viralityScore: _calculateVirality(userId),
      revenueScore: _calculateLTV(userId),
      composite: _calculateComposite(userId),
    );
  }

  /// Compare cohorts
  CohortComparison compareCohorts({
    required List<String> witnessConverted,
    required List<String> organicUsers,
    required Duration window,
  }) {
    // Statistical comparison
  }
}

/// Validation dashboard
class ValidationDashboard {
  final CohortComparison d7Retention;
  final CohortComparison d30Retention;
  final CohortComparison pactCompletionRate;
  final CohortComparison invitationRate;
  final double statisticalSignificance;  // p-value
  final String recommendation;  // "Validated" or "Not Validated"
}
```

---

## Architectural Constraints (Hard Requirements)

| Constraint | Rule | Rationale |
|------------|------|-----------|
| **Platform** | Android-first (CD-017) | All invitation channels must work on Android |
| **Ethics** | No dark patterns (CD-010) | No guilt/shame/FOMO-based invitations |
| **Optional Witnesses** | AI as default witness (CD-002) | Cannot require human witness |
| **Complexity** | VALUABLE threshold (CD-018) | No MLM-style multi-level referral complexity |
| **Database** | Supabase PostgreSQL | Standard relational tables, no graph DB |
| **Attribution** | End-to-end tracking | Must track invitation → registration → conversion |
| **Privacy** | GDPR/CCPA compliant | Contact data handling, opt-out mechanisms |

---

## Output Quality Criteria

| Criterion | Question to Ask |
|-----------|-----------------|
| **Quantitative** | Are K-factor projections backed by realistic assumptions? |
| **Actionable** | Can engineering implement the invitation flow from this spec? |
| **Ethical** | Does this avoid dark patterns in social mechanics? |
| **Testable** | Are hypotheses structured for A/B testing? |
| **Segment-Aware** | Does the model account for user diversity? |
| **Sustainable** | Will this growth engine work at 100K users? 1M users? |
| **Measurable** | Is there a clear dashboard spec for monitoring K? |

---

## Example of Good Output: Invitation Message A/B Test

```markdown
### Invitation Message Variants (A/B Test Framework)

| Variant | Message | Psychological Lever | Expected CTR |
|---------|---------|---------------------|--------------|
| **A: Personal** | "Hey {name}, I'm working on becoming {identity}. I picked you because I trust your honesty. Will you watch my journey? {link}" | Trust, vulnerability | 35% |
| **B: Social Proof** | "{name}, I just started day 1 of my transformation. {mutual_friends_count} people are already on The Pact. Join my corner? {link}" | FOMO, social proof | 28% |
| **C: Reciprocal** | "{name}, I need an accountability partner. If this works for me, maybe you'll want to try too. Here's the invite: {link}" | Reciprocity, curiosity | 32% |
| **D: Story** | "{name}, remember when I said I wanted to {goal}? I finally started. Can you help me not give up? {link}" | Narrative, history | 40% |

**Recommendation:** Variant D (Story) predicted highest CTR due to:
1. References shared history (trust signal)
2. Vulnerability admission (authenticity)
3. Clear ask (help me not give up)
4. No pressure to join themselves

**Test Plan:**
- Sample: 1000 invitations per variant
- Duration: 14 days
- Primary metric: Invitation open rate
- Secondary metric: Registration rate
- Statistical threshold: p < 0.05
```

---

## Concrete Scenario: Solve This End-to-End

**Maya's Viral Journey**

Maya joins The Pact on February 1st via organic search.

**Day 1:**
- Completes Sherlock Protocol
- Creates pact: "I want to become someone who writes daily"
- Prompted to add witness

**Walk through EXACTLY:**

1. **Day 1: Witness invitation flow**
   - What does Maya see?
   - What are her options?
   - What does the invitation message say?
   - What channel is used?
   - What tracking is in place?

2. **Day 1: Witness (Marcus) receives invitation**
   - What does Marcus see in the SMS/WhatsApp/email?
   - What happens when he clicks the link?
   - What's his first 60 seconds in the app?
   - Is he prompted to download? Register? Both?

3. **Day 7: Marcus is an active witness**
   - What notifications has Marcus received?
   - What has he seen about Maya's progress?
   - What actions has he taken?
   - What's his engagement score?

4. **Day 14: Maya hits 14-day milestone**
   - What does Marcus see?
   - Is he prompted to convert?
   - What's the conversion prompt?
   - What happens if he clicks "Start My Pact"?
   - What happens if he clicks "Not Yet"?

5. **Day 21: Marcus converts**
   - What's his onboarding flow? (expedited?)
   - Is Maya automatically his witness?
   - What does Maya see about Marcus starting?
   - What's Marcus's first invitation flow?

6. **Day 30: Viral loop complete**
   - Marcus has invited his friend Jordan
   - What are the K-factor metrics at this point?
   - What would need to happen for this loop to continue?

---

## Industry Research Required

| Company | What They Do | What We Learn |
|---------|--------------|---------------|
| **Strava** | Follow athletes, see activity | Passive following creates engagement but low conversion |
| **Duolingo** | Referral bonuses | Incentivized referral, but gems inflation risk |
| **Clubhouse** | Exclusive invites | Scarcity-driven virality (K~2 at peak), but burned out |
| **Robinhood** | Free stock for invites | Strong incentive, but regulatory scrutiny |
| **BeReal** | Notification-based social | Time-pressure creates engagement, mixed retention |
| **Beeminder** | Referees verify goals | Accountability-focused witnesses, niche audience |
| **StickK** | Referee + stakes | Financial stakes + social accountability |

**Key Question:** Which model is most analogous to The Pact's witness mechanic?

---

## Final Checklist Before Submitting

- [ ] Each sub-question (a1-a7, b1-b7, etc.) has explicit answer
- [ ] Questions marked ⚖️ have 2-3 options with tradeoff analysis
- [ ] Witness value proposition is clearly articulated
- [ ] Invitation flow includes channel selection logic and message templates
- [ ] Conversion triggers include decision tree for timing and framing
- [ ] Network effects model includes topology analysis
- [ ] K-factor model includes sensitivity analysis and projections
- [ ] Witness retention includes lifecycle management
- [ ] High-value validation includes statistical framework
- [ ] Maya/Marcus scenario solved with day-by-day walkthrough
- [ ] All Dart pseudocode is implementable
- [ ] SQL schemas are complete with indexes
- [ ] Anti-patterns explicitly avoided
- [ ] CD-010 compliance verified (no dark patterns)
- [ ] Industry comparison included with actionable insights
- [ ] Dashboard specs include all metrics for monitoring

---

## Confidence Assessment Template

| Recommendation | Confidence | Rationale | Follow-Up Needed |
|----------------|------------|-----------|------------------|
| Witness value prop | HIGH/MEDIUM/LOW | [Why] | [Validation approach] |
| Optimal invitation channel | HIGH/MEDIUM/LOW | [Why] | [A/B test plan] |
| Conversion trigger timing | HIGH/MEDIUM/LOW | [Why] | [User research] |
| K-factor target | HIGH/MEDIUM/LOW | [Why] | [Benchmark validation] |
| Multi-witness recommendation | HIGH/MEDIUM/LOW | [Why] | [UX testing] |
| High-value hypothesis | HIGH/MEDIUM/LOW | [Why] | [Cohort analysis] |

---

*This prompt follows the DEEP_THINK_PROMPT_GUIDANCE.md quality framework. Comprehensive research across all 7 sub-RQs required for complete growth strategy specification.*
