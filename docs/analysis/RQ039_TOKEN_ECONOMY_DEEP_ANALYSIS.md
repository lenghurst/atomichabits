# RQ-039: Token Economy Architecture — Deep Analysis

> **Date:** 11 January 2026
> **Purpose:** Deconstruct token earning mechanism decision, expose biases, create rigorous RQ
> **Method:** SME identification → Bias analysis → SWOT → Sub-RQ formulation

---

## Part 1: Subject Matter Expert (SME) Niche Identification

The token earning mechanism spans **7 distinct SME domains**. No single expert can fully evaluate this decision.

### 1.1 SME Domain Map

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    TOKEN ECONOMY SME DOMAIN MAP                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────┐                                                         │
│  │ BEHAVIORAL      │  Token earning = incentive design                       │
│  │ ECONOMICS       │  Key Question: Does earning mechanism crowd out        │
│  │                 │  intrinsic motivation?                                  │
│  │  SMEs: Dan      │                                                         │
│  │  Ariely, Nir    │  Relevant Theories:                                     │
│  │  Eyal, BJ Fogg  │  - Overjustification Effect                             │
│  │                 │  - Token Economy Design (Kazdin, 1977)                  │
│  └────────┬────────┘  - Endowment Effect                                     │
│           │                                                                  │
│           ▼                                                                  │
│  ┌─────────────────┐                                                         │
│  │ GAME DESIGN     │  Tokens = virtual currency                              │
│  │                 │  Key Question: What's the "feel" of earning?            │
│  │  SMEs: Jane     │                                                         │
│  │  McGonigal,     │  Relevant Frameworks:                                   │
│  │  Yu-kai Chou    │  - Octalysis (8 core drives)                            │
│  │                 │  - Flow State (Csikszentmihalyi)                        │
│  │                 │  - Progression Systems Design                           │
│  └────────┬────────┘                                                         │
│           │                                                                  │
│           ▼                                                                  │
│  ┌─────────────────┐                                                         │
│  │ SUBSCRIPTION    │  Premium = token boost                                  │
│  │ ECONOMICS       │  Key Question: What drives conversion?                  │
│  │                 │                                                         │
│  │  SMEs: Patrick  │  Relevant Metrics:                                      │
│  │  Campbell,      │  - LTV:CAC ratio                                        │
│  │  Lincoln Murphy │  - Free-to-paid conversion rate (industry: 2-5%)       │
│  │                 │  - Activation metrics                                   │
│  └────────┬────────┘                                                         │
│           │                                                                  │
│           ▼                                                                  │
│  ┌─────────────────┐                                                         │
│  │ SELF-           │  Reflection = autonomy support                          │
│  │ DETERMINATION   │  Key Question: Does mandated reflection feel            │
│  │ THEORY          │  controlling or supportive?                             │
│  │                 │                                                         │
│  │  SMEs: Deci &   │  SDT Components:                                        │
│  │  Ryan, Kennon   │  - Autonomy (choice in HOW to earn)                     │
│  │  Sheldon        │  - Competence (earning feels achievable)                │
│  │                 │  - Relatedness (connection to identity)                 │
│  └────────┬────────┘                                                         │
│           │                                                                  │
│           ▼                                                                  │
│  ┌─────────────────┐                                                         │
│  │ MENTAL HEALTH   │  Tokens gate therapeutic feature                        │
│  │ APP ETHICS      │  Key Question: Is any gate on mental health             │
│  │                 │  support ethical?                                       │
│  │  SMEs: Stephen  │                                                         │
│  │  Schueller,     │  Ethical Considerations:                                │
│  │  John Torous    │  - Vulnerable population access                         │
│  │                 │  - Crisis intervention latency                          │
│  │                 │  - "Pay for therapy" perception                         │
│  └────────┬────────┘                                                         │
│           │                                                                  │
│           ▼                                                                  │
│  ┌─────────────────┐                                                         │
│  │ HABIT           │  Earning mechanism = habit loop                         │
│  │ FORMATION       │  Key Question: Does weekly cadence match                │
│  │                 │  habit formation science?                               │
│  │  SMEs: Wendy    │                                                         │
│  │  Wood, James    │  Relevant Research:                                     │
│  │  Clear          │  - Automaticity timeline (66 days avg)                  │
│  │                 │  - Cue-routine-reward loop                              │
│  │                 │  - Implementation intentions                            │
│  └────────┬────────┘                                                         │
│           │                                                                  │
│           ▼                                                                  │
│  ┌─────────────────┐                                                         │
│  │ MOBILE APP      │  Tokens = retention mechanic                            │
│  │ PRODUCT         │  Key Question: Does token scarcity drive                │
│  │                 │  retention or churn?                                    │
│  │  SMEs: Lenny    │                                                         │
│  │  Rachitsky,     │  Industry Benchmarks:                                   │
│  │  Reforge Team   │  - D1/D7/D30 retention curves                           │
│  │                 │  - Habit app retention (~10-15% D30)                    │
│  │                 │  - Mental health app retention (~5-10% D30)             │
│  └─────────────────┘                                                         │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 SME Domain Weights for This Decision

