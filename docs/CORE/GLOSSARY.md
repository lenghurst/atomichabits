# GLOSSARY.md — The Pact Terminology Bible

> **Last Updated:** 05 January 2026
> **Purpose:** Universal terminology definitions for AI agents and developers
> **Owner:** Product Team (update when new terms are introduced)

---

## Why This Document Exists

Multiple AI agents and developers work on this codebase. Inconsistent terminology leads to:
- Confusion in code (is it "habit" or "pact"?)
- Conflicting implementations
- User-facing inconsistency

**Rule:** When introducing new terminology, add it here FIRST.

---

## Core Product Terms

### Habit (Foundational Definition)

**Definition:** A single, repeatable action that builds toward an identity.

**Internal (Data Layer):**
```
Habit = {
  id: UUID,
  name: string,              // What the action is
  frequency: enum,           // Daily, Weekly, Custom
  identity_link: string,     // "I am a..."
  dimension_vector: float[6], // Which behavioral dimensions this reinforces
  evidence_count: int,       // Times completed
  streak: int,               // Consecutive completions (legacy)
  graceful_score: float      // Rolling consistency (preferred)
}
```

**External (UI Layer):**
- Presented as "daily actions that prove who you are"
- Never called "tasks" or "to-dos"
- Always linked to identity statement

**Identity Coach Role:**
- Recommends habits based on user's aspirational identity
- Detects habits misaligned with stated values
- Suggests habit additions/removals

---

### Ritual (Foundational Definition)

**Definition:** A sequence of habits performed together in a specific order, often time-anchored.

**Internal (Data Layer):**
```
Ritual = {
  id: UUID,
  name: string,              // "Morning Power Hour"
  habits: Habit[],           // Ordered list of habits
  anchor: TimeWindow,        // When this ritual occurs
  trigger: string,           // "After waking up"
  sequence_matters: bool,    // Order is important
  total_duration: int        // Minutes
}
```

**External (UI Layer):**
- Presented as "sacred routines" or "power sequences"
- Visual distinction from single habits (grouped, sequential)
- Progress shown as ritual completion, not individual habit ticks

**Key Distinction:**
| Aspect | Habit | Ritual |
|--------|-------|--------|
| Scope | Single action | Sequence of actions |
| Timing | Flexible within day | Time-anchored |
| Order | N/A | Matters |
| Examples | "Drink water" | "Morning routine: meditate → journal → exercise" |

**Identity Coach Role:**
- Suggests ritual templates based on user goals
- Detects broken ritual sequences
- Recommends ritual restructuring for consistency

---

### The Pact
**Definition:** The app's name and the commitment a user makes to become their target identity.

**Usage:**
- App name: "The Pact"
- User commitment: "Enter the Pact"
- NOT: "AtomicHabits", "Atomic Habits" (legacy branding — being deprecated)

**Code References:** Throughout UI, but legacy `atomichabits://` URL scheme still exists (pending deprecation).

---

### Identity Evidence
**Definition:** The atomic unit of the app. A single action that provides evidence of who the user is becoming.

**Philosophy:** We don't track "habits" — we collect "evidence" that proves the user is becoming their target identity.

**Example:** Completing a morning run isn't a "habit check" — it's evidence that "I am a runner."

**Code References:** `identity_seeds` table in Supabase, `EvidenceService`

---

### Holy Trinity
**Definition:** The three psychological traits extracted during Sherlock onboarding.

| Trait | Purpose | Timing |
|-------|---------|--------|
| **Anti-Identity** | The villain they fear becoming | Day 1 Activation |
| **Failure Archetype** | Why their past attempts died | Day 7 Conversion |
| **Resistance Lie** | The excuse they tell themselves | Day 30+ Retention |

**Code References:** `psychometric_profile.dart` lines 17-29

**Status:** UNDER REVIEW — may be too simplistic. See PRODUCT_DECISIONS.md.

---

### Archetype / Failure Archetype
**Definition:** A behavioural pattern that explains why users quit habits.

