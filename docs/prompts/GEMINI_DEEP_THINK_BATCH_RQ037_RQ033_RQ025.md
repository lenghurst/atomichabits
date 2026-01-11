# Gemini Deep Think Batch: Holy Trinity, Streak Philosophy, Token Economy

> **Target Research:** RQ-037, RQ-033, RQ-025
> **Prepared:** 10 January 2026
> **For:** Gemini 2.0 Flash Thinking (Antigravity)
> **App Name:** The Pact
> **Processing Mode:** Sequential — Complete RQ-037 first (blocks others)

---

## Instructions for Gemini

You are being asked to complete THREE interconnected research questions for a habit-tracking app called "The Pact." Process them in ORDER because RQ-037 findings inform RQ-033 and RQ-025.

**Your output style:**
- Use markdown with clear headers
- Include citations for peer-reviewed research (author, year, journal if known)
- Present 2-3 options with tradeoffs before recommending
- Rate confidence HIGH/MEDIUM/LOW for each recommendation
- Include pseudocode where specified

**Critical constraints (cannot violate):**
- CD-005: 6-dimension archetype model (Perfectionist-Pragmatist, Rebellious-Compliant, Impulsive-Deliberate, Social-Independent, Novelty-Stability, Achievement-Balance)
- CD-010: No dark patterns — user success > app engagement
- CD-015: Parliament of Selves architecture — users have multiple identity facets
- CD-016: DeepSeek V3.2 for reasoning, Gemini for real-time
- CD-017: Android-first — all features must work on mobile
- CD-018: Complexity threshold — ESSENTIAL/VALUABLE only, no OVER-ENGINEERING

---

# PART 1: RQ-037 — Holy Trinity Model Validation

## Context

The Pact extracts 3 psychological traits during onboarding to personalize all AI interactions:

| Trait | Name | Purpose | Current Extraction |
|-------|------|---------|-------------------|
| 1 | Anti-Identity | Who user fears becoming | "Who is the person you're afraid of becoming?" |
| 2 | Failure Archetype | Why they've quit before | PERFECTIONIST, NOVELTY_SEEKER, OBLIGER, REBEL, OVERCOMMITTER |
| 3 | Resistance Lie | The excuse they tell themselves | "I'll start Monday", "I need more research" |

**Current implementation:**
```dart
class PsychometricProfile {
  final String? antiIdentityLabel;     // e.g., "The Sleepwalker"
  final String? antiIdentityContext;   // e.g., "Hits snooze 5 times"
  final String? failureArchetype;      // e.g., "PERFECTIONIST"
  final String? failureTriggerContext; // e.g., "Missed 3 days, felt guilty, quit"
  final String? resistanceLieLabel;    // e.g., "The Tomorrow Trap"
  final String? resistanceLieContext;  // e.g., "I'll do double tomorrow"
}
```

## Core Question

Is the 3-trait model psychologically valid and sufficient for personality-driven habit coaching?

## Sub-Questions (Answer Each)

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Model Size:** Should we use 2, 3, or 4 traits? | Present 3 options with tradeoffs. Consider extraction time (5 min max) vs predictive validity. |
| 2 | **Trait Selection:** Are these the optimal traits? | Map each to established psychology (Possible Selves, SDT, IFS, Big Five). Cite 2+ papers per trait. |
| 3 | **Extraction Feasibility:** Can 4-6 voice conversation turns extract these accurately? | Cite conversational assessment research. Minimum turns per trait? |
| 4 | **Validation Metrics:** How do we measure extraction quality? | Propose 3+ metrics with collection methods and thresholds. |
| 5 | **Trait Stability:** Do these change over time? | When should re-extraction occur? |
| 6 | **Cultural Validity:** Does this work cross-culturally? | Flag limitations for non-Western users. |

## Required Output

1. **Model Options Table:** 3 trait-count options with extraction complexity, validity estimate, citations
2. **Trait Validation Table:** Each trait mapped to psychological construct with research support
3. **Extraction Protocol:** Turn-by-turn question flow in pseudocode
4. **Validation Framework:** Metrics table with targets
5. **Confidence Assessment:** HIGH/MEDIUM/LOW for each major recommendation

---

# PART 2: RQ-033 — Streak Philosophy & Gamification

## Context

The Pact has a tension between code and messaging:

```
CODE: Uses streaks (currentStreak, longestStreak)
MESSAGING: "Streaks are vanity metrics. We measure rolling consistency."
FORMULA: gracefulScore = (7-day average × 0.4) + (recovery bonus × 0.2) +
                          (time consistency × 0.2) + (NMT rate × 0.2)
```

**The "Never Miss Twice" (NMT) philosophy:** Missing one day is fine; missing two consecutive days breaks the habit formation.

## Core Question

Should The Pact use streak counts or rolling consistency as the primary gamification mechanic?

## Sub-Questions (Answer Each)

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Streak Psychology:** Does streak-tracking help or harm long-term habit formation? | Cite 2-3 peer-reviewed studies. Distinguish short-term engagement vs long-term automaticity. |
| 2 | **Display Strategy:** What are the viable options? | Present 3: (A) Streak-primary, (B) Consistency-primary, (C) "Resilient Streak" hybrid. Pros/cons for each. |
| 3 | **Archetype Adaptation:** How should display vary by perfectionist dimension? | HIGH perfectionist (>0.7) vs LOW perfectionist (<0.4) — different UI? |
| 4 | **Broken Streak Cliff:** What happens psychologically when streak breaks? | Research on loss aversion, "what-the-hell effect" (Polivy & Herman). |
| 5 | **Recovery Flow:** How should app respond to a miss? | Design notification + app-open experience for Day 0 and Day 1. |
| 6 | **Gamification Alternatives:** What non-streak mechanics work? | Assess: Identity Votes, Levels, Weekly Goals, Resilience Score. |

