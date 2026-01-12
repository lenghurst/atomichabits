# Witness Intelligence Layer (WIL)

> **Created:** 12 January 2026
> **Status:** DRAFT — Architectural specification
> **Related:** RQ-040 (Viral Witness Growth), JITAI Architecture, Deep Think "The Confidant"
> **Principle:** JITAI is the entire intelligence layer — it captures granular data to generate differentiated, high-impact insights across ALL touchpoints, including witnesses.

---

## Core Concept

**Current State:** JITAI adapts interventions for the **creator** based on their context.

**Required Evolution:** JITAI must extend to capture and adapt the **entire witness lifecycle**:
- What witnesses see
- When they're notified
- How messages are framed
- What actions they can take
- When/how they're prompted to convert
- What punishment/stakes mechanics are triggered

```
┌─────────────────────────────────────────────────────────────────────┐
│                    WITNESS INTELLIGENCE LAYER                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  CREATOR JOURNEY                    WITNESS JOURNEY                 │
│  ──────────────                     ───────────────                 │
│  Onboarding                         Invitation Received             │
│       │                                    │                        │
│       ▼                                    ▼                        │
│  Sherlock (Holy Trinity)            Link Clicked                    │
│       │                                    │                        │
│       ▼                                    ▼                        │
│  Digital Pact Signing ─────────────► Witness Access Decision        │
│       │                             (App/Web/Notification-only)     │
│       ▼                                    │                        │
│  "Appoint Your Council" ◄──────────────────┘                        │
│  (Commitment Ceremony)                     │                        │
│       │                                    ▼                        │
│       ▼                             Witness Engagement              │
│  Daily Habit Voting ───────────────► Narrative Delivery             │
│       │                             (Role-based JITAI)              │
│       ▼                                    │                        │
│  Milestones/Struggles ─────────────► Conversion Triggers            │
│       │                                    │                        │
│       ▼                                    ▼                        │
│  Stakes/Punishment ◄───────────────► Witness Accountability         │
│                                                                     │
│  ◄──────────── DATA CAPTURE AT EVERY TOUCHPOINT ────────────►       │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## PD-130: Witness App Access Model ⚖️

**Decision Required:** What level of app access should witnesses have?

### Options Analysis

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| **A: Notification-Only** | Witnesses receive notifications but no app access | Lowest friction, no install required | No engagement surface, limited data capture |
| **B: Web PWA** | Witnesses access via progressive web app (no install) | Low friction, cross-platform, sharable | Limited push notification reliability, no deep permissions |
| **C: Limited App Access** | Witnesses install app but see restricted "witness view" | Full notification capability, some data capture | Install friction kills conversion |
| **D: Full App Preview** | Witnesses get full app access as "preview" before converting | Maximum exposure to value, highest conversion potential | Complexity, may satisfy without converting |

### JITAI Considerations for App Access

**The Question:** How does JITAI inform witness app access?

| JITAI Principle | Implication for Witness Access |
|-----------------|-------------------------------|
| **Context Capture** | More access = more data = better personalization |
| **Timing Optimization** | Need engagement signals to time conversion prompts |
| **Burden Calculation** | Install friction is HIGH burden — may exceed value for early witnesses |
| **Adaptive Intervention** | Can't adapt what we can't measure — limited access = blind intervention |

### Recommended Model: Tiered Access Based on Engagement

```
STAGE 1: Web PWA (Days 0-7)
├── No install required
├── Magic link access
├── Basic creator progress view
├── Limited push notifications (browser-based)
└── Data captured: page views, time on site, actions taken

STAGE 2: App Invitation (Day 7+ OR High Engagement)
├── Triggered by: milestone event OR engagement threshold
├── Framing: "Get real-time updates on [Creator]'s journey"
├── Unlock: Full notification capability, witness dashboard
└── Data captured: Full engagement funnel