| Domain | Relevance | Why |
|--------|-----------|-----|
| **Behavioral Economics** | CRITICAL | Token earning IS incentive design |
| **Self-Determination Theory** | CRITICAL | Reflection mechanism impacts autonomy |
| **Mental Health Ethics** | HIGH | Council is therapeutic feature |
| **Subscription Economics** | HIGH | Premium model depends on this |
| **Game Design** | MEDIUM | Currency feel matters for engagement |
| **Habit Formation** | MEDIUM | Cadence affects habit building |
| **Mobile Product** | MEDIUM | Retention metrics matter |

---

## Part 2: Underlying Beliefs & Biases Analysis

### 2.1 Identified Biases in Original Recommendations

| # | Bias | How It Manifested | Validity Check |
|---|------|-------------------|----------------|
| **B1** | Pro-Reflection | Assumed reflection is inherently valuable and users will engage | ⚠️ QUESTIONABLE — Many users avoid journaling; may feel like "homework" |
| **B2** | Anti-Grinding | Framed consistency-based earning as negative "grinding" | ⚠️ QUESTIONABLE — Streaks work for many apps; is grinding actually bad? |
| **B3** | Premium-as-Acceleration | Assumed free tier must remain fully viable | ⚠️ QUESTIONABLE — Some successful apps have premium-only features |
| **B4** | CD-010 Overweight | All options filtered through "no dark patterns" constraint | ✅ VALID — This is a locked CD, appropriate to weight heavily |
| **B5** | Weekly Cadence | Assumed weekly reflection is optimal cadence | ⚠️ QUESTIONABLE — Why not daily micro? Monthly deep? |
| **B6** | 3-Token Cap | Accepted cap without questioning | ⚠️ QUESTIONABLE — Why 3? Why any cap? |
| **B7** | 0.7 Tension Threshold | Accepted crisis bypass threshold without validation | ⚠️ QUESTIONABLE — Is 0.7 the right threshold? How was it derived? |
| **B8** | Single Mechanism | Assumed users should have ONE earning path | ⚠️ QUESTIONABLE — Why not multiple options? |

### 2.2 Bias Deep Dive

#### B1: Pro-Reflection Bias

**My Assumption:** Weekly reflection → token earning builds meaning-making habit, differentiates from competitors.

**Counter-Evidence:**
- Journaling apps have notoriously low retention (~5% D30)
- "Mandatory" reflection may feel controlling (SDT: autonomy violation)
- Users seeking quick help don't want friction before access
- Competitor analysis: Headspace, Calm don't gate meditation behind journaling

