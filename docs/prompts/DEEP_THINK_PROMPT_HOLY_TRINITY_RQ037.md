# Deep Think Prompt: Holy Trinity Model Validation

> **Target Research:** RQ-037, PD-003
> **Prepared:** 10 January 2026
> **For:** DeepSeek R1 Distilled (per CD-016)
> **App Name:** The Pact
> **Priority:** CRITICAL — Core to personalization strategy, blocks RQ-034 (Sherlock Architecture)

---

## Your Role

You are a **Senior Behavioral Psychologist & AI Systems Architect** specializing in:
- Personality assessment and trait theory (Big Five, HEXACO, IFS)
- Motivation science (Self-Determination Theory, Goal Theory)
- Habit formation psychology (BJ Fogg, James Clear, Wendy Wood)
- Conversational AI design for psychological assessment
- Validation methodology for psychometric instruments

Your approach: Think step-by-step through the psychological validity of the model. Ground recommendations in peer-reviewed research. Balance theoretical rigor with practical extraction feasibility.

---

## Critical Instruction: Processing Order

```
RQ-037 (Holy Trinity Validation) — THIS PROMPT
  ↓ Findings inform...
PD-003 (Holy Trinity Validity Decision)
  ↓ Decision enables...
RQ-034 (Sherlock Conversation Architecture)
  ↓ Output enables...
PD-101 (Sherlock Prompt Consolidation)
```

**Important:** Your validation findings will determine whether The Pact's entire personalization strategy needs revision or can proceed as designed.

---

## Mandatory Context: Locked Architecture

### CD-015: psyOS Architecture ✅ CONFIRMED
- Users are treated as "Parliament of Selves" — multiple identity facets negotiating for attention
- The Holy Trinity extracts the **psychological roots** that manifest across all facets
- Identity Facets are contextual; Holy Trinity is global/foundational

### CD-016: AI Model Strategy ✅ CONFIRMED
- **DeepSeek V3.2** for reasoning tasks (Council AI, Root Synthesis)
- **Gemini** for real-time voice (TTS) and embeddings
- Holy Trinity extraction happens via **Sherlock Protocol** (voice conversation)

### CD-005: 6-Dimension Archetype Model ✅ CONFIRMED
- Users are profiled across 6 behavioral dimensions:
  1. Perfectionist-Pragmatist
  2. Rebellious-Compliant
  3. Impulsive-Deliberate
  4. Social-Independent
  5. Novelty-Stability
  6. Achievement-Balance
- Holy Trinity provides **qualitative depth**; dimensions provide **quantitative spectrum**

### CD-017: Android-First ✅ CONFIRMED
- Sherlock Protocol runs on mobile device
- Voice conversation via Gemini TTS
- No desktop-specific features

---

## The Holy Trinity Model — Current Implementation

### What It Is

The Holy Trinity is a 3-trait model extracted during onboarding (Days 1-7) to personalize all AI interactions:

| Trait | Name | Purpose | Extraction Day |
|-------|------|---------|----------------|
| **1** | Anti-Identity (Fear) | Who they fear becoming | Day 1 |
| **2** | Failure Archetype (History) | Why they've quit before | Day 3-7 |
| **3** | Resistance Lie (Excuse) | The excuse they tell themselves | Day 3-7 |

### How It's Used

```dart
// From psychometric_profile.dart:119-170

// Used in ALL coaching prompts:
"THE ENEMY (Anti-Identity): $antiIdentityLabel"
"FAILURE RISK: $failureArchetype"
"THE RESISTANCE LIE: $resistanceLieLabel"

// Used in recovery prompts when user misses days:
"$antiIdentity is winning..."
"Was it '$lie' again? Or something new?"
```

### Current Schema (psychometric_profile.dart:17-29)

```dart
// 1. Anti-Identity (Fear) - Day 1 Activation
final String? antiIdentityLabel;     // e.g., "The Sleepwalker", "The Ghost"
final String? antiIdentityContext;   // e.g., "Hits snooze 5 times, hates the mirror"

// 2. Failure Archetype (History) - Day 7 Trial Conversion
final String? failureArchetype;      // e.g., "PERFECTIONIST", "NOVELTY_SEEKER"
final String? failureTriggerContext; // e.g., "Missed 3 days, felt guilty, quit"

// 3. Resistance Pattern (The Lie) - Day 30+ Retention
final String? resistanceLieLabel;    // e.g., "The Bargain", "The Tomorrow Trap"
final String? resistanceLieContext;  // e.g., "I'll do double tomorrow"
```