**Current Archetypes (Hardcoded):**
| ID | Display Name | Description |
|----|--------------|-------------|
| PERFECTIONIST | The Perfectionist | Aims for 100%, often quits after one mistake |
| REBEL | The Rebel | Resists expectations, needs to feel free |
| PROCRASTINATOR | The Procrastinator | Delays until the last moment, needs tiny starts |
| OVERTHINKER | The Overthinker | Paralyzed by analysis, needs clarity and permission |
| PLEASURE_SEEKER | The Pleasure Seeker | Follows dopamine, needs bundling and immediate rewards |
| PEOPLE_PLEASER | The People Pleaser | Motivated by others, needs witness accountability |

**Code References:** `archetype_registry.dart`, `archetype_evolution_service.dart`

**Status:** UNDER REVIEW — hardcoded approach may be too limiting. See PRODUCT_DECISIONS.md.

---

### Witness
**Definition:** An accountability partner who observes and supports the user's Pact.

**Current Implementation:**
- Human witness (invited via share link)
- AI witness (The Pact AI is always watching)

**Philosophy:** The Pact AI should be the DEFAULT witness. Human witness is ADDITIVE (for virality/referral).

**Code References:** `WitnessService`, `WitnessDeepLinkService`

**Status:** PENDING DECISION — "Go Solo" terminology being removed. See PRODUCT_DECISIONS.md.

---

## AI Personas

### Sherlock
**Definition:** The onboarding AI persona — an "Identity Architect" and "Parts Detective" inspired by IFS therapy.

**Role:** Extract the Holy Trinity through conversational deduction.

**Voice:** Curious, incisive, Sherlock Holmes-inspired.

**Code References:** `prompt_factory.dart:47-67`, `VoiceSessionType.sherlock`

**Status:** NEEDS OVERHAUL — current prompt is too simplistic. See PRODUCT_DECISIONS.md.

---

### Oracle
**Definition:** The "Future Self" AI persona — a vision of who the user is becoming.

**Role:** Guide users to visualize success, used post-onboarding.

**Voice:** Gravitas, hope, "Future Memory" language.

**Code References:** `prompt_factory.dart:69-87`, `VoiceSessionType.oracle`

---

### Tough Truths
**Definition:** The "Mirror" AI persona — stern accountability.

**Role:** Hold users accountable when they make excuses.

**Voice:** Stern, direct, stoic.

**Code References:** `prompt_factory.dart:89-107`, `VoiceSessionType.toughTruths`

---

### Puck
**Definition:** The default coaching persona — a Stoic accountability coach.

**Voice:** Deep, calm, punchy, British English.

**Code References:** `prompt_factory.dart:109-112`

---

## Technical Terms

### JITAI (Just-In-Time Adaptive Interventions)
**Definition:** The system that decides WHEN and HOW to intervene with notifications.

**Components:**
| Component | Purpose |
|-----------|---------|
| V-O Calculator | Calculates Vulnerability (risk of failure) and Opportunity (receptivity) |
| Thompson Sampling | Multi-armed bandit that learns which interventions work |
| Gottman Ratio | Maintains 5:1 positive-to-negative interaction ratio |
| Population Learning | Aggregates learnings across users with similar archetypes |

**Code References:** `jitai_decision_engine.dart`, `vulnerability_opportunity_calculator.dart`

**Status:** Partially hardcoded — needs documentation and review. See PRODUCT_DECISIONS.md.

---

### Thompson Sampling / Multi-Armed Bandit
**Definition:** A machine learning approach that balances exploration (trying new interventions) with exploitation (using what works).

**How It Works:**
1. Each intervention type is an "arm"
2. Success/failure updates probability distributions
3. Algorithm samples from distributions to choose next intervention
4. Over time, learns which interventions work for each user

**Code References:** `hierarchical_bandit.dart`, `jitai_decision_engine.dart:155-162`

---

### Gottman Ratio
**Definition:** A 5:1 ratio of positive to negative interactions, based on relationship research.

