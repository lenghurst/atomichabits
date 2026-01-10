# Deep Think Prompt: psyOS UX Phase — Constellation & Airlock

> **Target Research:** RQ-017, RQ-018
> **Related Decisions:** PD-108, PD-110, PD-112
> **Prepared:** 10 January 2026
> **For:** Google Deep Think / Claude / External AI Tool
> **App Name:** The Pact

---

## Your Role

You are a **Senior UX Architect & Behavioral Systems Designer** specializing in:
- Data visualization for psychological systems (identity models, energy states)
- Gamification and motivational design (progress feedback, state awareness)
- Mobile animation and interaction design (Flutter, Rive, Lottie)
- Behavioral priming and state transition psychology
- Sensory design (audio cues, haptic feedback, visual triggers)

Your approach:
1. Think step-by-step. Reason through each sub-question methodically.
2. **Present 2-3 options with explicit tradeoffs** before recommending.
3. **Cite 2-3 academic papers** where applicable (behavior change, visualization, sensory priming).
4. Rate each recommendation with confidence levels (HIGH/MEDIUM/LOW).
5. Classify each proposal per CD-018: ESSENTIAL/VALUABLE/NICE-TO-HAVE/OVER-ENGINEERED.

---

## Critical Instruction: Processing Order

```
RQ-017 (Constellation UX — Solar System Visualization)
  ↓ Defines the visual model for...
RQ-018 (Airlock Protocol & Identity Priming)
  ↓ Uses Constellation as visual anchor for...
PD-108 (Constellation UX Migration Strategy)
PD-110 (Airlock Protocol User Control)
PD-112 (Identity Priming Audio Strategy)
```

**Why This Order Matters:**
- RQ-017 defines the visual metaphor → RQ-018 uses it for state transition feedback
- Constellation shows "where you are" → Airlock guides "how to transition"
- Both inform the notification/intervention visual language

---

## MANDATORY: Android-First Data Reality Audit

**CRITICAL CONSTRAINT (CD-017):** All designs must work on Android with these available signals only:

| Data Point | Android API | Permission | Battery | Available? |
|------------|-------------|------------|---------|------------|
| `foregroundApp` | UsageStatsManager | PACKAGE_USAGE_STATS | Low | YES |
| `screenOnDuration` | UsageStatsManager | PACKAGE_USAGE_STATS | Low | YES |
| `stepsLast30Min` | Google Fit / Health Connect | Health Connect | Low | YES |
| `locationZone` | Geofencing API | ACCESS_FINE_LOCATION | Medium | YES |
| `calendarEvents` | CalendarContract | READ_CALENDAR | Low | YES |
| `timeOfDay` | System | None | None | YES |
| `dayOfWeek` | System | None | None | YES |

**Anti-Patterns:**
- ❌ Do NOT require continuous location tracking (battery drain)
- ❌ Do NOT require wearable-only data (HRV, stress levels)
- ❌ Do NOT design animations that exceed 16ms frame budget

---

## Architectural Constraints (Hard Requirements)

| Constraint | Rule | Rationale |
|------------|------|-----------|
| **Animation Framework** | Flutter + optional Rive/Lottie | Existing stack |
| **Energy Model** | 4 states ONLY (CD-015) | high_focus, high_physical, social, recovery |
| **Max Facets** | 7 facets per user (soft limit) | Cognitive load |
| **Active Facets** | Max 3 active for new users | Progressive disclosure |
| **Battery Budget** | < 5% daily from animations | Mobile constraint |
| **Audio Format** | MP3/OGG, < 500KB total | Asset size constraint |
| **Haptic Patterns** | Android VibrationEffect API | No iOS-specific patterns |
| **Transition Time** | Airlock: 5 seconds to 5 minutes | User configurable |

---

## Mandatory Context: Locked Architecture

### CD-015: psyOS Architecture (4-State Energy Model)
```
high_focus   ←→ high_physical
    ↑              ↑
    ↓              ↓
  social     ←→  recovery
```

