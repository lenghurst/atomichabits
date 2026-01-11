# Deep Think Prompt: Holy Trinity Model Validation (v2)

> **Target Research:** RQ-037, PD-003
> **Prepared:** 10 January 2026
> **For:** DeepSeek R1 Distilled (per CD-016)
> **App Name:** The Pact
> **Priority:** CRITICAL — Core to personalization strategy, blocks RQ-034 (Sherlock Architecture)
> **Version:** 2.0 — Improved from v1 based on DEEP_THINK_PROMPT_GUIDANCE.md audit

---

## Your Role

You are a **Senior Behavioral Psychologist & AI Systems Architect** specializing in:
- Personality assessment and trait theory (Big Five, HEXACO, IFS)
- Motivation science (Self-Determination Theory, Goal Theory)
- Habit formation psychology (BJ Fogg, James Clear, Wendy Wood)
- Conversational AI design for psychological assessment
- Validation methodology for psychometric instruments

**Your approach:** Think step-by-step through each sub-question. For each major decision point, present 2-3 options with explicit tradeoffs before recommending. Ground all recommendations in peer-reviewed research with citations. Balance theoretical rigor with practical extraction feasibility.

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

## Prior Research Summary: Completed RQs That Inform This Research

### RQ-012: Fractal Trinity ✅ COMPLETE
**Key Findings:**
- Psychology is FRACTAL — root fears manifest differently per identity facet
- The same "fear of failure" shows as perfectionism in work, procrastination in fitness
- Holy Trinity should capture ROOT psychology, not surface manifestations
- **Implication for RQ-037:** Holy Trinity traits should be GLOBAL, not facet-specific

### RQ-013: Identity Topology ✅ COMPLETE
**Key Findings:**
- Users have multiple identity facets (3-7 typical)
- Facets have tension_score (0.0-1.0) with each other
- friction_coefficient determines conflict intensity
- **Implication for RQ-037:** Holy Trinity informs HOW facets conflict, not just WHICH facets exist

### RQ-014: State Economics ✅ COMPLETE
**Key Findings:**
- 4-state energy model: high_focus, high_physical, social, recovery
- State switching has neurochemical cost (15-90 min recovery)
- **Implication for RQ-037:** Extraction timing matters — don't extract when user is depleted

### RQ-015: Polymorphic Habits ✅ COMPLETE
**Key Findings:**
- Same action serves different facets differently
- User validates "Who did this serve?" at completion
- **Implication for RQ-037:** Holy Trinity explains WHY habits fail, not just WHICH habits to track

---

## Mandatory Context: Locked Decisions

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

## Current Implementation: Code & Schema

### Dart Model (psychometric_profile.dart:17-29)

```dart
class PsychometricProfile {
  // 1. Anti-Identity (Fear) - Day 1 Activation
  final String? antiIdentityLabel;     // e.g., "The Sleepwalker", "The Ghost"
  final String? antiIdentityContext;   // e.g., "Hits snooze 5 times, hates the mirror"

  // 2. Failure Archetype (History) - Day 7 Trial Conversion
  final String? failureArchetype;      // e.g., "PERFECTIONIST", "NOVELTY_SEEKER"
  final String? failureTriggerContext; // e.g., "Missed 3 days, felt guilty, quit"

  // 3. Resistance Pattern (The Lie) - Day 30+ Retention
  final String? resistanceLieLabel;    // e.g., "The Bargain", "The Tomorrow Trap"
  final String? resistanceLieContext;  // e.g., "I'll do double tomorrow"

  // Inferred data
  final List<String> inferredFears;    // Derived from conversation
}
```

### Database Schema (identity_seeds table)