**Application:** JITAI gates "tough love" interventions — can only withdraw (challenge) if enough deposits (support) have been made.

**Code References:** `jitai_decision_engine.dart:1073-1106` (`GottmanTracker` class)

---

### V-O State (Vulnerability-Opportunity)
**Definition:** The calculated state that determines intervention strategy.

| Quadrant | Vulnerability | Opportunity | Action |
|----------|--------------|-------------|--------|
| Intervene Now | High | High | User at risk but receptive — intervene |
| Wait for Moment | High | Low | User at risk but unreceptive — defer |
| Light Touch | Low | High | User doing well, receptive — positive reinforcement |
| Silence | Low | Low | User fine, not receptive — stay silent |

**Code References:** `vulnerability_opportunity_calculator.dart:440-505`

---

### Context Snapshot
**Definition:** A point-in-time capture of all context signals used for JITAI decisions.

**Includes:**
- Time context (hour, day of week, weekend)
- Biometric context (sleep, HRV, stress)
- Calendar context (meetings, free windows)
- Digital context (screen time, app usage, emotions)
- Location context (home, gym, work)
- History context (streaks, recent misses)

**Code References:** `context_snapshot.dart`, `context_snapshot_builder.dart`

---

## Onboarding Terms

### Identity Access Gate
**Definition:** The first onboarding screen where users select their target identity.

**Current Implementation:** "Mad Libs" chip selector with preset identities.

**Default:** "A Morning Person" (anchoring bias)

**Code References:** `identity_access_gate_screen.dart`

---

### Sherlock Voice Session
**Definition:** The voice-based onboarding conversation where Sherlock extracts the Holy Trinity.

**Code References:** `VoiceCoachScreen` with `VoiceSessionType.sherlock`

---

### Loading Insights Screen
**Definition:** The screen shown while processing Sherlock data.

**Current State:** Generic spinner.

**Intended State:** Should show personalized insights from Holy Trinity + permissions data.

**Status:** Major UX gap. See PRODUCT_DECISIONS.md.

---

### Pact Reveal
**Definition:** The screen where the user's personalized Pact card is revealed.

**Code References:** `PactRevealScreen`, `PactIdentityCard`

---

## Legacy Terms (Being Deprecated)

### AtomicHabits / Atomic Habits
**Status:** DEPRECATED — app is now "The Pact"

**Action:** Remove all references to "atomichabits" from code and assets.

**Known Occurrences:**
- URL scheme: `atomichabits://` (needs migration to `thepact://`)
- Package name: `co.thepact.app` (already correct)

---

### Go Solo
**Status:** DEPRECATED — being replaced with AI Witness concept.

**Old Meaning:** User chooses not to invite a human witness.

**New Framing:** AI is ALWAYS the witness. Human witness is optional/additive.

---

### Streaks
**Status:** UNDER REVIEW — philosophical tension.

**Current Code:** Uses streak counts heavily (21/66/100 day milestones).

**Stated Philosophy:** "Streaks are vanity metrics. We measure rolling consistency."

**Resolution Needed:** See PRODUCT_DECISIONS.md.

---

## Terms Needing Definition

These terms appear in the codebase but need formal definition:

| Term | Context | Status |
|------|---------|--------|
| Hexis Score | Referenced in README, unclear calculation | NEEDS DEFINITION |
| Living Garden | Aspirational visualization feature | NOT IMPLEMENTED |
| Shadow Dialogue | "Talk to my Rebel" feature | NOT IMPLEMENTED |
| Power Words / Lexicon | Vocabulary builder feature | SPEC EXISTS, NOT IMPLEMENTED |
| Gap Analysis | DeepSeek-powered value-behavior analysis | PARTIALLY IMPLEMENTED |

---

## How to Add New Terms

1. **Before coding:** Add term to this glossary
2. **Include:** Definition, purpose, code references
3. **Flag status:** Is it implemented? Under review? Deprecated?
4. **Update:** PRODUCT_DECISIONS.md if decision needed
5. **Commit:** With message "docs: add [term] to glossary"