## Required Output

1. **Display Strategy Table:** 3 options with UI mockup descriptions, psychological basis, best-for-archetype
2. **Archetype-Specific Rules:** Display logic for all 6 dimensions
3. **"Resilient Streak" Specification:** If hybrid recommended, define exactly when streak resets
4. **Recovery Flow:** Day-by-day experience for perfectionist vs non-perfectionist
5. **Success Metrics:** 5+ KPIs with targets (30-day retention, NMT rate, anxiety signals)
6. **Confidence Assessment:** HIGH/MEDIUM/LOW for each recommendation

---

# PART 3: RQ-025 — Summon Token Economy

## Context

Council AI is an expensive feature (DeepSeek V3.2, $0.02-0.10 per session) that resolves conflicts between identity facets. Access rules:

- **Automatic:** When tension_score > 0.7 (no token needed)
- **Manual:** User spends Summon Token to bypass threshold

Tokens gate proactive Council access. Economy not yet designed.

## Core Question

How should the Summon Token economy balance Council access, engagement, and cost control?

## Sub-Questions (Answer Each)

| # | Question | Your Task |
|---|----------|-----------|
| 1 | **Economy Models:** What are viable token economies? | Present 3: (A) Generous, (B) Balanced, (C) Scarce. Include 90-day simulation for each. |
| 2 | **Earning Mechanics:** How are tokens earned? | Design 4-6 actions with token values, frequency caps, anti-gaming safeguards. |
| 3 | **Spending Cost:** What does Council summon cost? | 1 token? More? Justify. |
| 4 | **Token Cap:** Maximum accumulation? | No cap vs soft cap vs hard cap — analyze hoarding behavior. |
| 5 | **Token Expiry:** Do tokens expire? | Consider CD-010 (no anxiety) vs engagement. |
| 6 | **New User Bootstrap:** How do new users get first token? | Day 1 gift amount and tutorial. |
| 7 | **Anti-Gaming:** How prevent exploits? | Identify 5+ risks with safeguards. |
| 8 | **Monetization (Optional):** Should tokens be purchasable? | Present 3 options: Free-only, Optional purchase, Premium subscription. Ethical analysis. |

## Resource Constraints

- Target monthly API cost per user: < $0.50
- Average Council sessions per user: 2-3/month
- Free users must access Council 2-3x/month without payment

## Required Output

1. **Economy Model Table:** 3 models with earn rate, spend rate, 30/90-day balance projection
2. **90-Day Simulation:** For recommended model, week-by-week token flow for regular user
3. **Earning Specification:** Actions table with anti-gaming safeguards
4. **Economy Parameters:** Specific values (not ranges) for cap, expiry, gift, earn rate
5. **Onboarding Flow:** Day-by-day token introduction
6. **Health Metrics:** 6+ KPIs with targets and warning signs
7. **Confidence Assessment:** HIGH/MEDIUM/LOW for each recommendation

---

# Output Format

Structure your response as:

```
# RQ-037: Holy Trinity Validation

## Summary
[1-2 paragraph executive summary]

## Model Options Analysis
[Table + analysis]

## Trait Validation
[Table with citations]

## Extraction Protocol
[Pseudocode]

## Validation Framework
[Metrics table]

## Recommendations
[Bulleted list with confidence levels]

---

# RQ-033: Streak Philosophy

## Summary
[1-2 paragraph executive summary]

## Display Strategy Options
[Table with mockups]

## Archetype-Specific Rules
[Logic table]

## Recovery Flow Design
[Day-by-day flow]

## Recommendations
[Bulleted list with confidence levels]

---

# RQ-025: Summon Token Economy

## Summary
[1-2 paragraph executive summary]

## Economy Model Options
[Table with simulations]

## 90-Day Simulation
[Week-by-week table]

## Earning Mechanics
[Actions table]

## Recommendations
[Bulleted list with confidence levels]

---

# Cross-RQ Integration Notes

[How findings from RQ-037 affected RQ-033 and RQ-025 recommendations]
```

---

# Anti-Patterns to Avoid

- ❌ Single solution without alternatives
- ❌ Recommendations without citations
- ❌ Ignoring archetype adaptation (CD-005)
- ❌ Dark patterns or anxiety-inducing mechanics (CD-010)
- ❌ Over-engineering (CD-018)
- ❌ Assuming Western psychology is universal
- ❌ Forgetting the 5-minute extraction constraint
- ❌ Economy that costs > $0.50/month/user

---

# Success Criteria

Your output is successful if:
- [ ] Each sub-question has explicit answer with citation
- [ ] 2-3 options presented for major decisions
- [ ] Confidence levels stated (HIGH/MEDIUM/LOW)
- [ ] Archetype adaptation addressed
- [ ] Pseudocode/tables provided where requested
- [ ] Cross-RQ integration noted
- [ ] Anti-patterns explicitly avoided
- [ ] All constraints respected

---

*End of Gemini Deep Think Batch Prompt*
