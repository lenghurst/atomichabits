# Witness Decisions — Witness Intelligence Layer

> **Domain:** WITNESS
> **Token Budget:** <12k
> **Load:** When working on witness features, invitations, viral growth
> **Dependencies:** PD_CORE.md (always load first)
> **Related RQs:** RQ-040 through RQ-045

---

## Quick Reference

| PD# | Decision | Phase | Status | Blocking RQ |
|-----|----------|-------|--------|-------------|
| PD-130 | Witness App Access Model | A, D | OPEN | RQ-041 |
| PD-131 | Invitation Message Strategy | D | OPEN | RQ-042 |
| PD-132 | Invitation Timing (Commitment Ceremony) | D | CONFIRMED | — |
| PD-133 | Witness Stakes & Punishment | B, D | OPEN | RQ-044 |
| PD-134 | JITAI Witness Data Schema | A, B | OPEN | RQ-045 |

---

## Context: Witness Intelligence Layer (WIL)

The Witness Intelligence Layer extends JITAI to capture and adapt the **entire witness lifecycle**:
- What witnesses see (role-based narratives)
- When they're notified (timing optimization)
- How messages are framed (personalization)
- What actions they can take
- When/how they're prompted to convert
- What punishment/stakes mechanics are triggered

**Core Insight:** JITAI for witnesses uses REDUCED parameters (5-8 vs 20+ for creators) because witness needs are simpler.

**Full Specification:** See `WITNESS_INTELLIGENCE_LAYER.md`

---

## PD-130: Witness App Access Model

| Field | Value |
|-------|-------|
| **Phase** | A (Schema), D (UX) |
| **Question** | What level of app access should witnesses have? |
| **Status** | OPEN |
| **Blocking RQ** | RQ-041 (Witness App Access Tier Progression) |

### Options Under Consideration

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| **A: Notification-Only** | No app access, just notifications | Lowest friction | No engagement surface |
| **B: Web PWA** | Progressive web app (no install) | Low friction, cross-platform | Limited push capability |
| **C: Limited App** | Install app, restricted "witness view" | Full notifications | Install friction |
| **D: Full Preview** | Full app access before converting | Maximum exposure | May satisfy without converting |

### Recommended Model (Pending Validation)

**Tiered Access:**
1. **Stage 1 (Days 0-7):** Web PWA — magic link access, no install
2. **Stage 2 (Day 7+):** App invitation — triggered by engagement threshold
3. **Stage 3 (Milestone):** Conversion prompt — creator milestone + witness engagement

### Cross-Domain Impact

- **Schema (Phase A):** `access_token`, `lifecycle_state` fields
- **UX (Phase D):** Witness landing page, invitation flow

---

## PD-132: Invitation Timing — Commitment Ceremony ✅ CONFIRMED

| Field | Value |
|-------|-------|
| **Phase** | D |
| **Decision** | Prompt witness invitation immediately after digital pact signing |
| **Status** | CONFIRMED |
| **Copy** | "A Pact is only binding if witnessed. Appoint your Council." |

### Rationale

| Factor | Why This Works |
|--------|----------------|
| **Peak Commitment** | User just made commitment — psychological momentum highest |
| **Ceremony Completion** | Witness appointment "seals" the pact |
| **Narrative Coherence** | "Council" matches Parliament of Selves framing |
| **JITAI Alignment** | Peak Opportunity, low Vulnerability |

### Ceremony Flow

```
STEP 1: Identity Declaration
  "I am becoming [The Writer / The Athlete]"

STEP 2: Shadow Acknowledgment
  "I recognize my [Procrastinator / Perfectionist]"

STEP 3: Pact Signing
  [Digital signature / thumbprint animation]

STEP 4: Council Appointment ◄── WITNESS INVITATION TRIGGER
  "A Pact is only binding if witnessed. Appoint your Council."
  [Select 1-3 witnesses from contacts]

STEP 5: Pact Activation
  "Your Pact is now active. Day 1 begins."
```

---

## PD-131: Invitation Message Strategy

| Field | Value |
|-------|-------|
| **Phase** | D |
| **Question** | Which invitation message variants to A/B test? |
| **Status** | OPEN |
| **Blocking RQ** | RQ-042 (Invitation Variant Performance) |

### Confirmed Variants for Testing

| Variant | Message | Psychological Lever |
|---------|---------|---------------------|
| **A: Vulnerability** | "Hey [Name], I'm trying to become 'The Writer' but I keep self-sabotaging. I need a witness to keep me honest. You don't need to do anything but watch. [Link]" | Authenticity, low-ask |
| **B: The Contract** | "I've signed a Pact to defeat my 'Procrastinator' archetype. I need a witness to seal the contract. Can you sign for me? [Link]" | Ceremony, commitment device |
| **C: The Story** | "Hey [Name], remember when I said I wanted to [goal]? I finally started. Can you help me not give up? [Link]" | Shared history, narrative |
| **D: The Confidant** | "I'm fighting my inner Saboteur. I need someone who can see the real battle. Will you be my witness? [Link]" | Exclusive access, intimacy |