**State Definitions:**
| State | Description | Example Context |
|-------|-------------|-----------------|
| `high_focus` | Deep cognitive work | Coding, writing, studying |
| `high_physical` | Active movement | Gym, sports, walking |
| `social` | Interpersonal engagement | Family dinner, meetings |
| `recovery` | Rest and restoration | Sleep, meditation, leisure |

**Dangerous Transitions (High Friction):**
| From | To | Why Dangerous |
|------|-----|---------------|
| `high_focus` | `social` | Cognitive residue → distracted presence |
| `high_physical` | `high_focus` | Elevated cortisol → poor concentration |
| `social` | `high_focus` | Emotional carryover → rumination |

### RQ-012: Fractal Trinity Architecture ✅ COMPLETE
- **Root Psychology:** 3 immutable traits (Anti-Identity, Failure Archetype, Resistance Lie)
- **Manifestations:** Context-specific expressions per facet
- **Triangulation Protocol:** Days 1-7 extraction via Sherlock
- **Schema:** `identity_facets`, `facet_manifestations`, `habit_facet_links`

### RQ-016: Council AI ✅ COMPLETE
- **Activation:** tension_score > 0.7 OR Summon Token
- **Turn Limit:** 6 turns per session
- **Voice Mode:** Single narrator (Audiobook Pattern)
- **Output:** script[] + proposed_treaty

### CD-005: 6-Dimension Archetype Model
User profiles include a 6-float vector:
1. Regulatory Focus (Promotion ↔ Prevention)
2. Autonomy/Reactance (Rebel ↔ Conformist)
3. Action-State Orientation (Executor ↔ Overthinker)
4. Temporal Discounting (Future ↔ Present)
5. Perfectionistic Reactivity (Adaptive ↔ Maladaptive)
6. Social Rhythmicity (Stable ↔ Chaotic)

### RQ-013: Identity Topology & Graph Modeling ✅ COMPLETE
- **Schema:** `identity_topology` table with facet-to-facet edges
- **Interaction Types:** synergistic, antagonistic, competitive, neutral
- **Friction Coefficient:** 0.0 to 1.0 (higher = more conflict)
- **Council Trigger:** `(tensionScore × 0.6) + (frictionCoefficient × 0.4) > 0.75`

```sql
CREATE TABLE identity_topology (
  source_facet_id UUID REFERENCES identity_facets(id),
  target_facet_id UUID REFERENCES identity_facets(id),
  interaction_type TEXT CHECK (interaction_type IN ('synergistic', 'antagonistic', 'competitive', 'neutral')),
  friction_coefficient FLOAT DEFAULT 0.5,
  switching_cost_minutes INT,
  PRIMARY KEY (source_facet_id, target_facet_id)
);
```

### RQ-014: State Economics & Bio-Energetic Conflicts ✅ COMPLETE
- **Switching Cost Matrix (4×4):** Minutes required for clean transition

| From ↓ / To → | high_focus | high_physical | social | recovery |
|---------------|------------|---------------|--------|----------|
| **high_focus** | 0 | 45 | **60** ⚠️ | 20 |
| **high_physical** | 0 (Boost) | 0 | 15 | 5 |
| **social** | **50** ⚠️ | 15 | 0 | 10 |
| **recovery** | 15 | 10 | 10 | 0 |

- **3 Dangerous Transitions:**
  1. `high_focus → social` (60 min) — "Pirate to Parent"
  2. `social → high_focus` (50 min) — "Parent to Pirate"
  3. `high_focus → high_physical` (45 min) — Cognitive to Physical

### RQ-015: Polymorphic Habits ✅ COMPLETE
- **Waterfall Attribution:** Same habit counts differently per facet
- **Attribution Logic:** System assigns based on active facet at completion time
- **10% Shadow Bonus:** Multi-facet habits get slight boost
- **Constellation Impact:** Planet size includes only habits attributed to that facet