**What I Missed:**
- Reflection works best when INTRINSICALLY motivated, not extrinsically rewarded
- Tying reflection to tokens may CREATE extrinsic motivation, reducing quality
- "50+ characters" minimum could produce garbage input just to earn token

**Validity:** 40% — Reflection is valuable, but mandating it may backfire.

---

#### B2: Anti-Grinding Bias

**My Assumption:** Earning tokens via 4/7 day completion is "grinding" and reinforces competitor patterns.

**Counter-Evidence:**
- Streaks are effective engagement mechanics (Duolingo, Snapchat)
- Completing habits IS the core value prop — rewarding it is logical
- "Grinding" framing is pejorative; users may experience it as "progress"
- Simpler mechanism = lower cognitive load

**What I Missed:**
- Consistency-based earning directly rewards the behavior the app exists to encourage
- Users who complete 4/7 days ARE engaged — they deserve tokens
- Reflection can be OPTIONAL bonus, not required mechanism

**Validity:** 30% — My framing was unnecessarily negative toward a proven mechanism.

---

#### B3: Premium-as-Acceleration Bias

**My Assumption:** Premium should accelerate, not gate; free tier must be fully viable.

**Counter-Evidence:**
- Many successful apps have premium-only features (Strava, Notion)
- "Fully viable free tier" may undermine premium conversion
- If free gets 1 token/week, why would anyone pay for 3?
- Industry benchmark: 2-5% free-to-paid conversion

**What I Missed:**
- Premium value must be COMPELLING, not just "faster"
- If free tier is too good, conversion suffers
- Alternative: Premium = different VALUE, not just more tokens

**Validity:** 50% — Acceleration is one model, but may not drive conversion.

---

#### B5: Weekly Cadence Bias

**My Assumption:** Weekly reflection is optimal.

**Counter-Evidence:**
- Daily micro-reflections (30 seconds) may be easier to habituate
- Monthly deep reflections may be more meaningful
- One-size-fits-all cadence ignores user preference diversity

**What I Missed:**
- Cadence should match user segment:
  - High-engagement: Daily micro
  - Moderate: Weekly standard
  - Casual: Monthly deep
- Adaptive cadence could optimize based on user behavior

**Validity:** 20% — Weekly is arbitrary; cadence should be researched.

---

#### B6: 3-Token Cap Bias

**My Assumption:** Cap at 3 prevents hoarding anxiety.

**Counter-Evidence:**
- Cap creates artificial scarcity (dark pattern adjacent?)
- Why 3? Why not 5? Why not 10?
- Cap punishes users who can't spend tokens (busy week)
- No cap + decay (1 token expires weekly) may be better

**What I Missed:**
- Cap rationale was never empirically validated
- Alternative: Soft cap (earn up to 3, can buy more) vs hard cap
- Alternative: No cap, but diminishing value (first 3 free, then pay)

**Validity:** 20% — Cap is convenient assumption, not validated design.

---

### 2.3 Bias Summary

| Bias | Original Confidence | Post-Analysis Confidence | Recommendation |
|------|--------------------|--------------------------|--------------  |
| B1: Pro-Reflection | HIGH | **LOW** | Research alternatives |
| B2: Anti-Grinding | HIGH | **LOW** | Reconsider consistency-based |
| B3: Premium-Acceleration | MEDIUM | **MEDIUM** | Test both models |
| B4: CD-010 Weight | HIGH | **HIGH** | Valid constraint |
| B5: Weekly Cadence | HIGH | **LOW** | Research optimal cadence |
| B6: 3-Token Cap | HIGH | **LOW** | Research cap alternatives |
| B7: 0.7 Threshold | HIGH | **MEDIUM** | Validate empirically |
| B8: Single Mechanism | HIGH | **LOW** | Consider multiple paths |

---

## Part 3: SWOT Analysis

### 3.1 Option A: Weekly Review Earning