STAGE 3: Conversion Prompt (Milestone + Engagement)
├── Triggered by: Creator milestone + Witness engagement score
├── Framing: "Start your own Pact — [Creator] can witness you"
└── Data captured: Conversion attribution, reciprocal relationship
```

### New RQs Generated

| RQ# | Question | Blocking |
|-----|----------|----------|
| **RQ-041** | What is the optimal witness access tier progression for maximizing conversion while minimizing friction? | PD-130 |
| **RQ-041a** | At what engagement threshold should witnesses be prompted to install the app? | RQ-041 |
| **RQ-041b** | Does PWA-first reduce or increase ultimate conversion vs app-first? | RQ-041 |
| **RQ-041c** | What's the data capture loss from PWA vs native app for witness behavior? | RQ-041 |

---

## PD-131: Invitation Message Strategy

**Decision Required:** What invitation message variants should we test, and what underlying beliefs do they challenge?

### Confirmed Variants

| Variant | Message | Psychological Lever | Underlying Belief Tested |
|---------|---------|---------------------|--------------------------|
| **A: Vulnerability** | "Hey [Name], I'm trying to become 'The Writer' but I keep self-sabotaging. I need a witness to keep me honest. You don't need to do anything but watch. [Link]" | Authenticity, low-ask | "Vulnerability creates connection" |
| **B: The Contract** | "I've signed a Pact to defeat my 'Procrastinator' archetype. I need a witness to seal the contract. Can you sign for me? [Link]" | Ceremony, commitment device | "Formal contracts increase perceived stakes" |
| **C: The Story** | "Hey [Name], remember when I said I wanted to [goal]? I finally started. Can you help me not give up? [Link]" | Shared history, narrative | "Referencing past conversations increases trust" |
| **D: The Confidant** | "I'm fighting my inner Saboteur. I need someone who can see the real battle. Will you be my witness? [Link]" | Exclusive access, intimacy | "Framing as privilege increases engagement" |

### JITAI Data Requirements for Message Optimization

**What must WIL capture to optimize invitation messages?**

```dart
class InvitationEvent {
  // Core metrics
  final String variantId;           // A, B, C, D
  final DateTime sentAt;
  final String channel;             // SMS, WhatsApp, email, share_sheet

  // Contextual factors (JITAI captures these)
  final CreatorContext creatorContext;  // Energy state, recent engagement, streak
  final RelationshipStrength relationship; // Inferred from contact frequency
  final TimeContext timeContext;    // Day of week, time of day

  // Outcomes (tracked over time)
  final DateTime? openedAt;
  final DateTime? clickedAt;
  final DateTime? registeredAt;
  final DateTime? firstEngagementAt;
  final DateTime? convertedAt;
}

class InvitationInsight {
  // JITAI-generated insights
  final String insight;             // "Vulnerability variant performs 2.3x better for high-intimacy relationships"
  final double confidence;
  final int sampleSize;
  final Map<String, double> segmentPerformance;
}
```

### New RQs Generated

| RQ# | Question | Blocking |
|-----|----------|----------|
| **RQ-042** | Which invitation message variant achieves highest open rate by relationship type? | PD-131 |
| **RQ-042a** | Does the "Contract" framing increase or decrease perceived burden for witnesses? | RQ-042 |
| **RQ-042b** | How does creator's current streak/state affect optimal message variant? | RQ-042 |
| **RQ-042c** | What is the optimal message length for each channel (SMS vs WhatsApp vs email)? | RQ-042 |
| **RQ-042d** | Does including the archetype name (e.g., "The Writer") increase or decrease click-through? | RQ-042 |

---

## PD-132: Invitation Timing — The Commitment Ceremony ✅ CONFIRMED

**Decision:** Prompt witness invitation immediately after the user signs the digital pact.

**Copy:** "A Pact is only binding if witnessed. Appoint your Council."

### Rationale

| Factor | Why This Timing Works |
|--------|----------------------|
| **Peak Commitment** | User just made public commitment — psychological momentum is highest |
| **Ceremony Completion** | Witness appointment "seals" the pact — incomplete without it |
| **Narrative Coherence** | "Council" language matches Parliament of Selves framing |
| **Low Friction** | User is already in high-engagement state, one more step feels natural |
| **JITAI Alignment** | V-O state is peak Opportunity (commitment made), low Vulnerability (hopeful state) |

### Ceremony Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                    THE COMMITMENT CEREMONY                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  STEP 1: Identity Declaration                                       │
│  "I am becoming [The Writer / The Athlete / The Present Parent]"    │
│                                                                     │
│  STEP 2: Shadow Acknowledgment                                      │
│  "I recognize my [Procrastinator / Perfectionist / Avoider]"        │
│                                                                     │
│  STEP 3: Pact Signing                                               │
│  [Digital signature / Thumbprint animation]                         │
│  "I hereby commit to this transformation"                           │
│                                                                     │
│  STEP 4: Council Appointment ◄── WITNESS INVITATION TRIGGER         │
│  "A Pact is only binding if witnessed. Appoint your Council."       │
│  [Select 1-3 witnesses from contacts]                               │
│                                                                     │
│  STEP 5: Pact Activation                                            │
│  "Your Pact is now active. Day 1 begins."                           │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### JITAI Data Capture at Ceremony

```dart
class CommitmentCeremonyEvent {
  final String pactId;
  final DateTime signedAt;