### RQ-020: Treaty-JITAI Integration ✅ COMPLETE
- **Pipeline Position:** Stage 3 (Post-Safety, Pre-Optimization)
- **Parser:** json_logic_dart for condition evaluation
- **Breach Tracking:** 3 breaches in 7 days → Probation → Auto-Suspend

### RQ-032: Identity Consolidation Score (ICS) ✅ COMPLETE
- **Formula:** `ICS = AvgConsistency × log10(TotalVotes + 1)`
- **Range:** 0.0 to ~5.0 (logarithmic prevents runaway)
- **Visual Tiers:** Seed (< 1.2), Sapling (< 3.0), Oak (≥ 3.0)
- **Usage:** Drives "integrationScore" for Constellation orbit distance

---

## Current Implementation Reference

### The Bridge (Current "Doing" State)
```dart
// lib/features/dashboard/widgets/the_bridge.dart
class TheBridge extends StatefulWidget {
  // Context-aware action deck with JITAI-powered priority sorting
  // Glass morphism cards, cascade risk warnings
  // "NOW" badge for highest priority habit
}
```

### Skill Tree (Current "Being" State — TO BE REPLACED)
```dart
// lib/features/dashboard/widgets/skill_tree.dart
class SkillTree extends StatefulWidget {
  // Custom-painted living tree visualization
  // Root (foundation) → Trunk → Branches → Leaves
  // Health scoring: Green → Yellow → Orange → Red
}
```

**Current Dashboard Toggle:**
```
┌─────────────────────────────────────┐
│  [ DOING ]  ←→  [ BEING ]          │
│  The Bridge      Skill Tree         │
│  (Action Deck)   (→ Constellation)  │
└─────────────────────────────────────┘
```

---

## Research Question 1: RQ-017 — Constellation UX (Solar System Visualization)

### Core Question
How should the dashboard visualize identity facets as a living solar system?

### Why This Matters
- **Core Visual Identity:** This IS the psyOS brand — "Parliament of Selves" made visible
- **Blocks:** Dashboard redesign, animation implementation, data binding
- **Differentiator:** Competitors show lists; we show a living cosmos

### The Problem
The current Skill Tree is static and hierarchical. psyOS philosophy requires a **dynamic, relational** visualization where:
- Facets can conflict (orbit interference)
- Facets can be neglected (cooling, erratic orbit)
- The Self is central (gravity metaphor)
- Energy states are visible (color/glow)

### Concrete Scenario: Solve This

**User Profile: Sarah**
- 5 active facets: "Super-Mom", "Career Warrior", "Fitness Fanatic", "Creative Soul", "Mindful Me"
- Current energy state: `social` (picking up kids)
- Pending transition: `social` → `high_focus` (work call in 30 min)
- Conflict detected: "Career Warrior" and "Super-Mom" (time tension score: 0.72)

**Questions to Answer:**
1. How does Sarah's Constellation look right now?
2. How is the pending transition visually indicated?
3. How is the conflict between "Career Warrior" and "Super-Mom" shown?
4. What happens to "Creative Soul" which hasn't been engaged in 2 weeks?

### Current Hypothesis (Validate or Refine)

| Element | Proposed Visualization | Confidence |
|---------|------------------------|------------|
| **Sun** | The Self (center of gravity) | HIGH |
| **Planets** | Facets (orbiting) | HIGH |
| **Planet Mass** | Habit volume / importance | MEDIUM |
| **Orbit Distance** | Integration with Core Self | LOW — needs validation |
| **Planet Color** | Energy state (focus=blue, physical=green, social=orange, recovery=purple) | MEDIUM |
| **Cooling** | Ignored facets dim/gray out | HIGH |
| **Orbit Wobble** | Neglected facets orbit erratically | MEDIUM |
| **Conflict Indicator** | Orbits that intersect/pulse red | LOW — needs design |