| **Strengths** | **Weaknesses** |
|---------------|----------------|
| Builds reflection habit | Adds friction to Council access |
| Differentiates from competitors | May feel like "homework" |
| Produces valuable user data | Low-quality reflections likely |
| Aligns with psyOS meaning-making | Journaling apps have terrible retention |
| | 50-char minimum is gameable |

| **Opportunities** | **Threats** |
|-------------------|-------------|
| Reflection data feeds Council AI | Users churn due to friction |
| Weekly Review becomes beloved feature | Competitors don't require this — we lose |
| Builds habit of self-examination | Overjustification effect kills intrinsic motivation |
| Can evolve into premium AI insights | Users game system with garbage input |

**SWOT Verdict:** Theoretically aligned, practically risky.

---

### 3.2 Option B: Consistency-Based Earning

| **Strengths** | **Weaknesses** |
|---------------|----------------|
| Simple, clear mechanism | No reflection benefit |
| Rewards actual habit completion | "Just another streak app" |
| Low cognitive load | Doesn't differentiate |
| Proven engagement mechanic | May feel like grinding |
| | No data beyond completions |

| **Opportunities** | **Threats** |
|-------------------|-------------|
| Easy to implement and iterate | Undifferentiated in market |
| Can add reflection as bonus later | Users expect this — not surprising |
| Low friction = higher adoption | Doesn't build deeper engagement |
| | CD-010 compliant but uninspired |

**SWOT Verdict:** Safe but undifferentiated.

---

### 3.3 Option C: Subscription = Unlimited

| **Strengths** | **Weaknesses** |
|---------------|----------------|
| Clear premium value prop | Free tier feels second-class |
| Predictable revenue | No token economy for premium users |
| Simple implementation | May feel like paywall on therapy |
| Premium users never frustrated | | |

| **Opportunities** | **Threats** |
|-------------------|-------------|
| High conversion if Council is valuable | Ethical backlash: "paying for mental health" |
| Subscription = predictable MRR | Free users churn, premium users don't need tokens |
| Focus dev on premium experience | CD-010 tension: is this dark? |
| | Competitors may offer unlimited free |

**SWOT Verdict:** Good business model, ethical risk.

---

### 3.4 Option D: Hybrid (My Original Recommendation)

| **Strengths** | **Weaknesses** |
|---------------|----------------|
| Balances reflection + monetization | Most complex to implement |
| Free tier remains viable | Premium value may feel weak (just "more") |
| CD-010 compliant | Users confused by two earning paths |
| Premium accelerates, doesn't gate | Still has reflection friction |

| **Opportunities** | **Threats** |
|-------------------|-------------|
| Can tune ratios based on data | Complexity leads to bugs |
| Reflection data + revenue | Neither free nor premium users fully satisfied |
| Both segments feel valued | May need to simplify post-launch |
| | Harder to explain in marketing |

**SWOT Verdict:** Theoretically best, practically complex.

---

### 3.5 NEW Option E: Multiple Earning Paths (User Choice)

Based on bias analysis, proposing a NEW option:

| **Strengths** | **Weaknesses** |
|---------------|----------------|
| User autonomy (SDT alignment) | Implementation complexity |
| Multiple paths = multiple motivations | Harder to balance |
| Reduces single-path friction | Marketing confusion |
| Each user optimizes for preference | Testing requires more users |

| **Opportunities** | **Threats** |
|-------------------|-------------|
| Personalization differentiator | Users may game easiest path |
| Can analyze which paths work | Complexity = bugs |
| Iterate based on usage data | May need to deprecate underused paths |
| | "Paradox of choice" — too many options |

**SWOT Verdict:** High autonomy, high complexity.

---

## Part 4: Improvement Recommendations

### 4.1 Recommended Earning Path Options (User Choice Model)