  // Identity declarations (for witness messaging personalization)
  final String aspirationalIdentity;  // "The Writer"
  final String shadowArchetype;       // "The Procrastinator"

  // Witness invitation context
  final int witnessesInvited;
  final List<WitnessInvitation> invitations;

  // Ceremony completion metrics
  final Duration ceremonyDuration;
  final bool skippedWitnessStep;      // CRITICAL: track skip rate
  final String? skipReason;           // If provided
}
```

### New RQs Generated

| RQ# | Question | Blocking |
|-----|----------|----------|
| **RQ-043** | What is the witness invitation skip rate at Commitment Ceremony, and what predicts skipping? | — |
| **RQ-043a** | Does offering "Invite Later" option increase or decrease ultimate invitation rate? | RQ-043 |
| **RQ-043b** | What is the optimal number of witnesses to prompt for at ceremony (1 vs 3 vs "up to 3")? | RQ-043 |

---

## PD-133: Witness Stakes & Punishment Mechanics

**Decision Required:** What punishment/stakes mechanics should witnesses be able to trigger or observe?

### Stakes Framework Options

| Option | Mechanism | Witness Role | Risk |
|--------|-----------|--------------|------|
| **A: Visibility Only** | Witness sees streaks/failures, no action | Passive accountability (shame-based) | Can feel like surveillance |
| **B: Soft Stakes** | Creator sets personal stakes, witness observes fulfillment | "I'll donate $20 if I fail" — witness verifies | Low friction, relies on honor |
| **C: Escrow Stakes** | Real money held in escrow, released to charity on failure | Witness confirms failure triggers release | High friction, high commitment |
| **D: Social Stakes** | Failure triggers auto-post to witness (or group) | "I failed my Pact today" | Highest stakes, relationship risk |
| **E: Witness-Set Challenges** | Witnesses can set mini-challenges with stakes | "If you write 500 words today, I'll buy you coffee" | Reciprocal engagement, complexity |

### Underlying Beliefs to Query

| Belief | Convention | Query |
|--------|------------|-------|
| "Stakes increase commitment" | Loss aversion drives behavior | But: Does external punishment undermine intrinsic motivation? |
| "Public accountability works" | Social pressure drives compliance | But: Does shame-based accountability damage relationships? |
| "Witnesses want to help" | Altruistic motivation | But: Are witnesses willing to be "enforcers"? |
| "Financial stakes are effective" | StickK/Beeminder model | But: Does money-at-risk attract different user segment? |

### JITAI Integration for Stakes

```dart
class StakesEngine {
  /// Determine if stakes intervention should fire
  Future<StakesDecision> evaluate({
    required CreatorState state,
    required StakesConfiguration stakes,
    required List<WitnessProfile> witnesses,
  }) async {
    // Check if failure threshold met
    if (!state.meetsFailureThreshold(stakes.threshold)) {
      return StakesDecision.noAction();
    }

    // Calculate optimal intervention
    final intervention = _selectIntervention(
      state: state,
      stakes: stakes,
      witnessEngagement: witnesses.map((w) => w.engagementScore).toList(),
    );

    // Apply JITAI timing
    final timing = _calculateOptimalTiming(state, intervention);

    return StakesDecision.trigger(
      intervention: intervention,
      timing: timing,
      notifyWitnesses: stakes.witnessVisibility,
    );
  }
}

