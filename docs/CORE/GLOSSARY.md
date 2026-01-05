# GLOSSARY.md — The Pact Terminology Bible

> **Last Updated:** 05 January 2026 (Added PGS hierarchy, Behavioral Dimensions, Ghost Term Policy)
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

### Habit vs Ritual: Design Decision Required

| Question | Current State | Options | Recommendation |
|----------|---------------|---------|----------------|
| Are they separate entities? | Undefined in code | (A) Separate models, (B) Ritual is habit container | **B** — Ritual contains ordered habits |
| Should UI use both terms? | "Habit" only | (A) Both, (B) Rename to "Rituals" | **NEEDS RESEARCH** — User testing required |
| How does data model relate? | Habit model exists, Ritual doesn't | Build Ritual as wrapper | Add to Track G (Identity Coach) |

**Status:** 🟡 DEFERRED — Contingent on broader architecture decisions

**Why Deferred:**
This decision is part of a wider discussion that includes:
- Dashboard architecture (what views exist)
- What we track (habits, rituals, or both)
- How we track (metrics, scoring, streaks vs consistency)
- How we recommend (content library, recommendation engine, JITAI integration)

These interconnected decisions must be made together. See:
- RQ-005: Proactive Recommendation Algorithms
- RQ-006: Content Library for Recommendations
- RQ-007: Identity Roadmap Architecture

**Proposed Relationship (Pending Validation):**
```
Ritual (Container)
├── Habit 1 (sequence: 1)
├── Habit 2 (sequence: 2)
└── Habit 3 (sequence: 3)

A Habit can exist:
- Standalone (not part of any Ritual)
- Within one or more Rituals
```

**Why This Matters:**
- If Habits and Rituals are separate, we need two recommendation systems
- If Rituals contain Habits, recommendations are unified
- User mental model affects onboarding and dashboard design

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

**Architecture (CD-005 Decision):**
- **Backend:** 6-dimension continuous model (float vector)
- **UI:** 4 simplified clusters for user identification
- **Status:** Research complete, implementation pending

**The 6 Behavioral Dimensions (Backend):**
| # | Dimension | Continuum | What It Predicts |
|---|-----------|-----------|------------------|
| 1 | Regulatory Focus | Promotion ↔ Prevention | Identity Evidence framing |
| 2 | Autonomy/Reactance | Rebel ↔ Conformist | Anti-Identity risk |
| 3 | Action-State Orientation | Executor ↔ Overthinker | Rumination patterns |
| 4 | Temporal Discounting | Future ↔ Present | Streak value perception |
| 5 | Perfectionistic Reactivity | Adaptive ↔ Maladaptive | Failure Archetype risk |
| 6 | Social Rhythmicity | Stable ↔ Chaotic | Schedule normalization |

**The 4 UI Clusters:**
| Cluster | Maps From | Intervention Strategy |
|---------|-----------|----------------------|
| The Defiant Rebel | REBEL | Autonomy-Supportive ("You decide when") |
| The Anxious Perfectionist | PERFECTIONIST | Self-Compassion ("A missed day is part of the process") |
| The Paralyzed Procrastinator | PROCRASTINATOR + OVERTHINKER | Value Affirmation ("Remember why you started") |
| The Chaotic Discounter | PLEASURE_SEEKER | Micro-Steps ("Just put on your shoes") |

**Legacy Archetypes (Still in Code — Pending Migration):**
| ID | Display Name | Status |
|----|--------------|--------|
| PERFECTIONIST | The Perfectionist | → Maps to Anxious Perfectionist |
| REBEL | The Rebel | → Maps to Defiant Rebel |
| PROCRASTINATOR | The Procrastinator | → Maps to Paralyzed Procrastinator |
| OVERTHINKER | The Overthinker | → Maps to Paralyzed Procrastinator |
| PLEASURE_SEEKER | The Pleasure Seeker | → Maps to Chaotic Discounter |
| PEOPLE_PLEASER | The People Pleaser | 🟡 CONTINGENT — Awaiting 7th dimension (CD-007) |