```sql
CREATE TABLE identity_seeds (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,

  -- Holy Trinity: Trait 1 (Anti-Identity)
  anti_identity_label TEXT,
  anti_identity_context TEXT,
  anti_identity_intensity FLOAT,  -- 0.0-1.0, motivational potency

  -- Holy Trinity: Trait 2 (Failure Archetype)
  failure_archetype TEXT CHECK (failure_archetype IN (
    'PERFECTIONIST', 'NOVELTY_SEEKER', 'OBLIGER', 'REBEL', 'OVERCOMMITTER'
  )),
  failure_trigger_context TEXT,

  -- Holy Trinity: Trait 3 (Resistance Lie)
  resistance_lie_label TEXT,
  resistance_lie_context TEXT,

  -- Extraction Metadata
  extraction_quality_score FLOAT,  -- 0.0-1.0, confidence in extraction
  extraction_turn_count INT,
  extracted_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(user_id)
);
```

### Sherlock Prompt (prompt_factory.dart:47-67)

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

### Prompt Usage (prompt_factory.dart:119-170)

```dart
// Used in ALL coaching prompts:
"THE ENEMY (Anti-Identity): $antiIdentityLabel"
"FAILURE RISK: $failureArchetype"
"THE RESISTANCE LIE: $resistanceLieLabel"

// Used in recovery prompts when user misses days:
"$antiIdentity is winning..."
"Was it '$lie' again? Or something new?"
```

**Gaps Identified in Current Implementation:**
- No structured extraction protocol for all 3 traits
- No turn limit (conversation can drift indefinitely)
- No extraction quality validation
- No fallback if extraction fails
- No re-extraction trigger for stale traits

---

## Resource Constraints (Quantified)

| Resource | Constraint | Budget |
|----------|------------|--------|
| **Extraction Time** | Max onboarding conversation | 5-7 minutes |
| **API Calls (Gemini TTS)** | Per extraction session | ~8-12 calls |
| **API Cost (Gemini)** | Per extraction | ~$0.01-0.02 |
| **API Calls (DeepSeek V3.2)** | For trait synthesis | 1 call |
| **API Cost (DeepSeek)** | Per synthesis | ~$0.005 |
| **Total Extraction Budget** | Per user | < $0.03 |
| **Storage** | Per user | < 1KB |
| **Turn Limit** | Max conversation turns | 4-8 (TBD by this research) |

---

## Research Question: RQ-037 — Holy Trinity Model Validation

### Core Question
Is the 3-trait model (Anti-Identity, Failure Archetype, Resistance Lie) psychologically valid and sufficient for personality-driven habit coaching?

### Why This Matters
The Holy Trinity is the foundation of ALL personalization in The Pact:
- Every coaching prompt references it (100% penetration)
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

| Assumption | Current Belief | Confidence | Research Need |
|------------|----------------|------------|---------------|
| 3 traits are sufficient | Yes — covers fear, history, excuse | MEDIUM | Validate against literature |
| Traits are extractable via conversation | Yes — IFS-style dialogue | MEDIUM | Minimum turn count |
| Traits are stable over time | Partially — core stable, context evolves | LOW | Re-extraction triggers |
| Model has research backing | Partial — inspired by Clear + Fogg | LOW | Need citations |
| Extraction quality is measurable | Unknown — no validation protocol | LOW | Define metrics |

**Key Risk:** We may have invented a model that "sounds right" but lacks empirical validity.

---

## Sub-Questions (Answer Each Explicitly)

**IMPORTANT:** For questions marked with ⚖️, present 2-3 options with explicit tradeoffs before recommending.