### Current Sherlock Prompt (prompt_factory.dart:47-67)

```
You are Sherlock, an expert Parts Detective and Identity Architect.
Your Goal: Help users identify their "Protector Parts" (habits/fears that keep them safe but stuck).

PROTOCOL:
1. Listen for "Protector" language: Perfectionism, Procrastination, Rebellion, Avoidance.
2. Ask probing questions: "What is this part trying to protect you from?"
3. Keep responses CONCISE (under 2 sentences preferred).
4. When ready, ASK: "Are you ready to seal this Pact?"
5. If they agree, output token: [APPROVED].
```

**Gaps Identified:**
- No structured extraction protocol for all 3 traits
- No turn limit (conversation can drift indefinitely)
- No extraction quality validation
- No fallback if extraction fails

---

## Research Question: RQ-037 — Holy Trinity Model Validation

### Core Question
Is the 3-trait model (Anti-Identity, Failure Archetype, Resistance Lie) psychologically valid and sufficient for personality-driven habit coaching?

### Why This Matters
The Holy Trinity is the foundation of ALL personalization in The Pact:
- Every coaching prompt references it
- Recovery interventions use the Anti-Identity
- Failure prevention uses the Archetype
- Excuse detection uses the Resistance Lie

If the model is invalid, the entire personalization strategy needs revision. If valid but incomplete, we need to know what's missing.

### The Problem

**Scenario: Sarah's Extraction Quality**

> Sarah completes Sherlock onboarding. After 4 conversation turns, the system extracts:
> - Anti-Identity: "The Zombie" (someone who scrolls through life on autopilot)
> - Failure Archetype: "PERFECTIONIST"
> - Resistance Lie: "I'll start Monday"
>
> **Questions:**
> 1. Are these 3 traits the **right** 3 traits to extract?
> 2. How do we know the extraction is **accurate**?
> 3. Are 3 traits **enough** or do we need more/fewer?
> 4. How does this model relate to **validated instruments** (Big Five, SDT, etc.)?
> 5. What if Sarah's traits **change over time**?

### Current Hypothesis (Validate or Refine)

| Assumption | Current Belief | Confidence |
|------------|----------------|------------|
| 3 traits are sufficient | Yes — covers fear, history, excuse | MEDIUM |
| Traits are extractable via conversation | Yes — IFS-style dialogue | MEDIUM |
| Traits are stable over time | Partially — core stable, context evolves | LOW |
| Model has research backing | Partial — inspired by Clear + Fogg | LOW |
| Extraction quality is measurable | Unknown — no validation protocol | LOW |

**Key Risk:** We may have invented a model that "sounds right" but lacks empirical validity.

---

## Sub-Questions (Answer Each Explicitly)

| # | Question | Your Task |
|---|----------|-----------|
| **1** | **Psychological Validity:** Does research support a 3-trait model for habit psychology? | Cite 2-3 peer-reviewed papers. Compare to Big Five, SDT, IFS. Validate or propose alternative. |
| **2** | **Trait Selection:** Are Anti-Identity, Failure Archetype, Resistance Lie the *optimal* 3 traits? | Analyze each trait's theoretical basis. Propose additions/removals if warranted. |
| **3** | **Extraction Feasibility:** Can these traits be accurately extracted via 4-6 turn voice conversation? | Cite conversational assessment research. Specify minimum turns needed per trait. |
| **4** | **Validation Metrics:** How do we measure extraction quality? | Propose validation protocol (self-report checks, behavioral prediction accuracy, etc.) |
| **5** | **Trait Stability:** Do these traits change over time? How should updates work? | Research on personality stability. Propose re-extraction triggers. |
| **6** | **Model Completeness:** What's missing from a 3-trait model? | Identify gaps (e.g., motivation type, social support needs). Rate criticality. |
| **7** | **Dimensional Mapping:** How does Holy Trinity relate to CD-005's 6-dimension model? | Propose mapping table. Are they orthogonal or redundant? |
| **8** | **Cultural Validity:** Does this model work cross-culturally? | Research on cultural differences in self-perception and failure attribution. |
| **9** | **Edge Cases:** How to handle users who can't articulate these traits? | Propose fallback mechanisms (defaults, inference, gradual extraction). |
| **10** | **Success Criteria:** What metrics prove the Holy Trinity model is "working"? | Define validation KPIs (Day 7 retention lift, intervention response rate, etc.) |