Instead of picking ONE mechanism, offer users a CHOICE:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    EARN YOUR COUNCIL SEAL                                    │
│                                                                              │
│   Choose how you'd like to earn tokens this week:                           │
│                                                                              │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │  📝 REFLECT                                                          │   │
│   │  Write a 2-minute reflection on your week                           │   │
│   │  Reward: 1 Council Seal                                              │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │  🔥 CONSISTENCY                                                      │   │
│   │  Complete any habit 4+ days this week                               │   │
│   │  Reward: 1 Council Seal                                              │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │  💎 PREMIUM                                                          │   │
│   │  Subscribe for 3 Seals/week auto-granted                            │   │
│   │  Reward: 3 Council Seals + reflection bonus                         │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.2 Sub-RQ Structure for Full Research

Given the complexity and bias exposure, this decision requires **systematic research** before implementation.

---

## Part 5: Proposed RQ-039 Structure

### RQ-039: Token Economy Architecture

> **Status:** 🔴 NEEDS RESEARCH
> **Priority:** HIGH
> **Blocking:** E-12 (Token earning logic), PD-119 resolution
> **Dependencies:** None

#### Master Question

**How should users earn Council Seals (tokens) in a way that is psychologically sound, ethically compliant, and commercially viable?**

#### Sub-RQs

| Sub-RQ | Question | SME Domain | Priority |
|--------|----------|------------|----------|
| **RQ-039a** | What earning mechanism(s) maximize intrinsic motivation while avoiding overjustification effect? | Behavioral Economics, SDT | CRITICAL |
| **RQ-039b** | What is the optimal reflection cadence (daily/weekly/monthly) for different user segments? | Habit Formation | HIGH |
| **RQ-039c** | Should users have ONE earning path or MULTIPLE choice-based paths? | Game Design, SDT | HIGH |
| **RQ-039d** | What token cap (or decay mechanism) balances scarcity without creating anxiety? | Behavioral Economics | HIGH |
| **RQ-039e** | What Crisis Bypass threshold (currently 0.7) is clinically appropriate? | Mental Health Ethics | HIGH |
| **RQ-039f** | What premium token allocation creates compelling conversion without ethical risk? | Subscription Economics | MEDIUM |
| **RQ-039g** | What quality thresholds prevent gaming of reflection-based earning? | Product Design | MEDIUM |

---

### RQ-039a: Earning Mechanism & Intrinsic Motivation

**Question:** What earning mechanism(s) maximize intrinsic motivation while avoiding overjustification effect?

**Background:**
- Overjustification effect (Deci, 1971): External rewards can REDUCE intrinsic motivation
- Token economies can work OR backfire depending on design
- Reflection tied to reward may produce low-quality, extrinsically-motivated reflections

**Research Approach:**
1. Literature review: Token economy design in therapeutic contexts
2. Competitor analysis: How do mental health apps handle premium gating?
3. User interviews: What motivates users to reflect? Does reward help or hurt?

**Decision Criteria:**
- Does the mechanism INCREASE reflection quality over no-reward baseline?
- Does the mechanism maintain engagement at D30?
- Is the mechanism CD-010 compliant?

**Output:** Recommended earning mechanism with empirical rationale

---

### RQ-039b: Optimal Reflection Cadence

**Question:** What is the optimal reflection cadence (daily/weekly/monthly) for different user segments?

**Background:**
- Weekly assumed but never validated
- Daily micro-reflections (30 sec) may habituate faster
- Monthly deep reflections may be more meaningful but less frequent

**Research Approach:**
1. Literature review: Journaling cadence research
2. A/B test design: Daily vs weekly vs monthly in controlled pilot
3. User segment analysis: Does cadence preference correlate with archetype?

**Decision Criteria:**
- Which cadence produces highest completion rate?
- Which cadence produces highest QUALITY reflections?
- Which cadence correlates with D30 retention?

**Output:** Recommended cadence per user segment (or adaptive system)

---

### RQ-039c: Single vs Multiple Earning Paths

**Question:** Should users have ONE earning path or MULTIPLE choice-based paths?