| # | Question | Your Task |
|---|----------|-----------|
| **1** ⚖️ | **Model Size Tradeoff:** Should we use 3 traits, 4 traits, or 2 traits? | Present 3 options: (A) Current 3-trait, (B) 4-trait with motivation type added, (C) 2-trait simplified. Analyze tradeoff: extraction complexity vs predictive validity. Recommend with citation. |
| **2** ⚖️ | **Trait Selection:** Are Anti-Identity, Failure Archetype, Resistance Lie the *optimal* traits? | Present 2-3 alternative trait combinations from research literature. Compare: Possible Selves vs IFS vs Big Five-derived traits. Recommend. |
| **3** | **Psychological Validity:** What peer-reviewed research supports each trait? | Cite 2-3 papers per trait. Map to established constructs (Possible Selves, SDT, etc.). Rate validity HIGH/MEDIUM/LOW. |
| **4** ⚖️ | **Extraction Depth vs Speed:** Deeper extraction (more turns) vs faster onboarding (fewer turns)? | Present tradeoff analysis: 4-turn vs 6-turn vs 8-turn extraction. Impact on accuracy, dropout, and cost. Recommend with data. |
| **5** | **Validation Metrics:** How do we measure extraction quality? | Propose 3+ validation methods: self-report check, behavioral prediction, test-retest reliability. Include collection method and target threshold. |
| **6** | **Trait Stability:** Do these traits change over time? How should updates work? | Research on personality stability (cite). Propose re-extraction trigger conditions. |
| **7** | **Model Completeness:** What's missing from a 3-trait model? | Identify gaps (motivation type, social support, autonomy level). Rate criticality of each gap. |
| **8** | **Dimensional Mapping:** How does Holy Trinity relate to CD-005's 6-dimension model? | Create mapping table. Analyze: orthogonal (good), correlated (acceptable), or redundant (problem)? |
| **9** | **Cultural Validity:** Does this model work cross-culturally? | Research on cultural differences in self-perception and failure attribution. Flag limitations. |
| **10** | **Edge Cases:** How to handle users who can't articulate these traits? | Propose fallback mechanisms: (A) Default assignment, (B) Behavioral inference, (C) Gradual extraction over time. |

---

## Anti-Patterns to Avoid

- ❌ **Inventing without citing:** Don't propose traits without peer-reviewed research backing
- ❌ **Over-psychologizing:** Keep it implementable (Sherlock is a 5-min voice conversation, not therapy)
- ❌ **Ignoring extraction reality:** 5+ minute voice onboarding = user drop-off risk
- ❌ **Assuming Western universality:** Consider cultural variation in self-perception
- ❌ **Static personality fallacy:** Traits evolve; don't assume immutability
- ❌ **Validation theater:** "Users said they liked it" ≠ psychological validity
- ❌ **Ignoring the 6-dimension model:** Holy Trinity must complement, not conflict with CD-005
- ❌ **Single solution:** Present options with tradeoffs, not just one answer

---

## Output Required

### Deliverable 1: Model Options Analysis

Present 2-3 trait model alternatives with tradeoffs:

| Model | Traits | Extraction Complexity | Predictive Validity | Research Basis | Recommendation |
|-------|--------|----------------------|---------------------|----------------|----------------|
| Option A: Current 3-Trait | Anti-Identity, Archetype, Lie | MEDIUM (6 turns) | [Estimate] | [Citation] | |
| Option B: 4-Trait Extended | +Motivation Type | HIGH (8 turns) | [Estimate] | [Citation] | |
| Option C: 2-Trait Minimal | Fear + Pattern | LOW (4 turns) | [Estimate] | [Citation] | |
| **RECOMMENDED** | | | | | [Why] |

### Deliverable 2: Trait Validation Assessment

| Trait | Psychological Basis | Research Support | Extraction Feasibility | Verdict |
|-------|---------------------|------------------|------------------------|---------|
| Anti-Identity | Map to construct | CITE: [paper 1], [paper 2] | HIGH/MEDIUM/LOW turns | KEEP/MODIFY/REPLACE |
| Failure Archetype | Map to construct | CITE: [paper 1], [paper 2] | HIGH/MEDIUM/LOW turns | KEEP/MODIFY/REPLACE |
| Resistance Lie | Map to construct | CITE: [paper 1], [paper 2] | HIGH/MEDIUM/LOW turns | KEEP/MODIFY/REPLACE |

### Deliverable 3: Extraction Protocol (in Dart Pseudocode)