### Sub-Questions (Answer Each Explicitly)

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Minimal Viable Constellation:** What's the simplest version that conveys the core metaphor? | Propose v0.5 (launch) vs v1.0 (enhanced). Classify per CD-018. |
| 2 | **Data Binding:** What metrics drive each visual property (mass, distance, color, wobble)? | Provide mapping table with formulas or thresholds. |
| 3 | **Animation Performance:** How do we render 5-7 orbiting elements at 60fps on mid-range Android? | Recommend approach: Canvas, Rive, or Lottie. Cite perf benchmarks. |
| 4 | **Conflict Visualization:** How do we show facet tension without overwhelming the view? | Propose 2-3 options. Consider: orbit lines, glows, particles, gravity pulls. |
| 5 | **Neglect Indication:** How do we show "cooling" facets that need attention? | Visual + optional notification trigger. Propose thresholds. |
| 6 | **Transition Previews:** How do we hint at upcoming state changes (e.g., calendar event in 30 min)? | Propose animation or UI element. |
| 7 | **Touch Interaction:** What happens when user taps a planet (facet)? | Propose drill-down UX: habit list? stats? Council summon? |
| 8 | **Empty State:** What does Constellation look like for Day 1 user with 1 facet? | Propose progressive disclosure strategy. |

### Anti-Patterns to Avoid

- ❌ **Over-animated:** More than 3 simultaneous animations (visual noise)
- ❌ **Literal planetarium:** Astronomical accuracy over psychological metaphor
- ❌ **Dense info overlays:** Stats competing with visualization
- ❌ **Complex gestures:** Pinch-zoom, multi-touch (accessibility issues)
- ❌ **Constant motion:** Battery drain; allow "settled" state when app is static

### Output Required

1. **Constellation Design Spec:** Visual elements + data bindings + thresholds
2. **Animation Approach:** Canvas vs Rive vs Lottie recommendation with rationale
3. **Performance Budget:** Frame timing, particle limits, draw call estimates
4. **Interaction Model:** Tap, long-press, swipe behaviors
5. **Progressive Disclosure:** Day 1 → Day 7 → Day 30 visual complexity curve
6. **PD-108 Resolution:** Recommend migration strategy (Big Bang / Parallel / Progressive)

---

## Research Question 2: RQ-018 — Airlock Protocol & Identity Priming

### Core Question
How should state transitions and sensory priming be implemented?

### Why This Matters
- **Differentiator:** psyOS doesn't just remind; it **primes** for state change
- **Blocks:** JITAI integration, notification content, audio assets
- **Risk:** Mandatory rituals → user frustration → abandonment

### The Problem
Two related concepts need specification:

**Airlock Protocol:** When energy state conflict detected, insert mandatory transition ritual.
```
"You are switching from Hunter Mode (Work) to Gatherer Mode (Home).
Do not enter yet. 5-minute Box Breathing."
```

**Identity Priming:** Nudges don't just remind (Cognitive); they **prime** (Sensory).
```
Trigger: 5 mins before "Deep Work"
Audio: Personal focus mantra (user-recorded) + Binaural 40Hz
Visual: Constellation zooms to "Code Ninja" planet
Haptic: Slow pulse building to steady
```

### Concrete Scenario: Solve This

**User Profile: Marcus**
- Current state: `high_focus` (coding for 3 hours)
- Next state: `social` (family dinner in 15 min, calendar event)
- This transition is DANGEROUS (`high_focus` → `social` = cognitive residue)
- Marcus has a treaty: "Transition Airlock" requiring 5-min decompression before family time

**Questions to Answer:**
1. When and how is Marcus notified of the upcoming transition?
2. What does the Airlock experience look like/feel like?
3. What happens if Marcus dismisses/skips the Airlock?
4. How is this tracked for treaty compliance?

### Current Hypothesis (Validate or Refine)