**Background:**
- Original analysis assumed single mechanism
- SDT suggests choice increases autonomy → engagement
- But paradox of choice (Schwartz) suggests too many options → paralysis

**Research Approach:**
1. Literature review: Choice architecture in gamification
2. Competitor analysis: Do any apps offer earning path choice?
3. Mockup testing: User preference for choice vs simplicity

**Decision Criteria:**
- Does choice increase or decrease completion rate?
- Does choice increase or decrease satisfaction?
- What's the implementation complexity tradeoff?

**Output:** Single mechanism vs 2-3 path choice recommendation

---

### RQ-039d: Token Cap vs Decay Alternatives

**Question:** What token cap (or decay mechanism) balances scarcity without creating anxiety?

**Background:**
- 3-token cap assumed but not validated
- Cap may create anxiety ("I have to spend before I lose earning opportunity")
- Alternative: No cap, but tokens decay (use-it-or-lose-it weekly)
- Alternative: Soft cap (earn up to 3 free, buy more)

**Research Approach:**
1. Literature review: Virtual currency design best practices
2. Economy simulation: Model different cap/decay scenarios
3. User testing: Which model feels fairest?

**Decision Criteria:**
- Does the mechanism create anxiety (dark pattern)?
- Does the mechanism encourage healthy engagement?
- Does the mechanism support conversion to premium?

**Output:** Cap, no-cap, or decay recommendation with rationale

---

### RQ-039e: Crisis Bypass Threshold Validation

**Question:** What Crisis Bypass threshold (currently 0.7) is clinically appropriate?

**Background:**
- 0.7 tension score assumed as crisis threshold
- Tension score formula not clinically validated
- False negatives (user in crisis, score < 0.7) could be harmful
- False positives (user not in crisis, score > 0.7) waste resources

**Research Approach:**
1. Clinical literature review: Crisis detection in mental health apps
2. Tension score formula audit: What inputs, what weights?
3. Sensitivity analysis: What thresholds minimize false negatives?