class StakesConfiguration {
  final StakesType type;              // visibility, soft, escrow, social
  final int failureThreshold;         // Days of non-completion before trigger
  final double? escrowAmount;         // If financial stakes
  final String? charityDestination;   // Where money goes on failure
  final bool witnessVisibility;       // Do witnesses see failure events?
  final bool witnessCanTrigger;       // Can witnesses manually trigger stakes?
}
```

### New RQs Generated

| RQ# | Question | Blocking |
|-----|----------|----------|
| **RQ-044** | What stakes mechanism achieves highest habit completion rate without damaging intrinsic motivation? | PD-133 |
| **RQ-044a** | Does witness-visible failure increase or decrease long-term retention? | RQ-044 |
| **RQ-044b** | What percentage of users would use financial escrow stakes? | RQ-044 |
| **RQ-044c** | Do social stakes (auto-post failure) damage witness relationships? | RQ-044 |
| **RQ-044d** | Should witnesses have power to "forgive" a failure (grace period)? | RQ-044 |

---

## PD-134: JITAI Witness Data Schema

**Decision Required:** What granular data must WIL capture to generate differentiated insights?

### Minimum Viable Data Model

```sql
-- Witness engagement events (granular capture)
CREATE TABLE witness_engagement_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  witness_relationship_id UUID REFERENCES witness_relationships(id),
  event_type TEXT NOT NULL,
  event_data JSONB,
  context JSONB,  -- JITAI context at time of event
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Event types to capture
COMMENT ON TABLE witness_engagement_events IS '
Event types:
- invitation_sent
- invitation_opened
- invitation_clicked
- page_viewed (PWA)
- app_installed
- notification_received
- notification_opened
- notification_dismissed
- encouragement_sent
- challenge_set (mentor role)
- creator_progress_viewed
- conversion_prompt_shown
- conversion_prompt_clicked
- conversion_prompt_dismissed
- converted_to_creator
- churned (30 days inactive)
';

-- Context captured with each event
COMMENT ON COLUMN witness_engagement_events.context IS '
JITAI context:
{
  "time_of_day": "morning|afternoon|evening|night",
  "day_of_week": "monday|...|sunday",
  "creator_streak": 7,
  "creator_last_activity": "2026-01-12T10:00:00Z",
  "witness_engagement_score": 0.75,
  "witness_notifications_this_week": 3,
  "witness_role_type": "confidant|cheerleader|mentor",
  "relationship_strength": "close|casual|unknown",
  "days_since_invitation": 14,
  "invitation_variant": "A|B|C|D"
}
';