**Code References:** `archetype_registry.dart`, `archetype_evolution_service.dart`

**Open Question:** Should users see their full 6-dimensional profile, or only the 4 simplified clusters? (Potential PD to create)

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
**Definition:** Legacy name for coaching persona — being consolidated to Sherlock.

**Status:** 🔴 DEPRECATED — Consolidate to "Sherlock"

**Issue:** Two conflicting prompts exist:
- `ai_prompts.dart:717-745` — Calls AI "Puck"
- `prompt_factory.dart:47-67` — Calls AI "Sherlock"

**Resolution:** Use "Sherlock" as canonical name. Puck references should be migrated.

**Note:** Final persona naming may change once app direction is firmer.

**Code References:** `prompt_factory.dart:109-112` (to be updated)

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

### Proactive Guidance System (PGS)
**Definition:** The umbrella system that orchestrates all coaching intelligence.

**Status:** 🔴 ARCHITECTURE PENDING — See PD-107

**Hierarchy:**
```
PROACTIVE GUIDANCE SYSTEM (umbrella)
├── Aspiration Extraction (via Sherlock)
│   └── Captures: Holy Trinity + Aspirational Identities
│
├── Guidance Content (renamed from "Content Library")
│   ├── Habit recommendation templates
│   ├── Ritual templates
│   ├── Intervention messages (4 variants per archetype)
│   └── Coaching insights
│
├── Gap Analysis Engine
│   ├── Detects value-behavior dissonance
│   └── Generates Socratic questions
│
├── Recommendation Engine
│   ├── What habits/rituals to suggest
│   └── Based on aspirational identity + gaps
│
└── JITAI (timing component)
    ├── When to deliver (V-O calculation)
    ├── How to deliver (channel selection)
    └── Learning (Thompson Sampling)
```

**Key Insight:** JITAI is ONE COMPONENT of PGS, not a separate system. JITAI handles timing. Recommendation Engine handles content selection. Gap Analysis feeds both.

**Related Terms:**
- **Identity-First Design** — The philosophy (optimize for identity evidence, not task completion)
- **Proactive Guidance System** — The implementation (the system that delivers on the philosophy)

**Code References:** Not yet implemented as unified system. Components exist separately.

---

### Behavioral Dimensions (6-Dimension Model)
**Definition:** The six psychological dimensions used to personalize interventions.

**Status:** ✅ CONFIRMED — See CD-005

**The 6 Dimensions:**

| # | Dimension | Continuum | What It Predicts |
|---|-----------|-----------|------------------|
| 1 | **Regulatory Focus** | Promotion ↔ Prevention | How to frame identity evidence |
| 2 | **Autonomy/Reactance** | Rebel ↔ Conformist | Intervention style (autonomy-supportive vs directive) |
| 3 | **Action-State Orientation** | Executor ↔ Overthinker | Rumination risk, decision paralysis |
| 4 | **Temporal Discounting** | Future ↔ Present | Streak value, micro-reward effectiveness |
| 5 | **Perfectionistic Reactivity** | Adaptive ↔ Maladaptive | Failure response, shame spiral risk |
| 6 | **Social Rhythmicity** | Stable ↔ Chaotic | Schedule normalization, timing strategy |

**Detailed Definitions:**

#### Regulatory Focus
Whether a person is motivated by pursuing gains (Promotion) or avoiding losses (Prevention).
- **Promotion:** Eager, growth-oriented, excited by possibilities → "Imagine becoming..."
- **Prevention:** Vigilant, security-oriented, fears regression → "Don't let yourself slide back..."

#### Autonomy/Reactance
How much a person resists being told what to do.
- **Rebel (High Reactance):** Resists external pressure → "You decide when" (autonomy-supportive)
- **Conformist (Low Reactance):** Welcomes guidance → "Here's what to do" (directive)