### Open Questions (RQ-042)

- Which variant performs best by relationship type?
- Does "Contract" framing increase perceived burden?
- Does archetype name inclusion help or hurt?

---

## PD-133: Witness Stakes & Punishment Mechanics

| Field | Value |
|-------|-------|
| **Phase** | B (Backend), D (UX) |
| **Question** | What punishment/stakes mechanics should witnesses trigger? |
| **Status** | OPEN |
| **Blocking RQ** | RQ-044 (Stakes vs Intrinsic Motivation) |

### Options Under Consideration

| Option | Mechanism | Witness Role | Risk |
|--------|-----------|--------------|------|
| **A: Visibility Only** | Witness sees failures | Passive accountability | Feels like surveillance |
| **B: Soft Stakes** | Creator sets personal stakes | Witness observes fulfillment | Low friction |
| **C: Escrow Stakes** | Real money in escrow | Witness confirms failure | High friction |
| **D: Social Stakes** | Auto-post failure | Witness receives failure notification | Relationship damage |
| **E: Witness Challenges** | Witnesses set mini-challenges | Active engagement | Complexity |

### CD-010 Constraint

**NO DARK PATTERNS.** Stakes must:
- Be user-initiated (not forced)
- Be transparent (witness knows their role)
- Support user success (not app engagement)
- Not damage relationships

### Open Questions (RQ-044)

- Does witness-visible failure increase or decrease retention?
- What % of users would use financial escrow?
- Should witnesses have power to "forgive" failures?

---

## PD-134: JITAI Witness Data Schema

| Field | Value |
|-------|-------|
| **Phase** | A (Schema), B (Backend) |
| **Question** | What granular data must WIL capture for differentiated insights? |
| **Status** | OPEN |
| **Blocking RQ** | RQ-045 (Minimum Data Capture for Insights) |

### Proposed Schema

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

-- Event types:
-- invitation_sent, invitation_opened, invitation_clicked
-- page_viewed, app_installed, notification_received
-- notification_opened, notification_dismissed
-- encouragement_sent, challenge_set
-- creator_progress_viewed
-- conversion_prompt_shown, conversion_prompt_clicked
-- converted_to_creator, churned
```

### Context Captured

```json
{
  "time_of_day": "morning|afternoon|evening|night",
  "day_of_week": "monday|...|sunday",
  "creator_streak": 7,
  "witness_engagement_score": 0.75,
  "witness_role_type": "confidant|cheerleader|mentor",
  "relationship_strength": "close|casual|unknown",
  "days_since_invitation": 14,
  "invitation_variant": "A|B|C|D"
}
```

### Cross-Domain Impact

- **JITAI Domain:** Extends JITAI context model
- **Privacy:** Must balance capture depth vs trust

---

## Witness Role Types

Based on "The Confidant" model from Deep Think research:

| Role | Sees | Actions | Narrative Style |
|------|------|---------|-----------------|
| **Confidant** | Inner battles, struggles, wins | Send encouragement | "I see the real battle" |
| **Cheerleader** | Wins only, milestones | Celebrate | Positive moments only |
| **Mentor** | Struggles + progress | Send challenges, guidance | Can offer direction |

### Role Permissions

```dart
class WitnessPermissions {
  bool canSeeFacetBattles;  // Only Confidant
  bool canSeeStruggles;     // Confidant + Mentor
  bool canSeeCompletions;   // All
  bool canSeeMilestones;    // All
  bool canSendEncouragement; // All
  bool canSendChallenges;   // Only Mentor
}
```

---

## Related Research Questions

| RQ# | Title | Status | Blocks |
|-----|-------|--------|--------|
| RQ-040 | Viral Witness Growth Strategy | NEEDS RESEARCH | — |
| RQ-040a-g | Sub-questions (7) | NEEDS RESEARCH | RQ-040 |
| RQ-041 | Witness App Access Tiers | NEEDS RESEARCH | PD-130 |
| RQ-042 | Invitation Variant Performance | NEEDS RESEARCH | PD-131 |
| RQ-043 | Ceremony Skip Rate | NEEDS RESEARCH | — |
| RQ-044 | Stakes vs Intrinsic Motivation | NEEDS RESEARCH | PD-133 |
| RQ-045 | Witness Data Capture | NEEDS RESEARCH | PD-134 |

---

*Witness decisions define how "The Pact" creates viral growth through authentic accountability relationships.*