**Airlock Options:**

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| **A: Mandatory** | Always show Airlock, no skip | Full value | User frustration |
| **B: Skippable** | Show Airlock, allow skip | User control | Undermines value |
| **C: Earned Skip** | Must complete 3x before skip unlocks | Training period | Complex UX |
| **D: Severity-Based** | Mandatory for high friction, optional for low | Intelligent | Detection complexity |
| **E: Treaty-Bound** | Only mandatory if user has active treaty | User agency | Opt-out risk |

**Identity Priming Modalities:**

| Modality | Example | Battery Impact | User Control |
|----------|---------|----------------|--------------|
| **Audio** | Focus tone, recorded mantra | Low | Volume/mute |
| **Visual** | Constellation zoom, color shift | Low | Already in-app |
| **Haptic** | Slow pulse, sharp tap | Very Low | System vibration |
| **Voice** | TTS identity affirmation | Medium | Enable/disable |

### Sub-Questions (Answer Each Explicitly)

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Trigger Detection:** How do we detect an impending state transition? | Propose detection algorithm using available Android signals. |
| 2 | **Lead Time:** How far in advance should Airlock be triggered? | Propose thresholds: 15 min? 30 min? Configurable? |
| 3 | **Minimum Viable Airlock:** What's the simplest ritual that delivers value? | Propose v0.5 (5 seconds) vs v1.0 (5 minutes). Classify per CD-018. |
| 4 | **Skip Economics:** What's the cost of skipping an Airlock? | Propose: no cost? streak impact? treaty breach? grace period? |
| 5 | **Transition Pair Matrix:** Should different state pairs have different Airlock intensities? | Provide 4×4 matrix with recommended intensity levels. |
| 6 | **Audio Asset Spec:** What audio cues are needed for priming? | List with duration, format, sourcing (stock vs custom). |
| 7 | **Haptic Pattern Spec:** What vibration patterns work for priming vs completion? | Propose Android VibrationEffect patterns with ms timings. |
| 8 | **Treaty Integration:** How does Airlock interact with existing treaty system? | Propose: separate? treaty-enabled? auto-create treaty? |
| 9 | **Measurement:** How do we know if Airlock is "working"? | Propose metrics: transition quality? user satisfaction? treaty compliance? |
| 10 | **Notification Design:** What does the Airlock notification look like? | Propose: expand to show ritual? deep link? rich media? |

### Anti-Patterns to Avoid

- ❌ **Always mandatory:** Will cause abandonment
- ❌ **Guilt messaging:** "You skipped Airlock again" (shame spiral)
- ❌ **Complex rituals:** More than 3 steps per Airlock
- ❌ **Loud audio defaults:** Jarring sounds without user opt-in
- ❌ **Ignoring context:** Airlock during driving (safety hazard)
- ❌ **No feedback loop:** User can't report "This doesn't help"

### Output Required

1. **Airlock Protocol Spec:** Trigger conditions, UX flow, skip logic
2. **PD-110 Resolution:** Recommend user control level (Mandatory/Skippable/Earned/Severity/Treaty)
3. **Transition Pair Matrix:** 4×4 matrix with Airlock intensity per pair
4. **Audio Asset List:** Sounds needed with specifications
5. **Haptic Pattern Library:** Android VibrationEffect definitions
6. **PD-112 Resolution:** Recommend audio strategy (stock/custom/user-recorded)
7. **Integration Spec:** How Airlock integrates with JITAI pipeline and treaties

---

## Product Decisions to Resolve

### PD-108: Constellation UX Migration Strategy

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| **A: Big Bang** | Replace Skill Tree with Constellation at launch | Clean cut | High risk |
| **B: Parallel** | Offer both as toggle | User choice | Maintenance |
| **C: Progressive** | Tree → Tree+Orbits → Full Constellation | Gradual | Longer |
| **D: New Users Only** | Constellation for new, Tree for existing | A/B test | Fragmented |

**Your Task:** Recommend with rationale.

### PD-110: Airlock Protocol User Control