#### Action-State Orientation
Whether someone acts immediately or ruminates before acting.
- **Executor:** Acts quickly, doesn't overthink → Simple prompts work
- **Overthinker:** Ruminates, gets stuck in analysis paralysis → Value affirmation ("Remember why")

#### Temporal Discounting
How much someone devalues future rewards relative to immediate ones.
- **Future-Oriented:** Cares about long-term outcomes → Streak milestones motivating
- **Present-Oriented:** Wants immediate gratification → Micro-rewards ("Just 2 minutes")

#### Perfectionistic Reactivity
How someone responds to failure/imperfection.
- **Adaptive:** Uses failure as learning, bounces back → Standard messaging fine
- **Maladaptive:** Failure triggers shame spiral, gives up → Self-compassion messaging critical

#### Social Rhythmicity
How stable/predictable a person's daily schedule is.
- **Stable:** Consistent routines, predictable day → Time-specific reminders work
- **Chaotic:** Variable schedule, unpredictable day → Context-based triggers better

**Code References:** `archetype_registry.dart`, dimension vectors in `psychometric_profile.dart`

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

**Current State:** Generic spinner with generic (non-personalized) insights. Shows animated insight cards cycling through categories (context, intent, baseline, population).

**Future Sprint Required:** Personalize insights based on:
- Holy Trinity data from Sherlock
- User permissions data
- Behavioral dimensions

**Code References:** `loading_insights_screen.dart:1-427`, `onboarding_insights_service.dart`

**Status:** Functional but not personalized. Future sprint needed.

---

### Pact Reveal
**Definition:** The screen where the user's personalized Pact card is revealed.

**Code References:** `PactRevealScreen`, `PactIdentityCard`

---

## Dashboard Terms

### Binary Interface
**Definition:** The two-state dashboard toggle between "Doing" (action) and "Being" (identity).

**Current Implementation:** ✅ IMPLEMENTED in Phase 67

**Components:**
- `identity_dashboard.dart` — Container with toggle
- `the_bridge.dart` — "Doing" state
- `skill_tree.dart` — "Being" state

**Status:** 🟡 Implemented but needs concrete definition within broader dashboard/recommendation architecture. See RQ-005, RQ-006, RQ-007.

---

### The Bridge (Doing State)
**Definition:** Context-aware action deck with JITAI-powered habit sorting.

**Features:**
- Habits sorted by V-O scoring, cascade risk, timing
- Glass morphism card design with priority indicators
- "NOW" badge for highest priority habit
- Quick completion (full or tiny version)
- Identity votes counter per habit

**Code References:** `the_bridge.dart:24-38`

**Status:** 🟡 Implemented but definition may evolve with dashboard architecture decisions.

---

### Skill Tree (Being State)
**Definition:** Custom-painted tree visualization of identity growth.

**Features:**
- Multi-part structure: Root (foundation) → Trunk (primary habit) → Branches (related habits) → Leaves (decorative)
- Health scoring: Green (strong) → Yellow → Orange → Red (at risk)
- Stats overlay showing votes, streak, completions

**Code References:** `skill_tree.dart:18-32`

**Status:** 🟡 Implemented but definition may evolve with dashboard architecture decisions.

---

### Identity Score vs Identity Evidence
**Definition Clarification:**

| Term | Meaning | Type |
|------|---------|------|
| **Identity Evidence** | A single action proving identity (philosophical unit) | Concept |
| **Identity Score** | Composite score calculated from evidence + other factors | Metric |

**Relationship:** Identity Score is likely composed of:
- Identity Evidence (primary input)
- Consistency metrics
- Dimension-specific adjustments
- Possibly Hexis Score (if implemented)

**Status:** 🟡 Relationship needs clarification once JITAI Engine, Content Library, and Recommendation Engine architecture is finalized.

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

## Terms Contingent on Product Decisions

These terms appear in documentation but are either not implemented or require product/research decisions before implementation.

### Hexis Score
**Definition:** Proposed composite score for identity visualization.

**Status:** 🔴 DEPRECATED — Never concretely defined or implemented