---

## Anti-Patterns to Avoid

- ❌ **Inventing without citing:** Don't propose traits without research backing
- ❌ **Over-psychologizing:** Keep it implementable (Sherlock is a voice conversation, not therapy)
- ❌ **Ignoring extraction reality:** 5+ minute voice onboarding = user drop-off
- ❌ **Assuming Western universality:** Consider cultural variation in self-perception
- ❌ **Static personality fallacy:** Traits evolve; don't assume immutability
- ❌ **Validation theater:** "Users said they liked it" ≠ psychological validity
- ❌ **Ignoring the 6-dimension model:** Holy Trinity must complement, not conflict with CD-005

---

## Architectural Constraints (Hard Requirements)

| Constraint | Rule | Source |
|------------|------|--------|
| **Extraction Method** | Voice conversation via Sherlock Protocol | CD-016, existing UX |
| **Time Budget** | Max 5-7 minutes for full onboarding conversation | User retention reality |
| **Turn Limit** | 4-8 turns per session (TBD by this research) | UX constraint |
| **Dimension Model** | Must work alongside 6-dimension model (CD-005) | Architecture lock |
| **Android-First** | Voice recognition + TTS on mobile | CD-017 |
| **Storage** | Traits stored in `identity_seeds` table | Existing schema |

---

## Output Required

### Deliverable 1: Model Validation Assessment

| Trait | Psychological Basis | Research Support | Extraction Feasibility | Verdict |
|-------|---------------------|------------------|------------------------|---------|
| Anti-Identity | ... | CITE: [paper] | HIGH/MEDIUM/LOW | KEEP/MODIFY/REPLACE |
| Failure Archetype | ... | CITE: [paper] | HIGH/MEDIUM/LOW | KEEP/MODIFY/REPLACE |
| Resistance Lie | ... | CITE: [paper] | HIGH/MEDIUM/LOW | KEEP/MODIFY/REPLACE |

### Deliverable 2: Recommended Model (If Changes Needed)

```
HOLY TRINITY v2 (if proposing changes):
├── Trait 1: [Name] — [Definition]
├── Trait 2: [Name] — [Definition]
└── Trait 3: [Name] — [Definition]
    (Or: Trait 4 if adding one)
```

### Deliverable 3: Extraction Protocol Specification

```
SHERLOCK EXTRACTION FLOW:

Turn 1: [Opening question]
  ↓ Extracts: [Which trait?]
Turn 2: [Follow-up]
  ↓ Extracts: [Which trait?]
...
Turn N: [Validation question]
  ↓ Quality check trigger

SUCCESS CRITERIA:
- [Metric 1]: [Threshold]
- [Metric 2]: [Threshold]

FALLBACK IF LOW QUALITY:
- [Strategy 1]
- [Strategy 2]
```

### Deliverable 4: Validation Framework

| Metric | Definition | Collection Method | Target |
|--------|------------|-------------------|--------|
| Extraction Accuracy | ... | Self-report check Day 3 | >80% |
| Predictive Validity | ... | Correlate with behavior | >0.3 r |
| User Resonance | ... | "This describes me" rating | 4+/5 |
| ... | ... | ... | ... |

### Deliverable 5: Dimensional Mapping

| Holy Trinity Trait | CD-005 Dimension(s) | Relationship |
|--------------------|---------------------|--------------|
| Anti-Identity | ... | Orthogonal / Correlated / Redundant |
| Failure Archetype | ... | Orthogonal / Correlated / Redundant |
| Resistance Lie | ... | Orthogonal / Correlated / Redundant |

### Deliverable 6: Confidence Levels