| Option | Description |
|--------|-------------|
| **A: Mandatory** | Always show Airlock, no skip |
| **B: Skippable** | Show Airlock, allow skip |
| **C: Earned Skip** | Must complete 3x before skip unlocks |
| **D: Severity-Based** | Mandatory for high friction, optional for low |
| **E: Treaty-Bound** | Only mandatory if user has active treaty |

**Your Task:** Recommend with rationale.

### PD-112: Identity Priming Audio Strategy

| Option | Description |
|--------|-------------|
| **A: Stock Library** | Curated royalty-free sounds |
| **B: Generated** | AI-generated per user (DeepSeek V3.2 — see CD-016) |
| **C: User-Recorded** | User records their own mantras |
| **D: Hybrid** | Stock default + user override |

**Your Task:** Recommend with rationale.

**Note:** This resolution will inform RQ-026 (Sound Design & Haptic Specification) requirements.

---

## Example of Good Output: Constellation Data Binding

```dart
/// Example mapping for Constellation visualization
class ConstellationBinding {
  // Planet radius = f(habit_count, importance_weight)
  double planetRadius(IdentityFacet facet) {
    final habitCount = facet.habits.length.clamp(1, 10);
    final importance = facet.importanceWeight; // 0.0 - 1.0
    return 20.0 + (habitCount * 4) + (importance * 10);
  }

  // Orbit distance = f(integration_score, recency)
  double orbitDistance(IdentityFacet facet) {
    final integration = facet.integrationScore; // 0.0 - 1.0
    return 100.0 + ((1 - integration) * 150); // Closer = more integrated
  }

  // Planet color = energy_state
  Color planetColor(IdentityFacet facet) {
    return switch (facet.energyState) {
      'high_focus' => Colors.blue[600]!,
      'high_physical' => Colors.green[500]!,
      'social' => Colors.orange[400]!,
      'recovery' => Colors.purple[300]!,
    };
  }

  // Opacity = f(days_since_engagement)
  double planetOpacity(IdentityFacet facet) {
    final daysSince = DateTime.now().difference(facet.lastEngaged).inDays;
    if (daysSince < 3) return 1.0;
    if (daysSince < 7) return 0.8;
    if (daysSince < 14) return 0.5;
    return 0.3; // "Cooling"
  }
}
```

---

## Output Quality Criteria

Before submitting your response, verify:

| Criterion | Check |
|-----------|-------|
| **Data Bindings Specified** | Every visual property has a data source and formula |
| **Performance Addressed** | Animation approach with frame budget justification |
| **Android Constraints Met** | All signals available, haptics use VibrationEffect API |
| **Options Presented** | 2-3 options per major question with tradeoffs |
| **PDs Resolved** | Clear recommendation for PD-108, PD-110, PD-112 |
| **Anti-Patterns Avoided** | No mandatory-only Airlock, no complex gestures |
| **CD-018 Applied** | Each feature classified ESSENTIAL/VALUABLE/NICE-TO-HAVE |
| **Confidence Rated** | HIGH/MEDIUM/LOW per recommendation |

---

## Final Checklist Before Submitting

- [ ] Constellation visual spec complete with data bindings
- [ ] Animation approach recommended (Canvas/Rive/Lottie)
- [ ] Conflict visualization designed
- [ ] Neglect/cooling visualization designed
- [ ] Airlock trigger detection algorithm specified
- [ ] Transition pair matrix (4×4) provided
- [ ] Audio asset list with specifications
- [ ] Haptic patterns defined (VibrationEffect format)
- [ ] PD-108 resolved with migration strategy
- [ ] PD-110 resolved with user control recommendation
- [ ] PD-112 resolved with audio strategy
- [ ] All recommendations classified per CD-018
- [ ] All recommendations rated HIGH/MEDIUM/LOW confidence

---

*This prompt follows the DEEP_THINK_PROMPT_GUIDANCE.md quality framework.*