```dart
/// Sherlock Extraction Protocol
/// Target: 6 turns, 5 minutes, 3 traits extracted
class SherlockExtractionProtocol {

  static const int MAX_TURNS = 6;
  static const Duration TARGET_DURATION = Duration(minutes: 5);

  /// Turn 1: Opening - Anti-Identity Probe
  String getTurn1Prompt() {
    return "[Opening question targeting Anti-Identity]";
  }

  /// Turn 2: Follow-up - Anti-Identity Confirmation
  String getTurn2Prompt(String userResponse) {
    // Extract Anti-Identity candidate
    return "[Follow-up to confirm Anti-Identity]";
  }

  /// Turn 3: Transition - Failure Archetype Probe
  String getTurn3Prompt() {
    return "[Question targeting past failure patterns]";
  }

  /// [Continue for all turns...]

  /// Quality Check: Validate extraction completeness
  ExtractionQuality validateExtraction(PsychometricProfile profile) {
    final completeness = _calculateCompleteness(profile);
    final confidence = _calculateConfidence(profile);

    if (completeness < 0.8 || confidence < 0.6) {
      return ExtractionQuality.needsFollowUp;
    }
    return ExtractionQuality.complete;
  }
}
```

### Deliverable 4: Validation Framework

| Metric | Definition | Collection Method | Target | Warning Threshold |
|--------|------------|-------------------|--------|-------------------|
| Extraction Completeness | % of 3 traits captured | Automated check | 100% | <80% |
| User Resonance | "This describes me" rating | Day 3 prompt | 4+/5 | <3/5 |
| Predictive Validity | Correlation with behavior | 30-day tracking | r>0.3 | r<0.2 |
| Test-Retest Reliability | Stability over 2 weeks | Re-extraction test | r>0.7 | r<0.5 |
| Intervention Response | Trait-matched msg effectiveness | A/B test | +20% engagement | <10% |

### Deliverable 5: Dimensional Mapping with CD-005

| Holy Trinity Trait | CD-005 Dimension(s) | Relationship | Implication |
|--------------------|---------------------|--------------|-------------|
| Anti-Identity | [Which dimension?] | Orthogonal / Correlated / Redundant | [What it means] |
| Failure Archetype | [Which dimension?] | Orthogonal / Correlated / Redundant | [What it means] |
| Resistance Lie | [Which dimension?] | Orthogonal / Correlated / Redundant | [What it means] |

### Deliverable 6: Re-Extraction Trigger Conditions

| Trigger | Condition | Action |
|---------|-----------|--------|
| Time-based | >90 days since extraction | Soft prompt to re-extract |
| Behavior-based | [What pattern?] | [What action?] |
| User-initiated | User requests update | Immediate re-extraction |
| Model confidence | extraction_quality_score < 0.6 | Gradual re-extraction |

### Deliverable 7: Confidence Assessment

| Recommendation | Confidence | Rationale | Follow-Up Needed |
|----------------|------------|-----------|------------------|
| Keep 3-trait model | HIGH/MEDIUM/LOW | [Cite research] | [If LOW, what research?] |
| Trait selection | HIGH/MEDIUM/LOW | [Cite research] | [If LOW, what research?] |
| Extraction protocol (6 turns) | HIGH/MEDIUM/LOW | [Cite research] | [If LOW, what research?] |
| Validation metrics | HIGH/MEDIUM/LOW | [Cite research] | [If LOW, what research?] |
| Cultural applicability | HIGH/MEDIUM/LOW | [Cite research] | [If LOW, what research?] |

---

## Example of Good Output: Trait Options Analysis