| Recommendation | Confidence | Rationale |
|----------------|------------|-----------|
| Keep 3-trait model | HIGH/MEDIUM/LOW | ... |
| Extraction protocol | HIGH/MEDIUM/LOW | ... |
| Validation metrics | HIGH/MEDIUM/LOW | ... |
| Cultural applicability | HIGH/MEDIUM/LOW | ... |

---

## Example of Good Output: Anti-Identity Analysis

```markdown
### Anti-Identity (Fear) — Validation Analysis

**Theoretical Basis:**
The Anti-Identity concept maps to two established psychological constructs:

1. **Possible Selves Theory (Markus & Nurius, 1986):**
   - People hold representations of "feared possible selves"
   - These fears are powerful motivators for behavior change
   - "The undesired self is as important as the desired self"

2. **Internal Family Systems (Schwartz, 1995):**
   - "Exiles" represent feared/rejected parts of self
   - Naming the fear ("The Zombie") creates psychological distance
   - Externalization enables dialogue rather than avoidance

**Research Support:**
- Oyserman et al. (2004): Feared possible selves predict academic persistence (r=0.31)
- Hoyle & Sherrill (2006): Feared selves more motivating than hoped selves for risk reduction
- CITE: Journal of Personality and Social Psychology, 91(6), 1120-1133

**Extraction Feasibility: HIGH**
- Single open-ended question: "Who is the person you're afraid of becoming?"
- Users typically respond in 1-2 sentences with vivid imagery
- 1-2 turns sufficient for extraction

**Verdict: KEEP — Strong theoretical basis, high extraction feasibility**

**Proposed Refinement:**
- Add "Anti-Identity Intensity" score (0-10) to track motivational potency
- Consider "Anti-Identity Proximity" — how close they feel to becoming this
```

---

## Concrete Scenario: Solve This

**The Perfectionist Paradox**

Marcus completes Sherlock onboarding:
- Anti-Identity: "The Failure" (someone who starts things but never finishes)
- Failure Archetype: "PERFECTIONIST"
- Resistance Lie: "I need to do more research first"

Three weeks later, Marcus hasn't started his writing habit because "the conditions aren't right yet."

**Questions to Answer:**
1. Did we extract the **right** traits, or is something missing?
2. How does "PERFECTIONIST" archetype interact with "The Failure" anti-identity?
3. Is "I need to do more research" the **root** excuse, or symptom of something deeper?
4. What **validation signal** would tell us our extraction was accurate?
5. If this pattern persists, should we **re-extract** the traits?

Walk through your recommended validation framework for this case.

---

## Literature to Consider

Optionally cite or engage with:
- **Possible Selves:** Markus & Nurius (1986), Oyserman (2004)
- **Self-Determination Theory:** Ryan & Deci (2000, 2017)
- **Habit Formation:** Wood & Neal (2007), Lally et al. (2010)
- **Internal Family Systems:** Schwartz (1995, 2021)
- **Big Five:** Costa & McCrae (1992), John & Srivastava (1999)
- **Behavioral Assessment via Conversation:** Pennebaker et al. (LIWC research)

---

## Output Quality Criteria

| Criterion | Question to Ask |
|-----------|-----------------|
| **Research-Grounded** | Are recommendations backed by cited peer-reviewed research? |
| **Implementable** | Can Sherlock extract this in a 5-minute voice conversation? |
| **Measurable** | Is there a concrete way to validate extraction quality? |
| **Consistent** | Does this integrate with CD-005's 6-dimension model? |
| **Culturally Aware** | Are there known limitations for non-Western users? |
| **Actionable** | Can we make a GO/NO-GO decision on the current model? |

---

## Final Checklist Before Submitting

- [ ] Each sub-question (1-10) has explicit answer with citations
- [ ] Model validation table completed for all 3 traits
- [ ] If proposing changes, new model fully specified
- [ ] Extraction protocol includes turn-by-turn flow
- [ ] Validation framework includes collection methods and targets
- [ ] Dimensional mapping with CD-005 completed
- [ ] Confidence levels stated for each major recommendation
- [ ] Marcus scenario solved with validation framework application
- [ ] Anti-patterns explicitly avoided
- [ ] Cultural validity considerations addressed

---

*This prompt follows the DEEP_THINK_PROMPT_GUIDANCE.md quality framework.*