**Original Intent (from ARCHITECTURE_RECONCILIATION.md):**
```
Base score from habit completions
- Doom scrolling penalty (−0.05 per session)
+ Positive emotion boost (+0.1 for confidence)
= Hexis Score (0.0 - 1.0)
```

**Why Deprecated:**
- `hexis_calculator.dart` was never built
- No concrete specification existed beyond the above formula
- Dependencies (Living Garden, Digital Truth Sensor) also not implemented
- Term created confusion without adding value

**Replacement:** Consider using existing `gracefulScore` or `difficultyLevel` fields if a composite identity metric is needed in future.

---

### Living Garden
**Definition:** Aspirational Rive-animated ecosystem visualization representing identity growth.

**Planned Features:**
- `garden_ecosystem` Rive state machine
- Inputs: hexis_score, shadow_presence, season
- Weather effects based on emotional state
- "Wilts" during doom scrolling, "glows" during positive emotion

**Status:** ❌ NOT IMPLEMENTED — Layer 3 in ROADMAP.md

**Current Replacement:** Skill Tree (custom-painted, not animated)

---

### Shadow Presence
**Definition:** A proposed real-time metric measuring how "active" a user's shadow/resistance patterns are at any given moment.

**Status:** ❌ NOT IMPLEMENTED — Contingent on Living Garden (Layer 3)

**Original Intent (from product discussions):**
Shadow Presence was conceived as the "darkness" input to the Living Garden visualization:
- **High Shadow Presence:** User is in self-sabotage mode (doom scrolling, avoidance, excuse-making)
- **Low Shadow Presence:** User is aligned with identity goals, shadow dormant
- **Visual Effect:** Garden would "darken" or show "wilting" when Shadow Presence is high

**Measurement Approach (Theoretical):**
```
Shadow Presence = f(
  doom_scrolling_detected,      // Digital Truth Sensor
  missed_habits_today,          // Habit completion
  time_since_last_evidence,     // Engagement gap
  negative_self_talk_detected,  // Voice session analysis
  excuse_patterns_matched       // Resistance Lie activation
)
```