**Decision Criteria:**
- Minimize false negative rate (user needs help but doesn't get bypass)
- Acceptable false positive rate (user gets free access when not needed)
- Clinical appropriateness for non-therapist context

**Output:** Validated threshold OR alternative crisis detection mechanism

---

### RQ-039f: Premium Token Allocation

**Question:** What premium token allocation creates compelling conversion without ethical risk?

**Background:**
- Current proposal: 3 tokens/week for premium vs 1 for free
- Is 3x enough to drive conversion?
- Is unlimited better for premium satisfaction?
- How does allocation affect free tier perception?

**Research Approach:**
1. Subscription economics literature: What ratios drive conversion?
2. Competitor analysis: What do successful apps offer premium users?
3. Willingness-to-pay research: What would users pay for Council access?

**Decision Criteria:**
- Conversion rate: Does allocation drive 2-5% free-to-paid?
- Churn rate: Does allocation reduce premium churn?
- Ethical: Does allocation feel fair to free users?

**Output:** Recommended premium allocation with pricing sensitivity

---

### RQ-039g: Reflection Quality Thresholds

**Question:** What quality thresholds prevent gaming of reflection-based earning?

**Background:**
- 50+ characters is easily gamed ("This week was good good good good good")
- Higher bar may reduce completion
- AI quality check may be overkill

**Research Approach:**
1. Literature review: Reflection quality measurement
2. Heuristic design: Character count + word diversity + sentiment variance
3. A/B test: Minimum bar vs AI quality gate vs no gate

**Decision Criteria:**
- Gaming rate: What % of reflections are low-quality?
- Completion rate: Does quality gate reduce reflection attempts?
- AI cost: Is AI quality check worth the API cost?

**Output:** Recommended quality threshold with implementation spec

---

## Part 6: Revised Recommendation

### Original Recommendation (Biased)

> Option D (Hybrid): Free gets 1/week via reflection; Premium gets 3/week auto + bonus.

### Revised Recommendation (Post-Bias Analysis)

> **DEFER DECISION** until RQ-039 sub-questions are researched.

**Rationale:**
1. My original recommendation was heavily biased toward reflection-based earning without validating the assumption
2. Consistency-based earning was unfairly dismissed as "grinding"
3. Weekly cadence was assumed without research
4. 3-token cap was accepted without validation
5. Multiple earning paths (user choice) were not considered

**Immediate Action:**
- Create RQ-039 with 7 sub-RQs
- Prioritize RQ-039a (mechanism) and RQ-039e (crisis threshold) as CRITICAL
- Design A/B test framework for cadence and mechanism
- Proceed with MVP using SIMPLEST mechanism (consistency-based) pending research

**MVP Fallback:**
If research cannot be completed before launch, use **Option B (Consistency)** as it is:
- Simplest to implement
- Proven in market
- CD-010 compliant
- Can layer reflection as OPTIONAL bonus post-launch

---

## Part 7: Deep Think Prompt for RQ-039

### Recommended External Research Prompt

```
CONTEXT:
The Pact is a psychological operating system (psyOS) that treats users as a
"Parliament of Selves" — multiple identity facets negotiating for attention.
Council AI is a therapeutic feature where AI-generated facets discuss the user's goals.
Users need tokens ("Council Seals") to summon the Council.

CURRENT ASSUMPTION (UNVALIDATED):
- Users earn 1 token/week by completing a 50+ character reflection
- Cap at 3 tokens, no expiry
- Crisis Bypass: Free access when tension > 0.7

BIASES IDENTIFIED:
1. Pro-Reflection: Assumed reflection is inherently good; may be friction
2. Anti-Grinding: Framed consistency-based earning negatively
3. Weekly Cadence: Assumed weekly is optimal; not researched
4. 3-Token Cap: Accepted without validation

QUESTIONS FOR RESEARCH:

1. EARNING MECHANISM
   - What does behavioral economics research say about token economy design
     in therapeutic contexts?
   - How do mental health apps (Woebot, Wysa, Youper) handle premium gating?
   - What is the overjustification effect and how do we avoid it?

2. REFLECTION CADENCE
   - What does journaling research say about optimal cadence?
   - Should cadence be fixed (weekly) or adaptive (based on user behavior)?
   - What's the minimum viable reflection (30 sec? 2 min? 5 min?)?

3. MULTIPLE EARNING PATHS
   - Does offering choice (reflect OR consistency) increase autonomy (SDT)?
   - Does paradox of choice apply? How many options is too many?
   - Are there apps that offer earning path choice successfully?

4. TOKEN CAP/DECAY
   - What's the psychological impact of caps vs decay in virtual currencies?
   - Does scarcity drive engagement or anxiety?
   - What cap/decay model is CD-010 compliant (no artificial urgency)?

5. CRISIS BYPASS
   - What's the clinical standard for crisis detection in non-therapist contexts?
   - What false negative rate is acceptable for crisis bypass?
   - Should crisis bypass be tension-based or user-initiated ("I need help now")?

OUTPUT REQUESTED:
- Evidence-based recommendation for each question
- Cite peer-reviewed sources where available
- Flag where expert clinical review is needed
- Provide implementation spec if possible
```

---

## Summary

| Element | Original | Revised |
|---------|----------|---------|
| **Recommendation** | Option D (Hybrid) | **DEFER** pending RQ-039 |
| **Confidence** | HIGH | **LOW** — too many unvalidated assumptions |
| **MVP Fallback** | — | Option B (Consistency) |
| **Research Required** | None assumed | 7 sub-RQs identified |
| **Bias Count** | 0 acknowledged | 8 identified |

**Key Insight:** The original recommendation was confident but fragile. Exposing biases reveals that this decision requires systematic research, not intuition.

---

*Analysis complete. RQ-039 structure ready for governance integration.*