```markdown
### Model Size Tradeoff Analysis

**Option A: Current 3-Trait Model**
- Traits: Anti-Identity, Failure Archetype, Resistance Lie
- Extraction: 6 turns (~5 minutes)
- Research Basis: Possible Selves (Markus & Nurius, 1986), Goal Failure (Polivy & Herman, 2002)
- Predictive Validity Estimate: r=0.25-0.35 based on similar interventions
- Pros: Balanced complexity, proven extraction feasibility
- Cons: May miss motivation type (intrinsic vs extrinsic)

**Option B: 4-Trait Extended Model**
- Traits: +Motivation Orientation (intrinsic/extrinsic)
- Extraction: 8 turns (~7 minutes)
- Research Basis: SDT (Ryan & Deci, 2000) — motivation type predicts persistence
- Predictive Validity Estimate: r=0.35-0.45 (SDT has strong validation)
- Pros: Captures "why" behind behavior, not just "how they fail"
- Cons: +2 turns = ~15% higher dropout risk (based on onboarding research)

**Option C: 2-Trait Minimal Model**
- Traits: Anti-Identity + Failure Pattern (merge Archetype + Lie)
- Extraction: 4 turns (~3 minutes)
- Research Basis: Feared Possible Selves + Implementation Intentions
- Predictive Validity Estimate: r=0.20-0.28 (less specificity)
- Pros: Fastest extraction, lowest dropout
- Cons: Loses granularity for personalized interventions

**RECOMMENDED: Option A (Current 3-Trait) with monitoring**
- Rationale: 6 turns is the sweet spot — enough depth without excessive dropout
- Validation: Track predictive validity in production; if r<0.25, add 4th trait
- Citation: Lally et al. (2010) found that intervention specificity matters for habit formation, supporting the 3-trait granularity
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

**Walk through your recommended validation framework for Marcus:**
- Which metrics would flag this case?
- What intervention would be trait-appropriate?
- How would you update extraction_quality_score?

---

## Literature to Consider

**Required (cite at least 2-3 for each trait):**
- **Possible Selves:** Markus & Nurius (1986), Oyserman et al. (2004), Hoyle & Sherrill (2006)
- **Self-Determination Theory:** Ryan & Deci (2000, 2017)
- **Habit Formation:** Wood & Neal (2007), Lally et al. (2010)
- **Internal Family Systems:** Schwartz (1995, 2021)
- **Big Five:** Costa & McCrae (1992), John & Srivastava (1999)

**Optional (for depth):**
- **Behavioral Assessment via Conversation:** Pennebaker et al. (LIWC research)
- **Goal Abandonment:** Polivy & Herman (2002) — "What-the-Hell Effect"
- **Implementation Intentions:** Gollwitzer (1999)

---

## Output Quality Criteria

| Criterion | Question to Ask |
|-----------|-----------------|
| **Research-Grounded** | Are ALL recommendations backed by cited peer-reviewed research? |
| **Tradeoff-Aware** | Did you present 2-3 options for major decisions? |
| **Implementable** | Can Sherlock extract this in a 5-minute voice conversation? |
| **Measurable** | Is there a concrete way to validate extraction quality? |
| **Consistent** | Does this integrate with RQ-012, RQ-013, RQ-014, RQ-015 findings? |
| **Culturally Aware** | Are there known limitations for non-Western users? |
| **Actionable** | Can we make a GO/NO-GO decision on the current model? |
| **Code-Ready** | Is extraction protocol in Dart pseudocode format? |

---

## Final Checklist Before Submitting

- [ ] Each sub-question (1-10) has explicit answer with citations
- [ ] Questions marked ⚖️ have 2-3 options with tradeoff analysis
- [ ] Model options table completed (at least 3 alternatives)
- [ ] Trait validation table completed for all 3 traits with citations
- [ ] Extraction protocol provided in Dart pseudocode format
- [ ] Validation framework includes collection methods and thresholds
- [ ] Dimensional mapping with CD-005 completed
- [ ] Re-extraction triggers specified
- [ ] Confidence levels stated for each major recommendation
- [ ] Marcus scenario solved step-by-step with validation framework
- [ ] Anti-patterns explicitly avoided
- [ ] Cultural validity considerations addressed
- [ ] Integration with RQ-012, RQ-013, RQ-014, RQ-015 explicit

---

*This prompt follows the DEEP_THINK_PROMPT_GUIDANCE.md quality framework (v2 improvements applied).*