-- Aggregated witness metrics (materialized for queries)
CREATE TABLE witness_metrics (
  witness_relationship_id UUID PRIMARY KEY REFERENCES witness_relationships(id),

  -- Engagement metrics
  total_notifications_sent INT DEFAULT 0,
  total_notifications_opened INT DEFAULT 0,
  notification_open_rate DECIMAL(5,4),
  total_encouragements_sent INT DEFAULT 0,
  total_page_views INT DEFAULT 0,
  total_time_on_site_seconds INT DEFAULT 0,

  -- Conversion metrics
  conversion_prompts_shown INT DEFAULT 0,
  conversion_prompts_clicked INT DEFAULT 0,
  converted_at TIMESTAMPTZ,

  -- Derived scores
  engagement_score DECIMAL(5,4),  -- 0-1 composite score
  conversion_probability DECIMAL(5,4),  -- ML-predicted

  -- Timestamps
  first_engagement_at TIMESTAMPTZ,
  last_engagement_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for JITAI queries
CREATE INDEX idx_witness_engagement_context ON witness_engagement_events USING GIN (context);
CREATE INDEX idx_witness_metrics_engagement ON witness_metrics (engagement_score DESC);
```

### Insight Generation Requirements

```dart
/// WIL Insight Generator
class WitnessInsightGenerator {
  /// Generate actionable insights from witness data
  Future<List<WitnessInsight>> generateInsights() async {
    return [
      // Invitation optimization
      await _analyzeInvitationVariants(),

      // Timing optimization
      await _analyzeNotificationTiming(),

      // Conversion triggers
      await _analyzeConversionTriggers(),

      // Role effectiveness
      await _analyzeRoleTypePerformance(),

      // Stakes effectiveness
      await _analyzeStakesImpact(),
    ];
  }

  /// Example insight: Invitation variant performance
  Future<WitnessInsight> _analyzeInvitationVariants() async {
    // Query: Group by variant, calculate open rate, click rate, conversion rate
    // Segment by: relationship strength, creator archetype, time of day
    // Output: "Variant B (Contract) performs 1.8x better for 'Perfectionist' creators"
  }
}

/// Structured insight output
class WitnessInsight {
  final String category;        // 'invitation', 'notification', 'conversion', 'stakes'
  final String insight;         // Human-readable finding
  final double confidence;      // Statistical confidence
  final int sampleSize;
  final String recommendation;  // Actionable next step
  final Map<String, dynamic> data;  // Supporting data
}
```

### New RQs Generated

| RQ# | Question | Blocking |
|-----|----------|----------|
| **RQ-045** | What is the minimum data capture required to generate statistically significant witness insights? | PD-134 |
| **RQ-045a** | What engagement signals best predict witness conversion? | RQ-045 |
| **RQ-045b** | How do we balance data capture depth vs witness privacy/trust? | RQ-045 |

---

## Summary: New RQs and PDs

### New Product Decisions (PD)

| PD# | Decision | Status | Blocking RQ |
|-----|----------|--------|-------------|
| **PD-130** | Witness App Access Model | OPEN | RQ-041 |
| **PD-131** | Invitation Message Strategy | OPEN | RQ-042 |
| **PD-132** | Invitation Timing (Commitment Ceremony) | ✅ CONFIRMED | — |
| **PD-133** | Witness Stakes & Punishment Mechanics | OPEN | RQ-044 |
| **PD-134** | JITAI Witness Data Schema | OPEN | RQ-045 |

### New Research Questions (RQ)

| RQ# | Question | Status | Blocking |
|-----|----------|--------|----------|
| **RQ-041** | Optimal witness access tier progression | 🔴 NEEDS RESEARCH | PD-130 |
| **RQ-041a** | Engagement threshold for app install prompt | 🔴 NEEDS RESEARCH | RQ-041 |
| **RQ-041b** | PWA-first vs app-first conversion impact | 🔴 NEEDS RESEARCH | RQ-041 |
| **RQ-041c** | Data capture loss from PWA vs native | 🔴 NEEDS RESEARCH | RQ-041 |
| **RQ-042** | Invitation variant performance by relationship type | 🔴 NEEDS RESEARCH | PD-131 |
| **RQ-042a** | "Contract" framing burden perception | 🔴 NEEDS RESEARCH | RQ-042 |
| **RQ-042b** | Creator state effect on optimal message variant | 🔴 NEEDS RESEARCH | RQ-042 |
| **RQ-042c** | Optimal message length by channel | 🔴 NEEDS RESEARCH | RQ-042 |
| **RQ-042d** | Archetype name inclusion impact | 🔴 NEEDS RESEARCH | RQ-042 |
| **RQ-043** | Witness invitation skip rate at ceremony | 🔴 NEEDS RESEARCH | — |
| **RQ-043a** | "Invite Later" option impact | 🔴 NEEDS RESEARCH | RQ-043 |
| **RQ-043b** | Optimal witness count prompt at ceremony | 🔴 NEEDS RESEARCH | RQ-043 |
| **RQ-044** | Stakes mechanism effectiveness vs intrinsic motivation | 🔴 NEEDS RESEARCH | PD-133 |
| **RQ-044a** | Witness-visible failure impact on retention | 🔴 NEEDS RESEARCH | RQ-044 |
| **RQ-044b** | Financial escrow adoption rate | 🔴 NEEDS RESEARCH | RQ-044 |
| **RQ-044c** | Social stakes relationship damage risk | 🔴 NEEDS RESEARCH | RQ-044 |
| **RQ-044d** | Witness "forgiveness" grace period value | 🔴 NEEDS RESEARCH | RQ-044 |
| **RQ-045** | Minimum data capture for significant insights | 🔴 NEEDS RESEARCH | PD-134 |
| **RQ-045a** | Engagement signals predicting conversion | 🔴 NEEDS RESEARCH | RQ-045 |
| **RQ-045b** | Data capture vs privacy balance | 🔴 NEEDS RESEARCH | RQ-045 |

---

## Next Steps

1. **Create Deep Think prompt** for RQ-041 through RQ-045 (Witness Intelligence research)
2. **Update RQ_INDEX.md** with new RQs
3. **Update PD_INDEX.md** with new PDs
4. **A/B test framework** for invitation variants (requires implementation spec)
5. **Schema migration** for witness_engagement_events table

---

*This document defines the Witness Intelligence Layer (WIL) as an extension of JITAI, capturing granular data across the entire witness lifecycle to generate differentiated, high-impact insights.*