**Relationship to Other Concepts:**
| Concept | Relationship |
|---------|--------------|
| Failure Archetype | Shadow patterns vary by archetype (Perfectionist's shadow = harsh self-criticism) |
| Resistance Lie | High Shadow Presence often correlates with Resistance Lie activation |
| JITAI | Could inform Vulnerability score — high Shadow Presence = high Vulnerability |
| Hexis Score | Was intended to be inverse of Shadow Presence |

**Why Not Implemented:**
- Living Garden (Layer 3) not built — Shadow Presence had no consumer
- Detection logic requires Digital Truth Sensor maturity
- Philosophy needs validation: Is "shadow" the right frame, or does it pathologize normal resistance?

**Future Consideration:** If Living Garden or equivalent visualization is built, Shadow Presence should be reconsidered. May integrate with JITAI Vulnerability scoring instead of being a separate metric.

---

### Shadow Dialogue
**Definition:** "Talk to my [Rebel/Perfectionist] part" feature — conversational interaction with user's shadow archetypes.

**Status:** ❌ NOT IMPLEMENTED — Referenced in ROADMAP Layer 2

**Concept:** IFS-inspired dialogue where user can converse directly with identified protector parts.

---

### Gap Analysis Engine
**Definition:** DeepSeek-powered analysis detecting dissonance between stated values and actual behavior.

**Status:** 🟡 PARTIALLY IMPLEMENTED — DeepSeek pipeline exists but `GapAnalysisEngine` class does not

**Priority:** 🔴 HIGH — Core to app value proposition

**Current State:**
- DeepSeek integration exists for post-session analysis
- Full gap analysis logic not yet built
- Referenced in ROADMAP Layer 5

**Why This Is Architecturally Critical:**
The Gap Analysis Engine speaks to fundamental questions about how the app operates:
1. **Insight Generation:** How does the app generate meaningful insights from user data?
2. **Surfacing:** How are insights surfaced to users (push vs pull)?
3. **JITAI Integration:** Should gap insights trigger JITAI interventions?
4. **Governance:** What rules govern when DeepSeek is called (cost, privacy, timing)?

**Architectural Questions to Resolve:**
| Question | Options | Status |
|----------|---------|--------|
| When is DeepSeek called? | Real-time vs batch vs on-demand | PENDING |
| What data does it analyze? | Session transcripts, habit data, both | PENDING |
| How are insights stored? | Local, cloud, ephemeral | PENDING |
| How do insights reach users? | Notification, dashboard widget, voice summary | PENDING |
| Cost management? | Credit system, rate limiting, caching | PENDING |

**Note:** DeepSeek is intended to be a substantive part of the app experience. Current partial implementation (post-session only) is insufficient for the vision.

**Action Required:** Add to existing PD or create new one to prioritize Gap Analysis Engine completion alongside JITAI/Recommendation architecture decisions.

---

### Power Words / Lexicon
**Definition:** Vocabulary builder where users collect "Power Words" that reinforce their identity.

**Status:** ❌ NOT IMPLEMENTED — Spec exists in archive (LEXICON_SPEC.md)

**Example:** User identifies as "Stoic" → collects words like "Antifragile", "Equanimity"

---

## Terms Needing Research

| Term | Question | Depends On |
|------|----------|------------|
| Season | Time-based context for Living Garden — what defines "seasons"? | Living Garden design |
| Cascade Risk | Currently implemented but threshold (0.6) may need tuning | JITAI research |
| Doom Scrolling | Detection logic partially implemented — is it accurate enough? | Digital Truth Sensor |

---

## How to Add New Terms

1. **Before coding:** Add term to this glossary
2. **Include:** Definition, purpose, code references
3. **Flag status:** Is it implemented? Under review? Deprecated?
4. **Update:** PRODUCT_DECISIONS.md if decision needed
5. **Commit:** With message "docs: add [term] to glossary"

---

## Ghost Term Policy

**Problem:** Terms added to documentation without implementation create confusion ("ghost terms").

**Rule:** For aspirational terms (not yet implemented):

| Requirement | Reason |
|-------------|--------|
| Mark as ❌ NOT IMPLEMENTED | Clarity on current state |
| Reference blocking PD or RQ | Accountability |
| If no PD/RQ exists → Create one first | Forces discipline |
| Include "Why Not Implemented" | Context for future |

**Good Example:**
```markdown
### Living Garden
**Status:** ❌ NOT IMPLEMENTED — Layer 3 in ROADMAP.md
**Blocking:** RQ-007 (Identity Roadmap Architecture)
**Why Not Implemented:** Depends on visualization philosophy decisions
```

**Bad Example (Ghost Term):**
```markdown
### Hexis Score
**Definition:** A composite score...
(No status, no blocking reference, no accountability)
```

**Enforcement:** During GLOSSARY reviews, identify and either:
1. Add blocking reference (RQ/PD) if term has value
2. Deprecate if term has no clear path to implementation

---

## Signposting Guidance

**Purpose:** When to reference this GLOSSARY from other documents.

**Rule:** Document this practice in all Core docs that use specialized terms.

**When to Signpost:**
| Scenario | Action |
|----------|--------|
| First use of critical term in a document | "(see GLOSSARY.md: Term Name)" |
| Term has specific technical meaning | "JITAI (GLOSSARY)" |
| Term has changed meaning | "Note: Identity Coach now refers to..." |

**When NOT to Signpost:**
- Every occurrence of a term
- Obvious terms used in their normal sense
- Terms in their document of origin (GLOSSARY itself)

**Example:**
> The Proactive Guidance System (see GLOSSARY.md) orchestrates all coaching intelligence, with JITAI handling timing decisions.

**For AI Agents:** When writing documentation, signpost on first use of terms defined in GLOSSARY.md. This ensures consistent understanding across sessions and developers.
